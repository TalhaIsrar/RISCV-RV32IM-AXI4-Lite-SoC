`timescale 1ns/1ps

module axi4_lite_tb;

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

    logic read_start;
    logic [ADDR_WIDTH-1:0] read_addr;
    logic [DATA_WIDTH-1:0] read_data;
    logic read_busy;

    // AXI wires
    logic [ADDR_WIDTH-1:0] M_AXI_AWADDR, M_AXI_ARADDR;
    logic M_AXI_AWVALID, M_AXI_WVALID, M_AXI_ARVALID;
    logic M_AXI_WREADY, M_AXI_AWREADY, M_AXI_RREADY, M_AXI_BREADY;
    logic [DATA_WIDTH-1:0] M_AXI_WDATA, M_AXI_RDATA;
    logic [3:0] M_AXI_WSTRB;
    logic [1:0] M_AXI_BRESP, M_AXI_RRESP;
    logic M_AXI_BVALID, M_AXI_RVALID;

    // Peripheral signals
    logic mem_write;
    logic [3:0] byte_en;
    logic [11:0] mem_write_addr, mem_read_addr;
    logic [31:0] mem_write_data;
    logic [31:0] mem_read_data;

    // Clock
    initial clk = 0;
    always #5 clk = ~clk; // 100 MHz

    // Reset
    initial begin
        rst = 1;
        #20;
        rst = 0;
    end

    // Instantiate Unified Master
    axi4_lite_master #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_axi_master (
        .clk(clk),
        .rst(rst),

        .write_start(write_start),
        .write_addr(write_addr),
        .write_data(write_data),
        .write_strobe(write_strobe),
        .write_busy(write_busy),
        
        .read_start(read_start),
        .read_addr(read_addr),
        .read_data(read_data),
        .read_busy(read_busy),

        .M_AXI_AWADDR(M_AXI_AWADDR),
        .M_AXI_AWVALID(M_AXI_AWVALID),
        .M_AXI_AWREADY(M_AXI_AWREADY),
        .M_AXI_WDATA(M_AXI_WDATA),
        .M_AXI_WSTRB(M_AXI_WSTRB),
        .M_AXI_WVALID(M_AXI_WVALID),
        .M_AXI_WREADY(M_AXI_WREADY),
        .M_AXI_BRESP(M_AXI_BRESP),
        .M_AXI_BVALID(M_AXI_BVALID),
        .M_AXI_BREADY(M_AXI_BREADY),
        .M_AXI_ARADDR(M_AXI_ARADDR),
        .M_AXI_ARVALID(M_AXI_ARVALID),
        .M_AXI_ARREADY(M_AXI_ARREADY),
        .M_AXI_RDATA(M_AXI_RDATA),
        .M_AXI_RRESP(M_AXI_RRESP),
        .M_AXI_RVALID(M_AXI_RVALID),
        .M_AXI_RREADY(M_AXI_RREADY)
    );

    // Instantiate Unified Slave
    axi4_lite_slave #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_axi_slave (
        .clk(clk),
        .rst(rst),
        
        .mem_write(mem_write),
        .byte_en(byte_en),
        .write_addr(mem_write_addr),
        .write_data(mem_write_data),

        .read_data(mem_read_data),
        .data_valid(1'b1), // always valid for memory
        .read_addr(mem_read_addr),

        .S_AXI_AWADDR(M_AXI_AWADDR),
        .S_AXI_AWVALID(M_AXI_AWVALID),
        .S_AXI_AWREADY(M_AXI_AWREADY),
        .S_AXI_WDATA(M_AXI_WDATA),
        .S_AXI_WSTRB(M_AXI_WSTRB),
        .S_AXI_WVALID(M_AXI_WVALID),
        .S_AXI_WREADY(M_AXI_WREADY),
        .S_AXI_BRESP(M_AXI_BRESP),
        .S_AXI_BVALID(M_AXI_BVALID),
        .S_AXI_BREADY(M_AXI_BREADY),
        .S_AXI_ARADDR(M_AXI_ARADDR),
        .S_AXI_ARVALID(M_AXI_ARVALID),
        .S_AXI_ARREADY(M_AXI_ARREADY),
        .S_AXI_RDATA(M_AXI_RDATA),
        .S_AXI_RRESP(M_AXI_RRESP),
        .S_AXI_RVALID(M_AXI_RVALID),
        .S_AXI_RREADY(M_AXI_RREADY)
    );

    // Instantiate memory
    data_mem u_mem (
        .clk(clk),
        .rst(rst),
        .mem_write(mem_write),
        .byte_en(byte_en),
        .write_addr(mem_write_addr[11:0]),
        .read_addr(mem_read_addr[11:0]),
        .write_data(mem_write_data),
        .read_data(mem_read_data)
    );

    // Test sequence
    initial begin
        write_start = 0;
        write_addr  = 0;
        write_data  = 0;
        write_strobe= 4'b1111;

        read_start  = 0;
        read_addr   = 0;

        #50;
        @(negedge clk);

        // Write 0xAABBCCDD to address 0x04
        write_addr   = 32'h04;
        write_data   = 32'hAABBCCDD;
        write_start  = 1;
        #10;
        write_start  = 0;

        // Wait for write completion
        wait(!write_busy);
        @(negedge clk);

        // Read back
        read_addr    = 32'h04;
        read_start   = 1;
        #10;
        read_start   = 0;

        // Wait for read completion
        wait(!read_busy);
        #30;

        $display("Read data: %h", read_data);

        $finish;
    end

endmodule
