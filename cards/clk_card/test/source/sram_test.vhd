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
-- <revision control keyword substitutions e.g. $Id: sram_test_wrapper.vhd,v 1.2 2004/04/21 19:58:39 bburger Exp $>
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
-- Revision 1.2  2004/04/21 19:58:39  bburger
-- Changed address moniker
--
-- Revision 1.1  2004/04/14 21:53:28  jjacob
-- new directory structure
--
-- Revision 1.1  2004/03/25 20:23:14  erniel
-- initial version
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library sys_param;
use sys_param.wishbone_pack.all;
use sys_param.data_types_pack.all;

library components;
use components.component_pack.all;

--library lpm;
--use lpm.lpm_components.all;
                     
entity sram_test_wrapper is
port(-- test control signals
     rst_i  : in std_logic;    
     clk_i  : in std_logic;    
     en_i   : in std_logic;    
     done_o : out std_logic;   
      
     -- RS232 signals
      
     -- physical pins
     addr_o  : out std_logic_vector(19 downto 0);
     data_bi : inout std_logic_vector(15 downto 0); 
     n_ble_o : out std_logic;
     n_bhe_o : out std_logic;
     n_oe_o  : out std_logic;
     n_ce1_o : out std_logic;
     ce2_o   : out std_logic;
     n_we_o  : out std_logic;
     pass    : out std_logic;
     fail    : out std_logic);
end sram_test_wrapper;


architecture rtl of sram_test_wrapper is

-- LPM component

--component slr 
--	PORT
--	(
--		clock		: IN STD_LOGIC ;
--		load		: IN STD_LOGIC ;
--		data		: IN STD_LOGIC_VECTOR (19 DOWNTO 0);
--		q		: OUT STD_LOGIC_VECTOR (19 DOWNTO 0)
--	);
--END component;

-- test wrapper state encoding and variables:
type states is (IDLE, WR0_PREP, WR0, WR_PREP, WR, RD0_PREP, RD0, RD0_DONE, RD_PREP, RD, RD_DONE, NXT, FAILED, PASSED);
signal present_state : states;
signal next_state    : states;
signal cur_addr      : std_logic_vector(19 downto 0);

signal slr_clk       : std_logic;
signal slr_load      : std_logic;
signal slr_data      : std_logic_vector(19 downto 0);

signal zero, one     : std_logic;
signal zero_int      : integer;

type    w_array3 is array (2 downto 0) of word16;
signal idx           : integer;
signal dummy         : std_logic;

begin
-- instantiate a shift-left-register for generating walking 1 pattern.

--   slr_inst : slr PORT MAP (
--		clock	 => slr_clk,
--		load	 => slr_load,
--		data	 => slr_data,
--		q	 => cur_addr
--	);
   slr_inst : shift_reg 
      generic map (WIDTH => 20)
      port map (
           clk        => slr_clk,
           rst        => rst_i,
           ena        => one,
           load       => slr_load,
           clr        => zero,
           shr        => zero,
           serial_i   => zero,
           serial_o   => dummy,
           parallel_i => slr_data,
           parallel_o => cur_addr
   );     		      

