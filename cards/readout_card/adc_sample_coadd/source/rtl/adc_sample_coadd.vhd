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
-- adc_sample_coadd.vhd
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
--
-- 1. This block samples the data from A/D at each clock.
-- 
-- 2. Acting on an incoming signal (raw_req_i) from the wishbone slave
-- (wbs_frame_data), it saves USED_RAW_DAT_WIDTH bits from the ADC sampled
-- data. The data is saved for two frames, starting from the next frame after
-- the raw_req_i.  The data is saved in a memory bank,(raw_dat_bank).  When
-- finished with raw data collection, it asserts the signal raw_ack_o.
-- Following the disassertion of raw_req_i, it disasserts raw_ack_o.
-- 
-- 3. Acting on adc_coadd_en_i, the block coaddes the sampled signals from ADC,
-- and saves them into a register. This addition is started after the nominal
-- latency within ADC.  At the end of the coaddition, the result is saved into
-- either of coadd_dat_bank0 or coadd_dat_bank1 and coadd_done_o is asserted.
-- One bank represents the current data and the other one represents the
-- previous value. current_bank_o indicates which bank is current, i.e, its
-- value (0 or 1) is the current bank index.
--
-- 4.When coading is done, current coadd value is added to previous integral
-- value of coadded values and is saved into either of intgrl_dat_bank0 or
-- intgrl_dat_bank1 as selected by current_bank_o.  The previous integral value
-- is retrieved from the respective ingrl_dat bank.  Also, the integral is
-- saved into a register for fsfb_calc to use it.  Moreover, a difference
-- value (current coadd - previous coadd) is also found and saved only
-- inot a register.  The previous coadd is retrieved from repective memory
-- bank. 
--
--
-- Ports:
-- #adc_dat_i: Input to adc_sample_coadd block from ADC
-- #adc_ovr_i: Input to adc_sample_coadd block from ADC (not used here)
-- #adc_rdy_i: Input to adc_sample_coadd block from ADC (not used here)
-- #adc_clk_o: Input to adc_sample_coadd block from ADC (not used here)
-- #clk_i: global clock
-- #rst_i: global reset active high
-- #adc_coadd_en_i: System input that indicates the window to do coadd.
-- #restart_frame_1row_prev_i: input signal to adc_sample_coadd block from
-- frame timing block.  It is high for one clock cycle and its falling edge
-- corresponds to to the beginning for row 40 cycle time in any frame.
-- #restart_frame_aligned_i: Input to flux_loop_ctrl block from frame_timing
-- block. This signal is high for one clock cycle and its falling edge
-- corresponds to the row0 cycle time in a new data frame.
-- #row_switch_i: Input to flux_loop_ctrl block from frame_timing block.  This
-- signal is high for one clock cycle at the end of each row dwell time and its
-- falling edge corresponds to the boundary of the row cycle.
-- #initialize_window_i: Input from frame timing block.  This input is high for
-- the entire duration of the first frame in any sequence of frames.
-- #coadded_addr_i: Address index from wbs frame data for reading coadd value.
-- #coadded_dat_o: Memory bank data output to wbs frame data.
-- #raw_addr_i: Address index from wbs frame data to read raw data.
-- #raw_req_i: Input from wbs_frame_data to ask for raw data.  It is high until
-- an acknowlege is issued by this (raw_dat_manager_ctrl) block.  This block
-- will start to acquire raw data from the first restart_frame_aligned_i pulse
-- after raw_req_i goes high.
-- #raw_ack_o: Output to wbs_frame_data block to indicate the end of raw data
-- acquisition.  It remains high until it sees the falling edge of raw_req_i.
-- #coadd_done_o: It is asserted after certain delay after each row_switch_i
-- if adc_coadd_en_i is present in that row.
-- #current_coadd_dat_o: Output to fsfb_calc block.  The data is valid from 5
-- clock cycles after the falling edge of adc_coadd_en to 5 clock cycles after
-- the falling edge of the next adc_coadd_en.
-- #current_diff_dat_o: Output to fsfb_calc block. The data is valid from 5
-- clock cycles after the falling edge of adc_coadd_en to 5 clock cycles after
-- the falling edge of the next adc_coadd_en.
-- #current_integral_dat_o: Output to fsfb_calc block. The data is valid from 5
-- clock cycles after the falling edge of adc_coadd_en to 5 clock cycles after
-- the falling edge of the next adc_coadd_en.
-- #adc_offset_dat_i: Input from wbs_fb_data.  Per row we need to get this
-- value. Only the least significant 14 bits used in correcting the value of
-- adc_dat_i.
-- #adc_offset_adr_o: Output to wbs_fb_data.  This is the address index to
-- retrieve the adc_offset_dat_i from the dedicated memory in wbs_fb_data. Note
-- that the address index for coadd_write_addr_o is used for this purpose as
-- the address indices are equal.
-- 
--
-- Revision history:
-- 
-- $Log: adc_sample_coadd.vhd,v $
-- Revision 1.12  2012-01-23 20:36:22  mandana
-- added qterm support
--
-- Revision 1.11  2011-10-27 21:08:05  mandana
-- coadd_done_o timing is now tied to ADC_LATENCY parameter
--
-- Revision 1.10  2010/03/12 20:34:23  bburger
-- BB: added i_clamp_val interface signals
--
-- Revision 1.9.2.1  2009/11/13 19:26:03  bburger
-- BB: Added i-term clamp interface signals
--
-- Revision 1.9  2009/05/27 01:21:45  bburger
-- BB: removed unused raw data interface signals and entities
--
-- Revision 1.8  2009/03/19 21:23:05  bburger
-- BB:
-- - Added the ADC_LATENCY generic to generalize this block for Readout Card Rev. C
-- - Removed unused signals adc_ovr_i, adc_rdy_i, adc_clk_o from interface
--
-- Revision 1.7  2008/06/20 17:14:05  mandana
-- merging from 1.6.2.3 raw_dat width
--
-- Revision 1.6.2.3  2008/06/19 23:48:14  mandana
-- increase raw_dat from 8 bit to 14 bit
--
-- Revision 1.6.2.2  2007/02/19 20:10:08  mandana
-- sign-extend raw-data
--
-- Revision 1.6.2.1  2006/04/10 19:49:03  mandana
-- RAM storage for raw mode is enabled.
--
-- Revision 1.6  2005/11/28 18:56:25  bburger
-- Bryce:  Raw data queue removed to make room from flux-jumping & signal tap
--
-- Revision 1.5  2004/12/20 19:43:01  mohsen
-- fixed sign bits usage
--
-- Revision 1.4  2004/12/13 21:03:01  mohsen
-- Reduced the word size of RAW data storage from 16 to 8.  This is as the result of
-- the memroy shortage in the Stratix EP1S30 with the current design of the readout card.
--
-- Revision 1.3  2004/11/26 18:25:54  mohsen
-- Anthony & Mohsen: Restructured constant declaration.  Moved shared constants from lower level package files to the upper level ones.  This was done to resolve compilation error resulting from shared constants defined in multiple package files.
--
-- Revision 1.2  2004/10/29 01:50:58  mohsen
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

