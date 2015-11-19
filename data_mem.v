module data_mem(
    //data inputs
    input [63:0] datIn,
    input [63:0] addr,
    input clk,

    //control input
    input [1:0] control, //says whether ld or st
    input arbiter, //arbiter says selected for wb

    //data output
    output reg [63:0] datOut,


    //ready
    output ready,

    //output mem for testbench
    output [64*64 -1:0] tb_mem
);

  reg [31:0] i;
  reg [63:0] DMemory [0:1023];

  //Parameters for reading input file
  integer fd,code, fd_out;
  reg [63:0] str;

  //assign tb_mem
  assign tb_mem [63:0] =      DMemory[0];
  assign tb_mem [127:64] =    DMemory[1];
  assign tb_mem [191:128] =   DMemory[2];
  assign tb_mem [255:192] =   DMemory[3];
  assign tb_mem [319:256] =   DMemory[4];
  assign tb_mem [383:320] =   DMemory[5];
  assign tb_mem [447:384] =   DMemory[6];
  assign tb_mem [511:448] =   DMemory[7];
  assign tb_mem [575:512] =   DMemory[8];
  assign tb_mem [639:576] =   DMemory[9];
  assign tb_mem [703:640] =   DMemory[10];
  assign tb_mem [767:704] =   DMemory[11];
  assign tb_mem [831:768] =   DMemory[12];
  assign tb_mem [895:832] =   DMemory[13];
  assign tb_mem [959:896] =   DMemory[14];
  assign tb_mem [1023:960] =  DMemory[15];
  assign tb_mem [1087:1024] = DMemory[16];
  assign tb_mem [1151:1088] = DMemory[17];
  assign tb_mem [1215:1152] = DMemory[18];
  assign tb_mem [1279:1216] = DMemory[19];
  assign tb_mem [1343:1280] = DMemory[20];
  assign tb_mem [1407:1344] = DMemory[21];
  assign tb_mem [1471:1408] = DMemory[22];
  assign tb_mem [1535:1472] = DMemory[23];
  assign tb_mem [1599:1536] = DMemory[24];
  assign tb_mem [1663:1600] = DMemory[25];
  assign tb_mem [1727:1664] = DMemory[26];
  assign tb_mem [1791:1728] = DMemory[27];
  assign tb_mem [1855:1792] = DMemory[28];
  assign tb_mem [1919:1856] = DMemory[29];
  assign tb_mem [1983:1920] = DMemory[30];
  assign tb_mem [2047:1984] = DMemory[31];
  assign tb_mem [2111:2048] = DMemory[32];
  assign tb_mem [2175:2112] = DMemory[33];
  assign tb_mem [2239:2176] = DMemory[34];
  assign tb_mem [2303:2240] = DMemory[35];
  assign tb_mem [2367:2304] = DMemory[36];
  assign tb_mem [2431:2368] = DMemory[37];
  assign tb_mem [2495:2432] = DMemory[38];
  assign tb_mem [2559:2496] = DMemory[39];
  assign tb_mem [2623:2560] = DMemory[40];
  assign tb_mem [2687:2624] = DMemory[41];
  assign tb_mem [2751:2688] = DMemory[42];
  assign tb_mem [2815:2752] = DMemory[43];
  assign tb_mem [2879:2816] = DMemory[44];
  assign tb_mem [2943:2880] = DMemory[45];
  assign tb_mem [3007:2944] = DMemory[46];
  assign tb_mem [3071:3008] = DMemory[47];
  assign tb_mem [3135:3072] = DMemory[48];
  assign tb_mem [3199:3136] = DMemory[49];
  assign tb_mem [3263:3200] = DMemory[50];
  assign tb_mem [3327:3264] = DMemory[51];
  assign tb_mem [3392:3328] = DMemory[52];
  assign tb_mem [3455:3392] = DMemory[53];
  assign tb_mem [3519:3456] = DMemory[54];
  assign tb_mem [3583:3520] = DMemory[55];
  assign tb_mem [3647:3584] = DMemory[56];
  assign tb_mem [3711:3648] = DMemory[57];
  assign tb_mem [3775:3712] = DMemory[58];
  assign tb_mem [3839:3776] = DMemory[59];
  assign tb_mem [3903:3840] = DMemory[60];
  assign tb_mem [3967:3904] = DMemory[61];
  assign tb_mem [4031:3968] = DMemory[62];
  assign tb_mem [4095:4032] = DMemory[63];

  initial
  begin

    i=0;
    fd =$fopen("./mem.dat","r" ); //open memory file
    while(!$feof(fd))
    begin
       code = $fscanf(fd, "%b\n", str);
       DMemory[i] = str;
       i=i+1;
    end
    datOut = 0;
    $fclose(fd);

  end

  reg st;
  reg compute_wait;
  reg some_input;
  assign ready = ~compute_wait;

  initial
  begin
      compute_wait = 1;
  end

  always @(posedge clk)
  begin
      case(control)
        2'b00 :
                begin
                DMemory[addr] <= datIn; //store
                end
        2'b01 : begin
                  datOut <= DMemory[addr]; //load
                 end
        default : ; //branch, jumps, alu operations
      endcase
  end

  always @(control)
  begin
       case (control)
          2'b00 :
                 begin
                  st = 1;
                  some_input = 1;
                 end
          2'b01 :
                 begin
                   st = 0;
                   some_input = 1;
                 end
          default :
                  begin
                    st = 0;
                    some_input = 0;
                  end
       endcase
  end

  always @(posedge clk)
  begin
      // --- exec wait control
      if(compute_wait == 0)
      begin
         if(arbiter | st) compute_wait <= 1;
      end
      else if (compute_wait == 1)
      begin
        if (some_input) compute_wait <= compute_wait -1;
        else compute_wait <= 1;
      end
  end

endmodule
