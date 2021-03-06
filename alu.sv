// COMPUTER ARCHITECTURE
// LAB 5: Tyler and Sam
//
// Naming Conventions:
// MODULE_NAME
// ModuleInstance
// signalName

module AND
#(parameter width = 32)
 (input logic [width-1:0] inputA, inputB,
  output logic [width-1:0] andResult);

  // BEGIN BEHAVIOR
  assign andResult = inputA[width-1:0] & inputB[width-1:0];
endmodule

module OR
#(parameter width = 32)
 (input logic [width-1:0] inputA, inputB,
  output logic [width-1:0] orResult);

  // BEGIN BEHAVIOR
  assign orResult = inputA[width-1:0] | inputB[width-1:0];
endmodule

module ZERO_DETECT
#(parameter width = 32)
 (input logic [width-1:0] zdInput,
  output logic zeroResult);

  // BEGIN BEHAVIOR
  assign zeroResult = (zdInput[width-1:0] == 32'b0) ? 1 : 0;
endmodule

module ADDER
#(parameter width = 32)
 (input logic [width-1:0] inputA, inputB,
  input logic cin,
  output logic [width-1:0] sum);

  // BEGIN BEHAVIOR
  assign sum = inputA + inputB + cin;
endmodule

module SET_LESS_THAN
#(parameter width = 32)
 (input logic [width-1:0] sltInput,
  output logic sltResult);

  // BEGIN BEHAVIOR
  assign sltResult = (sltInput[width-1] == 1) ? '1 : '0;
endmodule

module MULTIPLEXER
#(parameter width = 8)
 (input logic [width-1:0] inputA, inputB,
  input logic control,
  output logic [width-1:0] muxResult);

  // BEGIN BEHAVIOR
  assign muxResult = control ? inputB : inputA;
endmodule

// BEGIN ALU

module ALU
#(parameter width = 32)
 (input logic [width-1:0] inputA, inputB,
  input logic [2:0] aluControl,
  output logic [width-1:0] aluResult,
  output logic zero);

  // BEGIN BEHAVIOR
  logic [width-1:0] andResult, orResult, addResult, subResult;
  logic sltResult, cin;
  assign cinAdd = 0;
  assign cinSub = 1;

  AND             AluAnd(inputA, inputB, andResult);
  OR              AluOr(inputA, inputB, orResult);
  ADDER           AluAdd(inputA, inputB, cinAdd, addResult);
  ADDER           AluSub(inputA, ~inputB, cinSub, subResult);
  SET_LESS_THAN   AluSlt(subResult, sltResult);
  always_comb
    case (aluControl)
      3'b000:     aluResult = andResult;
      3'b001:     aluResult = orResult;
      3'b010:     aluResult = addResult;
      3'b110:     aluResult = subResult;
      3'b111:     aluResult = sltResult;
    endcase
    ZERO_DETECT AluZeroDetect(inputA, zero);
endmodule

// BEGIN ALU TESTBENCH

module ALU_TESTBENCHLAB5
#(parameter width = 32)
 (output logic [width-1:0] tbResult,
  output logic zero);

  // BEGIN BEHAVIOR
  logic [width-1:0] inputA, inputB;
  logic [2:0] aluControl;

  // Instantiate the ALU under test.
  ALU AluTest(inputA, inputB, aluControl, tbResult, zero);

  // Applying inputs one at a time.
  // Test cases collected from lab handout.
  initial begin
    inputA = 32'd0; inputB = 32'd1; aluControl = 3'b010; #10;
    inputA = 32'd1; inputB = -1;    aluControl = 3'b010; #10;
    inputA = 32'd1; inputB = 32'd1; aluControl = 3'b110; #10;
    inputA = 32'd0; inputB = 32'd1; aluControl = 3'b110; #10;
    inputA = 32'd5; inputB = 32'd7; aluControl = 3'b111; #10;
    inputA = 32'd7; inputB = 32'd3; aluControl = 3'b111; #10;

    inputA = 32'hAAAAAAAA; inputB = 32'h55555555; aluControl = 3'b000; #10;
    inputA = 32'hAAAAAAAA; inputB = 32'h55555555; aluControl = 3'b001;
  end
endmodule
