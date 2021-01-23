module add_tb;

	reg [2:0] opcode; //assume 101 = ALU
	reg [1:0] op;// assume 00 = ADD
	reg s;
	reg reset;
	reg clk;
	
	wire [6:0] present_state; //internal signal
	wire w; 
	wire [2:0] nsel;
	wire [3:0] vsel; //9
	wire [15:0] mdata;
	wire [7:0] PC;
	wire write;
	wire loada; //3
	wire loadb; //3
	wire [1:0] shift; //8		//all inputs required by other module instantiations	
	wire bsel; //7
	wire asel; //6
	wire loadc; //5
	wire loads; //10

statemachine adddut(opcode, op, s, reset, w,

clk,

nsel,
vsel,
mdata,
PC,

write, 
clk,

loada,
loadb,

shift,
bsel,
asel,

loadc,
loads

);

initial begin
forever begin
clk = 0;
#5;
clk = 1;
#5;
end
end

initial begin
	reset = 1;
	s=0;
	#10;
	opcode = 3'b101;
	op = 2'b01;// assume 00 = ADD
	s = 1;
	reset = 0;
end

endmodule 


