## 🧩 AXI4-Lite Interconnect Subsystem

This directory contains a **modular and scalable AXI4-Lite interconnect** designed for the **RISC-V SoC** project.
It connects a **single AXI4-Lite master** (the RISC-V CPU’s memory stage) to **multiple memory-mapped slave peripherals** such as on-chip memory, GPIO, or UART.

This subsystem forms the backbone of peripheral communication in the SoC, allowing simple, low-latency register-based access through a standardized bus interface. This module is built with the help of axi-lite master-slave interfaces given at [axi4_lite](../axi4_lite/).

---

### 🧭 Interconnect Block Diagram

Below is the visual overview of the interconnect architecture:

![AXI4-Lite Interconnect Diagram](../../imgs/axi4_lite/axi4lite_interconnect.png)

---

### 📂 Folder Contents

| File                            | Description                                                                                                                         |
| ------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| **`axi4_lite_if.sv`**           | Defines the reusable AXI4-Lite interface bundle, grouping all read/write channel signals.                                           |
| **`axi4_lite_addr_decoder.sv`** | Implements one-hot address decoding logic to select the correct slave based on address ranges.                                      |
| **`axi4_lite_addr_map_pkg.sv`** | Central package defining all slave base addresses and masks — easily extendable for new peripherals.                                |
| **`axi4_lite_interconnect.sv`** | Top-level interconnect that routes signals between the master and multiple slaves, performs address decoding, and merges responses. |

---

### 🧠 Concept Overview

The **AXI4-Lite Interconnect** serves as the communication hub between the RISC-V processor core and its peripherals.
It is:

* **Configurable** – Supports any number of slaves via the `SLAVE_NUM` parameter.
* **Modular** – Cleanly separated into decoding, routing, and response logic.
* **Expandable** – Add new slaves by simply updating the address map package and array connections.

Each slave is **memory-mapped**, enabling easy peripheral access through standard load/store instructions.

---

### 🗺️ Example Address Map

Defined in `axi4_lite_addr_map_pkg.sv`:

```systemverilog
localparam logic [ADDR_WIDTH - 1 : 0] SLAVE_BASE_ADDR [SLAVE_NUM] = '{
    32'h0000_0000, // Memory
    32'h0000_0100, // Memory
    32'h0000_1000  // LED
};

localparam logic [ADDR_WIDTH - 1 : 0] SLAVE_ADDR_MASK [SLAVE_NUM] = '{
    32'hFFFF_FF00, // 1KB region
    32'hFFFF_FF00, // 1KB region
    32'hFFFF_FFFF  // Single register
};
```

Adding a new peripheral (e.g., a **Timer or SPI**) is as simple as:

1. Increasing `SLAVE_NUM`
2. Appending its base address and mask in the package
3. Instantiating its slave interface in the AXI4Lite peripheral top module

---

### 🧩 System Overview

#### 🔹 Interconnect Functionality

1. **Address Decoder** – Determines which slave should respond to the transaction.
2. **Signal Router** – Forwards the master’s read/write signals only to the selected slave.
3. **Response Multiplexer** – Merges the active slave’s response (`BRESP`, `RRESP`, `RDATA`) back to the master.
4. **Scalability** – Parameterized and easily expandable for future peripherals or additional address regions.

---

### 🧱 Integration Example

```systemverilog
axi4_lite_if #(32, 32) master_if();
axi4_lite_if #(32, 32) slave_if [3] ();

axi4_lite_interconnect #(
    .ADDR_WIDTH(32),
    .DATA_WIDTH(32),
    .SLAVE_NUM(3),
    .SLAVE_BASE_ADDR(axi4_lite_addr_map_package::SLAVE_BASE_ADDR),
    .SLAVE_ADDR_MASK(axi4_lite_addr_map_package::SLAVE_ADDR_MASK)
) interconnect (
    .clk(clk),
    .rst(rst),
    .master_if(master_if),
    .slave_if(slave_if)
);
```

---

### 🧮 Channel Signal Reference

| Channel            | Signal    | Direction      | Description                     |
| ------------------ | --------- | -------------- | ------------------------------- |
| **Write Address**  | `AWADDR`  | Master → Slave | Write transaction address       |
|                    | `AWVALID` | Master → Slave | Address valid handshake         |
|                    | `AWREADY` | Slave → Master | Slave ready to accept address   |
| **Write Data**     | `WDATA`   | Master → Slave | Write data bus                  |
|                    | `WSTRB`   | Master → Slave | Byte-level write strobe         |
|                    | `WVALID`  | Master → Slave | Data valid handshake            |
|                    | `WREADY`  | Slave → Master | Slave ready for write data      |
| **Write Response** | `BRESP`   | Slave → Master | Write completion status         |
|                    | `BVALID`  | Slave → Master | Response valid                  |
|                    | `BREADY`  | Master → Slave | Master ready to accept response |
| **Read Address**   | `ARADDR`  | Master → Slave | Read transaction address        |
|                    | `ARVALID` | Master → Slave | Address valid handshake         |
|                    | `ARREADY` | Slave → Master | Slave ready to accept address   |
| **Read Data**      | `RDATA`   | Slave → Master | Read data bus                   |
|                    | `RRESP`   | Slave → Master | Read response status            |
|                    | `RVALID`  | Slave → Master | Data valid handshake            |
|                    | `RREADY`  | Master → Slave | Master ready to accept data     |

---

### 🏗️ Future Enhancements

* 🔄 Multi-master support with **round-robin arbitration**
* 🧮 Add **error response generation** for unmapped addresses
* 🧱 Bridge to **AXI4** or **APB** for mixed peripheral buses
* 📈 Support for **dynamic address remapping**

---

## 📄 License

This project is released under the MIT License.

---

## 🤝 Contributions

Contributions, suggestions, and issue reports are welcome! Feel free to fork and open pull requests.

---

*Created by Talha Israr*  
