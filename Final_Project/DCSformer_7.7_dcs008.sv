module DCSformer(
	// Input signals
	clk,
	rst_n,
	i_valid,
	w_valid,
	i_data,
	w_data,
	// Output signals
	w_ready,
	o_valid,
	o_data
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input               clk, rst_n, i_valid, w_valid;
input         [7:0] i_data, w_data;
output logic        w_ready, o_valid;
output logic [31:0] o_data;
//---------------------------------------------------------------------
//   Your design                       
//---------------------------------------------------------------------


//control
parameter IDLE = 3'b000,
		  INPUT = 3'b001,
		  MM = 3'b010,
		  RAT = 3'b011,
		  WEIGHT_IN = 3'b100,
		  OUTPUT = 3'b101;
logic [2:0] current_state, next_state;
logic [6:0] counter;

always_ff @( posedge clk or negedge rst_n ) begin 
	if(!rst_n)begin
		current_state <= IDLE;
	end
	else begin
		current_state <= next_state;
	end
end
always_ff @( posedge clk or negedge rst_n ) begin 
	if(!rst_n)begin
		counter <= 7'b0;
	end
	else begin
		if((current_state==IDLE&&!i_valid) || (current_state==INPUT&& counter==127) || (current_state==MM && counter==63) || (current_state==RAT&& counter==7) || (current_state==WEIGHT_IN && (counter==7 || !w_valid)) || (current_state==OUTPUT && counter==7))begin
			counter <= 7'b0;
		end
		else begin
			counter <= counter + 1;
		end
	end
end
always_comb begin : fsm
	case (current_state)
		IDLE:begin
			if(i_valid)begin
				next_state = INPUT;
			end
			else begin
				next_state = IDLE;
			end
		end 
		INPUT:begin
			if(counter==127)begin
				next_state = MM;
			end
			else begin
				next_state = INPUT;
			end
		end
		MM:begin
			if(counter==63)begin
				next_state = RAT;
			end
			else begin
				next_state = MM;
			end
		end
		RAT:begin
			if(counter==7)begin
				next_state = WEIGHT_IN;
			end
			else begin
				next_state = RAT;
			end
		end
		WEIGHT_IN:begin
			if(counter==7)begin
				next_state = OUTPUT;
			end
			else begin
				next_state = WEIGHT_IN;
			end
		end
		OUTPUT:begin
			if(counter==7)begin
				next_state = IDLE;
			end
			else begin
				next_state = OUTPUT;
			end
		end
		default:
			next_state = IDLE; 
	endcase
end


//data path
logic  [7:0] i_data_reg [7:0][15:0];
logic  [19:0] mm_out_reg [7:0][7:0];
logic [22:0] RAT_value;

genvar i,j;
generate
	for(i=0;i<8;i=i+1)begin
		for(j=0;j<16;j=j+1)begin
			always_ff @(posedge clk or negedge rst_n)begin
				if(~rst_n)begin
					i_data_reg[i][j] <= 8'b0;
				end
				else begin
					if(i_valid)begin
						if(i==counter[6:4] && j==counter[3:0])begin
							i_data_reg[i][j] <= i_data;
						end
					end
				end
			end
		end
	end
endgenerate
generate
	for(i=0;i<8;i=i+1)begin
		for(j=0;j<8;j=j+1)begin
			always_ff @(posedge clk or negedge rst_n)begin
				if(~rst_n)begin
					mm_out_reg[i][j] <= 8'b0;
				end
				else begin
					if(current_state==MM)begin
						if(i==counter[5:3] && j==counter[2:0])begin
							mm_out_reg[i][j] <= i_data_reg[i][0]*i_data_reg[j][0] + i_data_reg[i][1]*i_data_reg[j][1] + i_data_reg[i][2]*i_data_reg[j][2] + i_data_reg[i][3]*i_data_reg[j][3] + i_data_reg[i][4]*i_data_reg[j][4] + i_data_reg[i][5]*i_data_reg[j][5] + i_data_reg[i][6]*i_data_reg[j][6] + i_data_reg[i][7]*i_data_reg[j][7]+i_data_reg[i][8]*i_data_reg[j][8] + i_data_reg[i][9]*i_data_reg[j][9] + i_data_reg[i][10]*i_data_reg[j][10] + i_data_reg[i][11]*i_data_reg[j][11] + i_data_reg[i][12]*i_data_reg[j][12] + i_data_reg[i][13]*i_data_reg[j][13] + i_data_reg[i][14]*i_data_reg[j][14] + i_data_reg[i][15]*i_data_reg[j][15];
						end
					end
					if(current_state==RAT)begin
						if(i==counter[2:0])begin
							if(mm_out_reg[i][j]<RAT_value[22:3])begin
								mm_out_reg[i][j] <= 0;
							end
						end
					end
				end
			end
		end
	end
endgenerate
	
always_comb  begin
	begin
		if(current_state==RAT)begin
			RAT_value = mm_out_reg[counter[2:0]][0] + mm_out_reg[counter[2:0]][1] + mm_out_reg[counter[2:0]][2] + mm_out_reg[counter[2:0]][3] + mm_out_reg[counter[2:0]][4] + mm_out_reg[counter[2:0]][5] + mm_out_reg[counter[2:0]][6] + mm_out_reg[counter[2:0]][7];
		end
		else
			RAT_value = 0;
	end
end
	
logic [7:0] weight_in_reg [7:0];

always_comb  begin
	if(current_state==RAT && counter==7)begin
		w_ready = 1'b1;
	end
	else
		w_ready = 1'b0;
end

generate
	for(i=0;i<8;i=i+1)begin
		always_ff @(posedge clk or negedge rst_n)begin
			if(~rst_n)begin
				weight_in_reg[i] <= 4'b0;
			end
			else begin
				if(current_state==WEIGHT_IN)begin
					if(i==counter[2:0])begin
						weight_in_reg[i] <= w_data;
					end
				end
			end
		end
	end
endgenerate

always_ff @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		o_data <= 31'b0;
	end
	else
	begin
		if(current_state==OUTPUT)begin
			o_data <= mm_out_reg[counter[2:0]][0]*weight_in_reg[0] + mm_out_reg[counter[2:0]][1]*weight_in_reg[1] + mm_out_reg[counter[2:0]][2]*weight_in_reg[2] + mm_out_reg[counter[2:0]][3]*weight_in_reg[3] + mm_out_reg[counter[2:0]][4]*weight_in_reg[4] + mm_out_reg[counter[2:0]][5]*weight_in_reg[5] + mm_out_reg[counter[2:0]][6]*weight_in_reg[6] + mm_out_reg[counter[2:0]][7]*weight_in_reg[7];
		end
		else
			o_data <= 0;
	end
end
always_ff @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		o_valid <= 1'b0;
	end
	else
	if(current_state==OUTPUT)begin
		o_valid <= 1'b1;
	end
	else
		o_valid <= 1'b0;
end
	
endmodule
