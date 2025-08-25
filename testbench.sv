`include "uvm_pkg.sv"
`include "uvm_macros.svh"
`include "alu_pkg.sv"
`include "alu_interface.sv"
`include "design.sv"

module top;
  import uvm_pkg::*;  
  import alu_pkg::*;
 
  bit clk;
  bit reset;
  
  always #5 clk = ~clk;
  
  initial begin
//     reset = 1;
//     #5 reset =0;
  end
  alu_interface intrf(clk,reset);
  
  ALU_DESIGN DUV(
    .OPA(intrf.opa),
    .OPB(intrf.opb),
    .CIN(intrf.cin),
    .CLK(clk),
    .RST(reset),
    .CE(intrf.ce),
    .MODE(intrf.mode),
    .CMD(intrf.cmd),
    .INP_VALID(intrf.inp_valid),
    .RES(intrf.res),
    .COUT(intrf.cout),
    .OFLOW(intrf.oflow),
    .G(intrf.g),
    .E(intrf.e),
    .L(intrf.l),
    .ERR(intrf.err)
  );

  
  initial begin 
    uvm_config_db#(virtual alu_interface)::set(uvm_root::get(),"*","vif",intrf);
  end
  
  initial begin 
    run_test("two_arithmetic_test");
    #1000 $finish;
  end
endmodule
