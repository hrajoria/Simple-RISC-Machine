/*
Module: cpu_tb (cpu test bench)
Purpose: to test the functionality of the cpu module

There are three test cases per instruction as specified in Table 1 of the Lab 6 document, except for MOV Rn,#<im8>, which is implicitly being tested in every case. 
*/

module cpu_tb;

reg clk, reset, s, load; //inputs to the cpu design under test instantiation below 
reg [15:0] in; //16 bit instruction set that encodes what the computer should do 
wire [15:0] out; //16 bit output of the ALU
wire N,V,Z,w; //1 bit status outputs and 1 bit wait signal - status outputs: Z (zero flag) is 1 when both inputs are equal, N (negative flag) is 1 when the ALU output is negative, V (overflow flag) is 1 when the ALU output requires more than 16 bits to represent; wait signal: w is 1 when the state machine is in the wait state

cpu cpudut(clk, reset, s, load, in, out, N, V, Z, w); //cpu design under test instantiation 

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

//TEST SET 1: AND tests

//Test set 1 - test case 1: AND not shifted

reset = 1;
s = 0;
load = 1;
in = 16'b1101000100001101; //110 10 001 (r1)  00001101 

#10

reset = 0;
s = 1;
in = 16'b1101000100001101; //110 10 001 (r1)  00001101 

#30

in = 16'b1101001000000101; //110 10 010 (r2)  00000101 

#30

in = 16'b1011000101100010; //101 10 (r1) (r3) 00 (r2) - output = 101 stored in r3

#55

s = 1;

#5

//Test set 1 - test case 2: AND shifted left

reset = 1;
s = 0;
load = 1;
in = 16'b1101000111111111; //110 10 001 (r1)  11111111

#10

reset = 0;
s = 1;
in = 16'b1101000111111111; //110 10 001 (r1)  11111111

#30

in = 16'b1101001000000001; //110 10 010 (r2)  00000001

#30

in = 16'b1011000101101010; //101 10 (r1) (r3) 01 (r2) - output = 00000010 read into R3 = Rm = 011

#55

s = 1;

#5

//Test set 1 - test case 3: AND shifted right 

reset = 1;
s = 0;
load = 1;
in = 16'b1101000100000001; //110 10 001 (r1)  00000001

#10

reset = 0;
s = 1;
in = 16'b1101000100000001; //110 10 001 (r1)  00000001

#30

in = 16'b1101001000000010; //110 10 010 (r2)  00000010

#30

in = 16'b1011000101110010; //101 10 (r1) (r3) 10 (r2) - output = 00000001 read into R3 

#55

s = 1;

#5
 
//TEST SET 2: ADD tests

//Test set 2 - test case 1: ADD shifted left

reset = 1;    
s = 0;
load = 1;
in = 16'b1101000100000001;  // 11010 (r1) 00000001

#10

reset = 0;
s = 1;
in = 16'b1101000100000001; // 11010 (r1) 00000001

#30

in = 16'b1101001000000010; // 11010 (r2) 00000010

#30

in = 16'b1010000110101010; //10100 (r1) (r5) (shift left) (r2) output = 101 = 5 should be stored in r5

#55

s = 1;

#5

//Test set 2 - test case 2: ADD shifted right

reset = 1;    
s = 0;
load = 1;
in = 16'b1101001000000010; // 11010 (r2) 00000010

#10

reset = 0;
s = 1;
in = 16'b1101001000000010; // 11010 (r2) 00000010

#30

in = 16'b1101011000001000; // 11010 (r6) 00001000

#30

in = 16'b1010001011110110; // 10100 (r2) (r7) (shift right) (r6) output = 110 = 6 should be stored in r7

#55

s = 1;

#5

//Test case 2 - test case 3: ADD no shift 

reset = 1;    
s = 0;
load = 1;
in = 16'b1101011100100000; // 11010 (r7) 00100000

#10

reset = 0;
s = 1;
in = 16'b1101011100100000; // 11010 (r7) 00100000

#30

in = 16'b1101001000011001; // 11010 (r2) 00011001

#30

in = 16'b1010011100100010; // 10100 (r7) (r1) (no shift) (r2) output = 0000000000111001 = '57' should be stored in r1

