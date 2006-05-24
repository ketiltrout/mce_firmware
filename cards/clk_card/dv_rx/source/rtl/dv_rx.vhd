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
-- $Id: dv_rx.vhd,v 1.8 2006/05/23 21:26:42 bburger Exp $
--
-- Project:       SCUBA-2
-- Author:        Bryce Burger
-- Organization:  UBC
--
-- Description:
-- DV and Manchester Decoder
--
-- Revision history:
-- $Log: dv_rx.vhd,v $
-- Revision 1.8  2006/05/23 21:26:42  bburger
-- Bryce:  Intemediate Committal
--
-- Revision 1.7  2006/05/13 07:38:49  bburger
-- Bryce:  Intermediate commital -- going away on holiday and don't want to lose work
--
-- Revision 1.6  2006/03/23 23:18:02  bburger
-- Bryce:  cleaned up this file a little
--
-- Revision 1.5  2006/03/16 00:14:52  bburger
-- Bryce:  dv is inverted at the receiver, so dv_rx detects rising edges instead of falling edges.
--
-- Revision 1.4  2006/03/09 00:53:04  bburger
-- Bryce:
-- - Implemented the dv_fibre receiver
-- - Moved some constants from dv_rx_pack to sync_gen_pack
--
-- Revision 1.3  2006/03/01 02:53:32  bburger
-- Bryce:  modified interface signals dv_sel_i and sync_sel_i to dv_mode_i and sync_mode_i
--
-- Revision 1.2  2006/02/28 09:20:58  bburger
-- Bryce:  Modified the interface of dv_rx.  Non-functional at this point.
--
-- Revision 1.1  2006/02/11 01:11:53  bburger
-- Bryce:  New!
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library components;
use components.component_pack.all;

library work;
use work.sync_gen_pack.all;
use work.dv_rx_pack.all;

entity dv_rx is
   port(
      -- Clock and Reset:
      clk_i             : in std_logic;
      clk_n_i           : in std_logic;
      rst_i             : in std_logic;
      
      -- Fibre Interface:
      manchester_dat_i  : in std_logic;
      dv_dat_i          : in std_logic;
      
      -- Issue-Reply Interface:
      dv_mode_i         : in std_logic_vector(DV_SELECT_WIDTH-1 downto 0);
      dv_o              : out std_logic;
      dv_sequence_num_o : out std_logic_vector(DV_NUM_WIDTH-1 downto 0);

--      sync_mode_i       : in std_logic_vector(SYNC_SELECT_WIDTH-1 downto 0);
--      sync_i            : in std_logic;
      sync_o            : out std_logic
   );     
end dv_rx;

architecture top of dv_rx is
   
   ---------------------------------------------------------
   -- Signal Declarations
   ---------------------------------------------------------
   type states is (IDLE, FIBRE_DV_HIGH, FIBRE_DV_LOW, WAIT_FOR_SYNC, SYNC_ARRIVED, MANCH_DV_RCVD, MANCH_DV_ACK);   
   signal current_state, next_state : states;
   
   type m_states is (IDLE, RX_1, RX_2, DONE);   
   signal current_m_state, next_m_state : m_states;
   
   signal dv_dat_temp      : std_logic;
   signal dv_dat           : std_logic;
   signal manch_dat_temp   : std_logic;
   signal manch_dat        : std_logic;
   signal manch_rdy        : std_logic;
   signal manch_ack        : std_logic;
   signal manch_word       : std_logic_vector(MANCHESTER_WORD_WIDTH-1 downto 0);
   signal manch_reg        : std_logic_vector(MANCHESTER_WORD_WIDTH-1 downto 0);
   signal manch_reg_en     : std_logic;
   signal manch_sync       : std_logic;
   signal manch_dv         : std_logic;

   --00’, followed by a 32 bit number, followed by 6 spare bits
   signal rx_buf_ena       : std_logic;
   signal rx_buf_clr       : std_logic;
   
   signal sample_count     : std_logic_vector(7 downto 0);
   signal sample_count_ena : std_logic;
   signal sample_count_clr : std_logic;

