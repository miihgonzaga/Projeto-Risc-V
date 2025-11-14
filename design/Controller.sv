`timescale 1ns / 1ps

module Controller (
    //Input
    input logic [6:0] Opcode, //campo de 7 bits (faz parte da identificação da instrução)

    //Outputs
    output logic ALUSrc, // saída que define qual sinal é o operando B (SrcB) da ULA 
      //Se for 0: operando B (SrcB) da ULA é o valor guardado num registrador file output (Read data 2); 
      //Se for 1: operando B (SrcB) da ULA é um imediato (extraído da instrução e estendido com sinal (sign-extended))
    
    output logic MemtoReg, // controle o valor da memória sendo carregado para registradores de destino (rd em loads)
      //Se for 0: o valor a ser escrito no registrador é o resultado da ULA.
      //Se for 1: o valor a ser escrito no registrador é um dado da memória.
    
    output logic RegWrite, // controla a escrita no registrador (quando é 1, o reg recebe o valor de "write back") 
    output logic MemRead,  // controla quando a memória de dados deve ser lida (loads)
    output logic MemWrite, // controla quando a escrita de registradores deve ser feita
    output logic [1:0] ALUOp,  // indica o tipo de operação (00: LW/SW; 01:Branch; 10: Rtype/IMM; 11: JAL/JALR);
    output logic Branch  // 0: indica que o branch NÃO foi tomado; 1: indica que o branch foi tomado
    );

    logic [6:0] R_TYPE, LW, SW, BR, IMM; // define os sinais conforme os tipos de instruções

    assign R_TYPE = 7'b0110011;  //add,and
    assign LW = 7'b0000011;  //lw, lb, lh, lbu
    assign SW = 7'b0100011;  //sw, sb, sh
    assign BR = 7'b1100011;  //beq, bne, blt, bge
    assign IMM = 7'b0010011;  //imm: addi, slti, slli, srli, srai

    assign ALUSrc = (Opcode == LW || Opcode == SW || Opcode == IMM); // opcodes que mandam sinal pra ula
    assign MemtoReg = (Opcode == LW); // valor da memória é carregado para registradores (loads)
    assign RegWrite = (Opcode == R_TYPE || Opcode == LW || Opcode == IMM); // instruções que escrevem em registradores
    assign MemRead = (Opcode == LW); // leitura da memória 
    assign MemWrite = (Opcode == SW); // escrita na memória 

    // controle dos dois bits da ALUOp (do menos significativo pro mais significativo)
    assign ALUOp[0] = (Opcode == BR); // bit menos significativo do ALUOp (01 = Branch, 11 = JAL/JALR)
    assign ALUOp[1] = (Opcode == R_TYPE || Opcode == IMM); // bit mais significativo do ALUOp (10 = Rtype/IMM, 11 = JAL/JALR)
    assign Branch = (Opcode == BR); // indica que é uma instrução de branch
  
endmodule
