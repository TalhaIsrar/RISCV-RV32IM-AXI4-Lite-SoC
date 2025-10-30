`timescale 1ns/1ps

module axi4_lite_peripheral_tb;

    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;
    parameter SLAVE_NUM  = 2;

    logic clk;
    logic rst;

    // Master signals
    logic write_start;
    logic [ADDR_WIDTH-1:0] write_addr;
    logic [DATA_WIDTH-1:0] write_data;
    logic [3:0] write_strobe;
    logic write_busy;

    logic read_start;
    logic [ADDR_WIDTH-1:0] read_addr;
    logic [DATA_WIDTH-1:0] read_data;
    logic read_busy;

    // Clock
    initial clk = 0;
    always #5 clk = ~clk; // 100 MHz

    // Reset
    initial begin
        rst = 1;
        #20;
        rst = 0;
    end

    // Instantiate Peripheral Interface
    axi4_lite_peripheral_top #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .SLAVE_NUM()
    ) axi_peripherls (
        .clk(clk),
        .rst(rst),

        .write_start(write_start),
        .write_addr(write_addr),
        .write_data(write_data),
        .write_strobe(write_strobe),
        .write_busy(write_busy),
        
        .read_start(read_start),
        .read_addr(read_addr),
        .read_data(read_data),
        .read_busy(read_busy)
    );


    // Task to perform read write
    task automatic axi_rw(
        input  logic [31:0] write_addr_i,
        input  logic [31:0] write_data_i,
        input  logic [3:0]  write_strobe_i,
        input  logic        write_start_i,
        input  logic [31:0] read_addr_i,
        input  logic        read_start_i
    );
        // Initialize signals
        if (write_start_i) begin
            write_addr   = write_addr_i;
            write_data   = write_data_i;
            write_strobe = write_strobe_i;
            write_start = 1;
        end else begin
            write_start = 0;
        end

        if (read_start_i) begin
            read_addr  = read_addr_i;
            read_start = 1;
        end else begin
            read_start = 0;
        end

        // Small delay to latch signals
        #10;
        write_start = 0;
        read_start  = 0;

        // Wait for write to complete if enabled
        if (write_start_i) wait(!write_busy);
        // Wait for read to complete if enabled
        if (read_start_i)  wait(!read_busy);

        @(negedge clk);

        // Display results
        if (write_start_i) $display("WRITE: Addr=0x%08h, Data=0x%08h", write_addr_i, write_data_i);
        if (read_start_i)  $display("READ : Addr=0x%08h, Data=0x%08h", read_addr_i, read_data);
        @(negedge clk);

    endtask


    // Test sequence
    initial begin

        // Reset
        write_start = 0;
        write_addr  = 0;
        write_data  = 0;
        write_strobe= 4'b1111;

        read_start  = 0;
        read_addr   = 0;

        #50;
        @(negedge clk);

        $display("Reset complete");

        // Write 0xAABBCCDD to address 0x04 (First slave)
        axi_rw(32'h04, 32'hAABBCCDD, 4'b1111, 1'b1, 32'h0, 1'b0);

        // Write 0xDDCBBBAA to address 0x104 (Second slave)
        axi_rw(32'h104, 32'hDDCBBBAA, 4'b1111, 1'b1, 32'h0, 1'b0);

        // Read address 0x104 (Second slave)
        axi_rw(32'h0, 32'h0, 4'b1111, 1'b0, 32'h104, 1'b1);

        // Read address 0x04 (First slave)
        axi_rw(32'h0, 32'h0, 4'b1111, 1'b0, 32'h04, 1'b1);

        // Write 0xABABABAB to address 0x108 (Second slave)
        axi_rw(32'h108, 32'hABABABAB, 4'b1111, 1'b1, 32'h0, 1'b0);

        // Write 0xDEADBEEF to 0x08 (First slave) and Read from 0x108 (Second slave)
        axi_rw(32'h08, 32'hDEADBEEF, 4'b1111, 1'b1, 32'h108, 1'b1);

        // Read address 0x08 (First slave)
        axi_rw(32'h0, 32'h0, 4'b1111, 1'b0, 32'h08, 1'b1);

        #50;
        $display("Finished");
        $finish;
    end

endmodule
