`timescale 1ns/1ps

module axi4_lite_write_master_tb;

    // Parameters
    localparam ADDR_WIDTH = 32;
    localparam DATA_WIDTH = 32;

    // Clock & Reset
    logic clk;
    logic rst;

    // DUT signals
    logic                         write_start;
    logic [ADDR_WIDTH-1:0]       write_addr;
    logic [DATA_WIDTH-1:0]       write_data;
    logic [3:0]                   write_strobe;
    logic                         write_busy;

    logic [ADDR_WIDTH-1:0]       M_AXI_AWADDR;
    logic                         M_AXI_AWVALID;
    logic                         M_AXI_AWREADY;
    logic [DATA_WIDTH-1:0]       M_AXI_WDATA;
    logic [3:0]                  M_AXI_WSTRB;
    logic                         M_AXI_WVALID;
    logic                         M_AXI_WREADY;
    logic [1:0]                  M_AXI_BRESP;
    logic                         M_AXI_BVALID;
    logic                         M_AXI_BREADY;

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;  // 10 ns period

    // DUT instantiation
    axi4_lite_write_master #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .write_start(write_start),
        .write_addr(write_addr),
        .write_data(write_data),
        .write_strobe(write_strobe),
        .write_busy(write_busy),
        .M_AXI_AWADDR(M_AXI_AWADDR),
        .M_AXI_AWVALID(M_AXI_AWVALID),
        .M_AXI_AWREADY(M_AXI_AWREADY),
        .M_AXI_WDATA(M_AXI_WDATA),
        .M_AXI_WSTRB(M_AXI_WSTRB),
        .M_AXI_WVALID(M_AXI_WVALID),
        .M_AXI_WREADY(M_AXI_WREADY),
        .M_AXI_BRESP(M_AXI_BRESP),
        .M_AXI_BVALID(M_AXI_BVALID),
        .M_AXI_BREADY(M_AXI_BREADY)
    );

    // Simple AXI4-Lite slave
    initial begin
        M_AXI_AWREADY = 0;
        M_AXI_WREADY  = 0;
        M_AXI_BVALID  = 0;
        M_AXI_BRESP   = 2'b00; // OKAY
    end

    // Slave behavior
    always @(posedge clk) begin
        // AW handshake
        if (!M_AXI_AWREADY && M_AXI_AWVALID) begin
            M_AXI_AWREADY <= 1;
        end else begin
            M_AXI_AWREADY <= 0;
        end

        // W handshake
        if (!M_AXI_WREADY && M_AXI_WVALID) begin
            M_AXI_WREADY <= 1;
        end else begin
            M_AXI_WREADY <= 0;
        end

        // BVALID generation
        if (M_AXI_AWREADY && M_AXI_WREADY && M_AXI_AWVALID && M_AXI_WVALID) begin
            M_AXI_BVALID <= 1;
        end else if (M_AXI_BREADY && M_AXI_BVALID) begin
            M_AXI_BVALID <= 0;
        end
    end

    // Test sequence
    initial begin
        // Initialize signals
        rst = 1;
        write_start = 0;
        write_addr = 0;
        write_data = 0;
        write_strobe = 4'b1111;

        #20;
        rst = 0;

        // First write
        #10;
        write_addr  = 32'h0000_1000;
        write_data  = 32'hDEAD_BEEF;
        write_start = 1;
        #10;
        write_start = 0;
        write_addr  = 0;
        write_data  = 0;

        // Second write
        #30;
        write_addr  = 32'h0000_2000;
        write_data  = 32'hCAFEBABE;
        write_start = 1;
        #10;
        write_start = 0;
        write_addr  = 0;
        write_data  = 0;

        #50;
        $finish;
    end

endmodule
