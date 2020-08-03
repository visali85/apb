
//` include "apb_config.sv"

class demo_config extends apb_config;

  `uvm_object_utils(demo_config)

  function new(string name = "demo_config");
    super.new(name);
    add_slave("slave0", 32'h0000_0000, 32'hFFFF_FFFF, 0, UVM_ACTIVE);
    add_slave("slave1", 32'h0000_0000, 32'h7FFF_FFFF, 1, UVM_PASSIVE);
    add_master("master", UVM_ACTIVE);
  endfunction

endclass

class demo_048_config extends apb_config;

  `uvm_object_utils(demo_048_config)

  function new(string name = "demo_048_config");
    super.new(name);
    add_slave("slave0", 32'h0001_0000, 32'h7FFF_FFFF, 0, UVM_ACTIVE);
    add_slave("slave1", 32'h8000_0000, 32'hFFFF_FFFF, 4, UVM_ACTIVE);
    add_slave("slave2", 32'h0000_0000, 32'h0000_FFFF, 8, UVM_ACTIVE);
    //add_slave("slave0", 32'h0000_0000, 32'hFFFF_FFFF, 0, UVM_ACTIVE);
    //add_slave("slave1", 32'h0000_0000, 32'h7FFF_FFFF, 1, UVM_PASSIVE);
    add_master("master", UVM_ACTIVE);
  endfunction

endclass
