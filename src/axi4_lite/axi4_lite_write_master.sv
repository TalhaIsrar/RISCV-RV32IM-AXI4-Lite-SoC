module axi4_lite_write_master #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
) (
    // Input
    input logic                         clk,
    input logic                         rst,

    input logic                         write_start,
    input logic [ADDR_WIDTH - 1 : 0]    write_addr,
    input logic [DATA_WIDTH - 1 : 0]    write_data,
    input logic [3:0]                   write_strobe,

    output logic                        write_busy,

    // AXI4-lite interface

    // WRIE ADDRESS CHANNEL
    output logic [ADDR_WIDTH - 1 : 0]   M_AXI_AWADDR,   // Write address
    output logic                        M_AXI_AWVALID,  // Write address valid
    input logic                         M_AXI_AWREADY,  // Slave ready to accept address

    // WRITE DATA CHANNEL
    output logic [DATA_WIDTH - 1 : 0]   M_AXI_WDATA,    // Write data
    output logic [3:0]                  M_AXI_WSTRB,    // Write data byte enable
    output logic                        M_AXI_WVALID,   // Write data is valid
    input logic                         M_AXI_WREADY,   // Slave ready to accept data

    // WRITE RESPONSE CHANNEL
    input logic [1:0]                   M_AXI_BRESP,    // Slave response - Unused here
    input logic                         M_AXI_BVALID,   // Write response valid from slave
    output logic                        M_AXI_BREADY    // Master ready to accept response
);

    // Buffer input signals
    logic [ADDR_WIDTH - 1 : 0]    buf_write_addr;
    logic [DATA_WIDTH - 1 : 0]    buf_write_data;
    logic [3:0]                   buf_write_strobe;

    // Buffer signals
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            buf_write_addr      <= 0;
            buf_write_data      <= 0;
            buf_write_strobe    <= 0;
        end else begin
            if (write_start) begin
                buf_write_addr     <= write_addr;
                buf_write_data     <= write_data;
                buf_write_strobe   <= write_strobe;
            end
        end
    end

    typedef enum logic [1:0] {
        ST_IDLE         = 2'b00,
        ST_ADDR_PHASE   = 2'b01,
        ST_WAIT_BRESP   = 2'b10
    } m_axi_write_states;

    m_axi_write_states current_state, next_state;

    // State Register
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= ST_IDLE;
        end else begin
            current_state <= next_state;
        end 
    end

    // Next State Logic
    always_comb begin : NEXT_STATE_LOGIC
        case (current_state) 
            ST_IDLE: 
                next_state = write_start ? ST_ADDR_PHASE : ST_IDLE;

            ST_ADDR_PHASE:
                next_state = (M_AXI_AWREADY & M_AXI_WREADY) ? ST_WAIT_BRESP : ST_ADDR_PHASE;

            ST_WAIT_BRESP:
                next_state = M_AXI_BVALID ? ST_IDLE : ST_WAIT_BRESP;

            default: next_state = ST_IDLE;
        endcase
    end

    // Output logic
    always_comb begin
        // Default assignments for all signals
        write_busy    = 0;
        M_AXI_AWADDR  = 0;
        M_AXI_AWVALID = 0;
        M_AXI_WDATA   = 0;
        M_AXI_WVALID  = 0;
        M_AXI_WSTRB   = 0;
        M_AXI_BREADY  = 0;

        // Only override for states that are active
        // IDLE has all zeros so no need to write
        case (current_state)
            ST_ADDR_PHASE: begin
                write_busy    = 1;
                M_AXI_AWADDR  = buf_write_addr;
                M_AXI_AWVALID = 1;
                M_AXI_WVALID  = 1;
                M_AXI_WDATA   = buf_write_data;
                M_AXI_WSTRB   = buf_write_strobe;
            end
            ST_WAIT_BRESP: begin
                write_busy   = 1;
                M_AXI_BREADY = 1;
            end
        endcase
    end


endmodule