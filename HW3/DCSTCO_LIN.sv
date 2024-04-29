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

parameter S_IDLE  = 2'd0,
          S_SUFFICIENT  = 2'd1,
          S_INSUFFICIENT  = 2'd2,
          S_HANDSHAKE = 2'd3;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------

logic [6:0] nugget_in_shop_comb, fried_rice_in_shop_comb ;
logic [6:0] apple_in_shop_comb , peach_in_shop_comb ;

logic in_check, in_check_before;
logic [11:0] data_target, data_target_before;

logic [6:0] sum, sum_mod10;

logic [3:0] ten_now ;
logic five_now ;
logic [2:0] one_now ;

// logic valid_kitch_comb;
// logic valid_refri_comb;

logic s1, s2, s3, s4;
logic s1_comb, s2_comb, s3_comb, s4_comb;

logic in_suff, in_insuff;
logic in_suff_before, in_insuff_before;

////////////////

logic v_kitch1, v_kitch0, v_refri1, v_refri0;
logic v_kitch1_comb, v_kitch0_comb, v_refri1_comb, v_refri0_comb;

///////////////

logic [11:0] data, data_comb;

/////////

logic run_out_ing_comb;

//---------------------------------------------------------------------
//   DON'T MODIFIED THE REGISTER'S NAME (PRODUCT REGISTER)
//---------------------------------------------------------------------
logic [6:0] nugget_in_shop, fried_rice_in_shop ;
logic [6:0] apple_in_shop , peach_in_shop ;
//---------------------------------------------------------------------

//---------------------------------------------------------------------
//   FSM
//---------------------------------------------------------------------

logic [1:0] cur_state, next_state;

//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------

always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		nugget_in_shop <= 0;
		fried_rice_in_shop <= 0;
		apple_in_shop <= 0;
		peach_in_shop <= 0;
	end else begin
		nugget_in_shop <= nugget_in_shop_comb;
		fried_rice_in_shop <= fried_rice_in_shop_comb;
		apple_in_shop <= apple_in_shop_comb;
		peach_in_shop <= peach_in_shop_comb;
	end
end 

always_comb begin
	case(cur_state)
		S_INSUFFICIENT: begin
			nugget_in_shop_comb = nugget_in_shop;
			fried_rice_in_shop_comb = fried_rice_in_shop;
			apple_in_shop_comb = apple_in_shop;
			peach_in_shop_comb = peach_in_shop;
			// if (valid_kitch && ready_kitch && s1 && v_kitch1) begin
			// 	nugget_in_shop_comb = 50;
			// end
			// else if (valid_refri && ready_refri && s3 && v_refri1) begin
			// 	apple_in_shop_comb = 50;
			// end
			// else if (valid_kitch && ready_kitch && s2 && v_kitch0) begin
			// 	fried_rice_in_shop_comb = 50;
			// end
			// else if (valid_refri && ready_refri && s4 && v_refri0) begin
			// 	peach_in_shop_comb = 50;
			// end

			// original
			
			if (s1) begin
				if(ready_kitch && v_kitch1) nugget_in_shop_comb = 50;
			end
			else if (s3) begin
				if(ready_refri && v_refri1) apple_in_shop_comb = 50;
			end
			else if (s2) begin
				if(ready_kitch && v_kitch0) fried_rice_in_shop_comb = 50;
			end
			else if (s4) begin
				if(ready_refri && v_refri0) peach_in_shop_comb = 50;
			end

			// if (valid_refri && ready_refri && s4 && v_refri0) begin
			// 	peach_in_shop_comb = 50;
			// end
			// else if (valid_kitch && ready_kitch && s1 && v_kitch1) begin
			// 	nugget_in_shop_comb = 50;
			// end
			// else if (valid_refri && ready_refri && s3 && v_refri1) begin
			// 	apple_in_shop_comb = 50;
			// end
			// else if (valid_kitch && ready_kitch && s2 && v_kitch0) begin
			// 	fried_rice_in_shop_comb = 50;
			// end
		end
		S_HANDSHAKE: begin
			nugget_in_shop_comb = nugget_in_shop;
			fried_rice_in_shop_comb = fried_rice_in_shop;
			apple_in_shop_comb = apple_in_shop;
			peach_in_shop_comb = peach_in_shop;
			if (in_suff && out_valid) begin
				nugget_in_shop_comb = nugget_in_shop - data_target[11:9];
				fried_rice_in_shop_comb = fried_rice_in_shop - data_target[8:6];
				apple_in_shop_comb = apple_in_shop - data_target[5:3];
				peach_in_shop_comb = peach_in_shop - data_target[2:0];
			end
		end
		default: begin
			nugget_in_shop_comb = nugget_in_shop;
			fried_rice_in_shop_comb = fried_rice_in_shop;
			apple_in_shop_comb = apple_in_shop;
			peach_in_shop_comb = peach_in_shop;
		end
	endcase
