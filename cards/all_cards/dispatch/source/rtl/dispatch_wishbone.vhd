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
-- dispatch_wishbone.vhd
--
-- Project:       SCUBA-2
-- Author:         Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Implements the Wishbone Master part of the dispatch block
--
-- Revision history:
--
-- $Log: dispatch_wishbone.vhd,v $
-- Revision 1.18  2008/10/03 00:30:13  mandana
-- BB: Moved the tga_o signal out of the FSM, and made it a continuous assignment. This signal has one of the highest fan-out counts in the RTL design, and actually was impossible to route in Stratix III chips in its previous configuration because of the number of gates on the fan-out. As a consequence of making it a continuous assignment, the Stratix III fitter was able to succeed, and the Stratix I timing characteristics were greatly improved.
--
-- Revision 1.17  2008/08/12 19:08:59  bburger
-- BB: replaced the binary_counter block for generating address with discrete implementation.  Simulated the block to ensure that the behaviour was the same.
--
-- Revision 1.16  2007/12/18 20:25:33  bburger
-- BB:  Added a default state assignment to the FSM to lessen the likelyhood of uncontrolled state transitions
--
-- Revision 1.15  2005/12/12 20:48:44  erniel
-- fixed implicit register on buf_addr_o
--
-- Revision 1.14  2005/12/02 00:41:17  erniel
-- modified FSM to accomodate pipeline-mode buffer at dispatch top-level
--
-- Revision 1.13  2005/11/03 19:41:39  erniel
-- removed reference to obsolete dispatch_pack
-- fixed hard-coded assignment to tga_o in WB_CYCLE state
--
-- Revision 1.12  2005/10/28 01:15:26  erniel
-- unified cmd/reply buffer interfaces
-- start/done signal name changes
-- removed master wait state support
-- added buffer access to FSM
-- watchdog timeout is now a constant
--
-- Revision 1.11  2005/10/08 00:13:29  erniel
-- replaced counter with binary_counter
-- hard-coded watchdog timer limit
--
-- Revision 1.10  2005/03/18 23:09:09  erniel
-- updated changed buffer addr & data bus size constants
-- slight modification to buffer address generation due to different buffer sizes
--
-- Revision 1.9  2004/11/26 01:34:31  erniel
-- added support for wishbone err_i signal
--
-- Revision 1.8  2004/10/28 20:42:27  erniel
-- fixed synthesis warning in process stateNS
--
-- Revision 1.7  2004/10/13 04:01:15  erniel
-- parameterized watchdog timer limit
--
-- Revision 1.6  2004/09/27 23:02:03  erniel
-- using updated constants from command_pack
--
-- Revision 1.5  2004/09/11 00:58:08  erniel
-- added watchdog timer functionality
--
-- Revision 1.4  2004/09/10 16:42:12  erniel
-- added reply acknowledge signal
--
-- Revision 1.3  2004/08/25 20:17:35  erniel
-- modified addr_ena timing
--
-- Revision 1.2  2004/08/23 22:02:29  erniel
-- removed WB_WAIT state (master wait state)
--
-- Revision 1.1  2004/08/23 20:35:56  erniel
-- initial version
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library components;
use components.component_pack.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

entity dispatch_wishbone is
port(clk_i : in std_logic;
     rst_i : in std_logic;

     -- Command header and data buffer interface:
     header0_i : in std_logic_vector(31 downto 0);
     header1_i : in std_logic_vector(31 downto 0);

     buf_data_i : in std_logic_vector(31 downto 0);
     buf_data_o : out std_logic_vector(31 downto 0);
     buf_addr_o : out std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
     buf_wren_o : out std_logic;

     -- Start/done/error signals:
     execute_start_i : in std_logic;
     execute_done_o   : out std_logic;
     execute_error_o  : out std_logic;

     -- Wishbone interface:
     dat_o  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
     addr_o : out std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
     tga_o  : out std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
     we_o   : out std_logic;
     stb_o  : out std_logic;
     cyc_o  : out std_logic;
     dat_i  : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
     ack_i  : in std_logic;
     err_i  : in std_logic;  -- asserted when a Wishbone slave is not connected

     -- Watchdog reset interface:
     wdt_rst_o : out std_logic);
end dispatch_wishbone;

architecture rtl of dispatch_wishbone is

   constant WATCHDOG_TIMEOUT_US : integer := 180000;

   type master_states is (IDLE, FETCH, WB_CYCLE, DONE, ERROR);
   signal pres_state : master_states;
   signal next_state : master_states;

   signal addr_ena : std_logic;
   signal addr_clr : std_logic;
   signal addr_preload: std_logic;
--   signal addr     : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);

   signal timer_rst : std_logic;
   signal timer     : integer;

   signal addr       : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
   signal addr_count_new   : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
   signal tga_offset : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);

