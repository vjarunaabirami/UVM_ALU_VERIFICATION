class alu_driver extends uvm_driver #(alu_sequence_item);
  
  virtual alu_interface vif;
  
  `uvm_component_utils(alu_driver)
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual alu_interface)::get(this, "", "vif", vif))
       `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction
 
  virtual task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);
      $display("PACET GOT AT %0T",$time);
      drive();
      seq_item_port.item_done();
    end
  endtask 
  
  virtual task drive();
    repeat(1) @(vif.drv_cb);
    //for(int i=0; i < `no_of_trans; i++) begin
      req.mode.rand_mode(1);
      req.cmd.rand_mode(1);
      if(vif.reset==0) begin //reset == 0
      
        if(req.inp_valid == 2'b00 || req.inp_valid == 2'b11) begin
          drive_input();
          if (req.cmd inside {[9:10]} && req.mode == 1 )
            repeat(3) @(vif.drv_cb);
          else begin
            repeat(1) @(vif.drv_cb);
          end
          
        end
      
        else if(req.inp_valid == 2'b01 || req.inp_valid == 2'b10) begin 
          if(req.mode == 0) begin
            if(req.cmd inside {[6:11]}) begin 
              drive_input();
            end
            else begin 
              req.mode.rand_mode(0);
              req.cmd.rand_mode(0);
              for(int i=0;i<16;i++) begin 
                req.randomize();
                drive_input();
                if(req.inp_valid == 2'b11) begin 
                  break;
                end 
              end 
            end 
          end
     
          
          else begin  //mode == 1 (inp val == 01/10)
            if(req.cmd inside {4,6,7}) begin
              drive_input();
            end
            else if(req.cmd inside {9,10}) begin   
              repeat(2)@(vif.drv_cb);
              drive_input();                             
            end
            else begin
              req.mode.rand_mode(0);
              req.cmd.rand_mode(0);
              for(int i=0;i<16;i++) begin
                req.randomize();
                drive_input();
                if(req.inp_valid == 2'b11) begin
                  break;
                end
              end
            end
          end 
        end
      end
      else begin  //reset == 1
        vif.drv_cb.ce <= 0;
        vif.drv_cb.mode <= 0;
        vif.drv_cb.cmd <= 0;
        vif.drv_cb.cin <= 0;
        vif.drv_cb.inp_valid <= 0;
        vif.drv_cb.opa <= 0;
        vif.drv_cb.opb <= 0;
        drive_input();
      end
      //repeat(1) @(vif.drv_cb);
    //end
  endtask
  task drive_input();
    vif.drv_cb.ce <= req.ce;
    vif.drv_cb.mode <= req.mode;
    vif.drv_cb.cmd <= req.cmd;
    vif.drv_cb.cin <= req.cin;
    vif.drv_cb.inp_valid <= req.inp_valid;
    vif.drv_cb.opa <= req.opa;
    vif.drv_cb.opb <= req.opb;
    `uvm_info("DRIVER", $sformatf("Driving DUT: opa=%0h opb=%0h cmd=%0d mode=%0d inp_valid=%0b ce=%0b",  vif.drv_cb.opa, vif.drv_cb.opb, vif.drv_cb.cmd, vif.drv_cb.mode, vif.drv_cb.inp_valid, vif.drv_cb.ce), UVM_LOW)
  endtask
endclass
