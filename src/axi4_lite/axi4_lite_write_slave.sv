module axi4_lite_write_slave #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    // Input
    input logic                         clk,
    input logic                         rst,
    input logic                         slave_write_sel,

    output logic                        mem_write,
    output logic [3:0]                  byte_en,
    output logic [ADDR_WIDTH - 1 : 0]   addr,
    output logic [DATA_WIDTH - 1 : 0]   write_data,

    // AXI4-lite interface

    // WRIE ADDRESS CHANNEL
    input logic [ADDR_WIDTH - 1 : 0]    S_AXI_AWADDR,   // Write address
    input logic                         S_AXI_AWVALID,  // Write address valid
    output logic                        S_AXI_AWREADY,  // Slave ready to accept address

    // WRITE DATA CHANNEL
    input logic [DATA_WIDTH - 1 : 0]    S_AXI_WDATA,    // Write data
    input logic [3:0]                   S_AXI_WSTRB,    // Write data byte enable
    input logic                         S_AXI_WVALID,   // Write data is valid
    output logic                        S_AXI_WREADY,   // Slave ready to accept data

    // WRITE RESPONSE CHANNEL
    output logic [1:0]                  S_AXI_BRESP,    // Slave response - Unused here
    output logic                        S_AXI_BVALID,   // Write response valid from slave
    input logic                         S_AXI_BREADY    // Master ready to accept response
);

    typedef enum logic [1:0] {
        ST_IDLE         = 2'b00,
        ST_ADDR_PHASE   = 2'b01,
        ST_BRESP        = 2'b10
    } s_axi_write_states;

    s_axi_write_states current_state, next_state;

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
                next_state = (S_AXI_AWVALID && slave_write_sel) ? ST_ADDR_PHASE : ST_IDLE;

            ST_ADDR_PHASE:
                next_state = (S_AXI_AWVALID && S_AXI_WVALID) ? ST_BRESP : ST_ADDR_PHASE;

            ST_BRESP:
                next_state = S_AXI_BREADY ? ST_IDLE : ST_BRESP;

            default: next_state = ST_IDLE;
        endcase
    end

    // -------------------------
    // Write outputs
    always_comb begin
        S_AXI_AWREADY     = 0; 
        S_AXI_WREADY      = 0; 
        S_AXI_BVALID      = 0; 
        S_AXI_BRESP       = 0;
        mem_write   = 0; 
        byte_en     = 0; 
        addr        = 0; 
        write_data  = 0;

        case(current_state)
            ST_IDLE:       
                S_AXI_AWREADY = 1;

            ST_ADDR_PHASE: begin
                S_AXI_WREADY    = 1;
                S_AXI_AWREADY   = 1;
                mem_write       = 1;
                byte_en         = S_AXI_WSTRB;
                addr            = S_AXI_AWADDR;
                write_data      = S_AXI_WDATA;
            end

            ST_BRESP: 
                S_AXI_BVALID = 1;
        endcase
    end

endmodule
