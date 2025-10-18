# Testbench (TB) Folder

This folder contains the **verification testbenches** for the RISC-V core design.  
The goal of these tests is to validate both functionality and performance under different workloads.

The processor was tested using a variety of test assembly codes. To further test the processor real life examples were used. These can be found at [Example Programs](../programs/tests/examples) with their [Results](imgs/tests/programs).

---

## 📂 Test Categories

### 1. Branch Target Buffer (BTB) Stress Tests
- Validates the **BTB correctness** under frequent taken/not-taken branches.
- A variety of tests for different workloads are compared and presented below. The tests can be found at [Branch Target Buffer tests](../programs/tests/btb/).
- The improvement from using the Branch Target Buffer (BTB) is calculated as:

$$
\text{Improvement (\%)} = \frac{\text{Cycles without BTB} - \text{Cycles with BTB}}{\text{Cycles without BTB}} \times 100
$$

- The total number of cycles in simulation can be calculated using:

$$
\text{Total Cycles} = \frac{\text{Time of last write to register file} - \text{Time when reset is released}}{\text{Simulation clock period}}
$$

Where:

* **Time of last write to register file** = the timestamp in your simulation when the last instruction writes back to the register file.
* **Time when reset is released** = the simulation time when reset is deasserted.
* **Simulation clock period** = the time period of your clock in the testbench (e.g., 10 ns).

| Test               | Without BTB (Cycles) | With BTB (Cycles) | Improvement |
| ------------------ | -------------------- |------------------ |------------ |
| Forward Branch     |         45           |        33         |    26.7 %   |
| Long Forward Branch|         133          |        77         |    42.1 %   |
| Conditional Branch |         86           |        60         |    30.2 %   |
| Nested Branch      |         147          |        103        |    29.9 %   |
| Alternating Branch |         165          |        129        |    21.8 %   |

One such result can be seen below. The following test is of Long Forward Branch.
![Long Forward Branch without BTB](../imgs/tests/btb/long_forward_without_btb.png)

After using the BTB we get the following results. The BTB is connected and dis-connected by changing the `update` signal in btb inst in top module to btb_update or 0.

![Long Forward Branch with BTB](../imgs/tests/btb/long_forward_btb.png)

See [Results](../imgs/tests/btb/) for more results.

### 2. Multiplication Tests
- Covers **shift-and-add multiply** (software) and **hardware MUL instructions**.
- Covers **shift-and-sub divide** (software) and **hardware DIV/REM instructions**.
- The main tests can be found at [M Unit Tests](../programs/tests/m_unit/).
- The improvement from using the M unit is calculated as:

$$
\text{Improvement (\%)} = \frac{\text{Cycles worst case SW} - \text{Cycles worst case HW}}{\text{Cycles worst case SW}} \times 100
$$

- The total number of cycles in simulation can be calculated using:

$$
\text{Total Cycles} = \frac{\text{Time of write of MUL/DIV result in regfile} - \text{Time when reset is released}}{\text{Simulation clock period}}
$$

Where:

* **Time of write of MUL/DIV result in regfile** = the timestamp in your simulation when the mul/div result writes back to the register file.
* **Time when reset is released** = the simulation time when reset is deasserted.
* **Simulation clock period** = the time period of your clock in the testbench (e.g., 10 ns).

| Test         | SW Implementation | HW Extension | Improvement | Speedup |
| ------------ | ----------------- | ------------ | ----------- | ------- |
| Multiply     |        231        |      10      |    95.7 %   |  21.3x  |
| Divide       |        350        |      41      |    88.3 %   |  8.54x  |

One such result can be seen below. The following test is of Multiplication.
![Multiplication SW](../imgs/tests/m_unit/mul_sw.png)

Using the M instructions from M extension we get the same result but in much less cycles.

![Multiplication HW](../imgs/tests/m_unit/mul_hw.png)

See [Results](../imgs/tests/m_unit/) for more results.

### 3. Forwarding and Hazard Tests

- Forwarding Unit: Click on [Forwarding Test](../programs/basic_instructions/forwarding_test.s) to see the assembly code for the test.

![Forwarding Test](../imgs/tests/general/forwarding_test.png)

- Hazard Unit: The hazard unit is used in following 3 places all of which have been tested in the respective sections for each instruction
   - Load Stall
   - M Unit Stall
   - Jump/Branch Stall and Flush

### 4. General ISA & Functional Tests
The following contrains different test cases for different functional scenarios. The exact assembly code will also be available.

- ALU Edge Cases: Click on [ALU Edge](../programs/basic_instructions/alu_edgecases.s) to see the assembly code for the test.

![ALU Edge](../imgs/tests/general/alu_edge.png)

- Load-Store Tests: Click on [Load Store](../programs/basic_instructions/load_store_test.s) to see the assembly code for the test.

![ALU Edge](../imgs/tests/general/load_store.png)

- All instructions test: Click on [All Instructions](../programs/basic_instructions/all_instructions.s) to see the assembly code for the test.

![All Instructions](../imgs/tests/general/overall_test.png)
---

## Running Tests

To test different programs, use `programs/tests/` folder:

1. Copy or rename the desired test file into `programs/instructions.s`

   ```bash
   cp tests/alu_edgecases.s instructions.s
   ```
2. Rebuild:

   ```bash
   make clean
   make
   ```
3. Use the generated `instructions.hex` as your processor’s instruction memory.

4. Use the `rv32i_core_tb.sv` file for testbench and observe the results in the simulation waveform.

---

## 📌 Future Work

* Formal Verification using onespin and SVA
* UVM-based verification
* System Verilog automated testbenches

---

*Created by Talha Israr*
