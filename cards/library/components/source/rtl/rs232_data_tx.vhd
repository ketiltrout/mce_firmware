-- Copyright (c) 2003 SCUBA-2 Project
--                  All Rights Reserved
--
--  THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE SCUBA-2 Project
--  The copyright notice above does not evidence any
--  actual or intended publication of such source code.
--
--  SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
--  REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
--  MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
--  PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
--  THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.
--
-- For the purposes of this code the SCUBA-2 Project consists of the
-- following organisations.
--
-- UKATC, Royal Observatory, Blackford Hill Edinburgh EH9 3HJ
-- UBC,   University of British Columbia, Physics & Astronomy Department,
--        Vancouver BC, V6T 1Z1
--
--
-- rs232_data_tx.vhd
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Transmits binary data (as hex digits) over RS232 interface
--
-- Revision history:
-- 
-- $Log: rs232_data_tx.vhd,v $
-- Revision 1.3  2004/05/12 23:15:58  erniel
-- added CR/LF prior to sending string
--
-- Revision 1.2  2004/05/05 21:21:40  erniel
-- modified generic WIDTH range
--
-- Revision 1.1  2004/05/05 03:51:26  erniel
-- initial version
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity rs232_data_tx is
generic(WIDTH : in integer range 4 to 1024 := 8);  -- number of bits to transmit
port(clk_i   : in std_logic;
     rst_i   : in std_logic;
     data_i  : in std_logic_vector(WIDTH-1 downto 0);
     start_i : in std_logic;
     done_o  : out std_logic;

     tx_busy_i : in std_logic;
     tx_ack_i  : in std_logic;
     tx_data_o : out std_logic_vector(7 downto 0);
     tx_we_o   : out std_logic;
     tx_stb_o  : out std_logic);
end rs232_data_tx;

architecture rtl of rs232_data_tx is

type states is (IDLE, TX_CR, TX_CR_BUSY, TX_LF, TX_LF_BUSY, TX, TX_BUSY, SETUP, DONE);
signal present_state : states;
signal next_state    : states;

signal reg : std_logic_vector(0 to WIDTH-1);  -- reg is defined as a TO vector to make it easier to shift out MSB-first
signal count : integer range 0 to WIDTH;

signal shift_ena  : std_logic;
signal shift_load : std_logic;
signal count_ena  : std_logic;
signal count_rst  : std_logic;

signal tx_data : std_logic_vector(7 downto 0);

