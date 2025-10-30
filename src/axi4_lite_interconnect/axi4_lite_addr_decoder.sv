module axi4_lite_addr_decoder #(
    parameter int ADDR_WIDTH = 32,
    parameter int SLAVE_NUM  = 2,
    parameter logic [ADDR_WIDTH-1:0] SLAVE_BASE_ADDR [SLAVE_NUM],
    parameter logic [ADDR_WIDTH-1:0] SLAVE_ADDR_MASK [SLAVE_NUM]    
)(
    input  logic [ADDR_WIDTH-1:0]           addr,
    output logic [SLAVE_NUM-1:0]            slave_sel  // One hot slave encoding
);

    integer i;
    always_comb begin
        slave_sel      = '0;
        for (i = 0; i < SLAVE_NUM; i++) begin
            if ((addr & SLAVE_ADDR_MASK[i]) == SLAVE_BASE_ADDR[i]) begin
                slave_sel[i] = 1'b1;
            end
        end
    end

endmodule