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
-- Project:	  SCUBA-2
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
-- (wbs_frame_data), it saves all the sampled data for two frames, starting
-- from the next frame after the raw_req_i.  The data is saved in a memory
-- bank,(raw_dat_bank).  When finished with raw data collection, it asserts the
-- signal raw_ack_o.  Following the disassertion of raw_req_i, it disasserts
-- raw_ack_o.
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



entity adc_sample_coadd is

  port (
    -- ADC interface signals
    adc_dat_i                 : in std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
    adc_ovr_i                 : in std_logic;
    adc_rdy_i                 : in std_logic;
    adc_clk_o                 : out std_logic;

    -- Global signals 
    clk_50_i                  : in  std_logic;
    rst_i                     : in  std_logic;

    -- Frame timing signals
    adc_coadd_en_i            : in  std_logic;
    restart_frame_1row_prev_i : in  std_logic;
    restart_frame_aligned_i   : in  std_logic;
    row_switch_i              : in  std_logic;
    initialize_window_i       : in  std_logic;

    -- Wishbone Slave (wbs) Frame Data signals
    coadded_addr_i            : in  std_logic_vector (COADD_ADDR_WIDTH-1 downto 0);
    coadded_dat_o             : out std_logic_vector (COADD_DAT_WIDTH-1 downto 0);
    raw_addr_i                : in  std_logic_vector (RAW_ADDR_WIDTH-1 downto 0);
    raw_dat_o                 : out std_logic_vector (RAW_DAT_WIDTH-1 downto 0);
    raw_req_i                 : in  std_logic;
    raw_ack_o                 : out std_logic;

    -- First Stage Feedback Calculation (fsfb_calc) block signals
    coadd_done_o              : out std_logic;
    current_coadd_dat_o       : out std_logic_vector (COADD_DAT_WIDTH-1 downto 0);
    current_diff_dat_o        : out std_logic_vector (COADD_DAT_WIDTH-1 downto 0);
    current_integral_dat_o    : out std_logic_vector (COADD_DAT_WIDTH-1 downto 0);

    -- Wishbove Slave (wbs) Feedback (fb) Data Signals
    adc_offset_dat_i          : in  std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
    adc_offset_adr_o          : out std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0));
  

end adc_sample_coadd;



architecture struct of adc_sample_coadd is


  
  constant GROUNDED_ADDR : std_logic_vector(COADD_ADDR_WIDTH-1 downto 0) := (others => '0');
  constant ZERO_PAD      : std_logic_vector((RAW_DAT_WIDTH - ADC_DAT_WIDTH -1) downto 0) := (others => '0');

  
  
  -----------------------------------------------------------------------------
  -- Signals name change from outside the block
  -----------------------------------------------------------------------------
  signal raw_dat               : std_logic_vector (RAW_DAT_WIDTH-1 downto 0);

  -----------------------------------------------------------------------------
  -- Signals name change to ouside of the block
  -----------------------------------------------------------------------------
  
  -----------------------------------------------------------------------------
  -- signals from raw_dat_bank
  -----------------------------------------------------------------------------

  
  -----------------------------------------------------------------------------
  -- signals from raw_dat_manager_data_path 
  -----------------------------------------------------------------------------
  signal raw_write_addr        : std_logic_vector (RAW_ADDR_WIDTH-1 downto 0);

  -----------------------------------------------------------------------------
  -- signals from raw_dat_manager_ctrl
  -----------------------------------------------------------------------------
  signal clr_raw_addr_index    : std_logic;
  signal raw_wren              : std_logic;
  
  -----------------------------------------------------------------------------
  -- signals from coadd storage bank 0 and 1
  -----------------------------------------------------------------------------
  signal coadd_dat_porta_bank0  : std_logic_vector(COADD_DAT_WIDTH-1 downto 0);
  signal coadd_dat_portb_bank0  : std_logic_vector(COADD_DAT_WIDTH-1 downto 0);
  signal coadd_dat_porta_bank1  : std_logic_vector(COADD_DAT_WIDTH-1 downto 0);
  signal coadd_dat_portb_bank1  : std_logic_vector(COADD_DAT_WIDTH-1 downto 0);

  -----------------------------------------------------------------------------
  -- signlas from dynamic data storage bank 0 and 1
  -----------------------------------------------------------------------------
  signal intgrl_dat_portb_bank0 : std_logic_vector(COADD_DAT_WIDTH-1 downto 0);
  signal intgrl_dat_portb_bank1 : std_logic_vector(COADD_DAT_WIDTH-1 downto 0);

  
  -----------------------------------------------------------------------------
  -- signals from coadd_manager_data_path
  -----------------------------------------------------------------------------
  signal adc_coadd_en_5delay    : std_logic;
  signal adc_coadd_en_4delay    : std_logic;
  signal samples_coadd_reg      : std_logic_vector(COADD_DAT_WIDTH-1 downto 0);
  signal coadd_write_addr       : std_logic_vector(COADD_ADDR_WIDTH-1 downto 0);


  -----------------------------------------------------------------------------
  -- signals from coadd_dynamic_manager_ctrl
  -----------------------------------------------------------------------------
  signal clr_samples_coadd_reg  : std_logic;
  signal address_count_en       : std_logic;
  signal clr_address_count      : std_logic;
  signal wren_bank0             : std_logic;
  signal wren_bank1             : std_logic;
  signal wren_for_fsfb          : std_logic;
  signal current_bank           : std_logic;

  
  -----------------------------------------------------------------------------
  -- signals from dynamic_dat_manager_data_path
  -----------------------------------------------------------------------------
  signal integral_result : std_logic_vector(COADD_DAT_WIDTH-1 downto 0);

  

  
