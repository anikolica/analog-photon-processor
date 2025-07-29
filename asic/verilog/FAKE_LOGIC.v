/* Add fake logic to stop Genus from removing physical macros
  -ncd 2025 
 */

module top (
  input logic dummy_in,
  output logic dummy_out
);
  wire net_analog;

  // Connect analog macro to pad
  X0814_opamp_N_P u_opamp (.VINm(net_analog), .VINp(net_analog), .VOUT(net_analog));
  PDB1A u_pad (.AIO(net_analog));

  // Anchor net to real logic
  assign net_analog = dummy_in;
  assign dummy_out = net_analog;
endmodule
