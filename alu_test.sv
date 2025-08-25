
class alu_base extends uvm_test;
  `uvm_component_utils(alu_base)  
  alu_environment alu_env;
  function new(string name = "alu_base",uvm_component parent=null);
    super.new(name,parent);
  endfunction : new
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    alu_env = alu_environment::type_id::create("alu_environment", this);
  endfunction : build_phase

  virtual function void end_of_elaboration();
   print();
  endfunction
endclass 



class single_arithmetic_test extends alu_base; 
  `uvm_component_utils(single_arithmetic_test)
  function new(string name = "single_arithmetic_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  virtual task run_phase(uvm_phase phase);
    single_arithmetic_sequence seq;
    phase.raise_objection(this);
    seq = single_arithmetic_sequence ::type_id::create("seq");
    seq.start(alu_env.alu_agent_1.alu_sequencer_1);
    phase.drop_objection(this);
  endtask
endclass

class single_logical_test extends alu_base;
  `uvm_component_utils(single_logical_test)
  function new(string name = "single_logical_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  virtual task run_phase(uvm_phase phase);
    single_logical_sequence seq;
    phase.raise_objection(this);
    seq = single_logical_sequence::type_id::create("seq");
    seq.start(alu_env.alu_agent_1.alu_sequencer_1);
    phase.drop_objection(this);
  endtask
endclass


class two_arithmetic_test extends alu_base;
  `uvm_component_utils(two_arithmetic_test)
  function new(string name = "two_arithmetic_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  virtual task run_phase(uvm_phase phase);
    two_arithmetic_sequence seq;
    phase.raise_objection(this);
    seq = two_arithmetic_sequence::type_id::create("seq");
    seq.start(alu_env.alu_agent_1.alu_sequencer_1);
    phase.drop_objection(this);
  endtask
endclass

class two_logical_test extends alu_base;
  `uvm_component_utils(two_logical_test)
  function new(string name = "two_logical_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  virtual task run_phase(uvm_phase phase);
    two_logical_sequence seq;
    phase.raise_objection(this);
    seq = two_logical_sequence::type_id::create("seq");
    seq.start(alu_env.alu_agent_1.alu_sequencer_1);
    phase.drop_objection(this);
  endtask
endclass

class alu_regression_test extends alu_base;
  `uvm_component_utils(alu_regression_test)
  function new(string name = "alu_regression_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  virtual task run_phase(uvm_phase phase);
    alu_regression_sequence seq;
    phase.raise_objection(this);
    seq =  alu_regression_sequence::type_id::create("seq");
    seq.start(alu_env.alu_agent_1.alu_sequencer_1);
    phase.drop_objection(this);
  endtask
endclass
