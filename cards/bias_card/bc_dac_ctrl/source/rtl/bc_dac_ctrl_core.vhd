-- 2003 SCUBA-2 Project
--                  All Rights Reserved

--  THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE SCUBA-2 Project
--  The copyright notice above does not evidence any
--  actual or intended publication of such source code.

--  SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
--  REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
--  MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
--  PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
--  THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.

-- For the purposes of this code the SCUBA-2 Project consists of the
-- following organisations.

-- UKATC, Royal Observatory, Blackford Hill Edinburgh EH9 3HJ
-- UBC,   University of British Columbia, Physics & Astronomy Department,
--        Vancouver BC, V6T 1Z1

-- $Id: bc_dac_ctrl.vhd,v 1.2 2004/11/15 20:03:41 bburger Exp $
--
-- Project:       SCUBA2
-- Author:        Bryce Burger
-- Organisation:  UBC
--
-- Description:
-- 
-- Revision history:
-- $Log: bc_dac_ctrl.vhd,v $
-- Revision 1.2  2004/11/15 20:03:41  bburger
-- Bryce :  Moved frame_timing to the 'work' library, and physically moved the files to "all_cards" directory
--
-- Revision 1.1  2004/11/11 01:47:10  bburger
-- Bryce:  new
--
--   
--
-- 
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;

library sys_param;
use sys_param.wishbone_pack.all;
use sys_param.general_pack.all;
use sys_param.data_types_pack.all;
use sys_param.command_pack.all;

library components;
use components.component_pack.all;

library work;
use work.bc_dac_ctrl_pack.all;
use work.frame_timing_pack.all;

entity bc_dac_ctrl_core is
   port
   (
      -- DAC hardware interface:
      -- There are 32 DAC channels, thus 32 serial data/cs/clk lines.
      flux_fb_data_o    : out std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);   
      flux_fb_ncs_o     : out std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);
      flux_fb_clk_o     : out std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);
      
      bias_data_o       : out std_logic;
      bias_ncs_o        : out std_logic;
      bias_clk_o        : out std_logic;
      
      dac_nclr_o        : out std_logic;

      -- wbs_bc_dac_ctrl interface:
      flux_fb_addr_o    : out std_logic_vector(COL_ADDR_WIDTH-1 downto 0);
      flux_fb_data_i    : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      bias_data_i       : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      flux_fb_changed_i : in std_logic;
      bias_changed_i    : in std_logic;
      
      -- frame_timing signals
      update_bias_i     : in std_logic;
      
      -- Global Signals      
      clk_i             : in std_logic;
      rst_i             : in std_logic      
   );     
end bc_dac_ctrl_core;

architecture rtl of bc_dac_ctrl_core is

   type flux_fb_states is (IDLE, PENDING, LOAD, CLOCK_OUT, LAST_BIT, NEXT_DAC);
   signal flux_fb_current_state  : flux_fb_states;
   signal flux_fb_next_state     : flux_fb_states;
   
   type bias_states is (IDLE, PENDING, LOAD, CLOCK_OUT, LAST_BIT);
   signal bias_current_state     : bias_states;
   signal bias_next_state        : bias_states;
   
   -- Flux Feedback SPI interface
   signal flux_fb_clk            : std_logic;
   signal flux_fb_done           : std_logic;
   signal flux_fb_ncs            : std_logic;
   signal flux_fb_data           : std_logic;
   signal flux_fb_start          : std_logic;
   
   -- Bias Feedback SPI interface
   signal bias_clk               : std_logic;
   signal bias_done              : std_logic;
   signal bias_ncs               : std_logic;
   signal bias_data              : std_logic;
   signal bias_start             : std_logic;
   
   -- Counter for the Flux Feedback DACs
   signal dac_count_clk          : std_logic;
   signal dac_count_rst          : std_logic;
   signal dac_count              : integer;

begin

   dac_nclr_o <= not rst_i;

   dac_counter: counter_xstep 
   generic map
   (
      MAX => (2**COL_ADDR_WIDTH)-1
   )
   port map
   (
      clk_i   => dac_count_clk,
      rst_i   => dac_count_rst,
      ena_i   => '1',
      step_i  => 1,
      count_o => dac_count
   );
   
   state_FF : process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         flux_fb_current_state <= IDLE;
         bias_current_state    <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         flux_fb_current_state <= flux_fb_next_state;
         bias_current_state    <= bias_next_state;
      end if;
   end process state_FF;
   
