-- BNN fully connected layer
-- Set rows > 1 for convolution input, to 1 for fc-fc layers

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity bnn_fc_layer is
    generic (
        COUNT       : integer;
        OUTPUT_WIDTH : integer;
        INPUT_COLS  : integer;
        INPUT_ROWS  : integer
    );
    port (
        -- System
        clk         : in  std_logic;
        reset       : in  std_logic;

        -- Weight configuration
        w_en        : in  std_logic; -- enable shifting
        w_in        : in  std_logic; -- input
        w_out       : out std_logic; -- output/passthrough

        -- Input data
        row_in      : in  std_logic_vector(INPUT_COLS-1 downto 0);
        ready       : in  std_logic;

        -- Output data
        row_out     : out std_logic_vector(COUNT*OUTPUT_WIDTH-1 downto 0);
        done        : out std_logic
    );
end entity;


architecture struct of bnn_fc_layer is

    constant ROW_OUT_WIDTH : integer := OUTPUT_WIDTH;

    signal w_pass : std_logic_vector(0 to COUNT);
    signal done_s : std_logic_vector(0 to COUNT-1);

begin

bnn_fc_gen: for I in 0 to COUNT-1 generate
    bnn_fc_inst: entity work.bnn_fc
        generic map (
            OUTPUT_WIDTH => OUTPUT_WIDTH,
            INPUT_COLS  => INPUT_COLS,
            INPUT_ROWS  => INPUT_ROWS
        )
        port map (
            clk         => clk,
            reset       => reset,

            w_en        => w_en,
            w_in        => w_pass(I),
            w_out       => w_pass(I+1),

            row_in      => row_in,
            ready       => ready,

            row_out     => row_out((I+1)*ROW_OUT_WIDTH-1 downto I*ROW_OUT_WIDTH),
            done        => done_s(I)
        );
end generate;

    w_pass(0) <= w_in;
    w_out <= w_pass(COUNT);

    done <= done_s(0);

end architecture;
