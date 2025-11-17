`timescale 1ns / 1ps

module datamemory #(
    parameter DM_ADDRESS = 9,
    parameter DATA_W = 32
) (
    input logic clk,
    input logic MemRead,  // comes from control unit
    input logic MemWrite,  // Comes from control unit
    input logic [DM_ADDRESS - 1:0] a,  // Read / Write address - 9 LSB bits of the ALU output -> endereço do byte que vai ser lido (bloco de bytes)
    input logic [DATA_W - 1:0] wd,  // Write Data
    input logic [2:0] Funct3,  // bits 12 to 14 of the instruction
    output logic [DATA_W - 1:0] rd  // Read Data
);

  logic [31:0] raddress;
  logic [31:0] waddress;
  logic [31:0] Datain;
  logic [31:0] Dataout;
  logic [ 3:0] Wr;

  Memoria32Data mem32 (
      .raddress(raddress),
      .waddress(waddress),
      .Clk(~clk),
      .Datain(Datain),
      .Dataout(Dataout),
      .Wr(Wr)
  );

  always_comb begin
    raddress = {{22{1'b0}}, a[8:2], {2{1'b0}}};
    waddress = {{22{1'b0}}, a[8:2], {2{1'b0}}}; 
    Datain = wd;
    Wr = 4'b0000;

    if (MemRead) begin
      case (Funct3)
        3'b000: begin //LB
          case (a[1:0]) //determinar qual byte deve ser lido
            2'b00: rd = {{24{Dataout[7]}}, Dataout[7:0]};    // byte 0
            2'b01: rd = {{24{Dataout[15]}}, Dataout[15:8]};  // byte 1
            2'b10: rd = {{24{Dataout[23]}}, Dataout[23:16]}; // byte 2
            2'b11: rd = {{24{Dataout[31]}}, Dataout[31:24]}; // byte 3
          endcase
        end
        3'b001: begin //LH
          case (a[1:0]) //determinar o halfword a ser lido
            2'b00: rd = {{16{Dataout[15]}}, Dataout[15:0]};    // halfword 0
            2'b10: rd = {{16{Dataout[31]}}, Dataout[31:16]};  // halfword 1
            default: rd = 32'b0; //quando o endereço estiver desalinhado
          endcase
        end
        3'b010:  //LW
          rd = Dataout;
        3'b100: begin //LBU
          case (a[1:0])
            2'b00: rd = {24'b0, Dataout[7:0]};    // byte 0
            2'b01: rd = {24'b0, Dataout[15:8]};  // byte 1
            2'b10: rd = {24'b0, Dataout[23:16]}; // byte 2
            2'b11: rd = {24'b0, Dataout[31:24]}; // byte 3
          endcase
        end
        default: rd = Dataout;
      endcase
    end else if (MemWrite) begin
      case (Funct3)
        3'b000: begin  //SB
          case(a[1:0])
            2'b00: begin
              Wr = 4'b0001; //escrever o byte 0
              Datain = {24'b0, wd[7:0]};
            end
            2'b01: begin 
              Wr = 4'b0010; //escrever o byte 1
              Datain = {16'b0, wd[7:0], 8'b0};
            end
            2'b10: begin
              Wr = 4'b0100; //escrever o byte 2
              Datain = {8'b0, wd[7:0], 16'b0};
            end
            2'b11: begin
              Wr = 4'b1000; //escrever o byte 3
              Datain = {wd[7:0], 24'b0};
            end 
          endcase
        end
        3'b001: begin //SH
          case(a[1:0])  //determina o endereço da operação
          2'b00: begin 
            Wr = 4'b0011; //escreve halfword 0; 
            Datain = {16'b0, wd[15:0]};
          end
          2'b10: begin 
            Wr = 4'b1100; //escreve halfword 1;
            Datain = {wd[15:0], 16'b0};
          end
          default: begin
            Wr = 4'b0000; //quando o endereço estiver desalinhado
            Datain = 32'b0; 
          end
          endcase
        end
        3'b010: begin  //SW
          Wr = 4'b1111;
          Datain = wd;
        end
        default: begin
          Wr = 4'b0000;  //mantém o "estado" anterior = nao escreve nada
          Datain = wd;
        end
      endcase
    end
  end

endmodule
