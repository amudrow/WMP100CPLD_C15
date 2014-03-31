// Copyright (C) 1991-2012 Altera Corporation
// Your use of Altera Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License 
// Subscription Agreement, Altera MegaCore Function License 
// Agreement, or other applicable license agreement, including, 
// without limitation, that your use is for the sole purpose of 
// programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the 
// applicable agreement for further details.

// PROGRAM		"Quartus II 32-bit"
// VERSION		"Version 12.1 Build 177 11/07/2012 SJ Full Version"
// CREATED		"Wed Dec 05 15:08:26 2012"

module BufSig(
input 		CRASH_CLEAR,			//Source  : DMM MSP GPIO3.5
input 		CRASH_PULSE,			//Source	 : = XAXIS OR YAXIS OR ZAXIS
input 		SYS_CLK,					//32 KHz clock, generated internally
input			DMM_ON,					//DMM MSP power on (active HIGH)
output reg	CRASH_EVENT = 0		//To 		 : DMM MSP GPIO1.2, held LOW after power ON
);

reg	crash_clear_delay1 	= 0;
reg	crash_clear_delay2 	= 0;
reg 	crash_su_dly 			= 0;

always@(posedge CRASH_PULSE or posedge SYS_CLK)
begin
	if (CRASH_PULSE)												//set CRASH_EVENT on the positive edge of CRASH_PULSE
		CRASH_EVENT <= crash_su_dly;
	else if (crash_clear_delay2 || !crash_su_dly)		//clear CRASH_EVENT on CRASH_CLEAR delayed by 2X32KHz clock cycles (~31us to ~62us) or within 2 seconds of DMM MSP power on
		CRASH_EVENT <= 1'b0;
	else
		CRASH_EVENT <= CRASH_EVENT;
end


always@(posedge SYS_CLK)										//CRASH_CLEAR is delayed by two clock cycles
begin
	begin
		crash_clear_delay1 <= CRASH_CLEAR;
		crash_clear_delay2 <= crash_clear_delay1;
	end
end

reg [15:0] crash_ctr	= 0;										//Keep CRASH_EVENT clear for 2 seconds after DMM MSP power is turned on
always @ (posedge SYS_CLK)
begin
if (!DMM_ON)
	begin
	crash_ctr <= 0;
	crash_su_dly <= 0;
	end
else if (crash_ctr < 16'hFFFF)
	begin
	crash_ctr <= crash_ctr + 16'h0001;
	crash_su_dly <= 0;
	end
else 
	begin
	crash_ctr <= crash_ctr;
	crash_su_dly <= 1;
	end
end	
	

endmodule
