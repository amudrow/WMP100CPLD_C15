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
// CREATED		"Fri Nov 30 16:37:58 2012"

module CrossPoint_SW(
input 	[3:0]SEL,
input 	WMP_CTS1,
input 	GPS_TXD,
input 	RS232_TX,
input 	WMP_RXD2,
input 	WMP_RXD1,
input 	VBI_TX,
input 	RS232_RTS,
input 	PUR,
output 	RS232_CTS,
output 	GPS_RXD,
output 	RS232_RX,
output 	WMP_TXD2,
output 	WMP_TXD1,
output 	WMP_RTS1,
output 	VBI_RX
);

//Debug port clear to send
wire [15:0]IN1;
assign IN1[3:0] = 0;
assign IN1[4] = WMP_CTS1;
assign IN1[11:5] = 0;
assign IN1[12] = WMP_CTS1;
assign IN1[13] = 0;
assign IN1[14] = WMP_CTS1;
assign IN1[15] = 0;

mux16to1 	b2v_inst67(
	.EN(PUR),
	.SEL(SEL),
	.IN(IN1),
	.OUT(RS232_CTS)
	);
	
//Vehicle bus receive data
wire [15:0]IN2;
assign IN2[0] = RS232_TX;
assign IN2[1] = WMP_RXD1;
assign IN2[2] = WMP_RXD1;
assign IN2[6:3] = 0;
assign IN2[7] = WMP_RXD1;
assign IN2[8] = RS232_TX;
assign IN2[9] = WMP_RXD1;
assign IN2[10] = WMP_RXD1;
assign IN2[11] = WMP_RXD1;
assign IN2[12] = 0;
assign IN2[13] = WMP_RXD1;
assign IN2[14] = WMP_RXD1;
assign IN2[15] = WMP_RXD1;

mux16to1 	b2v_inst68(
	.EN(PUR),
	.SEL(SEL),
	.IN(IN2),
	.OUT(VBI_RX)
	);
	
//Debug port receive data
wire [15:0]IN3;
assign IN3[0] = VBI_TX;
assign IN3[1] = 0;
assign IN3[2] = GPS_TXD;
assign IN3[3] = WMP_RXD1;
assign IN3[4] = WMP_RXD1;
assign IN3[6:5] = 0;
assign IN3[7] = WMP_RXD1;
assign IN3[8] = VBI_TX;
assign IN3[9] = 0;
assign IN3[10] = GPS_TXD;
assign IN3[11] = GPS_TXD;
assign IN3[12] = WMP_RXD1;
assign IN3[13] = GPS_TXD;
assign IN3[14] = WMP_RXD1 & VBI_TX;
assign IN3[15] = WMP_RXD1;

mux16to1 	b2v_inst69(			
	.EN(PUR),
	.SEL(SEL),
	.IN(IN3),
	.OUT(RS232_RX)
	);

//WMP request to send port 1
wire [15:0]IN4;
assign IN4[3:0] = 0;
assign IN4[4] = RS232_RTS;
assign IN4[11:5] = 0;
assign IN4[12] = RS232_RTS;
assign IN4[13] = 0;
assign IN4[14] = RS232_RTS;
assign IN4[15] = 0;

mux16to1 	b2v_inst71(			
	.EN(PUR),
	.SEL(SEL),
	.IN(IN4),
	.OUT(WMP_RTS1)
	);

//GPS receive data
wire [15:0]IN5;
assign IN5[0] = 0;
assign IN5[1] = WMP_RXD2;
assign IN5[2] = WMP_RXD2;
assign IN5[3] = 0;
assign IN5[4] = WMP_RXD2;
assign IN5[6:5] = 0;
assign IN5[7] = WMP_RXD2;
assign IN5[8] = 0;
assign IN5[9] = WMP_RXD2;
assign IN5[10] = RS232_TX;
assign IN5[11] = RS232_TX;
assign IN5[12] = WMP_RXD2;
assign IN5[13] = WMP_RXD2;
assign IN5[14] = WMP_RXD2;
assign IN5[15] = WMP_RXD2;

mux16to1 	b2v_inst72(			
	.EN(PUR),
	.SEL(SEL),
	.IN(IN5),
	.OUT(GPS_RXD));
	
//WMP transmit data port 2
wire [15:0]IN6;
assign IN6[0] = 0;
assign IN6[1] = GPS_TXD;
assign IN6[2] = GPS_TXD;
assign IN6[3] = RS232_TX;
assign IN6[4] = GPS_TXD;
assign IN6[6:5] = 0;
assign IN6[7] = GPS_TXD;
assign IN6[8] = 0;
assign IN6[9] = GPS_TXD;
assign IN6[10] = RS232_TX;
assign IN6[11] = RS232_TX;
assign IN6[12] = GPS_TXD;
assign IN6[13] = GPS_TXD;
assign IN6[14] = GPS_TXD;
assign IN6[15] = GPS_TXD;

mux16to1 	b2v_inst73(			
	.EN(PUR),
	.SEL(SEL),
	.IN(IN6),
	.OUT(WMP_TXD2));
	
//WMP transmit data port 1
wire [15:0]IN7;
assign IN7[0] = 0;
assign IN7[1] = VBI_TX;
assign IN7[2] = VBI_TX;
assign IN7[3] = VBI_TX;
assign IN7[4] = RS232_TX;
assign IN7[6:5] = 0;
assign IN7[7] = VBI_TX;
assign IN7[8] = 0;
assign IN7[9] = VBI_TX;
assign IN7[10] = VBI_TX;
assign IN7[11] = VBI_TX;
assign IN7[12] = RS232_TX;
assign IN7[13] = VBI_TX;
assign IN7[14] = RS232_TX;
assign IN7[15] = VBI_TX;

mux16to1 	b2v_inst80(			
	.EN(PUR),
	.SEL(SEL),
	.IN(IN7),
	.OUT(WMP_TXD1));

endmodule

module mux16to1(
input		EN,						//Enable (active HIGH), OUT is LOW is EN is LOW
input		[3:0]	SEL,
input		[15:0] IN,
output			OUT
);

assign OUT = IN[SEL] & EN;

endmodule
