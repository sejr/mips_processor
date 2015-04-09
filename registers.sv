module INSTRUCTION_MEMORY
#(parameter N = 5, M = 8)
 (input logic clk,
  input logic [M*4-1:0] address,
  output logic [M*4-1:0] dataOut);

  // BEGIN BEHAVIOR
  logic [M-1:0] memory[2**N-1:0];

  initial
    $readmemh("instmem.dat", memory);
  always @(posedge clk)
  assign dataOut = {memory[address+3],   memory[address+2],
                    memory[address+1], memory[address]};
endmodule

module DATA_MEMORY
#(parameter N = 5, M = 8)
 (input logic clk, writeEnable,
  input logic [M*4-1:0] address, dataIn,
  output logic [M*4-1:0] dataOut);

  // BEGIN BEHAVIOR
  logic [M-1:0] memory[2**N-1:0];

  initial
    $readmemh("mem.dat", memory);
  always_ff @(posedge clk)
  if (writeEnable)
    begin
      memory[address+3]   <= dataIn[31:24];
      memory[address+2] <= dataIn[23:16];
      memory[address+1] <= dataIn[15:8];
      memory[address] <= dataIn[7:0];
    end
    assign dataOut = {memory[address+3],   memory[address+2],
                      memory[address+1], memory[address]};
endmodule

module REGISTER_MEMORY
#(parameter N = 5, M = 32)
 (input logic clk, writeEnable_3,
  input logic [N-1:0] address_1, address_2, address_3,
  output logic [M-1:0] data_1, data_2,
  input logic [M-1:0] data_3);
  

  // BEGIN BEHAVIOR
  logic [M-1:0] memory[2**N-1:0];

  initial
    $readmemh("regmem.dat", memory);
    always_ff @(posedge clk)
    if (writeEnable_3) memory[address_3] <= data_3;
      
    assign data_1 = memory[address_1];
    assign data_2 = memory[address_2];    
endmodule

