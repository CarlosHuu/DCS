module PIPE(
  // Input signals
  clk,
  rst_n,
  in_valid,
  in_1,
  in_2,
  in_3,
  in_4,
  mode,
  // Output signals
  out_valid,
  out_value
);

//---------------------------------------------------------------------
//   PORT DECLARATION
//---------------------------------------------------------------------
input  logic clk,rst_n,in_valid;
input  logic [5:0]in_1,in_2,in_3,in_4;
input  logic [1:0] mode;

output logic out_valid;

output logic [26:0]out_value;
//---------------------------------------------------------------------
//   Design
//---------------------------------------------------------------------
logic in_valid_1, in_valid_2, in_valid_3, in_valid_4, in_valid_5;
logic [1:0] mode_reg, mode_comb,mode_regg, mode_reg1;
logic [5:0] in_1_reg, in_2_reg, in_1_comb, in_2_comb;
logic [5:0] in_3_reg, in_4_reg, in_3_comb, in_4_comb;

logic [23:0]outcome_comb, outcome_reg, outcome_reg_1;
logic [23:0]result0, result1, result2;
logic [23:0]result0_reg, result1_reg, result2_reg;
logic [23:0]muti1, muti2, add11;
logic [23:0]muti1_reg, muti2_reg, add11_reg;

logic out_valid_comb;




// First Layer
assign in_1_comb = in_valid ? in_1 : 0;
assign in_2_comb = in_valid ? in_2 : 0;
assign in_3_comb = in_valid ? in_3 : 0;
assign in_4_comb = in_valid ? in_4 : 0;
assign mode_comb = in_valid ? mode : 0;

always_ff @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		in_valid_1 <= 0;
		in_1_reg <= 0;
		in_2_reg <= 0;
		in_3_reg <= 0;
		in_4_reg <= 0;
    mode_reg <= 0;
	end
	else begin
		in_valid_1 <= in_valid;
		in_1_reg <= in_1_comb;
		in_2_reg <= in_2_comb;
		in_3_reg <= in_3_comb;
		in_4_reg <= in_4_comb;
    mode_reg <= mode_comb;
	end
end
//
always_comb begin
  muti1 = in_1_reg * in_2_reg;
  muti2 = in_3_reg * in_4_reg;
  add11 = in_3_reg + in_4_reg;
end
always_ff @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		in_valid_2 <= 0;
    muti1_reg <= 0;
    muti2_reg <= 0;
    add11_reg <= 0;
    mode_reg1 <= 0;
		
	end
	else begin
		in_valid_2 <= in_valid_1;
    muti1_reg <= muti1;
    muti2_reg <= muti2;
    add11_reg <= add11;
		mode_reg1 <= mode_reg;
	end
end

//
always_comb begin 
  result0 = muti1_reg;
  result1 = add11_reg;
  result2 = muti1_reg * muti2_reg;
end
always_ff @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		in_valid_3 <= 0;
		result0_reg <= 0;
    result1_reg <= 0;
    result2_reg <= 0;
    mode_regg <= 0;
   
	end
	else begin
		in_valid_3 <= in_valid_2;
		result0_reg <= result0;
    result1_reg <= result1;
    result2_reg <= result2;
    mode_regg <= mode_reg1;
	end
end

// Second Layer
always_comb begin
  case(mode_regg)
    0 : outcome_comb = result0_reg;
    1 : outcome_comb = result1_reg;
    2 : outcome_comb = result2_reg;
    default : outcome_comb = 0 ;
  endcase
end
always_ff @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		in_valid_4 <= 0;
		outcome_reg_1 <= 0;

	end
	else begin
		in_valid_4 <= in_valid_3;
		outcome_reg_1 <= outcome_comb;
	end
end

// always_ff @(posedge clk or negedge rst_n) begin
// 	if (!rst_n) begin
// 		in_valid_5 <= 0;
// 		outcome_reg <= 0;

// 	end
// 	else begin
// 		in_valid_5 <= in_valid_4;
// 		outcome_reg <= outcome_reg_1;
// 	end
// end
//


//
assign out_valid_comb = in_valid_4 ? 1 : 0;

always_ff @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		out_valid <= 0;
		out_value <= 0;
	end
	else begin
		out_valid <= out_valid_comb;
		out_value <= outcome_reg_1;
	end
end
endmodule
