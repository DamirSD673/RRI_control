library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rri_control_v1_0_S_AXI_LITE is
	generic (
		-- Users to add parameters here
		C_DEFAULT_DAC_LENGTH : integer := 1023;

		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- Width of S_AXI data bus
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		-- Width of S_AXI address bus
		C_S_AXI_ADDR_WIDTH	: integer	:= 6
	);
	port (
		-- Users to add ports here
		table_addr : out std_logic_vector(15 downto 0);
		table_data : out std_logic_vector(13 downto 0);
		table_write_ena : out std_logic;
		dac_length : out std_logic_vector(15 downto 0);
		adc_length : out std_logic_vector(31 downto 0);
		adc_dma_channel : out std_logic_vector(1 downto 0);
		dac_enable : out std_logic;
		adc_dma_start : out std_logic;
		adc_dma_running : in std_logic;
		

		-- User ports ends
		-- Do not modify the ports beyond this line

		-- Global Clock Signal
		S_AXI_ACLK	: in std_logic;
		-- Global Reset Signal. This Signal is Active LOW
		S_AXI_ARESETN	: in std_logic;
		-- Write address (issued by master, acceped by Slave)
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		-- Write channel Protection type. This signal indicates the
    		-- privilege and security level of the transaction, and whether
    		-- the transaction is a data access or an instruction access.
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		-- Write address valid. This signal indicates that the master signaling
    		-- valid write address and control information.
		S_AXI_AWVALID	: in std_logic;
		-- Write address ready. This signal indicates that the slave is ready
    		-- to accept an address and associated control signals.
		S_AXI_AWREADY	: out std_logic;
		-- Write data (issued by master, acceped by Slave) 
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		-- Write strobes. This signal indicates which byte lanes hold
    		-- valid data. There is one write strobe bit for each eight
    		-- bits of the write data bus.    
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		-- Write valid. This signal indicates that valid write
    		-- data and strobes are available.
		S_AXI_WVALID	: in std_logic;
		-- Write ready. This signal indicates that the slave
    		-- can accept the write data.
		S_AXI_WREADY	: out std_logic;
		-- Write response. This signal indicates the status
    		-- of the write transaction.
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		-- Write response valid. This signal indicates that the channel
    		-- is signaling a valid write response.
		S_AXI_BVALID	: out std_logic;
		-- Response ready. This signal indicates that the master
    		-- can accept a write response.
		S_AXI_BREADY	: in std_logic;
		-- Read address (issued by master, acceped by Slave)
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		-- Protection type. This signal indicates the privilege
    		-- and security level of the transaction, and whether the
    		-- transaction is a data access or an instruction access.
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		-- Read address valid. This signal indicates that the channel
    		-- is signaling valid read address and control information.
		S_AXI_ARVALID	: in std_logic;
		-- Read address ready. This signal indicates that the slave is
    		-- ready to accept an address and associated control signals.
		S_AXI_ARREADY	: out std_logic;
		-- Read data (issued by slave)
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		-- Read response. This signal indicates the status of the
    		-- read transfer.
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		-- Read valid. This signal indicates that the channel is
    		-- signaling the required read data.
		S_AXI_RVALID	: out std_logic;
		-- Read ready. This signal indicates that the master can
    		-- accept the read data and response information.
		S_AXI_RREADY	: in std_logic
	);
end rri_control_v1_0_S_AXI_LITE;

architecture arch_imp of rri_control_v1_0_S_AXI_LITE is

	-- AXI4LITE signals
	signal axi_awaddr	: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	signal axi_awready	: std_logic;
	signal axi_wready	: std_logic;
	signal axi_bresp	: std_logic_vector(1 downto 0);
	signal axi_bvalid	: std_logic;
	signal axi_araddr	: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	signal axi_arready	: std_logic;
	signal axi_rdata	: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal axi_rresp	: std_logic_vector(1 downto 0);
	signal axi_rvalid	: std_logic;

	-- Example-specific design signals
	-- local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	-- ADDR_LSB is used for addressing 32/64 bit registers/memories
	-- ADDR_LSB = 2 for 32 bits (n downto 2)
	-- ADDR_LSB = 3 for 64 bits (n downto 3)
	constant ADDR_LSB  : integer := (C_S_AXI_DATA_WIDTH/32)+ 1;
	--constant OPT_MEM_ADDR_BITS : integer := 2;
	------------------------------------------------
	---- Signals for user logic register space example
	--------------------------------------------------
	---- Number of Slave Registers 4
	--signal slv_reg0	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	--signal slv_reg1	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	--signal slv_reg2	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	--signal slv_reg3	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal reg_dac_length : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal reg_adc_length : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal reg_adc_dma_status : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal reg_adc_dma_start_req : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal reg_dac_enable : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal reg_dac_table_data : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal reg_dac_table_addr : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	
	
	signal dac_enable_int :std_logic := '0';
	signal dac_ram_write_ena : std_logic;
	signal dac_ram_write_ena_delay : std_logic;
	signal dac_ram_data : std_logic_vector(13 downto 0);
	signal dac_ram_addr : std_logic_vector(15 downto 0);
	signal dac_ram_ena : std_logic;
	
	--signal req_dac_ena_reset : std_logic;
	signal dac_length_out : std_logic_vector(15 downto 0);
	signal adc_length_out : std_logic_vector(31 downto 0);
	signal adc_start_int : std_logic := '0';
	signal reg_adc_channel : std_logic_vector(31 downto 0);
	signal slv_reg_rden	: std_logic;
	signal slv_reg_wren	: std_logic;
	signal reg_data_out	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal byte_index	: integer;
	signal aw_en	: std_logic;
	

