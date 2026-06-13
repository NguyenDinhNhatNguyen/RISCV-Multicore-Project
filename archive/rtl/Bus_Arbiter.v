`timescale 1ns / 1ps

module Bus_Arbiter(
    input  wire        clk,
    input  wire        reset,

    // Kênh Master 0 (Core 0)
    input  wire        c0_req,
    input  wire        c0_wen,
    input  wire [31:0] c0_addr,
    input  wire [31:0] c0_wdata,
    output wire        c0_gnt,
    output wire [31:0] c0_rdata,

    // Kênh Master 1 (Core 1)
    input  wire        c1_req,
    input  wire        c1_wen,
    input  wire [31:0] c1_addr,
    input  wire [31:0] c1_wdata,
    output wire        c1_gnt,
    output wire [31:0] c1_rdata,

    // Kênh Slave (RAM)
    output wire        ram_req,
    output wire        ram_wen,
    output wire [31:0] ram_addr,
    output wire [31:0] ram_wdata,
    input  wire [31:0] ram_rdata
);

    // Trạng thái ưu tiên luân phiên (Round-Robin)
    reg current_priority; // 0: Ưu tiên Core 0, 1: Ưu tiên Core 1

    always @(posedge clk or negedge reset) begin
        if (!reset)
            current_priority <= 1'b0;
        else if (c0_req & c1_req)
            // Nếu cả 2 cùng xin, sau khi phục vụ đứa được ưu tiên, lật trạng thái
            current_priority <= ~current_priority;
    end

    // Logic cấp quyền (Grant)
    // Core 0 được Grant nếu nó xin và:
    // (Không có Core 1 xin) HOẶC (Nó đang giữ ưu tiên)
    assign c0_gnt = c0_req & (~c1_req | ~current_priority);

    // Core 1 được Grant nếu nó xin và:
    // (Không có Core 0 xin) HOẶC (Nó đang giữ ưu tiên)
    assign c1_gnt = c1_req & (~c0_req | current_priority);

    // Ghép kênh xuống RAM (MUX)
    assign ram_req   = c0_gnt | c1_gnt;
    assign ram_wen   = c0_gnt ? c0_wen   : (c1_gnt ? c1_wen   : 1'b0);
    assign ram_addr  = c0_gnt ? c0_addr  : (c1_gnt ? c1_addr  : 32'h0);
    assign ram_wdata = c0_gnt ? c0_wdata : (c1_gnt ? c1_wdata : 32'h0);

    // Trả dữ liệu về Core
    assign c0_rdata = ram_rdata;
    assign c1_rdata = ram_rdata;

endmodule