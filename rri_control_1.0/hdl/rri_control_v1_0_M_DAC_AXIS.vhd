library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rri_control_v1_0_M_DAC_AXIS is
	generic (
		-- Users to add parameters here
		C_DAC_RAM_DATA_WIDTH : integer := 14;

		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- Width of S_AXIS address bus. The slave accepts the read and write addresses of width C_M_AXIS_TDATA_WIDTH.
		C_M_AXIS_TDATA_WIDTH	: integer	:= 16
	);
	port (
		-- Users to add ports here
		
		dac_ram_data : in std_logic_vector (C_DAC_RAM_DATA_WIDTH-1 downto 0);
		
		output_enable : in std_logic;
		
		-- User ports ends
		-- Do not modify the ports beyond this line

		-- Global ports
		M_AXIS_ACLK	: in std_logic;
		--
		M_AXIS_TLAST	: out std_logic;
		-- TLAST indicates the boundary of a packet.
		M_AXIS_ARESETN	: in std_logic;
		-- Master Stream Ports. TVALID indicates that the master is driving a valid transfer, A transfer takes place when both TVALID and TREADY are asserted. 
		M_AXIS_TVALID	: out std_logic;
		-- TDATA is the primary payload that is used to provide the data that is passing across the interface from the master.
		M_AXIS_TDATA	: out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
		-- TSTRB is the byte qualifier that indicates whether the content of the associated byte of TDATA is processed as a data byte or a position byte.
		M_AXIS_TREADY	: in std_logic
	);
end rri_control_v1_0_M_DAC_AXIS;

architecture implementation of rri_control_v1_0_M_DAC_AXIS is     
	--streaming data valid
	signal axis_tvalid	: std_logic := '0';
	--streaming data las
	signal axis_tlast	: std_logic := '0';
	--FIFO implementation signals
	signal stream_data_out	: std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0) := (others => '0');


begin
	-- I/O Connections assignments

    M_AXIS_TLAST    <= axis_tlast;
	M_AXIS_TVALID	<= axis_tvalid;
	M_AXIS_TDATA	<= stream_data_out;


	-- Control state machine implementation                                               
	process(M_AXIS_ACLK)                                                                        
	begin                                                                                       
	   if (rising_edge (M_AXIS_ACLK)) then
	       if M_AXIS_ARESETN = '0' then
	           axis_tvalid <= '0';
	           stream_data_out <= (others => '0');
	       else
               if (output_enable = '1') then
                   axis_tvalid <= '1';
                   stream_data_out <= std_logic_vector(resize(signed(dac_ram_data), C_M_AXIS_TDATA_WIDTH));
               else
                   axis_tvalid <= '0';
                   stream_data_out <= (others => '0');
               end if;
	       end if;                                                                                                                         
	   end if;                                                                                   
	end process;                                                                                

                                                               

	-- Add user logic here

	-- User logic ends

end implementation;