zero <= '0';
one  <= '1';
zero_int <= 0;

   idx_count: counter
   generic map(MAX => 20)
   port map(clk_i   => slr_clk,
            rst_i   => zero,
            ena_i   => one,
            load_i  => slr_load,
            down_i  => zero,
            count_i => zero_int,
            count_o => idx);
      
   -- state register:
   state_FF: process(clk_i, rst_i, en_i)
   begin
      if(rst_i = '1' or en_i = '0') then 
         present_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         present_state <= next_state;
      end if;
   end process state_FF;
   
   state_NS: process(present_state, en_i, idx)
   begin
      case present_state is
         when IDLE =>     
            if(en_i = '1') then
               next_state <= WR0_PREP;
            else
               next_state <= IDLE;
            end if;
                          
         when WR0_PREP =>  
            next_state <= WR0;
                                
         when WR0 =>  
            next_state <= WR_PREP;         

         when WR_PREP =>  
            next_state <= WR;
                                
         when WR =>  
            next_state <= RD0_PREP;         
         
         when RD0_PREP =>
            next_state <= RD0;
         
         when RD0 =>                  
            if data_bi = "0000000000000000" then
	       next_state <= RD0_DONE;
	    else
	       next_state <= FAILED;
	    end if;   

         when RD0_DONE =>
            next_state <= RD_PREP;
	    
	 when RD_PREP =>
            next_state <= RD;
         
         when RD =>                  
            if data_bi = "1010101010101010" then
	       next_state <= RD_DONE;
	    else
	       next_state <= FAILED;
	    end if;   
	       
         when RD_DONE =>
            next_state <= NXT;
         
         when NXT =>
            if (idx < 20) then
               next_state <= WR_PREP;
            else
               next_state <= PASSED;
            end if;
         
         when FAILED =>
            next_state <= IDLE;
            
         when PASSED =>     
            next_state <= IDLE;
         
         when others =>   
            next_state <= IDLE;
         
      end case;
   end process state_NS;
   
   state_out: process(present_state)
   begin
      case present_state is
         when IDLE =>   
            slr_data  <= "00000000000000000001";                     
            slr_load  <= '1';
            slr_clk   <= '0';
            addr_o    <= (others => '0');
--            data_bi   <= '0';
            n_ble_o   <= '1';
            n_bhe_o   <= '1';
            n_oe_o    <= '1';
            n_ce1_o   <= '1';
            ce2_o     <= '0';
            n_we_o    <= '1';
            pass      <= '0';            
            fail      <= '0';
            done_o    <= '0';

         when WR0_PREP =>  
            slr_data  <= "00000000000000000001";                     
            slr_load  <= '0';
            slr_clk   <= '0';
            addr_o    <= "00000000000000000000";
            data_bi   <= "0000000000000000";
            n_ble_o   <= '0';
            n_bhe_o   <= '0';
            n_oe_o    <= '1';
            n_ce1_o   <= '0';
            ce2_o     <= '1';
            n_we_o    <= '0';
            pass      <= '0';            
            fail      <= '0';
            done_o    <= '0';                       
            
         when WR0 =>  
            slr_data  <= "00000000000000000001";                     
            slr_load  <= '0';
            slr_clk   <= '0';
            addr_o    <= "00000000000000000000";
            data_bi   <= "0000000000000000";
            n_ble_o   <= '1';
            n_bhe_o   <= '1';
            n_oe_o    <= '1';
            n_ce1_o   <= '1';
            ce2_o     <= '0';
            n_we_o    <= '1';
            pass      <= '0';            
            fail      <= '0';
            done_o    <= '0';
            
         when WR_PREP =>  
            slr_data  <= "00000000000000000001";                     
            slr_load  <= '0';
            slr_clk   <= '0';
            addr_o    <= cur_addr;
            data_bi   <= "1010101010101010";
            n_ble_o   <= '0';
            n_bhe_o   <= '0';
            n_oe_o    <= '1';
            n_ce1_o   <= '0';
            ce2_o     <= '1';
            n_we_o    <= '0';
            pass      <= '0';            
            fail      <= '0';
            done_o    <= '0';                       
            
         when WR =>  
            slr_data  <= "00000000000000000001";                     
            slr_load  <= '0';
            slr_clk   <= '0';
            addr_o    <= cur_addr;
            data_bi   <= "1010101010101010";
            n_ble_o   <= '1';
            n_bhe_o   <= '1';
            n_oe_o    <= '1';
            n_ce1_o   <= '1';
            ce2_o     <= '0';
            n_we_o    <= '1';
            pass      <= '0';            
            fail      <= '0';
            done_o    <= '0';
                                    
         when RD0_PREP =>
            slr_data  <= "00000000000000000001";                     
            slr_load  <= '0';
            slr_clk   <= '0';
            addr_o    <= "00000000000000000000";
            data_bi   <= (others => 'Z');
            n_ble_o   <= '0';
            n_bhe_o   <= '0';
            n_oe_o    <= '0';
            n_ce1_o   <= '0';
            ce2_o     <= '1';
            n_we_o    <= '1';
            pass      <= '0';            
            fail      <= '0';
            done_o    <= '0';
            
         when RD0 =>        
            slr_data   <= "00000000000000000001";                     
            slr_load  <= '0';
            slr_clk   <= '0';
            addr_o    <= "00000000000000000000";
            data_bi   <= (others => 'Z');
            n_ble_o   <= '0';
            n_bhe_o   <= '0';
            n_oe_o    <= '0';
            n_ce1_o   <= '0';
            ce2_o     <= '1';
            n_we_o    <= '1';
            pass      <= '0';            
            fail      <= '0';
            done_o    <= '0';
                          
         when RD0_DONE =>        
            slr_data   <= "00000000000000000001";                     
            slr_load  <= '0';
            slr_clk   <= '0';
            addr_o    <= "00000000000000000000";
