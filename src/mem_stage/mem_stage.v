module mem_stage(
    input clk,
    input rst,
    input [31:0] result,
    input [31:0] op2_data,
    input mem_write,
    input mem_read,
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

    // Check if we have read/write instruction
    wire load_store_inst;
    assign load_store_inst = mem_write & mem_read;

    // Byte offset from address
    wire [1:0] byte_offset;
    assign byte_offset = addr[1:0];

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



    // Read data from axi interconnect
    reg [31:0] read_data_axi;

    // Perform byte/half-word selection and sign/zero extension *after* the read.
    // This logic is combinatorial and will be synthesized as muxes outside the BRAM.
    always @(*) begin
        case (load_type)
            3'b000: begin // LB - load byte, sign extend
                case (byte_offset)
                    2'b00: read_data = {{24{read_data_axi[7]}},  read_data_axi[7:0]};
                    2'b01: read_data = {{24{read_data_axi[15]}}, read_data_axi[15:8]};
                    2'b10: read_data = {{24{read_data_axi[23]}}, read_data_axi[23:16]};
                    2'b11: read_data = {{24{read_data_axi[31]}}, read_data_axi[31:24]};
                    default: read_data = 32'h00000000;
                endcase
            end
            3'b001: begin // LH - load halfword, sign extend
                if (byte_offset[1] == 1'b0) read_data = {{16{read_data_axi[15]}}, read_data_axi[15:0]};
                else                        read_data = {{16{read_data_axi[31]}}, read_data_axi[31:16]};
            end
            3'b010: begin // LW - load word
                read_data = read_data_axi;
            end
            3'b011: begin // LBU - load byte, zero extend
                case (byte_offset)
                    2'b00: read_data = {24'h0, read_data_axi[7:0]};
                    2'b01: read_data = {24'h0, read_data_axi[15:8]};
                    2'b10: read_data = {24'h0, read_data_axi[23:16]};
                    2'b11: read_data = {24'h0, read_data_axi[31:24]};
                    default: read_data = 32'h00000000;
                endcase
            end
            3'b100: begin // LHU - load halfword, zero extend
                if (byte_offset[1] == 1'b0) read_data = {16'h0, read_data_axi[15:0]};
                else                        read_data = {16'h0, read_data_axi[31:16]};
            end
            default: read_data = read_data_axi;
        endcase
    end

    assign calculated_result = result;

endmodule