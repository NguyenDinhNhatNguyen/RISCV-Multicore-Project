transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/RISCV-Multicore-Project/rtl/core {D:/RISCV-Multicore-Project/rtl/core/RISCV_Core.v}
vlog -vlog01compat -work work +incdir+D:/RISCV-Multicore-Project/rtl/core {D:/RISCV-Multicore-Project/rtl/core/Result_Mux.v}
vlog -vlog01compat -work work +incdir+D:/RISCV-Multicore-Project/rtl/core {D:/RISCV-Multicore-Project/rtl/core/Register_File.v}
vlog -vlog01compat -work work +incdir+D:/RISCV-Multicore-Project/rtl/core {D:/RISCV-Multicore-Project/rtl/core/PC_Target.v}
vlog -vlog01compat -work work +incdir+D:/RISCV-Multicore-Project/rtl/core {D:/RISCV-Multicore-Project/rtl/core/PC_Plus_4.v}
vlog -vlog01compat -work work +incdir+D:/RISCV-Multicore-Project/rtl/core {D:/RISCV-Multicore-Project/rtl/core/PC.v}
vlog -vlog01compat -work work +incdir+D:/RISCV-Multicore-Project/rtl/core {D:/RISCV-Multicore-Project/rtl/core/Main_Decoder.v}
vlog -vlog01compat -work work +incdir+D:/RISCV-Multicore-Project/rtl/core {D:/RISCV-Multicore-Project/rtl/core/Extend.v}
vlog -vlog01compat -work work +incdir+D:/RISCV-Multicore-Project/rtl/core {D:/RISCV-Multicore-Project/rtl/core/Core_Datapath.v}
vlog -vlog01compat -work work +incdir+D:/RISCV-Multicore-Project/rtl/core {D:/RISCV-Multicore-Project/rtl/core/Control_Unit.v}
vlog -vlog01compat -work work +incdir+D:/RISCV-Multicore-Project/rtl/core {D:/RISCV-Multicore-Project/rtl/core/ALU_Mux.v}
vlog -vlog01compat -work work +incdir+D:/RISCV-Multicore-Project/rtl/core {D:/RISCV-Multicore-Project/rtl/core/ALU_decoder.v}
vlog -vlog01compat -work work +incdir+D:/RISCV-Multicore-Project/rtl/core {D:/RISCV-Multicore-Project/rtl/core/ALU.v}
vlog -vlog01compat -work work +incdir+D:/RISCV-Multicore-Project/rtl/interconnect {D:/RISCV-Multicore-Project/rtl/interconnect/crossbar_2x3.v}
vlog -vlog01compat -work work +incdir+D:/RISCV-Multicore-Project/rtl/ip {D:/RISCV-Multicore-Project/rtl/ip/InterCore_Ctrl.v}
vlog -vlog01compat -work work +incdir+D:/RISCV-Multicore-Project/rtl/memory {D:/RISCV-Multicore-Project/rtl/memory/Instruction_Memory.v}
vlog -vlog01compat -work work +incdir+D:/RISCV-Multicore-Project/rtl/memory {D:/RISCV-Multicore-Project/rtl/memory/Data_Memory.v}
vlog -vlog01compat -work work +incdir+D:/RISCV-Multicore-Project/rtl {D:/RISCV-Multicore-Project/rtl/DualCore_Top.v}

vlog -vlog01compat -work work +incdir+D:/RISCV-Multicore-Project/quartus/../sim {D:/RISCV-Multicore-Project/quartus/../sim/DualCore_Top_tb.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  DualCore_Top_tb

add wave *
view structure
view signals
run -all
