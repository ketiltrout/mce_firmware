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
-- tb_dispatch_cmd_receive.vhd
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Testbnech for dispatch command receiver and parser
--
-- Revision history:
-- 
-- $Log: tb_dispatch_cmd_receive.vhd,v $
-- Revision 1.3  2004/08/25 20:37:37  erniel
-- updated dispatch_cmd_receive port declaration
--
-- Revision 1.2  2004/08/10 00:37:47  erniel
-- initial version
--
--
-----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

library work;
use work.dispatch_pack.all;

entity TB_DISPATCH_CMD_RECEIVE is
end TB_DISPATCH_CMD_RECEIVE;

architecture BEH of TB_DISPATCH_CMD_RECEIVE is

   component DISPATCH_CMD_RECEIVE

      port(CLK_I        : in std_logic ;
           COMM_CLK_I   : in std_logic ;
           RST_I        : in std_logic ;
           LVDS_CMD_I   : in std_logic ;
           CARD_I       : in std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0) ;
           CMD_RDY_O    : out std_logic ;
           CMD_ERR_O    : out std_logic ;
           HEADER0_O    : out std_logic_vector ( PACKET_WORD_WIDTH - 1 downto 0 );
           HEADER1_O    : out std_logic_vector ( PACKET_WORD_WIDTH - 1 downto 0 );
           BUF_DATA_O   : out std_logic_vector ( BUF_DATA_WIDTH - 1 downto 0 );
           BUF_ADDR_O   : out std_logic_vector ( BUF_ADDR_WIDTH - 1 downto 0 );
           BUF_WREN_O   : out std_logic );

   end component;

   component LVDS_TX
      port(CLK_I        : in std_logic ;
           RST_I        : in std_logic ;
           DAT_I        : in std_logic_vector ( 31 downto 0 );
           RDY_I        : in std_logic ;
           BUSY_O       : out std_logic ;
           LVDS_O       : out std_logic );

   end component;


   constant PERIOD : time := 32 ns;
   constant COMM_PERIOD : time := 4 ns;
   
   signal W_CLK_I         : std_logic := '1';
   signal W_COMM_CLK_I    : std_logic := '1';
   signal W_RST_I         : std_logic ;
   signal W_CMD_RDY_O     : std_logic ;
   signal W_CMD_ERR_O     : std_logic ;
   signal W_HEADER0_O     : std_logic_vector ( PACKET_WORD_WIDTH - 1 downto 0 );
   signal W_HEADER1_O     : std_logic_vector ( PACKET_WORD_WIDTH - 1 downto 0 );
   signal W_BUF_DATA_O    : std_logic_vector ( BUF_DATA_WIDTH - 1 downto 0 );
   signal W_BUF_ADDR_O    : std_logic_vector ( BUF_ADDR_WIDTH - 1 downto 0 );
   signal W_BUF_WREN_O    : std_logic ;
   signal W_DAT_I         : std_logic_vector ( 31 downto 0 );
   signal W_LVDS_START_I  : std_logic ;
   signal W_LVDS_DONE_O   : std_logic ;
   signal W_LVDS_CMD      : std_logic ;         

begin

   DUT : DISPATCH_CMD_RECEIVE

      port map(CLK_I        => W_CLK_I,
               COMM_CLK_I   => W_COMM_CLK_I,
               RST_I        => W_RST_I,
               LVDS_CMD_I   => W_LVDS_CMD,
               CARD_I       => "00000011",   -- RC1
               CMD_RDY_O    => W_CMD_RDY_O,
               CMD_ERR_O    => W_CMD_ERR_O,
               HEADER0_O    => W_HEADER0_O,
               HEADER1_O    => W_HEADER1_O,
               BUF_DATA_O   => W_BUF_DATA_O,
               BUF_ADDR_O   => W_BUF_ADDR_O,
               BUF_WREN_O   => W_BUF_WREN_O);

   TX : LVDS_TX
      port map(CLK_I        => W_CLK_I,
               RST_I        => W_RST_I,
               DAT_I        => W_DAT_I,
               RDY_I      => W_LVDS_START_I,
               BUSY_O       => W_LVDS_DONE_O,
               LVDS_O       => W_LVDS_CMD);

   
   W_CLK_I <= not W_CLK_I after PERIOD/2;
   W_COMM_CLK_I <= not W_COMM_CLK_I after COMM_PERIOD/2;
   
   STIMULI : process
   procedure reset is
   begin
      W_RST_I         <= '1';
      W_DAT_I         <= (others => '0');
      W_LVDS_START_I  <= '0';
      
      wait for PERIOD*200;
      
   end reset;
   
   procedure transmit (data : in std_logic_vector(31 downto 0)) is
   begin
      W_RST_I         <= '0';
      W_DAT_I         <= data;
      W_LVDS_START_I  <= '1';
      
      wait for PERIOD;
      
      W_RST_I         <= '0';
      W_LVDS_START_I  <= '0';
      
      wait until W_LVDS_DONE_O = '1';

      wait for PERIOD*2;
   
   end transmit;
   
   procedure pause (length : in integer) is
   begin
      wait for PERIOD*length;
      
   end pause;
   
   begin
      
      reset;
      
      transmit("10101010101010100000000000000001");  -- 1 data word
      transmit("00000000000000000000000000000000");  -- for no card
      transmit("00000000000000000000000000000000");  -- 0x00000000
      transmit("01010100010101011101111000000101");  -- 0x5455DE05
      
      pause(100);
      
      transmit("10101010101010100000000000000011");  -- 3 data words  (simulates receiver out-of-sync)
      transmit("00000010010100110000000100000001");  -- for CC
      transmit("00001100000110100101010100011100");  -- 0x0C1A551C
      transmit("00000000000000001100000011011110");  -- 0x0000C0DE
      transmit("01111110010101011001000000000110");  -- 0x7E559006
            
      pause(200);
      
      -- this packet is skipped:
      transmit("10101010101010100000000000000011");  -- 3 data words
      transmit("00000111001000000000000000000000");  -- for BC1
      transmit("00000000000000000000000000001010");  -- 0x0000000A
      transmit("00000000000000001101111010101111");  -- 0x0000DEAF
      transmit("00000000110010101011101100011110");  -- 0x00CABB1E
      transmit("01110010011010111110010111111111");  -- 0x726BE5FF
      
      pause(50);
      
      transmit("10101010101010100000000000000001");  -- 1 data word
      transmit("00001100000011110001000000010001");  -- for all BCs
      transmit("00000000000000001111101010110101");  -- 0x0000FAB5
      transmit("00100101110000110110010000000100");  -- 0x25C36404
      
      pause(100);
      
      assert FALSE report "End of simulation." severity FAILURE;
      
      wait for PERIOD;
      wait;
   end process STIMULI;

end BEH;