end

/////////////////////

always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		cur_state <= S_IDLE;
	end
	else begin
		cur_state <= next_state;
	end
end

always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		in_check_before <= 0;
		data_target_before <= 0;
	end
	else begin
		in_check_before <= in_check;
		data_target_before <= data_target;
	end
end

always_comb begin
	in_check = (in_valid) ? 1 : in_check_before;
	data_target = (in_valid) ? target_product : data_target_before;

	case(cur_state) 
		S_IDLE: begin
			// if(in_check && in_suff) begin
			// 	next_state = S_SUFFICIENT;
			// 	in_check = 0;
			// end
			// else if(in_check && in_insuff) begin
			// 	next_state = S_INSUFFICIENT;
			// 	in_check = 0;
			// end

			if(in_check) begin
				if(in_suff) next_state = S_SUFFICIENT;
				else 		next_state = S_INSUFFICIENT;
				in_check = 0;
			end
			else
				next_state = cur_state;
		end
		S_SUFFICIENT: begin
			next_state = S_HANDSHAKE;
		end
		S_INSUFFICIENT: begin
			// if(!s1 && !s2 && !s3 && !s4) begin
			if(!s1_comb && !s2_comb && !s3_comb && !s4_comb) begin // early 1 cycle
				next_state = S_HANDSHAKE;
				in_check = 0;
			end
			else
				next_state = cur_state;
		end
		S_HANDSHAKE: begin
			next_state = S_IDLE;
		end
	endcase
end

//////////////////

always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		in_suff_before <= 0;
	end else begin
		in_suff_before <= in_suff;
	end
end 

always_comb begin
	in_suff   = (in_valid) ? ((target_product[11:9] <= nugget_in_shop) && (target_product[8:6] <= fried_rice_in_shop) && (target_product[5:3] <= apple_in_shop) && (target_product[2:0] <= peach_in_shop)) : in_suff_before;
	// in_insuff = !in_suff;
end

//////////////////

always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		ten <= 0;
		five <= 0;
		one <= 0;
	end else begin
		ten <= ten_now;
		five <= five_now;
		one <= one_now;
	end
end 

always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		data <= 0;
	end else begin
		data <= data_comb;
	end
end 

always_comb begin
	data_comb = (in_valid) ? target_product : data;

	ten_now = 0;
	five_now = 0;
	one_now = 0;
	if(cur_state == S_SUFFICIENT) begin
		// sum = data[11:9] * 3 + data[8:6] * 5 + data[5:3] * 2 + data[2:0] * 4;
		sum = (data[11:9] + data[5:3] + (data[8:6] + data[2:0]) * 2) * 2 + data[11:9] + data[8:6];

		ten_now = sum / 10;
		sum_mod10 = sum % 10;


		five_now = (sum_mod10 >= 5) ? 1 : 0;
		one_now = (five_now) ? (sum_mod10 - 5) : sum_mod10;
	end
end

///////////////////

always_comb begin
	if(cur_state == S_HANDSHAKE) begin
		out_valid = 1;
	end 
	else begin
		out_valid = 0;
	end
end

/////////////////

always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		s1 <= 0;
		s2 <= 0;
		s3 <= 0;
		s4 <= 0;
	end
	else begin
		s1 <= s1_comb;
		s2 <= s2_comb;
		s3 <= s3_comb;
		s4 <= s4_comb;
	end
end

