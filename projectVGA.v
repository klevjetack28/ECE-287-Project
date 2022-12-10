module projectVGA(
clk, 
rst,
plot, 
VGA_R, 
VGA_G,
VGA_B,
VGA_HS,
VGA_VS,
VGA_BLANK,
VGA_SYNC,
VGA_CLK,
done,
left,
right,
start,
shoot,
seg7_dig0,
seg7_dig1,
seg7_dig2,
seg7_dig0_score,
seg7_dig1_score
);
input clk, rst, plot;
output reg done;
output [9:0] VGA_R;
output [9:0] VGA_G;
output [9:0] VGA_B;
output VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC, VGA_CLK;

output [6:0]seg7_dig0;
output [6:0]seg7_dig1;
output [6:0]seg7_dig2;
output [6:0]seg7_dig0_score;
output [6:0]seg7_dig1_score;
	
// VGA module was given to me by Chris Lallo

// Instantiations
lfsr my_lfsr_1(clk, rst, rand1);
lfsr2 my_lfsr_2(clk, rst, rand2);
lfsr3 my_lfsr_3(clk, rst, rand3);
three_decimal_vals my_three(timer, seg7_dig0, seg7_dig1, seg7_dig2);
three_decimal_vals_score my_three_score(score, seg7_dig0_score, seg7_dig1_score);
vga_adapter my_vga(rst, clk, color, x, y, VGA_en, VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC, VGA_CLK);

// States
reg [15:0] S;
reg [15:0] NS;

// Main Variables
reg [8:0] x;
reg [7:0] y;
reg [5:0] color;
wire [31:0] rand1;
wire [31:0] rand2;
wire [31:0] rand3;
reg [63:0] score;
reg [63:0] timer;
reg [63:0] counter;
reg shoot_cond;
reg VGA_en;
reg game_rst;

// Image Variables
reg [63:0] backgroundX;
reg [63:0] backgroundY;
reg [63:0] end_backgroundX;
reg [63:0] end_backgroundY;
reg [63:0] car_imageX;
reg [63:0] car_imageY;
reg [63:0] obstacle_1_imageX;
reg [63:0] obstacle_1_imageY;
reg [63:0] obstacle_2_imageX;
reg [63:0] obstacle_2_imageY;
reg [63:0] obstacle_3_imageX;
reg [63:0] obstacle_3_imageY;
reg [63:0] bullet_imageX;
reg [63:0] bullet_imageY;
reg [63:0] init_obstacle_1_imageX;
reg [63:0] init_obstacle_2_imageX;
reg [63:0] init_obstacle_3_imageX;
reg [63:0] init_bullet_imageX;

// Image Constants
parameter init_car_imageX = 64'd150,
			 init_car_imageY = 64'd190,
			 init_obstacle_1_imageY = 64'd1,
			 init_obstacle_2_imageY = 64'd1,
			 init_obstacle_3_imageY = 64'd1,
			 init_bullet_imageY = 64'd199,
			 carHieght = 64'd30,
			 carLength = 64'd15,
			 obstacle_1_Hieght = 64'd20,
			 obstacle_1_Length = 64'd45,
			 obstacle_2_Hieght = 64'd25,
			 obstacle_2_Length = 64'd25,
			 obstacle_3_Hieght = 64'd35,
			 obstacle_3_Length = 64'd20,
			 bulletLength = 64'd5,
			 bulletHieght = 64'd5;
			 
			 
// Input Variables
input left, right, start, shoot;
	
// This video was a huge help in figuring out movement https://youtu.be/PDgg1SN8g6s
	
// Misc	
wire refresh_tick;
assign refresh_tick = ((y == 241) && (x == 0)) ? 1 : 0;

reg [63:0] car_x_reg, car_y_reg;
wire [63:0] car_x_next, car_y_next;
assign car_x_next = (refresh_tick) ? car_x_reg + car_x_delta_reg : car_x_reg;
assign car_y_next = (refresh_tick) ? car_y_reg + car_y_delta_reg : car_y_reg;


reg [63:0] car_x_delta_reg, car_y_delta_reg;
reg [63:0] car_x_delta_next, car_y_delta_next;

wire [63:0] car_x_l, car_x_r; // Left and Right bounds
wire [63:0] car_y_t, car_y_b; // Top and Bottom bounds
assign car_x_l = car_x_reg;
assign car_x_r = car_x_l + carLength - 1'd1;
assign car_y_t = car_imageY;
assign car_y_b = car_y_t + carHieght - 1'd1;
//----------------------------------------------------------------------------------------------------------------------------
reg [63:0] obstacle_1_x_reg, obstacle_1_y_reg;
wire [63:0] obstacle_1_x_next, obstacle_1_y_next;
assign obstacle_1_x_next = (refresh_tick) ? obstacle_1_x_reg + obstacle_1_x_delta_reg : obstacle_1_x_reg;
assign obstacle_1_y_next = (refresh_tick) ? obstacle_1_y_reg + obstacle_1_y_delta_reg : obstacle_1_y_reg;


reg [63:0] obstacle_1_x_delta_reg, obstacle_1_y_delta_reg;
reg [63:0] obstacle_1_x_delta_next, obstacle_1_y_delta_next;

wire [63:0] obstacle_1_x_l, obstacle_1_x_r; // Left and Right bounds
wire [63:0] obstacle_1_y_t, obstacle_1_y_b; // Top and Bottom bounds
assign obstacle_1_x_l = obstacle_1_imageX;
assign obstacle_1_x_r = obstacle_1_x_l + obstacle_1_Length - 1'd1;
assign obstacle_1_y_t = obstacle_1_y_reg;
assign obstacle_1_y_b = obstacle_1_y_t + obstacle_1_Hieght - 1'd1;
//----------------------------------------------------------------------------------------------------------------------------
reg [63:0] obstacle_2_x_reg, obstacle_2_y_reg;
wire [63:0] obstacle_2_x_next, obstacle_2_y_next;
assign obstacle_2_x_next = (refresh_tick) ? obstacle_2_x_reg + obstacle_2_x_delta_reg : obstacle_2_x_reg;
assign obstacle_2_y_next = (refresh_tick) ? obstacle_2_y_reg + obstacle_2_y_delta_reg : obstacle_2_y_reg;


reg [63:0] obstacle_2_x_delta_reg, obstacle_2_y_delta_reg;
reg [63:0] obstacle_2_x_delta_next, obstacle_2_y_delta_next;

