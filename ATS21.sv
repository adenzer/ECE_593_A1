/*

Andrew Denzer and Zack Fravel
ECE593 Assignment 1
Spring 2021

ATS21.sv
--------------------
Description:

Implements the ATS21, a programmable multi-clock/timer/alarm component described
in the high level spec document provided by our instructor Tom Schubert. The 
component contains 16 different clocks and 24 alarms that can be set against any
of the 16 clocks. The clocks can run at 1x, 2x, or 4x the reference clock speed.

** add more here later (design assumptions, etc.) ***

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

////////// Design Clocks, Parameters, and Data Structures //////////

// Parameters
parameter clock_width = 16;
parameter num_alarms = 24;
parameter num_clocks = 16;
parameter num_clocks_bits = $clog2(num_clocks);

// Internal Clock Signals
logic clk_1x, clk_2x, clk_4x;

// Internal 1x Clock Generation
always_ff @(clk) begin : clock1x_generation
	clk_1x <= ~clk_1x;
end

// Internal 2x Clock Generation 
always_ff @(posedge clk_1x) begin : clock2x_generation
	clk_2x <= ~clk_2x;
end

// Internal 4x Clock Generation 
always_ff @(posedge clk_2x) begin : clock4x_generation
	clk_4x <= ~clk_4x;
end

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
} ControlRegisters;

ControlRegisters cr_bits;

////////// Reference Design Behaviorial Implementation //////////



// Task that resets the controller (all clocks, and alarms/timers)
task Reset();
	// Reset Clocks
	for(int i=0; i<num_clocks; i++)
	 begin
		base_clocks[i].enable = 0;
		base_clocks[i].count = '0;
	 end
	 
	// Reset Alarms
	for(int i=0; i<num_alarms; i++)
	 begin
		alarms[i].enable = 0;
		alarms[i].loop = 0;
		alarms[i].assigned_clock = '0;
		alarms[i].value = '0;
		alarms[i].finished = 0;
	 end

	// Reset Control Bits
	cr_bits.active = 0;
	cr_bits.clientA_clock = 0;
	cr_bits.clientB_clock = 0;
	cr_bits.clientA_alarm = 0;
	cr_bits.clientB_alarm = 0;
endtask

// Task that is called when an alarm or countdownt timer goes off.
task Alarm_Finished (int alarm_id);
	alarms[alarm_id].finished = 1;
	repeat(2) @(posedge(clk));
	alarms[alarm_id].finished = 0;	
endtask

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
