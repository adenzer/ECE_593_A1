onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Testbench Signals}
add wave -noupdate /ATS21_tb/dut/clk
add wave -noupdate /ATS21_tb/dut/reset
add wave -noupdate /ATS21_tb/dut/req
add wave -noupdate /ATS21_tb/dut/ctrlA
add wave -noupdate /ATS21_tb/dut/ctrlB
add wave -noupdate -divider {Internal Multiplied Clocks}
add wave -noupdate /ATS21_tb/dut/clk_1x
add wave -noupdate /ATS21_tb/dut/clk_2x
add wave -noupdate /ATS21_tb/dut/clk_4x
add wave -noupdate -divider {Control Registers}
add wave -noupdate -expand /ATS21_tb/dut/cr_bits
add wave -noupdate -divider {Internal Clocks}
add wave -noupdate /ATS21_tb/dut/base_clocks
add wave -noupdate -divider Alarms/Timers
add wave -noupdate /ATS21_tb/dut/alarms
add wave -noupdate -divider Outputs
add wave -noupdate /ATS21_tb/dut/ready
add wave -noupdate /ATS21_tb/dut/stat
add wave -noupdate /ATS21_tb/dut/data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 277
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
WaveRestoreZoom {0 ns} {116 ns}
