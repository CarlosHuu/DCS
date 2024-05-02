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
logic [7:0] block_data [15:0];
logic [7:0] area_data [63:0];
logic [11:0] SAD [24:0];
logic [11:0] SAD_reg [24:0];
logic [11:0] min_row1, min_row2, min_row3, min_row4, min_row5, min_sad;
logic signed [2:0] x_vector, y_vector;
logic [3:0] cnt, cnt_next;
logic signed [2:0] out_vector_comb;
logic [1:0] out;
//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------

always_ff @ (posedge clk, negedge rst_n)begin
    if(!rst_n) begin
        block_data[0] <= 0;     block_data[4] <= 0;     block_data[8] <= 0;     block_data[12] <= 0;
        block_data[1] <= 0;     block_data[5] <= 0;     block_data[9] <= 0;     block_data[13] <= 0;
        block_data[2] <= 0;     block_data[6] <= 0;     block_data[10] <= 0;     block_data[14] <= 0;
        block_data[3] <= 0;     block_data[7] <= 0;     block_data[11] <= 0;     block_data[15] <= 0;
    end
    else if(block_valid)begin
        block_data[0] <= block_data[1];     block_data[4] <= block_data[5];     block_data[8] <= block_data[9];     block_data[12] <= block_data[13];     
        block_data[1] <= block_data[2];     block_data[5] <= block_data[6];     block_data[9] <= block_data[10];     block_data[13] <= block_data[14];
        block_data[2] <= block_data[3];     block_data[6] <= block_data[7];     block_data[10] <= block_data[11];     block_data[14] <= block_data[15];
        block_data[3] <= block_data[4];     block_data[7] <= block_data[8];     block_data[11] <= block_data[12];     block_data[15] <= in_data;
    end

    else begin
        block_data[0] <= block_data[0];     block_data[4] <= block_data[4];     block_data[8] <= block_data[8];     block_data[12] <= block_data[12];     
        block_data[1] <= block_data[1];     block_data[5] <= block_data[5];     block_data[9] <= block_data[9];     block_data[13] <= block_data[13];
        block_data[2] <= block_data[2];     block_data[6] <= block_data[6];     block_data[10] <= block_data[10];     block_data[14] <= block_data[14];
        block_data[3] <= block_data[3];     block_data[7] <= block_data[7];     block_data[11] <= block_data[11];     block_data[15] <= block_data[15];
    end
end

always_ff @ (posedge clk, negedge rst_n)begin
    if(!rst_n) begin
        area_data[0] <= 0;     area_data[16] <= 0;     area_data[32] <= 0;     area_data[48] <= 0;
        area_data[1] <= 0;     area_data[17] <= 0;     area_data[33] <= 0;     area_data[49] <= 0;
        area_data[2] <= 0;     area_data[18] <= 0;     area_data[34] <= 0;     area_data[50] <= 0;
        area_data[3] <= 0;     area_data[19] <= 0;     area_data[35] <= 0;     area_data[51] <= 0;
        area_data[4] <= 0;     area_data[20] <= 0;     area_data[36] <= 0;     area_data[52] <= 0;
        area_data[5] <= 0;     area_data[21] <= 0;     area_data[37] <= 0;     area_data[53] <= 0;
        area_data[6] <= 0;     area_data[22] <= 0;     area_data[38] <= 0;     area_data[54] <= 0;
        area_data[7] <= 0;     area_data[23] <= 0;     area_data[39] <= 0;     area_data[55] <= 0;
        area_data[8] <= 0;     area_data[24] <= 0;     area_data[40] <= 0;     area_data[56] <= 0;
        area_data[9] <= 0;     area_data[25] <= 0;     area_data[41] <= 0;     area_data[57] <= 0;
        area_data[10] <= 0;     area_data[26] <= 0;     area_data[42] <= 0;     area_data[58] <= 0;
        area_data[11] <= 0;     area_data[27] <= 0;     area_data[43] <= 0;     area_data[59] <= 0;
        area_data[12] <= 0;     area_data[28] <= 0;     area_data[44] <= 0;     area_data[60] <= 0;
        area_data[13] <= 0;     area_data[29] <= 0;     area_data[45] <= 0;     area_data[61] <= 0;
        area_data[14] <= 0;     area_data[30] <= 0;     area_data[46] <= 0;     area_data[62] <= 0;
        area_data[15] <= 0;     area_data[31] <= 0;     area_data[47] <= 0;     area_data[63] <= 0; 
    end
    else if(area_valid)begin
        area_data[0] <= area_data[1];     area_data[16] <= area_data[17];     area_data[32] <= area_data[33];     area_data[48] <= area_data[49];     
        area_data[1] <= area_data[2];     area_data[17] <= area_data[18];     area_data[33] <= area_data[34];     area_data[49] <= area_data[50];     
        area_data[2] <= area_data[3];     area_data[18] <= area_data[19];     area_data[34] <= area_data[35];     area_data[50] <= area_data[51];     
        area_data[3] <= area_data[4];     area_data[19] <= area_data[20];     area_data[35] <= area_data[36];     area_data[51] <= area_data[52];     
        area_data[4] <= area_data[5];     area_data[20] <= area_data[21];     area_data[36] <= area_data[37];     area_data[52] <= area_data[53];     
        area_data[5] <= area_data[6];     area_data[21] <= area_data[22];     area_data[37] <= area_data[38];     area_data[53] <= area_data[54];     
        area_data[6] <= area_data[7];     area_data[22] <= area_data[23];     area_data[38] <= area_data[39];     area_data[54] <= area_data[55];     
        area_data[7] <= area_data[8];     area_data[23] <= area_data[24];     area_data[39] <= area_data[40];     area_data[55] <= area_data[56];     
        area_data[8] <= area_data[9];     area_data[24] <= area_data[25];     area_data[40] <= area_data[41];     area_data[56] <= area_data[57];     
        area_data[9] <= area_data[10];     area_data[25] <= area_data[26];     area_data[41] <= area_data[42];     area_data[57] <= area_data[58];
        area_data[10] <= area_data[11];     area_data[26] <= area_data[27];     area_data[42] <= area_data[43];     area_data[58] <= area_data[59];     
        area_data[11] <= area_data[12];     area_data[27] <= area_data[28];     area_data[43] <= area_data[44];     area_data[59] <= area_data[60];
        area_data[12] <= area_data[13];     area_data[28] <= area_data[29];     area_data[44] <= area_data[45];     area_data[60] <= area_data[61];
        area_data[13] <= area_data[14];     area_data[29] <= area_data[30];     area_data[45] <= area_data[46];     area_data[61] <= area_data[62];
        area_data[14] <= area_data[15];     area_data[30] <= area_data[31];     area_data[46] <= area_data[47];     area_data[62] <= area_data[63];
        area_data[15] <= area_data[16];     area_data[31] <= area_data[32];     area_data[47] <= area_data[48];     area_data[63] <= in_data;
    end

    else begin
        area_data[0] <= area_data[0];     area_data[16] <= area_data[16];     area_data[32] <= area_data[32];     area_data[48] <= area_data[48];     
        area_data[1] <= area_data[1];     area_data[17] <= area_data[17];     area_data[33] <= area_data[33];     area_data[49] <= area_data[49];     
        area_data[2] <= area_data[2];     area_data[18] <= area_data[18];     area_data[34] <= area_data[34];     area_data[50] <= area_data[50];     
        area_data[3] <= area_data[3];     area_data[19] <= area_data[19];     area_data[35] <= area_data[35];     area_data[51] <= area_data[51];     
        area_data[4] <= area_data[4];     area_data[20] <= area_data[20];     area_data[36] <= area_data[36];     area_data[52] <= area_data[52];     
        area_data[5] <= area_data[5];     area_data[21] <= area_data[21];     area_data[37] <= area_data[37];     area_data[53] <= area_data[53];     
        area_data[6] <= area_data[6];     area_data[22] <= area_data[22];     area_data[38] <= area_data[38];     area_data[54] <= area_data[54];     
        area_data[7] <= area_data[7];     area_data[23] <= area_data[23];     area_data[39] <= area_data[39];     area_data[55] <= area_data[55];     
        area_data[8] <= area_data[8];     area_data[24] <= area_data[24];     area_data[40] <= area_data[40];     area_data[56] <= area_data[56];     
        area_data[9] <= area_data[9];     area_data[25] <= area_data[25];     area_data[41] <= area_data[41];     area_data[57] <= area_data[57];
        area_data[10] <= area_data[10];     area_data[26] <= area_data[26];     area_data[42] <= area_data[42];     area_data[58] <= area_data[58];
        area_data[11] <= area_data[11];     area_data[27] <= area_data[27];     area_data[43] <= area_data[43];     area_data[59] <= area_data[59];
        area_data[12] <= area_data[12];     area_data[28] <= area_data[28];     area_data[44] <= area_data[44];     area_data[60] <= area_data[60];
        area_data[13] <= area_data[13];     area_data[29] <= area_data[29];     area_data[45] <= area_data[45];     area_data[61] <= area_data[61];
        area_data[14] <= area_data[14];     area_data[30] <= area_data[30];     area_data[46] <= area_data[46];     area_data[62] <= area_data[62];
        area_data[15] <= area_data[15];     area_data[31] <= area_data[31];     area_data[47] <= area_data[47];     area_data[63] <= area_data[63];
    end
