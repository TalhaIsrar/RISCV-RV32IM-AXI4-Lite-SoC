`include "../defines.vh"

module mem_stage(
    input [31:0] result,
    input [31:0] op2_data,
    input mem_write,
    input mem_read,
    input [1:0] store_type,
    input [2:0] load_type,
    output reg [31:0] read_data,
    output wire [31:0] calculated_result,
    output wire stall_axi,

    // IO from AXI4 Lite
    output axi_write_start,
    output [31:0] axi_write_addr,
    output [31:0] axi_write_data,
    output [3:0] axi_write_strobe,
    input axi_write_busy,
    output axi_read_start,
    output [31:0] axi_read_addr,
    input [31:0] axi_read_data,
    input axi_read_busy
);
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

    // Stall signals from axi
    assign stall_axi = axi_write_busy || axi_read_busy; 

    assign axi_write_start = mem_write;
    assign axi_write_addr = result;
    assign axi_write_data = op2_data;
    assign axi_write_strobe = write_byte_strobe;
    assign axi_read_start = mem_read;
    assign axi_read_addr = result;

    // Perform byte/half-word selection and sign/zero extension *after* the read.
    always @(*) begin
        case (load_type)
            `LOAD_LB: begin // LB - load byte, sign extend
                case (byte_offset)
                    2'b00: read_data = {{24{axi_read_data[7]}},  axi_read_data[7:0]};
                    2'b01: read_data = {{24{axi_read_data[15]}}, axi_read_data[15:8]};
                    2'b10: read_data = {{24{axi_read_data[23]}}, axi_read_data[23:16]};
                    2'b11: read_data = {{24{axi_read_data[31]}}, axi_read_data[31:24]};
                    default: read_data = 32'h00000000;
                endcase
            end
            `LOAD_HD: begin // LH - load halfword, sign extend
                if (byte_offset[1] == 1'b0) read_data = {{16{axi_read_data[15]}}, axi_read_data[15:0]};
                else                        read_data = {{16{axi_read_data[31]}}, axi_read_data[31:16]};
            end
            `LOAD_LW: begin // LW - load word
                read_data = axi_read_data;
            end
            `LOAD_LBU: begin // LBU - load byte, zero extend
                case (byte_offset)
                    2'b00: read_data = {24'h0, axi_read_data[7:0]};
                    2'b01: read_data = {24'h0, axi_read_data[15:8]};
                    2'b10: read_data = {24'h0, axi_read_data[23:16]};
                    2'b11: read_data = {24'h0, axi_read_data[31:24]};
                    default: read_data = 32'h00000000;
                endcase
            end
            `LOAD_LHU: begin // LHU - load halfword, zero extend
                if (byte_offset[1] == 1'b0) read_data = {16'h0, axi_read_data[15:0]};
                else                        read_data = {16'h0, axi_read_data[31:16]};
            end
            default: read_data = axi_read_data;
        endcase
    end

    assign calculated_result = result;

endmodule