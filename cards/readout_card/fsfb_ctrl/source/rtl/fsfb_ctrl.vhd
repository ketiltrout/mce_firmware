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
-- fsfb_ctrl.vhd
--
-- Project:   SCUBA-2
-- Author:        Mohsen Nahvi
-- Organisation:  UBC
--
-- Description:
-- 
-- This block is part of the flux_loop_ctrl block, which in turn is part of the
-- readout card.  Here is a short description of the functions of this block:
--
-- 1. This block latched the data coming from fsfb_calc on the ready signal
-- from that block.
--
-- 2. It then converts the 2's complement value recieved into binary value
-- according to the CONVERSION_POLARITY_MODE.  The flag is 1 for reverse
-- polarity where a positive change in the balometer voltage results in a
-- negative value in the ADC and hence a negative value in the fsfb_calc.
-- 
-- 3. Based on fsfb_ctrl_lock_en_i, it may ignore the result of the conversion
-- map and use the fsfb_ctrl_dat_i directly.  The conversion and decision to
-- use the unchange input data is done in one clock cycle.  In the next cycle
-- after the latching of the data and converting, the converted(or unconverted)
-- data, i.e., dac_dat is latched into another register to provide dac_dat_o.
-- An internal qualifer, rdy_to_clk_dac, is asserted at this time.
-- 
-- 4. An ecoding clock is generated when dac_dat_en_i is seen and the internal
-- qualifier of rdy_to_clk_dac is valid. The internal qualifier is disasserted.
--
--
--
-- Ports:
-- #clk_50_i: global clock
-- #rst_i: global reset active high
-- #dac_dat_en_i: system input that indicates the window to send data to dac
-- #fsfb_ctrl_dat_i: Data input from the upstream block, fsfb_calc
-- #fsfb_ctrl_dat_rdy_i: Input from the upstream block, fsfb_calc, asserts for
-- one clock cycle when input data is ready.
-- #fsfb_ctrl_lock_en_i: Input from the upstream block, fsfb_calc. It is high
-- when the flux_loop_ctrl is in lock mode.  Hence the data from fsfb_calc
-- needs to be mapped for the DAC, i.e., the data is 2's complement.  When the
-- input is low, it indicates the input data is normal binary number and no
-- mapping is needed.
-- #dac_dat_o: Data output to DAC.
-- #dac_clk_o: Encoding clock to DAC.
-- 
--
-- Revision history:
-- 
-- $Log: fsfb_ctrl.vhd,v $
-- Revision 1.4  2004/12/14 19:59:47  bench2
-- Fix unused condition
--
-- Revision 1.3  2004/12/04 03:11:14  mohsen
-- Corrected error in not using the sign
--
-- Revision 1.2  2004/11/26 18:27:02  mohsen
-- Anthony & Mohsen: Restructured constant declaration.  Moved shared constants from lower level package files to the upper level ones.  This was done to resolve compilation error resulting from shared constants defined in multiple package files.
--
-- Revision 1.1  2004/11/05 02:13:07  mohsen
-- Initial release
--
--
--
------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
use work.fsfb_ctrl_pack.all;

-- Call Parent Library
use work.flux_loop_ctrl_pack.all;
use work.readout_card_pack.all;

entity fsfb_ctrl is
  
  generic (
    CONVERSION_POLARITY_MODE : integer := 0;                 -- a 0 indicates straight polarity in ADC conversion, a 1 indicates reverse polarity
    FSFB_ACCURACY_POSITION   : integer := DAC_DAT_WIDTH-1);  -- Indicates the position (with 0 the starting point) of MSB in the FSFB data that needs to be used for sending to DAC

  port (
    -- Global Signals
    clk_50_i            : in  std_logic;
    rst_i               : in  std_logic;

    -- From Frame Timing
    dac_dat_en_i        : in  std_logic;

    -- Upstream fsfb_calc interface
    fsfb_ctrl_dat_i     : in  std_logic_vector(FSFB_DAT_WIDTH-1 downto 0);
    fsfb_ctrl_dat_rdy_i : in  std_logic;
    fsfb_ctrl_lock_en_i : in  std_logic;

    -- DAC Interface
    dac_dat_o           : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
    dac_clk_o           : out std_logic);

end fsfb_ctrl;



architecture rtl of fsfb_ctrl is

  signal fsfb_ctrl_dat        : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
  signal fsfb_ctrl_mux_dat    : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
  signal dac_dat              : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
  signal fsfb_ctrl_dat_mapped : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
  signal latch_dac_dat        : std_logic;
  signal rdy_to_clk_dac       : std_logic;
  signal dac_clk              : std_logic;

  
