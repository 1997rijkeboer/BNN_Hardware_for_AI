from string import Template



###############################################################################
def gen_conv_layer(str, layer_num, count, output_width, input_cols, kernel_cols, kernel_rows):
    row_in_width  = input_cols
    row_out_width = count*(input_cols-kernel_cols+1)*output_width

    inst_temp = Template("""layer_${I}_conv_inst: entity work.bnn_row_conv_layer
    generic map (
        COUNT       => $count,
        OUTPUT_WIDTH => $output_width,
        INPUT_COLS  => $input_cols,
        KERNEL_COLS => $kernel_cols,
        KERNEL_ROWS => $kernel_rows
    )
    port map (
        clk         => clk,
        reset       => reset,

        w_en        => w_en,
        w_in        => w_pass($I),
        w_out       => w_pass($Inext),

        row_in      => row_$I,
        ready       => rd_pass($I),

        row_out     => row_$Inext,
        done        => rd_pass($Inext)
    );

    $inst_gen""")

    inst = inst_temp.safe_substitute(
        I           = layer_num,
        Inext       = layer_num + 1,
        count       = count,
        output_width = output_width,
        input_cols  = input_cols,
        kernel_cols = kernel_cols,
        kernel_rows = kernel_rows
    )

    sig_temp = Template("""signal row_$Inext : std_logic_vector($row_out_width-1 downto 0);
    $sig_gen""")

    sig = sig_temp.safe_substitute(
        Inext         = layer_num + 1,
        row_out_width = row_out_width
    )

    str = Template(str).safe_substitute(sig_gen=sig, inst_gen=inst)

    return (str, layer_num+1)

