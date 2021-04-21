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
logic [ 2:0] opcodeA, opcodeB;
logic [23:0] data;

// Testbench Signals
//logic BC_enable [num_clocks-1:0];
//logic [1:0] BC_rate [num_clocks-1:0];
//logic alarm_enable [num_alarms-1:0];
//logic alarm_countdown [num_alarms-1:0];
//logic alarm_loop [num_alarms-1:0];
//logic [num_clocks_bits-1:0] alarm_assigned_clock [num_alarms-1:0];
//logic alarm_finished [num_alarms-1:0];
logic [num_alarms-1:0] all_alarms;

/*
typedef struct packed {
	logic enable;
	logic [clock_width-1:0] count;
	logic [1:0] rate;
} Clock;

// Array of Clocks
Clock [num_clocks-1:0] base_clocks;
assign base_clocks = dut.base_clocks;

typedef struct packed {
	logic enable;
 	logic countdown;
	logic loop;
	logic [num_clocks_bits-1:0] assigned_clock;
	logic [clock_width-1:0] value;
	logic finished;
} Alarm;

Alarm [num_alarms-1:0] alarms;
assign alarms = dut.alarms;

typedef struct packed {
	logic active;
	logic clientA_clock;
	logic clientB_clock;
	logic clientA_alarm;
	logic clientB_alarm;
} ControlRegisters;

ControlRegisters cr_bits;
assign cr_bits = dut.cr_bits;
*/

// Instantiate DUT
ATS21 dut(.clk(clk), .reset(reset), .req(req), .ctrlA(ctrlA), .ctrlB(ctrlB),
			.ready(ready), .stat(stat), .data(data));

// Reference Clock Generator
always begin
	#1 clk = ~clk;
end

always_ff @(posedge clk) begin : add_alarms
	all_alarms <= data[0] + data + data[2] + data[3] + data[4] + data[5] + data[6] + data[7] + data[8] + data[9] + data[10]
				+ data[11] + data[12] + data[13] + data[14] + data[15] + data[16] + data[17] + data[18] + data[19] + data[20] 
				+ data[21] + data[22] + data[23];
end

///////////////////////////////////////
////////// Testbench Simulus //////////
///////////////////////////////////////

assign opcodeA = dut.checkInst.ctrlA[31:29];
assign opcodeB = dut.checkInst.ctrlB[31:29];
assign sameOpcode = opcodeA == opcodeB;
assign ABsameTime = opcodeA != 3'b000 && opcodeB != 3'b000;

/*
 genvar j;
 generate
 	for (j = 0; j < num_clocks; j++)
 	 begin
 		assign BC_enable[j] = dut.base_clocks[j].enable;
 		assign BC_rate[j] = dut.base_clocks[j].rate;
 	 end
 endgenerate

 genvar k;
 generate
 	for (k = 0; k < num_alarms; k++)
 	 begin
 		assign alarm_enable[k] = dut.alarms[k].enable;
 		assign alarm_countdown[k] = dut.alarms[k].countdown;
 		assign alarm_loop[k] = dut.alarms[k].loop;
 		assign alarm_assigned_clock[k] = dut.alarms[k].assigned_clock;
 		assign alarm_finished[k] = dut.alarms[k].finished;
 	 end
 endgenerate*/

covergroup ats21 @(posedge clk);
	option.at_least =2;

	coverpoint opcodeA {
		bins set_BC              = {3'b001};
		bins toggle_BC           = {3'b010};
		bins set_AT              = {3'b101};
		bins set_Countdown       = {3'b110};
		bins toggle_AT           = {3'b111};
		bins set_ATS21_mode      = {3'b011};
		bins invalid_instruction = default;
	}

	coverpoint opcodeB {
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

	coverpoint dut.base_clocks;
	/*coverpoint base_clocks[0].rate;
	coverpoint base_clocks[0].enable;
	coverpoint base_clocks[0].count;*/

	coverpoint dut.alarms;
	/*coverpoint alarms[0].enable;
	coverpoint alarms[0].countdown;
	coverpoint alarms[0].loop;
	coverpoint alarms[0].assigned_clock;
	coverpoint alarms[0].value;
	coverpoint alarms[0].finished;*/

	coverpoint dut.cr_bits;
	/*coverpoint cr_bits.active;
	coverpoint cr_bits.clientA_clock;
	coverpoint cr_bits.clientB_clock;
	coverpoint cr_bits.clientA_alarm;
	coverpoint cr_bits.clientB_alarm;*/

	// Coverage is missing when Opcode is 000, but not all the time
	coverpoint dut.checkInst.ctrlA[31:29]{
		bins set_BC              = {32'b001};
		bins toggle_BC           = {32'b010};
		bins set_AT              = {32'b101};
		bins set_Countdown       = {32'b110};
		bins toggle_AT           = {32'b111};
		bins set_ATS21_mode      = {32'b011};
		bins invalid_instruction = default;
	}
	coverpoint dut.checkInst.ctrlB[31:29]{
		bins set_BC              = {32'b001};
		bins toggle_BC           = {32'b010};
		bins set_AT              = {32'b101};
		bins set_Countdown       = {32'b110};
		bins toggle_AT           = {32'b111};
		bins set_ATS21_mode      = {32'b011};
		bins invalid_instruction = default;
	}
	
	// Coverage is missing when Opcode is 000, but not all the time
	coverpoint dut.processInst.ctrlA;
	coverpoint dut.processInst.ctrlB;

	coverpoint all_alarms {
		bins no_alarms   = {24'd0};
		bins one_alarm   = {24'd1};
		bins two_alarms  = {24'd2};
		bins many_alarms = default;
	}

	coverpoint sameOpcode;
	coverpoint ABsameTime;

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

	/*coverpoint data[0];
	coverpoint data[1];
	coverpoint data[2];
	coverpoint data[3];
	coverpoint data[4];
	coverpoint data[5];
	coverpoint data[6];
	coverpoint data[7];
	coverpoint data[8];
	coverpoint data[9];
	coverpoint data[10];
	coverpoint data[11];
	coverpoint data[12];
	coverpoint data[13];
	coverpoint data[14];
	coverpoint data[15];
	coverpoint data[16];
	coverpoint data[17];
	coverpoint data[18];
	coverpoint data[19];
	coverpoint data[20];
	coverpoint data[21];
	coverpoint data[22];
	coverpoint data[23];*/

	coverpoint stat {
		bins Nack   = {2'b00};
		bins Ack_A  = {2'b01};
		bins Ack_B  = {2'b10};
		bins Ack_AB = {2'b11};
	}

endgroup // instructions

ats21 fcover = new;

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

	while (fcover.get_coverage()<100) begin
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
