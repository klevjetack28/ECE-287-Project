# ECE-287-Project
A 2D Left to Right Shooter game! This game is made on the DE2-115 FPGA board. Project is no longer maintained

Tooltips - 

<img width="410" alt="Labels" src="https://user-images.githubusercontent.com/112716986/206824979-cb663cc2-8250-4df9-9f17-538b7f88f832.png">

Useful Controls
SW[0] - This is the restart control. When running the program you want this to always be on high unless you want to reset the program. Then, switch in off and back on again to restart the program.

KEY[0] - This is the start control. This is what you will press to start the game. When the program is launched you will be brought with a white screen. Press start and the game will start. Every time you die you will be brought back to the same white screen, and each time you will need to press start.

KEY[2] - This is the control to move right in the game. Hold it down to move right and to stop moving right stop pressing the button.

KEY[3] - This is the control to move left in the game. Hold it down to move left and to stop moving left stop pressing the button.

File Information
vga_adapter - This is a file inside of my project file that contains all of the information on the VGA. This is what I instantiated into my top level module that takes in my x and y coordinates and outputs them onto the screen.

projectVGA.v - This is my top level module that has almost my entire code inside. This contains my FSM that runs my program and has everything from a background to movement and collision.

lfsr.v - This is to generate a random number for my first object.

lfsr2.v - This is to generate a random number for my second object.

lfsr3.v - This is to generate a random number for my third object.

seven_segment.v - This is the file that displays the seven segment numbers for score and time.

three_decimal_vals - This file turns the time number into a number that the seven_segment.v file is able to read and output.

three_decimal_vals_score - This file takes in the score input and turns it into something that the seven_segment.v file is able to output.


