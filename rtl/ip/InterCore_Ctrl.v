`timescale 1ns / 1ps

module InterCore_Ctrl(
    input  wire        clk,
    input  wire        rst_n,
    input  wire        icc_valid,
    input  wire        icc_write,
    input  wire [31:0] icc_addr,
    input  wire [31:0] icc_wdata,

    output reg  [31:0] icc_rdata,
    output reg         irq_core0,
    output reg         irq_core1
);

    reg        mutex_lock;
    reg [31:0] mailbox_0to1;
    reg [31:0] mailbox_1to0;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mutex_lock   <= 1'b0;
            mailbox_0to1 <= 32'd0;
            mailbox_1to0 <= 32'd0;
            irq_core0    <= 1'b0;
            irq_core1    <= 1'b0;
        end else if (icc_valid) begin
            if (!icc_write) begin
                if (icc_addr == 32'h0C00_0000)
                    mutex_lock <= 1'b1; // Atomic Test-and-Set

                if (icc_addr == 32'h0C00_0004)
                    irq_core1 <= 1'b0;  // Xóa ngắt khi đọc hộp thư

                if (icc_addr == 32'h0C00_0008)
                    irq_core0 <= 1'b0;
            end else begin
                if (icc_addr == 32'h0C00_0000 && icc_wdata == 32'd0)
                    mutex_lock <= 1'b0; // Unlock

                if (icc_addr == 32'h0C00_0004) begin
                    mailbox_0to1 <= icc_wdata;
                    irq_core1    <= 1'b1;
                end

                if (icc_addr == 32'h0C00_0008) begin
                    mailbox_1to0 <= icc_wdata;
                    irq_core0    <= 1'b1;
                end
            end
        end
    end

    always @(*) begin
        icc_rdata = 32'd0;

        if (icc_valid && !icc_write) begin
            case (icc_addr)
                32'h0C00_0000: icc_rdata = {31'b0, mutex_lock};
                32'h0C00_0004: icc_rdata = mailbox_0to1;
                32'h0C00_0008: icc_rdata = mailbox_1to0;
            endcase
        end
    end

endmodule