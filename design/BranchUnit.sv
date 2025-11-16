`timescale 1ns / 1ps

module BranchUnit #(
    parameter PC_W = 9
    ) (
    // entradas:
    input logic [PC_W-1:0] Cur_PC, // campo de 9 bits (de 0 a 8)
    input logic [31:0] Imm, // entrada de immediato com 32 bits (sign-extended)
    input logic Branch, // entrada que indica se o branch foi tomado ou não
    input logic Jump,  // implementar jal e jalr (indica se jump foi tomado)
    input logic [31:0] AluResult, // resultado da ula (32 bits)
    input logic [2:0] Funct3,  // pra identificar o tipo de branch 
    input logic [6:0] Opcode, // decidir entre jal e jalr

    // saídas:
    output logic [31:0] PC_Imm, // pc + imm (offset do branch/jump) (vem do imm_Gen)
    output logic [31:0] PC_Four, // pc + 4
    output logic [31:0] BrPC, // valor do branch quando é tomado
    
    // PcSel = Sinal de seleção do PC
      // 0 = branch NÃO foi tomado (pc = segue p/ próxima instrução logo após o branch = pc+4)
      // 1 = branch foi tomado (segue p/ a primeira instrução dentro do branch)
    output logic PcSel 
    );

    logic Branch_Sel; // 0 = branch não foi tomado; 1 = branch foi tomado
    logic Jump_Sel; // 0 = nenhum jump foi tomado; 1 = (jal ou jalr) foi tomado
    logic [31:0] Jump_Address; // endereço de destino do jump
    logic [31:0] PC_Full; // cria a instância de um campo com 32 bits (completa o PC)
    
    
    assign PC_Full = {23'b0, Cur_PC}; //completa os 32 bits do Cur_PC (inicialmente chega com 9 bits)
    assign PC_Imm = PC_Full + Imm; // o PC_Imm é o valor do pc caso o branch seja tomado
    assign PC_Four = PC_Full + 32'b100; // pc + 4 


    // determinar se o branch foi tomado, conforme os resultados da alu
        // beq e bne usam equal da alu: 
            // beq: AluResult = 1; bne: AluResult = 0 
        // blt e bge usam ambos slt da alu:
            // blt: AluResult = 1; bge: AluResult = 0

    // cases para determinar se o branch foi tomado, conforme o funct3 e o AluResult
    always_comb begin
        Branch_Sel = 1'b0; // inicializando variável 
        if (Branch) begin
            case(Funct3)
                // o bit menos significativo do AluResult indica o resultado do equal e slt (0 ou 1)

                3'b000: // beq
                    Branch_Sel = (AluResult[0] == 1'b1); // assume o valor do Equal
                3'b001: // bne
                    Branch_Sel = (AluResult[0] == 1'b0); // assume o valor negado do Equal
                3'b100: // blt
                    Branch_Sel = (AluResult[0] == 1'b1); // assume o valor do SLT
                3'b101: // bge  
                    Branch_Sel = (AluResult[0] == 1'b0); // assume o valor contrário ao SLT

                default: // caso não seja nenhum dos funct3s acima
                    Branch_Sel = 1'b0; // branch não é tomado!!
            endcase
        end 
        
        else // caso o branch tenha sinal = 0
            Branch_Sel = 1'b0; //else do if(branch)
    end 

    // cases para determinar se o jump foi tomado, conforme o opcode
    always_comb begin 
        Jump_Address = PC_Full; // inicializando variáveis
        Jump_Sel = 1'b0;

        if (Jump) begin// se jump tiver sido tomado:
            case(Opcode)
                7'b1101111: begin// JAL
                    // o endereço é pc + offset (vem do imm_Gen) = pc_imm
                    Jump_Address = PC_Imm; 
                    Jump_Sel = 1'b1; // indica que jump foi tomado
                end
                
                7'b1100111: begin// JALR
                    // o endereço é (reg1 + deslocamento) & ~1 (forçar alinhamento com endereço par!)
                    // alu_result = reg1 + deslocamento 
                    Jump_Address = {AluResult[31:1], 1'b0}; // forçar o último bit a ser zero. 
                    Jump_Sel = 1'b1; //indicar que o jump foi tomado
                end
                
                default: begin // caso o opcode não seja jal nem jalr
                    Jump_Address = PC_Full; // mantém o cur_pc
                    Jump_Sel = 1'b0; 
            
            end
            endcase
        end
        else begin
            Jump_Address = PC_Full; // mantém o cur_pc
            Jump_Sel = 1'b0; 
        end

    end

    // selecionar endereço
        // se for jump, usa Jump_Address, se não: usa pc_imm
    always_comb begin
        if (Jump_Sel) begin
            // jump tomado
            BrPC = Jump_Address; // recebe o valor do endereço do jump 
        end
        else if (Branch_Sel) begin
            // branch tomado
            BrPC = PC_Imm; // recebe o valor do imediato do branch
        end
        else
            BrPC = PC_Four; // se nem branch nem jump forem tomados, BrPC é pc+4. 
    end

    // ativar PcSel se branchs ou jumps forem ativados:
    assign PcSel = (Jump && Jump_Sel) || (Branch && Branch_Sel);  // o output de saída (PcSel é definido conforme Branch_Sel ou Jump_Sel)


endmodule
