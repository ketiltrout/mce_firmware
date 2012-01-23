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
-- dynamic_manager_data_path.vhd
--
-- Project:   SCUBA-2
-- Author:        Mohsen Nahvi
-- Organisation:  UBC
--
-- Description:
-- 
-- This block is the data path in the dynamic manager unit.  Dynamic manager is
-- a component of the adc_sample_coadd block.
--
-- The actions taken in this block are:
--
-- 1. Current coadd value is added to the previous integral value and saved in
-- the current memory bank for coadd integral and also written into a register
-- on the command of wren_for_fsfb_i.  However, for the duration of the
-- entire first frame, as shown by initialize_window_i the previous value of
-- the integral is neglected. Note that the current coadd value is read
-- directly from the samples_coadd_reg_o instead of reading from the coadd
-- memory bank. Note also that the previous coadd integral value is read form
-- the integral memory bank selected by current_bank_i.  Note also that all the
-- read and write address indices for the integral memory bank are equal
-- and they are the same as the address index used in the
-- coadd_manager_data_path.  In effect, the same address index is used
-- universally in the adc_sample_coadd block, except for the raw data
-- acquisition.
--
-- 2. Current coadd value is subtracted by the previous coadd value and written
-- into a register on the command of wren_for_fsfb_i.  Note that we don't use
-- memory banks to keep the difference, as previous differences are not needed.
-- Note that previous coadd value is retrieved by current_bank_i.
--
-- 3. Current coadd value is also written into a register under the command of
-- wren_for_fsfb_i to provide it for fsfb_calc block of the flux_loop_ctrl.  We
-- do this, in spite of having the data in the coadd memory bank in order to
-- make the address index signalling simple.
-- 
-- 4. qterm is a decayed pterm calculated as: q(n)=coadd(n) + b*q(n-1) where
-- b=(1-2/n) and n is a wishbone param id
--
-- Ports:
-- #rst_i: global reset active high
-- #clk_i: global clock
-- #initialize_window_i: Input from frame timing block to the parent block of
-- this current block.  This input is high for the entire duration of the first
-- frame in any sequence of frames.
-- #current_coadd_dat_i: Input form coadd_manager_data_path.  It holds the
-- coadded value for two clock cycles after the last coaddition.
-- #current_bank_i: Input from coadd_dynamic_manager_ctrl.  The value of this
-- signal represents the number of the bank that is current: 0= bank0 is
-- current, 1=bank1 is current. This signal is updated right after the coadded
-- data for the last row, row40, in any frame is writen into.
-- #wren_for_fsfb_i: Input from coadd_dynamic_manager_ctrl.  It represents the
-- time in the state of the system when the data is ready to be wrtien into
-- the memory banks and into the registers used for outpuing data to first
-- stage feedback calc (fsfb_calc) block.
-- #coadd_dat_frm_bank0_i: Input from qb of coadd_dat_bank0.
-- #coadd_dat_frm_bank1_i: Input from qb of coadd_dat_bank1.
-- #intgrl_dat_frm_bank0_i: Input from qb of intgrl_dat_bank0.
-- #intgrl_dat_frm_bank1_i: Input from qb of intgrl_dat_bank1.
-- #qterm_dat_frm_bank0_i: Input from qb of intgrl_dat_bank0.
-- #qterm_dat_frm_bank1_i: Input from qb of intgrl_dat_bank1.
-- #current_coadd_dat_o: Output to fsfb_calc block.  The data is valid from 5
-- clock cycles after the falling edge of adc_coadd_en to 5 clock cycles after
-- the falling edge of the next adc_coadd_en.
-- #current_diff_dat_o: Output to fsfb_calc block. The data is valid from 5
-- clock cycles after the falling edge of adc_coadd_en to 5 clock cycles after
-- the falling edge of the next adc_coadd_en.
-- #current_integral_dat_o: Output to fsfb_calc block. The data is valid from 5
-- clock cycles after the falling edge of adc_coadd_en to 5 clock cycles after
-- the falling edge of the next adc_coadd_en.
-- #current_qterm_dat_o: Output to fsfb_calc block. The data is valid from 5
-- clock cycles after the falling edge of adc_coadd_en to 5 clock cycles after
-- the falling edge of the next adc_coadd_en.
-- #integral_result_o: output to integral memory banks.  This is the output of
-- the combinational adder for calculating integral.
-- #qterm_result_o: output to qterm memory banks.  This is the output of
-- the combinational adder for calculating qterm.
--
--
-- signals:
-- #shifted_initialize_window: A shift register to shift initialize_window_i.
-- #integral_result: Internal representation of integral_result_o.
-- #previous_intgral: previous value of the integral.
-- #diff_result: result of the subtraction.
-- #qterm_result: Internal representation of qterm_result_o.
-- #previous_qterm: previous value of the qterm
-- #previous_coadd: previous value of coadd
-- 
--
-- Revision history:
-- 
-- $Log: dynamic_manager_data_path.vhd,v $
-- Revision 1.8  2010/10/19 23:59:25  mandana
-- integral_result is now cleared when flx_lp_init is issued
-- once fsfb hits the clamp value, the clamp is in effect until another flx_lp_init is issued.
--
-- Revision 1.7  2010/10/07 18:39:52  mandana
-- fixed a bug that caused servo instability when a clamp value was specified.
-- removed clamping of diff and coadd values, this is strictly an integral clamp.
--
-- Revision 1.6  2010/03/12 20:38:03  bburger
-- BB: added i_clamp_val interface signals and logic
--
-- Revision 1.5.2.2  2010/03/02 19:53:27  bburger
-- BB: Added logic for disabling the PID calculation clamping feature when clamp_val = 0
--
-- Revision 1.5.2.1  2009/11/13 19:28:44  bburger
-- BB: Added i-term clamp interface signals and logic.  The clamping occurs in this file.
--
-- Revision 1.5  2009/04/09 19:10:44  bburger
-- BB: Removed the default assignement of ADC_LATENCY which is a constant that doesn't exist anymore.
--
-- Revision 1.4  2004/12/13 21:50:22  mohsen
-- To avoid synthesis complication, changed the construct to generate shift register.
--
-- Revision 1.3  2004/11/26 18:25:54  mohsen
-- Anthony & Mohsen: Restructured constant declaration.  Moved shared constants from lower level package files to the upper level ones.  This was done to resolve compilation error resulting from shared constants defined in multiple package files.
--
-- Revision 1.2  2004/10/29 01:54:30  mohsen
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
use ieee.std_logic_signed.all;