library sys_param;
use sys_param.wishbone_pack.all;

library work;
use work.adc_sample_coadd_pack.all;

-- Call Parent Library
use work.flux_loop_ctrl_pack.all;
use work.flux_loop_pack.all;
use work.readout_card_pack.all;


entity adc_sample_coadd is
generic (ADC_LATENCY         : integer);
port (
   -- ADC interface signals
   adc_dat_i                 : in std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
    
   -- Global signals 
   clk_50_i                  : in  std_logic;
   rst_i                     : in  std_logic;

   i_clamp_val_i             : in std_logic_vector(COADD_DAT_WIDTH-1 downto 0);
   qterm_decay_bits_i        : in std_logic_vector(COADD_DAT_WIDTH-1 downto 0);

   -- Frame timing signals
   adc_coadd_en_i            : in  std_logic;
   restart_frame_1row_prev_i : in  std_logic;
   restart_frame_aligned_i   : in  std_logic;
   row_switch_i              : in  std_logic;
   initialize_window_i       : in  std_logic;
   servo_rst_window_i        : in std_logic;

   -- Wishbone Slave (wbs) Frame Data signals
   coadded_addr_i            : in  std_logic_vector (COADD_ADDR_WIDTH-1 downto 0);
   coadded_dat_o             : out std_logic_vector (COADD_DAT_WIDTH-1 downto 0);

   -- First Stage Feedback Calculation (fsfb_calc) block signals
   coadd_done_o              : out std_logic;
   current_coadd_dat_o       : out std_logic_vector (COADD_DAT_WIDTH-1 downto 0);
   current_diff_dat_o        : out std_logic_vector (COADD_DAT_WIDTH-1 downto 0);
   current_integral_dat_o    : out std_logic_vector (COADD_DAT_WIDTH-1 downto 0);
   current_qterm_dat_o       : out std_logic_vector (COADD_DAT_WIDTH-1 downto 0);

   -- Wishbove Slave (wbs) Feedback (fb) Data Signals
   adc_offset_dat_i          : in  std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
   adc_offset_adr_o          : out std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
   servo_rst_dat_i           : in std_logic;
   servo_rst_addr_o          : out std_logic_vector(SERVO_RST_ADDR_WIDTH-1 downto 0)
);
end adc_sample_coadd;

