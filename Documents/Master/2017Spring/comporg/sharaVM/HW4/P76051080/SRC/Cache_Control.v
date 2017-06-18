// Cache Control

module Cache_Control ( 
					   clk,
					   rst,
					   // input
					   en_R,
					   en_W,
					   hit,
					   // output
					   Read_mem,
					   Write_mem,
					   Valid_enable,
					   Tag_enable,
					   Data_enable,
					   sel_mem_core,
					   stall
					   );
	
	input clk, rst;
	input en_R;
	input en_W;
    	input hit;
	
	output reg Read_mem;
	output reg Write_mem;
	output reg Valid_enable;
	output reg Tag_enable;
	output reg Data_enable;
	output reg sel_mem_core;	// 0 data from mem, 1 data from core
	output reg stall;
	
	// write your code here

	parameter Idle = 2'b00;
	parameter R_wait = 2'b01;
	parameter R_read = 2'b10;

	reg [1:0] curr_state;
	reg [1:0] next_state;

//state reg
	always@(negedge clk or posedge rst)
		if(rst)curr_state <= Idle;
		else	curr_state <= next_state;

// next state logic
	always@(*)begin
		case(curr_state)begin
			Idle	:if(~hit) next_state = R_wait;
					else 	next_state = Idle;
			R_wait	: if(~hit)next_state = R_wait;
					else    next_state = R_read;
			R_read	: if(~hit)next_state = R_read;
					else    next_state = Idle;
					  Valid_enable<=1;
					  Tag_enable<=1;
					  Data_enable<=1;
			default	:	  next_state = Idle;
					  
		endcase

//output logic
	always@(*)
		case(curr_state)
			Idle	:begin
						Valid_enable<=1;
						Tag_enable<=1;
						Data_enable<=1;
						sel_mem_core<=1;
					end
			R_wait :begin
						Read_mem<=1;
						Valid_enable<=0;
						Tag_enable<=0;
						Data_enable<=0;
						stall<=1;
						sel_mem_core<=0;
					end
			R_read :begin
						Read_mem<=1;
						Valid_enable<=0;
						Tag_enable<=0;
						Data_enable<=0;
						stall<=1;
						sel_mem_core<=0;
					end
			
			
		if(en_R)begin
			if(hit)begin
				sel_mem_core<=1;
			end
			else begin //read miss
				sel_mem_core<=0;
				Read_mem<=1;
				stall<=1;
			end
		end
		else if(en_W)begin
			if(hit)begin
				Valid_enable<=1;
				Tag_enable<=1;
				Data_enable<=1;
				sel_mem_core<=1;
			end
			else begin //WRITE miss
				sel_mem_core<=0;
				Write_mem<=1;
				stall<=1;
			end
		end
		
	end
	
endmodule



