end

SAD_compute SAD_0(  .in_area_0(area_data[0]), .in_area_1(area_data[1]), .in_area_2(area_data[2]), .in_area_3(area_data[3]), 
                    .in_area_4(area_data[8]), .in_area_5(area_data[9]), .in_area_6(area_data[10]), .in_area_7(area_data[11]), 
                    .in_area_8(area_data[16]), .in_area_9(area_data[17]), .in_area_10(area_data[18]), .in_area_11(area_data[19]), 
                    .in_area_12(area_data[24]), .in_area_13(area_data[25]), .in_area_14(area_data[26]), .in_area_15(area_data[27]),
                    .in_block_0(block_data[0]), .in_block_1(block_data[1]), .in_block_2(block_data[2]), .in_block_3(block_data[3]), 
                    .in_block_4(block_data[4]), .in_block_5(block_data[5]), .in_block_6(block_data[6]), .in_block_7(block_data[7]), 
                    .in_block_8(block_data[8]), .in_block_9(block_data[9]), .in_block_10(block_data[10]), .in_block_11(block_data[11]), 
                    .in_block_12(block_data[12]), .in_block_13(block_data[13]), .in_block_14(block_data[14]), .in_block_15(block_data[15]),
                    .out(SAD[0])
                );
SAD_compute SAD_1(  .in_area_0(area_data[1]), .in_area_1(area_data[2]), .in_area_2(area_data[3]), .in_area_3(area_data[4]),
                    .in_area_4(area_data[9]), .in_area_5(area_data[10]), .in_area_6(area_data[11]), .in_area_7(area_data[12]),
                    .in_area_8(area_data[17]), .in_area_9(area_data[18]), .in_area_10(area_data[19]), .in_area_11(area_data[20]),
                    .in_area_12(area_data[25]), .in_area_13(area_data[26]), .in_area_14(area_data[27]), .in_area_15(area_data[28]),
                    .in_block_0(block_data[0]), .in_block_1(block_data[1]), .in_block_2(block_data[2]), .in_block_3(block_data[3]), 
                    .in_block_4(block_data[4]), .in_block_5(block_data[5]), .in_block_6(block_data[6]), .in_block_7(block_data[7]), 
                    .in_block_8(block_data[8]), .in_block_9(block_data[9]), .in_block_10(block_data[10]), .in_block_11(block_data[11]), 
                    .in_block_12(block_data[12]), .in_block_13(block_data[13]), .in_block_14(block_data[14]), .in_block_15(block_data[15]),
                    .out(SAD[1])
                );
SAD_compute SAD_2(  .in_area_0(area_data[2]), .in_area_1(area_data[3]), .in_area_2(area_data[4]), .in_area_3(area_data[5]),
                    .in_area_4(area_data[10]), .in_area_5(area_data[11]), .in_area_6(area_data[12]), .in_area_7(area_data[13]),
                    .in_area_8(area_data[18]), .in_area_9(area_data[19]), .in_area_10(area_data[20]), .in_area_11(area_data[21]),
                    .in_area_12(area_data[26]), .in_area_13(area_data[27]), .in_area_14(area_data[28]), .in_area_15(area_data[29]),
                    .in_block_0(block_data[0]), .in_block_1(block_data[1]), .in_block_2(block_data[2]), .in_block_3(block_data[3]), 
                    .in_block_4(block_data[4]), .in_block_5(block_data[5]), .in_block_6(block_data[6]), .in_block_7(block_data[7]), 
                    .in_block_8(block_data[8]), .in_block_9(block_data[9]), .in_block_10(block_data[10]), .in_block_11(block_data[11]), 
                    .in_block_12(block_data[12]), .in_block_13(block_data[13]), .in_block_14(block_data[14]), .in_block_15(block_data[15]),
                    .out(SAD[2])
                );
