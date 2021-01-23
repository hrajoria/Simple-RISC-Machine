/*
Module: shifter_tb 
Purpose: to test common and corner cases encountered by the shifter module 

The following tests are conducted to determine the module shifter fulfills its requirements:

1. shift = 00 - input and output expected to be unchanged
2. shift = 01 - output expected to be input*2
3. shift = 10 - output expected to be input/2 - most significant bit (MSB - 15th index of output) expected to be 0 
4. shift = 11 - output expected to be input shifted right with MSB = 1*
5. shift = 11 - output expected to be input shifted right with MSB = 0*

*Note: Tests 4 and 5 both test shift = 11 - however the inputs are varied so that in test 4, the MSB of the input is 1 and in test 5, the MSB of the input is 0. This is to ensure that the MSB really is remaining unchanged.  

*/

`define n1 16'b0000000000000001
`define n2 16'b0000000000000010
`define n3 16'b0000000000000011
`define n4 16'b0000000000000100
`define n5 16'b0000000000000101
`define n6 16'b0000000000000110
`define n7 16'b0000000000000111
`define n8 16'b0000000000001000
`define n9 16'b0000000000001001
`define n10 16'b0000000000001010
`define n11 16'b0000000000001011
`define n12 16'b0000000000001100
`define n13 16'b0000000000001101
`define n14 16'b0000000000001110

`define ntest 16'b1110000000000000
`define ntestout 16'b1111000000000000

`define ntest2 16'b0110000000000000
`define ntestout2 16'b0011000000000000

`define ntest3 16'b1111000011001111
`define ntestout3 16'b1111100001100111

module shifter_tb;
	reg [15:0] in; //16 bit input as specified in the header of the shifter module
	reg [1:0] shift; //2 bit input as specified in the header of the shifter module
	reg err; //1 bit error signal indicating the status of the test - if the test does not produce the expected output, error signal will be set to 1
	wire [15:0] sout; //16 bit output as specified in the header of the shifter module

shifter DUT(in, shift, sout); //instantiation of design under test shifter

initial begin

	err = 1'b0; //error signal initially set to 0

	//Test case 1: output = input: shift = 00(n5 --> n5)
	shift = 2'b00;
	in = `n5;

#1;

	if(shifter_tb.DUT.sout != `n5) begin //if block to identify and indicate an error if there is one - this structure is replicated for every test case
	$display("ERROR ** output is %b, expected %b", shifter_tb.DUT.sout, `n5); //displays error in the transcript window
	err = 1'b1; //sets error signal to one to indicate that the output of the manipulation was not what was expected
	end 

#5;

	//Test case 2: shift to the left: shift = 01(n2 --> n4)
	shift = 2'b01;
	in  = `n2;

#1;

	if(shifter_tb.DUT.sout != `n4) begin
	$display("ERROR ** output is %b, expected %b", shifter_tb.DUT.sout, `n4);
	err = 1'b1;
	end 

#5;

	//Test case 3: shift to the right: shift = 10(n2 --> n1)
	shift = 2'b10;
	in = `n2;

#1;

	if(shifter_tb.DUT.sout != `n1) begin
	$display("ERROR ** output is %b, expected %b", shifter_tb.DUT.sout, `n1);
	err = 1'b1;
	end 

#5;

	//Test case 4: shift to the right without changing MSB: shift = 11(ntest ->  ntestout)
	shift = 2'b11;
	in = `ntest;

#1;

	if(shifter_tb.DUT.sout != `ntestout) begin
	$display("ERROR ** output is %b, expected %b", shifter_tb.DUT.sout, `ntestout);
	err = 1'b1;
	end

#5;

	//Test case 5: shift to the right without changing MSB: shift = 11(ntest2 -> ntestout2)
	shift = 2'b11;
	in = `ntest2;

#1;

	if(shifter_tb.DUT.sout != `ntestout2) begin
	$display("ERROR ** output is %b, expected %b", shifter_tb.DUT.sout, `ntestout2);
	err = 1'b1;
	end 

#5;

	//Test case 6: shift to the right without changing MSB: shift =11(ntest3 -> ntestout3)
	shift = 2'b11;
	in = `ntest3;

#1;

	if(shifter_tb.DUT.sout != `ntestout3) begin
	$display("ERROR ** output is %b, expected %b", shifter_tb.DUT.sout, `ntestout3);
	err = 1'b1;
	end 

end

endmodule 
