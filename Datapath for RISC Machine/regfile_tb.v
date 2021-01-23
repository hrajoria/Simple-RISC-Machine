/*

Module: regfile_tb
Purpose: to test common and corner cases encountered by the regfile module 

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
`define n17 16'b0000000000010001

module regfile_tb;

	reg [15:0] data_in;
	reg [2:0] writenum, readnum;
	reg write;
	reg clk;
	wire [15:0] data_out;
	reg err;

regfile DUT(data_in,writenum,write,readnum,clk,data_out);

initial begin
	clk = 1'b0;

	#5;

	forever begin
	clk = 1'b1;

	#5;

	clk = 1'b0;

	#5;
	end
end

initial begin

err = 1'b0;

//From START_ONE to END_ONE, registers 0 and 1 both receive values; however, the value in register 1 is selected to be copied to data_out
//START_ONE

	//writes the value 0 to register 0  
	data_in = 0; //input value = 0
	writenum = 3'b000; //indicates the input value = 0 should be stored in register 0 at the next rising edge of the clock
	write = 1'b1; //indicates that the input value should be stored in the relevant register (in this case, register 0) at the next rising edge of the clock
	
	#10;

	//writes the value 1 to register 1
	writenum = 3'b001; //input value = 1
	data_in[0] = 1; //indicates the input value = 1 should be stored in register 1 at the next rising edge of the clock
	
	#10;

	readnum = 3'b001; //since readnum is set to 3'b001 - indiciating we should read from register 1 at 20 ps - and does not rely on the clock, we should expect to see data_out = the value stored in register 1 = 3'b001 at this point

	#1;

	if(data_out !== `n1) begin
	err = 1'b1;
	end

//END_ONE

//FROM START_TWO to END_TWO, registers 2 and 3 both also recieve values; however, the value in register 2 is selected to be copied to data_out
//START_TWO

	//writes the value 2 to register 2 
	writenum = 3'b010;
	data_in[0] = 0;
	data_in[1] =  1;

	#10;

	//writes the value 3 to register 3  
	writenum = 3'b011;
	data_in[1] = 1;
	data_in[0] = 1;

	#10;
	
	readnum = 3'b010; //since readnum is set to 3'b010 - indiciating we should read from register 2 at 40 ps - and does not rely on the clock, we should expect to see data_out = the value stored in register 2 = 3'b010 at this point

	#1;

	if(data_out !== `n2) begin
	err = 1'b1;
	end

//testing write = 0

	writenum = 3'b100;
	data_in = 16'b0000000000000100;

	#5; //45

	readnum = 3'b100;

	#1;

	if(data_out !== `n4) begin
	err = 1'b1;
	end

	#5; //50

	write = 1'b0;
	writenum = 3'b100;
	data_in = 16'b0000000001000000;

	#5; //55

	readnum = 3'b100; //value that should be read here is 4 because write = 0

	#1;

	if(data_out !== `n4) begin
	err = 1'b1;
	end

	#5; //60

//1. Value stored in register 4 only -> value extracted from same register
	writenum = 3'b100; //register 4
	data_in = 16'b0000000000010001; //value = 17
	write = 1'b1; 

	readum = 3'b100;

	#1;

	if(data_out !== `n17) begin
	err = 1'b1;
	end

	#10;

//2. Value stored in register 1 after value stored in register 4 -> testing value extracted from register 1, then register 4
	writenum = 3'b001; //register 1
	write = 1'b1;
	data_in = 16'b0000000000000010; //value = 2

	#10;

	readnum = 3'b001; //expected output = 2

	#1;

	if(data_out !== `n2) begin
	err = 1'b1;
	end

	#10;

	readnum = 3'b100; //expected output = 17

	#1;

	if(data_out !== `n17) begin
	err = 1'b1;
	end

	#10;

end

endmodule 


	
