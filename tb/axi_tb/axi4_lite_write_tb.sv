`timescale 1ns/1ps

module axi4_lite_write_tb;

    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;

    logic clk;
    logic rst;

    // Master signals
    logic write_start;
    logic [ADDR_WIDTH-1:0] write_addr;
    logic [DATA_WIDTH-1:0] write_data;
    logic [3:0] write_strobe;
    logic write_busy;

    // Slave / memory signals
    logic mem_write;
    logic [3:0] byte_en;
    logic [ADDR_WIDTH-1:0] mem_addr;
    logic [DATA_WIDTH-1:0] mem_write_data;
    logic [DATA_WIDTH-1:0] read_data;

    // AXI signals
    logic [ADDR_WIDTH-1:0] M_AXI_AWADDR, S_AXI_AWADDR;
    logic M_AXI_AWVALID, S_AXI_AWREADY;
    logic [DATA_WIDTH-1:0] M_AXI_WDATA, S_AXI_WDATA;
    logic [3:0] M_AXI_WSTRB, S_AXI_WSTRB;
    logic M_AXI_WVALID, S_AXI_WREADY;
    logic [1:0] M_AXI_BRESP, S_AXI_BRESP;
    logic M_AXI_BVALID, S_AXI_BVALID;
    logic M_AXI_BREADY, S_AXI_BREADY;

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk; // 100 MHz clock

    // Reset
    initial begin
        rst = 1;
        #20;
        rst = 0;
    end

    // Instantiate AXI Write Master
    axi4_lite_write_master #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) master_inst (
        .clk(clk),
        .rst(rst),
        .write_start(write_start),
        .write_addr(write_addr),
        .write_data(write_data),
        .write_strobe(write_strobe),
        .write_busy(write_busy),
        .M_AXI_AWADDR(M_AXI_AWADDR),
        .M_AXI_AWVALID(M_AXI_AWVALID),
        .M_AXI_AWREADY(S_AXI_AWREADY),
        .M_AXI_WDATA(M_AXI_WDATA),
        .M_AXI_WSTRB(M_AXI_WSTRB),
        .M_AXI_WVALID(M_AXI_WVALID),
        .M_AXI_WREADY(S_AXI_WREADY),
        .M_AXI_BRESP(M_AXI_BRESP),
        .M_AXI_BVALID(M_AXI_BVALID),
        .M_AXI_BREADY(S_AXI_BREADY)
    );

    // Instantiate AXI Write Slave
    axi4_lite_write_slave #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) slave_inst (
        .clk(clk),
        .rst(rst),
        .mem_write(mem_write),
        .byte_en(byte_en),
        .addr(mem_addr),
        .write_data(mem_write_data),
        .S_AXI_AWADDR(M_AXI_AWADDR),
        .S_AXI_AWVALID(M_AXI_AWVALID),
        .S_AXI_AWREADY(S_AXI_AWREADY),
        .S_AXI_WDATA(M_AXI_WDATA),
        .S_AXI_WSTRB(M_AXI_WSTRB),
        .S_AXI_WVALID(M_AXI_WVALID),
        .S_AXI_WREADY(S_AXI_WREADY),
        .S_AXI_BRESP(M_AXI_BRESP),
        .S_AXI_BVALID(M_AXI_BVALID),
        .S_AXI_BREADY(S_AXI_BREADY)
    );

    // Instantiate memory
    data_mem mem_inst (
        .clk(clk),
        .rst(rst),
        .mem_write(mem_write),
        .byte_en(byte_en),
        .write_addr(mem_addr[11:0]),
        .write_data(mem_write_data),
        .read_data(read_data)
    );

    // Test stimulus
    initial begin
        // Initialize signals
        write_start = 0;
        write_addr  = 0;
        write_data  = 0;
        write_strobe = 4'b1111;
        S_AXI_BREADY = 1; // always ready for response

        @(negedge rst);

        // First write
        @(posedge clk);
        write_addr  = 32'h0000_0004;
        write_data  = 32'hDEADBEEF;
        write_strobe = 4'b1111;
        write_start = 1;
        @(posedge clk);
        write_start = 0;

        // Wait until write completes
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);

        // Second write
        @(posedge clk);
        write_addr  = 32'h0000_0008;
        write_data  = 32'h12345678;
        write_strobe = 4'b1010;
        write_start = 1;
        @(posedge clk);
        write_start = 0;

        // Wait until write completes
        wait (!write_busy);

        // End simulation
        #50;
        $finish;
    end

endmodule
