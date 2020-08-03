
//------------------------------------------------------------------------------
// CLASS: apb_transfer declaration
//------------------------------------------------------------------------------

class apb_transfer extends uvm_sequence_item;                                  

  rand bit [31:0]           addr;
  rand apb_direction_enum   direction;
  rand bit [31:0]           data;
  rand int unsigned         delay = 0;
  string                    master = "";
  string                    slave = "";
   
  constraint c_direction { direction inside { APB_READ, APB_WRITE }; }
 
  constraint c_delay { delay <= 10 ; }

  `uvm_object_utils_begin(apb_transfer)
    `uvm_field_int(addr, UVM_DEFAULT)
    `uvm_field_enum(apb_direction_enum, direction, UVM_DEFAULT)
    `uvm_field_int(data, UVM_DEFAULT)
    `uvm_field_string(master, UVM_DEFAULT|UVM_NOCOMPARE)
    `uvm_field_string(slave, UVM_DEFAULT|UVM_NOCOMPARE)
  `uvm_object_utils_end

  function new (string name = "apb_transfer");
    super.new(name);
  endfunction

endclass : apb_transfer
