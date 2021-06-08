-- Row-parallel BNN convolution + pooling testbench

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity conv_pool_tb is
end entity;


architecture sim of conv_pool_tb is

    constant CLK_PERIOD : time := 10 ns;

    constant INPUT_COLS     : integer := 6;
    constant INPUT_ROWS     : integer := 6;

    constant CONV_WIDTH     : integer := 8;
    constant KERNEL_COLS    : integer := 3;
    constant KERNEL_ROWS    : integer := 3;

    constant POOL_WIDTH     : integer := 8;
    constant POOL_COLS      : integer := 2;
    constant POOL_ROWS      : integer := 2;


    constant WEIGHTS : std_logic_vector(0 to 8) := "101101011";
    type inputd_t is array(0 to INPUT_ROWS-1) of std_logic_vector(INPUT_COLS-1 downto 0);
    constant INPUTD : inputd_t := ("010010","100100","010010","001001","111111","101101");

    signal clk : std_logic := '0';
    signal reset : std_logic;

    signal w_en, w_in, w_conv, w_out : std_logic;
    signal row_in       : std_logic_vector(INPUT_COLS-1 downto 0);
    signal ready_in     : std_logic;

    constant CONV_COLS  : integer := INPUT_COLS - KERNEL_COLS + 1;
    signal row_conv     : std_logic_vector(CONV_COLS*CONV_WIDTH-1 downto 0);
    signal done_conv    : std_logic;

    constant TPOOL_COLS  : integer := CONV_COLS/POOL_COLS;
    signal row_pool     : std_logic_vector(TPOOL_COLS*POOL_WIDTH-1 downto 0);
    signal done_pool    : std_logic;

begin

conv_inst: entity work.bnn_row_conv
    generic map (
        OUTPUT_WIDTH => CONV_WIDTH,
        INPUT_COLS  => INPUT_COLS,
        KERNEL_COLS => KERNEL_COLS,
        KERNEL_ROWS => KERNEL_ROWS
    )
    port map (
        clk         => clk,
        reset       => reset,

        w_en        => w_en,
        w_in        => w_in,
        w_out       => w_conv,

        row_in      => row_in,
        ready       => ready_in,

        row_out     => row_conv,
        done        => done_conv
    );

pool_inst: entity work.row_pool_max
    generic map (
        INPUT_WIDTH => CONV_WIDTH,
        OUTPUT_WIDTH => POOL_WIDTH,
        INPUT_COLS  => CONV_COLS,
        POOL_COLS   => POOL_COLS,
        POOL_ROWS   => POOL_ROWS
    )
    port map (
        clk         => clk,
        reset       => reset,

        row_in      => row_conv,
        ready       => done_conv,

        row_out     => row_pool,
        done        => done_pool
    );

    clk   <= not clk after CLK_PERIOD/2;

    process
    begin
        w_en <= '0';
        w_in <= '0';
        row_in <= (others => '0');
        ready_in  <= '0';

        reset <= '1';
        wait for CLK_PERIOD;
        reset <= '0';
        wait for CLK_PERIOD;

        for I in 0 to WEIGHTS'length-1 loop
            w_en <= '1';
            w_in <= WEIGHTS(I);
            wait for CLK_PERIOD;
        end loop;
        w_en <= '0';

        wait for CLK_PERIOD;

        for I in 0 to INPUT_ROWS-1 loop
            row_in <= INPUTD(I);
            ready_in <= '1';
            wait for CLK_PERIOD;
            --wait for CLK_PERIOD;
            --wait for CLK_PERIOD;
            --ready_in <= '0';
        end loop;
        ready_in <= '0';

        wait;
    end process;

end architecture;
