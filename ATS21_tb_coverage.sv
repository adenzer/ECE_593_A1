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

// Testbench Signals
logic [num_alarms-1:0] all_alarms;

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


covergroup ats21_internal @(posedge clk);
	// Coverage is missing when Opcode is 000, but not all the time
	checkInst_opcodeA: coverpoint dut.checkInst.ctrlA[31:29]{
		bins set_BC              = {32'b001};
		bins toggle_BC           = {32'b010};
		bins set_AT              = {32'b101};
		bins set_Countdown       = {32'b110};
		bins toggle_AT           = {32'b111};
		bins set_ATS21_mode      = {32'b011};
		bins invalid_instruction = default;
	}
	checkInst_opcodeB: coverpoint dut.checkInst.ctrlB[31:29]{
		bins set_BC              = {32'b001};
		bins toggle_BC           = {32'b010};
		bins set_AT              = {32'b101};
		bins set_Countdown       = {32'b110};
		bins toggle_AT           = {32'b111};
		bins set_ATS21_mode      = {32'b011};
		bins invalid_instruction = default;
	}

	// Coverage is missing when Opcode is 000, but not all the time
	processInst_ctrlA: coverpoint dut.processInst.ctrlA;
	processInst_ctrlB: coverpoint dut.processInst.ctrlB;
endgroup // ats21_internal


covergroup ats21_BCs @(posedge clk);
	BC0_enable: coverpoint dut.base_clocks[0].enable;
	BC0_count: coverpoint dut.base_clocks[0].count;
	BC0_rate: coverpoint dut.base_clocks[0].rate;
	BC0_cross : cross BC0_enable, BC0_count, BC0_rate;

	BC1_enable: coverpoint dut.base_clocks[1].enable;
	BC1_count: coverpoint dut.base_clocks[1].count;
	BC1_rate: coverpoint dut.base_clocks[1].rate;
	BC1_cross : cross BC1_enable, BC1_count, BC1_rate;

	BC2_enable: coverpoint dut.base_clocks[2].enable;
	BC2_count: coverpoint dut.base_clocks[2].count;
	BC2_rate: coverpoint dut.base_clocks[2].rate;
	BC2_cross : cross BC2_enable, BC2_count, BC2_rate;

	BC3_enable: coverpoint dut.base_clocks[3].enable;
	BC3_count: coverpoint dut.base_clocks[3].count;
	BC3_rate: coverpoint dut.base_clocks[3].rate;
	BC3_cross : cross BC3_enable, BC3_count, BC3_rate;

	BC4_enable: coverpoint dut.base_clocks[4].enable;
	BC4_count: coverpoint dut.base_clocks[4].count;
	BC4_rate: coverpoint dut.base_clocks[4].rate;
	BC4_cross : cross BC4_enable, BC4_count, BC4_rate;

	BC5_enable: coverpoint dut.base_clocks[5].enable;
	BC5_count: coverpoint dut.base_clocks[5].count;
	BC5_rate: coverpoint dut.base_clocks[5].rate;
	BC5_cross : cross BC5_enable, BC5_count, BC5_rate;

	BC6_enable: coverpoint dut.base_clocks[6].enable;
	BC6_count: coverpoint dut.base_clocks[6].count;
	BC6_rate: coverpoint dut.base_clocks[6].rate;
	BC6_cross : cross BC6_enable, BC6_count, BC6_rate;

	BC7_enable: coverpoint dut.base_clocks[7].enable;
	BC7_count: coverpoint dut.base_clocks[7].count;
	BC7_rate: coverpoint dut.base_clocks[7].rate;
	BC7_cross : cross BC7_enable, BC7_count, BC7_rate;

	BC8_enable: coverpoint dut.base_clocks[8].enable;
	BC8_count: coverpoint dut.base_clocks[8].count;
	BC8_rate: coverpoint dut.base_clocks[8].rate;
	BC8_cross : cross BC8_enable, BC8_count, BC8_rate;

	BC9_enable: coverpoint dut.base_clocks[9].enable;
	BC9_count: coverpoint dut.base_clocks[9].count;
	BC9_rate: coverpoint dut.base_clocks[9].rate;
	BC9_cross : cross BC9_enable, BC9_count, BC9_rate;

	BC10_enable: coverpoint dut.base_clocks[10].enable;
	BC10_count: coverpoint dut.base_clocks[10].count;
	BC10_rate: coverpoint dut.base_clocks[10].rate;
	BC10_cross : cross BC10_enable, BC10_count, BC10_rate;

	BC11_enable: coverpoint dut.base_clocks[11].enable;
	BC11_count: coverpoint dut.base_clocks[11].count;
	BC11_rate: coverpoint dut.base_clocks[11].rate;
	BC11_cross : cross BC11_enable, BC11_count, BC11_rate;

	BC12_enable: coverpoint dut.base_clocks[12].enable;
	BC12_count: coverpoint dut.base_clocks[12].count;
	BC12_rate: coverpoint dut.base_clocks[12].rate;
	BC12_cross : cross BC12_enable, BC12_count, BC12_rate;

	BC13_enable: coverpoint dut.base_clocks[13].enable;
	BC13_count: coverpoint dut.base_clocks[13].count;
	BC13_rate: coverpoint dut.base_clocks[13].rate;
	BC13_cross : cross BC13_enable, BC13_count, BC13_rate;

	BC14_enable: coverpoint dut.base_clocks[14].enable;
	BC14_count: coverpoint dut.base_clocks[14].count;
	BC14_rate: coverpoint dut.base_clocks[14].rate;
	BC14_cross : cross BC14_enable, BC14_count, BC14_rate;

	BC15_enable: coverpoint dut.base_clocks[15].enable;
	BC15_count: coverpoint dut.base_clocks[15].count;
	BC15_rate: coverpoint dut.base_clocks[15].rate;
	BC15_cross : cross BC15_enable, BC15_count, BC15_rate;

endgroup	// ats21_BCs


covergroup ats21_alarms @(posedge clk);
	alarm0_enable: coverpoint dut.alarms[0].enable;
	alarm0_countdown: coverpoint dut.alarms[0].countdown;
	alarm0_loop: coverpoint dut.alarms[0].loop;
	alarm0_assigned_clock: coverpoint dut.alarms[0].assigned_clock;
	alarm0_value: coverpoint dut.alarms[0].value;
	alarm0_finished: coverpoint dut.alarms[0].finished;
	alarm0_cross : cross alarm0_enable, alarm0_countdown, alarm0_loop, alarm0_assigned_clock, alarm0_value, alarm0_finished;

	alarm1_enable: coverpoint dut.alarms[1].enable;
	alarm1_countdown: coverpoint dut.alarms[1].countdown;
	alarm1_loop: coverpoint dut.alarms[1].loop;
	alarm1_assigned_clock: coverpoint dut.alarms[1].assigned_clock;
	alarm1_value: coverpoint dut.alarms[1].value;
	alarm1_finished: coverpoint dut.alarms[1].finished;
	alarm1_cross : cross alarm1_enable, alarm1_countdown, alarm1_loop, alarm1_assigned_clock, alarm1_value, alarm1_finished;

	alarm2_enable: coverpoint dut.alarms[2].enable;
	alarm2_countdown: coverpoint dut.alarms[2].countdown;
	alarm2_loop: coverpoint dut.alarms[2].loop;
	alarm2_assigned_clock: coverpoint dut.alarms[2].assigned_clock;
	alarm2_value: coverpoint dut.alarms[2].value;
	alarm2_finished: coverpoint dut.alarms[2].finished;
	alarm2_cross : cross alarm2_enable, alarm2_countdown, alarm2_loop, alarm2_assigned_clock, alarm2_value, alarm2_finished;

	alarm3_enable: coverpoint dut.alarms[3].enable;
	alarm3_countdown: coverpoint dut.alarms[3].countdown;
	alarm3_loop: coverpoint dut.alarms[3].loop;
	alarm3_assigned_clock: coverpoint dut.alarms[3].assigned_clock;
	alarm3_value: coverpoint dut.alarms[3].value;
	alarm3_finished: coverpoint dut.alarms[3].finished;
	alarm3_cross : cross alarm3_enable, alarm3_countdown, alarm3_loop, alarm3_assigned_clock, alarm3_value, alarm3_finished;

	alarm4_enable: coverpoint dut.alarms[4].enable;
	alarm4_countdown: coverpoint dut.alarms[4].countdown;
	alarm4_loop: coverpoint dut.alarms[4].loop;
	alarm4_assigned_clock: coverpoint dut.alarms[4].assigned_clock;
	alarm4_value: coverpoint dut.alarms[4].value;
	alarm4_finished: coverpoint dut.alarms[4].finished;
	alarm4_cross : cross alarm4_enable, alarm4_countdown, alarm4_loop, alarm4_assigned_clock, alarm4_value, alarm4_finished;

	alarm5_enable: coverpoint dut.alarms[5].enable;
	alarm5_countdown: coverpoint dut.alarms[5].countdown;
	alarm5_loop: coverpoint dut.alarms[5].loop;
	alarm5_assigned_clock: coverpoint dut.alarms[5].assigned_clock;
	alarm5_value: coverpoint dut.alarms[5].value;
	alarm5_finished: coverpoint dut.alarms[5].finished;
	alarm5_cross : cross alarm5_enable, alarm5_countdown, alarm5_loop, alarm5_assigned_clock, alarm5_value, alarm5_finished;

	alarm6_enable: coverpoint dut.alarms[6].enable;
	alarm6_countdown: coverpoint dut.alarms[6].countdown;
	alarm6_loop: coverpoint dut.alarms[6].loop;
	alarm6_assigned_clock: coverpoint dut.alarms[6].assigned_clock;
	alarm6_value: coverpoint dut.alarms[6].value;
	alarm6_finished: coverpoint dut.alarms[6].finished;
	alarm6_cross : cross alarm6_enable, alarm6_countdown, alarm6_loop, alarm6_assigned_clock, alarm6_value, alarm6_finished;

	alarm7_enable: coverpoint dut.alarms[7].enable;
	alarm7_countdown: coverpoint dut.alarms[7].countdown;
	alarm7_loop: coverpoint dut.alarms[7].loop;
	alarm7_assigned_clock: coverpoint dut.alarms[7].assigned_clock;
	alarm7_value: coverpoint dut.alarms[7].value;
	alarm7_finished: coverpoint dut.alarms[7].finished;
	alarm7_cross : cross alarm7_enable, alarm7_countdown, alarm7_loop, alarm7_assigned_clock, alarm7_value, alarm7_finished;

	alarm8_enable: coverpoint dut.alarms[8].enable;
	alarm8_countdown: coverpoint dut.alarms[8].countdown;
	alarm8_loop: coverpoint dut.alarms[8].loop;
	alarm8_assigned_clock: coverpoint dut.alarms[8].assigned_clock;
	alarm8_value: coverpoint dut.alarms[8].value;
	alarm8_finished: coverpoint dut.alarms[8].finished;
	alarm8_cross : cross alarm8_enable, alarm8_countdown, alarm8_loop, alarm8_assigned_clock, alarm8_value, alarm8_finished;

	alarm9_enable: coverpoint dut.alarms[9].enable;
	alarm9_countdown: coverpoint dut.alarms[9].countdown;
	alarm9_loop: coverpoint dut.alarms[9].loop;
	alarm9_assigned_clock: coverpoint dut.alarms[9].assigned_clock;
	alarm9_value: coverpoint dut.alarms[9].value;
	alarm9_finished: coverpoint dut.alarms[9].finished;
	alarm9_cross : cross alarm9_enable, alarm9_countdown, alarm9_loop, alarm9_assigned_clock, alarm9_value, alarm9_finished;

	alarm10_enable: coverpoint dut.alarms[10].enable;
	alarm10_countdown: coverpoint dut.alarms[10].countdown;
	alarm10_loop: coverpoint dut.alarms[10].loop;
	alarm10_assigned_clock: coverpoint dut.alarms[10].assigned_clock;
	alarm10_value: coverpoint dut.alarms[10].value;
	alarm10_finished: coverpoint dut.alarms[10].finished;
	alarm10_cross : cross alarm10_enable, alarm10_countdown, alarm10_loop, alarm10_assigned_clock, alarm10_value, alarm10_finished;

	alarm11_enable: coverpoint dut.alarms[11].enable;
	alarm11_countdown: coverpoint dut.alarms[11].countdown;
	alarm11_loop: coverpoint dut.alarms[11].loop;
	alarm11_assigned_clock: coverpoint dut.alarms[11].assigned_clock;
	alarm11_value: coverpoint dut.alarms[11].value;
	alarm11_finished: coverpoint dut.alarms[11].finished;
	alarm11_cross : cross alarm11_enable, alarm11_countdown, alarm11_loop, alarm11_assigned_clock, alarm11_value, alarm11_finished;

	alarm12_enable: coverpoint dut.alarms[12].enable;
	alarm12_countdown: coverpoint dut.alarms[12].countdown;
	alarm12_loop: coverpoint dut.alarms[12].loop;
	alarm12_assigned_clock: coverpoint dut.alarms[12].assigned_clock;
	alarm12_value: coverpoint dut.alarms[12].value;
	alarm12_finished: coverpoint dut.alarms[12].finished;
	alarm12_cross : cross alarm12_enable, alarm12_countdown, alarm12_loop, alarm12_assigned_clock, alarm12_value, alarm12_finished;

	alarm13_enable: coverpoint dut.alarms[13].enable;
	alarm13_countdown: coverpoint dut.alarms[13].countdown;
	alarm13_loop: coverpoint dut.alarms[13].loop;
	alarm13_assigned_clock: coverpoint dut.alarms[13].assigned_clock;
	alarm13_value: coverpoint dut.alarms[13].value;
	alarm13_finished: coverpoint dut.alarms[13].finished;
	alarm13_cross : cross alarm13_enable, alarm13_countdown, alarm13_loop, alarm13_assigned_clock, alarm13_value, alarm13_finished;

	alarm14_enable: coverpoint dut.alarms[14].enable;
	alarm14_countdown: coverpoint dut.alarms[14].countdown;
	alarm14_loop: coverpoint dut.alarms[14].loop;
	alarm14_assigned_clock: coverpoint dut.alarms[14].assigned_clock;
	alarm14_value: coverpoint dut.alarms[14].value;
	alarm14_finished: coverpoint dut.alarms[14].finished;
	alarm14_cross : cross alarm14_enable, alarm14_countdown, alarm14_loop, alarm14_assigned_clock, alarm14_value, alarm14_finished;

	alarm15_enable: coverpoint dut.alarms[15].enable;
	alarm15_countdown: coverpoint dut.alarms[15].countdown;
	alarm15_loop: coverpoint dut.alarms[15].loop;
	alarm15_assigned_clock: coverpoint dut.alarms[15].assigned_clock;
	alarm15_value: coverpoint dut.alarms[15].value;
	alarm15_finished: coverpoint dut.alarms[15].finished;
	alarm15_cross : cross alarm15_enable, alarm15_countdown, alarm15_loop, alarm15_assigned_clock, alarm15_value, alarm15_finished;

	alarm16_enable: coverpoint dut.alarms[16].enable;
	alarm16_countdown: coverpoint dut.alarms[16].countdown;
	alarm16_loop: coverpoint dut.alarms[16].loop;
	alarm16_assigned_clock: coverpoint dut.alarms[16].assigned_clock;
	alarm16_value: coverpoint dut.alarms[16].value;
	alarm16_finished: coverpoint dut.alarms[16].finished;
	alarm16_cross : cross alarm16_enable, alarm16_countdown, alarm16_loop, alarm16_assigned_clock, alarm16_value, alarm16_finished;

	alarm17_enable: coverpoint dut.alarms[17].enable;
	alarm17_countdown: coverpoint dut.alarms[17].countdown;
	alarm17_loop: coverpoint dut.alarms[17].loop;
	alarm17_assigned_clock: coverpoint dut.alarms[17].assigned_clock;
	alarm17_value: coverpoint dut.alarms[17].value;
	alarm17_finished: coverpoint dut.alarms[17].finished;
	alarm17_cross : cross alarm17_enable, alarm17_countdown, alarm17_loop, alarm17_assigned_clock, alarm17_value, alarm17_finished;

	alarm18_enable: coverpoint dut.alarms[18].enable;
	alarm18_countdown: coverpoint dut.alarms[18].countdown;
	alarm18_loop: coverpoint dut.alarms[18].loop;
	alarm18_assigned_clock: coverpoint dut.alarms[18].assigned_clock;
	alarm18_value: coverpoint dut.alarms[18].value;
	alarm18_finished: coverpoint dut.alarms[18].finished;
	alarm18_cross : cross alarm18_enable, alarm18_countdown, alarm18_loop, alarm18_assigned_clock, alarm18_value, alarm18_finished;

	alarm19_enable: coverpoint dut.alarms[19].enable;
	alarm19_countdown: coverpoint dut.alarms[19].countdown;
	alarm19_loop: coverpoint dut.alarms[19].loop;
	alarm19_assigned_clock: coverpoint dut.alarms[19].assigned_clock;
	alarm19_value: coverpoint dut.alarms[19].value;
	alarm19_finished: coverpoint dut.alarms[19].finished;
	alarm19_cross : cross alarm19_enable, alarm19_countdown, alarm19_loop, alarm19_assigned_clock, alarm19_value, alarm19_finished;

	alarm20_enable: coverpoint dut.alarms[20].enable;
	alarm20_countdown: coverpoint dut.alarms[20].countdown;
	alarm20_loop: coverpoint dut.alarms[20].loop;
	alarm20_assigned_clock: coverpoint dut.alarms[20].assigned_clock;
	alarm20_value: coverpoint dut.alarms[20].value;
	alarm20_finished: coverpoint dut.alarms[20].finished;
	alarm20_cross : cross alarm20_enable, alarm20_countdown, alarm20_loop, alarm20_assigned_clock, alarm20_value, alarm20_finished;

	alarm21_enable: coverpoint dut.alarms[21].enable;
	alarm21_countdown: coverpoint dut.alarms[21].countdown;
	alarm21_loop: coverpoint dut.alarms[21].loop;
	alarm21_assigned_clock: coverpoint dut.alarms[21].assigned_clock;
	alarm21_value: coverpoint dut.alarms[21].value;
	alarm21_finished: coverpoint dut.alarms[21].finished;
	alarm21_cross : cross alarm21_enable, alarm21_countdown, alarm21_loop, alarm21_assigned_clock, alarm21_value, alarm21_finished;

	alarm22_enable: coverpoint dut.alarms[22].enable;
	alarm22_countdown: coverpoint dut.alarms[22].countdown;
	alarm22_loop: coverpoint dut.alarms[22].loop;
	alarm22_assigned_clock: coverpoint dut.alarms[22].assigned_clock;
	alarm22_value: coverpoint dut.alarms[22].value;
	alarm22_finished: coverpoint dut.alarms[22].finished;
	alarm22_cross : cross alarm22_enable, alarm22_countdown, alarm22_loop, alarm22_assigned_clock, alarm22_value, alarm22_finished;

	alarm23_enable: coverpoint dut.alarms[23].enable;
	alarm23_countdown: coverpoint dut.alarms[23].countdown;
	alarm23_loop: coverpoint dut.alarms[23].loop;
	alarm23_assigned_clock: coverpoint dut.alarms[23].assigned_clock;
	alarm23_value: coverpoint dut.alarms[23].value;
	alarm23_finished: coverpoint dut.alarms[23].finished;
	alarm23_cross : cross alarm23_enable, alarm23_countdown, alarm23_loop, alarm23_assigned_clock, alarm23_value, alarm23_finished;
endgroup	// ats21_alarms


covergroup ats21_control_register @(posedge clk);
	cr_device_enable: coverpoint dut.cr_bits.active;
	cr_clientA_clock: coverpoint dut.cr_bits.clientA_clock;
	cr_clientB_clock: coverpoint dut.cr_bits.clientB_clock;
	cr_clientA_alarm: coverpoint dut.cr_bits.clientA_alarm;
	cr_clientB_alarm: coverpoint dut.cr_bits.clientB_alarm;
	cr_bits_cross: cross cr_device_enable, cr_clientA_clock, cr_clientB_clock, cr_clientA_alarm, cr_clientB_alarm;
endgroup	// ats21_control_register


covergroup ats21_output @(posedge clk);
	coverpoint all_alarms {
		bins no_alarms   = {24'd0};
		bins one_alarm   = {24'd1};
		bins two_alarms  = {24'd2};
		bins many_alarms = default;
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
ats21_internal internal_cover = new;
ats21_BCs base_clocks_cover = new;
ats21_alarms alarms_cover = new;
ats21_control_register cr_cover = new;
ats21_output output_cover = new;

// Random Input Class
class RandomInput;
	rand bit[15:0] rand_ctrlA;
	rand bit[15:0] rand_ctrlB;
	rand bit	   rand_req;
endclass

// Simulation
initial begin

	RandomInput i;
	i = new;

	// Initialize Design
	initialize();

	while (input_cover.get_coverage()<100 ||
				internal_cover.get_coverage()<100 ||
				base_clocks_cover.get_coverage()<100 ||
				alarms_cover.get_coverage()<100 ||
				cr_cover.get_coverage()<100 ||
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
