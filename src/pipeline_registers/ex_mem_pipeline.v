module ex_mem_pipeline(
    input clk,
    input rst,
    input pipeline_flush,
    input pipeline_stall,
    input pipeline_en,

    input [31:0] ex_result,
    input [31:0] ex_op2_selected,
    input ex_memory_write,
    input [2:0] ex_memory_load_type,
    input [1:0] ex_memory_store_type,
    input ex_wb_load,
    input ex_wb_reg_file,
    input [4:0] ex_wb_rd,
    input [31:0] ex_pc,
    input [31:0] ex_immediate,
    input [31:0] ex_op1,
    input [6:0] ex_opcode,
    input ex_predictedTaken,
    input [5:0] ex_branch_type,
    input [2:0] ex_alu_flags,

    output reg [31:0] mem_result,
    output reg [31:0] mem_op2_selected,
    output reg mem_memory_write,
    output reg mem_memory_read,
    output reg [2:0] mem_memory_load_type,
    output reg [1:0] mem_memory_store_type,
    output reg mem_wb_load,
    output reg mem_wb_reg_file,
    output reg [4:0] mem_wb_rd,
    output reg [31:0] mem_pc,
    output reg [31:0] mem_immediate,
    output reg [31:0] mem_op1,
    output reg [6:0] mem_opcode,
    output reg mem_predictedTaken,
    output reg [5:0] mem_branch_type,
    output reg [2:0] mem_alu_flags
);

    always @(posedge clk or posedge rst) begin
        if (rst || pipeline_flush) begin
            mem_result <= 32'h00000000;
            mem_op2_selected <= 32'h00000000;
            mem_memory_write <= 1'b0;
            mem_memory_read <= 1'b0;
            mem_memory_load_type <= 3'b111;
            mem_memory_store_type <= 2'b11;
            mem_wb_load <= 1'b0;
            mem_wb_reg_file <= 1'b0;
            mem_wb_rd <= 5'b00000;
            mem_pc <= 0;
            mem_immediate <= 0;
            mem_op1 <= 0;
            mem_opcode <= 0;
            mem_predictedTaken <= 0;
            mem_branch_type <= 0;
            mem_alu_flags <= 0;

        end else if (pipeline_stall) begin
            mem_memory_write <= 1'b0;
            mem_memory_read <= 1'b0;

        end else if (pipeline_en) begin
            mem_result <= ex_result;
            mem_op2_selected <= ex_op2_selected;
            mem_memory_write <= ex_memory_write;
            mem_memory_read <= ex_wb_load;
            mem_memory_load_type <= ex_memory_load_type;
            mem_memory_store_type <= ex_memory_store_type;
            mem_wb_load <= ex_wb_load;
            mem_wb_reg_file <= ex_wb_reg_file;
            mem_wb_rd <= ex_wb_rd;
            mem_pc <= ex_pc;
            mem_immediate <= ex_immediate;
            mem_op1 <= ex_op1;
            mem_opcode <= ex_opcode;
            mem_predictedTaken <= ex_predictedTaken;
            mem_branch_type <= ex_branch_type;
            mem_alu_flags <= ex_alu_flags;
        end
    end

endmodule