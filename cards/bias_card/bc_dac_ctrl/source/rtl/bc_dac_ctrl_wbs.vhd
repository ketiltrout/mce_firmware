-- 2003 SCUBA-2 Project
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
-- $Id: bc_dac_ctrl_wbs.vhd,v 1.10 2008/07/15 17:48:04 bburger Exp $
--
-- Project:       SCUBA2
-- Author:        Bryce Burger
-- Organisation:  UBC
--
-- Description:
-- Wishbone interface for a 16-bit serial DAC controller
-- This block was written to be coupled with bc_dac_ctrl
--
-- Revision history:
-- $Log: bc_dac_ctrl_wbs.vhd,v $
-- Revision 1.10  2008/07/15 17:48:04  bburger
-- BB: added tga_i to the state_out FSM's sensitivity list
--
-- Revision 1.9  2007/12/20 00:40:04  mandana
-- added flux_fb_upper
--
-- Revision 1.8  2006/10/02 18:42:52  bburger
-- Bryce:  Gave the WBS the ability to update either the bias or flux_fb, without having to do the other.
--
-- Revision 1.7  2006/08/03 19:00:52  mandana
-- removed reference to ac_dac_ctrl_pack file
-- moved ram component declaraion to bc_dac_ctrl_pack
--
-- Revision 1.6  2006/08/01 18:23:33  bburger
-- Bryce:  removed component declarations from header files and moved them to source files
--
-- Revision 1.5  2005/03/05 01:37:20  mandana
-- fixed the problem with first data being read twice
--
-- Revision 1.4  2005/01/17 23:01:04  mandana
-- removed mem_clk_i
-- read from RAM is performed in 2 clk_i cycles, added an extra state for read
--
-- Revision 1.3  2005/01/07 01:32:03  bench2
-- Mandana: watch for debug ports
--
-- Revision 1.2  2005/01/04 19:19:47  bburger
-- Mandana: changed mictor assignment to 0 to 31 and swapped odd and even pods
--
-- Revision 1.1  2004/11/25 03:05:08  bburger
-- Bryce:  Modified the Bias Card DAC control slaves.
--
-- Revision 1.1  2004/11/11 01:46:56  bburger
-- Bryce:  new
--
--
--
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;  -- for ext function
use ieee.std_logic_unsigned.all;


library sys_param;
use sys_param.wishbone_pack.all;

library work;
use work.bias_card_pack.all;
use work.bc_dac_ctrl_pack.all;

entity bc_dac_ctrl_wbs is
   port
   (
      -- ac_dac_ctrl interface:
      flux_fb_addr_i    : in std_logic_vector(FLUX_FB_DAC_ADDR_WIDTH-1 downto 0);   -- address index to read DAC data from RAM
      flux_fb_data_o    : out std_logic_vector(FLUX_FB_DAC_DATA_WIDTH-1 downto 0);  -- data read from RAM to be consumed by bc_dac_ctrl_core
      flux_fb_changed_o : out std_logic;
      ln_bias_addr_i    : in std_logic_vector(LN_BIAS_DAC_ADDR_WIDTH-1 downto 0);
      ln_bias_data_o    : out std_logic_vector(LN_BIAS_DAC_DATA_WIDTH-1 downto 0);
      ln_bias_changed_o : out std_logic;

      -- wishbone interface:
      dat_i             : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_i            : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_i             : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i              : in std_logic;
      stb_i             : in std_logic;
      cyc_i             : in std_logic;
      dat_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_o             : out std_logic;

      -- global interface
      clk_i             : in std_logic;
      rst_i             : in std_logic;
      debug             : inout std_logic_vector(31 downto 0)
   );
end bc_dac_ctrl_wbs;

architecture rtl of bc_dac_ctrl_wbs is

   -- FSM inputs
   signal wr_cmd           : std_logic;
   signal rd_cmd           : std_logic;
   signal master_wait      : std_logic;

   -- RAM/Register signals
   signal flux_fb_wren     : std_logic;
   signal flux_fb_data     : std_logic_vector(FLUX_FB_DAC_DATA_WIDTH-1 downto 0);
   signal ln_bias_wren     : std_logic;
   signal ln_bias_data     : std_logic_vector(LN_BIAS_DAC_DATA_WIDTH-1 downto 0);

   signal ram_addr         : std_logic_vector(FLUX_FB_DAC_ADDR_WIDTH-1 downto 0);
   signal addr             : std_logic_vector(WB_ADDR_WIDTH-1 downto 0);


   -- WBS states:
   type states is (IDLE, WR, RD1, RD2);
   signal current_state    : states;
   signal next_state       : states;

