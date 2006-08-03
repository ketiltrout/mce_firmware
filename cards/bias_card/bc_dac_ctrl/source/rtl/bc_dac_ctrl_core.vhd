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

-- $Id: bc_dac_ctrl_core.vhd,v 1.8.2.1 2006/06/06 21:10:54 mandana Exp $
--
-- Project:       SCUBA2
-- Author:        Bryce Burger
-- Organisation:  UBC
--
-- Description:
-- 
-- Revision history:
-- $Log: bc_dac_ctrl_core.vhd,v $
-- Revision 1.8.2.1  2006/06/06 21:10:54  mandana
-- fixed a critical warning with asynchronous bias_changed and flux_fb_changed
--
-- Revision 1.8  2006/04/07 22:02:21  bburger
-- Bryce:  Bug Fix:  Added integer ranges to dac_count and clk_count.  Quartus 5.1 was messing up the synthsis without these ranges.
--
-- Revision 1.7  2005/01/25 00:00:03  mandana
-- fixed the synthesis error about flux_fb_changed_reg
--
-- Revision 1.6  2005/01/20 23:08:14  mandana
-- added a register for flux_fb_changed_i
-- removed debug connections
--
-- Revision 1.5  2005/01/17 22:58:06  mandana
-- add an extra state for loading the data to the SPI module
--
-- Revision 1.4  2005/01/07 01:31:27  bench2
-- Mandana: create type dac_states
-- changed SPI modules to run at 12.5MHz
-- Now that state machine runs at 50MHz and SPI at 12.5MHz, start_spi is modified to stay high till SPI_done goes high.
-- Add an extra state NEXT_DAC2, so the dac_counter is clocked in a different state.
--
-- Revision 1.3  2005/01/04 19:19:47  bburger
-- Mandana: changed mictor assignment to 0 to 31 and swapped odd and even pods
--
-- Revision 1.2  2004/12/21 22:06:51  bburger
-- Bryce:  update
--
-- Revision 1.1  2004/11/25 03:05:08  bburger
-- Bryce:  Modified the Bias Card DAC control slaves.
--
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

library sys_param;
use sys_param.command_pack.all;

library components;
use components.component_pack.all;

library work;
use work.bc_dac_ctrl_pack.all;

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
      rst_i             : in std_logic;
      debug             : inout std_logic_vector(31 downto 0)
   );     
end bc_dac_ctrl_core;

architecture rtl of bc_dac_ctrl_core is

   type dac_states is (IDLE, PENDING, LOAD1, LOAD2, CLOCK_OUT, LAST_BIT, NEXT_DAC, NEXT_DAC2);
   signal flux_fb_current_state  : dac_states;
   signal flux_fb_next_state     : dac_states;
   signal flux_fb_changed        : std_logic;
   signal flux_fb_changed_clr    : std_logic;
   
   signal bias_current_state     : dac_states;
   signal bias_next_state        : dac_states;
   signal bias_changed           : std_logic;
   signal bias_changed_clr       : std_logic;
   
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
   signal dac_count              : integer range 0 to NUM_FLUX_FB_DACS;
   
   -- SPI counter signals for clock division
   signal clk_div2                  : std_logic;
   signal clk_count              : integer range 0 to 3;

begin

   dac_nclr_o <= not rst_i;
   debug (8)  <= clk_i;
   debug (9)  <= clk_div2;
   debug (10) <= flux_fb_changed_i;
   debug (11) <= update_bias_i;
   debug (12) <= flux_fb_done;
   debug (13) <= flux_fb_start;
   debug (14) <= dac_count_rst;
   debug (15) <= dac_count_clk;
   debug (21 downto 16) <= std_logic_vector(conv_unsigned(dac_count, COL_ADDR_WIDTH));
   
