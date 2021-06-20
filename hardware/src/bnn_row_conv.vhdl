-- Row-parallel BNN convolution block

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity bnn_row_conv is
    generic (
        OUTPUT_WIDTH : integer;
        INPUT_COLS  : integer;
        KERNEL_COLS : integer;
        KERNEL_ROWS : integer
    );
    port (
        -- System
        clk         : in  std_logic;
        reset       : in  std_logic;

        -- Weights
        weights     : std_logic_vector(0 to KERNEL_COLS*KERNEL_ROWS-1);

        -- Input data
        row_in      : in  std_logic_vector(INPUT_COLS-1 downto 0);
        ready       : in  std_logic;

        -- Output data
        row_out     : out std_logic_vector((INPUT_COLS-KERNEL_COLS+1)*OUTPUT_WIDTH-1 downto 0);
        done        : out std_logic
    );
end entity;


architecture rtl of bnn_row_conv is

    -- Weights
    constant NUM_WEIGHTS : integer := KERNEL_COLS * KERNEL_ROWS;
    --signal weights : std_logic_vector(0 to NUM_WEIGHTS-1) := WEIGHTS;

    -- Input buffer
    type ibuffer_t is array(0 to KERNEL_ROWS-1) of std_logic_vector(INPUT_COLS-1 downto 0);
    signal ibuffer : ibuffer_t; -- := (others => (others => '0'));

    -- Output
    signal row : integer range 0 to KERNEL_ROWS-1;

begin

    -- Input buffer
    process (clk)
    begin
        if rising_edge(clk) and ready = '1' then
            ibuffer(KERNEL_ROWS-1) <= row_in;
            if KERNEL_ROWS > 1 then
                ibuffer(0 to KERNEL_ROWS-2) <= ibuffer(1 to KERNEL_ROWS-1);
            end if;
        end if;
    end process;


    -- Convolution
    process (weights, ibuffer)
        variable mul : std_logic;
        variable sum : signed(OUTPUT_WIDTH-1 downto 0);
    begin
        for I in 0 to INPUT_COLS-KERNEL_COLS loop
            sum := (others => '0');

            for Y in 0 to KERNEL_ROWS-1 loop
                for X in 0 to KERNEL_COLS-1 loop
                    mul := weights((Y+1)*KERNEL_COLS-1-X) xnor ibuffer(Y)(I+X);
                    --mul := weights(Y*KERNEL_COLS+X) xnor ibuffer(Y)(I+X);
                    if mul = '1' then
                        sum := sum + 1;
                    else
                        sum := sum - 1;
                    end if;
                end loop;
            end loop;

            row_out((I+1)*OUTPUT_WIDTH-1 downto I*OUTPUT_WIDTH) <= std_logic_vector(sum);
        end loop;
    end process;


    -- Output
    process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                row <= 0;
            else
                if ready = '1' and row < KERNEL_ROWS-1 then
                    row <= row + 1;
                else
                    row <= row;
                end if;

                if ready = '1' and row >= KERNEL_ROWS-1 then
                    done <= '1';
                else
                    done <= '0';
                end if;
            end if;
        end if;
    end process;

end architecture;
