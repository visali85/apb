

`include "demo_config.sv"

// uvm_default_factory extends uvm_factory
class my_factory extends uvm_default_factory;

  virtual function void register(uvm_object_wrapper obj);
    `uvm_info("REGISTER",
      $sformatf("%s", obj.get_type_name()), UVM_LOW);
    super.register(obj);
  endfunction

  /**
   * Check whether all type overrides have been used.
   */
  function bit all_type_overrides_used();
    foreach(m_type_overrides[i]) begin
      if (m_type_overrides[i].used == 0) begin
        return 0;
      end
    end
    return 1;
  endfunction

endclass


class my_coreservice extends uvm_default_coreservice_t;

  local my_factory factory;

  virtual function uvm_factory get_factory();
    if (factory == null) begin
      factory = new();
    end
    return factory;
  endfunction

endclass

//------------------------------------------------------------------------------
// CLASS: apb_env
//------------------------------------------------------------------------------q

class apb_env extends uvm_env;

  // Virtual interface for this environment. This should only be done if the
  // same interface is used for all masters/slaves in the environment. Otherwise,
  // Each agent should have its interface independently set.
  protected virtual interface apb_if vif;

  // Environment Configuration Parameters
  apb_config cfg;     // APB configuration object

  // The following two bits are used to control whether checks and coverage are
  // done both in the bus monitor class and the interface.
  bit checks_enable = 1; 
  bit coverage_enable = 1;

  // Components of the environment
  apb_monitor bus_monitor;
  apb_collector bus_collector;
  apb_master_agent master;
  apb_slave_agent slaves[];

  // Provide implementations of virtual methods such as get_type_name and create
  `uvm_component_utils_begin(apb_env)
    `uvm_field_object(cfg, UVM_DEFAULT)
    `uvm_field_int(checks_enable, UVM_DEFAULT)
    `uvm_field_int(coverage_enable, UVM_DEFAULT)
  `uvm_component_utils_end

  // Constructor - Required UVM syntax
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // Additional class methods
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
  extern virtual function void start_of_simulation_phase(uvm_phase phase);
  extern virtual function void update_config(apb_config cfg);
  extern virtual task run_phase(uvm_phase phase);
  extern virtual task update_vif_enables();

endclass : apb_env

// UVM build_phase
function void apb_env::build_phase(uvm_phase phase);
  super.build_phase(phase);
   //uvm_coreservice_t coreservice = uvm_coreservice_t :: get();
   // uvm_factory factory = coreservice.get_factory();
  // Create the APB UVC configuration class if it has not been set
  if(cfg == null) //begin
    if (!uvm_config_db#(apb_config)::get(this, "", "cfg", cfg)) begin
    `uvm_info("NOCONFIG", "Using default_apb_config", UVM_MEDIUM)
	cfg = default_apb_config :: type_id :: create();
     //$cast(cfg, factory.create_object_by_name("default_apb_config","cfg"));

  end
  // set the master config
  uvm_config_object::set(this, "*", "cfg", cfg); 
  // set the slave configs
  foreach(cfg.slave_configs[i]) begin
    string sname;
    sname = $sformatf("slave[%0d]*", i); 
    uvm_config_object::set(this, sname, "cfg", cfg.slave_configs[i]);
  end

  bus_monitor = apb_monitor::type_id::create("bus_monitor",this);
  bus_collector = apb_collector::type_id::create("bus_collector",this);
  master = apb_master_agent::type_id::create(cfg.master_config.name,this);
  slaves = new[cfg.slave_configs.size()];
  for(int i = 0; i < cfg.slave_configs.size(); i++) begin
    slaves[i] = apb_slave_agent::type_id::create($sformatf("slave[%0d]", i), this);
  end

endfunction : build_phase

// UVM connect_phase
function void apb_env::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  // Get the virtual interface if set via get_config
  if (!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif))
    `uvm_error("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
  bus_collector.item_collected_port.connect(bus_monitor.coll_mon_port);
  bus_monitor.addr_trans_port.connect(bus_collector.addr_trans_export);
  master.monitor = bus_monitor;
  master.collector = bus_collector;
  foreach(slaves[i]) begin
    slaves[i].monitor = bus_monitor;
    slaves[i].collector = bus_collector;
    if (slaves[i].is_active == UVM_ACTIVE)
      slaves[i].sequencer.addr_trans_port.connect(bus_monitor.addr_trans_export);
  end
endfunction : connect_phase

// UVM start_of_simulation_phase
function void apb_env::start_of_simulation_phase(uvm_phase phase);
  set_report_id_action_hier("CFGOVR", UVM_DISPLAY);
  set_report_id_action_hier("CFGSET", UVM_DISPLAY);
  check_config_usage();
endfunction : start_of_simulation_phase

// update_config() method
function void apb_env::update_config(apb_config cfg);
  bus_monitor.cfg = cfg;
  bus_collector.cfg = cfg;
  master.update_config(cfg);
  foreach(slaves[i])
    slaves[i].update_config(cfg.slave_configs[i]);
endfunction : update_config

// update_vif_enables
task apb_env::update_vif_enables();
  vif.has_checks <= checks_enable;
  vif.has_coverage <= coverage_enable;
  forever begin
    @(checks_enable || coverage_enable);
    vif.has_checks <= checks_enable;
    vif.has_coverage <= coverage_enable;
  end
endtask : update_vif_enables

//UVM run_phase()
task apb_env::run_phase(uvm_phase phase);
  fork
    update_vif_enables();
  join
endtask : run_phase

