class alu_passive_agent extends uvm_agent;

  `uvm_component_utils(alu_passive_agent)
  
  alu_passive_monitor alu_monitor_2;

  uvm_active_passive_enum is_active = UVM_PASSIVE;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (is_active == UVM_PASSIVE) begin
      alu_monitor_2 = alu_passive_monitor::type_id::create("alu_monitor_2", this);
    end
  endfunction
  
endclass
