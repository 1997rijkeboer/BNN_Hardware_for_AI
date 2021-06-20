-- Row-parallel channel sum block

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity row_channel_sum is
    generic (
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
        row_in      : in  std_logic_vector(CHANNELS*INPUT_COLS*INPUT_WIDTH-1 downto 0);
        ready       : in  std_logic;

        -- Output data
        row_out     : out std_logic_vector(INPUT_COLS*OUTPUT_WIDTH-1 downto 0);
        done        : out std_logic
    );
end entity;


architecture rtl of row_channel_sum is

--    function sum (x : std_logic_vector; width : integer) return integer is
--        variable result : integer;
--        variable half : integer;
--    begin
--        half := x'length/width;
--
--        if x'length = width then
--            result := to_integer(signed(x));
--        else
--            result := sum(x(x'length-1 downto half*width), width)
--                    + sum(x(half*width-1 downto 0), width);
--        end if;
--
--        return result;
--    end function;

    function sum (x : std_logic_vector; width : integer) return integer is
        variable sum : integer;
    begin
        sum := 0;
        for I in 0 to x'length/width-1 loop
            sum := sum + to_integer(signed(x((I+1)*width-1+x'low downto I*width+x'low)));
        end loop;
        return sum;
    end function;

begin

    process (clk)
    begin
        if rising_edge(clk) then
            for I in 0 to INPUT_COLS-1 loop
                row_out((I+1)*OUTPUT_WIDTH-1 downto I*OUTPUT_WIDTH) <= std_logic_vector(to_signed(sum(row_in((I+1)*CHANNELS*INPUT_WIDTH-1 downto I*CHANNELS*INPUT_WIDTH), INPUT_WIDTH), OUTPUT_WIDTH));
            end loop;
            done    <= ready;
        end if;
    end process;

end architecture;
