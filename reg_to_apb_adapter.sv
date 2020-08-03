
class reg_to_apb_adapter extends uvm_reg_adapter;

`uvm_object_utils(reg_to_apb_adapter)

  function new(string name="reg_to_apb_adapter");
    super.new(name);
  endfunction : new

  function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    apb_transfer transfer;
    transfer = apb_transfer::type_id::create("transfer");
    transfer.addr = rw.addr;
    transfer.data = rw.data;
    transfer.direction = (rw.kind == UVM_READ) ? APB_READ : APB_WRITE;
    return (transfer);
  endfunction : reg2bus

  function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
    apb_transfer transfer;
    if (!$cast(transfer, bus_item)) begin
      `uvm_fatal("NOT_REG_TYPE",
       "Provided bus_item is not of the correct type. Expecting apb_transfer")
       return;
    end
    rw.kind =  (transfer.direction == APB_READ) ? UVM_READ : UVM_WRITE;
    rw.addr = transfer.addr;
    rw.data = transfer.data;
    //rw.byte_en = 'h0;   // Set this to -1 or DO NOT SET IT AT ALL - 
    rw.status = UVM_IS_OK;
  endfunction  : bus2reg

endclass : reg_to_apb_adapter
