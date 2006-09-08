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

-- sram_test.vhd
--
-- <revision control keyword substitutions e.g. $Id: sram_test.vhd,v 1.3 2005/11/01 00:42:46 mandana Exp $>
--
-- Project:	      SCUBA-2
-- Author:	       Mandana Amiri
-- Organisation:  UBC
--
-- Description:
-- Test U31 and U32 1Mx16 SRAMs on Clock Card.
-- The test procedure is:
-- walking 1 test:
-- write x00 to address 00
-- for address bit 0 to 19
--   write xAA to address X (where only 1 bit is set to 1 in X)
--   read back from address 00
--   read back from address X
-- end loop
-- now walking-0 test:
-- write x00 to address 00
-- for address bit 0 to 19
--   write x55 to address Y (where only 1 bit is set to 0 in Y)
--   read back from address 00
--   read back from address X
-- end loop
-- set fail_o or pass_o accordingly
--
-- Revision history:
-- $Log: sram_test.vhd,v $
-- Revision 1.3  2005/11/01 00:42:46  mandana
-- updated the interface to shift_reg and counter in order to compile rc_test
--
-- Revision 1.2  2004/07/01 00:22:51  mandana
-- Mandana: walking 0/1 tests combined
--
-- Revision 1.1  2004/06/29 18:51:20  mandana
-- Initial release
--
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

--library sys_param;
--use sys_param.wishbone_pack.all;
--use sys_param.data_types_pack.all;

library components;
use components.component_pack.all;
                     
entity sram_test is
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
--     idx_o   : out integer;
     pass_o  : out std_logic;
     fail_o  : out std_logic);
end sram_test;


architecture rtl of sram_test is

-- test state encoding and variables:
type states is (IDLE, WR0_PREP, WR0, WR_PREP, WR, RD0_PREP, RD0, RD0_DONE, RD_PREP, RD, RD_DONE, NXT, FAILED, PASSED, DONE);
signal present_state : states;
signal next_state    : states;

signal slr_en        : std_logic;
signal slr_load      : std_logic;

signal mem_data      : std_logic_vector (15 downto 0);
signal fix_addr      : std_logic_vector(19 downto 0);
signal cur_addr      : std_logic_vector(19 downto 0);
signal walking_addr : std_logic_vector(19 downto 0);

signal slr_filler    : std_logic;
signal idx           : integer range 0 to 20;
signal sel_pattern   : std_logic := '0';
signal passtemp      : std_logic;
signal iteration     : std_logic;

signal dummy         : std_logic;


