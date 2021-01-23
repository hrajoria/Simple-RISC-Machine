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

module datapath_tb;

	reg vsel; //9
	reg [15:0] datapath_in;
	wire [15:0] data_in;

	reg [2:0]  writenum;	//1
	reg write;
	reg clk;
	reg [2:0] readnum;
	wire [15:0] data_out;

	reg loada; //3
	wire [15:0] outa;

	reg loadb; //4
	wire [15:0] outb; 

	reg [1:0] shift; //8
	wire [15:0] sout; 

	reg bsel; //7
	wire [15:0] Bin; 

	reg asel; //6
	wire [15:0] Ain;

	reg [1:0] ALUop; //2
	wire [15:0] out;
	wire Z;

	reg loadc; //5
	wire [15:0] datapath_out; 

	reg loads; //10
	wire Z_out;

datapath dut1(clk, // recall from Lab 4 that KEY0 is 1 when NOT pushed

                // register operand fetch stage
                readnum,
                vsel,
                loada,
                loadb,

                // computation stage (sometimes called "execute")
                shift,
                asel,
                bsel,
                ALUop,
                loadc,
                loads,

                // set when "writing back" to register file
                writenum,
                write,  
                datapath_in,

                // outputs
                Z_out,
                datapath_out
             );

initial begin
	clk = 0; 
	#5;
	forever begin
	clk = 1;
	#5;
	clk = 0; 
	#5;
	end
end

initial begin 

//Cycle 1

datapath_in = `n7; //9
vsel = 1;

writenum = 3'b000; //1
write = 1;
readnum = 3'b000;

loada = 0; //3
loadb = 0; //4
asel = 1; //6
bsel = 1; //7

#10;
//$display("%b", dut1.data_in);
//Cycle 2

loada = 0; //3
loadb = 1; //4
asel = 1; //6
bsel = 1; //7

#10;

//Cycle 3

loada = 0; //3
loadb = 1; //4
asel = 0; //6
shift = 2'b01; //8
bsel = 0; //7

#10;


//Cycle 4

loada = 0;
loadb = 0;

datapath_in = `n2; //9
vsel = 1;

writenum = 3'b001; //1
write = 1;
readnum = 3'b001;
asel = 1; //6
bsel = 1; //7

#10;

//Cycle 5

loada = 1;
asel = 1; //6
bsel = 1; //7

#10;

//Cycle 6

loada = 1;
asel = 1; //6
bsel = 1; //7

#10;

//Cycle 7

loada = 0;
loadb = 0;

shift = 2'b01; //8
bsel = 0; //7
asel = 0;

ALUop = 2'b00; //2

loadc = 1; //5
loads = 1; //10

#10;

//Cycle 8

loadc = 0;
loads = 0;

vsel = 0;

writenum = 3'b010; //1
write = 1;
readnum = 3'b010;

loada = 0; //3
loadb = 0; //4
asel = 1; //6
bsel = 1; //7

/*
loadc = 0; //5
loads = 0; //10
vsel = 0; //9

writenum = 3'b010; //1
write = 1;*/

#10;
$stop;
end

endmodule 


