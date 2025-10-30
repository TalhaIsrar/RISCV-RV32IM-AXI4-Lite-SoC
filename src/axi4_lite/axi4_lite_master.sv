module axi4_lite_master #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input  logic                   clk,
    input  logic                   rst,

    // Write interface
    input  logic                   write_start,
    input  logic [ADDR_WIDTH-1:0]  write_addr,
    input  logic [DATA_WIDTH-1:0]  write_data,
    input  logic [3:0]             write_strobe,
    output logic                   write_busy,

    // Read interface
    input  logic                   read_start,
    input  logic [ADDR_WIDTH-1:0]  read_addr,
    output logic [DATA_WIDTH-1:0]  read_data,
    output logic                   read_busy,

    // Unified AXI4-Lite interface
    axi4_lite_if master_if
);

    // ------------------------------
    // Instantiate AXI Write Master
    axi4_lite_write_master #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) master_write_if (
        .clk(clk),
        .rst(rst),
        .write_start(write_start),
        .write_addr(write_addr),
        .write_data(write_data),
        .write_strobe(write_strobe),
        .write_busy(write_busy),

        .M_AXI_AWADDR(master_if.AWADDR),
        .M_AXI_AWVALID(master_if.AWVALID),
        .M_AXI_AWREADY(master_if.AWREADY),
        .M_AXI_WDATA(master_if.WDATA),
        .M_AXI_WSTRB(master_if.WSTRB),
        .M_AXI_WVALID(master_if.WVALID),
        .M_AXI_WREADY(master_if.WREADY),
        .M_AXI_BRESP(master_if.BRESP),
        .M_AXI_BVALID(master_if.BVALID),
        .M_AXI_BREADY(master_if.BREADY)
    );

    // ------------------------------
    // Instantiate AXI Read Master
    axi4_lite_read_master #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) master_read_if (
        .clk(clk),
        .rst(rst),
        .read_start(read_start),
        .read_addr(read_addr),
        .read_data(read_data),
        .read_busy(read_busy),

        .M_AXI_ARADDR(master_if.ARADDR),
        .M_AXI_ARVALID(master_if.ARVALID),
        .M_AXI_ARREADY(master_if.ARREADY),
        .M_AXI_RDATA(master_if.RDATA),
        .M_AXI_RRESP(master_if.RRESP),
        .M_AXI_RVALID(master_if.RVALID),
        .M_AXI_RREADY(master_if.RREADY)
    );

endmodule