--            data_bi   <= "1010101010101010";
            n_ble_o   <= '0';
            n_bhe_o   <= '0';
            n_oe_o    <= '1';
            n_ce1_o   <= '1';
            ce2_o     <= '0';
            n_we_o    <= '1';
            pass      <= '0';            
            fail      <= '0';
            done_o    <= '0';
            
         when RD_PREP =>
            slr_data  <= "00000000000000000001";                     
            slr_load  <= '0';
            slr_clk   <= '0';
            addr_o    <= cur_addr;
            data_bi   <= (others => 'Z');
            n_ble_o   <= '0';
            n_bhe_o   <= '0';
            n_oe_o    <= '0';
            n_ce1_o   <= '0';
            ce2_o     <= '1';
            n_we_o    <= '1';
            pass      <= '0';            
            fail      <= '0';
            done_o    <= '0';
            
         when RD =>        
            slr_data   <= "00000000000000000001";                     
            slr_load  <= '0';
            slr_clk   <= '0';
            addr_o    <= cur_addr;
            data_bi   <= (others => 'Z');
            n_ble_o   <= '0';
            n_bhe_o   <= '0';
            n_oe_o    <= '0';
            n_ce1_o   <= '0';
            ce2_o     <= '1';
            n_we_o    <= '1';
            pass      <= '0';            
            fail      <= '0';
            done_o    <= '0';
            
         when RD_DONE =>        
            slr_data   <= "00000000000000000001";                     
            slr_load  <= '0';
            slr_clk   <= '0';
            addr_o    <= cur_addr;
--            data_bi   <= "1010101010101010";
            n_ble_o   <= '1';
            n_bhe_o   <= '1';
            n_oe_o    <= '1';
            n_ce1_o   <= '1';
            ce2_o     <= '0';
            n_we_o    <= '1';
            pass      <= '0';            
            fail      <= '0';
            done_o    <= '0';
         
         when NXT =>
            slr_data   <= "00000000000000000001";  
            if (idx = 19) then
               slr_load <= '1'; 
            else   
               slr_load  <= '0';
            end if;
            slr_clk   <= '1';
            addr_o    <= cur_addr;
--            data_bi   <= "1010101010101010";
            n_ble_o   <= '1';
            n_bhe_o   <= '1';
            n_oe_o    <= '1';
            n_ce1_o   <= '1';
            ce2_o     <= '0';
            n_we_o    <= '1';
            pass      <= '0';            
            fail      <= '0';
            done_o    <= '0';                    
            
         when FAILED=>     
            slr_data  <= "00000000000000000001";                     
            slr_load  <= '0';
            slr_clk   <= '0';
            addr_o    <= cur_addr;
            data_bi   <= (others => 'Z');
            n_ble_o   <= '1';
            n_bhe_o   <= '1';
            n_oe_o    <= '1';
            n_ce1_o   <= '1';
            ce2_o     <= '0';
            n_we_o    <= '1';
            pass      <= '0'; 
            fail      <= '1';
            done_o    <= '1';
         
         when PASSED =>     
            slr_data   <= "00000000000000000001";                     
            slr_load  <= '0';
            slr_clk   <= '0';
            addr_o    <= cur_addr;
            data_bi   <= (others => 'Z');
            n_ble_o   <= '1';
            n_bhe_o   <= '1';
            n_oe_o    <= '1';
            n_ce1_o   <= '1';
            ce2_o     <= '0';
            n_we_o    <= '1';
            pass      <= '1';            
            fail      <= '0';
            done_o    <= '1';
         
                         
                          
      end case;
   end process state_out;
end rtl;
