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
-- dispatch_crc_test.vhd
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Implements the CRC datapath for the dispatch block
--
-- Revision history:
-- 
-- $Log: dispatch_crc_test.vhd,v $
-- Revision 1.2  2004/08/05 00:26:02  erniel
-- entity renamed
--
-- Revision 1.1  2004/08/04 19:43:19  erniel
-- initial version
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library components;
use components.component_pack.all;


entity dispatch_crc_test is
generic(TEMP : std_logic_vector(3 downto 0) := "0000");
port(clk_i : in std_logic;
     rst_i : in std_logic;
     
     rx_data : in std_logic_vector(31 downto 0);
     rx_rdy  : in std_logic;
     rx_ack  : out std_logic;
     
     word_done : out std_logic;
     
     cmd_data : out std_logic_vector(31 downto 0));
end dispatch_crc_test;     

architecture rtl of dispatch_crc_test is
type crc_states is (IDLE_CRC, INITIALIZE_CRC, CALCULATE_CRC, CALC_CRC_DONE, PAUSE_NEXT, LOAD_NEXT);
signal crc_pres_state : crc_states;
signal crc_next_state : crc_states;

signal cmd_size_reg_ena   : std_logic;
signal crc_data_shreg_ena : std_logic;
signal crc_data_shreg_ld  : std_logic;
signal crc_bit_count_clr  : std_logic;
signal crc_ena            : std_logic;
signal crc_clr            : std_logic;

signal cmd_size      : std_logic_vector(15 downto 0);
signal crc_bit_count : integer;
signal crc_num_bits  : integer;
signal crc_input_bit : std_logic;
signal crc_done      : std_logic;
signal crc_valid     : std_logic;

constant CRC32 : std_logic_vector(31 downto 0) := "00000100110000010001110110110111";

begin

   -- CRC datapath
   cmd_size_reg : reg
      generic map(WIDTH => 16)
      port map(clk_i => clk_i,
           rst_i => rst_i,
           ena_i => cmd_size_reg_ena,
           reg_i => rx_data(15 downto 0),
           reg_o => cmd_size);

   crc_num_bits <= conv_integer((cmd_size + 3) & "00000");
   
   crc_data_reg : shift_reg
      generic map(WIDTH => 32)
      port map(clk_i      => clk_i,
               rst_i      => rst_i,
               ena_i      => crc_data_shreg_ena,
               load_i     => crc_data_shreg_ld,
               clr_i      => '0',
               shr_i      => '1',
               serial_i   => crc_input_bit,  -- this makes the shift register a rotator! (eliminates need for separate buffer)
               serial_o   => crc_input_bit,
               parallel_i => rx_data,
               parallel_o => cmd_data);
   
   crc_bit_counter : counter
      generic map(MAX         => 32,
                  WRAP_AROUND => '0')
      port map(clk_i   => clk_i,
               rst_i   => rst_i,
               ena_i   => '1',
               load_i  => crc_bit_count_clr,
               count_i => 0,
               count_o => crc_bit_count);

   crc_calc : crc
      generic map(POLY_WIDTH => 32)
      port map(clk_i      => clk_i,
               rst_i      => rst_i,
               clr_i      => crc_clr,
               ena_i      => crc_ena,
               data_i     => crc_input_bit,
               num_bits_i => crc_num_bits,
               poly_i     => CRC32,
               done_o     => crc_done,
               valid_o    => crc_valid,
               checksum_o => open);
           
   -- CRC control FSM
   crc_stateFF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         crc_pres_state <= IDLE_CRC;
      elsif(clk_i'event and clk_i = '1') then
         crc_pres_state <= crc_next_state;
      end if;
   end process crc_stateFF;
   
   crc_stateNS: process(crc_pres_state, rx_rdy, crc_bit_count, crc_done)
   begin
      case crc_pres_state is
         when IDLE_CRC =>       if(rx_rdy = '1') then
                                   crc_next_state <= INITIALIZE_CRC;
                                else
                                   crc_next_state <= IDLE_CRC;
                                end if;
                          
         when INITIALIZE_CRC => crc_next_state <= CALCULATE_CRC;
         
         when CALCULATE_CRC =>  if(crc_bit_count = 31) then
                                   crc_next_state <= CALC_CRC_DONE;
                                else
                                   crc_next_state <= CALCULATE_CRC;
                                end if;
                          
         when CALC_CRC_DONE =>  crc_next_state <= PAUSE_NEXT;
                                         
         when PAUSE_NEXT =>     if(crc_done = '1') then
                                   crc_next_state <= IDLE_CRC;
                                elsif(rx_rdy = '1') then 
                                   crc_next_state <= LOAD_NEXT;
                                else
                                   crc_next_state <= PAUSE_NEXT;
                                end if;
                            
         when LOAD_NEXT =>      crc_next_state <= CALCULATE_CRC;
         
         when others =>         crc_next_state <= IDLE_CRC;
      end case;
   end process crc_stateNS;
   
   crc_stateOut: process(crc_pres_state)
   begin
      rx_ack             <= '0';   
      cmd_size_reg_ena   <= '0';
      crc_data_shreg_ld  <= '0';
      crc_data_shreg_ena <= '0';      
      crc_bit_count_clr  <= '0';
      crc_clr            <= '0';
      crc_ena            <= '0';
      word_done          <= '0';
      
      case crc_pres_state is
         when INITIALIZE_CRC => rx_ack             <= '1';  
                                cmd_size_reg_ena   <= '1';
                                crc_data_shreg_ld  <= '1';
                                crc_data_shreg_ena <= '1';
                                crc_bit_count_clr  <= '1';
                                crc_clr            <= '1';
                                crc_ena            <= '1';
                           
         when CALCULATE_CRC =>  crc_ena            <= '1';
                                crc_data_shreg_ena <= '1';
         
         when CALC_CRC_DONE =>  word_done <= '1';
         
         when LOAD_NEXT =>      rx_ack             <= '1';
                                crc_data_shreg_ld  <= '1';
                                crc_data_shreg_ena <= '1';
                                crc_bit_count_clr  <= '1';
                                
         when others =>         null;
      end case;
   end process crc_stateOut;
   
end rtl;