module IMG_SUB(
  // Input signals
	clk,
	rst_n,
    in_valid,
    in_image,
  // Output signals
    out_valid,
	out_diff
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n ;
input in_valid ;
input [3:0] in_image ;
output logic out_valid ;
output logic [3:0] out_diff ;
 
//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic [3:0] inp[17:0];
logic [4:0] cnt, cnt_next;
logic [3:0]out_data_state;
logic out_valid_state;
//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------

always @(posedge clk or negedge rst_n) begin 
if(!rst_n) begin 
    inp[0] <= 0;
	inp[1] <= 0;
	inp[2] <= 0;
	inp[3] <= 0;
	inp[4] <= 0;
	inp[5] <= 0;
	inp[6] <= 0;
	inp[7] <= 0;
	inp[8] <= 0;
	inp[9] <= 0;
	inp[10] <= 0;
	inp[11] <= 0;
	inp[12] <= 0;
	inp[13] <= 0;
	inp[14] <= 0;
	inp[15] <= 0;
	inp[16] <= 0;
	inp[17] <= 0;
end 
else begin 
    case(cnt) 
    0:	inp[0] <= in_image;
	1:	inp[1] <= in_image;
	2:	inp[2] <= in_image;
	3:	inp[3] <= in_image;
	4:	inp[4] <= in_image;
	5:	inp[5] <= in_image;
	6:	inp[6] <= in_image;
	7:	inp[7] <= in_image;
	8:	inp[8] <= in_image;
	9:	inp[9] <= in_image;
	10:	inp[10] <= in_image;
	11:	inp[11] <= in_image;
	12:	inp[12] <= in_image;
	13:	inp[13] <= in_image;
	14:	inp[14] <= in_image;
	15:	inp[15] <= in_image;
	16:	inp[16] <= in_image;
	17:	inp[17] <= in_image;
    default: begin 
        inp[0] <= inp[0];
		inp[1] <= inp[1];
		inp[2] <= inp[2];
		inp[3] <= inp[3];
		inp[4] <= inp[4];
		inp[5] <= inp[5];
		inp[6] <= inp[6];
		inp[7] <= inp[7];
		inp[8] <= inp[8];
		inp[9] <= inp[9];
		inp[10] <= inp[10];
		inp[11] <= inp[11];
		inp[12] <= inp[12];
		inp[13] <= inp[13];
		inp[14] <= inp[14];
		inp[15] <= inp[15];
		inp[16] <= inp[16];
		inp[17] <= inp[17];
    end 
    endcase 
end 
end 
 
//counter 

always_comb begin
	if (in_valid && cnt == 0) 
		cnt_next = 1; 
	else if (cnt == 27) 
		cnt_next = 0; 
	else if (cnt > 0) 
		cnt_next = cnt + 1; 
	else
		cnt_next =cnt; 
    
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        cnt <= 0; 
	else
        cnt <= cnt_next; 
end




//outdiff
always @(posedge clk, negedge rst_n) begin
	if (!rst_n) out_diff <= 0;
	else out_diff <= out_data_state;
end

always_comb begin
	
	case(cnt) 
		18: out_data_state=inp[0]-inp[9]; 
		19: out_data_state=inp[1]-inp[10]; 
		20: out_data_state=inp[2]-inp[11]; 
		21: out_data_state=inp[3]-inp[12]; 
		22: out_data_state=inp[4]-inp[13]; 
		23: out_data_state=inp[5]-inp[14]; 
		24: out_data_state=inp[6]-inp[15]; 
		25: out_data_state=inp[7]-inp[16]; 
		26: out_data_state=inp[8]-inp[17]; 
    	default:out_data_state=0; 
    
    endcase 

end

//outvalue
always @(posedge clk, negedge rst_n) begin
	if (!rst_n) out_valid <= 0;
	else out_valid <= out_valid_state;
end

always_comb begin
	if (cnt>=18 && cnt<=26) out_valid_state =1;
  	else out_valid_state = 0;
	
end


endmodule