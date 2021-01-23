`define MWRITE 1'b1
`define MREAD 1'b1

module lab7_top(KEY, SW, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
	input [3:0] KEY;
	input [9:0] SW;
	output [9:0] LEDR;
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

//modification #1
wire [15:0] out;
wire Z, N, V;
wire [15:0] datapath_out;


//extra wires declared for new  instantitations RAM buffer etc. 
wire [15:0] read_data;
wire [7:0] read_address;
wire [7:0] write_address;
reg writemem, enabletridriv;
wire [15:0] din, dout;
wire msel;
wire [8:0] mem_addr;
wire [1:0] m_cmd;

assign read_address = mem_addr[7:0];
assign write_address = mem_addr[7:0];

RAM #(16,8) MEM(KEY[0], read_address, write_address, writemem, din, dout);

tribuff trinst(dout, enabletridriv, read_data);

cpu cpuinstance(KEY[0], 
		KEY[1], 
		read_data, 
		datapath_out, 
		N, V, Z, 
		mem_addr, 
		m_cmd);

  assign HEX5[0] = ~Z;
  assign HEX5[6] = ~N;
  assign HEX5[3] = ~V;


assign msel = (mem_addr[8] == 1'b0);

always@(*) begin

if((m_cmd[1] == `MWRITE) & (msel == 1)) begin
	writemem = 1;
end else begin
	writemem = 0;
end 

if((m_cmd[0] == `MREAD) & (msel == 1)) begin
	enabletridriv = 1;
end else begin
	enabletridriv = 0;
end 

end

endmodule			

module tribuff(inp, en, outp);
	input [15:0] inp;
	input en;
	output [15:0] outp;

	assign outp = en? inp: 16'bz;

endmodule

module RAM(clk, read_address, write_address, write, din, dout);
	parameter data_width = 32;
	parameter addr_width = 4;
	parameter filename = "lab7instructionset.txt";

	input clk;
	input [addr_width-1:0] read_address, write_address;
	input write;
	input [data_width-1:0] din;
	output [data_width-1:0] dout;
	reg [data_width-1:0] dout;

	reg[data_width-1:0] mem [2**addr_width-1:0];
	
	initial $readmemb(filename, mem);

	always@(posedge clk) begin
		if(write)
			mem[write_address] <= din;
		dout<= mem[read_address];

	end
endmodule 


