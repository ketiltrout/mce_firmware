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

-- tb_dip_switch.vhd
--
-- <revision control keyword substitutions e.g. $Id: tb_dip_switch.vhd,v 1.2 2004/03/29 21:40:31 erniel Exp $>
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- This file implements the testbench for the DIP switch interface
--
-- Revision history:
-- <date $Date: 2004/03/29 21:40:31 $>	- <initials $Author: erniel $>
-- $Log: tb_dip_switch.vhd,v $
-- Revision 1.2  2004/03/29 21:40:31  erniel
-- added rty_o signal to component
-- added tga_i signal to component
--
--
-----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

library sys_param;
use sys_param.wishbone_pack.all;
use sys_param.general_pack.all;

library work;
use work.dip_switch_pack.all;

entity TB_DIP_SWITCH is
end TB_DIP_SWITCH;

architecture BEH of TB_DIP_SWITCH is

   component DIP_SWITCH
      generic(WIDTH : in integer range 1 to 16 := 4);
      port(dip_switch_i  : in std_logic_vector(WIDTH-1 downto 0);
           clk_i  : in std_logic;
           rst_i  : in std_logic;
           addr_i : in std_logic_vector(WB_ADDR_WIDTH - 1 downto 0);
           dat_i  : in std_logic_vector(WB_DATA_WIDTH - 1 downto 0);
           dat_o  : out std_logic_vector(WB_DATA_WIDTH - 1 downto 0);
           tga_i  : in std_logic_vector(WB_TAG_ADDR_WIDTH - 1 downto 0);
           we_i   : in std_logic;
           stb_i  : in std_logic;
           cyc_i  : in std_logic;
           rty_o  : out std_logic;
           ack_o  : out std_logic);
   end component;


--   constant PERIOD : time :=  20 ns;

   signal W_DIP_SWITCH_I   : std_logic_vector ( 7 downto 0 ) := "10010010";
   signal W_CLK_I          : std_logic := '1';
   signal W_RST_I          : std_logic ;
   signal W_DAT_I          : std_logic_vector ( WB_DATA_WIDTH - 1 downto 0 );
   signal W_ADDR_I         : std_logic_vector ( WB_ADDR_WIDTH - 1 downto 0 );
   signal W_WE_I           : std_logic ;
   signal W_STB_I          : std_logic ;
   signal W_CYC_I          : std_logic ;
   signal W_DAT_O          : std_logic_vector ( WB_DATA_WIDTH - 1 downto 0 );
   signal W_ACK_O          : std_logic ;
   signal W_RTY_O          : std_logic;
   signal W_TGA_I          : std_logic_vector(WB_TAG_ADDR_WIDTH - 1 downto 0);
   
begin

   DUT : DIP_SWITCH
      port map(DIP_SWITCH_I   => W_DIP_SWITCH_I,
               CLK_I          => W_CLK_I,
               RST_I          => W_RST_I,
               DAT_I          => W_DAT_I,
               ADDR_I         => W_ADDR_I,
               WE_I           => W_WE_I,
               STB_I          => W_STB_I,
               CYC_I          => W_CYC_I,
               DAT_O          => W_DAT_O,
               ACK_O          => W_ACK_O,
               RTY_O          => W_RTY_O,
               TGA_I          => W_TGA_I);

   W_CLK_I <= not W_CLK_I after CLOCK_PERIOD/2;

   STIMULI : process
      procedure do_reset is
      begin
         W_RST_I       <= '1';
         W_DAT_I       <= (others => '0');
         W_ADDR_I      <= (others => '0');
         W_WE_I        <= '0';
         W_STB_I       <= '0';
         W_CYC_I       <= '0';
         W_TGA_I       <= (others => '0');
               
         wait for CLOCK_PERIOD*3;
         assert false report "Performing System Reset." severity NOTE;
      end do_reset;
   
      procedure do_read is
      begin
         W_RST_I       <= '0';
         W_DAT_I       <= (others => '0');
         W_ADDR_I      <= DIP_ADDR;
         W_WE_I        <= '0';
         W_STB_I       <= '1';
         W_CYC_I       <= '1';
         W_TGA_I       <= (others => '0');
                        
         wait for CLOCK_PERIOD* 2;
         
         assert false report "Performing Wishbone Read." severity NOTE;
      end do_read;   
      
      procedure do_nop is
      begin
         W_RST_I       <= '0';
         W_DAT_I       <= (others => '0');
         W_ADDR_I      <= (others => '0');
         W_WE_I        <= '0';
         W_STB_I       <= '0';
         W_CYC_I       <= '0';
         W_TGA_I       <= (others => '0');
                        
         wait for CLOCK_PERIOD;
         assert false report "Performing No Operation." severity NOTE;
      end do_nop;
      
   begin
   
   do_reset;
   do_nop;
   do_read;
   do_nop;
   do_nop;
   
--      W_DIP_SWITCH_I   <= (others => '0');
--      W_RST_I          <= '0';
--      W_DAT_I          <= (others => '0');
--      W_ADDR_I         <= (others => '0');
--      W_WE_I           <= '0';
--      W_STB_I          <= '0';
--      W_CYC_I          <= '0';

      wait for CLOCK_PERIOD;
      wait;
   end process STIMULI;

end BEH;