begin
	-- I/O Connections assignments

	S_AXI_AWREADY	<= axi_awready;
	S_AXI_WREADY	<= axi_wready;
	S_AXI_BRESP	<= axi_bresp;
	S_AXI_BVALID	<= axi_bvalid;
	S_AXI_ARREADY	<= axi_arready;
	S_AXI_RDATA	<= axi_rdata;
	S_AXI_RRESP	<= axi_rresp;
	S_AXI_RVALID	<= axi_rvalid;
	dac_enable <= dac_enable_int;
	dac_length <= dac_length_out;
	adc_length <= adc_length_out;
	adc_dma_start <= adc_start_int;
	
	table_addr <= dac_ram_addr;
	table_data <= dac_ram_data;
	table_write_ena <= dac_ram_ena;
	
	
	
	
	-- Implement axi_awready generation
	-- axi_awready is asserted for one S_AXI_ACLK clock cycle when both
	-- S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
	-- de-asserted when reset is low.

	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_awready <= '0';
	      aw_en <= '1';
	    else
	      if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1' and aw_en = '1') then
	        -- slave is ready to accept write address when
	        -- there is a valid write address and write data
	        -- on the write address and data bus. This design 
	        -- expects no outstanding transactions. 
	           axi_awready <= '1';
	           aw_en <= '0';
	        elsif (S_AXI_BREADY = '1' and axi_bvalid = '1') then
	           aw_en <= '1';
	           axi_awready <= '0';
	      else
	        axi_awready <= '0';
	      end if;
	    end if;
	  end if;
	end process;

	-- Implement axi_awaddr latching
	-- This process is used to latch the address when both 
	-- S_AXI_AWVALID and S_AXI_WVALID are valid. 

	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_awaddr <= (others => '0');
	    else
	      if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1' and aw_en = '1') then
	        -- Write Address latching
	        axi_awaddr <= S_AXI_AWADDR;
	      end if;
	    end if;
	  end if;                   
	end process; 

	-- Implement axi_wready generation
	-- axi_wready is asserted for one S_AXI_ACLK clock cycle when both
	-- S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
	-- de-asserted when reset is low. 

	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_wready <= '0';
	    else
	      if (axi_wready = '0' and S_AXI_WVALID = '1' and S_AXI_AWVALID = '1' and aw_en = '1') then
	          -- slave is ready to accept write data when 
	          -- there is a valid write address and write data
	          -- on the write address and data bus. This design 
	          -- expects no outstanding transactions.           
	          axi_wready <= '1';
	      else
	        axi_wready <= '0';
	      end if;
	    end if;
	  end if;
	end process; 

	-- Implement memory mapped register select and write logic generation
	-- The write data is accepted and written to memory mapped registers when
	-- axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
	-- select byte enables of slave registers while writing.
	-- These registers are cleared when reset (active low) is applied.
	-- Slave register write enable is asserted when valid address and data are available
	-- and the slave is ready to accept the write address and write data.
	slv_reg_wren <= axi_wready and S_AXI_WVALID and axi_awready and S_AXI_AWVALID ;

	process (S_AXI_ACLK)
	variable loc_addr :std_logic_vector(3 downto 0); 
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      reg_dac_length <= std_logic_vector(to_unsigned(C_DEFAULT_DAC_LENGTH, reg_dac_length'length));
	      reg_adc_length <= (others => '0');
	      reg_adc_dma_start_req <= (others => '0');
	      reg_dac_enable <= (others => '0');
	      reg_dac_table_data <= (others => '0');
	      reg_dac_table_addr <= (others => '0');
	      dac_ram_write_ena <= '0';
	      dac_ram_write_ena_delay <= '0';
	    else
	      loc_addr := axi_awaddr(C_S_AXI_ADDR_WIDTH -1 downto ADDR_LSB);
	      dac_ram_write_ena_delay <= dac_ram_write_ena;
	      if (slv_reg_wren = '1') then
	        case loc_addr is
	          when x"0" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 0
	                reg_dac_length(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when x"1" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 1
	                reg_adc_length(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when x"2" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 2
	                reg_dac_enable(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when x"3" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 3
	                reg_adc_dma_start_req(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when x"4" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 4
	                reg_dac_table_data(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	              
	            end loop;
	            reg_dac_enable(0) <= '0';
	            dac_ram_write_ena <= '1';
	          when x"5" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 5
	                reg_dac_table_addr(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	            reg_dac_enable(0) <= '0';
			when x"6" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 6
	                reg_adc_channel(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	            reg_adc_channel(31 downto 2) <= (others => '0');
	          when others =>
	             reg_dac_length <= reg_dac_length;
	             reg_adc_length <= reg_adc_length;
	             reg_adc_dma_start_req <= (others => '0');
	             reg_dac_enable <= reg_dac_enable;
	             reg_dac_table_data <= reg_dac_table_data;
	             reg_dac_table_addr <= reg_dac_table_addr;
	        end case;
	      else
	          reg_adc_dma_start_req <= (others => '0');
	          dac_ram_write_ena <= '0';
	      end if;
	    end if;
	  end if;                   
	end process; 

	-- Implement write response logic generation
	-- The write response and response valid signals are asserted by the slave 
	-- when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
	-- This marks the acceptance of address and indicates the status of 
	-- write transaction.

	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_bvalid  <= '0';
	      axi_bresp   <= "00"; --need to work more on the responses
	    else
	      if (axi_awready = '1' and S_AXI_AWVALID = '1' and axi_wready = '1' and S_AXI_WVALID = '1' and axi_bvalid = '0'  ) then
	        axi_bvalid <= '1';
	        axi_bresp  <= "00"; 
	      elsif (S_AXI_BREADY = '1' and axi_bvalid = '1') then   --check if bready is asserted while bvalid is high)
	        axi_bvalid <= '0';                                 -- (there is a possibility that bready is always asserted high)
	      end if;
	    end if;
	  end if;                   
	end process; 

	-- Implement axi_arready generation
	-- axi_arready is asserted for one S_AXI_ACLK clock cycle when
	-- S_AXI_ARVALID is asserted. axi_awready is 
	-- de-asserted when reset (active low) is asserted. 
	-- The read address is also latched when S_AXI_ARVALID is 
	-- asserted. axi_araddr is reset to zero on reset assertion.

	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_arready <= '0';
	      axi_araddr  <= (others => '1');
	    else
	      if (axi_arready = '0' and S_AXI_ARVALID = '1') then
	        -- indicates that the slave has acceped the valid read address
	        axi_arready <= '1';
	        -- Read Address latching 
	        axi_araddr  <= S_AXI_ARADDR;           
	      else
	        axi_arready <= '0';
	      end if;
	    end if;
	  end if;                   
	end process; 

	-- Implement axi_arvalid generation
	-- axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
	-- S_AXI_ARVALID and axi_arready are asserted. The slave registers 
	-- data are available on the axi_rdata bus at this instance. The 
	-- assertion of axi_rvalid marks the validity of read data on the 
	-- bus and axi_rresp indicates the status of read transaction.axi_rvalid 
	-- is deasserted on reset (active low). axi_rresp and axi_rdata are 
	-- cleared to zero on reset (active low).  
	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then
	    if S_AXI_ARESETN = '0' then
	      axi_rvalid <= '0';
	      axi_rresp  <= "00";
	    else
	      if (axi_arready = '1' and S_AXI_ARVALID = '1' and axi_rvalid = '0') then
	        -- Valid read data is available at the read data bus
	        axi_rvalid <= '1';
	        axi_rresp  <= "00"; -- 'OKAY' response
	      elsif (axi_rvalid = '1' and S_AXI_RREADY = '1') then
	        -- Read data is accepted by the master
	        axi_rvalid <= '0';
	      end if;            
	    end if;
	  end if;
	end process;

	-- Implement memory mapped register select and read logic generation
	-- Slave register read enable is asserted when valid address is available
	-- and the slave is ready to accept the read address.
	slv_reg_rden <= axi_arready and S_AXI_ARVALID and (not axi_rvalid) ;

	process (reg_dac_length, reg_adc_length, reg_adc_dma_status, reg_dac_enable, reg_dac_table_data, reg_dac_table_addr, reg_adc_channel, axi_araddr, S_AXI_ARESETN, slv_reg_rden)
	variable loc_addr :std_logic_vector(C_S_AXI_ADDR_WIDTH-ADDR_LSB-1 downto 0);
	begin
	    -- Address decoding for reading registers
	    loc_addr := axi_araddr(C_S_AXI_ADDR_WIDTH-1 downto ADDR_LSB);
	    case loc_addr is
	      when x"0" =>
	        reg_data_out <= reg_dac_length;
	      when x"1" =>
	        reg_data_out <= reg_adc_length;
	      when x"2" =>
	        reg_data_out <= reg_adc_dma_status;
	      when x"3" =>
	        reg_data_out <= reg_dac_enable;
	      when x"4" =>
	        reg_data_out <= reg_dac_table_data;
	      when x"5" =>
	        reg_data_out <= reg_dac_table_addr;
		  when x"6" =>
			reg_data_out <= reg_adc_channel;
	      when others =>
	        reg_data_out  <= (others => '0');
	    end case;
	end process;
	
	-- DMA Start Routine
	process( S_AXI_ACLK ) is
	begin
	  if (rising_edge (S_AXI_ACLK)) then
	    if ( S_AXI_ARESETN = '0' ) then
	      reg_adc_dma_status <= (others => '0');
	      adc_start_int  <= '0';
	    else
	       reg_adc_dma_status(0) <= adc_dma_running;
	       if reg_adc_dma_start_req(0) = '1' and  reg_adc_dma_status(0) = '0' then
	           adc_start_int  <= '1';
	       elsif reg_adc_dma_status(0) = '1' then
	           adc_start_int  <= '0';
	       end if;
	    end if;
	  end if;
	end process;
	

	-- Output register or memory read data
	process( S_AXI_ACLK ) is
	begin
	  if (rising_edge (S_AXI_ACLK)) then
	    if ( S_AXI_ARESETN = '0' ) then
	      axi_rdata  <= (others => '0');
	    else
	      if (slv_reg_rden = '1') then
	        -- When there is a valid read address (S_AXI_ARVALID) with 
	        -- acceptance of read address by the slave (axi_arready), 
	        -- output the read dada 
	        -- Read address mux
	          axi_rdata <= reg_data_out;     -- register read data
	      end if;   
	    end if;
	  end if;
	end process;
	
	-- Output DAC Enable
	process( S_AXI_ACLK ) is
	begin
	  if (rising_edge (S_AXI_ACLK)) then
	    if ( S_AXI_ARESETN = '0' ) then
	      dac_enable_int  <= '0';
	    else
	      if reg_dac_enable(0) = '1' then
	          dac_enable_int  <= '1';
	      else
	          dac_enable_int  <= '0';
	      end if;   
	    end if;
	  end if;
	end process;
	
	
	-- Output DAC Length
	process( S_AXI_ACLK ) is
	begin
	  if (rising_edge (S_AXI_ACLK)) then
	    if ( S_AXI_ARESETN = '0' ) then
	      dac_length_out  <= (others => '0');
	    else
	      if unsigned(reg_dac_length) >= x"FFFF" then
	          dac_length_out <= x"FFFF";
	      else
	          dac_length_out <= reg_dac_length(15 downto 0);
	      end if;   
	    end if;
	  end if;
	end process;
	
	-- Output ADC Length
	process( S_AXI_ACLK ) is
	begin
	  if (rising_edge (S_AXI_ACLK)) then
	    if ( S_AXI_ARESETN = '0' ) then
	      adc_length_out  <= (others => '0');
	    else
	      if unsigned(reg_dac_length) >= x"1FFFFFF" then
	          adc_length_out <= x"01FFFFFF";
	      else
	          adc_length_out <= reg_adc_length;
	      end if;   
	    end if;
	  end if;
	end process;
	
	-- Output DAC RAM Data
	process( S_AXI_ACLK ) is
	begin
	  if (rising_edge (S_AXI_ACLK)) then
	    if ( S_AXI_ARESETN = '0' ) then
	      dac_ram_addr <= (others => '0');
	      dac_ram_data <= (others => '0');
	      dac_ram_ena <= '0';
	    else
	       if (dac_ram_write_ena = '1' and dac_ram_write_ena_delay = '0') then
	           if unsigned(reg_dac_table_data) > x"3FFF" then
	               dac_ram_data <= (others => '1');
	           else
	               dac_ram_data <= reg_dac_table_data(13 downto 0);
	           end if;
	           if unsigned(reg_dac_table_addr) > x"FFFF" then
	               dac_ram_addr <= (others => '1');
	           else
	               dac_ram_addr <= reg_dac_table_addr(15 downto 0);
	           end if;
	           dac_ram_ena <= '1';
	       else
	           dac_ram_ena <= '0';
	           dac_ram_addr <= (others => '0');
	           dac_ram_data <= (others => '0');
	       end if;
	    end if;
	  end if;
	end process;

	-- Output ADC channel 
	process( S_AXI_ACLK ) is
		begin
		  if (rising_edge (S_AXI_ACLK)) then
			if ( S_AXI_ARESETN = '0' ) then
			  	adc_dma_channel  <= b"00";
			else
				adc_dma_channel <= reg_adc_channel(1 downto 0);
			end if;
		  end if;
		end process;

end arch_imp;
