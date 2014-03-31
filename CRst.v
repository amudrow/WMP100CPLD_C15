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
// CREATED		"Wed Dec 05 17:10:37 2012"


module CRst(
input			DIP_SW4,				//added to disable watchdog whenever DIP_SW4 is LOW
input			CLK_32K,				//32 KHz clock, generated in the SysClk module
input			CLK_16HZ,			//16 Hz clock, generated in the SysClk module
input			RESET_PRESS,		//TiwiPro reset button, active HIGH
input			WMP_TOUT,			//watchdog timer reset from WMP GPIO
input			WMP_RXD1,			//watchdog timer reset (whenever a transaction occurs on WMP_RXD1)
input			NWMP_GPS_RST,		//GPS reset from WMP (GPIO GPIO09) active LOW
input			CPLD_GPS_PWR_EN,	//GPS ower enable from WMP (active LOW)
output		GRN_LED,				//drives CPLD status LED D7
output		MSP_RESET,			//DMM MSP reset (active LOW)
output		GLB_RESET,			//Global reset to WMP and DMM MSP (active LOW)
output		CYCLE_POWER,		//Cycle power signal to PM MSP
output		WMP_RESET_IN,		//WMP reset (active LOW)
output reg	reset_system = 0,	//Low for 31ms at power up
output reg	NGPS_RST = 0,		//GPS reset (active LOW), delayed 18ms
output reg 	PUR = 0				//power up reset, active LOW 2 seconds after CPLD power on
);

// Internal wires and registers
// Power on reset
reg	PUR_DLY_n1				= 0;
//Clocks
wire	clk_1hz;
wire	clk_2hz;
wire	clk_4hz;
wire	clk_8hz;
// Reset button
reg	reset_down				= 0;		//The reset button is pressed
wire	reset_down_DLY_n1;				//The reset buttton is pressed and debounced
reg	RESET_SW_4_SEC			= 0;		// The reset switch has been pressed for 4 seconds
reg	RESET_SW_5_SEC			= 0;		// The reset switch has been pressed for 5 seconds
reg	RESET_SW_10_SEC		= 0;		// The reset switch has been pressed for 10 seconds
wire	[7:0] reset_count;
// Watchdog timer
wire	WDT_TOUT;							//Signals the watchdog timer has timed out
wire	RESET_WDT;
wire	RESET_WDT_PULSE;
reg	RESET_WDT_PULSE_DLY1	= 0;
reg	RESET_WDT_DLY1			= 0;
reg	RESET_WDT_DLY2			= 0;
reg	RESET_PRESS_DLY1		= 0;
reg	RESET_PRESS_DLY2		= 0;
reg	RESET_PRESS_DLY3		= 0;
reg	WDT_TOUT_DLY1			= 0;		




//-----------------------------------------------------------------------------------------------
// Reset button (SW1) function: Press and hold reset button (RESET_PRESS is active HIGH)
// 	After 4 seconds enable GLB_RESET: warning a reset is coming
// 	After 5 seconds enable MSP_RESET: reset the DMM MSP
//		After 10 seconds, enable CYCLE_POWER: signal the PM MSP to cycle system power

// Debounce reset button with three CLK_16HZ cycles (125 ms to 187 ms)
always@(posedge CLK_16HZ or negedge PUR)
begin
if (!PUR)
	begin
	RESET_PRESS_DLY1 <= 0;
	end
else
	begin
	RESET_PRESS_DLY1 <= RESET_PRESS;
	end
end

always@(posedge CLK_16HZ or negedge PUR)
begin
if (!PUR)
	begin
	RESET_PRESS_DLY2 <= 0;
	end
else
	begin
	RESET_PRESS_DLY2 <= RESET_PRESS_DLY1;
	end
end

always@(posedge CLK_16HZ or negedge PUR)
begin
if (!PUR)
	begin
	RESET_PRESS_DLY3 <= 0;
	end
else
	begin
	RESET_PRESS_DLY3 <= RESET_PRESS_DLY2;
	end
end

