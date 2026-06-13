`timescale 1ns / 1ps

module RISCV_Core(
    input wire          clk, reset,
    input wire          ext_irq,    // Chân tiếp nhận tín hiệu ngắt từ PLIC

    // --- Giao tiếp với ROM (Lệnh) ---
    input wire [31:0]   Instr,      // Nhận lệnh từ ROM tương ứng
    output wire [31:0]  PC,         // Gửi địa chỉ bộ đếm chương trình sang ROM
    
    // --- Giao tiếp với Crossbar Bus (Dữ liệu) ---
    input wire          gnt,        // Quyền truy cập Bus dữ liệu (1: Cho chạy, 0: Stall)
    input wire [31:0]   mem_rdata,  // Dữ liệu đọc về từ ma trận Crossbar
    output wire         mem_req,    // Phát tín hiệu yêu cầu chiếm Bus dữ liệu
    output wire         mem_wen,    // Tín hiệu báo lệnh Store Word (MemWrite)
    output wire [31:0]  mem_addr,   // Địa chỉ cần thao tác (ALUResult)
    output wire [31:0]  mem_wdata   // Dữ liệu mang đi Store (WriteData)
);

    // Địa chỉ Vector ngắt cố định của hệ thống
    localparam TRAP_VECTOR = 32'h0000_0100; 

    // Nhận diện lệnh thoát ngắt mret (Opcode chuẩn RISC-V Privileged: 32'h30200073)
    wire is_mret = (Instr == 32'h30200073);

    // Cơ chế phần cứng lưu trữ Context tạm thời 
    reg [31:0] mepc_reg;
    reg        ie_status; // 1: Sẵn sàng nhận ngắt mới, 0: Khóa ngắt lặp khi đang trong Trap

    wire stall_internal;
    wire [31:0] mem_addr_internal;
    wire [31:0] mem_wdata_internal;
    
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            mepc_reg  <= 32'h0;
            ie_status <= 1'b1; // Mặc định mở ngắt khi khởi động hệ thống
        end else begin
            if (ext_irq && ie_status && !stall_internal) begin
                mepc_reg  <= PC;       // Điểm danh địa chỉ lệnh chạy dở vào mepc
                ie_status <= 1'b0;     // Khóa chặt cửa ngắt để thực thi Trap Handler
            end else if (is_mret) begin
                ie_status <= 1'b1;     // Mở khóa cho phép nhận ngắt tiếp theo
            end
        end
    end

    // Logic can thiệp ép nạp PC
    wire        irq_take    = ext_irq & ie_status;
    wire [31:0] core_pc_out;
    
    // Nếu có ngắt: Ép PC nhảy thẳng về vector ngắt. Gặp mret: Trả PC lại vị trí cũ trong mepc.
    assign PC = irq_take ? TRAP_VECTOR : (is_mret ? mepc_reg : core_pc_out);

    // --- LIÊN KẾT LOGIC NỘI BỘ VÀ KIỂM SOÁT STALL ---
    wire ALUSrc, RegWrite, Jump, Zero, PCSrc;
    wire [1:0] ResultSrc, ImmSrc;
    wire [3:0] ALUControl;
    wire MemWrite_internal;

    wire is_load  = (Instr[6:0] == 7'b0000011);
    wire is_store = (Instr[6:0] == 7'b0100011);
    
    // CPU chỉ được phép xin Bus nếu không bị khóa chu kỳ phục vụ bẫy ban đầu
    assign mem_req = (is_load | is_store) & ie_status; 

    assign stall_internal = mem_req & (~gnt);
    assign mem_wen   = MemWrite_internal & (~stall_internal); 
    assign mem_addr  = mem_addr_internal;
    assign mem_wdata = mem_wdata_internal;

    // GỌI KHỐI ĐIỀU KHIỂN (CONTROL UNIT)
    Control_Unit Control(
        .op(Instr[6:0]), .funct3(Instr[14:12]), .funct7b5(Instr[30]), .Zero(Zero),
        .stall(stall_internal),
        .ResultSrc(ResultSrc), .MemWrite(MemWrite_internal), .PCSrc(PCSrc),
        .ALUSrc(ALUSrc), .RegWrite(RegWrite), .Jump(Jump), .ImmSrc(ImmSrc), .ALUControl(ALUControl)
    );

    // GỌI KHỐI MẠCH DỮ LIỆU (DATAPATH)
    Core_Datapath Datapath(
        .clk(clk), .reset(reset), .stall(stall_internal),
        .ResultSrc(ResultSrc), .PCSrc(PCSrc), .ALUSrc(ALUSrc), .RegWrite(RegWrite),
        .ImmSrc(ImmSrc), .ALUControl(ALUControl), .Instr(Instr), .ReadData(mem_rdata),
        .Zero(Zero), .PC(core_pc_out), .ALUResult(mem_addr_internal), .WriteData(mem_wdata_internal)
    );

endmodule