------------------------------------------------------------------------
-- FSM for the 32 flux feedback DACs
------------------------------------------------------------------------   
   flux_fb_state_NS : process(flux_fb_current_state, flux_fb_changed_i, update_bias_i, flux_fb_done, dac_count)
   begin      
      -- Default assignment
      flux_fb_next_state <= flux_fb_current_state;
      
      case flux_fb_current_state is 
         when IDLE => 
            if(flux_fb_changed_i = '1') then
               flux_fb_next_state <= PENDING;
            end if;   
                     
         when PENDING =>
            if(update_bias_i = '1') then         
               flux_fb_next_state <= LOAD;                
            end if;           
          
         when LOAD =>
            flux_fb_next_state <= CLOCK_OUT;
            
         when CLOCK_OUT =>
            if(flux_fb_done = '1') then
               flux_fb_next_state <= LAST_BIT;                
            end if;
         
         when LAST_BIT =>
            flux_fb_next_state <= NEXT_DAC;                
         
         when NEXT_DAC =>
            if(dac_count < NUM_FLUX_FB_DACS) then
               flux_fb_next_state <= LOAD;
            else 
               flux_fb_next_state <= IDLE;
            end if;   
            
         when others =>
            flux_fb_next_state <= IDLE;
      end case;
   end process flux_fb_state_NS;   
   
   flux_fb_addr_o <= std_logic_vector(conv_unsigned(dac_count, COL_ADDR_WIDTH));
   
   flux_fb_state_out : process(flux_fb_current_state, dac_count, flux_fb_data, flux_fb_ncs, flux_fb_clk)
   begin
      -- Default assignments
      dac_count_clk  <= '0';
      dac_count_rst  <= '0';
      flux_fb_start  <= '0';
      flux_fb_data_o <= (others => '0');    
      flux_fb_ncs_o  <= (others => '1');
      flux_fb_clk_o  <= (others => '0');        
      
      case flux_fb_current_state is 
         
         when IDLE =>
            dac_count_rst             <= '1';
         
         when PENDING =>          
            dac_count_rst             <= '1';
         
         when LOAD =>
            flux_fb_start             <= '1';
            flux_fb_data_o(dac_count) <= flux_fb_data;
            flux_fb_ncs_o(dac_count)  <= flux_fb_ncs;
            flux_fb_clk_o(dac_count)  <= flux_fb_clk;
         
         when CLOCK_OUT =>
            flux_fb_data_o(dac_count) <= flux_fb_data;
            flux_fb_ncs_o(dac_count)  <= flux_fb_ncs;
            flux_fb_clk_o(dac_count)  <= flux_fb_clk;
         
         when LAST_BIT =>
            flux_fb_data_o(dac_count) <= flux_fb_data;
            flux_fb_ncs_o(dac_count)  <= flux_fb_ncs;
            flux_fb_clk_o(dac_count)  <= flux_fb_clk;

         when NEXT_DAC =>
            dac_count_clk             <= '1';            
         
         when others =>
      end case;      
   end process flux_fb_state_out;

----------------------------------------------------------------------
-- FSM for the bias DAC
----------------------------------------------------------------------
   bias_state_NS : process(bias_current_state, bias_changed_i, update_bias_i, bias_done)
   begin      
      -- Default assignment
      bias_next_state <= bias_current_state;
      
      case bias_current_state is 
         when IDLE => 
            if(bias_changed_i = '1') then
               bias_next_state <= PENDING;
            end if;   
                     
         when PENDING =>
            if(update_bias_i = '1') then         
               bias_next_state <= LOAD;                
            end if;           
          
         when LOAD =>
            bias_next_state <= CLOCK_OUT;
            
         when CLOCK_OUT =>
            if(bias_done = '1') then
               bias_next_state <= LAST_BIT;                
            end if;

         when LAST_BIT =>
            bias_next_state <= IDLE;                
         
         when others =>
            bias_next_state <= IDLE;
            
      end case;
   end process bias_state_NS;   
   
   bias_state_out : process(bias_current_state, bias_data, bias_ncs, bias_clk)
   begin
      -- Default assignments
      bias_start     <= '0';
      bias_data_o    <= '0';    
      bias_ncs_o     <= '1';
      bias_clk_o     <= '0';        
      
      case bias_current_state is 
         
         when IDLE =>
         
         when PENDING =>          
         
         when LOAD =>
            bias_start    <= '1';
            bias_data_o   <= bias_data;
            bias_ncs_o    <= bias_ncs;
            bias_clk_o    <= bias_clk;
         
         when CLOCK_OUT =>
            bias_data_o   <= bias_data;
            bias_ncs_o    <= bias_ncs;
            bias_clk_o    <= bias_clk;

         when LAST_BIT =>
            bias_data_o   <= bias_data;
            bias_ncs_o    <= bias_ncs;
            bias_clk_o    <= bias_clk;
         
         when others =>
         
      end case;      
   end process bias_state_out;
   
------------------------------------------------------------------------
-- SPI interfaces to the 32 flux feedback DACs
------------------------------------------------------------------------
   flux_fb_dac : write_spi_with_cs
      generic map
      (
         DATA_LENGTH => BIAS_DATA_LENGTH
      )
      port map
      (
         --inputs
         spi_clk_i        => clk_i,
         rst_i            => rst_i,
         start_i          => flux_fb_start,
         parallel_data_i  => flux_fb_data_i(BIAS_DATA_LENGTH-1 downto 0),
       
         --outputs
         spi_clk_o        => flux_fb_clk,
         done_o           => flux_fb_done,
         spi_ncs_o        => flux_fb_ncs,
         serial_wr_data_o => flux_fb_data
      );

----------------------------------------------------------------------
-- SPI interface to the bias DAC
----------------------------------------------------------------------
    bias_dac : write_spi_with_cs
       generic map
       (
          DATA_LENGTH => BIAS_DATA_LENGTH
       )
       port map
       (
          --inputs
          spi_clk_i        => clk_i,
          rst_i            => rst_i,
          start_i          => bias_start,
          parallel_data_i  => bias_data_i(BIAS_DATA_LENGTH-1 downto 0),
        
          --outputs
          spi_clk_o        => bias_clk,
          done_o           => bias_done,
          spi_ncs_o        => bias_ncs,
          serial_wr_data_o => bias_data
       );
      
end rtl;