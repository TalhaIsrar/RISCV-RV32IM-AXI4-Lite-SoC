module data_mem (
    input clk,
    input rst,
    input mem_write,       // 1 = write, 0 = read
    input [1:0] store_type, // 2'b00=SB , 2'b01=SH , 2'b10=SW
    input [11:0] addr,
    input [31:0] write_data,
    output reg [31:0] read_data
);

    // Declare memory as word-addressable.
    // 1KB = 1024 bytes = 256 words of 32 bits.
    // The `ram_style` attribute explicitly tells Vivado to use BRAM.
    (* ram_style = "block" *) reg [31:0] mem [0:255];

    // Address for the 32-bit word.
    wire [9:0] word_addr = addr[11:2];
    wire [1:0] byte_offset = addr[1:0];

    // Buffers to keep the load type and byte offset saved since they are applied after read operation
    reg [1:0] byte_offset_r;

    // Implement a single, synchronous read operation.
    // This is the core of BRAM inference.
    always @(posedge clk) begin
        read_data <= mem[word_addr];
    end

    // Save these details to apply after read operation
    always @(posedge clk) begin
        byte_offset_r <= addr[1:0]; // align with the word you just fetched
    end


    // Implement synchronous write with byte-enables.
    // This maps directly to BRAM's byte-write enable feature.
    always @(posedge clk) begin
        if (mem_write) begin
            case (store_type)
                2'b00: begin // SB - store byte
                    if (byte_offset == 2'b00) mem[word_addr][7:0]   <= write_data[7:0];
                    if (byte_offset == 2'b01) mem[word_addr][15:8]  <= write_data[7:0];
                    if (byte_offset == 2'b10) mem[word_addr][23:16] <= write_data[7:0];
                    if (byte_offset == 2'b11) mem[word_addr][31:24] <= write_data[7:0];
                end
                2'b01: begin // SH - store halfword
                    if (byte_offset[1] == 1'b0) mem[word_addr][15:0]  <= write_data[15:0];
                    else                       mem[word_addr][31:16] <= write_data[15:0];
                end
                2'b10: begin // SW - store word
                    mem[word_addr] <= write_data;
                end
            endcase
        end
    end

endmodule