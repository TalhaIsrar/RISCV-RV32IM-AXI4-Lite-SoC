`include "defines.vh"

module hazard_unit(
    input [4:0] id_rs1,
    input [4:0] id_rs2,
    input [6:0] opcode,
    input [4:0] ex_rd,
    input ex_load_inst,
    input jump_branch_taken,
    input invalid_inst,
    input stall,
    input mem_read_write,

    output reg if_id_pipeline_flush,
    output reg if_id_pipeline_en,
    output reg id_ex_pipeline_flush,
    output reg id_ex_pipeline_en,
    output reg ex_mem_pipeline_flush,
    output reg mem_wb_pipeline_en,
    output reg pc_en,
    output reg load_stall
);

    wire id_rs1_used;
    wire id_rs2_used;

    wire rs1_hazard;
    wire rs2_hazard;
    wire load_hazard;

    // For load we need to check if rs1 or rs2 is actually used in the instruction
    assign id_rs2_used  = (opcode == `OPCODE_RTYPE ||
                         opcode == `OPCODE_STYPE ||
                         opcode == `OPCODE_BTYPE);

    assign id_rs1_used  = (opcode == `OPCODE_ITYPE ||
                         opcode == `OPCODE_ILOAD ||
                         opcode == `OPCODE_IJALR) || id_rs2_used;

    assign rs1_hazard = id_rs1_used && (id_rs1 == ex_rd);
    assign rs2_hazard = id_rs2_used && (id_rs2 == ex_rd);
    assign load_hazard = ex_load_inst && (ex_rd != 5'b0) && (rs1_hazard || rs2_hazard);
     
    // At one time only 1 of `ex_load_inst` or `jump_branch_taken` will be true
    always @(*) begin
        //  Default values to avoid latch
        if_id_pipeline_flush = 1'b0;
        if_id_pipeline_en = 1'b1;
        id_ex_pipeline_flush = 1'b0;
        id_ex_pipeline_en = 1'b1;
        pc_en = 1'b1;
        load_stall = 1'b0;
        ex_mem_pipeline_flush = 1'b0;
        mem_wb_pipeline_en = 1'b1;

        // Jump/Branch taken flush - 2 Stall
        if (jump_branch_taken) begin
            if_id_pipeline_flush = 1'b1;
            if_id_pipeline_en = 1'b0;
            id_ex_pipeline_flush = 1'b1;

        end else if (mem_read_write) begin
            if_id_pipeline_en = 1'b0;
            id_ex_pipeline_en = 1'b0;
            pc_en = 1'b0;
            ex_mem_pipeline_flush = 1'b1;
            mem_wb_pipeline_en = 1'b0;

        // Load flush - 1 Stall
        end else if (load_hazard) begin
            if_id_pipeline_en = 1'b0;
            id_ex_pipeline_flush = 1'b1;
            pc_en = 1'b0;
            load_stall = 1'b1;
        end

        else if (stall) begin
            if_id_pipeline_en = 1'b0;
            id_ex_pipeline_en = 1'b0;
            pc_en = 1'b0;
        end

        else if (invalid_inst) begin
            id_ex_pipeline_flush = 1'b1;
        end

    end

endmodule