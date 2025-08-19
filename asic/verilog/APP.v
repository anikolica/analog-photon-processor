`timescale 1ns/1ps

/*
 * This is a dummy top level for APP.  It should be converted to something 
 * realistic as soon as possible.
 * 
 * Pads are in
 *      /cad/Technology/TSMC650A/V1.7A_1/1p9m6x1z1u/../../digital/Front_End/verilog/tpdn65lpnv2od3_140b/tpdn65lpnv2od3.v
 * Standard Cells are in
 *     /cad/Technology/TSMC650A/V1.7A_1/1p9m6x1z1u/../../digital/Front_End/verilog/tcbn65lp_200a/tcbn65lp.v
 */

module APP(
	   input wire  pad_a0_i,
	   input wire  pad_a1_i,
	   input wire  pad_a2_i,
	   input wire  pad_a3_i,
	   input wire  pad_b0_i,
	   input wire  pad_b1_i,
	   input wire  pad_b2_i,
	   input wire  pad_b3_i,

	   input wire  pad_ana0_i,
	   input wire  pad_ana1_i,

	   output wire pad_c0_o,
	   output wire pad_c1_o,
	   output wire pad_c2_o,
	   output wire pad_c3_o ,
	   output wire pad_c4_o,

	   output wire pad_ts00_o,
	   output wire pad_ts01_o,
	   output wire pad_ts02_o,
	   output wire pad_ts03_o,
	   output wire pad_ts04_o,
	   output wire pad_ts05_o,
	   output wire pad_ts06_o,
	   output wire pad_ts07_o,
	   output wire pad_ts08_o,
	   output wire pad_ts09_o,
	   output wire pad_ts10_o,
	   output wire pad_ts11_o,
	   output wire pad_ts12_o,
	   output wire pad_ts13_o,
	   output wire pad_ts14_o,
	   output wire pad_ts15_o,

	   output wire pad_anaOut_o,
	   
	   input wire  pad_clk_i,
	   input wire  pad_rstb_i
		 );

/****************************************************************************
 *				 PADS                                       *
 ****************************************************************************/
/* -> /tape/mitch_sim/cds_proto/tsmc/digital/coldMPW_v3/syn/verilog/coldMPW.v <-
 
   module PDDW0204CDG (I,DS,OEN,PAD,C,PE,IE);
   input I,DS,OEN,PE,IE;
   inout PAD;
   output C;
   wire  MG;
   parameter PullTime = 100000;
   reg lastPAD, pull_uen, pull_den,PS;
** pin I: internal chip data to be sent off chip
 * pin C: received external data
 
** 2mA drive strength 
** can Program a pulldown on Pad
** Schmidt trigger on input 
** can Program drive strength DS=1 high  
** Receiver Mode: IE=1, OEN=1
** Driver Mode: OEN=0, IE=0
** Driver /w readback: OEN=0, IE=1 

 Input (digital) example:
 PDDW0408SCDG padXXX( .I(1'b0), .DS(1'b1), .OEN(1'b1),
   .PAD(pad_XXX),    // Input pad
   .C  (XXX),        // signal
   .PE (1'b1), .IE(1'b1) );
 
 Output (digital) example:
 PDDW0408SCDG padXXX( .I (XXX),  // signal
   .DS  (1'b1),
   .OEN (1'b0),
   .PAD (pad_XXX),   // Output pad
   .C   (),
   .PE  (1'b0),
   .IE  (1'b0) );

 */

   wire [3:0] a_i;
   wire [3:0] b_i;

   wire       ana0, ana1;
   
   wire [4:0] c_o;

   wire [15:0] tstamp;
   wire [15:0] tstampOut;
   
   wire       anaOut;

   wire       clk;
   wire       rstb;

   /*****************************************************
    *             Input pads                            *
    *****************************************************/
   PDDW0408SCDG padA0( .I(1'b0), .DS(1'b1), .OEN(1'b1),
			.PAD(pad_a0_i),    // Input pad
			.C  (a_i[0]),      // signal
			.PE (1'b1), .IE(1'b1) );

   PDDW0408SCDG padA1( .I(1'b0), .DS(1'b1), .OEN(1'b1),
			.PAD(pad_a1_i),    // Input pad
			.C  (a_i[1]),      // signal
			.PE (1'b1), .IE(1'b1) );

   PDDW0408SCDG padA2( .I(1'b0), .DS(1'b1), .OEN(1'b1),
			.PAD(pad_a2_i),    // Input pad
			.C  (a_i[2]),      // signal
			.PE (1'b1), .IE(1'b1) );

   PDDW0408SCDG padA3( .I(1'b0), .DS(1'b1), .OEN(1'b1),
			.PAD(pad_a3_i),    // Input pad
			.C  (a_i[3]),      // signal
			.PE (1'b1), .IE(1'b1) );


   PDDW0408SCDG padB0( .I(1'b0), .DS(1'b1), .OEN(1'b1),
			.PAD(pad_b0_i),    // Input pad
			.C  (b_i[0]),      // signal
			.PE (1'b1), .IE(1'b1) );

   PDDW0408SCDG padB1( .I(1'b0), .DS(1'b1), .OEN(1'b1),
			.PAD(pad_b1_i),    // Input pad
			.C  (b_i[1]),      // signal
			.PE (1'b1), .IE(1'b1) );

   PDDW0408SCDG padB2( .I(1'b0), .DS(1'b1), .OEN(1'b1),
			.PAD(pad_b2_i),    // Input pad
			.C  (b_i[2]),      // signal
			.PE (1'b1), .IE(1'b1) );

   PDDW0408SCDG padB3( .I(1'b0), .DS(1'b1), .OEN(1'b1),
			.PAD(pad_b3_i),    // Input pad
			.C  (b_i[3]),      // signal
			.PE (1'b1), .IE(1'b1) );

   PDDW0408SCDG padana0( .I(1'b0), .DS(1'b1), .OEN(1'b1),
			.PAD(pad_ana0_i),    // Input pad
			.C  (ana0_i),      // signal
			.PE (1'b1), .IE(1'b1) );
   PDDW0408SCDG padana1( .I(1'b0), .DS(1'b1), .OEN(1'b1),
			.PAD(pad_ana1_i),    // Input pad
			.C  (ana1_i),      // signal
			.PE (1'b1), .IE(1'b1) );
   

   PDDW0408SCDG padCLK( .I(1'b0), .DS(1'b1), .OEN(1'b1),
			.PAD(pad_clk_i),  // Input pad
			.C  (clk),        // signal
			.PE (1'b1), .IE(1'b1) );
   
   PDDW0408SCDG padRSTb( .I(1'b0), .DS(1'b1), .OEN(1'b1),
			.PAD(pad_rstb_i),  // Input pad
			.C  (rstb),        // signal
			.PE (1'b1), .IE(1'b1) );
   
   /*****************************************************
    *             Output pads                            *
    *****************************************************/
   PDDW0408SCDG padC0( .I (c_o[0]),  // signal
			.DS  (1'b1),
			.OEN (1'b0),
			.PAD (pad_c0_o),   // Output pad
			.C   (),
			.PE  (1'b0),
			.IE  (1'b0) );

   PDDW0408SCDG padC1( .I (c_o[1]),  // signal
			.DS  (1'b1),
			.OEN (1'b0),
			.PAD (pad_c1_o),   // Output pad
			.C   (),
			.PE  (1'b0),
			.IE  (1'b0) );

   PDDW0408SCDG padC2( .I (c_o[2]),  // signal
			.DS  (1'b1),
			.OEN (1'b0),
			.PAD (pad_c2_o),   // Output pad
			.C   (),
			.PE  (1'b0),
			.IE  (1'b0) );

   PDDW0408SCDG padC3( .I (c_o[3]),  // signal
			.DS  (1'b1),
			.OEN (1'b0),
			.PAD (pad_c3_o),   // Output pad
			.C   (),
			.PE  (1'b0),
			.IE  (1'b0) );

   PDDW0408SCDG padC4( .I (c_o[4]),  // signal
			.DS  (1'b1),
			.OEN (1'b0),
			.PAD (pad_c4_o),   // Output pad
			.C   (),
			.PE  (1'b0),
			.IE  (1'b0) );

   PDDW0408SCDG padTS00( .I (tstampOut[0]),  // signal
			.DS  (1'b1),
			.OEN (1'b0),
			.PAD (pad_ts00_o),   // Output pad
			.C   (),
			.PE  (1'b0),
			.IE  (1'b0) );
   PDDW0408SCDG padTS01( .I (tstampOut[1]),  // signal
			.DS  (1'b1),
			.OEN (1'b0),
			.PAD (pad_ts01_o),   // Output pad
			.C   (),
			.PE  (1'b0),
			.IE  (1'b0) );
   PDDW0408SCDG padTS02( .I (tstampOut[2]),  // signal
			.DS  (1'b1),
			.OEN (1'b0),
			.PAD (pad_ts02_o),   // Output pad
			.C   (),
			.PE  (1'b0),
			.IE  (1'b0) );
   PDDW0408SCDG padTS03( .I (tstampOut[3]),  // signal
			.DS  (1'b1),
			.OEN (1'b0),
			.PAD (pad_ts03_o),   // Output pad
			.C   (),
			.PE  (1'b0),
			.IE  (1'b0) );
   PDDW0408SCDG padTS04( .I (tstampOut[4]),  // signal
			.DS  (1'b1),
			.OEN (1'b0),
			.PAD (pad_ts04_o),   // Output pad
			.C   (),
			.PE  (1'b0),
			.IE  (1'b0) );
   PDDW0408SCDG padTS05( .I (tstampOut[5]),  // signal
			.DS  (1'b1),
			.OEN (1'b0),
			.PAD (pad_ts05_o),   // Output pad
			.C   (),
			.PE  (1'b0),
			.IE  (1'b0) );
   PDDW0408SCDG padTS06( .I (tstampOut[6]),  // signal
			.DS  (1'b1),
			.OEN (1'b0),
			.PAD (pad_ts06_o),   // Output pad
			.C   (),
			.PE  (1'b0),
			.IE  (1'b0) );
   PDDW0408SCDG padTS07( .I (tstampOut[7]),  // signal
			.DS  (1'b1),
			.OEN (1'b0),
			.PAD (pad_ts07_o),   // Output pad
			.C   (),
			.PE  (1'b0),
			.IE  (1'b0) );
   PDDW0408SCDG padTS08( .I (tstampOut[8]),  // signal
			.DS  (1'b1),
			.OEN (1'b0),
			.PAD (pad_ts08_o),   // Output pad
			.C   (),
			.PE  (1'b0),
			.IE  (1'b0) );
   PDDW0408SCDG padTS09( .I (tstampOut[9]),  // signal
			.DS  (1'b1),
			.OEN (1'b0),
			.PAD (pad_ts09_o),   // Output pad
			.C   (),
			.PE  (1'b0),
			.IE  (1'b0) );
   PDDW0408SCDG padTS10( .I (tstampOut[10]),  // signal
			.DS  (1'b1),
			.OEN (1'b0),
			.PAD (pad_ts10_o),   // Output pad
			.C   (),
			.PE  (1'b0),
			.IE  (1'b0) );
   PDDW0408SCDG padTS11( .I (tstampOut[11]),  // signal
			.DS  (1'b1),
			.OEN (1'b0),
			.PAD (pad_ts11_o),   // Output pad
			.C   (),
			.PE  (1'b0),
			.IE  (1'b0) );
   PDDW0408SCDG padTS12( .I (tstampOut[12]),  // signal
			.DS  (1'b1),
			.OEN (1'b0),
			.PAD (pad_ts12_o),   // Output pad
			.C   (),
			.PE  (1'b0),
			.IE  (1'b0) );
   PDDW0408SCDG padTS13( .I (tstampOut[13]),  // signal
			.DS  (1'b1),
			.OEN (1'b0),
			.PAD (pad_ts13_o),   // Output pad
			.C   (),
			.PE  (1'b0),
			.IE  (1'b0) );
   PDDW0408SCDG padTS14( .I (tstampOut[14]),  // signal
			.DS  (1'b1),
			.OEN (1'b0),
			.PAD (pad_ts14_o),   // Output pad
			.C   (),
			.PE  (1'b0),
			.IE  (1'b0) );
   PDDW0408SCDG padTS15( .I (tstampOut[15]),  // signal
			.DS  (1'b1),
			.OEN (1'b0),
			.PAD (pad_ts15_o),   // Output pad
			.C   (),
			.PE  (1'b0),
			.IE  (1'b0) );
   

   PDDW0408SCDG padanaOut( .I (anaOut_o),  // signal
			.DS  (1'b1),
			.OEN (1'b0),
			.PAD (pad_anaOut_o),   // Output pad
			.C   (),
			.PE  (1'b0),
			.IE  (1'b0) );

   
   /*****************************************************
    *             Top Level Modules                     *
    *****************************************************/

   wire        re_trig;
   wire        we_trig;

   assign re_trig = ( tstamp == 16'h5555 )? 1'b1 : 1'b0;
   assign we_trig = ( c_o == 5'b01010 ) ? 1'b1 : 1'b0;

   
   addr top_addr ( .a_i(a_i), .b_i(b_i), .c_o( c_o ), .clk(clk), .rstb(rstb) );

   clk_counter #( .WIDTH(16) ) tstamp_gen ( .count( tstamp ), .clk( clk ), .rstb( rstb ) );

   hcc_syncFifo_latC #( .WORDWIDTH(16), .logDEPTH(3) ) TstampBuf (
						       .data_i( tstamp ),
						       .data_o( tstampOut ),
						       .re_i( re_trig ),
						       .we_i( we_trig ),
						       .clk( clk ),
						       .rstb( rstb )
						      );
   

 
  /****************************************************
    *             MACROS -ncd                          *
    ****************************************************/ 
   wire  inN, inP, opamp_out; // use pragma to encourage Genus to NOT remove this Macro -ncd
   
   X0814_opamp_N_P amplifier1 (                  //verilog doesnt like start with number  
			      .VINm (inN),
			      .VINp (inP),       // verilog not like VIN-, VIN+ either
			      .VOUT (opamp_out)  // can also preserve this analog net
			      );

/*  Adding a preserve net (opamp_out) statement just after elaboration 
   tells Genus to NOT remove analog-only macros (analog pads, etc) that are
   connected to it.    -ncd 2025    
                set_attribute preserve true opamp_out
                                                              */

   
  /********************************************************
   *      Single APP Channel  Macro                        *
   *********************************************************/


/*   
wire  GND, TOT_INTEGRAL, VDD, VDDH, amplitudePeak1, amplitudePeak2,
     amplitudeValley1, eventEdge_back, eventEdge_front, timePeak1,
     timePeak2, timeValley1;
*/
   
wire  CLK, RE, RST_INIT, VTH_armpeak, VTH_armvalley, VTH_peak,
     VTH_valley, Vbase, vcomp;

wire [8:1]  WE_ampl_ch1;
wire [8:1]  WE_time_ch1;

   
wire B0_ch1;  // PMT chan1   
wire CMP_ch1;
wire timePeak1_ch1;
wire timePeak2_ch1;
wire timeValley1_ch1;
wire amplitudeValley1_ch1;
wire amplitudePeak2_ch1;
wire amplitudePeak1_ch1;
wire eventEdge_back_ch1;
wire eventEdge_front_ch1;
wire TOT_INTEGRAL_ch1;
   
wire timePeak1_ch2;
wire timePeak2_ch2;
wire timeValley1_ch2;
wire amplitudeValley1_ch2;
wire amplitudePeak2_ch2;
wire amplitudePeak1_ch2;
wire eventEdge_back_ch2;
wire eventEdge_front_ch2;
wire TOT_INTEGRAL_ch2;
   

wire B0_ch2;   // PMT chan2
wire CMP_ch2;
wire [3:1]  sel_TOT_event;
wire [3:0]  TOT_delay;
wire [3:0]  delay_hold_U2;
wire [3:0]  delay_hold_U2P;
wire [3:0]  delay_hold_U1P;
wire [3:0]  delay_hold_U1;
wire [3:0]  delay_hold_D1;
wire [3:0]  delay_hold_D1P;

  
APP_chan APPchan1 (.CMP(CMP_ch1), .WE_ampl(WE_ampl_ch1), .WE_time(WE_TOTback_ch1),
     .timePeak1(timePeak1_ch1), .timePeak2(timePeak2_ch1),
     .timeValley1(timeValley1_ch1), .amplitudeValley1(amplitudeValley1_ch1),
     .amplitudePeak2(amplitudePeak2_ch1), .amplitudePeak1(amplitudePeak1_ch1),
     .eventEdge_back(eventEdge_back_ch1),
     .eventEdge_front(eventEdge_front_ch1),
     .sel_TOT_event(sel_TOT_event[3:1]), .TOT_INTEGRAL(TOT_INTEGRAL_ch1),
     .GND(GND), .VDD(VDD), .VDDH(VDDH), .B0(B0_ch1), .CLK(CLK), .RE(RE),
     .RST_INIT(RST_INIT), .TOT_delay(TOT_delay[2:0]),
     .VTH_armpeak(VTH_armpeak), .VTH_armvalley(VTH_armvalley),
     .VTH_peak(VTH_peak), .VTH_valley(VTH_valley), .Vbase(Vbase),
     .delay_hold_D1(delay_hold_D1[3:0]),
     .delay_hold_D1P(delay_hold_D1P[3:0]),
     .delay_hold_U1(delay_hold_U1[3:0]),
     .delay_hold_U1P(delay_hold_U1P[3:0]),
     .delay_hold_U2(delay_hold_U2[3:0]),
     .delay_hold_U2P(delay_hold_U2P[3:0]), .vcomp(vcomp));


APP_chan APPchan2 (.CMP(CMP_ch2), .WE_ampl(WE_ampl_ch2), .WE_time(WE_TOTback_ch2),
     .timePeak1(timePeak1_ch2), .timePeak2(timePeak2_ch2),
     .timeValley1(timeValley1_ch2), .amplitudeValley1(amplitudeValley1_ch2),
     .amplitudePeak2(amplitudePeak2_ch2), .amplitudePeak1(amplitudePeak1_ch2),
     .eventEdge_back(eventEdge_back_ch2),
     .eventEdge_front(eventEdge_front_ch2),
     .sel_TOT_event(sel_TOT_event[3:1]), .TOT_INTEGRAL(TOT_INTEGRAL_ch2),
     .GND(GND), .VDD(VDD), .VDDH(VDDH), .B0(B0_ch2), .CLK(CLK), .RE(RE),
     .RST_INIT(RST_INIT), .TOT_delay(TOT_delay[2:0]),
     .VTH_armpeak(VTH_armpeak), .VTH_armvalley(VTH_armvalley),
     .VTH_peak(VTH_peak), .VTH_valley(VTH_valley), .Vbase(Vbase),
     .delay_hold_D1(delay_hold_D1[3:0]),
     .delay_hold_D1P(delay_hold_D1P[3:0]),
     .delay_hold_U1(delay_hold_U1[3:0]),
     .delay_hold_U1P(delay_hold_U1P[3:0]),
     .delay_hold_U2(delay_hold_U2[3:0]),
     .delay_hold_U2P(delay_hold_U2P[3:0]), .vcomp(vcomp));

/* APP_channel signals -ncd
 
 GND          inout
  VDD          inout       1.2v
 VDDH         inout       1.6v

 TOT_INTEGRAL inout       PMT TOT Intagral (ADC)
 amplitudePeak1   inout   Amplitude of peak1 (ADC)
 amplitudePeak2   inout   Amplitude of peak2 (ADC)
 amplitudeValley1 inout   Amplitude of first valley (ADC)
 eventEdge_back   inout   Time of PMT back edge (ADC)
 eventEdge_front  inout   Time of PMT front edge (ADC)
 timePeak1       inout    Time of peak1 (ADC)
 timePeak2       inout    Time of peak2 (ADC)
 timeValley1     inout    Time of first valley (ADC)
 
 B0              input    PMT analog signal terminated 50 Ohms and referenced to Vbase=600mv
 CLK             input    synchronous clock 50MHz
 RE              input    Read Enable (read back everything)
 RST_INIT        input    System Reset (need after power-up)
 VTH_armpeak     input    Arming comparator for peak detector (connect to a DAC)
 VTH_armvalley   input    Arming comparator for valley detector (connect to a DAC)
 VTH_peak        input    Threshold for peak detector (connect to a DAC)
 VTH_valley      input    Threshold for valley detector (connect to a DAC)
 Vbase           input    Base volage for all opamps: connect to 600mV reference (OR a DAC)
 vcomp           input    Threshold for TOT Comparator (DAC)
 delay_hold_D1 [3:0] input   Digital delay to align valley1 ping
 delay_hold_D1P [3:0] input  Digital delay to align peak1   pong
 delay_hold_U1 [3:0] input   Digital delay to align peak1   ping
 delay_hold_U1P [3:0] input  Digital delay to align peak1   pong
 delay_hold_U2 [3:0] input   Digital delay to align peak2   ping
 delay_hold_U2P [3:0] input  Digital delay to align peak2   pong
 TOT_delay     [3:0] input   Digital delay to align TOT comparator 
 sel_TOT_event [3:1] input   Select TOT event to read out with ADCs
 WE_ampl [8:1] output        Flags: Amplitude done for each TOT event; 1 if writing memory
                                                                       0 when write is done 
                                                                       Asychronous!   
 
 WE_time [8:1] output        Flags: TAC done for each TOT event ; = 1 if writing memory
                                                                    0 when write is done
                                                                    Sychronous with CLK  
 
 
 
 */
   
   

  /****************************************************
    *             POWER/GND PADS  -ncd                          *
    ****************************************************/ 
// Cell and Description -ncd
//PVDD1ANA Dedicated Power Supply to Internal Macro with Core Voltage
//PVDD1CDG Vdd Pad for Core Power Supply
//PVDD2ANA Dedicated Power Supply to Internal Macro with I/O Voltage
//PVDD2CDG Power Pad for I/O Power Supply
//PVDD2POC Power-on Control Power Pad for I/O Power Supply
//PVSS1ANA Dedicated Ground Supply for PVDD1ANA
//PVSS1CDG Vss Pad for Core Ground Supply
//PVSS2ANA Dedicated Ground Supply for PVDD2ANA
//PVSS2CDG Ground Pad for I/O Ground Supply
//PVSS3CDG Ground Pad for I/O and Core Ground Supply
//PXOE1CDG Crystal Oscillator Cell (High Enable, without Feedback Resistor)
//PXOE2CDG Crystal Oscillator Cell (High Enable, with Feedback Resistor)

//PCLAMP1ANA ESD Clamp Cell for Core Voltage
//PCLAMP2ANA ESD Clamp Cell for I/O Voltage  

// PRCUT Power-Cut Cell between Digital Domain A and Digital Domain B with
//       VSS Shorted and the Rest of Rails Cut 


// Digital Core power/gnd   
PVDD1CDG VDD1(.VDD(VDD) ); // digital core logic 1.2v
PVDD1CDG VDD2(.VDD(VDD) );

PVSS1CDG VSS1(.VSS(VSS) );  // digital core logic return 0v
PVSS1CDG VSS2(.VSS(VSS) );
PVSS1CDG VSS3(.VSS(VSS) );
PVSS1CDG VSS4(.VSS(VSS) );

//PCLAMP1ANA vddClamp (.VSSESD(VSS), .VDDESD(VDD) ); // ESD clamp for core voltage 1.2v  

   
// IO Digital power/gnd
PVDD2CDG VDDPST1(.VDDPST(VDD) ); // digital I/O Drivers/Receivers 2.5v 
PVDD2CDG VDDPST2(.VDDPST(VDD) );

PVSS2CDG VSSPST1(.VSSPST(VSS)); // digital I/O return 0v 
PVSS2CDG VSSPST2(.VSSPST(VSS));

PCLAMP2ANA dvddClamp (.VSSESD(VSS), .VDDESD(DVDD) ); // ESD clamp for I/O voltage 2.5v  
   
// Digital Power-on I/O ring sequencer (need one per power domain) 
PVDD2POC POC1(.VDDPST() );

    
// analog inputs/outputs -ncd
// PDB1A Analog pad with diode protection
// PCLAMPA Analog clamp ckt


// ANALOG DOMAIN  -ncd
// Separate from digital regions with "PRCUT" Physical cell in innovus -ncd   

PVDD3AC VDDA1(.AVDD(VDD) );
PVSS2AC VSSA1(.VSS(VSS) ); 

//PCLAMPAC vddClampA (.VSSESD(VSS), .VDDESD(VDD) ); // ESD clamp for core voltage 1.2v 
   
  
  
PDB1A ch1_PMT (.AIO(B0_ch1) ); // PMT channel 1
PDB1A ch2_PMT (.AIO(B0_ch2) ); // PMT channel 2
   
PDB1A ANA_P (.AIO(inP) );
PDB1A ANA_N (.AIO(inN) );
PDB1A ANA_OUT (.AIO(opamp_out) );


// These single-ended pads will eventually be replace with differential pads -ncd   
PDB1A ch1_TOT_INTEGRAL (.AIO (TOT_INTEGRAL_ch1) ); 
PDB1A ch1_amplitudePeak1 (.AIO (amplitudePeak1_ch1) );
PDB1A ch1_amplitudePeak2 (.AIO (amplitudePeak2_ch1) );
PDB1A ch1_amplitudeValley1 (.AIO (amplitudeValley1_ch1) );
PDB1A ch1_eventEdge_back (.AIO (eventEdge_back_ch1) );
PDB1A ch1_eventEdge_front (.AIO (eventEdge_front_ch1) );
PDB1A ch1_timePeak1 (.AIO (timePeak1_ch1) );
PDB1A ch1_timePeak2 (.AIO (timePeak2_ch1) );
PDB1A ch1_timeValley1 (.AIO (timeValley1_ch1) );
PDB1A ch1_CMP (.AIO (CMP_ch1) );


PDB1A ch2_TOT_INTEGRAL (.AIO (TOT_INTEGRAL_ch2) ); 
PDB1A ch2_amplitudePeak1 (.AIO (amplitudePeak1_ch2) );
PDB1A ch2_amplitudePeak2 (.AIO (amplitudePeak2_ch2) );
PDB1A ch2_amplitudeValley1 (.AIO (amplitudeValley1_ch2) );
PDB1A ch2_eventEdge_back (.AIO (eventEdge_back_ch2) );
PDB1A ch2_eventEdge_front (.AIO (eventEdge_front_ch2) );
PDB1A ch2_timePeak1 (.AIO (timePeak1_ch2) );
PDB1A ch2_timePeak2 (.AIO (timePeak2_ch2) );
PDB1A ch2_timeValley1 (.AIO (timeValley1_ch2) );
PDB1A ch2_CMP (.AIO (CMP_ch2) );

   


 
endmodule // dummy_top
