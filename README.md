This is an incomplete behavioral implementation of the Tomasulo algorithm in verilog.
Your task is to add a reorder buffer to it in order to support speculation.

1. To compile the code, type ' iverilog *.v '

2. cp ./benchmarks/i1.dat instructions.dat
   cp ./benchmarks/m1.dat mem.dat
   Then type './a.out' to run the code.

3. The simulation information is dumped to tomasulo.vcd.
   You can access this vcd file using 'gtkwave' and observe any wire/reg in the processor
   over the course of the simulation. It is useful for debugging your code.

  Type 'gtkwave &' on the command line to open gtkwave window.
  Load the vcd file from File-> New Tab

4. The result of the simulation is dumped into regs_result.dat and mem_result.dat.
   This is used to evaluate the correctness of the simulation.
