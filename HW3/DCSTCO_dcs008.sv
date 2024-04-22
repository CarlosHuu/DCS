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
parameter S_IDLE = 3'b000,
		  S_InStock = 3'b001,
		  S_OutOfStock = 3'b010,
		  S_OutOfStock_nugget = 3'b011,
		  S_OutOfStock_fried_rice = 3'b100,
		  S_OutOfStock_apple = 3'b101,
		  S_OutOfStock_peach = 3'b110;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic [2:0] next_state, cur_state; 
logic [6:0] Number_nugget, Number_fried_rice, Number_apple, Number_peach;
logic [6:0] nugget_in_shop_comb, fried_rice_in_shop_comb, apple_in_shop_comb , peach_in_shop_comb;
logic [6:0] total_money;
logic in_stock_nug, in_stock_fri, in_stock_app, in_stock_pea;
logic in_stock_nug_bef, in_stock_fri_bef, in_stock_app_bef, in_stock_pea_bef;
logic InStock;
logic [3:0] ten_comb;
logic five_comb;
logic [2:0] one_comb;
logic [3:0] rem_ten;
logic [2:0] rem_five;
logic valid_refri_temp, valid_kitch_temp;
logic [5:0] number_out_temp;
logic product_out_temp;
logic run_out_ing_temp;

logic [6:0] nugget_in_shop_test, fried_rice_in_shop_test, apple_in_shop_test, peach_in_shop_test;
logic [6:0] nugget_in_shop_reg, fried_rice_in_shop_reg, apple_in_shop_reg, peach_in_shop_reg;
logic [2:0] Number_nugget_reg, Number_fried_rice_reg, Number_apple_reg, Number_peach_reg;

logic [11:0] target_product_dff;
logic in_valid_dff;
//---------------------------------------------------------------------
//   DON'T MODIFIED THE REGISTER'S NAME (PRODUCT REGISTER)
//---------------------------------------------------------------------
logic [6:0] nugget_in_shop, fried_rice_in_shop ;
logic [6:0] apple_in_shop , peach_in_shop ;
//---------------------------------------------------------------------

//---------------------------------------------------------------------
//   FSM
//---------------------------------------------------------------------
always_ff @( posedge clk or negedge rst_n ) begin 
    if(!rst_n) begin
        target_product_dff<= 0;
        in_valid_dff<= 0;
		cur_state <= S_IDLE;
    end
    else begin
        target_product_dff[11:0] <= target_product[11:0];
        in_valid_dff <= in_valid;
		cur_state <= next_state;
    end
