module SysClk_m(
input				PCLK,   				//Main Clock = 7.3728MHz
output			CLK_1P8M, 			//1.8432 MHz
output reg		CLK_32K 		= 0,	//32.05565217 KHz
output reg  	CLK_16HZ 	= 0	//16 Hz
);

reg [1:0]  count1 = 0;  //used to generate 1.8432MHz
reg [6:0]  count2 = 0;  //used to generate 32Khz
reg [17:0] count3 = 0;  //used to generate 16Hz

//#1  Generate 1.8432MHz Clock from 7.3728MHz
//-------------------------------------------------------------

always @(posedge PCLK)
begin
		count1 <= count1 + 1'b1;
end
assign CLK_1P8M = count1[1];

//#2   Generate 32KHz Clock 
//--------------------------------------------------------------
always @ (posedge PCLK)
begin
   if(count2 < 7'h73) begin	//count to 0x73 to get 32KHz clock (half period)   
     CLK_32K <= CLK_32K;
     count2  <= count2 + 1'b1;
 end
 else begin
     CLK_32K <= !CLK_32K;
     count2  <= 0;
   end 
end

//#3  Generate 16Hz clock
//--------------------------------------------------------------
always @ (posedge PCLK)
begin
   if(count3 < 18'h38400) begin//count to 0x38400 to get 16Hz clock (half period)   
     CLK_16HZ <= CLK_16HZ;
     count3   <= count3 + 1'b1;
 end
 else begin
     CLK_16HZ <= !CLK_16HZ;
     count3   <= 0;
   end 
end
endmodule
