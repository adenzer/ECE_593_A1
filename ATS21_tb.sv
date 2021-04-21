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
logic [23:0] data;

// Testbench Input Signals
logic[31:0] a, b;
logic[15:0] a_first, a_second, b_first, b_second;

// Instantiate DUT
ATS21 dut(.clk(clk), .reset(reset), .req(req), .ctrlA(ctrlA), .ctrlB(ctrlB),
			.ready(ready), .stat(stat), .data(data));

// Reference Clock Generator 
always begin
	#1 clk = ~clk;
end

///////////////////////////////////////
////////// Testbench Simulus //////////
///////////////////////////////////////

// Simulation
initial begin
	// Initialize Design
	initialize();

	// Set clock 0 to 1X from A
	set_clock(4'b0000, 2'b00, 16'h0000, "a");
	// Set clock 1 to 2X from B
	set_clock(4'b0001, 2'b01, 16'h0000, "b");
	// Simulatenous Instructions
	send_instruction(a, b);

	wait_cycles(10);

	// Set clock 1 to 4X from A
	set_clock(4'b0001, 2'b10, 16'h0000, "a");
	// Set clock 2 to 1X from B
	set_clock(4'b0010, 2'b00, 16'h0000, "b");
	// Simulatenous Instructions
	send_instruction(a, b);

	wait_cycles(10);

	// Set alarm 0 to reference clock 0, loop, and go off at count 50 cycles
	set_alarm(5'b00000, 1'b1, 4'b0000, 16'd50, "a");
	// Set alarm 23 to reference clock 0, don't loop, and go off at count 50 cycles
	set_alarm(5'b10111, 1'b0, 4'b0000, 16'd50, "b");
	// Staggered Instructions Testing
	send_staggered_instructions(a,b);

	wait_cycles(15);

	// Set alarm 1 to reference clock 1, and go off after 10 cycles (countdown)
	set_countdown(5'b00001, 4'b0001, 16'd10, "a");
	Nop("b");
	send_instruction(a, b);

	wait_cycles(30);

	// Set clock 3 to 1X from A
	set_clock(4'b0011, 2'b00, 16'h0000, "a");
	// Set clock 4 to 2X from B
	set_clock(4'b0100, 2'b01, 16'h0000, "b");
	// Staggered Instructions Testing
	send_staggered_instructions(a,b);

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
	clk = 0; reset = 1; req = 0;
	ctrlA = '0; ctrlB = '0;
	a_first = '0; a_second = '0;
	b_first = '0; b_second = '0;
	a = '0; b = '0;
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

// No Operation
task Nop(string client);
	// Clear A and B input vectors
	if (client == "a") begin
		a[15:12] = 3'b000;
	end else begin
		b[15:12] = 3'b000;
	end
endtask

// Set Clock Instruction (Opcode 001)
task set_clock(logic[3:0] clock_id, logic[1:0] rate, logic[15:0] time_val, string client);
	// Check for which client is setting the clock and set fields accordingly:
	// - [1][12:9] Clock #
	// - [1][7:6] Rate
	// - [1][5:0] Unused
	// - [0][15:0] Unused
	if (client == "a") begin
		// Clear Buffers
		a_first = '0;
		a_second = '0;
		// Set Fields
		a_first[15:13] = 3'b001;
		a_first[12:9] = clock_id;
		a_first[7:6] = rate;
		a_second = time_val;
		// Assign Output
		a = {a_first, a_second};
	end else begin
		// Clear Buffers
		b_first = '0;
		b_second = '0;
		// Set Fields
		b_first[15:13] = 3'b001;
		b_first[12:9] = clock_id;
		b_first[7:6] = rate;
		b_second = time_val;
		// Assign Output
		b = {b_first, b_second};
	end
endtask

// Enable / Disable Clock (Opcode 010)
task toggle_BCs(logic[3:0] clock_id, logic toggle, string client);
	// Check for which client is setting the clock and set fields accordingly:
	// - [1][12:9] Clock #
	// - [1][7] Enable/Disable
	// - [1][6:0] Unused
	// - [0][15:0] Unused
	if (client == "a") begin
		// Clear Buffers
		a_first = '0;
		a_second = '0;
		// Set Fields
		a_first[15:13] = 3'b010;
		a_first[12:9] = clock_id;
		a_first[7] = toggle;
		// Assign Output
		a = {a_first, a_second};
	end else begin
		// Clear Buffers
		b_first = '0;
		b_second = '0;
		// Set Fields
		b_first[15:13] = 3'b010;
		b_first[12:9] = clock_id;
		b_first[7] = toggle;
		// Assign Output
		b = {b_first, b_second};
	end
endtask

// Set Alarm (Opcode 101)
task set_alarm(logic[4:0] alarm_id, logic loop, logic[3:0] clock_id, logic[15:0] alarm_time, string client);
	// Check for which client is setting the clock and set fields accordingly:
	// - [1][12:8] Alarm/Timer #
	// - [1][7] Repeat
	// - [1][6:4] Unused
	// - [1][3:0] Clock #
	// - [0][15:0] Alarm Time
	if (client == "a") begin
		// Clear Buffers
		a_first = '0;
		a_second = '0;
		// Set Fields
		a_first[15:13] = 3'b101;
		a_first[12:8] = alarm_id;
		a_first[7] = loop;
		a_first[3:0] = clock_id;
		a_second = alarm_time;
		// Assign Output
		a = {a_first, a_second};
	end else begin
		// Clear Buffers
		b_first = '0;
		b_second = '0;
		// Set Fields
		b_first[15:13] = 3'b101;
		b_first[12:8] = alarm_id;
		b_first[7] = loop;
		b_first[3:0] = clock_id;
		b_second = alarm_time;
		// Assign Output
		b = {b_first, b_second};
	end
endtask

// Set Countdown Timer (Opcode 110)
task set_countdown(logic[4:0] alarm_id, logic[3:0] clock_id, logic[15:0] interval, string client);
	// Check for which client is setting the clock and set fields accordingly:
	// - [1][12:8] Alarm/Timer #
	// - [1][7:4] Unused
	// - [1][3:0] Clock #
	// - [0][15:0] Interval
	if (client == "a") begin
		// Clear Buffers
		a_first = '0;
		a_second = '0;
		// Set Fields
		a_first[15:13] = 3'b110;
		a_first[12:8] = alarm_id;
		a_first[3:0] = clock_id;
		a_second = interval;
		// Assign Output
		a = {a_first, a_second};
	end else begin
		// Clear Buffers
		b_first = '0;
		b_second = '0;
		// Set Fields
		b_first[15:13] = 3'b110;
		b_first[12:8] = alarm_id;
		b_first[3:0] = clock_id;
		b_second = interval;
		// Assign Output
		b = {b_first, b_second};
	end
endtask

// Enable / Disable Alarm/Timer (Opcode 111)
task toggle_ATs(logic[4:0] alarm_id, logic toggle, string client);
	// Check for which client is setting the clock and set fields accordingly:
	// - [1][12:8] Alarm/Timer #
	// - [1][7] Enable/Disable
	// - [1][6:0] Unused
	// - [0][15:0] Unused
	if (client == "a") begin
		// Clear Buffers
		a_first = '0;
		a_second = '0;
		// Set Fields
		a_first[15:13] = 3'b111;
		a_first[12:8] = alarm_id;
		a_first[7] = toggle;
		// Assign Output
		a = {a_first, a_second};
	end else begin
		// Clear Buffers
		b_first = '0;
		b_second = '0;
		// Set Fields
		b_first[15:13] = 3'b111;
		b_first[12:8] = alarm_id;
		b_first[7] = toggle;
		// Assign Output
		b = {b_first, b_second};
	end
endtask

// Set ATS21 Mode (Opcode 011)
task set_ATS21_Mode(logic active, logic[1:0] AT_permissions, logic[1:0] BC_permissions, string client);
	// Check for which client is setting the clock and set fields accordingly:
	// - [1][12] Active
	// - [1][11:10] Allow Timer/Alarm Change
	// - [1][9:8] Allow Clock Change
	// - [1][7:0] Unused
	// - [0][15:0] Unused
	if (client == "a") begin
		// Clear Buffers
		a_first = '0;
		a_second = '0;
		// Set Fields
		a_first[15:13] = 3'b011;
		a_first[12] = active;
		a_first[11:10] = AT_permissions;
		a_first[9:8] = BC_permissions;
		// Assign Output
		a = {a_first, a_second};
	end else begin
		// Clear Buffers
		b_first = '0;
		b_second = '0;
		// Set Fields
		b_first[15:13] = 3'b011;
		b_first[12] = active;
		b_first[11:10] = AT_permissions;
		b_first[9:8] = BC_permissions;
		// Assign Output
		b = {b_first, b_second};
	end
endtask

// Send Instruction Task
task send_instruction(logic[31:0] a, logic[31:0] b);

	// NOTE FOR TESTING: According to v0.4 of the design document, the same cycle
	// req is asserted is when the design should bring in the top 16 bits, second 16 bits
	// the next cycle. The following cycle, bits [15:12] of the client need to go to '000'
	// to distinguish which client is requesting. If req is high for two cycles, it is an
	// indication a request is coming from the other client the cycle after.

	// Assert 'req' for 1 clock cycle and then send ctrlA and ctrlB
	// words one cycle after another. Then finally wait one cycle for
	// the second word to latch and DUT to respond before sending anything more.

	// If we're only sending one instruction, be sure to set the other input to a Nop.

	req = 1;
	ctrlA = a[31:16];
	ctrlB = b[31:16];
	wait_cycles(1);
	req = 0;
	ctrlA = a[15:0];
	ctrlB = b[15:0];
	wait_cycles(1);

endtask

// Send Staggered Instructions Task
task send_staggered_instructions(logic[31:0] a, logic[31:0] b);

	// Testing when 'req' is high for two cycles. Design should take in the first 16 bits on the first
	// instruction while req is high for the first cycle, then the second 16 bits the second cycle while
	// also capturing the first 16 bits from the second instruction then the second 16 bits the next cycle. 

	req = 1;
	ctrlA = a[31:16];
	ctrlB[15:12] = 3'b000;
	wait_cycles(1);
	ctrlA = a[15:0];
	ctrlB = b[31:16];
	wait_cycles(1);
	req = 0;
	ctrlA[15:12] = 3'b000;
	ctrlB = b[15:0];
	wait_cycles(1);

endtask

endmodule
