module led(
    input clk,
    input rst,
    input [7:0] led_write,
    input write_enable,
    output logic [7:0] led_out
);
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            led_out <= '0;
        end else if (write_enable) begin
            led_out <= led_write; 
        end 
    end

endmodule