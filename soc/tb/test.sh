make -C .. build/top.v;
cp ../build/*.init .;
iverilog ../build/top.v s27kl0641.v tb.v;
./a.out;
