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
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Implements the Wishbone Master part of the dispatch block
--
-- Revision history:
-- 
-- $Log: dispatch_wishbone.vhd,v $
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

library work;
use work.dispatch_pack.all;

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
     dat_i 	: in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
     ack_i  : in std_logic;
     err_i  : in std_logic;  -- asserted when a Wishbone slave is not connected
     
     -- Watchdog reset interface:
     wdt_rst_o : out std_logic);
end dispatch_wishbone;
     
architecture rtl of dispatch_wishbone is

constant WATCHDOG_TIMEOUT_US : integer := 180000;
   
type master_states is (IDLE, WB_CYCLE, DONE, ERROR);
signal pres_state : master_states;
signal next_state : master_states;

signal addr_ena : std_logic;
signal addr_clr : std_logic;
signal addr     : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);

signal timer_rst : std_logic;
signal timer     : integer;

begin
  
   ---------------------------------------------------------
   -- Address generator
   ---------------------------------------------------------
   
   addr_gen : binary_counter
   generic map(WIDTH => BB_DATA_SIZE_WIDTH)
   port map(clk_i   => clk_i,
            rst_i   => rst_i,
            ena_i   => addr_ena,
            up_i    => '1',
            load_i  => '0',
            clear_i => addr_clr,
            count_i => (others => '0'),
            count_o => addr);

   
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
      case pres_state is
         when IDLE =>     if(execute_start_i = '1') then
                             next_state <= WB_CYCLE;
                          else
                             next_state <= IDLE;
                          end if;
                              
         when WB_CYCLE => if(ack_i = '1' and addr = header0_i(BB_DATA_SIZE'range)-1) then  
                             next_state <= DONE;        -- slave has accepted last piece of data
                          elsif(err_i = '1') then 
                             next_state <= ERROR;       -- slave does not exist, abort
                          else
                             next_state <= WB_CYCLE;
                          end if;
                                                      
         when DONE =>     next_state <= IDLE;
         
         when ERROR =>    next_state <= IDLE;
      end case;
   end process stateNS;
   
   stateOut: process(pres_state, header0_i, header1_i, buf_data_i, dat_i, ack_i, addr)
   begin
      addr_o          <= (others => '0');
      tga_o           <= (others => '0');
      dat_o           <= (others => '0');
      we_o            <= '0';
      cyc_o           <= '0';
      stb_o           <= '0';
      addr_ena        <= '0';
      addr_clr        <= '0';
      buf_data_o      <= (others => '0');
      buf_wren_o      <= '0';
      execute_done_o  <= '0';
      execute_error_o <= '0';
                            
      case pres_state is
         when IDLE =>     addr_clr      <= '1';
         
         when WB_CYCLE => addr_o        <= header1_i(BB_PARAMETER_ID'range);
                          tga_o         <= "00000000000000000" & addr;
                          cyc_o         <= '1';
                          stb_o         <= '1';
                          
                          if(ack_i = '1') then
                             addr_ena   <= '1';
                          end if;
                             
                          if(header0_i(BB_COMMAND_TYPE'range) = WRITE_CMD) then  
                             buf_addr_o <= addr;           -- write commands: read data from buffer
                             dat_o      <= buf_data_i;                                        
                             we_o       <= '1';
                          else  
                             buf_addr_o <= addr;           -- read commands: write data to buffer              
                             buf_data_o <= dat_i;
                             buf_wren_o <= '1';
                          end if;
                          
         when DONE =>     execute_done_o     <= '1';
         
         when ERROR =>    execute_done_o     <= '1';
                          execute_error_o    <= '1';
      end case;  
   end process stateOut;
   
end rtl;