begin  -- rtl

    

  -----------------------------------------------------------------------------
  -- Latch in the Input from fsfb_calc
  -- Note that only 14 bits of the bits out of 32 bits are used.  However, the
  -- position of the accuracy is determined by the generic value.  Normally, we
  -- are interested in the lowest significant 14 bits.
  -----------------------------------------------------------------------------

  with fsfb_ctrl_lock_en_i select
    fsfb_ctrl_mux_dat <=
    fsfb_ctrl_dat_i(FSFB_DAT_WIDTH-1) & fsfb_ctrl_dat_i (FSFB_ACCURACY_POSITION-1 downto (FSFB_ACCURACY_POSITION - DAC_DAT_WIDTH +1)) when '1',
    fsfb_ctrl_dat_i (DAC_DAT_WIDTH-1 downto 0) when others;
  
  i_latch_fsfb_dat: process (clk_50_i, rst_i)
  begin  -- process i_latch_fsfb_dat
    if rst_i = '1' then                 -- asynchronous reset (active high)
      fsfb_ctrl_dat <= (others => '0');
      
    elsif clk_50_i'event and clk_50_i = '1' then  -- rising clock edge
      if fsfb_ctrl_dat_rdy_i='1' then
        fsfb_ctrl_dat <= fsfb_ctrl_mux_dat;
      else
        fsfb_ctrl_dat <= fsfb_ctrl_dat;
      end if;
      
    end if;
  end process i_latch_fsfb_dat;

    
  
  -----------------------------------------------------------------------------
  -- Conversion Map.
  -- Instead of adding the offset, a more clever method is used.  See
  -- documentation for more details.
  -----------------------------------------------------------------------------

  map_with_straight_polarity: if CONVERSION_POLARITY_MODE=0 generate
    fsfb_ctrl_dat_mapped <=
      ((not fsfb_ctrl_dat(DAC_DAT_WIDTH-1)) & fsfb_ctrl_dat(DAC_DAT_WIDTH-2 downto 0));    
  end generate map_with_straight_polarity;


  map_with_reverse_polarity: if CONVERSION_POLARITY_MODE=1 generate
    fsfb_ctrl_dat_mapped <=
      (fsfb_ctrl_dat(DAC_DAT_WIDTH-1) & (not fsfb_ctrl_dat(DAC_DAT_WIDTH-2 downto 0)));
  end generate map_with_reverse_polarity;
    
  
  -----------------------------------------------------------------------------
  -- MUX for selecting lock mode or other modes
  -----------------------------------------------------------------------------

  dac_dat <=
    fsfb_ctrl_dat_mapped when fsfb_ctrl_lock_en_i='1' else
    fsfb_ctrl_dat;

  

  -----------------------------------------------------------------------------
  -- Latch DAC output value
  -----------------------------------------------------------------------------
  
  i_latch_dac_out: process (clk_50_i, rst_i)
  begin  -- process i_latch_dac_out
    if rst_i = '1' then                 -- asynchronous reset (active high)
      dac_dat_o <= (others => '0');
      
    elsif clk_50_i'event and clk_50_i = '1' then  -- rising clock edge
      if latch_dac_dat='1' then
        dac_dat_o <= dac_dat;
      end if;
      
    end if;
  end process i_latch_dac_out;


  
  -----------------------------------------------------------------------------
  -- Delay fsfb_ctrl_dat_rdy_i by one clock cycle to generate the latch_dac_dat
  -- signal.  This is because we latch to DAC register output right after we
  -- read in the fsfb data
  -----------------------------------------------------------------------------

  i_dly_fsfb_dat_rdy: process (clk_50_i, rst_i)
  begin  -- process i_dly_fsfb_dat_rdy
    if rst_i = '1' then                 -- asynchronous reset (active high)
      latch_dac_dat <= '0';
    elsif clk_50_i'event and clk_50_i = '1' then  -- rising clock edge
      latch_dac_dat <= fsfb_ctrl_dat_rdy_i;      
    end if;
  end process i_dly_fsfb_dat_rdy;



  
  -----------------------------------------------------------------------------
  -- Generate control and output signals
  -----------------------------------------------------------------------------
  i_control: process (clk_50_i, rst_i)
  begin  -- process i_control
    if rst_i = '1' then                 -- asynchronous reset (active high)
      rdy_to_clk_dac <= '0';
      dac_clk        <= '0';
      
    elsif clk_50_i'event and clk_50_i = '1' then  -- rising clock edge

      -- internal qualifier
      if latch_dac_dat='1' then
        rdy_to_clk_dac <= '1';
      elsif dac_clk='1' then
        rdy_to_clk_dac <= '0';
      else
        rdy_to_clk_dac <= rdy_to_clk_dac;
      end if;

      
      -- output signal
      case dac_clk is
        when '0' =>
          dac_clk <= (dac_dat_en_i and rdy_to_clk_dac);
        when others =>
          dac_clk <= '0';
      end case;
      
    end if;
  end process i_control;

  dac_clk_o <= dac_clk;


  
  -----------------------------------------------------------------------------
  -- 
  -----------------------------------------------------------------------------

  
end rtl;
