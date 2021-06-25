# Simulation
To perform a full simulation from this repository, the following steps have to be taken.

## Train software model
From the [software](software) directory, run
```
python3 nn.py
```
This generates the file `bnn_weights.txt` in the [hardware](hardware) directory.

## Generate top-level VHDL
From the [script](hardware/script) directory, run
```
python3 generate_top_level.py
```
This generates the file `top.vhdl` in the [src](hardware/src) directory.

## Generate test data
From the [sim](hardware/sim) directory, run
```
python3 generate_testdata.py
```
This generates the file `testdata.txt` in the same directory.

## Run simulation
For convenience, a Makefile is used for the remaining commands. Still from the [sim](hardware/sim) directory, run
```
make sim
```
This will load the design into Vivado and run the `sim.tcl` script, printing the results to the output.
