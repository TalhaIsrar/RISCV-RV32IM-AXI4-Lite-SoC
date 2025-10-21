module mem_stage(
    input clk,
    input rst,
    input [31:0] result,
    input [31:0] op2_data,
    input mem_write,
    input [1:0] store_type,
    input [2:0] load_type,
    output wire [31:0] read_data,
    output wire [31:0] calculated_result
);


    //TODO: Integrate AXI4-lite here
    //TODO: Make sure load store still work
    //TODO: Make sure byte/hardword/word store/load still works
    //TODO: Stall CPU if AXI4-lite based approach takes multiple cycles
    //TODO: Modify the MEM/WB Pipeline module because it doesnt register the read_data signal


/**
    // Instantiate the Data Memory
    data_mem data_mem_inst (
        .clk(clk),
        .rst(rst),
        .mem_write(mem_write),
        .store_type(store_type),
        .load_type(load_type),
        .addr(result[11:0]),
        .write_data(op2_data),
        .read_data(read_data)
    );   
**/

    assign calculated_result = result;

endmodule