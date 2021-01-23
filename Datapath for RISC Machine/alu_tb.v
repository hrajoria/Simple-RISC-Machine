/*

Module: ALU_TB

Purpose: to test common and corner cases encountered by the ALU module 

The following tests are conducted to determine the module ALU fulfills its requirements:
1. ALUop = 00 - output is expected to be sum of Ain and Bin
2. ALUop = 01 - output is expected to be the difference of Bin and Ain
3. ALUop = 10 - output is expected to be Ain and Bin bitwise ANDED
4. ALUop = 11 - output is expected to be bitwise NOT of Bin

*/

`define n1 16'b0000000000000001
`define n2 16'b0000000000000010
`define n3 16'b0000000000000011
`define n4 16'b0000000000000100
`define n5 16'b0000000000000101
`define n7 16'b0000000000000111
`define n9 16'b0000000000001001
`define n11 16'b0000000000001011
`define n14 16'b0000000000001110
`define ntestout 16'b1111111111111011

//i/o specified in header
module ALU_tb;

	reg [15:0] Ain, Bin; //16 bit inputs Ain and Bin as specified in the header of the ALU module
	reg [1:0] ALUop; //2 bit input ALUop as specified in the header of the ALU module
	reg err; //1 bit error signal indicating the status of the test - if the test does not produce the expected output, error signal will be set to 1
	wire [15:0] out; //16 bit output as specified in the header of the ALU module
	wire Z; //1 bit output as specified in the header of the ALU module

ALU DUT(Ain, Bin, ALUop, out, Z); //instantiation of design under test ALU

initial begin 

	//Test Case 1: Addition of 3 + 11 = 14

	err = 1'b0;

	Ain = `n3;
	Bin = `n11; 
	ALUop = 2'b00;

	#1;
	
	if(ALU_tb.DUT.out != `n14) begin //if block to identify and indicate an error if there is one - this structure is replicated for every test case
	$display("ERROR ** output is %b, expected %b", ALU_tb.DUT.out, `n14); //displays error in the transcript window
	err = 1; //sets error signal to one to indicate that the output of the manipulation was not what was expected
	end

	#5;

	//Test Case 2: Subtraction of 5 - 2 = 3

	Ain = `n5;
	Bin = `n2;
	ALUop = 2'b01;

	#1;

	if(ALU_tb.DUT.out != `n3) begin
	$display("ERROR ** output is %b, expected %b", ALU_tb.DUT.out, `n3);
	err = 1;
	end

	#5;

	//Test Case 3: Comparing 7 and 9 using bitwise AND -> expecting 1

	Ain = `n7;
	Bin = `n9;
	ALUop = 2'b10;

	#1;

	if(ALU_tb.DUT.out != `n1) begin
	$display("ERROR ** output is %b, expected %b", ALU_tb.DUT.out, `n1);
	err = 1;
	end

	#5;

	//Test Case 4: Input: bin = 4, Output, ~(bin = 4) = ntestout

	Bin = `n4;
	ALUop = 2'b11;

	#1;

	if(ALU_tb.DUT.out != `ntestout) begin
	$display("ERROR ** output is %b, expected %b", ALU_tb.DUT.out, `ntestout);
	err = 1;
	end

	#5;
	
end

endmodule 


	
