`timescale 1ns / 1ps

module DualCore_Top_tb;

    reg clk;
    reg reset;

    // --- CÁC BIẾN PHỤC VỤ ĐO ĐẠC HIỆU NĂNG ---
    integer stall_count_0 = 0;
    integer stall_count_1 = 0;
    real start_time = 0;
    real end_time = 0;
    // -----------------------------------------

    // 1. Khởi tạo Hệ thống lõi kép (DUT)
    DualCore_Top uut(
        .clk   (clk),
        .reset (reset)
    );

    // 2. Tạo xung Clock chu kỳ 10ns (100MHz)
    // Lưu ý: Tần số mô phỏng đang là 100MHz (10ns), 
    // khi tính toán báo cáo vật lý, hãy dùng Fmax = 32.32 MHz (30.94ns) như đã phân tích.
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 3. Khối tự động đếm số chu kỳ Stall
    always @(posedge clk) begin
        // Chỉ đếm khi hệ thống đang chạy (reset = 1)
        if (reset == 1'b1) begin
            // Đường dẫn uut.Interconnect khớp với cấu trúc phân cấp trên Waveform của bạn
            if (uut.Interconnect.m0_stall) 
                stall_count_0 = stall_count_0 + 1;
            
            if (uut.Interconnect.m1_stall) 
                stall_count_1 = stall_count_1 + 1;
        end
    end

    // 4. Kịch bản Mô phỏng
    initial begin
        // Khởi tạo trạng thái ban đầu
        // Reset bằng 1 trước để hệ thống ổn định
        reset = 1'b1;
        #10

        // Kéo Reset xuống 0 (tạo sườn xuống negedge) để kích hoạt PC = 0
        reset = 1'b0;
        #20;

        // Kéo Reset lên 1 lại để CPU bắt đầu chạy
        reset = 1'b1;
        
        // Ghi nhận thời gian bắt đầu chạy lệnh đầu tiên
        start_time = $realtime; 
        $display("===========================================");
        $display("=== HE THONG BAT DAU HOAT DONG TAI %0t ns ===", start_time);
        $display("===========================================");

        // Chờ 5000ns để Core 0 và Core 1 thi nhau đọc/ghi RAM
        #5000;
        
        // Ghi nhận thời gian kết thúc
        end_time = $realtime; 

        // In báo cáo hiệu năng trực tiếp ra Console
        $display("\n===========================================");
        $display("=== KET THUC MO PHONG VA BAO CAO HIEU NANG ===");
        $display("-> Tong thoi gian chay (T_exec) : %0t ns", end_time - start_time);
        $display("-> Tong so chu ky Stall Core 0  : %0d chu ky", stall_count_0);
        $display("-> Tong so chu ky Stall Core 1  : %0d chu ky", stall_count_1);
        $display("===========================================\n");

        $stop;
    end

endmodule