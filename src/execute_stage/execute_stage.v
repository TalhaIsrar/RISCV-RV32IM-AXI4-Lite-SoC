module execute_stage(
    input [31:0] pc,
    input [31:0] op1,
    input [31:0] op2,
    input pipeline_flush,
    input [31:0] immediate,
    input [6:0] func7,
    input [2:0] func3,
    input [6:0] opcode,
    input ex_alu_src,
    input invalid_inst,
    input ex_wb_reg_file,
    input [31:0] m_unit_result,
    input m_unit_wr,
    input m_unit_ready,
    input [4:0] m_unit_dest,
    input [4:0] alu_rd,
    
    input [1:0] operand_a_forward_cntl,
    input [1:0] operand_b_forward_cntl,
    input [31:0] data_forward_mem,
    input [31:0] data_forward_wb,

    output wire [31:0] result,
    output wire [31:0] op1_selected,
    output wire [31:0] op2_selected,
    output wire [4:0] wb_rd,
    output wire wb_reg_file,
    output wire [5:0] branch_type,
    output wire [2:0] alu_flags
);

    wire [3:0] ALUControl;
    reg [31:0] op1_forwarded;
    reg [31:0] op2_forwarded;
    reg [31:0] op1_alu;
    reg [31:0] op2_alu;
    wire [31:0] alu_result;

    wire [31:0] op1_valid;
    wire [31:0] op2_valid;

    // Compute branch/jump enable
    assign branch_type[0] = (func3 == `BTYPE_BEQ); //beq
    assign branch_type[1] = (func3 == `BTYPE_BNE); //bne
    assign branch_type[2] = (func3 == `BTYPE_BLT); //blt
    assign branch_type[3] = (func3 == `BTYPE_BGE); //bge
    assign branch_type[4] = (func3 == `BTYPE_BLTU); //bltu
    assign branch_type[5] = (func3 == `BTYPE_BGEU); //bgeu

    // Mux for forwarding operand 1
    always @(*) begin
        case (operand_a_forward_cntl)
            `FORWARD_MEM: op1_forwarded = data_forward_mem;
            `FORWARD_WB:  op1_forwarded = data_forward_wb;
            default:      op1_forwarded = op1;
        endcase
    end

    // Mux for forwarding operand 2
    always @(*) begin
        case (operand_b_forward_cntl)
            `FORWARD_MEM: op2_forwarded = data_forward_mem;
            `FORWARD_WB:  op2_forwarded = data_forward_wb;
            default:      op2_forwarded = op2;
        endcase
    end

    // Pass op2 directly to pipeline stage in case it is used for Load instruction
    // Forwarded outputs are also used in the M unit to avoid data hazards
    assign op2_selected = op2_forwarded;
    assign op1_selected = op1_forwarded;

    always @(*) begin
        case (opcode)
            `OPCODE_IJALR: begin
                op1_alu = pc;
                op2_alu = 32'd4;
            end
            `OPCODE_JTYPE: begin
                op1_alu = pc;
                op2_alu = 32'd4;
            end
            `OPCODE_UTYPE: begin
                op1_alu = 32'h00000000;
                op2_alu = immediate;
            end
            `OPCODE_AUIPC: begin
                op1_alu = pc;
                op2_alu = immediate;
            end
            default: begin
                op1_alu = invalid_inst ? 0 : op1_forwarded;
                op2_alu = ex_alu_src ? immediate : op2_forwarded;
            end      
        endcase
    end
        
    assign op1_valid = pipeline_flush ? 0 : op1_alu;
    assign op2_valid = pipeline_flush ? 0 : op2_alu;

    // Instantiate the PC Jump Module
    pc_jump pc_jump_inst (
        .pc(pc),
        .immediate(immediate),
        .op1(op1_forwarded),
        .opcode(opcode),
        .func3(func3),
        .predictedTaken(predictedTaken),
    );

    // Instantiate the ALU Controller
    alu_control alu_control_inst (
        .func3(func3),
        .func7(func7),
        .opcode(opcode),
        .ALUControl(ALUControl)
    );   

    // Instantiate the ALU module
    alu alu_inst (
        .op1(op1_valid),
        .op2(op2_valid),
        .ALUControl(ALUControl),
        .result(alu_result),
        .lt_flag(alu_flags[0]),
        .ltu_flag(alu_flags[1]),
        .zero_flag(alu_flags[2])
    );

    // Check if we have data from M unit
    assign result = m_unit_ready ? m_unit_result : alu_result;
    assign wb_reg_file = m_unit_ready ? m_unit_wr : ex_wb_reg_file;
    assign wb_rd = m_unit_ready ? m_unit_dest : (pipeline_flush ? 5'b00000 : alu_rd);

endmodule