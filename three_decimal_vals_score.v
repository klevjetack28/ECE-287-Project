module three_decimal_vals_score (
input [7:0]val,
output [0:6]seg7_dig0,
output [0:6]seg7_dig1
);

reg [3:0] result_one_digit;
reg [3:0] result_ten_digit;

always @(*)
begin
	result_one_digit = val % 10;
	result_ten_digit = val / 10;	
end

seven_segment seven_segment_one_digit (result_one_digit, seg7_dig0);
seven_segment seven_segment_ten_digit (result_ten_digit, seg7_dig1);

endmodule
