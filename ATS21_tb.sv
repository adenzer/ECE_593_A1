/*

Andrew Denzer and Zack Fravel
ECE593 Assignment 1
Spring 2021

ATS21_tb.sv
--------------------
Description:

DUT takes a 32 bit instruction in two sets of 16 bits each clock (2 clocks). Tasks
for each instruction are implemented to make stimulus generation simple for the testbench
writer. A seperate send_instruction() task asserts the 'req' signal to the design and
sends the ctrlA and ctrlB inputs to the desired instructions to send. After the exit_simulation()
task is called, the tool exits after 20 clock cycles.

Current Tests :

	Test Reset
		- All clocks and alarms set to 0, control bits set to 1.
	Test setting BCs and ATs
		- Correct rates and clocks specified by the instructions are set
	Test sending simultaneous and staggered instructions
		- Verified all forms of instruction input layed out in the v0.4 design document can be
		  handled by the design and testbench feeds the design accordingly.
		  	- When one client makes a request a Nop() is called for the other client.
		  	- When both clients make a request, they are both handled.
		  	- When one client makes a request the cycle after another (i.e. req is high two cycles)
		  	  they are both handled properly.
	Test AT function
		- Alarm goes off when 'n' count is reached on one of the 16 specified clocks
		- Countdown goes off 'n' cycles after the client req is asserted
		- Multiple data bits are able to be asserted simulatenously

Future Tests :

	Test ATS21 Modes more thoroughly
	Clock start values
	Repeating Alarms (longer simulations)
	Disabling / Reenabling alarms and clocks

*/

////////////////////////////////////////////////////
////////// Module and Signal Declarations //////////
////////////////////////////////////////////////////

timeunit 1ns/1ns;

module ATS21_tb ();

// DUT Signals
logic clk, reset, req, ready;
logic [1:0] stat;
logic [15:0] ctrlA, ctrlB;
logic [ 2:0] opcodeA, opcodeB;
logic [23:0] data;

logic [15:0] BC_enable;
logic [15:0] BC_rate;
logic [15:0] BC_count;

logic [23:0] alarm_enable;
logic [23:0] alarm_countdown;
logic [23:0] alarm_loop;
logic [23:0] [3:0] alarm_bc;
logic [23:0] [15:0] alarm_value;
logic [23:0] alarm_finished;


// Instantiate DUT
ATS21 dut(.clk(clk), .reset(reset), .req(req), .ctrlA(ctrlA), .ctrlB(ctrlB),
			.ready(ready), .stat(stat), .data(data), .opcodeA_proc(opcodeA), .opcodeB_proc(opcodeB));

// Reference Clock Generator
always begin
	#1 clk = ~clk;
end

///////////////////////////////////////
////////// Testbench Simulus //////////
///////////////////////////////////////

assign sameOpcode = opcodeA == opcodeB;
assign ABsameTime = opcodeA != 3'b000 && opcodeB != 3'b000;

genvar j;
generate
	for (j = 0; j < 16; j++)
	 begin
		assign BC_enable[j] = dut.base_clocks[j].enable;
		assign BC_rate[j] = dut.base_clocks[j].rate;
		assign BC_count[j] = dut.base_clocks[j].count;
	 end
endgenerate

genvar k;
generate
	for (k = 0; k < 24; k++)
	 begin
		assign alarm_enable[k] = dut.alarms[k].enable;
		assign alarm_countdown[k] = dut.alarms[k].countdown;
		assign alarm_loop[k] = dut.alarms[k].loop;
		assign alarm_bc[k] = dut.alarms[k].assigned_clock;
		assign alarm_value[k] = dut.alarms[k].value;
		assign alarm_finished[k] = dut.alarms[k].finished;
	 end
endgenerate

covergroup ats21 @(posedge clk);
	option.at_least =2;
	coverpoint opcodeA {
		bins a0[1] = {3'b001};
		bins a1[1] = {3'b010};
		bins a2[1] = {3'b101};
		bins a3[1] = {3'b110};
		bins a4[1] = {3'b111};
		bins a5[1] = default;
	}
	coverpoint opcodeB {
		bins a0[1] = {3'b001};
		bins a1[1] = {3'b010};
		bins a2[1] = {3'b101};
		bins a3[1] = {3'b110};
		bins a4[1] = {3'b111};
		bins a5[1] = default;
	}
	coverpoint sameOpcode;
	coverpoint ABsameTime;

	coverpoint BC_rate;
	coverpoint BC_count;
	coverpoint BC_enable;
	coverpoint alarm_enable;
	coverpoint alarm_countdown;
	coverpoint alarm_loop;
	coverpoint alarm_bc;
	coverpoint alarm_value[0];
	coverpoint alarm_value[1];
	coverpoint alarm_value[2];
	coverpoint alarm_value[3];
	coverpoint alarm_finished;

	coverpoint dut.checkInst.ctrlA;
	coverpoint dut.checkInst.ctrlB;

	coverpoint dut.processInst.ctrlA;
	coverpoint dut.processInst.ctrlB;

	coverpoint dut.cr_bits;


	coverpoint data[0];
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
	coverpoint data[23];

	coverpoint stat {
		bins a0[1] = {2'b00};
		bins a1[1] = {2'b01};
		bins a2[1] = {2'b10};
		bins a3[1] = {2'b11};
	}
endgroup // instructions

ats21 fcover = new;


class RandomInput;
	rand bit[15:0] rand_ctrlA;
	rand bit[15:0] rand_ctrlB;
	rand bit			 rand_req;
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
