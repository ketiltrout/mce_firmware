-- Copyright (c) 2003 SCUBA-2 Project
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

-- sync_gen.vhd
--
-- Project:     SCUBA-2
-- Author:      Bryce Burger
-- Organisation:   UBC
--
-- Description:
-- This implements the sync pulse generation on the Clock Card.
-- This block outputs a sync pulse one clock cycle wide whenever clk_ctr wraps to zero
-- The clk_ctr wraps to zero after counting to the last clock cycle in a frame:  END_OF_FRAME
-- If the output of sync pulse is to be regulated by the DV pulse, then: 
-- 1- assert dv_en_i high, and 
-- 2- connect the DV pulse input to dv_i
--
-- As long as a DV pulse is detected once per frame, the sync_gen will generate a sync pulse
-- To make sure that the DV pulse is detected, one can leave the DV line asserted high as long as data are desired
-- Even with DV asserted high for the duration of several frame cycles, only one sync pulse will be generated per frame
--
-- Revision history:
-- $Log: sync_gen.vhd,v $
-- Revision 1.3  2004/09/15 18:42:02  bburger
-- Bryce:  Added a recirculation MUX
--
-- Revision 1.2  2004/08/21 00:00:31  bburger
-- Bryce:  now issues a sync pulse on the last cycle of a frame.
--
-- Revision 1.1  2004/08/05 00:19:33  bburger
-- Bryce:  new
--
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library sys_param;
use sys_param.frame_timing_pack.all;
use sys_param.command_pack.all;

library components;
use components.component_pack.all;

library work;
use work.sync_gen_pack.all;

entity sync_gen is
   port(
      clk_i       : in std_logic;
      rst_i       : in std_logic;
      dv_i        : in std_logic;
      dv_en_i     : in std_logic;
      sync_o      : out std_logic;
      sync_num_o  : out std_logic_vector(SYNC_NUM_WIDTH-1 downto 0)
   );
end sync_gen;

architecture beh of sync_gen is

   type states is (SYNC_LOW, SYNC_HIGH, DV_RECEIVED, RESET);   
   signal current_state, next_state : states;
   
   signal new_frame_period : std_logic;   
   signal clk_count        : integer;
   signal sync_count       : integer;
   signal sync_num         : std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
   
   signal sync_num_mux     : std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
   signal sync_num_mux_sel : std_logic;

   begin      
      clk_ctr: counter
         generic map(
            MAX         => END_OF_FRAME,
            STEP_SIZE   =>   1, 
            WRAP_AROUND =>  '1', 
            UP_COUNTER  =>  '1'        
         )
         port map(
            clk_i       => clk_i,
            rst_i       => rst_i,
            ena_i       =>  '1',
            load_i      =>  '0',
            count_i     =>   0,
            count_o     => clk_count
         );

      sync_ctr: counter
         generic map(
            MAX         => 255,
            STEP_SIZE   =>   1, 
            WRAP_AROUND =>  '1', 
            UP_COUNTER  =>  '1'        
         )
         port map(
            clk_i       => new_frame_period,
            rst_i       => rst_i,
            ena_i       =>  '1',
            load_i      =>  '0',
            count_i     =>   0,
            count_o     => sync_count
         );

      new_frame_period  <= '1' when clk_count = END_OF_FRAME else '0';
      sync_o            <= new_frame_period;
      sync_num_o        <= sync_num;
--      sync_num_o        <= std_logic_vector(conv_unsigned(sync_count, SYNC_NUM_WIDTH));

      sync_state_FF: process(clk_i, rst_i)
      begin
         if(rst_i = '1') then
            current_state <= RESET;
            sync_num      <= (others=>'0');
         elsif(clk_i'event and clk_i = '1') then
            current_state <= next_state;
            sync_num      <= sync_num_mux;
         end if;
      end process;

      sync_state_NS: process(current_state, dv_en_i, dv_i, new_frame_period)
      begin
         case current_state is
            when RESET =>
               next_state <= SYNC_LOW;
            when SYNC_LOW =>
               if(dv_en_i = '1') then
                  if(dv_i = '1') then
                     next_state <= DV_RECEIVED;
                  else
                     next_state <= SYNC_LOW;
                  end if;
               else
                  if(new_frame_period = '1') then
                     next_state <= SYNC_HIGH;
                  else
                     next_state <= SYNC_LOW;
                  end if;
               end if;
            when SYNC_HIGH =>
               next_state <= SYNC_LOW;
            when DV_RECEIVED =>
               if(new_frame_period = '1') then
                  next_state <= SYNC_HIGH;
               else
                  next_state <= DV_RECEIVED;
               end if;
            when others =>
               next_state <= SYNC_LOW;
         end case;
      end process;    
      
      sync_state_out: process(current_state)
      begin
         case current_state is
            when RESET =>
               --sync_o <= '0';
               sync_num_mux_sel <= '1';
               --sync_num <= std_logic_vector(conv_unsigned(sync_count, SYNC_NUM_WIDTH));
            when SYNC_LOW =>
               --sync_o <= '0';
               sync_num_mux_sel <= '0';
               --sync_num <= sync_num;
            when SYNC_HIGH =>
               --sync_o     <= '1';
               sync_num_mux_sel <= '1';
               --sync_num <= std_logic_vector(conv_unsigned(sync_count, SYNC_NUM_WIDTH));
            when DV_RECEIVED =>
               --sync_o <= '0';
               sync_num_mux_sel <= '0';
               --sync_num <= sync_num;
            when others =>
               --sync_o <= '0';
               sync_num_mux_sel <= '0';
               --sync_num <= sync_num;
         end case;
      end process;
      
      sync_num_mux <= sync_num when sync_num_mux_sel = '0' else std_logic_vector(conv_unsigned(sync_count, SYNC_NUM_WIDTH));

end beh;