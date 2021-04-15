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
Clocks, Alarms, and Global Control Registers are managed using arrays of packed structs
with the appropriate fields for each struct.

The module's primary behavioral implementation begins on line 425, between there are Reset(),
AlarmFinished(), checkInst(), and processInst() tasks that are used in the behavioral blocks.
The behavior always_ff block is responsible for detecting req being asserted on the clock
and taking in the inputs using inCount signals and ctrlA/B_top buffers. The checkInst() task is
responsible for input error handling as well as instruction decoding. checkInst() then calls processInst()
for the current valid instruction where struct fields are manipulated according to the
instruction set. This is also where status bits are set. Following the calling of checkInst()
we have written always_ff blocks for incrimenting the clocks and checking the alarms for the respective
clock domains. Finally at the bottom we have two for loops, one for calling the AlarmFinished()
on detection of an alarm going off, and one for assigning all the alarm struct .finished fields
to the data output bits.

32-bit Instructions (opcode is bits [31:29]):

  Nop - 000

  Set clock - 001
      clock # - bits [28:25]
      rate - bits [23:22]
        - 00 clk
        - 01 clk/2
        - 10 clk/4

  Enable/disable clock - 010
      clock # - bits [28:25]
      enable/disable - bit [23]

  Set alarm - 101
      alarm # - bits [28:24]
      repeat - bit [23]
      clock # - bits [19:16]
      alarm time - bits [31:0]

  Set countdown timer - 110
      alarm # - bits [28:24]
      clock # - bits [19:16]
      interval - bits[31:0]

  Enable/disable alarm/timer - 111
      alarm/timer # - bits [28:24]
      enable/disable - bit [23]

  Set ATS21 mode - 011
      device active - [28]
      allow timer/alarm change - bits [27:26]
      allow clock change - bits [25:24]

*/

timeunit 1ns/1ns;

