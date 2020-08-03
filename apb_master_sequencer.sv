
//------------------------------------------------------------------------------
// CLASS: apb_master_sequencer declaration
//------------------------------------------------------------------------------

class apb_master_sequencer extends uvm_sequencer #(apb_transfer);

  // Config in case it is needed by the sequencer
  apb_config cfg;

  bit tful;   //KATHLEEN _REMOVE THIS LATER
  // Provide implementations of virtual methods such as get_type_name and create
  `uvm_component_utils_begin(apb_master_sequencer)
    `uvm_field_object(cfg, UVM_DEFAULT|UVM_REFERENCE)
  `uvm_component_utils_end

  // Constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // UVM build_phase
  virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (cfg == null)
        if (!uvm_config_db#(apb_config)::get(this, "", "cfg", cfg))
        `uvm_warning("NOCONFIG", "apb_config not set for this component")
  endfunction : build_phase

endclass : apb_master_sequencer
