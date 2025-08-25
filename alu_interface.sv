interface alu_interface #(parameter WIDTH = 8) (input bit clk, reset);

  logic [WIDTH-1:0] opa;
  logic [WIDTH-1:0] opb;
  logic [3:0] cmd;
  logic ce;
  logic [1:0]inp_valid;
  logic mode;
  logic cin;
  
  logic [WIDTH+1:0] res;
  logic oflow;
  logic cout;
  logic g;
  logic l;
  logic e;
  logic err;
  
  clocking drv_cb @(posedge clk);
    default input #0 output #0;
    output opa, opb, cmd, inp_valid, mode, cin, ce;
    input res,oflow,cout,g,l,e,err;
  endclocking
  
  clocking mon_cb @(posedge clk);
    default input #0 output #0;
    input opa, opb, cmd, inp_valid, mode, cin, ce, reset;
    input res, oflow, cout, g, l, e, err;
  endclocking
  
  modport DRV(input clk, reset, clocking drv_cb);
  modport MON(input clk, reset, clocking mon_cb);
    
endinterface
