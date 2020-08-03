
//------------------------------------------------------------------------------
// CLASS: apb_master_agent
//------------------------------------------------------------------------------

class apb_master_agent extends uvm_agent;

  // This field determines whether an agent is active or passive.
  //uvm_active_passive_enum is_active = UVM_ACTIVE;

  // Configuration information: (master_config: name, is_active)
  apb_config cfg;

  apb_monitor   monitor;
  apb_collector collector;
  apb_master_sequencer sequencer;
  apb_master_driver    driver;

  // Provide implementations of virtual methods such as get_type_name and create
  `uvm_component_utils_begin(apb_master_agent)
    `uvm_field_object(monitor, UVM_DEFAULT | UVM_REFERENCE)
    `uvm_field_object(collector, UVM_DEFAULT | UVM_REFERENCE)
    `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_DEFAULT)
    `uvm_field_object(cfg, UVM_DEFAULT | UVM_REFERENCE)
  `uvm_component_utils_end

  // new - constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new
  
  // Additional class methods
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
  extern virtual function void update_config(input apb_config cfg);

endclass : apb_master_agent

// UVM build_phase
function void apb_master_agent::build_phase(uvm_phase phase);
  uvm_object config_obj;
  super.build_phase(phase);
  if (cfg == null) begin
    if (!uvm_config_db#(apb_config)::get(this, "", "cfg", cfg))
     `uvm_warning("NOCONFIG", 
          "Config not set for master agent, using default is_active field")
    end
  else is_active = cfg.master_config.is_active;
  
  if(is_active == UVM_ACTIVE) begin
    sequencer = apb_master_sequencer::type_id::create("sequencer",this);
    driver = apb_master_driver::type_id::create("driver",this);
  end
endfunction : build_phase

// UVM connect_phase
function void apb_master_agent::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  if (is_active == UVM_ACTIVE) begin
    // Connect the driver to the sequencer using TLM interface
    driver.seq_item_port.connect(sequencer.seq_item_export);
  end
endfunction : connect_phase

// update_config() 
function void apb_master_agent::update_config(input apb_config cfg);
  if (is_active == UVM_ACTIVE) begin
    sequencer.cfg = cfg;
    driver.cfg = cfg;
  end
endfunction : update_config