architecture struct of adc_sample_coadd is
  
   constant GROUNDED_ADDR        : std_logic_vector(COADD_ADDR_WIDTH-1 downto 0) := (others => '0');
   
   -- signals from coadd storage bank 0 and 1
   signal coadd_dat_porta_bank0  : std_logic_vector(COADD_DAT_WIDTH-1 downto 0);
   signal coadd_dat_portb_bank0  : std_logic_vector(COADD_DAT_WIDTH-1 downto 0);
   signal coadd_dat_porta_bank1  : std_logic_vector(COADD_DAT_WIDTH-1 downto 0);
   signal coadd_dat_portb_bank1  : std_logic_vector(COADD_DAT_WIDTH-1 downto 0);

   -- signlas from dynamic data storage bank 0 and 1
   signal intgrl_dat_portb_bank0 : std_logic_vector(COADD_DAT_WIDTH-1 downto 0);
   signal intgrl_dat_portb_bank1 : std_logic_vector(COADD_DAT_WIDTH-1 downto 0);

   -- signlas from dynamic data storage bank 0 and 1
   signal qterm_dat_portb_bank0 : std_logic_vector(COADD_DAT_WIDTH-1 downto 0);
   signal qterm_dat_portb_bank1 : std_logic_vector(COADD_DAT_WIDTH-1 downto 0);

   -- signals from coadd_manager_data_path
   signal adc_coadd_en_5delay    : std_logic;
   signal adc_coadd_en_4delay    : std_logic;
   signal samples_coadd_reg      : std_logic_vector(COADD_DAT_WIDTH-1 downto 0);
   signal coadd_write_addr       : std_logic_vector(COADD_ADDR_WIDTH-1 downto 0);

   -- signals from coadd_dynamic_manager_ctrl
   signal clr_samples_coadd_reg  : std_logic;
   signal address_count_en       : std_logic;
   signal clr_address_count      : std_logic;
   signal wren_bank0             : std_logic;
   signal wren_bank1             : std_logic;
   signal wren_for_fsfb          : std_logic;
   signal current_bank           : std_logic;

   -- signals from dynamic_dat_manager_data_path
   signal integral_result        : std_logic_vector(COADD_DAT_WIDTH-1 downto 0);
   signal qterm_result           : std_logic_vector(COADD_DAT_WIDTH-1 downto 0);
   
begin  -- struc
     
   -- The following statement is used to select part of the accuracy of the ADC.
   -- Based on the value of RAW_DATA_POSITION_POINTER, we select part of the
   -- ADC 14-bit output
--  raw_dat   <= adc_dat_i; --(ADC_DAT_WIDTH-1) & adc_dat_i(RAW_DATA_POSITION_POINTER-2 downto RAW_DATA_POSITION_POINTER-USED_RAW_DAT_WIDTH);
  