SAD_compute SAD_3(  .in_area_0(area_data[3]), .in_area_1(area_data[4]), .in_area_2(area_data[5]), .in_area_3(area_data[6]),
                    .in_area_4(area_data[11]), .in_area_5(area_data[12]), .in_area_6(area_data[13]), .in_area_7(area_data[14]),
                    .in_area_8(area_data[19]), .in_area_9(area_data[20]), .in_area_10(area_data[21]), .in_area_11(area_data[22]),
                    .in_area_12(area_data[27]), .in_area_13(area_data[28]), .in_area_14(area_data[29]), .in_area_15(area_data[30]),
                    .in_block_0(block_data[0]), .in_block_1(block_data[1]), .in_block_2(block_data[2]), .in_block_3(block_data[3]), 
                    .in_block_4(block_data[4]), .in_block_5(block_data[5]), .in_block_6(block_data[6]), .in_block_7(block_data[7]), 
                    .in_block_8(block_data[8]), .in_block_9(block_data[9]), .in_block_10(block_data[10]), .in_block_11(block_data[11]), 
                    .in_block_12(block_data[12]), .in_block_13(block_data[13]), .in_block_14(block_data[14]), .in_block_15(block_data[15]),
                    .out(SAD[3])
                );
SAD_compute SAD_4(  .in_area_0(area_data[4]), .in_area_1(area_data[5]), .in_area_2(area_data[6]), .in_area_3(area_data[7]),
                    .in_area_4(area_data[12]), .in_area_5(area_data[13]), .in_area_6(area_data[14]), .in_area_7(area_data[15]),
                    .in_area_8(area_data[20]), .in_area_9(area_data[21]), .in_area_10(area_data[22]), .in_area_11(area_data[23]),
                    .in_area_12(area_data[28]), .in_area_13(area_data[29]), .in_area_14(area_data[30]), .in_area_15(area_data[31]),
                    .in_block_0(block_data[0]), .in_block_1(block_data[1]), .in_block_2(block_data[2]), .in_block_3(block_data[3]), 
                    .in_block_4(block_data[4]), .in_block_5(block_data[5]), .in_block_6(block_data[6]), .in_block_7(block_data[7]), 
                    .in_block_8(block_data[8]), .in_block_9(block_data[9]), .in_block_10(block_data[10]), .in_block_11(block_data[11]), 
                    .in_block_12(block_data[12]), .in_block_13(block_data[13]), .in_block_14(block_data[14]), .in_block_15(block_data[15]),
                    .out(SAD[4])
                );
SAD_compute SAD_5(
                    .in_area_0(area_data[8]), .in_area_1(area_data[9]), .in_area_2(area_data[10]), .in_area_3(area_data[11]),
                    .in_area_4(area_data[16]), .in_area_5(area_data[17]), .in_area_6(area_data[18]), .in_area_7(area_data[19]),
                    .in_area_8(area_data[24]), .in_area_9(area_data[25]), .in_area_10(area_data[26]), .in_area_11(area_data[27]),
                    .in_area_12(area_data[32]), .in_area_13(area_data[33]), .in_area_14(area_data[34]), .in_area_15(area_data[35]),
                    .in_block_0(block_data[0]), .in_block_1(block_data[1]), .in_block_2(block_data[2]), .in_block_3(block_data[3]),
                    .in_block_4(block_data[4]), .in_block_5(block_data[5]), .in_block_6(block_data[6]), .in_block_7(block_data[7]),
                    .in_block_8(block_data[8]), .in_block_9(block_data[9]), .in_block_10(block_data[10]), .in_block_11(block_data[11]),
                    .in_block_12(block_data[12]), .in_block_13(block_data[13]), .in_block_14(block_data[14]), .in_block_15(block_data[15]),
                    .out(SAD[5])
                );
SAD_compute SAD_6(
                    .in_area_0(area_data[9]), .in_area_1(area_data[10]), .in_area_2(area_data[11]), .in_area_3(area_data[12]),
                    .in_area_4(area_data[17]), .in_area_5(area_data[18]), .in_area_6(area_data[19]), .in_area_7(area_data[20]),
                    .in_area_8(area_data[25]), .in_area_9(area_data[26]), .in_area_10(area_data[27]), .in_area_11(area_data[28]),
                    .in_area_12(area_data[33]), .in_area_13(area_data[34]), .in_area_14(area_data[35]), .in_area_15(area_data[36]),
                    .in_block_0(block_data[0]), .in_block_1(block_data[1]), .in_block_2(block_data[2]), .in_block_3(block_data[3]),
                    .in_block_4(block_data[4]), .in_block_5(block_data[5]), .in_block_6(block_data[6]), .in_block_7(block_data[7]),
                    .in_block_8(block_data[8]), .in_block_9(block_data[9]), .in_block_10(block_data[10]), .in_block_11(block_data[11]),
                    .in_block_12(block_data[12]), .in_block_13(block_data[13]), .in_block_14(block_data[14]), .in_block_15(block_data[15]),
                    .out(SAD[6])
                );
SAD_compute SAD_7(
                    .in_area_0(area_data[10]), .in_area_1(area_data[11]), .in_area_2(area_data[12]), .in_area_3(area_data[13]),
                    .in_area_4(area_data[18]), .in_area_5(area_data[19]), .in_area_6(area_data[20]), .in_area_7(area_data[21]),
                    .in_area_8(area_data[26]), .in_area_9(area_data[27]), .in_area_10(area_data[28]), .in_area_11(area_data[29]),
                    .in_area_12(area_data[34]), .in_area_13(area_data[35]), .in_area_14(area_data[36]), .in_area_15(area_data[37]),
                    .in_block_0(block_data[0]), .in_block_1(block_data[1]), .in_block_2(block_data[2]), .in_block_3(block_data[3]),
                    .in_block_4(block_data[4]), .in_block_5(block_data[5]), .in_block_6(block_data[6]), .in_block_7(block_data[7]),
                    .in_block_8(block_data[8]), .in_block_9(block_data[9]), .in_block_10(block_data[10]), .in_block_11(block_data[11]),
                    .in_block_12(block_data[12]), .in_block_13(block_data[13]), .in_block_14(block_data[14]), .in_block_15(block_data[15]),
                    .out(SAD[7])
                );
