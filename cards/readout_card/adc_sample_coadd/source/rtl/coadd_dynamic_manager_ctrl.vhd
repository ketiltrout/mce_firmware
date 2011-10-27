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
-- coadd_dynamic_manager_ctrl.vhd
--
-- Project:   SCUBA-2
-- Author:        Mohsen Nahvi
-- Organisation:  UBC
--
-- Description:
--
-- This block is the controller for coadd_manager_data_path and
-- dynamic_manager_data_path.  Coadd Manager and dynamic mangers are components
-- of the adc_sample_coadd block.
-- 
-- The actions taken in this block are:
-- 
-- 1. Make a last_row and its delayed version of last_row_5delay to indicates
-- the last row of a frame. These signals mark the frame boundary and the
-- number of rows in the frame.
--
-- 2. Deduce wren qualifier from adc_coadd_en_4delay_i, and use it to control
-- wren of appropriate data bank.  A select signal, current_bank, is used for
-- that MUX.  current_bank is deduced from wren ANDED with last-row indicative
-- signal, i.e., last_row and last_row_5delay.  Again, current_bank need to be
-- asserted at the boundary of a frame and the frame boundary information is
-- only available in last_row_5delay.
--
-- 3. Generate a delayed version of adc_coadd_en_i.
--
-- 4. Deduce an internal qualifier, coadd_cycle, from adc_coadd_en_i and
-- another qualifier, do_coadd_done, from coadd_cycle and row switch to decide
-- if we need to generate coadd_done_o.  Note that coadd_done_o is to be
-- asserted for one clock cycle and after certain delay from the end of row.
-- This signal is only to be asserted if coadding was done in the row dwell
-- time. 
--
-- 5. Deduce output signals based on internal qualifiers.
--
-- Ports:
-- #rst_i: global reset active high
-- #clk_i: global clock
-- #restart_frame_1row_prev_i: input signal to adc_sample_coadd block from
-- frame timing block.  It is high for one clock cycle and its falling edge
-- corresponds to to the beginning for row 40 cycle time in any frame.
-- #restart_frame_aligned_i: Input to flux_loop_ctrl block from frame_timing
-- block. This signal is high for one clock cycle and its falling edge
-- corresponds to the row0 cycle time in a new data frame.
-- #row_switch_i: Input to flux_loop_ctrl block from frame_timing block.  This
-- signal is high for one clock cycle at the end of each row dwell time and its
-- falling edge corresponds to the boundary of the row cycle.
-- #adc_coadd_en_i: System input that indicates the window to do coadd.
-- #adc_coadd_en_5delay_i: Input from coadd_manager_data_path. This signals is
-- the 5th clock delay of adc_coadd_en_i.
-- #adc_coadd_en_4delay_i: Input from coadd_manager_data_path. This signals is
-- the 4th clock delay of adc_coadd_en_i.
-- #clr_samples_coadd_reg_o: Out signal to coadd_manager_data_path and is
-- assrted high (true) for entire duration of coadding plus two colck cycles.
-- In the 1st clock cycle the data is written into the memory bank, and in the
-- 2nd cycle the register is cleared.  This signal clears the register holding
-- the coadd value.
-- #address_count_en_o: Out put to coadd_manager_data_path.  This signal is
-- high for only one clock cycle after the coadded value is writen into the
-- memory bank.  It enables the index counter to the next memory location.
-- Note that the address index points to the present row during coadding.
-- #clr_address_count_o: Output to coadd_manager_data_path.  This signal is
-- asserted high for one clock cycle and only once per frame.  It is asserted
-- after the coaddition of the last row in a frame is done.  It clears the
-- address index that points to the location where in the memory bank the
-- coadded data is stored.
-- #wren_bank0_o: Output to coadd_dat_bank0.  It is high for one clock cycle
-- right after the time the coadd is finished and we can write the data into
-- the memory banks.
-- #wren_bank1_o: Output to coadd_dat_bank1.  It is high for one clock cycle
-- right after the time the coadd is finished and we can write the data into
-- the memory banks.
-- #wren_for_fsfb_o: Output to dynamic_manager_data_path.  This is the same as
-- the wren used for writing into the banks, i.e., it represents the time in
-- the state of the system when the data is ready to be wrtien into the memory
-- banks and into the registers used for outpuing data to first stage feedback
-- calc (fsfb_calc) block.
-- #coadd_done_o: This is the output of the parent block.  It is asserted after
-- certain delay after each row_switch_i if adc_coadd_en_4delay_i is present in
-- that row.
-- #current_bank_o: Output to coadd_manager_data_path and
-- dynamic_dat_manager_data_path.  The value of this signal represents the
-- number of the bank that is current: 0= bank0 is current, 1=bank1 is current.
-- This signal is updated right after the coadded data for the last row, row40,
-- in any frame is writen into.
--
-- Signals:
-- #current_bank: Intenal register representation of current_bank_o.
-- 
-- Qualifiers:
-- #wren: Internal register to indicate when we can write to the memory banks.
-- It is high for one clock cycle.  It feeds into a MUX and drives wren_bank1_o
-- or wren_bank0_o based on current_bank register.
-- #last_row: This qualifier is high for the entire duration of the last row in
-- a frame.
-- #delayed_last_row: a shift register to delay last_row.
-- #delay_row_switch: a shift register to delay row_switch_i.
-- #coadd_cycle: This is asserted when adc_coadd_en_i is high and diasserts
-- when  row_switch_i is seen.  Indicates that we did coadd during row time.
-- #do_coadd_done: Indicates that we need to do coadd_done_o.  This is used to
-- avoid keeping coadd_cycle asserted high after the boundary of a row in case
-- we have adc_coadd_en_i that comes soon.  The rising edge of do_coadd_done is
-- activated by both row_switch_i and coadd_cycle.  The falling edge is
-- activated by coadd_done_o itself.
-- 
-- 
-- Revision history:
-- 
-- $Log: coadd_dynamic_manager_ctrl.vhd,v $
-- Revision 1.4  2009/04/09 19:10:44  bburger
-- BB: Removed the default assignement of ADC_LATENCY which is a constant that doesn't exist anymore.
--
-- Revision 1.3  2004/12/13 21:50:22  mohsen
-- To avoid synthesis complication, changed the construct to generate shift register.
--
-- Revision 1.2  2004/10/29 01:52:12  mohsen
-- Sorted out library use and use parameters
--
-- Revision 1.1  2004/10/22 00:14:37  mohsen
-- Created
--
--
------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
use work.adc_sample_coadd_pack.all;


