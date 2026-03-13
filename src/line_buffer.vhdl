----------------------------------------------------------------------------------
-- Engineer: Batuhan Kirtac
-- Project Name: Sobel Edge Detection FPGA Accelerator
-- Design Name: line_buffer.vhd
-- Description: Dual line buffer implementation to provide a 3x3 pixel window.
--              Infers BRAM on Xilinx FPGAs for resource efficiency.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity line_buffer is
    Generic (
        IMAGE_WIDTH : integer := 256 
    );
    Port ( 
        clk            : in  STD_LOGIC;
        rst            : in  STD_LOGIC;
        
        pixel_in       : in  STD_LOGIC_VECTOR (7 downto 0);
        valid_in       : in  STD_LOGIC;
        
        pixel_out_row1 : out STD_LOGIC_VECTOR (7 downto 0);
        pixel_out_row2 : out STD_LOGIC_VECTOR (7 downto 0);
        pixel_out_row3 : out STD_LOGIC_VECTOR (7 downto 0);
        valid_out      : out STD_LOGIC
    );
end line_buffer;

architecture Behavioral of line_buffer is
    -- Define line memory type
    type line_mem_type is array (0 to IMAGE_WIDTH-1) of STD_LOGIC_VECTOR(7 downto 0);
    
    -- Buffers for storing previous two rows
    signal line_buf1 : line_mem_type := (others => (others => '0'));
    signal line_buf2 : line_mem_type := (others => (others => '0'));
    
    -- Control Signals
    signal col_ptr : integer range 0 to IMAGE_WIDTH-1 := 0;
    signal line_count : integer range 0 to 3 := 0;
    signal buffer_full : STD_LOGIC := '0';

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                col_ptr <= 0;
                line_count <= 0;
                buffer_full <= '0';
                valid_out <= '0';
                pixel_out_row1 <= (others => '0');
                pixel_out_row2 <= (others => '0');
                pixel_out_row3 <= (others => '0');
            else
                if valid_in = '1' then
                    
                    -- Read current window column:
                    -- Row 1 comes from the oldest buffer
                    -- Row 2 comes from the middle buffer
                    -- Row 3 is the current incoming pixel
                    pixel_out_row1 <= line_buf2(col_ptr); 
                    pixel_out_row2 <= line_buf1(col_ptr); 
                    pixel_out_row3 <= pixel_in;          
                    
                    -- Shift data through buffers (Line sliding)
                    line_buf2(col_ptr) <= line_buf1(col_ptr);
                    line_buf1(col_ptr) <= pixel_in;
                    
                    -- Manage column pointer and line tracking
                    if col_ptr = IMAGE_WIDTH - 1 then
                        col_ptr <= 0; 
                        if line_count < 2 then
                            line_count <= line_count + 1;
                        else
                            buffer_full <= '1'; 
                        end if;
                    else
                        col_ptr <= col_ptr + 1; 
                    end if;
                    
                    -- Output data is valid only after first 2 lines are buffered
                    if buffer_full = '1' or line_count = 2 then
                        valid_out <= '1';
                    else
                        valid_out <= '0';
                    end if;
                    
                else
                    valid_out <= '0'; 
                end if;
            end if;
        end if;
    end process;

end Behavioral;
