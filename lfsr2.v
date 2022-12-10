module lfsr2(clk, rst, rand);

input clk, rst;
output reg [7:0] rand;

always @(posedge clk or negedge rst)
begin
	if (rst == 1'b0)
		rand <= 8'd11111111;
	else
		rand <= {rand[1] ^ rand[5] ^ rand[7],                      
				  rand[3:2], 													   
				  (rand[4] ^ rand[1] ^ rand[3] ^ rand[4] ^ rand[7]), 
				  rand[1:0],													  
				  (rand[5] ^ rand[1] ^ rand[2] ^ rand[1]), 			  
				  (rand[6] ^ rand[4] ^ rand[2])};				  
end
endmodule