always_comb begin
	case(cur_state)
		S_IDLE: begin
			if (in_valid) begin
				s1_comb = (target_product[11:9] > nugget_in_shop) ? 1 : s1;
				s2_comb = (target_product[8:6] > fried_rice_in_shop) ? 1 : s2;
				s3_comb = (target_product[5:3] > apple_in_shop) ? 1 : s3;
				s4_comb = (target_product[2:0] > peach_in_shop) ? 1 : s4;
			end
			else begin
				s1_comb = 0;
				s2_comb = 0;
				s3_comb = 0;
				s4_comb = 0;
			end
		end
		S_INSUFFICIENT: begin
			s1_comb = s1;
			s2_comb = s2;
			s3_comb = s3;
			s4_comb = s4;
			// if (s1) begin
			// 	if(valid_kitch && ready_kitch && v_kitch1) s1_comb = 0;
			// end
			// else if (s3) begin
			// 	if(valid_refri && ready_refri && v_refri1) s3_comb = 0;
			// end
			// else if (s2) begin
			// 	if(valid_kitch && ready_kitch && v_kitch0) s2_comb = 0;
			// end
			// else if (s4) begin
			// 	if(valid_refri && ready_refri && v_refri0) s4_comb = 0;
			// end

			if (s1) begin
				if(ready_kitch && v_kitch1) s1_comb = 0;
			end
			else if (s3) begin
				if(ready_refri && v_refri1) s3_comb = 0;
			end
			else if (s2) begin
				if(ready_kitch && v_kitch0) s2_comb = 0;
			end
			else if (s4) begin
				if(ready_refri && v_refri0) s4_comb = 0;
			end
		end
		default: begin
			s1_comb = 0;
			s2_comb = 0;
			s3_comb = 0;
			s4_comb = 0;
		end
	endcase
end

///////////////

always_comb begin
	v_kitch1 = 0;
	v_kitch0 = 0;
	v_refri1 = 0;
	v_refri0 = 0;
	// if (s1) begin 
	// 	v_kitch1 = 1;
	// end
	// else if (s3) begin
	// 	v_refri1 = 1;
	// end
	// else if (s2) begin
	// 	v_kitch0 = 1;
	// end
	// else if (s4) begin
	// 	v_refri0 = 1;
	// end

	if (s1) begin 
		v_kitch1 = 1;
	end
	else if (s3) begin
		v_refri1 = 1;
	end
	else if (s2) begin
		v_kitch0 = 1;
	end
	else if (s4) begin
		v_refri0 = 1;
	end
end

//////////////////

assign valid_kitch = (v_kitch1 || v_kitch0);
assign valid_refri = (v_refri1 || v_refri0);

////////////////////

always_comb begin
	product_out = 0;
	// if (s1) begin
	// 	product_out = 1;
	// end
	// else if (s3) begin
	// 	product_out = 1;
	// end
	// else if (s2) begin
	// 	product_out = 0;
	// end
	// else if (s4) begin
	// 	product_out = 0;
	// end

	if (s1) begin
		product_out = 1;
	end
	else if (s3) begin
		product_out = 1;
	end
	else if (s2) begin
		product_out = 0;
	end
	else if (s4) begin
		product_out = 0;
	end

	// if (s1 || s3) begin
	// 	product_out = 1;
	// end
	// else if (s2 || s4) begin
	// 	product_out = 0;
	// end
end

///////////////////

always_comb begin
	number_out = 0;
	// if (s1) begin
	// 	number_out = 50 - nugget_in_shop;
	// end
	// else if (s3) begin
	// 	number_out = 50 - apple_in_shop;
	// end
	// else if (s2) begin
	// 	number_out = 50 - fried_rice_in_shop;
	// end
	// else if (s4) begin
	// 	number_out = 50 - peach_in_shop;
	// end

	if (s1) begin
		number_out = 50 - nugget_in_shop;
	end
	else if (s3) begin
		number_out = 50 - apple_in_shop;
	end
	else if (s2) begin
		number_out = 50 - fried_rice_in_shop;
	end
	else if (s4) begin
		number_out = 50 - peach_in_shop;
	end
end

/////////////////

always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		run_out_ing <= 0;
	end
	else begin
		run_out_ing <= run_out_ing_comb;
	end
end

always_comb begin
	if((next_state == S_HANDSHAKE) && (cur_state == S_INSUFFICIENT)) begin
		run_out_ing_comb = 1;
	end
	else begin
		run_out_ing_comb = 0;
	end
end

///////////////////

endmodule