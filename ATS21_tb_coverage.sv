/*

Andrew Denzer and Zack Fravel
ECE593 Assignment 1
Spring 2021

ATS21_tb_coverage.sv
--------------------
Description:


*/

////////////////////////////////////////////////////
////////// Module and Signal Declarations //////////
////////////////////////////////////////////////////

timeunit 1ns/1ns;

module ATS21_tb_coverage();

// Parameters
parameter clock_width = 16;
parameter num_alarms = 24;
parameter num_clocks = 16;
parameter num_clocks_bits = $clog2(num_clocks);

// DUT Signals
logic clk, reset, req, ready;
logic [1:0] stat;
logic [15:0] ctrlA, ctrlB;
logic [ 2:0] ctrlA_opcode_in, ctrlB_opcode_in;
logic [23:0] data;


logic [num_clocks-1:0]				BC_enable;
logic [num_clocks-1:0][15:0]	BC_count;
logic [num_clocks-1:0][1:0] 	BC_rate;

genvar i;
generate
	for (i = 0; i < num_clocks; i++)
	 begin
		 assign BC_enable[i] = dut.base_clocks[i].enable;
		 assign BC_count[i] = dut.base_clocks[i].count;
		 assign BC_rate[i] = dut.base_clocks[i].rate;
	 end
endgenerate

logic [num_alarms-1:0] alarm_enable;
logic [num_alarms-1:0] alarm_countdown;
logic [num_alarms-1:0] alarm_loop;
logic [num_alarms-1:0][num_clocks_bits-1:0] alarm_assigned_clock;
logic [num_alarms-1:0][15:0] alarm_value;
logic [num_alarms-1:0] alarm_finished;

genvar k;
generate
	for (k = 0; k < num_alarms; k++)
	 begin
		 assign alarm_enable[k] = dut.alarms[k].enable;
		 assign alarm_countdown[k] = dut.alarms[k].countdown;
		 assign alarm_loop[k] = dut.alarms[k].loop;
		 assign alarm_assigned_clock[k] = dut.alarms[k].assigned_clock;
		 assign alarm_value[k] = dut.alarms[k].value;
		 assign alarm_finished[k] = dut.alarms[k].finished;
	 end
endgenerate


logic cr_device_enable;
logic cr_clientA_clock, cr_clientB_clock;
logic cr_clientA_alarm, cr_clientB_alarm;

assign cr_device_enable = dut.cr_bits.active;
assign cr_clientA_clock = dut.cr_bits.clientA_clock;
assign cr_clientB_clock = dut.cr_bits.clientB_clock;
assign cr_clientA_alarm = dut.cr_bits.clientA_alarm;
assign cr_clientB_alarm = dut.cr_bits.clientB_alarm;


// Testbench Signals
logic [$clog2(num_alarms):0] all_alarms;

// Instantiate DUT
ATS21 dut(.clk(clk), .reset(reset), .req(req), .ctrlA(ctrlA), .ctrlB(ctrlB),
			.ready(ready), .stat(stat), .data(data));

// Reference Clock Generator
always begin
	#1 clk = ~clk;
end

always_ff @(posedge clk) begin : add_alarms
	all_alarms <= data[0] + data[1] + data[2] + data[3] + data[4] + data[5] + data[6] + data[7] + data[8] + data[9] + data[10]
				+ data[11] + data[12] + data[13] + data[14] + data[15] + data[16] + data[17] + data[18] + data[19] + data[20]
				+ data[21] + data[22] + data[23];
end

///////////////////////////////////////
////////// Testbench Simulus //////////
///////////////////////////////////////

assign ctrlA_opcode_in = ctrlA[15:13];
assign ctrlB_opcode_in = ctrlB[15:13];
assign sameOpcode = (ctrlA_opcode_in == ctrlB_opcode_in) && req;
assign ABsameTime = (ctrlA_opcode_in != 3'b000 && ctrlB_opcode_in != 3'b000) && req;


