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
-- $Id: dv_rx.vhd,v 1.4 2006/03/09 00:53:04 bburger Exp $
--
-- Project:       SCUBA-2
-- Author:        Greg Dennis
-- Organization:  UBC
--
-- Description:
-- DV and Manchester Decoder
--
-- Revision history:
-- $Log: dv_rx.vhd,v $
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

      sync_mode_i       : in std_logic_vector(SYNC_SELECT_WIDTH-1 downto 0);
      sync_i            : in std_logic;
      sync_o            : out std_logic
   );     
end dv_rx;

architecture top of dv_rx is
   
   ---------------------------------------------------------
   -- Signal Declarations
   ---------------------------------------------------------
   type states is (IDLE, FIBRE_DV_HIGH, FIBRE_DV_LOW, WAIT_FOR_SYNC, SYNC_ARRIVED, MANCH_DV_RCVD, MANCH_DV_ACK);   
   signal current_state, next_state : states;
   
   signal dv_dat_temp    : std_logic;
   signal dv_dat         : std_logic;
   signal manch_dat_temp : std_logic;
   signal manch_dat      : std_logic;
   signal manch_rdy      : std_logic;
   signal manch_ack      : std_logic;
   signal manch_word     : std_logic_vector(MANCHESTER_WORD_WIDTH-1 downto 0);
   signal manch_sync     : std_logic;
   signal manch_dv       : std_logic;
   signal manch_dv_num   : std_logic_vector(DV_NUM_WIDTH-1 downto 0);

begin

   ---------------------------------------------------------
   -- Continuous Assignments
   ---------------------------------------------------------
   manch_sync   <= manch_word(0);
   manch_dv     <= manch_word(1);
   manch_dv_num <= manch_word(33 downto 2);

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
      elsif(clk_i'event and clk_i = '1') then
         dv_dat         <= dv_dat_temp;
         manch_dat      <= manch_dat_temp;
      end if;
   end process;

   ---------------------------------------------------------
   -- State Machine
   ---------------------------------------------------------
   state_ff: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         current_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         current_state <= next_state;
      end if;
   end process state_ff;   

   --   constant DV_NUM_WIDTH           : integer := PACKET_WORD_WIDTH;
   --   constant DV_SELECT_WIDTH        : integer := 2;
   --   constant DV_INTERNAL            : std_logic_vector(DV_SELECT_WIDTH-1 downto 0) := "00";
   --   constant DV_EXTERNAL_FIBRE      : std_logic_vector(DV_SELECT_WIDTH-1 downto 0) := "01";
   --   constant DV_EXTERNAL_MANCHESTER : std_logic_vector(DV_SELECT_WIDTH-1 downto 0) := "10";
   --
   --   constant SYNC_SELECT_WIDTH      : integer := 2;
   --   constant SYNC_INTERNAL          : std_logic_vector(DV_SELECT_WIDTH-1 downto 0) := "00";
   --   constant SYNC_EXTERNAL          : std_logic_vector(DV_SELECT_WIDTH-1 downto 0) := "01";

   state_ns: process(current_state, dv_mode_i, dv_dat, manch_rdy, manch_dv, sync_i)
   begin
      next_state <= current_state;
      case current_state is
         
         when IDLE =>
            if(dv_mode_i = DV_EXTERNAL_FIBRE) then
               -- Note: the dv input is inverted, so we detect the rising edge.
               if(dv_dat = '0') then
                  next_state <= FIBRE_DV_HIGH;
               end if;
            elsif(dv_mode_i = DV_EXTERNAL_MANCHESTER) then
               if(manch_rdy = '1' and manch_dv = '1') then
                  next_state <= MANCH_DV_RCVD;
               end if;
            end if;
            
         when FIBRE_DV_HIGH =>
            if(dv_dat = '1') then
               next_state <= FIBRE_DV_LOW;
            end if;
         
         when FIBRE_DV_LOW =>
            next_state <= IDLE;         
         
         when WAIT_FOR_SYNC =>
            if(sync_i = '1') then
               next_state <= SYNC_ARRIVED;
            end if;
         
         when SYNC_ARRIVED =>
            next_state <= IDLE;
         
         when MANCH_DV_RCVD =>
            next_state <= MANCH_DV_ACK;
         
         when MANCH_DV_ACK =>
            next_state <= IDLE;
         
         when others =>
            next_state <= IDLE;
      end case;
   end process state_ns;
   
   state_out: process(current_state, manch_dv, manch_sync, manch_dv_num)
   begin
      -- Default Assignments
      dv_o              <= '0';
      dv_sequence_num_o <= (others => '0');
      sync_o            <= '0';
      manch_ack         <= '0';
    
      case current_state is
         
         when IDLE =>

         when FIBRE_DV_HIGH =>

         when WAIT_FOR_SYNC =>

         when FIBRE_DV_LOW =>
            -- cmd_translator synchronizes the DV pulse with the clock cycle following the next sync pulse (only for fibre dv input)
            -- DV input from Manchester is alredy sync'd with sync pulse.
            dv_o           <= '1';

         when SYNC_ARRIVED =>

         when MANCH_DV_RCVD =>
            dv_o              <= manch_dv;
            sync_o            <= manch_sync;
            dv_sequence_num_o <= manch_dv_num;

         when MANCH_DV_ACK =>
            manch_ack         <= '1';

         when others => NULL;
      end case;
   end process state_out;

end top;


