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
-- Wishbone asynchronous transmitter implementation.
-- 
-- Revision History:
-- Dec 22, 2003: Initial version - NRG
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

---------------------------------------------------------------------

entity async_tx is
port(tx_clk_i : in std_logic;   -- 25 MHz for LVDS, 115.2 kHz for RS232
     rst_i    : in std_logic;

     dat_i    : in std_logic_vector (7 downto 0);
     stb_i    : in std_logic;
     tx_o     : out std_logic;
     busy_o   : out std_logic);
end async_tx ;

---------------------------------------------------------------------

architecture behaviour of async_tx is

   type states is (IDLE, TRANSMIT);
   signal pres_state : states;
   signal next_state : states;

   signal data  : std_logic_vector(9 downto 0);
   signal count : integer;

begin

   tx_counter: process(rst_i, tx_clk_i)
   begin
      if(rst_i = '1') then
         count <= 0;
      elsif(tx_clk_i'event and tx_clk_i = '1') then
         if(pres_state = IDLE) then
            count <= 0;                       -- don't start transmitting until transmit phase
         else
            count <= count + 1;
         end if;
      end if;
   end process tx_counter;

   tx_databuf: process(rst_i, tx_clk_i)
   begin
      if(rst_i = '1') then
         data <= (others => '0');
      elsif(tx_clk_i'event and tx_clk_i = '1') then 
         if(pres_state = IDLE) then
            data <= '1' & dat_i & '0';        -- frame data with start ('0') & stop ('1') bits
         else
            data <= '0' & data(9 downto 1);   -- shift data out LSB first
         end if;
      end if;
   end process tx_databuf;
     
   stateFF: process(rst_i, tx_clk_i)
   begin
      if(rst_i = '1') then   
         pres_state <= IDLE;
      elsif(tx_clk_i'event and tx_clk_i = '1') then
         pres_state <= next_state;
      end if;
   end process stateFF;
   
   state_logic: process(pres_state, stb_i, count, data)
   begin
      case pres_state is
         when IDLE =>     if(stb_i = '1') then
                             next_state <= TRANSMIT;
                          else
                             next_state <= IDLE;
                          end if;
                          busy_o <= '0';
                          tx_o <= '1';
                          
         when TRANSMIT => if(count = 9) then 
                             next_state <= IDLE;
                          else
                             next_state <= TRANSMIT;
                          end if;
                          busy_o <= '1';
                          tx_o <= data(0);
      end case;
   end process state_logic;
   
END behaviour;
