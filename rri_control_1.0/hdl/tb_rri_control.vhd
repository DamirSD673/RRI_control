----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/24/2022 12:29:25 PM
-- Design Name: 
-- Module Name: tb_rri_control - Behavioral
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
use std.env.all;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

use std.textio.all;
use ieee.std_logic_textio.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_rri_control is
    generic (  
            g_period_axi  : time := 20 ns;
            g_period_axis  : time := 8 ns;
            g_timeout : time :=  1 ms
        );
--  Port ( );
end tb_rri_control;

architecture Behavioral of tb_rri_control is

    component rri_control_v1_0 is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S_AXI_LITE
		C_S_AXI_LITE_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_LITE_ADDR_WIDTH	: integer	:= 6;

		-- Parameters of Axi Slave Bus Interface S_ADC_AXIS
		C_S_ADC_AXIS_TDATA_WIDTH	: integer	:= 32;

		-- Parameters of Axi Master Bus Interface M_DMA_AXIS
		C_M_DMA_AXIS_TDATA_WIDTH	: integer	:= 64;

		-- Parameters of Axi Master Bus Interface M_DAC_AXIS
		C_M_DAC_AXIS_TDATA_WIDTH	: integer	:= 16
	);
	port (
		-- Users to add ports here

		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S_AXI_LITE
		s_axi_lite_aclk	: in std_logic;
		s_axi_lite_aresetn	: in std_logic;
		s_axi_lite_awaddr	: in std_logic_vector(C_S_AXI_LITE_ADDR_WIDTH-1 downto 0);
		s_axi_lite_awprot	: in std_logic_vector(2 downto 0);
		s_axi_lite_awvalid	: in std_logic;
		s_axi_lite_awready	: out std_logic;
		s_axi_lite_wdata	: in std_logic_vector(C_S_AXI_LITE_DATA_WIDTH-1 downto 0);
		s_axi_lite_wstrb	: in std_logic_vector((C_S_AXI_LITE_DATA_WIDTH/8)-1 downto 0);
		s_axi_lite_wvalid	: in std_logic;
		s_axi_lite_wready	: out std_logic;
		s_axi_lite_bresp	: out std_logic_vector(1 downto 0);
		s_axi_lite_bvalid	: out std_logic;
		s_axi_lite_bready	: in std_logic;
		s_axi_lite_araddr	: in std_logic_vector(C_S_AXI_LITE_ADDR_WIDTH-1 downto 0);
		s_axi_lite_arprot	: in std_logic_vector(2 downto 0);
		s_axi_lite_arvalid	: in std_logic;
		s_axi_lite_arready	: out std_logic;
		s_axi_lite_rdata	: out std_logic_vector(C_S_AXI_LITE_DATA_WIDTH-1 downto 0);
		s_axi_lite_rresp	: out std_logic_vector(1 downto 0);
		s_axi_lite_rvalid	: out std_logic;
		s_axi_lite_rready	: in std_logic;
		
		axis_aclk : in std_logic;

		-- Ports of Axi Slave Bus Interface S_ADC_AXIS
		s_adc_axis_aresetn	: in std_logic;
		s_adc_axis_tready	: out std_logic;
		s_adc_axis_tdata	: in std_logic_vector(C_S_ADC_AXIS_TDATA_WIDTH-1 downto 0);
		s_adc_axis_tlast	: in std_logic;
		s_adc_axis_tvalid	: in std_logic;

		-- Ports of Axi Master Bus Interface M_DMA_AXIS
		m_dma_axis_aresetn	: in std_logic;
		m_dma_axis_tvalid	: out std_logic;
		m_dma_axis_tdata	: out std_logic_vector(C_M_DMA_AXIS_TDATA_WIDTH-1 downto 0);
		m_dma_axis_tlast	: out std_logic;
		m_dma_axis_tready	: in std_logic;

		-- Ports of Axi Master Bus Interface M_DAC_AXIS
		m_dac_axis_aresetn	: in std_logic;
		m_dac_axis_tvalid	: out std_logic;
		m_dac_axis_tdata	: out std_logic_vector(C_M_DAC_AXIS_TDATA_WIDTH-1 downto 0);
		m_dac_axis_tlast	: out std_logic;
		m_dac_axis_tready	: in std_logic
	);
    end component rri_control_v1_0;

    signal s_clk_axi : std_logic := '1';
    signal s_clk_axis : std_logic := '1';
    signal s_rst_axi : std_logic := '0';
    signal s_rst_axis : std_logic := '0';  
    
    signal s_s_axi_lite_aclk : std_logic;
    signal s_s_axi_lite_aresetn	: std_logic;
    signal s_s_axi_lite_awaddr	: std_logic_vector(5 downto 0);
    signal s_s_axi_lite_awprot	: std_logic_vector(2 downto 0) := (others => '0');
    signal s_s_axi_lite_awvalid	: std_logic;
    signal s_s_axi_lite_awready	: std_logic;
    signal s_s_axi_lite_wdata	: std_logic_vector(31 downto 0);
    signal s_s_axi_lite_wstrb	: std_logic_vector(3 downto 0);
    signal s_s_axi_lite_wvalid	: std_logic;
    signal s_s_axi_lite_wready	: std_logic;
    signal s_s_axi_lite_bresp	: std_logic_vector(1 downto 0);
    signal s_s_axi_lite_bvalid	: std_logic;
    signal s_s_axi_lite_bready	: std_logic;
    signal s_s_axi_lite_araddr	: std_logic_vector(5 downto 0);
    signal s_s_axi_lite_arprot	: std_logic_vector(2 downto 0) := (others => '0');
    signal s_s_axi_lite_arvalid	: std_logic;
    signal s_s_axi_lite_arready	: std_logic;
    signal s_s_axi_lite_rdata	: std_logic_vector(31 downto 0);
    signal s_s_axi_lite_rresp	: std_logic_vector(1 downto 0);
    signal s_s_axi_lite_rvalid	: std_logic;
    signal s_s_axi_lite_rready	: std_logic;

    -- Ports of Axi Slave Bus Interface S_ADC_AXIS
    signal s_s_adc_axis_aresetn	: std_logic;
    signal s_s_adc_axis_tready	: std_logic;
    signal s_s_adc_axis_tdata	: std_logic_vector(31 downto 0) := (others => '0');
    signal s_s_adc_axis_tlast	: std_logic := '0';
    signal s_s_adc_axis_tvalid	: std_logic := '1';

    -- Ports of Axi Master Bus Interface M_DMA_AXIS
    signal s_m_dma_axis_aresetn	: std_logic := '0';
    signal s_m_dma_axis_tvalid	: std_logic := '0';
    signal s_m_dma_axis_tdata	: std_logic_vector(63 downto 0);
    signal s_m_dma_axis_tlast	: std_logic := '0';
    signal s_m_dma_axis_tready	: std_logic := '0';

    -- Ports of Axi Master Bus Interface M_DAC_AXIS
    signal s_m_dac_axis_aresetn	: std_logic := '0';
    signal s_m_dac_axis_tvalid	: std_logic := '0';
    signal s_m_dac_axis_tdata	: std_logic_vector(15 downto 0);
    signal s_m_dac_axis_tlast	: std_logic := '0';
    signal s_m_dac_axis_tready	: std_logic := '0';
    
    -- AXI LITE testbench control
    signal sendIt : std_logic := '0';
    signal readIt : std_logic := '0';
    signal timeIt : std_logic := '0';
    signal flag_write : std_logic := '0';
    
    -- ADC Signal Generator
    signal adc_value : unsigned(13 downto 0) := (others => '0');

