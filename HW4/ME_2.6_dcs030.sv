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
logic [7:0] block [0:15];
logic [7:0] in [0:15];
logic [7:0] result0;
logic [8:0] result1;
logic [9:0] result2, result3;
logic [9:0] result_f0, result_f1, result_f2, result_f3;
logic [10:0] result4, result5, result6, result7;
logic [10:0] result_f4, result_f5, result_f6, result_f7;
logic [11:0] next, result8, result9, result10, result11, result12, result13, result14;
logic [11:0] result_f8, result_f9, result_f10, result_f11;
logic [11:0] min;

logic signed [2:0] x,y;
logic signed [2:0] x_min,y_min;
logic out0, out1, out2;

//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------
always @(posedge clk) begin
    if(block_valid) begin
        block[15] <= in_data;
        block[14] <= block[15];
        block[13] <= block[14];
        block[12] <= block[13];
        block[11] <= block[12];
        block[10] <= block[11];
        block[9] <= block[10];
        block[8] <= block[9];
        block[7] <= block[8];
        block[6] <= block[7];
        block[5] <= block[6];
        block[4] <= block[5];
        block[3] <= block[4];
        block[2] <= block[3];
        block[1] <= block[2];
        block[0] <= block[1];   
    end
end
always @(posedge clk) begin
    if(block_valid) begin
        x <= 2;
        y <= -2;
    end
    else begin
        x <= x + 1;
        if(x == 2) begin
            y <= y - 1;
        end
        else begin
            y <= y;
        end
    end
end

always @(posedge clk) begin
    in[0] <= (block[0]>in_data)? block[0] - in_data: in_data - block[0];
    in[1] <= (block[1]>in_data)? block[1] - in_data: in_data - block[1] ;
    in[2] <= (block[2]>in_data)? block[2] - in_data: in_data - block[2];
    in[3] <= (block[3]>in_data)? block[3] - in_data: in_data - block[3];
    in[4] <= (block[4]>in_data)? block[4] - in_data: in_data - block[4];
    in[5] <= (block[5]>in_data)? block[5] - in_data: in_data - block[5];
    in[6] <= (block[6]>in_data)? block[6] - in_data: in_data - block[6];
    in[7] <= (block[7]>in_data)? block[7] - in_data: in_data - block[7];
    in[8] <= (block[8]>in_data)? block[8] - in_data: in_data - block[8];
    in[9] <= (block[9]>in_data)? block[9] - in_data: in_data - block[9];
    in[10] <= (block[10]>in_data)? block[10] - in_data: in_data - block[10];
    in[11] <= (block[11]>in_data)? block[11] - in_data: in_data - block[11];
    in[12] <= (block[12]>in_data)? block[12] - in_data: in_data - block[12];
    in[13] <= (block[13]>in_data)? block[13] - in_data: in_data - block[13];
    in[14] <= (block[14]>in_data)? block[14] - in_data: in_data - block[14];
    in[15] <= (block[15]>in_data)? block[15] - in_data: in_data - block[15];
end
always @(posedge clk) begin
    result0 <= in[0];
    result1 <= result0 + in[1];
    result2 <= result1 + in[2];
    result3 <= result2 + in[3];
    result_f0 <= result3;
    result_f1 <= result_f0;
    result_f2 <= result_f1;
    result_f3 <= result_f2;
    result4 <= result_f3 + in[4];
    result5 <= result4 + in[5];
    result6 <= result5 + in[6];
    result7 <= result6 + in[7];
    result_f4 <= result7;
    result_f5 <= result_f4;
    result_f6 <= result_f5;
    result_f7 <= result_f6;
    result8 <= result_f7 + in[8];
    result9 <= result8 + in[9];
    result10 <= result9 + in[10];
    result11 <= result10 + in[11];
    result_f8 <= result11;
    result_f9 <= result_f8;
    result_f10 <= result_f9;
    result_f11 <= result_f10;
    result12 <= result_f11 + in[12];
    result13 <= result12 + in[13];
    result14 <= result13 + in[14];
    //next <= result14 + in[15];
end
assign next = result14 + in[15];

always @(posedge clk) begin
    out0 <= (x == -3 && y == 2);
    out1 <= (area_valid && x == 1 && y == -2);
    out2 <= out1;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        min <= 0;
        out_valid <= 0;
        out_vector <= 0;
        x_min <= x_min;
        y_min <= y_min;
    end
    else if(out0) begin
        min <= next;
        out_valid <= 0;
        out_vector <= 0;
        x_min <= -2;
        y_min <= 2;
    end
    else if(out1) begin
        out_valid <= 1;
        if(next<min) begin
            out_vector <= 2;
            y_min <= -2;
        end
        else begin
            out_vector <= x_min;
            y_min <= y_min;
        end
        min <= min;
        x_min <= x_min;
    end
    else if((x > -3 && x < 3) && (y > -3 && y < 3)) begin
        out_valid <= 0;
        out_vector <= 0;
        if(next<min) begin
            min <= next;
            x_min <= x;
            y_min <= y;
        end
        else begin
            min <= min;
            x_min <= x_min;
            y_min <= y_min;
        end
    end
    else if(out2) begin
        out_valid <= 1;
        out_vector <= y_min;
        min <= min;
    end
    else begin
        out_valid <= 0;
        out_vector <= 0;
        min <= min;
        x_min <= x_min;
        y_min <= y_min;
    end
end
endmodule