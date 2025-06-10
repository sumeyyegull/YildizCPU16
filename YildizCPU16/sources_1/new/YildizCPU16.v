module YildizCPU16 (
    input         clk,
    input         rst,
    input         we_in,
    input         sel_in,
    input  [15:0] data_in,
    input  [11:0] adr_in,
    output [15:0] data_out, data_mem_in,

    // Test çıkışları
    output [15:0] tbDR,
    output [15:0] tbAC,
    output [15:0] tbIR,
    output [15:0] tbBus,
    output [11:0] tbAR,
    output [11:0] tbPC,
    output [127:0] tbRegs,
    output [11:0] tbSP,
    output [11:0] tbISR,
    output [3:0]  tbFLAGS,
    output [7:0]  tbINPR,
    output [7:0]  tbOUTPR,
    output        we_out
);

    // İç sinyaller
    wire        we;
    wire [15:0] from_mem, to_mem;
    wire [11:0] adr;
    wire [15:0] cpu_mem;
    wire        cpu_we;
    wire [11:0] cpu_adr;

    // Test sinyalleri
    wire [15:0] testDR, testAC, testIR, testBus;
    wire [11:0] testAR, testPC;
    wire [3:0]  testFLAGS;
    wire [7:0]  testINPR, testOUTPR;
    wire [127:0] regbank_flat;
    wire [11:0] sp_wire, isr_wire;

    // Bellek bağlantıları
    assign data_out = from_mem;
    assign we_out = we;
    assign data_mem_in=to_mem;

    // Test çıkışları
    assign tbDR    = testDR;
    assign tbAC    = testAC;
    assign tbIR    = testIR;
    assign tbBus   = testBus;
    assign tbAR    = testAR;
    assign tbPC    = testPC;
    assign tbFLAGS = testFLAGS;
    assign tbINPR  = testINPR;
    assign tbOUTPR = testOUTPR;
    assign tbRegs  = regbank_flat;
    assign tbSP    = sp_wire;
    assign tbISR   = isr_wire;

    // Multiplexer mantığı
    assign to_mem = (sel_in == 1'b1) ? data_in : cpu_mem;
    assign adr    = (sel_in == 1'b1) ? adr_in  : cpu_adr;
    assign we     = (sel_in == 1'b1) ? we_in   : cpu_we;

yildiz_cpu_16bit cpu (
    .clk(clk),
    .rst(rst),
    .from_memory(from_mem),
    .to_memory(cpu_mem),
    .address(cpu_adr),
    .write(cpu_we),
    .sel_in(sel_in),
    .testDR(testDR),
    .testAC(testAC),
    .testIR(testIR),
    .testAR(testAR),
    .testPC(testPC),
    .testBus(testBus),
    .testFLAGS(testFLAGS),
    .testINPR(testINPR),
    .testOUTPR(testOUTPR),
    .registers_out_flat(regbank_flat),
    .sp_out(sp_wire),
    .isr_out(isr_wire)
);



// RAM instantiation - 4096 x 16-bit
    ram_16bit #(
        .DATA_WIDTH(16),
        .ADDR_WIDTH(12)
    ) ram4096byte (
        .clk(clk),
        .we(we),
        .addr(adr),
        .din(to_mem),
        .dout(from_mem)
    );


endmodule
