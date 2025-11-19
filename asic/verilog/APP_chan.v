// Library - 2025_APP_FINAL, Cell - APP_chan, View - schematic
// LAST TIME SAVED: Aug  7 14:35:34 2025
// NETLIST TIME: Aug  7 14:37:20 2025
`timescale 1ns / 1ns 

module APP_chan ( CMP, WE_ampl, WE_time, GND, TOT_INTEGRAL, VDD, VDDH,
     amplitudePeak1, amplitudePeak2, amplitudeValley1, eventEdge_back,
     eventEdge_front, timePeak1, timePeak2, timeValley1, B0, CLK, RE,
     RST_INIT, TOT_delay, VTH_armpeak, VTH_armvalley, VTH_peak,
     VTH_valley, Vbase, delay_hold_D1, delay_hold_D1P, delay_hold_U1,
     delay_hold_U1P, delay_hold_U2, delay_hold_U2P, sel_TOT_event,
     vcomp, cycle, LI_INTEGRAL, sel_LI_event, Nhit_sum, Analog_sum);

output  CMP;

inout  GND, TOT_INTEGRAL, VDD, VDDH, amplitudePeak1, amplitudePeak2,
     amplitudeValley1, eventEdge_back, eventEdge_front, timePeak1,
     timePeak2, timeValley1, LI_INTEGRAL, Nhit_sum, Analog_sum;

input  B0, CLK, RE, RST_INIT, VTH_armpeak, VTH_armvalley, VTH_peak,
     VTH_valley, Vbase, vcomp, cycle;

output [8:1]  WE_ampl;
output [8:1]  WE_time;

input [3:1]  sel_LI_event;
input [3:1]  sel_TOT_event;
input [3:0]  TOT_delay;
input [3:0]  delay_hold_U2;
input [3:0]  delay_hold_U2P;
input [3:0]  delay_hold_U1P;
input [3:0]  delay_hold_U1;
input [3:0]  delay_hold_D1;
input [3:0]  delay_hold_D1P;


endmodule // APP_chan



