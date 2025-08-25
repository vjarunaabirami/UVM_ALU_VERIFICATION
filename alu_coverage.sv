`uvm_analysis_imp_decl(_pass_mon_cg)
`uvm_analysis_imp_decl(_act_mon_cg)

class alu_coverage extends uvm_component;
  `uvm_component_utils(alu_coverage)
  uvm_analysis_imp_act_mon_cg #(alu_sequence_item, alu_coverage) aport_mon1;
  uvm_analysis_imp_pass_mon_cg #(alu_sequence_item, alu_coverage) aport_mon2;
  alu_sequence_item mon1_trans, mon2_trans;
  real mon1_cov, mon2_cov;
  
  virtual alu_interface vif;
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual alu_interface)::get(this, "", "vif", vif)) begin
      `uvm_info(get_type_name(), "vif not set in config_db for coverage yet — will try again later", UVM_LOW)
      `uvm_fatal(get_type_name(), "vif not set for alu_coverage");
    end
  endfunction
    
  
  covergroup active_mon_cov;
    MODE : coverpoint mon1_trans.mode{bins mode_bin[]= {0,1}; }
    CMD : coverpoint mon1_trans.cmd{bins cmd_bin[] ={[0:13]}; }
    CIN : coverpoint mon1_trans.cin { bins cin_bin[] = {0,1}; }
    INP_VALID : coverpoint mon1_trans.inp_valid { bins inp_valid_bin[] = {2'b00, 2'b01, 2'b10, 2'b11}; }
    //OPA : coverpoint drv_trans.opa;
    //OPB : coverpoint drv_trans.opb;
    RST : coverpoint vif.reset{ bins rst_bin[] = {0}; }
    CE : coverpoint mon1_trans.ce { bins ce_bin[] = {0,1}; }

    CMD_X_INP_VALID  : cross CMD, INP_VALID;
  endgroup
  
  covergroup pass_monitor_cov;
    //RES : coverpoint mon_trans.res;
    ERR : coverpoint mon2_trans.err{ bins err_bin[]  = {0,1}; }
    OFLOW :coverpoint mon2_trans.oflow{bins of_bin[] = {0,1}; }
    COUT : coverpoint mon2_trans.cout{bins cout_bin[] = {0,1}; }
    G : coverpoint mon2_trans.g { bins g_bin[] = {0,1}; }
    L : coverpoint mon2_trans.l { bins l_bin[] = {0,1}; }
    E : coverpoint mon2_trans.e { bins e_bin[] = {0,1}; }
  endgroup
  
  
  
  function new(string name = "", uvm_component parent);
    super.new(name, parent);
    pass_monitor_cov = new;
    active_mon_cov = new;
    aport_mon1=new("aport_mon1", this);
    aport_mon2 = new("aport_mon2", this);
  endfunction
  
  function void write_act_mon_cg(alu_sequence_item t);
    if(t==null) begin
      `uvm_warning(get_type_name(), "Coverage got NULL transaction, skipping");
      return;
    end
    mon1_trans = t;
    active_mon_cov.sample();
    //`uvm_info(get_type_name(), $sformatf("[input] cmd=%0d mode=%0d cin=%0d ce=%0b inp_valid=%0b",mon1_trans.cmd,mon1_trans.mode,mon1_trans.cin,mon1_trans.ce,mon1_trans.inp_valid),UVM_MEDIUM)
  endfunction
  
  function void write_pass_mon_cg(alu_sequence_item t);
    mon2_trans = t;
    pass_monitor_cov.sample();
   //`uvm_info(get_type_name(), $sformatf("[MONITOR] res=%0d err=%0b oflow=%0b cout=%0b g=%0b l=%0b e=%0b",mon2_trans.res,mon2_trans.err,mon2_trans.oflow,mon2_trans.cout,mon2_trans.g,mon2_trans.l, mon2_trans.e),UVM_MEDIUM)
  endfunction
  
  function void extract_phase(uvm_phase phase);
    super.extract_phase(phase);
    mon1_cov = active_mon_cov.get_coverage();
    mon2_cov = pass_monitor_cov.get_coverage();
  endfunction

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_type_name(), $sformatf("[input] Coverage ------> %0.2f%%,", mon1_cov), UVM_LOW);
    `uvm_info(get_type_name(), $sformatf("[output] Coverage ------> %0.2f%%", mon2_cov), UVM_LOW);
  endfunction

endclass
