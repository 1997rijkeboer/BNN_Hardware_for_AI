-- Row-parallel channel sum layer

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity row_channel_sum_layer is
    generic (
        COUNT       : integer;
        INPUT_WIDTH : integer;
        OUTPUT_WIDTH : integer;
        INPUT_COLS  : integer;
        CHANNELS    : integer
    );
    port (
        -- System
        clk         : in  std_logic;
        reset       : in  std_logic;

        -- Input data
        row_in      : in  std_logic_vector(COUNT*CHANNELS*INPUT_COLS*INPUT_WIDTH-1 downto 0);
        ready       : in  std_logic;

        -- Output data
        row_out     : out std_logic_vector(COUNT*INPUT_COLS*OUTPUT_WIDTH-1 downto 0);
        done        : out std_logic
    );
end entity;


architecture struct of row_channel_sum_layer is

    constant ROW_IN_WIDTH  : integer := CHANNELS*INPUT_COLS*INPUT_WIDTH;
    constant ROW_OUT_WIDTH : integer := INPUT_COLS*OUTPUT_WIDTH;

    signal done_s : std_logic_vector(0 to COUNT-1);

begin

row_channel_sum_gen: for I in 0 to COUNT-1 generate
    row_channel_sum_inst: entity work.row_channel_sum
        generic map (
            INPUT_WIDTH => INPUT_WIDTH,
            OUTPUT_WIDTH => OUTPUT_WIDTH,
            INPUT_COLS  => INPUT_COLS,
            CHANNELS    => CHANNELS
        )
        port map (
            clk         => clk,
            reset       => reset,

            row_in      => row_in((I+1)*ROW_IN_WIDTH-1 downto I*ROW_IN_WIDTH),
            ready       => ready,

            row_out     => row_out((I+1)*ROW_OUT_WIDTH-1 downto I*ROW_OUT_WIDTH),
            done        => done_s(I)
        );
end generate;

    done <= done_s(0);

end architecture;