assign	reset_down_DLY_n1 = RESET_PRESS_DLY2 | RESET_PRESS_DLY3 | RESET_PRESS_DLY1;   //reset down when any of the delays are active

always@(negedge CLK_16HZ or negedge PUR)
begin
if (!PUR)
	begin
	reset_down <= 0;
	end
else
	begin
	reset_down <= reset_down_DLY_n1;
	end
end

// After the reset button is pressed and debounced, start the up counter

lpm_counter_1	b2v_inst6(			//Upcounter
	.clock(clk_4hz),
	.aclr(!reset_down),
	.q(reset_count)
	);

always@(negedge CLK_16HZ or negedge reset_down)	// Reset button pressed for 4 seonds
begin
if (!reset_down)
	begin
	RESET_SW_4_SEC <= 1;
	end
else
if (reset_count[4])
	begin
	RESET_SW_4_SEC <= 0;
	end
end


always@(negedge CLK_16HZ or negedge reset_down)	// Reset button pressed for 5 seonds
begin
if (!reset_down)
	begin
	RESET_SW_5_SEC <= 1;
	end
else
if (reset_count[4] & reset_count[2])
	begin
	RESET_SW_5_SEC <= 0;
	end
end


always@(negedge CLK_16HZ or negedge reset_down)	// Reset button pressed for 10 seonds
begin
if (!reset_down)
	begin
	RESET_SW_10_SEC <= 1;
	end
else
if (reset_count[5] & reset_count[3])
	begin
	RESET_SW_10_SEC <= 0;
	end
end

assign	GLB_RESET = RESET_SW_4_SEC & PUR;								// GLB_RESET goes active 4 seconds after the reset button is pressed
assign	MSP_RESET = RESET_SW_5_SEC & PUR;								// MSP_RESET goes active 5 seconds after the reset button is pressed
assign	CYCLE_POWER = (!RESET_SW_10_SEC & PUR) | (WDT_TOUT_DLY1 & DIP_SW4);	// CYCLE_POWER goes active 10 seconds after the reset button is pressed or if the watchdog timer times out 

// End of reset button function






//-------------------------------------------------------------------------------------------------------------------------------------------
// Watchdog timer function: If the watchdog timer times out (after 128 seconds), the WMP is reset and the PM MSP is signaled to cycle power
//		The watchdog timer is reset if either the WMP_TOUT (active HIGH) or the WMP_RXD (active LOW) signals transition
//		The watchdog timer is disabled if DIP_SW4 is set (LOW)

assign	RESET_WDT = !WMP_RXD1 | WMP_TOUT;		// The conditions that reset the watchdog timer

// Look for a transition on the watchdog timer conditions

always@(posedge CLK_16HZ or negedge reset_system)
begin
if (!reset_system)
	begin
	RESET_WDT_DLY1 <= 0;
	end
else
	begin
	RESET_WDT_DLY1 <= RESET_WDT;
	end
end

always@(negedge CLK_16HZ or negedge reset_system)
begin
if (!reset_system)
	begin
	RESET_WDT_DLY2 <= 0;
	end
else
	begin
	RESET_WDT_DLY2 <= RESET_WDT_DLY1;
	end
end

assign	RESET_WDT_PULSE = RESET_WDT_DLY1 ^ RESET_WDT_DLY2;		//exclusive OR

always@(negedge CLK_16HZ or negedge reset_system)
begin
if (!reset_system)
	begin
	RESET_WDT_PULSE_DLY1 <= 0;
	end
else
	begin
	RESET_WDT_PULSE_DLY1 <= RESET_WDT_PULSE;
	end
end

lpm_counter_1	b2v_inst5(					//128 second watchdog timer timeout (8 bit counter clocked at 2 Hz)
	.clock(clk_2hz),
	.aclr(RESET_WDT_PULSE_DLY1),   		
	.cout(WDT_TOUT)   						//Carry out signals the watchdog timer has timed out
	);

always@(negedge clk_2hz or negedge reset_system)
begin
if (!reset_system)
	begin
	WDT_TOUT_DLY1 <= 0;
	end
else
	begin
	WDT_TOUT_DLY1 <= WDT_TOUT;
	end
