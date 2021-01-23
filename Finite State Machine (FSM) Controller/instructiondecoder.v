module instructiondecoder (outtid, nsel, opcode, op, writenum, readnum, sximm5, sximm8,  ALUop, shift);

input [15:0] outtid;
input [2:0] nsel;

output [2:0] opcode;
output [1:0] op;

wire [2:0] Rm;
wire [2:0] Rd;
wire [2:0] Rn;
wire [2:0] out;
output [2:0] writenum;
output [2:0] readnum;

wire [7:0] imm8;
wire [4:0] imm5;
output [15:0] sximm8; //signed?
output [15:0] sximm5; //signed?

output [1:0] ALUop;
output [1:0] shift;

assign opcode = outtid[15:13];
assign op = outtid[12:11];
assign Rm = outtid[2:0];
assign Rd = outtid[7:5];
assign Rn = outtid[10:8];
assign shift = outtid[4:3];
assign imm8 = outtid[7:0];
assign imm5 = outtid[4:0];

modifiedmux #(3) modifiedmuxinstance(Rn, Rd, Rm, nsel, out);

assign readnum = out;
assign writenum = out;
 
assign sximm5 = {{(16-5+1){imm5[5-1]}},imm5[3:0]}; //Page 222
assign sximm8 = {{(16-8+1){imm8[8-1]}},imm8[7:0]}; //Page 222

assign ALUop = outtid[12:11];

module modifiedmux(a, b, c, selector, out);		//module defined for Multiplexer - seperately defined because number of inputs were changed
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
endmodule

