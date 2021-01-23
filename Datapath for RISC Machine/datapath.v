module datapath (clk, // recall from Lab 4 that KEY0 is 1 when NOT pushed

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

	input vsel; //9
	input [15:0] datapath_in;
	wire [15:0] data_in;

	input [2:0]  writenum;	//1
	input write;
	input clk;
	input [2:0] readnum;
	wire [15:0] data_out;

	input loada; //3
	wire [15:0] outa;

	input loadb; //3
	wire [15:0] outb; 

	input [1:0] shift; //8
	wire [15:0] sout; 

	input bsel; //7
	wire [15:0] Bin; 

	input asel; //6
	wire [15:0] Ain;

	input [1:0] ALUop; //2
	wire [15:0] out;
	wire Z;

	input loadc; //5
	output [15:0] datapath_out; 
	//wire [15:0] datapath_out;

	input loads; //10
	output Z_out;

//assign datapath_in = 16'b0000000000000001;
//assign datapath_out = 16'b0000000000000000;

//assign vsel = 1;

Mux3a #(16) muxnine(datapath_in, datapath_out, vsel, data_in); //9 - working

//assign data_in = vsel? datapath_in:datapath_out;
//assign writenum = 3'b001;
//assign write = 1;
//assign readnum = 3'b001;
//assign clk = 1;

regfile REGFILE(data_in,writenum,write,readnum,clk,data_out); //1 - currently problematic

//assign data_out = 16'b0000000000000001;
//assign loada = 1;        

vDFFEx #(16) rlea(clk, loada, data_out, outa); //3 - currently problematic
Mux3a #(16) muxsix(16'b0, outa, asel, Ain); //6

//assign outa = 16'b0000000000000001;
//assign asel = 0;

vDFFEx #(16) rleb(clk, loadb, data_out, outb); //4 - currently problematic
shifter shifterinstance(outb, shift, sout); //8 - currently problematic 
Mux3a #(16) muxseven({11'b0, datapath_in[4:0]}, sout, bsel, Bin); //9

//assign outb = 16'b0000000000000001;
//assign shift = 01; 
//assign bsel = 0;

//assign ALUop = 00;

ALU aluinstance(Ain, Bin, ALUop, out, Z); //2

//assign loadc = 1;

vDFFEx #(16) rlec(clk, loadc, out, datapath_out); //error 1 - 5
vDFFEx #(1) status(clk, loads, Z, Z_out);

endmodule 

module vDFFEx(clk, load, in, out);
	parameter n = 1;
	input clk, load;
	input [n-1:0] in;
	output [n-1:0] out;
	reg [n-1:0] out;
	wire [n-1:0] next_out;

	assign next_out = load ? in : out;

	always @(posedge clk)
	out = next_out;
endmodule 

module Mux3a(a, b, selector, out);
	parameter k = 1;
	input [k-1:0] a, b;
	input selector;
	output [k-1:0] out;
	reg [k-1:0] out;

always @(*) begin
	case(selector)
		1'b1: out = a;
		1'b0: out = b;
		default: out = {k{1'bx}};
	endcase
end

endmodule 

