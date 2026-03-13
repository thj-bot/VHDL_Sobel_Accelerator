----------------------------------------------------------------------------------
-- Engineer: Batuhan Kirtac
-- Project Name: Sobel Edge Detection FPGA Accelerator
-- Design Name: tb_sobel.vhd
-- Description: Testbench for the Sobel Accelerator. 
--              Reads grayscale input from 'original_pixels.txt' and 
--              writes processed output to 'fpga_hardware_pixels.txt'.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL; 

entity tb_sobel is
end tb_sobel;

architecture Behavioral of tb_sobel is

    -- Component Declaration
    component sobel_top
        Generic ( IMAGE_WIDTH : integer );
        Port ( 
            clk        : in  STD_LOGIC;
            rst        : in  STD_LOGIC;
            pixel_in   : in  STD_LOGIC_VECTOR (7 downto 0);
            valid_in   : in  STD_LOGIC;
            pixel_out  : out STD_LOGIC_VECTOR (7 downto 0);
            valid_out  : out STD_LOGIC
        );
    end component;

    -- Signals
    signal clk        : STD_LOGIC := '0';
    signal rst        : STD_LOGIC := '0';
    signal pixel_in   : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal valid_in   : STD_LOGIC := '0';
    signal pixel_out  : STD_LOGIC_VECTOR (7 downto 0);
    signal valid_out  : STD_LOGIC;

    -- Constants
    constant clk_period : time := 10 ns;
    
    -- FIXED: Relative paths for GitHub portability
    constant IN_FILE_PATH  : string := "original_pixels.txt";
    constant OUT_FILE_PATH : string := "fpga_hardware_pixels.txt";

begin

    -- Unit Under Test (UUT)
    UUT: sobel_top
    generic map ( IMAGE_WIDTH => 256 )
    port map (
        clk       => clk,
        rst       => rst,
        pixel_in  => pixel_in,
        valid_in  => valid_in,
        pixel_out => pixel_out,
        valid_out => valid_out
    );

    -- Clock Generation
    clk_process: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus Process: Feeding the input pixels
    stim_proc: process
        file in_file      : text open read_mode is IN_FILE_PATH;
        variable in_line  : line;
        variable pixel_val: integer;
    begin
        -- System Reset
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for clk_period * 5;

        -- Read from file and drive the FPGA input
        while not endfile(in_file) loop
            wait until rising_edge(clk);
            
            if not endfile(in_file) then
                readline(in_file, in_line);
                read(in_line, pixel_val); 
                pixel_in <= std_logic_vector(to_unsigned(pixel_val, 8));
                valid_in <= '1';
            end if;
        end loop;

        -- End of transmission
        wait until rising_edge(clk);
        valid_in <= '0';
        
        -- Wait for the last pixels to pass through the pipeline
        wait for clk_period * 1000;

        report "SIMULASYON BASARIYLA TAMAMLANDI!" severity note;
        assert false report "Simulation Finished" severity failure; -- Stop the simulation
    end process;

    -- Output Capture Process: Writing processed data to file
    out_proc: process(clk)
        file out_file     : text open write_mode is OUT_FILE_PATH;
        variable out_line : line;
    begin
        if rising_edge(clk) then
            if valid_out = '1' then
                write(out_line, to_integer(unsigned(pixel_out))); 
                writeline(out_file, out_line);
            end if;
        end if;
    end process;

end Behavioral;