--  raw_dat_o <= sxt(raw_dat_out, raw_dat_o'length);  -- sign extend to match the width expected by wbs_frame_data

   
   -----------------------------------------------------------------------------
   -- Instantiate MUX for coadded data output to wishbone frame data slave
   -- Note: wbs_frame_data block reads the previous set of values.  Hence, when
   -- current_bank is 0, vlaue from bank1 is read and vice versa.
   -----------------------------------------------------------------------------
  
  coadded_dat_o <=
    coadd_dat_porta_bank1 when current_bank='0' else
    coadd_dat_porta_bank0;


   -----------------------------------------------------------------------------
   -- Instantiation of Coadd Data Bank 0
   -----------------------------------------------------------------------------
   i_coadd_dat_bank0 : coadd_storage
   port map (
      data        => samples_coadd_reg,  -- from coadd data path
      wraddress   => coadd_write_addr,   -- from coadd data path
      rdaddress_a => coadded_addr_i,     -- system input
      rdaddress_b => coadd_write_addr,   -- from coadd data path
      wren        => wren_bank0,         -- from coadd/dynamic controller
      clock       => clk_50_i,           -- system input
      qa          => coadd_dat_porta_bank0,
      qb          => coadd_dat_portb_bank0
   );


   -----------------------------------------------------------------------------
   -- Instantiation of Coadd Data Bank 1
   -----------------------------------------------------------------------------
   i_coadd_dat_bank1 : coadd_storage
   port map (
      data        => samples_coadd_reg,   -- from coadd data path
      wraddress   => coadd_write_addr,    -- from coadd data path
      rdaddress_a => coadded_addr_i,      -- system input
      rdaddress_b => coadd_write_addr,    -- from coadd data path
      wren        => wren_bank1,          -- from coadd/dynamic controller
      clock       => clk_50_i,            -- system input
      qa          => coadd_dat_porta_bank1,
      qb          => coadd_dat_portb_bank1
   );


   -----------------------------------------------------------------------------
   -- Instantiation of Integral Data Bank 0
   -----------------------------------------------------------------------------
   i_intgrl_dat_bank0 : coadd_storage
   port map (
      data        => integral_result,     -- from dynamic data path
      wraddress   => coadd_write_addr,    -- from coadd data path
      rdaddress_a => GROUNDED_ADDR,       -- grounded(not used)
      rdaddress_b => coadd_write_addr,    -- from coadd data path
      wren        => wren_bank0,          -- from coadd/dynamic controller
      clock       => clk_50_i,            -- system input
      qa          => open,
      qb          => intgrl_dat_portb_bank0
   );


   -----------------------------------------------------------------------------
   -- Instantiation of Integral Data Bank 1
   -----------------------------------------------------------------------------
   i_intgrl_dat_bank1 : coadd_storage
   port map (
      data        => integral_result,     -- from dynamic data path
      wraddress   => coadd_write_addr,    -- from coadd data path
      rdaddress_a => GROUNDED_ADDR,       -- grounded (not used)
      rdaddress_b => coadd_write_addr,    -- from coadd data path
      wren        => wren_bank1,          -- from coadd/dynamic controller
      clock       => clk_50_i,            -- system input
      qa          => open,
      qb          => intgrl_dat_portb_bank1
   );
   
   -----------------------------------------------------------------------------
   -- Instantiation of Q-term Data Bank 0
   -----------------------------------------------------------------------------
   i_qterm_dat_bank0 : coadd_storage
   port map (
      data        => qterm_result,        -- from dynamic data path
      wraddress   => coadd_write_addr,    -- from coadd data path
      rdaddress_a => GROUNDED_ADDR,       -- grounded(not used)
      rdaddress_b => coadd_write_addr,    -- from coadd data path
      wren        => wren_bank0,          -- from coadd/dynamic controller
      clock       => clk_50_i,            -- system input
      qa          => open,
      qb          => qterm_dat_portb_bank0
   );

   -----------------------------------------------------------------------------
   -- Instantiation of Q-term Data Bank 1
   -----------------------------------------------------------------------------
   i_qterm_dat_bank1 : coadd_storage
   port map (
      data        => qterm_result,        -- from dynamic data path
      wraddress   => coadd_write_addr,    -- from coadd data path
      rdaddress_a => GROUNDED_ADDR,       -- grounded (not used)
      rdaddress_b => coadd_write_addr,    -- from coadd data path
      wren        => wren_bank1,          -- from coadd/dynamic controller
      clock       => clk_50_i,            -- system input
      qa          => open,
      qb          => qterm_dat_portb_bank1
   );
   
   -----------------------------------------------------------------------------
   -- Instantiation of Coadd Manager Data Path
   -----------------------------------------------------------------------------
   i_coadd_manager_data_path : coadd_manager_data_path
   generic map (
      MAX_COUNT => TOTAL_ROW_NO,
      MAX_SHIFT => ADC_LATENCY+1)
   port map (
      rst_i                   => rst_i,                  -- system input
      clk_i                   => clk_50_i,               -- system input
      adc_dat_i               => adc_dat_i,              -- system input
      adc_offset_dat_i        => adc_offset_dat_i,       -- system input
      adc_offset_adr_o        => adc_offset_adr_o,  
      adc_coadd_en_i          => adc_coadd_en_i,         -- system input
      adc_coadd_en_5delay_o   => adc_coadd_en_5delay,  
      adc_coadd_en_4delay_o   => adc_coadd_en_4delay,
      clr_samples_coadd_reg_i => clr_samples_coadd_reg,  -- from coadd control
      samples_coadd_reg_o     => samples_coadd_reg,
      address_count_en_i      => address_count_en,       -- from coadd control
      clr_address_count_i     => clr_address_count,      -- from coadd control
      coadd_write_addr_o      => coadd_write_addr,
      servo_rst_addr_o        => servo_rst_addr_o
   );


   -----------------------------------------------------------------------------
   -- Instantiation of Coadd & dynamic Manager Controller
   -----------------------------------------------------------------------------
   i_coadd_dynamic_manager_ctrl : coadd_dynamic_manager_ctrl
   generic map (
      COADD_DONE_MAX_COUNT => ADC_LATENCY+3, --formerly FSFB_DONE_DLY+1 or 7
      MAX_SHIFT            => ADC_LATENCY+1)
   port map (
      rst_i                     => rst_i,                      -- system input
      clk_i                     => clk_50_i,                   -- system input
      restart_frame_1row_prev_i => restart_frame_1row_prev_i,  -- system input
      restart_frame_aligned_i   => restart_frame_aligned_i,    -- system input
      row_switch_i              => row_switch_i,         -- system input
      adc_coadd_en_i            => adc_coadd_en_i,       -- system input
      adc_coadd_en_5delay_i     => adc_coadd_en_5delay,  -- frm coadd data path
      adc_coadd_en_4delay_i     => adc_coadd_en_4delay,  -- frm coadd data path
      clr_samples_coadd_reg_o   => clr_samples_coadd_reg, 
      address_count_en_o        => address_count_en, 
      clr_address_count_o       => clr_address_count,
      wren_bank0_o              => wren_bank0,
      wren_bank1_o              => wren_bank1,
      wren_for_fsfb_o           => wren_for_fsfb,
      coadd_done_o              => coadd_done_o,
      current_bank_o            => current_bank
   );


   -----------------------------------------------------------------------------
   -- Instantiation of Dynamic Manager Data Path
   -----------------------------------------------------------------------------
   i_dynamic_manager_data_path : dynamic_manager_data_path
   generic map (
      MAX_SHIFT => ADC_LATENCY+1)
   port map (
      rst_i                  => rst_i,                  -- system input
      clk_i                  => clk_50_i,               -- system input
      i_clamp_val_i          => i_clamp_val_i,
      qterm_decay_bits_i     => qterm_decay_bits_i,
      initialize_window_i    => initialize_window_i,    -- system input
      servo_rst_window_i     => servo_rst_window_i,     -- system input
      servo_rst_dat_i        => servo_rst_dat_i,        -- from wishbone fb slave
      current_coadd_dat_i    => samples_coadd_reg,      -- frm coadd data path
      current_bank_i         => current_bank,           -- frm coadd controller
      wren_for_fsfb_i        => wren_for_fsfb,          -- frm coadd controller
      coadd_dat_frm_bank0_i  => coadd_dat_portb_bank0,   -- coadd memory bank0
      coadd_dat_frm_bank1_i  => coadd_dat_portb_bank1,   -- coadd memory bank1
      intgrl_dat_frm_bank0_i => intgrl_dat_portb_bank0,  -- intgrl memory bank0
      intgrl_dat_frm_bank1_i => intgrl_dat_portb_bank1,  -- intgrl memory bank1
      qterm_dat_frm_bank0_i  => qterm_dat_portb_bank0,   -- qterm memory bank0
      qterm_dat_frm_bank1_i  => qterm_dat_portb_bank1,   -- qterm memory bank1      
      current_coadd_dat_o    => current_coadd_dat_o,  
      current_diff_dat_o     => current_diff_dat_o,
      current_integral_dat_o => current_integral_dat_o,
      current_qterm_dat_o    => current_qterm_dat_o,
      integral_result_o      => integral_result,
      qterm_result_o         => qterm_result
   );

end struct;
