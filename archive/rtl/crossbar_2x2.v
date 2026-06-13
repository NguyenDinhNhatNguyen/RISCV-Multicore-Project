module crossbar_2x2 (
    input  wire        clk,
    input  wire        rst_n,

    // Master 0 Interface
    input  wire        m0_valid,
    input  wire        m0_write,
    input  wire [31:0] m0_addr,
    input  wire [31:0] m0_wdata,
    output wire [31:0] m0_rdata,
    output reg         m0_grant,
    output reg         m0_stall,
    output reg         m0_error,

    // Master 1 Interface
    input  wire        m1_valid,
    input  wire        m1_write,
    input  wire [31:0] m1_addr,
    input  wire [31:0] m1_wdata,
    output wire [31:0] m1_rdata,
    output reg         m1_grant,
    output reg         m1_stall,
    output reg         m1_error,

    // Slave 0 Interface: RAM
    // Address range: 0x0000_0000 - 0x0000_FFFF
    output reg         s0_valid,
    output reg         s0_write,
    output reg  [31:0] s0_addr,
    output reg  [31:0] s0_wdata,
    input  wire [31:0] s0_rdata,

    // Slave 1 Interface: Peripheral
    // Address range: 0x1000_0000 - 0x1000_FFFF
    output reg         s1_valid,
    output reg         s1_write,
    output reg  [31:0] s1_addr,
    output reg  [31:0] s1_wdata,
    input  wire [31:0] s1_rdata
);

    // Address Map
    localparam SLAVE0_BASE = 32'h0000_0000;
    localparam SLAVE0_END  = 32'h0000_FFFF;

    localparam SLAVE1_BASE = 32'h1000_0000;
    localparam SLAVE1_END  = 32'h1000_FFFF;

    // Decode result
    // 2'b00: Slave 0
    // 2'b01: Slave 1
    // 2'b11: Invalid address
    localparam DEC_S0  = 2'b00;
    localparam DEC_S1  = 2'b01;
    localparam DEC_ERR = 2'b11;

    reg [1:0] m0_target;
    reg [1:0] m1_target;

    // Address Decoder
    always @(*) begin
        if (m0_addr >= SLAVE0_BASE && m0_addr <= SLAVE0_END)
            m0_target = DEC_S0;
        else if (m0_addr >= SLAVE1_BASE && m0_addr <= SLAVE1_END)
            m0_target = DEC_S1;
        else
            m0_target = DEC_ERR;
    end

    always @(*) begin
        if (m1_addr >= SLAVE0_BASE && m1_addr <= SLAVE0_END)
            m1_target = DEC_S0;
        else if (m1_addr >= SLAVE1_BASE && m1_addr <= SLAVE1_END)
            m1_target = DEC_S1;
        else
            m1_target = DEC_ERR;
    end

    // Crossbar + Fixed Priority Arbiter
    // Master 0 has higher priority than Master 1
    always @(*) begin
        // Default output
        m0_grant = 1'b0;
        m1_grant = 1'b0;

        m0_stall = 1'b0;
        m1_stall = 1'b0;

        m0_error = 1'b0;
        m1_error = 1'b0;

        s0_valid = 1'b0;
        s0_write = 1'b0;
        s0_addr  = 32'b0;
        s0_wdata = 32'b0;

        s1_valid = 1'b0;
        s1_write = 1'b0;
        s1_addr  = 32'b0;
        s1_wdata = 32'b0;

        // Check invalid address
        if (m0_valid && m0_target == DEC_ERR) begin
            m0_error = 1'b1;
            m0_stall = 1'b1;
        end

        if (m1_valid && m1_target == DEC_ERR) begin
            m1_error = 1'b1;
            m1_stall = 1'b1;
        end

        // Slave 0 Arbitration
        // Fixed Priority: M0 > M1
        if (m0_valid && m0_target == DEC_S0) begin
            s0_valid = 1'b1;
            s0_write = m0_write;
            s0_addr  = m0_addr;
            s0_wdata = m0_wdata;

            m0_grant = 1'b1;

            if (m1_valid && m1_target == DEC_S0) begin
                m1_stall = 1'b1;
            end
        end
        else if (m1_valid && m1_target == DEC_S0) begin
            s0_valid = 1'b1;
            s0_write = m1_write;
            s0_addr  = m1_addr;
            s0_wdata = m1_wdata;

            m1_grant = 1'b1;
        end

        // Slave 1 Arbitration
        // Fixed Priority: M1 > M0 (công bằng tải)
        if (m1_valid && m1_target == DEC_S1) begin
            s1_valid = 1'b1;
            s1_write = m1_write;
            s1_addr  = m1_addr;
            s1_wdata = m1_wdata;

            m1_grant = 1'b1;

            if (m0_valid && m0_target == DEC_S1) begin
                m0_stall = 1'b1; // Ép M0 nhường đường
            end
        end
        else if (m0_valid && m0_target == DEC_S1) begin
            s1_valid = 1'b1;
            s1_write = m0_write;
            s1_addr  = m0_addr;
            s1_wdata = m0_wdata;

            m0_grant = 1'b1;
        end
    end

    // Trả dữ liệu từ Bank tương ứng về cho Core 0
assign m0_rdata = (m0_grant && m0_target == DEC_S0) ? s0_rdata : 
                  (m0_grant && m0_target == DEC_S1) ? s1_rdata : 32'h0;

// Trả dữ liệu từ Bank tương ứng về cho Core 1
assign m1_rdata = (m1_grant && m1_target == DEC_S0) ? s0_rdata : 
                  (m1_grant && m1_target == DEC_S1) ? s1_rdata : 32'h0;

endmodule