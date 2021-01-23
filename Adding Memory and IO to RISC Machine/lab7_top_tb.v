module lab7_top_tb;
	
	reg [3:0] KEY;
	reg [9:0] SW;
	wire [9:0] LEDR;
	wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

lab7_top DUT(KEY, SW, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);

initial begin

forever begin

KEY[0] = 0; //clock low
#5;
KEY[0] = 1; //clock high
#5;

end

end

initial begin

KEY[1] = 1; //reset high

#10;

KEY[1] = 0; //reset low

#2000;

$stop;

end

endmodule 