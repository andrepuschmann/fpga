
`define DSP_CORE_TX_BASE 128

module tx_control
  #(parameter FIFOSIZE = 10)
    (input clk, input rst,
     input set_stb, input [7:0] set_addr, input [31:0] set_data,
     
     input [31:0] master_time, 
     output underrun,
     
     // To Buffer interface
     input [31:0] rd_dat_i,
     input rd_sop_i,
     input rd_eop_i,
     output rd_read_o,
     output rd_done_o,
     output rd_error_o,
     
     // To DSP Core
     output [31:0] sample,
     output run,
     input strobe,

     // FIFO Levels
     output [15:0] fifo_occupied,
     output fifo_full,
     output fifo_empty,

     // Debug
     output [31:0] debug
     );

   // Buffer interface to internal FIFO
   wire     write_data, write_ctrl, full_data, full_ctrl;
   wire     read_data, read_ctrl, empty_data, empty_ctrl;
   wire     clear_state;
   reg [1:0] xfer_state;
   reg [2:0] held_flags;
   
   localparam XFER_IDLE = 0;
   localparam XFER_1 = 1;
   localparam XFER_2 = 2;
   localparam XFER_DATA = 3;
   
   always @(posedge clk)
     if(rst)
       xfer_state <= XFER_IDLE;
     else
       if(clear_state)
	 xfer_state <= XFER_IDLE;
       else
	 case(xfer_state)
	   XFER_IDLE :
	     if(rd_sop_i)
	       xfer_state <= XFER_1;
	   XFER_1 :
	     begin
		xfer_state <= XFER_2;
		held_flags <= rd_dat_i[2:0];
	     end
	   XFER_2 :
	     if(~full_ctrl)
	       xfer_state <= XFER_DATA;
	   XFER_DATA :
	     if(rd_eop_i & ~full_data)
	       xfer_state <= XFER_IDLE;
	 endcase // case(xfer_state)
   
   assign write_data = (xfer_state == XFER_DATA) & ~full_data;
   assign write_ctrl = (xfer_state == XFER_2) & ~full_ctrl;

   assign rd_read_o = (xfer_state == XFER_1) | write_data | write_ctrl;
   assign rd_done_o = 0;  // Always take everything we're given
   assign rd_error_o = 0;  // Should we indicate overruns here?
   
   wire [31:0] data_o;
   wire        sop_o, eop_o, eob, sob, send_imm;
   wire [31:0] sendtime;
   wire [4:0]  occ_ctrl;
   
   cascadefifo2 #(.WIDTH(34),.SIZE(FIFOSIZE)) txctrlfifo
     (.clk(clk),.rst(rst),.clear(clear_state),
      .datain({rd_sop_i,rd_eop_i,rd_dat_i}), .write(write_data), .full(full_data),
      .dataout({sop_o,eop_o,data_o}), .read(read_data), .empty(empty_data),
      .space(), .occupied(fifo_occupied) );
   assign      fifo_full = full_data;
   assign      fifo_empty = empty_data;

   shortfifo #(.WIDTH(35)) ctrlfifo
     (.clk(clk),.rst(rst),.clear(clear_state),
      .datain({held_flags[2:0],rd_dat_i}), .write(write_ctrl), .full(full_ctrl),
      .dataout({send_imm,sob,eob,sendtime}), .read(read_ctrl), .empty(empty_ctrl),
      .space(), .occupied(occ_ctrl) );

   // Internal FIFO to DSP interface
   reg [2:0]   ibs_state;
   
   localparam  IBS_IDLE = 0;
   localparam  IBS_WAIT = 1;
   localparam  IBS_RUNNING = 2;
   localparam  IBS_CONT_BURST = 3;
   localparam  IBS_UNDERRUN = 7;

   wire [32:0] delta_time = {1'b0,sendtime}-{1'b0,master_time};
   
   wire        too_late = (delta_time[32:31] == 2'b11);
   wire        go_now = ( master_time == sendtime );
   
   always @(posedge clk)
     if(rst)
       ibs_state <= IBS_IDLE;
     else
       case(ibs_state)
	 IBS_IDLE :
	   if(~empty_ctrl & ~empty_data)
	     ibs_state <= IBS_WAIT;
	 IBS_WAIT :
	   if(send_imm)
	     ibs_state <= IBS_RUNNING;
	   else if(too_late)
	     ibs_state <= IBS_UNDERRUN;
	   else if(go_now)
	     ibs_state <= IBS_RUNNING;
	 IBS_RUNNING :
	   if(strobe)
	     if(empty_data)
	       ibs_state <= IBS_UNDERRUN;
	     else if(eop_o)
	       if(eob)
		 ibs_state <= IBS_IDLE;
	       else
		 ibs_state <= IBS_CONT_BURST;
	 IBS_CONT_BURST :
	   if(~empty_ctrl)  //  & ~empty_data)
	     ibs_state <= IBS_RUNNING;
	   else if(strobe)
	     ibs_state <= IBS_UNDERRUN;
	 IBS_UNDERRUN :   // FIXME Should probably clean everything out
	   if(clear_state)
	     ibs_state <= IBS_IDLE;
       endcase // case(ibs_state)

   assign      read_ctrl = (ibs_state == IBS_RUNNING) & strobe & eop_o;  // & ~empty_ctrl;
   assign      read_data = (ibs_state == IBS_RUNNING) & strobe & ~empty_data;
   assign      run = (ibs_state == IBS_RUNNING) | (ibs_state == IBS_CONT_BURST);
   assign      underrun = (ibs_state == IBS_UNDERRUN);

   wire [7:0]  interp_rate;
   setting_reg #(.my_addr(`DSP_CORE_TX_BASE+3)) sr_3
     (.clk(clk),.rst(rst),.strobe(set_stb),.addr(set_addr),
      .in(set_data),.out(),.changed(clear_state));

   assign      sample = data_o;

   assign      debug = { {16'b0},
			 { read_data, write_data, read_ctrl, write_ctrl, xfer_state[1:0],full_ctrl,empty_ctrl },
			 { occ_ctrl, eop_o, clear_state, underrun} };
   
endmodule // tx_control