module ATS21 (
  input logic         clk,
  input logic         reset,
  input logic         req,
  input logic  [15:0] ctrlA,
  input logic  [15:0] ctrlB,
  output logic        ready,
  output logic [ 1:0] stat,
  output logic [23:0] data,
  output logic [15:0] ctrlA_top,
  output logic [15:0] ctrlB_top,
  output logic [ 2:0] opcodeA_proc,
  output logic [ 2:0] opcodeB_proc
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

// temp regs for top 16-bits of input instruction
// logic [15:0] ctrlA_top, ctrlB_top;

logic inCountA, inCountB;    // keep track of input instruction

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
    alarms[i].countdown = 0;
		alarms[i].loop = 0;
		alarms[i].assigned_clock = '0;
		alarms[i].value = '0;
		alarms[i].finished = 0;
	 end

	// Reset Control Bits
	cr_bits.active = 1;
	cr_bits.clientA_clock = 1;
	cr_bits.clientB_clock = 1;
	cr_bits.clientA_alarm = 1;
	cr_bits.clientB_alarm = 1;

  // Reset Internal Signals
  inCountA = 0;
  inCountB = 0;
  ctrlA_top = 'z;
  ctrlB_top = 'z;
endtask

// Task that is called when an alarm or countdownt timer goes off.
task Alarm_Finished ();
  int i;
	repeat(2) @(posedge(clk));
  for (i=0; i < num_alarms; i = i + 1) begin
	  alarms[i].finished = 0;
  end
endtask

// check if ctrlA and ctrlB have same opcode
// if so, check if they are trying to change the same clock/alarm/timer
// if so, disregard instruction (Nack)
// also, if both are trying to write to control register, disregard instruction (Nack)
// if all is in order, call processInst task
task checkInst(input logic [31:0] ctrlA, input logic [31:0] ctrlB);
  if (ctrlA[31:29] == ctrlB[31:29]) begin
    case (ctrlA[31:29])
      3'b001:
        begin
          if (ctrlA[28:25] == ctrlB[28:25]) begin
            statusA <= Nack;
            statusB <= Nack;
          end
          else begin
            processInst(ctrlA, ctrlB);
          end
        end
      3'b010:
        begin
          if (ctrlA[28:25] == ctrlB[28:25]) begin
            statusA <= Nack;
            statusB <= Nack;
          end
          else begin
            processInst(ctrlA, ctrlB);
          end
        end
      3'b101:
        begin
          if (ctrlA[28:24] == ctrlB[28:24]) begin
            statusA <= Nack;
            statusB <= Nack;
          end
          else begin
            processInst(ctrlA, ctrlB);
          end
        end
      3'b110:
        begin
          if (ctrlA[28:24] == ctrlB[28:24]) begin
            statusA <= Nack;
            statusB <= Nack;
          end
          else begin
            processInst(ctrlA, ctrlB);
          end
        end
      3'b111:
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
  // if one is an alarm and the other is a countdown timer, both trying to set the same alarm/timer, disregard
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

    opcodeA_proc <= ctrlA[31:29];   // for coverage
    opcodeB_proc <= ctrlB[31:29];   // for coverage

    // process ctrlA instruction
    case (ctrlA[31:29])   // opcode
      3'b001:   // set clock
        begin
          if (cr_bits.clientA_clock) begin
            base_clocks[ctrlA[28:25]].enable <= 1;
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
            alarms[ctrlA[28:24]].countdown <= 1'b0;    // alarm, not a countdown timer
            alarms[ctrlA[28:24]].loop <= ctrlA[23];    // enable/disable repeat alarm
            alarms[ctrlA[28:24]].value <= ctrlA[15:0];
            #0 alarms[ctrlA[28:24]].enable <= 1'b1;    // enable alarm when set
            #0 alarms[ctrlA[28:24]].finished <= 1'b0;
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
            alarms[ctrlA[28:24]].countdown <= 1'b1;     // countdown timer, not alarm
            alarms[ctrlA[28:24]].loop <= 1'b0;          // countdown timers can't repeat
            alarms[ctrlA[28:24]].value <= ctrlA[15:0] + base_clocks[ctrlA[19:16]].count; // timer expires at current base clock plus duration of timer
            #0 alarms[ctrlA[28:24]].enable <= 1'b1;     // enable timer when set
            #0 alarms[ctrlA[28:24]].finished <= 1'b0;
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
          cr_bits.active <= ctrlA[28];            // device enable bit
          cr_bits.clientA_clock <= ctrlA[27:26];  // alarm change permission bits
          cr_bits.clientA_alarm <= ctrlA[25:24];  // clock change permission bits
        end
      default:  statusA <= Nack;
    endcase

    // process ctrlB instruction
    case (ctrlB[31:29])   // opcode
      3'b001:   // set clock
        begin
          if (cr_bits.clientB_clock) begin
            base_clocks[ctrlB[28:25]].enable <= 1;
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
            alarms[ctrlB[28:24]].countdown <= 1'b0;    // alarm, not countdown timer
            alarms[ctrlB[28:24]].loop <= ctrlB[23];
            alarms[ctrlB[28:24]].value <= ctrlB[15:0];
            #0 alarms[ctrlB[28:24]].enable <= 1'b1;    // enable alarm when set
            #0 alarms[ctrlB[28:24]].finished <= 1'b0;
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
            alarms[ctrlB[28:24]].countdown <= 1'b1;   // countdown timer, not alarm
            alarms[ctrlB[28:24]].loop <= 1'b0;    // countdown timers cannot repeat
            alarms[ctrlB[28:24]].value <= ctrlB[15:0] + base_clocks[ctrlB[19:16]].count;  // timer expires at current base clock plus duration of timer
            #0 alarms[ctrlB[28:24]].enable <= 1'b1;    // enable timer when set
            #0 alarms[ctrlB[28:24]].finished <= 1'b0;
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
          cr_bits.active <= ctrlB[28];    // device active bit
          cr_bits.clientB_clock <= ctrlB[27:26];  //
          cr_bits.clientB_alarm <= ctrlB[25:24];
        end
      default:  statusB <= Nack;
    endcase
endtask

/////////////////////////////////////////////////////////////////
////////// Reference Design Behaviorial Implementation //////////
/////////////////////////////////////////////////////////////////

// Clock 1X Generation
assign clk_1x = clk;

// Clock / 2 Generation
always @(posedge clk_1x) begin : clkDiv2_generation
	clk_2x <= ~clk_2x;
end

// Clock / 4 Generation
always @(posedge clk_2x) begin : clkDiv4_generation
  clk_4x <= ~clk_4x;
end

// Behaviorial Block
always_ff @(posedge clk or posedge reset) begin : module_behavior
  if (cr_bits.active) begin
    // Reset Detection
  	if(reset)
  		Reset();
  	// Normal Operation
    else begin
      if (req) begin    // if device is active and request signal received
         // read first 16-bits of ctrlA instruction
        if ((ctrlA[15:13] != 3'b000) && (inCountA == 1'b0)) begin    // if not NOP and top half of instruction not yet received
          ctrlA_top <= ctrlA;
          inCountA <= 1'b1;   // on next cycle, read second half of ctrlA instruction
        end
        else begin
          inCountA <= 1'b0;
        end
        // read first 16-bits of ctrlB instruction
        if ((ctrlB[15:13] != 3'b000) && (inCountB == 1'b0)) begin    // if not NOP and top half of instruction not yet received
          ctrlB_top <= ctrlB;
          inCountB <= 1'b1;   // on next cycle, read second half of ctrlB instruction
        end
        else begin
          inCountB <= 1'b0;
        end
      end
      else begin
        inCountA <= 1'b0;
        inCountB <= 1'b0;
      end

      // read second 16-bits of new instruction(s) and call instruction procedure
      if ((inCountA == 1'b1) && (inCountB == 1'b1)) begin    // if both ctrlA and ctrlB have received first half, append second half and send to decode
        checkInst({ctrlA_top, ctrlA}, {ctrlB_top, ctrlB});
      end
      else if ((inCountA == 1'b1) && (inCountB == 1'b0)) begin   // if ctrlA is ready for second half of instruction but ctrlB is not, send ctrlA to decode and send NOP for ctrlB
        checkInst({ctrlA_top, ctrlA}, 32'h00000000);
      end
      else if ((inCountA == 1'b0) && (inCountB == 1'b1)) begin    // if ctrlB is ready for second half of instruction but ctrlA is not, send ctrlB to decode and send NOP for ctrlA
        checkInst(32'h00000000, {ctrlB_top, ctrlB});
      end
      else begin    // if neither instruction is ready, send NOPs for both
        checkInst(32'h00000000, 32'h00000000);
      end
    end
  end
end

// increment 1x base clocks
always_ff @(posedge clk_1x) begin
  int i;
  if (cr_bits.active) begin
    for (i = 0; i < num_clocks; i = i + 1) begin
      if (base_clocks[i].enable) begin
        if (base_clocks[i].rate == 2'b00) begin
          base_clocks[i].count <= base_clocks[i].count + 1;
        end
      end
    end
  end
end

// increment 2x base clocks
always_ff @(posedge clk_2x) begin
  int i;
  if (cr_bits.active) begin
    for (i = 0; i < num_clocks; i = i + 1) begin
      if (base_clocks[i].enable) begin
        if (base_clocks[i].rate == 2'b01) begin
          base_clocks[i].count <= base_clocks[i].count + 1;
        end
      end
    end
  end
end

// increment 4x base clocks
always_ff @(posedge clk_4x) begin
  int i;
  if (cr_bits.active) begin
    for (i = 0; i < num_clocks; i = i + 1) begin
      if (base_clocks[i].enable) begin
        if (base_clocks[i].rate == 2'b10) begin
          base_clocks[i].count <= base_clocks[i].count + 1;
        end
      end
    end
  end
end

// check alarms on 1x clocks
always_ff @(posedge clk_1x) begin
  int i;
  if (cr_bits.active) begin
    for (i = 0; i < num_alarms; i = i + 1) begin
      if ((base_clocks[alarms[i].assigned_clock].count + 1 == alarms[i].value) && alarms[i].enable && (base_clocks[alarms[i].assigned_clock].rate == 2'b00)) begin
        alarms[i].finished <= 1'b1;
        if (~alarms[i].loop) begin
          alarms[i].enable <= 1'b0;   // disable alarm if not set to repeat
        end
      end
    end
  end
end

// check alarms on 2x clocks
always_ff @(posedge clk_2x) begin
  int i;
  if (cr_bits.active) begin
    for (i = 0; i < num_alarms; i = i + 1) begin
      if ((base_clocks[alarms[i].assigned_clock].count + 1 == alarms[i].value) && alarms[i].enable && (base_clocks[alarms[i].assigned_clock].rate == 2'b01)) begin
        alarms[i].finished <= 1'b1;
        if (~alarms[i].loop) begin
          alarms[i].enable <= 1'b0;   // disable alarm if not set to repeat
        end
      end
    end
  end
end

// check alarms on 4x clocks
always_ff @(posedge clk_4x) begin
  int i;
  if (cr_bits.active) begin
    for (i = 0; i < num_alarms; i = i + 1) begin
      if ((base_clocks[alarms[i].assigned_clock].count + 1 == alarms[i].value) && alarms[i].enable && (base_clocks[alarms[i].assigned_clock].rate == 2'b10)) begin
        alarms[i].finished <= 1'b1;
        if (~alarms[i].loop) begin
          alarms[i].enable <= 1'b0;   // disable alarm if not set to repeat
        end
      end
    end
  end
end

// monitor finished signals
// when they go high, keep them high for two cycles
genvar k;
generate
	for (k = 0; k < num_alarms; k++)
	 begin
		always @(posedge alarms[k].finished) begin
      Alarm_Finished();
    end
	 end
endgenerate

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
