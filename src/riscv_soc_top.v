module riscv_soc_top(
    input clk,
    input rst,
    output [31:0] wb_result,
    output [31:0] ex_result,
    output pc_en,
    output led
);

    // EX/IF Signals
    wire [31:0] ex_if_pc_jump_addr;
    wire ex_jump_en;

    // Branch Target Buffer Signals
    wire [31:0] btb_target_pc;
    wire btb_pc_valid;
    wire btb_pc_predictTaken;
    wire btb_update;
    wire [31:0] btb_update_target;

    // Hazard Unit Signals
    wire pc_en;
    wire if_id_pipeline_flush;
    wire if_id_pipeline_en;
    wire id_ex_pipeline_flush;
    wire id_ex_pipeline_en;
    wire ex_mem_pipeline_flush;
    wire mem_wb_pipeline_en;
    wire invalid_inst;
    wire load_stall;
    wire m_type_inst;
    wire stall_axi;

    // IF/ID Connection
    wire [31:0] if_instruction, id_instruction;
    wire [31:0] if_pc, id_pc;
    wire id_flush;

    // M Unit Connection
    wire [31:0] m_unit_op1;
    wire [31:0] m_unit_instruction;
    wire m_unit_invalid_inst;
    wire m_unit_ready;
    wire m_unit_wr;
    wire [31:0] m_unit_result;
    wire m_unit_busy;
    wire [4:0] m_unit_dest;

    // ID/EX Connection
    wire [31:0] ex_pc;
    wire [31:0] id_op1, ex_op1;
    wire [31:0] id_op2, ex_op2;
    wire [4:0]  id_rs1, ex_rs1;
    wire [4:0]  id_rs2, ex_rs2;
    wire [4:0]  id_wb_rd, ex_wb_rd;
    wire [31:0] id_immediate, ex_immediate;
    wire [6:0]  id_opcode, ex_opcode;
    wire        id_alu_src, ex_alu_src;
    wire [6:0]  id_func7, ex_func7;
    wire [2:0]  id_func3, ex_func3;
    wire        id_mem_write, ex_mem_write;
    wire [2:0]  id_mem_load_type, ex_mem_load_type;
    wire [1:0]  id_mem_store_type, ex_mem_store_type;
    wire        id_wb_load, ex_wb_load;
    wire        id_wb_reg_file, ex_wb_reg_file;
    wire        id_pred_taken, ex_pred_taken;
    wire        ex_forward_pipeline_flush;

    // Forwarding Unit Connection
    wire [1:0]  operand_a_cntl;
    wire [1:0]  operand_b_cntl;

    // EX/MEM Conncetion
    wire [4:0]  alu_rd;
    wire        alu_wb;
    wire [31:0] ex_result, mem_result;
    wire [31:0] ex_op2_selected, mem_op2_selected;
    wire [4:0]  mem_wb_rd;
    wire        mem_memory_write;
    wire        mem_memory_read;
    wire [2:0]  mem_memory_load_type;
    wire [1:0]  mem_memory_store_type;
    wire        mem_wb_load;
    wire        mem_wb_reg_file;

    // IO to/from AXI4 Lite
    wire axi_write_start;
    wire [31:0] axi_write_addr;
    wire [31:0] axi_write_data;
    wire [3:0] axi_write_strobe;
    wire axi_write_busy;
    wire axi_read_start;
    wire [31:0] axi_read_addr;
    wire [31:0] axi_read_data;
    wire axi_read_busy;

    // MEM/WB Connection
    wire [31:0] mem_read_data, wb_read_data;
    wire [31:0] mem_calculated_result, wb_calculated_result;
    wire [4:0]  wb_rd;
    wire        wb_reg_file;
    wire        wb_load;
    wire [31:0] wb_result;


    // Instantiate the Fetch stage module
    fetch_stage fetch_stage_inst (
        .clk(clk),
        .rst(rst),
        .pc_en(pc_en),
        .flush(if_id_pipeline_flush),
        .pc_jump_addr(ex_if_pc_jump_addr),
        .jump_en(ex_if_jump_en),
        .btb_target_pc(btb_target_pc),
        .btb_pc_valid(btb_pc_valid), // Replace this by 1'b0 to disconnect BTB
        .btb_pc_predictTaken(btb_pc_predictTaken), // Replace this by 1'b0 to disconnect BTB
        .instruction(if_instruction),
        .pc(if_pc)
    );

    // Instantiate the Branch Target Buffer module
    btb btb_inst (
        .clk(clk),
        .rst(rst),
        .pc(if_pc),
        .update_pc(ex_pc),
        .update(btb_update), // Replace this by 1'b0 to disconnect BTB otherwise keep btb_update
        .update_target(btb_update_target),
        .mispredicted(ex_if_jump_en),
        .target_pc(btb_target_pc),
        .valid(btb_pc_valid),
        .predictedTaken(btb_pc_predictTaken)
    );

    // Instantiate the IF/ID pipeline module
    if_id_pipeline if_id_pipeline_inst (
        .clk(clk),
        .rst(rst),
        .pipeline_flush(if_id_pipeline_flush),
        .pipeline_en(if_id_pipeline_en),
        .if_flush(if_id_pipeline_flush),
        .if_pc(if_pc),
        .if_instruction(if_instruction),
        .if_pred_taken(btb_pc_predictTaken),
        .id_flush(id_flush),
        .id_pc(id_pc),
        .id_instruction(id_instruction),
        .id_pred_taken(id_pred_taken)
    );

    // Instantiate the Decode stage module
    decode_stage decode_stage_inst (
        .clk(clk),
        .rst(rst),
        .id_flush(id_flush),
        .instruction_in(id_instruction),
        .reg_file_wr_en(wb_reg_file),   // Come from WB stage
        .reg_file_wr_addr(wb_rd), // Come from WB stage
        .reg_file_wr_data(wb_result), // Come from WB stage
        .op1(id_op1),
        .op2(id_op2),
        .rs1(id_rs1),
        .rs2(id_rs2),
        .rd(id_wb_rd),
        .immediate(id_immediate),
        .opcode(id_opcode),
        .alu_src(id_alu_src),
        .invalid_inst(invalid_inst),
        .m_type_inst(m_type_inst),
        .func7(id_func7),
        .func3(id_func3),
        .mem_write(id_mem_write),
        .mem_load_type(id_mem_load_type),
        .mem_store_type(id_mem_store_type),
        .wb_load(id_wb_load),
        .wb_reg_file(id_wb_reg_file)
    );

    // Instantiate the ID/EX pipeline module
    id_ex_pipeline id_ex_pipeline_inst (
        .clk(clk),
        .rst(rst),
        .pipeline_flush(id_ex_pipeline_flush),
        .pipeline_en(id_ex_pipeline_en),
        .id_invalid_inst(!load_stall && invalid_inst && !ex_if_jump_en),
        .id_instruction(id_instruction),
        .id_pc(id_pc),
        .id_op1(id_op1),
        .id_op2(id_op2),
        .id_immediate(id_immediate),
        .id_opcode(id_opcode),
        .id_alu_src(id_alu_src),
        .id_func7(id_func7),
        .id_func3(id_func3),
        .id_mem_write(id_mem_write),
        .id_mem_load_type(id_mem_load_type),
        .id_mem_store_type(id_mem_store_type),
        .id_wb_load(id_wb_load),
        .id_wb_reg_file(id_wb_reg_file),
        .id_rs1(id_rs1),
        .id_rs2(id_rs2),
        .id_wb_rd(id_wb_rd),
        .id_pred_taken(id_pred_taken),

        .ex_forward_pipeline_flush(ex_forward_pipeline_flush),
        .ex_invalid_inst(m_unit_invalid_inst),
        .ex_instruction(m_unit_instruction),
        .ex_pc(ex_pc),
        .ex_op1(ex_op1),
        .ex_op2(ex_op2),
        .ex_immediate(ex_immediate),
        .ex_opcode(ex_opcode),
        .ex_alu_src(ex_alu_src),
        .ex_func7(ex_func7),
        .ex_func3(ex_func3),
        .ex_mem_write(ex_mem_write),
        .ex_mem_load_type(ex_mem_load_type),
        .ex_mem_store_type(ex_mem_store_type),
        .ex_wb_load(ex_wb_load),
        .ex_wb_reg_file(ex_wb_reg_file),
        .ex_rs1(ex_rs1),
        .ex_rs2(ex_rs2),
        .ex_wb_rd(ex_wb_rd),
        .ex_pred_taken(ex_pred_taken)
    );

    // Instantiate the M Unit
    riscv_m_unit riscv_m_unit_inst(
        .clk(clk),
        .resetn(rst),
        .valid(m_unit_invalid_inst),
        .instruction(m_unit_instruction),
        .rs1(m_unit_op1),
        .rs2(ex_op2_selected),
        .rd(ex_wb_rd),
        .rs1_reg(ex_rs1),
        .rs2_reg(ex_rs2),
        .wr(m_unit_wr),
        .result(m_unit_result),
        .busy(m_unit_busy),
        .ready(m_unit_ready),
        .result_dest(m_unit_dest)
    );

    // Instantiate the Forwading Unit module
    forwarding_unit forwarding_unit_inst (
        .rs1(ex_rs1),
        .rs2(ex_rs2),
        .rd_mem(mem_wb_rd),
        .rd_wb(wb_rd),
        .reg_file_wr_mem(mem_wb_reg_file),
        .reg_file_wr_wb(wb_reg_file),
        .operand_a_cntl(operand_a_cntl),
        .operand_b_cntl(operand_b_cntl)
    );

    // Instantiate the Execute stage module
    execute_stage execute_stage_inst (
        .pc(ex_pc),
        .op1(ex_op1),
        .op2(ex_op2),
        .pipeline_flush(ex_mem_pipeline_flush),
        .immediate(ex_immediate),
        .func7(ex_func7),
        .func3(ex_func3),
        .opcode(ex_opcode),
        .ex_alu_src(ex_alu_src),
        .predictedTaken(ex_pred_taken),
        .invalid_inst(m_unit_invalid_inst),
        .ex_wb_reg_file(ex_wb_reg_file),
        .m_unit_result(m_unit_result),
        .m_unit_wr(m_unit_wr),
        .m_unit_ready(m_unit_ready),
        .m_unit_dest(m_unit_dest),
        .alu_rd(ex_wb_rd),
        .operand_a_forward_cntl(operand_a_cntl),
        .operand_b_forward_cntl(operand_b_cntl),
        .data_forward_mem(mem_result),
        .data_forward_wb(wb_result),
        .result(ex_result),
        .op1_selected(m_unit_op1),
        .op2_selected(ex_op2_selected),
        .pc_jump_addr(ex_if_pc_jump_addr),
        .jump_en(ex_if_jump_en),
        .update_btb(btb_update),
        .calc_jump_addr(btb_update_target),
        .wb_rd(alu_rd),
        .wb_reg_file(alu_wb)
    );

    // Instantiate the Hazard Unit module
    hazard_unit hazard_unit_inst (
        .id_rs1(id_rs1),
        .id_rs2(id_rs2),
        .opcode(id_opcode),
        .ex_rd(ex_wb_rd),
        .ex_load_inst(ex_wb_load),
        .jump_branch_taken(ex_if_jump_en),
        .invalid_inst(invalid_inst),
        .stall(m_unit_busy || m_unit_ready),
        .mem_read_write(mem_memory_write || mem_memory_read || stall_axi),
        .if_id_pipeline_flush(if_id_pipeline_flush),
        .if_id_pipeline_en(if_id_pipeline_en),
        .id_ex_pipeline_flush(id_ex_pipeline_flush),
        .id_ex_pipeline_en(id_ex_pipeline_en),
        .ex_mem_pipeline_flush(ex_mem_pipeline_flush),
        .mem_wb_pipeline_en(mem_wb_pipeline_en),
        .pc_en(pc_en),
        .load_stall(load_stall)
    );

    // Instantiate the EX/MEM pipeline module
    ex_mem_pipeline ex_mem_pipeline_inst (
        .clk(clk),
        .rst(rst),
        .pipeline_flush(ex_mem_pipeline_flush),
        .pipeline_en(!m_unit_busy),
        .ex_result(ex_result),
        .ex_op2_selected(ex_op2_selected),
        .ex_memory_write(ex_mem_write),
        .ex_memory_load_type(ex_mem_load_type),
        .ex_memory_store_type(ex_mem_store_type),
        .ex_wb_load(ex_wb_load),
        .ex_wb_reg_file(alu_wb),
        .ex_wb_rd(alu_rd),

        .mem_result(mem_result),
        .mem_op2_selected(mem_op2_selected),
        .mem_memory_write(mem_memory_write),
        .mem_memory_read(mem_memory_read),
        .mem_memory_load_type(mem_memory_load_type),
        .mem_memory_store_type(mem_memory_store_type),
        .mem_wb_load(mem_wb_load),
        .mem_wb_reg_file(mem_wb_reg_file),
        .mem_wb_rd(mem_wb_rd)
    );

    // Instantiate the Memory stage module
    mem_stage mem_stage_inst (
        .result(mem_result),
        .op2_data(mem_op2_selected),
        .mem_write(mem_memory_write),
        .mem_read(mem_memory_read),
        .store_type(mem_memory_store_type),
        .load_type(mem_memory_load_type),
        .read_data(mem_read_data),
        .calculated_result(mem_calculated_result),
        .stall_axi(stall_axi),

        .axi_write_start(axi_write_start),
        .axi_write_addr(axi_write_addr),
        .axi_write_data(axi_write_data),
        .axi_write_strobe(axi_write_strobe),
        .axi_write_busy(axi_write_busy),
        .axi_read_start(axi_read_start),
        .axi_read_addr(axi_read_addr),
        .axi_read_data(axi_read_data),
        .axi_read_busy(axi_read_busy)
    );

    axi4_lite_peripheral_top #(
        .ADDR_WIDTH(32),
        .DATA_WIDTH(32)
    ) axi4_lite_bus(
        .clk(clk),
        .rst(rst),
        .write_start(axi_write_start),
        .write_addr(axi_write_addr),
        .write_data(axi_write_data),
        .write_strobe(axi_write_strobe),
        .write_busy(axi_write_busy),
        .read_start(axi_read_start),
        .read_addr(axi_read_addr),
        .read_data(axi_read_data),
        .read_busy(axi_read_busy),
        .led(led)
    );

    // Instantiate the MEM/WB pipeline module
    mem_wb_pipeline mem_wb_pipeline_inst (
        .clk(clk),
        .rst(rst),
        .mem_wb_pipeline_en(mem_wb_pipeline_en),
        .mem_wb_load(mem_wb_load),
        .mem_wb_reg_file(mem_wb_reg_file),
        .mem_read_data(mem_read_data),
        .mem_calculated_result(mem_calculated_result),
        .mem_wb_rd(mem_wb_rd),
        .wb_load(wb_load),
        .wb_reg_file(wb_reg_file),
        .wb_read_data(wb_read_data),
        .wb_calculated_result(wb_calculated_result),
        .wb_rd(wb_rd)
    );

    // Instantiate the Write Back stage module
    writeback_stage writeback_stage_inst (
        .wb_load(wb_load),
        .mem_read_data(wb_read_data),
        .alu_result(wb_calculated_result),
        .wb_result(wb_result)
    );

endmodule