`timescale 1ns / 1ps

module alu #(
        parameter DATA_WIDTH = 32,
        parameter OPCODE_LENGTH = 4
        )
        (
        // a alu sempre recebe dois valores (ScrA e ScrB) -> são os operandos 
        // srcA vem dos registradores 
        // srcB pode vir de registradores ou de immediatos (constantes da instrução)
        // o ALUSrc (do módulo Controller) escolhe qual sinal será o operando B da ula:
        //      escolhe entre registrador e immediato.

        input logic [DATA_WIDTH-1:0]    SrcA, //entrada dos operandos da ULA (ambos com 32 bits)
        input logic [DATA_WIDTH-1:0]    SrcB, // a ula recebe um valor gravado no reg ou um immediato

        input logic [OPCODE_LENGTH-1:0]    Operation, //entrada que define a operação a ser realizada

        // overflows são desconsiderados por definição da arquitetura (32 bits é a saída da ula)
        output logic[DATA_WIDTH-1:0] ALUResult //saída = resultado da ula
        );
    
        always_comb
        begin
            case(Operation) //cada operação é um possível caso:

                4'b0000:        // AND
                        ALUResult = SrcA & SrcB;
                4'b0001:        // SUB
                        ALUResult = SrcA - SrcB;
                4'b0010: //ADD E ADDI
                        ALUResult = SrcA + SrcB;
                4'b0011:        // OR
                        ALUResult = SrcA | SrcB;
                4'b0100:        // XOR
                        ALUResult = SrcA ^ SrcB;
                4'b0101: //SLT e SLTI (usado também pelo blt, bge)
                        ALUResult = ($signed(SrcA) < $signed(SrcB)) ? 1 : 0; //signed (considera valores negativos)
                4'b1000:       //  Equal (usado pelo beq e bne)
                        ALUResult = (SrcA == SrcB) ? 1 : 0;
                4'b1001:       //  SLLI
                        ALUResult = SrcA << SrcB[4:0];
                4'b1010:       //  SRLI
                        ALUResult = SrcA >> SrcB[4:0];
                4'b1011:       //  SRAI
                        ALUResult = $signed(SrcA) >>> SrcB[4:0]; //levar em consideração o sinal

                default: //se não for nenhum dos casos válidos descritos acima:
                        ALUResult = 32'b0; //resultado = 0

            endcase
        end
endmodule

