// verilog stub required for genus to not remove physical-only macros/pads -ncd 
`celldefine
module ESD_DIFF_Penn2 (A, P, N, DifRef, TACVDD, VSS);
   inout A;
   inout P, N;
   inout DifRef;
   inout TACVDD, VSS;


   // Behavioral placeholder ? no internal modeling
 //  tran (AIO, AIO); // THIS causes genus to uniquify! -ncd 2025
endmodule
`endcelldefine
