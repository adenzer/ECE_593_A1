help:
	@echo " "
	@echo "Welcome to Assignment 1 for ECE593 (Zack Fravel and Andrew Denzer)"
	@echo " "
	@echo "Targets: compile  clean"
	@echo " "

compile: 
	vlib work
	vmap work work
	vlog ATS21.sv

simulate_c:
	make compile
	vlog ATS21_tb.sv
	vsim -c ATS21_tb -do "run -all;quit"

simulate_gui:
	make compile
	vlog ATS21_tb.sv
	vsim -voptargs="+acc" ATS21_tb -do "run -all;"

clean:
	rm -rf work modelsim.ini *.wlf *.log replay* transcript *.db