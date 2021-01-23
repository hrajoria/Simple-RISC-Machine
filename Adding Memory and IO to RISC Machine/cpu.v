/*
Module: CPU
Purpose: integrates decoder, FSM and instruction register and datapath module into one system that can be used in lab6_top. 
inputs: clk, reset, s, load, in
Outputs: out, N, V, Z, w. the first four are a result of the datapath module and w represents the wait state for the FSM. 
*/
`define MWRITE 1
`define MREAD 1

module cpu(clk, reset, read_data, datapath_out, N, V, Z, mem_addr, m_cmd, write_data);

input clk, reset;
input [15:0] read_data;
output [15:0] datapath_out;
output N,V,Z; 
output [8:0] mem_addr;
output [15:0] write_data;
//instructiondecoder 
wire [15:0] outtid; //16 bit instruction register output 
wire [2:0] nsel;
wire [2:0] opcode;
wire [1:0] op;

wire [2:0] writenum;
wire [2:0] readnum;

wire [15:0] sximm8; //signed?
wire [15:0] sximm5; //signed?
wire [1:0] ALUop; 

	//statemachine
	
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

//State machine modifications

wire load_ir, load_pc, reset_pc, addr_sel, load_addr;
output [1:0] m_cmd;

//PC
wire [8:0] in1;

assign in1 = 9'b0;

wire [8:0] pcout;
//wire reset_pc;
wire [8:0] next_pc;

//Data Address

wire [15:0] write_data;
//wire load_addr;
wire [8:0] dataaddout;

//tribuff

//wire [15:0] dout;
//wire [15:0] read_data;

//wire addr_sel;
//wire pcout defined above
//mem_addr defined as output above - implicit wire

wire [8:0] counterout; 
vDFFE #(16) instructionregisterinstantiation(clk, load_ir, read_data, outtid); //instruction register - out to instruction decoder

instructiondecoder instructiondecoderinstantiation(outtid, nsel, opcode, op, writenum, readnum, sximm5, sximm8,  ALUop, shift);

statemachine statemachineinstantiation(opcode, op, reset, clk,

nsel,
vsel,
mdata,
PC,

write, 

loada,
loadb,

bsel,
asel,

loadc,
loads,

//modifications
load_ir,
load_pc,
reset_pc,
addr_sel,
m_cmd,
load_addr

);


datapath DP(clk, // recall from Lab 4 that KEY0 is 1 when NOT pushed

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
                datapath_out,

		//modification //NEW
		mdata,
		sximm8,
		sximm5,
		PC
             );

//PC

Counter1 PC_counter(pcout, counterout);
Mux2a #(9) PCmux(in1, counterout, reset_pc, next_pc);
vDFFE #(9) PCinstance(clk, load_pc, next_pc, pcout);


//Data Address

vDFFE #(9) DataAddressinstance(clk, load_addr, write_data[8:0], dataaddout);
Mux2a #(9) PCDataAddressmuxinstance(pcout, dataaddout, addr_sel, mem_addr); //output);

assign write_data = datapath_out; //consider putting in always block 
assign din = write_data;

assign mdata = read_data;

endmodule 


module Counter1(in, out);

	input [8:0] in;
	output reg [8:0] out; 

always @(*) begin

	out = in + 1; 
end
endmodule


module vDFF(clk, in , out);
	parameter n = 1;
	input clk;
	input [n-1:0] in;
	output [n-1:0] out; 
	reg [n-1:0] out;

always @(posedge clk)
	out = in;
endmodule

module Mux2a(a, b, selector, out);		//module defined for Multiplexer - seperately defined because number of inputs were changed
	parameter k = 1;
	input [k-1:0] a, b;
	input selector;
	output [k-1:0] out;
	reg [k-1:0] out;

always @(*) begin				//multiplexer choice depends on selector to choose between a and b depending on the input value on selector. 
	case(selector)
		1'b1: out = a;
		1'b0: out = b;
		default: out = {k{1'bx}};
	endcase
end

endmodule
