-- Row-parallel BNN convolution testbench

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;
use IEEE.std_logic_textio.all;

entity bnn_read_file is
end entity;


architecture sim of bnn_row_conv_tb is

    constant CLK_PERIOD : time := 10 ns;

    constant OUTPUT_WIDTH : integer := 8;
    constant INPUT_COLS   : integer := 6;
    constant INPUT_ROWS   : integer := 6;
    constant KERNEL_COLS  : integer := 3;
    constant KERNEL_ROWS  : integer := 3;

    constant WEIGHTS : std_logic_vector(0 to 8) := "101101011";
    type inputd_t is array(0 to INPUT_ROWS-1) of std_logic_vector(INPUT_COLS-1 downto 0);
    constant INPUTD : inputd_t := ("010010","100100","010010","001001","111111","101101");

    signal clk : std_logic := '0';
    signal reset : std_logic;

    signal w_en, w_in, w_out : std_logic;
    signal row_in  : std_logic_vector(INPUT_COLS-1 downto 0);
    signal ready   : std_logic;
    signal row_out : std_logic_vector((INPUT_COLS-KERNEL_COLS+1)*OUTPUT_WIDTH-1 downto 0);
    signal done    : std_logic;

    file input_buf : text;

begin

dut: entity work.bnn_row_conv
        generic map (
            OUTPUT_WIDTH => OUTPUT_WIDTH,
            INPUT_COLS  => INPUT_COLS,
            KERNEL_COLS => KERNEL_COLS,
            KERNEL_ROWS => KERNEL_ROWS
        )
        port map (
            -- System
            clk         => clk,
            reset       => reset,

            -- Weight configuration
            w_en        => w_en,
            w_in        => w_in,
            w_out       => w_out,

            row_in      => row_in,
            ready       => ready,

            row_out     => row_out,
            done        => done
        );

    clk   <= not clk after CLK_PERIOD/2;

    process
        variable read_col_from_input_buf : line;
        variable conv_1 : std_logic_vector(31 downto 0);


    begin
        file_open(input_buf, "bnn_weights.txt",  read_mode);

        w_en <= '0';
        w_in <= '0';
        row_in <= (others => '0');
        ready  <= '0';

        reset <= '1';
        wait for CLK_PERIOD;
        reset <= '0';
        wait for CLK_PERIOD;

--        while not endfile(input_buf) loop
        for I in 0 to 8 loop
          readline(input_buf, input_line);
          read(input_line, conv_line);
          for I in 0 to 31 loop
              w_en <= '1';
              w_in <= conv_line(I);
              wait for CLK_PERIOD;
          end loop;
        w_en <= '0';

        wait for CLK_PERIOD;

        for I in 0 to INPUT_ROWS-1 loop
            row_in <= INPUTD(I);
            wait for CLK_PERIOD;
            ready <= '1';
            wait for CLK_PERIOD;
            ready <= '0';
            wait for CLK_PERIOD;
        end loop;
        ready <= '0';

        wait;
    end process;

end architecture;
