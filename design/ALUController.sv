`timescale 1ns / 1ps

module ALUController (
    //Inputs
    input logic [1:0] ALUOp,  //campo de dois bits (output do módulo Controller) 00: LW/SW/AUIPC; 01: BRANCH; 10: Rtype/Itype; 11: JAL/LUI
    input logic [6:0] Funct7,  // bits 25 to 31 of the instruction
    input logic [2:0] Funct3,  // bits 12 to 14 of the instruction

    //Output
    output logic [3:0] Operation  // campo de quatro bits (seleciona a operação na ALU)
  );

    always_comb begin
        case(ALUOp)
            2'b00: // operações de memória: (lw, lb, lh, lbu, sw, sb, sh)
                Operation = 4'b0010;

            2'b01: begin//operações de branche (beq, bne, blt, bge)
                case(Funct3) //tratar operações conforme o funct3 

                    3'b000: // beq
                        Operation = 4'b1000; // equal na ula
                    3'b001: // bne
                        Operation = 4'b1000; // equal na ula 
                    3'b100: // blt
                        Operation = 4'b0101; // slt na ula 
                    3'b101: // bge
                        Operation = 4'b0101; // slt na ula

                endcase
            end
            
            2'b10: begin
                case(Funct3) //tratar operações com mesmo funct3 
                    
                    3'b000: begin // (sub, add, addi)
                        
                        if (Funct7 == 7'b0100000) //sub
                            Operation = 4'b0001;
                        else if (Funct7 == 7'b0000000) //add
                            Operation = 4'b0010;
                        else
                            Operation = 4'b0010; //addi (nao tem funct7)   
                    end  

                    3'b001: // (sll, slli)
                        Operation = 4'b1001;
                    
                    3'b010: // (slt, slti)
                        Operation = 4'b0101;
                    //3'b011 são operação de sltu e sltiu - nao foram implementadas :)

                    3'b100: // (xor)
                        Operation = 4'b0100; // (xor)
                    
                    3'b101: begin// (srli, srai)

                        if (Funct7 == 7'b0000000) // srli
                            Operation = 4'b1010; 
                        else if (Funct7 == 7'b0100000) // srai
                            Operation = 4'b1011;
                    end

                    3'b110: // (or)
                        Operation = 4'b0011; 
                    
                    3'b111: // (and)
                        Operation = 4'b0000; 

                endcase
            end

            //2'b11: jal e jalr :)
                    
        endcase
    end
endmodule
