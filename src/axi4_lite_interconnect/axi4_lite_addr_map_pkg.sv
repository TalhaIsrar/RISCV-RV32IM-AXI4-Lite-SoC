package axi4_lite_addr_map_package;

    // Number of slaves
    parameter int SLAVE_NUM = 2;

    // Address and Data Width
    parameter int ADDR_WIDTH = 32;
    parameter int DATA_WIDTH = 32;

    // Base Address for each slave
    localparam logic [ADDR_WIDTH - 1 : 0] SLAVE_BASE_ADDR [SLAVE_NUM] = `{
        32'h0000_0000,
        32'h0000_0100
    }

    // Address Mask for each slave
    localparam logic [ADDR_WIDTH - 1 : 0] SLAVE_ADDR_MASK [SLAVE_NUM] = `{
        32'hFFFF_FF00,  // 1 KB Memory
        32'hFFFF_0000   // 1 KB Memory
    }

endpackage