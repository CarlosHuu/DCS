module IDC(
    // Input signals
	clk,
	rst_n,
	in_valid,
    in_id,
    // Output signals
    out_valid,
    out_legal_id
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n, in_valid;
input [5:0] in_id;

output logic out_valid;
output logic out_legal_id;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic [3:0] cnt, cnt_next;
logic [3:0] char;
logic [4:0] sum;
logic [4:0] sum_next;
logic [5:0] in_id_dff;
logic [3:0] input_lut [10:35];
logic in_valid_dff;
logic [3:0] check;
logic out_legal_id_comb;


// hardwire value 
assign input_lut[10] = 1;
assign input_lut[11] = 0;
assign input_lut[12] = 9;
assign input_lut[13] = 8;
assign input_lut[14] = 7;
assign input_lut[15] = 6;
assign input_lut[16] = 5;
assign input_lut[17] = 4;
assign input_lut[18] = 3;
assign input_lut[19] = 2;
assign input_lut[20] = 2;
assign input_lut[21] = 1;
assign input_lut[22] = 0;
assign input_lut[23] = 9;
assign input_lut[24] = 8;
assign input_lut[25] = 7;
assign input_lut[26] = 6;
assign input_lut[27] = 5;
assign input_lut[28] = 4;
assign input_lut[29] = 3;
assign input_lut[30] = 3;
assign input_lut[31] = 2;
assign input_lut[32] = 1;
assign input_lut[33] = 0;
assign input_lut[34] = 9;
assign input_lut[35] = 8;

//--------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------

always_ff @( posedge clk or negedge rst_n ) begin 
    if(!rst_n) begin
        in_id_dff<= 0;
        in_valid_dff<= 0;
        cnt <= 0;
    end
    else begin
        in_id_dff <= in_id;
        in_valid_dff <= in_valid;
        cnt <= cnt_next;
    end
end

//sum
always_ff @( posedge clk or negedge rst_n ) begin 
    if(!rst_n) sum <= 0;
    else if (in_valid_dff)  sum <= sum_next ;
    else sum <= 0;
end


// counter
assign cnt_next = (in_valid_dff) ? cnt + 1 : 0;



always_comb begin
    if(cnt == 0) begin 
        char = input_lut[in_id_dff];
    end

    else begin
        case(cnt)
            1: begin
                case(in_id_dff)
                    0: char = 0;
                    1: char = 8; 
                    2: char = 6; 
                    3: char = 4; 
                    4: char = 2; 
                    5: char = 0; 
                    6: char = 8; 
                    7: char = 6;
                    8: char = 4; 
                    9: char = 2; 
                endcase
            end
            2: begin
                case(in_id_dff)
                    0: char = 0; 
                    1: char = 7; 
                    2: char = 4; 
                    3: char = 1; 
                    4: char = 8; 
                    5: char = 5; 
                    6: char = 2; 
                    7: char = 9; 
                    8: char = 6; 
                    9: char = 3;
                endcase
            end
            3: begin
                case(in_id_dff)
                    0: char = 0; 
                    1: char = 6; 
                    2: char = 2; 
                    3: char = 8; 
                    4: char = 4; 
                    5: char = 0; 
                    6: char = 6; 
                    7: char = 2;
                    8: char = 8; 
                    9: char = 4; 
                endcase

            end
            4: begin
                case(in_id_dff[0])
                    1'b1: char = 5;  
                    1'b0: char = 0;  
                endcase
            end
            5: begin
                case(in_id_dff)
                    0: char = 0; 
                    1: char = 4; 
                    2: char = 8; 
                    3: char = 2; 
                    4: char = 6; 
                    5: char = 0; 
                    6: char = 4;
                    7: char = 8; 
                    8: char = 2; 
                    9: char = 6; 
                endcase

            end
            6: begin
                case(in_id_dff)
                    0: char = 0; 
                    1: char = 3; 
                    2: char = 6; 
                    3: char = 9; 
                    4: char = 2; 
                    5: char = 5; 
                    6: char = 8; 
                    7: char = 1; 
                    8: char = 4; 
                    9: char = 7; 
                endcase
            end

            7: begin
                if (in_id_dff == 0 || in_id_dff == 5)
                char = 0;
            if (in_id_dff == 1 || in_id_dff == 6) 
                char = 2;
            if (in_id_dff == 2 || in_id_dff == 7)
                char = 4;
            if (in_id_dff == 3 || in_id_dff == 8)
                char = 6;
            if (in_id_dff == 4 || in_id_dff == 9)
                char = 8;
            end

            8: begin
                char = in_id_dff; 
            end
            default: char = 0;
        endcase 
    end
    
    

    sum_next = (sum + char);
    if (sum_next >= 10) sum_next = sum + char - 10;
end



always_comb begin
    case(sum) 
        0: check = 0;
        1: check = 9;
        2: check = 8;
        3: check = 7;
        4: check = 6;
        5: check = 5;
        6: check = 4;
        7: check = 3;
        8: check = 2;
        9: check = 1;
        10: check = 0;
        default: check = 0;
    endcase
    
    out_legal_id_comb = ((check == in_id_dff[3:0]));
    out_legal_id = (out_legal_id_comb && out_valid);
end

// out_valid
assign out_valid = (cnt == 9) ? 1 : 0;
endmodule