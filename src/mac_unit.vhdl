----------------------------------------------------------------------------------
-- Engineer: Batuhan Kirtac
-- Project Name: Sobel Edge Detection FPGA Accelerator
-- Design Name: mac_unit.vhd
-- Description: Multiply-Accumulate unit for Sobel operator. 
--              Uses bit-shift optimization to achieve zero DSP block utilization.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mac_unit is
    Port ( 
        clk            : in  STD_LOGIC;
        rst            : in  STD_LOGIC;
        pixel_row1_in  : in  STD_LOGIC_VECTOR (7 downto 0);
        pixel_row2_in  : in  STD_LOGIC_VECTOR (7 downto 0);
        pixel_row3_in  : in  STD_LOGIC_VECTOR (7 downto 0);
        valid_in       : in  STD_LOGIC;
        pixel_out      : out STD_LOGIC_VECTOR (7 downto 0);
        valid_out      : out STD_LOGIC
    );
end mac_unit;

architecture Behavioral of mac_unit is
    type window_type is array (0 to 2, 0 to 2) of unsigned(7 downto 0);
    signal window : window_type := (others => (others => (others => '0')));
    signal Gx_sum, Gy_sum : signed(10 downto 0) := (others => '0');
    signal abs_Gx, abs_Gy : signed(10 downto 0) := (others => '0');
    signal G_total        : unsigned(10 downto 0) := (others => '0');
    signal valid_pipe : std_logic_vector(2 downto 0) := (others => '0');

begin
    process(clk)
        variable temp_Gx : signed(10 downto 0);
        variable temp_Gy : signed(10 downto 0);
    begin
        if rising_edge(clk) then
            if rst = '1' then
                window <= (others => (others => (others => '0')));
                valid_pipe <= (others => '0');
                pixel_out <= (others => '0');
                valid_out <= '0';
            else
                window(0,0) <= window(0,1); window(0,1) <= window(0,2); window(0,2) <= unsigned(pixel_row1_in);
                window(1,0) <= window(1,1); window(1,1) <= window(1,2); window(1,2) <= unsigned(pixel_row2_in);
                window(2,0) <= window(2,1); window(2,1) <= window(2,2); window(2,2) <= unsigned(pixel_row3_in);
                
                valid_pipe(0) <= valid_in;
                valid_pipe(1) <= valid_pipe(0);
                valid_pipe(2) <= valid_pipe(1);

                temp_Gx := signed("000" & window(0,2)) - signed("000" & window(0,0))
                         + signed("00" & window(1,2) & '0') - signed("00" & window(1,0) & '0')
                         + signed("000" & window(2,2)) - signed("000" & window(2,0));

                temp_Gy := signed("000" & window(0,0)) + signed("00" & window(0,1) & '0') + signed("000" & window(0,2))
                         - signed("000" & window(2,0)) - signed("00" & window(2,1) & '0') - signed("000" & window(2,2));
                         
                Gx_sum <= temp_Gx;
                Gy_sum <= temp_Gy;

                if Gx_sum < 0 then abs_Gx <= -Gx_sum; else abs_Gx <= Gx_sum; end if;
                if Gy_sum < 0 then abs_Gy <= -Gy_sum; else abs_Gy <= Gy_sum; end if;
                G_total <= unsigned(abs_Gx) + unsigned(abs_Gy);

                if G_total > 255 then
                    pixel_out <= x"FF"; 
                else
                    pixel_out <= std_logic_vector(G_total(7 downto 0));
                end if;
                valid_out <= valid_pipe(2);
            end if;
        end if;
    end process;
end Behavioral;