###############################################################################
def gen_pool_max_layer(str, layer_num, count, input_width, output_width, input_cols, pool_cols, pool_rows):
    row_in_width  = count*input_cols*input_width
    row_out_width = count*(input_cols//pool_cols)*output_width

    inst_temp = Template("""layer_${I}_pool_max_inst: entity work.row_pool_max_layer
    generic map (
        COUNT       => $count,
        INPUT_WIDTH => $input_width,
        OUTPUT_WIDTH => $output_width,
        INPUT_COLS  => $input_cols,
        POOL_COLS   => $pool_cols,
        POOL_ROWS   => $pool_rows
    )
    port map (
        clk         => clk,
        reset       => reset,

        w_en        => w_en,
        w_in        => w_pass($I),
        w_out       => w_pass($Inext),

        row_in      => row_$I,
        ready       => rd_pass($I),

        row_out     => row_$Inext,
        done        => rd_pass($Inext)
    );

    $inst_gen""")

    inst = inst_temp.safe_substitute(
        I           = layer_num,
        Inext       = layer_num + 1,
        count       = count,
        input_width = input_width,
        output_width = output_width,
        input_cols  = input_cols,
        pool_cols   = pool_cols,
        pool_rows   = pool_rows
    )

    sig_temp = Template("""signal row_$Inext : std_logic_vector($row_out_width-1 downto 0);
    $sig_gen""")

    sig = sig_temp.safe_substitute(
        Inext         = layer_num + 1,
        row_out_width = row_out_width
    )

    str = Template(str).safe_substitute(sig_gen=sig, inst_gen=inst)

    return (str, layer_num+1)

###############################################################################
def gen_pool_sum_layer(str, layer_num, count, input_width, output_width, input_cols, pool_cols, pool_rows):
    row_in_width  = count*input_cols*input_width
    row_out_width = count*(input_cols//pool_cols)*output_width

    inst_temp = Template("""layer_${I}_pool_sum_inst: entity work.row_pool_sum_layer
    generic map (
        COUNT       => $count,
        INPUT_WIDTH => $input_width,
        OUTPUT_WIDTH => $output_width,
        INPUT_COLS  => $input_cols,
        POOL_COLS   => $pool_cols,
        POOL_ROWS   => $pool_rows
    )
    port map (
        clk         => clk,
        reset       => reset,

        w_en        => w_en,
        w_in        => w_pass($I),
        w_out       => w_pass($Inext),

        row_in      => row_$I,
        ready       => rd_pass($I),

        row_out     => row_$Inext,
        done        => rd_pass($Inext)
    );

    $inst_gen""")

    inst = inst_temp.safe_substitute(
        I           = layer_num,
        Inext       = layer_num + 1,
        count       = count,
        input_width = input_width,
        output_width = output_width,
        input_cols  = input_cols,
        pool_cols   = pool_cols,
        pool_rows   = pool_rows
    )

    sig_temp = Template("""signal row_$Inext : std_logic_vector($row_out_width-1 downto 0);
    $sig_gen""")

    sig = sig_temp.safe_substitute(
        Inext         = layer_num + 1,
        row_out_width = row_out_width
    )

    str = Template(str).safe_substitute(sig_gen=sig, inst_gen=inst)

    return (str, layer_num+1)

###############################################################################
def gen_act_layer(str, layer_num, count, input_width, input_cols):
    row_in_width  = count*input_cols*input_width
    row_out_width = count*input_cols

    inst_temp = Template("""layer_${I}_act_inst: entity work.row_activation_layer
    generic map (
        COUNT       => $count,
        INPUT_WIDTH => $input_width,
        INPUT_COLS  => $input_cols
    )
    port map (
        clk         => clk,
        reset       => reset,

        w_en        => w_en,
        w_in        => w_pass($I),
        w_out       => w_pass($Inext),

        row_in      => row_$I,
        ready       => rd_pass($I),

        row_out     => row_$Inext,
        done        => rd_pass($Inext)
    );

    $inst_gen""")

    inst = inst_temp.safe_substitute(
        I           = layer_num,
        Inext       = layer_num + 1,
        count       = count,
        input_width = input_width,
        input_cols  = input_cols,
    )

    sig_temp = Template("""signal row_$Inext : std_logic_vector($row_out_width-1 downto 0);
    $sig_gen""")

    sig = sig_temp.safe_substitute(
        Inext         = layer_num + 1,
        row_out_width = row_out_width
    )

    str = Template(str).safe_substitute(sig_gen=sig, inst_gen=inst)

    return (str, layer_num+1)

###############################################################################
def gen_act_uthres_layer(str, layer_num, count, input_width, input_cols, threshold):
    row_in_width  = count*input_cols*input_width
    row_out_width = count*input_cols

    inst_temp = Template("""layer_${I}_act_uthres_inst: entity work.row_activation_uthreshold_layer
    generic map (
        COUNT       => $count,
        INPUT_WIDTH => $input_width,
        INPUT_COLS  => $input_cols,
        THRESHOLD   => $threshold
    )
    port map (
        clk         => clk,
        reset       => reset,

        w_en        => w_en,
        w_in        => w_pass($I),
        w_out       => w_pass($Inext),

        row_in      => row_$I,
        ready       => rd_pass($I),

        row_out     => row_$Inext,
        done        => rd_pass($Inext)
    );

    $inst_gen""")

    inst = inst_temp.safe_substitute(
        I           = layer_num,
        Inext       = layer_num + 1,
        count       = count,
        input_width = input_width,
        input_cols  = input_cols,
        threshold   = threshold
    )

    sig_temp = Template("""signal row_$Inext : std_logic_vector($row_out_width-1 downto 0);
    $sig_gen""")

    sig = sig_temp.safe_substitute(
        Inext         = layer_num + 1,
        row_out_width = row_out_width
    )

    str = Template(str).safe_substitute(sig_gen=sig, inst_gen=inst)

    return (str, layer_num+1)

###############################################################################
def gen_fc_layer(str, layer_num, count, output_width, input_cols, input_rows):
    row_in_width  = input_cols
    row_out_width = count*output_width

    inst_temp = Template("""layer_${I}_fc_inst: entity work.bnn_fc_layer
    generic map (
        COUNT       => $count,
        OUTPUT_WIDTH => $output_width,
        INPUT_COLS  => $input_cols,
        INPUT_ROWS  => $input_rows
    )
    port map (
        clk         => clk,
        reset       => reset,

        w_en        => w_en,
        w_in        => w_pass($I),
        w_out       => w_pass($Inext),

        row_in      => row_$I,
        ready       => rd_pass($I),

        row_out     => row_$Inext,
        done        => rd_pass($Inext)
    );

    $inst_gen""")

    inst = inst_temp.safe_substitute(
        I           = layer_num,
        Inext       = layer_num + 1,
        count       = count,
        output_width = output_width,
        input_cols  = input_cols,
        input_rows  = input_rows
    )

    sig_temp = Template("""signal row_$Inext : std_logic_vector($row_out_width-1 downto 0);
    $sig_gen""")

    sig = sig_temp.safe_substitute(
        Inext         = layer_num + 1,
        row_out_width = row_out_width
    )

    str = Template(str).safe_substitute(sig_gen=sig, inst_gen=inst)

    return (str, layer_num+1)

###############################################################################
def gen_output(str, layer_num):
    str = Template(str).safe_substitute(
        num_layers  = layer_num,
        sig_gen     = "",
        inst_gen    = ""
    )

    return str
