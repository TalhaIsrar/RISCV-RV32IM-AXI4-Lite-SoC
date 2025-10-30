import axi4_lite_addr_map_package::*;

module axi4_litw_interconnect #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter int SLAVES = SLAVE_NUM
)(
    input logic clk,
    input logic rst,

    axi4_lite_if master_if,
    axi4_lite_if slave_if [SLAVES]
);

    // Slave select signal - Based on decoding
    logic [SL-1:0]  aw_sel;
    logic [SL-1:0]  ar_sel;

    



endmodule