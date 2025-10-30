interface axi4_lite_if
  #( parameter ADDR_WIDTH = 32, parameter DATA_WIDTH = 32 );

    // Write address channel
    logic [ADDR_WIDTH -1:0] AWADDR;
    logic                  AWVALID;
    logic                  AWREADY;

    // Write data channel
    logic [DATA_WIDTH-1:0] WDATA;
    logic [DATA_WIDTH/8-1:0] WSTRB;
    logic                  WVALID;
    logic                  WREADY;

    // Write response channel
    logic [1:0]            BRESP;
    logic                  BVALID;
    logic                  BREADY;

    // Read address channel
    logic [ADDR_WIDTH-1:0] ARADDR;
    logic                  ARVALID;
    logic                  ARREADY;

    // Read data channel
    logic [DATA_WIDTH-1:0] RDATA;
    logic [1:0]            RRESP;
    logic                  RVALID;
    logic                  RREADY;

    // Modports for direction
    modport master (
        output AWADDR, AWVALID, WDATA, WSTRB, WVALID, BREADY,
               ARADDR, ARVALID, RREADY,
        input  AWREADY, WREADY, BRESP, BVALID,
               ARREADY, RDATA, RRESP, RVALID
    );

    modport slave (
        input  AWADDR, AWVALID, WDATA, WSTRB, WVALID, BREADY,
               ARADDR, ARVALID, RREADY,
        output AWREADY, WREADY, BRESP, BVALID,
               ARREADY, RDATA, RRESP, RVALID
    );


endinterface
