---------------------------------------------------------------------
-- Copyright (c) 2003 UK Astronomy Technology Centre
--                All Rights Reserved
--
--  THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE UK ATC
--  The copyright notice above does not evidence any
--  actual or intended publication of such source code.
--
--  SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
--  REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
--  MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
--  PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
--  THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.
--
-- Project:             Scuba 2
-- Author:              Neil Gruending
-- Organisation:        UBC Physics and Astronomy
--
-- Description:
-- Idle state function.
-- 
-- Revision History:
--
-- $Log$
--
-- Feb 15, 2004: Initial version - NRG
-- Feb 25, 2004: Added serial commands - NRG
-- Feb 28, 2004: Capitalized state names - NRG
-- Mar 01, 2004: Added CMD_LED_3 - NRG
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
use work.all_test_pack.all;

entity all_test_idle is
   port (
      -- basic signals
      rst_i : in std_logic;   -- reset input
      clk_i : in std_logic;   -- clock input
      en_i : in std_logic;    -- enable signal
      done_o : out std_logic; -- done ouput signal
      
      -- transmitter signals
      tx_busy_i : in std_logic;  -- transmit busy flag
      tx_ack_i : in std_logic;   -- transmit ack
      tx_data_o : out std_logic_vector(7 downto 0);   -- transmit data
      tx_we_o : out std_logic;   -- transmit write flag
      tx_stb_o : out std_logic;  -- transmit strobe flag
      
      -- extended signals
      cmd1_o : out std_logic_vector(7 downto 0); -- command char 1
      cmd2_o : out std_logic_vector(7 downto 0); -- command char 2
      
      -- receiver signals
      rx_valid_i : in std_logic;  -- receive data flag
      rx_ack_i : in std_logic;   -- receive ack
      rx_stb_o : out std_logic;  -- receive strobe
      rx_data_i : in std_logic_vector(7 downto 0) -- receive data
   );
end all_test_idle;

architecture behaviour of all_test_idle is
   -- transmitter definitions
   type astring is array (natural range <>) of std_logic_vector(7 downto 0);
   signal tx_buffer : astring (0 to 3);
   signal tx_done : std_logic;
   signal tx_flag : std_logic;
   signal tx_tbuf : std_logic_vector(7 downto 0);
   signal tx_active : std_logic;
   signal tx_strobe : std_logic;
   
   -- receiver definitions
   type rx_states is (RX_WAIT_TX, RX_WAIT1, RX_DONE, RX_ERROR, RX_POWER,
                      RX_ID, RX_RX, RX_TX, RX_FIBRE, RX_LED, RX_SRAM);
   signal rx_state : rx_states;
   signal rx_newdata : std_logic;
   signal rx_newdata_clr : std_logic;
   
   signal error : std_logic;
   signal done : std_logic;
