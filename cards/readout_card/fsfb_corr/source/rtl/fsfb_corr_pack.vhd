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
-- $Id: fsfb_corr_pack.vhd,v 1.8 2006/03/24 18:35:37 bburger Exp $
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
-- Revision 1.8  2006/03/24 18:35:37  bburger
-- Bryce:
-- In fsfb_corr_pack:  converted FSFB_MAX and FSFB_MIN to std_logic_vectors
-- In fsfb_corr:  removed a conv_integer call to get rid of timing violations
--
-- Revision 1.7  2005/11/25 20:08:16  bburger
-- Bryce:  Adjusted fsfb_max = 7800 so that it is not too close to the actual sq1 V-I period of 6200 DA units -- & other modifications
--
-- Revision 1.6  2005/09/14 23:48:39  bburger
-- bburger:
-- Integrated flux-jumping into flux_loop
--
-- Revision 1.5  2005/05/06 20:06:07  bburger
-- Bryce:  Bug Fix.  The fb_max and fb_min constants weren't being initialized properly.  Any integer multiplied by a fraction is zero.
--
-- Revision 1.4  2005/04/30 01:37:42  bburger
-- Bryce:  Added a second multplier and subtractor to the fsfb_corr pipeline to reduce the time required for the flux-jumping calculation.
--
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
   
   -- This is the index of the least significant bit used in the flux-jumping algorithm
   -- Using a window of this type is equivalent to dividing P, I and D by 2^15.
   constant LSB_WINDOW_INDEX       : integer := 12;  

--   constant FSFB_MAX               : integer :=  7800;  -- Max is  (2**13)-1 =  8191;  One sq1 flux quanta is about 6200 DAC units
--   constant FSFB_MIN               : integer := -7800;  -- Min is -(2**13)   = -8192;  One sq1 flux quanta is about 6200 DAC units
   constant FSFB_MAX               : std_logic_vector(SUB_WIDTH-1 downto 0) := x"0000000000001E78"; --  7800
   constant FSFB_MIN               : std_logic_vector(SUB_WIDTH-1 downto 0) := x"FFFFFFFFFFFFE188"; -- -7800
   
   constant M_MAX                  : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0) := "01111111";
   constant M_MIN                  : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0) := "10000000";
   
   constant FSFB_CLAMP_MAX         : std_logic_vector(SUB_WIDTH-1 downto 0) := x"0000000000001FFF";  --  (2^13)-1
   constant FSFB_CLAMP_MIN         : std_logic_vector(SUB_WIDTH-1 downto 0) := x"FFFFFFFFFFFF2000";  -- -(2^13)
   
   constant SIGN_XTND_M_POS        : std_logic_vector(MULT_WIDTH - FLUX_QUANTA_CNT_WIDTH - 1 downto 0) := (others => '0');
   constant SIGN_XTND_M_NEG        : std_logic_vector(MULT_WIDTH - FLUX_QUANTA_CNT_WIDTH - 1 downto 0) := (others => '1');
   constant SIGN_XTND_PID_PREV_POS : std_logic_vector(SUB_WIDTH  - FSFB_QUEUE_DATA_WIDTH + LSB_WINDOW_INDEX - 1 downto 0) := (others => '0');
   constant SIGN_XTND_PID_PREV_NEG : std_logic_vector(SUB_WIDTH  - FSFB_QUEUE_DATA_WIDTH + LSB_WINDOW_INDEX - 1 downto 0) := (others => '1');

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

   function sign_xtnd_pid_prev (input : std_logic_vector(FSFB_QUEUE_DATA_WIDTH - LSB_WINDOW_INDEX - 1 downto 0)) return std_logic_vector;
   
end fsfb_corr_pack;

package body fsfb_corr_pack is

   function sign_xtnd_m (input : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0)) return std_logic_vector is
   variable result : std_logic_vector(MULT_WIDTH-1 downto 0);
   begin
      case input(FLUX_QUANTA_CNT_WIDTH-1) is
         when '0' =>    result := SIGN_XTND_M_POS & input;           
         when '1' =>    result := SIGN_XTND_M_NEG & input;
         when others => result := (others => '0');
      end case;
      return result;
   end function sign_xtnd_m;

   function sign_xtnd_pid_prev (input : std_logic_vector(FSFB_QUEUE_DATA_WIDTH - LSB_WINDOW_INDEX - 1 downto 0)) return std_logic_vector is
   variable result : std_logic_vector(SUB_WIDTH-1 downto 0);
   begin
      case input(input'left) is
         when '0' =>    result := SIGN_XTND_PID_PREV_POS & input;           
         when '1' =>    result := SIGN_XTND_PID_PREV_NEG & input;
         when others => result := (others => '0');
      end case;
      return result;
   end function sign_xtnd_pid_prev;

end package body fsfb_corr_pack;