// verilog stub required for genus to not remove physical-only macros/pads -ncd 
`celldefine
module PDB1A (AIO, TAVDD, TACVDD, VSS);
   inout AIO;
   inout TAVDD, TACVDD, VSS;
   

   // Behavioral placeholder ? no internal modeling
 //  tran (AIO, AIO); // THIS causes genus to uniquify! -ncd 2025
endmodule
`endcelldefine
