module ifetch( //instruction fetch

  //inputs
  input[63:0] PC,
  input clk,

  //output
  output [31:0] fetched_instruction,
  output reg [63:0] incrPC);

reg [31:0] i; //used to initialize registers
reg [31:0] IMemory[0:1023]; //instruction which need to be read from the memory

//Parameters for reading input file
integer fd,code;
reg [31:0] str;

initial //reading in the i memory contents from a file
begin
    i=0;
    fd =$fopen("./instructions.dat","r" ); //open instructions file
    while(!$feof(fd))
    begin
       code = $fscanf(fd, "%b\n", str);
       IMemory[i] = str;
       i=i+1;
    end
    $fclose(fd);
    incrPC = 64'b0_0100; //initialized to 4
    
end

//initial 
    //$monitor (" clk is %d Fetched instruction is %b ", clk, fetched_instruction);

assign fetched_instruction = IMemory[(PC[9:0])/4];

always @(*)
begin
    incrPC = PC + 64'b0_0100; //incremented PC
end

endmodule
