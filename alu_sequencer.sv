
class alu_sequencer extends uvm_sequencer#(alu_sequence_item);

  `uvm_component_utils(alu_sequencer)

  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction
  
endclass