begin  -- struc

  
  adc_clk_o <= clk_50_i;                -- get data on each clk edge (4 cycles)
                                        -- latency according to ADC data sheet
  raw_dat   <= (ZERO_PAD & adc_dat_i);  -- pad adc_dat_i with zero to match the
                                        -- data width of the raw_dat_bank

  
  -----------------------------------------------------------------------------
  -- Instantiate MUX for coadded data output to wishbone frame data slave
  -- Note: wbs_frame_data block reads the previous set of values.  Hence, when
  -- current_bank is 0, vlaue from bank1 is read and vice versa.
  -----------------------------------------------------------------------------
  
  coadded_dat_o <=
    coadd_dat_porta_bank1 when current_bank='0' else
    coadd_dat_porta_bank0;

  
  -----------------------------------------------------------------------------
  -- Instantiation of the Raw data bank
  -----------------------------------------------------------------------------

  i_raw_dat_bank: raw_dat_bank

    port map (
    data      => raw_dat,               -- system input modified
    wren      => raw_wren,              -- from raw controller
    wraddress => raw_write_addr,        -- from raw data path
    rdaddress => raw_addr_i,            -- system input
    clock     => clk_50_i,              -- system input
    q         => raw_dat_o);


  -----------------------------------------------------------------------------
  -- Instantiation of Raw Data Manager Data Path
  -----------------------------------------------------------------------------

  i_raw_dat_manager_data_path : raw_dat_manager_data_path

    generic map (
    ADDR_WIDTH => RAW_ADDR_WIDTH)

    port map (
    rst_i        => rst_i,               -- system input
    clk_i        => clk_50_i,            -- system input
    clr_index_i  => clr_raw_addr_index,  -- from raw controller
    addr_index_o => raw_write_addr);    


  -----------------------------------------------------------------------------
  -- Instantiation of Raw Data Manager Controller
  -----------------------------------------------------------------------------

  i_raw_dat_manager_ctrl : raw_dat_manager_ctrl

    port map (
    rst_i                   => rst_i,                    -- system input
    clk_i                   => clk_50_i,                 -- system input
    restart_frame_aligned_i => restart_frame_aligned_i,  -- system input
    raw_req_i               => raw_req_i,                -- system input
    clr_raw_addr_index_o    => clr_raw_addr_index,  
    raw_wren_o              => raw_wren,
    raw_ack_o               => raw_ack_o);


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
      qb          => coadd_dat_portb_bank0);


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
    qb          => coadd_dat_portb_bank1);


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
    qb          => intgrl_dat_portb_bank0);


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
    qb          => intgrl_dat_portb_bank1);
  
  
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
      coadd_write_addr_o      => coadd_write_addr);




  -----------------------------------------------------------------------------
  -- Instantiation of Coadd & dynamic Manager Controller
  -----------------------------------------------------------------------------

  i_coadd_dynamic_manager_ctrl : coadd_dynamic_manager_ctrl

    generic map (
      COADD_DONE_MAX_COUNT => FSFB_DONE_DLY+1,
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
      current_bank_o            => current_bank);


  -----------------------------------------------------------------------------
  -- Instantiation of Dynamic Manager Data Path
  -----------------------------------------------------------------------------

  i_dynamic_manager_data_path : dynamic_manager_data_path

    generic map (
    MAX_SHIFT => ADC_LATENCY+1)
    
    port map (
      rst_i                  => rst_i,                  -- system input
      clk_i                  => clk_50_i,               -- system input
      initialize_window_i    => initialize_window_i,    -- system input
      current_coadd_dat_i    => samples_coadd_reg,      -- frm coadd data path
      current_bank_i         => current_bank,           -- frm coadd controller
      wren_for_fsfb_i        => wren_for_fsfb,          -- frm coadd controller
      coadd_dat_frm_bank0_i  => coadd_dat_portb_bank0,   -- coadd memory bank0
      coadd_dat_frm_bank1_i  => coadd_dat_portb_bank1,   -- coadd memory bank1
      intgrl_dat_frm_bank0_i => intgrl_dat_portb_bank0,  -- intgrl memory bank0
      intgrl_dat_frm_bank1_i => intgrl_dat_portb_bank1,  -- intgrl memory bank1
      current_coadd_dat_o    => current_coadd_dat_o,  
      current_diff_dat_o     => current_diff_dat_o,
      current_integral_dat_o => current_integral_dat_o,
      integral_result_o      => integral_result);


  
  -----------------------------------------------------------------------------
  -- 
  -----------------------------------------------------------------------------



end struct;
