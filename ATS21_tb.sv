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

// Reference Clock Generator (8ns Period)
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
	set_clock(4'b0000, 2'b00, "a");
	// Set clock 1 to 2X from B
	set_clock(4'b0001, 2'b01, "b");
	send_instruction(a,b);

	// Set clock 0 to 4X from A
	set_clock(4'b0000, 2'b10, "a");
	// Set clock 2 to 1X from B
	set_clock(4'b0010, 2'b00, "b");
	send_instruction(a,b);

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
		a = '0;
	end else begin
		b = '0;
	end
endtask

// Set Clock Instruction (Opcode 001)
task set_clock(logic[3:0] clock_id, logic[1:0] rate, string client);
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
	// Assert 'req' for 1 clock cycle and then send ctrlA and ctrlB
	// words one cycle after another. Then finally wait two cycles for
	// the second word to latch and DUT to respond before sending anything more.

	// NOTE FOR TESTING: According to v0.4 of the design document, the same cycle
	// req is asserted is when the design should bring in the top 16 bits, second 16 bits
	// the next cycle. The following cycle, bits [15:12] of the client need to go to '000'
	// to distinguish which client is requesting. If req is high for two cycles, it is an
	// indication a request is coming from the other client the cycle after.

	// Summary: We need to adapt our design to latch the inputs the same cycle req is high as
	// well as seperating A and B coming in as two processes rather than each happening always together
	// everytime req is high.

	req = 1;
	ctrlA = a[31:16];
	ctrlB = b[31:16];
	wait_cycles(1);
	req = 0;
	ctrlA = a[15:0];
	ctrlB = b[15:0];
	wait_cycles(1);
endtask

endmodule
