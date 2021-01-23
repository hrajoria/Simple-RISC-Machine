module cpu(clk, reset, s, load, in, out, N, V, Z, w);

input clk, reset, s, load;
input [15:0] in;
output [15:0] out;
output N,V,Z,w; 

//instructiondecoder 
wire [15:0] outtid; //16 bit instruction register output
wire [2:0] nsel;
wire [2:0] opcode;
wire [1:0] op;
//wire [2:0] Rm;
//wire [2:0] Rd;
//wire [2:0] Rn;
//wire [2:0] out;
wire [2:0] writenum;
wire [2:0] readnum;
//wire [7:0] imm8;
//wire [4:0] imm5;
wire [15:0] sximm8; //signed?
wire [15:0] sximm5; //signed?
wire [1:0] ALUop; 

	//statemachine
	//wire [2:0] opcode; //assume 101 = ALU
	//wire [1:0] op;// assume 00 = ADD
	//wire s;
	//wire reset;
	//wire [4:0] present_state; 
	//wire [2:0] nsel;
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

	//datapath
	//wire [3:0] vsel; //9
	//wire [15:0] mdata;
	//wire [15:0] sximm8; //NOT ASSIGNED
	//wire [7:0] PC;
	//wire [15:0] data_in;
	//wire [15:0] sximm5; //NOT ASSIGNED
	//wire [2:0] writenum;	//1
	//wire write;
	//input clk;
	//wire [2:0] readnum;
	//wire [15:0] data_out;
	//wire loada; //3
	//wire [15:0] outa;
	//wire loadb; //3
	//wire [15:0] outb; 
	//wire [1:0] shift; //8		//all inputs required by other module instantiations
	//wire [15:0] sout; 		
	//wire bsel; //7
	//wire [15:0] Bin; 
	//wire asel; //6
	//wire [15:0] Ain;		//all internal signals are declared as wires.
	//wire [1:0] ALUop; //2
	//wire [15:0] out;
	//wire Z, V, N;
	//wire loadc; //5
	//output [15:0] out; 
	//wire loads; //10
	//output Z, V, N;

vDFFE #(16) instructionregisterinstantiation(clk, load, in, outtid); //instruction register - out to instruction decoder
instructiondecoder instructiondecoderinstantiation(outtid, nsel, opcode, op, writenum, readnum, sximm5, sximm8,  ALUop, shift);
statemachine statemachineinstantiation(opcode, op, s, reset, w, clk,
nsel,
vsel,
mdata,
PC,
write, 
clk,
loada,
loadb,
bsel,
asel,
loadc,
loads
);
datapath datapathinstantiation(clk, // recall from Lab 4 that KEY0 is 1 when NOT pushed

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

                // outputs
                Z, V, N,
                out,

		//modification
		mdata,
		sximm8,
		sximm5,
		PC
             );

endmodule			

module vDFFE(clk, load, in, storedval);
	parameter n = 1;
	input clk, load;
	input [n-1:0] in;
	output [n-1:0] storedval;
	reg [n-1:0] storedval;
	wire [n-1:0] next_out;

	assign next_out = load ? in : storedval;

	always @(posedge clk)
	storedval = next_out;
endmodule 
