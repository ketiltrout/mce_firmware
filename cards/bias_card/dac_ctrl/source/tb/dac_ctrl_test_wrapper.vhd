---------------------------------------------------------------------
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
-- <revision control keyword substitutions e.g. $Id: dac_ctrl_test_wrapper.vhd,v 1.3 2004/04/29 20:53:59 mandana Exp $>

--
-- Project:	      SCUBA-2
-- Author:	      Mandana Amiri
-- 
-- Organisation:  UBC
--
-- Description:
-- dac_ctrl test wrapper file.  This file instanstiates the dac_ctrl
-- and emulates the master (command FSM, for example) on the wishbone bus.
-- when enabled, same value is loaded to lvds DAC and 32 DACs simultaneously.
-- The next enable signal would load another set of values to the DACs. overall
-- 5 different set of values are loaded.
--
-- Revision history:
-- <date $Date: 2004/04/29 20:53:59 $>	- <initials $Author: mandana $>
-- $Log: dac_ctrl_test_wrapper.vhd,v $
-- Revision 1.3  2004/04/29 20:53:59  mandana
-- added dac_nclr signal and removed tx signals from wrapper
--
-- Revision 1.2  2004/04/23 00:52:12  mandana
-- fixed ack timing, dac_count_clk now counts the acks
--
-- Revision 1.1  2004/04/21 16:52:51  mandana
-- Initial release
--
--
-----------------------------------------------------------------------------

library ieee, sys_param, components, work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use sys_param.wishbone_pack.all;
use sys_param.frame_timing_pack.all;
use sys_param.data_types_pack.all;
use components.component_pack.all;
use work.dac_ctrl_pack.all;

-----------------------------------------------------------------------------
                     
entity dac_ctrl_test_wrapper is
   port (
      -- basic signals
      rst_i     : in std_logic;    -- reset input
      clk_i     : in std_logic;    -- clock input
      en_i      : in std_logic;    -- enable signal
      done_o    : out std_logic;   -- done ouput signal
      
      -- transmitter signals removed!
                
      -- extended signals
      dac_dat_o : out std_logic_vector (31 downto 0); 
      dac_ncs_o : out std_logic_vector (31 downto 0); 
      dac_clk_o : out std_logic_vector (31 downto 0);

      dac_nclr_o: out std_logic;
      
      lvds_dac_dat_o: out std_logic;
      lvds_dac_ncs_o: out std_logic;
      lvds_dac_clk_o: out std_logic
      
   );   
end;  

---------------------------------------------------------------------

architecture rtl of dac_ctrl_test_wrapper is

   -- state definitions
   type states is (IDLE, DAC32, DAC32_NXT, LVDS_DAC, LVDS_DONE, DONE);
   signal present_state  : states;
   signal next_state     : states;

   -- wishbone "emulated master" signals
   signal addr_o   : std_logic_vector (WB_ADDR_WIDTH-1 downto 0);
   signal tga_o    : std_logic_vector (WB_TAG_ADDR_WIDTH-1 downto 0);
   signal dat_o    : std_logic_vector (WB_DATA_WIDTH-1 downto 0); 
   signal dat_i    : std_logic_vector (WB_DATA_WIDTH-1 downto 0);
   signal we_o     : std_logic;  
   signal stb_o    : std_logic;
   signal ack_i    : std_logic;
   signal rty_i    : std_logic;
   signal cyc_o    : std_logic;  
   
   signal sync_i   : std_logic;
   signal idac     : integer;
   signal idx      : integer;
   type   w_array4 is array (4 downto 0) of word32; 
   signal data     : w_array4;
   signal val_clk  : std_logic;
   signal dac_count_clk: std_logic;
   signal idac_rst : std_logic;
     
begin

-- instantiate a counter for idac to go through all 32 DACs
   dac_count: counter
   generic map(MAX => 16)
   port map(clk_i   => dac_count_clk,
            rst_i   => idac_rst,
            ena_i   => '1',
            load_i  => '0',
            down_i  => '0',
            count_i => 0 ,
            count_o => idac);
   
-- instantiate a counter for idx to go through different values    
   idx_count: counter
   generic map(MAX => 4)
   port map(clk_i   => val_clk,
            rst_i   => rst_i,
            ena_i   => '1',
            load_i  => '0',
            down_i  => '0',
            count_i =>  0,
            count_o => idx);