begin

   -- shift register stores binary word to be transmitted
   -- hex digits (4 bits) are sent out MSB first
   shift_register : process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         reg <= (others => '0');
      elsif(clk_i'event and clk_i = '1') then
         if(shift_load = '1') then
            reg <= data_i;
         elsif(shift_ena = '1') then
            reg <= reg(4 to WIDTH-1) & "0000";
         end if;
      end if;
   end process shift_register;

   -- counter keeps track of how many bits have been transmitted
   counter : process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         count <= 4;
      elsif(clk_i'event and clk_i = '1') then
         if(count_rst = '1') then
            count <= 4;
         elsif(count_ena = '1') then
            count <= count + 4;
         end if;
      end if;
   end process counter;
   
   -- hex to ascii performs conversion from hex digit to ascii character   
   hex_to_ascii : process(reg)
   begin
      case reg(0 to 3) is
         when "0000" => tx_data <= "00110000";   -- 0 hex = 48 ascii
         when "0001" => tx_data <= "00110001";   -- 1 hex = 49 ascii
         when "0010" => tx_data <= "00110010";   -- 2 hex = 50 ascii
         when "0011" => tx_data <= "00110011";   -- 3 hex = 51 ascii
         when "0100" => tx_data <= "00110100";   -- 4 hex = 52 ascii
         when "0101" => tx_data <= "00110101";   -- 5 hex = 53 ascii
         when "0110" => tx_data <= "00110110";   -- 6 hex = 54 ascii
         when "0111" => tx_data <= "00110111";   -- 7 hex = 55 ascii
         when "1000" => tx_data <= "00111000";   -- 8 hex = 56 ascii
         when "1001" => tx_data <= "00111001";   -- 9 hex = 57 ascii
         when "1010" => tx_data <= "01000001";   -- A hex = 65 ascii
         when "1011" => tx_data <= "01000010";   -- B hex = 66 ascii
         when "1100" => tx_data <= "01000011";   -- C hex = 67 ascii
         when "1101" => tx_data <= "01000100";   -- D hex = 68 ascii
         when "1110" => tx_data <= "01000101";   -- E hex = 69 ascii
         when "1111" => tx_data <= "01000110";   -- F hex = 70 ascii
         when others => tx_data <= "00111111";   -- else output "?"
      end case;
   end process hex_to_ascii;

   
   ------------------------------------------------------------
   --
   -- Transmit Controller FSM
   --
   ------------------------------------------------------------
   
   stateFF : process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         present_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         present_state <= next_state;
      end if;
   end process;
      
   NS_logic : process(present_state, count, start_i, tx_ack_i, tx_busy_i)
   begin
      case present_state is
         when IDLE =>    if(start_i = '1') then
                            next_state <= TX_CR;
                         else
                            next_state <= IDLE;
                         end if;

         --------------------------------------------------
                  
         when TX_CR =>      if(tx_ack_i = '1') then
                               next_state <= TX_CR_BUSY;
                            else
                               next_state <= TX_CR;
                            end if;
                  
         when TX_CR_BUSY => if(tx_ack_i = '0' and tx_busy_i = '0') then
                               next_state <= TX_LF;
                            else
                               next_state <= TX_CR_BUSY;
                            end if;
                            
         when TX_LF =>      if(tx_ack_i = '1') then
                               next_state <= TX_LF_BUSY;
                            else
                               next_state <= TX_LF;
                            end if;
         
         when TX_LF_BUSY => if(tx_ack_i = '0' and tx_busy_i = '0') then
                               next_state <= TX;
                            else
                               next_state <= TX_LF_BUSY;
                            end if;

         --------------------------------------------------
                                          
         when TX =>      if(tx_ack_i = '1') then 
                            next_state <= TX_BUSY;
                         else
                            next_state <= TX;
                         end if;
         
         when TX_BUSY => if(tx_ack_i = '0' and tx_busy_i = '0') then
                            if(count >= WIDTH) then
                               next_state <= DONE;
                            else
                               next_state <= SETUP;
                            end if;
                         else
                            next_state <= TX_BUSY;
                         end if;

         when SETUP =>   next_state <= TX;
                                  
         when DONE =>    next_state <= IDLE;
         
         when others =>  next_state <= IDLE;
      end case;
   end process;
   
   
   out_logic : process(present_state, tx_data)
   begin
      -- default values:
      shift_ena  <= '0';
      shift_load <= '0';
      count_ena  <= '0';
      count_rst  <= '0';
      tx_we_o    <= '0';
      tx_stb_o   <= '0';
      tx_data_o  <= tx_data;
      done_o     <= '0';
                         
      case present_state is
         when IDLE =>    shift_load <= '1';
                         count_rst  <= '1';
         
                         
         when TX_CR =>   tx_data_o  <= "00001101";
                         tx_we_o    <= '1';
                         tx_stb_o   <= '1';
         
         when TX_CR_BUSY => tx_data_o <= "00001101";
                  
         when TX_LF =>   tx_data_o  <= "00001010";
                         tx_we_o    <= '1';
                         tx_stb_o   <= '1';
         
         when TX_LF_BUSY => tx_data_o <= "00001010";
                                           
         when TX =>      tx_we_o    <= '1';
                         tx_stb_o   <= '1';
                                                  
                                                  
         when TX_BUSY => null;
         
         when SETUP =>   shift_ena  <= '1';
                         count_ena  <= '1';
                         
         when DONE =>    done_o     <= '1';
                         
         when others =>  shift_load <= '1';
                         count_rst  <= '1';
      end case;
   end process;
   
end rtl;