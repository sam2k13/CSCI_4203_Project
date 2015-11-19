//This contains a testbench for the tomasulo algorithm ooo execution
module tb_tomasulo;

  //testbench breakout variables
  reg clk;
  wire [64*32 - 1:0] tb_regs;
  wire [64*64 -1:0] tb_mem;

  //dummy variables
  integer i;
  integer fd,code;
  reg [63:0] str;

  wire [63:0] tb_DMemory[0:63];
  wire [63:0] tb_Regs[0:31];


assign tb_DMemory[0] =                           tb_mem [63:0] ;
assign tb_DMemory[1] =                           tb_mem [127:64];
assign tb_DMemory[2] =                           tb_mem [191:128];
assign tb_DMemory[3] =                           tb_mem [255:192] ;
assign tb_DMemory[4] =                           tb_mem [319:256] ;
assign tb_DMemory[5] =                           tb_mem [383:320] ;
assign tb_DMemory[6] =                           tb_mem [447:384] ;
assign tb_DMemory[7] =                           tb_mem [511:448] ;
assign tb_DMemory[8] =                           tb_mem [575:512] ;
assign tb_DMemory[9] =                           tb_mem [639:576] ;
assign tb_DMemory[10] =                          tb_mem [703:640] ;
assign tb_DMemory[11] =                          tb_mem [767:704] ;
assign tb_DMemory[12] =                          tb_mem [831:768] ;
assign tb_DMemory[13] =                          tb_mem [895:832] ;
assign tb_DMemory[14] =                          tb_mem [959:896] ;
assign tb_DMemory[15] =                          tb_mem [1023:960] ;
assign tb_DMemory[16] =                          tb_mem [1087:1024] ;
assign tb_DMemory[17] =                          tb_mem [1151:1088] ;
assign tb_DMemory[18] =                          tb_mem [1215:1152] ;
assign tb_DMemory[19] =                          tb_mem [1279:1216] ;
assign tb_DMemory[20] =                          tb_mem [1343:1280] ;
assign tb_DMemory[21] =                          tb_mem [1407:1344] ;
assign tb_DMemory[22] =                          tb_mem [1471:1408] ;
assign tb_DMemory[23] =                          tb_mem [1535:1472] ;
assign tb_DMemory[24] =                          tb_mem [1599:1536] ;
assign tb_DMemory[25] =                          tb_mem [1663:1600] ;
assign tb_DMemory[26] =                          tb_mem [1727:1664] ;
assign tb_DMemory[27] =                          tb_mem [1791:1728] ;
assign tb_DMemory[28] =                          tb_mem [1855:1792] ;
assign tb_DMemory[29] =                          tb_mem [1919:1856] ;
assign tb_DMemory[30] =                          tb_mem [1983:1920] ;
assign tb_DMemory[31] =                          tb_mem [2047:1984] ;
assign tb_DMemory[32] =                          tb_mem [2111:2048] ;
assign tb_DMemory[33] =                          tb_mem [2175:2112] ;
assign tb_DMemory[34] =                          tb_mem [2239:2176] ;
assign tb_DMemory[35] =                          tb_mem [2303:2240] ;
assign tb_DMemory[36] =                          tb_mem [2367:2304] ;
assign tb_DMemory[37] =                          tb_mem [2431:2368] ;
assign tb_DMemory[38] =                          tb_mem [2495:2432] ;
assign tb_DMemory[39] =                          tb_mem [2559:2496] ;
assign tb_DMemory[40] =                          tb_mem [2623:2560] ;
assign tb_DMemory[41] =                          tb_mem [2687:2624] ;
assign tb_DMemory[42] =                          tb_mem [2751:2688] ;
assign tb_DMemory[43] =                          tb_mem [2815:2752] ;
assign tb_DMemory[44] =                          tb_mem [2879:2816] ;
assign tb_DMemory[45] =                          tb_mem [2943:2880] ;
assign tb_DMemory[46] =                          tb_mem [3007:2944] ;
assign tb_DMemory[47] =                          tb_mem [3071:3008] ;
assign tb_DMemory[48] =                          tb_mem [3135:3072] ;
assign tb_DMemory[49] =                          tb_mem [3199:3136] ;
assign tb_DMemory[50] =                          tb_mem [3263:3200] ;
assign tb_DMemory[51] =                          tb_mem [3327:3264] ;
assign tb_DMemory[52] =                          tb_mem [3392:3328];
assign tb_DMemory[53] =                          tb_mem [3455:3392];
assign tb_DMemory[54] =                          tb_mem [3519:3456];
assign tb_DMemory[55] =                          tb_mem [3583:3520];
assign tb_DMemory[56] =                          tb_mem [3647:3584];
assign tb_DMemory[57] =                          tb_mem [3711:3648];
assign tb_DMemory[58] =                          tb_mem [3775:3712];
assign tb_DMemory[59] =                          tb_mem [3839:3776];
assign tb_DMemory[60] =                          tb_mem [3903:3840];
assign tb_DMemory[61] =                          tb_mem [3967:3904];
assign tb_DMemory[62] =                          tb_mem [4031:3968];
assign tb_DMemory[63] =                          tb_mem [4095:4032];



