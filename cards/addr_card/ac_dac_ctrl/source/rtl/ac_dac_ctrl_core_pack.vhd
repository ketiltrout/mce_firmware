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
-- $Id: ac_dac_ctrl_core_pack.vhd,v 1.1 2004/11/20 01:20:44 bburger Exp $
--
-- Project:       SCUBA2
-- Author:        Bryce Burger
-- Organisation:  UBC
--
-- Description:
-- 14-bit 165MS/s DAC (AD9744) controller pack file
-- This block must be coupled with frame_timing and wbs_ac_dac_ctrl blocks to work properly
--
-- Revision history:
-- $Log: ac_dac_ctrl_core_pack.vhd,v $
-- Revision 1.1  2004/11/20 01:20:44  bburger
-- Bryce :  fixed a bug in the ac_dac_ctrl_core block that did not load the off value of the row at the end of a frame.
--
-- Revision 1.5  2004/11/18 05:21:56  bburger
-- Bryce :  modified addr_card top level.  Added ac_dac_ctrl and frame_timing
--
-- Revision 1.4  2004/11/15 20:03:41  bburger
-- Bryce :  Moved frame_timing to the 'work' library, and physically moved the files to "all_cards" directory
--
-- Revision 1.3  2004/11/02 07:38:09  bburger
-- Bryce:  ac_dac_ctrl in progress
--
--   
--
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.data_types_pack.all;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

library work;
use work.ac_dac_ctrl_wbs_pack.all;
use work.frame_timing_pack.all;

package ac_dac_ctrl_core_pack is

component ac_dac_ctrl_core is        
   port
   (
      -- DAC hardware interface:
      dac_data_o              : out w14_array11;   
      dac_clks_o              : out std_logic_vector(NUM_OF_ROWS-1 downto 0);
   
      -- Wishbone interface
      on_off_addr_o           : out std_logic_vector(ROW_ADDR_WIDTH-1 downto 0);
      dac_id_i                : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      on_data_i               : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      off_data_i              : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      mux_en_wbs_i            : in std_logic;

      -- frame_timing interface:
      row_switch_i            : in std_logic;
      restart_frame_aligned_i : in std_logic;
      row_en_i                : in std_logic;
      
      -- Global Signals      
      clk_i                   : in std_logic;
      rst_i                   : in std_logic     
   );     
end component;


end ac_dac_ctrl_core_pack;