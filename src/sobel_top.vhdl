----------------------------------------------------------------------------------
-- Engineer: Batuhan Kirtac
-- Project Name: Sobel Edge Detection FPGA Accelerator
-- Design Name: sobel_top.vhd
-- Description: Top-level structural module connecting Line Buffer and MAC unit 
--              for real-time edge detection.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sobel_top is
    Generic (
        IMAGE_WIDTH : integer := 256 
    );
    Port ( 
        clk        : in  STD_LOGIC;
        rst        : in  STD_LOGIC;
        pixel_in   : in  STD_LOGIC_VECTOR (7 downto 0);
        valid_in   : in  STD_LOGIC;
        
        pixel_out  : out STD_LOGIC_VECTOR (7 downto 0);
        valid_out  : out STD_LOGIC
    );
end sobel_top;

architecture Structural of sobel_top is

    -- Component declaration for Line Buffer
    component line_buffer is
        Generic ( IMAGE_WIDTH : integer );
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
    end component;

    -- Component declaration for MAC Unit (Calculates Gradients)
    component mac_unit is
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
    end component;
    
    -- Internal Signals
    signal row1_sig      : STD_LOGIC_VECTOR (7 downto 0);
    signal row2_sig      : STD_LOGIC_VECTOR (7 downto 0);
    signal row3_sig      : STD_LOGIC_VECTOR (7 downto 0);
    signal buf_valid_sig : STD_LOGIC;

begin

    -- Line Buffer Instance
    U_LINE_BUFFER: line_buffer
    generic map (
        IMAGE_WIDTH => IMAGE_WIDTH
    )
    port map (
        clk            => clk,              
        rst            => rst,              
        pixel_in       => pixel_in,        
        valid_in       => valid_in,         
        pixel_out_row1 => row1_sig,         
        pixel_out_row2 => row2_sig,
        pixel_out_row3 => row3_sig,
        valid_out      => buf_valid_sig
    );

    -- MAC Unit Instance
    U_MAC_UNIT: mac_unit
    port map (
        clk            => clk,              
        rst            => rst,              
        pixel_row1_in  => row1_sig,         
        pixel_row2_in  => row2_sig,
        pixel_row3_in  => row3_sig,
        valid_in       => buf_valid_sig,
        pixel_out      => pixel_out,        
        valid_out      => valid_out         
    );

end Structural;