library work;
use work.adc_sample_coadd_pack.all;

-- Call Parent Library
use work.flux_loop_ctrl_pack.all;




entity dynamic_manager_data_path is

  generic (
    MAX_SHIFT : integer);  -- delay stages for
                                            -- initialize_window_i
                                          
  port (

    -- From System
    rst_i                  : in  std_logic;
    clk_i                  : in  std_logic;
    i_clamp_val_i          : in  std_logic_vector(COADD_DAT_WIDTH-1 downto 0);
    qterm_decay_bits_i     : in  std_logic_vector(COADD_DAT_WIDTH-1 downto 0);
    initialize_window_i    : in  std_logic;
    
    -- From coadd_manager_data_path
    current_coadd_dat_i    : in  std_logic_vector(COADD_DAT_WIDTH-1 downto 0);

    -- From coadd_dynamic_controller
    current_bank_i         : in  std_logic;
    wren_for_fsfb_i        : in  std_logic;
    
    -- From coadd memory banks
    coadd_dat_frm_bank0_i  : in  std_logic_vector(COADD_DAT_WIDTH-1 downto 0);
    coadd_dat_frm_bank1_i  : in  std_logic_vector(COADD_DAT_WIDTH-1 downto 0);

    -- From integral memory banks
    intgrl_dat_frm_bank0_i : in  std_logic_vector(COADD_DAT_WIDTH-1 downto 0);
    intgrl_dat_frm_bank1_i : in  std_logic_vector(COADD_DAT_WIDTH-1 downto 0);

    -- From qterm memory banks
    qterm_dat_frm_bank0_i  : in  std_logic_vector(COADD_DAT_WIDTH-1 downto 0);
    qterm_dat_frm_bank1_i  : in  std_logic_vector(COADD_DAT_WIDTH-1 downto 0);

    -- Outputs to fsfb_calc
    current_coadd_dat_o    : out std_logic_vector(COADD_DAT_WIDTH-1 downto 0);
    current_diff_dat_o     : out std_logic_vector(COADD_DAT_WIDTH-1 downto 0);
    current_integral_dat_o : out std_logic_vector(COADD_DAT_WIDTH-1 downto 0);
    current_qterm_dat_o    : out std_logic_vector(COADD_DAT_WIDTH-1 downto 0);

    -- Outputs to integral memory banks
    integral_result_o      : out std_logic_vector(COADD_DAT_WIDTH-1 downto 0);
    
    -- Outputs to qterm memory banks
    qterm_result_o         : out std_logic_vector(COADD_DAT_WIDTH-1 downto 0));
  

