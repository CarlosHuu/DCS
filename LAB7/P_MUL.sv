module P_MUL(
    // input signals
	in_1,
	in_2,
	in_3,
	in_4,
	in_valid,
	rst_n,
	clk,
	
    // output signals
    out_valid,
	out
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input [47:0] in_1, in_2;
input [47:0] in_3, in_4;
input in_valid, rst_n, clk;
output logic out_valid;
output logic [95:0] out;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic in_valid_1, in_valid_2, in_valid_3;

logic [47:0] in_1_reg, in_2_reg, in_1_comb, in_2_comb;
logic [47:0] in_3_reg, in_4_reg, in_3_comb, in_4_comb;


logic [47:0] max_1v2, max_3v4, max_1v2_reg, max_3v4_reg;

logic [31:0] outcome1, outcome1_comb;	// [47:32] * [47:32]  (64)
logic [31:0] outcome2, outcome2_comb;	// [47:32] * [31:16]  (48)
logic [31:0] outcome3, outcome3_comb;	// [47:32] * [15:0]   (32)
logic [31:0] outcome4, outcome4_comb;	// [31:16] * [47:32]  (48)
logic [31:0] outcome5, outcome5_comb;	// [31:16] * [31:16]  (32)
logic [31:0] outcome6, outcome6_comb;	// [31:16] * [15:0]   (16)
logic [31:0] outcome7, outcome7_comb;	// [15:0]  * [47:32]  (32)
logic [31:0] outcome8, outcome8_comb;	// [15:0]  * [31:16]  (16)
logic [31:0] outcome9, outcome9_comb;	// [15:0]  * [15:0]   (0)

logic out_valid_comb;
logic [95:0] shift1, shift2, shift3, shift4, shift5, shift6, shift7, shift8, shift9;
logic [95:0] out_comb;



//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------
// First Layer
assign in_1_comb = in_valid ? in_1 : 0;
assign in_2_comb = in_valid ? in_2 : 0;
assign in_3_comb = in_valid ? in_3 : 0;
assign in_4_comb = in_valid ? in_4 : 0;

always_ff @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		in_valid_1 <= 0;
		in_1_reg <= 0;
		in_2_reg <= 0;
		in_3_reg <= 0;
		in_4_reg <= 0;
	end
	else begin
		in_valid_1 <= in_valid;
		in_1_reg <= in_1_comb;
		in_2_reg <= in_2_comb;
		in_3_reg <= in_3_comb;
		in_4_reg <= in_4_comb;
	end
end
// Second Layer
always_comb begin
	if(in_1_reg>=in_2_reg) max_1v2 = in_1_reg;
	else max_1v2 = in_2_reg;
end
always_comb begin
	if(in_3_reg>=in_4_reg) max_3v4 = in_3_reg;
	else max_3v4 = in_4_reg;
end

always_ff @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		in_valid_2 <= 0;
		max_1v2_reg <= 0;
		max_3v4_reg <= 0;
	end
	else begin
		in_valid_2 <= in_valid_1;
		max_1v2_reg <= max_1v2;
		max_3v4_reg <= max_3v4;
	end
end
// Third Layer
always_comb begin
	if (in_valid_2) begin
		outcome1_comb = max_1v2_reg[47:32]*max_3v4_reg[47:32];
		outcome2_comb = max_1v2_reg[47:32]*max_3v4_reg[31:16];
		outcome3_comb = max_1v2_reg[47:32]*max_3v4_reg[15:0];
		outcome4_comb = max_1v2_reg[31:16]*max_3v4_reg[47:32];
		outcome5_comb = max_1v2_reg[31:16]*max_3v4_reg[31:16];
		outcome6_comb = max_1v2_reg[31:16]*max_3v4_reg[15:0];
		outcome7_comb = max_1v2_reg[15:0]*max_3v4_reg[47:32];
		outcome8_comb = max_1v2_reg[15:0]*max_3v4_reg[31:16];
		outcome9_comb = max_1v2_reg[15:0]*max_3v4_reg[15:0];
	end
	else begin
		outcome1_comb = 0;	
		outcome2_comb = 0;	
		outcome3_comb = 0;
		outcome4_comb = 0;	
		outcome5_comb = 0;	
		outcome6_comb = 0;
		outcome7_comb = 0;	
		outcome8_comb = 0;	
		outcome9_comb = 0;
	end
end

always_ff @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		in_valid_3 <= 0;
		outcome1 <= 0;	
		outcome2 <= 0;	
		outcome3 <= 0;
		outcome4 <= 0;	
		outcome5 <= 0;	
		outcome6 <= 0;
		outcome7 <= 0;	
		outcome8 <= 0;	
		outcome9 <= 0;
	end
	else begin
		in_valid_3 <= in_valid_2;
		outcome1 <= outcome1_comb;	
		outcome2 <= outcome2_comb;	
		outcome3 <= outcome3_comb;
		outcome4 <= outcome4_comb;	
		outcome5 <= outcome5_comb;	
		outcome6 <= outcome6_comb;
		outcome7 <= outcome7_comb;	
		outcome8 <= outcome8_comb;	
		outcome9 <= outcome9_comb;
	end
end
// Final Layer
assign out_valid_comb = in_valid_3 ? 1 : 0;

always_comb begin
	if (in_valid_3) begin
		shift1 = outcome1 << 64;
		shift2 = outcome2 << 48;
		shift3 = outcome3 << 32;
		shift4 = outcome4 << 48;
		shift5 = outcome5 << 32;
		shift6 = outcome6 << 16;
		shift7 = outcome7 << 32;
		shift8 = outcome8 << 16;
		shift9 = outcome9;
	end
	else begin
		shift1 = 0;		
		shift2 = 0;		
		shift3 = 0;
		shift4 = 0;		
		shift5 = 0;		
		shift6 = 0;
		shift7 = 0;		
		shift8 = 0;		
		shift9 = 0;
	end
end

assign out_comb = in_valid_3 ? (shift1 + shift2 + shift3 + shift4 + shift5 + shift6 + shift7 + shift8 + shift9) : 0;

always_ff @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		out_valid <= 0;
		out <= 0;
	end
	else begin
		out_valid <= out_valid_comb;
		out <= out_comb;
	end
end
endmodule