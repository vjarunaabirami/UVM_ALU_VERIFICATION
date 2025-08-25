

class alu_environment extends uvm_env;
  alu_active_agent alu_agent_1;
  alu_passive_agent alu_agent_2;
  alu_scoreboard alu_scoreboard_1;
  alu_coverage alu_coverage_1;
  
  `uvm_component_utils(alu_environment)
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    alu_agent_1 = alu_active_agent::type_id::create("alu_agent_1", this);
    alu_agent_2 = alu_passive_agent::type_id::create("alu_agent_2", this);
    alu_scoreboard_1 = alu_scoreboard::type_id::create("alu_scoreboard_1", this);
    alu_coverage_1 = alu_coverage::type_id::create("alu_coverage_1", this);
  endfunction
 
  function void connect_phase(uvm_phase phase);  
    alu_agent_1.alu_monitor_1.ap.connect(alu_scoreboard_1.mon1_imp);
    alu_agent_2.alu_monitor_2.ap.connect(alu_scoreboard_1.mon2_imp);
    alu_agent_1.alu_monitor_1.ap.connect(alu_coverage_1.aport_mon1);
    alu_agent_2.alu_monitor_2.ap.connect(alu_coverage_1.aport_mon2);
  endfunction

endclass