end dynamic_manager_data_path;



architecture rtl of dynamic_manager_data_path is

  -- Signals needed for shifting initialize_window_i
  signal shifted_initialize_window : std_logic_vector(MAX_SHIFT-1 downto 0);
  alias initialize_window_max_dly  : std_logic is shifted_initialize_window(MAX_SHIFT-1);


  -- Signals needed for Integral Finder
  signal integral_result : std_logic_vector(COADD_DAT_WIDTH-1 downto 0);
  signal previous_intgral : std_logic_vector(COADD_DAT_WIDTH-1 downto 0);

  -- Signals needed for qterm Finder
  signal qterm_result   : std_logic_vector(COADD_DAT_WIDTH-1 downto 0);
  signal previous_qterm : std_logic_vector(COADD_DAT_WIDTH-1 downto 0);    
  signal previous_qterm_shift : std_logic_vector(COADD_DAT_WIDTH-1 downto 0);    
  
  -- Signals needed for Difference Finder
  signal diff_result : std_logic_vector(COADD_DAT_WIDTH-1 downto 0);
  signal previous_coadd : std_logic_vector(COADD_DAT_WIDTH-1 downto 0);
  
  -- Signals needed for the Coadd Finder  
  signal en_clamp     : std_logic;  
  
  signal QTERM_DECAY_BITS : integer range 0 to COADD_DAT_WIDTH-1 := 3;
  
begin  -- rtl
  
  --QTERM_DECAY_BITS <= conv_integer(qterm_decay_bits_i);
  
  -----------------------------------------------------------------------------
  -- Shift register to delay initialize_window_i by MAX_SHIFT clock cycles. 
  -----------------------------------------------------------------------------
  
  i_delay_initialize_window: process (clk_i, rst_i)
       
  begin  -- process i_delay_initialize_window
    if rst_i = '1' then                 -- asynchronous reset (active high)
      shifted_initialize_window <= (others => '0');
      
    elsif clk_i'event and clk_i = '1' then  -- rising clock edge

      shifted_initialize_window(MAX_SHIFT-1 downto 1) <= shifted_initialize_window(MAX_SHIFT-2 downto 0);
      shifted_initialize_window(0)                    <= initialize_window_i;

    end if;
  end process i_delay_initialize_window;

  -----------------------------------------------------------------------------
  -- Integral Adder
  -- This is a combinational adder that adds the present current coadded value
  -- to the previous integral.  However, the previous integral is selected
  -- using two MUXes, one selects the value from current bank and the other
  -- masks the previous value to zero based on the shifted value of
  -- initialize_window_i.  Note that the MUX that masks the input from memory
  -- banks has higher priority in the code wirtten here.  Also note that when
  -- current_bank_i=1, inputs from bank 1 is selected and vice versa.
  -----------------------------------------------------------------------------
  previous_intgral <=
    (others => '0')        when initialize_window_max_dly = '1' else
    intgrl_dat_frm_bank1_i when current_bank_i = '0' else
    intgrl_dat_frm_bank0_i;
  
  -----------------------------------------------------------------------------
  -- Integral-Term Clamping:
  -- When integral clamp is enabled (i_clamp_val_i /=0),  I-term is frozen until a flx_lp_init command clears the pipeline.
  -- Documented on wiki is the formula to calculate the correct clamping value for any set of PID parameters and flux-jump quanta:
  -----------------------------------------------------------------------------
  integral_result <= 
    i_clamp_val_i  when previous_intgral >= i_clamp_val_i  and i_clamp_val_i /= x"00000000" and initialize_window_max_dly ='0' else
    -i_clamp_val_i when previous_intgral <= -i_clamp_val_i and i_clamp_val_i /= x"00000000" and initialize_window_max_dly ='0' else    
    current_coadd_dat_i + previous_intgral;
  
  integral_result_o <= integral_result;

  -----------------------------------------------------------------------------
  -- qterm Adder
  -- This is a combinational adder that adds the present current coadded value
  -- to the previous qterm.qterm is a decaying p-term with a decay coefficient of 
  -- 1-1/2^n where n=QTERM_DECAY_BITS
  -- The previous qterm is selected
  -- using two MUXes, one selects the value from current bank and the other
  -- masks the previous value to zero based on the shifted value of
  -- initialize_window_i.  Note that the MUX that masks the input from memory
  -- banks has higher priority in the code wirtten here.  Also note that when
  -- current_bank_i=1, inputs from bank 1 is selected and vice versa.
  -----------------------------------------------------------------------------
  previous_qterm <=
    (others => '0')        when initialize_window_max_dly = '1' else
    qterm_dat_frm_bank1_i when current_bank_i = '0' else
    qterm_dat_frm_bank0_i;

