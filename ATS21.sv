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

Assumptions:
	- Active High Signals
		- Reset
		- Req
		- Outputs (Ready, Data)
		- Clk 1x is 8ns period (Reference Clock)
		- Clk 2x is 4ns period
		- Clk 4x is 2ns period

*/

timeunit 1ns/1ns;

module ATS21 (
  input logic         clk,
  input logic         reset,
  input logic         req,
  input logic  [15:0] ctrlA,
  input logic  [15:0] ctrlB,
  output logic        ready,
  output logic [ 1:0] statA,
  output logic [ 1:0] statB,
  output logic [23:0] data
);

////////////////////////////////////////////////////////////////////
////////// Design Clocks, Parameters, and Data Structures //////////
////////////////////////////////////////////////////////////////////

// Parameters
parameter clock_width = 16;
parameter num_alarms = 24;
parameter num_clocks = 16;
parameter num_clocks_bits = $clog2(num_clocks);

// Status States
enum logic {Nack = 1'b0, Ack = 1'b1} statusA, statusB;
assign stat = {statusB, statusA};

// temp regs for entire 32-bit input instruction
logic [31:0] ctrlA_inst, ctrlB_inst;

// Internal Clock Signals
logic clk_1x;
logic clk_2x = 0;
logic clk_4x = 0;

