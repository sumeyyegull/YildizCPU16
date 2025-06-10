module alu(
    input [3:0] islem_in,        // 4-bit işlem kodu (OpCode)
    input [15:0] s1_in, s2_in,   // Giriş operandları
    output [15:0] s_out,         // ALU sonucu
    output [3:0] flags           // [N Z V C] bayrakları
);

    reg [15:0] sx;               // ALU çıkışı (işlem sonucu)
    reg [16:0] sy;               // Carry/taşma kontrolü için geniş bitli sonuç

    assign s_out = sx;

    // FLAGS [3:0] = [N Z V C]
    assign flags[3] = sx[15]; // N: Negatif (sonucun işaret biti)
    assign flags[2] = (sx == 16'b0); // Z: Zero
    assign flags[1] = ((s1_in[15] == s2_in[15]) && (sx[15] != s1_in[15]) &&
                       (islem_in == 4'b0000 || islem_in == 4'b0001)) ? 1'b1 : 1'b0; // V: Overflow (sadece ADD & SUB)
    assign flags[0] = sy[16]; // C: Carry

    always @(*) begin
        case (islem_in)
            4'b0000: begin // ADD
                sx = s1_in + s2_in;
                sy = {1'b0, s1_in} + {1'b0, s2_in};
            end
            4'b0001: begin // SUB
                sx = s1_in - s2_in;
                sy = {1'b0, s1_in} - {1'b0, s2_in};
            end
            4'b0010: begin // INC
                sx = s1_in + 1;
                sy = {1'b0, s1_in} + 17'd1;
            end
            4'b0011: begin // DEC
                sx = s1_in - 1;
                sy = {1'b0, s1_in} - 17'd1;
            end
            4'b0100: begin // AND
                sx = s1_in & s2_in;
                sy = 0;
            end
            4'b0101: begin // OR
                sx = s1_in | s2_in;
                sy = 0;
            end
            4'b0110: begin // XOR
                sx = s1_in ^ s2_in;
                sy = 0;
            end
            4'b0111: begin // NOT
                sx = ~s1_in;
                sy = 0;
            end
            4'b1000: begin // CMP
                sx = s1_in - s2_in;
                sy = {1'b0, s1_in} - {1'b0, s2_in};
            end
            default: begin
                sx = 16'b0;
                sy = 0;
            end
        endcase
    end
endmodule