module uart_transmit #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input  logic clk,
    input  logic rst,
    input  logic [ADDR_WIDTH-1:0] addr,
    input  logic [DATA_WIDTH-1:0] wdata,
    input  logic write,
    output logic [DATA_WIDTH-1:0] rdata
);

    // Transmit buffer
    logic ready;
    always_ff @(posedge clk) begin
        if(rst)
            ready <= 1;
        else if(write) begin
            case(uart_addr)
                32'h0: $write("%c", wdata[7:0]); // TXDATA
                default: ;
            endcase
            ready <= 0;
        end else
            ready <= 1;
    end

    assign rdata = (uart_addr == 32'h4) ? {31'b0, ready} : 32'b0;

endmodule