SAD_compute SAD_8(
                    .in_area_0(area_data[11]), .in_area_1(area_data[12]), .in_area_2(area_data[13]), .in_area_3(area_data[14]),
                    .in_area_4(area_data[19]), .in_area_5(area_data[20]), .in_area_6(area_data[21]), .in_area_7(area_data[22]),
                    .in_area_8(area_data[27]), .in_area_9(area_data[28]), .in_area_10(area_data[29]), .in_area_11(area_data[30]),
                    .in_area_12(area_data[35]), .in_area_13(area_data[36]), .in_area_14(area_data[37]), .in_area_15(area_data[38]),
                    .in_block_0(block_data[0]), .in_block_1(block_data[1]), .in_block_2(block_data[2]), .in_block_3(block_data[3]),
                    .in_block_4(block_data[4]), .in_block_5(block_data[5]), .in_block_6(block_data[6]), .in_block_7(block_data[7]),
                    .in_block_8(block_data[8]), .in_block_9(block_data[9]), .in_block_10(block_data[10]), .in_block_11(block_data[11]),
                    .in_block_12(block_data[12]), .in_block_13(block_data[13]), .in_block_14(block_data[14]), .in_block_15(block_data[15]),
                    .out(SAD[8])
                );
SAD_compute SAD_9(
                    .in_area_0(area_data[12]), .in_area_1(area_data[13]), .in_area_2(area_data[14]), .in_area_3(area_data[15]),
                    .in_area_4(area_data[20]), .in_area_5(area_data[21]), .in_area_6(area_data[22]), .in_area_7(area_data[23]),
                    .in_area_8(area_data[28]), .in_area_9(area_data[29]), .in_area_10(area_data[30]), .in_area_11(area_data[31]),
                    .in_area_12(area_data[36]), .in_area_13(area_data[37]), .in_area_14(area_data[38]), .in_area_15(area_data[39]),
                    .in_block_0(block_data[0]), .in_block_1(block_data[1]), .in_block_2(block_data[2]), .in_block_3(block_data[3]),
                    .in_block_4(block_data[4]), .in_block_5(block_data[5]), .in_block_6(block_data[6]), .in_block_7(block_data[7]),
                    .in_block_8(block_data[8]), .in_block_9(block_data[9]), .in_block_10(block_data[10]), .in_block_11(block_data[11]),
                    .in_block_12(block_data[12]), .in_block_13(block_data[13]), .in_block_14(block_data[14]), .in_block_15(block_data[15]),
                    .out(SAD[9])
                );
SAD_compute SAD_10(
                    .in_area_0(area_data[16]), .in_area_1(area_data[17]), .in_area_2(area_data[18]), .in_area_3(area_data[19]),
                    .in_area_4(area_data[24]), .in_area_5(area_data[25]), .in_area_6(area_data[26]), .in_area_7(area_data[27]),
                    .in_area_8(area_data[32]), .in_area_9(area_data[33]), .in_area_10(area_data[34]), .in_area_11(area_data[35]),
                    .in_area_12(area_data[40]), .in_area_13(area_data[41]), .in_area_14(area_data[42]), .in_area_15(area_data[43]),
                    .in_block_0(block_data[0]), .in_block_1(block_data[1]), .in_block_2(block_data[2]), .in_block_3(block_data[3]),
                    .in_block_4(block_data[4]), .in_block_5(block_data[5]), .in_block_6(block_data[6]), .in_block_7(block_data[7]),
                    .in_block_8(block_data[8]), .in_block_9(block_data[9]), .in_block_10(block_data[10]), .in_block_11(block_data[11]),
                    .in_block_12(block_data[12]), .in_block_13(block_data[13]), .in_block_14(block_data[14]), .in_block_15(block_data[15]),
                    .out(SAD[10])
                );
SAD_compute SAD_11(
                    .in_area_0(area_data[17]), .in_area_1(area_data[18]), .in_area_2(area_data[19]), .in_area_3(area_data[20]),
                    .in_area_4(area_data[25]), .in_area_5(area_data[26]), .in_area_6(area_data[27]), .in_area_7(area_data[28]),
                    .in_area_8(area_data[33]), .in_area_9(area_data[34]), .in_area_10(area_data[35]), .in_area_11(area_data[36]),
                    .in_area_12(area_data[41]), .in_area_13(area_data[42]), .in_area_14(area_data[43]), .in_area_15(area_data[44]),
                    .in_block_0(block_data[0]), .in_block_1(block_data[1]), .in_block_2(block_data[2]), .in_block_3(block_data[3]),
                    .in_block_4(block_data[4]), .in_block_5(block_data[5]), .in_block_6(block_data[6]), .in_block_7(block_data[7]),
                    .in_block_8(block_data[8]), .in_block_9(block_data[9]), .in_block_10(block_data[10]), .in_block_11(block_data[11]),
                    .in_block_12(block_data[12]), .in_block_13(block_data[13]), .in_block_14(block_data[14]), .in_block_15(block_data[15]),
                    .out(SAD[11])
                );
SAD_compute SAD_12(
                    .in_area_0(area_data[18]), .in_area_1(area_data[19]), .in_area_2(area_data[20]), .in_area_3(area_data[21]),
                    .in_area_4(area_data[26]), .in_area_5(area_data[27]), .in_area_6(area_data[28]), .in_area_7(area_data[29]),
                    .in_area_8(area_data[34]), .in_area_9(area_data[35]), .in_area_10(area_data[36]), .in_area_11(area_data[37]),
                    .in_area_12(area_data[42]), .in_area_13(area_data[43]), .in_area_14(area_data[44]), .in_area_15(area_data[45]),
                    .in_block_0(block_data[0]), .in_block_1(block_data[1]), .in_block_2(block_data[2]), .in_block_3(block_data[3]),
                    .in_block_4(block_data[4]), .in_block_5(block_data[5]), .in_block_6(block_data[6]), .in_block_7(block_data[7]),
                    .in_block_8(block_data[8]), .in_block_9(block_data[9]), .in_block_10(block_data[10]), .in_block_11(block_data[11]),
                    .in_block_12(block_data[12]), .in_block_13(block_data[13]), .in_block_14(block_data[14]), .in_block_15(block_data[15]),
                    .out(SAD[12])
                );
