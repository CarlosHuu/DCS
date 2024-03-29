module inter(
  // Input signals
  clk,
  rst_n,
  in_valid_1,
  in_valid_2,
  data_in_1,
  data_in_2,
  ready_slave1,
  ready_slave2,
  // Output signals
  valid_slave1,
  valid_slave2,
  addr_out,
  value_out,
  handshake_slave1,
  handshake_slave2
);

//---------------------------------------------------------------------
//   PORT DECLARATION
//---------------------------------------------------------------------
input clk, rst_n, in_valid_1, in_valid_2;
input [6:0] data_in_1, data_in_2; 
input ready_slave1, ready_slave2;

output logic valid_slave1, valid_slave2;
output logic [2:0] addr_out, value_out;
output logic handshake_slave1, handshake_slave2;

//---------------------------------------------------------------------
//   FSM state
//---------------------------------------------------------------------
parameter 	S_IDLE  = 'd0,
			S_master1  = 'd1,
			S_master2  = 'd2,
			S_handshake = 'd3;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic [1:0] state, state_next;					// State
logic in1, in2, in1_bef, in2_bef;
logic [6:0] data1, data2, data1_bef, data2_bef;
logic [2:0] valid_out_tmp, addr_out_tmp;
logic hsk_1_state, hsk_2_state;
logic vs1_comb, vs2_comb, vs1, vs2;
logic valid_slave1_comb, valid_slave2_comb;
logic one_valid_1, one_valid_1_bef, one_valid_2, one_valid_2_bef;

//---------------------------------------------------------------------
//   Your design
//---------------------------------------------------------------------

//FSM
always @(posedge clk or negedge rst_n) begin // State changes with posedge
	if (!rst_n) begin
		state <= S_IDLE;
	end
	else begin
		state <= state_next;
	end
end
always_comb begin
    in1 = (in_valid_1)? 1 : in1_bef;
    in2 = (in_valid_2)? 1 : in2_bef;

    data1 = (in_valid_1)? data_in_1 : data1_bef;
    data2 = (in_valid_2)? data_in_2 : data2_bef;

    one_valid_1 = (in_valid_1 && !in_valid_2)? 1 : one_valid_1_bef;
    one_valid_2 = (!in_valid_1 && in_valid_2)? 1 : one_valid_2_bef;

    case(state)
    S_IDLE:
        if(in2) begin
            state_next = S_master2;
            in2 = 0;
            one_valid_2 = 0;
        end
        else if (in1) begin
            state_next = S_master1;
            in1 = 0;
            one_valid_1 = 0;
        end
        else
            state_next = state;

    S_master1:
        if(data1[6]==0) begin
            if(valid_slave1 && ready_slave1)begin
                state_next = S_handshake;
                in1 = 0;
                one_valid_1 = 0;
            end
            else
                state_next = state;
        end
        else begin
            if(valid_slave2 && ready_slave2)begin
                state_next = S_handshake;
                in1 = 0;
                one_valid_1 = 0;
            end
            else
                state_next = state;
        end

    S_master2:
        if(data2[6]==0) begin
            if(valid_slave1 && ready_slave1)begin
                state_next = S_handshake;
                in2 = 0;
                one_valid_2 = 0;
            end
            else
                state_next = state;
        end
        else begin
            if(valid_slave2 && ready_slave2)begin
                state_next = S_handshake;
                in2 = 0;
                one_valid_2 = 0;
            end
            else
                state_next = state;
        end

    S_handshake:
        state_next = (!one_valid_1 && !one_valid_2) ? (in2 ? S_master2 : (in1 ? S_master1 : S_IDLE)) :
             (!one_valid_1 && one_valid_2) ? S_IDLE :
             (one_valid_1 && !one_valid_2) ? S_IDLE :
           state;
    
    default : state_next = state;
    endcase
end

// register

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
		in1_bef <= 0;
        in2_bef <= 0;
	end
	else begin
		in1_bef <= in1;
        in2_bef <= in2;
	end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
		data1_bef <= 0;
        data2_bef <= 0;
	end
	else begin
		data1_bef <= data1;
        data2_bef <= data2;
	end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
		one_valid_1_bef <= 0;
        one_valid_2_bef <= 0;
	end
	else begin
		one_valid_1_bef <= one_valid_1;
        one_valid_2_bef <= one_valid_2;
	end
end
//---------------------------------------------------------------------
//output
//---------------------------------------------------------------------
// valid & addr
always_comb begin
    if (state == S_master2) begin
        valid_out_tmp = data2[2:0];
        addr_out_tmp = data2[5:3];
    end
    else if (state == S_master1) begin
        valid_out_tmp = data1[2:0];
        addr_out_tmp = data1[5:3];
    end
    else begin
        valid_out_tmp = 0;
        addr_out_tmp = 0;
    end
end
always_ff @( posedge clk or negedge rst_n ) begin 
    if(!rst_n) begin
        value_out <= 0;
        addr_out <= 0;
    end
    else begin
        value_out <= valid_out_tmp;
        addr_out <= addr_out_tmp;
    end
end

// handshake slave
always @(posedge clk, negedge rst_n) begin
	if (!rst_n) handshake_slave1 <= 0;
	else handshake_slave1 <= hsk_1_state;
end

always @(posedge clk, negedge rst_n) begin
	if (!rst_n) handshake_slave2 <= 0;
	else handshake_slave2 <= hsk_2_state;
end

always_comb begin
	if (ready_slave1 && valid_slave1) hsk_1_state = 1;
	else hsk_1_state = 0;
end

always_comb begin
	if (ready_slave2 && valid_slave2) hsk_2_state = 1;
	else hsk_2_state = 0;
end


//valid_slave
always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		vs1 <= 0;
		vs2 <= 0;
	end
	else begin
		vs1 <= vs1_comb;
		vs2 <= vs2_comb;
	end
end
always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        valid_slave1 <= 0;
        valid_slave2 <= 0;
    end
    else begin
        valid_slave1 <= valid_slave1_comb;
        valid_slave2 <= valid_slave2_comb;
    end
end

always_comb begin
    if(state == S_IDLE) vs1_comb = data_in_1[6];
    else vs1_comb = vs1;
    if(state == S_IDLE) vs2_comb = data_in_2[6];
    else vs2_comb = vs2;

    case(state)
      S_master2: begin
			valid_slave1_comb = (vs2) ? 0 : 1;
			valid_slave2_comb = (vs2) ? 1 : 0;
		end
      S_master1: begin
			valid_slave1_comb = (vs1) ? 0 : 1;
			valid_slave2_comb = (vs1) ? 1 : 0;
        end
      default: begin
			valid_slave1_comb = 0;
			valid_slave2_comb = 0;
		end

    endcase
end

endmodule


