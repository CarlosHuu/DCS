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

//================================================================
// DESIGN 
//================================================================
////function////
parameter ADD_OR_LEFT = 3'b000;
parameter AND = 3'b100;
parameter OR = 3'b101;
parameter NOR = 3'b111;
parameter RIGHT = 3'b010;
////ADDress////
parameter add_0 = 5'b10001;
parameter add_1 = 5'b10010;
parameter add_2 = 5'b01000;
parameter add_3 = 5'b10111;
parameter add_4 = 5'b11111;
parameter add_5 = 5'b10000;

logic instruction_fail_comb;
logic [15:0] out_reg[0:5];
logic [15:0] out_comb[0:5];

logic [2:0] rt_index, rd_index;
logic [31:0] instruction_reg;
logic in_valid_reg;
logic illegal, I_TYPE;
logic add_or_shamt;
logic[2:0] funct;
logic [15:0] imme;
logic [4:0] shamt;
logic [15:0] result_add, result_and, result_or, result_nor, result_shift_left, result_shift_right,result_000;
logic [15:0] addend;
logic[15:0] rs_value, rt_value;

function integer get_index;
    input [4:0] in_value; 
    begin
        case(in_value)
            add_0 : get_index = 3'd0;
            add_1 : get_index = 3'd1;
            add_2 : get_index = 3'd2;
            add_3 : get_index = 3'd3;
            add_4 : get_index = 3'd4;
            add_5 : get_index = 3'd5;
            default:  get_index = 3'd7;
        endcase
    end
endfunction

always_ff @( posedge clk or negedge rst_n ) begin
    if(!rst_n) begin
        rt_index <= 0;
        rd_index <= 0;
    end
    else begin
        rt_index <= get_index(instruction[20:16]);  
        rd_index <= get_index(instruction[15:11]);  

    end
end

always_ff @( posedge clk or negedge rst_n ) begin
    if(!rst_n) begin
        out_valid <= 0;
        instruction_fail <= 0;
        in_valid_reg <= 0;
        illegal <= 0;
        I_TYPE <= 0;
        funct <= 0;
        imme <= 0;
        shamt <= 0;
        add_or_shamt <= 0;
        funct <= 0;
    end
    else begin
        out_valid <= in_valid_reg;
        instruction_fail <= instruction_fail_comb;
        in_valid_reg <= in_valid;
        illegal <= instruction[31] | instruction[30] | instruction[28] | instruction[27] | instruction[26];
        I_TYPE <= instruction[29];
        funct <= instruction[5:0];
        imme <= instruction[15:0];
        shamt <= instruction[10:6];
        add_or_shamt <= instruction[5];
        funct <= instruction[2:0];
    end
end

always_ff @( posedge clk or negedge rst_n ) begin
    if(!rst_n) begin
        out_reg[0] <= 0;
        out_reg[1] <= 0;
        out_reg[2] <= 0;
        out_reg[3] <= 0;
        out_reg[4] <= 0;
        out_reg[5] <= 0;

    end
    else begin
        out_reg[0] <= out_comb[0];
        out_reg[1] <= out_comb[1];
        out_reg[2] <= out_comb[2];
        out_reg[3] <= out_comb[3];
        out_reg[4] <= out_comb[4];
        out_reg[5] <= out_comb[5];
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rs_value <= 0;
        rt_value <= 0;
    end
    else if (in_valid) begin
        case (instruction[25:21])
            add_0: rs_value <= out_reg[0];
            add_1: rs_value <= out_reg[1];
            add_2: rs_value <= out_reg[2];
            add_3: rs_value <= out_reg[3];
            add_4: rs_value <= out_reg[4];
            add_5: rs_value <= out_reg[5];
            default: rs_value <= 16'b0;
        endcase

        case (instruction[20:16])
            add_0: rt_value <= out_reg[0];
            add_1: rt_value <= out_reg[1];
            add_2: rt_value <= out_reg[2];
            add_3: rt_value <= out_reg[3];
            add_4: rt_value <= out_reg[4];
            add_5: rt_value <= out_reg[5];
            default: rt_value <= 16'b0;
        endcase
    end
end

assign result_and = rs_value& rt_value;
assign result_or  = rs_value| rt_value;
assign result_nor = ~(rs_value| rt_value);
assign result_shift_left = rt_value << shamt;
assign result_shift_right = rt_value >> shamt;
assign addend = (I_TYPE) ? imme : rt_value;
assign result_add = (rs_value+ addend)& 16'hFFFF;;
assign result_000 = add_or_shamt ? result_add : result_shift_left;

always_comb begin
    instruction_fail_comb = instruction_fail;
    out_comb[0] = out_reg[0];
    out_comb[1] = out_reg[1];
    out_comb[2] = out_reg[2];
    out_comb[3] = out_reg[3];
    out_comb[4] = out_reg[4];
    out_comb[5] = out_reg[5];

    if (in_valid_reg) begin
        if (illegal) begin
            instruction_fail_comb = 1;
        end 
        else begin
            instruction_fail_comb = 0;
            if (I_TYPE) begin 
                out_comb[rt_index] = result_add; 
            end 
            else begin 
                case(funct)
                        ADD_OR_LEFT: begin
                            case (rd_index)
                                0: out_comb[0] = result_000;
                                1: out_comb[1] = result_000;
                                2: out_comb[2] = result_000;
                                3: out_comb[3] = result_000;
                                4: out_comb[4] = result_000;
                                5: out_comb[5] = result_000;
                            endcase
                        end
                        AND: begin
                            case (rd_index)
                                0: out_comb[0] = result_and;
                                1: out_comb[1] = result_and;
                                2: out_comb[2] = result_and;
                                3: out_comb[3] = result_and;
                                4: out_comb[4] = result_and;
                                5: out_comb[5] = result_and;
                            endcase
                        end
                        OR: begin
                            case (rd_index)
                                0: out_comb[0] = result_or;
                                1: out_comb[1] = result_or;
                                2: out_comb[2] = result_or;
                                3: out_comb[3] = result_or;
                                4: out_comb[4] = result_or;
                                5: out_comb[5] = result_or;
                            endcase
                        end
                        NOR: begin
                            case (rd_index)
                                0: out_comb[0] = result_nor;
                                1: out_comb[1] = result_nor;
                                2: out_comb[2] = result_nor;
                                3: out_comb[3] = result_nor;
                                4: out_comb[4] = result_nor;
                                5: out_comb[5] = result_nor;
                            endcase
                        end
                        RIGHT: begin
                            case (rd_index)
                                0: out_comb[0] = result_shift_right;
                                1: out_comb[1] = result_shift_right;
                                2: out_comb[2] = result_shift_right;
                                3: out_comb[3] = result_shift_right;
                                4: out_comb[4] = result_shift_right;
                                5: out_comb[5] = result_shift_right;
                            endcase
                        end
                endcase
            end
        end
    end 
    else begin
        instruction_fail_comb = 0;
        out_comb[0] = 0;
        out_comb[1] = 0;
        out_comb[2] = 0;
        out_comb[3] = 0;
        out_comb[4] = 0;
        out_comb[5] = 0;
    end
end

always_comb begin
    out_0 = out_reg[0];
    out_1 = out_reg[1];
    out_2 = out_reg[2];
    out_3 = out_reg[3];
    out_4 = out_reg[4];
    out_5 = out_reg[5];
end


endmodule