#55

s = 1;

#5

//TEST SET 3: CMP tests

//Test set 3 - test case 1: CMP two equal values 

reset = 1;
s = 0;
load = 1;
in = 16'b1101000111111111; // 110 10 (r1) 11111111

#10

reset = 0;
s = 1;
in = 16'b1101000111111111; //110 10 (r1) 11111111

#30

in = 16'b1101001011111111; //110 10 (r2) 11111111

#30

in = 16'b1010100100000010; //10101 (r1) 00000 (r2) - expected output: Z == 1, N, V == 0

#45

s = 1;

#5

//Test set 3 - test case 2: CMP for overflow

reset = 1;
s = 0;
load = 1;
in = 16'b1101000110000010;

#10

reset = 0;
s = 1;
in = 16'b1101000110100010;

#30

in = 16'b1101001010101000;

#30

in = 16'b1010100100000010; // 101 01 (r1) 00000 (r2) - expected output: V == 1, N, Z == 0

#45

s = 1;

#5

//Test set 3 - test case 3: CMP for negative numbers 

reset = 1;
s = 0;
load = 1;
in = 16'b1101000100000011;

#10

reset = 0;
s = 1;
in = 16'b1101000100000011;

#30

in = 16'b1101001000000110;

#30

in = 16'b1010100100000010; // 101 01 (r1) 00000 (r2) - subtracting 6 from 3, expected output: N == 1, V, Z == 0

#45

s = 1;

#5

//TEST SET 4: MVN tests

//Test set 4 - test case 1: MVN shifting left

reset = 1;
s = 0;
load = 1;
in = 16'b1101000100000010; 

#10

reset = 0;
s = 1;
in = 16'b1101000100000010; // 16'b11010 (r1) 00000010

#30

in = 16'b1011100001001001;  //16'b101 11 000 (r2) (shift left) (r1)  - output = 1111111111111011 stored in r2

#45

s = 1;

#5

//Test set 4 - test case 2: MVN shifting right 

reset = 1;
s = 0;
load = 1;
in = 16'b1101000100000010; 

#10

reset = 0;
s = 1;
in = 16'b1101001000000101; // 16'b11010 (r2) 00000101

#30

in = 16'b1011100010110010;  //16'b101 11 000 (r5) (shift right) (r2)  - output = 11111101

#45

s = 1;

#5

//Test set 4 - test case 3: MVN no shifting

reset = 1;
s = 0;
load = 1;
in = 16'b1101011111111111; 

#10

reset = 0;
s = 1;
in = 16'b1101011111111111; // 11010 (r7) 11111111

#30

in = 16'b1011100010100111;  //16'b101 11 000 (r5) (no shift) 001  - output = 00000000 stored in r5

#45

s = 1;

#5

//TEST SET 5: MOVSHIFT tests

//Test set 5 - test case 1: MOVSHIFT shift left 

reset = 1;
s = 0;
load = 1;
in = 16'b1101000100000001; 

#10

reset = 0;
s = 1;
in = 16'b1101000100000001; //110 10 (r1) 0000001

#30

in = 16'b1100000001001001; //110 00 000 (r2) (shift left) (r1) - output = '2' stored in r2

#45 

s = 1;

#5

//Test set 5 - test case 2: MOVSHIFT shift right

reset = 1;
s = 0;
load = 1;
in = 16'b1101010001000000; 

#10

reset = 0;
s = 1;
in = 16'b1101010001000000; //11010 (r4) 10000000

#30

in = 16'b1100000010110100; //110 00 000 (r5) (shift right) (r4) - output = 0000000001000000 stored in r5

#45 

s = 1;

#5

//Test set 5 - test case 3: MOVSHIFT  no shift 

reset = 1;
s = 0;
load = 1;
in = 16'b1101000100000111;	

#10

reset = 0;
s = 1;
in = 16'b1101000100000111; // 11010 (r1) 00000111

#30

in = 16'b1100000011100001; // 110 00 000 (r7) (no shift) (r1) - output = 00000111 stored in r7

#45 

s = 1;

#5

$stop;

end

endmodule




