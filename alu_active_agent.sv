class alu_active_agent extends uvm_agent;
  
  alu_driver alu_driver_1;
  alu_sequencer alu_sequencer_1;
  alu_active_monitor alu_monitor_1;
  
  `uvm_component_utils(alu_active_agent)
  
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (get_is_active() == UVM_ACTIVE) begin
      alu_driver_1    = alu_driver::type_id::create("alu_driver_1", this);
      alu_sequencer_1 = alu_sequencer::type_id::create("alu_sequencer_1", this);
    end
    alu_monitor_1 = alu_active_monitor::type_id::create("alu_monitor_1", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    if(get_is_active() == UVM_ACTIVE) begin
      alu_driver_1.seq_item_port.connect(alu_sequencer_1.seq_item_export);
    end
  endfunction

endclass