// Each clock is a packed struct with 1 bit for enabling / disabling
// the clock and 'clock_width' bits for the counter.
typedef struct packed {
	logic enable;
	logic [clock_width-1:0] count;
	logic [1:0] rate;
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
  logic countdown;
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

/////////////////////////////////////////
////////// Tasks and Functions //////////
/////////////////////////////////////////

// Task that resets the controller (all clocks, and alarms/timers)
task Reset();
  // Reset Status Signals
  ready = 1'b0;
  statusA = Nack;
  statusB = Nack;

	// Reset Clocks
	for(int i=0; i<num_clocks; i++)
	 begin
		base_clocks[i].enable = 0;
		base_clocks[i].count = '0;
    base_clocks[i].rate = '0;
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

// Assume 2X Clock is 4ns Period
task Generate_2x_Clock();
	repeat(2) #2 clk_2x <= ~clk_2x;
endtask

// Assume 4X Clock is 2ns Period
task Generate_4x_Clock();
	repeat(4) #1 clk_4x <= ~clk_4x;
endtask

// check if ctrlA and ctrlB have same opcode
// if so, check if they are trying to change the same clock/alarm/timer
// if so, disregard instruction (Nack)
// also, if both are trying to write to control register, disregard instruction (Nack)
// if all is in order, call processInst task
task checkInst(input logic [31:0] ctrlA, input logic [31:0] ctrlB);
  if (ctrlA[31:29] == ctrlB[31:29]) begin
    case (ctrlA[31:29])
      001:
        begin
          if (ctrlA[28:25] == ctrlB[28:25]) begin
            statusA <= Nack;
            statusB <= Nack;
          end
          else begin
            processInst(ctrlA, ctrlB);
          end
        end
      010:
        begin
          if (ctrlA[28:25] == ctrlB[28:25]) begin
            statusA <= Nack;
            statusB <= Nack;
          end
          else begin
            processInst(ctrlA, ctrlB);
          end
        end
      101:
        begin
          if (ctrlA[28:24] == ctrlB[28:24]) begin
            statusA <= Nack;
            statusB <= Nack;
          end
          else begin
            processInst(ctrlA, ctrlB);
          end
        end
      110:
        begin
          if (ctrlA[28:24] == ctrlB[28:24]) begin
            statusA <= Nack;
            statusB <= Nack;
          end
          else begin
            processInst(ctrlA, ctrlB);
          end
        end
      111:
        begin
          if (ctrlA[28:24] == ctrlB[28:24]) begin
            statusA <= Nack;
            statusB <= Nack;
          end
          else begin
            processInst(ctrlA, ctrlB);
          end
        end
      default:
        begin
          statusA <= Nack;
          statusB <= Nack;
        end
    endcase
  end
  else if (((ctrlA[31:29] == 3'b101) && (ctrlB[31:29] == 3'b110)) ||
      ((ctrlA[31:29] == 3'b110) && (ctrlB[31:29] == 3'b101))) begin
    if (ctrlA[28:24] == ctrlB[28:24]) begin
      statusA <= Nack;
      statusB <= Nack;
    end
    else begin
      processInst(ctrlA, ctrlB);
    end
  end
  else begin
    processInst(ctrlA, ctrlB);
  end
endtask

task processInst(input logic [31:0] ctrlA, input logic [31:0] ctrlB);
    // process ctrlA instruction
    case (ctrlA[31:29])   // opcode
      3'b001:   // set clock
        begin
          if (cr_bits.clientA_clock) begin
            base_clocks[ctrlA[28:25]].rate <= ctrlA[23:22];
            base_clocks[ctrlA[28:25]].count <= ctrlA[15:0];
            statusA <= Ack;
          end
          else begin
            statusA <= Nack;
          end
        end
      3'b010:   // enable/disable clock
        begin
          if (cr_bits.clientA_clock) begin
            base_clocks[ctrlA[28:25]].enable <= ctrlA[23];
            statusA <= Ack;
          end
          else begin
            statusA <= Nack;
          end
        end
      3'b101:   // set alarm
        begin
          if (cr_bits.clientA_alarm) begin
            alarms[ctrlA[28:24]].assigned_clock <= ctrlA[19:16];
            alarms[ctrlA[28:24]].countdown <= 1'b0;
            alarms[ctrlA[28:24]].loop <= ctrlA[23];
            alarms[ctrlA[28:24]].value <= ctrlA[15:0];
            #1 alarms[ctrlA[28:24]].enable <= 1'b1;    // enable alarm when set
            statusA <= Ack;
          end
          else begin
            statusA <= Nack;
          end
        end
      3'b110:   // set countdown timer
        begin
          if (cr_bits.clientA_alarm) begin
            alarms[ctrlA[28:24]].assigned_clock <= ctrlA[19:16];
            alarms[ctrlA[28:24]].countdown <= 1'b1;
            alarms[ctrlA[28:24]].loop <= 1'b0;
            alarms[ctrlA[28:24]].value <= ctrlA[15:0] + base_clocks[ctrlA[19:16]].count; // timer expires at current base clock plus duration of timer
            #1 alarms[ctrlA[28:24]].enable <= 1'b1;    // enable timer when set
            statusA <= Ack;
          end
          else begin
            statusA <= Nack;
          end
        end
      3'b111:   // enable/disable alarm/timer
        begin
          if (cr_bits.clientA_alarm) begin
            alarms[ctrlA[28:24]].enable <= ctrlA[23];
          end
          else begin
            statusA <= Nack;
          end
        end
      3'b011:   // set ATS21 mode
        begin
          cr_bits.active <= ctrlA[28];
          cr_bits.clientA_clock <= ctrlA[27:26];
          cr_bits.clientA_alarm <= ctrlA[25:24];
        end
      default:  statusA <= Nack;
    endcase

    // process ctrlB instruction
    case (ctrlB[31:29])   // opcode
      3'b001:   // set clock
        begin
          if (cr_bits.clientB_clock) begin
            base_clocks[ctrlB[28:25]].rate <= ctrlB[23:22];
            base_clocks[ctrlB[28:25]].count <= ctrlB[15:0];
            statusB <= Ack;
          end
          else begin
            statusB <= Nack;
          end
        end
      3'b010:   // enable/disable clock
        begin
          if (cr_bits.clientB_clock) begin
            base_clocks[ctrlB[28:25]].enable <= ctrlB[23];
            statusB <= Ack;
          end
          else begin
            statusB <= Nack;
          end
        end
      3'b101:   // set alarm
        begin
          if (cr_bits.clientB_alarm) begin
            alarms[ctrlB[28:24]].assigned_clock <= ctrlB[19:16];
            alarms[ctrlB[28:24]].countdown <= 1'b0;
            alarms[ctrlB[28:24]].loop <= ctrlB[23];
            alarms[ctrlB[28:24]].value <= ctrlB[15:0];
            #0 alarms[ctrlB[28:24]].enable <= 1'b1;    // enable alarm when set
            statusB <= Ack;
          end
          else begin
            statusB <= Nack;
          end
        end
      3'b110:   // set countdown timer
        begin
          if (cr_bits.clientB_alarm) begin
            alarms[ctrlB[28:24]].assigned_clock <= ctrlB[19:16];
            alarms[ctrlB[28:24]].countdown <= 1'b1;
            alarms[ctrlB[28:24]].loop <= 1'b0;
            alarms[ctrlB[28:24]].value <= ctrlB[15:0] + base_clocks[ctrlB[19:16]].count;  // timer expires at current base clock plus duration of timer
            #0 alarms[ctrlB[28:24]].enable <= 1'b1;    // enable timer when set
            statusB <= Ack;
          end
          else begin
            statusB <= Nack;
          end
        end
      3'b111:   // enable/disable alarm/timer
        begin
          if (cr_bits.clientB_alarm) begin
            alarms[ctrlB[28:24]].enable <= ctrlB[23];
          end
          else begin
            statusB <= Nack;
          end
        end
      3'b011:   // set ATS21 mode
        begin
          cr_bits.active <= ctrlA[28];
          cr_bits.clientB_clock <= ctrlB[27:26];
          cr_bits.clientB_alarm <= ctrlB[25:24];
        end
      default:  statusB <= Nack;
    endcase
endtask

task Check_Alarms();
  int i;
  for (i = 0; i < num_alarms; i = i + 1) begin
    if ((base_clocks[i].count == alarms[i].value) && alarms[i].enable) begin
      repeat(2) @(posedge clk) alarms[i].finished <= 1'b1;
      alarms[i].finished <= 1'b0;
      if (~alarms[i].loop) begin
        alarms[i].enable <= 1'b0;   // disable alarm if not set to repeat
      end
    end
    else
      alarms[i].finished <= 1'b0;
  end
endtask

/////////////////////////////////////////////////////////////////
////////// Reference Design Behaviorial Implementation //////////
/////////////////////////////////////////////////////////////////

// Clock 1X Generation
assign clk_1x = clk;

// Clock 2X Generation
always @(clk_1x) begin : clk2x_generation
	Generate_2x_Clock();
end

// Clock 4X Generation
always @(clk_1x) begin : clk4x_generation
	Generate_4x_Clock();
end

logic readFlag;     // read input while flag is high
logic readComplete; // full 32-bit instruction has been read
logic byteCount;    // keep track of input bytes

// Behaviorial Block
always_ff @(posedge clk or posedge reset) begin : module_behavior
	// Reset Detection
	if(reset)
		Reset();
	// Normal Operation
	else if (readFlag) begin
      ready <= 1'b0;
      if (byteCount == 0) begin         // read first 16-bit input
        ctrlA_inst[31:16] <= ctrlA;     // read ctrlA
        ctrlB_inst[31:16] <= ctrlB;     // read ctrlB
        byteCount <= 1'b1;              // increment byte count
       end
      else if (byteCount == 1) begin    // read second 16-bit input
        ctrlA_inst[15:0] <= ctrlA;      // read ctrlA
        ctrlB_inst[15:0] <= ctrlB;      // read ctrlB
        byteCount <= 1'b0;              // reset byte count
        readFlag <= 1'b0;               // stop reading
        readComplete <= 1'b1;           // full 32-bit instruction received
       end
      end

	if (req) begin
      ready <= 1'b1;      // ready to receive input
      readFlag <= 1'b1;   // begin read cycle
      end

    if (readComplete) begin
      readComplete <= 1'b0;
      checkInst(ctrlA_inst, ctrlB_inst);    // process ctrl instructions
    end

    Check_Alarms();
end

//int n, j, k;  // loop incrementers for base clocks

// increment 1x base clocks
always_ff @(posedge clk) begin
  int i;
  for (i = 0; i < num_clocks; i = i + 1) begin
    if (base_clocks[i].enable) begin
      if (base_clocks[i].rate == 2'b00) begin
        base_clocks[i].count <= base_clocks[i].count + 1;
      end
    end
  end
end

// increment 2x base clocks
always_ff @(posedge clk_2x) begin
  int i;
  for (i = 0; i < num_clocks; i = i + 1) begin
    if (base_clocks[i].enable) begin
      if (base_clocks[i].rate == 2'b01) begin
        base_clocks[i].count <= base_clocks[i].count + 1;
      end
    end
  end
end

// increment 4x base clocks
always_ff @(posedge clk_4x) begin
  int i;
  for (i = 0; i < num_clocks; i = i + 1) begin
    if (base_clocks[i].enable) begin
      if (base_clocks[i].rate == 2'b10) begin
        base_clocks[i].count <= base_clocks[i].count + 1;
      end
    end
  end
end

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
