-- Copyright (c) 2003 SCUBA-2 Project
--               All Rights Reserved
--
-- THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE SCUBA-2 Project
-- The copyright notice above does not evidence any
-- actual or intended publication of such source code.
--
-- SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
-- REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
-- MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
-- PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
-- THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.
--
-- For the purposes of this code the SCUBA-2 Project consists of the
-- following organisations.
--
-- UKATC, Royal Observatory, Blackford Hill Edinburgh EH9 3HJ
-- UBC,   University of British Columbia, Physics & Astronomy Department,
--        Vancouver BC, V6T 1Z1
--
-- Project:       SCUBA2
-- Author:        Bryce Burger
-- Organisation:  UBC
--
-- $Id: flux_loop.vhd,v 1.4 2004/08/31 00:00:04 bburger Exp $
-- Description:
-- Readout Card flux loop
--
-- Revision history:
-- $Log: flux_loop.vhd,v $
-- Revision 1.4  2004/08/31 00:00:04  bburger
-- Bryce:  removed compilation errors
--
-- Revision 1.3  2004/08/27 01:04:33  bburger
-- Bryce:  in progress
--
-- Revision 1.2  2004/08/26 21:46:00  bburger
-- Bryce:  in progress
--
-- Revision 1.1  2004/08/25 23:07:10  bburger
-- Bryce:  new
--
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library sys_param;
use sys_param.wishbone_pack.all;
--use sys_param.frame_timing_pack.all;
use sys_param.command_pack.all;
use sys_param.data_types_pack.all;

library components;
--use components.component_pack.all;

library work;
use work.coadded_data_queue_pack.all;
use work.first_stage_fb_queue_pack.all;
use work.raw_data_queue_pack.all;
use work.pidz_coeff_queue_pack.all;

entity flux_loop is
   port(
      ----------------------------------------------------------------
      -- ADC Interface
      ----------------------------------------------------------------      
      -- adc_enc_o tells the ADC when to sample data.
      -- This is a differential signal, and needs to be routed to the ADC with an inverted duplicate
      adc_enc_o     : out std_logic;    
      
      -- adc_ovr_o is the over-range bit.
      -- It signifies whether the ADC has been saturdated or not.
      -- It will be added as bit 15 to the acd_dat_i.
      adc_ovr_i     : in std_logic;
      
      -- adc_rdy_o is an inverted, delayed and single-ended version of adc_enc_o.
      -- It indicates when the adc conversion is valid.
      adc_rdy_i     : in std_logic;
      
      -- adc_dat_i is the data output for the ADC
      -- At 50 MHz, the latency of the data-output is on the order of several clock cycles.
      adc_dat_i     : in w14_array11;
      
      ----------------------------------------------------------------
      -- DAC interface
      ----------------------------------------------------------------      
      dac_data_o    : out w14_array11;
      dac_clk_o     : out std_logic;
      
      ----------------------------------------------------------------
      -- Wishbone interface a:  data readout
      ----------------------------------------------------------------
      wba_clk_i     : in std_logic;
      wba_rst_i     : in std_logic;      
      wba_dat_i     : in std_logic_vector (WB_DATA_WIDTH-1 downto 0);
      wba_addr_i    : in std_logic_vector (WB_ADDR_WIDTH-1 downto 0);
      wba_tga_i     : in std_logic_vector (WB_TAG_ADDR_WIDTH-1 downto 0);
      wba_we_i      : in std_logic;
      wba_stb_i     : in std_logic;
      wba_cyc_i     : in std_logic;
      wba_dat_o     : out std_logic_vector (WB_DATA_WIDTH-1 downto 0);
      wba_rty_o     : out std_logic;
      wba_ack_o     : out std_logic;
      
      ----------------------------------------------------------------
      -- Wishbone interface b:  parameter control
      ----------------------------------------------------------------
      wbb_clk_i     : in std_logic;
      wbb_rst_i     : in std_logic;      
      wbb_dat_i     : in std_logic_vector (WB_DATA_WIDTH-1 downto 0);
      wbb_addr_i    : in std_logic_vector (WB_ADDR_WIDTH-1 downto 0);
      wbb_tga_i     : in std_logic_vector (WB_TAG_ADDR_WIDTH-1 downto 0);
      wbb_we_i      : in std_logic;
      wbb_stb_i     : in std_logic;
      wbb_cyc_i     : in std_logic;
      wbb_dat_o     : out std_logic_vector (WB_DATA_WIDTH-1 downto 0);
      wbb_rty_o     : out std_logic;
      wbb_ack_o     : out std_logic;

      ----------------------------------------------------------------
      -- Clocks/resets
      ----------------------------------------------------------------
      clk_i         : in std_logic; -- Advances the state machines
      clk_200mhz_i  : in std_logic; -- Clocks the RAMs
      rst_i         : in std_logic;  -- Resets all FSMs    

      ----------------------------------------------------------------
      -- Timing signals received from the frame_timing block
      ----------------------------------------------------------------
      sync_i        : in std_logic; -- The sync pulse determines when and when not to issue u-ops
      sync_num_i    : in std_logic_vector(SYNC_NUM_BUS_WIDTH-1 downto 0)
   );
