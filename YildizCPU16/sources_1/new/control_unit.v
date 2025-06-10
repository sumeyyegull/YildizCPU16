//16 bitlik CPU veriyollu
// Sadece SUBM, ADDM, SUB (register), LDA #imm, INC komutlarını destekleyen bir control_unit

module control_unit(
    input clk,sel_in,
    input rst,
    input [15:0] IR_Value,
    input [3:0] FLAGS_Value,
    output reg IR_Load, DR_Load, PC_Load, AR_Load, AC_Load,FLAGS_Load,
    output reg AC_Inc, PC_Inc, write_en, DR_Inc,
    output reg [3:0] alu_sel, 
    output reg [2:0] bus_sel, 
     output reg [3:0] reg_sel,         // ALU'ya veri verecek kaynak register (src)
    output reg [3:0] reg_write_sel,   // Yazma hedefi (dest)
    output reg reg_we          // Register'a yazma enable
);

    reg [7:0] current_state, next_state;

    // Genel FSM Durumlari
    localparam [7:0]
        S_FETCH_0 = 8'd0,
        S_FETCH_1 = 8'd1,
        S_FETCH_2 = 8'd2,
        S_DECODE_3 = 8'd3,

        // SUBM $addr
        S_SUBM_4 = 8'd10,
        S_SUBM_5 = 8'd11,
        S_SUBM_6 = 8'd12,
        S_SUBM_7 = 8'd13,
        S_SUBM_8 = 8'd14,
        S_SUBM_9 = 8'd15,

        // ADDM $addr
        S_ADDM_4 = 8'd20,
        S_ADDM_5 = 8'd21,
        S_ADDM_6 = 8'd22,
        S_ADDM_7 = 8'd23,
        S_ADDM_8 = 8'd24,
        S_ADDM_9 = 8'd25,

        // SUB Rx
        S_SUBR_4 = 8'd30,
        S_SUBR_5 = 8'd31,
        S_SUBR_6 = 8'd32,

        // LDA #imm
        S_LDAI_4 = 8'd40,
        S_LDAI_5 = 8'd41,
        S_LDAI_6 = 8'd42,
        S_LDAI_7 = 8'd43,

        // INC
        S_INC_4 = 8'd50,
        S_INC_5 = 8'd51;

    // Komutlar ------ IR_Value değeri ile gelecek ----------

 localparam [5:0]
    OPCODE_SUBM = 6'b100011,
    OPCODE_ADDM = 6'b100010,
    OPCODE_SUBR = 6'b000001,
    OPCODE_LDAI = 6'b010010,
    OPCODE_INC  = 6'b010111;

    
  // ALU işlemleri
    localparam [3:0]
        ALU_ADD = 4'b0000,
        ALU_SUB = 4'b0001;


    // Geçiş: state logic
    always @(posedge clk) begin
        if (rst==1'b0) begin
           current_state <= S_FETCH_0;
           end
        else begin current_state <= next_state;
    end
    end

     // next state logic, sonraki durum güncellemesi
    always @(*) begin
        case (current_state)
            S_FETCH_0: next_state = S_FETCH_1;
            S_FETCH_1: next_state = S_FETCH_2;
            S_FETCH_2: next_state = S_DECODE_3;

            S_DECODE_3:
                case (IR_Value[15:10]) // İlk 6 bit opcode
                    OPCODE_SUBM: next_state = S_SUBM_4;
                    OPCODE_ADDM: next_state = S_ADDM_4;
                    OPCODE_SUBR: next_state = S_SUBR_4;
                    OPCODE_LDAI: next_state = S_LDAI_4;
                    OPCODE_INC:  next_state = S_INC_4;
                    default:     next_state = S_FETCH_0;
                endcase

            // SUBM FSM
            S_SUBM_4: next_state = S_SUBM_5;
            S_SUBM_5: next_state = S_SUBM_6;
            S_SUBM_6: next_state = S_SUBM_7;
            S_SUBM_7: next_state = S_SUBM_8;
            S_SUBM_8: next_state = S_SUBM_9;
            S_SUBM_9: next_state = S_FETCH_0;

            // ADDM FSM
            S_ADDM_4: next_state = S_ADDM_5;
            S_ADDM_5: next_state = S_ADDM_6;
            S_ADDM_6: next_state = S_ADDM_7;
            S_ADDM_7: next_state = S_ADDM_8;
            S_ADDM_8: next_state = S_ADDM_9;
            S_ADDM_9: next_state = S_FETCH_0;

            // SUBR FSM
            S_SUBR_4: next_state = S_SUBR_5;
            S_SUBR_5: next_state = S_SUBR_6;
            S_SUBR_6: next_state = S_FETCH_0;

            // LDAI FSM
            S_LDAI_4: next_state = S_LDAI_5;
            S_LDAI_5: next_state = S_LDAI_6;
            S_LDAI_6: next_state = S_LDAI_7;
            S_LDAI_7: next_state = S_FETCH_0;

            // INC FSM
            S_INC_4: next_state = S_INC_5;
            S_INC_5: next_state = S_FETCH_0;

            default: next_state = S_FETCH_0;
        endcase
    end

    // Output logic
always @(*) begin
    // Varsayılan değerler
    IR_Load = 0;
    DR_Load = 0;
    PC_Load = 0;
    AR_Load = 0;
    AC_Load = 0;
    FLAGS_Load = 0;
    AC_Inc = 0;
    PC_Inc = 0;
    write_en = 0;
    DR_Inc = 0;
    alu_sel = 4'b0000;
    bus_sel = 3'b000;          // Varsayılan bus_sel
    reg_sel = 4'b0000;
    reg_write_sel = 4'b0000;
    reg_we = 0;

    case (current_state)
        // FETCH aşaması
        S_FETCH_0: begin
            // AR <= PC
            bus_sel = 3'b011;     // {4'd0, PC} veri yolu seçildi
            AR_Load = 1;
        end
        S_FETCH_1: begin
            PC_Inc = 1;
        end
        S_FETCH_2: begin
            bus_sel = 3'b010;     // from_memory (bellek veri yolu)
            IR_Load = 1;
        end
        S_DECODE_3: begin
            // Decode aşamasında bus_sel değişmiyor
        end

        // SUBM $addr komutu
        S_SUBM_4: begin
            bus_sel = 3'b011;     // {4'd0, PC} adres yolu
            AR_Load = 1;
        end
        S_SUBM_5: begin
            PC_Inc = 1;
        end
        S_SUBM_6: begin
            bus_sel = 3'b010;     // from_memory
            DR_Load = 1;
        end
        S_SUBM_7: begin
            alu_sel = ALU_SUB;
            reg_sel = 4'b0100;    // Örnek: DR register'ı seçildi (4. bit olarak ayarlanabilir)
        end
        S_SUBM_8: begin
            AC_Load = 1;
        end
        S_SUBM_9: begin
            // İşlem sonu
        end

        // ADDM $addr komutu
        S_ADDM_4: begin
            bus_sel = 3'b011;     // {4'd0, PC}
            AR_Load = 1;
        end
        S_ADDM_5: begin
            PC_Inc = 1;
        end
        S_ADDM_6: begin
            bus_sel = 3'b010;     // from_memory
            DR_Load = 1;
        end
        S_ADDM_7: begin
            alu_sel = ALU_ADD;
            reg_sel = 4'b0100;    // DR register seçimi
        end
        S_ADDM_8: begin
            AC_Load = 1;
        end
        S_ADDM_9: begin
            // İşlem bitti
        end

        // SUB Rx komutu (register-based)
        S_SUBR_4: begin
            reg_sel = IR_Value[3:0]; // Rx register seçimi (4-bit)
            alu_sel = ALU_SUB;
        end
        S_SUBR_5: begin
            AC_Load = 1;
        end
       S_SUBR_6: begin
    alu_sel = ALU_SUB;
    reg_sel = IR_Value[9:6];         // kaynak register (Rx)
    reg_write_sel = 4'b0000;         // AC'ye yaz (örnek olarak R0 olabilir)
    reg_we = 1;                      // yazma aktif
    AC_Load = 1;                     // AC güncelle
    FLAGS_Load = 1;
end

        // LDA #imm komutu
        S_LDAI_4: begin
            bus_sel = 3'b011;     // {4'd0, PC} adres yolu
            AR_Load = 1;
        end
        S_LDAI_5: begin
            PC_Inc = 1;
        end
        S_LDAI_6: begin
            bus_sel = 3'b010;     // from_memory
            DR_Load = 1;
        end
        S_LDAI_7: begin
            AC_Load = 1;
             bus_sel = 3'b100;               // immediate veri
    FLAGS_Load = 1;
        end

        // INC komutu
        S_INC_4: begin
            AC_Inc = 1;
        end
        S_INC_5: begin
            // İşlem tamam
        end

        default: begin
            // Tüm sinyaller sıfırla
            IR_Load = 0;
            DR_Load = 0;
            PC_Load = 0;
            AR_Load = 0;
            AC_Load = 0;
            FLAGS_Load = 0;
            AC_Inc = 0;
            PC_Inc = 0;
            write_en = 0;
            DR_Inc = 0;
            alu_sel = 4'b0000;
            bus_sel = 3'b000;
            reg_sel = 4'b0000;
            reg_write_sel = 4'b0000;
            reg_we = 0;
        end
    endcase
end

endmodule