//the memory unit
module mem_order(

    input clk,
    input CTRL_addtag,
    input [4:0] ready, //1-hot representation of ready spots 
    input [64*5 - 1 : 0 ] address_bus, //addresses from the reservation stations
    input [3:0] tag,
    input remove,
    output reg [3:0] mem_tag
    );

  parameter notag = 0,
            add_1 = 1,
            add_2 = 2,
            add_3 = 3,
            mult_1 = 4,
            mult_2 = 5,
            ld_1 = 6,
            ld_2 = 7,
            ld_3 = 8,
            st_1 = 9,
            st_2 = 10;

// -------- function definitions ----
function [3:0] check_tag;
input  [3:0] tag;
//this module decides the next instruction that should go to
input [4:0] ready;
    case(tag)
        ld_1 :  check_tag = ready & 5'b10000;
        ld_2 :  check_tag = ready & 5'b01000;
        ld_3 :  check_tag = ready & 5'b00100;
        st_1 :  check_tag = ready & 5'b00010;
        st_2 :  check_tag = ready & 5'b00001;
        default : check_tag = 0;
    endcase
endfunction

function [63:0] get_address;
input [3:0] tag;
input [64*5 -1:0] address_bus;
    case(tag)
        st_1 : get_address =  address_bus[63:0];
        st_2 : get_address =  address_bus[127:64];
        ld_1 : get_address =  address_bus[191:128];
        ld_2 : get_address =  address_bus[255:192];
        ld_3 : get_address =  address_bus[319:256];
    endcase
endfunction
//----  end of function definitions ---

  

   reg [3:0] order [0:10] ; //an 8 input array

   reg [3:0] pos; //position from where to remove
   reg [3:0] head;
   reg [3:0] i;
   reg [3:0] j;

    //POS logic
    reg [3:0] tag_temp;
    reg [63:0] addr;
    reg [63:0] addr_temp;
    reg flag;

    initial
    begin
        head = 0;
        pos = 0;
        order[0] = 0;
        order[1] = 0;
        order[2] = 0;
        order[3] = 0;
        order[4] = 0;
        order[5] = 0;
        order[5] = 0;
        order[6] = 0;
        order[7] = 0;
        order[8] = 0;
        order[9] = 0;
        order[10] = 0;
    end

    always@(posedge clk)
    begin
       // -- logic to add and remove entries
       if (remove)
       begin
           if(CTRL_addtag)  //remove entry and add new one
           begin
                for (i=pos ; i<head ; i=i+1)
                begin
                   order[i] <= order[i+1];
                end
                order[head-1] <= tag ;
           end
           else
           begin
                for (i=pos ; i < head ; i=i+1) //just remove the entry
                begin
                     order[i] <= order[i+1];
                end
                head <= head - 1;
           end
       end
       else
       begin
           if(CTRL_addtag) //don't remove entry and add a new one
           begin
                order[head] <= tag ;
                head <= head + 1;
           end
           else ; //don't remove entry and don't add a new one
       end
    end

    always @(*)
    begin
          // -- logic decides what entry goes to mem
          // -- if found, set the pos
          mem_tag = notag;
          pos = 0;
          for(i=0; i < 10;  i=i+1)
          begin
                tag_temp = order[i];
                flag = 1;
                pos = 0;
                if(check_tag(tag_temp, ready)) //put check function here
                begin
                    addr = get_address(tag_temp, address_bus);
                    for(j=0; j < i; j=j+1)
                    begin
                         addr_temp = get_address(order[j], address_bus);
                         if(addr_temp ==  addr)
                              flag = 0;
                    end
                end
                if (flag == 1)
                begin
                   pos=i;
                   i=10; //like a break statement
                   mem_tag = tag_temp;
                end
          end
    end

endmodule
