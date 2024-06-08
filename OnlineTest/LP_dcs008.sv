module LP(
    // Input signals
	clk,
	rst_n,
	in_valid,
    in_a1,
	in_a2,
	in_b,
    // Output signals
    out_valid,
    out_max_value
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n, in_valid;
input signed [5:0] in_a1,in_a2;
input signed [11:0] in_b;

output logic out_valid;
output logic signed [11:0] out_max_value;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
parameter S_IDLE = 3'b000,
          S_GetValue = 3'b001,
          S_Compute = 3'b010,
          S_OUT = 3'b011;
logic [2:0] cur_state, next_state;

logic signed [5:0] target_x1, target_x2;
logic [11:0] b_ignored;
logic signed[5:0] x1 [5:0];
logic signed[5:0] x2 [5:0];
logic signed[11:0] b [5:0];

logic signed[11:0] min_x1, min_x2;
logic signed[11:0] min_x1_reg, min_x2_reg;
logic signed[11:0] max_x1, max_x2;
logic signed[11:0] max_x1_reg, max_x2_reg;

logic signed [4:0] x1_cnt, x2_cnt, x1_cntnxt, x2_cntnxt, com_cnt, com_cntnxt;
logic signed [11:0] out_max, out_max_reg;


//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------
always_ff @ (posedge clk, negedge rst_n)begin
    if(!rst_n)begin
        target_x1 <= 0;
        x1[0] <= 0;
        x1[1] <= 0;
        x1[2] <= 0;
        x1[3] <= 0;
        x1[4] <= 0;
        x1[5] <= 0;
    end
    else if(in_valid) begin
        target_x1 <= x1[0];
        x1[0] <= x1[1];
        x1[1] <= x1[2];
        x1[2] <= x1[3];
        x1[3] <= x1[4];
        x1[4] <= x1[5];
        x1[5] <= in_a1;
    end
    else begin
        target_x1 <= target_x1 ;
        x1[0] <= x1[0];
        x1[1] <= x1[1];
        x1[2] <= x1[2];
        x1[3] <= x1[3];
        x1[4] <= x1[4];
        x1[5] <= x1[5];
    end
end

always_ff @ (posedge clk, negedge rst_n)begin
    if(!rst_n)begin
        target_x2 <= 0;
        x2[0] <= 0;
        x2[1] <= 0;
        x2[2] <= 0;
        x2[3] <= 0;
        x2[4] <= 0;
        x2[5] <= 0;
    end
    else if(in_valid) begin
        target_x2 <= x2[0];
        x2[0] <= x2[1];
        x2[1] <= x2[2];
        x2[2] <= x2[3];
        x2[3] <= x2[4];
        x2[4] <= x2[5];
        x2[5] <= in_a2;
    end
    else begin
        target_x2 <= target_x2;
        x2[0] <= x2[0];
        x2[1] <= x2[1];
        x2[2] <= x2[2];
        x2[3] <= x2[3];
        x2[4] <= x2[4];
        x2[5] <= x2[5];
    end
end

always_ff @ (posedge clk, negedge rst_n)begin
    if(!rst_n)begin
        b_ignored <= 0;
        b[0] <= 0;
        b[1] <= 0;
        b[2] <= 0;
        b[3] <= 0;
        b[4] <= 0;
        b[5] <= 0;
    end
    else if(in_valid) begin
        b_ignored <= b[0];
        b[0] <= b[1];
        b[1] <= b[2];
        b[2] <= b[3];
        b[3] <= b[4];
        b[4] <= b[5];
        b[5] <= in_b;
    end
    else begin
        b_ignored <= b_ignored;
        b[0] <= b[0];
        b[1] <= b[1];
        b[2] <= b[2];
        b[3] <= b[3];
        b[4] <= b[4];
        b[5] <= b[5];
    end
end

always_ff @ (posedge clk, negedge rst_n)begin
    if(!rst_n) begin
        cur_state <= S_IDLE;
        min_x1 <= -31;
        min_x2 <= -31;
        max_x1 <= 31;
        max_x2 <= 31;
        out_max <= 0;
    end
    else begin
        cur_state <= next_state;
        min_x1 <= min_x1_reg;
        min_x2 <= min_x2_reg;
        max_x1 <= max_x1_reg;
        max_x2 <= max_x2_reg;
        out_max <= out_max_reg;
    end
end

always_comb begin
    out_valid = 0;
    out_max_value = 0;
    next_state = S_IDLE;
    case(cur_state)
    S_IDLE : begin
        if(in_valid) next_state = S_GetValue;
        else next_state = cur_state;
    end
    S_GetValue : begin
        if(!in_valid) next_state = S_Compute;
        else next_state = cur_state;
    end
    S_Compute : begin
        if(x2_cnt == 5'b01111 && x1_cnt == 5'b01111)
            next_state = S_OUT;
        else
            next_state = cur_state;
    end
    S_OUT : begin
        out_valid = 1;
        out_max_value = out_max;
        next_state = S_IDLE;
    end
    endcase
end

always_ff @ (posedge clk)begin
    if (cur_state == S_Compute) begin
        x1_cnt <= x1_cntnxt;
        x2_cnt <= x2_cntnxt;
    end
    else begin
        x1_cnt <= 0;
        x2_cnt <= 0;
    end
end
always_comb begin
    if (cur_state == S_Compute) begin
        if(x1_cnt < 15) x1_cntnxt = x1_cnt + 1; else x1_cntnxt = 0; 
        if(x1_cnt == 15) x2_cntnxt = x2_cnt + 1; else x2_cntnxt = x2_cnt; 
    end
    else begin
        x1_cntnxt = 0;
        x2_cntnxt = 0;
    end
end

always_ff @ (posedge clk)begin
    if (cur_state == S_GetValue) begin
        com_cnt <= com_cntnxt;
    end
    else begin
        com_cnt <= 0;
    end
end
always_comb begin
    if (cur_state == S_GetValue) begin
        com_cntnxt = com_cnt + 1;; 
    end
    else begin
        com_cntnxt = 0;
    end
end

always_comb begin

    if(cur_state == S_IDLE) begin
        out_max_reg = -2047;
        min_x1_reg = -31;
        min_x2_reg = -31;
        max_x1_reg = 31;
        max_x2_reg = 31;
    end
    else if ( cur_state == S_GetValue) begin
        out_max_reg = out_max;
        if (com_cnt == 0) begin
            min_x1_reg = min_x1;
            min_x2_reg = min_x2;
            max_x1_reg = max_x1;
            max_x2_reg = max_x2;
        end
        else begin

            if (x1[5] == -1 && x2[5] == 6'b000000) begin
                if ( b[5]/x1[5] > min_x1) begin
                    min_x1_reg = b[5]/x1[5];
                end
                else begin
                    min_x1_reg = min_x1;
                end
            end
            else min_x1_reg = min_x1;

            if (x2[5] == -1 && x1[5] == 6'b000000) begin
                if ( b[5]/x2[5] > min_x2) begin
                    min_x2_reg = b[5]/x2[5];
                end
                else begin
                    min_x2_reg = min_x2;
                end
            end
            else min_x2_reg = min_x2;

            if (x1[5] == 1 && x2[5] == 6'b000000) begin
                if ( b[5]/x1[5] < max_x1) begin
                    max_x1_reg = b[5]/x1[5];
                end
                else begin
                    max_x1_reg = max_x1;
                end
            end
            else max_x1_reg = max_x1;

            if (x2[5] == 1 && x1[5] == 6'b000000) begin
                if ( b[5]/x2[5] < max_x2) begin
                    max_x2_reg = b[5]/x2[5];
                end
                else begin
                    max_x2_reg = max_x2;
                end
            end
            else max_x2_reg = max_x2;
        end

    end

    else if (cur_state == S_Compute)begin
        min_x1_reg = min_x1;
        min_x2_reg = min_x2;
        max_x1_reg = max_x1;
        max_x2_reg = max_x2;
        if( 
            (x1[0]*(min_x1 + x1_cnt) + x2[0]*(min_x2 + x2_cnt))<= b[0] &&
            (x1[1]*(min_x1 + x1_cnt) + x2[1]*(min_x2 + x2_cnt))<= b[1] && 
            (x1[2]*(min_x1 + x1_cnt) + x2[2]*(min_x2 + x2_cnt))<= b[2] && 
            (x1[3]*(min_x1 + x1_cnt) + x2[3]*(min_x2 + x2_cnt))<= b[3] && 
            (x1[4]*(min_x1 + x1_cnt) + x2[4]*(min_x2 + x2_cnt))<= b[4] && 
            (x1[5]*(min_x1 + x1_cnt) + x2[5]*(min_x2 + x2_cnt))<= b[5] &&
            (min_x1 + x1_cnt) <= max_x1 && (min_x2 + x2_cnt) <= max_x2)begin
        
            if((target_x1*(min_x1 + x1_cnt) + target_x2*(min_x2 + x2_cnt)) > out_max)
                out_max_reg =target_x1*(min_x1 + x1_cnt) + target_x2*(min_x2 + x2_cnt);
            else out_max_reg = out_max;

        end
        else out_max_reg = out_max;
    end
    else begin
        out_max_reg = out_max;
        min_x1_reg = min_x1;
        min_x2_reg = min_x2;
        max_x1_reg = max_x1;
        max_x2_reg = max_x2;

    end


end
endmodule