wire [63:0] obstacle_2_x_l, obstacle_2_x_r; // Left and Right bounds
wire [63:0] obstacle_2_y_t, obstacle_2_y_b; // Top and Bottom bounds
assign obstacle_2_x_l = obstacle_2_imageX;
assign obstacle_2_x_r = obstacle_2_x_l + obstacle_2_Length - 1'd1;
assign obstacle_2_y_t = obstacle_2_y_reg;
assign obstacle_2_y_b = obstacle_2_y_t + obstacle_2_Hieght - 1'd1;
//----------------------------------------------------------------------------------------------------------------------------
reg [63:0] obstacle_3_x_reg, obstacle_3_y_reg;
wire [63:0] obstacle_3_x_next, obstacle_3_y_next;
assign obstacle_3_x_next = (refresh_tick) ? obstacle_3_x_reg + obstacle_3_x_delta_reg : obstacle_3_x_reg;
assign obstacle_3_y_next = (refresh_tick) ? obstacle_3_y_reg + obstacle_3_y_delta_reg : obstacle_3_y_reg;


reg [63:0] obstacle_3_x_delta_reg, obstacle_3_y_delta_reg;
reg [63:0] obstacle_3_x_delta_next, obstacle_3_y_delta_next;

wire [63:0] obstacle_3_x_l, obstacle_3_x_r; // Left and Right bounds
wire [63:0] obstacle_3_y_t, obstacle_3_y_b; // Top and Bottom bounds
assign obstacle_3_x_l = obstacle_3_imageX;
assign obstacle_3_x_r = obstacle_3_x_l + obstacle_3_Length - 1'd1;
assign obstacle_3_y_t = obstacle_3_y_reg;
assign obstacle_3_y_b = obstacle_3_y_t + obstacle_3_Hieght - 1'd1;
//----------------------------------------------------------------------------------------------------------------------------
reg [63:0] bullet_x_reg, bullet_y_reg;
wire [63:0] bullet_x_next, bullet_y_next;
assign bullet_x_next = (refresh_tick) ? bullet_x_reg + bullet_x_delta_reg : bullet_x_reg;
assign bullet_y_next = (refresh_tick) ? bullet_y_reg - bullet_y_delta_reg : bullet_y_reg;


reg [63:0] bullet_x_delta_reg, bullet_y_delta_reg;
reg [63:0] bullet_x_delta_next, bullet_y_delta_next;

wire [63:0] bullet_x_l, bullet_x_r; // Left and Right bounds
wire [63:0] bullet_y_t, bullet_y_b; // Top and Bottom bounds
assign bullet_x_l = bullet_imageX;
assign bullet_x_r = bullet_x_l + bulletLength - 1'd1;
assign bullet_y_t = bullet_y_reg;
assign bullet_y_b = bullet_y_t + bulletHieght - 1'd1;

parameter START = 16'd0,
			 DRAW = 16'd1,
			 XCOND = 16'd2,
			 XADD = 16'd3,
			 YADD = 16'd4,
			 YCOND = 16'd5,
			 EXIT = 16'd6,
//----------------------------------------------------------------------------------------------------------------------------			 
			 CAR_START = 16'd7,
			 CAR_DRAW = 16'd8,
			 CAR_XADD = 16'd9,
			 CAR_YADD = 16'd10,
			 CAR_YCOND = 16'd11,
			 CAR_VELOCITY = 16'd12,
			 CAR_BUFFER = 16'd13,
			 CAR_EXIT = 16'd14,
//----------------------------------------------------------------------------------------------------------------------------
			 OBSTACLE_1_START = 16'd15,
			 OBSTACLE_1_DRAW = 16'd16,
			 OBSTACLE_1_XADD = 16'd17,
			 OBSTACLE_1_YADD = 16'd18,
			 OBSTACLE_1_XCOND = 16'd19,
			 OBSTACLE_1_VELOCITY = 16'd20,
			 OBSTACLE_1_BUFFER = 16'd21,
			 OBSTACLE_1_EXIT = 16'd22,
//----------------------------------------------------------------------------------------------------------------------------
			 OBSTACLE_2_START = 16'd23,
			 OBSTACLE_2_DRAW = 16'd24,
			 OBSTACLE_2_XADD = 16'd25,
			 OBSTACLE_2_YADD = 16'd26,
			 OBSTACLE_2_XCOND = 16'd27,
			 OBSTACLE_2_VELOCITY = 16'd28,
			 OBSTACLE_2_BUFFER = 16'd29,
			 OBSTACLE_2_EXIT = 16'd30,
//----------------------------------------------------------------------------------------------------------------------------
			 OBSTACLE_3_START = 16'd31,
			 OBSTACLE_3_DRAW = 16'd32,
			 OBSTACLE_3_XADD = 16'd33,
			 OBSTACLE_3_YADD = 16'd34,
			 OBSTACLE_3_XCOND = 16'd35,
			 OBSTACLE_3_VELOCITY = 16'd36,
			 OBSTACLE_3_BUFFER = 16'd37,
			 OBSTACLE_3_EXIT = 16'd38,
//----------------------------------------------------------------------------------------------------------------------------
			 COLLISION_COND = 16'd39,
			 GAME_RESET = 16'd40,
//----------------------------------------------------------------------------------------------------------------------------
			 END_BACKGROUND_START = 16'd41,
			 END_BACKGROUND_DRAW = 16'd42,
			 END_BACKGROUND_XCOND = 16'd43,
			 END_BACKGROUND_XADD = 16'd44,
			 END_BACKGROUND_YADD = 16'd45,
			 END_BACKGROUND_YCOND = 16'd46,
			 END_BACKGROUND_EXIT = 16'd47,
//----------------------------------------------------------------------------------------------------------------------------
			 BULLET_START = 16'd48,
			 BULLET_DRAW = 16'd49,
			 BULLET_XADD = 16'd50,
			 BULLET_YADD = 16'd51,
			 BULLET_XCOND = 16'd52,
			 BULLET_VELOCITY = 16'd53,
			 BULLET_BUFFER = 16'd54,
			 BULLET_EXIT = 16'd55;
			 
