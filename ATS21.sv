/*

Andrew Denzer and Zack Fravel
ECE593 Assignment 1
Spring 2021

ATS21.sv
--------------------
Description:


*/

module ATS21 (
  input logic         clk,
  input logic         reset,
  input logic         req,
  input logic  [15:0] ctrlA,
  input logic  [15:0] ctrlB,
  output logic        ready,
  output logic [ 1:0] stat,
  output logic [23:0] data
);

endmodule