begin

   ---------------------------------------------------------
   -- Address generator
   ---------------------------------------------------------

   addr_count_new <= addr + "00000000001";  
   addr_cntr: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         addr <= (others => '0');
         tga_offset <= (others => '0');
      elsif(clk_i'event and clk_i = '1') then
         if (addr_clr = '1') then
            tga_offset <= (others => '0');
         elsif (addr_preload = '1') then
            tga_offset <= "00000100000";
         end if;   
      
         if(addr_clr = '1') then
            addr <= "00000000000";
         elsif(addr_ena = '1') then
            addr <= addr_count_new;
         end if;
      end if;
   end process addr_cntr;

   ---------------------------------------------------------
   -- Watchdog timer
   ---------------------------------------------------------

   -- When in IDLE, kick the watchdog every WATCHDOG_TIMEOUT_US (currently 180,000) us

   -- When in WB_CYCLE or DONE, do not kick the watchdog (hold timer at 0).
   -- If the wishbone hangs, the external watchdog will be allowed to reset the FPGA (since it is not being kicked)

   wdt : us_timer
   port map (clk => clk_i,
             timer_reset_i => timer_rst,
             timer_count_o => timer);

   timer_rst <= '1' when timer = WATCHDOG_TIMEOUT_US or pres_state = WB_CYCLE or pres_state = DONE else '0';
   wdt_rst_o <= '1' when timer = 0 else '0';


   ---------------------------------------------------------
   -- Wishbone protocol FSM
   ---------------------------------------------------------

   stateFF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         pres_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         pres_state <= next_state;
      end if;
   end process stateFF;

   stateNS: process(pres_state, header0_i, execute_start_i, ack_i, err_i, addr)
   begin
      -- Default Assignment
      next_state <= pres_state;

      case pres_state is
         when IDLE =>
            if(execute_start_i = '1') then
               if(header0_i(BB_COMMAND_TYPE'range) = WRITE_CMD) then
                  next_state <= FETCH;
               else
                  next_state <= WB_CYCLE;
               end if;
            end if;

         when FETCH =>
            next_state <= WB_CYCLE;

         when WB_CYCLE =>
            if(ack_i = '1') then
               if(addr = header0_i(BB_DATA_SIZE'range)-1) then
                  next_state <= DONE;                              -- slave has accepted last piece of data
               elsif(header0_i(BB_COMMAND_TYPE'range) = WRITE_CMD) then
                  next_state <= FETCH;
               else
                  next_state <= WB_CYCLE;
               end if;
            elsif(err_i = '1') then
               next_state <= ERROR;                                -- slave does not exist, abort
            end if;

         when DONE =>
            next_state <= IDLE;

         when ERROR =>
            next_state <= IDLE;

         when others =>
            next_state <= IDLE;

      end case;
   end process stateNS;
    
   tga_o <= "000000000000000000000" & (addr + tga_offset);          -- zero-padded to 32-bits by default assignment
   stateOut: process(pres_state, header0_i, header1_i, buf_data_i, dat_i, ack_i, addr)
   begin
      addr_o          <= (others => '0');
--      tga_o           <= (others => '0');
      dat_o           <= (others => '0');
      we_o            <= '0';
      cyc_o           <= '0';
      stb_o           <= '0';
      addr_ena        <= '0';
      addr_clr        <= '0';
      addr_preload    <= '0';
      buf_addr_o      <= (others => '0');
      buf_data_o      <= (others => '0');
      buf_wren_o      <= '0';
      execute_done_o  <= '0';
      execute_error_o <= '0';

      case pres_state is
         when IDLE =>
            addr_clr      <= '1';

         when FETCH =>
            buf_addr_o    <= addr;
            addr_preload  <= header1_i(28);
            
         when WB_CYCLE =>
            addr_o        <= header1_i(BB_PARAMETER_ID'range);
--            tga_o(BB_DATA_SIZE_WIDTH-1 downto 0) <= addr;          -- zero-padded to 32-bits by default assignment
            addr_preload  <= header1_i(28);
            cyc_o         <= '1';
            stb_o         <= '1';

            if(ack_i = '1') then
               addr_ena   <= '1';
            end if;

            if(header0_i(BB_COMMAND_TYPE'range) = WRITE_CMD) then
               buf_addr_o <= addr;                                 -- write commands: read data from buffer
               dat_o      <= buf_data_i;
               we_o       <= '1';
            else
               buf_addr_o <= addr;                                 -- read commands: write data to buffer
               buf_data_o <= dat_i;
               buf_wren_o <= '1';
            end if;

         when DONE =>
            execute_done_o     <= '1';

         when ERROR =>
            execute_done_o     <= '1';
            execute_error_o    <= '1';

      end case;
   end process stateOut;

end rtl;