end flux_loop;

architecture behav of flux_loop is

   -- Coadded data queue inputs/ouputs
   subtype coadded_queue_addr is std_logic_vector(CD_Q_ADDR_WIDTH-1 downto 0);
   type coadded_queue_addr_array is array (0 to 1) of coadded_queue_addr;
   subtype coadded_queue_wren is std_logic;
   type coadded_queue_wren_array is array (0 to 1) of coadded_queue_wren;
   subtype coadded_queue_data is std_logic_vector(CD_Q_WIDTH-1 downto 0);
   type coadded_queue_data_array is array (0 to 1) of coadded_queue_data;
   signal coadded_data        : coadded_queue_data_array;
   signal coadded_wren        : coadded_queue_wren_array;
   signal coadded_wadd        : coadded_queue_addr_array;
   signal coadded_radd_a0     : coadded_queue_addr_array;
   signal coadded_radd_b0     : coadded_queue_addr_array;
   signal coadded_qa0         : coadded_queue_data_array;
   signal coadded_qb0         : coadded_queue_data_array;
   signal coadded_radd_a1     : coadded_queue_addr_array;
   signal coadded_radd_b1     : coadded_queue_addr_array;
   signal coadded_qa1         : coadded_queue_data_array;
   signal coadded_qb1         : coadded_queue_data_array;
   
   -- Coadded data queue management signals
   signal coadded_sample_ptr  : std_logic_vector(CD_Q_ADDR_WIDTH-1 downto 0);
   signal coadded_wishbone_ptr: std_logic_vector(CD_Q_ADDR_WIDTH-1 downto 0);
   signal coadded_fsfb_ptr    : std_logic_vector(CD_Q_ADDR_WIDTH-1 downto 0);
   signal even_odd            : std_logic;
   signal sample_delay        : std_logic_vector(31 downto 0);

   -- First-stage feedback queue inputs/ouputs
   subtype fsfb_queue_addr is std_logic_vector(FSFB_Q_ADDR_WIDTH-1 downto 0);
   type fsfb_queue_addr_array is array (0 to 1) of fsfb_queue_addr;
   subtype fsfb_queue_wren is std_logic;
   type fsfb_queue_wren_array is array (0 to 1) of fsfb_queue_wren;
   subtype fsfb_queue_data is std_logic_vector(FSFB_Q_WIDTH-1 downto 0);
   type fsfb_queue_data_array is array (0 to 1) of fsfb_queue_data;
   signal fsfb_data           : fsfb_queue_data_array;
   signal fsfb_wren           : fsfb_queue_wren_array;
   signal fsfb_wadd           : fsfb_queue_addr_array;
   signal fsfb_radd_a0        : fsfb_queue_addr_array;
   signal fsfb_radd_b0        : fsfb_queue_addr_array;
   signal fsfb_qa0            : fsfb_queue_data_array;
   signal fsfb_qb0            : fsfb_queue_data_array;
   signal fsfb_radd_a1        : fsfb_queue_addr_array;
   signal fsfb_radd_b1        : fsfb_queue_addr_array;
   signal fsfb_qa1            : fsfb_queue_data_array;
   signal fsfb_qb1            : fsfb_queue_data_array;
   
   -- First-stage feedback queue management signals
   signal fsfb_calc_ptr       : std_logic_vector(FSFB_Q_ADDR_WIDTH-1 downto 0);
   signal fsfb_wishbone_ptr   : std_logic_vector(FSFB_Q_ADDR_WIDTH-1 downto 0);
   signal fsfb_ctrl_ptr       : std_logic_vector(FSFB_Q_ADDR_WIDTH-1 downto 0);
   signal fsfb_filter_ptr     : std_logic_vector(FSFB_Q_ADDR_WIDTH-1 downto 0);
   
   -- Raw data queue inputs/outputs
   subtype raw_queue_addr is std_logic_vector(RD_Q_ADDR_WIDTH-1 downto 0);
   subtype raw_queue_wren is std_logic;
   subtype raw_queue_data is std_logic_vector(RD_Q_WIDTH-1 downto 0);
   signal raw_data            : raw_queue_data;
   signal raw_wren            : raw_queue_wren;
   signal raw_wadd            : raw_queue_addr;
   signal raw_radd_a          : raw_queue_addr;
   signal raw_radd_b          : raw_queue_addr;
   signal raw_qa              : raw_queue_data;
   signal raw_qb              : raw_queue_data;

   -- P, I, D and Z coefficient queue inputs/outputs
   subtype pidz_queue_addr is std_logic_vector(PIDZ_Q_ADDR_WIDTH-1 downto 0);
   subtype pidz_queue_wren is std_logic;
   subtype pidz_queue_data is std_logic_vector(PIDZ_Q_WIDTH-1 downto 0);
   signal pidz_data            : pidz_queue_data;
   signal pidz_wren            : pidz_queue_wren;
   signal pidz_wadd            : pidz_queue_addr;
   signal pidz_radd_a          : pidz_queue_addr;
   signal pidz_radd_b          : pidz_queue_addr;
   signal pidz_qa              : pidz_queue_data;
   signal pidz_qb              : pidz_queue_data;

   -- adc_sample FSM
   type adc_sample_states is (IDLE, DELAY, COADD);
   signal present_adc_sample_state : adc_sample_states;
   signal next_adc_sample_state    : adc_sample_states;
   signal coadded_val         : std_logic_vector(31 downto 0);
   
   -- first_stage_fb_calc FSM
   type first_stage_fb_calc_states is (IDLE);
   signal present_first_stage_fb_calc_state : first_stage_fb_calc_states;
   signal next_first_stage_fb_calc_state    : first_stage_fb_calc_states;
   
   -- first_stage_fb_ctrl FSM
   type first_stage_fb_ctrl_states is (IDLE);
   signal present_first_stage_fb_ctrl_state : first_stage_fb_ctrl_states;
   signal next_first_stage_fb_ctrl_state    : first_stage_fb_ctrl_states;

   -- Constants that can be removed when the sync_counter and frame_timer are moved out of this block
   constant HIGH              : std_logic := '1';
   constant LOW               : std_logic := '0';
   
   -- Timing signals
   signal coadd_ctrl : std_logic;
   

