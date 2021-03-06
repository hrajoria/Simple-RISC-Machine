/*Instruction decoder module
Purpose: extract information from the information register specifying the instruction set so that relevant bits can be assigned to different systems 
in order to control datapath. 
*/
module instructiondecoder (outtid, nsel, opcode, op, writenum, readnum, sximm5, sximm8,  ALUop, shift);

input [15:0] outtid;	/*output to instruction decoder: the 16 bit instruction is split into respective groups of bits that travel to elements like the FSM and datapath*/
input [2:0] nsel;		/*selects between Rm and Rn and Rd from the instruction register depending on the state of the FSM. */

output [2:0] opcode;	/*determines the operation to be performed along with specification from op. */
output [1:0] op;

wire [2:0] Rm;			
wire [2:0] Rd;
wire [2:0] Rn;
wire [2:0] out;
output [2:0] writenum;
output [2:0] readnum;

wire [7:0] imm8;
wire [4:0] imm5;
output [15:0] sximm8; 	/*input number coming from the instruction set (signed to 16 bits)*/
output [15:0] sximm5; 	/*signed number generated from instruction set*/

output [1:0] ALUop;		/*determines the ALU operation to be performed by the ALU unit in datapath.*/ 
output [1:0] shift;		/*shift instruction from a component of outtid that determines whether to shift the input right, left or not at all. */

assign opcode = outtid[15:13];			/*all the wires defined previously are assigned components of the instruction set that are relevant using relevant bits of the personally developed outtid bus.*/ 
assign op = outtid[12:11];
assign Rm = outtid[2:0];
assign Rd = outtid[7:5];
assign Rn = outtid[10:8];
assign shift = outtid[4:3];
assign imm8 = outtid[7:0];
assign imm5 = outtid[4:0];

modifiedmuxid #(3) modifiedmuxinstance(Rn, Rd, Rm, nsel, out);		/*Instantiating the multiplexer within the decoder diagram. It has 3 ports instead of two or four hence needs to be seperately defined and instantiated*/

assign readnum = out;
assign writenum = out;
 
assign sximm5 = {{(16-5+1){imm5[5-1]}},imm5[3:0]}; //Page 222  /*SIGN EXTENSION of the imm5 and imm8 was done using logic from Dally digital design textbook chapter 10.3*/ 
assign sximm8 = {{(16-8+1){imm8[8-1]}},imm8[6:0]}; //Page 222 	

assign ALUop = outtid[12:11];

endmodule

module modifiedmuxid(a, b, c, selector, out);		//module defined for Multiplexer - seperately defined because number of inputs to the mux in the instruction block were changed
	parameter k = 1;
	input [k-1:0] a, b, c;
	input [2:0] selector;
	output [k-1:0] out;
	reg [k-1:0] out;

always @(*) begin				//multiplexer choice depends on selector to choose between a and b depending on the input value on selector. 
	case(selector)
		3'b100: out = a;
		3'b010: out = b;
		3'b001: out = c;
		default: out = {k{1'bx}};
	endcase
end

endmodule 

