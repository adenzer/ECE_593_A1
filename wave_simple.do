onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group {Testbench Interface} -divider Inputs
add wave -noupdate -expand -group {Testbench Interface} /ATS21_tb/clk
add wave -noupdate -expand -group {Testbench Interface} /ATS21_tb/reset
add wave -noupdate -expand -group {Testbench Interface} /ATS21_tb/req
add wave -noupdate -expand -group {Testbench Interface} /ATS21_tb/ctrlA
add wave -noupdate -expand -group {Testbench Interface} /ATS21_tb/ctrlB
add wave -noupdate -expand -group {Testbench Interface} -divider Ouputs
add wave -noupdate -expand -group {Testbench Interface} /ATS21_tb/ready
add wave -noupdate -expand -group {Testbench Interface} -radix binary /ATS21_tb/stat
add wave -noupdate -expand -group {Testbench Interface} /ATS21_tb/data
add wave -noupdate -expand -group DUT -divider Inputs
add wave -noupdate -expand -group DUT -expand -group {DUT - Inputs} /ATS21_tb/dut/clk
add wave -noupdate -expand -group DUT -expand -group {DUT - Inputs} /ATS21_tb/dut/reset
add wave -noupdate -expand -group DUT -expand -group {DUT - Inputs} /ATS21_tb/dut/req
add wave -noupdate -expand -group DUT -expand -group {DUT - Inputs} /ATS21_tb/dut/ctrlA
add wave -noupdate -expand -group DUT -expand -group {DUT - Inputs} /ATS21_tb/dut/ctrlB
add wave -noupdate -expand -group DUT -divider {Internal Signals}
add wave -noupdate -expand -group DUT -expand -group {DUT - Internal} /ATS21_tb/dut/statusA
add wave -noupdate -expand -group DUT -expand -group {DUT - Internal} /ATS21_tb/dut/statusB
add wave -noupdate -expand -group DUT -expand -group {DUT - Internal} /ATS21_tb/dut/ctrlA_inst
add wave -noupdate -expand -group DUT -expand -group {DUT - Internal} /ATS21_tb/dut/ctrlB_inst
add wave -noupdate -expand -group DUT -expand -group {DUT - Internal} /ATS21_tb/dut/clk_1x
add wave -noupdate -expand -group DUT -expand -group {DUT - Internal} /ATS21_tb/dut/clk_2x
add wave -noupdate -expand -group DUT -expand -group {DUT - Internal} /ATS21_tb/dut/clk_4x
add wave -noupdate -expand -group DUT -expand -group {DUT - Internal} /ATS21_tb/dut/base_clocks
add wave -noupdate -expand -group DUT -expand -group {DUT - Internal} /ATS21_tb/dut/alarms
add wave -noupdate -expand -group DUT -expand -group {DUT - Internal} /ATS21_tb/dut/cr_bits
add wave -noupdate -expand -group DUT -expand -group {DUT - Internal} /ATS21_tb/dut/readFlag
add wave -noupdate -expand -group DUT -expand -group {DUT - Internal} /ATS21_tb/dut/readComplete
add wave -noupdate -expand -group DUT -expand -group {DUT - Internal} /ATS21_tb/dut/byteCount
add wave -noupdate -expand -group DUT -divider Outputs
add wave -noupdate -expand -group DUT -expand -group {DUT - Outputs} /ATS21_tb/dut/ready
add wave -noupdate -expand -group DUT -expand -group {DUT - Outputs} -radix binary /ATS21_tb/dut/stat
add wave -noupdate -expand -group DUT -expand -group {DUT - Outputs} /ATS21_tb/dut/data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 254
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {284 ns}
