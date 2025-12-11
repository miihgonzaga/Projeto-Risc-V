`timescale 1ns / 1ps

module imm_Gen (
    input  logic [31:0] inst_code,
    output logic [31:0] Imm_out
);


  always_comb
    case (inst_code[6:0])
      7'b0000011:  /*I-type load part*/
        Imm_out = {inst_code[31] ? 20'hFFFFF : 20'b0, inst_code[31:20]};

      7'b0100011:  /*S-type*/
        Imm_out = {inst_code[31] ? 20'hFFFFF : 20'b0, inst_code[31:25], inst_code[11:7]};

      7'b1100011:  /*B-type*/
        Imm_out = {
          {19{inst_code[31]}},
          inst_code[31],
          inst_code[7],
          inst_code[30:25],
          inst_code[11:8],
          1'b0
          };

      7'b0010011:  //instruções do tipo I - (ADDI, SLTI, SLLI, SRLI, SRAI)
        Imm_out = {inst_code[31] ? 20'hFFFFF : 20'b0, inst_code[31:20]};

      7'b1101111: // instruções do tipo JAL (desembaralhar 21 bits de immediato)
        Imm_out = {{11{inst_code[31]}}, inst_code[31], inst_code[19:12], inst_code[20], inst_code[30:21], 1'b0};

      7'b1100111: // instruções do tipo JALR (mesma estrutura das instruções do tipo I)
        Imm_out = {inst_code[31] ? 20'hFFFFF : 20'b0, inst_code[31:20]};

      default: Imm_out = {32'b0};

    endcase

endmodule