begin

------------------------------------------------------------------------
-- Instantiations
------------------------------------------------------------------------ 

   -- Coadded data queue 0
   coadded_data_queue_0a: coadded_data_queue
      port map(
         data        => coadded_data(0),
         wraddress   => coadded_wadd(0),
         rdaddress_a => coadded_radd_a0(0),
         rdaddress_b => coadded_radd_b0(0),
         wren        => coadded_wren(0),
         clock       => clk_200mhz_i,  
         qa          => coadded_qa0(0),         
         qb          => coadded_qb0(0) 
      );

   -- Replica of coadded data queue 0, for additional read ports
   coadded_data_queue_0b: coadded_data_queue
      port map(
         data        => coadded_data(0),
         wraddress   => coadded_wadd(0),
         rdaddress_a => coadded_radd_a1(0),
         rdaddress_b => coadded_radd_b1(0),
         wren        => coadded_wren(0),
         clock       => clk_200mhz_i,  
         qa          => coadded_qa1(0),         
         qb          => coadded_qb1(0) 
      );

   -- Coadded data queue 1
   coadded_data_queue_1a: coadded_data_queue
      port map(
         data        => coadded_data(1),
         wraddress   => coadded_wadd(1),
         rdaddress_a => coadded_radd_a0(1),
         rdaddress_b => coadded_radd_b0(1),
         wren        => coadded_wren(1),
         clock       => clk_200mhz_i,  
         qa          => coadded_qa0(1),         
         qb          => coadded_qb0(1) 
      );

   -- Replica
   coadded_data_queue_1b: coadded_data_queue
      port map(
         data        => coadded_data(1),
         wraddress   => coadded_wadd(1),
         rdaddress_a => coadded_radd_a1(1),
         rdaddress_b => coadded_radd_b1(1),
         wren        => coadded_wren(1),
         clock       => clk_200mhz_i,  
         qa          => coadded_qa1(1),         
         qb          => coadded_qb1(1) 
      );
      
   -- First stage feedback queue 0
   first_stage_fb_queue_0a: first_stage_fb_queue
      port map(
         data        => fsfb_data(0),
         wraddress   => fsfb_wadd(0),
         rdaddress_a => fsfb_radd_a0(0),
         rdaddress_b => fsfb_radd_b0(0),
         wren        => fsfb_wren(0),
         clock       => clk_200mhz_i,  
         qa          => fsfb_qa0(0),         
         qb          => fsfb_qb0(0) 
      );

   -- Replica
   first_stage_fb_queue_0b: first_stage_fb_queue
      port map(
         data        => fsfb_data(0),
         wraddress   => fsfb_wadd(0),
         rdaddress_a => fsfb_radd_a1(0),
         rdaddress_b => fsfb_radd_b1(0),
         wren        => fsfb_wren(0),
         clock       => clk_200mhz_i,  
         qa          => fsfb_qa1(0),         
         qb          => fsfb_qb1(0) 
      );

   -- First stage feedback queue 1
   first_stage_fb_queue_1a: first_stage_fb_queue
      port map(
         data        => fsfb_data(1),
         wraddress   => fsfb_wadd(1),
         rdaddress_a => fsfb_radd_a0(1),
         rdaddress_b => fsfb_radd_b0(1),
         wren        => fsfb_wren(1),
         clock       => clk_200mhz_i,  
         qa          => fsfb_qa0(1),         
         qb          => fsfb_qb0(1) 
      );

   -- Replica
   first_stage_fb_queue_1b: first_stage_fb_queue
      port map(
         data        => fsfb_data(1),
         wraddress   => fsfb_wadd(1),
         rdaddress_a => fsfb_radd_a1(1),
         rdaddress_b => fsfb_radd_b1(1),
         wren        => fsfb_wren(1),
         clock       => clk_200mhz_i,  
         qa          => fsfb_qa1(1),         
         qb          => fsfb_qb1(1) 
      );

   -- Raw data queue
   raw_data_queue_0: raw_data_queue
      port map(
         data        => raw_data,
         wraddress   => raw_wadd,
         rdaddress   => raw_radd_a,
--         rdaddress_a => raw_radd_a,
--         rdaddress_b => raw_radd_b,
         wren        => raw_wren,
         clock       => clk_200mhz_i,  
         q          => raw_qa
--         qa          => raw_qa,         
--         qb          => raw_qb 
      );   

   -- P, I, D, Z coefficient queue
   pidz_queue: pidz_coeff_queue
      port map(
         data        => pidz_data,
         wraddress   => pidz_wadd,
         rdaddress_a => pidz_radd_a,
         rdaddress_b => pidz_radd_b,
         wren        => pidz_wren,
         clock       => clk_200mhz_i,  
         qa          => pidz_qa,         
         qb          => pidz_qb 
      );   
      
