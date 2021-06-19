#!/usr/bin/python3
# Generate top-level NN entity from template
# Small top-level config for testing

from gen_funcs import *


with open("../src/top.vhdl.template", "r") as file:
    str = file.read()

weightsfp = open("../smalltb_weights_raw.txt", "r")

state = (str, 0, weightsfp)
state = gen_act_uthres_layer(state, 1, 8, 28, 123)
state = gen_conv_layer(state, 1, 1, 5, 28, 3, 3)
state = gen_pool_max_layer(state, 1, 5, 5, 26, 2, 2)
state = gen_act_layer(state, 1, 5, 13)
state = gen_fc_layer(state, 2, 14, 13, 13)
state = gen_arg_max_layer(state, 2, 14, 4) #count, inputwidth, outputwidth = 4 bits as count = 10

str = gen_output(state)

weightsfp.close()

with open("../src/top.vhdl", "w") as file:
    file.write(str)
