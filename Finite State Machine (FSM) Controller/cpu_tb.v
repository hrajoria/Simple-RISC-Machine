module cpu_tb;

reg clk, reset, s, load;
reg [15:0] in;
wire [15:0] out;
wire N,V,Z,w; 

cpu cpudut(clk, reset, s, load, in, out, N, V, Z, w);

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

//Test case 1: testing ADD -> Rn = R1, Rm = R2, Rd = R5;
//load = 1 throughout
//MOV1 - move sign extended 

reset = 1;
s = 0;
load = 1;
in = 16'b1101000100000001;

#10

reset = 0;
s = 1;
in = 16'b1101000100000001;

#30

in = 16'b1101001000000010;

#30

in = 16'b1010000101101010;

#55

s = 1;

#5

//Test case 3: AND Rn = R1 (value 1) Rm = R2 (value 2) Rd = R5
reset = 1;
s = 0;
load = 1;
in = 16'b1101010000000001; 	//premature input: 16'b110 10 100 00000001;

#10

reset = 0;
s = 1;
in = 16'b1101010000000001;	//decode state

#30

in = 16'b1101000100000010;    //R2 - value 2 - 16'b11010 001 00000010

#30

in = 16'b1011010001001001;  //operation to AND 16'b101 10 100 010 01 001

#55

s = 1;

#5


//Test case 4: bitwise not and shifting
reset = 1;
s = 0;
load = 1;
in = 16'b1101000100000010; 

#10

reset = 0;
s = 1;
in = 16'b1101000100000010; //R2 - value 2 - 16'b11010 001 00000010

#30

in = 16'b1011100001001001;  //16'b101 11 000 010 01 001  - shifting and bitwise not operation; 

#55

s = 1;

#5

$stop;


end

endmodule
