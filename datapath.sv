module PROGRAM_COUNTER
 (input logic clk, reset,
  output logic [31:0] count);

  // BEGIN BEHAVIOR
  always_ff @(negedge clk)
    if (reset) count <= 32'b0;
    else count <= count + 4;
endmodule

module SIGN_EXTEND
 (input logic [15:0] sxInput,
  output logic [31:0] sxResult);

  // BEGIN BEHAVIOR
  assign sxResult [31:16] = (sxInput[15] == 1) ? '1 : '0;
  assign sxResult [15:0]  = sxInput;
endmodule

// BEGIN DATAPATH

module DATAPATH
 (input logic clk, registerDestination, aluSource, memoryToRegister,
  input logic registerWrite, memoryWrite, reset,
  input logic [2:0] aluOpcode,
  output logic zero);

  // 1: Instruction
  // 2: Data
  // 3: Register

  // BEGIN BEHAVIOR
  logic [4:0] dataOut_1, dataOut_2, registerDataOut, multiplexerA, multiplexerB;
  logic [31:0] programCount, instructionMemoryOut;
  logic [31:0] aluOut, aluMuxOut, sxOutput;
  logic [31:0] registerData_1, registerData_2, memoryOut, memoryOut_1;

  PROGRAM_COUNTER     ProgramCounter(clk, reset, programCount);
  INSTRUCTION_MEMORY  InstructionMemory(clk, programCount, instructionMemoryOut);

  assign multiplexerA = instructionMemoryOut[20:16];
  assign multiplexerB = instructionMemoryOut[15:11];
  assign dataOut_1    = instructionMemoryOut[25:21];
  assign dataOut_2    = instructionMemoryOut[20:16];

  MULTIPLEXER #(5)    DataRegister(multiplexerA, multiplexerB, registerDestination, registerDataOut);
  REGISTER_MEMORY     RegisterMemory(clk, registerWrite, dataOut_1, dataOut_2, registerDataOut, registerData_1, registerData_2, memoryOut);
  SIGN_EXTEND         SignExtend(instructionMemoryOut[15:0], sxOutput);
  MULTIPLEXER #(32)   AluMux (registerData_2, sxOutput, aluSource, aluMuxOut);
  ALU #(32)           Alu(registerData_1, aluMuxOut, aluOpcode, aluOut, zero);
  DATA_MEMORY         DataMemory(clk, memoryWrite, aluOut, registerData_2, memoryOut_1);
  MULTIPLEXER #(32)   MemoryRegisterMux(aluOut, memoryOut_1, memoryToRegister, memoryOut);
endmodule

// BEGIN DATAPATH TESTBENCH

module DATAPATH_TESTBENCH ();
  logic clk, registerDestination, aluSource, memoryToRegister;
  logic registerWrite, memoryWrite, zero, reset;
  logic [2:0] opcode;

  // BEGIN BEHAVIOR
  DATAPATH DatapathTest(clk, registerDestination, aluSource, memoryToRegister, registerWrite, memoryWrite, reset, opcode, zero);

  initial begin
    reset = 1; clk = 1; #10; clk = 0; opcode = 'b010; #5; reset = 0; #5;
    registerDestination = 0; registerWrite = 1; aluSource = 1; opcode = 'b010; memoryWrite = 0; memoryToRegister = 1; clk = 1; #10;
    registerDestination = 0; registerWrite = 1; aluSource = 1; opcode = 'b010; memoryWrite = 0; memoryToRegister = 1; clk = 0; #10;
    clk = 1; #10;
    registerDestination = 1; registerWrite = 1; aluSource = 0; opcode = 'b010; memoryWrite = 0; memoryToRegister = 0; clk = 0; #10;
    clk = 1; #10;
    registerDestination = 1; registerWrite = 0; aluSource = 1; opcode = 'b010; memoryWrite = 1; memoryToRegister = 1; clk = 0; #10;
    clk = 1; #10;
    clk = 0; #10;
  end
endmodule
