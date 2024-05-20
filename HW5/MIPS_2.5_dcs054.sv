module MIPS(
    // INPUT
    clk,
    rst_n,
    in_valid,
    instruction,

    // OUTPUT
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

logic [15:0] reg_0, reg_1, reg_2, reg_3, reg_4, reg_5;
logic [15:0] temp_result;

logic [4:0] rd_addr;
logic in_valid_reg;
logic illegal, I_TYPE;
logic add_or_shamt;
logic [2:0] funct;
logic [15:0] imme;
logic [4:0] shamt;
logic [15:0] result_add, result_and, result_or, result_nor, result_shift_left, result_shift_right, result_000;
logic [15:0] addend;
logic [15:0] rs_value, rt_value;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rd_addr <= 0;
    end
    else if (in_valid) begin
        rd_addr <= instruction[29] ? instruction[20:16] : instruction[15:11];  
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        instruction_fail <= 0;
        in_valid_reg <= 0;
        illegal <= 0;
        I_TYPE <= 0;
        funct <= 0;
        imme <= 0;
        shamt <= 0;
        add_or_shamt <= 0;
        out_valid <= 0;
    end
    else begin
        instruction_fail <= instruction_fail_comb;
        in_valid_reg <= in_valid;
        illegal <= instruction[31] | instruction[30] | instruction[28] | instruction[27] | instruction[26];
        I_TYPE <= instruction[29];
        funct <= instruction[5:0];
        imme <= instruction[15:0];
        shamt <= instruction[10:6];
        add_or_shamt <= instruction[5];
        out_valid <= in_valid_reg;
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        reg_0 <= 0;
        reg_1 <= 0;
        reg_2 <= 0;
        reg_3 <= 0;
        reg_4 <= 0;
        reg_5 <= 0;
    end
    else begin
    if (in_valid_reg && !illegal) begin
        case (rd_addr)
            add_0: reg_0 <= temp_result;
            add_1: reg_1 <= temp_result;
            add_2: reg_2 <= temp_result;
            add_3: reg_3 <= temp_result;
            add_4: reg_4 <= temp_result;
            add_5: reg_5 <= temp_result;
        endcase
    end
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rs_value <= 0;
        rt_value <= 0;
    end
    else if (in_valid) begin
        case (instruction[25:21])
            add_0: rs_value <= reg_0;
            add_1: rs_value <= reg_1;
            add_2: rs_value <= reg_2;
            add_3: rs_value <= reg_3;
            add_4: rs_value <= reg_4;
            add_5: rs_value <= reg_5;
            default: rs_value <= 16'b0;
        endcase

        case (instruction[20:16])
            add_0: rt_value <= reg_0;
            add_1: rt_value <= reg_1;
            add_2: rt_value <= reg_2;
            add_3: rt_value <= reg_3;
            add_4: rt_value <= reg_4;
            add_5: rt_value <= reg_5;
            default: rt_value <= 16'b0;
        endcase
    end
end

assign result_and = rs_value & rt_value;
assign result_or  = rs_value | rt_value;
assign result_nor = ~(rs_value | rt_value);
assign result_shift_left = rt_value << shamt;
assign result_shift_right = rt_value >> shamt;
assign addend = (I_TYPE) ? imme : rt_value;
assign result_add = (rs_value + addend) & 16'hFFFF;
assign result_000 = add_or_shamt ? result_add : result_shift_left;

always_comb begin
    temp_result = 16'hFFFF;
    if (in_valid_reg) begin
        if (I_TYPE) begin 
            temp_result = result_add;
        end 
        else begin 
            case (funct)
                ADD_OR_LEFT: temp_result = result_000;
                AND: temp_result = result_and;
                OR: temp_result = result_or;
                NOR: temp_result = result_nor;
                RIGHT: temp_result = result_shift_right;
                default: temp_result = 16'hFFFF; 
            endcase
        end
    end
end

always_comb begin
    instruction_fail_comb = 0;
    if (in_valid_reg) begin
        if (illegal) begin
            instruction_fail_comb = 1;
        end else begin
            instruction_fail_comb = 0;
        end
    end
end

always_comb begin
    out_0 = out_valid ? reg_0 : 0;
    out_1 = out_valid ? reg_1 : 0;
    out_2 = out_valid ? reg_2 : 0;
    out_3 = out_valid ? reg_3 : 0;
    out_4 = out_valid ? reg_4 : 0;
    out_5 = out_valid ? reg_5 : 0;
end

endmodule
