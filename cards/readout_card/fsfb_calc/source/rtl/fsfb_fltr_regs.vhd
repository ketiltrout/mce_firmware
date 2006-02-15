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
-- fsfb_fltr_regs.vhd
--
-- Project:	  SCUBA-2
-- Author:        Mandana Amiri
-- Organisation:  UBC
--
-- Description:
-- fsfb_fltr_regs
--
-- This block is a collection of regsiters to store the wn terms of the
-- IIR filter (in direct form II). Due to limited logic resources, this
-- block is implemented using altsyncram 
--
--
-- Revision history:
-- 
-- <date $Date: 2005/12/12 23:48:05 $>    - <initials $Author: mandana $>
-- $Log: fsfb_fltr_regs.vhd,v $
-- Revision 1.2  2005/12/12 23:48:05  mandana
-- fix the bug with clearing wn2 upon initilize_window, tied wren for fsfb_wn2_Q to wren_muxed instead of wren_i
--
-- Revision 1.1  2005/11/30 18:20:08  mandana
-- initial release
--
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- Call Parent Library
use work.readout_card_pack.all;
use work.flux_loop_pack.all;
use work.fsfb_calc_pack.all;

entity fsfb_fltr_regs is
   port (    
      -- global signals
      rst_i                     : in     std_logic;                                    -- global reset
      clk_50_i                  : in     std_logic;                                    -- global clock (50 MHz)
      fltr_rst_i                : in     std_logic;                                    

      -- register interface     
      addr_i                    : in     std_logic_vector(FLTR_QUEUE_ADDR_WIDTH-1 downto 0);
      wn2_o                     : out    std_logic_vector(FILTER_DLY_WIDTH-1 downto 0);
      wn1_o 			: out    std_logic_vector(FILTER_DLY_WIDTH-1 downto 0);
      wn_i                      : in     std_logic_vector(FILTER_DLY_WIDTH-1 downto 0);
      wren_i                    : in     std_logic
   );
end fsfb_fltr_regs;

architecture rtl of fsfb_fltr_regs is

   signal wn1_temp       : std_logic_vector (FILTER_DLY_WIDTH-1 downto 0);
   signal wn1_temp_muxed : std_logic_vector (FILTER_DLY_WIDTH-1 downto 0);
   signal wn_muxed       : std_logic_vector (FILTER_DLY_WIDTH-1 downto 0);
   signal wren_muxed     : std_logic;
   
begin

   -- use a multiplexer to reset wn values when fltr_rst_i is asserted
   -- fltr_rst_i is high for the period of one frame, hence, initializing
   -- wn values for all addresses.
   wn1_temp_muxed <= (others=>'0') when fltr_rst_i = '1' else
                     wn1_temp;
                     
   wn_muxed       <= (others=>'0') when fltr_rst_i = '1' else
                     wn_i;                  

   wren_muxed     <= '1'           when fltr_rst_i = '1' else
                     wren_i;                  


   i_fsfb_wn1_Q : fsfb_wn_queue
      port map (
         data                         => wn_muxed,
         address                      => addr_i,         
         wren                         => wren_muxed,
         clock                        => clk_50_i,
         q                            => wn1_temp
      );   
   
   
   i_fsfb_wn2_Q : fsfb_wn_queue
      port map (
         data                         => wn1_temp_muxed,
         address                      => addr_i,
         wren                         => wren_muxed,
         clock                        => clk_50_i,
         q                            => wn2_o
      );
      
   wn1_o <= wn1_temp_muxed;
      
end rtl;

