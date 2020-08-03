
package apb_package;

// Import the UVM class library  and UVM automation macros
import uvm_pkg::*;
`include "uvm_macros.svh"

`include "apb_config.sv"
`include "apb_types.sv"
`include "apb_transfer.sv"
`include "apb_monitor.sv"
`include "apb_collector.sv"

`include "apb_master_driver.sv"
`include "apb_master_sequencer.sv"
`include "apb_master_agent.sv"

`include "apb_slave_driver.sv"
`include "apb_slave_sequencer.sv"
`include "apb_slave_agent.sv"

`include "apb_master_seq_lib.sv"
`include "apb_slave_seq_lib.sv"

`include "apb_env.sv"

`include "reg_to_apb_adapter.sv"

endpackage : apb_package