end

assign	WMP_RESET_IN = !((WDT_TOUT_DLY1 && DIP_SW4) || !MSP_RESET || !PUR);	//WMP_RESET_IN is LOW if WDT_TOUT_DLY1 is HIGH and DIP_SW4 is HIGH, OR MSP_RESET is LOW OR PUR is LOW
																										//the watchdog timer is disabled if DIP_SW4 is LOW
	// End of watchdog timer function


	
//-------------------------------------------------------------------------------------------------------------------------------------------
// Power up reset function: Power up reset (PUR) is active (LOW) for two seconds after power to the CPLD is turned on
//		
//		

// Turn OFF the reset_system signal on the first LOW to HIGH transition of CLK_16HZ (should be 31 ms after power on)

always@(posedge CLK_32K)
begin
if (!reset_system)
	begin
	reset_system <= CLK_16HZ;
	end
end

// Divide CLK_16HZ to create 1 Hz, 2 Hz, 4 Hz and 8 Hz signals
reg [3:0] countf = 0;
always @(posedge CLK_16HZ)
begin
		countf <= countf + 1'b1;
end
assign clk_8hz = countf[0];
assign clk_4hz = countf[1];
assign clk_2hz = countf[2];
assign clk_1hz = countf[3];

// Generate PUR active (LOW for two clocks of the 1 HZ signal (clk_1hz)
always@(negedge clk_1hz or negedge reset_system)
begin	
if (!reset_system)
	begin
	PUR_DLY_n1 <= 0;
	end
else
	begin
	PUR_DLY_n1 <= 1'b1;
	end
end

always@(negedge clk_1hz or negedge reset_system)
begin
if (!reset_system)
	begin
	PUR <= 0;
	end
else
	begin
	PUR <= PUR_DLY_n1;
	end
end


	// End of power up reset function

//-------------------------------------------------------------------------------------------------------------------------------------------
// Green LED function: The green LED is ON for two seconds at CPLD power up and then blinks at an 8 Hz rate thereafter
//		
//		
assign	GRN_LED = PUR & clk_8hz;
	// End of power up reset function

	
	
//-------------------------------------------------------------------------------------------------------------------------------------------
// GPS reset delay function: NGPS_RST is kept low for 18ms (590 cloclks of 32KHz) after GPS power is enabled
//		
//		

// 

reg [9:0] cgps 	= 0;							//GPS reset counter

always @(posedge CLK_32K)
begin
//	if (!NWMP_GPS_RST | !CPLD_GPS_PWR_EN)
	if (!CPLD_GPS_PWR_EN)				//(test)
	begin
		NGPS_RST <= 1'b0;					//NGPS_RST is LOW whenever NWMP_GPS_RST is LOW OR whenever GPS power is off
		cgps <= 0;							//Clear the GPS reset counter if NWMP_GPS_RST is LOW
	end
	else if (cgps < 590)
	begin
		cgps <= cgps+1'b1;				// GPS_RST is kept low for 18ms (590 cloclks of 32KHz) after  NWMP_GPS_RST 
		NGPS_RST <= 1'b0;	
	end
	else if (cgps >= 590) 				
	begin
		cgps <= cgps;
		NGPS_RST <= 1'b1;
	end
	else
	begin
		NGPS_RST <= 1'b1;
	end
end 

// End of GPS reset delay function
endmodule


// Counter module
module lpm_counter_1 ( 
    clock,	// Positive-edge-triggered clock. (Required)
    aclr,	// Asynchronous clear input.
    q,		// Data output from the counter.
    cout		// Carry-out of the MSB.
);
    input wire clock; 
    input wire aclr;
    output reg [7:0]	q	= 0;
    output reg cout		= 0;


    always @(posedge aclr or posedge clock)
    begin
        if (aclr)
        begin
          q <= 0;
          cout <= 0;
        end
        else 
        begin
			   cout <= (q == 8'b11111111)? 1'b1 : 1'b0;
			   q <= q + 1'b1;
        end
    end                  
endmodule // lpm_counter_1

