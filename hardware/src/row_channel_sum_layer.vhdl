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

    signal row_in_reorder : std_logic_vector(COUNT*CHANNELS*INPUT_COLS*INPUT_WIDTH-1 downto 0);

    signal done_s : std_logic_vector(0 to COUNT-1);

begin

    process (row_in)
        variable reorder : std_logic_vector(COUNT*CHANNELS*INPUT_COLS*INPUT_WIDTH-1 downto 0);
        variable src, dst : integer;
    begin
        for IO in 0 to COUNT-1 loop
            for II in 0 to CHANNELS-1 loop
                for X in 0 to INPUT_COLS-1 loop
                    src := IO*CHANNELS*INPUT_COLS + II*INPUT_COLS + X;
                    dst := IO*CHANNELS*INPUT_COLS + X*CHANNELS + II;
                    reorder((dst+1)*INPUT_WIDTH-1 downto dst*INPUT_WIDTH) := row_in((src+1)*INPUT_WIDTH-1 downto src*INPUT_WIDTH);
                end loop;
            end loop;
        end loop;
        row_in_reorder <= reorder;
    end process;

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

            row_in      => row_in_reorder((I+1)*ROW_IN_WIDTH-1 downto I*ROW_IN_WIDTH),
            ready       => ready,

            row_out     => row_out((I+1)*ROW_OUT_WIDTH-1 downto I*ROW_OUT_WIDTH),
            done        => done_s(I)
        );
end generate;

    done <= done_s(0);

end architecture;
