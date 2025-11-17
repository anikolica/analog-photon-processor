// verilog stub required for genus to not remove physical-only macros/pads -ncd 
`celldefine
module PDB3A_Penn (AIO, TAVDD, VSS);
   inout AIO;
   inout TAVDD, VSS;
   

   // Behavioral placeholder ? no internal modeling
 //  tran (AIO, AIO); // THIS causes genus to uniquify! -ncd 2025
endmodule
`endcelldefine
