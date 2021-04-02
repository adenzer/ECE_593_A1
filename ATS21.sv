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

////////// Design Parameters and Data Structures //////////

parameter clock_width = 16;
parameter num_alarms = 24;
parameter num_clocks = 16;
parameter num_clocks_bits = $clog2(num_clocks);

// Each clock is a packed struct with 1 bit for enabling / disabling
// the clock and 'clock_width' bits for the counter. 
typedef struct packed {
	logic enable;
	logic [clock_width-1:0] count;
} Clock;

// Array of Clocks
Clock [num_clocks-1:0] base_clocks;

// Each alarm is a packed struct with 1 bit for enabling / disbaling
// the alarm and 'clock_width' bits for the value to be compared to the
// clocks. There is another bit 'loop' that indicates if the alarm should
// restart after asserting the 'finished' bit for 2 cycles once the value
// has been reached by the clock. Finally the 'assigned_clock' field is used
// so the design knows which clock to compare the alarm against. 
typedef struct packed {
	logic enable;
	logic loop;
	logic [num_clocks_bits-1:0] assigned_clock;
	logic [clock_width-1:0] value;
	logic finished;
} Alarm;

// Array of Alarms.
Alarm [num_alarms-1:0] alarms; 

// Control Registers
typedef struct packed {
	logic active;
	logic clientA_clock;
	logic clientB_clock;
	logic clientA_alarm;
	logic clientB_alarm;
	logic unused_5;
	logic unused_6;
	logic unused_7;
} ControlRegisters;

ControlRegisters cr_bits;

////////// Reference Design Behavior //////////



// Continuous assignment of all alarm 'finished' signals with the corrosponding 
// data output bit. (i.e. alarms[0].finished = data[0], and so on . . .) 
genvar i;
generate
	for (i = 0; i < num_alarms; i++)
	begin
		assign data[i] = alarms[i].finished;
	end
endgenerate

endmodule
