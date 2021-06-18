-- Row-parallel sum pooling block

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity row_pool_sum is
    generic (
        INPUT_WIDTH : integer;
        OUTPUT_WIDTH : integer;
        INPUT_COLS  : integer;
        POOL_COLS   : integer;
        POOL_ROWS   : integer
    );
    port (
        -- System
        clk         : in  std_logic;
        reset       : in  std_logic;

        -- Input data
        row_in      : in  std_logic_vector(INPUT_COLS*INPUT_WIDTH-1 downto 0);
        ready       : in  std_logic;

        -- Output data
        row_out     : out std_logic_vector((INPUT_COLS/POOL_COLS)*OUTPUT_WIDTH-1 downto 0);
        done        : out std_logic
    );
end entity;


architecture rtl of row_pool_sum is

    -- Delayed ready
    signal ready1 : std_logic;

    -- Sum/output registers
    constant OUTPUT_COLS : integer := INPUT_COLS/POOL_COLS;
    type sumreg_t is array(0 to OUTPUT_COLS-1) of signed(OUTPUT_WIDTH-1 downto 0);
    signal sumreg : sumreg_t;
    signal outreg : sumreg_t;

    signal row : integer range 0 to POOL_ROWS-1;

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
    process (clk)
        variable sum : signed(OUTPUT_WIDTH-1 downto 0);
        variable index : integer;
    begin
        if rising_edge(clk) and ready = '1' then
            for I in 0 to OUTPUT_COLS-1 loop
                sum := (others => '0');

                for X in 0 to POOL_COLS-1 loop
                    index := I*POOL_COLS + X;
                    sum := sum + signed(row_in((index+1)*INPUT_WIDTH-1 downto index*INPUT_WIDTH));
                end loop;

                sumreg(I) <= sum;
            end loop;
        end if;
    end process;


    -- Output sum
    process (clk)
        variable sum : signed(OUTPUT_WIDTH-1 downto 0);
    begin
        if rising_edge(clk) then
            done <= '0';
            if reset = '1' then
                row <= 0;
                done <= '0';
                outreg <= (others => (others => '0'));
            elsif ready1 = '1' then
                if row = POOL_ROWS-1 then
                    row <= 0;
                    done <= '1';
                else
                    row <= row + 1;
                    done <= '0';
                end if;

                if row = 0 then
                    outreg <= sumreg;
                else
                    for I in 0 to OUTPUT_COLS-1 loop
                        outreg(I) <= outreg(I) + sumreg(I);
                    end loop;
                end if;
            end if;
        end if;
    end process;

    --done <= '1' when (ready1 = '1' and row = POOL_ROWS-1) else '0';

    -- Output
    process (outreg)
    begin
        for I in 0 to OUTPUT_COLS-1 loop
            row_out((I+1)*OUTPUT_WIDTH-1 downto I*OUTPUT_WIDTH) <= std_logic_vector(outreg(I));
        end loop;
    end process;


end architecture;
