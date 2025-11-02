# Memory Stage Module

This folder contains the implementation of the **Memory (MEM) stage** for the RV32IM 5-stage pipelined processor.
The MEM stage handles **memory read/write operations** and passes the ALU result forward to the next stage. This module is connected to the AXI4-lite as a Master and handles sending/recieving data.

## 📂 Folder Structure

* **mem_stage.v**
  RTL Verilog file implementing the MEM stage.

* **README.md**
  This documentation file.

## 🚀 Features

* Handles **load** and **store** instructions with byte, halfword, and word granularity.
* Passes and reads data according to the byte enable to/from the AXI4 Lite slaves
* Computes the value to forward to the Writeback stage.

## 📜 How It Works

### Ports

| Name                | Direction | Width | Description                              |
| ------------------- | --------- | ----- | ---------------------------------------- |
| `clk`               | input     | 1     | Clock signal                             |
| `rst`               | input     | 1     | Reset signal                             |
| `result`            | input     | 32    | ALU result / memory address              |
| `op2_data`          | input     | 32    | Data to store (for store instructions)   |
| `mem_write`         | input     | 1     | High to perform a write operation        |
| `store_type`        | input     | 2     | 00=SB, 01=SH, 10=SW                      |
| `load_type`         | input     | 3     | 000=LB, 001=LH, 010=LW, 011=LBU, 100=LHU |
| `read_data`         | output    | 32    | Data read from memory (to WB stage)      |
| `calculated_result` | output    | 32    | ALU result forwarded to WB stage         |

## 📌 Notes

* Compatible with 5-stage RV32IM pipeline.
* Supports byte/halfword/word loads and stores with proper sign/zero extension.

---

*Created by Talha Israr*
