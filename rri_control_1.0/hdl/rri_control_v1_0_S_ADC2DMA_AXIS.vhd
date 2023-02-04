library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rri_control_v1_0_S_ADC2DMA_AXIS is
	generic (
		-- Users to add parameters here

        -- DMA DATA Width		
		C_M_AXIS_TDATA_WIDTH	: integer	:= 64;

		-- AXI4Stream sink: Data Width
		C_S_AXIS_TDATA_WIDTH	: integer	:= 32
		
	);
	port (
		-- Users to add ports here
		dma_output_enable : in std_logic;		
		dma_last_value : in std_logic;
		dma_channel : in std_logic_vector(1 downto 0);

		-- AXI4Stream Clock
		AXIS_ACLK	: in std_logic;
		-- AXI4Stream sink: Reset
		S_AXIS_ARESETN	: in std_logic;
		-- Ready to accept data in
		S_AXIS_TREADY	: out std_logic;
		-- Data in
		S_AXIS_TDATA	: in std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
		-- Byte qualifier
		S_AXIS_TLAST	: in std_logic;
		-- Data is in valid
		S_AXIS_TVALID	: in std_logic;
		
		M_AXIS_ARESETN	: in std_logic;
		-- Master Stream Ports. TVALID indicates that the master is driving a valid transfer, A transfer takes place when both TVALID and TREADY are asserted. 
		M_AXIS_TVALID	: out std_logic;
		-- TDATA is the primary payload that is used to provide the data that is passing across the interface from the master.
		M_AXIS_TDATA	: out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
		-- TLAST indicates the boundary of a packet.
		M_AXIS_TLAST	: out std_logic;
		-- TREADY indicates that the slave can accept a transfer in the current cycle.
		M_AXIS_TREADY	: in std_logic
	);
end rri_control_v1_0_S_ADC2DMA_AXIS;

architecture arch_imp of rri_control_v1_0_S_ADC2DMA_AXIS is
	-- Total number of input data.
	constant NUMBER_OF_INPUT_WORDS  : integer := 8;
	-- bit_num gives the minimum number of bits needed to address 'NUMBER_OF_INPUT_WORDS' size of FIFO.
	-- Define the states of state machine
	-- The control state machine oversees the writing of input streaming data to the FIFO,
	-- and outputs the streaming data from the FIFO
	type state is ( IDLE,        -- This is the initial/idle state 
	                WRITE_FIFO); -- In this state FIFO is written with the
	                             -- input stream data S_AXIS_TDATA 
	signal axis_tready	: std_logic := '0';
	-- State variable
	signal  mst_exec_state : state := IDLE;  
	-- FIFO implementation signals
	signal data_in_reg : std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
	signal dma_channel_active: std_logic_vector(1 downto 0);
	
	signal data_counter : unsigned(1 downto 0);
	signal data_counter_last : unsigned(1 downto 0);
	
	signal dma_data_last : std_logic := '0';
	signal dma_data_last_delay : std_logic := '0';
	signal dma_data_valid : std_logic := '0';
	signal dma_data : std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
	
	signal dma_enable_delay : std_logic := '0';
	
	signal dma_running_int : std_logic := '0';
	
	signal write_enable : std_logic := '0';
	
