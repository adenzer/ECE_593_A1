#  ECE_593_A1 

Submission by Andrew Denzer and Zack Fravel for Assignment 1 - ECE593

## ATS21.sv

Implements the ATS21, a programmable multi-clock/timer/alarm component described
in the high level spec document provided by our instructor Tom Schubert. The component contains 16 different clocks and 24 alarms that can be set against any of the 16 clocks. The clocks can run at 1x, 2x, or 4x the reference clock speed. Clocks, Alarms, and Global Control Registers are managed using arrays of packed structs with the appropriate fields for each struct.

The module's primary behavioral implementation begins on line 425, between there are Reset(), AlarmFinished(), checkInst(), and processInst() tasks that are used in the behavioral blocks. The behavior always_ff block is responsible for detecting req being asserted on the clock and taking in the inputs using inCount signals and ctrlA/B_top buffers. The checkInst() task is responsible for input error handling as well as instruction decoding. checkInst() then calls processInst() for the current valid instruction where struct fields are manipulated according to the instruction set and status bits are set. This is also where status bits are set. Following the calling of checkInst() we have written always_ff blocks for incrimenting the clocks and checking the alarms for the respective clock domains. Finally at the bottom we have two for loops, one for calling the AlarmFinished() on detection of an alarm going off, and one for assigning all the alarm struct 'finished' fields 
to the data output bits. 

## ATS21_tb.sv

DUT takes a 32 bit instruction in two sets of 16 bits each clock (2 clocks). Tasks for each instruction are implemented to make stimulus generation simple for the testbench writer. A seperate send_instruction() task asserts the 'req' signal to the design and sends the ctrlA and ctrlB inputs to the desired instructions to send. After the exit_simulation() task is called, the tool exits after 20 clock cycles.

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

## Makefile

Targets: 
	
	help - Displays User Options
	compile - Compiles Reference Design and Testbench (ATS21.sv and ATS21_tb.sv).
	sim_c - Simulates the testbench in the command line
	sim_gui - Simulates the testbench in the gui with a pre-organized wave file (wave_simple.do)