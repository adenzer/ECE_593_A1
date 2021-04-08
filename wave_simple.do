onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group Testbench /ATS21_tb/clk
add wave -noupdate -expand -group Testbench /ATS21_tb/reset
add wave -noupdate -expand -group Testbench /ATS21_tb/req
add wave -noupdate -expand -group Testbench /ATS21_tb/ready
add wave -noupdate -expand -group Testbench /ATS21_tb/stat
add wave -noupdate -expand -group Testbench /ATS21_tb/ctrlA
add wave -noupdate -expand -group Testbench /ATS21_tb/ctrlB
add wave -noupdate -expand -group Testbench /ATS21_tb/data
add wave -noupdate -expand -group Testbench -expand -group {Testbench Internal Signals} /ATS21_tb/a
add wave -noupdate -expand -group Testbench -expand -group {Testbench Internal Signals} /ATS21_tb/b
add wave -noupdate -expand -group Testbench -expand -group {Testbench Internal Signals} /ATS21_tb/a_first
add wave -noupdate -expand -group Testbench -expand -group {Testbench Internal Signals} /ATS21_tb/a_second
add wave -noupdate -expand -group Testbench -expand -group {Testbench Internal Signals} /ATS21_tb/b_first
add wave -noupdate -expand -group Testbench -expand -group {Testbench Internal Signals} /ATS21_tb/b_second
add wave -noupdate -expand -group DUT /ATS21_tb/dut/clk
add wave -noupdate -expand -group DUT /ATS21_tb/dut/reset
add wave -noupdate -expand -group DUT /ATS21_tb/dut/clk_1x
add wave -noupdate -expand -group DUT /ATS21_tb/dut/clk_2x
add wave -noupdate -expand -group DUT /ATS21_tb/dut/clk_4x
add wave -noupdate -expand -group DUT -expand -group Inputs /ATS21_tb/dut/req
add wave -noupdate -expand -group DUT -expand -group Inputs /ATS21_tb/dut/ctrlA
add wave -noupdate -expand -group DUT -expand -group Inputs /ATS21_tb/dut/ctrlB
add wave -noupdate -expand -group DUT -expand -group {Internal Signals} /ATS21_tb/dut/statusA
add wave -noupdate -expand -group DUT -expand -group {Internal Signals} /ATS21_tb/dut/statusB
add wave -noupdate -expand -group DUT -expand -group {Internal Signals} /ATS21_tb/dut/ctrlA_top
add wave -noupdate -expand -group DUT -expand -group {Internal Signals} /ATS21_tb/dut/ctrlB_top
add wave -noupdate -expand -group DUT -expand -group {Internal Signals} /ATS21_tb/dut/inCountA
add wave -noupdate -expand -group DUT -expand -group {Internal Signals} /ATS21_tb/dut/inCountB
add wave -noupdate -expand -group DUT -expand -group {Internal Registers} /ATS21_tb/dut/base_clocks
add wave -noupdate -expand -group DUT -expand -group {Internal Registers} /ATS21_tb/dut/alarms
add wave -noupdate -expand -group DUT -expand -group {Internal Registers} /ATS21_tb/dut/cr_bits
add wave -noupdate -expand -group DUT -expand -group Outputs /ATS21_tb/dut/ready
add wave -noupdate -expand -group DUT -expand -group Outputs /ATS21_tb/dut/stat
add wave -noupdate -expand -group DUT -expand -group Outputs /ATS21_tb/dut/data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 214
configure wave -valuecolwidth 200
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
WaveRestoreZoom {0 ns} {112 ns}
