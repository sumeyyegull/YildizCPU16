module ram_16bit #(
    parameter DATA_WIDTH = 16,
    parameter ADDR_WIDTH = 12
)(
    input clk,
    input we,
    input [ADDR_WIDTH-1:0] addr,
    input [DATA_WIDTH-1:0] din,
    output [DATA_WIDTH-1:0] dout
);

    reg [DATA_WIDTH-1:0] bellek [0:(1<<ADDR_WIDTH)-1];

    always @(posedge clk) begin
        if (we)
            bellek[addr] <= din;
    end

    // HER ZAMAN OKUMA YAP
    assign dout = bellek[addr];

endmodule
