class alu_sequence extends uvm_sequence #(alu_sequence_item);
  `uvm_object_utils(alu_sequence)
  function new(string name = "alu_sequence");
    super.new(name);
  endfunction
  virtual task body();
    repeat(`no_of_trans) begin
      req = alu_sequence_item::type_id::create("req");
      wait_for_grant();
      req.randomize();
      send_request(req);
      req.print();
      wait_for_item_done();
    end
  endtask
endclass
    
class single_arithmetic_sequence extends uvm_sequence #(alu_sequence_item);
  `uvm_object_utils(single_arithmetic_sequence)
  function new(string name = "single_arithmetic_sequence");
    super.new(name);
  endfunction
  virtual task body();
    repeat(`no_of_trans) begin
    `uvm_do_with(req,{cmd inside {[4:7]};
                      mode == 1;
                      cin == 0;
                      ce == 1;
                      inp_valid inside {[0:3]};})
    end
  endtask
endclass

class single_logical_sequence extends uvm_sequence #(alu_sequence_item);
  `uvm_object_utils(single_logical_sequence)
  function new(string name = "single_logical_sequence");
    super.new(name);
  endfunction
  virtual task body();
    `uvm_do_with(req,{cmd inside {[6:11]};
                      mode == 0; 
                      cin == 0;
                      ce == 1;
                      inp_valid inside {[0:3]};})
  endtask
endclass


class two_arithmetic_sequence extends uvm_sequence #(alu_sequence_item);
  `uvm_object_utils(two_arithmetic_sequence)
  function new(string name = "two_arithmetic_sequence");
    super.new(name);
  endfunction
  virtual task body();
    repeat(`no_of_trans) begin
    `uvm_do_with(req,{cmd inside {0};
                      mode == 1;
                      cin == 0;
                      ce == 1;
                      inp_valid inside {[0:3]};})
    end
  endtask
endclass
    
class two_logical_sequence extends uvm_sequence #(alu_sequence_item);
  `uvm_object_utils(two_logical_sequence)
  function new(string name = "two_logical_sequence");
    super.new(name);
  endfunction
  virtual task body();
    `uvm_do_with(req,{cmd inside {0,1,2,3,4,5,12,13};
                      mode == 0; 
                      cin == 0;
                      ce == 1;
                      inp_valid inside {[0:3]};})
  endtask
endclass

class alu_regression_sequence extends uvm_sequence #(uvm_sequence_item);
  single_arithmetic_sequence ar1_seq;
  two_arithmetic_sequence ar2_seq;
  single_logical_sequence log1_seq;
  two_logical_sequence log2_seq;
  alu_sequence a1;
  `uvm_object_utils(alu_regression_sequence)
  function new(string name = "alu_regression_sequence");
    super.new(name);
  endfunction
  virtual task body();
    
    //`uvm_do(a1);
    
   // `uvm_do(ar1_seq)
    `uvm_do(ar2_seq)
//     `uvm_do(log1_seq)
//     `uvm_do(log2_seq)
  endtask
endclass

    
