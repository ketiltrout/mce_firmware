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

-- sram_test_wrapper.vhd
--
-- <revision control keyword substitutions e.g. $Id: sram_test_wrapper.vhd,v 1.1 2004/03/25 20:23:14 erniel Exp $>
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- This file implements the test wrapper for the SRAM
--
-- Revision history:
-- $Log: sram_test_wrapper.vhd,v $
-- Revision 1.1  2004/03/25 20:23:14  erniel
-- initial version
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
use work.sram_ctrl_pack.all;

library sys_param;
use sys_param.wishbone_pack.all;

                     
entity sram_test_wrapper is
port(-- test control signals
     rst_i  : in std_logic;    
     clk_i  : in std_logic;    
     en_i   : in std_logic;    
     done_o : out std_logic;   
      
     -- RS232 signals
     tx_busy_i : in std_logic;
     tx_ack_i  : in std_logic;
     tx_data_o : out std_logic_vector(7 downto 0);
     tx_we_o   : out std_logic; 
     tx_stb_o  : out std_logic; 
      
     -- physical pins
     addr_o  : out std_logic_vector(19 downto 0);
     data_bi : inout std_logic_vector(15 downto 0); 
     n_ble_o : out std_logic;
     n_bhe_o : out std_logic;
     n_oe_o  : out std_logic;
     n_ce1_o : out std_logic;
     ce2_o   : out std_logic;
     n_we_o  : out std_logic);
end sram_test_wrapper;

architecture rtl of sram_test_wrapper is

-- test wrapper state encoding and variables:
type states is (IDLE, REQUEST, TX_PASS, TX_FAIL, TX_WAIT, DONE);
signal present_state : states;
signal next_state    : states;

-- wishbone signals:
signal adr_o  : std_logic_vector (WB_ADDR_WIDTH-1 downto 0);
signal tga_o  : std_logic_vector (WB_TAG_ADDR_WIDTH-1 downto 0);
signal dat_o 	: std_logic_vector (WB_DATA_WIDTH-1 downto 0); 
signal dat_i  : std_logic_vector (WB_DATA_WIDTH-1 downto 0);
signal we_o   : std_logic;
signal stb_o  : std_logic;
signal ack_i  : std_logic;
signal rty_i  : std_logic;
signal cyc_o  : std_logic;  

