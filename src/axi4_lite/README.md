## 🧩 AXI4-Lite Master / Slave Subsystem

This folder contains synthesizable SystemVerilog implementations of the **AXI4-Lite master and slave interfaces** used to connect the memory stage of the RISC-V processor to memory-mapped peripherals through the AXI4-Lite interconnect.

Both the master and slave modules are compliant with the **AMBA AXI4-Lite specification**, supporting independent read and write channels with handshake signaling (`VALID` / `READY`).

---

## 📂 File Overview

| File                        | Description                                                                                                 |
| --------------------------- | ----------------------------------------------------------------------------------------------------------- |
| `axi4_lite_master.sv`       | Unified top-level AXI4-Lite master that integrates both read and write master logic.                        |
| `axi4_lite_write_master.sv` | Implements the **write channel FSM** responsible for address, data, and response handshakes.                |
| `axi4_lite_read_master.sv`  | Implements the **read channel FSM** responsible for issuing read requests and handling read data.           |
| `axi4_lite_slave.sv`        | Unified top-level AXI4-Lite slave module integrating both read and write slave logic for peripheral access. |
| `axi4_lite_write_slave.sv`  | Handles write transactions from the master — latching address/data and generating write responses.          |
| `axi4_lite_read_slave.sv`   | Handles read transactions — responding with data from memory or peripheral registers.                       |

---

## ⚙️ AXI4-Lite Signal Description

The AXI4-Lite interface consists of five independent channels:
two for write, two for read, and one for write response.

<img src="../../imgs/axi4_lite/axi4lite_channels.png" width="500">
*(Diagram source: [All about circuits: Introduction to the Advanced Extensible Interface (AXI)](https://www.allaboutcircuits.com/technical-articles/introduction-to-the-advanced-extensible-interface-axi/))*  


| Channel            | Signal    | Direction      | Description                                              |
| ------------------ | --------- | -------------- | -------------------------------------------------------- |
| **Read Address**   | `ARADDR`  | Master → Slave | Read address for the transaction.                        |
|                    | `ARVALID` | Master → Slave | Indicates a valid read address.                          |
|                    | `ARREADY` | Slave → Master | Indicates the slave is ready to accept the read address. |
| **Read Data**      | `RDATA`   | Slave → Master | Data returned from the slave.                            |
|                    | `RRESP`   | Slave → Master | Read response status.                                    |
|                    | `RVALID`  | Slave → Master | Indicates valid read data is available.                  |
|                    | `RREADY`  | Master → Slave | Master ready to accept read data.                        |
| **Write Address**  | `AWADDR`  | Master → Slave | Write address for the transaction.                       |
|                    | `AWVALID` | Master → Slave | Indicates a valid write address is available.            |
|                    | `AWREADY` | Slave → Master | Indicates the slave is ready to accept the address.      |
| **Write Data**     | `WDATA`   | Master → Slave | Write data bus.                                          |
|                    | `WSTRB`   | Master → Slave | Byte-enable signals (1 bit per byte).                    |
|                    | `WVALID`  | Master → Slave | Indicates valid write data.                              |
|                    | `WREADY`  | Slave → Master | Indicates slave is ready to accept data.                 |
| **Write Response** | `BRESP`   | Slave → Master | Response status (`OKAY`, `SLVERR`, etc.).                |
|                    | `BVALID`  | Slave → Master | Indicates valid response.                                |
|                    | `BREADY`  | Master → Slave | Master ready to accept response.                         |

---

## 🧠 FSM Overview

### 📝 Master FSMs

The AXI4-Lite master implements separate finite-state machines for read and write operations, ensuring proper sequencing and handshaking with the slave.

![AXI4Lite Master FSM](../../imgs/axi4_lite/axi4lite_master.png)

### 🧱 Slave FSMs

The AXI4-Lite slave logic is split into two independent FSMs for read and write channels, allowing concurrent read and write transactions.

![AXI4Lite Slave FSM](../../imgs/axi4_lite/axi4lite_slave.png)

---

## 🧩 Integration Notes

* This master module connects to the **memory stage** of the RISC-V core and communicates through the **AXI4-Lite Interconnect** located in `axi4_lite_interconnect/` folder.
* Each slave instance typically wraps around a peripheral module or memory block.
* Both master and slave support **independent read/write transactions**, though AXI4-Lite does not allow burst transfers.

---

## 📘 Related Modules

| Directory                 | Description                                                                          |
| ------------------------- | ------------------------------------------------------------------------------------ |
| `axi4_lite_interconnect/` | Multi-slave address-decoding interconnect connecting one master to multiple slaves.  |
| `peripherals/`            | Peripheral implementations connected to the slaves (e.g., data memory, UART, timer). |

## 📄 License

This project is released under the MIT License.

---

## 🤝 Contributions

Contributions, suggestions, and issue reports are welcome! Feel free to fork and open pull requests.

---

*Created by Talha Israr*  