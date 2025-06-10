module register_bank (
    input wire clk,
    input wire rst,

    input wire [3:0] read_sel1, // R0-R7 veya SP/ISR seçimi
    input wire [3:0] read_sel2,
    input wire [3:0] write_sel,
    input wire write_en,
    input wire [15:0] write_data,

    output wire [15:0] read_data1,
    output wire [15:0] read_data2,
    output wire [127:0] regs_out_flat, // R0-R7 tek bir 128-bit çıkışta düzleştirilmiş
    output wire [11:0] sp_out,
    output wire [11:0] isr_out
);

    // 8 adet genel amaçlı register (R0 - R7)
    reg [15:0] registers [7:0];

    // Özel registerlar
    reg [11:0] SP;   // Stack Pointer
    reg [11:0] ISR;  // Interrupt Service Register

    integer i;

    // Register yazma ve reset işlemi
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 8; i = i + 1)
                registers[i] <= 16'd0;
            SP  <= 12'd0;
            ISR <= 12'd0;
        end else if (write_en) begin
            case (write_sel)
                4'd0, 4'd1, 4'd2, 4'd3, 4'd4, 4'd5, 4'd6, 4'd7:
                    registers[write_sel] <= write_data;
                4'd8: SP  <= write_data[11:0];
                4'd9: ISR <= write_data[11:0];
                default: ; // geçersiz seçim, işlem yapılmaz
            endcase
        end
    end

    // Register okuma işlemleri
    assign read_data1 = (read_sel1 < 8) ? registers[read_sel1] :
                        (read_sel1 == 8) ? {4'd0, SP} :
                        (read_sel1 == 9) ? {4'd0, ISR} :
                        16'd0;

    assign read_data2 = (read_sel2 < 8) ? registers[read_sel2] :
                        (read_sel2 == 8) ? {4'd0, SP} :
                        (read_sel2 == 9) ? {4'd0, ISR} :
                        16'd0;

    // R0-R7'yi düzleştirme (flatten)
    genvar j;
    generate
        for (j = 0; j < 8; j = j + 1) begin : flatten
            assign regs_out_flat[j*16 +: 16] = registers[j];
        end
    endgenerate

    // SP ve ISR çıkışları
    assign sp_out  = SP;
    assign isr_out = ISR;

endmodule
