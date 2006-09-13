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
-- $Id: dv_rx.vhd,v 1.13 2006/08/16 17:55:55 bburger Exp $
--
-- Project:       SCUBA-2
-- Author:        Mandana Amiri
-- Organization:  UBC
--
-- Description:
-- DV and Manchester Decoder Test. Loopback fibre has to be connected from
-- fibre tx to sync-in inputs on clock card
--
-- Revision history:
-- <date $Date$>    - <initials $Author$>
-- $Log$
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library components;
use components.component_pack.all;

library work;
use work.cc_test_pack.all;

entity dv_rx_test is
   port(
      -- Clock and Reset:
      clk_i               : in std_logic;
      clk_n_i             : in std_logic;
      rst_i               : in std_logic;
      en_i                : in std_logic;
      done_o              : out std_logic;
      
      -- Fibre Interface:
      manch_det_i         : in std_logic;
      manch_dat_i         : in std_logic;
      dv_dat_i            : in std_logic;
      
      -- Test output
      dat_o               : out std_logic_vector (MANCH_WIDTH-1 downto 0)      
   );     
end dv_rx_test;

architecture rtl of dv_rx_test is
 
   ---------------------------------------------------------
   -- Signal Declarations
   ---------------------------------------------------------   
   type states is (IDLE, RX, DONE);   
   signal present_state, next_state : states;
     
   signal dv_dat_temp   : std_logic;
   signal dv_dat        : std_logic;
   
   signal manch_dat_temp: std_logic;
   signal manch_dat     : std_logic;
   signal manch_det_temp: std_logic;
   signal manch_det     : std_logic;
   
   signal manch_ena     : std_logic;
   signal data          : std_logic_vector(MANCH_WIDTH-1 downto 0);
   
   signal rxcount       : integer range 0 to 256;
   signal rxcount_ena   : std_logic;
   signal rxcount_clr   : std_logic;
  
begin

   ---------------------------------------------------------
   -- double synchronizer for dv_dat_i and manchester_dat_i:
   ---------------------------------------------------------
   process(rst_i, clk_n_i)
   begin
      if(rst_i = '1') then
         dv_dat_temp    <= '0';
         manch_dat_temp <= '0';
         manch_det_temp <= '0';
      elsif(clk_n_i'event and clk_n_i = '1') then
         dv_dat_temp    <= dv_dat_i;
         manch_dat_temp <= manch_dat_i;
         manch_det_temp <= manch_det_i;
      end if;
   end process;
   
   process(rst_i, clk_i)
   begin
      if(rst_i = '1') then
         dv_dat          <= '0';      
         manch_dat       <= '0';    
         manch_det       <= '0';         
      elsif(clk_i'event and clk_i = '1') then
         dv_dat          <= dv_dat_temp;
         manch_dat       <= manch_dat_temp;
         manch_det       <= manch_det_temp;
      end if;
   end process;

   ---------------------------------------------------------
   -- Manchester receiver
   ---------------------------------------------------------
   i_shift_reg: process (clk_i, rst_i)
   begin  
      if rst_i = '1' then               
         data <= (others => '0');        
      elsif clk_i'event and clk_i = '1' then       
         if (manch_ena = '1') then
            data(MANCH_WIDTH-1 downto 1) <= data(MANCH_WIDTH-2 downto 0);
            data(0)                      <= manch_dat;
         end if;
      end if;
   end process i_shift_reg;
   
   -- sample counter
   i_counter: process(clk_i, rst_i)
   begin
      if (rst_i = '1') then
         rxcount <= 0;
      elsif (clk_i'event and clk_i = '1') then
         if (rxcount_clr = '1') then
            rxcount <= 0;
         elsif (rxcount_ena = '1') then   
            rxcount <= rxcount + 1;
         end if;
      end if;
   end process i_counter;
   
   -- control state machine
   state_ff: process (clk_i, rst_i)
   begin
      if (rst_i = '1') then
         present_state <= IDLE;
      elsif (clk_i'event and clk_i = '1') then   
         present_state <= next_state;
      end if;
   end process;   
         
   state_ns: process(present_state, en_i,manch_dat, rxcount, manch_det)
   begin
      next_state <= present_state;
      case present_state is         
         when IDLE =>
            -- Manchester sync and DV are active low
            if (en_i = '1' ) then 
               next_state <= RX;
            end if;
            
         when RX =>
            if (rxcount = MANCH_WIDTH) then
               next_state <= DONE;
--            else
--               next_state <= RX;
            end if;           

--         when RX =>
--            next_state <= CHECK;
                     
         when DONE =>
            next_state <= IDLE;
         
         when others =>
            next_state <= IDLE;
      end case;
   end process state_ns;

   state_out: process(present_state, manch_dat, rxcount, manch_det)
   begin
      -- Default Assignments
      manch_ena   <= '0';
      rxcount_ena <= '0';
      rxcount_clr <= '0';      
      done_o      <= '0';

      case present_state is         
         when IDLE =>
            -- Manchester sync and DV are active low
            if (en_i = '1') then 
               manch_ena   <= '1';
               rxcount_ena <= '1';
            end if;
            
--         when CHECK => null;
--            if (rxcount = MANCH_WIDTH) then
--               done_o <= '1';
--            end if;

         when RX =>
            manch_ena   <= '1';
            rxcount_ena <= '1';
            
         when DONE =>
            rxcount_clr <= '1';
            done_o <= '1';
            
         when others => null;
         
      end case;
   end process state_out;
   
   dat_o <= data;

end rtl;


