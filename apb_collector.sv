
//------------------------------------------------------------------------------
// CLASS: apb_collector
//------------------------------------------------------------------------------

class apb_collector extends uvm_component;

  // The virtual interface used to view HDL signals.
  virtual apb_if vif;

  // APB configuration information
  apb_config cfg;

  // Property indicating the number of transactions occuring on the apb.
  protected int unsigned num_transactions = 0;

  // The following two bits are used to control whether checks and coverage are
  // done both in the collector class and the interface.
  bit checks_enable = 1; 
  bit coverage_enable = 1;

  // TLM Ports - transfer collected for monitor other components
  uvm_analysis_port #(apb_transfer) item_collected_port;

  // TLM Port - Allows sequencer access to transfer during address phase
  uvm_blocking_peek_imp#(apb_transfer,apb_collector) addr_trans_export;
  event addr_trans_grabbed;

  // The following property holds the transaction information currently
  // being captured (by the collect_address_phase and data_phase methods). 
  apb_transfer trans_collected;

  //Adding pseudo-memory leakage for heap analysis lab
  `ifdef HEAP
  static apb_transfer runq[$];
  `endif

  // Provide implementations of virtual methods such as get_type_name and create
  `uvm_component_utils_begin(apb_collector)
    `uvm_field_object(cfg, UVM_DEFAULT|UVM_REFERENCE)
    `uvm_field_int(checks_enable, UVM_DEFAULT)
    `uvm_field_int(coverage_enable, UVM_DEFAULT)
    `uvm_field_int(num_transactions, UVM_DEFAULT)
  `uvm_component_utils_end

  // new - constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
    trans_collected = apb_transfer::type_id::create("trans_collected");
    // TLM ports are created here
    item_collected_port = new("item_collected_port", this);
    addr_trans_export = new("addr_trans_export", this);
  endfunction : new

  // Additional class methods
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern virtual protected task collect_transactions();
  extern task peek(output apb_transfer trans);
  extern virtual function void report_phase(uvm_phase phase);

endclass : apb_collector

// UVM build_phase
function void apb_collector::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (cfg == null)
      if (!uvm_config_db#(apb_config)::get(this, "", "cfg", cfg))
      `uvm_error("NOCONFIG", "apb_config not set for this component")
endfunction : build_phase

// UVM connect_phase
function void apb_collector::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif))
      `uvm_error("NOVIF", {"virtual interface must be set for: ", get_full_name(), ".vif"})
endfunction : connect_phase


// UVM run_phase()
task apb_collector::run_phase(uvm_phase phase);
    @(posedge vif.preset);
    `uvm_info(get_type_name(), "Detected Reset Done", UVM_LOW)
    collect_transactions();
endtask : run_phase

// collect_transactions
task apb_collector::collect_transactions();
  forever begin
    @(posedge vif.pclock iff (vif.psel != 0));
    void'(this.begin_tr(trans_collected,"APB_COLLECTOR","UVM Debug","APB collector transaction inside collect_transactions()"));
    trans_collected.addr = vif.paddr;
    trans_collected.master = cfg.master_config.name;
    trans_collected.slave = cfg.get_slave_name_by_addr(trans_collected.addr);
    case (vif.prwd)
      1'b0 : trans_collected.direction = APB_READ;
      1'b1 : trans_collected.direction = APB_WRITE;
    endcase
      @(posedge vif.pclock);
    if(trans_collected.direction == APB_READ)
      trans_collected.data = vif.prdata;
    if (trans_collected.direction == APB_WRITE)
      trans_collected.data = vif.pwdata;
    -> addr_trans_grabbed;
    @(posedge vif.pclock);
    if(trans_collected.direction == APB_READ) begin
        if(vif.pready != 1'b1)
          @(posedge vif.pclock);
      trans_collected.data = vif.prdata;
      end
    this.end_tr(trans_collected);
    item_collected_port.write(trans_collected);
    `uvm_info(get_type_name(), $sformatf("Transfer collected :\n%s",
              trans_collected.sprint()), UVM_MEDIUM)
      `ifdef HEAP
      runq.push_back(trans_collected);
      `endif
     num_transactions++;
    end
endtask : collect_transactions

task apb_collector::peek(output apb_transfer trans);
  @addr_trans_grabbed;
  trans = trans_collected;
endtask : peek

function void apb_collector::report_phase(uvm_phase phase);
  `uvm_info(get_type_name(), $sformatf("Report: APB collector collected %0d transfers", num_transactions), UVM_LOW);
endfunction : report_phase
