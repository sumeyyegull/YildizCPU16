module data_path (
    input clk, rst,                             // Saat ve reset sinyalleri

    input IR_Load, DR_Load, PC_Load, AR_Load, AC_Load, FLAGS_Load,  // Register yükleme kontrol sinyalleri
    input DR_Inc, AC_Inc, PC_Inc,             // Register arttırma kontrol sinyalleri
    input [3:0] alu_sel,                       // ALU işlem seçici
    input [2:0] bus_sel,                       // Veriyolu seçim sinyali

    input [15:0] from_memory,                  // Bellekten gelen veri
                 
    output [15:0] to_memory,                   // Belleğe yazılacak veri
    output [11:0] address,                     // Bellek adresi (AR'den)

    output [15:0] IR_Value,                     // IR içeriği (debug)
    output [3:0] FLAGS_Value,                   // Bayraklar (debug)

    output [15:0] tDR, tAC, tIR, tBus,         // Test çıkışları (register ve bus değerleri)
    output [11:0] tAR, tPC,
    
    input [15:0] rb_data1,                      // Register bank verisi 1
    input [15:0] rb_data2,                      // Register bank verisi 2
    output [15:0] bus                           // Veri yolu çıkışı
);

    // Dahili registerlar
    reg [15:0] IR, DR, AC;                      // Komut, veri ve akümülatör registerları
    reg [11:0] AR, PC;                          // Adres registerı ve program sayacı
    reg [3:0] FLAGS;                            // Durum bayrakları

    wire [15:0] alu_out;                        // ALU çıkışı
    // Veriyolu seçimi: bus_sel sinyaline göre kaynaktan veri alır
    assign bus = (bus_sel == 3'b000) ? rb_data1 :
             (bus_sel == 3'b001) ? rb_data2 :
             (bus_sel == 3'b010) ? from_memory :
             (bus_sel == 3'b011) ? {4'd0, PC} :
             (bus_sel == 3'b100) ? DR :
             (bus_sel == 3'b101) ? AC :
             16'd0;
                                // Hiçbiri değilse yine sabit 0 → default değer

    // Bellek arayüzü
    assign to_memory = bus;                     // Belleğe yazılacak veri bus'tan
    assign address = AR;                        // Bellek adresi AR'dan

    // Test çıkışları (debug için register ve bus değerleri)
    assign tDR = DR;
    assign tAC = AC;
    assign tIR = IR;
    assign tAR = AR;
    assign tPC = PC;
    assign tBus = bus;
    assign IR_Value = IR;
    assign FLAGS_Value = FLAGS;

    // IR registerı: reset sıfırlar, IR_Load sinyaliyle veriyoldan yüklenir
    always @(posedge clk or posedge rst) begin
        if (rst)
            IR <= 16'd0;
        else if (IR_Load)
            IR <= bus;
    end

    // DR registerı: reset sıfırlar, DR_Load ile yüklenir, DR_Inc ile 1 artırılır
    always @(posedge clk or posedge rst) begin
        if (rst)
            DR <= 16'd0;
        else if (DR_Load)
            DR <= bus;
        else if (DR_Inc)
            DR <= DR + 1;
    end

    // AC registerı: reset sıfırlar, AC_Load ile ALU çıkışı yüklenir, AC_Inc ile 1 artırılır
    always @(posedge clk or posedge rst) begin
        if (rst)
            AC <= 16'd0;
        else if (AC_Load)
            AC <= alu_out;
        else if (AC_Inc)
            AC <= AC + 1;
    end

    // AR registerı: reset sıfırlar, AR_Load ile veriyolunun alt 12 biti yüklenir
    always @(posedge clk or posedge rst) begin
        if (rst)
            AR <= 12'd0;
        else if (AR_Load)
            AR <= bus[11:0];
    end

    // PC registerı: reset sıfırlar, PC_Load ile yüklenir, PC_Inc ile 1 artırılır
    always @(posedge clk or posedge rst) begin
        if (rst)
            PC <= 12'd0;
        else if (PC_Load)
            PC <= bus[11:0];
        else if (PC_Inc)
            PC <= PC + 1;
    end

    // FLAGS registerı: reset sıfırlar, FLAGS_Load ile ALU sonuçlarına göre güncellenir
   always @(posedge clk or posedge rst) begin       // Saatin pozitif kenarında veya reset durumunda çalışır
    if (rst)
        FLAGS <= 4'b0000;                        // Reset durumunda tüm bayraklar sıfırlanır
    else if (FLAGS_Load) begin                   // Eğer bayraklar güncellenmek isteniyorsa
        FLAGS[0] <= (alu_out == 16'd0);          // Zero flag: ALU sonucu 0 ise 1 olur (Z)
        FLAGS[1] <= alu_out[15];                 // Negative flag: ALU sonucu negatifse (MSB=1) 1 olur (N)
        FLAGS[2] <= ^{AC[15], DR[15], alu_out[15]}; // Overflow flag: İşaretli taşma kontrolü (AC, DR, sonuç MSB XOR'u) (V)
        FLAGS[3] <= alu_out[15];                 // Carry/Sign flag: MSB'ye bakılarak ayarlanır (örnek kullanım; gerçek carry değil) (C/S)
    end
end


    // ALU modülü: AC ve DR registerlarından gelen verilerle işlem yapar
    alu alu_uut (
        .s1_in(AC),          // ALU operand 1
        .s2_in(DR),          // ALU operand 2
        .islem_in(alu_sel),  // ALU işlem seçici
        .s_out(alu_out)      // ALU sonucu
    );

endmodule
