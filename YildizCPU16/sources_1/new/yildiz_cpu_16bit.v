module yildiz_cpu_16bit (
    input clk, rst, sel_in,
    input [15:0] from_memory,
    output [15:0] to_memory,
    output [11:0] address,
    output write,
    
    // Test çıkışları
    output [15:0] testDR, testAC, testIR, testBus,
    output [11:0] testAR, testPC,
    output [3:0]  testFLAGS,
    output [7:0]  testINPR, testOUTPR,
    output [127:0] registers_out_flat, // R0-R7: 8×16 = 128 bit düzleştirilmiş çıktı
    output [11:0] sp_out, isr_out
);

    // Ara sinyaller
    wire IR_Load, DR_Load, PC_Load, AR_Load, AC_Load, FLAGS_Load;
    wire DR_Inc, AC_Inc, PC_Inc;
    wire [3:0] alu_sel;
    wire [2:0] bus_sel;

    // Register bankası yazma kontrolü
    wire [3:0]  rb_write_sel;
    wire reg_we;
    wire [15:0] rb_data1, rb_data2;

    // Bellek arabirim sinyalleri
    wire [15:0] to_mem;
    wire [11:0] adr;
    wire write_en;

    // Test amaçlı iç sinyaller
    wire [15:0] tDR, tAC, tIR, tBus;
    wire [11:0] tAR, tPC;
    wire [3:0] FLAGS_Value;
    wire [15:0] IR_Value;

    // Bellek arabirimi çıkışları
    assign to_memory = to_mem;
    assign address   = adr;
    assign write     = write_en;

    // Test gözlemleme sinyalleri
    assign testDR    = tDR;
    assign testAC    = tAC;
    assign testIR    = tIR;
    assign testBus   = tBus;
    assign testAR    = tAR;
    assign testPC    = tPC;
    assign testFLAGS = FLAGS_Value;
    assign testINPR  = 8'b0;
    assign testOUTPR = 8'b0;

    // Kontrol Ünitesi
    control_unit control (
        .clk(clk),
        .rst(rst),
        .IR_Value(tIR),
        .FLAGS_Value(FLAGS_Value),
        .IR_Load(IR_Load),
        .DR_Load(DR_Load),
        .PC_Load(PC_Load),
        .AR_Load(AR_Load),
        .AC_Load(AC_Load),
        .FLAGS_Load(FLAGS_Load),
        .DR_Inc(DR_Inc),
        .AC_Inc(AC_Inc),
        .PC_Inc(PC_Inc),
        .alu_sel(alu_sel),
        .bus_sel(bus_sel),
        .reg_we(reg_we),
        .reg_write_sel(rb_write_sel),
        .write_en(write_en),
        .sel_in(sel_in)
        
        
    );

    // Register Bank
    register_bank regbank_inst (
        .clk(clk),
        .rst(rst),
        .read_sel1(4'd0),  // İsteğe bağlı: bağlamıyorsan dummy değer ver
        .read_sel2(4'd0),
        .write_sel(rb_write_sel),  // yazılacak reg secimi
        .write_en(reg_we),
        .write_data(tBus),
        .read_data1(rb_data1),  //okunan veri1
        .read_data2(rb_data2),  //okunan veri2
        .regs_out_flat(registers_out_flat),
        .sp_out(sp_out),
        .isr_out(isr_out)
    );

    // Veri Yolu (Data Path)
    data_path datapath (
        .clk(clk),
        .rst(rst),
        .IR_Load(IR_Load),
        .DR_Load(DR_Load),
        .PC_Load(PC_Load),
        .AR_Load(AR_Load),
        .AC_Load(AC_Load),
        .FLAGS_Load(FLAGS_Load),
        .DR_Inc(DR_Inc),
        .AC_Inc(AC_Inc),
        .PC_Inc(PC_Inc),
        .alu_sel(alu_sel),
        .bus_sel(bus_sel),
        .from_memory(from_memory),
        .to_memory(to_mem),
        .address(adr),
        .IR_Value(IR_Value),
        .FLAGS_Value(FLAGS_Value),
        .tDR(tDR),
        .tAC(tAC),
        .tIR(tIR),
        .tAR(tAR),
        .tPC(tPC),
        .tBus(tBus),
        .rb_data1(rb_data1),
        .rb_data2(rb_data2)
       
    );

endmodule