entity coadd_dynamic_manager_ctrl is

  generic (
    COADD_DONE_MAX_COUNT : integer := 7;  -- = max delay+1 for coadd_done 
    MAX_SHIFT            : integer := 5); -- = Delay stages for the
                                                      -- coadd enable signal 
 
  port (
    rst_i                     : in  std_logic;
    clk_i                     : in  std_logic;
    restart_frame_1row_prev_i : in  std_logic;
    restart_frame_aligned_i   : in  std_logic;
    row_switch_i              : in  std_logic;
    adc_coadd_en_i            : in  std_logic;
    adc_coadd_en_5delay_i     : in  std_logic;
    adc_coadd_en_4delay_i     : in  std_logic;
    clr_samples_coadd_reg_o   : out std_logic;
    address_count_en_o        : out std_logic;
    clr_address_count_o       : out std_logic;
    wren_bank0_o              : out std_logic;
    wren_bank1_o              : out std_logic;
    wren_for_fsfb_o           : out std_logic;
    coadd_done_o              : out std_logic;
    current_bank_o            : out std_logic);

end coadd_dynamic_manager_ctrl;


architecture timing_beh of coadd_dynamic_manager_ctrl is

  -- internal signals
  signal current_bank      : std_logic;
  
  
  -- internal qualifiers
  signal wren              : std_logic;
  signal last_row          : std_logic;
  signal delayed_last_row  : std_logic_vector(MAX_SHIFT-1 downto 0);
  alias  last_row_5delay   : std_logic is delayed_last_row(MAX_SHIFT-1);
  signal delay_row_switch  : std_logic_vector(COADD_DONE_MAX_COUNT-1 downto 0);
  alias  row_switch_max_dly: std_logic is delay_row_switch(COADD_DONE_MAX_COUNT-1);
  signal coadd_cycle       : std_logic;
  signal do_coadd_done     : std_logic;

  

