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
-- $Id$
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
-- $Log$
--   
--
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.data_types_pack.all;
use sys_param.frame_timing_pack.all;
use sys_param.command_pack.all;

library work;
use work.wbs_ac_dac_ctrl_pack.all;

package ac_dac_ctrl_pack is

   constant AC_NUM_BUSES : integer := 11;
   constant AC_BUS_WIDTH : integer := 14;
   constant ROW_COUNTER_MAX : integer := 63;

component ac_dac_ctrl is        
   port
   (
      -- DAC hardware interface:
      dac_data_o              : out w14_array11;   
      dac_clks_o               : out std_logic_vector(NUM_OF_ROWS downto 0);
   
      -- wbs_ac_dac_ctrl interface:
      on_off_addr_o           : out std_logic_vector(ROW_ADDR_WIDTH-1 downto 0); --
      dac_id_i                : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      on_data_i               : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      off_data_i              : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0); 
      mux_en_i                : in std_logic; --
      
      -- frame_timing interface:
      row_switch_i            : in std_logic; --
      restart_frame_aligned_i : in std_logic; --
      row_en_i                : in std_logic; --
      
      -- Global Signals      
      clk_i                   : in std_logic;
      mem_clk_i               : in std_logic;
      rst_i                   : in std_logic
   );     
end component;


end ac_dac_ctrl_pack;