begin

   -- instantiate sram controller
   sram0 : sram_ctrl
   generic map(ADDR_WIDTH     => WB_ADDR_WIDTH,
               DATA_WIDTH     => WB_DATA_WIDTH,
               TAG_ADDR_WIDTH => WB_TAG_ADDR_WIDTH)
        
   port map(-- SRAM signals:
            addr_o  => addr_o,
            data_bi => data_bi,
            n_ble_o => n_ble_o,
            n_bhe_o => n_bhe_o,
            n_oe_o  => n_oe_o,
            n_ce1_o => n_ce1_o,
            ce2_o   => ce2_o,
            n_we_o  => n_we_o,
     
            -- wishbone signals:
            clk_i   => clk_i,
            rst_i   => rst_i,
            dat_i 	 => dat_o,
            addr_i  => adr_o,
            tga_i   => tga_o,
            we_i    => we_o,
            stb_i   => stb_o,
            cyc_i   => cyc_o,
            dat_o   => dat_i,
            rty_o   => rty_i,
            ack_o   => ack_i);
   
   
   -- state register:
   state_FF: process(clk_i, rst_i, en_i)
   begin
      if(rst_i = '1' or en_i = '0') then 
         present_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         present_state <= next_state;
      end if;
   end process state_FF;
   
   state_NS: process(present_state, en_i, rty_i, ack_i, dat_i, tx_ack_i, tx_busy_i)
   begin
      case present_state is
         when IDLE =>     if(en_i = '1') then
                             next_state <= REQUEST;
                          else
                             next_state <= IDLE;
                          end if;
                          
         when REQUEST =>  if(rty_i = '1') then
                             next_state <= IDLE;
                          elsif(ack_i = '1' and dat_i = "00000000000000000000000000000000" and tx_busy_i = '0') then
                             next_state <= TX_PASS;
                          elsif(ack_i = '1' and not (dat_i = "00000000000000000000000000000000") and tx_busy_i = '0') then
                             next_state <= TX_FAIL;
                          else
                             next_state <= REQUEST;
                          end if;
                                
         when TX_PASS =>  if(tx_ack_i = '1') then
                             next_state <= TX_WAIT;
                          else
                             next_state <= TX_PASS;
                          end if;
         
         when TX_FAIL =>  if(tx_ack_i = '1') then
                             next_state <= TX_WAIT;
                          else
                             next_state <= TX_FAIL;
                          end if;
                          
         when TX_WAIT =>  if(tx_ack_i = '0' and tx_busy_i = '0') then
                             next_state <= DONE;
                          else
                             next_state <= TX_WAIT;
                          end if;
                          
         when DONE =>     next_state <= IDLE;
         
         when others =>   next_state <= IDLE;
         
      end case;
   end process state_NS;
   
   state_out: process(present_state)
   begin
      case present_state is
         when IDLE =>     adr_o     <= (others => '0');
                          tga_o     <= (others => '0');
                          dat_o     <= (others => '0');
                          we_o      <= '0';
                          stb_o     <= '0';
                          cyc_o     <= '0';                          
                          tx_data_o <= (others => '0');
                          tx_we_o   <= '0';
                          tx_stb_o  <= '0';
                          done_o    <= '0';
         
         when REQUEST =>  adr_o     <= SRAM_VERIFY_ADDR;
                          tga_o     <= (others => '0');
                          dat_o     <= (others => '0');
                          we_o      <= '0';
                          stb_o     <= '1';
                          cyc_o     <= '1';                          
                          tx_data_o <= (others => '0');
                          tx_we_o   <= '0';
                          tx_stb_o  <= '0';
                          done_o    <= '0';
                          
         when TX_PASS =>  adr_o     <= (others => '0');
                          tga_o     <= (others => '0');
                          dat_o     <= (others => '0');
                          we_o      <= '0';
                          stb_o     <= '0';
                          cyc_o     <= '0';  
                          tx_data_o <= "01010000";   -- ascii P, if passed console prints out "P"
                          tx_we_o   <= '1';
                          tx_stb_o  <= '1';
                          done_o    <= '0';

         when TX_FAIL =>  adr_o     <= (others => '0');
                          tga_o     <= (others => '0');
                          dat_o     <= (others => '0');
                          we_o      <= '0';
                          stb_o     <= '0';
                          cyc_o     <= '0';       
                          tx_data_o <= "01000110";   -- ascii F, if failed console prints out "F"
                          tx_we_o   <= '1';
                          tx_stb_o  <= '1';
                          done_o    <= '0';
                          
         when TX_WAIT =>  adr_o     <= (others => '0');
                          tga_o     <= (others => '0');
                          dat_o     <= (others => '0');
                          we_o      <= '0';
                          stb_o     <= '0';
                          cyc_o     <= '0';       
                          tx_data_o <= (others => '0');
                          tx_we_o   <= '0';
                          tx_stb_o  <= '0';
                          done_o    <= '0';
                          
         when DONE =>     adr_o     <= (others => '0');
                          tga_o     <= (others => '0');
                          dat_o     <= (others => '0');
                          we_o      <= '0';
                          stb_o     <= '0';
                          cyc_o     <= '0';                          
                          tx_data_o <= (others => '0');
                          tx_we_o   <= '0';
                          tx_stb_o  <= '0';
                          done_o    <= '1';
                          
         when others =>   adr_o     <= (others => '0');
                          tga_o     <= (others => '0');
                          dat_o     <= (others => '0');
                          we_o      <= '0';
                          stb_o     <= '0';
                          cyc_o     <= '0';
                          tx_data_o <= (others => '0');
                          tx_we_o   <= '0';
                          tx_stb_o  <= '0';
                          done_o    <= '0';
                          
      end case;
   end process state_out;
end rtl;
