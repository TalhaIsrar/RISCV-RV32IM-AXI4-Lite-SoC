# RISCV SoC

This project implements a RISCV SoC with **5-stage pipelined RISC-V RV32IM processor** and AXI4 Lite based interconnect. It follows the classical pipeline structure (IF → ID → EX → MEM → WB) with additional modules for branch prediction, hazard detection, forwarding, and multiplication/division support.
Furthermore, there are wrappers for AXI4 Master/Slave, the interconnect network and top module connections

---

## Block Diagram

![RISCV SoC Top](../imgs/riscv_soc_block_diagram.png)

---

## Processor Pipeline Overview

### Pipeline Stages

1. **Instruction Fetch (IF)**

   * Fetches instruction from instruction memory.
   * Integrates with **Branch Target Buffer (BTB)** for branch prediction.
   * Next PC logic selects between sequential, jump, or predicted target.

2. **Instruction Decode (ID)**

   * Decodes instruction fields (opcode, funct3, funct7).
   * Reads register file operands.
   * Immediate generator produces required constants.

3. **Execute (EX)**

   * Performs ALU operations (arithmetic, logical, shifts, branch compare).
   * Integrates with **M-unit** for multiplication/division instructions.
   * Calculates jump/branch target addresses.
   * Updates BTB if misprediction detected.

4. **Memory Access (MEM)**

   * Handles data memory reads/writes.
   * Load/store alignment and size supported.

5. **Write Back (WB)**

   * Writes either memory read data or ALU/M-unit result back to the register file.

---

## Key Supporting Units

### 1. AXI4 Lite Master/Slave, Interconnect and Top

* Single master-Multi slave AXI4 Interconnect
* Parallel read-write support (Though procerssor only uses 1 at a time)
* Parametrized allowing easy integration of new peripherals
* Allows addition of memory-mapped peripherals with minimal changes

![AXI4 Lite top](../imgs/axi4_lite/axi4lite_peripheral.png)

---

### 2. Branch Target Buffer (BTB)

* Stores branch targets and prediction bits.
* 8 - 2 way set associative buffer
* Supplies predicted PC for branches in the IF stage.
* Updated in EX stage on branch/jump resolution.
* Helps reduce branch penalty to 1 cycle.

![Branch Target Buffer](../imgs/rv32im_btb.png)

---

### 3. M-unit (Multiply/Divide Unit)

* Executes RISC-V **M extension** instructions.
* Operates alongside ALU in EX stage.
* Provides result once ready (`m_unit_ready`).
* Hazard unit stalls pipeline when M-unit is busy.

![M unit Extension](../imgs/rv32im_m_unit.png)

---

### 4. Forwarding Unit

* Resolves **data hazards** without stalling when possible.
* Selects between:

  * Register file operands (default)
  * MEM stage result
  * WB stage result
* Provides `operand_a_cntl` and `operand_b_cntl` control signals to the EX stage.

![Forwarding Unit](../imgs/rv32im_forwarding_unit.png)

---

### 5. Hazard Unit

* Handles pipeline **stalls and flushes**:

  * **Load-use hazard**: Inserts 1-cycle stall when an instruction depends on a load in EX.
  * **Branch/jump misprediction**: Flushes IF/ID and ID/EX stages.
  * **Invalid instructions**: Flushed before execution.
* Controls pipeline register enable/flush signals (`if_id_pipeline_flush`, `id_ex_pipeline_flush`, etc.) and `pc_en`.

![Hazard Unit](../imgs/rv32im_hazard_unit.png)

---

## Pipeline Registers

Each pipeline stage is separated by registers for timing and hazard management:

* **IF/ID**: Holds instruction + PC. *No separate instruction register needed since instruction memory already has 1-cycle latency.*
* **ID/EX**: Holds decoded operands, immediates, and control signals.
* **EX/MEM**: Holds ALU/M-unit results and operands for memory stage.
* **MEM/WB**: Holds data read from memory and ALU result for write-back.

---

## Summary

This RISCV SoC processor integrates:

* **5-stage pipelined datapath**
* **Hazard detection and forwarding logic** for smooth execution
* **BTB-based branch prediction** for reduced branch penalty
* **M extension support** for multiplication/division
* **AXI4 Lite Interconnect** allowing easy peripheral integration

The modular design makes it easy to extend with caches, pipeline optimizations, or additional ISA extensions.

---

*Created by Talha Israr*
