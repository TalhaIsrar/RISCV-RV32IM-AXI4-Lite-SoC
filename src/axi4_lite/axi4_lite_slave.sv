module axi4_lite_slave #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input  logic                   clk,
    input  logic                   rst,

    // Slave select signals
    input  logic                   slave_write_sel,
    input  logic                   slave_read_sel,

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

    // WRIE ADDRESS CHANNEL
    input logic [ADDR_WIDTH - 1 : 0]    S_AXI_AWADDR,   // Write address
    input logic                         S_AXI_AWVALID,  // Write address valid
    output logic                        S_AXI_AWREADY,  // Slave ready to accept address

    // WRITE DATA CHANNEL
    input logic [DATA_WIDTH - 1 : 0]    S_AXI_WDATA,    // Write data
    input logic [3:0]                   S_AXI_WSTRB,    // Write data byte enable
    input logic                         S_AXI_WVALID,   // Write data is valid
    output logic                        S_AXI_WREADY,   // Slave ready to accept data

    // WRITE RESPONSE CHANNEL
    output logic [1:0]                  S_AXI_BRESP,    // Slave response - Unused here
    output logic                        S_AXI_BVALID,   // Write response valid from slave
    input logic                         S_AXI_BREADY,   // Master ready to accept response

    // READ ADDRESS CHANNEL
    input logic [ADDR_WIDTH - 1 : 0]    S_AXI_ARADDR,   // Read address
    input logic                         S_AXI_ARVALID,  // Read address valid
    output logic                        S_AXI_ARREADY,  // Slave ready to accept address

    // READ DATA CHANNEL
    output logic [DATA_WIDTH - 1 : 0]   S_AXI_RDATA,    // Read data
    output logic [1:0]                  S_AXI_RRESP,    // Slave response
    output logic                        S_AXI_RVALID,   // Read data from slave is valid
    input logic                         S_AXI_RREADY    // Master is ready to accept data
);

    // ----------------------------------
    // Instantiate write slave
    axi4_lite_write_slave #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) slave_write_if (
        .clk(clk),
        .rst(rst),
        .slave_write_sel(slave_write_sel),
        .mem_write(mem_write),
        .byte_en(byte_en),
        .addr(write_addr),
        .write_data(write_data),
    
        .S_AXI_AWADDR(S_AXI_AWADDR),
        .S_AXI_AWVALID(S_AXI_AWVALID),
        .S_AXI_AWREADY(S_AXI_AWREADY),
        .S_AXI_WDATA(S_AXI_WDATA),
        .S_AXI_WSTRB(S_AXI_WSTRB),
        .S_AXI_WVALID(S_AXI_WVALID),
        .S_AXI_WREADY(S_AXI_WREADY),
        .S_AXI_BRESP(S_AXI_BRESP),
        .S_AXI_BVALID(S_AXI_BVALID),
        .S_AXI_BREADY(S_AXI_BREADY)
    );

    // ----------------------------------
    // Instantiate read slave
    axi4_lite_read_slave #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) slave_read_if (
        .clk(clk),
        .rst(rst),
        .slave_read_sel(slave_read_sel),
        .read_data(read_data),
        .data_valid(data_valid),
        .addr(read_addr),

        .S_AXI_ARADDR(S_AXI_ARADDR),
        .S_AXI_ARVALID(S_AXI_ARVALID),
        .S_AXI_ARREADY(S_AXI_ARREADY),
        .S_AXI_RDATA(S_AXI_RDATA),
        .S_AXI_RRESP(S_AXI_RRESP),
        .S_AXI_RVALID(S_AXI_RVALID),
        .S_AXI_RREADY(S_AXI_RREADY)
    );

endmodule
