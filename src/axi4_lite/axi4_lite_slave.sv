module axi4_lite_slave #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input  logic                   clk,
    input  logic                   rst,

    // Write interface to peripheral
    output logic                   mem_write,
    output logic [3:0]             byte_en,
    output logic [ADDR_WIDTH-1:0]  write_addr,
    output logic [DATA_WIDTH-1:0]  write_data,

    // Read interface from peripheral
    input  logic [DATA_WIDTH-1:0]  read_data,
    input  logic                   data_valid,
    output logic [ADDR_WIDTH-1:0]  read_addr,

    // Unified AXI4-Lite interface
    axi4_lite_if slave_if
);

    // ----------------------------------
    // Instantiate write slave
    axi4_lite_write_slave #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) slave_write_if (
        .clk(clk),
        .rst(rst),
        .mem_write(mem_write),
        .byte_en(byte_en),
        .addr(write_addr),
        .write_data(write_data),
    
        .S_AXI_AWADDR(slave_if.AWADDR),
        .S_AXI_AWVALID(slave_if.AWVALID),
        .S_AXI_AWREADY(slave_if.AWREADY),
        .S_AXI_WDATA(slave_if.WDATA),
        .S_AXI_WSTRB(slave_if.WSTRB),
        .S_AXI_WVALID(slave_if.WVALID),
        .S_AXI_WREADY(slave_if.WREADY),
        .S_AXI_BRESP(slave_if.BRESP),
        .S_AXI_BVALID(slave_if.BVALID),
        .S_AXI_BREADY(slave_if.BREADY)
    );

    // ----------------------------------
    // Instantiate read slave
    axi4_lite_read_slave #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) slave_read_if (
        .clk(clk),
        .rst(rst),
        .read_data(read_data),
        .data_valid(data_valid),
        .addr(read_addr),

        .S_AXI_ARADDR(slave_if.ARADDR),
        .S_AXI_ARVALID(slave_if.ARVALID),
        .S_AXI_ARREADY(slave_if.ARREADY),
        .S_AXI_RDATA(slave_if.RDATA),
        .S_AXI_RRESP(slave_if.RRESP),
        .S_AXI_RVALID(slave_if.RVALID),
        .S_AXI_RREADY(slave_if.RREADY)
    );

endmodule