// Jacob Gardener gave me the always block to stop my VGA from flickering
always @ (*)
begin
	if ((backgroundX >= (init_car_imageX + car_imageX + car_x_delta_next) && 
		 backgroundX <= (init_car_imageX + car_imageX + car_x_delta_next + carLength + 1'd1) &&
		 backgroundY >= (init_car_imageY + car_imageY) && 
		 backgroundY <= (init_car_imageY + car_imageY + carHieght)) ||
		 
		 (backgroundX >= (init_obstacle_1_imageX + obstacle_1_imageX - obstacle_1_Length - 1'd1) &&
		 backgroundX <= (init_obstacle_1_imageX + obstacle_1_imageX) &&
		 backgroundY >= (init_obstacle_1_imageY + obstacle_1_imageY + obstacle_1_y_delta_next) && 
		 backgroundY <= (init_obstacle_1_imageY + obstacle_1_imageY + obstacle_1_y_delta_next + obstacle_1_Hieght)) || 
		 
		 (backgroundX >= (init_obstacle_2_imageX + obstacle_2_imageX - obstacle_2_Length - 1'd1) && 
		 backgroundX <= (init_obstacle_2_imageX + obstacle_2_imageX) &&
		 backgroundY >= (init_obstacle_2_imageY + obstacle_2_imageY + obstacle_2_y_delta_next) && 
		 backgroundY <= (init_obstacle_2_imageY + obstacle_2_imageY + obstacle_2_y_delta_next + obstacle_2_Hieght)) ||
		 
		 (backgroundX >= (init_obstacle_3_imageX + obstacle_3_imageX - obstacle_3_Length - 1'd1) && 
		 backgroundX <= (init_obstacle_3_imageX + obstacle_3_imageX) &&
		 backgroundY >= (init_obstacle_3_imageY + obstacle_3_imageY + obstacle_3_y_delta_next) && 
		 backgroundY <= (init_obstacle_3_imageY + obstacle_3_imageY + obstacle_3_y_delta_next + obstacle_3_Hieght)) ||
		 
		 (backgroundX >= (init_bullet_imageX + bullet_imageX) && 
		 backgroundX <= (init_bullet_imageX + bullet_imageX + bulletLength + 2'd2) &&
		 backgroundY >= (init_bullet_imageY + bullet_imageY - bullet_y_delta_next) && 
		 backgroundY <= (init_bullet_imageY + bullet_imageY - bullet_y_delta_next + bulletHieght)))
		VGA_en = 1'd0;
	else
		VGA_en = 1'd1;
end	

always @(posedge clk or negedge rst)
begin
	if (rst == 1'b0)
		S <= START;
	else
		S <= NS;
end

always @(*)
begin
	case(S)
		START: 
		if (~start)
			NS = DRAW;
		else
			NS = END_BACKGROUND_START;
		DRAW: NS = XCOND;
		XCOND:
		if(backgroundX >= 9'd319)
			NS = YCOND;
		else
			NS = XADD;
		XADD: NS = DRAW;
		YCOND: 
		if(backgroundY >= 8'd241)
			NS = EXIT;
		else
			NS = YADD;
		YADD: NS = DRAW;
		EXIT: NS = CAR_START;
//----------------------------------------------------------------------------------------------------------------------------	
		CAR_START: NS = CAR_VELOCITY;
		CAR_DRAW:
		if (car_x_r >= car_imageX && car_imageX >= car_x_l)
			NS = CAR_XADD;
		else
			NS = CAR_YADD;
		CAR_XADD: NS = CAR_YCOND;
		CAR_YADD: NS = CAR_YCOND;
		CAR_YCOND: 
		if (car_imageY > carHieght)
			NS = CAR_EXIT;
		else
			NS = CAR_VELOCITY;
		CAR_VELOCITY: NS = CAR_BUFFER;
		CAR_BUFFER: NS = CAR_DRAW;
		CAR_EXIT: NS = OBSTACLE_1_START;
//----------------------------------------------------------------------------------------------------------------------------
		OBSTACLE_1_START: NS = OBSTACLE_1_DRAW;
		OBSTACLE_1_DRAW:
		if (obstacle_1_y_b >= obstacle_1_imageY && obstacle_1_imageY >= obstacle_1_y_t)
			NS = OBSTACLE_1_YADD;
		else
			NS = OBSTACLE_1_XADD;
		OBSTACLE_1_XADD: NS = OBSTACLE_1_XCOND;
		OBSTACLE_1_YADD: NS = OBSTACLE_1_XCOND;
		OBSTACLE_1_XCOND:
		if (obstacle_1_imageX > obstacle_1_Length)
			NS = OBSTACLE_1_EXIT;
		else
			NS = OBSTACLE_1_VELOCITY;
		OBSTACLE_1_VELOCITY: NS = OBSTACLE_1_BUFFER;
		OBSTACLE_1_BUFFER: NS = OBSTACLE_1_DRAW;
		OBSTACLE_1_EXIT: NS = OBSTACLE_2_START;
//----------------------------------------------------------------------------------------------------------------------------
		OBSTACLE_2_START: NS = OBSTACLE_2_DRAW;
		OBSTACLE_2_DRAW:
		if (obstacle_2_y_b >= obstacle_2_imageY && obstacle_2_imageY >= obstacle_2_y_t)
			NS = OBSTACLE_2_YADD;
		else
			NS = OBSTACLE_2_XADD;
		OBSTACLE_2_XADD: NS = OBSTACLE_2_XCOND;
		OBSTACLE_2_YADD: NS = OBSTACLE_2_XCOND;
		OBSTACLE_2_XCOND:
		if (obstacle_2_imageX > obstacle_2_Length)
			NS = OBSTACLE_2_EXIT;
		else
			NS = OBSTACLE_2_VELOCITY;
		OBSTACLE_2_VELOCITY: NS = OBSTACLE_2_BUFFER;
		OBSTACLE_2_BUFFER: NS = OBSTACLE_2_DRAW;
		OBSTACLE_2_EXIT: NS = OBSTACLE_3_START;
//----------------------------------------------------------------------------------------------------------------------------
		OBSTACLE_3_START: NS = OBSTACLE_3_DRAW;
		OBSTACLE_3_DRAW:
		if (obstacle_3_y_b >= obstacle_3_imageY && obstacle_3_imageY >= obstacle_3_y_t)
			NS = OBSTACLE_3_YADD;
		else
			NS = OBSTACLE_3_XADD;
		OBSTACLE_3_XADD: NS = OBSTACLE_3_XCOND;
		OBSTACLE_3_YADD: NS = OBSTACLE_3_XCOND;
		OBSTACLE_3_XCOND:
		if (obstacle_3_imageX > obstacle_3_Length)
			NS = OBSTACLE_3_EXIT;
		else
			NS = OBSTACLE_3_VELOCITY;
		OBSTACLE_3_VELOCITY: NS = OBSTACLE_3_BUFFER;
		OBSTACLE_3_BUFFER: NS = OBSTACLE_3_DRAW;
		OBSTACLE_3_EXIT: NS = BULLET_START;
//----------------------------------------------------------------------------------------------------------------------------
		BULLET_START: NS = BULLET_DRAW;
		BULLET_DRAW: 
		if (bullet_y_b >= bullet_imageY && bullet_imageY >= bullet_y_t)
			NS = BULLET_YADD;
		else
			NS = BULLET_XADD;
		BULLET_XADD: NS = BULLET_XCOND;
		BULLET_YADD: NS = BULLET_XCOND;
		BULLET_XCOND: 
		if (bullet_imageX > bulletLength)
			NS = BULLET_EXIT;
		else
			NS = BULLET_VELOCITY;
		BULLET_VELOCITY: NS = BULLET_BUFFER;
		BULLET_BUFFER: NS = BULLET_DRAW;
		BULLET_EXIT: NS = COLLISION_COND;
//----------------------------------------------------------------------------------------------------------------------------
		COLLISION_COND:
		if (game_rst)
			NS = GAME_RESET;
		else
			NS = DRAW;
		GAME_RESET: NS = END_BACKGROUND_START;
//----------------------------------------------------------------------------------------------------------------------------
		END_BACKGROUND_START: NS = END_BACKGROUND_DRAW;
		END_BACKGROUND_DRAW: NS = END_BACKGROUND_XCOND;
		END_BACKGROUND_XCOND:
		if(end_backgroundX >= 9'd319)
				NS = END_BACKGROUND_YCOND;
			else
				NS = END_BACKGROUND_XADD;
		END_BACKGROUND_XADD: NS = END_BACKGROUND_DRAW;
		END_BACKGROUND_YADD: NS = END_BACKGROUND_DRAW;
		END_BACKGROUND_YCOND:
		if(end_backgroundY >= 8'd241)
			NS = END_BACKGROUND_EXIT;
		else
			NS = END_BACKGROUND_YADD;
		END_BACKGROUND_EXIT: NS = START;		
	endcase
end

always @(posedge clk or negedge rst)
begin
	if (rst == 1'b0)
	begin
		color <= 6'b000000;
		backgroundX <= 64'b0;
		backgroundY <= 64'b0;
		end_backgroundX <= 64'b0;
		end_backgroundY <= 64'b0;
		car_imageX <= 64'b0;
		car_imageY <= 64'b0;
		car_x_reg <= 64'b0;
		car_y_reg <= 64'b0;
		car_x_delta_next <= 64'b0;
		car_y_delta_next <= 64'b0;
		car_x_delta_reg <= 64'b0;
		car_y_delta_reg <= 64'b0;
		obstacle_1_imageX <= 64'd0;
		obstacle_1_imageY <= 64'd0;
		obstacle_2_imageX <= 64'd0;
		obstacle_2_imageY <= 64'd0;
		obstacle_3_imageX <= 64'd0;
		obstacle_3_imageY <= 64'd0;
		bullet_x_reg <= 64'd0;
		bullet_y_reg <= 64'd0;
		obstacle_1_x_delta_next <= 64'b0;
		obstacle_1_y_delta_next <= 64'b0;
		obstacle_1_x_delta_reg <= 64'b0;
		obstacle_1_y_delta_reg <= 64'b0;
		obstacle_2_x_reg <= 64'd0;
		obstacle_2_y_reg <= 64'd0;
		obstacle_2_x_delta_next <= 64'b0;
		obstacle_2_y_delta_next <= 64'b0;
		obstacle_2_x_delta_reg <= 64'b0;
		obstacle_2_y_delta_reg <= 64'b0;
		obstacle_3_x_reg <= 64'd0;
		obstacle_3_y_reg <= 64'd0;
		obstacle_3_x_delta_next <= 64'b0;
		obstacle_3_y_delta_next <= 64'b0;
		obstacle_3_x_delta_reg <= 64'b0;
		obstacle_3_y_delta_reg <= 64'b0;
		bullet_x_reg <= 64'd0;
		bullet_y_reg <= 64'd0;
		bullet_x_delta_next <= 64'b0;
		bullet_y_delta_next <= 64'b0;
		bullet_x_delta_reg <= 64'b0;
		bullet_y_delta_reg <= 64'b0;
		score <= 64'd0;
		counter <= 64'd0;
		timer <= 64'd0;
	end
	else
	begin
		case(S)
			START:
			begin
				game_rst <= 1'd0;
				backgroundX <= 64'b0;
				backgroundY <= 64'b0;
				end_backgroundX <= 64'b0;
				end_backgroundY <= 64'b0;
				score <= 64'd0;
			end
			DRAW: 
			begin
				counter <= counter + 64'd1;
				if (counter == 17500000)
				begin
					timer <= timer + 64'd1;
					counter <= 64'd0;
				end
				color <= 6'b000000;
				x <= backgroundX;
				y <= backgroundY;
			end	
			XADD: 
			begin
				backgroundX <= backgroundX + 1'b1;
			end
			YADD:
			begin
				backgroundY <= backgroundY + 1'b1;
				backgroundX <= 64'b0;
			end
			EXIT:
			begin
				backgroundX <= 64'b0;
				backgroundY <= 64'b0;
			end
//----------------------------------------------------------------------------------------------------------------------------
			CAR_START:
			begin
				car_imageX <= 64'b0;
				car_imageY <= 64'b0;
			end
			CAR_DRAW:
			begin
				color <= 6'b101100;
				x <= init_car_imageX + car_imageX + car_x_delta_next;
				y <= init_car_imageY + car_imageY;
			end
			CAR_XADD:
			begin
				car_imageX <= car_imageX + 1'b1;
			end
			CAR_YADD:
			begin
				car_imageY <= car_imageY + 1'b1;
				car_imageX <= 64'b0;
			end
			CAR_BUFFER:
			begin
				car_x_delta_reg <= car_x_delta_next;
				car_x_reg <= car_x_next;
			end
			CAR_EXIT:
			begin
				if (~right && ~left)
				begin
					car_x_delta_next <= car_x_delta_reg;
				end
				else if (~right)
				begin
					car_x_delta_next <= (init_car_imageX + car_imageX + car_x_delta_next >= 10'd305) ? car_x_delta_next : car_x_delta_next + 64'd1;
				end
				else if (~left)
				begin
					car_x_delta_next <= (init_car_imageX + car_imageX + car_x_delta_next <= 10'd0) ? car_x_delta_next : car_x_delta_next - 64'd1;
				end
				else
				begin
					car_x_delta_next <= car_x_delta_next;
				end
				car_imageX <= 64'b0;
				car_imageY <= 64'b0;
			end	
//----------------------------------------------------------------------------------------------------------------------------
			OBSTACLE_1_START:
			begin
				obstacle_1_imageX <= 64'd0;
				obstacle_1_imageY <= 64'd0;
			end
			OBSTACLE_1_DRAW:
			begin
				color <= 6'b010101;
				x <= init_obstacle_1_imageX + obstacle_1_imageX;
				y <= init_obstacle_1_imageY + obstacle_1_imageY + obstacle_1_y_delta_next;
			end	
			OBSTACLE_1_XADD:
			begin
				obstacle_1_imageX <= obstacle_1_imageX + 1'b1;
				obstacle_1_imageY <= 64'b0; 
			end
			OBSTACLE_1_YADD:
			begin
				obstacle_1_imageY <= obstacle_1_imageY + 1'b1;
			end
			OBSTACLE_1_BUFFER:
			begin
				obstacle_1_y_delta_reg <= obstacle_1_y_delta_next;
				obstacle_1_y_reg <= obstacle_1_y_next;
			end
			OBSTACLE_1_EXIT: 
			begin
					obstacle_1_y_delta_next <= (init_obstacle_1_imageY + obstacle_1_imageY + obstacle_1_y_delta_next >= 8'd221) ? 64'd0 : obstacle_1_y_delta_next + 1'd1;
					if (obstacle_1_y_delta_next == 1'd0)
						init_obstacle_1_imageX <= (rand1 + 1'd1); 
			end
//----------------------------------------------------------------------------------------------------------------------------
			OBSTACLE_2_START:
			begin
				obstacle_2_imageX <= 64'd0;
				obstacle_2_imageY <= 64'd0;
			end
			OBSTACLE_2_DRAW:
			begin
				color <= 6'b001100;
				x <= init_obstacle_2_imageX + obstacle_2_imageX;
				y <= init_obstacle_2_imageY + obstacle_2_imageY + obstacle_2_y_delta_next;
			end	
			OBSTACLE_2_XADD:
			begin
				obstacle_2_imageX <= obstacle_2_imageX + 1'b1;
				obstacle_2_imageY <= 64'b0; 
			end
			OBSTACLE_2_YADD:
			begin
				obstacle_2_imageY <= obstacle_2_imageY + 1'b1; 
			end
			OBSTACLE_2_BUFFER:
			begin
				obstacle_2_y_delta_reg <= obstacle_2_y_delta_next;
				obstacle_2_y_reg <= obstacle_2_y_next;
			end
			OBSTACLE_2_EXIT: 
			begin
				obstacle_2_y_delta_next <= (init_obstacle_2_imageY + obstacle_2_imageY + obstacle_2_y_delta_next >= 8'd221) ? 64'd0 : obstacle_2_y_delta_next + 1'd1;
				if (obstacle_2_y_delta_next == 1'd0)
					init_obstacle_2_imageX <= (rand1 + 1'd1);
			end
//----------------------------------------------------------------------------------------------------------------------------
			OBSTACLE_3_START:
			begin
				obstacle_3_imageX <= 64'd0;
				obstacle_3_imageY <= 64'd0;
			end
			OBSTACLE_3_DRAW:
			begin
				color <= 6'b000011;
				x <= init_obstacle_3_imageX + obstacle_3_imageX;
				y <= init_obstacle_3_imageY + obstacle_3_imageY + obstacle_3_y_delta_next;
			end	
			OBSTACLE_3_XADD:
			begin
				obstacle_3_imageX <= obstacle_3_imageX + 1'b1;
				obstacle_3_imageY <= 64'b0; 
			end
			OBSTACLE_3_YADD:
			begin
				obstacle_3_imageY <= obstacle_3_imageY + 1'b1; 
			end
			OBSTACLE_3_BUFFER:
			begin
				obstacle_3_y_delta_reg <= obstacle_3_y_delta_next;
				obstacle_3_y_reg <= obstacle_3_y_next;
			end
			OBSTACLE_3_EXIT: 
			begin
				obstacle_3_y_delta_next <= (init_obstacle_3_imageY + obstacle_3_imageY + obstacle_3_y_delta_next >= 8'd221) ? 64'd0 : obstacle_3_y_delta_next + 1'd1;
				if (obstacle_3_y_delta_next == 1'd0)
					init_obstacle_3_imageX <= (rand3 + 1'd1);
			end
//----------------------------------------------------------------------------------------------------------------------------
			BULLET_START:
			begin
				bullet_imageX <= 64'd0;
				bullet_imageY <= 64'd0;
			end
			BULLET_DRAW:
			begin
				color <= 6'b111111;
				x <= init_bullet_imageX + bullet_imageX;
				y <= init_bullet_imageY + bullet_imageY - bullet_y_delta_next;
			end	
			BULLET_XADD:
			begin
				bullet_imageX <= bullet_imageX + 1'b1;
				bullet_imageY <= 64'b0; 
			end
			BULLET_YADD:
			begin
				bullet_imageY <= bullet_imageY + 1'b1; 
			end
			BULLET_BUFFER:
			begin
				bullet_y_delta_reg <= bullet_y_delta_next;
				bullet_y_reg <= bullet_y_next;
			end
			BULLET_EXIT: 
			begin
				bullet_y_delta_next <= (init_bullet_imageY + bullet_imageY - bullet_y_delta_next >= 64'd1) ? bullet_y_delta_next + 1'd1 : 64'd0;
				if (bullet_y_delta_next == 1'd0)
					init_bullet_imageX <= init_car_imageX + car_imageX + car_x_delta_next + 64'd5;
					shoot_cond <= 1'd0;
					bullet_imageX <= 64'd0;
					bullet_imageY <= 64'd0;
			end
//----------------------------------------------------------------------------------------------------------------------------
			COLLISION_COND:
			begin
				if ((((init_car_imageX + car_imageX + car_x_delta_next) >= (init_obstacle_1_imageX + obstacle_1_imageX - obstacle_1_Length - 1'd1) &&
					(init_obstacle_1_imageX + obstacle_1_imageX) >= (init_car_imageX + car_imageX + car_x_delta_next) &&
				   (init_car_imageY + car_imageY) >= (init_obstacle_1_imageY + obstacle_1_imageY + obstacle_1_y_delta_next) &&
				   (init_obstacle_1_imageY + obstacle_1_imageY + obstacle_1_y_delta_next + obstacle_1_Hieght) >= (init_car_imageY + car_imageY)) ||
					 
					((init_car_imageX + car_imageX + car_x_delta_next + carLength + 1'd1) >= (init_obstacle_1_imageX + obstacle_1_imageX - obstacle_1_Length - 1'd1) &&
					(init_obstacle_1_imageX + obstacle_1_imageX) >= (init_car_imageX + car_imageX + car_x_delta_next + carLength + 1'd1) &&
				   (init_car_imageY + car_imageY) >= (init_obstacle_1_imageY + obstacle_1_imageY + obstacle_1_y_delta_next) &&
				   (init_obstacle_1_imageY + obstacle_1_imageY + obstacle_1_y_delta_next + obstacle_1_Hieght) >= (init_car_imageY + car_imageY)) ||
					 
				   ((init_car_imageX + car_imageX + car_x_delta_next) >= (init_obstacle_1_imageX + obstacle_1_imageX - obstacle_1_Length - 1'd1) &&
				   (init_obstacle_1_imageX + obstacle_1_imageX) >= (init_car_imageX + car_imageX + car_x_delta_next) &&
				   (init_car_imageY + car_imageY + carHieght) >= (init_obstacle_1_imageY + obstacle_1_imageY + obstacle_1_y_delta_next) &&
					(init_obstacle_1_imageY + obstacle_1_imageY + obstacle_1_y_delta_next + obstacle_1_Hieght) >= (init_car_imageY + car_imageY + carHieght)) ||
					 
				   ((init_car_imageX + car_imageX + car_x_delta_next + carLength + 1'd1) >= (init_obstacle_1_imageX + obstacle_1_imageX - obstacle_1_Length - 1'd1) &&
				   (init_obstacle_1_imageX + obstacle_1_imageX) >= (init_car_imageX + car_imageX + car_x_delta_next + carLength + 1'd1) &&
				   (init_car_imageY + car_imageY + carHieght) >= (init_obstacle_1_imageY + obstacle_1_imageY + obstacle_1_y_delta_next) &&
				   (init_obstacle_1_imageY + obstacle_1_imageY + obstacle_1_y_delta_next + obstacle_1_Hieght) >= (init_car_imageY + car_imageY + carHieght))) 
					
					||
					 
					(((init_car_imageX + car_imageX + car_x_delta_next) >= (init_obstacle_2_imageX + obstacle_2_imageX - obstacle_2_Length - 1'd1) &&
					(init_obstacle_2_imageX + obstacle_2_imageX) >= (init_car_imageX + car_imageX + car_x_delta_next) &&
					(init_car_imageY + car_imageY) >= (init_obstacle_2_imageY + obstacle_2_imageY + obstacle_2_y_delta_next) &&
					(init_obstacle_2_imageY + obstacle_2_imageY + obstacle_2_y_delta_next + obstacle_2_Hieght) >= (init_car_imageY + car_imageY)) ||
					 
					((init_car_imageX + car_imageX + car_x_delta_next + carLength + 1'd1) >= (init_obstacle_2_imageX + obstacle_2_imageX - obstacle_2_Length - 1'd1) &&
					(init_obstacle_2_imageX + obstacle_2_imageX) >= (init_car_imageX + car_imageX + car_x_delta_next + carLength + 1'd1) &&
					(init_car_imageY + car_imageY) >= (init_obstacle_2_imageY + obstacle_2_imageY + obstacle_2_y_delta_next) &&
					(init_obstacle_2_imageY + obstacle_2_imageY + obstacle_2_y_delta_next + obstacle_2_Hieght) >= (init_car_imageY + car_imageY)) ||
					 
					((init_car_imageX + car_imageX + car_x_delta_next) >= (init_obstacle_2_imageX + obstacle_2_imageX - obstacle_2_Length - 1'd1) &&
					(init_obstacle_2_imageX + obstacle_2_imageX) >= (init_car_imageX + car_imageX + car_x_delta_next) &&
					(init_car_imageY + car_imageY + carHieght) >= (init_obstacle_2_imageY + obstacle_2_imageY + obstacle_2_y_delta_next) &&
					(init_obstacle_2_imageY + obstacle_2_imageY + obstacle_2_y_delta_next + obstacle_2_Hieght) >= (init_car_imageY + car_imageY + carHieght)) ||
					 
					((init_car_imageX + car_imageX + car_x_delta_next + carLength + 1'd1) >= (init_obstacle_2_imageX + obstacle_2_imageX - obstacle_2_Length - 1'd1) &&
					(init_obstacle_2_imageX + obstacle_2_imageX) >= (init_car_imageX + car_imageX + car_x_delta_next + carLength + 1'd1) &&
					(init_car_imageY + car_imageY + carHieght) >= (init_obstacle_2_imageY + obstacle_2_imageY + obstacle_2_y_delta_next) &&
					(init_obstacle_2_imageY + obstacle_2_imageY + obstacle_2_y_delta_next + obstacle_2_Hieght) >= (init_car_imageY + car_imageY + carHieght)))
					
					||
					
					(((init_car_imageX + car_imageX + car_x_delta_next) >= (init_obstacle_3_imageX + obstacle_3_imageX - obstacle_3_Length - 1'd1) &&
					(init_obstacle_3_imageX + obstacle_3_imageX) >= (init_car_imageX + car_imageX + car_x_delta_next) &&
					(init_car_imageY + car_imageY) >= (init_obstacle_3_imageY + obstacle_3_imageY + obstacle_3_y_delta_next) &&
					(init_obstacle_3_imageY + obstacle_3_imageY + obstacle_3_y_delta_next + obstacle_3_Hieght) >= (init_car_imageY + car_imageY)) ||
					
					((init_car_imageX + car_imageX + car_x_delta_next + carLength + 1'd1) >= (init_obstacle_3_imageX + obstacle_3_imageX - obstacle_3_Length - 1'd1) &&
					(init_obstacle_3_imageX + obstacle_3_imageX) >= (init_car_imageX + car_imageX + car_x_delta_next + carLength + 1'd1) &&
					(init_car_imageY + car_imageY) >= (init_obstacle_3_imageY + obstacle_3_imageY + obstacle_3_y_delta_next) &&
					(init_obstacle_3_imageY + obstacle_3_imageY + obstacle_3_y_delta_next + obstacle_3_Hieght) >= (init_car_imageY + car_imageY)) ||
					
					((init_car_imageX + car_imageX + car_x_delta_next) >= (init_obstacle_3_imageX + obstacle_3_imageX - obstacle_3_Length - 1'd1) &&
					(init_obstacle_3_imageX + obstacle_3_imageX) >= (init_car_imageX + car_imageX + car_x_delta_next) &&
					(init_car_imageY + car_imageY + carHieght) >= (init_obstacle_3_imageY + obstacle_3_imageY + obstacle_3_y_delta_next) &&
					(init_obstacle_3_imageY + obstacle_3_imageY + obstacle_3_y_delta_next + obstacle_3_Hieght) >= (init_car_imageY + car_imageY + carHieght)) ||
					
					((init_car_imageX + car_imageX + car_x_delta_next + carLength + 1'd1) >= (init_obstacle_3_imageX + obstacle_3_imageX - obstacle_3_Length - 1'd1) &&
					(init_obstacle_3_imageX + obstacle_3_imageX) >= (init_car_imageX + car_imageX + car_x_delta_next + carLength + 1'd1) &&
					(init_car_imageY + car_imageY + carHieght) >= (init_obstacle_3_imageY + obstacle_3_imageY + obstacle_3_y_delta_next) &&
					(init_obstacle_3_imageY + obstacle_3_imageY + obstacle_3_y_delta_next + obstacle_3_Hieght) >= (init_car_imageY + car_imageY + carHieght))))
					game_rst = 1'd1;
				else
					game_rst = 1'd0;
				if (((init_bullet_imageX + bullet_imageX + bulletLength + 2'd2) >= (init_obstacle_1_imageX + obstacle_1_imageX - obstacle_1_Length - 1'd1) &&
					(init_obstacle_1_imageX + obstacle_1_imageX) >= (init_bullet_imageX + bullet_imageX + bulletLength + 2'd2) &&
				   (init_bullet_imageY + bullet_imageY - bullet_y_delta_next + bulletHieght) >= (init_obstacle_1_imageY + obstacle_1_imageY + obstacle_1_y_delta_next) &&
				   (init_obstacle_1_imageY + obstacle_1_imageY + obstacle_1_y_delta_next + obstacle_1_Hieght) >= (init_bullet_imageY + bullet_imageY - bullet_y_delta_next + bulletHieght)) ||
					 
					((init_bullet_imageX + bullet_imageX + bullet_x_delta_next - bulletLength - 1'd1) >= (init_obstacle_1_imageX + obstacle_1_imageX - obstacle_1_Length - 1'd1) &&
					(init_obstacle_1_imageX + obstacle_1_imageX) >= (init_bullet_imageX + bullet_imageX + bullet_x_delta_next - bulletLength - 1'd1) &&
				   (init_bullet_imageY + bullet_imageY - bullet_y_delta_next + bulletHieght) >= (init_obstacle_1_imageY + obstacle_1_imageY + obstacle_1_y_delta_next) &&
				   (init_obstacle_1_imageY + obstacle_1_imageY + obstacle_1_y_delta_next + obstacle_1_Hieght) >= (init_bullet_imageY + bullet_imageY - bullet_y_delta_next + bulletHieght)) ||
					 
				   ((init_bullet_imageX + bullet_imageX + bulletLength + 2'd2) >= (init_obstacle_1_imageX + obstacle_1_imageX - obstacle_1_Length - 1'd1) &&
				   (init_obstacle_1_imageX + obstacle_1_imageX) >= (init_bullet_imageX + bullet_imageX + bulletLength + 2'd2) &&
				   (init_bullet_imageY + bullet_imageY - bullet_y_delta_next + bulletHieght) >= (init_obstacle_1_imageY + obstacle_1_imageY + obstacle_1_y_delta_next) &&
					(init_obstacle_1_imageY + obstacle_1_imageY + obstacle_1_y_delta_next + obstacle_1_Hieght) >= (init_bullet_imageY + bullet_imageY - bullet_y_delta_next + bulletHieght)) ||
					 
				   ((init_bullet_imageX + bullet_imageX + bullet_x_delta_next - bulletLength - 1'd1) >= (init_obstacle_1_imageX + obstacle_1_imageX - obstacle_1_Length - 1'd1) &&
				   (init_obstacle_1_imageX + obstacle_1_imageX) >= (init_bullet_imageX + bullet_imageX + bullet_x_delta_next - bulletLength - 1'd1) &&
				   (init_bullet_imageY + bullet_imageY - bullet_y_delta_next + bulletHieght) >= (init_obstacle_1_imageY + obstacle_1_imageY + obstacle_1_y_delta_next) &&
				   (init_obstacle_1_imageY + obstacle_1_imageY + obstacle_1_y_delta_next + obstacle_1_Hieght) >= (init_bullet_imageY + bullet_imageY - bullet_y_delta_next + bulletHieght)))
				begin
					init_obstacle_1_imageX <= rand1 + 1'd1;
					obstacle_1_y_delta_next <= 64'd0;
					bullet_y_delta_next <= 64'd0;
					score <= score + 64'd1;
				end
				else if (((init_bullet_imageX + bullet_imageX + bulletLength + 2'd2) >= (init_obstacle_2_imageX + obstacle_2_imageX - obstacle_2_Length - 1'd1) &&
						  (init_obstacle_2_imageX + obstacle_2_imageX) >= (init_bullet_imageX + bullet_imageX + bulletLength + 2'd2) &&
						  (init_bullet_imageY + bullet_imageY - bullet_y_delta_next) >= (init_obstacle_2_imageY + obstacle_2_imageY + obstacle_2_y_delta_next) &&
						  (init_obstacle_2_imageY + obstacle_2_imageY + obstacle_2_y_delta_next + obstacle_2_Hieght) >= (init_bullet_imageY + bullet_imageY - bullet_y_delta_next)) ||
					 
						  ((init_bullet_imageX + bullet_imageX + bullet_x_delta_next - bulletLength - 1'd1) >= (init_obstacle_2_imageX + obstacle_2_imageX - obstacle_2_Length - 1'd1) &&
					     (init_obstacle_2_imageX + obstacle_2_imageX) >= (init_bullet_imageX + bullet_imageX + bullet_x_delta_next - bulletLength - 1'd1) &&
						  (init_bullet_imageY + bullet_imageY - bullet_y_delta_next + bulletHieght) >= (init_obstacle_2_imageY + obstacle_2_imageY + obstacle_2_y_delta_next) &&
						  (init_obstacle_2_imageY + obstacle_2_imageY + obstacle_2_y_delta_next + obstacle_2_Hieght) >= (init_bullet_imageY + bullet_imageY - bullet_y_delta_next)) ||
					 
						  ((init_bullet_imageX + bullet_imageX + bulletLength + 2'd2) >= (init_obstacle_2_imageX + obstacle_2_imageX - obstacle_2_Length - 1'd1) &&
						  (init_obstacle_2_imageX + obstacle_2_imageX) >= (init_bullet_imageX + bullet_imageX + bulletLength + 2'd2) &&
						  (init_bullet_imageY + bullet_imageY + bulletHieght) >= (init_obstacle_2_imageY + obstacle_2_imageY + obstacle_2_y_delta_next) &&
						  (init_obstacle_2_imageY + obstacle_2_imageY + obstacle_2_y_delta_next + obstacle_2_Hieght) >= (init_bullet_imageY + bullet_imageY - bullet_y_delta_next + bulletHieght)) ||
					 
						  ((init_bullet_imageX + bullet_imageX + bullet_x_delta_next - bulletLength - 1'd1) >= (init_obstacle_2_imageX + obstacle_2_imageX - obstacle_2_Length - 1'd1) &&
						  (init_obstacle_2_imageX + obstacle_2_imageX) >= (init_bullet_imageX + bullet_imageX + bullet_x_delta_next - bulletLength - 1'd1) &&
						  (init_bullet_imageY + bullet_imageY - bullet_y_delta_next + bulletHieght) >= (init_obstacle_2_imageY + obstacle_2_imageY + obstacle_2_y_delta_next) &&
					     (init_obstacle_2_imageY + obstacle_2_imageY + obstacle_2_y_delta_next + obstacle_2_Hieght) >= (init_bullet_imageY + bullet_imageY - bullet_y_delta_next + bulletHieght)))
				begin
					init_obstacle_2_imageX <= rand2 + 1'd1;
					obstacle_2_y_delta_next <= 64'd0;
					bullet_y_delta_next <= 64'd0;	
					score <= score + 64'd1;
				end
				else if (((init_bullet_imageX + bullet_imageX) >= (init_obstacle_3_imageX + obstacle_3_imageX - obstacle_3_Length - 1'd1) &&
						  (init_obstacle_3_imageX + obstacle_3_imageX) >= (init_bullet_imageX + bullet_imageX) &&
						  (init_bullet_imageY + bullet_imageY - bullet_y_delta_next) >= (init_obstacle_3_imageY + obstacle_3_imageY + obstacle_3_y_delta_next) &&
						  (init_obstacle_3_imageY + obstacle_3_imageY + obstacle_3_y_delta_next + obstacle_3_Hieght) >= (init_bullet_imageY + bullet_imageY - bullet_y_delta_next)) ||
					
						  ((init_bullet_imageX + bullet_imageX + bulletLength + 2'd2) >= (init_obstacle_3_imageX + obstacle_3_imageX - obstacle_3_Length - 1'd1) &&
						  (init_obstacle_3_imageX + obstacle_3_imageX) >= (init_bullet_imageX + bullet_imageX + bulletLength + 2'd2) &&
						  (init_bullet_imageY + bullet_imageY) >= (init_obstacle_3_imageY + obstacle_3_imageY + obstacle_3_y_delta_next) &&
					     (init_obstacle_3_imageY + obstacle_3_imageY + obstacle_3_y_delta_next + obstacle_3_Hieght) >= (init_bullet_imageY + bullet_imageY - bullet_y_delta_next)) ||
					
						  ((init_bullet_imageX + bullet_imageX) >= (init_obstacle_3_imageX + obstacle_3_imageX - obstacle_3_Length - 1'd1) &&
						  (init_obstacle_3_imageX + obstacle_3_imageX) >= (init_bullet_imageX + bullet_imageX) &&
						  (init_bullet_imageY + bullet_imageY - bullet_y_delta_next + bulletHieght) >= (init_obstacle_3_imageY + obstacle_3_imageY + obstacle_3_y_delta_next) &&
					     (init_obstacle_3_imageY + obstacle_3_imageY + obstacle_3_y_delta_next + obstacle_3_Hieght) >= (init_bullet_imageY + bullet_imageY - bullet_y_delta_next + bulletHieght)) ||
					
						  ((init_bullet_imageX + bullet_imageX + bulletLength + 2'd2) >= (init_obstacle_3_imageX + obstacle_3_imageX - obstacle_3_Length - 1'd1) &&
						  (init_obstacle_3_imageX + obstacle_3_imageX) >= (init_bullet_imageX + bullet_imageX + bulletLength + 2'd2) &&
						  (init_bullet_imageY + bullet_imageY - bullet_y_delta_next + bulletHieght) >= (init_obstacle_3_imageY + obstacle_3_imageY + obstacle_3_y_delta_next) &&
						  (init_obstacle_3_imageY + obstacle_3_imageY + obstacle_3_y_delta_next + obstacle_3_Hieght) >= (init_bullet_imageY + bullet_imageY - bullet_y_delta_next + bulletHieght)))
				begin
					init_obstacle_3_imageX <= rand3 + 1'd1;
					obstacle_3_y_delta_next <= 64'd0;
					bullet_y_delta_next <= 64'd0;
					score <= score + 64'd1;
				end
			end
			GAME_RESET:
			begin
				color <= 6'b000000;
				backgroundX <= 64'b0;
				backgroundY <= 64'b0;
				end_backgroundX <= 64'b0;
				end_backgroundY <= 64'b0;
				car_imageX <= 64'b0;
				car_imageY <= 64'b0;
				car_x_reg <= 64'b0;
				car_y_reg <= 64'b0;
				car_x_delta_next <= 64'b0;
				car_y_delta_next <= 64'b0;
				car_x_delta_reg <= 64'b0;
				car_y_delta_reg <= 64'b0;
				obstacle_1_imageX <= 64'd0;
				obstacle_1_imageY <= 64'd0;
				obstacle_1_x_reg <= 64'd0;
				obstacle_1_y_reg <= 64'd0;
				obstacle_1_x_delta_next <= 64'b0;
				obstacle_1_y_delta_next <= 64'b0;
				obstacle_1_x_delta_reg <= 64'b0;
				obstacle_1_y_delta_reg <= 64'b0;
				obstacle_2_x_reg <= 64'd0;
				obstacle_2_y_reg <= 64'd0;
				obstacle_2_x_delta_next <= 64'b0;
				obstacle_2_y_delta_next <= 64'b0;
				obstacle_2_x_delta_reg <= 64'b0;
				obstacle_2_y_delta_reg <= 64'b0;
				obstacle_3_x_reg <= 64'd0;
				obstacle_3_y_reg <= 64'd0;
				obstacle_3_x_delta_next <= 64'b0;
				obstacle_3_y_delta_next <= 64'b0;
				obstacle_3_x_delta_reg <= 64'b0;
				obstacle_3_y_delta_reg <= 64'b0;
				bullet_x_reg <= 64'd0;
				bullet_y_reg <= 64'd0;
				bullet_x_delta_next <= 64'b0;
				bullet_y_delta_next <= 64'b0;
				bullet_x_delta_reg <= 64'b0;
				bullet_y_delta_reg <= 64'b0;
				bullet_x_reg <= 64'd0;
				bullet_y_reg <= 64'd0;
				bullet_x_delta_next <= 64'b0;
				bullet_y_delta_next <= 64'b0;
				bullet_x_delta_reg <= 64'b0;
				bullet_y_delta_reg <= 64'b0;
				score <= 64'b0;
				counter <= 64'd0;
				timer <= 64'd0;
			end
//----------------------------------------------------------------------------------------------------------------------------
			END_BACKGROUND_DRAW:
			begin
				color <= 6'b111111;
				x <= end_backgroundX;
				y <= end_backgroundY;
			end
			END_BACKGROUND_XADD:
			begin
				end_backgroundX <= end_backgroundX + 1'd1;
			end
			END_BACKGROUND_YADD:
			begin
				end_backgroundY <= end_backgroundY + 1'd1;
				end_backgroundX <= 64'd0;
			end
		endcase
	end
end

endmodule
