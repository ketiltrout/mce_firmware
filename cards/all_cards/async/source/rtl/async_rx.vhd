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
-- Wishbone asynchronous receiver implementation.
-- 
-- Revision History:
--
-- $Log: async_rx.vhd,v $
-- Revision 1.3  2004/06/11 18:30:46  erniel
-- changed interface to non-wishbone
-- reworked code body (made it RTL description)
--
-- Revision 1.2  2004/04/17 21:42:14  erniel
-- removed synthesis warnings
--
-- Dec 22, 2003: Initial version - NRG
--
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

---------------------------------------------------------------------

entity async_rx is
port(rx_clk_i : in std_logic;   -- 200 MHz for LVDS, 921.6 kHz for RS232
     rst_i    : in std_logic;
     
     dat_o    : out std_logic_vector (7 downto 0);
     stb_i    : in std_logic;
     rx_i     : in std_logic;
     valid_o  : out std_logic;
     error_o  : out std_logic);
end async_rx ;

---------------------------------------------------------------------

architecture behaviour of async_rx is

   type states is (IDLE, RECEIVE, DONE);
   signal pres_state : states;
   signal next_state : states;
     
   signal sample : std_logic_vector(2 downto 0);
   signal rxbit  : std_logic; 
   signal data   : std_logic_vector(9 downto 0);
   signal count  : integer;   
   
begin

   rx_samplebuf: process(rst_i, rx_clk_i)
   begin
      if(rst_i = '1') then
         sample <= (others => '0');
      elsif(rx_clk_i'event and rx_clk_i = '1') then
         sample <= rx_i & sample(2 downto 1);
      end if;
   end process rx_samplebuf;
   
   rxbit <= (sample(2) and sample(1)) or (sample(2) and sample(0)) or (sample(1) and sample(0));
   
   rx_databuf: process(rst_i, rx_clk_i)
   begin
      if(rst_i = '1') then
         data <= (others => '0');
      elsif(rx_clk_i'event and rx_clk_i = '1') then
         if((count =  3) or (count = 11) or (count = 19) or (count = 27) or (count = 35) or
            (count = 43) or (count = 51) or (count = 59) or (count = 67) or (count = 75)) then
            data <= rxbit & data(9 downto 1);
         end if;
      end if;
   end process rx_databuf;
   
   rx_counter: process(rst_i, rx_clk_i)
   begin
      if(rst_i = '1') then
         count <= 0;
      elsif(rx_clk_i'event and rx_clk_i = '1') then
         if(pres_state = IDLE) then
            count <= 0;
         else
            count <= count + 1;
         end if;
      end if;
   end process rx_counter;
   
   stateFF: process(rst_i, rx_clk_i)
   begin
      if(rst_i = '1') then
         pres_state <= IDLE;
      elsif(rx_clk_i'event and rx_clk_i = '1') then
         pres_state <= next_state;
      end if;
   end process stateFF;
   
   state_logic: process(pres_state, rx_i, stb_i, count, data)
   begin
      case pres_state is
         when IDLE =>    if(rx_i = '0') then
                            next_state <= RECEIVE;
                         else
                            next_state <= IDLE;
                         end if;
                         valid_o <= '0';
                         error_o <= '0';
                         
         when RECEIVE => if(count = 80) then
                            next_state <= DONE;
                         else 
                            next_state <= RECEIVE;
                         end if;
                         valid_o <= '0';
                         error_o <= '0';
                                                  
         when DONE =>    if(stb_i = '1') then
                            next_state <= IDLE;
                         else
                            next_state <= DONE;
                         end if;
                         valid_o <= '1';
                         error_o <= not data(9);      -- error_o indicates framing error                         
      end case;
   end process state_logic;
   
   dat_o <= data(8 downto 1);
   
end behaviour;