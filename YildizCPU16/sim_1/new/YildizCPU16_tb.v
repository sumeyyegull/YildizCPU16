module YildizCPU16_tb;

    reg clk = 0, rst = 0;
    reg tb_we;
    reg [15:0] tb_data_in;
    reg [11:0] tb_adr;
    reg [7:0] tb_sel_in;
    
    reg [15:0] program[0:15];
    integer i;
    reg [11:0] row;

    wire [15:0] d_out, d_in;
    wire [15:0] r_dr, r_ac, r_ir, r_bus;
    wire [11:0] r_ar, r_pc, r_sp, r_isr;
    wire [127:0] r_regs;
    wire [3:0] r_flags;
    wire [7:0] r_inpr, r_outpr;
    wire tb_we_out;

    YildizCPU16 uut (
        .clk(clk),
        .rst(rst),
        .we_in(tb_we),
        .sel_in(tb_sel_in),
        .adr_in(tb_adr),
        .data_mem_in(d_in),
        .data_out(d_out),
        .data_in(tb_data_in),
        .tbDR(r_dr),
        .tbAC(r_ac),
        .tbIR(r_ir),
        .tbBus(r_bus),
        .tbAR(r_ar),
        .tbPC(r_pc),
        .tbRegs(r_regs),
        .tbSP(r_sp),
        .tbISR(r_isr),
        .tbFLAGS(r_flags),
        .tbINPR(r_inpr),
        .tbOUTPR(r_outpr),
        .we_out(tb_we_out)
    );

    // Clock üretimi
    always #10 clk = ~clk;

    initial begin
        // Program belleği içeriği
        program[0] = 16'h0A05;  // LDI #05
        program[1] = 16'h1250;  // ADDM 50h
        program[2] = 16'h1360;  // SUBM 60h
        program[3] = 16'h0E11;  // OUT
        program[4] = 16'h70FF;  // JMP 0FFFh
        program[5] = 16'hFFFF;  // Program sonu

        // İlk reset
        rst = 1;
        tb_we = 0;
        tb_sel_in = 0;
        tb_adr = 0;
        tb_data_in = 0;
        row = 12'h010;  // Program yükleme başlangıç adresi

        #50;
        rst = 0;  // Reset kaldır

        // Programı belleğe yazma
        tb_we = 1;
        tb_sel_in = 1;
        for (i = 0; i < 6; i = i + 1) begin
            tb_adr = row;
            tb_data_in = program[i];
            #20;
            row = row + 1;
        end

        // Veri yazımı
        tb_adr = 12'h050;
        tb_data_in = 16'h0007;
        #20;

        tb_adr = 12'h060;
        tb_data_in = 16'h0002;
        #20;

        tb_we = 0;
        tb_sel_in = 0;

        // Program çalışması için bekle
        tb_adr = 12'h010;  // Başlangıç adresi (program counter başlangıcı olabilir)
        #3000;

        $finish;
    end

endmodule
