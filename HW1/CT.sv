module CT(
    // Input signals
    opcode,
	in_n0,
	in_n1,
	in_n2,
	in_n3,
	in_n4,
	in_n5,
    // Output signals
    out_n
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input [3:0] in_n0, in_n1, in_n2, in_n3, in_n4, in_n5;
input [4:0] opcode;
output logic [8:0] out_n;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic [4:0] value_0, value_1, value_2, value_3, value_4, value_5;

// mergesort layer
logic [4:0] l1_0, l1_1, l1_2, l1_3, l1_4, l1_5; //layer 1
logic [4:0] l2_0, l2_1, l2_2, l2_3, l2_4, l2_5; //layer 2
logic [4:0] l3_0, l3_1, l3_2, l3_3, l3_4, l3_5; //layer 3
logic [4:0] l4_0, l4_1, l4_2, l4_3, l4_4, l4_5; //layer 4
logic [4:0] num0, num1, num2, num3, num4, num5; //layer 5

logic [6:0] sum;
logic [4:0] average;
logic [2:0] count;
logic [2:0] count_above_average;

//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------

register_file connect_0(.address(in_n0), .value(value_0));
register_file connect_1(.address(in_n1), .value(value_1));
register_file connect_2(.address(in_n2), .value(value_2));
register_file connect_3(.address(in_n3), .value(value_3));
register_file connect_4(.address(in_n4), .value(value_4));
register_file connect_5(.address(in_n5), .value(value_5));

always_comb begin
    //Sorting
    case(opcode[4])
        1'b0 : {num0, num1, num2, num3, num4, num5} = {value_0, value_1, value_2, value_3, value_4, value_5};
        1'b1 :  begin //mergesort big to small
            // layer 1 
            {l1_0, l1_1} = {value_0 > value_1} ? {value_0, value_1} : {value_1, value_0};
            {l1_2, l1_3} = {value_2 > value_3} ? {value_2, value_3} : {value_3, value_2};
            {l1_4, l1_5} = {value_4 > value_5} ? {value_4, value_5} : {value_5, value_4};

            //layer 2
			{l2_1, l2_4} = (l1_1 > l1_4) ? {l1_1, l1_4} : {l1_4, l1_1};
			{l2_3, l2_5} = (l1_3 > l1_5) ? {l1_3, l1_5} : {l1_5, l1_3};
			{l2_0, l2_2} = (l1_0 > l1_2) ? {l1_0, l1_2} : {l1_2, l1_0};
		
			//layer 3
			{l3_0, l3_1} = (l2_0 > l2_1) ? {l2_0, l2_1} : {l2_1, l2_0};
			{l3_2, l3_3} = (l2_2 > l2_3) ? {l2_2, l2_3} : {l2_3, l2_2};
			{l3_4, l3_5} = (l2_4 > l2_5) ? {l2_4, l2_5} : {l2_5, l2_4};
			
			//layer 4
			{l4_0, l4_5} = {l3_0, l3_5};
            {l4_1, l4_2} = (l3_1 > l3_2) ? {l3_1, l3_2} : {l3_2, l3_1};
			{l4_3, l4_4} = (l3_3 > l3_4) ? {l3_3, l3_4} : {l3_4, l3_3};
			 			
			//layer 5
			{num0, num1} = {l4_0, l4_1};
			{num4, num5} = {l4_4, l4_5};
			{num2, num3} = (l4_2 > l4_3) ? {l4_2, l4_3} : {l4_3, l4_2};
            end
    endcase

    case(opcode[3])
        1'b1 : {num0, num1, num2, num3, num4, num5} = {num5, num4, num3, num2, num1, num0};//reverse order
        1'b0 : {num0, num1, num2, num3, num4, num5} = {num0, num1, num2, num3, num4, num5};
    endcase

    if (opcode[2:0] == 000)begin
        sum = num0 + num1 + num2 + num3 + num4 + num5;
        average = sum / 6;
        count = 0;
        if (num0 >= average) count = count + 1;
        if (num1 >= average) count = count + 1;
        if (num2 >= average) count = count + 1;
        if (num3 >= average) count = count + 1;
        if (num4 >= average) count = count + 1;
        if (num5 >= average) count = count + 1;
        count_above_average = count;
    end
    else begin
        sum =0;
        average=0;
        count=0;
        count_above_average=0;
    end
    //Calculation
	case(opcode[2:0])
        3'b000:	out_n = count_above_average;
        3'b001:	out_n = num0 + num5;
        3'b010:	out_n = (num3 * num4) / 2;
        3'b011:	out_n = num0 + (num2 << 1); //double
        3'b100:	out_n = num1 & num2;
        3'b101:	out_n = ~num0;
        3'b110:	out_n = num3 ^ num4;
        3'b111:	out_n = num1 << 1;
	endcase
end
endmodule

//---------------------------------------------------------------------
//   Register design from TA (Do not modify, or demo fails)
//---------------------------------------------------------------------
module register_file(
    address,
    value
);
input [3:0] address;
output logic [4:0] value;

always_comb begin
    case(address)
    4'b0000:value = 5'd9;
    4'b0001:value = 5'd27;
    4'b0010:value = 5'd30;
    4'b0011:value = 5'd3;
    4'b0100:value = 5'd11;
    4'b0101:value = 5'd8;
    4'b0110:value = 5'd26;
    4'b0111:value = 5'd17;
    4'b1000:value = 5'd3;
    4'b1001:value = 5'd12;
    4'b1010:value = 5'd1;
    4'b1011:value = 5'd10;
    4'b1100:value = 5'd15;
    4'b1101:value = 5'd5;
    4'b1110:value = 5'd23;
    4'b1111:value = 5'd20;
    default: value = 0;
    endcase
end

endmodule