`timescale 1ns / 1ps

module DualCore_Top(
    input wire        clk,
    input wire        reset,

    output wire [31:0] dummy_out
);

    // =========================================================
    // 1. ĐỊNH NGHĨA ĐƯỜNG DÂY LIÊN KẾT (WIRES)
    // =========================================================
    // Kênh kết nối Lõi 0 (Core 0 Interface)
    wire [31:0] c0_pc, c0_instr; 
    wire [31:0] c0_mem_addr, c0_mem_wdata, c0_mem_rdata;
    wire        c0_mem_req, c0_mem_wen, c0_gnt;
    wire        core0_irq;

    // Kênh kết nối Lõi 1 (Core 1 Interface)
    wire [31:0] c1_pc, c1_instr; 
    wire [31:0] c1_mem_addr, c1_mem_wdata, c1_mem_rdata;
    wire        c1_mem_req, c1_mem_wen, c1_gnt;
    wire        core1_irq;

    // Kênh kết nối thiết bị Slave 0 (RAM Bank 0)
    wire [31:0] s0_addr, s0_wdata, s0_rdata;
    wire        s0_req, s0_wen;

    // Kênh kết nối thiết bị Slave 1 (RAM Bank 1)
    wire [31:0] s1_addr, s1_wdata, s1_rdata;
    wire        s1_req, s1_wen;

    // Kênh kết nối thiết bị Slave 2 (Hệ thống ngắt PLIC)
    wire [31:0] s2_addr, s2_wdata, s2_rdata;
    wire        s2_req, s2_wen;

    // =========================================================
    // 2. LẮP RÁP CÁC LÕI VI XỬ LÝ (RISCV CORES)
    // =========================================================
    // Phân vùng lõi 0
    // Code dưới để test bus bằng core0
    // Instruction_Memory #(.FILE_NAME(D:/RISCV-Multicore-Project/archive/asm/core0_testbus.txt")) ROM_Core0 ( .A(c0_pc), .RD(c0_instr) ); 
    Instruction_Memory #(.FILE_NAME("D:/RISCV-Multicore-Project/software/asm/core0.txt")) ROM_Core0 ( .A(c0_pc), .RD(c0_instr) );

    RISCV_Core Core_0 (
        .clk(clk), .reset(reset),
        .ext_irq(core0_irq), 
        .Instr(c0_instr), .PC(c0_pc),
        .gnt(c0_gnt), .mem_rdata(c0_mem_rdata),
        .mem_req(c0_mem_req), .mem_wen(c0_mem_wen),
        .mem_addr(c0_mem_addr), .mem_wdata(c0_mem_wdata)
    );

    // Phân vùng lõi 1
    // Code dưới để hỗ trợ test bus bằng core0
    // Instruction_Memory #(.FILE_NAME("D:/RISCV-Multicore-Project/archive/asm/core1_testbus.txt")) ROM_Core1 ( .A(c1_pc), .RD(c1_instr) ); 
    Instruction_Memory #(.FILE_NAME("D:/RISCV-Multicore-Project/software/asm/core1.txt")) ROM_Core1 ( .A(c1_pc), .RD(c1_instr) ); 

    RISCV_Core Core_1 (
        .clk(clk), .reset(reset),
        .ext_irq(core1_irq), 
        .Instr(c1_instr), .PC(c1_pc),
        .gnt(c1_gnt), .mem_rdata(c1_mem_rdata),
        .mem_req(c1_mem_req), .mem_wen(c1_mem_wen),
        .mem_addr(c1_mem_addr), .mem_wdata(c1_mem_wdata)
    );

    // =========================================================
    // 3. MA TRẬN CHUYỂN MẠCH TRỌNG TÀI PHÂN TÁN (CROSSBAR 2X3)
    // =========================================================
    crossbar_2x3 Interconnect (
        .clk(clk), 
        .rst_n(reset),

        // Master 0 (Core 0)
        .m0_valid(c0_mem_req), .m0_write(c0_mem_wen), 
        .m0_addr(c0_mem_addr), .m0_wdata(c0_mem_wdata), 
        .m0_rdata(c0_mem_rdata), .m0_grant(c0_gnt), 
        .m0_stall(), .m0_error(),

        // Master 1 (Core 1)
        .m1_valid(c1_mem_req), .m1_write(c1_mem_wen), 
        .m1_addr(c1_mem_addr), .m1_wdata(c1_mem_wdata), 
        .m1_rdata(c1_mem_rdata), .m1_grant(c1_gnt), 
        .m1_stall(), .m1_error(),

        // Slave 0 (RAM Bank 0 - Không gian địa chỉ 0x0000_....)
        .s0_valid(s0_req), .s0_write(s0_wen), 
        .s0_addr(s0_addr), .s0_wdata(s0_wdata), 
        .s0_rdata(s0_rdata),

        // Slave 1 (RAM Bank 1 - Không gian địa chỉ 0x1000_....)
        .s1_valid(s1_req), .s1_write(s1_wen), 
        .s1_addr(s1_addr), .s1_wdata(s1_wdata), 
        .s1_rdata(s1_rdata),

        // Slave 2 (PLIC - Không gian địa chỉ 0x0C00_....)
        .s2_valid(s2_req), .s2_write(s2_wen), 
        .s2_addr(s2_addr), .s2_wdata(s2_wdata), 
        .s2_rdata(s2_rdata)
    );

    // =========================================================
    // 4. HỆ THỐNG HA BANK BỘ NHỚ VÀ BỘ ĐIỀU KHIỂN NGẮT
    // =========================================================
    // Bộ nhớ RAM dùng chung - Bank 0
    Data_Memory Shared_RAM_Bank0 (
        .clk(clk),
        .WE(s0_wen & s0_req),
        .A(s0_addr),
        .WD(s0_wdata),
        .RD(s0_rdata)
    );

    // Bộ nhớ RAM dùng chung - Bank 1
    Data_Memory Shared_RAM_Bank1 (
        .clk(clk),
        .WE(s1_wen & s1_req),
        .A(s1_addr),
        .WD(s1_wdata),
        .RD(s1_rdata)
    );

    // Bộ điều khiển điều phối ngắt PLIC 
    InterCore_Ctrl ICC_Inst (
        .clk(clk), .rst_n(reset),
        .icc_valid(s2_req), .icc_write(s2_wen), .icc_addr(s2_addr), .icc_wdata(s2_wdata), .icc_rdata(s2_rdata),
        .irq_core0(core0_irq), .irq_core1(core1_irq)
    );

    assign dummy_out = c0_mem_addr | c1_mem_addr;

endmodule