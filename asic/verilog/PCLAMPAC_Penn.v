// verilog stub required for genus to not remove physical-only macros/pads -ncd 
`celldefine
module PCLAMPAC_Penn (VDDESD, VSSESD);
   inout VDDESD, VSSESD;   

   // Behavioral placeholder ? no internal modeling
 //  tran (AIO, AIO); // THIS causes genus to uniquify! -ncd 2025
endmodule
`endcelldefine
