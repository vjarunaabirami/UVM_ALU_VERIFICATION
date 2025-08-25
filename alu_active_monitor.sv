class alu_active_monitor extends uvm_monitor;

  `uvm_component_utils(alu_active_monitor)

  virtual alu_interface vif;
  
  uvm_analysis_port #(alu_sequence_item) ap;
 alu_sequence_item temp; 
 
  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual alu_interface)::get(this, "", "vif", vif))
      `uvm_fatal("NO_VIF", {"virtual interface must be set for: ",get_full_name(), "vif"});
  endfunction

  virtual task run_phase(uvm_phase phase);
    alu_sequence_item seq;
    forever begin
      repeat(2) @(vif.mon_cb);
      if (!vif.reset) begin
        seq = alu_sequence_item::type_id::create("tr", this);  
        seq.opa       = vif.opa;
        seq.opb       = vif.opb;
        seq.cin       = vif.cin;
        seq.cmd       = vif.cmd;
        seq.mode      = vif.mode;
        seq.ce        = vif.ce;
        seq.inp_valid = vif.inp_valid;
        `uvm_info(get_type_name(), $sformatf("Active monitor captured input: opa=%0h opb=%0h cmd=%0d mode=%0d cin=%0d inp_valid=%0d", seq.opa, seq.opb, seq.cmd, seq.mode, seq.cin, seq.inp_valid), UVM_LOW);
       // repeat(1) @(vif.mon_cb);
          $cast(temp,seq.clone());
          ap.write(seq);
          
       
        
      end
    end
  endtask
endclass
