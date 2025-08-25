`uvm_analysis_imp_decl(_act_mon)
`uvm_analysis_imp_decl(_pass_mon)

class alu_scoreboard extends uvm_scoreboard;
   
  `uvm_component_utils(alu_scoreboard)
  uvm_analysis_imp_act_mon #(alu_sequence_item, alu_scoreboard) mon1_imp;
  uvm_analysis_imp_pass_mon #(alu_sequence_item, alu_scoreboard) mon2_imp;
  
  logic [8:0] store;
  logic g, e, l, oflow, cout;
  localparam bits_req = $clog2(`WIDTH);
  
   
  virtual alu_interface vif;

  alu_sequence_item expected_q[$];
  alu_sequence_item actual_q[$];
  
  function new(string name="alu_scoreboard", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon1_imp = new("mon1_imp", this);
    mon2_imp = new("mon2_imp", this);
    if (!uvm_config_db#(virtual alu_interface)::get(this, "", "vif", vif)) begin
    `uvm_fatal("NOVIF", "Virtual interface not set for scoreboard")
    end
  endfunction
  
  function void write_act_mon(alu_sequence_item inp_seq);
    fork
      ref_model(inp_seq);
    join_none
  endfunction
  
  function void write_pass_mon(alu_sequence_item actual_res);
    alu_sequence_item temp;
    actual_q.push_back(actual_res);
    $display("THE RES IN ACTUAL THNG S %0d",actual_res.res);
   // temp = actual_q.pop_front();
    //$display("THE RES IN ACTUAL THNG S %0d",temp.res);
//    compare();
  endfunction
  
  task run_phase(uvm_phase phase);
    forever begin
      @(posedge vif.clk);
      compare();
    end
  endtask
  
  task automatic ref_model(alu_sequence_item ip);
    bit is_mul = 0;
    bit [bits_req-1:0] shift_val;
  
    alu_sequence_item exp = alu_sequence_item::type_id::create("exp");
    exp.copy(ip);
    exp.res = 'z;
    exp.cout = 'z;
    exp.oflow = 'z;
    exp.err = 'z;
    exp.g = 'z;
    exp.l = 'z;
    exp.e = 'z;
    
    if(vif.reset) begin
      store = 0;
      g = 0;
      e = 0;
      l = 0;
      oflow = 0;
      cout = 0;
      
      exp.res = '0;
      exp.cout = '0;
      exp.oflow = '0;
      exp.err = '0;
      exp.g = '0;
      exp.l = '0;
      exp.e = '0;
      
      expected_q.push_back(exp);
      compare();
      return;
    end
    
    if((ip.mode == 1 && !(ip.cmd inside {0,1,2,3,4,5,6,7,8,9,10})) || (ip.mode==0 && !(ip.cmd inside {0,1,2,3,4,5,6,7,8,9,10,11,12,13})) ) begin
      exp.err = 1;
      expected_q.push_back(exp);
      compare();
      return;
    end
    
    if(ip.ce == 0) begin
      exp.res = store;
      exp.g = g;
      exp.l = l;
      exp.e = e;
      exp.oflow = oflow;
      exp.cout = cout;
      exp.err = 0;
      expected_q.push_back(exp);
      compare();
      return;
    end
    
    if(need_oprd(ip.mode, ip.cmd) && (ip.inp_valid!=2'b00 && ip.inp_valid!=2'b11) ) begin
      bit got = 0;
      repeat(16) @(posedge vif.clk) begin
        if(vif.inp_valid == 2'b11) begin
          exp.opa = vif.opa;
          exp.opb = vif.opb;
          exp.cin = vif.cin;
          got = 1;
          break;
        end
      end
      if(!got) begin
        exp.err = 1;
        expected_q.push_back(exp);
        compare();
        return;
      end
    end
    
    is_mul = 0;
    shift_val[bits_req-1:0]  = exp.opb[bits_req-1:0];
    
    if(exp.mode) begin //mode ==1
      case(exp.inp_valid)
        2'b01: begin
          case(exp.cmd)
            4'd4: exp.res = exp.opa + 1;
            4'd5: exp.res = exp.opa - 1;
            default : exp.res = 'z;
          endcase
        end
        2'b10: begin
          case(exp.cmd)
            4'd6: exp.res = exp.opb + 1;
            4'd7: exp.res = exp.opb - 1;
            default : exp.res = 'z;
          endcase
        end
        2'b11: begin
          case(exp.cmd)
            4'd4: exp.res = exp.opa + 1;
            4'd5: exp.res = exp.opa - 1;
            4'd6: exp.res = exp.opb + 1;
            4'd7: exp.res = exp.opb - 1;
            
            4'd0: begin //add
              logic [8:0] tmp = exp.opa + exp.opb;
              exp.res  = tmp[7:0];
              exp.cout = tmp[8];
            end

            4'd1: begin  //sub
              logic [8:0] tmp = {1'b0, exp.opa} - {1'b0, exp.opb};
              exp.res  = tmp[7:0];
              exp.cout = (exp.opa < exp.opb); 
            end

            4'd2: begin // add + cin
              logic [8:0] tmp = exp.opa + exp.opb + exp.cin;
              exp.res  = tmp[7:0];
              exp.cout = tmp[8];
            end

            4'd3: begin // sub - cin
              logic [8:0] tmp = {1'b0, exp.opa} - ({1'b0, exp.opb} + exp.cin);
              exp.res  = tmp[7:0];
              exp.cout = (exp.opa >= (exp.opb + exp.cin));
            end

            4'd8: begin // compare
              exp.res = 'z;
              if (exp.opa > exp.opb) begin 
                exp.g = 1; 
                exp.e = 'z; 
                exp.l = 'z; 
              end
              else if (exp.opa < exp.opb) begin 
                exp.l = 1; 
                exp.g = 'z; 
                exp.e = 'z; 
              end
              else begin 
                exp.e = 1; 
                exp.g = 'z; 
                exp.l = 'z; 
              end
            end

            4'd9: begin //mult
              exp.res = (exp.opa + 1) * (exp.opb + 1);
              is_mul = 1;
            end

            4'd10: begin //mult
              exp.res = (exp.opa << 1) * exp.opb;
              is_mul = 1;
            end

            default: ;
          endcase
        end

        2'b00: begin
          // err=1 & replay previous store/flags
          exp.err = 1;
          exp.res = store; 
          exp.g = g; 
          exp.e = e; 
          exp.l = l;
        end
        default: ;
      endcase
    end
    
    else begin //mode = 0
      case(exp.inp_valid)
        2'b01: begin
          case(exp.cmd)
            4'd6: exp.res = {1'b0, ~exp.opa};
            4'd8: exp.res = {1'b0, exp.opa >> 1};
            4'd9: exp.res = {1'b0, exp.opa << 1};
            default: ;
          endcase
        end
        2'b10: begin
          case(exp.cmd)
            4'd7:  exp.res = {1'b0, ~exp.opb};
            4'd10: exp.res = {1'b0, exp.opb >> 1};
            4'd11: exp.res = {1'b0, exp.opb << 1};
            default: ;
          endcase
        end
        2'b11: begin
          case(exp.cmd)
            4'd6:  exp.res = {1'b0, ~exp.opa};
            4'd8:  exp.res = {1'b0, exp.opa >> 1};
            4'd9:  exp.res = {1'b0, exp.opa << 1};
            4'd7:  exp.res = {1'b0, ~exp.opb};
            4'd10: exp.res = {1'b0, exp.opb >> 1};
            4'd11: exp.res = {1'b0, exp.opb << 1};

            4'd0:  exp.res = {1'b0, exp.opa &  exp.opb};
            4'd1:  exp.res = {1'b0, ~(exp.opa &  exp.opb)};
            4'd2:  exp.res = {1'b0, (exp.opa |  exp.opb)};
            4'd3:  exp.res = {1'b0, ~(exp.opa |  exp.opb)};
            4'd4:  exp.res = {1'b0, (exp.opa ^  exp.opb)};
            4'd5:  exp.res = {1'b0, ~(exp.opa ^  exp.opb)};

            4'd12: begin // ROL 
              if (|exp.opb[`WIDTH-1:bits_req]) begin
                exp.err = 1; 
                exp.res = 0;
              end 
              else begin
                exp.res = {1'b0, (exp.opa << shift_val) |(exp.opa >> (`WIDTH - shift_val))};
              end
            end

            4'd13: begin // ROR 
              if (|exp.opb[`WIDTH-1:bits_req]) begin
                exp.err = 1; 
                exp.res = 0;
              end 
              else begin
                exp.res = {1'b0, (exp.opa >> shift_val) | (exp.opa << (`WIDTH - shift_val))};
              end
            end
            default: ;
          endcase
        end
        
        2'b00: begin
          exp.err = 1;
          exp.res = store; 
          exp.g = g; 
          exp.e = e; 
          exp.l = l;
          exp.oflow = oflow; 
          exp.cout = cout;
        end
        default: ;
      endcase
    end
    
    
    if(is_mul)
      repeat(2) @(posedge vif.clk);
    else
      repeat(1) @(posedge vif.clk);
    
    store = exp.res;
    g = exp.g;
    e = exp.e;
    l = exp.l;
    if(exp.cout != 'z) 
      cout = exp.cout;
    if(exp.oflow != 'z)
      oflow = exp.oflow;
    
    if(exp.mode && exp.cmd!=4'd8) begin
       exp.e = 'z; 
       exp.g = 'z; 
       exp.l = 'z;
    end
    
    expected_q.push_back(exp);
    //compare();  
  endtask
  
  function need_oprd(bit mode, bit [3:0] cmd);
    return ( mode && (cmd inside {0,1,2,3,8,9,10}) ) || (!mode && (cmd inside {0,1,2,3,4,5,12,13}));
  endfunction
  
  task compare();
    alu_sequence_item exp;
    alu_sequence_item act;
    bit pass;
    
    wait (expected_q.size()>0 && actual_q.size()>0) begin
      $display("THE SIZE OF ACTUAL PT S %0D AT %T",actual_q.size(),$time());
      $display("ENTERED COMPASRISON");
      
      exp = expected_q.pop_front();
      act = actual_q.pop_front();
    
      $display("THE RES DURNG COMB IS %0D ",act.res);
      $display("THE RES DURNG COMB IS %0D ",exp.res);
      pass = (exp.res === act.res) && (exp.err === act.err)   && (exp.oflow === act.oflow) && (exp.cout === act.cout)  && (exp.g === act.g) && (exp.e === act.e) && (exp.l === act.l);
      if (!pass) begin
        `uvm_error(get_type_name(),$sformatf("\nMISMATCH\nEXP:\n%s\nACT:\n%s", exp.sprint(), act.sprint()))
      end 
      else begin
        `uvm_info(get_type_name(), "Match", UVM_LOW)
      end
    end
  endtask
    
endclass
