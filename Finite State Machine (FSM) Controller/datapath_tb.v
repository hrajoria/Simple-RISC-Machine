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

//i/o specified in datapath module header
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

datapath DUT(clk, // recall from Lab 4 that KEY0 is 1 when NOT pushed

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

//Cycle 1: datapath_in is set to number 7, vsel is set to 1, writenum is set to 3 and write is set to 1 so that the value 7 is copied into register 3. 


datapath_in = `n7; //9
vsel = 1;

writenum = 3'b000; //1
write = 1;

//readnum is set to 1 so that data_out equals the value stored in register 0 (decimal = 7).
readnum = 3'b000;

//both loads a and b initially set to 0 so that the value from data_out isn't copied into either.
loada = 0; //3
loadb = 0; //4

//both asel and bsel are set to 1 so that the multiplexers copy the dummy values into the ALU unit instead of any values currently in loads a and b (until we want to).
asel = 1; //6
bsel = 1; //7

#10;

//Cycle 2: loada is set to 0, loadb is set to 1 so that the value in register 0 (coming from data_out) is copied to RLE B. 

loada = 0; //3
loadb = 1; //4

//both asel and bsel remain at 1 so that the multiplexers copy the dummy values into the ALU unit instead of any values currently in loads a and b (until we want to).
asel = 1; //6
bsel = 1; //7

#20;

//Cycle 3: loada and loadb are both reset to 0 so that the value currently in loadb is stored. datapath_in is set to 2, vsel is set to 1, writenum is set to 1 and write is set to 1 so that the value is copied to register 1.

loada = 0;
loadb = 0;

datapath_in = `n2; //9
vsel = 1;

writenum = 3'b001; //1
write = 1;

//readnum is set to 1 so that data_out equals the value stored in register 1 (decimal = 2)
readnum = 3'b001;

//both asel and bsel remain at 1 so that the multiplexers copy the dummy values into the ALU unit instead of any values currently in loads a and b (until we want to).
asel = 1; //6
bsel = 1; //7

#10;

//Cycle 4: load a is set to 1 so that the value from register 1 (assigned to data_out) is copied into it. asel and bsel remain at 1 so that dummy values are copied into the ALU instead of the values from loads a and b (until we're ready to do that).

loada = 1;

//both asel and bsel remain at 1 so that the multiplexers copy the dummy values into the ALU unit instead of any values currently in loads a and b (until we want to).
asel = 1; //6
bsel = 1; //7

#20;

//Cycle 5: both loads a and b are set to 0 so they store the values acquired from registers 1 and 0 respectively.

loada = 0;
loadb = 0;

//shift is set to 01 to multiply the value in loadb (decimal = 7) by 2.
shift = 2'b01; //8 

//bsel and asel are set to 0 so that the actual acquired values from load a and b are transmitted to the ALU unit.
bsel = 0; //7
asel = 0;

//ALUop is set to 2'b00 to indicate that the values from loada and loadb should be added.
ALUop = 2'b00; //2

//loadc is set to 1 to acquire the output value from the ALU (output = 'out').
loadc = 1; //5

//loads is set to 1 to acquire the output status of the computation (output = 'Z').
loads = 1; //10

#10;

//Cycle 8

//both loadc and loads are set to 0 to store the values from the ALU.
loadc = 0;
loads = 0;

//vsel is set to 0 so the multiplexer selects the output value of the previous addition operation as 'data_in'.
vsel = 0;

//writenum is set to 2 and write is set to 1 so that 'data_in' is stored/written to the second register, and the test case is complete.
writenum = 3'b010; //1
write = 1;

#10;
$stop;

end

endmodule 


