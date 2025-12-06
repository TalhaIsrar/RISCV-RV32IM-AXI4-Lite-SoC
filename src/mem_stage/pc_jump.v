`include "../defines.vh"

module pc_jump(
    input [31:0] pc,
    input [31:0] immediate,
    input [31:0] op1,
    input [6:0] opcode,
    input predictedTaken,
    input [5:0] branch_type,
    input [2:0] alu_flags,
    output [31:0] update_pc,
    output [31:0] jump_addr,
    output modify_pc,
    output update_btb
);
    wire [31:0] input_a;
    wire jump_inst, branch_inst;
    wire jalr_inst;
    wire branch_taken;
    wire jump_en;
    wire [31:0] adder_out;
    wire [31:0] pc_inc;

    wire lt_flag, ltu_flag, zero_flag;
    assign lt_flag = alu_flags[0];
    assign ltu_flag = alu_flags[1];
    assign zero_flag = alu_flags[2];

    assign jalr_inst = opcode ==`OPCODE_IJALR;
    assign jump_inst = (opcode ==`OPCODE_JTYPE) || jalr_inst;
    assign branch_inst = (opcode == `OPCODE_BTYPE);

    assign update_btb = jump_inst || branch_inst;

    assign branch_taken = (branch_type[0]  &&  zero_flag) ||
                        (branch_type[1]  && ~zero_flag) ||
                        (branch_type[2]  &&  lt_flag)   ||
                        (branch_type[3]  && ~lt_flag)   ||
                        (branch_type[4] &&  ltu_flag)  ||
                        (branch_type[5] && ~ltu_flag);

    assign jump_en = jump_inst || (branch_inst && branch_taken);

    assign modify_pc = jump_en ^ predictedTaken;
    
    assign input_a = jalr_inst ? op1 : pc;
    assign adder_out = input_a + immediate;
    assign jump_addr = jalr_inst ? (adder_out & 32'hFFFFFFFE) : adder_out;

    assign pc_inc = pc + 32'h4;
    assign update_pc = predictedTaken ? pc_inc : jump_addr;


endmodule