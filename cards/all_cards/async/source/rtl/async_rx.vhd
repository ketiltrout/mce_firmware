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
-- Dec 22, 2003: Initial version - NRG
--
-- $Log$
--
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

---------------------------------------------------------------------

entity async_rx is
   port( 
      rx_i    : in std_logic;   -- receiver input pin
      flag_o  : out std_logic;  -- receiver data ready flag
      error_o : out std_logic;  -- receiver error flag

      -- Wishbone signals
      clk_i   : in std_logic;   -- 8x receive bit rate
      rst_i   : in std_logic;
      dat_o   : out std_logic_vector (7 downto 0);
      we_i    : in std_logic;
      stb_i   : in std_logic;
      ack_o   : out std_logic;
      cyc_i   : in std_logic
   );
end async_rx ;

---------------------------------------------------------------------

architecture behaviour of async_rx is

   signal rxdata, rxcount : std_logic_vector(9 downto 0);
   signal rxclock, data : std_logic_vector(7 downto 0);
   signal sreg : std_logic_vector(2 downto 0);
   signal rxbit : std_logic;
   signal dummy : std_logic;
   signal stb_sync : std_logic;

begin

   -- synchronize the strobe to our receive clock
   strobe_sync : process (rst_i, clk_i)
   begin
      if (rst_i = '1') then
         stb_sync <= '1';
      elsif (Rising_Edge(clk_i)) then
         stb_sync <= stb_i;
      end if;
   end process strobe_sync;
                                  
   -- receive_flag controls flag_o
   receive_flag : process(stb_sync, rxcount(9))
   begin
      if (stb_sync = '1') then
         -- asynchronous reset
         flag_o <= '0';
      elsif (Falling_Edge(rxcount(9))) then
         flag_o <= '1';
      end if;
   end process receive_flag;

   -- receive deserializes rx_i into data
   receive : process(rst_i, clk_i)
   begin
       if (rst_i = '1') then
          -- reset everything to default values
          data <= "00000000";
          error_o <= '0';
          rxcount <= "0000000000";
          rxdata <= "0000000000";
          rxclock <= "00000000";
          sreg <= "111";
          rxbit <= '1';
       elsif Rising_Edge(clk_i) then
          -- we process everything on the rising clock edge

          -- noise filter - the majority of bits in the 3 bit
          -- sample register is what we use.
          sreg <= sreg(1 downto 0) & rx_i;
          rxbit <= (sreg(2) and (sreg(1) or sreg(0))) or 
                   (sreg(1) and sreg(0));

          -- look for start bit
          if (rxcount(9) = '0') then
              -- look for start bit
              if (rxbit = '0') then
                 -- found start bit
                 rxcount <= "1111111111";
                 rxclock <= "00100000";
              end if;
          elsif (rxclock(7) = '1') then
              -- sample the incoming data
              rxdata <= rxbit & rxdata(9 downto 1);
              rxclock <= "00000001";

              -- save the data if this is the stop bit
              if (rxcount(8) = '0') then
                 data <= rxdata(9 downto 2);
                 error_o <= rxdata(1) or (not rxbit);
              end if;

              rxcount <= rxcount(8 downto 0) & '0';
          else
              -- shift the sample clock
              rxclock <= rxclock(6 downto 0) & '0';
          end if;
       end if;
   end process receive;

   -- the wishbone interface
   -- synchronize the ack to our receive clock
   ack_sync : process (rst_i, clk_i)
   begin
      if (rst_i = '1') then
         ack_o <= '0';
      elsif (Rising_Edge(clk_i)) then
         ack_o <= stb_i and cyc_i;
      end if;
   end process ack_sync;
   dat_o <= data;
   dummy <= we_i;   -- we don't need the write signal

end behaviour;
