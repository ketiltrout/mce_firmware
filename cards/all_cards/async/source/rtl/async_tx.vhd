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
   port( 
      tx_o    : out std_logic;  -- transmitter output pin
      busy_o  : out std_logic;  -- transmitter busy flag

      -- Wishbone signals
      clk_i   : in std_logic;   -- 8x transmit bit rate
      rst_i   : in std_logic;
      dat_i   : in std_logic_vector (7 downto 0);
      we_i    : in std_logic;
      stb_i   : in std_logic;
      ack_o   : out std_logic;
      cyc_i   : in std_logic
   );
end async_tx ;

---------------------------------------------------------------------

architecture behaviour of async_tx is

    signal sreg, txcount : std_logic_vector(9 downto 0);

begin

   -- transmit transmits data at clk_i/8 bit rate as well
   -- as the wishbone interface
   transmit : process(rst_i, clk_i)
   begin
      if (rst_i = '1') then
         -- asynchronous reset
         tx_o <= '1';
         busy_o <= '0';
         txcount <= "0000000000";
         ack_o <= '0';
      elsif Rising_Edge(clk_i) then
         -- we process everything on the rising clock edge
         
         -- wishbone acknowledge signal
         ack_o <= stb_i and cyc_i;

         -- wishbone interface write
         if ((stb_i = '1') and (cyc_i = '1') and (we_i = '1')) then
            -- we need to load the data into our temporary
            -- shift register storage
            sreg(9) <= '0'; -- start bit
            sreg(8) <= dat_i(0); -- data to transmit, LSB first
            sreg(7) <= dat_i(1); 
            sreg(6) <= dat_i(2); 
            sreg(5) <= dat_i(3); 
            sreg(4) <= dat_i(4); 
            sreg(3) <= dat_i(5); 
            sreg(2) <= dat_i(6); 
            sreg(1) <= dat_i(7); 
            sreg(0) <= '1'; -- stop bit

            -- initialise txcount to transmit on the next clock
            txcount <= "1111111111";
         elsif (txcount(9) = '1') then
            -- we need to transmit some data
            tx_o <= sreg(9);
            sreg <= sreg(8 downto 0) & '0'; -- left shift
            txcount <= txcount(8 downto 0) & '0'; -- left shift
         end if;
         busy_o <= txcount(9);
      end if;
   end process transmit;

END behaviour;