begin

   ---------------------------------------------------------
   -- Continuous Assignments
   ---------------------------------------------------------
   manch_sync        <= manch_reg(0);
   manch_dv          <= manch_reg(1);
   dv_sequence_num_o <= manch_reg(33 downto 2);

   ---------------------------------------------------------
   -- double synchronizer for dv_dat_i and manchester_dat_i:
   ---------------------------------------------------------
   process(rst_i, clk_n_i)
   begin
      if(rst_i = '1') then
         dv_dat_temp    <= '0';
         manch_dat_temp <= '0';
      elsif(clk_n_i'event and clk_n_i = '1') then
         dv_dat_temp    <= dv_dat_i;
         manch_dat_temp <= manchester_dat_i;
      end if;
   end process;
   
   process(rst_i, clk_i)
   begin
      if(rst_i = '1') then
         dv_dat         <= '0';      
         manch_dat      <= '0';    
         manch_reg      <= (others => '0');
      elsif(clk_i'event and clk_i = '1') then
         dv_dat         <= dv_dat_temp;
         manch_dat      <= manch_dat_temp;
         
         if (manch_reg_en = '1') then
            manch_reg <= manch_word;
         else
            manch_reg <= manch_reg;
         end if;
         
      end if;
   end process;

   ---------------------------------------------------------
   -- Manchester receiver
   ---------------------------------------------------------
   rx_buffer: shift_reg
   generic map(
      WIDTH => MANCHESTER_WORD_WIDTH
   )
   port map(
      clk_i      => clk_i,
      rst_i      => rst_i,
      ena_i      => rx_buf_ena,
      load_i     => '0',
      clr_i      => rx_buf_clr,
      shr_i      => '1',
      serial_i   => manch_dat,
      serial_o   => open,
      parallel_i => (others => '0'),
      parallel_o => manch_word
   );

   sample_counter: binary_counter
   generic map(WIDTH => 8)
   port map(
      clk_i   => clk_i,
      rst_i   => rst_i,
      ena_i   => sample_count_ena,
      up_i    => '1',
      load_i  => '0',
      clear_i => sample_count_clr,
      count_i => (others => '0'),
      count_o => sample_count
   );
   
   

   manch_ns: process(current_m_state, manch_dat, sample_count)
   begin
      next_m_state <= current_m_state;
      case current_m_state is
         
         when IDLE =>
            if (manch_dat = '1') then
               next_m_state <= RX_2;
            end if;
            
         when RX_1 =>
            next_m_state <= RX_2;
            
         when RX_2 =>
            if (sample_count = "00101000") then
               next_m_state <= DONE;
            else
               next_m_state <= RX_1;
            end if;           
         
         when DONE =>
            next_m_state <= IDLE;
         
         when others =>
            next_m_state <= IDLE;
      end case;
   end process manch_ns;

   manch_out: process(current_m_state, manch_dat, sample_count)
   begin
      -- Default Assignments
      rx_buf_ena       <= '0';
      sample_count_ena <= '0';
      sample_count_clr <= '0';
      manch_reg_en     <= '0';
      manch_rdy        <= '0';
      
      case current_m_state is
         
         when IDLE =>
            if (manch_dat = '1') then
               rx_buf_ena       <= '1';
               sample_count_ena <= '1';
            end if;
            
         when RX_1 =>
            rx_buf_ena       <= '1';
            sample_count_ena <= '1';

         when RX_2 =>
            if (sample_count = "00101000") then
               manch_reg_en     <= '1';
            end if;
            
         when DONE =>
            sample_count_clr <= '1';
            manch_rdy        <= '1';

         when others => NULL;
      end case;
   end process manch_out;

   ---------------------------------------------------------
   -- State Machine
   ---------------------------------------------------------
   state_ff: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         current_state <= IDLE;
         current_m_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         current_state <= next_state;
         current_m_state <= next_m_state;
      end if;
   end process state_ff;   

   state_ns: process(current_state, dv_mode_i, dv_dat, manch_rdy, manch_dv)
   begin
      next_state <= current_state;
      case current_state is
         
         when IDLE =>
            if(dv_mode_i = DV_EXTERNAL_FIBRE) then
               -- Note: the dv input is inverted, so if we detect '0', we wait for the rising edge.
               if(dv_dat = '0') then
                  next_state <= FIBRE_DV_HIGH;
               end if;
            elsif(dv_mode_i = DV_EXTERNAL_MANCHESTER) then
               if(manch_rdy = '1') then
                  next_state <= MANCH_DV_RCVD;
               end if;
            end if;
            
         when FIBRE_DV_HIGH =>
            if(dv_dat = '1') then
               next_state <= FIBRE_DV_LOW;
            end if;
         
         when FIBRE_DV_LOW =>
            next_state <= IDLE;         
         
         when MANCH_DV_RCVD =>
            next_state <= MANCH_DV_ACK;
         
         when MANCH_DV_ACK =>
            next_state <= IDLE;
         
         when others =>
            next_state <= IDLE;
      end case;
   end process state_ns;
   
   state_out: process(current_state, manch_dv, manch_sync)
   begin
      -- Default Assignments
      dv_o              <= '0';
      sync_o            <= '0';
      manch_ack         <= '0';
    
      case current_state is
         
         when IDLE =>

         when FIBRE_DV_HIGH =>

         when FIBRE_DV_LOW =>
            -- cmd_translator synchronizes the DV pulse with the clock cycle following the next sync pulse (only for fibre dv input)
            -- DV input from Manchester is alredy sync'd with sync pulse.
            dv_o              <= '1';

         when MANCH_DV_RCVD =>
            dv_o              <= manch_dv;
            sync_o            <= manch_sync;

         when MANCH_DV_ACK =>
            manch_ack         <= '1';

         when others => NULL;
      end case;
   end process state_out;

end top;


