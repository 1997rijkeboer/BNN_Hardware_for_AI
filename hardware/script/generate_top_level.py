#!/usr/bin/python3
# Generate top-level NN entity from template

from gen_funcs import *


with open("../src/top.vhdl.template", "r") as file:
    str = file.read()

weightsfp = open("../bnn_weights.txt", "r")

conv1 = 16
conv2 = 32

state = (str, 0, weightsfp)
state = gen_act_uthres_layer(state, 1, 8, 28, 128)

state = gen_conv_layer(state, 1, conv1, 5, 28, 3, 3)
state = gen_pool_max_layer(state, conv1, 5, 5, 26, 2, 2)
state = gen_act_layer(state, conv1, 5, 13)

state = gen_conv_layer(state, conv1, conv2, 5, 13, 3, 3)
state = gen_channel_sum_layer(state, conv2, 5, 10, 11, conv1)
state = gen_pool_max_layer(state, conv2, 10, 10, 11, 2, 2)
state = gen_act_layer(state, conv2, 10, 5)

state = gen_fc_layer(state, conv2, 10, 20, 5, 5)
state = gen_arg_max_layer(state, 10, 20, 4)

str = gen_output(state)

weightsfp.close()

with open("../src/top.vhdl", "w") as file:
    file.write(str)
