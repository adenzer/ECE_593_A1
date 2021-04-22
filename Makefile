help:
	@echo " "
	@echo "Welcome to Assignment 1 for ECE593 (Zack Fravel and Andrew Denzer)"
	@echo " "
	@echo "Targets: compile  sim_c  sim_gui  coverage  clean"
	@echo " "

compile:
	vlib work
	vmap work work
	vlog ATS21.sv
	vlog ATS21_tb.sv
	vlog ATS21_tb_coverage.sv

sim_c:
	vsim -c ATS21_tb -do "run -all;quit"

sim_gui:
	vsim -voptargs="+acc" ATS21_tb -do "wave_simple.do" -do "run -all"

coverage:
	vsim -coverage -voptargs="+acc +cover=bces" ATS21_tb_coverage -do "run -all;"

clean:
	rm -rf work modelsim.ini *.wlf *.log replay* transcript *.db
