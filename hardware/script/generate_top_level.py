#!/usr/bin/python3
# Generate top-level NN entity from template

from gen_funcs import *


with open("../src/top.vhdl.template", "r") as file:
    str = file.read()

weightsfp = open("../bnn_weights.txt", "r")

state = (str, 0, weightsfp)
state = gen_act_uthres_layer(state, 1, 8, 28, 123)

state = gen_conv_layer(state, 1, 42, 5, 28, 3, 3)
state = gen_pool_max_layer(state, 42, 5, 5, 26, 2, 2)
state = gen_act_layer(state, 42, 5, 13)

state = gen_conv_layer(state, 42, 78, 5, 13, 3, 3)
state = gen_channel_sum_layer(state, 78, 5, 10, 11, 42)
state = gen_pool_max_layer(state, 78, 10, 10, 11, 2, 2)
state = gen_act_layer(state, 78, 10, 5)

state = gen_fc_layer(state, 10, 20, 78*5, 5)
state = gen_arg_max_layer(state, 10, 20, 4) #count, inputwidth, outputwidth = 4 bits as count = 10

str = gen_output(state)

weightsfp.close()

with open("../src/top.vhdl", "w") as file:
    file.write(str)
