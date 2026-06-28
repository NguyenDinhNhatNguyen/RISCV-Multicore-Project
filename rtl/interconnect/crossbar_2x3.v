`timescale 1ns / 1ps

module crossbar_2x3 (
    input  wire        clk, rst_n,

    // Giao tiếp Master 0 (Core 0)
    input  wire        m0_valid, m0_write,
    input  wire [31:0] m0_addr, m0_wdata,
    output wire [31:0] m0_rdata,
    output wire        m0_grant, m0_stall, m0_error,

    // Giao tiếp Master 1 (Core 1)
    input  wire        m1_valid, m1_write,
    input  wire [31:0] m1_addr, m1_wdata,
    output wire [31:0] m1_rdata,
    output wire        m1_grant, m1_stall, m1_error,

    // Giao tiếp Slave 0 (Shared RAM 0)
    output wire        s0_valid, s0_write,
    output wire [31:0] s0_addr, s0_wdata,
    input  wire [31:0] s0_rdata,

    // Giao tiếp Slave 1 (Shared RAM 1)
    output wire        s1_valid, s1_write,
    output wire [31:0] s1_addr, s1_wdata,
    input  wire [31:0] s1_rdata,

    // Giao tiếp Slave 2 (ICC / Mutex)
    output wire        s2_valid, s2_write,
    output wire [31:0] s2_addr, s2_wdata,
    input  wire [31:0] s2_rdata
);

    localparam DEC_S0 = 16'h0000; 
    localparam DEC_S1 = 16'h1000; 
    localparam DEC_S2 = 16'h0C00;

    // ==========================================
    // 1. DECODE PHASE (Giải mã địa chỉ Master)
    // ==========================================
    wire m0_req_s0 = m0_valid && (m0_addr[31:16] == DEC_S0);
    wire m0_req_s1 = m0_valid && (m0_addr[31:16] == DEC_S1);
    wire m0_req_s2 = m0_valid && (m0_addr[31:16] == DEC_S2);
    wire m0_err_dec = m0_valid && !m0_req_s0 && !m0_req_s1 && !m0_req_s2;

    wire m1_req_s0 = m1_valid && (m1_addr[31:16] == DEC_S0);
    wire m1_req_s1 = m1_valid && (m1_addr[31:16] == DEC_S1);
    wire m1_req_s2 = m1_valid && (m1_addr[31:16] == DEC_S2);
    wire m1_err_dec = m1_valid && !m1_req_s0 && !m1_req_s1 && !m1_req_s2;

    // ==========================================
    // 2. ARBITRATION PHASE (Phân xử độc lập cho 3 Slave)
    // ==========================================
    reg rr_s0, rr_s1, rr_s2; // Cờ Round-Robin (0: M0 ưu tiên, 1: M1 ưu tiên)

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rr_s0 <= 0; rr_s1 <= 0; rr_s2 <= 0;
        end else begin
            // Chỉ đảo cờ khi CẢ HAI cùng yêu cầu chung 1 Slave
            if (m0_req_s0 && m1_req_s0) rr_s0 <= ~rr_s0;
            if (m0_req_s1 && m1_req_s1) rr_s1 <= ~rr_s1;
            if (m0_req_s2 && m1_req_s2) rr_s2 <= ~rr_s2;
        end
    end

    // Quyết định cấp quyền (Grant) cho từng Slave
    wire grant_m0_s0 = m0_req_s0 && (!m1_req_s0 || rr_s0 == 0);
    wire grant_m1_s0 = m1_req_s0 && (!m0_req_s0 || rr_s0 == 1);

    wire grant_m0_s1 = m0_req_s1 && (!m1_req_s1 || rr_s1 == 0);
    wire grant_m1_s1 = m1_req_s1 && (!m0_req_s1 || rr_s1 == 1);

    wire grant_m0_s2 = m0_req_s2 && (!m1_req_s2 || rr_s2 == 0);
    wire grant_m1_s2 = m1_req_s2 && (!m0_req_s2 || rr_s2 == 1);

    // ==========================================
    // 3. ROUTING PHASE (Định tuyến tín hiệu bằng MUX song song)
    // ==========================================
    
    // Luồng truyền xuống Slave (Master -> Slave)
    assign s0_valid = grant_m0_s0 | grant_m1_s0;
    assign s0_write = grant_m0_s0 ? m0_write : (grant_m1_s0 ? m1_write : 1'b0);
    assign s0_addr  = grant_m0_s0 ? m0_addr  : (grant_m1_s0 ? m1_addr  : 32'h0);
    assign s0_wdata = grant_m0_s0 ? m0_wdata : (grant_m1_s0 ? m1_wdata : 32'h0);

    assign s1_valid = grant_m0_s1 | grant_m1_s1;
    assign s1_write = grant_m0_s1 ? m0_write : (grant_m1_s1 ? m1_write : 1'b0);
    assign s1_addr  = grant_m0_s1 ? m0_addr  : (grant_m1_s1 ? m1_addr  : 32'h0);
    assign s1_wdata = grant_m0_s1 ? m0_wdata : (grant_m1_s1 ? m1_wdata : 32'h0);

    assign s2_valid = grant_m0_s2 | grant_m1_s2;
    assign s2_write = grant_m0_s2 ? m0_write : (grant_m1_s2 ? m1_write : 1'b0);
    assign s2_addr  = grant_m0_s2 ? m0_addr  : (grant_m1_s2 ? m1_addr  : 32'h0);
    assign s2_wdata = grant_m0_s2 ? m0_wdata : (grant_m1_s2 ? m1_wdata : 32'h0);

    // Luồng truyền ngược về Master (Slave -> Master)
    assign m0_grant = grant_m0_s0 | grant_m0_s1 | grant_m0_s2 | m0_err_dec;
    assign m1_grant = grant_m1_s0 | grant_m1_s1 | grant_m1_s2 | m1_err_dec;

    assign m0_stall = m0_valid && !m0_grant && !m0_err_dec;
    assign m1_stall = m1_valid && !m1_grant && !m1_err_dec;

    assign m0_error = m0_err_dec;
    assign m1_error = m1_err_dec;

    assign m0_rdata = grant_m0_s0 ? s0_rdata :
                      grant_m0_s1 ? s1_rdata :
                      grant_m0_s2 ? s2_rdata : 32'h0;

    assign m1_rdata = grant_m1_s0 ? s0_rdata :
                      grant_m1_s1 ? s1_rdata :
                      grant_m1_s2 ? s2_rdata : 32'h0;

endmodule