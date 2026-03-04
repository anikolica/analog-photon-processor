// verilog stub required for genus to not remove physical-only macros/pads -ncd 
`celldefine
module CLK_DIFF_Penn (CLK, P, N, i_sink_in_10u, vddd_2p5, TACVDD, VDD, VSS);
   inout CLK;
   inout P, N;
   inout i_sink_in_10u;
   inout vddd_2p5, TACVDD, VDD, VSS;


   // Behavioral placeholder ? no internal modeling
 //  tran (AIO, AIO); // THIS causes genus to uniquify! -ncd 2025
endmodule
`endcelldefine
