----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/17/2022 03:46:29 PM
-- Design Name: 
-- Module Name: rri_counter - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity rri_counter is
    Port ( clk : in STD_LOGIC;
           dac_enable : in STD_LOGIC;
           adc_start : in STD_LOGIC;
           adc_dma_enable : out STD_LOGIC;
           adc_dma_last : out STD_LOGIC;
           adc_length : in STD_LOGIC_VECTOR (31 downto 0);
           dac_length : in STD_LOGIC_VECTOR (15 downto 0);
           dac_addr : out STD_LOGIC_VECTOR (15 downto 0);
           adc_channel : in STD_LOGIC_VECTOR (1 downto 0);
           adc_channel_active : out STD_LOGIC_VECTOR (1 downto 0)
           );
end rri_counter;

architecture Behavioral of rri_counter is
    signal dac_counter	: unsigned(15 downto 0) := (others => '0');
    signal adc_counter	: unsigned(31 downto 0) := (others => '0');
    signal adc_counter_ena : std_logic := '0';
    signal adc_dma_last_int : std_logic := '0';
    signal adc_last_channel : std_logic_vector(1 downto 0);
begin
    
    process (clk)
    begin
        if rising_edge(clk) then
            if adc_start /= '1' then
                adc_last_channel <= adc_channel;
            end if;

            if (dac_enable = '1') then
                if dac_counter >= (unsigned(dac_length)) then
                    dac_counter <= (others => '0');
                    if adc_start = '1' and adc_counter_ena = '0' then
                        adc_counter_ena <= '1';
                        adc_counter <= (others => '0');
                    end if;
                else
                    dac_counter <=  dac_counter + 1 ;
                    
                end if;
                if adc_counter_ena = '1' then
                   if adc_counter >= (unsigned(adc_length)) then
                       adc_counter <= (others => '0');
                       adc_counter_ena <= '0';
                       adc_dma_last_int <= '0';
                   else
                       if adc_counter >= (unsigned(adc_length)-1) then
                           adc_dma_last_int <= '1';
                       end if;
                       adc_counter <= adc_counter + 1 ;
                   end if;
                end if;
            end if;
        end if;
    end process;
    
    adc_dma_enable <= adc_counter_ena;
    adc_dma_last <= adc_dma_last_int;
    dac_addr <= std_logic_vector(dac_counter);
    adc_channel_active <= adc_last_channel;


end Behavioral;
