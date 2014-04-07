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
// CREATED		"Fri Nov 30 16:35:33 2012"

`timescale 1ns / 1ns

/* 3/27/2014 WMP100 CPLD C15 changes:
1. Translated machine generated Verilog to human generated Verilog to make the code more supportable.
2. CPLD outputs to GPS, WMP and DMM MSP are gated OFF (0V) if power to those modules is OFF.
3. GPS power is OFF whenever WMP power is OFF.
4. CRASH_EVENT is kept clear for 2 seconds after DMM MSP power is turned on (BufSig module).
5. GPS reset to the GPS module (active LOW), delayed 18ms after WMP GPS reset goes inactive or WMP GPS power enable goes active.
6. GPS power enable is held OFF (LOW) for one second after WMP reset goes inactive to filter WMP 1ms bootup spikes
7. Unused pins are driven LOW.
*/

module WMPPROCPLDREVC(
	//Power management MSP signals
	input		SYS_ON,				//PIN_7  : PM MSP GPIO1.2, PM MSP signal to CPLD to turn system ON
	input		DMM_ON,				//PIN_89 : PM MSP GPIO1.3, DMM MSP power rail ON 
	input		VB_ON,				//PIN_90 : PM MSP GPIO2.7, vehicle bus power rail ON
	output	CYCLE_POWER,		//PIN_73 : PM MSP GPIO2.1, signal to PM MSP to cycle the system power, either due to the reset button pressed or a watchdog timer timeout
	//DMM MSP signals
	input		DMM_P5_0,			//PIN_83 : DMM MSP GPIO5.0, (reserved for future use)
	input		DMM_P6_6,			//PIN_81 : DMM MSP GPIO6.6, (reserved for future use)
	input		DMM_P6_7,			//PIN_82 : DMM MSP GPIO6.7, (reserved for future use)
	input		CRASH_CLEAR,		//PIN_5  : DMM MSP GPIO3.5, DMM MSP signal to the CPLD to clear the crash event register
	input		CRASH_PULSE,		//PIN_4  : = XAXIS OR YAXIS OR ZAXIS, signal from the crash detect circuit to set the crash event register
	output	CRASH_EVENT,		//PIN_78 : DMM MSP GPIO1.2, the crash event register signal to the DMM MSP
	output	CPLD_WMP_SHUTDOWN,//PIN_87 : DMM MSP GPIO2.0, signal to the DMM MSP indicating the WMP is shut down
	output	CPLD_CALL_BUTTON,	//PIN_88 : DMM MSP GPIO1.3, signal to the DMM MSP that the call button is being pressed
	output	DMM_RSTn,			//PIN_74 : DMM MSP reset (active LOW), DMM MSP reset signal
	output	GLB_RESETn,			//PIN_75 : DMM MSP GPIO2.7, one second warning to the WMP that a reset condition is coming
	output	NCPLD_3V3_ON,		//PIN_92 : DMM MSP GPIO1.X transceivers enable
	output	CLK_1P8432M,		//PIN_99 : DMM MSP 1.8432 MHz clock input
	output	CLK_32K,				//PIN_98 : DMM MSP 32 KHz clock input
	//WMP signals
	input		WMP_GPIO7,			//PIN_50 : WMP GPIO07, (reserved for future use)
	input		WMP_GPIO8,			//PIN_51 : WMP GPIO08, (reserved for future use)
	input		WMP_GPIO22,			//PIN_41 : WMP GPIO22, (reserved for future use)
	input		WMP_SHUTDOWN,		//PIN_21 : WMP GPIO11, signal from the WMP indicating WMP is powering OFF
	input		WMP_GPS_PWR_EN,	//PIN_40 : WMP GPIO20, signal from the PM MSP indicating the GPS power rail is ON
	input		NWMP_GPS_RST,		//PIN_42 : WMP GPIO09, signal from the WMP to reset the GPS
	input		WMP_TOUT,			//PIN_47 : WMP GPIO10, signal from thw WMP to reset the watchdog timer
	input		WMP_SEL0,			//PIN_48 : WMP GPIO12, (reserved for future use)
	input		WMP_SEL1,			//PIN_49 : WMP GPIO13, (reserved for future use)
	input		WMP_GREEN_LED,		//PIN_35 : WMP green LED ON (active LOW), indicates the green LED on the TiwiPro front is ON
	input		WMP_RXD1,			//PIN_30 : WMP RS232 receive data port 1, TTL level 
	input		WMP_RXD2,			//PIN_37 : WMP RS232 receive data port 2, TTL level
	input		WMP_CTS1,			//PIN_29 : WMP RS232 clear to send port 1, TTL level
	input		WMP_CTS2,			//PIN_39 : WMP RS232 clear to send port 2, TTL level
	output	WMP_TXD1,			//PIN_26 : WMP RS232 transmit data port 1, TTL level
	output	WMP_TXD2,			//PIN_36 : WMP RS232 transmit data port 2, TTL level
	output	WMP_RTS1,			//PIN_27 : WMP RS232 request to send port 1, TTL level
	output	WMP_RTS2,			//PIN_38 : WMP RS232 request to send port 2, TTL level
	output	WMP_DTR1,			//PIN_28 : WMP RS232 data terminal ready port 1, TTL level
	output	WMP_RSTn,			//PIN_33 : WMP Reset in (active LOW)
	output	WMP_READY,			//PIN_1  : WMP external tranceiver enable (active HIGH)
	output	Global_Reset_1V8n,//PIN_34 : WMP INT2/GPIO45
	output	WMP_ON,				//PIN_100: WMP ON (active high)
	output	CPLD_4V2_ON,		//PIN_71 : WMP, audio amp power enables (active HIGH)
	//GPS signals
	input		GPS_TXD,				//PIN_8  : GPS RS232 transmit data, TTL level
	output	GPS_RXD,				//PIN_68 : GPS RS232 receive data, TTL level, held LOW if GPS power is OFF
	output	NGPS_RST,			//PIN_69 : GPS reset (active LOW), held LOW for 18ms after GPS power is turned ON or NWMP_GPS_RST becomes inactive 
	output	CPLD_GPS_PWR_EN,	//PIN_70 : GPS power enable (active HIGH)
	//Debug port signals
	input		RS232_TX,			//PIN_53 : Debug RS232 transmit data (debug connector J2)
	input		RS232_RTS,			//PIN_52 : Debug RS232 request to send (debug connector J2)
	output	RS232_RX,			//PIN_55 : Debug RS232 receive data (debug connector J2)
	output	RS232_CTS,			//PIN_54 : Debug RS232 clear to send (debug connector J2)
	output	DBG232_PWRDN,		//PIN_56 : Debug RS232 transmitter power down (active LOW)
	output	DBG232_ENn,			//PIN_57 : Debug RS232 receiver enable (active LOW)
	input [3:0] SEL,				//PIN_67, PIN_66, PIN_61, PIN_58: disable WDT, select debug RS232 or GPS RS232 (active LOW)
	//Vehicle bus signals
	input		RUN_NSTOP,			//PIN_17 : PM MSP GPIO2.7 (Vehicle bus PCBA power shutdown - active LOW)
	input		VBI_TX,				//PIN_77 : Vehicle bus RS232 transmit data (vehicle bus connector J11), scaled TTL level
	output	VBI_RX,				//PIN_76 : Vehicle bus RS232 receive data (vehicle bus connector J11), scaled TTL level
	output	NRUN_STOP,			//PIN_95 : Vehicle bus enable transceiver CPLD reset, data and clock programming (active LOW)
	//External port signals
	input		DMM_RX,				//PIN_3  : External RS232 receive data (external connector J4), TTL level
	output	DMM_TX,				//PIN_84 : External RS232 trasmit data (external connector J4), TTL level
	output	CPLD_3V3_ON,		//PIN_72 : External interfaces power enables (active HIGH) 
	//Button signals
	input		CALL_BUTTON,		//PIN_18 : Call button (SW2)(active LOW)
	input		RESET_PRESS,		//PIN_6  : Reset button (SW1)(active HIGH)
	//Tamper detect signals
	input		CPLD_TAMPER,		//PIN_85 : Tamper flag, U64, set HIGH at install or JTAG reset
	input		WMP_CLR_TAMPER,	//PIN_20 : Tamper detect clear (sourced by WMP GPIO05)
	output	WMP_TAMPER,			//PIN_19 : Tamper flag, bus level 1.8V, to WMP
	output	CPLD_CLR_TAMPER,	//PIN_86 : Clears the tamper flag (active LOW)
	//CPLD signals
	input		CLK_7P3728M,		//PIN_62 : 7.3728MHz oscillator
	output	CLK_ON,				//PIN_91 : 7.3728 MHz enable (active HIGH)	
	output	GRN_LED1,			//PIN_96 : Turns on green CPLD heartbeat LED D7 (active LOW)
	output	TP_12,				//PIN_12 : pulled LOW externally
	output	TP_14,				//PIN_14 : pulled LOW externally
	output	TP_64,				//PIN_64 : pulled LOW externally
	//unused
	output	CPLD_PIN_2,
	output	CPLD_PIN_15,
	output	CPLD_PIN_16,
	output	CPLD_PIN_97 
	
);



wire		CLK_16HZ;
wire		PUR;
wire		GPS_RXD_INT;
wire		CLK_32K_INT;
wire		CLK_1P8432M_INT;
wire		reset_system;
reg 		GPS_pwr_dly = 0;	
	
//Test points
assign TP_12             = GLB_RESETn;
assign TP_14             = WMP_RSTn;
assign TP_64             = PUR;

//Constant assignments
assign WMP_DTR1			= 0; 	//WMP RS232 data terminal ready port 1, TTL level. Data terminal ready is always active.
assign WMP_RTS2			= 0; 	//WMP RS232 request to send port 2, TTL level. Request to send is always active.
assign DBG232_ENn			= 0;	//Debug RS232 receiver enable (active LOW) always enabled
assign CLK_ON				= 1;	//7.3728 MHz enable (active HIGH). Turned ON when the CPLD is powered.
assign	CPLD_PIN_2		= 0;	//unused
assign	CPLD_PIN_15		= 0;	//unused
assign	CPLD_PIN_16		= 0;	//unused
assign	CPLD_PIN_97		= 0; 	//unused


//Pin-to-pin routing in the CPLD
assign CPLD_3V3_ON 			= SYS_ON && reset_system;			//The external interfaces are powered on when SYS_ON is active
assign CPLD_4V2_ON       	= SYS_ON && reset_system;			//The WMP is powered ON when the PM MSP SYS_ON signal is active
assign CPLD_GPS_PWR_EN 		= WMP_GPS_PWR_EN && GPS_pwr_dly && SYS_ON && reset_system;		//Disable GPS power when WMP power is OFF
assign Global_Reset_1V8n 	= GLB_RESETn; 							//WMP INT2/GPIO45
assign NRUN_STOP         	= !RUN_NSTOP;							//Vehicle bus enable transceiver CPLD reset, data and clock programming (active LOW)
assign WMP_TAMPER        	= CPLD_TAMPER && CPLD_4V2_ON;		//Bus voltage level shift for tamper flag to WMP. Should be gated with CPLD_4V2_ON
assign CPLD_WMP_SHUTDOWN 	= WMP_SHUTDOWN && DMM_ON;			//DMM MSP GPIO2.0
assign CPLD_CALL_BUTTON  	= CALL_BUTTON && DMM_ON;			//DMM MSP GPIO1.3
assign CPLD_CLR_TAMPER   	= WMP_CLR_TAMPER;						//Clears the tamper flag (active LOW)
assign WMP_ON 					= SYS_ON && reset_system;			//The WMP_ON signal is enabled only when the WMP is powered ON
assign WMP_READY 				= SYS_ON && reset_system && GPS_pwr_dly;			//The WMP_READY signal is only enabled whh the WMP is powered ON
assign NCPLD_3V3_ON 			=  ~(SYS_ON && DMM_ON);				// NCPLD_3V3_ON should only go active when the DMM is power is ON
assign DBG232_PWRDN      	= SYS_ON && reset_system;			//Disable debug RS232 transmitter until 3.3V power rail is turned ON
assign DMM_TX					= DMM_RX;								//Unused external TX and RX
assign GPS_RXD					= GPS_RXD_INT && CPLD_GPS_PWR_EN;//Hold GPS_RXD LOW if GPS power is OFF
assign CLK_32K					= CLK_32K_INT && DMM_ON;			//Hold CLK_32K LOW if DMM MSP power is OFF
assign CLK_1P8432M			= CLK_1P8432M_INT && DMM_ON;		//Hold CLK_1P8432M LOW if DMM MSP power is OFF




CrossPoint_SW	b2v_inst(					//Serial communications cross point switch (multiplexor)
	.WMP_RXD2(WMP_RXD2),
	.GPS_TXD(GPS_TXD),
	.VBI_TX(VBI_TX),
	.RS232_RTS(RS232_RTS),
	.WMP_RXD1(WMP_RXD1),
	.RS232_TX(RS232_TX),
	.WMP_CTS1(WMP_CTS1),
	.SEL(SEL),
	.PUR(PUR),
	.RS232_CTS(RS232_CTS),
	.GPS_RXD(GPS_RXD_INT),
	.RS232_RX(RS232_RX),
	.WMP_TXD2(WMP_TXD2),
	.WMP_TXD1(WMP_TXD1),
	.WMP_RTS1(WMP_RTS1),
	.VBI_RX(VBI_RX)
	);


BufSig	b2v_inst1(							//Crash pulse latching and clear
	.CRASH_PULSE(CRASH_PULSE),
	.CRASH_CLEAR(CRASH_CLEAR),
	.SYS_CLK(CLK_32K_INT),
	.CRASH_EVENT(CRASH_EVENT),
	.DMM_ON(DMM_ON)
	);
CRst	b2v_inst6(								//Power on reset and watchdog timer
	.DIP_SW4(SEL[3]),							//added to disable watchdog.
	.CLK_32K(CLK_32K_INT),
	.CLK_16HZ(CLK_16HZ),
	.RESET_PRESS(RESET_PRESS),
	.WMP_TOUT(WMP_TOUT),
	.WMP_RXD1(WMP_RXD1),
	.NWMP_GPS_RST(NWMP_GPS_RST),
	.CPLD_GPS_PWR_EN(CPLD_GPS_PWR_EN && GPS_pwr_dly),
	.GRN_LED(GRN_LED1),
	.MSP_RESET(DMM_RSTn),
	.GLB_RESET(GLB_RESETn),
	.CYCLE_POWER(CYCLE_POWER),
	.WMP_RESET_IN(WMP_RSTn),
	.NGPS_RST(NGPS_RST),
	.reset_system(reset_system),
	.PUR(PUR)
);

SysClk_m	b2v_inst7(							//Generate system clocks
	.PCLK(CLK_7P3728M),
	.CLK_1P8M(CLK_1P8432M_INT),
	.CLK_32K(CLK_32K_INT),
	.CLK_16HZ(CLK_16HZ)
	);


//Counter to keep CPLD_GPS_PWR_EN clear for 1 second after WMP_RSTn goes inactive to filter WMP 1ms bootup spikes
reg [14:0] GPS_pwr_ctr	= 0;											
always @ (posedge CLK_32K)
begin
if (!WMP_RSTn)
	begin
	GPS_pwr_ctr <= 0;
	GPS_pwr_dly <= 0;
	end
else if (GPS_pwr_ctr < 15'h7FFF)
	begin
	GPS_pwr_ctr <= GPS_pwr_ctr + 15'h0001;
	GPS_pwr_dly <= 0;
	end
else 
	begin
	GPS_pwr_ctr <= GPS_pwr_ctr;
	GPS_pwr_dly <= 1;
	end
end	
	

endmodule
