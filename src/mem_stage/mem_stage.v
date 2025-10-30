`include "../defines.vh"

module mem_stage(
    input clk,
    input rst,
    input [31:0] result,
    input [31:0] op2_data,
    input mem_write,
    input mem_read,
    input [1:0] store_type,
    input [2:0] load_type,
    output reg [31:0] read_data,
    output wire [31:0] calculated_result,
    output wire stall_axi
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
    assign byte_offset = result[1:0];

    // Generate byte strobe for axi4lite write channel
    reg [3:0] write_byte_strobe;

    // Combinational block to convert store type and byte offset to byte enables
    always @(*) begin
        case (store_type)
            `STORE_SB: begin
                if (byte_offset == 2'b00) write_byte_strobe = 4'b0001;
                if (byte_offset == 2'b01) write_byte_strobe = 4'b0010;
                if (byte_offset == 2'b10) write_byte_strobe = 4'b0100;
                if (byte_offset == 2'b11) write_byte_strobe = 4'b1000;
            end
            `STORE_SH: begin
                write_byte_strobe = !byte_offset[1] ? 4'b0011 : 4'b1100;
            end 
            `STORE_SW: begin
                write_byte_strobe = 4'b1111;
            end
            default: begin
                write_byte_strobe = 4'b0000;
            end
        endcase
    end

    // Read data from axi interconnect
    wire [31:0] read_data_axi;

    // Stall signals from axi
    wire write_busy, read_busy;

    assign stall_axi = write_busy && read_busy; 

    axi4_lite_peripheral_top axi4_lite_bus(
        .clk(clk),
        .rst(rst),
        .write_start(mem_write),
        .write_addr(result),
        .write_data(op2_data),
        .write_strobe(write_byte_strobe),
        .write_busy(write_busy),
        .read_start(mem_read),
        .read_addr(result),
        .read_data(read_data_axi),
        .read_busy(read_busy)
    );

    // Perform byte/half-word selection and sign/zero extension *after* the read.
    always @(*) begin
        case (load_type)
            `LOAD_LB: begin // LB - load byte, sign extend
                case (byte_offset)
                    2'b00: read_data = {{24{read_data_axi[7]}},  read_data_axi[7:0]};
                    2'b01: read_data = {{24{read_data_axi[15]}}, read_data_axi[15:8]};
                    2'b10: read_data = {{24{read_data_axi[23]}}, read_data_axi[23:16]};
                    2'b11: read_data = {{24{read_data_axi[31]}}, read_data_axi[31:24]};
                    default: read_data = 32'h00000000;
                endcase
            end
            `LOAD_HD: begin // LH - load halfword, sign extend
                if (byte_offset[1] == 1'b0) read_data = {{16{read_data_axi[15]}}, read_data_axi[15:0]};
                else                        read_data = {{16{read_data_axi[31]}}, read_data_axi[31:16]};
            end
            `LOAD_LW: begin // LW - load word
                read_data = read_data_axi;
            end
            `LOAD_LBU: begin // LBU - load byte, zero extend
                case (byte_offset)
                    2'b00: read_data = {24'h0, read_data_axi[7:0]};
                    2'b01: read_data = {24'h0, read_data_axi[15:8]};
                    2'b10: read_data = {24'h0, read_data_axi[23:16]};
                    2'b11: read_data = {24'h0, read_data_axi[31:24]};
                    default: read_data = 32'h00000000;
                endcase
            end
            `LOAD_LHU: begin // LHU - load halfword, zero extend
                if (byte_offset[1] == 1'b0) read_data = {16'h0, read_data_axi[15:0]};
                else                        read_data = {16'h0, read_data_axi[31:16]};
            end
            default: read_data = read_data_axi;
        endcase
    end

    assign calculated_result = result;

endmodule