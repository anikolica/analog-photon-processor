// verilog stub required for genus to not remove physical-only macros/pads -ncd 
`celldefine
module ESD_PDB1AC_Penn (PAD, CORE, TACVDD, VSS);
   inout PAD, CORE;
   inout TACVDD, VSS;
   

   // Behavioral placeholder ? no internal modeling
 //  tran (AIO, AIO); // THIS causes genus to uniquify! -ncd 2025
endmodule
`endcelldefine
