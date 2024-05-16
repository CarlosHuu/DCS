
`include "Handshake_syn.v"

module CDC(
	// Input signals
	clk_1,
	clk_2,
	rst_n,
	in_valid,
	in_data,
	// Output signals
	out_valid,
	out_data
);

input clk_1; 
input clk_2;			
input rst_n;
input in_valid;
input[7:0]in_data;

output logic out_valid;
output logic [4:0]out_data; 			

// ---------------------------------------------------------------------
// logic declaration                 
// ---------------------------------------------------------------------	

logic [7:0] in_data_comb, in_data_reg;
logic sidle_syn, dvalid_syn;
logic [7:0] dout_syn;
logic [1:0] state1_cs, state1_ns;
logic [1:0] state2_cs, state2_ns;
logic send_valid;
logic valid_comb;
logic [4:0] out_comb;
parameter S_wait_input = 2'b00,
		  S_wait_sync_idle = 2'b01,
		  S_send_data = 2'b10;

parameter S_wait_sync_high = 2'b00,
		  S_out = 2'b01,
		  S_wait_sync_low = 2'b10;

// ---------------------------------------------------------------------
// design              
// ---------------------------------------------------------------------

Handshake_syn sync(
					.sclk(clk_1), 
					.dclk(clk_2), 
					.rst_n(rst_n),
					.sready(send_valid), 
					.din(in_data_reg), 
					.sidle(sidle_syn),
					.dbusy(0),
					.dvalid(dvalid_syn),
					.dout(dout_syn)
);
assign in_data_comb = (in_valid) ? in_data : in_data_reg;

always_ff @(posedge clk_1 or negedge rst_n) begin
	if (!rst_n) begin
		in_data_reg <= 0;
	end
	else begin
		in_data_reg <= in_data_comb;
	end
end
always_ff @(posedge clk_1 or negedge rst_n) begin
	if (!rst_n) state1_cs <= 0;
	else state1_cs <= state1_ns;
end
//clk_1 domain
always_comb begin
	case (state1_cs)
		S_wait_input :	   state1_ns = in_valid ? S_wait_sync_idle : S_wait_input;
		S_wait_sync_idle : state1_ns = sidle_syn ? S_send_data : S_wait_sync_idle;
		S_send_data :      state1_ns = S_wait_input;
		default:state1_ns = S_wait_input;
	endcase
end
assign send_valid = (state1_cs == S_send_data) ? 1 : 0;
//clk_2 domain
always_ff @(posedge clk_2 or negedge rst_n) begin
	if (!rst_n) state2_cs <= 0;
	else state2_cs <= state2_ns;
end
always_comb begin
	case (state2_cs)
		S_wait_sync_high : state2_ns = dvalid_syn ? S_out : S_wait_sync_high;
		S_out :   		   state2_ns = S_wait_sync_low;
		S_wait_sync_low :  state2_ns = (!dvalid_syn) ? S_wait_sync_high : S_wait_sync_low;
		default:state2_ns = S_wait_input;
	endcase
end

always_comb begin
	case (state2_cs)
		S_wait_sync_high:	begin
					out_comb = 0;
					valid_comb = 0;
				end
		S_out:begin
					out_comb = dout_syn[7:4] + dout_syn[3:0];
					valid_comb = 1;
				end
		S_wait_sync_low:	begin
					out_comb = 0;
					valid_comb = 0;
				end
		default:begin
					out_comb = 0;
					valid_comb = 0;
				end
	endcase
end


always_ff @(posedge clk_2 or negedge rst_n) begin
	if (!rst_n) begin
		out_data <= 0;
		out_valid <= 0;
	end
	else begin
		out_data <= out_comb;
		out_valid <= valid_comb;
	end
end

endmodule