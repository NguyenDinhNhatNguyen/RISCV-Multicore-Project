`timescale 1ns / 1ps

module RISCV_Core(
    input wire          clk, reset,
    input wire          ext_irq,    

    // --- Giao tiếp với ROM (Lệnh) ---
    input wire [31:0]   Instr,      
    output wire [31:0]  PC,         
    
    // --- Giao tiếp với Crossbar Bus (Dữ liệu) ---
    input wire          gnt,        
    input wire [31:0]   mem_rdata,  
    output wire         mem_req,    
    output wire         mem_wen,    
    output wire [31:0]  mem_addr,   
    output wire [31:0]  mem_wdata   
);
    localparam TRAP_VECTOR = 32'h0000_0100;
    wire is_mret = (Instr == 32'h30200073);
    
    reg [31:0] mepc_reg;
    reg        ie_status; 

    wire stall_internal;
    wire [31:0] mem_addr_internal;
    wire [31:0] mem_wdata_internal;
    
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            mepc_reg  <= 32'h0;
            ie_status <= 1'b1; 
        end else begin
            if (ext_irq && ie_status && !stall_internal) begin
                mepc_reg  <= PC;
                ie_status <= 1'b0;
            end else if (is_mret) begin
                ie_status <= 1'b1;
            end
        end
    end

    wire        irq_take    = ext_irq & ie_status;
    wire [31:0] core_pc_out;
    
    assign PC = irq_take ? TRAP_VECTOR : (is_mret ? mepc_reg : core_pc_out);

    wire ALUSrc, RegWrite, Jump, Zero, PCSrc;
    wire [1:0] ResultSrc, ImmSrc;
    wire [3:0] ALUControl;
    wire MemWrite_internal;
    wire Jalr;

    wire is_load  = (Instr[6:0] == 7'b0000011);
    wire is_store = (Instr[6:0] == 7'b0100011);
    
    // [FIXED] Bỏ '& ie_status' để Trap Handler vẫn đọc/ghi RAM được
    assign mem_req = (is_load | is_store); 
    assign stall_internal = mem_req & (~gnt);
    
    // [FIXED] Không cần chặn stall ở đây vì Crossbar đã bảo vệ
    assign mem_wen   = MemWrite_internal; 
    
    assign mem_addr  = mem_addr_internal;
    assign mem_wdata = mem_wdata_internal;

    Control_Unit Control(
        .op(Instr[6:0]), .funct3(Instr[14:12]), .funct7b5(Instr[30]), .Zero(Zero),
        .stall(stall_internal),
        .ResultSrc(ResultSrc), .MemWrite(MemWrite_internal), .PCSrc(PCSrc),
        .ALUSrc(ALUSrc), .RegWrite(RegWrite), .Jump(Jump), .ImmSrc(ImmSrc), .ALUControl(ALUControl),
        .Jalr(Jalr)
    );

    Core_Datapath Datapath(
        .clk(clk), .reset(reset), .stall(stall_internal),
        .ResultSrc(ResultSrc), .PCSrc(PCSrc), .ALUSrc(ALUSrc), .RegWrite(RegWrite),
        .ImmSrc(ImmSrc), .ALUControl(ALUControl), .Instr(Instr), .ReadData(mem_rdata),
        .Zero(Zero), .PC(core_pc_out), .ALUResult(mem_addr_internal), .WriteData(mem_wdata_internal),
        .Jalr(Jalr)
    );
endmodule