class c_1_1;
    rand bit[7:0] da; // rand_mode = ON 

    constraint tx_data_i_this    // (constraint_mode = ON) (../src/master_agent/master_xtn.sv:33)
    {
       (da inside {[1000:5000]});
    }
endclass

program p_1_1;
    c_1_1 obj;
    string randState;

    initial
        begin
            obj = new;
            randState = "x0xz1010xx1zz1x0x0x00xz0xx1x010zxzxxxxxzxzzzzxxzzxzxxzxzzzxxzzxx";
            obj.set_randstate(randState);
            obj.randomize();
        end
endprogram
