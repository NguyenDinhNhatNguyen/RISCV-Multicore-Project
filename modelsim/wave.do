onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /DualCore_Top_tb/clk
add wave -noupdate /DualCore_Top_tb/reset
add wave -noupdate -divider {Core 0}
add wave -noupdate -color Salmon -radix hexadecimal /DualCore_Top_tb/uut/c0_pc
add wave -noupdate -divider {Core 1}
add wave -noupdate -color Cyan -radix hexadecimal /DualCore_Top_tb/uut/c1_pc
add wave -noupdate -divider Crossbar
add wave -noupdate -color Gold /DualCore_Top_tb/uut/ICC_Inst/mutex_lock
add wave -noupdate -color Salmon /DualCore_Top_tb/uut/Interconnect/m0_stall
add wave -noupdate -color Cyan /DualCore_Top_tb/uut/Interconnect/m1_stall
add wave -noupdate -divider {Share RAM}
add wave -noupdate -color Plum /DualCore_Top_tb/uut/Shared_RAM_Bank0/WE
add wave -noupdate -color Plum -radix hexadecimal /DualCore_Top_tb/uut/Shared_RAM_Bank0/A
add wave -noupdate -color Plum -radix hexadecimal /DualCore_Top_tb/uut/Shared_RAM_Bank0/WD
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 276
configure wave -valuecolwidth 58
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {400 ns}
