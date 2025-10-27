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

    // WRIE ADDRESS CHANNEL
    output logic [ADDR_WIDTH - 1 : 0]   M_AXI_AWADDR,   // Write address
    output logic                        M_AXI_AWVALID,  // Write address valid
    input logic                         M_AXI_AWREADY,  // Slave ready to accept address

    // WRITE DATA CHANNEL
    output logic [DATA_WIDTH - 1 : 0]   M_AXI_WDATA,    // Write data
    output logic [3:0]                  M_AXI_WSTRB,    // Write data byte enable
    output logic                        M_AXI_WVALID,   // Write data is valid
    input logic                         M_AXI_WREADY,   // Slave ready to accept data

    // WRITE RESPONSE CHANNEL
    input logic [1:0]                   M_AXI_BRESP,    // Slave response - Unused here
    input logic                         M_AXI_BVALID,   // Write response valid from slave
    output logic                        M_AXI_BREADY    // Master ready to accept response

    // READ ADDRESS CHANNEL
    output logic [ADDR_WIDTH - 1 : 0]   M_AXI_ARADDR,   // Read address
    output logic                        M_AXI_ARVALID,  // Read address valid
    input logic                         M_AXI_ARREADY,  // Slave ready to accept address

    // READ DATA CHANNEL
    input logic [DATA_WIDTH - 1 : 0]    M_AXI_RDATA,    // Read data
    input logic [1:0]                   M_AXI_RRESP,    // Slave response
    input logic                         M_AXI_RVALID,   // Read data from slave is valid
    output logic                        M_AXI_RREADY    // Master is ready to accept data
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

        .M_AXI_ARADDR(M_AXI_ARADDR),
        .M_AXI_ARVALID(M_AXI_ARVALID),
        .M_AXI_ARREADY(M_AXI_ARREADY),
        .M_AXI_RDATA(M_AXI_RDATA),
        .M_AXI_RRESP(M_AXI_RRESP),
        .M_AXI_RVALID(M_AXI_RVALID),
        .M_AXI_RREADY(M_AXI_RREADY)
    );

endmodule