SAD_compute SAD_13(
                    .in_area_0(area_data[19]), .in_area_1(area_data[20]), .in_area_2(area_data[21]), .in_area_3(area_data[22]),
                    .in_area_4(area_data[27]), .in_area_5(area_data[28]), .in_area_6(area_data[29]), .in_area_7(area_data[30]),
                    .in_area_8(area_data[35]), .in_area_9(area_data[36]), .in_area_10(area_data[37]), .in_area_11(area_data[38]),
                    .in_area_12(area_data[43]), .in_area_13(area_data[44]), .in_area_14(area_data[45]), .in_area_15(area_data[46]),
                    .in_block_0(block_data[0]), .in_block_1(block_data[1]), .in_block_2(block_data[2]), .in_block_3(block_data[3]),
                    .in_block_4(block_data[4]), .in_block_5(block_data[5]), .in_block_6(block_data[6]), .in_block_7(block_data[7]),
                    .in_block_8(block_data[8]), .in_block_9(block_data[9]), .in_block_10(block_data[10]), .in_block_11(block_data[11]),
                    .in_block_12(block_data[12]), .in_block_13(block_data[13]), .in_block_14(block_data[14]), .in_block_15(block_data[15]),
                    .out(SAD[13])
                );
SAD_compute SAD_14(
                    .in_area_0(area_data[20]), .in_area_1(area_data[21]), .in_area_2(area_data[22]), .in_area_3(area_data[23]),
                    .in_area_4(area_data[28]), .in_area_5(area_data[29]), .in_area_6(area_data[30]), .in_area_7(area_data[31]),
                    .in_area_8(area_data[36]), .in_area_9(area_data[37]), .in_area_10(area_data[38]), .in_area_11(area_data[39]),
                    .in_area_12(area_data[44]), .in_area_13(area_data[45]), .in_area_14(area_data[46]), .in_area_15(area_data[47]),
                    .in_block_0(block_data[0]), .in_block_1(block_data[1]), .in_block_2(block_data[2]), .in_block_3(block_data[3]),
                    .in_block_4(block_data[4]), .in_block_5(block_data[5]), .in_block_6(block_data[6]), .in_block_7(block_data[7]),
                    .in_block_8(block_data[8]), .in_block_9(block_data[9]), .in_block_10(block_data[10]), .in_block_11(block_data[11]),
                    .in_block_12(block_data[12]), .in_block_13(block_data[13]), .in_block_14(block_data[14]), .in_block_15(block_data[15]),
                    .out(SAD[14])
                );
SAD_compute SAD_15(
                    .in_area_0(area_data[24]), .in_area_1(area_data[25]), .in_area_2(area_data[26]), .in_area_3(area_data[27]),
                    .in_area_4(area_data[32]), .in_area_5(area_data[33]), .in_area_6(area_data[34]), .in_area_7(area_data[35]),
                    .in_area_8(area_data[40]), .in_area_9(area_data[41]), .in_area_10(area_data[42]), .in_area_11(area_data[43]),
                    .in_area_12(area_data[48]), .in_area_13(area_data[49]), .in_area_14(area_data[50]), .in_area_15(area_data[51]),
                    .in_block_0(block_data[0]), .in_block_1(block_data[1]), .in_block_2(block_data[2]), .in_block_3(block_data[3]),
                    .in_block_4(block_data[4]), .in_block_5(block_data[5]), .in_block_6(block_data[6]), .in_block_7(block_data[7]),
                    .in_block_8(block_data[8]), .in_block_9(block_data[9]), .in_block_10(block_data[10]), .in_block_11(block_data[11]),
                    .in_block_12(block_data[12]), .in_block_13(block_data[13]), .in_block_14(block_data[14]), .in_block_15(block_data[15]),
                    .out(SAD[15])
                );
SAD_compute SAD_16(
                    .in_area_0(area_data[25]), .in_area_1(area_data[26]), .in_area_2(area_data[27]), .in_area_3(area_data[28]),
                    .in_area_4(area_data[33]), .in_area_5(area_data[34]), .in_area_6(area_data[35]), .in_area_7(area_data[36]),
                    .in_area_8(area_data[41]), .in_area_9(area_data[42]), .in_area_10(area_data[43]), .in_area_11(area_data[44]),
                    .in_area_12(area_data[49]), .in_area_13(area_data[50]), .in_area_14(area_data[51]), .in_area_15(area_data[52]),
                    .in_block_0(block_data[0]), .in_block_1(block_data[1]), .in_block_2(block_data[2]), .in_block_3(block_data[3]),
                    .in_block_4(block_data[4]), .in_block_5(block_data[5]), .in_block_6(block_data[6]), .in_block_7(block_data[7]),
                    .in_block_8(block_data[8]), .in_block_9(block_data[9]), .in_block_10(block_data[10]), .in_block_11(block_data[11]),
                    .in_block_12(block_data[12]), .in_block_13(block_data[13]), .in_block_14(block_data[14]), .in_block_15(block_data[15]),
                    .out(SAD[16])
                );
SAD_compute SAD_17(
                    .in_area_0(area_data[26]), .in_area_1(area_data[27]), .in_area_2(area_data[28]), .in_area_3(area_data[29]),
                    .in_area_4(area_data[34]), .in_area_5(area_data[35]), .in_area_6(area_data[36]), .in_area_7(area_data[37]),
                    .in_area_8(area_data[42]), .in_area_9(area_data[43]), .in_area_10(area_data[44]), .in_area_11(area_data[45]),
                    .in_area_12(area_data[50]), .in_area_13(area_data[51]), .in_area_14(area_data[52]), .in_area_15(area_data[53]),
                    .in_block_0(block_data[0]), .in_block_1(block_data[1]), .in_block_2(block_data[2]), .in_block_3(block_data[3]),
                    .in_block_4(block_data[4]), .in_block_5(block_data[5]), .in_block_6(block_data[6]), .in_block_7(block_data[7]),
                    .in_block_8(block_data[8]), .in_block_9(block_data[9]), .in_block_10(block_data[10]), .in_block_11(block_data[11]),
                    .in_block_12(block_data[12]), .in_block_13(block_data[13]), .in_block_14(block_data[14]), .in_block_15(block_data[15]),
                    .out(SAD[17])
                );