begin
-- instantiate a shift-left-register for generating walking 1/0 pattern.
   slr_inst : shift_reg 
      generic map (WIDTH => 20)
      port map (
           clk_i      => clk_i,
           rst_i      => rst_i,
           ena_i      => slr_en,
           load_i     => slr_load,
           clr_i      => '0',
           shr_i      => '0',
           serial_i   => slr_filler,
           serial_o   => dummy,
           parallel_i => walking_addr,
           parallel_o => cur_addr
   );     		      

   --sel_pattern <= '0';
   -- index counter to trace the bit location, not really needed since we can find out from 
   -- bit location, ma
   
   idx_count: process (rst_i, clk_i)
   begin
      if (rst_i = '1') then
         idx <= 0;
      elsif (clk_i'event and clk_i = '1') then
         if (slr_en = '1') then
            if (slr_load = '1') then 
               idx <= 0;
            else   
               idx <= idx + 1;
            end if;   
         end if;
      end if;
   end process idx_count;
   
   mem_data     <= "1010101010101010"     when sel_pattern = '0' else "0101010101010101";
   fix_addr     <= "00000000000000000000" when sel_pattern = '0' else "11111111111111111111";
   walking_addr <= "00000000000000000001" when sel_pattern = '0' else "11111111111111111110";
   slr_filler   <= '0'                    when sel_pattern = '0' else '1';

   -- state register:
   state_FF: process(clk_i, rst_i, en_i)
   begin
      if(rst_i = '1' or en_i = '0') then 
         present_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         present_state <= next_state;
      end if;
   end process state_FF;
   
   state_NS: process(present_state, en_i, data_bi, idx, sel_pattern, mem_data)
   begin
      next_state <= present_state;
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
            if (data_bi = "0000000000000000") then
	       next_state <= RD0_DONE;
	    else
	       next_state <= FAILED;
	    end if;   

         when RD0_DONE =>
            next_state <= RD_PREP;
	    
	 when RD_PREP =>
            next_state <= RD;
         
         when RD =>                  
            if (data_bi = mem_data) then
	       next_state <= RD_DONE;
	    else
	       next_state <= FAILED;
	    end if;   
	       
         when RD_DONE =>
            next_state <= NXT;
         
         when NXT =>
            if (idx = 19) then
               next_state <= PASSED;
            else
               next_state <= WR_PREP;
            end if;
         
         when FAILED =>
            next_state <= IDLE;
            
         when PASSED =>    
            if (sel_pattern = '0') then
               next_state <= IDLE;
            else
               next_state <= DONE;
            end if;   
         when DONE =>     
            next_state <= IDLE;

         when others =>   
            next_state <= IDLE;
         
      end case;
   end process state_NS;
   
   state_out: process(present_state, en_i, idx, fix_addr, cur_addr, mem_data)
   begin
      -- default assignments
      slr_load  <= '0';
      slr_en    <= '0';
      addr_o    <= fix_addr;
      data_bi   <= (others => '0');
      addr_o    <= (others => '0');
      n_ble_o   <= '1';
      n_bhe_o   <= '1';
      n_oe_o    <= '1';
      n_ce1_o   <= '1';
      ce2_o     <= '0';
      n_we_o    <= '1';
      passtemp  <= '0';    
      iteration <= '0';
      fail_o    <= '0';
      done_o    <= '0';
      
      case present_state is
         when IDLE =>   
--            if (en_i = '1') then
--               slr_en   <= '1';            
--            else
               slr_en   <= '1';
               slr_load <= '1';
--            end if;
            
         when WR0_PREP =>  
            addr_o    <= fix_addr;
            n_ble_o   <= '0';
            n_bhe_o   <= '0';
            n_ce1_o   <= '0';
            ce2_o     <= '1';
            n_we_o    <= '0';
                  
         when WR0 =>  
            addr_o    <= fix_addr;
            
         when WR_PREP =>  
            addr_o    <= cur_addr;
            data_bi   <= mem_data;
            n_ble_o   <= '0';
            n_bhe_o   <= '0';
            n_ce1_o   <= '0';
            ce2_o     <= '1';
            n_we_o    <= '0';
            
         when WR =>  
            addr_o    <= cur_addr;
            data_bi   <= mem_data;
                                    
         when RD0_PREP =>
            addr_o    <= fix_addr;
            data_bi   <= (others => 'Z');
            n_ble_o   <= '0';
            n_bhe_o   <= '0';
            n_oe_o    <= '0';
            n_ce1_o   <= '0';
            ce2_o     <= '1';
            
         when RD0 =>        
            addr_o    <= fix_addr;
            data_bi   <= (others => 'Z');
            n_ble_o   <= '0';
            n_bhe_o   <= '0';
            n_oe_o    <= '0';
            n_ce1_o   <= '0';
            ce2_o     <= '1';
                          
         when RD0_DONE =>        
            addr_o    <= fix_addr;
--            data_bi   <= "1010101010101010";
--            n_ble_o   <= '0';
--            n_bhe_o   <= '0';
            
         when RD_PREP =>
            addr_o    <= cur_addr;
            data_bi   <= (others => 'Z');
            n_ble_o   <= '0';
            n_bhe_o   <= '0';
            n_oe_o    <= '0';
            n_ce1_o   <= '0';
            ce2_o     <= '1';
            
         when RD =>        
            addr_o    <= cur_addr;
            data_bi   <= (others => 'Z');
            n_ble_o   <= '0';
            n_bhe_o   <= '0';
            n_oe_o    <= '0';
            n_ce1_o   <= '0';
            ce2_o     <= '1';
            
         when RD_DONE =>        
            addr_o    <= cur_addr;
--            data_bi   <= "1010101010101010";
         
         when NXT =>
            if (idx = 19) then
               slr_load  <= '1'; 
            else   
               slr_load  <= '0';
            end if;
            slr_en    <= '1';
            addr_o    <= cur_addr;
            data_bi   <= mem_data;
            
         when FAILED=>     
            addr_o    <= cur_addr;
            data_bi   <= (others => 'Z');
            fail_o    <= '1';
            done_o    <= '1';
         
         when PASSED =>
            addr_o    <= cur_addr;
            data_bi   <= (others => 'Z');
            passtemp  <= '1';            
            iteration <= '1';
            
         when DONE =>
            addr_o    <= cur_addr;
            data_bi   <= (others => 'Z');
            passtemp  <= '1';            
            done_o    <= '1';         

         when others =>   
            slr_en    <= '1';
            slr_load  <= '1';
            addr_o    <= cur_addr;
                                                      
      end case;
   end process state_out;
   
   sel_process: process (rst_i, clk_i)
   begin
      if (rst_i = '1') then
         sel_pattern <= '0';         
      elsif(clk_i'event and clk_i= '1') then 
         if (iteration = '1') then
            sel_pattern <= not sel_pattern;
         else
            sel_pattern <= sel_pattern;
         end if;   
      end if;
   end process;   
   
   pass_o <= passtemp;
--   idx_o  <= idx;
   
end rtl;
