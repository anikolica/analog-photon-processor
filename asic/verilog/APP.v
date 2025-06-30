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

   X0814_opamp_N_P amplifier1 (                        //verilog doesnt like start with number  
			      .VINm (inN),
			      .VINp (inP),            // verilog not like VIN-, VIN+ either
			      .VOUT (opamp_out)          // This is output
			      );
   


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


// Core power/gnd   
PVDD1CDG VDD1(.VDD(VDD) );
PVDD1CDG VDD2(.VDD(VDD) );

PVSS1CDG VSS1(.VSS(VSS) );
PVSS1CDG VSS2(.VSS(VSS) );
PVSS1CDG VSS3(.VSS(VSS) );
PVSS1CDG VSS4(.VSS(VSS) );

// IO power/gnd
PVDD2CDG VDDPST1(.VDDPST(DVDD) );
PVDD2CDG VDDPST2(.VDDPST(DVDD) );

PVSS2CDG VSSPST1(.VSSPST(VSS));
PVSS2CDG VSSPST2(.VSSPST(VSS));

// Power-on I/O ring sequencer (need one per power domain) 
PVDD2POC POC1(.VDDPST() );

   
// analog inputs/outputs -ncd
PVDD1ANA   ANA_P(.AVDD(inP) );
PCLAMP1ANA ANA_P_clamp(.VSSESD(VSS), .VDDESD(inP) );  

PVDD1ANA   ANA_N(.AVDD(inN) );
PCLAMP1ANA ANA_N_clamp(.VSSESD(VSS), .VDDESD(inN) );  


PVDD1ANA   ANA_OUT(.AVDD(opamp_out) );
PCLAMP1ANA ANA_OUT_clamp(.VSSESD(VSS), .VDDESD(opamp_out) );  


PCLAMP1ANA VDD_clamp(.VSSESD(VSS), .VDDESD(VDD) );  
PCLAMP2ANA DVDD_clamp(.VSSESD(VSS), .VDDESD(DVDD) );  



 
endmodule // dummy_top