SAD_compute SAD_18(
                    .in_area_0(area_data[27]), .in_area_1(area_data[28]), .in_area_2(area_data[29]), .in_area_3(area_data[30]),
                    .in_area_4(area_data[35]), .in_area_5(area_data[36]), .in_area_6(area_data[37]), .in_area_7(area_data[38]),
                    .in_area_8(area_data[43]), .in_area_9(area_data[44]), .in_area_10(area_data[45]), .in_area_11(area_data[46]),
                    .in_area_12(area_data[51]), .in_area_13(area_data[52]), .in_area_14(area_data[53]), .in_area_15(area_data[54]),
                    .in_block_0(block_data[0]), .in_block_1(block_data[1]), .in_block_2(block_data[2]), .in_block_3(block_data[3]),
                    .in_block_4(block_data[4]), .in_block_5(block_data[5]), .in_block_6(block_data[6]), .in_block_7(block_data[7]),
                    .in_block_8(block_data[8]), .in_block_9(block_data[9]), .in_block_10(block_data[10]), .in_block_11(block_data[11]),
                    .in_block_12(block_data[12]), .in_block_13(block_data[13]), .in_block_14(block_data[14]), .in_block_15(block_data[15]),
                    .out(SAD[18])
                );
SAD_compute SAD_19(
                    .in_area_0(area_data[28]), .in_area_1(area_data[29]), .in_area_2(area_data[30]), .in_area_3(area_data[31]),
                    .in_area_4(area_data[36]), .in_area_5(area_data[37]), .in_area_6(area_data[38]), .in_area_7(area_data[39]),
                    .in_area_8(area_data[44]), .in_area_9(area_data[45]), .in_area_10(area_data[46]), .in_area_11(area_data[47]),
                    .in_area_12(area_data[52]), .in_area_13(area_data[53]), .in_area_14(area_data[54]), .in_area_15(area_data[55]),
                    .in_block_0(block_data[0]), .in_block_1(block_data[1]), .in_block_2(block_data[2]), .in_block_3(block_data[3]),
                    .in_block_4(block_data[4]), .in_block_5(block_data[5]), .in_block_6(block_data[6]), .in_block_7(block_data[7]),
                    .in_block_8(block_data[8]), .in_block_9(block_data[9]), .in_block_10(block_data[10]), .in_block_11(block_data[11]),
                    .in_block_12(block_data[12]), .in_block_13(block_data[13]), .in_block_14(block_data[14]), .in_block_15(block_data[15]),
                    .out(SAD[19])
                );
SAD_compute SAD_20(
                    .in_area_0(area_data[32]), .in_area_1(area_data[33]), .in_area_2(area_data[34]), .in_area_3(area_data[35]),
                    .in_area_4(area_data[40]), .in_area_5(area_data[41]), .in_area_6(area_data[42]), .in_area_7(area_data[43]),
                    .in_area_8(area_data[48]), .in_area_9(area_data[49]), .in_area_10(area_data[50]), .in_area_11(area_data[51]),
                    .in_area_12(area_data[56]), .in_area_13(area_data[57]), .in_area_14(area_data[58]), .in_area_15(area_data[59]),
                    .in_block_0(block_data[0]), .in_block_1(block_data[1]), .in_block_2(block_data[2]), .in_block_3(block_data[3]),
                    .in_block_4(block_data[4]), .in_block_5(block_data[5]), .in_block_6(block_data[6]), .in_block_7(block_data[7]),
                    .in_block_8(block_data[8]), .in_block_9(block_data[9]), .in_block_10(block_data[10]), .in_block_11(block_data[11]),
                    .in_block_12(block_data[12]), .in_block_13(block_data[13]), .in_block_14(block_data[14]), .in_block_15(block_data[15]),
                    .out(SAD[20])
                );
SAD_compute SAD_21(
                    .in_area_0(area_data[33]), .in_area_1(area_data[34]), .in_area_2(area_data[35]), .in_area_3(area_data[36]),
                    .in_area_4(area_data[41]), .in_area_5(area_data[42]), .in_area_6(area_data[43]), .in_area_7(area_data[44]),
                    .in_area_8(area_data[49]), .in_area_9(area_data[50]), .in_area_10(area_data[51]), .in_area_11(area_data[52]),
                    .in_area_12(area_data[57]), .in_area_13(area_data[58]), .in_area_14(area_data[59]), .in_area_15(area_data[60]),
                    .in_block_0(block_data[0]), .in_block_1(block_data[1]), .in_block_2(block_data[2]), .in_block_3(block_data[3]),
                    .in_block_4(block_data[4]), .in_block_5(block_data[5]), .in_block_6(block_data[6]), .in_block_7(block_data[7]),
                    .in_block_8(block_data[8]), .in_block_9(block_data[9]), .in_block_10(block_data[10]), .in_block_11(block_data[11]),
                    .in_block_12(block_data[12]), .in_block_13(block_data[13]), .in_block_14(block_data[14]), .in_block_15(block_data[15]),
                    .out(SAD[21])
                );
SAD_compute SAD_22(
                    .in_area_0(area_data[34]), .in_area_1(area_data[35]), .in_area_2(area_data[36]), .in_area_3(area_data[37]),
                    .in_area_4(area_data[42]), .in_area_5(area_data[43]), .in_area_6(area_data[44]), .in_area_7(area_data[45]),
                    .in_area_8(area_data[50]), .in_area_9(area_data[51]), .in_area_10(area_data[52]), .in_area_11(area_data[53]),
                    .in_area_12(area_data[58]), .in_area_13(area_data[59]), .in_area_14(area_data[60]), .in_area_15(area_data[61]),
                    .in_block_0(block_data[0]), .in_block_1(block_data[1]), .in_block_2(block_data[2]), .in_block_3(block_data[3]),
                    .in_block_4(block_data[4]), .in_block_5(block_data[5]), .in_block_6(block_data[6]), .in_block_7(block_data[7]),
                    .in_block_8(block_data[8]), .in_block_9(block_data[9]), .in_block_10(block_data[10]), .in_block_11(block_data[11]),
                    .in_block_12(block_data[12]), .in_block_13(block_data[13]), .in_block_14(block_data[14]), .in_block_15(block_data[15]),
                    .out(SAD[22])
                );
