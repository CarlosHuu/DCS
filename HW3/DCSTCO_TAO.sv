module DCSTCO(
    // Input signals
	clk,
	rst_n,
    in_valid,
	target_product,
    // Output signals
    out_valid,
	ten,
	five,
	one,
	run_out_ing,
	// AHB-interconnect input signals
	ready_refri,
	ready_kitch,
	// AHB-interconnect output signals
	valid_refri,
	valid_kitch,
	product_out,
	number_out
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input        clk, rst_n ;
input        in_valid ;
input        [11:0] target_product ;
input        ready_refri ;
input        ready_kitch ;
output logic out_valid ;
output logic [3:0] ten ;
output logic five ;
output logic [2:0] one ;
output logic run_out_ing ;
output logic valid_refri ;
output logic valid_kitch ;
output logic product_out ;
output logic [5:0] number_out ; 

//---------------------------------------------------------------------
//   PARAMETER
//---------------------------------------------------------------------
parameter S_Idle = 3'd0 ;
parameter S_Enough = 3'd1 ;
parameter S_OutOfStock = 3'd2;
parameter S_OutOfStock_nugget = 3'd3 ;
parameter S_OutOfStock_fried_rice = 3'd4 ;
parameter S_OutOfStock_apple = 3'd5 ;
parameter S_OutOfStock_peach = 3'd6 ;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic [2:0] nugget, fried_rice, apple, peach;
logic[6:0] total_price;
logic[3:0] cur_state, next_state;
logic out_valid_comb;
logic [3:0] ten_comb ;
logic five_comb ;
logic [2:0] one_comb ;
logic run_out_ing_comb;
logic valid_refri_comb ;
logic valid_kitch_comb ;
logic product_out_comb ;
logic [5:0] number_out_comb ; 
logic [2:0] nugget_comb, fried_rice_comb, apple_comb, peach_comb;


//---------------------------------------------------------------------
//   DON'T MODIFIED THE REGISTER'S NAME (PRODUCT REGISTER)
//---------------------------------------------------------------------
logic [6:0] nugget_in_shop, fried_rice_in_shop ;
logic [6:0] apple_in_shop , peach_in_shop ;
//---------------------------------------------------------------------
logic [6:0] nugget_in_shop_comb, fried_rice_in_shop_comb,apple_in_shop_comb, peach_in_shop_comb;
logic nugget_enough, fried_rice_enough, apple_enough, peach_enough;
logic nugget_enough_comb, fried_rice_enough_comb, apple_enough_comb, peach_enough_comb;

//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------
always_ff @(posedge clk or negedge rst_n) begin // inventory managemant
	if(!rst_n)begin
		nugget_in_shop <= 0;
		fried_rice_in_shop <= 0;
		apple_in_shop <= 0;
		peach_in_shop <= 0;
	end
	else begin
		nugget_in_shop <= nugget_in_shop_comb;
		fried_rice_in_shop <= fried_rice_in_shop_comb;
		apple_in_shop <= apple_in_shop_comb;
		peach_in_shop <= peach_in_shop_comb;
	end
end

always_ff @( posedge clk or negedge rst_n ) begin //reset output
	if(!rst_n)begin
		cur_state <= S_Idle;
		out_valid <= 0 ;
		ten <= 0 ;
		five <= 0 ;
		one <= 0 ;
		run_out_ing <= 0 ;
		valid_refri <= 0 ;
		valid_kitch <= 0 ;
		product_out <= 0 ;
		number_out <= 0; 
		
	end
	else begin
		cur_state <= next_state;
		ten <= ten_comb;
		five <= five_comb;
		one <= one_comb;
		out_valid <= out_valid_comb;
		run_out_ing <= run_out_ing_comb;
		valid_refri <= valid_refri_comb;
		valid_kitch <= valid_kitch_comb;
		product_out <= product_out_comb;
		number_out <= number_out_comb;
	end
	
end

always_comb begin //read product 
	nugget_comb = in_valid ? target_product[11:9] : nugget;
	fried_rice_comb = in_valid ? target_product[8:6]:fried_rice;
	apple_comb = in_valid ? target_product[5:3]:apple;
	peach_comb = in_valid ? target_product[2:0]:peach;
end

always_ff @( posedge clk or negedge rst_n ) begin 
	if(!rst_n)begin
		nugget <= 0;
		fried_rice <= 0;
		apple <= 0;
		peach <= 0;
	end
	else begin
		if(in_valid)
			nugget <= nugget_comb;
			fried_rice <= fried_rice_comb;
			apple <= apple_comb;
			peach <= peach_comb;
		
	end
end

always_comb begin
	nugget_enough = (nugget_in_shop_comb >= nugget_comb);
	fried_rice_enough = (fried_rice_in_shop_comb >= fried_rice_comb);
	apple_enough = (apple_in_shop_comb >= apple_comb);
	peach_enough = (peach_in_shop_comb >= peach_comb);
end


always_comb begin 
	case(cur_state)
		S_Enough :
			fried_rice_in_shop_comb = fried_rice_in_shop - fried_rice;
		S_OutOfStock_fried_rice :
			fried_rice_in_shop_comb = 50;
		default : fried_rice_in_shop_comb = fried_rice_in_shop;
	endcase
end

always_comb begin
	case(cur_state)
		S_Enough :
			nugget_in_shop_comb = nugget_in_shop - nugget;
		S_OutOfStock_nugget :
			nugget_in_shop_comb = 50;
		default : nugget_in_shop_comb = nugget_in_shop;
	endcase
end

always_comb begin
	case(cur_state)
		S_Enough :
			apple_in_shop_comb = apple_in_shop - apple;
		S_OutOfStock_apple :
			apple_in_shop_comb = 50;
		default : apple_in_shop_comb = apple_in_shop;
	endcase
end

always_comb begin
	case(cur_state)
		S_Enough :
			peach_in_shop_comb = peach_in_shop - peach;
		S_OutOfStock_peach :
			peach_in_shop_comb = 50;
		default : peach_in_shop_comb = peach_in_shop;
	endcase
end

always_comb begin
	case(cur_state)
		S_Enough:begin
			total_price = nugget + nugget + nugget + 5 * fried_rice + 2 * apple + 4 * peach;
			ten_comb = total_price / 10;
			// five_comb = (total_price % 10) / 5;
			five_comb = (total_price % 10) >= 5 ? 1 : 0;
			one_comb = total_price % 5;
		end
		default: begin
			ten_comb = 0;
			five_comb = 0;
			one_comb = 0;
		end
	endcase
end

always_comb begin
	case(cur_state) 
	S_Idle:begin
		out_valid_comb = 0;
		run_out_ing_comb = 0;
		valid_kitch_comb = 0;
		valid_refri_comb = 0;
		number_out_comb = 0;
		product_out_comb = 0;
		if(in_valid)begin
		if(nugget_enough && fried_rice_enough && apple_enough && peach_enough) begin
			next_state = S_Enough;
			product_out_comb = 0;
			end
		else begin
		if(!nugget_enough)begin
			next_state = S_OutOfStock_nugget;
			product_out_comb = 1;
			valid_kitch_comb = 1;
			valid_refri_comb = 0;
			number_out_comb = 50 - (nugget_in_shop);
			end
		else if(!apple_enough)begin
			next_state = S_OutOfStock_apple;
			product_out_comb = 1;
			valid_refri_comb = 1;
			valid_kitch_comb = 0;
			number_out_comb = 50 - (apple_in_shop);
		end
		else if(!fried_rice_enough)begin
			next_state = S_OutOfStock_fried_rice;
			product_out_comb = 0;
			valid_kitch_comb = 1;
			valid_refri_comb = 0;
			number_out_comb = 50 - (fried_rice_in_shop);
		end
		else begin
			next_state = S_OutOfStock_peach;
			product_out_comb = 0;
			valid_refri_comb = 1;
			valid_kitch_comb = 0;
			number_out_comb = 50 - (peach_in_shop);
		end
		end
		end
		else next_state = cur_state;
	end
	S_Enough:begin
		product_out_comb = 0;
		out_valid_comb = 1;
		valid_kitch_comb = 0;
		valid_refri_comb = 0;
		run_out_ing_comb = 0;
		next_state = S_Idle;
		number_out_comb = number_out;
	end

	S_OutOfStock_nugget : begin
		run_out_ing_comb = 0;
		valid_kitch_comb = 1;
		valid_refri_comb = 0;
		out_valid_comb = 0;
		number_out_comb = number_out;
		if(valid_kitch &&ready_kitch)begin
			if(!apple_enough)begin
			next_state = S_OutOfStock_apple;
			product_out_comb = 1;
			valid_refri_comb = 1;
			valid_kitch_comb = 0;
			number_out_comb = 50 - (apple_in_shop);
			end
			else if(!fried_rice_enough)begin
			product_out_comb = 0;
			next_state = S_OutOfStock_fried_rice;
			valid_kitch_comb = 1;
			valid_refri_comb = 0;
			number_out_comb = 50 - (fried_rice_in_shop);
			end
			else if(!peach_enough)begin
			next_state = S_OutOfStock_peach;
			product_out_comb = 0;
			valid_refri_comb = 1;
			valid_kitch_comb = 0;
			number_out_comb = 50 - (peach_in_shop);
			end
			else begin
			run_out_ing_comb = 1;
			out_valid_comb = 1;
			next_state = S_Idle;
			product_out_comb = 0;
			number_out_comb = 0;
			valid_kitch_comb = 0;
			valid_refri_comb = 0;
			end
		end
		else begin 
			next_state = cur_state;
			product_out_comb = product_out;
		end
	end 
	S_OutOfStock_fried_rice : begin
		run_out_ing_comb = 0;
		valid_kitch_comb = 1;
		valid_refri_comb = 0;
		out_valid_comb = 0;
		number_out_comb = number_out;
		if(valid_kitch &&ready_kitch)begin
			if(!peach_enough)begin
			next_state = S_OutOfStock_peach;
			product_out_comb = 0;
			valid_refri_comb = 1;
			valid_kitch_comb = 0;
			number_out_comb = 50 - (peach_in_shop);
			end
			else begin
			run_out_ing_comb = 1;
			out_valid_comb = 1;
			next_state = S_Idle;
			product_out_comb = 0;
			number_out_comb = 0;
			valid_kitch_comb = 0;
			valid_refri_comb = 0;
			end
		end
		else begin 
			next_state = cur_state;
			product_out_comb = product_out;
		end
	end
	S_OutOfStock_apple : begin
		run_out_ing_comb = 0;
		valid_refri_comb = 1;
		valid_kitch_comb = 0;
		out_valid_comb = 0;
		number_out_comb = number_out;
		if(valid_refri &&ready_refri)begin
			if(!fried_rice_enough)begin
			product_out_comb = 0;
			next_state = S_OutOfStock_fried_rice;
			valid_kitch_comb = 1;
			valid_refri_comb = 0;
			number_out_comb = 50 - (fried_rice_in_shop);
			end
			else if(!peach_enough)begin
			next_state = S_OutOfStock_peach;
			product_out_comb = 0;
			valid_refri_comb = 1;
			valid_kitch_comb = 0;
			number_out_comb = 50 - (peach_in_shop);
			end
			else begin
			run_out_ing_comb = 1;
			product_out_comb = 0;
			out_valid_comb = 1;
			next_state = S_Idle;
			number_out_comb = 0;
			valid_kitch_comb = 0;
			valid_refri_comb = 0;
			end
		end
		else begin 
			next_state = cur_state;
			product_out_comb = product_out;
		end
	end
	S_OutOfStock_peach : begin
		run_out_ing_comb = 0;
		valid_refri_comb = 1;
		valid_kitch_comb = 0;
		product_out_comb = 0;
		out_valid_comb = 0;
		number_out_comb = number_out;
		if(valid_refri &&ready_refri)begin
			run_out_ing_comb = 1;
			out_valid_comb = 1;
			next_state = S_Idle;
			number_out_comb = 0;
			valid_kitch_comb = 0;
			valid_refri_comb = 0;
		end
		else begin 
			next_state = cur_state;
			product_out_comb = product_out;
		end
	end
	default: begin
		valid_kitch_comb = 0;
		valid_refri_comb = 0;
		next_state = cur_state;
		out_valid_comb = 0;
		run_out_ing_comb = 0;
		number_out_comb = number_out;
		product_out_comb = 0;
	end
	endcase
end

endmodule

