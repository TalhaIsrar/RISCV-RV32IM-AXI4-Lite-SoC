import axi4_lite_addr_map_package::*;

module axi4_lite_peripheral_top #(
    parameter ADDR_WIDTH = ADDR_WIDTH,
    parameter DATA_WIDTH = DATA_WIDTH,
    parameter SLAVE_NUM  = SLAVE_NUM
)(
    input logic                    clk,
    input logic                    rst,

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
    output logic                   read_busy
);

    // Master interface signals
    axi4_lite_if #(ADDR_WIDTH, DATA_WIDTH) master_if();

    // Slave interface array
    axi4_lite_if #(ADDR_WIDTH, DATA_WIDTH) slave_if[SLAVE_NUM]();

    // Peripheral interface outputs
    logic [SLAVE_NUM-1:0]                 peripheral_mem_write;
    logic [SLAVE_NUM-1:0][3:0]            peripheral_byte_en;
    logic [SLAVE_NUM-1:0][ADDR_WIDTH-1:0] peripheral_write_addr;
    logic [SLAVE_NUM-1:0][DATA_WIDTH-1:0] peripheral_write_data;
    logic [SLAVE_NUM-1:0][DATA_WIDTH-1:0] peripheral_read_data;
    logic [SLAVE_NUM-1:0][ADDR_WIDTH-1:0] peripheral_read_addr;
    logic [SLAVE_NUM-1:0]                 peripheral_data_valid;

    // Master module instance
    axi4_lite_master #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) master_inst (
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
        .master_if(master_if)
    );

    // Interconnect instance
    axi4_lite_interconnect #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .SLAVE_NUM(SLAVE_NUM),
        .SLAVE_BASE_ADDR(SLAVE_BASE_ADDR),
        .SLAVE_ADDR_MASK(SLAVE_ADDR_MASK)
    ) interconnect_inst (
        .clk(clk),
        .rst(rst),
        .master_if(master_if),
        .slave_if(slave_if)
    );

    // Instantiate AXI4-Lite Slaves for connection to slaves
    genvar i;
    generate
        for (i = 0; i < SLAVE_NUM; i++) begin : gen_slaves
            axi4_lite_slave #(
                .ADDR_WIDTH(ADDR_WIDTH),
                .DATA_WIDTH(DATA_WIDTH)
            ) u_slave (
                .clk(clk),
                .rst(rst),

                // Connect peripheral outputs
                .mem_write(peripheral_mem_write[i]),
                .byte_en(peripheral_byte_en[i]),
                .write_addr(peripheral_write_addr[i]),
                .write_data(peripheral_write_data[i]),

                .read_data(peripheral_read_data[i]),
                .data_valid(1'b1),
                .read_addr(peripheral_read_addr[i]),

                // Connect AXI interface
                .slave_if(slave_if[i])
            );
        end
    endgenerate

    // Slaves

    // Slave 1 - Data Memory
    data_memory mem1 (
        .clk(clk),
        .rst(rst),
        .mem_write(peripheral_mem_write[0]),
        .byte_en(peripheral_byte_en[0]),
        .write_addr(peripheral_write_addr[0][11:0]),
        .read_addr(peripheral_read_addr[0][11:0]),
        .write_data(peripheral_write_data[0]),
        .read_data(peripheral_read_data[0])
    );

    // Slave 2 - Data Memory
    data_memory mem2 (
        .clk(clk),
        .rst(rst),
        .mem_write(peripheral_mem_write[1]),
        .byte_en(peripheral_byte_en[1]),
        .write_addr(peripheral_write_addr[1][11:0]),
        .read_addr(peripheral_read_addr[1][11:0]),
        .write_data(peripheral_write_data[1]),
        .read_data(peripheral_read_data[1])
    );

endmodule