end
always_comb begin

	in_stock_nug = (nugget_in_shop >= Number_nugget /*&& nugget_in_shop!=0 && Number_nugget!=0*/)? 1 : (nugget_in_shop_test >= Number_nugget) ? in_stock_nug_bef : 0;
	in_stock_fri = (fried_rice_in_shop >= Number_fried_rice /*&& fried_rice_in_shop!=0 && Number_fried_rice!=0*/)? 1 : (fried_rice_in_shop_test >= Number_fried_rice ) ? in_stock_fri_bef : 0;
	in_stock_app = (apple_in_shop >= Number_apple /*&& apple_in_shop !=0 && Number_apple!=0*/)? 1 : (apple_in_shop_test >= Number_apple ) ? in_stock_fri_bef : 0;
	in_stock_pea = (peach_in_shop >= Number_peach /*&& peach_in_shop!=0 && Number_peach!=0*/)? 1 : (peach_in_shop_test >= Number_peach) ? in_stock_pea_bef : 0;



	InStock =  (in_stock_nug&&in_stock_fri&&in_stock_app&&in_stock_pea) ? 1 : 0;


	nugget_in_shop_comb= (ready_kitch && valid_kitch_temp && cur_state == S_OutOfStock_nugget) ? nugget_in_shop + (50-nugget_in_shop) : nugget_in_shop;
	fried_rice_in_shop_comb = (ready_kitch && valid_kitch_temp && cur_state == S_OutOfStock_fried_rice) ? fried_rice_in_shop + (50-fried_rice_in_shop) :fried_rice_in_shop;
	apple_in_shop_comb = (ready_refri && valid_refri_temp && cur_state == S_OutOfStock_apple) ? apple_in_shop + (50-apple_in_shop) :apple_in_shop;
	peach_in_shop_comb = (ready_refri && valid_refri_temp && cur_state == S_OutOfStock_peach) ? peach_in_shop + (50-peach_in_shop) :peach_in_shop;
	
	// ten_comb = (cur_state == S_InStock) ? total_money/10 : 0;
	// rem_ten = (cur_state == S_InStock) ? total_money%10 : 0;

	// five_comb = (cur_state == S_InStock) ? rem_ten /5 : 0;
	// rem_five = (cur_state == S_InStock) ? rem_ten %5 : 0;
	// one_comb =(cur_state == S_InStock) ? rem_five/5 : 0;
	case(cur_state)
		S_IDLE : begin
			if (in_valid_dff)begin
				if (!in_stock_nug) next_state = S_OutOfStock_nugget;
				else if (!in_stock_app) next_state = S_OutOfStock_apple;
				else if (!in_stock_fri) next_state = S_OutOfStock_fried_rice;
				else if (!in_stock_pea) next_state = S_OutOfStock_peach;
				else next_state = S_InStock;
			end
			else next_state = cur_state;
		end
		S_InStock :begin
			nugget_in_shop_comb = nugget_in_shop - Number_nugget;
			fried_rice_in_shop_comb = fried_rice_in_shop - Number_fried_rice;
			apple_in_shop_comb = apple_in_shop - Number_apple;
			peach_in_shop_comb = peach_in_shop - Number_peach;

			// ten_comb = total_money/10;
			// rem_ten = total_money%10;
			// five_comb = rem_ten /5;
			// rem_five = rem_ten %5;
			// one_comb =rem_five; 

			next_state = S_IDLE;
		end

		S_OutOfStock_nugget:begin
			next_state = S_OutOfStock;
		end

		S_OutOfStock_fried_rice :begin
			next_state = S_OutOfStock;
		end

		S_OutOfStock_apple : begin
			next_state = S_OutOfStock;
		end

		S_OutOfStock_peach : begin
			next_state = S_OutOfStock;
		end

		S_OutOfStock : begin
			if (!in_stock_nug) next_state = S_OutOfStock_nugget;
			else if (!in_stock_fri) next_state = S_OutOfStock_fried_rice;
			else if (!in_stock_app) next_state = S_OutOfStock_apple;
			else if (!in_stock_pea) next_state = S_OutOfStock_peach;
			else begin
				// run_out_ing_temp = 1;
				next_state = S_IDLE;
			end
		end
	default : next_state = cur_state;

	
	endcase
end

//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------
assign run_out_ing_temp = (cur_state == S_OutOfStock && next_state == S_IDLE) ? 1 : 0;
always_comb begin
	if (cur_state == S_InStock)begin
			ten_comb = total_money/10;
			rem_ten = total_money%10;
			five_comb = rem_ten /5;
			rem_five = rem_ten %5;
			one_comb =rem_five; 
	end
	else begin
			ten_comb = 0;
			rem_ten = 0;
			five_comb = 0;
			rem_five = 0;
			one_comb = 0 ;
	end
end

always_ff @(posedge clk , negedge rst_n) begin
	if(!rst_n) begin
		nugget_in_shop_reg <= 0;
		apple_in_shop_reg <= 0;
		fried_rice_in_shop_reg <= 0;
		peach_in_shop_reg <= 0; 
	end
	else begin
		nugget_in_shop_reg <= nugget_in_shop_test;
		apple_in_shop_reg <= apple_in_shop_test;
		fried_rice_in_shop_reg <= fried_rice_in_shop_test;
		peach_in_shop_reg <= peach_in_shop_test; 
	end
end

always_comb begin
	if(in_valid_dff) begin
		nugget_in_shop_test = nugget_in_shop_comb;
		apple_in_shop_test = apple_in_shop_comb;
		fried_rice_in_shop_test = fried_rice_in_shop_comb;
		peach_in_shop_test = peach_in_shop_comb;
	end
	else begin
		nugget_in_shop_test = nugget_in_shop_reg;
		apple_in_shop_test = apple_in_shop_reg;
		fried_rice_in_shop_test = fried_rice_in_shop_reg;
		peach_in_shop_test = peach_in_shop_reg;
	end
