-- BNN fully connected block
-- Set rows > 1 for convolution input, to 1 for fc-fc layers

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity bnn_fc is
    generic (
        COUNT_IN    : integer;
        OUTPUT_WIDTH : integer;
        INPUT_COLS  : integer;
        INPUT_ROWS  : integer
    );
    port (
        -- System
        clk         : in  std_logic;
        reset       : in  std_logic;

        -- Weight configuration
        weights     : in  std_logic_vector(0 to COUNT_IN*INPUT_COLS*INPUT_ROWS-1);

        -- Input data
        row_in      : in  std_logic_vector(COUNT_IN*INPUT_COLS-1 downto 0);
        ready       : in  std_logic;

        -- Output data
        row_out     : out std_logic_vector(OUTPUT_WIDTH-1 downto 0);
        done        : out std_logic
    );
end entity;


architecture rtl of bnn_fc is

    -- Delayed ready
    signal ready1 : std_logic;

    -- Weights
    constant NUM_WEIGHTS : integer := COUNT_IN * INPUT_COLS * INPUT_ROWS;
    --signal weights : std_logic_vector(0 to NUM_WEIGHTS-1); -- := (others => '0');

    -- Sum/output
    signal sumreg : signed(OUTPUT_WIDTH-1 downto 0);
    signal outreg : signed(OUTPUT_WIDTH-1 downto 0);

    signal row : integer range 0 to INPUT_ROWS-1;

begin

    -- Delayed ready
    process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                ready1 <= '0';
            else
                ready1 <= ready;
            end if;
        end if;
    end process;


    -- Input sum
    process (clk, ready)
        variable mul : std_logic;
        variable sum : signed(OUTPUT_WIDTH-1 downto 0);
        variable index : integer;
    begin
        if rising_edge(clk) and ready = '1' then
            sum := (others => '0');

            for I in 0 to COUNT_IN-1 loop
                for J in 0 to INPUT_COLS-1 loop
                    --index := I*INPUT_COLS*INPUT_ROWS + row*INPUT_COLS + J;
                    index := row*INPUT_COLS*COUNT_IN + I*INPUT_COLS + J;
                    mul := weights(index) xnor row_in((COUNT_IN-I)*INPUT_COLS-1-J);
                    if mul = '1' then
                        sum := sum + 1;
                    else
                        sum := sum - 1;
                    end if;
                end loop;
            end loop;

            sumreg <= sum;
        end if;
    end process;


    -- Output sum
MULTI_ROW: if INPUT_ROWS /= 1 generate
    process (clk)
    begin
        if rising_edge(clk) then
            --done <= '0';
            if reset = '1' then
                row <= 0;
                done <= '0';
            elsif ready = '1' then
                if row = INPUT_ROWS-1 then
                    row <= 0;
                    done <= '1';
                else
                    row <= row + 1;
                    done <= '0';
                end if;
            end if;

            if reset = '1' then
                outreg <= (others => '0');
            elsif ready1 = '1' then
                if row = 1 then
                    outreg <= sumreg;
                else
                    outreg <= outreg + sumreg;
                end if;
            end if;
        end if;
    end process;
end generate;

SINGLE_ROW: if INPUT_ROWS = 1 generate
    process(clk)
    begin
        if rising_edge(clk) and ready = '1' then
            row <= 0;
            done <= '1';
            outreg <= sumreg;
        end if;
    end process;
end generate;


    -- Output
    row_out <= std_logic_vector(outreg);

end architecture;
