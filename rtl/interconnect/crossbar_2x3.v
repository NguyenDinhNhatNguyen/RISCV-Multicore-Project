`timescale 1ns / 1ps

module crossbar_2x3 (
    input  wire        clk, rst_n,

    input  wire        m0_valid, m0_write,
    input  wire [31:0] m0_addr, m0_wdata,
    output wire [31:0] m0_rdata,
    output reg         m0_grant, m0_stall, m0_error,

    input  wire        m1_valid, m1_write,
    input  wire [31:0] m1_addr, m1_wdata,
    output wire [31:0] m1_rdata,
    output reg         m1_grant, m1_stall, m1_error,

    output reg         s0_valid, s0_write,
    output reg  [31:0] s0_addr, s0_wdata,
    input  wire [31:0] s0_rdata,

    output reg         s1_valid, s1_write,
    output reg  [31:0] s1_addr, s1_wdata,
    input  wire [31:0] s1_rdata,

    output reg         s2_valid, s2_write,
    output reg  [31:0] s2_addr, s2_wdata,
    input  wire [31:0] s2_rdata
);
    wire [15:0] m0_target = m0_addr[31:16];
    wire [15:0] m1_target = m1_addr[31:16];

    localparam DEC_S0 = 16'h0000; 
    localparam DEC_S1 = 16'h1000; 
    localparam DEC_S2 = 16'h0C00; 

    // Cờ Round-Robin (0: Ưu tiên M0, 1: Ưu tiên M1)
    reg rr_flag_s0, rr_flag_s1, rr_flag_s2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rr_flag_s0 <= 0; rr_flag_s1 <= 0; rr_flag_s2 <= 0;
        end else begin
            if (m0_valid && m1_valid && m0_target == DEC_S0 && m1_target == DEC_S0) rr_flag_s0 <= ~rr_flag_s0;
            if (m0_valid && m1_valid && m0_target == DEC_S1 && m1_target == DEC_S1) rr_flag_s1 <= ~rr_flag_s1;
            if (m0_valid && m1_valid && m0_target == DEC_S2 && m1_target == DEC_S2) rr_flag_s2 <= ~rr_flag_s2;
        end
    end

    always @(*) begin
        m0_grant = 0; m0_stall = 0; m0_error = 0;
        m1_grant = 0; m1_stall = 0; m1_error = 0;
        s0_valid = 0; s0_write = 0; s0_addr = 0; s0_wdata = 0;
        s1_valid = 0; s1_write = 0; s1_addr = 0; s1_wdata = 0;
        s2_valid = 0; s2_write = 0; s2_addr = 0; s2_wdata = 0;

        if (m0_valid && m0_target != DEC_S0 && m0_target != DEC_S1 && m0_target != DEC_S2) begin m0_error = 1; m0_stall = 1; end
        if (m1_valid && m1_target != DEC_S0 && m1_target != DEC_S1 && m1_target != DEC_S2) begin m1_error = 1; m1_stall = 1; end

        // Phân xử Slave 0
        if (m0_valid && m0_target == DEC_S0 && m1_valid && m1_target == DEC_S0) begin
            if (rr_flag_s0 == 1'b0) begin 
                s0_valid = 1; s0_write = m0_write; s0_addr = m0_addr; s0_wdata = m0_wdata; m0_grant = 1; m1_stall = 1;
            end else begin                
                s0_valid = 1; s0_write = m1_write; s0_addr = m1_addr; s0_wdata = m1_wdata; m1_grant = 1; m0_stall = 1;
            end
        end else if (m0_valid && m0_target == DEC_S0) begin s0_valid = 1; s0_write = m0_write; s0_addr = m0_addr; s0_wdata = m0_wdata; m0_grant = 1;
        end else if (m1_valid && m1_target == DEC_S0) begin s0_valid = 1; s0_write = m1_write; s0_addr = m1_addr; s0_wdata = m1_wdata; m1_grant = 1; end

        // Phân xử Slave 1
        if (m0_valid && m0_target == DEC_S1 && m1_valid && m1_target == DEC_S1) begin
            if (rr_flag_s1 == 1'b0) begin 
                s1_valid = 1; s1_write = m0_write; s1_addr = m0_addr; s1_wdata = m0_wdata; m0_grant = 1; m1_stall = 1;
            end else begin                
                s1_valid = 1; s1_write = m1_write; s1_addr = m1_addr; s1_wdata = m1_wdata; m1_grant = 1; m0_stall = 1;
            end
        end else if (m0_valid && m0_target == DEC_S1) begin s1_valid = 1; s1_write = m0_write; s1_addr = m0_addr; s1_wdata = m0_wdata; m0_grant = 1;
        end else if (m1_valid && m1_target == DEC_S1) begin s1_valid = 1; s1_write = m1_write; s1_addr = m1_addr; s1_wdata = m1_wdata; m1_grant = 1; end

        // Phân xử Slave 2 (ICC)
        if (m0_valid && m0_target == DEC_S2 && m1_valid && m1_target == DEC_S2) begin
            if (rr_flag_s2 == 1'b0) begin 
                s2_valid = 1; s2_write = m0_write; s2_addr = m0_addr; s2_wdata = m0_wdata; m0_grant = 1; m1_stall = 1;
            end else begin                
                s2_valid = 1; s2_write = m1_write; s2_addr = m1_addr; s2_wdata = m1_wdata; m1_grant = 1; m0_stall = 1;
            end
        end else if (m0_valid && m0_target == DEC_S2) begin s2_valid = 1; s2_write = m0_write; s2_addr = m0_addr; s2_wdata = m0_wdata; m0_grant = 1;
        end else if (m1_valid && m1_target == DEC_S2) begin s2_valid = 1; s2_write = m1_write; s2_addr = m1_addr; s2_wdata = m1_wdata; m1_grant = 1; end
    end

    assign m0_rdata = (m0_grant && m0_target == DEC_S0) ? s0_rdata : (m0_grant && m0_target == DEC_S1) ? s1_rdata : (m0_grant && m0_target == DEC_S2) ? s2_rdata : 32'h0;
    assign m1_rdata = (m1_grant && m1_target == DEC_S0) ? s0_rdata : (m1_grant && m1_target == DEC_S1) ? s1_rdata : (m1_grant && m1_target == DEC_S2) ? s2_rdata : 32'h0;
endmodule