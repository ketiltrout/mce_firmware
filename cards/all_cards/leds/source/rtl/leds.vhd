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
-- <revision control keyword substitutions e.g. $Id: leds.vhd,v 1.5 2004/03/06 01:14:27 bburger Exp $>
--
-- Project:		SCUBA2
-- Author:		Bryce Burger
-- Organisation:	UBC
--
-- Description:
-- This file implements the Array ID functionality
--
-- Revision history:
-- <date $Date: 2004/03/06 01:14:27 $>	-		<text>		- <initials $Author: bburger $>
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
--use work.slave_ctrl_pack.all;
use work.leds_pack.all;

library sys_param;
use sys_param.wishbone_pack.all;

library components;
use components.component_pack.all;


entity leds is
   generic (
      SLAVE_SEL  : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := (others => '0');
      ADDR_WIDTH : integer := WB_ADDR_WIDTH;
      DATA_WIDTH : integer := WB_DATA_WIDTH;
      TAG_ADDR_WIDTH : integer := WB_TAG_ADDR_WIDTH
   );
   port (   
      -- Wishbone signals
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
      ack_o   : out std_logic;
      
      -- LED outputs
      power_ok : out std_logic;
      status : out std_logic;
      fault : out std_logic;
      spare : out std_logic
   );
end leds;

architecture rtl of leds is

-- internal signals
signal slave_wr_ready_sig : std_logic;
signal slave_rd_data_valid_sig : std_logic;
signal slave_wr_data_valid_sig : std_logic;
signal leds_reg : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal dat_i_leds : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal slave_retry_sig : std_logic;

begin

------------------------------------------------------------------------
--
--  LED control block
--
------------------------------------------------------------------------

   process (clk_i, rst_i)
   begin
      if rst_i = '1' then
         leds_reg(WB_DATA_WIDTH-1 downto 0) <= (others => '0');
      elsif clk_i'event and clk_i = '1' then
         if slave_wr_data_valid_sig = '1' then
            -- LEDs get new data
            -- LEDs will receive new data using a byte
            -- The 4 MSB will designate which LEDs are being accessed
            -- The 4 LSB will designate the new values which the LEDs are to receive
            -- The groups of 4 bits will be in the order (from MSB to LSB) of power_ok, status, fault, spare
            -- slave_wr_data_valid_sig is a constant signal during the time that the data on bus is valid
            -- slave_ctrl takes care of determining if this block as been addressed or not
            L1: for i in 1 to LEDS_BITS loop
               if dat_i_leds(2*LEDS_BITS - i) = '1' then
                  leds_reg(LEDS_BITS - i) <= dat_i_leds(LEDS_BITS - i);
               end if;
            end loop L1;
         end if;
      end if;     
   end process;
  
   -- The LED register value constantly drives the LEDs
   power_ok <= leds_reg(LEDS_BITS-1);
   status <= leds_reg(LEDS_BITS-2);
   fault <= leds_reg(LEDS_BITS-3);
   spare <= leds_reg(LEDS_BITS-4);
   
   -- LED register is always ready to be written to
   slave_wr_ready_sig <= '1';
   -- LED register data is always valid, and therefore can always be read 
   slave_rd_data_valid_sig <= '1';
   -- LED block doesn't ever need to stop a read/write cycle
   slave_retry_sig <= '0'; 
   
------------------------------------------------------------------------
--
-- Wishbone
--
------------------------------------------------------------------------ 

   leds_slave_ctrl : slave_ctrl
   generic map (
      SLAVE_SEL  => BIT_STATUS_ADDR,
      ADDR_WIDTH => WB_ADDR_WIDTH,
      DATA_WIDTH => WB_DATA_WIDTH,
      TAG_ADDR_WIDTH => TAG_ADDR_WIDTH
   )
   port map (
      slave_wr_ready        => slave_wr_ready_sig,
      slave_rd_data_valid   => slave_rd_data_valid_sig,
      slave_retry           => slave_retry_sig,
      master_wr_data_valid  => slave_wr_data_valid_sig,
      slave_ctrl_dat_i      => leds_reg,
      slave_ctrl_dat_o      => dat_i_leds,
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