`timescale 1ns/1ps

module riscv_soc_top_tb;

    reg clk;
    reg rst;

    // Instantiate the core
    riscv_soc_top dut (
        .clk(clk),
        .rst(rst)
    );

    // Clock generation: 10ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test stimulus
    initial begin
        // Initialize reset
        rst = 1;
        #20;       // Hold reset for 20ns
        rst = 0;

        // Run simulation for 1700ns then finish
        #1700;
        $finish;
    end
endmodule
