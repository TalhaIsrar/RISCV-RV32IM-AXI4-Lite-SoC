module axi4_lite_read_slave #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    // Input
    input logic                         clk,
    input logic                         rst,

    input logic [DATA_WIDTH - 1 : 0]    read_data,
    input                               data_valid,
    output logic [ADDR_WIDTH - 1 : 0]   addr,

    // AXI4-lite interface

    // READ ADDRESS CHANNEL
    input logic [ADDR_WIDTH - 1 : 0]    S_AXI_ARADDR,   // Read address
    input logic                         S_AXI_ARVALID,  // Read address valid
    output logic                        S_AXI_ARREADY,  // Slave ready to accept address

    // READ DATA CHANNEL
    output logic [DATA_WIDTH - 1 : 0]   S_AXI_RDATA,    // Read data
    output logic [1:0]                  S_AXI_RRESP,    // Slave response
    output logic                        S_AXI_RVALID,   // Read data from slave is valid
    input logic                         S_AXI_RREADY    // Master is ready to accept data
);

    // Internal data buffer
    logic [DATA_WIDTH - 1 : 0]    data_buf;

    typedef enum logic [1:0] {
        ST_IDLE       = 2'b00,
        ST_WAIT_DATA  = 2'b01,
        ST_SEND_DATA  = 2'b10
    } s_axi_read_states;

    s_axi_read_states current_state, next_state;

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
                next_state = S_AXI_ARVALID ? ST_WAIT_DATA : ST_IDLE;

            ST_WAIT_DATA:
                next_state = data_valid ? ST_SEND_DATA : ST_WAIT_DATA;

            ST_SEND_DATA:
                next_state = S_AXI_RREADY ? ST_IDLE : ST_SEND_DATA;

            default: next_state = ST_IDLE;
        endcase
    end

    // -------------------------
    // Write outputs
    always_comb begin
        S_AXI_ARREADY     = 0; 
        S_AXI_RDATA       = 0; 
        S_AXI_RRESP       = 0; 
        S_AXI_RVALID      = 0;

        case(current_state)
            ST_IDLE:       
                S_AXI_ARREADY = 1;

            ST_SEND_DATA: begin
                S_AXI_RVALID    = 1;
                S_AXI_RDATA     = read_data;
            end
        endcase
    end

    // Buffer the address and data
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            addr      <= 0;
        end else begin
            if (S_AXI_ARVALID) begin
                addr  <= S_AXI_ARADDR;
            end

            if (data_valid) begin
                data_buf <= read_data;
            end
        end
    end

endmodule
