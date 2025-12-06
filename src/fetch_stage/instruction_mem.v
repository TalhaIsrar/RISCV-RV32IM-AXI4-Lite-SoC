module instruction_mem(
    input clk,
    input rst,
    input [31:0] pc,
    input read_en,
    input write_en,
    input flush,
    input [7:0] write_addr,
    input [31:0] write_data,
    output [31:0] instruction
);
    reg [31:0] instruction;

    // Memory array to hold instructions
    reg [31:0] mem [0:255]; // 1KB memory

    // Initialize memory using file
    initial begin
        $readmemh("C:\\Users\\Talha\\Documents\\vivado\\riscv_rv32im_axi4_lite_soc_optimized\\programs\\instructions.hex", mem);
    end

    // Add this for synthesis to block RAM
    always @(posedge clk) begin
        if (write_en) 
            mem[write_addr] <= write_data;
    end


    always @(posedge clk) begin
        if (rst) begin
            instruction <= 32'h00000000; // Reset instruction to NOP
        end else if (flush) begin
            instruction <= 32'h00000000; // Flush instruction to NOP
        end else if (read_en) begin
            instruction <= mem[pc[11:2]]; // Fetch instruction based on PC
        end
    end
endmodule