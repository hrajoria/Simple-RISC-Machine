/*
Module: CPU
Purpose: integrates decoder, FSM and instruction register and datapath module into one system that can be used in lab6_top. 
inputs: clk, reset, s, load, in
Outputs: out, N, V, Z, w. the first four are a result of the datapath module and w represents the wait state for the FSM. 
*/
`define MWRITE 1
`define MREAD 1

module cpu(clk, reset, read_data, datapath_out, N, V, Z, mem_addr, m_cmd, write_data, halt);

input clk, reset;
input [15:0] read_data;
output [15:0] datapath_out;
output N,V,Z; 
output [8:0] mem_addr;

output halt; //to switch on LEDR8

//instructiondecoder 
wire [15:0] outtid; //16 bit instruction register output 
wire [2:0] nsel;
wire [2:0] opcode;
wire [1:0] op;

wire [2:0] writenum;
wire [2:0] readnum;

wire [15:0] sximm8; //signed
wire [15:0] sximm5; //signed
wire [1:0] ALUop; 

	//statemachine
	
	wire [3:0] vsel; //9
	wire [15:0] mdata;
	wire [7:0] PCin;
	wire write;
	wire loada; //3
	wire loadb; //3
	wire [1:0] shift; //8		//all inputs required by other module instantiations	
	wire bsel; //7
	wire asel; //6
	wire loadc; //5
	wire loads; //10

//State machine modifications - new outputs controlling address and read/write instructions and the program counter. 

wire load_ir, load_pc, reset_pc, addr_sel, load_addr;
output [1:0] m_cmd;

//PC
wire [8:0] in1;

assign in1 = 9'b0;	/*alternate to PC input, if we want to reset.*/ 

wire [8:0] PC;
wire [8:0] next_pc;

wire [8:0] PCinout;

//Data Address

output [15:0] write_data;
wire [8:0] dataaddout;
wire [8:0] counterout;

wire [2:0] cond;  //modification: output of decoder -> input to counter


/*All 3 hardware blocks exist in same place as Lab 6*/ 
vDFFE #(16) instructionregisterinstantiation(clk, load_ir, read_data, outtid); //instruction register - out to instruction decoder

instructiondecoder instructiondecoderinstantiation(outtid, nsel, opcode, op, writenum, readnum, sximm5, sximm8,  ALUop, shift, cond); 

statemachine FSM(opcode, op, reset, clk,

nsel,
vsel,

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
load_addr,

cond,
halt

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
		PCin
             );

//Program counter instantiations - NEW. 

Counter2 PC_counter(datapath_out, sximm8 /*(input)*/, PC /*input*/, counterout /*output*/, PCinout /*output 2*/, opcode, op, cond, Z, V, N);	 /*input: PC, output counterout*/ 

assign PCin = PCinout; 

Mux3a #(9) PCmux(in1, counterout, reset_pc, next_pc);/*multiplexer which decides whether to reset or increment.*/	

vDFFE #(9) PCinstance(clk, load_pc, next_pc, PC); /*the actual program counter register that holds and transfers appropriate values depending on the progress of the program. */

//Data Address - lower part of figure 2 - responsible for transferring address to memory. 

vDFFE #(9) DataAddressinstance(clk, load_addr, write_data[8:0], dataaddout);	/*holding or transferring the address fed from datapath module*/
Mux3a #(9) PCDataAddressmuxinstance(PC, dataaddout, addr_sel, mem_addr);	/*Mux chooses between PC address or data address. */  

//assign PCin = 0;	/*random input coming into VSEL that we are not going to use until Lab 8, set to 0 for no reason. */

assign write_data = datapath_out;  //wire assignments as in Figure 2 of Lab 7 handout

assign mdata = read_data;

/*always @(*) begin
	if(opcode == 3'b111) begin
		HALT = 1;
	end else begin
		HALT = 0;
	end
end*/

endmodule 

module Counter2(datapath_out, sximm8 /*(input)*/, PC /*input*/, counterout /*output 1*/, PCinout /*output 2*/, opcode, op, cond, Z, V, N);	/*at any change in conditions, output is incremented by 1, starting from fixed initial input value. */
input [15:0] sximm8;
input [15:0] datapath_out;
input [8:0] PC; /*reg because assigned in always block*/
output reg [8:0] counterout; output reg [8:0] PCinout; //new
input [2:0] opcode;
input [1:0] op; 
input [2:0] cond;		
input Z, V, N;

always @(*) begin
	if (opcode == 3'b001 && op == 2'b00) begin
	    if (cond == 3'b000) begin
		counterout = PC + 1'b1 + sximm8[8:0];
	    end
	    else begin
		counterout = PC + 1'b1 + sximm8[8:0];
	    end		
//2nd cond case
	    if (cond == 3'b001) begin
		if (Z == 1)  begin
		    counterout = PC + 1'b1 + sximm8[8:0];
	    	end else begin
		    counterout = PC + 1'b1;
	    	end
	    end	
//3rd cond case
	    if (cond == 3'b010) begin
		if (Z == 0) begin 
		    counterout = PC + 1'b1 + sximm8[8:0];
		end else begin
		    counterout = PC + 1'b1; 
		end
	    end
//4th cond case
	    if (cond == 3'b011) begin
		if (N != V) begin 
		    counterout = PC + 1'b1 + sximm8[8:0];
		end else begin
		    counterout = PC + 1'b1; 
		end					 
	    end 			
//5th cond case
	     if (cond == 3'b100) begin
		if ((N != V)||(Z == 1'b1)) begin 
		    counterout = PC + 1'b1 + sximm8[8:0];
		end else begin
		    counterout = PC + 1'b1; 
		end
	     end

	end else if (opcode == 3'b010 && op == 2'b11) begin
		counterout = PC + 1'b1 + sximm8;
		PCinout = PC + 1'b1;

	end else if (opcode == 3'b010 && op == 2'b00) begin
		counterout = datapath_out;
	end else begin
		counterout = PC + 1'b1;
	end
 
end

endmodule




