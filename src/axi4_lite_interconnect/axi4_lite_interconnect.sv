import axi4_lite_addr_map_package::*;

module axi4_litw_interconnect #(
    parameter ADDR_WIDTH = ADDR_WIDTH,
    parameter DATA_WIDTH = DATA_WIDTH,
    parameter int SLAVE_NUM   = SLAVE_NUM,
    parameter logic [ADDR_WIDTH-1:0] SLAVE_BASE_ADDR [SLAVE_NUM],
    parameter logic [ADDR_WIDTH-1:0] SLAVE_ADDR_MASK [SLAVE_NUM]
)(
    input logic clk,
    input logic rst,

    // Unified AXI4-Lite master interface
    axi4_lite_if master_if,

    // Multiple slave interfaces
    axi4_lite_if slave_if [SLAVES]
);

    // Slave select signal - Based on decoding
    logic [SLAVE_NUM-1:0]           write_sel, read_sel;
    logic [$clog2(SLAVE_NUM)-1:0]   write_sel_idx, read_sel_idx;

    // --- Decode write and read addresses ---
    axi4_lite_addr_decoder #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .SLAVE_NUM (SLAVE_NUM),
        .SLAVE_BASE_ADDR (SLAVE_BASE_ADDR),
        .SLAVE_ADDR_MASK (SLAVE_ADDR_MASK)
    ) write_decoder (
        .addr(master_if.AWADDR),
        .sel(write_sel),
        .sel_idx(write_sel_idx)
    );

    axi4_lite_addr_decoder #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .SLAVE_NUM (SLAVE_NUM),
        .SLAVE_BASE_ADDR (SLAVE_BASE_ADDR),
        .SLAVE_ADDR_MASK (SLAVE_ADDR_MASK)
    ) read_decoder (
        .addr(master_if.ARADDR),
        .sel(read_sel),
        .sel_idx(read_sel_idx)
    );

    // Master -> Slave Signals routing
    genvar i;
    generate
        for (i = 0; i < SLAVE_NUM; i++) begin : gen_slave_connect
            // Write channels
            assign slave_if[i].AWADDR  = master_if.AWADDR - SLAVE_BASE_ADDR[i];
            assign slave_if[i].AWVALID = master_if.AWVALID & write_sel[i];
            assign slave_if[i].WDATA   = master_if.WDATA;
            assign slave_if[i].WSTRB   = master_if.WSTRB;
            assign slave_if[i].WVALID  = master_if.WVALID & write_sel[i];
            assign slave_if[i].BREADY  = master_if.BREADY & write_sel[i];

            // Read channels
            assign slave_if[i].ARADDR  = master_if.ARADDR - SLAVE_BASE_ADDR[i];
            assign slave_if[i].ARVALID = master_if.ARVALID & read_sel[i];
            assign slave_if[i].RREADY  = master_if.RREADY & read_sel[i];
        end
    endgenerate

    // Slave -> Master Signals routing
    assign master_if.AWREADY = |(write_sel & '{slave_if.AWREADY});
    assign master_if.WREADY  = |(write_sel & '{slave_if.WREADY});
    assign master_if.BVALID  = |(write_sel & '{slave_if.BVALID});
    assign master_if.BRESP   = slave_if[write_sel_idx].BRESP;

    assign master_if.ARREADY = |(read_sel & '{slave_if.ARREADY});
    assign master_if.RVALID  = |(read_sel & '{slave_if.RVALID});
    assign master_if.RDATA   = slave_if[read_sel_idx].RDATA;
    assign master_if.RRESP   = slave_if[read_sel_idx].RRESP;

endmodule