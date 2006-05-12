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
-- <revision control keyword substitutions e.g. $Id: leds.vhd,v 1.8 2004/10/13 03:56:12 erniel Exp $>
--
-- Project:      SCUBA2
-- Author:		 Bryce Burger
-- Organisation:	UBC
--
-- Description:
-- This file implements the LED functionality
--
-- Revision history:
-- 
-- $Log: leds.vhd,v $
-- Revision 1.8  2004/10/13 03:56:12  erniel
-- minor correction to comments
--
-- Revision 1.7  2004/10/09 09:00:32  erniel
-- removed slave_ctrl submodule
-- removed generic map
-- added new wishbone slave controller
--
--
-- <date $Date: 2004/10/13 03:56:12 $>	-		<text>		- <initials $Author: erniel $>
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
use work.leds_pack.all;

library sys_param;
use sys_param.wishbone_pack.all;

entity leds is
   port(clk_i   : in std_logic;
        rst_i   : in std_logic;		
        
        -- Wishbone signals
        dat_i 	 : in std_logic_vector (WB_DATA_WIDTH-1 downto 0); 
        addr_i  : in std_logic_vector (WB_ADDR_WIDTH-1 downto 0);
        tga_i   : in std_logic_vector (WB_TAG_ADDR_WIDTH-1 downto 0);
        we_i    : in std_logic;
        stb_i   : in std_logic;
        cyc_i   : in std_logic;
        dat_o   : out std_logic_vector (WB_DATA_WIDTH-1 downto 0);
        ack_o   : out std_logic;
      
        -- LED outputs
        power   : out std_logic;
        status  : out std_logic;
        fault   : out std_logic);
end leds;

architecture rtl of leds is

type states is (IDLE, GET_PACKET, SEND_PACKET, DONE);
signal pres_state : states;
signal next_state : states;

signal write_cmd : std_logic;
signal read_cmd  : std_logic;

signal led_data        : std_logic_vector(NUM_LEDS-1 downto 0);
signal led_data_ld     : std_logic;

signal padded_led_data : std_logic_vector(WB_DATA_WIDTH-1 downto 0);

begin

------------------------------------------------------------------------
--
-- LED Wishbone slave controller
--
------------------------------------------------------------------------ 

   state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         pres_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         pres_state <= next_state;
      end if;
   end process state_FF;
  
   state_NS: process(pres_state, write_cmd, read_cmd)
   begin
      case pres_state is
         when IDLE =>        if(write_cmd = '1') then
                                next_state <= GET_PACKET;
                             elsif(read_cmd = '1') then
                                next_state <= SEND_PACKET;
                             else
                                next_state <= IDLE;
                             end if;
                             
         when GET_PACKET =>  next_state <= DONE;
         
         when SEND_PACKET => next_state <= DONE;
         
         when DONE =>        next_state <= IDLE;
      end case;
   end process state_NS;
   
   state_out: process(pres_state, padded_led_data)
   begin
      case pres_state is
         when IDLE =>        led_data_ld <= '0';
                             ack_o       <= '0';
                             dat_o       <= (others => '0');
                             
         when GET_PACKET =>  led_data_ld <= '1';
                             ack_o       <= '1';
                             dat_o       <= (others => '0');
         
         when SEND_PACKET => led_data_ld <= '0';
                             ack_o       <= '1';
                             dat_o       <= padded_led_data;
                             
         when DONE =>        led_data_ld <= '0';
                             ack_o       <= '0';
                             dat_o       <= (others => '0');
      end case;
   end process state_out;


------------------------------------------------------------------------
--
-- Wishbone
--
------------------------------------------------------------------------ 
   
   write_cmd <= '1' when (addr_i = LED_ADDR and stb_i = '1' and cyc_i = '1' and we_i = '1') else '0';
   read_cmd  <= '1' when (addr_i = LED_ADDR and stb_i = '1' and cyc_i = '1' and we_i = '0') else '0';
   
   
------------------------------------------------------------------------
--
-- LED register
--
------------------------------------------------------------------------ 

   led_reg: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         led_data <= "110"; --  yellow: off, green: on, red: off
      elsif(clk_i'event and clk_i = '1') then
         if(led_data_ld = '1') then
            led_data <= led_data xor dat_i(NUM_LEDS-1 downto 0);
         end if;
      end if;
   end process led_reg;
   
   padded_led_data(WB_DATA_WIDTH-1 downto NUM_LEDS) <= (others => '0');
   padded_led_data(NUM_LEDS-1 downto 0) <= led_data;
   
   power  <= led_data(POWER_LED); -- green
   status <= led_data(STATUS_LED); -- yellow
   fault  <= led_data(FAULT_LED); -- red
   
end rtl;