begin  -- timing_beh


  -----------------------------------------------------------------------------
  -- Generate last_row qualifier.
  -- This signal is the only signal representative of the number of rows in a
  -- frame that we are relying on in this block.  Note that other signals like
  -- adc_coadd_en_i that we rely on does not have any information as to the row
  -- number in the frame.
  -----------------------------------------------------------------------------

  i_last_row: process (clk_i, rst_i)
  begin  -- process i_last_row
    if rst_i = '1' then                 -- asynchronous reset (active high)
      last_row <= '0';
      
    elsif clk_i'event and clk_i = '1' then  -- rising clock edge

      if restart_frame_1row_prev_i = '1' then
        last_row <= '1';
      elsif restart_frame_aligned_i = '1' then
        last_row <= '0';
      else
        last_row <= last_row;
      end if;
      
    end if;
  end process i_last_row;


  
  -----------------------------------------------------------------------------
  -- Shift last row qualifier by 5 clock cycles.  5 is the result of A/D
  -- latency of four clock cycles plus an extra clock cycles for the wren
  -- signal. In essence, we use last_row_5delay as indication of when to assert
  -- signals related to the new frame timing.
  -----------------------------------------------------------------------------
  
  i_shift_delay: process (clk_i, rst_i)
  begin  -- process i_shift_delay
    if rst_i = '1' then                 -- asynchronous reset (active high)
      delayed_last_row <= (others => '0');
      
    elsif clk_i'event and clk_i = '1' then  -- rising clock edge
      
      delayed_last_row(MAX_SHIFT-1 downto 1) <= delayed_last_row(MAX_SHIFT-2 downto 0);
      delayed_last_row(0)                    <= last_row;
      
    end if;
  end process i_shift_delay;


  -----------------------------------------------------------------------------
  -- Shift row_switch_i by COADD_DONE_MAX_COUNT
  -----------------------------------------------------------------------------

  i_shift_row_switch: process (clk_i, rst_i)
  begin  -- process i_shift_row_switch
    if rst_i = '1' then                 -- asynchronous reset (active high)
      delay_row_switch <= (others => '0');
      
    elsif clk_i'event and clk_i = '1' then  -- rising clock edge

      delay_row_switch(COADD_DONE_MAX_COUNT-1 downto 1) <= delay_row_switch(COADD_DONE_MAX_COUNT-2 downto 0);
      delay_row_switch(0)                               <= row_switch_i;
      
    end if;
  end process i_shift_row_switch;
  
  
  -----------------------------------------------------------------------------
  -- Generate Rest of qualifiers
  -----------------------------------------------------------------------------

  i_qulifiers: process (clk_i, rst_i)
  begin  -- process i_qulifiers
    if rst_i = '1' then                 -- asynchronous reset (active high)
      current_bank        <= '0';
      coadd_cycle         <= '0';
      do_coadd_done       <= '0';
      
    elsif clk_i'event and clk_i = '1' then  -- rising clock edge

      
      if (wren = '1' and last_row_5delay = '1') then
        current_bank <= not current_bank;
      else
        current_bank <= current_bank;
      end if;

      if (row_switch_i='1') then
        coadd_cycle <= '0';
      elsif (adc_coadd_en_i = '1') then
        coadd_cycle <= '1';
      else
        coadd_cycle <= coadd_cycle;
      end if;

      if (row_switch_max_dly = '1') then
        do_coadd_done <= '0';
      elsif (row_switch_i = '1' and coadd_cycle = '1') then
        do_coadd_done <= '1';
      else
        do_coadd_done <= do_coadd_done;
      end if;
      
    end if;
  end process i_qulifiers;

  wren           <= (not adc_coadd_en_4delay_i) and (adc_coadd_en_5delay_i);
  current_bank_o <= current_bank;


  
  -----------------------------------------------------------------------------
  -- Generate output signals
  -----------------------------------------------------------------------------

  i_control_outputs: process (clk_i, rst_i)
  begin  -- process i_control_outputs
    if rst_i = '1' then                 -- asynchronous reset (active high)

      address_count_en_o  <= '0';
      clr_address_count_o <= '0';
      
    elsif clk_i'event and clk_i = '1' then  -- rising clock edge

      if wren = '1' then
        address_count_en_o <= '1';      -- update address index only if wrote
                                        -- into memory 
      else
        address_count_en_o <= '0';
      end if;

      if (wren = '1' and last_row_5delay = '1') then
        clr_address_count_o <= '1';
      else
        clr_address_count_o <= '0';
      end if;

      
    end if;
  end process i_control_outputs;

  clr_samples_coadd_reg_o <= not (adc_coadd_en_4delay_i or
                                  adc_coadd_en_5delay_i);

  wren_bank0_o            <= wren when current_bank='0' else
                             '0';

  wren_bank1_o            <= wren when current_bank='1' else
                             '0';
  
  wren_for_fsfb_o         <= wren;

  coadd_done_o            <= (do_coadd_done and row_switch_max_dly);

  
end timing_beh;
