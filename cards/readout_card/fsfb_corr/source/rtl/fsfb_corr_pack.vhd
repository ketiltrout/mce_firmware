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
-- $Id: fsfb_corr_pack.vhd,v 1.3 2005/04/22 23:22:46 bburger Exp $
--
-- Project:       SCUBA2
-- Author:        Bryce Burger
-- Organisation:  UBC
--
-- Description:
-- 
--
-- Revision history:
-- $Log: fsfb_corr_pack.vhd,v $
-- Revision 1.3  2005/04/22 23:22:46  bburger
-- Bryce:  Fixed some bugs.  Now in working order.
--
-- Revision 1.2  2005/04/22 00:41:56  bburger
-- Bryce:  New.
--
-- Revision 1.1.2.2  2005/04/21 00:27:18  bburger
-- Bryce:  Code update.  All files compile now.
--
-- Revision 1.1.2.1  2005/04/20 00:18:43  bburger
-- Bryce:  new
--
--
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.flux_loop_ctrl_pack.all;
use work.flux_loop_pack.all;
use work.readout_card_pack.all;

package fsfb_corr_pack is

   constant SUB_WIDTH              : integer := 64;
   constant MULT_WIDTH             : integer := 32;
   constant PROD_WIDTH             : integer := 64;

   constant FSFB_MAX               : std_logic_vector(DAC_DAT_WIDTH-1 downto 0) := "01100000000000"; --(3/4)*(2**13);
   constant FSFB_MIN               : std_logic_vector(DAC_DAT_WIDTH-1 downto 0) := "10100000000000"; -- -(3/4)*(2**13);
   constant SIGN_XTND_M_POS        : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-FLUX_QUANTA_CNT_WIDTH-1 downto 0) := (others => '0');
   constant SIGN_XTND_M_NEG        : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-FLUX_QUANTA_CNT_WIDTH-1 downto 0) := (others => '1');
   constant SIGN_XTND_PID_PREV_POS : std_logic_vector(SUB_WIDTH-FSFB_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0');
   constant SIGN_XTND_PID_PREV_NEG : std_logic_vector(SUB_WIDTH-FSFB_QUEUE_DATA_WIDTH-1 downto 0) := (others => '1');

   component fsfb_corr_multiplier is
      port (
         dataa    : IN STD_LOGIC_VECTOR (MULT_WIDTH-1 DOWNTO 0);
         datab    : IN STD_LOGIC_VECTOR (MULT_WIDTH-1 DOWNTO 0);
         result      : OUT STD_LOGIC_VECTOR (PROD_WIDTH-1 DOWNTO 0)
      );   
   end component fsfb_corr_multiplier; 
   
   component fsfb_corr_subtractor is
      port (
         dataa    : IN STD_LOGIC_VECTOR (SUB_WIDTH-1 DOWNTO 0);
         datab    : IN STD_LOGIC_VECTOR (SUB_WIDTH-1 DOWNTO 0);
         result      : OUT STD_LOGIC_VECTOR (SUB_WIDTH-1 DOWNTO 0)
      );   
   end component fsfb_corr_subtractor; 

   function sign_xtnd_m (input : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0)) return std_logic_vector;

   function sign_xtnd_pid_prev (input : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0)) return std_logic_vector;
   
end fsfb_corr_pack;

package body fsfb_corr_pack is

   function sign_xtnd_m (input : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0)) return std_logic_vector is
   variable result : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);
   begin
      case input(FLUX_QUANTA_CNT_WIDTH-1) is
         when '0' =>    result := SIGN_XTND_M_POS & input;           
         when '1' =>    result := SIGN_XTND_M_NEG & input;
         when others => result := (others => '0');
      end case;
      return result;
   end function sign_xtnd_m;

   function sign_xtnd_pid_prev (input : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0)) return std_logic_vector is
   variable result : std_logic_vector(SUB_WIDTH-1 downto 0);
   begin
      case input(FSFB_QUEUE_DATA_WIDTH-1) is
         when '0' =>    result := SIGN_XTND_PID_PREV_POS & input;           
         when '1' =>    result := SIGN_XTND_PID_PREV_NEG & input;
         when others => result := (others => '0');
      end case;
      return result;
   end function sign_xtnd_pid_prev;

end package body fsfb_corr_pack;