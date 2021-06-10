-- Row-parallel activation/quantization block

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity row_activation is
    generic (
        INPUT_WIDTH : integer;
        INPUT_COLS  : integer
    );
    port (
        -- System
        clk         : in  std_logic;
        reset       : in  std_logic;

        -- Input data
        row_in      : in  std_logic_vector(INPUT_COLS*INPUT_WIDTH-1 downto 0);
        ready       : in  std_logic;

        -- Output data
        row_out     : out std_logic_vector(INPUT_COLS-1 downto 0);
        done        : out std_logic
    );
end entity;


architecture rtl of row_activation is
begin

    process (row_in)
    begin
        for I in 0 to INPUT_COLS-1 loop
            -- invert sign bit
            row_out(I) <= not row_in((I+1)*INPUT_WIDTH-1);
        end loop;
    end process;

    done <= ready;

end architecture;