--  previous_qterm_shift_proc : process (clk_i, rst_i)
--  variable k : integer := 0;
--  begin
--    if (rst_i = '1') then
--      previous_qterm_shift <= (others => '0');
--    elsif (clk_i'event and clk_i = '1') then
--      k := QTERM_DECAY_BITS;
--      for i in 0 to previous_qterm_shift'length -1  loop       
--        if i <= previous_qterm_shift'length-1-QTERM_DECAY_BITS then
--          previous_qterm_shift(i) <= previous_qterm(k);
--        else
--          previous_qterm_shift(i) <= previous_qterm(previous_qterm'left);                      
--        end if;
--        k := k + 1;
--      end loop;   
--    end if;
--  end process previous_qterm_shift_proc;

  -- decay coefficient of 1-1/2^n for n=3,, this is 0.875    
  qterm_result <= current_coadd_dat_i + previous_qterm - --previous_qterm_shift;
                  sxt(previous_qterm(previous_qterm'length-1 downto QTERM_DECAY_BITS), previous_qterm'length); 

  qterm_result_o <= qterm_result;
  
  -----------------------------------------------------------------------------
  -- Difference finder
  -- This is a combinational subtractor that subtracts the previous coadd value
  -- from the current coadd value.  The previous coadd value is selected using
  -- a MUX by current_bank_i.  Note that when current_bank_i=0, inputs from
  -- bank 1 is selected and vice versa.
  -----------------------------------------------------------------------------

  diff_result <= current_coadd_dat_i - previous_coadd;

  previous_coadd <=
    (others => '0')       when initialize_window_max_dly = '1' else
    coadd_dat_frm_bank1_i when current_bank_i = '0' else
    coadd_dat_frm_bank0_i;

  
  -----------------------------------------------------------------------------
  -- Register Outputs for fsfb_calc
  -----------------------------------------------------------------------------

  i_output_for_fsfb: process (clk_i, rst_i)
  begin  -- process i_output_for_fsfb
    if rst_i = '1' then                 -- asynchronous reset (active high)
      current_coadd_dat_o    <= (others => '0');
      current_integral_dat_o <= (others => '0');
      current_qterm_dat_o    <= (others => '0');     
      current_diff_dat_o     <= (others => '0');
      
    elsif clk_i'event and clk_i = '1' then  -- rising clock edge

      if wren_for_fsfb_i = '1' then
        -- For PID loop calculation
        current_coadd_dat_o    <= current_coadd_dat_i;
        current_integral_dat_o <= integral_result;
        current_qterm_dat_o    <= qterm_result;
        current_diff_dat_o     <= diff_result;
      end if;
      
    end if;
  end process i_output_for_fsfb;
   
end rtl;


