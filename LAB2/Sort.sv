module Sort(
    // Input signals
	in_num0,
	in_num1,
	in_num2,
	in_num3,
	in_num4,
    // Output signals
	out_num
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input  [5:0] in_num0, in_num1, in_num2, in_num3, in_num4;
output logic [5:0] out_num;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic [5:0] com1_B,com1_S,com2_B,com2_S,com3_B,com3_S,com4_B,com4_S,com5_B,com5_S,com6_B,com6_S,com7_B,com7_S,
com8_B,com8_S,com9_B,com9_S,com10_B,com10_S;

//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------
//comb1
always_comb begin
	if(in_num0>=in_num1)begin
		com1_B=in_num0;
		com1_S=in_num1;
	end
	else begin
		com1_B=in_num1;
		com1_S=in_num0;
	end
end
//comb2
always_comb begin
	if(in_num2>=in_num3)begin
		com2_B=in_num2;
		com2_S=in_num3;
	end
	else begin
		com2_B=in_num3;
		com2_S=in_num2;
	end
end
//comb3
always_comb begin
	if(com1_S>=com2_B)begin
		com3_B=com1_S;
		com3_S=com2_B;
	end
	else begin
		com3_B=com2_B;
		com3_S=com1_S;
	end
end
//comb4
always_comb begin
	if(com2_S>=in_num4)begin
		com4_B=com2_S;
		com4_S=in_num4;
	end
	else begin
		com4_B=in_num4;
		com4_S=com2_S;
	end
end
//comb5
always_comb begin
	if(com1_B>=com3_B)begin
		com5_B=com1_B;
		com5_S=com3_B;
	end
	else begin
		com5_B=com3_B;
		com5_S=com1_B;
	end
end
//comb6
always_comb begin
	if(com3_S>=com4_B)begin
		com6_B=com3_S;
		com6_S=com4_B;
	end
	else begin
		com6_B=com4_B;
		com6_S=com3_S;
	end
end
//comb7
always_comb begin
	if(com5_S>=com6_B)begin
		com7_B=com5_S;
		com7_S=com6_B;
	end
	else begin
		com7_B=com6_B;
		com7_S=com5_S;
	end
end
//comb8
always_comb begin
	if(com6_S>=com4_S)begin
		com8_B=com6_S;
		com8_S=com4_S;
	end
	else begin
		com8_B=com4_S;
		com8_S=com6_S;
	end
end
//comb9
always_comb begin
	if(com5_B>=com7_B)begin
		com9_B=com5_B;
		com9_S=com7_B;
	end
	else begin
		com9_B=com7_B;
		com9_S=com5_B;
	end
end
//comb10
always_comb begin
	if(com7_S>=com8_B)begin
		com10_B=com7_S;
		com10_S=com8_B;
	end
	else begin
		com10_B=com8_B;
		com10_S=com7_S;
	end
end

assign out_num =com10_B;

endmodule