begin
   -- port a is used for updating DACs and port b for wishbone read
   flux_fb_ram : ram_16x64
   port map
      (
         clock             => clk_i,
         data              => dat_i(FLUX_FB_DAC_DATA_WIDTH-1 downto 0),
         wren              => flux_fb_wren,
         wraddress         => ram_addr,
         rdaddress_a       => flux_fb_addr_i,
         rdaddress_b       => ram_addr,
         qa                => flux_fb_data_o,
         qb                => flux_fb_data
      );
      
   -- port a is used for updating DACs and port b for wishbone read
   ln_bias_ram : ram_16x16
   port map
      (
         clock             => clk_i,
         data              => dat_i(LN_BIAS_DAC_DATA_WIDTH-1 downto 0),
         wren              => ln_bias_wren,
         wraddress         => ram_addr(LN_BIAS_DAC_ADDR_WIDTH-1 downto 0),
         rdaddress_a       => ln_bias_addr_i,
         rdaddress_b       => ram_addr(LN_BIAS_DAC_ADDR_WIDTH-1 downto 0),
         qa                => ln_bias_data_o,
         qb                => ln_bias_data
      );


   addr_reg: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         addr <= (others => '0');
      elsif(clk_i'event and clk_i = '1') then
         addr <= addr;
         if(cyc_i = '1') then
            addr <= addr_i;
         end if;
      end if;
   end process addr_reg;

------------------------------------------------------------
--  WB FSM
------------------------------------------------------------

   -- clocked FSMs, advance the state for both FSMs
   state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         current_state     <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         current_state     <= next_state;
      end if;
   end process state_FF;

   -- Transition table for DAC controller
   state_NS: process(current_state, rd_cmd, wr_cmd, cyc_i)
   begin
      -- Default assignments
      next_state <= current_state;

      case current_state is
         when IDLE =>
            if(wr_cmd = '1') then
               next_state <= WR;
            elsif(rd_cmd = '1') then
               next_state <= RD1;
            end if;

         when WR =>
            if(cyc_i = '0') then
               next_state <= IDLE;
            end if;

         when RD1 =>
            next_state <= RD2;

         when RD2 =>
            if(cyc_i = '0') then
               next_state <= IDLE;
            else
               next_state <= RD1;
            end if;

         when others =>
            next_state <= IDLE;

      end case;
   end process state_NS;

   -- Output states for DAC controller
   state_out: process(current_state, stb_i, addr_i, cyc_i, addr, tga_i)
   begin
      -- Default assignments
      flux_fb_wren      <= '0';
      ln_bias_wren      <= '0';
      ack_o             <= '0';
      flux_fb_changed_o <= '0';
      ln_bias_changed_o <= '0';
      ram_addr          <= tga_i(FLUX_FB_DAC_ADDR_WIDTH-1 downto 0);

      case current_state is
         when IDLE  =>
            ack_o <= '0';

         when WR =>
            ack_o <= '1';

            if(stb_i = '1') then
               if(addr_i = FLUX_FB_ADDR or addr_i = FLUX_FB_UPPER_ADDR) then
                  flux_fb_wren <= '1';
               end if;
               if (addr_i = FLUX_FB_UPPER_ADDR) then
                  ram_addr <= tga_i(FLUX_FB_DAC_ADDR_WIDTH-1 downto 0) + 16;
               end if;
               if(addr = BIAS_ADDR) then
                  ln_bias_wren <= '1';
               end if;
               
            end if;

            -- This is so that the bias block does not update bias during every frame - only when the values are changed
            if(cyc_i = '0') then
               if(addr = FLUX_FB_ADDR or addr = FLUX_FB_UPPER_ADDR) then
                  flux_fb_changed_o <= '1';
               end if;
               if(addr = BIAS_ADDR) then
                  ln_bias_changed_o <= '1';
               end if;
            end if;

         when RD1 =>
            if (addr = FLUX_FB_UPPER_ADDR) then
               ram_addr <= tga_i(FLUX_FB_DAC_ADDR_WIDTH-1 downto 0) + 16;
            end if;
            ack_o <= '0';

         when RD2 =>
            if (addr = FLUX_FB_UPPER_ADDR) then
               ram_addr <= tga_i(FLUX_FB_DAC_ADDR_WIDTH-1 downto 0) + 16;
            end if;
            ack_o  <= '1';

         when others =>
            null;

      end case;
   end process state_out;

------------------------------------------------------------
--  Wishbone interface
------------------------------------------------------------

   with addr_i select dat_o <=
      ext(flux_fb_data, WB_DATA_WIDTH)  when FLUX_FB_ADDR,
      ext(flux_fb_data, WB_DATA_WIDTH)  when FLUX_FB_UPPER_ADDR,
      ext(ln_bias_data, WB_DATA_WIDTH) when BIAS_ADDR,
      (others => '0') when others;

   master_wait <= '1' when ( stb_i = '0' and cyc_i = '1') else '0';

   rd_cmd  <= '1' when
      (stb_i = '1' and cyc_i = '1' and we_i = '0') and
      (addr_i = FLUX_FB_ADDR or addr_i = FLUX_FB_UPPER_ADDR or addr_i = BIAS_ADDR) else '0';

   wr_cmd  <= '1' when
      (stb_i = '1' and cyc_i = '1' and we_i = '1') and
      (addr_i = FLUX_FB_ADDR or addr_i = FLUX_FB_UPPER_ADDR or addr_i = BIAS_ADDR) else '0';

end rtl;