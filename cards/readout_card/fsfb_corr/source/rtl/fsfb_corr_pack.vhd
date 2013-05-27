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
-- $Id: fsfb_corr_pack.vhd,v 1.11 2012-10-30 23:31:12 mandana Exp $
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
-- Revision 1.11  2012-10-30 23:31:12  mandana
-- rewrote fsfb_corr, new types defined for clarity
--
-- Revision 1.10  2010/08/04 21:44:53  bburger
-- BB: increased the width of the flux-quanta multiplier input by 1 to fix a bug associated with signed multiplications.
--
-- Revision 1.9  2009/01/19 20:23:35  bburger
-- BB:  Merged v1.8.2.3 to head
--
-- Revision 1.8.2.3  2007/03/22 17:44:29  mandana
-- reduced sub & mult width, made the widths parameterized.
-- cleaned up unused functions and vars
--
-- Revision 1.8.2.2  2006/07/24 23:22:13  mandana
-- changed multiplier and subtractor width to relax timing
--
-- Revision 1.8.2.1  2006/04/03 19:31:01  mandana
-- LSB_WINDOW_INDEX changed from 14 to 12
--
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
use ieee.std_logic_arith.all;

library work;
use work.flux_loop_ctrl_pack.all;
use work.flux_loop_pack.all;
use work.readout_card_pack.all;

package fsfb_corr_pack is

   -- This is the index of the least significant bit used in the flux-jumping algorithm
   -- Using a window of this type is equivalent to dividing P, I and D by 2^12.
   constant LSB_WINDOW_INDEX       : integer := 12;  
   
   constant SUB_WIDTH              : integer := FSFB_QUEUE_DATA_WIDTH - LSB_WINDOW_INDEX; -- length of pid_prev as it comes to fsfb_corr (40-12=28)
   constant MULT_WIDTH             : integer := FLUX_QUANTA_DATA_WIDTH+1; -- Has to be one bit wider than FLUX_QUANTA_DATA_WIDTH to force it to be positive value for signed multiplication.
   constant PROD_WIDTH             : integer := MULT_WIDTH+FLUX_QUANTA_CNT_WIDTH; -- 15+8=23

   constant FSFB_MAX               : std_logic_vector(SUB_WIDTH-1 downto 0) := sxt(b"01111001111000", SUB_WIDTH);-- 1E78"; --  7800
   constant FSFB_MIN               : std_logic_vector(SUB_WIDTH-1 downto 0) := sxt(b"10000110001000", SUB_WIDTH);-- E188"; -- -7800
   
   constant M_MAX                  : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0) := "01111111";
   constant M_MIN                  : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0) := "10000000";
   
   constant FSFB_CLAMP_MAX         : std_logic_vector(SUB_WIDTH-1 downto 0) := sxt(b"01111111111111", SUB_WIDTH); --x1FFF; 2^13-1
   constant FSFB_CLAMP_MIN         : std_logic_vector(SUB_WIDTH-1 downto 0) := sxt(b"10000000000000", SUB_WIDTH); --x2000;-2^13

   subtype fsfb_dac_word is std_logic_vector(FSFB_QUEUE_DATA_WIDTH - LSB_WINDOW_INDEX-1 downto 0);                -- parallel DAC data
   type fsfb_dac_array is array (NUM_COLS-1 downto 0) of fsfb_dac_word;                                           -- array of parallel DAC data   

   subtype flux_jump_count_word is std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);                            -- flux-jump counter 
   type flux_jump_count_array is array (NUM_COLS-1 downto 0) of flux_jump_count_word;                             -- array of flux-jump counters

   subtype flux_quanta_word is std_logic_vector(FLUX_QUANTA_DATA_WIDTH-1 downto 0);                               -- flux-quanta data
   type flux_quanta_array is array (NUM_COLS-1 downto 0) of flux_quanta_word;                                     -- array of flux-quanta data

   subtype flux_quanta_xtnd_word is std_logic_vector(FLUX_QUANTA_DATA_WIDTH downto 0);                            -- flux-quanta data prepared for subtract block
   type flux_quanta_xtnd_array is array (NUM_COLS-1 downto 0) of flux_quanta_xtnd_word;                           -- array of flux-quanta data

   subtype mult_res_word is std_logic_vector(PROD_WIDTH-1 downto 0);                                              -- multiplier result
   type mult_res_array is array (NUM_COLS-1 downto 0) of mult_res_word;
   
   subtype sub_res_word is std_logic_vector(SUB_WIDTH-1 downto 0);                                                -- subtraction result
   type sub_res_array is array (NUM_COLS-1 downto 0) of sub_res_word;
   
   component fsfb_corr_multiplier is
      port (
         dataa    : IN STD_LOGIC_VECTOR (MULT_WIDTH-1 DOWNTO 0);
         datab    : IN STD_LOGIC_VECTOR (FLUX_QUANTA_CNT_WIDTH-1 DOWNTO 0);
         result   : OUT STD_LOGIC_VECTOR (PROD_WIDTH-1 DOWNTO 0)
      );   
   end component fsfb_corr_multiplier; 
   
   component fsfb_corr_subtractor is
      port (
         dataa    : IN STD_LOGIC_VECTOR (SUB_WIDTH-1 DOWNTO 0);
         datab    : IN STD_LOGIC_VECTOR (SUB_WIDTH-1 DOWNTO 0);
         result   : OUT STD_LOGIC_VECTOR (SUB_WIDTH-1 DOWNTO 0)
      );   
   end component fsfb_corr_subtractor; 
 
end fsfb_corr_pack;
