-- Copyright (c) 2003 SCUBA-2 Project
--               All Rights Reserved
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
-- <Title>
--
-- <revision control keyword substitutions e.g. $Id: array_id.vhd,v 1.1 2004/03/05 22:38:35 jjacob Exp $>
--
-- Project:		Scuba 2
-- Author:		Jonathan Jacob
-- Organisation:	UBC
--
-- Description:
-- This file implements the Array ID functionality
--
-- Revision history:
-- <date $Date: 2004/03/05 22:38:35 $>	-		<text>		- <initials $Author: jjacob $>
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
use work.array_id_pack.all;

library sys_param;
use sys_param.wishbone_pack.all;

library components;
use components.component_pack.all;

entity array_id is
   generic (
      ARRAY_ID_ADDR       : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := ARRAY_ID_ADDR;
      ARRAY_ID_ADDR_WIDTH : integer := WB_ADDR_WIDTH;
      ARRAY_ID_DATA_WIDTH : integer := WB_DATA_WIDTH;
      TAG_ADDR_WIDTH : integer := WB_TAG_ADDR_WIDTH
   );
   port (   
      array_id_i : in std_logic_vector (ARRAY_ID_BITS-1 downto 0);   
      -- wishbone signals
      clk_i   : in std_logic;
      rst_i   : in std_logic;		
      dat_i 	 : in std_logic_vector (WB_DATA_WIDTH-1 downto 0); -- not used since not writing to array ID
      addr_i  : in std_logic_vector (WB_ADDR_WIDTH-1 downto 0);
      tga_i   : in std_logic_vector (TAG_ADDR_WIDTH-1 downto 0);
      we_i    : in std_logic;
      stb_i   : in std_logic;
      cyc_i   : in std_logic;
      dat_o   : out std_logic_vector (WB_DATA_WIDTH-1 downto 0);
      rty_o   : out std_logic;
      ack_o   : out std_logic 
   );
end array_id;

architecture rtl of array_id is

-- internal signals
signal array_id_reg : std_logic_vector (ARRAY_ID_BITS-1 downto 0);
signal array_id_valid : std_logic;
signal slave_wr_ready_sig : std_logic;
signal padded_array_id_reg : std_logic_vector (WB_DATA_WIDTH-1 downto 0);
signal no_connect : std_logic_vector (WB_DATA_WIDTH-1 downto 0);
signal no_connect2 : std_logic;
signal slave_retry : std_logic;

begin

------------------------------------------------------------------------
--
-- Read array ID
--
------------------------------------------------------------------------

   process (clk_i, rst_i)
   begin
      if rst_i = '1' then
         array_id_reg <= "000";
         array_id_valid <= '0';
      elsif clk_i'event and clk_i = '1' then
         array_id_reg <= array_id_i;
         array_id_valid <= '1';
      end if;     
   end process;
   
   slave_wr_ready_sig <= '0'; -- never ready since can't write to array ID
   slave_retry <= '0';
   
------------------------------------------------------------------------
--
-- Wishbone
--
------------------------------------------------------------------------ 

   padded_array_id_reg(WB_DATA_WIDTH-1 downto ARRAY_ID_BITS) <= (others => '0');
   padded_array_id_reg(ARRAY_ID_BITS-1 downto 0) <= array_id_reg;
   
   array_id_slave_ctrl : slave_ctrl
   generic map (
      SLAVE_SEL  => ARRAY_ID_ADDR,
      ADDR_WIDTH => ARRAY_ID_ADDR_WIDTH,
      DATA_WIDTH => ARRAY_ID_DATA_WIDTH,
      TAG_ADDR_WIDTH => TAG_ADDR_WIDTH)
   port map (
      slave_wr_ready        => slave_wr_ready_sig, -- can't write to the array ID
      slave_rd_data_valid   => array_id_valid,
      slave_retry           => slave_retry,
      master_wr_data_valid  => no_connect2,
      slave_ctrl_dat_i      => padded_array_id_reg,
      slave_ctrl_dat_o      => no_connect,
      clk_i                 => clk_i,
      rst_i                 => rst_i,
      dat_i                 => dat_i,
      addr_i                => addr_i,
      tga_i                 => tga_i,
      we_i                  => we_i,
      stb_i                 => stb_i,
      cyc_i                 => cyc_i,
      dat_o                 => dat_o,
      rty_o                 => rty_o,
      ack_o                 => ack_o
   );

end rtl;
