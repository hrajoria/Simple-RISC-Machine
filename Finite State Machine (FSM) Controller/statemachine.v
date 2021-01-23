`define Wait 7'b0000001
`define Decode 7'b0000010
`define GetA 7'b0000100
`define GetB 7'b0001000
`define Add 7'b0010000
`define WriteReg 7'b0100000
`define WriteImm 7'b1000000

module statemachine(opcode, op, s, reset, w,

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
ALUop,
loadc,
loads

);

input [2:0] opcode; //assume 101 = ALU
input [1:0] op;// assume 00 = ADD
input s;
input reset;
output w; 
reg [6:0] present_state;

	output [2:0] nsel;
	output [3:0] vsel; //9
	output [15:0] mdata;
	//input [15:0] sximm8; //NOT ASSIGNED
	output [7:0] PC;
	//wire [15:0] data_in;
	//input [15:0] sximm5; //NOT ASSIGNED

	//output [2:0]  writenum;	//1
	output write;
	output clk;
	//output [2:0] readnum;
	//wire [15:0] data_out;

	output loada; //3
	//wire [15:0] outa;

	output loadb; //3
	//wire [15:0] outb; 

	output [1:0] shift; //8		//all inputs required by other module instantiations
	//wire [15:0] sout; 		

	output bsel; //7
	//wire [15:0] Bin; 

	output asel; //6
	//wire [15:0] Ain;		//all internal signals are declared as wires.

	output [1:0] ALUop; //2
	//wire [15:0] out;
	//wire Z;

	output loadc; //5
	//output [15:0] C; 

	output loads; //10
	//output Z_out;

always @(posedge clk) begin
if(reset == 1) begin
	present_state = `Wait;
end else begin
	case(present_state)
	`Wait: if(s == 0) begin
			present_state = `Wait;
		end else begin
			present_state = `Decode;
		end
	`Decode: if(opcode == 3'b101) begin
			present_state = `GetA;
		end else begin
			present_state = `WriteImm;
		end
	
	`GetA: present_state = `GetB;
	`GetB: present_state = `Add;
	`Add: present_state = `WriteReg;
	`WriteReg: present_state = `Wait;

	`WriteImm = present_state = `Wait;
	endcase
	
	case(present_state)
	`Wait: 

		w = 1;
         	nsel = 0;
		vsel = 0;
                loada = 0;
                loadb = 0;	
		//readnum,

                // computation stage (sometimes called "execute")
                //shift,
                asel = 0;
                bsel = 0;
                //ALUop,
                loadc = 0;
                loads = 0;

                // set when "writing back" to register file
                //writenum,
                write = 0; 
                //datapath_in = 0;

                // outputs
                //Z_out,
                //C

		//modification
		mdata = 0;
		//sximm8,
		//sximm5,
		PC = 0;

	`Decode:
		
		w = 0;
		nsel = 0;
		vsel = 0;
                loada = 0;
                loadb = 0;	
		//readnum,

                // computation stage (sometimes called "execute")
                //shift,
                asel = 0;
                bsel = 0;
                //ALUop,
                loadc = 0;
                loads = 0;

                // set when "writing back" to register file
                //writenum,
                write = 0; 
                datapath_in = 0;

                // outputs
                //Z_out,
                //C

		//modification
		mdata = 0;
		//sximm8,
		//sximm5,
		PC = 0;

	`GetA:

 		// register operand fetch stage
		
		w = 0;
                nsel = 3'b001;
		vsel = 0;
                loada = 1;
                loadb = 0;	
		//readnum,

                // computation stage (sometimes called "execute")
                //shift,
                asel = 0;
                bsel = 0;
                //ALUop,
                loadc = 0;
                loads = 0;

                // set when "writing back" to register file
                //writenum,
                write = 0; 
                //datapath_in = 0;

                // outputs
                //Z_out,
                //C

		//modification
		mdata = 0;
		//sximm8,
		//sximm5,
		PC = 0;

	`GetB:

		w = 0;
		nsel = 3'b010;
		vsel = 0;
                loada = 0;
                loadb = 1;	
		//readnum,

                // computation stage (sometimes called "execute")
                //shift,
                asel = 0;
                bsel = 0;
                //ALUop,
                loadc = 0;
                loads = 0;

                // set when "writing back" to register file
                //writenum,
                write = 0; 
                //datapath_in = 0;

                // outputs
                //Z_out,
                //C

		//modification
		mdata = 0;
		//sximm8,
		//sximm5,
		PC = 0;

	`WriteImm:

		w = 0;
		nsel = 3'b100;
		vsel = 0;
                loada = 0;
                loadb = 0;	
		//readnum,

                // computation stage (sometimes called "execute")
                //shift,
                asel = 0;
                bsel = 0;
                //ALUop,
                loadc = 0;
                loads = 0;

                // set when "writing back" to register file
                //writenum,
                write = 1; 
                //datapath_in = 0;

                // outputs
                //Z_out,
                //C

		//modification
		mdata = 0;
		//sximm8,
		//sximm5,
		PC = 0;

	`Add:		
	
		w = 0;
		nsel = 0;
		vsel = 0;
                loada = 0;
                loadb = 0;	
		//readnum,

                // computation stage (sometimes called "execute")
                //shift = 2'b00
                asel = 0;
                bsel = 0;
                //ALUop,
                loadc = 1;
                loads = 0;

                // set when "writing back" to register file
                //writenum,
                write = 0; 
                ///datapath_in = 0;

                // outputs
                //Z_out,
                //C

		//modification
		mdata = 0;
		//sximm8,
		//sximm5,
		PC = 0;

	`WriteReg: 	

		w = 0;	
		nsel = 3'b100;
		vsel = 0;
                loada = 0;
                loadb = 0;	
		//readnum,

                // computation stage (sometimes called "execute")
                //shift,
                asel = 0;
                bsel = 0;
                //ALUop,
                loadc = 0;
                loads = 0;

                // set when "writing back" to register file
                //writenum,
                write = 1; 
                //datapath_in = 0;

                // outputs
                //Z_out,
                //C

		//modification
		mdata = 0;
		//sximm8,
		//sximm5,
		PC = 0;

	endcase
	