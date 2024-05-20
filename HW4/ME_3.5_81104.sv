module ME(
    // Input signals
	clk,
	rst_n,
    block_valid,
	area_valid,
    in_data,
    // Output signals
    out_valid,
    out_vector
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n, block_valid, area_valid;
input [7:0] in_data;

output logic out_valid;
output logic signed [2:0] out_vector;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic [7:0]counter_area,counter_block;
logic [7:0] CB[0:15];
logic [7:0] SA;

logic [7:0] diff_value[0:15];
logic [7:0] diff_reg[0:15];
logic [11:0] sum[0:26];
logic [11:0] sum_reg[0:26];
logic [11:0] SAD_value;
logic [11:0] check_value;

logic [11:0] min_value;
logic [7:0] min_index;
logic [2:0] out1, out2;
logic compare_valid, compare_valid_next;

parameter S_Idle = 2'd0 ;
parameter S_GetValue = 2'd1 ;
parameter S_out1 = 2'd2 ;
parameter S_out2 = 2'd3 ;
logic[2:0] cur_state, next_state;

// logic [7:0]  sum_0;    // 255
// logic [8:0]  sum_1;    // 510
// logic [9:0]  sum_2;    // 765
// logic [10:0] sum_3;    // 1020
// logic [10:0] sum_4;    // 1020
// logic [10:0] sum_5;    // 1020
// logic [10:0] sum_6;    // 1020
// logic [10:0] sum_7;    // 1020
// logic [11:0] sum_8;    // 1275
// logic [11:0] sum_9;    // 1530
// logic [11:0] sum_10;   // 1785
// logic [11:0] sum_11;   // 2040
// logic [11:0] sum_12;   // 2040
// logic [11:0] sum_13;   // 2040
// logic [11:0] sum_14;   // 2040
// logic [11:0] sum_15;   // 2040
// logic [12:0] sum_16;   // 2295
// logic [12:0] sum_17;   // 2550
// logic [12:0] sum_18;   // 2805
// logic [12:0] sum_19;   // 3060
// logic [12:0] sum_20;   // 3060
// logic [12:0] sum_21;   // 3060
// logic [12:0] sum_22;   // 3060
// logic [12:0] sum_23;   // 3060
// logic [13:0] sum_24;   // 3315
// logic [13:0] sum_25;   // 3570
// logic [13:0] sum_26;   // 3825

logic [7:0]  sum_0;    // 255
logic [8:0]  sum_1;    // 510
logic [9:0]  sum_2;    // 765
logic [9:0] sum_3;    // 1020
logic [9:0] sum_4;    // 1020
logic [9:0] sum_5;    // 1020
logic [9:0] sum_6;    // 1020
logic [9:0] sum_7;    // 1020
logic [10:0] sum_8;    // 1275
logic [10:0] sum_9;    // 1530
logic [10:0] sum_10;   // 1785
logic [10:0] sum_11;   // 2040
logic [10:0] sum_12;   // 2040
logic [10:0] sum_13;   // 2040
logic [10:0] sum_14;   // 2040
logic [10:0] sum_15;   // 2040
logic [11:0] sum_16;   // 2295
logic [11:0] sum_17;   // 2550
logic [11:0] sum_18;   // 2805
logic [11:0] sum_19;   // 3060
logic [11:0] sum_20;   // 3060
logic [11:0] sum_21;   // 3060
logic [11:0] sum_22;   // 3060
logic [11:0] sum_23;   // 3060
logic [11:0] sum_24;   // 3315
logic [11:0] sum_25;   // 3570
logic [11:0] sum_26;   // 3825


// logic [7:0]   sum_reg_0;    // 255
// logic [8:0]   sum_reg_1;    // 510
// logic [9:0]   sum_reg_2;    // 765
// logic [10:0]  sum_reg_3;    // 1020
// logic [10:0]  sum_reg_4;    // 1020
// logic [10:0]  sum_reg_5;    // 1020
// logic [10:0]  sum_reg_6;    // 1020
// logic [10:0]  sum_reg_7;    // 1020
// logic [11:0]  sum_reg_8;    // 1275
// logic [11:0]  sum_reg_9;    // 1530
// logic [11:0]  sum_reg_10;   // 1785
// logic [11:0]  sum_reg_11;   // 2040
// logic [11:0]  sum_reg_12;   // 2040
// logic [11:0]  sum_reg_13;   // 2040
// logic [11:0]  sum_reg_14;   // 2040
// logic [12:0]  sum_reg_15;   // 2295
// logic [12:0]  sum_reg_16;   // 2550
// logic [12:0]  sum_reg_17;   // 2805
// logic [12:0]  sum_reg_18;   // 3060
// logic [13:0]  sum_reg_19;   // 3315
// logic [13:0]  sum_reg_20;   // 3570
// logic [13:0]  sum_reg_21;   // 3825
// logic [13:0]  sum_reg_22;   // 4080
// logic [13:0]  sum_reg_23;   // 4335
// logic [13:0]  sum_reg_24;   // 4590
// logic [13:0]  sum_reg_25;   // 4845
// logic [13:0]  sum_reg_26;   // 5100

logic [7:0]  sum_reg_0;    // 255
logic [8:0]  sum_reg_1;    // 510
logic [9:0]  sum_reg_2;    // 765
logic [9:0]  sum_reg_3;    // 1020
logic [9:0]  sum_reg_4;    // 1020
logic [9:0]  sum_reg_5;    // 1020
logic [9:0]  sum_reg_6;    // 1020
logic [9:0]  sum_reg_7;    // 1020
logic [10:0] sum_reg_8;    // 1275
logic [10:0] sum_reg_9;    // 1530
logic [10:0] sum_reg_10;   // 1785
logic [10:0] sum_reg_11;   // 2040
logic [10:0] sum_reg_12;   // 2040
logic [10:0] sum_reg_13;   // 2040
logic [10:0] sum_reg_14;   // 2040
logic [10:0] sum_reg_15;   // 2040
logic [11:0] sum_reg_16;   // 2295
logic [11:0] sum_reg_17;   // 2550
logic [11:0] sum_reg_18;   // 2805
logic [11:0] sum_reg_19;   // 3060
logic [11:0] sum_reg_20;   // 3060
logic [11:0] sum_reg_21;   // 3060
logic [11:0] sum_reg_22;   // 3060
logic [11:0] sum_reg_23;   // 3060
logic [11:0] sum_reg_24;   // 3315
logic [11:0] sum_reg_25;   // 3570
logic [11:0] sum_reg_26;   // 3825





//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------

always_ff @(negedge rst_n or posedge clk) begin
    if(!rst_n) begin
        counter_area <= 0;
    end
    else begin
        if(block_valid)begin
        CB[0] <= CB[1];
        CB[1] <= CB[2];
        CB[2] <= CB[3];
        CB[3] <= CB[4];
        CB[4] <= CB[5];
        CB[5] <= CB[6];
        CB[6] <= CB[7];
        CB[7] <= CB[8];
        CB[8] <= CB[9];
        CB[9] <= CB[10];
        CB[10] <= CB[11];
        CB[11] <= CB[12];
        CB[12] <= CB[13];
        CB[13] <= CB[14];
        CB[14] <= CB[15];
        CB[15] <= in_data;
        end
        if(area_valid)begin
        SA <= in_data;
        counter_area <= counter_area + 1;
        end
        else
            counter_area <= 0; 
    end
end


always_comb begin
     if ((counter_area >= 28 && counter_area <= 32) || 
        (counter_area >= 36 && counter_area <= 40) || 
        (counter_area >= 44 && counter_area <= 48) || 
        (counter_area >= 52 && counter_area <= 56) || 
        (counter_area >= 60 && counter_area <= 64))
        compare_valid = 1;
    else
        compare_valid = 0;
end

// always_ff @(negedge rst_n or posedge clk) begin
//     if(!rst_n) begin
//         sum_reg[0] <= 0;
//         sum_reg[1] <= 0;
//         sum_reg[2] <= 0;
//         sum_reg[3] <= 0;
//         sum_reg[4] <= 0;
//         sum_reg[5] <= 0;
//         sum_reg[6] <= 0;
//         sum_reg[7] <= 0;
//         sum_reg[8] <= 0;
//         sum_reg[9] <= 0;
//         sum_reg[10] <= 0;
//         sum_reg[11] <= 0;
//         sum_reg[12] <= 0;
//         sum_reg[13] <= 0;
//         sum_reg[14] <= 0;
//         sum_reg[15] <= 0;
//         sum_reg[16] <= 0;
//         sum_reg[17] <= 0;
//         sum_reg[18] <= 0;
//         sum_reg[19] <= 0;
//         sum_reg[20] <= 0;
//         sum_reg[21] <= 0;
//         sum_reg[22] <= 0;
//         sum_reg[23] <= 0;
//         sum_reg[24] <= 0;
//         sum_reg[25] <= 0;
//         sum_reg[26] <= 0;
// end
// else begin
//         sum_reg[0] <= sum[0];
//         sum_reg[1] <= sum[1];
//         sum_reg[2] <= sum[2];
//         sum_reg[3] <= sum[3];
//         sum_reg[4] <= sum[4];
//         sum_reg[5] <= sum[5];
//         sum_reg[6] <= sum[6];
//         sum_reg[7] <= sum[7];
//         sum_reg[8] <= sum[8];
//         sum_reg[9] <= sum[9];
//         sum_reg[10] <= sum[10];
//         sum_reg[11] <= sum[11];
//         sum_reg[12] <= sum[12];
//         sum_reg[13] <= sum[13];
//         sum_reg[14] <= sum[14];
//         sum_reg[15] <= sum[15];
//         sum_reg[16] <= sum[16];
//         sum_reg[17] <= sum[17];
//         sum_reg[18] <= sum[18];
//         sum_reg[19] <= sum[19];
//         sum_reg[20] <= sum[20];
//         sum_reg[21] <= sum[21];
//         sum_reg[22] <= sum[22];
//         sum_reg[23] <= sum[23];
//         sum_reg[24] <= sum[24];
//         sum_reg[25] <= sum[25];
//         sum_reg[26] <= sum[26];
//     end
// end

always_ff @(negedge rst_n or posedge clk) begin
    if (!rst_n) begin
        sum_reg_0 <= 0;
        sum_reg_1 <= 0;
        sum_reg_2 <= 0;
        sum_reg_3 <= 0;
        sum_reg_4 <= 0;
        sum_reg_5 <= 0;
        sum_reg_6 <= 0;
        sum_reg_7 <= 0;
        sum_reg_8 <= 0;
        sum_reg_9 <= 0;
        sum_reg_10 <= 0;
        sum_reg_11 <= 0;
        sum_reg_12 <= 0;
        sum_reg_13 <= 0;
        sum_reg_14 <= 0;
        sum_reg_15 <= 0;
        sum_reg_16 <= 0;
        sum_reg_17 <= 0;
        sum_reg_18 <= 0;
        sum_reg_19 <= 0;
        sum_reg_20 <= 0;
        sum_reg_21 <= 0;
        sum_reg_22 <= 0;
        sum_reg_23 <= 0;
        sum_reg_24 <= 0;
        sum_reg_25 <= 0;
        sum_reg_26 <= 0;
    end else begin
        sum_reg_0 <= sum_0;
        sum_reg_1 <= sum_1;
        sum_reg_2 <= sum_2;
        sum_reg_3 <= sum_3;
        sum_reg_4 <= sum_4;
        sum_reg_5 <= sum_5;
        sum_reg_6 <= sum_6;
        sum_reg_7 <= sum_7;
        sum_reg_8 <= sum_8;
        sum_reg_9 <= sum_9;
        sum_reg_10 <= sum_10;
        sum_reg_11 <= sum_11;
        sum_reg_12 <= sum_12;
        sum_reg_13 <= sum_13;
        sum_reg_14 <= sum_14;
        sum_reg_15 <= sum_15;
        sum_reg_16 <= sum_16;
        sum_reg_17 <= sum_17;
        sum_reg_18 <= sum_18;
        sum_reg_19 <= sum_19;
        sum_reg_20 <= sum_20;
        sum_reg_21 <= sum_21;
        sum_reg_22 <= sum_22;
        sum_reg_23 <= sum_23;
        sum_reg_24 <= sum_24;
        sum_reg_25 <= sum_25;
        sum_reg_26 <= sum_26;
    end
end

// always_comb begin
//     sum[0] = (SA >= CB[0]) ? (SA - CB[0]) : (CB[0] - SA);
//     sum[1] = sum_reg[0] + ((SA >= CB[1]) ? (SA - CB[1]) : (CB[1] - SA));
//     sum[2] = sum_reg[1] + ((SA >= CB[2]) ? (SA - CB[2]) : (CB[2] - SA));
//     sum[3] = sum_reg[2] + ((SA >= CB[3]) ? (SA - CB[3]) : (CB[3] - SA));
//     sum[4] = sum_reg[3];
//     sum[5] = sum_reg[4];
//     sum[6] = sum_reg[5];
//     sum[7] = sum_reg[6];
//     sum[8] = sum_reg[7] + ((SA >= CB[4]) ? (SA - CB[4]) : (CB[4] - SA));
//     sum[9] = sum_reg[8] + ((SA >= CB[5]) ? (SA - CB[5]) : (CB[5] - SA));
//     sum[10] = sum_reg[9] + ((SA >= CB[6]) ? (SA - CB[6]) : (CB[6] - SA));
//     sum[11] = sum_reg[10] + ((SA >= CB[7]) ? (SA - CB[7]) : (CB[7] - SA));
//     sum[12] = sum_reg[11];
//     sum[13] = sum_reg[12];
//     sum[14] = sum_reg[13];
//     sum[15] = sum_reg[14];
//     sum[16] = sum_reg[15] + ((SA >= CB[8]) ? (SA - CB[8]) : (CB[8] - SA));
//     sum[17] = sum_reg[16] + ((SA >= CB[9]) ? (SA - CB[9]) : (CB[9] - SA));
//     sum[18] = sum_reg[17] + ((SA >= CB[10]) ? (SA - CB[10]) : (CB[10] - SA));
//     sum[19] = sum_reg[18] + ((SA >= CB[11]) ? (SA - CB[11]) : (CB[11] - SA));
//     sum[20] = sum_reg[19];
//     sum[21] = sum_reg[20];
//     sum[22] = sum_reg[21];
//     sum[23] = sum_reg[22];
//     sum[24] = sum_reg[23] + ((SA >= CB[12]) ? (SA - CB[12]) : (CB[12] - SA));
//     sum[25] = sum_reg[24] + ((SA >= CB[13]) ? (SA - CB[13]) : (CB[13] - SA));
//     sum[26] = sum_reg[25] + ((SA >= CB[14]) ? (SA - CB[14]) : (CB[14] - SA));
//     check_value = sum_reg[26] + ((SA >= CB[15]) ? (SA - CB[15]) : (CB[15] - SA));
// end
always_comb begin
    sum_0 = (SA > CB[0]) ? (SA - CB[0]) : (CB[0] - SA);
    sum_1 = sum_reg_0 + ((SA > CB[1]) ? (SA - CB[1]) : (CB[1] - SA));
    sum_2 = sum_reg_1 + ((SA > CB[2]) ? (SA - CB[2]) : (CB[2] - SA));
    sum_3 = sum_reg_2 + ((SA > CB[3]) ? (SA - CB[3]) : (CB[3] - SA));
    sum_4 = sum_reg_3;
    sum_5 = sum_reg_4;
    sum_6 = sum_reg_5;
    sum_7 = sum_reg_6;
    sum_8 = sum_reg_7 + ((SA > CB[4]) ? (SA - CB[4]) : (CB[4] - SA));
    sum_9 = sum_reg_8 + ((SA > CB[5]) ? (SA - CB[5]) : (CB[5] - SA));
    sum_10 = sum_reg_9 + ((SA > CB[6]) ? (SA - CB[6]) : (CB[6] - SA));
    sum_11 = sum_reg_10 + ((SA > CB[7]) ? (SA - CB[7]) : (CB[7] - SA));
    sum_12 = sum_reg_11;
    sum_13 = sum_reg_12;
    sum_14 = sum_reg_13;
    sum_15 = sum_reg_14;
    sum_16 = sum_reg_15 + ((SA > CB[8]) ? (SA - CB[8]) : (CB[8] - SA));
    sum_17 = sum_reg_16 + ((SA > CB[9]) ? (SA - CB[9]) : (CB[9] - SA));
    sum_18 = sum_reg_17 + ((SA > CB[10]) ? (SA - CB[10]) : (CB[10] - SA));
    sum_19 = sum_reg_18 + ((SA > CB[11]) ? (SA - CB[11]) : (CB[11] - SA));
    sum_20 = sum_reg_19;
    sum_21 = sum_reg_20;
    sum_22 = sum_reg_21;
    sum_23 = sum_reg_22;
    sum_24 = sum_reg_23 + ((SA > CB[12]) ? (SA - CB[12]) : (CB[12] - SA));
    sum_25 = sum_reg_24 + ((SA > CB[13]) ? (SA - CB[13]) : (CB[13] - SA));
    sum_26 = sum_reg_25 + ((SA > CB[14]) ? (SA - CB[14]) : (CB[14] - SA));
    check_value = sum_reg_26 + ((SA > CB[15]) ? (SA - CB[15]) : (CB[15] - SA));
end

always_ff @(negedge rst_n or posedge clk) begin
    if(!rst_n) begin
        cur_state <= S_Idle;
    end
    else begin
        cur_state <= next_state;
    end
end

always_comb begin
    out_valid = 0;
    out_vector = 0;
    next_state = S_Idle;
    case(cur_state)
    S_Idle: begin
        if(block_valid)
            next_state = S_GetValue;
        else
            next_state = cur_state;
    end
    S_GetValue: begin
        if((block_valid || area_valid) == 0) begin
            next_state = S_out1;
        end
        else
            next_state = cur_state;
    end
    S_out1: begin
        out_valid= 1;
        out_vector = out1;
        next_state = S_out2;
    end
    S_out2: begin
        out_valid = 1;
        out_vector = out2;
        next_state = S_Idle;
    end
    endcase
end


always_ff @(negedge rst_n or posedge clk) begin
    if(!rst_n) begin
        min_value <= 12'b111111111111;
        min_index <= 8'b11111111;

    end
    else begin
        if(counter_area > 0 && counter_area <28) begin
            min_value <= 12'b111111111111;
            min_index <= 0;
        end
        
        else begin
            if (check_value < min_value) begin
                if (compare_valid == 1)begin
                    min_value <= check_value;
                    min_index <= counter_area;
                end
            end
        end
    end
end


always_comb begin
    out1 = 0;
    out2 = 0;
    case(min_index) 
        28, 36, 44, 52, 60: out1 = 110;
        29, 37, 45, 53, 61: out1 = 111;
        30, 38, 46, 54, 62: out1 = 000;
        31, 39, 47, 55, 63: out1 = 001;
        32, 40, 48, 56, 64: out1 = 010;
    endcase
    case(min_index) 
        28, 29, 30, 31, 32: out2 = 010;
        36, 37, 38, 39, 40: out2 = 001;
        44, 45, 46, 47, 48: out2 = 000;
        52, 53, 54, 55, 56: out2 = 111;
        60, 61, 62, 63, 64: out2 = 110;
    endcase
end

endmodule
