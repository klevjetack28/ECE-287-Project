module clock_count(clock, clock_count);
input clock;
output reg [63:0] clock_count;
reg [63:0]count;

always @ (posedge clock)
begin
	count <= count + 1'd1;
	if (count == 64'd50000000)
		clock_count <= clock_count + 1'd1;
end

endmodule