SAD_compute SAD_23(
                    .in_area_0(area_data[35]), .in_area_1(area_data[36]), .in_area_2(area_data[37]), .in_area_3(area_data[38]),
                    .in_area_4(area_data[43]), .in_area_5(area_data[44]), .in_area_6(area_data[45]), .in_area_7(area_data[46]),
                    .in_area_8(area_data[51]), .in_area_9(area_data[52]), .in_area_10(area_data[53]), .in_area_11(area_data[54]),
                    .in_area_12(area_data[59]), .in_area_13(area_data[60]), .in_area_14(area_data[61]), .in_area_15(area_data[62]),
                    .in_block_0(block_data[0]), .in_block_1(block_data[1]), .in_block_2(block_data[2]), .in_block_3(block_data[3]),
                    .in_block_4(block_data[4]), .in_block_5(block_data[5]), .in_block_6(block_data[6]), .in_block_7(block_data[7]),
                    .in_block_8(block_data[8]), .in_block_9(block_data[9]), .in_block_10(block_data[10]), .in_block_11(block_data[11]),
                    .in_block_12(block_data[12]), .in_block_13(block_data[13]), .in_block_14(block_data[14]), .in_block_15(block_data[15]),
                    .out(SAD[23])
                );
SAD_compute SAD_24(
                    .in_area_0(area_data[36]), .in_area_1(area_data[37]), .in_area_2(area_data[38]), .in_area_3(area_data[39]),
                    .in_area_4(area_data[44]), .in_area_5(area_data[45]), .in_area_6(area_data[46]), .in_area_7(area_data[47]),
                    .in_area_8(area_data[52]), .in_area_9(area_data[53]), .in_area_10(area_data[54]), .in_area_11(area_data[55]),
                    .in_area_12(area_data[60]), .in_area_13(area_data[61]), .in_area_14(area_data[62]), .in_area_15(area_data[63]),
                    .in_block_0(block_data[0]), .in_block_1(block_data[1]), .in_block_2(block_data[2]), .in_block_3(block_data[3]),
                    .in_block_4(block_data[4]), .in_block_5(block_data[5]), .in_block_6(block_data[6]), .in_block_7(block_data[7]),
                    .in_block_8(block_data[8]), .in_block_9(block_data[9]), .in_block_10(block_data[10]), .in_block_11(block_data[11]),
                    .in_block_12(block_data[12]), .in_block_13(block_data[13]), .in_block_14(block_data[14]), .in_block_15(block_data[15]),
                    .out(SAD[24])
                );
always @ (posedge clk) begin
        SAD_reg[0] <= SAD[0];  SAD_reg[1] <= SAD[1];  SAD_reg[2] <= SAD[2];  SAD_reg[3] <= SAD[3];  SAD_reg[4] <= SAD[4];  
        SAD_reg[5] <= SAD[5];  SAD_reg[6] <= SAD[6];  SAD_reg[7] <= SAD[7];  SAD_reg[8] <= SAD[8];  
        SAD_reg[9] <= SAD[9];  SAD_reg[10] <= SAD[10];  SAD_reg[11] <= SAD[11];  SAD_reg[12] <= SAD[12];  
        SAD_reg[13] <= SAD[13];  SAD_reg[14] <= SAD[14];  SAD_reg[15] <= SAD[15];  SAD_reg[16] <= SAD[16];  
        SAD_reg[17] <= SAD[17];  SAD_reg[18] <= SAD[18];  SAD_reg[19] <= SAD[19];  SAD_reg[20] <= SAD[20];  
        SAD_reg[21] <= SAD[21];  SAD_reg[22] <= SAD[22];  SAD_reg[23] <= SAD[23];  SAD_reg[24] <= SAD[24];  
end

MIN_compare5 ROW_1(.num1(SAD_reg[0]), .num2(SAD_reg[1]), .num3(SAD_reg[2]), .num4(SAD_reg[3]), .num5(SAD_reg[4]), .min(min_row1));
MIN_compare5 ROW_2(.num1(SAD_reg[5]), .num2(SAD_reg[6]), .num3(SAD_reg[7]), .num4(SAD_reg[8]), .num5(SAD_reg[9]), .min(min_row2));
MIN_compare5 ROW_3(.num1(SAD_reg[10]), .num2(SAD_reg[11]), .num3(SAD_reg[12]), .num4(SAD_reg[13]), .num5(SAD_reg[14]), .min(min_row3));
MIN_compare5 ROW_4(.num1(SAD_reg[15]), .num2(SAD_reg[16]), .num3(SAD_reg[17]), .num4(SAD_reg[18]), .num5(SAD_reg[19]), .min(min_row4));
MIN_compare5 ROW_5(.num1(SAD_reg[20]), .num2(SAD_reg[21]), .num3(SAD_reg[22]), .num4(SAD_reg[23]), .num5(SAD_reg[24]), .min(min_row5));
MIN_compare5 MIN_SAD(.num1(min_row1), .num2(min_row2), .num3(min_row3), .num4(min_row4), .num5(min_row5), .min(min_sad));

always_comb begin
    case(min_sad)
        SAD[0] : {x_vector, y_vector} = {3'b110, 3'b010};//-2, 2
        SAD[1] : {x_vector, y_vector} = {3'b111, 3'b010};//-1, 2 
        SAD[2] : {x_vector, y_vector} = {3'b000, 3'b010};//0 2
        SAD[3] : {x_vector, y_vector} = {3'b001, 3'b010};// 1 2
        SAD[4] : {x_vector, y_vector} = {3'b010, 3'b010};// 2 2
        SAD[5] : {x_vector, y_vector} = {3'b110, 3'b001};// -2 1
        SAD[6] : {x_vector, y_vector} = {3'b111, 3'b001};//-1 1
        SAD[7] : {x_vector, y_vector} = {3'b000, 3'b001};// 0 1
        SAD[8] : {x_vector, y_vector} = {3'b001, 3'b001};//1 1
        SAD[9] : {x_vector, y_vector} = {3'b010, 3'b001};//2 1
        SAD[10] : {x_vector, y_vector} = {3'b110, 3'b000};//-2 0
        SAD[11] : {x_vector, y_vector} = {3'b111, 3'b000};//-1 0
        SAD[12] : {x_vector, y_vector} = {3'b000, 3'b000};// 0 0
        SAD[13] : {x_vector, y_vector} = {3'b001, 3'b000};// 1 0
        SAD[14] : {x_vector, y_vector} = {3'b010, 3'b000};// 2 0
        SAD[15] : {x_vector, y_vector} = {3'b110, 3'b111};//-2 -1
        SAD[16] : {x_vector, y_vector} = {3'b111, 3'b111};//-1 -1
        SAD[17] : {x_vector, y_vector} = {3'b000, 3'b111};// 0 -1
        SAD[18] : {x_vector, y_vector} = {3'b001, 3'b111};//1 -1
        SAD[19] : {x_vector, y_vector} = {3'b010, 3'b111};//2 -1
        SAD[20] : {x_vector, y_vector} = {3'b110, 3'b110};//-2 -2
        SAD[21] : {x_vector, y_vector} = {3'b111, 3'b110};//-1 -2
        SAD[22] : {x_vector, y_vector} = {3'b000, 3'b110};//0 -2
        SAD[23] : {x_vector, y_vector} = {3'b001, 3'b110};//1 -2
        SAD[24] : {x_vector, y_vector} = {3'b010, 3'b110};//2 -2
        default : {x_vector, y_vector} = {3'b010, 3'b110};//-2, 2
    endcase