begin
    s_clk_axi <= not s_clk_axi after g_period_axi / 2;
    s_clk_axis <= not s_clk_axis after g_period_axis / 2;
    
    s_rst_axi <= '1' after 20 ns;
    s_rst_axis <= '1' after 30 ns;
    
    s_s_axi_lite_aclk <= s_clk_axi;
    
    s_s_adc_axis_aresetn <= s_rst_axis;
    s_m_dma_axis_aresetn <= s_rst_axis;
    s_m_dac_axis_aresetn <= s_rst_axis;
    
    dut : rri_control_v1_0
        generic map (
		C_S_AXI_LITE_DATA_WIDTH	=> 32,
		C_S_AXI_LITE_ADDR_WIDTH	=> 6,

		-- Parameters of Axi Slave Bus Interface S_ADC_AXIS
		C_S_ADC_AXIS_TDATA_WIDTH => 32,

		-- Parameters of Axi Master Bus Interface M_DMA_AXIS
		C_M_DMA_AXIS_TDATA_WIDTH => 64,

		-- Parameters of Axi Master Bus Interface M_DAC_AXIS
		C_M_DAC_AXIS_TDATA_WIDTH => 16
	)
	port map (		
		-- Ports of Axi Master Bus Interface M_AXIS
		s_axi_lite_aclk	=> s_s_axi_lite_aclk,
		s_axi_lite_aresetn	=> s_s_axi_lite_aresetn,
		s_axi_lite_awaddr	=> s_s_axi_lite_awaddr,
		s_axi_lite_awprot	=> s_s_axi_lite_awprot,
		s_axi_lite_awvalid	=> s_s_axi_lite_awvalid,
		s_axi_lite_awready	=> s_s_axi_lite_awready,
		s_axi_lite_wdata	=> s_s_axi_lite_wdata,
		s_axi_lite_wstrb	=> s_s_axi_lite_wstrb,
		s_axi_lite_wvalid	=> s_s_axi_lite_wvalid,
		s_axi_lite_wready	=> s_s_axi_lite_wready,
		s_axi_lite_bresp	=> s_s_axi_lite_bresp,
		s_axi_lite_bvalid	=> s_s_axi_lite_bvalid,
		s_axi_lite_bready	=> s_s_axi_lite_bready,
		s_axi_lite_araddr	=> s_s_axi_lite_araddr,
		s_axi_lite_arprot	=> s_s_axi_lite_arprot,
		s_axi_lite_arvalid	=> s_s_axi_lite_arvalid,
		s_axi_lite_arready	=> s_s_axi_lite_arready,
		s_axi_lite_rdata	=> s_s_axi_lite_rdata,
		s_axi_lite_rresp	=> s_s_axi_lite_rresp,
		s_axi_lite_rvalid	=> s_s_axi_lite_rvalid,
		s_axi_lite_rready	=> s_s_axi_lite_rready,
		
		axis_aclk	=> s_clk_axis,

		-- Ports of Axi Slave Bus Interface S_ADC_AXIS
		s_adc_axis_aresetn	=> s_s_adc_axis_aresetn,
		s_adc_axis_tready	=> s_s_adc_axis_tready,
		s_adc_axis_tdata	=> s_s_adc_axis_tdata,
		s_adc_axis_tlast	=> s_s_adc_axis_tlast,
		s_adc_axis_tvalid	=> s_s_adc_axis_tvalid,

		-- Ports of Axi Master Bus Interface M_DMA_AXIS
		m_dma_axis_aresetn	=> s_m_dma_axis_aresetn,
		m_dma_axis_tvalid	=> s_m_dma_axis_tvalid,
		m_dma_axis_tdata	=> s_m_dma_axis_tdata,
		m_dma_axis_tlast	=> s_m_dma_axis_tlast,
		m_dma_axis_tready	=> s_m_dma_axis_tready,

		-- Ports of Axi Master Bus Interface M_DAC_AXIS
		m_dac_axis_aresetn	=> s_m_dac_axis_aresetn,
		m_dac_axis_tvalid	=> s_m_dac_axis_tvalid,
		m_dac_axis_tdata	=> s_m_dac_axis_tdata,
		m_dac_axis_tlast	=> s_m_dac_axis_tlast,
		m_dac_axis_tready	=> s_m_dac_axis_tready
	);
	
	p_adc_counter : process(s_clk_axis)
	begin
	   if rising_edge(s_clk_axis) then
	       adc_value <= adc_value + 1;
	   end if;
	end process;
	
	s_s_adc_axis_tdata <= "00" & std_logic_vector(adc_value) & "00" & not(std_logic_vector(adc_value));
	
	p_timeout : process
	begin
		wait for g_timeout;
		assert false report "timeout reached" severity failure;
		stop(1);
	end process;
	
	-- Initiate process which simulates a master wanting to write.
    -- This process is blocked on a "Read Flag" (sendIt).
    -- When the flag goes to 1, the process exits the wait state and
    -- execute a write transaction.
	write : process
    begin
        s_s_axi_lite_awvalid<='0';
        s_s_axi_lite_wvalid<='0';
        s_s_axi_lite_bready<='0';
        loop
            wait until sendIt = '1';
            wait until s_s_axi_lite_aclk= '0';
                s_s_axi_lite_awvalid<='1';
                s_s_axi_lite_wvalid<='1';
            wait until (s_s_axi_lite_awready and s_s_axi_lite_wready) = '1';  --Client ready to read address/data        
                s_s_axi_lite_bready<='1';
            wait until s_s_axi_lite_bvalid = '1';  -- Write result valid
                assert s_s_axi_lite_bresp = "00" report "AXI data not written" severity failure;
                s_s_axi_lite_awvalid<='0';
                s_s_axi_lite_wvalid<='0';
                s_s_axi_lite_bready<='1';
            wait until s_s_axi_lite_bvalid = '0';  -- All finished
                s_s_axi_lite_bready<='0';
        end loop;
    end process write;

    -- Initiate process which simulates a master wanting to read.
    -- This process is blocked on a "Read Flag" (readIt).
    -- When the flag goes to 1, the process exits the wait state and
    -- execute a read transaction.
    read : PROCESS
    BEGIN
       s_s_axi_lite_arvalid<='0';
       s_s_axi_lite_rready<='0';
       loop
           wait until readIt = '1';
           wait until s_s_axi_lite_aclk= '0';
               s_s_axi_lite_arvalid<='1';
               s_s_axi_lite_rready<='1';
            wait until (s_s_axi_lite_rvalid and s_s_axi_lite_arready) = '1';  --Client provided data
              assert s_s_axi_lite_rresp = "00" report "AXI data not written" severity failure;
               s_s_axi_lite_arvalid<='0';
               s_s_axi_lite_rready<='0';
       end loop;
    end process read;
    
     tb : PROCESS
 BEGIN
        s_s_axi_lite_aresetn<='0';
        sendIt<='0';
    wait for 25 ns;
        s_s_axi_lite_aresetn<='1';

        s_s_axi_lite_awaddr<= x"0" & b"00"; -- write to register 0x00 (DAC Sample Length)
        s_s_axi_lite_wdata<=x"000003FF"; -- value 1023 (0x400)
        s_s_axi_lite_wstrb<=b"1111";
        sendIt<='1';                --Start AXI Write to Slave
        wait for 1 ns; sendIt<='0'; --Clear Start Send Flag
        --s_s_axi_lite_tready <= '1';
    wait until s_s_axi_lite_bvalid = '1';
    wait until s_s_axi_lite_bvalid = '0';  --AXI Write finished
        s_s_axi_lite_wstrb<=b"0000";
            
        s_s_axi_lite_awaddr<=x"1" & b"00"; -- write to register 0x01 (ADC Number of Samples)
        s_s_axi_lite_wdata<=x"000005E8";    -- value 
        s_s_axi_lite_wstrb<=b"1111";
        sendIt<='1';                        --Start AXI Write to Slave
        wait for 1 ns; sendIt<='0';     --Clear Start Send Flag
    wait until s_s_axi_lite_bvalid = '1';
    wait until s_s_axi_lite_bvalid = '0';  --AXI Write finished
        s_s_axi_lite_wstrb<=b"0000";
        
        s_s_axi_lite_awaddr<=x"6" & b"00"; -- write to register 0x06 ADC-channel
        s_s_axi_lite_wdata<=x"00000002"; -- value 
        s_s_axi_lite_wstrb<=b"1111";
        sendIt<='1';                --Start AXI Write to Slave
        wait for 1 ns; sendIt<='0'; --Clear Start Send Flag
    wait until s_s_axi_lite_bvalid = '1';
    wait until s_s_axi_lite_bvalid = '0';  --AXI Write finished
        s_s_axi_lite_wstrb<=b"0000";
        
        s_s_axi_lite_awaddr<=x"5" & b"00"; -- write to register 0x05 (DAC Table Address)
        s_s_axi_lite_wdata<=x"0000000A"; -- value 0xA 
        s_s_axi_lite_wstrb<=b"1111";
        sendIt<='1';                --Start AXI Write to Slave
        wait for 1 ns; sendIt<='0'; --Clear Start Send Flag
        
    wait until s_s_axi_lite_bvalid = '1';
    wait until s_s_axi_lite_bvalid = '0';  --AXI Write finished
        s_s_axi_lite_wstrb<=b"0000";
                
        s_s_axi_lite_awaddr<=x"4" & b"00"; -- write to register 0x04 (DAC Table Data)
        s_s_axi_lite_wdata<=x"00000F00"; -- value 
        s_s_axi_lite_wstrb<=b"1111";
        sendIt<='1';                --Start AXI Write to Slave
        wait for 1 ns; sendIt<='0'; --Clear Start Send Flag
        
    wait until s_s_axi_lite_bvalid = '1';
    wait until s_s_axi_lite_bvalid = '0';  --AXI Write finished
        s_s_axi_lite_wstrb<=b"0000";
        
        
        
        s_s_axi_lite_awaddr<=x"2" & b"00"; -- write to register 0x02 (DAC Enable)
        s_s_axi_lite_wdata<=x"00000001";
        s_s_axi_lite_wstrb<=b"1111";
        sendIt<='1';                --Start AXI Write to Slave
        wait for 1 ns; sendIt<='0'; --Clear Start Send Flag
    wait until s_s_axi_lite_bvalid = '1';
    wait until s_s_axi_lite_bvalid = '0';  --AXI Write finished
        s_s_axi_lite_wstrb<=b"0000";
    
        s_s_axi_lite_araddr<=x"0" & b"00";
        readIt<='1';                --Start AXI Read from Slave
        wait for 1 ns; readIt<='0'; --Clear "Start Read" Flag
    wait until s_s_axi_lite_rvalid = '1';
    wait until s_s_axi_lite_rvalid = '0';
    
            s_s_axi_lite_araddr<=x"4" & b"00";
        readIt<='1';                --Start AXI Read from Slave
        wait for 1 ns; readIt<='0'; --Clear "Start Read" Flag
    wait until s_s_axi_lite_rvalid = '1';
    wait until s_s_axi_lite_rvalid = '0';
        
        wait for 5 us;
        s_s_axi_lite_awaddr<= x"3" & b"00"; -- write to register 0x03
        s_s_axi_lite_wdata<=x"00000001"; -- value 1024 (0x400)
        s_s_axi_lite_wstrb<=b"1111";
        sendIt<='1';                --Start AXI Write to Slave
        wait for 1 ns; sendIt<='0'; --Clear Start Send Flag
        --s_s_axi_lite_tready <= '1';
    wait until s_s_axi_lite_bvalid = '1';
    wait until s_s_axi_lite_bvalid = '0';  --AXI Write finished
        s_s_axi_lite_wstrb<=b"0000"; -- END 
    
    wait for 10 us;
    timeIt <= '1';
    wait for 1 ns; timeIt <= '0';
    s_s_axi_lite_awaddr<=x"1" & b"00"; -- write to register 0x04 (DAC Table Data)
    s_s_axi_lite_wdata<=x"0000036D"; -- value 
    s_s_axi_lite_wstrb<=b"1111";
    sendIt<='1';                --Start AXI Write to Slave
    wait for 1 ns; sendIt<='0'; --Clear Start Send Flag
        
    wait until s_s_axi_lite_bvalid = '1';
    wait until s_s_axi_lite_bvalid = '0';  --AXI Write finished
        s_s_axi_lite_wstrb<=b"0000";
    
    wait for g_timeout;
		assert false report "timeout reached" severity failure;
		stop(1);
 END PROCESS tb;


end Behavioral;