module axi4_lite_read_master #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
) (
    // Input
    input logic                         clk,
    input logic                         rst,

    input logic                         read_start,
    input logic [ADDR_WIDTH - 1 : 0]    read_addr,

    output logic [DATA_WIDTH - 1 : 0]   read_data,
    output logic                        read_busy,

    // AXI4-lite interface

    // READ ADDRESS CHANNEL
    output logic [ADDR_WIDTH - 1 : 0]   M_AXI_ARADDR,   // Read address
    output logic                        M_AXI_ARVALID,  // Read address valid
    input logic                         M_AXI_ARREADY,  // Slave ready to accept address

    // READ DATA CHANNEL
    input logic [DATA_WIDTH - 1 : 0]    M_AXI_RDATA,    // Read data
    input logic [1:0]                   M_AXI_RRESP,    // Slave response
    input logic                         M_AXI_RVALID,   // Read data from slave is valid
    output logic                        M_AXI_RREADY    // Master is ready to accept data
);

    // Buffer input signals
    logic [ADDR_WIDTH - 1 : 0]    buf_read_addr;

    // Buffer signals
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            buf_read_addr      <= 0;
        end else begin
            if (read_start) begin
                buf_read_addr  <= read_addr;
            end
        end
    end

    typedef enum logic [1:0] {
        ST_IDLE         = 2'b00,
        ST_ADDR_PHASE   = 2'b01,
        ST_WAIT_RDATA   = 2'b10
    } m_axi_read_states;

    m_axi_read_states current_state, next_state;

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
                next_state = read_start ? ST_ADDR_PHASE : ST_IDLE;

            ST_ADDR_PHASE:
                next_state = M_AXI_ARREADY ? ST_WAIT_RDATA : ST_ADDR_PHASE;

            ST_WAIT_RDATA:
                next_state = M_AXI_RVALID ? ST_IDLE : ST_WAIT_RDATA;

            default: next_state = ST_IDLE;
        endcase
    end

    // Output logic
    always_comb begin
        // Default assignments for all signals
        read_busy     = 0;
        read_data     = 0;
        M_AXI_ARADDR  = 0;
        M_AXI_ARVALID = 0;
        M_AXI_RREADY  = 0;

        // Only override for states that are active
        // IDLE has all zeros so no need to write
        case (current_state)
            ST_ADDR_PHASE: begin
                read_busy     = 1;
                M_AXI_ARADDR  = buf_read_addr;
                M_AXI_ARVALID = 1;
            end
            ST_WAIT_RDATA: begin
                read_busy    = 1;
                M_AXI_RREADY = 1;
            end
        endcase
    end

    // Buffer the output data
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            read_data      <= 0;
        end else begin
            if (M_AXI_RVALID) begin
                read_data  <= M_AXI_RDATA;
            end
        end
    end

endmodule