///////////////////////////////////////
///////////// Cover Groups ////////////
///////////////////////////////////////
covergroup ats21_input @(posedge clk);
	// opcode input
	coverpoint ctrlA_opcode_in iff req {
		bins set_BC              = {3'b001};
		bins toggle_BC           = {3'b010};
		bins set_AT              = {3'b101};
		bins set_Countdown       = {3'b110};
		bins toggle_AT           = {3'b111};
		bins set_ATS21_mode      = {3'b011};
		bins invalid_instruction = default;
	}

	coverpoint ctrlB_opcode_in iff req {
		bins set_BC              = {3'b001};
		bins toggle_BC           = {3'b010};
		bins set_AT              = {3'b101};
		bins set_Countdown       = {3'b110};
		bins toggle_AT           = {3'b111};
		bins set_ATS21_mode      = {3'b011};
		bins invalid_instruction = default;
	}

	coverpoint req {
		bins recieve_instruction[]       = (1'b0 => 1'b1);
		bins active                      = {1'b1};
		bins active_two_or_more_cycles[] = (1'b0 => 1'b1[*2]);
		bins inactive                    = default;
	}

	coverpoint sameOpcode;		// if ctrlA and ctrlB input instruction have same opcode
	coverpoint ABsameTime;		// if ctrlA and ctrlB send valid instruction at same time
endgroup	// ats21_input


covergroup ats21_instructions @(posedge clk);

	checkInst_ctrlA: coverpoint dut.checkInst.ctrlA{
		bins nop								     = { [32'h00000000:32'h1FFFFFFF] };
		bins set_BC[64]              = { [32'h20000000:32'h3FFFFFFF] };
		bins toggle_BC[64]           = { [32'h40000000:32'h4FFFFFFF] };
		bins set_AT[64]              = { [32'hA0000000:32'hAFFFFFFF] };
		bins set_Countdown[64]       = { [32'hC0000000:32'hCFFFFFFF] };
		bins toggle_AT[64]           = { [32'hE0000000:32'hEFFFFFFF] };
		bins set_ATS21_mode[64]      = { [32'h30000000:32'h3FFFFFFF] };
		bins invalid_instruction     = default;
	}

	checkInst_ctrlB: coverpoint dut.checkInst.ctrlB{
		bins nop								     = { [32'h00000000:32'h1FFFFFFF] };
		bins set_BC[64]              = { [32'h20000000:32'h3FFFFFFF] };
		bins toggle_BC[64]           = { [32'h40000000:32'h4FFFFFFF] };
		bins set_AT[64]              = { [32'hA0000000:32'hAFFFFFFF] };
		bins set_Countdown[64]       = { [32'hC0000000:32'hCFFFFFFF] };
		bins toggle_AT[64]           = { [32'hE0000000:32'hEFFFFFFF] };
		bins set_ATS21_mode[64]      = { [32'h30000000:32'h3FFFFFFF] };
		bins invalid_instruction     = default;
	}

	checkInst_crtlA_X_ctrlB: cross checkInst_ctrlA, checkInst_ctrlB;


	// Coverage is missing when Opcode is 000, but not all the time
	processInst_ctrlA: coverpoint dut.processInst.ctrlA{
		bins nop								     = { [32'h00000000:32'h1FFFFFFF] };
		bins set_BC[64]              = { [32'h20000000:32'h3FFFFFFF] };
		bins toggle_BC[64]           = { [32'h40000000:32'h4FFFFFFF] };
		bins set_AT[64]              = { [32'hA0000000:32'hAFFFFFFF] };
		bins set_Countdown[64]       = { [32'hC0000000:32'hCFFFFFFF] };
		bins toggle_AT[64]           = { [32'hE0000000:32'hEFFFFFFF] };
		bins set_ATS21_mode[64]      = { [32'h30000000:32'h3FFFFFFF] };
		bins invalid_instruction     = default;
	}

	processInst_ctrlB: coverpoint dut.processInst.ctrlB{
		bins nop								     = { [32'h00000000:32'h1FFFFFFF] };
		bins set_BC[64]              = { [32'h20000000:32'h3FFFFFFF] };
		bins toggle_BC[64]           = { [32'h40000000:32'h4FFFFFFF] };
		bins set_AT[64]              = { [32'hA0000000:32'hAFFFFFFF] };
		bins set_Countdown[64]       = { [32'hC0000000:32'hCFFFFFFF] };
		bins toggle_AT[64]           = { [32'hE0000000:32'hEFFFFFFF] };
		bins set_ATS21_mode[64]      = { [32'h30000000:32'h3FFFFFFF] };
		bins invalid_instruction     = default;
	}

	processInst_crtlA_X_ctrlB: cross processInst_ctrlA, processInst_ctrlB;
endgroup // ats21_instructions


covergroup ats21_BCs @(posedge clk);
	BC0_enable: coverpoint BC_enable[0];
	BC0_count: coverpoint BC_count[0];
	BC0_rate: coverpoint BC_rate[0];
	BC0_cross : cross BC0_enable, BC0_count, BC0_rate;

	BC1_enable: coverpoint BC_enable[1];
	BC1_count: coverpoint BC_count[1];
	BC1_rate: coverpoint BC_rate[1];
	BC1_cross : cross BC1_enable, BC1_count, BC1_rate;

	BC2_enable: coverpoint BC_enable[2];
	BC2_count: coverpoint BC_count[2];
	BC2_rate: coverpoint BC_rate[2];
	BC2_cross : cross BC2_enable, BC2_count, BC2_rate;

	BC3_enable: coverpoint BC_enable[3];
	BC3_count: coverpoint BC_count[3];
	BC3_rate: coverpoint BC_rate[3];
	BC3_cross : cross BC3_enable, BC3_count, BC3_rate;

	BC4_enable: coverpoint BC_enable[4];
	BC4_count: coverpoint BC_count[4];
	BC4_rate: coverpoint BC_rate[4];
	BC4_cross : cross BC4_enable, BC4_count, BC4_rate;

	BC5_enable: coverpoint BC_enable[5];
	BC5_count: coverpoint BC_count[5];
	BC5_rate: coverpoint BC_rate[5];
	BC5_cross : cross BC5_enable, BC5_count, BC5_rate;

	BC6_enable: coverpoint BC_enable[6];
	BC6_count: coverpoint BC_count[6];
	BC6_rate: coverpoint BC_rate[6];
	BC6_cross : cross BC6_enable, BC6_count, BC6_rate;

	BC7_enable: coverpoint BC_enable[7];
	BC7_count: coverpoint BC_count[7];
	BC7_rate: coverpoint BC_rate[7];
	BC7_cross : cross BC7_enable, BC7_count, BC7_rate;

	BC8_enable: coverpoint BC_enable[8];
	BC8_count: coverpoint BC_count[8];
	BC8_rate: coverpoint BC_rate[8];
	BC8_cross : cross BC8_enable, BC8_count, BC8_rate;

	BC9_enable: coverpoint BC_enable[9];
	BC9_count: coverpoint BC_count[9];
	BC9_rate: coverpoint BC_rate[9];
	BC9_cross : cross BC9_enable, BC9_count, BC9_rate;

	BC10_enable: coverpoint BC_enable[10];
	BC10_count: coverpoint BC_count[10];
	BC10_rate: coverpoint BC_rate[10];
	BC10_cross : cross BC10_enable, BC10_count, BC10_rate;

	BC11_enable: coverpoint BC_enable[11];
	BC11_count: coverpoint BC_count[11];
	BC11_rate: coverpoint BC_rate[11];
	BC11_cross : cross BC11_enable, BC11_count, BC11_rate;

	BC12_enable: coverpoint BC_enable[12];
	BC12_count: coverpoint BC_count[12];
	BC12_rate: coverpoint BC_rate[12];
	BC12_cross : cross BC12_enable, BC12_count, BC12_rate;

	BC13_enable: coverpoint BC_enable[13];
	BC13_count: coverpoint BC_count[13];
	BC13_rate: coverpoint BC_rate[13];
	BC13_cross : cross BC13_enable, BC13_count, BC13_rate;

	BC14_enable: coverpoint BC_enable[14];
	BC14_count: coverpoint BC_count[14];
	BC14_rate: coverpoint BC_rate[14];
	BC14_cross : cross BC14_enable, BC14_count, BC14_rate;

	BC15_enable: coverpoint BC_enable[15];
	BC15_count: coverpoint BC_count[15];
	BC15_rate: coverpoint BC_rate[15];
	BC15_cross : cross BC15_enable, BC15_count, BC15_rate;
endgroup	// ats21_BCs


covergroup ats21_alarms @(posedge clk);
	alarm0_enable: coverpoint alarm_enable[0];
	alarm0_countdown: coverpoint alarm_countdown[0];
	alarm0_loop: coverpoint alarm_loop[0];
	alarm0_assigned_clock: coverpoint alarm_assigned_clock[0];
	alarm0_value: coverpoint alarm_value[0];
	alarm0_finished: coverpoint alarm_finished[0];
	alarm0_cross : cross alarm0_enable, alarm0_countdown, alarm0_loop, alarm0_assigned_clock, alarm0_value, alarm0_finished;

	alarm1_enable: coverpoint alarm_enable[1];
	alarm1_countdown: coverpoint alarm_countdown[1];
	alarm1_loop: coverpoint alarm_loop[1];
	alarm1_assigned_clock: coverpoint alarm_assigned_clock[1];
	alarm1_value: coverpoint alarm_value[1];
	alarm1_finished: coverpoint alarm_finished[1];
	alarm1_cross : cross alarm1_enable, alarm1_countdown, alarm1_loop, alarm1_assigned_clock, alarm1_value, alarm1_finished;

	alarm2_enable: coverpoint alarm_enable[2];
	alarm2_countdown: coverpoint alarm_countdown[2];
	alarm2_loop: coverpoint alarm_loop[2];
	alarm2_assigned_clock: coverpoint alarm_assigned_clock[2];
	alarm2_value: coverpoint alarm_value[2];
	alarm2_finished: coverpoint alarm_finished[2];
	alarm2_cross : cross alarm2_enable, alarm2_countdown, alarm2_loop, alarm2_assigned_clock, alarm2_value, alarm2_finished;

	alarm3_enable: coverpoint alarm_enable[3];
	alarm3_countdown: coverpoint alarm_countdown[3];
	alarm3_loop: coverpoint alarm_loop[3];
	alarm3_assigned_clock: coverpoint alarm_assigned_clock[3];
	alarm3_value: coverpoint alarm_value[3];
	alarm3_finished: coverpoint alarm_finished[3];
	alarm3_cross : cross alarm3_enable, alarm3_countdown, alarm3_loop, alarm3_assigned_clock, alarm3_value, alarm3_finished;

	alarm4_enable: coverpoint alarm_enable[4];
	alarm4_countdown: coverpoint alarm_countdown[4];
	alarm4_loop: coverpoint alarm_loop[4];
	alarm4_assigned_clock: coverpoint alarm_assigned_clock[4];
	alarm4_value: coverpoint alarm_value[4];
	alarm4_finished: coverpoint alarm_finished[4];
	alarm4_cross : cross alarm4_enable, alarm4_countdown, alarm4_loop, alarm4_assigned_clock, alarm4_value, alarm4_finished;

	alarm5_enable: coverpoint alarm_enable[5];
	alarm5_countdown: coverpoint alarm_countdown[5];
	alarm5_loop: coverpoint alarm_loop[5];
	alarm5_assigned_clock: coverpoint alarm_assigned_clock[5];
	alarm5_value: coverpoint alarm_value[5];
	alarm5_finished: coverpoint alarm_finished[5];
	alarm5_cross : cross alarm5_enable, alarm5_countdown, alarm5_loop, alarm5_assigned_clock, alarm5_value, alarm5_finished;

	alarm6_enable: coverpoint alarm_enable[6];
	alarm6_countdown: coverpoint alarm_countdown[6];
	alarm6_loop: coverpoint alarm_loop[6];
	alarm6_assigned_clock: coverpoint alarm_assigned_clock[6];
	alarm6_value: coverpoint alarm_value[6];
	alarm6_finished: coverpoint alarm_finished[6];
	alarm6_cross : cross alarm6_enable, alarm6_countdown, alarm6_loop, alarm6_assigned_clock, alarm6_value, alarm6_finished;

	alarm7_enable: coverpoint alarm_enable[7];
	alarm7_countdown: coverpoint alarm_countdown[7];
	alarm7_loop: coverpoint alarm_loop[7];
	alarm7_assigned_clock: coverpoint alarm_assigned_clock[7];
	alarm7_value: coverpoint alarm_value[7];
	alarm7_finished: coverpoint alarm_finished[7];
	alarm7_cross : cross alarm7_enable, alarm7_countdown, alarm7_loop, alarm7_assigned_clock, alarm7_value, alarm7_finished;

	alarm8_enable: coverpoint alarm_enable[8];
	alarm8_countdown: coverpoint alarm_countdown[8];
	alarm8_loop: coverpoint alarm_loop[8];
	alarm8_assigned_clock: coverpoint alarm_assigned_clock[8];
	alarm8_value: coverpoint alarm_value[8];
	alarm8_finished: coverpoint alarm_finished[8];
	alarm8_cross : cross alarm8_enable, alarm8_countdown, alarm8_loop, alarm8_assigned_clock, alarm8_value, alarm8_finished;

	alarm9_enable: coverpoint alarm_enable[9];
	alarm9_countdown: coverpoint alarm_countdown[9];
	alarm9_loop: coverpoint alarm_loop[9];
	alarm9_assigned_clock: coverpoint alarm_assigned_clock[9];
	alarm9_value: coverpoint alarm_value[9];
	alarm9_finished: coverpoint alarm_finished[9];
	alarm9_cross : cross alarm9_enable, alarm9_countdown, alarm9_loop, alarm9_assigned_clock, alarm9_value, alarm9_finished;

	alarm10_enable: coverpoint alarm_enable[10];
	alarm10_countdown: coverpoint alarm_countdown[10];
	alarm10_loop: coverpoint alarm_loop[10];
	alarm10_assigned_clock: coverpoint alarm_assigned_clock[10];
	alarm10_value: coverpoint alarm_value[10];
	alarm10_finished: coverpoint alarm_finished[10];
	alarm10_cross : cross alarm10_enable, alarm10_countdown, alarm10_loop, alarm10_assigned_clock, alarm10_value, alarm10_finished;

	alarm11_enable: coverpoint alarm_enable[11];
	alarm11_countdown: coverpoint alarm_countdown[11];
	alarm11_loop: coverpoint alarm_loop[11];
	alarm11_assigned_clock: coverpoint alarm_assigned_clock[11];
	alarm11_value: coverpoint alarm_value[11];
	alarm11_finished: coverpoint alarm_finished[11];
	alarm11_cross : cross alarm11_enable, alarm11_countdown, alarm11_loop, alarm11_assigned_clock, alarm11_value, alarm11_finished;

	alarm12_enable: coverpoint alarm_enable[12];
	alarm12_countdown: coverpoint alarm_countdown[12];
	alarm12_loop: coverpoint alarm_loop[12];
	alarm12_assigned_clock: coverpoint alarm_assigned_clock[12];
	alarm12_value: coverpoint alarm_value[12];
	alarm12_finished: coverpoint alarm_finished[12];
	alarm12_cross : cross alarm12_enable, alarm12_countdown, alarm12_loop, alarm12_assigned_clock, alarm12_value, alarm12_finished;

	alarm13_enable: coverpoint alarm_enable[13];
	alarm13_countdown: coverpoint alarm_countdown[13];
	alarm13_loop: coverpoint alarm_loop[13];
	alarm13_assigned_clock: coverpoint alarm_assigned_clock[13];
	alarm13_value: coverpoint alarm_value[13];
	alarm13_finished: coverpoint alarm_finished[13];
	alarm13_cross : cross alarm13_enable, alarm13_countdown, alarm13_loop, alarm13_assigned_clock, alarm13_value, alarm13_finished;

	alarm14_enable: coverpoint alarm_enable[14];
	alarm14_countdown: coverpoint alarm_countdown[14];
	alarm14_loop: coverpoint alarm_loop[14];
	alarm14_assigned_clock: coverpoint alarm_assigned_clock[14];
	alarm14_value: coverpoint alarm_value[14];
	alarm14_finished: coverpoint alarm_finished[14];
	alarm14_cross : cross alarm14_enable, alarm14_countdown, alarm14_loop, alarm14_assigned_clock, alarm14_value, alarm14_finished;

	alarm15_enable: coverpoint alarm_enable[15];
	alarm15_countdown: coverpoint alarm_countdown[15];
	alarm15_loop: coverpoint alarm_loop[15];
	alarm15_assigned_clock: coverpoint alarm_assigned_clock[15];
	alarm15_value: coverpoint alarm_value[15];
	alarm15_finished: coverpoint alarm_finished[15];
	alarm15_cross : cross alarm15_enable, alarm15_countdown, alarm15_loop, alarm15_assigned_clock, alarm15_value, alarm15_finished;

	alarm16_enable: coverpoint alarm_enable[16];
	alarm16_countdown: coverpoint alarm_countdown[16];
	alarm16_loop: coverpoint alarm_loop[16];
	alarm16_assigned_clock: coverpoint alarm_assigned_clock[16];
	alarm16_value: coverpoint alarm_value[16];
	alarm16_finished: coverpoint alarm_finished[16];
	alarm16_cross : cross alarm16_enable, alarm16_countdown, alarm16_loop, alarm16_assigned_clock, alarm16_value, alarm16_finished;

	alarm17_enable: coverpoint alarm_enable[17];
	alarm17_countdown: coverpoint alarm_countdown[17];
	alarm17_loop: coverpoint alarm_loop[17];
	alarm17_assigned_clock: coverpoint alarm_assigned_clock[17];
	alarm17_value: coverpoint alarm_value[17];
	alarm17_finished: coverpoint alarm_finished[17];
	alarm17_cross : cross alarm17_enable, alarm17_countdown, alarm17_loop, alarm17_assigned_clock, alarm17_value, alarm17_finished;

	alarm18_enable: coverpoint alarm_enable[18];
	alarm18_countdown: coverpoint alarm_countdown[18];
	alarm18_loop: coverpoint alarm_loop[18];
	alarm18_assigned_clock: coverpoint alarm_assigned_clock[18];
	alarm18_value: coverpoint alarm_value[18];
	alarm18_finished: coverpoint alarm_finished[18];
	alarm18_cross : cross alarm18_enable, alarm18_countdown, alarm18_loop, alarm18_assigned_clock, alarm18_value, alarm18_finished;

	alarm19_enable: coverpoint alarm_enable[19];
	alarm19_countdown: coverpoint alarm_countdown[19];
	alarm19_loop: coverpoint alarm_loop[19];
	alarm19_assigned_clock: coverpoint alarm_assigned_clock[19];
	alarm19_value: coverpoint alarm_value[19];
	alarm19_finished: coverpoint alarm_finished[19];
	alarm19_cross : cross alarm19_enable, alarm19_countdown, alarm19_loop, alarm19_assigned_clock, alarm19_value, alarm19_finished;

	alarm20_enable: coverpoint alarm_enable[20];
	alarm20_countdown: coverpoint alarm_countdown[20];
	alarm20_loop: coverpoint alarm_loop[20];
	alarm20_assigned_clock: coverpoint alarm_assigned_clock[20];
	alarm20_value: coverpoint alarm_value[20];
	alarm20_finished: coverpoint alarm_finished[20];
	alarm20_cross : cross alarm20_enable, alarm20_countdown, alarm20_loop, alarm20_assigned_clock, alarm20_value, alarm20_finished;

	alarm21_enable: coverpoint alarm_enable[21];
	alarm21_countdown: coverpoint alarm_countdown[21];
	alarm21_loop: coverpoint alarm_loop[21];
	alarm21_assigned_clock: coverpoint alarm_assigned_clock[21];
	alarm21_value: coverpoint alarm_value[21];
	alarm21_finished: coverpoint alarm_finished[21];
	alarm21_cross : cross alarm21_enable, alarm21_countdown, alarm21_loop, alarm21_assigned_clock, alarm21_value, alarm21_finished;

	alarm22_enable: coverpoint alarm_enable[22];
	alarm22_countdown: coverpoint alarm_countdown[22];
	alarm22_loop: coverpoint alarm_loop[22];
	alarm22_assigned_clock: coverpoint alarm_assigned_clock[22];
	alarm22_value: coverpoint alarm_value[22];
	alarm22_finished: coverpoint alarm_finished[22];
	alarm22_cross: cross alarm22_enable, alarm22_countdown, alarm22_loop, alarm22_assigned_clock, alarm22_value, alarm22_finished;

	alarm23_enable: coverpoint alarm_enable[23];
	alarm23_countdown: coverpoint alarm_countdown[23];
	alarm23_loop: coverpoint alarm_loop[23];
	alarm23_assigned_clock: coverpoint alarm_assigned_clock[23];
	alarm23_value: coverpoint alarm_value[23];
	alarm23_finished: coverpoint alarm_finished[23];
	alarm23_cross: cross alarm23_enable, alarm23_countdown, alarm23_loop, alarm23_assigned_clock, alarm23_value, alarm23_finished;
endgroup	// ats21_alarms


covergroup ats21_control_register @(posedge clk);
	device_enable: coverpoint cr_device_enable;
	clientA_clock: coverpoint cr_clientA_clock;
	clientB_clock: coverpoint cr_clientB_clock;
	clientA_alarm: coverpoint cr_clientA_alarm;
	clientB_alarm: coverpoint cr_clientB_alarm;
	cr_bits_cross: cross device_enable, clientA_clock, clientB_clock, clientA_alarm, clientB_alarm;
endgroup	// ats21_control_register

covergroup ats21_cr_cross @(posedge clk);
	ctrlA_set_BC: coverpoint dut.processInst.ctrlA[31:29]{
		bins set_BC = {3'b001};
	}

	ctrlA_toggle_BC: coverpoint dut.processInst.ctrlA[31:29]{
		bins toggle_BC = {3'b010};
	}

	ctrlA_set_AT: coverpoint dut.processInst.ctrlA[31:29]{
		bins set_AT = {3'b101};
	}

	ctrlA_set_Countdown: coverpoint dut.processInst.ctrlA[31:29]{
		bins set_Countdown = {3'b110};
	}

	ctrlA_toggle_AT: coverpoint dut.processInst.ctrlA[31:29]{
		bins toggle_AT = {3'b111};
	}

	ctrlA_set_ATS21_mode: coverpoint dut.processInst.ctrlA[31:29]{
		bins set_ATS21_mode = {3'b011};
	}

	ctrlB_set_BC: coverpoint dut.processInst.ctrlB[31:29]{
		bins set_BC = {3'b001};
	}

	ctrlB_toggle_BC: coverpoint dut.processInst.ctrlB[31:29]{
		bins toggle_BC = {3'b010};
	}

	ctrlB_set_AT: coverpoint dut.processInst.ctrlB[31:29]{
		bins set_AT = {3'b101};
	}

	ctrlB_set_Countdown: coverpoint dut.processInst.ctrlB[31:29]{
		bins set_Countdown = {3'b110};
	}

	ctrlB_toggle_AT: coverpoint dut.processInst.ctrlB[31:29]{
		bins toggle_AT = {3'b111};
	}

	ctrlB_set_ATS21_mode: coverpoint dut.processInst.ctrlB[31:29]{
		bins set_ATS21_mode = {3'b011};
	}
	//
	// processInst_opcodeB: coverpoint dut.processInst.ctrlB[31:29]{
	// 	bins nop								 = {3'b000};
	// 	bins set_BC              = {3'b001};
	// 	bins toggle_BC           = {3'b010};
	// 	bins set_AT              = {3'b101};
	// 	bins set_Countdown       = {3'b110};
	// 	bins toggle_AT           = {3'b111};
	// 	bins set_ATS21_mode      = {3'b011};
	// 	bins invalid_instruction = default;
	// }

	device_enable: coverpoint cr_device_enable;
	clientA_clock: coverpoint cr_clientA_clock;
	clientB_clock: coverpoint cr_clientB_clock;
	clientA_alarm: coverpoint cr_clientA_alarm;
	clientB_alarm: coverpoint cr_clientB_alarm;

	cr_active_X_ctrlA_inst: cross device_enable, ctrlA_set_BC, ctrlA_toggle_BC, ctrlA_set_AT,
																ctrlA_set_Countdown, ctrlA_toggle_AT, ctrlA_set_ATS21_mode;

	cr_active_X_ctrlB_inst: cross device_enable, ctrlB_set_BC, ctrlB_toggle_BC, ctrlB_set_AT,
																ctrlB_set_Countdown, ctrlB_toggle_AT, ctrlB_set_ATS21_mode;

	cr_clientA_clock_X_set_clock_instA: cross clientA_clock, ctrlA_set_BC, ctrlA_toggle_BC;
	cr_clientB_clock_X_set_clock_instB: cross clientB_clock, ctrlB_set_BC, ctrlB_toggle_BC;

	cr_clientA_alarm_X_set_alarm_instA: cross clientA_alarm, ctrlA_set_AT, ctrlA_set_Countdown, ctrlA_toggle_AT;
	cr_clientB_alarm_X_set_alarm_instB: cross clientB_alarm, ctrlB_set_AT, ctrlB_set_Countdown, ctrlB_toggle_AT;
endgroup


covergroup ats21_output @(posedge clk);
	coverpoint all_alarms {
		bins no_alarms   = {0};
		bins one_alarm   = {1};
		bins two_alarms  = {2};
		bins many_alarms = { [3:24] };
	}

	coverpoint data {
		bins alarm_0  = {24'b000000000000000000000001};
		bins alarm_1  = {24'b000000000000000000000010};
		bins alarm_2  = {24'b000000000000000000000100};
		bins alarm_3  = {24'b000000000000000000001000};
		bins alarm_4  = {24'b000000000000000000010000};
		bins alarm_5  = {24'b000000000000000000100000};
		bins alarm_6  = {24'b000000000000000001000000};
		bins alarm_7  = {24'b000000000000000010000000};
		bins alarm_8  = {24'b000000000000000100000000};
		bins alarm_9  = {24'b000000000000001000000000};
		bins alarm_10 = {24'b000000000000010000000000};
		bins alarm_11 = {24'b000000000000100000000000};
		bins alarm_12 = {24'b000000000001000000000000};
		bins alarm_13 = {24'b000000000010000000000000};
		bins alarm_14 = {24'b000000000100000000000000};
		bins alarm_15 = {24'b000000001000000000000000};
		bins alarm_16 = {24'b000000010000000000000000};
		bins alarm_17 = {24'b000000100000000000000000};
		bins alarm_18 = {24'b000001000000000000000000};
		bins alarm_19 = {24'b000010000000000000000000};
		bins alarm_20 = {24'b000100000000000000000000};
		bins alarm_21 = {24'b001000000000000000000000};
		bins alarm_22 = {24'b010000000000000000000000};
		bins alarm_23 = {24'b100000000000000000000000};
		bins other = default;
	}

	coverpoint stat {
		bins Nack   = {2'b00};
		bins Ack_A  = {2'b01};
		bins Ack_B  = {2'b10};
		bins Ack_AB = {2'b11};
	}
endgroup	// ats21_output

ats21_input input_cover = new;
ats21_instructions instructions_cover = new;
ats21_BCs base_clocks_cover = new;
ats21_alarms alarms_cover = new;
ats21_control_register cr_cover = new;
ats21_cr_cross cr_cross_cover = new;
ats21_output output_cover = new;

// Random Input Class
class RandomInput;
	rand bit[15:0] rand_ctrlA;
	rand bit[15:0] rand_ctrlB;
	rand bit	   	 rand_req;
endclass

// Simulation
initial begin

	RandomInput i;
	i = new;

	// Initialize Design
	initialize();

	while (input_cover.get_coverage()<100 ||
				instructions_cover.get_coverage()<100 ||
				base_clocks_cover.get_coverage()<100 ||
				alarms_cover.get_coverage()<100 ||
				cr_cover.get_coverage()<100 ||
				cr_cross_cover.get_coverage()<100 ||
				output_cover.get_coverage()<100) begin
		assert(i.randomize());
		req <= i.rand_req;
		ctrlA <= i.rand_ctrlA;
		ctrlB <= i.rand_ctrlB;
		@(posedge clk);
	end

	// End Simulation
	exit_simulation();
end

/////////////////////////////////////////
////////// Tasks and Functions //////////
/////////////////////////////////////////

// Wait Cycles Task
task wait_cycles(int t);
	repeat(t) @(posedge(clk));
endtask

// Init Task
task initialize();
	// Initialize Variables and Reset for 4 cycles
	clk = 0; reset = 1;
	req = 0; ctrlA = '0; ctrlB = '0;
	wait_cycles(4);
	reset = 0;
	wait_cycles(1);
endtask

// End Simulation task
task exit_simulation();
	// Stop Simulation after 20 cycles
	repeat(20) @(posedge(clk));
	$stop;
endtask


endmodule
