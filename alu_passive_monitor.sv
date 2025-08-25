class alu_passive_monitor extends uvm_monitor;

  `uvm_component_utils(alu_passive_monitor)
  
  virtual alu_interface vif;
  
  uvm_analysis_port #(alu_sequence_item) ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual alu_interface)::get(this, "", "vif", vif))
      $display("hell ");
      //`uvm_fatal(("NO_VIF"); {"Virtual interface must be set for: ",get_full_name(), ".vif"});
  endfunction

  task run_phase(uvm_phase phase);
    alu_sequence_item seq;
    alu_sequence_item temp;
    
    repeat(1) @(vif.mon_cb);
    forever begin
      
      
      seq = alu_sequence_item::type_id::create("seq", this);
      
//       wait( (((vif.inp_valid inside {3,0}) && (vif.mode == 0) && (vif.cmd inside {0,1,2,3,4,5,12,13})) || ((vif.inp_valid inside {3,0}) && (vif.mode == 1) && (vif.cmd inside { 0,1,2,3,8,9,10})) || ((vif.inp_valid inside {1,2}) && (vif.mode == 0) && (vif.cmd inside {[6:11]})) || ((vif.inp_valid inside {1,2}) && (vif.mode == 1) && (vif.cmd inside {[4:7]})))) ) begin
        
        if (vif.cmd inside {[9:10]} && vif.mode == 1 )
          repeat(3) @(vif.mon_cb);
          else begin
            repeat(2) @(vif.mon_cb);
          end
        
        seq.inp_valid = vif.inp_valid;
		seq.mode      = vif.mode;
		seq.cmd       = vif.cmd;
		seq.opa       = vif.opa;
		seq.opb       = vif.opb;
		seq.cin       = vif.cin;
		seq.ce        = vif.ce;
        
        seq.res = vif.res;
        seq.cout  = vif.cout;
        seq.oflow = vif.oflow;
        seq.g     = vif.g;
        seq.e     = vif.e;
        seq.l     = vif.l;
        seq.err   = vif.err;
        
        ap.write(seq);
        
        
        `uvm_info("MONITOR", $sformatf( "[MONITOR] Time=%0t: res=%0h cout=%0b oflow=%0b g=%0b e=%0b l=%0b err=%0b", $time, seq.res, seq.cout, seq.oflow, seq.g, seq.e, seq.l, seq.err), UVM_LOW);
       // repeat(1) @(vif.mon_cb);
        
//       end
    end
  endtask
endclass
k
