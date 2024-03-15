module SIPO(
	// input signals
	clk,
	rst_n,
	in_valid,
	s_in,
	
	// output signals
	out_valid,
	p_out
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n;
input in_valid;
input s_in;
output logic out_valid;
output logic [3:0] p_out;
//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic [3:0] cnt,cnt_next;
//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------

always_comb begin
    if (in_valid) 
		cnt_next = cnt + 1;
    else if (out_valid) 
		cnt_next = 0;
    else 
		cnt_next = cnt;
end

always_comb begin
    if (cnt == 4) 
		out_valid = 1;
    else 
		out_valid = 0;
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		cnt <= 0;
		p_out[0] <= 0;
		p_out[1] <= 0;
		p_out[2] <= 0;
		p_out[3] <= 0;
	end
	else begin
		if (in_valid) begin
			cnt <= cnt_next;
			if (cnt == 0)
				p_out[3] <= s_in;
			else if (cnt == 1)
				p_out[2] <= s_in;
			else if (cnt == 2)
				p_out[1] <= s_in;
			else if (cnt == 3)
				p_out[0] <= s_in;
			else begin
				p_out[0] <= 0;
				p_out[1] <= 0;
				p_out[2] <= 0;
				p_out[3] <= 0;
			end
		end

		else begin
			cnt <= 0;
			p_out[0] <= 0;
			p_out[1] <= 0;
			p_out[2] <= 0;
			p_out[3] <= 0;
		end
	end
end

endmodule