-- instantiate a counter to divide the clock by 2
   clk_div_2: counter
   generic map(MAX => 3,
               STEP_SIZE => 1,
               WRAP_AROUND => '1',
               UP_COUNTER => '1')
   port map(clk_i   => clk_i,
            rst_i   => rst_i,
            ena_i   => '1',
            load_i  => '0',
            count_i => 0,
            count_o => clk_count);
   clk_div2   <= '1' when clk_count > 1 else '0';

   dac_counter: counter 
   generic map
   (
        MAX => NUM_FLUX_FB_DACS,  -- an intentional out of range!
        STEP_SIZE => 1,
        WRAP_AROUND => '1',
        UP_COUNTER => '1')        
   port map
   (
      clk_i   => dac_count_clk,
      rst_i   => dac_count_rst,
      ena_i   => '1',
      load_i  => '0',
      count_i => 0,
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
   flux_fb_state_NS : process(flux_fb_current_state, flux_fb_changed, update_bias_i, flux_fb_done, dac_count)
   begin      
      -- Default assignment
      flux_fb_next_state <= flux_fb_current_state;
            
      case flux_fb_current_state is 
         when IDLE => 
            if(flux_fb_changed = '1') then
               flux_fb_next_state <= PENDING;
            else 
               flux_fb_next_state <= IDLE;
            end if;   
            
         when PENDING =>
            if(update_bias_i = '1') then         
               flux_fb_next_state <= LOAD1;                
            else 
               flux_fb_next_state <= PENDING;
                           
            end if;           

         when LOAD1 =>
           flux_fb_next_state <= LOAD2;

         when LOAD2 =>
            flux_fb_next_state <= CLOCK_OUT;

         when CLOCK_OUT =>
            if(flux_fb_done = '1') then
               flux_fb_next_state <= LAST_BIT;
            else 
               flux_fb_next_state <= CLOCK_OUT;
            end if;

         when LAST_BIT =>
            flux_fb_next_state <= NEXT_DAC;                

         when NEXT_DAC =>
            if(dac_count < NUM_FLUX_FB_DACS - 1) then
               flux_fb_next_state <= NEXT_DAC2;
            else 
               flux_fb_next_state <= IDLE;
            end if;   

	 when NEXT_DAC2 =>
	    flux_fb_next_state <= LOAD1;

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
      flux_fb_changed_clr <= '0';
      
      case flux_fb_current_state is 
         
         when IDLE =>
            dac_count_rst             <= '1';
         
         when PENDING =>          
            dac_count_rst             <= '1';

         when LOAD1 =>
            flux_fb_data_o(dac_count) <= flux_fb_data;
            flux_fb_ncs_o(dac_count)  <= flux_fb_ncs;
            flux_fb_clk_o(dac_count)  <= flux_fb_clk;
         
         when LOAD2 =>
            flux_fb_data_o(dac_count) <= flux_fb_data;
            flux_fb_ncs_o(dac_count)  <= flux_fb_ncs;
            flux_fb_clk_o(dac_count)  <= flux_fb_clk;
         
         when CLOCK_OUT =>
            flux_fb_start             <= '1';
            flux_fb_data_o(dac_count) <= flux_fb_data;
            flux_fb_ncs_o(dac_count)  <= flux_fb_ncs;
            flux_fb_clk_o(dac_count)  <= flux_fb_clk;
         
         when LAST_BIT =>
            flux_fb_data_o(dac_count) <= flux_fb_data;
            flux_fb_ncs_o(dac_count)  <= flux_fb_ncs;
            flux_fb_clk_o(dac_count)  <= flux_fb_clk;
         
         when NEXT_DAC =>
            if(dac_count = 0 ) then
               flux_fb_changed_clr    <= '1';      
            end if;

         when NEXT_DAC2 =>
            dac_count_clk             <= '1';            
         
         when others => 
            null;
            
      end case;      
   end process flux_fb_state_out;

----------------------------------------------------------------------
-- register the change, in case a new change commands comes in when 
-- state machine is not in IDLE, i.e. DAC values are being clocked out.
----------------------------------------------------------------------
   flux_fb_changed_reg: process(clk_i,rst_i)
   begin 
      if (rst_i = '1') then
         flux_fb_changed <= '0';
         bias_changed <= '0';
      elsif(clk_i'event and clk_i='1') then   
         if (flux_fb_changed_clr = '1') then
            flux_fb_changed <= '0';
         elsif (flux_fb_changed_i = '1') then
            flux_fb_changed <= '1';
         end if;
         
         if (bias_changed_clr = '1') then
            bias_changed <= '0';
         elsif (bias_changed_i = '1') then
            bias_changed <= '1';
         end if;
          
      end if;
   end process flux_fb_changed_reg;
      
----------------------------------------------------------------------
-- FSM for the bias DAC
----------------------------------------------------------------------
   bias_state_NS : process(bias_current_state, bias_changed, update_bias_i, bias_done)
   begin      
      -- Default assignment
      bias_next_state <= bias_current_state;
      
      case bias_current_state is 
         when IDLE => 
            if(bias_changed = '1') then
               bias_next_state <= PENDING;
            else 
               bias_next_state <= IDLE;               
            end if;   
                     
         when PENDING =>
            if(update_bias_i = '1') then         
               bias_next_state <= LOAD1;     
            else
               bias_next_state <= PENDING;
            end if;           
          
         when LOAD1 =>
            bias_next_state <= CLOCK_OUT;
            
         when CLOCK_OUT =>
            if(bias_done = '1') then
               bias_next_state <= LAST_BIT;                
            else 
               bias_next_state <= CLOCK_OUT;
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
      bias_changed_clr <= '0';
      
      case bias_current_state is 
         
--         when IDLE =>
--         when PENDING =>          
         
         when LOAD1 =>
            bias_data_o   <= bias_data;
            bias_ncs_o    <= bias_ncs;
            bias_clk_o    <= bias_clk;
         
         when CLOCK_OUT =>
            bias_start    <= '1';
            bias_data_o   <= bias_data;
            bias_ncs_o    <= bias_ncs;
            bias_clk_o    <= bias_clk;
            bias_changed_clr <= '1';

         when LAST_BIT =>
            bias_data_o   <= bias_data;
            bias_ncs_o    <= bias_ncs;
            bias_clk_o    <= bias_clk;
         
         when others   => 
            null;
         
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
         spi_clk_i        => clk_div2,
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
          spi_clk_i        => clk_div2,
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