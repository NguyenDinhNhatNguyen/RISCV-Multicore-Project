`timescale 1ns / 1ps

module DualCore_Top_tb;

    reg clk;
    reg reset;

    // 1. Khởi tạo Hệ thống lõi kép (DUT)
    DualCore_Top uut(
        .clk   (clk),
        .reset (reset)
    );

    // 2. Tạo xung Clock chu kỳ 10ns (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 3. Kịch bản Mô phỏng
    initial begin
        // Khởi tạo trạng thái ban đầu
        // Reset bằng 1 trước để hệ thống ổn định
        reset = 1'b1;
        #10

        // Kéo Reset xuống 0 (tạo sườn xuống negedge) để kích hoạt PC = 0Bt
        reset = 1'b0;
        #20;

        // Kéo Reset lên 1 lại để CPU bắt đầu chạy
        reset = 1'b1;
        $display("=== HE THONG BAT DAU HOAT DONG ===");

        // Chờ 5000ns để Core 0 và Core 1 thi nhau đọc/ghi RAM
        // Quan sát tín hiệu m0_stall và m1_stall trong Crossbar ở giai đoạn này
        // Quan sát sóng Mutex/Mailbox
        #5000;

        $display("=== KET THUC MO PHONG ===");
        $stop;
    end

endmodule