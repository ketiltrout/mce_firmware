
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library sys_param;
use sys_param.wishbone_pack.all;

library components;
use components.component_pack.all;


entity sram_ctrl is
generic(ADDR_WIDTH     : integer := WB_ADDR_WIDTH;
        DATA_WIDTH     : integer := WB_DATA_WIDTH;
        TAG_ADDR_WIDTH : integer := WB_TAG_ADDR_WIDTH);
        
port(-- SRAM signals:
     addr_o  : out std_logic_vector(19 downto 0);
     data_bi : inout std_logic_vector(15 downto 0);
     n_ble_o : out std_logic;
     n_bhe_o : out std_logic;
     n_oe_o  : out std_logic;
     n_ce1_o : out std_logic;
     ce2_o   : out std_logic;
     n_we_o  : out std_logic;
     
     -- wishbone signals:
     clk_i   : in std_logic;
     rst_i   : in std_logic;		
     dat_i 	 : in std_logic_vector (DATA_WIDTH-1 downto 0);
     addr_i  : in std_logic_vector (ADDR_WIDTH-1 downto 0); --define addr_width in pack file
     tga_i   : in std_logic_vector (TAG_ADDR_WIDTH-1 downto 0);
     we_i    : in std_logic;
     stb_i   : in std_logic;
     cyc_i   : in std_logic;
     dat_o   : out std_logic_vector (DATA_WIDTH-1 downto 0);
     rty_o   : out std_logic;
     ack_o   : out std_logic);     
end sram_ctrl;

architecture behav of sram_ctrl is

-- state encodings:
constant IDLE       : std_logic_vector(2 downto 0) := "000";
constant WRITE_LSB  : std_logic_vector(2 downto 0) := "001";
constant WRITE_MSB  : std_logic_vector(2 downto 0) := "010";
constant WRITE_DONE : std_logic_vector(2 downto 0) := "011";
constant READ_LSB   : std_logic_vector(2 downto 0) := "100";
constant READ_MSB   : std_logic_vector(2 downto 0) := "101";
constant SEND_DATA  : std_logic_vector(2 downto 0) := "110";
constant READ_DONE  : std_logic_vector(2 downto 0) := "111";

-- state variables:
signal present_state : std_logic_vector(2 downto 0);
signal next_state    : std_logic_vector(2 downto 0);

-- SRAM control:
signal ce_ctrl : std_logic;
signal wr_ctrl : std_logic;

-- SRAM data out buffer:
signal read_buf     : std_logic_vector(DATA_WIDTH-1 downto 0);
signal read_buf_ena : std_logic_vector(1 downto 0);  -- enables for each part of the data word.

-- wishbone status:
signal read_cycle  : std_logic;
signal write_cycle : std_logic;

begin
   
   -- SRAM is permanently enabled (but still controlled by CE)
   n_ble_o <= '0';
   n_bhe_o <= '0';
   n_oe_o  <= '0';
   n_we_o  <= sram_wr_ctrl;
   n_ce1_o <= not sram_ce_ctrl;
   ce2_o   <= sram_ce_ctrl;
        
      
   -- buffer SRAM data out:
   read_data_lsb: reg
      generic map(WIDTH => 16)
      port map(clk_i  => clk_i,
               rst_i  => rst_i,
               ena_i  => read_buf_ena(0),
               reg_i  => data_bi,
               reg_o  => read_buf(15 downto 0));
   
   read_data_msb: reg
      generic map(WIDTH => 16)
      port map(clk_i  => clk_i,
               rst_i  => rst_i,
               ena_i  => read_buf_ena(1),
               reg_i  => data_bi,
               reg_o  => read_buf(31 downto 16));
      
   
   -- state machine for writing to two SRAM locations for each WB transaction:
   state_FF: process(clk_i)
   begin
      if(rst_i = '1') then
         present_state <= idle;
      else
         present_state <= next_state;
      end if;
   end process state_FF;
   
   state_NS: process(present_state, read_cycle, write_cycle)
   begin
      case present_state is
         when IDLE =>       if(write_cycle = '1') then
                               next_state <= WRITE_LSB;
                            elsif(read_cycle = '1') then
                               next_state <= READ_LSB;
                            else
                               next_state <= IDLE;
                            end if;
                            
         when WRITE_LSB =>  next_state <= WRITE_MSB;
         
         when WRITE_MSB =>  next_state <= WRITE_DONE;
         
         when WRITE_DONE => if(write_cycle = '1') then
                               next_state <= WRITE_LSB;
                            else
                               next_state <= IDLE;
                            end if;
         
         when READ_LSB =>   next_state <= READ_MSB;
         
         when READ_MSB =>   next_state <= SEND_DATA;
         
         when SEND_DATA =>  next_state <= READ_DONE;
         
         when READ_DONE =>  if(read_cycle = '1') then
                               next_state <= READ_LSB;
                            else
                               next_state <= IDLE;
                            end if;
         
         when others =>     next_state <= IDLE;
      end case;
   end process state_NS;
   
   state_out: process(present_state)
   begin
      case present_state is
         when IDLE =>       ce_ctrl <= '0';
                            wr_ctrl <= '0';
                            read_buf_ena <= "00";
                            addr_o  <= (others => '0');
                            data_bi <= (others => 'Z');
                            
         when WRITE_LSB =>  ce_ctrl <= '1';
                            wr_ctrl <= '1';
                            read_buf_ena <= "00";
                            addr_o  <= tga_i(18 downto 0) & '0';
                            data_bi <= dat_i(15 downto 0);
                                                        
         when WRITE_MSB =>  ce_ctrl <= '1';
                            wr_ctrl <= '1';
                            read_buf_ena <= "00";
                            addr_o <= tga_i(18 downto 0) & '1';
                            data_bi <= dat_i(31 downto 16);
                                                        
         when WRITE_DONE => ce_ctrl <= '0';
                            m_wr_ctrl <= '0';
                            read_buf_ena <= "00";
                            addr_o <= (others => '0');
                                                        
         when READ_LSB =>   sram_ce_ctrl <= '1';
                            sram_wr_ctrl <= '0';
                            read_buf_ena <= "01";
                            addr_o <= tga_i(18 downto 0) & '0';
                                                        
         when READ_MSB =>   sram_ce_ctrl <= '1';
                            sram_wr_ctrl <= '0';
                            read_buf_ena <= "10";
                            addr_o <= tga_i(18 downto 0) & '1';
                                                        
         when SEND_DATA =>  sram_ce_ctrl <= '0';
                            sram_wr_ctrl <= '0';
                            read_buf_ena <= "00";
                            addr_o <= (others => '0');
                                                        
         when READ_DONE =>  sram_ce_ctrl <= '0';
                            sram_wr_ctrl <= '0';
                            read_buf_ena <= "00";
                            addr_o <= (others => '0');
                                                        
         when others =>     sram_ce_ctrl <= '0';
                            sram_wr_ctrl <= '0';
                            read_buf_ena <= "00";
                            addr_o <= (others => '0');                            
      end case;
   end process state_out;
   
   -- wishbone interface status signals
   ack_o <= '1' when (present_state = WRITE_MSB or present_state = SEND_DATA) else '0';
   rty_o <= '0';  -- never retry
   dat_o <= read_buf;
   
   read_cycle  <= '1' when (addr_i = SRAM_ADDR and stb_i = '1' and cyc_i = '1' and we_i = '0') else '0';
   write_cycle <= '1' when (addr_i = SRAM_ADDR and stb_i = '1' and cyc_i = '1' and we_i = '1') else '0'; 
   
end behav;