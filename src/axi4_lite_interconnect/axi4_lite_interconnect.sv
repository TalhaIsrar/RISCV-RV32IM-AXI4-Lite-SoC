module axi4_lite_interconnect #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter int SLAVE_NUM   = 2,
    parameter logic [ADDR_WIDTH-1:0] SLAVE_BASE_ADDR [SLAVE_NUM],
    parameter logic [ADDR_WIDTH-1:0] SLAVE_ADDR_MASK [SLAVE_NUM]
)(
    input logic clk,
    input logic rst,

    // Unified AXI4-Lite master interface
    axi4_lite_if master_if,

    // Multiple slave interfaces
    axi4_lite_if slave_if [SLAVE_NUM]
);

    // Slave select signal - Based on decoding
    logic [SLAVE_NUM-1:0]           write_sel, read_sel;

    // --- Decode write and read addresses ---
    axi4_lite_addr_decoder #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .SLAVE_NUM (SLAVE_NUM),
        .SLAVE_BASE_ADDR (SLAVE_BASE_ADDR),
        .SLAVE_ADDR_MASK (SLAVE_ADDR_MASK)
    ) write_decoder (
        .addr(master_if.AWADDR),
        .slave_sel(write_sel)
    );

    axi4_lite_addr_decoder #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .SLAVE_NUM (SLAVE_NUM),
        .SLAVE_BASE_ADDR (SLAVE_BASE_ADDR),
        .SLAVE_ADDR_MASK (SLAVE_ADDR_MASK)
    ) read_decoder (
        .addr(master_if.ARADDR),
        .slave_sel(read_sel)
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
    // Declare vectors for slave->master signals
    logic [SLAVE_NUM-1:0] awready_vec, wready_vec, bvalid_vec;
    logic [SLAVE_NUM-1:0] arready_vec, rvalid_vec;

    logic [DATA_WIDTH-1:0] rdata_mux [SLAVE_NUM];
    logic [1:0]            rresp_mux [SLAVE_NUM];
    logic [1:0]            bresp_mux [SLAVE_NUM];

    genvar k;
    generate
        for (k = 0; k < SLAVE_NUM; k++) begin : slave_master_or
            // AND with slave select for correct routing
            assign awready_vec[k] = slave_if[k].AWREADY & write_sel[k];
            assign wready_vec[k]   = slave_if[k].WREADY   & write_sel[k];
            assign bvalid_vec[k]   = slave_if[k].BVALID   & write_sel[k];
            assign arready_vec[k]  = slave_if[k].ARREADY  & read_sel[k];
            assign rvalid_vec[k]   = slave_if[k].RVALID   & read_sel[k];

            assign rdata_mux[k] = read_sel[k] ? slave_if[k].RDATA : '0;
            assign rresp_mux[k] = read_sel[k] ? slave_if[k].RRESP : '0;
            assign bresp_mux[k] = write_sel[k] ? slave_if[k].BRESP : '0;
        end
    endgenerate

    // Reduce vectors to single master signals
    assign master_if.AWREADY = |awready_vec;
    assign master_if.WREADY  = |wready_vec;
    assign master_if.BVALID  = |bvalid_vec;
    assign master_if.ARREADY = |arready_vec;
    assign master_if.RVALID  = |rvalid_vec;
    
    // RDATA mux
    logic [DATA_WIDTH-1:0] rdata_tmp;
    integer m;
    always_comb begin
        rdata_tmp = '0;
        for (m = 0; m < SLAVE_NUM; m++) begin
            if (read_sel[m])
                rdata_tmp = rdata_tmp | rdata_mux[m];
        end
    end
    assign master_if.RDATA = rdata_tmp;

    // RRESP mux (2-bit)
    logic [1:0] rresp_tmp;
    integer n;
    always_comb begin
        rresp_tmp = '0;
        for (n = 0; n < SLAVE_NUM; n++) begin
            if (read_sel[n])
                rresp_tmp = rresp_tmp | rresp_mux[n];
        end
    end
    assign master_if.RRESP = rresp_tmp;

    // BRESP mux (2-bit)
    logic [1:0] bresp_tmp;
    integer o;
    always_comb begin
        bresp_tmp = '0;
        for (o = 0; o < SLAVE_NUM; o++) begin
            if (write_sel[o])
                bresp_tmp = bresp_tmp | bresp_mux[o];
        end
    end
    assign master_if.BRESP = bresp_tmp;


endmodule