end
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        out_vector <= 0; 
	else 
        out_vector <= out_vector_comb; 
end

always_comb begin
    if (cnt == 1 ) out_vector_comb = x_vector;
    else if (cnt ==2 ) out_vector_comb = y_vector;
    else out_vector_comb = 0;
end


always_comb begin
	if (block_valid || area_valid) 
		cnt_next = 0; 
	else
		cnt_next =cnt + 1; 
end
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        cnt <= 0; 
	else 
        cnt <= cnt_next; 
end

assign out_valid = ((cnt==2 || cnt==3) && out) ? 1 : 0; 
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        out <= 0; 
	else if (block_valid)
        out <= 1; 
    else out <= out;
end
endmodule


module SAD_compute(
    in_block_0, in_block_1, in_block_2, in_block_3, 
    in_block_4, in_block_5, in_block_6, in_block_7, 
    in_block_8, in_block_9, in_block_10, in_block_11, 
    in_block_12, in_block_13, in_block_14, in_block_15,

    in_area_0, in_area_1, in_area_2, in_area_3, 
    in_area_4, in_area_5, in_area_6, in_area_7, 
    in_area_8, in_area_9, in_area_10, in_area_11, 
    in_area_12, in_area_13, in_area_14, in_area_15,

    out
);
input [7:0] in_block_0, in_block_1, in_block_2, in_block_3, 
            in_block_4, in_block_5, in_block_6, in_block_7, 
            in_block_8, in_block_9, in_block_10, in_block_11, 
            in_block_12, in_block_13, in_block_14, in_block_15,
            in_area_0, in_area_1, in_area_2, in_area_3, 
            in_area_4, in_area_5, in_area_6, in_area_7, 
            in_area_8, in_area_9, in_area_10, in_area_11, 
            in_area_12, in_area_13, in_area_14, in_area_15;

output logic [11:0] out;
logic [7:0]sub0, sub1, sub2, sub3, sub4, sub5, sub6, sub7, sub8, sub9, sub10, sub11, sub12, sub13, sub14, sub15;
always_comb begin
    sub0 = (in_block_0>=in_area_0) ? (in_block_0 - in_area_0) : (in_area_0 - in_block_0);
    sub1 = (in_block_1>=in_area_1) ? (in_block_1 - in_area_1) : (in_area_1 - in_block_1);
    sub2 = (in_block_2>=in_area_2) ? (in_block_2 - in_area_2) : (in_area_2 - in_block_2);
    sub3 = (in_block_3>=in_area_3) ? (in_block_3 - in_area_3) : (in_area_3 - in_block_3);
    sub4 = (in_block_4>=in_area_4) ? (in_block_4 - in_area_4) : (in_area_4 - in_block_4);
    sub5 = (in_block_5>=in_area_5) ? (in_block_5 - in_area_5) : (in_area_5 - in_block_5);
    sub6 = (in_block_6>=in_area_6) ? (in_block_6 - in_area_6) : (in_area_6 - in_block_6);
    sub7 = (in_block_7>=in_area_7) ? (in_block_7 - in_area_7) : (in_area_7 - in_block_7);
    sub8 = (in_block_8>=in_area_8) ? (in_block_8 - in_area_8) : (in_area_8 - in_block_8);
    sub9 = (in_block_9>=in_area_9) ? (in_block_9 - in_area_9) : (in_area_9 - in_block_9);
    sub10 = (in_block_10>=in_area_10) ? (in_block_10 - in_area_10) : (in_area_10 - in_block_10);
    sub11 = (in_block_11>=in_area_11) ? (in_block_11 - in_area_11) : (in_area_11 - in_block_11);
    sub12 = (in_block_12>=in_area_12) ? (in_block_12 - in_area_12) : (in_area_12 - in_block_12);
    sub13 = (in_block_13>=in_area_13) ? (in_block_13 - in_area_13) : (in_area_13 - in_block_13);
    sub14 = (in_block_14>=in_area_14) ? (in_block_14 - in_area_14) : (in_area_14 - in_block_14);
    sub15 = (in_block_15>=in_area_15) ? (in_block_15 - in_area_15) : (in_area_15 - in_block_15);

    out = (sub0 + sub1) + (sub2 + sub3) + (sub4 + sub5) + (sub6 + sub7) + (sub8 + sub9) + (sub10 + sub11) + (sub12 + sub13) + (sub14 + sub15);  
end

endmodule

module MIN_compare5(
    num1,
    num2,
    num3,
    num4,
    num5,
    min
);
input [11:0] num1, num2, num3, num4, num5;
output logic[11:0] min;
logic [11:0] l_1v4, h_1v4, l_2v5, h_2v5, l_1v3, h_1v3, l_2v4, h_2v4, h_1v2; 
// logic [11:0] min1, min2, min3;
always_comb begin
    // layer1
    {l_1v4, h_1v4} = (num1 < num4) ? {num1, num4} : {num4, num1};
    //layer2
    {l_2v5, h_2v5} = (num2 < num5) ? {num2, num5} : {num5, num2};
    //layer3
    {l_1v3, h_1v3} = (l_1v4 < num3) ? {l_1v4, num3} : {num3, l_1v4};
    //layer4
    {l_2v4, h_2v4} = (l_2v5 < h_1v4) ? {l_2v5, h_1v4} : {h_1v4, l_2v5};
    // final layer
    {min, h_1v2} = (l_1v3 < l_2v4) ? {l_1v3, l_2v4} : {l_2v4, l_1v3};
    
    // min1 =(num1 < num2) ?  num1 : num2;
    // min2 =(min1 < num3) ?  min1 : num3;
    // min3 =(min2 < num4) ?  min2 : num4;  
    // min =(min3 < num5) ?  min3 : num5; 
    // min = (l_1v3 < l_2v4) ? l_1v3 : l_2v4;
    
end

endmodule