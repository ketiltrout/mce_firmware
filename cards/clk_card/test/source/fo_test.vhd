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
-- 
--
-- Project:	      SCUBA-2
-- Author:	      Mandana Amiri
-- 
-- Organisation:  UBC
--
-- Description:
-- fibre_test file.  With the loopback cable on, this test sends 3 data
-- patterns to the transmitter chip (U20) and then this data can be verified
-- on the scope on the receiver side.
--
-- Revision history:
-- <date $Date: 2005/10/28 19:04:37 $>	- <initials $Author: mandana $>
-- $Log: fo_test.vhd,v $
-- Revision 1.3  2005/10/28 19:04:37  mandana
-- Updated for Rev. B Clock_card tcl file
-- signal name changes, more pins added for fibre interface to enable bist functionality.
-- BIST functionality not covered yet
-- rxrefclk is now generated through the PLL
--
-- Revision 1.2  2004/10/22 03:57:49  erniel
-- replaced "test" port with "mictor" port
-- connected fibre receive ports to debug mictor
--
-- Revision 1.1  2004/06/10 16:52:14  mandana
-- initial release: stand-alone fibre test
--
-----------------------------------------------------------------------------

library ieee, sys_param, components, work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--use components.component_pack.all;

-----------------------------------------------------------------------------

entity fo_bist is
   port(
      n_rst : in std_logic;
      
      -- clock signals
      inclk14  : in std_logic;
--      outclk   : out std_logic;
      
      -- fibre pins
      fibre_tx_data   : out std_logic_vector(7 downto 0);
      fibre_tx_clkW   : out std_logic;
      fibre_tx_ena    : out std_logic;
      fibre_tx_rp     : in std_logic;
      fibre_tx_sc_nd  : out std_logic;
      fibre_tx_enn    : out std_logic;
      -- fibre_tx_svs is tied to gnd on board
      -- fibre_tx_enn is tied to vcc on board
      -- fibre_tx_mode is tied to gnd on board
      fibre_tx_foto   : out std_logic;
      fibre_tx_bisten : out std_logic;
      
      fibre_rx_data   : in std_logic_vector(7 downto 0);
      fibre_rx_refclk : out std_logic;
      fibre_rx_error  : in std_logic;
      fibre_rx_rdy    : in std_logic;
      fibre_rx_status : in std_logic;
      fibre_rx_sc_nd  : in std_logic;
      fibre_rx_rvs    : in std_logic;
      fibre_rx_rf     : out std_logic; --  is tied to vcc on board, we lifted the pin and routed it to P10.22
      fibre_rx_a_nb   : out std_logic;
      fibre_rx_bisten : out std_logic;
      
      --dip switch
      dip_sw2      : in std_logic;
      dip_sw3      : in std_logic;
      
      --test pins
      mictor : out std_logic_vector(12 downto 1));
end fo_bist;
                     
architecture rtl of fo_bist is
   signal clk       : std_logic;
   signal fibre_tx_data_prereg : std_logic_vector(7 downto 0);
   signal fibre_tx_ena_prereg  : std_logic;

   -- state signals
   type states is (TX_DATA1, TX_EN1,TX_DATA2, TX_EN2, TX_DATA3, TX_EN3);
   signal present_state : states;
   signal next_state    : states;
    

component cc_pll
   port(
      inclk0 : in std_logic;
      e2     : out std_logic;
      c0     : out std_logic;
      c1     : out std_logic;
      c2     : out std_logic;
      c3     : out std_logic;
      e0     : out std_logic;
      e1     : out std_logic 
   );
end component;

   
begin

  fibre_pll: cc_pll
  port map(
         inclk0 => inclk14,
         c0     => open,
         c1     => open,
         c2     => open,
         c3     => clk,
         e0     => fibre_tx_clkW, 
         e1     => fibre_rx_refclk,   
         e2     => open 
      );
  
      
  fibre_tx_bisten <= '1';
--  fibre_tx_ena <= '1';
  fibre_tx_enn    <= 'Z';
  fibre_tx_foto   <= 'Z';
  fibre_rx_bisten <= '1';
  fibre_rx_a_nb   <= '1';
  fibre_rx_rf     <= '1';
  fibre_tx_sc_nd <= '0';
--  test(19) <= '1'; --fibre_tx_nbist;
--  test(20) <= '1'; -- fibre_rx_nbist;
--  test(22) <= '1';
--  test(24) <= fibre_rx_rdy;
--  test(11) <= '1';
--  test(12) <= '1';
--  test(25) <= '1';
--  test(26) <= '1';

   mictor(8 downto 1) <= fibre_rx_data;
   mictor(9) <=  fibre_rx_rdy;
   mictor(10) <= fibre_rx_status;
   mictor(11) <= fibre_rx_sc_nd;
   mictor(12) <= fibre_rx_rvs;

   state_FF: process(clk, n_rst)
   begin
      if(n_rst = '1') then 
         present_state <= TX_DATA1;
      elsif(clk'event and clk = '1') then
         present_state <= next_state;
      end if;
   end process state_FF;
---------------------------------------------------------------   
   state_NS: process(present_state)
   begin
      next_state <= present_state;
      case present_state is
         when TX_DATA1 =>     
            next_state <= TX_EN1;
               
         when TX_EN1 =>
            next_state  <= TX_DATA2; 
            
         when TX_DATA2 =>
            next_state  <= TX_EN2;                  
            
         when TX_EN2 =>
            next_state  <= TX_DATA3; 

         when TX_DATA3 =>
            next_state  <= TX_EN3;                  
            
         when TX_EN3 =>
            next_state  <= TX_DATA1; 
         
         when others => 
            next_state  <= TX_DATA1;
                                    
      end case;
   end process state_NS;
-----------------------------------------------------------------   
   state_out: process(present_state)
   begin
      -- default states
      fibre_tx_data_prereg  <= "00000000";
      fibre_tx_ena_prereg   <= '1';    
      
      case present_state is
         when TX_DATA1 =>     
            fibre_tx_data_prereg  <= "00000000";
            fibre_tx_ena_prereg   <= '1';               
         
         when TX_EN1 =>   
            fibre_tx_data_prereg  <= "00000000";
            fibre_tx_ena_prereg   <= '0';               

         when TX_DATA2 =>     
            fibre_tx_data_prereg  <= "11111111";
            fibre_tx_ena_prereg   <= '1';               
         
         when TX_EN2 =>   
            fibre_tx_data_prereg  <= "11111111";
            fibre_tx_ena_prereg   <= '0';               

         when TX_DATA3 =>     
            fibre_tx_data_prereg  <= "00000000";
            fibre_tx_ena_prereg   <= '1';               
         
         when TX_EN3 =>   
            fibre_tx_data_prereg  <= "00000000";
            fibre_tx_ena_prereg   <= '0';  
            
         when others =>
            null;
	                              
      end case;
   end process state_out;

   tx_reg: process(clk, n_rst)
   begin
      if(n_rst = '1') then 
         fibre_tx_data <= "11111111";
         fibre_tx_ena <= '1';
      elsif(clk'event and clk = '1') then
         fibre_tx_data <= fibre_tx_data_prereg;
         fibre_tx_ena <= fibre_tx_ena_prereg;
      end if;
   end process tx_reg;

    
end rtl;