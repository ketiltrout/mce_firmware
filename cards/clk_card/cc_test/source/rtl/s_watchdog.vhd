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
-- WDT state function.
-- 
-- Revision History:
-- Feb 29, 2004: Initial version - NRG
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
use work.watchdog_pack.all;

library sys_param;
use sys_param.wishbone_pack.all;
---------------------------------------------------------------------
                     
entity s_watchdog is
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
      wdt_o : out std_logic      -- physical watchdog pin
   );
end;

---------------------------------------------------------------------

architecture behaviour of s_watchdog is

   -- state definitions
   type wdt_states is (WDT_READ, WDT_READ_WAIT, WDT_WRITE, WDT_WRITE_WAIT, WDT_IDLE);
   signal wdt_state : wdt_states;

   -- WDT wishbone signals
   signal dat_i   : std_logic_vector (WB_DATA_WIDTH-1 downto 0);
   signal dat_o   : std_logic_vector (WB_DATA_WIDTH-1 downto 0);
   signal addr_i  : std_logic_vector (WB_ADDR_WIDTH-1 downto 0) := WATCHDOG_ADDR;
   signal we      : std_logic;
   signal stb     : std_logic;
   signal ack     : std_logic;
   signal cyc     : std_logic;
   signal tga_o   : std_logic_vector (WB_TAG_ADDR_WIDTH-1 downto 0);
   signal rty_i   : std_logic;
   
begin

   wdt : watchdog
      generic map(
         SLAVE_SEL  => WATCHDOG_ADDR,
         ADDR_WIDTH => WB_ADDR_WIDTH,
         DATA_WIDTH => WB_DATA_WIDTH,
         TAG_ADDR_WIDTH => WB_TAG_ADDR_WIDTH
      )
      port map(
         you_kick_my_dog => wdt_o,
         CLK_I => CLK_I,
         RST_I => RST_I,
         DAT_I => DAT_O,
         DAT_O => DAT_I,
         WE_I => WE,
         STB_I => STB,
         ACK_O => ACK,
         CYC_I => CYC,
      
         ADDR_I => ADDR_I,         
         tga_i => tga_o,
         rty_o => rty_i         
      );      
      
   -- we don't need cyc_i
   cyc <= '1';
   rty_i <= '0';
   
   -- we don't use the transmitter
   tx_data_o <= (others => '0');
   tx_we_o <= '0';
   tx_stb_o <= '0';
   
   -- wdt_test is our test state machine
   wdt_test : process (rst_i, en_i, clk_i)
   begin
      if ((rst_i = '1') or (en_i = '0')) then
         -- asynchronous reset
         wdt_state <= WDT_READ;
         done_o <= '0';
         stb <= '0';
         we <= '0';
         dat_o <= WATCHDOG_KICK;
      elsif Rising_Edge(clk_i) then
         -- process our state machine, en_i is '1'
         case wdt_state is
            when WDT_READ =>
               -- read the current wdt state
               stb <= '1';
               we <= '0';
               wdt_state <= WDT_READ_WAIT;
            
            when WDT_READ_WAIT =>
               -- wait for an ack, 
               if (ack = '1') then
                  stb <= '0';
                  we <= '0';
                  
                  dat_o <= WATCHDOG_KICK;
                  
                  wdt_state <= WDT_WRITE;
               end if;
            
            when WDT_WRITE =>
               -- write the new data
               stb <= '1';
               we <= '1';
               wdt_state <= WDT_WRITE_WAIT;
               
            when WDT_WRITE_WAIT =>
               -- wait for an ack
               if (ack = '1') then
                  stb <= '0';
                  we <= '0';
                  wdt_state <= WDT_IDLE;
               end if;
            
            when WDT_IDLE =>
               -- all done
               done_o <= '1';
               
            when others =>
               wdt_state <= WDT_IDLE;
               
         end case;
      end if;
   end process wdt_test;


end;
