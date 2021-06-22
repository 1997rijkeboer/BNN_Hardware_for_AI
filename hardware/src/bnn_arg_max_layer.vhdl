library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity arg_max_layer is
    generic (
        COUNT       : integer;
        INPUT_WIDTH : integer;
        OUTPUT_WIDTH : integer
    );
    port (
        -- System
        clk         : in  std_logic;
        reset       : in  std_logic;

        -- Input data
        row_in      : in  std_logic_vector(COUNT*INPUT_WIDTH-1 downto 0);
        ready       : in  std_logic;

        -- Output data
        row_out     : out std_logic_vector(OUTPUT_WIDTH-1 downto 0);
        done        : out std_logic
    );
end entity;

architecture struct of arg_max_layer is

    -- Maximum negative number of width OUTPUT_WIDTH
    constant MAX_NEG : signed(INPUT_WIDTH-1 downto 0) := (INPUT_WIDTH-1 => '1', others => '0');
    signal max_index : integer;

begin

    -- Max Index
    process (clk, ready)
        variable max : signed(INPUT_WIDTH-1 downto 0);
        variable inp : signed(INPUT_WIDTH-1 downto 0);
    begin
        if rising_edge(clk) and ready = '1' then
            max := MAX_NEG;
            for X in 0 to COUNT-1 loop
                inp := signed(row_in((X+1)*INPUT_WIDTH-1 downto X*INPUT_WIDTH));
                if inp > max then
                    max := inp;
                    max_index <= X;
                end if;
            end loop;
        end if;
    end process;

    -- Output
    row_out <= std_logic_vector(to_unsigned(max_index, row_out'length));

    -- Reset
    process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                done <= '0';
            else
                done <= ready;
            end if;
        end if;
    end process;

end architecture;
