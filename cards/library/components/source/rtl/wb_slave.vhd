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
-- wb_slave.vhd
--
-- Project:	      SCUBA-2
-- Author:        Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Implementation of the wishbone slave interface.
--
-- Revision history:
-- 
-- $Log$
--
-----------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library components;
use components.component_pack.all;

library sys_param;
use sys_param.wishbone_pack.all;

entity wb_slave is
generic(SLAVE_ADDR : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0));
port(clk_i  : in std_logic;
     rst_i  : in std_logic;
     dat_i  : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
     addr_i : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
     tga_i  : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
     we_i   : in std_logic;
     stb_i  : in std_logic;
     cyc_i  : in std_logic;
     dat_o 	: out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
     ack_o  : out std_logic);
end wb_slave;

architecture behav of wb_slave is
   
signal random0    : std_logic_vector(39 downto 0);
signal slave_rdy  : std_logic;

type regfile is array(15 downto 0) of std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal slave_reg : regfile;
   
begin

   -----------------------------------------------------------
   -- Slave readiness randomizer
   -----------------------------------------------------------
   
   wb_randomizer0: lfsr
      generic map(WIDTH => 40)
      port map(clk_i  => clk_i,
               rst_i  => rst_i,
               ena_i  => '1',
               load_i => '0',
               clr_i  => '0',
               lfsr_i => (others => '0'),
               lfsr_o => random0);       
   
   slave_rdy  <= '1' when (random0(2) = '1' and addr_i = SLAVE_ADDR) else '0';
   
   
   -----------------------------------------------------------
   -- Slave model
   -----------------------------------------------------------
          
   write_model: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         slave_reg(0)  <= (others => '0');
         slave_reg(1)  <= (others => '0');
         slave_reg(2)  <= (others => '0');
         slave_reg(3)  <= (others => '0');
         slave_reg(4)  <= (others => '0');
         slave_reg(5)  <= (others => '0');
         slave_reg(6)  <= (others => '0');
         slave_reg(7)  <= (others => '0');
         slave_reg(8)  <= (others => '0');
         slave_reg(9)  <= (others => '0');
         slave_reg(10) <= (others => '0');
         slave_reg(11) <= (others => '0');
         slave_reg(12) <= (others => '0');
         slave_reg(13) <= (others => '0');
         slave_reg(14) <= (others => '0');
         slave_reg(15) <= (others => '0');
      elsif(clk_i'event and clk_i = '1') then
         if(slave_rdy = '1') then
            if(cyc_i = '1' and stb_i = '1') then
               if(we_i = '1') then   -- write cycle
                  slave_reg(conv_integer(tga_i)) <= dat_i;  
               end if;
            end if;
         end if;
      end if;
   end process write_model;
   
   read_model: process(slave_rdy, cyc_i, stb_i, we_i, tga_i)
   begin
      if(slave_rdy = '1') then
         if(cyc_i = '1' and stb_i = '1') then
            if(we_i = '0') then   -- read cycle
               dat_o <= slave_reg(conv_integer(tga_i));
            end if;
         end if;
      end if;
   end process read_model;
   
   ack_o <= (cyc_i and stb_i) when slave_rdy = '1' else '0';

end behav;