assign tb_Regs[0] =                           tb_regs [63:0]  ;
assign tb_Regs[1] =                           tb_regs [127:64] ;
assign tb_Regs[2] =                           tb_regs [191:128];
assign tb_Regs[3] =                           tb_regs [255:192] ;
assign tb_Regs[4] =                           tb_regs [319:256] ;
assign tb_Regs[5] =                           tb_regs [383:320] ;
assign tb_Regs[6] =                           tb_regs [447:384] ;
assign tb_Regs[7] =                           tb_regs [511:448] ;
assign tb_Regs[8] =                           tb_regs [575:512] ;
assign tb_Regs[9] =                           tb_regs [639:576] ;
assign tb_Regs[10] =                          tb_regs [703:640] ;
assign tb_Regs[11] =                          tb_regs [767:704] ;
assign tb_Regs[12] =                          tb_regs [831:768] ;
assign tb_Regs[13] =                          tb_regs [895:832] ;
assign tb_Regs[14] =                          tb_regs [959:896] ;
assign tb_Regs[15] =                          tb_regs [1023:960] ;
assign tb_Regs[16] =                          tb_regs [1087:1024] ;
assign tb_Regs[17] =                          tb_regs [1151:1088] ;
assign tb_Regs[18] =                          tb_regs [1215:1152] ;
assign tb_Regs[19] =                          tb_regs [1279:1216] ;
assign tb_Regs[20] =                          tb_regs [1343:1280] ;
assign tb_Regs[21] =                          tb_regs [1407:1344] ;
assign tb_Regs[22] =                          tb_regs [1471:1408] ;
assign tb_Regs[23] =                          tb_regs [1535:1472] ;
assign tb_Regs[24] =                          tb_regs [1599:1536] ;
assign tb_Regs[25] =                          tb_regs [1663:1600] ;
assign tb_Regs[26] =                          tb_regs [1727:1664] ;
assign tb_Regs[27] =                          tb_regs [1791:1728] ;
assign tb_Regs[28] =                          tb_regs [1855:1792] ;
assign tb_Regs[29] =                          tb_regs [1919:1856] ;
assign tb_Regs[30] =                          tb_regs [1983:1920] ;
assign tb_Regs[31] =                          tb_regs [2047:1984] ;


  initial begin
    clk = 0;
    #400



  i=0;
  fd =$fopen("./mem_result.dat","w" ); //open memory result file
  while(i < 64)
  begin
     str = tb_DMemory[i]; //dump the tb memory values
     $fwrite(fd, "%b\n", str);
     i=i+1;
  end
  $fclose(fd);

  i=0;
  fd =$fopen("./regs_result.dat","w" ); //open register result file
  while(i < 32)
  begin
     str = tb_Regs[i];  //dump the tb register values
     $fwrite(fd, "%b\n", str);
     i=i+1;
  end
  $fclose(fd);

  $finish;

  end

  always
  begin

    #5;
    clk = ~clk;

  end

initial
begin

$dumpfile("tomasulo.vcd");  //optional VCD file dump
$dumpvars(0,tomasulo);

end





  tomasulo tomasulo(clk, tb_regs, tb_mem);

endmodule
