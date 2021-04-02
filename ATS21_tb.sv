/*

Andrew Denzer and Zack Fravel
ECE593 Assignment 1
Spring 2021

ATS21_tb.sv
--------------------
Description:


*/


timeunit 1ns/1ns;

module ATS21_tb ();

logic clk, reset, req, ready;
logic [1:0] stat;
logic [15:0] ctrlA, ctrlB;
logic [23:0] data;

ATS21 dut(.clk(clk), .reset(reset), .req(req), .ctrlA(ctrlA), .ctrlB(ctrlB), 
			.ready(ready), .stat(stat), .data(data));

// Reference Clock Generator (8ns Period)
always begin
	#4 clk = ~clk;
end

// Initial Block
initial begin
	// Initialize Variables and Reset for 4 cycles
	clk = 0;
	reset = 1;
	repeat(4) @(posedge(clk));
	reset = 0;
	// Stop Simulation after 20 cycles
	repeat(20) @(posedge(clk));
	$stop;
end

endmodule
