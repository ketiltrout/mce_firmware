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
-- $Id$
-- Description:
-- Readout Card flux loop
--
-- Revision history:
-- $Log$
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library sys_param;
--use sys_param.wishbone_pack.all;
--use sys_param.frame_timing_pack.all;
--use sys_param.command_pack.all;
use sys_param.data_types_pack.all;

library components;
--use components.component_pack.all;

entity flux_loop is
   port(
      -- ADC Interface ???
      adc_clk_o     : out std_logic;
      adc_ovr_o     : out std_logic;
      adc_rdy_o     : out std_logic;
      adc_clk_i     : in std_logic;
      adc_dat_i     : in w14_array11;
      
      -- DAC interface
      dac_data_o    : out w14_array11;
      dac_clk_o     : out std_logic;
      
      -- Wishbone interface
      clk_i         : in std_logic;
      rst_i         : in std_logic;      
      dat_i         : in std_logic_vector (WB_DATA_WIDTH-1 downto 0);
      addr_i        : in std_logic_vector (WB_ADDR_WIDTH-1 downto 0);
      tga_i         : in std_logic_vector (WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i          : in std_logic;
      stb_i         : in std_logic;
      cyc_i         : in std_logic;
      dat_o         : out std_logic_vector (WB_DATA_WIDTH-1 downto 0);
      rty_o         : out std_logic;
      ack_o         : out std_logic;
      
      -- Clocks/resets
      clk_i         : in std_logic; -- Advances the state machines
      clk_200mhz_i  : in std_logic; -- Clocks the RAMs
      rst_i         : in std_logic  -- Resets all FSMs    

      -- Timing signals received from the frame_timing block
      sync_i        : in std_logic; -- The sync pulse determines when and when not to issue u-ops
      sync_num_i    : in std_logic_vector(SYNC_NUM_BUS_WIDTH-1 downto 0);
   );
end flux_loop;

architecture behav of flux_loop is

   constant ADDR_ZERO          : std_logic_vector(QUEUE_ADDR_WIDTH-1 downto 0) := (others => '0');
   constant ADDR_FULL_SCALE    : std_logic_vector(QUEUE_ADDR_WIDTH-1 downto 0) := (others => '1');
   
   -- Calculated parameter queue inputs/ouputs
   subtype param_queue_addr is std_logic_vector(CD_Q_ADDR_WIDTH-1 downto 0);
   type param_queue_addr_array is array (0 to 1) of param_queue_addr;
   subtype param_queue_wren is std_logic;
   type param_queue_wren_array is array (0 to 1) of param_queue_wren;
   subtype param_queue_data is std_logic_vector(CD_Q_WIDTH-1 downto 0);
   type param_queue_data_array is array (0 to 1) of param_queue_data;
   signal param_data   : param_queue_data_array;
   signal param_wren   : param_queue_wren_array;
   signal param_wadd   : param_queue_addr_array;
   signal param_radd_a : param_queue_addr_array;
   signal param_radd_b : param_queue_addr_array;
   signal param_qa     : param_queue_data_array;
   signal param_qb     : param_queue_data_array;
   
   -- Raw data queue inputs/outputs
   subtype raw_queue_addr is std_logic_vector(RD_Q_ADDR_WIDTH-1 downto 0);
   --type raw_queue_addr_array is array (0 to 1) of raw_queue_addr;
   subtype raw_queue_wren is std_logic;
   --type raw_queue_wren_array is array (0 to 1) of raw_queue_wren;
   subtype raw_queue_data is std_logic_vector(RD_Q_WIDTH-1 downto 0);
   --type raw_queue_dat_array is array (0 to 1) of raw_queue_dat;
   signal raw_data     : raw_queue_data;
   signal raw_wren     : raw_queue_wren;
   signal raw_wadd     : raw_queue_addr;
   signal raw_radd_a   : raw_queue_addr;
   signal raw_radd_b   : raw_queue_addr;
   signal raw_qa       : raw_queue_data;
   signal raw_qb       : raw_queue_data;

   -- Queue management variables
   signal param_rw_ptr : std_logic_vector(QUEUE_ADDR_WIDTH-1 downto 0);
   signal even_odd     : std_logic;
   signal sample_delay : std_logic_vector(31 downto 0);

   -- adc_sample FSM
   type adc_sample_states is (IDLE, RESET, DELAY, COADD);
   signal present_adc_sample_state : adc_sample_states;
   signal next_adc_sample_state    : adc_sample_states;
   signal coadded_val  : std_logic_vector(31 downto 0);
   
   -- first_stage_fb_calc FSM
   type first_stage_fb_calc_states is (IDLE, RESET);
   signal present_first_stage_fb_calc_state : first_stage_fb_calc_states;
   signal next_first_stage_fb_calc_state    : first_stage_fb_calc_states;
   
   -- first_stage_fb_ctrl FSM
   type first_stage_fb_ctrl_states is (IDLE, RESET);
   signal present_first_stage_fb_ctrl_state : first_stage_fb_ctrl_states;
   signal next_first_stage_fb_ctrl_state    : first_stage_fb_ctrl_states;

   -- Constants that can be removed when the sync_counter and frame_timer are moved out of this block
   constant HIGH       : std_logic := '1';
   constant LOW        : std_logic := '0';

begin

------------------------------------------------------------------------
-- Instantiations
------------------------------------------------------------------------ 

   -- Calculated parameter queue 0
   coadded_data_queue_0: coadded_data_queue
      port map(
         data        => param_data(0),
         wraddress   => param_wadd(0),
         rdaddress_a => param_radd_a(0),
         rdaddress_b => param_radd_b(0),
         wren        => param_wren_sig(0),
         clock       => clk_200mhz_i,  
         qa          => param_qa(0),         
         qb          => param_qb(0) 
      );

   -- Calculated parameter queue 1
   coadded_data_queue_1: coadded_data_queue
      port map(
         data        => param_data(1),
         wraddress   => param_wadd(1),
         rdaddress_a => param_radd_a(1),
         rdaddress_b => param_radd_b(1),
         wren        => param_wren_sig(1),
         clock       => clk_200mhz_i,  
         qa          => param_qa(1),         
         qb          => param_qb(1) 
      );
      
   -- Raw data queue
   raw_data_queue_0: raw_data_queue
      port map(
         data        => raw_data,
         wraddress   => raw_wadd,
         rdaddress_a => raw_radd_a,
         rdaddress_b => raw_radd_b,
         wren        => raw_wren_sig,
         clock       => clk_200mhz_i,  
         qa          => raw_qa,         
         qb          => raw_qb 
      );   
      
------------------------------------------------------------------------
-- adc_sample FSM:  for co-adding and logging raw data
------------------------------------------------------------------------ 

   -- Feed the 50 MHz clock to the adc
   adc_clk_o <= clk_i;

   adc_sample_state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         present_adc_sample_state <= RESET;
      elsif(clk_i'event and clk_i = '1') then
         present_adc_sample_state <= next_adc_sample_state;
      end if;
   end process;

   adc_sample_state_NS: process(present_adc_sample_state)
   begin
      case present_adc_sample_state is
         when RESET =>
            next_adc_sample_state <= IDLE;
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
         when RESET =>
         when IDLE =>
         when DELAY =>
         when COADD =>
         when others =>
      end case;
   end process;
   
end behav;