begin
	-- I/O Connections assignments
	M_AXIS_TDATA <= dma_data;
	M_AXIS_TVALID <= dma_data_valid;
	M_AXIS_TLAST <= dma_data_last;
	

	S_AXIS_TREADY	<= axis_tready;
	
	process (AXIS_ACLK)
	begin
	  if rising_edge(AXIS_ACLK) then 
	    if S_AXIS_ARESETN = '0' then
	       axis_tready <= '0';
	    else
	       axis_tready <= '1';
	    end if;
	  end if;
    end process;
	
	process (AXIS_ACLK)
	begin
		if rising_edge(AXIS_ACLK) then 
			if S_AXIS_ARESETN = '0' then
	      	data_counter <= b"00";
	      	dma_data_last_delay <= '0';
	      
	      	data_counter_last <= b"00";
	      	data_in_reg <= (others => '0');
	      	dma_enable_delay <= '0';
	      	write_enable <= '0';
	      	dma_running_int <= '0';
	    else
	    	dma_enable_delay <= dma_output_enable;
	    	dma_data_last_delay <= dma_last_value;
	        dma_channel_active <= dma_channel;
	       	if (dma_output_enable = '1') then
	        	-- Choice of the ADC channel 
	       		case dma_channel_active is
	            	when "01" => --Channel A
	                   	case data_counter is
	                        when "00" =>
	                            data_in_reg(15 downto 0) <= S_AXIS_TDATA(15 downto 0);
	                        when "01" =>
	                           	data_in_reg(31 downto 16) <= S_AXIS_TDATA(15 downto 0);
	                        when "10" =>
	                           	data_in_reg(47 downto 32) <= S_AXIS_TDATA(15 downto 0);
	                        when "11" =>
	                           	data_in_reg(63 downto 48) <= S_AXIS_TDATA(15 downto 0);
	                        when others => -- 'U', 'X', '-', etc.
                                data_in_reg <= (others => 'X');
	                    end case;
	               	when "10" => -- Channel B
	                    case data_counter is
	                        when "00" =>
	                        	data_in_reg(15 downto 0) <= S_AXIS_TDATA(31 downto 16);
	                        when "01" =>
	                        	data_in_reg(31 downto 16) <= S_AXIS_TDATA(31 downto 16);
	                        when "10" =>
	                        	data_in_reg(47 downto 32) <= S_AXIS_TDATA(31 downto 16);
	                        when "11" =>
	                            data_in_reg(63 downto 48) <= S_AXIS_TDATA(31 downto 16);
	                        when others => -- 'U', 'X', '-', etc.
                                data_in_reg <= (others => 'X');
	                     end case;
	               	when "11" => -- Channel A and B
	                   	case data_counter is 
	                       	when "00" =>
	                           	data_in_reg(31 downto 0) <= S_AXIS_TDATA;
	                       	when "01" =>
	                           	data_in_reg(63 downto 32) <= S_AXIS_TDATA;
							when "10" =>
								data_in_reg(31 downto 0) <= S_AXIS_TDATA;
							when "11" =>
								data_in_reg(63 downto 32) <= S_AXIS_TDATA;
	                       when others =>
	                           	data_in_reg <= (others => 'X');
	                   	end case;
	               	when others =>
	                   	data_in_reg <= (others => 'X');
	           	end case;
	           
	           	if dma_last_value = '1' then
	               	data_counter <= b"00";
	               	data_counter_last <= data_counter;
	               	write_enable <= '1';
	           	else
					if dma_channel_active = b"11" then
						if data_counter = b"01" then
							write_enable <= '1';
							data_counter <= b"00";
						else
							write_enable <= '0';
							data_counter <= data_counter + 1;
						end if;							
					else
	            		if data_counter = b"11" then
	                   		write_enable <= '1';
							data_counter <= b"00";
	            		else
	                   		write_enable <= '0';
							data_counter <= data_counter + 1;
	            		end if;
				   end if;
	           	end if;
	        else
	           	write_enable <= '0';
	           	data_in_reg <= (others => '0');
	           	data_counter <= b"00";
	        end if;
	    end if;
	  end if;
	end process;
	
	process (AXIS_ACLK)
	begin
	  	if rising_edge(AXIS_ACLK) then 
	    	if S_AXIS_ARESETN = '0' then
	      		dma_data_valid <= '0';
	      		dma_data <= (others => '0');
	      		dma_data_last <= '0';
	    	else
	       		if write_enable = '1' then
	        		if (dma_data_last_delay = '1') then
						if dma_channel_active /= b"11" then -- Channel A or B data
                			for data_index in 0 to 3 loop
                    			if data_index > data_counter_last then
                        			dma_data(data_index*16+15 downto data_index*16) <= (others => '0');
                    			else
                        			dma_data(data_index*16+15 downto data_index*16) <= data_in_reg(data_index*16+15 downto data_index*16);
                    			end if;
                			end loop;
						else -- Both channels
							for data_index in 0 to 1 loop
								if data_index > data_counter_last then
									dma_data(data_index*32+31 downto data_index*32) <= (others => '0');
								else
									dma_data(data_index*32+31 downto data_index*32) <= data_in_reg(data_index*32+31 downto data_index*32);
								end if;
							end loop;
						end if;
               		else
                    	dma_data <= data_in_reg;
               		end if;
               		dma_data_last <= dma_data_last_delay;
	           		dma_data_valid <= '1';
	       		else
	           		dma_data <= (others => '0');
	           		dma_data_last <= '0';
	           		dma_data_valid <= '0';
	       		end if;
	    	end if;
		end if;
	end process;     
	

end arch_imp;