end
//
always_ff @(posedge clk , negedge rst_n) begin
	if(!rst_n) begin
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
//
always_ff @(posedge clk , negedge rst_n) begin
	if(!rst_n) begin
		Number_nugget_reg <=0;
		Number_fried_rice_reg <= 0;
		Number_apple_reg <= 0;
		Number_peach_reg <= 0;
	end
	else begin
		Number_nugget_reg <=Number_nugget;
		Number_fried_rice_reg <= Number_fried_rice;
		Number_apple_reg <= Number_apple;
		Number_peach_reg <= Number_peach;
	end
end
always_comb begin
	if(in_valid_dff) begin
		Number_nugget = target_product_dff[11:9];
		Number_fried_rice = target_product_dff[8:6];
		Number_apple = target_product_dff[5:3];
		Number_peach = target_product_dff[2:0];
	end
	else begin
		Number_nugget = Number_nugget_reg;
		Number_fried_rice = Number_fried_rice_reg;
		Number_apple = Number_apple_reg;
		Number_peach = Number_peach_reg;
	end
end
//

assign total_money = 3*Number_nugget+ 5*Number_fried_rice+ 2*Number_apple+ 4*Number_peach;

always_ff @ (posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		in_stock_nug_bef <= 0;
		in_stock_fri_bef <= 0;
		in_stock_app_bef <= 0;
		in_stock_pea_bef <= 0;
	end
	else begin
		in_stock_nug_bef <= in_stock_nug;
		in_stock_fri_bef <= in_stock_fri;
		in_stock_app_bef <= in_stock_app;
		in_stock_pea_bef <= in_stock_pea;
	end
end
//
always_ff @ (posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		ten <=0;
		five <= 0;
		one <= 0;
		out_valid <= 0;
	end
	else if (cur_state == S_InStock)begin
		ten <= ten_comb;
		five <= five_comb;
		one <= one_comb;
		out_valid <= 1;
	end
	else if (cur_state == S_OutOfStock && InStock)begin
		ten <= ten;
		five <= five;
		one <= one;
		out_valid <= 1;
	end
	else begin
		ten <= 0;
		five <= 0;
		one <= 0;
		out_valid <= 0;
	end
end
//
always_ff @ (posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		valid_refri <= 0;
		valid_kitch <= 0;
	end
	else begin
		valid_refri <= valid_refri_temp;
		valid_kitch <= valid_kitch_temp;
	end
end
always_comb begin
	if ((cur_state == S_OutOfStock_nugget || cur_state == S_OutOfStock_fried_rice) && ready_kitch)
		valid_kitch_temp = 1;
	else
		valid_kitch_temp = 0;
end
always_comb begin
	if ((cur_state == S_OutOfStock_apple || cur_state == S_OutOfStock_peach) && ready_refri)
		valid_refri_temp = 1;
	else
		valid_refri_temp = 0;
end
//
always_ff @ (posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		number_out <= 0;
		product_out <= 0;
	end
	else begin
		number_out <= number_out_temp;
		product_out <= product_out_temp;
	end
end
always_comb begin
	if (ready_kitch && valid_kitch_temp) begin
		if (cur_state == S_OutOfStock_nugget)begin
			number_out_temp =  50 - nugget_in_shop;
			product_out_temp = 1;
		end
		else if (cur_state == S_OutOfStock_fried_rice) begin
			number_out_temp =  50 - fried_rice_in_shop;
			product_out_temp = 0;
		end
		else begin
			number_out_temp = 0;
			product_out_temp = 0;
		end
	end
	else if(ready_refri && valid_refri_temp) begin
		if (cur_state == S_OutOfStock_apple)begin
			number_out_temp =  50 - apple_in_shop;
			product_out_temp = 1;
		end
		else if (cur_state == S_OutOfStock_peach) begin
			number_out_temp =  50 - peach_in_shop;
			product_out_temp = 0;
		end
		else begin
			number_out_temp = 0;
			product_out_temp = 0;
		end
	end
	else begin
		number_out_temp = 0;
		product_out_temp = 0;
	end
end
//
always_ff @ (posedge clk, negedge rst_n) begin
	if (!rst_n) run_out_ing <= 0;
	else if (cur_state == S_OutOfStock && InStock) run_out_ing <= run_out_ing_temp;
	else run_out_ing <=0;
end

endmodule