begin
   
   ------------------------------------------------------------------
   -- transmitter control processes
   tx_buffer(0) <= conv_std_logic_vector(33,8);  -- !
   tx_buffer(1) <= conv_std_logic_vector(10,8);  -- \r
   tx_buffer(2) <= conv_std_logic_vector(13,8);  -- \n
   tx_buffer(3) <= conv_std_logic_vector(62,8);  -- >
   
   -- transmit prints out tx_buffer and then sets tx_done when complete
   transmit : process (rst_i, en_i, tx_busy_i, error, tx_buffer)
      variable ptr : integer range tx_buffer'range;
   begin
      if ((rst_i = '1') or (en_i = '0') or (error = '1')) then
         if (error = '1') then
            ptr := tx_buffer'left;
            tx_tbuf <= tx_buffer(tx_buffer'left);
         else
            ptr := tx_buffer'left + 1;
            tx_tbuf <= tx_buffer(tx_buffer'left + 1);
         end if;
         tx_done <= '0';
      elsif Rising_Edge(tx_busy_i) then
         if (ptr < tx_buffer'right) then
            ptr := ptr + 1;
            tx_done <= '0';
         else
            ptr := ptr;
            tx_done <= '1';
         end if;
         tx_tbuf <= tx_buffer(ptr);
      end if;
   end process transmit;
   tx_flag <= not(tx_ack_i or tx_busy_i or tx_done);
   
   -- tx_mux controls tx_data_o so that we can switch between
   -- tx_buffer and rx_data_i to echo input characters.
   tx_mux : process (clk_i)
   begin
      if Rising_Edge(clk_i) then
         if (tx_done = '0') then
            tx_data_o <= tx_tbuf;
         else
            tx_data_o <= rx_data_i;
         end if;
      end if;
   end process tx_mux;
   
   -- tx_strobe controls the transmit strobe lines
   tx_strobe_ctl : process (rst_i, en_i, clk_i)
   begin
      if ((rst_i = '1') or (en_i = '0')) then
         tx_we_o <= '0';
         tx_strobe <= '0';
      elsif Rising_Edge(clk_i) then
         if ((rx_valid_i = '1') or (tx_flag = '1')) then
            tx_we_o <= '1';
            tx_strobe <= '1';
         elsif (tx_ack_i = '1') then
            tx_we_o <= '0';
            tx_strobe <= '0';
         end if;
      end if;
   end process tx_strobe_ctl;
   tx_stb_o <= tx_strobe;
   tx_active <= tx_ack_i or tx_busy_i or tx_strobe;
   
   ------------------------------------------------------------------
   -- receiver control processes
   -- rx_strobe controls the receiver strobe line
   rx_strobe : process (rst_i, en_i, clk_i, rx_valid_i, rx_ack_i, done)
   begin
      if ((rst_i = '1') or (en_i = '0')) then
         rx_stb_o <= '0';
      elsif Rising_Edge(clk_i) then
         rx_stb_o <= rx_valid_i and (not (rx_ack_i));-- or done));
      end if;
   end process rx_strobe;
   
   -- rx_newdata_ctl controls the rx_newdata flag
   rx_newdata_ctl : process (rst_i, en_i, rx_newdata_clr, rx_valid_i)
   begin
      if ((rst_i = '1') or (en_i = '0') or (rx_newdata_clr = '1')) then
         rx_newdata <= '0';
      elsif Rising_Edge(rx_valid_i) then
         rx_newdata <= '1';
      end if;
   end process rx_newdata_ctl;
   
   -- receiver receives and decodes incoming characters
   receiver : process (rst_i, en_i, clk_i)
   begin
      if ((rst_i = '1') or (en_i = '0')) then
         rx_state <= RX_WAIT_TX;
         done <= '0';
         error <= '0';
         rx_newdata_clr <= '1';
         cmd1_o <= (others => '0');
         cmd2_o <= (others => '0');
      elsif Rising_Edge(clk_i) then
         case rx_state is
            when RX_WAIT_TX =>
               -- wait for the prompt to be displayed
               if (tx_done = '1') then
                  rx_state <= RX_WAIT1;
                  rx_newdata_clr <= '0';
               end if;
               error <= '0';
               
            when RX_WAIT1 =>
               if (rx_newdata = '1') then
--                  case rx_data_i is
--                     when CMD_RESET | CMD_STATUS | CMD_WATCHDOG |
--                          CMD_JTAG | CMD_EEPROM | CMD_TEMP =>
                  if((rx_data_i = CMD_RESET) or 
                     (rx_data_i = CMD_STATUS) or 
                     (rx_data_i = CMD_WATCHDOG) or 
                     (rx_data_i = CMD_JTAG) or 
                     (rx_data_i = CMD_EEPROM) or 
                     (rx_data_i = CMD_TEMP)) then
                        -- got a single character command - we're done
                        rx_state <= RX_DONE;
                        
--                     when CMD_ID =>
                  elsif(rx_data_i = CMD_ID) then
                        -- ID command - get second byte
                        rx_state <= RX_ID;
                        
--                     when CMD_RX =>
                  elsif(rx_data_i = CMD_RX) then
                        -- rx command - get second byte
                        rx_state <= RX_RX;
                        
--                     when CMD_TX =>
                  elsif(rx_data_i = CMD_TX) then
                        -- tx command - get second byte
                        rx_state <= RX_TX;
                        
--                     when CMD_FIBRE =>
--                        -- fibre optic command - get second byte
--                        rx_state <= RX_FIBRE;

--                     when CMD_LED =>
                  elsif(rx_data_i = CMD_LED) then
                        -- LED command - get second byte
                        rx_state <= RX_LED;
                        
--                     when CMD_SRAM =>
--                        -- SRAM command - get second byte
--                        rx_state <= RX_SRAM;
--                     when CMD_POWER =>
--                        -- power command - get second byte
--                        rx_state <= RX_POWER;
--                     when others =>
                  else
                        -- we received a bad character
                        rx_state <= RX_ERROR;
--                  end case;
                  end if;
                  rx_newdata_clr <= '1';
                  cmd1_o <= rx_data_i;
               end if;
               
            when RX_ID =>               
               if (rx_newdata = '1') then
                  if ((rx_data_i = CMD_ID_SLOT) or
                      (rx_data_i = CMD_ID_SERIAL) or
                      (rx_data_i = CMD_ID_ARRAY) or
                      (rx_data_i = CMD_ID_BOX)) then
                     -- we've recieved a proper ID command
                     rx_state <= RX_DONE;
                  else
                     -- we received a bad character
                     rx_state <= RX_ERROR;
                  end if;
                  rx_newdata_clr <= '1';
                  cmd2_o <= rx_data_i;
               else
                  rx_newdata_clr <= '0';
               end if;
               
            when RX_RX =>               
               if (rx_newdata = '1') then
                  if ((rx_data_i = CMD_RX_0) or
                      (rx_data_i = CMD_RX_1) or
                      (rx_data_i = CMD_RX_2) or
                      (rx_data_i = CMD_RX_3) or
                      (rx_data_i = CMD_RX_4) or
                      (rx_data_i = CMD_RX_5) or
                      (rx_data_i = CMD_RX_6) or
                      (rx_data_i = CMD_RX_7)) then
                     -- we've recieved a proper rx command
                     rx_state <= RX_DONE;
                  else
                     -- we received a bad character
                     rx_state <= RX_ERROR;
                  end if;
                  rx_newdata_clr <= '1';
                  cmd2_o <= rx_data_i;
               else
                  rx_newdata_clr <= '0';
               end if;
               
            when RX_TX =>               
               if (rx_newdata = '1') then
                  if ((rx_data_i = CMD_TX_0) or
                      (rx_data_i = CMD_TX_1) or
                      (rx_data_i = CMD_TX_2)) then
                     -- we've recieved a proper tx command
                     rx_state <= RX_DONE;
                  else
                     -- we received a bad character
                     rx_state <= RX_ERROR;
                  end if;
                  rx_newdata_clr <= '1';
                  cmd2_o <= rx_data_i;
               else
                  rx_newdata_clr <= '0';
               end if;

--            when RX_FIBRE =>               
--               if (rx_newdata = '1') then
--                  if ((rx_data_i = CMD_FIBRE_READ) or
--                      (rx_data_i = CMD_FIBRE_WRITE) or
--                      (rx_data_i = CMD_FIBRE_FLAG)) then
--                     -- we've recieved a proper fibre optic command
--                     rx_state <= RX_DONE;
--                  else
--                     -- we received a bad character
--                     rx_state <= RX_ERROR;
--                  end if;
--                  rx_newdata_clr <= '1';
--                  cmd2_o <= rx_data_i;
--               else
--                  rx_newdata_clr <= '0';
--               end if;
               
            when RX_LED =>               
               if (rx_newdata = '1') then
                  if ((rx_data_i = CMD_LED_1) or
                      (rx_data_i = CMD_LED_2) or
                      (rx_data_i = CMD_LED_3)) then
                     -- we've recieved a proper led command
                     rx_state <= RX_DONE;
                  else
                     -- we received a bad character
                     rx_state <= RX_ERROR;
                  end if;
                  rx_newdata_clr <= '1';
                  cmd2_o <= rx_data_i;
               else
                  rx_newdata_clr <= '0';
               end if;

--            when RX_SRAM =>               
--               if (rx_newdata = '1') then
--                  if ((rx_data_i = CMD_SRAM_0) or
--                      (rx_data_i = CMD_SRAM_1)) then
--                     -- we've recieved a proper SRAM command
--                     rx_state <= RX_DONE;
--                  else
--                     -- we received a bad character
--                     rx_state <= RX_ERROR;
--                  end if;
--                  rx_newdata_clr <= '1';
--                  cmd2_o <= rx_data_i;
--               else
--                  rx_newdata_clr <= '0';
--               end if;
--            
--            when RX_POWER =>               
--               if (rx_newdata = '1') then
--                  if ((rx_data_i = CMD_POWER_READ) or
--                      (rx_data_i = CMD_POWER_WRITE)) then
--                     -- we've recieved a proper power command
--                     rx_state <= RX_DONE;
--                  else
--                     -- we received a bad character
--                     rx_state <= RX_ERROR;
--                  end if;
--                  rx_newdata_clr <= '1';
--                  cmd2_o <= rx_data_i;
--               else
--                  rx_newdata_clr <= '0';
--               end if;
            
            when RX_DONE =>
               -- wait for the last character to transmit
               if (tx_active = '0') then
                  done <= '1';
               end if;
               
            when RX_ERROR =>
               -- wait for the last character to transmit
               if (tx_active = '0') then
                  error <= '1';
                  rx_state <= RX_WAIT_TX;
               end if;
               
            when others =>
               rx_state <= RX_ERROR;
         end case;
      end if;
   end process receiver;
   done_o <= done;
   
end;
