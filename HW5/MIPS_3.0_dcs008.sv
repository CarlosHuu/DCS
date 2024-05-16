module MIPS(
    //INPUT
    clk,
    rst_n,
    in_valid,
    instruction,

    //OUTPUT
    out_valid,
    instruction_fail,
    out_0,
    out_1,
    out_2,
    out_3,
    out_4,
    out_5
);
// INPUT
input clk;
input rst_n;
input in_valid;
input [31:0] instruction;

// OUTPUT
output logic out_valid, instruction_fail;
output logic [15:0] out_0, out_1, out_2, out_3, out_4, out_5;
//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic [4:0] Rs, Rt, Rd;
logic [2:0] Rs_index, Rt_index, Rd_index;
logic [15:0] reg_list[5:0], reg_list_reg[5:0];
logic [31:0] instruction_fail_reg;
logic in_valid_1;
logic [31:0] instruction_reg;

//================================================================
// DESIGN 
//================================================================


always_ff @ (posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        instruction_reg <= 0;
        in_valid_1 <= 0;

        // reg_list[5:0] <= {16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0};
        reg_list <= '{6{16'd0}};
        instruction_fail <= 0;
        out_valid <= 0;
    end
    else begin
        instruction_reg <= instruction;
        in_valid_1 <=in_valid;
        
        reg_list[5:0] <= reg_list_reg[5:0];
        instruction_fail <= instruction_fail_reg;
        out_valid <= in_valid_1;
    end
end
always_comb begin
    Rs = in_valid_1 ? instruction_reg[25:21] : 0;
    Rt = in_valid_1 ? instruction_reg[20:16] : 0;
    Rd = in_valid_1 ? instruction_reg[15:11] : 0;
end

always_comb begin 
    case (Rs) 
        5'b10001 : Rs_index = 0;
        5'b10010 : Rs_index = 1;
        5'b01000 : Rs_index = 2;
        5'b10111 : Rs_index = 3;        
        5'b11111 : Rs_index = 4;       
        5'b10000 : Rs_index = 5;       
        default : Rs_index = 7;
    endcase
    case (Rt) 
        5'b10001 : Rt_index = 0;
        5'b10010 : Rt_index = 1;
        5'b01000 : Rt_index = 2;
        5'b10111 : Rt_index = 3;        
        5'b11111 : Rt_index = 4;       
        5'b10000 : Rt_index = 5;       
        default : Rt_index = 7;
    endcase
    case (Rd) 
        5'b10001 : Rd_index = 0;
        5'b10010 : Rd_index = 1;
        5'b01000 : Rd_index = 2;
        5'b10111 : Rd_index = 3;        
        5'b11111 : Rd_index = 4;       
        5'b10000 : Rd_index = 5;       
        default : Rd_index = 7;
    endcase

    reg_list_reg = reg_list;
    if (instruction_reg[31:26] == 6'b000000) begin
        case (instruction_reg[5:0])
            6'b100000 : begin//+
                reg_list_reg[Rd_index]= reg_list[Rs_index] + reg_list[Rt_index];
                instruction_fail_reg = 0; 
            end
            6'b100100 : begin//&
                reg_list_reg[Rd_index]= reg_list[Rs_index] & reg_list[Rt_index];
                instruction_fail_reg = 0; 
            end
            6'b100101 : begin//|
                reg_list_reg[Rd_index] = reg_list[Rs_index] | reg_list[Rt_index];
                instruction_fail_reg = 0; 
            end
            6'b100111 : begin//nor
                reg_list_reg[Rd_index] = ~(reg_list[Rs_index] | reg_list[Rt_index]);
                instruction_fail_reg = 0; 
            end
            6'b000000 : begin// <<
                reg_list_reg[Rd_index] = reg_list[Rt_index] << instruction_reg[10:6];
                instruction_fail_reg = 0; 
            end
            6'b000010 : begin// >>
                reg_list_reg[Rd_index] = reg_list[Rt_index] >> instruction_reg[10:6];
                instruction_fail_reg = 0; 
            end
            default : begin
                if(in_valid_1)
                    instruction_fail_reg = 1;
                else
                    instruction_fail_reg = 0;
            end
        endcase
    end
    else if (instruction_reg[31:26] == 6'b001000) begin
            reg_list_reg[Rt_index] = reg_list[Rs_index] + instruction_reg[15:0];
            instruction_fail_reg = 0; 
    end   
    else begin
        if(in_valid_1)
            instruction_fail_reg = 1;
        else
            instruction_fail_reg = 0;
    end
end

always_comb begin
    if (out_valid) begin
        out_0 = reg_list[0];
        out_1 = reg_list[1]; 
        out_2 = reg_list[2];
        out_3 = reg_list[3]; 
        out_4 = reg_list[4];
        out_5 = reg_list[5];
    end
    else begin
        out_0 = 0;
        out_1 = 0; 
        out_2 = 0;
        out_3 = 0; 
        out_4 = 0;
        out_5 = 0;
    end
end
endmodule