------------------------------------------------------------------------
--
-- instantiate the dac_ctrl
--
------------------------------------------------------------------------
      dac_ctrl_test : dac_ctrl
      generic map(DAC32_CTRL_ADDR      => FLUX_FB_ADDR ,
                  DAC_LVDS_CTRL_ADDR   => BIAS_ADDR )

      port map(dac_data_o (31 downto 0) => dac_dat_o (31 downto 0),
               dac_data_o (32) => lvds_dac_dat_o,
               
               dac_ncs_o (31 downto 0)  => dac_ncs_o (31 downto 0),
               dac_ncs_o (32)           => lvds_dac_ncs_o,
               
               dac_clk_o (31 downto 0)  => dac_clk_o (31 downto 0),
               dac_clk_o (32)           => lvds_dac_clk_o,
               
               dac_nclr_o   => dac_nclr_o,
               clk_i        => clk_i,
               rst_i        => rst_i,
               dat_i        => dat_o,
               addr_i       => addr_o,
               tga_i        => tga_o,
               we_i         => we_o,
               stb_i        => stb_o,
               cyc_i        => cyc_o,
               dat_o        => dat_i,
               rty_o        => rty_i,
               ack_o        => ack_i,
               sync_i       => sync_i);
                               
   data (0) <= "00000000000000000000000000000000";--00000000
   data (1) <= "01010101010101010101010100000101";--55555055
   data (2) <= "11110000001100110100000000000101";--f0334005
   data (3) <= "11101110111011101110111011101110";--eeeeeeee
   data (4) <= "11111111111111111111111111111111";--ffffffff

   -- state register:
   state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then 
         present_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         present_state <= next_state;
      end if;
   end process state_FF;
---------------------------------------------------------------   
   state_NS: process(present_state, en_i, ack_i, idac)
   begin
      case present_state is
         when IDLE =>     
            if(en_i = '1') then
               next_state <= DAC32;
            else
               next_state <= IDLE;
            end if;
                
         when DAC32 =>  
            if (ack_i = '0') then
               next_state <= DAC32;
            else 
               next_state <= DAC32_NXT;
            end if;
                       
         when DAC32_NXT =>  
            if (idac = 16) then 
              next_state <= LVDS_DAC;
            else  
               next_state <= DAC32;
            end if;
            
         when LVDS_DAC =>     
            if (ack_i = '0') then
               next_state <= LVDS_DAC;
            else   
               next_state <= LVDS_DONE;
            end if;
            
         when LVDS_DONE =>              
            next_state <= DONE;
             
         when DONE =>     
            next_state <= IDLE;
                 
      end case;
   end process state_NS;
-----------------------------------------------------------------   
   state_out: process(present_state, data, idx, idac)
   begin
      case present_state is
         when IDLE =>     
            idac_rst  <= '1';
            addr_o    <= (others => '0');
	    tga_o     <= (others => '0');
	    dat_o     <= (others => '0');
	    we_o      <= '0';
	    stb_o     <= '0';
	    cyc_o     <= '0';                          
--	    tx_data_o <= (others => '0');
--	    tx_we_o   <= '0';
--	    tx_stb_o  <= '0';
	    done_o    <= '0';
         
         when DAC32 =>    
            idac_rst  <= '0';
            addr_o    <= FLUX_FB_ADDR;
	    tga_o     <= (others => '0');
	    dat_o     <= data(idx);
            we_o      <= '1';
  	    stb_o     <= '1';
	    cyc_o     <= '1';                           
	    done_o    <= '0';
                          
         when DAC32_NXT =>    
            idac_rst  <= '0';
	    tga_o     <= (others => '0');
	    dat_o     <= (others => '0');
	    if (idac = 16) then
               addr_o    <= (others => '0');
	       we_o      <= '0';
	       stb_o     <= '0';
	       cyc_o     <= '0';       
	    else	    
               addr_o    <= FLUX_FB_ADDR;
	       we_o      <= '1';
	       stb_o     <= '0';
	       cyc_o     <= '1';      	       
	    end if;   
	    done_o    <= '0';
                                                    
         when LVDS_DAC =>
            idac_rst  <= '1';
            addr_o    <= BIAS_ADDR;
	    tga_o     <= (others => '0');
	    dat_o     <= data(idx);
	    we_o      <= '1';
	    stb_o     <= '1';
	    cyc_o     <= '1';                          
	    done_o    <= '0';
         
         when LVDS_DONE =>
            idac_rst  <= '1';
            addr_o    <= BIAS_ADDR;
	    tga_o     <= (others => '0');
	    dat_o     <= data(idx);
	    we_o      <= '0';
	    stb_o     <= '0';
	    cyc_o     <= '0';                          
	    done_o    <= '0';
                  
         when DONE =>     
            idac_rst  <= '1';
            addr_o    <= (others => '0');
	    tga_o     <= (others => '0');
	    dat_o     <= (others => '0');
	    we_o      <= '0';
	    stb_o     <= '0';
	    cyc_o     <= '0';                          
	    done_o    <= '1';
                          
      end case;
   end process state_out;
   val_clk <= '1' when idac = 16 and addr_o = x"20" else '0';
   dac_count_clk <= '1' when ack_i = '1' else '0';
 end;