----------------------------------------------------------------
-- adc_sample FSM:  for co-adding and logging raw data
--
-- This FSM will need to take into account the latency of the 
-- assetion of data on the adc_dat_o pins from the time the analog
-- inputs are sampled
----------------------------------------------------------------

   -- Feed the 50 MHz clock to the adc sampling pin
   adc_enc_o <= clk_i;

   adc_sample_state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         present_adc_sample_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         present_adc_sample_state <= next_adc_sample_state;
      end if;
   end process;

   adc_sample_state_NS: process(present_adc_sample_state)
   begin
      case present_adc_sample_state is
         when IDLE =>
            next_adc_sample_state <= IDLE;
         when DELAY =>
            next_adc_sample_state <= IDLE;
         when COADD =>
            next_adc_sample_state <= IDLE;
         when others =>
            next_adc_sample_state <= IDLE;
      end case;
   end process;

   adc_sample_state_out: process(present_adc_sample_state) 
   begin
      case present_adc_sample_state is
         when IDLE =>
         when DELAY =>
         when COADD =>
         when others =>
      end case;
   end process;


   
----------------------------------------------------------------
-- wishbone FSM:  for communication with the dispatch block
----------------------------------------------------------------
----------------------------------------------------------------
-- fsfb_calc FSM:  for calculating the first-stage feedback
----------------------------------------------------------------
----------------------------------------------------------------
-- fsfb_ctrl FSM:  for outputting the first-stage feedback to DAC
----------------------------------------------------------------
----------------------------------------------------------------
-- filter FSM:  for filtering first-stage feedback values
----------------------------------------------------------------

end behav;
