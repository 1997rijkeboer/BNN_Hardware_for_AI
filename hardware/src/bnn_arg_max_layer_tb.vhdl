library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity arg_max_layer_tb is
end entity;

architecture sim of arg_max_layer_tb is

    constant CLK_PERIOD     : time := 10 ns;
    constant INPUT_WIDTH    : integer := 4;
    constant OUTPUT_WIDTH   : integer := 3;
    constant COUNT          : integer := 8;

    --type inputd_t is std_logic_vector(COUNT*INPUT_WIDTH-1 downto 0);
    --constant INPUTD         : std_logic_vector(0 to COUNT*INPUT_WIDTH-1) := "01000111001011010100011111101001";
    --constant INPUTD         : std_logic_vector(0 to COUNT*INPUT_WIDTH-1) := "10001001101010111100110111111110"; --index should be 1
    constant INPUTD         : std_logic_vector(0 to COUNT*INPUT_WIDTH-1) := "00001001001010111100110111111110"; --index should be 5
 --"0000 1111 0010 1101 0100 0111 0001 1001"

    signal clk      : std_logic := '0';
    signal reset    : std_logic;

    signal w_en, w_in, w_out    : std_logic;
    signal row_in               : std_logic_vector(COUNT*INPUT_WIDTH-1 downto 0);
    signal ready                : std_logic;

    signal row_out              : std_logic_vector(OUTPUT_WIDTH-1 downto 0);
    signal done                 : std_logic;

begin

arg_max_inst: entity work.arg_max_layer
    generic map (
        COUNT       => COUNT,
        INPUT_WIDTH => INPUT_WIDTH,
        OUTPUT_WIDTH => OUTPUT_WIDTH
    )
    port map (
        -- System
        clk         => clk,
        reset       => reset,

        -- Weight configuration
        w_en       => w_en, -- enable shifting
        w_in       => w_in, -- input
        w_out      => w_out, -- output/passthrough

        -- Input data
        row_in      => row_in,--count * input_width
        ready       => ready,

        -- Output data
        row_out     => row_out,
        done        => done
    );

clk   <= not clk after CLK_PERIOD/2;

    process
    begin
        w_en <= '0';
        w_in <= '0';
        row_in <= (others => '0');
        ready  <= '0';

        reset <= '1';
        wait for CLK_PERIOD;
        reset <= '0';
        wait for CLK_PERIOD;
        ready   <= '1';
        row_in <= INPUTD(0 to COUNT*INPUT_WIDTH-1);
        wait for 2*CLK_PERIOD;

        assert row_out = "101"
            report "WRONG OUTPUT INDEX"
            severity failure;
        wait;
    end process;

end architecture;
