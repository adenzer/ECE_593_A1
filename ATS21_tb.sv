/*

Andrew Denzer and Zack Fravel
ECE593 Assignment 1
Spring 2021

ATS21_tb.sv
--------------------
Description:

DUT takes a 32 bit instruction in two sets of 16 bits each clock (2 clocks)
represented by [1] for the first 16 bits (MSB) and [0] for the second 16 bits (LSB).

[15:13] Opcodes:

000: No Operation

001: Set Clock 
	- [1][12:9] Clock #
	- [1][7:6] Rate
	- [1][5:0] Unused
	- [0][15:0] Unused

010: Enable/Disable Clock
	- [1][12:9] Clock #
	- [1][7] Enable/Disable
	- [1][6:0] Unused
	- [0][15:0] Unused

101: Set Alarm
	- [1][12:8] Alarm/Timer #
	- [1][7] Repeat
	- [1][6:4] Unused
	- [1][3:0] Clock #
	- [0][15:0] Alarm Time

110: Set Countdown Timer
	- [1][12:8] Alarm/Timer #
	- [1][7:4] Unused
	- [1][3:0] Clock #
	- [0][15:0] Interval

111: Enable/Disable Alarm/Timer
	- [1][12:8] Alarm/Timer #
	- [1][7] Enable/Disable 
	- [1][6:0] Unused
	- [0][15:0] Unused

011: Set ATS21 Mode
	- [1][12] Active
	- [1][11:10] Allow Timer/Alarm Change
	- [1][9:8] Allow Clock Change
	- [1][7:0] Unused
	- [0][15:0] Unused

*/


timeunit 1ns/1ns;

module ATS21_tb ();

// DUT Signals
logic clk, reset, req, ready;
logic [1:0] stat;
logic [15:0] ctrlA, ctrlB;
logic [23:0] data;

// Testbench Input Signals
logic[31:0] a, b;

// Instantiate DUT
ATS21 dut(.clk(clk), .reset(reset), .req(req), .ctrlA(ctrlA), .ctrlB(ctrlB), 
			.ready(ready), .stat(stat), .data(data));

// Reference Clock Generator (8ns Period)
always begin
	#4 clk = ~clk;
end

// Initial Block
initial begin
	// Initialize Variables and Reset for 4 cycles
	initialize();
	a = 32'h11114444;
	b = 32'h22223333;
	send_instruction(a, b);
	// Stop Simulation after 20 cycles
	repeat(20) @(posedge(clk));
	$stop;
end

task wait_cycles(int t);
	repeat(t) @(posedge(clk));
endtask 

task initialize();
	clk = 0;
	reset = 1;
	req = 0;
	ctrlA = '0;
	ctrlB = '0;
	wait_cycles(4);
	reset = 0;
	wait_cycles(1);
endtask

task send_instruction(logic[31:0] a, logic[31:0] b);
	req = 1;
	wait_cycles(1);
	req = 0;
	ctrlA = a[31:16];
	ctrlB = b[31:16];
	wait_cycles(1);
	ctrlA = a[15:0];
	ctrlB = b[15:0];
	wait_cycles(1);
endtask

endmodule
