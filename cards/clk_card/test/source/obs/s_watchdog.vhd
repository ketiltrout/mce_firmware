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
-- $Log: s_watchdog.vhd,v $
-- Revision 1.1  2004/05/20 23:51:14  erniel
-- relocated old cc_test files
--
-- Revision 1.2  2004/04/21 19:58:50  bburger
-- Changed address moniker
--
-- Revision 1.1  2004/04/14 22:16:23  jjacob
-- new directory structure
--
-- Revision 1.5  2004/04/09 03:50:31  erniel
-- removed unecessary states from state machine
-- separated state machine into 3 processes
-- corrected wishbone logic
-- updated watchdog timer instantiation
--
--
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

type states is (IDLE, WD_RESET, DONE);
signal present_state : states;
signal next_state    : states;
   
-- watchdog wishbone signals
signal dat_i   : std_logic_vector (WB_DATA_WIDTH-1 downto 0);
signal dat_o   : std_logic_vector (WB_DATA_WIDTH-1 downto 0);
signal addr_o  : std_logic_vector (WB_ADDR_WIDTH-1 downto 0);
signal we_o    : std_logic;
signal stb_o   : std_logic;
signal ack_i   : std_logic;
signal cyc_o   : std_logic;
signal tga_o   : std_logic_vector (WB_TAG_ADDR_WIDTH-1 downto 0);
signal rty_i   : std_logic;
   
begin

   wdt : watchdog
      generic map(ADDR_WIDTH     => WB_ADDR_WIDTH,
                  DATA_WIDTH     => WB_DATA_WIDTH,
                  TAG_ADDR_WIDTH => WB_TAG_ADDR_WIDTH)
      port map(clk_i  => clk_i,
               rst_i  => rst_i,
               dat_i  => dat_o,
               addr_i => addr_o,
               tga_i  => tga_o,
               we_i   => we_o,
               stb_i  => stb_o,
               cyc_i  => cyc_o,
               dat_o  => dat_i,
               rty_o  => rty_i, 
               ack_o  => ack_i,
          
               you_kick_my_dog => wdt_o);      
               
   
   -- unused transmitter signals:
   tx_data_o <= (others => '0');
   tx_we_o   <= '0';
   tx_stb_o  <= '0';
   
   -- unused wishbone signals:
   dat_o <= (others => '0');
   tga_o <= (others => '0');
   we_o <= '0';
   
   
   state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         present_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         present_state <= next_state;
      end if;
   end process state_FF;
   
   NS_logic: process(present_state, en_i, ack_i)
   begin
      case present_state is
         when IDLE =>     
            if(en_i = '1') then
               next_state <= WD_RESET;
            else
               next_state <= IDLE;
            end if;
                          
         when WD_RESET => 
            if(ack_i = '1') then
               next_state <= DONE;
            else
               next_state <= WD_RESET;
            end if;
                          
         when DONE =>     
            next_state <= IDLE;
            
         when others =>   
            next_state <= IDLE;
            
      end case;
   end process NS_logic;
   
   out_logic: process(present_state)
   begin
      case present_state is
         when IDLE =>     
            addr_o <= (others => '0');
            stb_o  <= '0';
            cyc_o  <= '0';
            done_o <= '0';
            
         when WD_RESET => 
            addr_o <= RST_WTCHDG_ADDR;
            stb_o  <= '1';
            cyc_o  <= '1';
            done_o <= '0';
            
         when DONE =>     
            addr_o <= (others => '0');
            stb_o  <= '0';
            cyc_o  <= '0';
            done_o <= '1';
            
         when others =>   
            addr_o <= (others => '0');
            stb_o  <= '0';
            cyc_o  <= '0';
            done_o <= '0';
      end case;
   end process out_logic;

end;
