#!/usr/bin/python3
# Generate top-level NN entity from template
# Small top-level config for testing

from gen_funcs import *


with open("../src/top.vhdl.template", "r") as file:
    str = file.read()

layer_num = 0
(str, layer_num) = gen_act_uthres_layer(str, layer_num, 1, 8, 28, 123)
(str, layer_num) = gen_conv_layer(str, layer_num, 1, 1, 5, 28, 3, 3)
(str, layer_num) = gen_pool_max_layer(str, layer_num, 1, 5, 5, 26, 2, 2)
(str, layer_num) = gen_act_layer(str, layer_num, 1, 5, 13)
(str, layer_num) = gen_fc_layer(str, layer_num, 2, 14, 13, 13)
(str, layer_num) = gen_arg_max_layer(str, layer_num, 2, 14, 4) #count, inputwidth, outputwidth = 4 bits as count = 10

str = gen_output(str, layer_num)

with open("../src/top.vhdl", "w") as file:
    file.write(str)
