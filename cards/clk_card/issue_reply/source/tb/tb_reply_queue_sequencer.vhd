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
-- tb_reply_queue_sequencer.vhd
--
-- Project:	      SCUBA-2
-- Author:        Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Testbench for matching logic for reply queue.
--
-- Revision history:
-- 
-- $Log$
--
-----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

library sys_param;
use sys_param.command_pack.all;

entity TB_REPLY_QUEUE_SEQUENCER is
end TB_REPLY_QUEUE_SEQUENCER;

architecture BEH of TB_REPLY_QUEUE_SEQUENCER is

   component REPLY_QUEUE_SEQUENCER
      port(CLK_I          : in std_logic ;
           RST_I          : in std_logic ;
           
           AC_DATA_I      : in std_logic_vector ( 31 downto 0 );
           AC_RDY_I       : in std_logic ;
           AC_ACK_O       : out std_logic ;
           AC_DISCARD_O   : out std_logic ;
           
           BC1_DATA_I     : in std_logic_vector ( 31 downto 0 );
           BC1_RDY_I      : in std_logic ;
           BC1_ACK_O      : out std_logic ;
           BC1_DISCARD_O  : out std_logic ;
           
           BC2_DATA_I     : in std_logic_vector ( 31 downto 0 );
           BC2_RDY_I      : in std_logic ;
           BC2_ACK_O      : out std_logic ;
           BC2_DISCARD_O  : out std_logic ;
           
           BC3_DATA_I     : in std_logic_vector ( 31 downto 0 );
           BC3_RDY_I      : in std_logic ;
           BC3_ACK_O      : out std_logic ;
           BC3_DISCARD_O  : out std_logic ;
           
           RC1_DATA_I     : in std_logic_vector ( 31 downto 0 );
           RC1_RDY_I      : in std_logic ;
           RC1_ACK_O      : out std_logic ;
           RC1_DISCARD_O  : out std_logic ;
           
           RC2_DATA_I     : in std_logic_vector ( 31 downto 0 );
           RC2_RDY_I      : in std_logic ;
           RC2_ACK_O      : out std_logic ;
           RC2_DISCARD_O  : out std_logic ;
           
           RC3_DATA_I     : in std_logic_vector ( 31 downto 0 );
           RC3_RDY_I      : in std_logic ;
           RC3_ACK_O      : out std_logic ;
           RC3_DISCARD_O  : out std_logic ;
           
           RC4_DATA_I     : in std_logic_vector ( 31 downto 0 );
           RC4_RDY_I      : in std_logic ;
           RC4_ACK_O      : out std_logic ;
           RC4_DISCARD_O  : out std_logic ;
           
           CC_DATA_I      : in std_logic_vector ( 31 downto 0 );
           CC_RDY_I       : in std_logic ;
           CC_ACK_O       : out std_logic ;
           CC_DISCARD_O   : out std_logic ;
           
           SIZE_O         : out integer ;
           ERROR_O        : out std_logic_vector ( 29 downto 0 );
           DATA_O         : out std_logic_vector ( 31 downto 0 );
           RDY_O          : out std_logic ;
           ACK_I          : in std_logic ;
           
           MACRO_OP_I     : in std_logic_vector ( 7 downto 0 );
           MICRO_OP_I     : in std_logic_vector ( 7 downto 0 );
           CARD_ADDR_I    : in std_logic_vector ( 7 downto 0 );
           CMD_VALID_I    : in std_logic ;
           MATCHED_O      : out std_logic ;
           TIMEOUT_O      : out std_logic );

   end component;

   component REPLY_QUEUE_RECEIVE
      port(CLK_I          : in std_logic ;
           COMM_CLK_I     : in std_logic ;
           RST_I          : in std_logic ;
           LVDS_REPLY_I   : in std_logic ;
           DATA_O         : out std_logic_vector ( 31 downto 0 );
           RDY_O          : out std_logic ;
           ACK_I          : in std_logic ;
           DISCARD_I      : in std_logic );

   end component;

   component LVDS_TX
      port(CLK_I        : in std_logic ;
           RST_I        : in std_logic ;
           DAT_I        : in std_logic_vector ( 31 downto 0 );
           RDY_I        : in std_logic ;
           BUSY_O       : out std_logic ;
           LVDS_O       : out std_logic );

   end component;

   constant PERIOD      : time := 20000 ps;
   constant COMM_PERIOD : time := 5000 ps;

   signal W_CLK_I          : std_logic := '1';
   signal W_COMM_CLK_I     : std_logic := '1';
   signal W_RST_I          : std_logic ;

   signal W_AC_DATA      : std_logic_vector ( 31 downto 0 );
   signal W_AC_RDY       : std_logic ;
   signal W_AC_ACK       : std_logic ;
   signal W_AC_DISCARD   : std_logic ;
   
   signal W_BC1_DATA     : std_logic_vector ( 31 downto 0 );
   signal W_BC1_RDY      : std_logic ;
   signal W_BC1_ACK      : std_logic ;
   signal W_BC1_DISCARD  : std_logic ;

   signal W_BC2_DATA     : std_logic_vector ( 31 downto 0 );
   signal W_BC2_RDY      : std_logic ;
   signal W_BC2_ACK      : std_logic ;
   signal W_BC2_DISCARD  : std_logic ;
   
   signal W_BC3_DATA     : std_logic_vector ( 31 downto 0 );
   signal W_BC3_RDY      : std_logic ;
   signal W_BC3_ACK      : std_logic ;
   signal W_BC3_DISCARD  : std_logic ;
   
   signal W_RC1_DATA     : std_logic_vector ( 31 downto 0 );
   signal W_RC1_RDY      : std_logic ;
   signal W_RC1_ACK      : std_logic ;
   signal W_RC1_DISCARD  : std_logic ;
   
   signal W_RC2_DATA     : std_logic_vector ( 31 downto 0 );
   signal W_RC2_RDY      : std_logic ;
   signal W_RC2_ACK      : std_logic ;
   signal W_RC2_DISCARD  : std_logic ;
   
   signal W_RC3_DATA     : std_logic_vector ( 31 downto 0 );
   signal W_RC3_RDY      : std_logic ;
   signal W_RC3_ACK      : std_logic ;
   signal W_RC3_DISCARD  : std_logic ;
   
   signal W_RC4_DATA     : std_logic_vector ( 31 downto 0 );
   signal W_RC4_RDY      : std_logic ;
   signal W_RC4_ACK      : std_logic ;
   signal W_RC4_DISCARD  : std_logic ;
   
   signal W_CC_DATA      : std_logic_vector ( 31 downto 0 );
   signal W_CC_RDY       : std_logic ;
   signal W_CC_ACK       : std_logic ;
   signal W_CC_DISCARD   : std_logic ;
   
   signal W_SIZE_O         : integer ;
   signal W_ERROR_O        : std_logic_vector ( 29 downto 0 );
   signal W_DATA_O         : std_logic_vector ( 31 downto 0 );
   signal W_RDY_O          : std_logic ;
   signal W_ACK_I          : std_logic ;
   signal W_MACRO_OP_I     : std_logic_vector ( 7 downto 0 );
   signal W_MICRO_OP_I     : std_logic_vector ( 7 downto 0 );
   signal W_CARD_ADDR_I    : std_logic_vector ( 7 downto 0 );
   signal W_CMD_VALID_I    : std_logic ;
   signal W_MATCHED_O      : std_logic ;
   signal W_TIMEOUT_O      : std_logic ;

   signal W_AC_LVDS_DAT_I   : std_logic_vector ( 31 downto 0 );
   signal W_AC_LVDS_RDY_I   : std_logic ;
   signal W_AC_LVDS_BUSY_O  : std_logic ;
   signal W_AC_LVDS_REPLY   : std_logic ;
   
   signal W_BC1_LVDS_DAT_I   : std_logic_vector ( 31 downto 0 );
   signal W_BC1_LVDS_RDY_I   : std_logic ;
   signal W_BC1_LVDS_BUSY_O  : std_logic ;
   signal W_BC1_LVDS_REPLY   : std_logic ;
   
   signal W_BC2_LVDS_DAT_I   : std_logic_vector ( 31 downto 0 );
   signal W_BC2_LVDS_RDY_I   : std_logic ;
   signal W_BC2_LVDS_BUSY_O  : std_logic ;
   signal W_BC2_LVDS_REPLY   : std_logic ;
   
   signal W_BC3_LVDS_DAT_I   : std_logic_vector ( 31 downto 0 );
   signal W_BC3_LVDS_RDY_I   : std_logic ;
   signal W_BC3_LVDS_BUSY_O  : std_logic ;
   signal W_BC3_LVDS_REPLY   : std_logic ;
   
   signal W_RC1_LVDS_DAT_I   : std_logic_vector ( 31 downto 0 );
   signal W_RC1_LVDS_RDY_I   : std_logic ;
   signal W_RC1_LVDS_BUSY_O  : std_logic ;
   signal W_RC1_LVDS_REPLY   : std_logic ;
   
   signal W_RC2_LVDS_DAT_I   : std_logic_vector ( 31 downto 0 );
   signal W_RC2_LVDS_RDY_I   : std_logic ;
   signal W_RC2_LVDS_BUSY_O  : std_logic ;
   signal W_RC2_LVDS_REPLY   : std_logic ;
   
   signal W_RC3_LVDS_DAT_I   : std_logic_vector ( 31 downto 0 );
   signal W_RC3_LVDS_RDY_I   : std_logic ;
   signal W_RC3_LVDS_BUSY_O  : std_logic ;
   signal W_RC3_LVDS_REPLY   : std_logic ;
   
   signal W_RC4_LVDS_DAT_I   : std_logic_vector ( 31 downto 0 );
   signal W_RC4_LVDS_RDY_I   : std_logic ;
   signal W_RC4_LVDS_BUSY_O  : std_logic ;
   signal W_RC4_LVDS_REPLY   : std_logic ;
   
   signal W_CC_LVDS_DAT_I   : std_logic_vector ( 31 downto 0 );
   signal W_CC_LVDS_RDY_I   : std_logic ;
   signal W_CC_LVDS_BUSY_O  : std_logic ;
   signal W_CC_LVDS_REPLY   : std_logic ;
      
begin

   DUT : REPLY_QUEUE_SEQUENCER
      port map(CLK_I          => W_CLK_I,
               RST_I          => W_RST_I,
               
               AC_DATA_I      => W_AC_DATA,
               AC_RDY_I       => W_AC_RDY,
               AC_ACK_O       => W_AC_ACK,
               AC_DISCARD_O   => W_AC_DISCARD,
               
               BC1_DATA_I     => W_BC1_DATA,
               BC1_RDY_I      => W_BC1_RDY,
               BC1_ACK_O      => W_BC1_ACK,
               BC1_DISCARD_O  => W_BC1_DISCARD,
               
               BC2_DATA_I     => W_BC2_DATA,
               BC2_RDY_I      => W_BC2_RDY,
               BC2_ACK_O      => W_BC2_ACK,
               BC2_DISCARD_O  => W_BC2_DISCARD,
               
               BC3_DATA_I     => W_BC3_DATA,
               BC3_RDY_I      => W_BC3_RDY,
               BC3_ACK_O      => W_BC3_ACK,
               BC3_DISCARD_O  => W_BC3_DISCARD,
               
               RC1_DATA_I     => W_RC1_DATA,
               RC1_RDY_I      => W_RC1_RDY,
               RC1_ACK_O      => W_RC1_ACK,
               RC1_DISCARD_O  => W_RC1_DISCARD,
               
               RC2_DATA_I     => W_RC2_DATA,
               RC2_RDY_I      => W_RC2_RDY,
               RC2_ACK_O      => W_RC2_ACK,
               RC2_DISCARD_O  => W_RC2_DISCARD,
               
               RC3_DATA_I     => W_RC3_DATA,
               RC3_RDY_I      => W_RC3_RDY,
               RC3_ACK_O      => W_RC3_ACK,
               RC3_DISCARD_O  => W_RC3_DISCARD,
               
               RC4_DATA_I     => W_RC4_DATA,
               RC4_RDY_I      => W_RC4_RDY,
               RC4_ACK_O      => W_RC4_ACK,
               RC4_DISCARD_O  => W_RC4_DISCARD,
               
               CC_DATA_I      => W_CC_DATA,
               CC_RDY_I       => W_CC_RDY,
               CC_ACK_O       => W_CC_ACK,
               CC_DISCARD_O   => W_CC_DISCARD,
               
               SIZE_O         => W_SIZE_O,
               DATA_O         => W_DATA_O,
               RDY_O          => W_RDY_O,
               ACK_I          => W_ACK_I,
               MACRO_OP_I     => W_MACRO_OP_I,
               MICRO_OP_I     => W_MICRO_OP_I,
               CARD_ADDR_I    => W_CARD_ADDR_I,
               CMD_VALID_I    => W_CMD_VALID_I,
               MATCHED_O      => W_MATCHED_O,
               TIMEOUT_O      => W_TIMEOUT_O);

   AC_QUEUE : REPLY_QUEUE_RECEIVE
      port map(CLK_I          => W_CLK_I,
               COMM_CLK_I     => W_COMM_CLK_I,
               RST_I          => W_RST_I,
               LVDS_REPLY_I   => W_AC_LVDS_REPLY,
               DATA_O         => W_AC_DATA,
               RDY_O          => W_AC_RDY,
               ACK_I          => W_AC_ACK,
               DISCARD_I      => W_AC_DISCARD);
   
   BC1_QUEUE : REPLY_QUEUE_RECEIVE
      port map(CLK_I          => W_CLK_I,
               COMM_CLK_I     => W_COMM_CLK_I,
               RST_I          => W_RST_I,
               LVDS_REPLY_I   => W_BC1_LVDS_REPLY,
               DATA_O         => W_BC1_DATA,
               RDY_O          => W_BC1_RDY,
               ACK_I          => W_BC1_ACK,
               DISCARD_I      => W_BC1_DISCARD);
               
   BC2_QUEUE : REPLY_QUEUE_RECEIVE
      port map(CLK_I          => W_CLK_I,
               COMM_CLK_I     => W_COMM_CLK_I,
               RST_I          => W_RST_I,
               LVDS_REPLY_I   => W_BC2_LVDS_REPLY,
               DATA_O         => W_BC2_DATA,
               RDY_O          => W_BC2_RDY,
               ACK_I          => W_BC2_ACK,
               DISCARD_I      => W_BC2_DISCARD);
               
   BC3_QUEUE : REPLY_QUEUE_RECEIVE
      port map(CLK_I          => W_CLK_I,
               COMM_CLK_I     => W_COMM_CLK_I,
               RST_I          => W_RST_I,
               LVDS_REPLY_I   => W_BC3_LVDS_REPLY,
               DATA_O         => W_BC3_DATA,
               RDY_O          => W_BC3_RDY,
               ACK_I          => W_BC3_ACK,
               DISCARD_I      => W_BC3_DISCARD);
               
   RC1_QUEUE : REPLY_QUEUE_RECEIVE
      port map(CLK_I          => W_CLK_I,
               COMM_CLK_I     => W_COMM_CLK_I,
               RST_I          => W_RST_I,
               LVDS_REPLY_I   => W_RC1_LVDS_REPLY,
               DATA_O         => W_RC1_DATA,
               RDY_O          => W_RC1_RDY,
               ACK_I          => W_RC1_ACK,
               DISCARD_I      => W_RC1_DISCARD);
               
   RC2_QUEUE : REPLY_QUEUE_RECEIVE
      port map(CLK_I          => W_CLK_I,
               COMM_CLK_I     => W_COMM_CLK_I,
               RST_I          => W_RST_I,
               LVDS_REPLY_I   => W_RC2_LVDS_REPLY,
               DATA_O         => W_RC2_DATA,
               RDY_O          => W_RC2_RDY,
               ACK_I          => W_RC2_ACK,
               DISCARD_I      => W_RC2_DISCARD);
               
   RC3_QUEUE : REPLY_QUEUE_RECEIVE
      port map(CLK_I          => W_CLK_I,
               COMM_CLK_I     => W_COMM_CLK_I,
               RST_I          => W_RST_I,
               LVDS_REPLY_I   => W_RC3_LVDS_REPLY,
               DATA_O         => W_RC3_DATA,
               RDY_O          => W_RC3_RDY,
               ACK_I          => W_RC3_ACK,
               DISCARD_I      => W_RC3_DISCARD);
               
   RC4_QUEUE : REPLY_QUEUE_RECEIVE
      port map(CLK_I          => W_CLK_I,
               COMM_CLK_I     => W_COMM_CLK_I,
               RST_I          => W_RST_I,
               LVDS_REPLY_I   => W_RC4_LVDS_REPLY,
               DATA_O         => W_RC4_DATA,
               RDY_O          => W_RC4_RDY,
               ACK_I          => W_RC4_ACK,
               DISCARD_I      => W_RC4_DISCARD);
               
   CC_QUEUE : REPLY_QUEUE_RECEIVE
      port map(CLK_I          => W_CLK_I,
               COMM_CLK_I     => W_COMM_CLK_I,
               RST_I          => W_RST_I,
               LVDS_REPLY_I   => W_CC_LVDS_REPLY,
               DATA_O         => W_CC_DATA,
               RDY_O          => W_CC_RDY,
               ACK_I          => W_CC_ACK,
               DISCARD_I      => W_CC_DISCARD);        
                           
   AC_TRANSMITTER : LVDS_TX
      port map(CLK_I        => W_CLK_I,
               RST_I        => W_RST_I,
               DAT_I        => W_AC_LVDS_DAT_I,
               RDY_I        => W_AC_LVDS_RDY_I,
               BUSY_O       => W_AC_LVDS_BUSY_O,
               LVDS_O       => W_AC_LVDS_REPLY);

   BC1_TRANSMITTER : LVDS_TX
      port map(CLK_I        => W_CLK_I,
               RST_I        => W_RST_I,
               DAT_I        => W_BC1_LVDS_DAT_I,
               RDY_I        => W_BC1_LVDS_RDY_I,
               BUSY_O       => W_BC1_LVDS_BUSY_O,
               LVDS_O       => W_BC1_LVDS_REPLY);

   BC2_TRANSMITTER : LVDS_TX
      port map(CLK_I        => W_CLK_I,
               RST_I        => W_RST_I,
               DAT_I        => W_BC2_LVDS_DAT_I,
               RDY_I        => W_BC2_LVDS_RDY_I,
               BUSY_O       => W_BC2_LVDS_BUSY_O,
               LVDS_O       => W_BC2_LVDS_REPLY);

   BC3_TRANSMITTER : LVDS_TX
      port map(CLK_I        => W_CLK_I,
               RST_I        => W_RST_I,
               DAT_I        => W_BC3_LVDS_DAT_I,
               RDY_I        => W_BC3_LVDS_RDY_I,
               BUSY_O       => W_BC3_LVDS_BUSY_O,
               LVDS_O       => W_BC3_LVDS_REPLY);

   RC1_TRANSMITTER : LVDS_TX
      port map(CLK_I        => W_CLK_I,
               RST_I        => W_RST_I,
               DAT_I        => W_RC1_LVDS_DAT_I,
               RDY_I        => W_RC1_LVDS_RDY_I,
               BUSY_O       => W_RC1_LVDS_BUSY_O,
               LVDS_O       => W_RC1_LVDS_REPLY);

   RC2_TRANSMITTER : LVDS_TX
      port map(CLK_I        => W_CLK_I,
               RST_I        => W_RST_I,
               DAT_I        => W_RC2_LVDS_DAT_I,
               RDY_I        => W_RC2_LVDS_RDY_I,
               BUSY_O       => W_RC2_LVDS_BUSY_O,
               LVDS_O       => W_RC2_LVDS_REPLY);

   RC3_TRANSMITTER : LVDS_TX
      port map(CLK_I        => W_CLK_I,
               RST_I        => W_RST_I,
               DAT_I        => W_RC3_LVDS_DAT_I,
               RDY_I        => W_RC3_LVDS_RDY_I,
               BUSY_O       => W_RC3_LVDS_BUSY_O,
               LVDS_O       => W_RC3_LVDS_REPLY);

   RC4_TRANSMITTER : LVDS_TX
      port map(CLK_I        => W_CLK_I,
               RST_I        => W_RST_I,
               DAT_I        => W_RC4_LVDS_DAT_I,
               RDY_I        => W_RC4_LVDS_RDY_I,
               BUSY_O       => W_RC4_LVDS_BUSY_O,
               LVDS_O       => W_RC4_LVDS_REPLY);

   CC_TRANSMITTER : LVDS_TX
      port map(CLK_I        => W_CLK_I,
               RST_I        => W_RST_I,
               DAT_I        => W_CC_LVDS_DAT_I,
               RDY_I        => W_CC_LVDS_RDY_I,
               BUSY_O       => W_CC_LVDS_BUSY_O,
               LVDS_O       => W_CC_LVDS_REPLY);
               
   W_CLK_I <= not W_CLK_I after PERIOD/2;
   W_COMM_CLK_I <= not W_COMM_CLK_I after COMM_PERIOD/2;

   STIMULI : process
   
   procedure reset is
   begin
      W_RST_I          <= '1';
      
      W_AC_LVDS_DAT_I  <= (others => '0');
      W_AC_LVDS_RDY_I  <= '0';
      
      W_BC1_LVDS_DAT_I <= (others => '0');
      W_BC1_LVDS_RDY_I <= '0';
      
      W_BC2_LVDS_DAT_I <= (others => '0');
      W_BC2_LVDS_RDY_I <= '0';
      
      W_BC3_LVDS_DAT_I <= (others => '0');
      W_BC3_LVDS_RDY_I <= '0';
      
      W_RC1_LVDS_DAT_I <= (others => '0');
      W_RC1_LVDS_RDY_I <= '0';
      
      W_RC2_LVDS_DAT_I <= (others => '0');
      W_RC2_LVDS_RDY_I <= '0';
      
      W_RC3_LVDS_DAT_I <= (others => '0');
      W_RC3_LVDS_RDY_I <= '0';
      
      W_RC4_LVDS_DAT_I <= (others => '0');
      W_RC4_LVDS_RDY_I <= '0';
      
      W_CC_LVDS_DAT_I  <= (others => '0');
      W_CC_LVDS_RDY_I  <= '0';
      
      W_ACK_I          <= '0';
      W_MACRO_OP_I     <= (others => '0');
      W_MICRO_OP_I     <= (others => '0');
      W_CARD_ADDR_I    <= (others => '0');
      W_CMD_VALID_I    <= '0';
                 
      wait for PERIOD;
      
      W_RST_I          <= '0';
      
      wait for PERIOD;
   end reset;
   
   procedure send_ac (data : in std_logic_vector(31 downto 0)) is
   begin      
      W_AC_LVDS_DAT_I <= data;
      W_AC_LVDS_RDY_I <= '1';
      
      wait for PERIOD;   
      
      W_AC_LVDS_DAT_I <= (others => '0');
      W_AC_LVDS_RDY_I <= '0';
      
      wait for PERIOD;      
   end send_ac;
   
   procedure send_bc1 (data : in std_logic_vector(31 downto 0)) is
   begin      
      W_BC1_LVDS_DAT_I <= data;
      W_BC1_LVDS_RDY_I <= '1';
      
      wait for PERIOD;   
      
      W_BC1_LVDS_DAT_I <= (others => '0');
      W_BC1_LVDS_RDY_I <= '0';
      
      wait for PERIOD;      
   end send_bc1;
   
   procedure send_bc2 (data : in std_logic_vector(31 downto 0)) is
   begin      
      W_BC2_LVDS_DAT_I <= data;
      W_BC2_LVDS_RDY_I <= '1';
      
      wait for PERIOD;   
      
      W_BC2_LVDS_DAT_I <= (others => '0');
      W_BC2_LVDS_RDY_I <= '0';
      
      wait for PERIOD;      
   end send_bc2;
   
   procedure send_bc3 (data : in std_logic_vector(31 downto 0)) is
   begin      
      W_BC3_LVDS_DAT_I <= data;
      W_BC3_LVDS_RDY_I <= '1';
      
      wait for PERIOD;   
      
      W_BC3_LVDS_DAT_I <= (others => '0');
      W_BC3_LVDS_RDY_I <= '0';
      
      wait for PERIOD;      
   end send_bc3;
   
   procedure send_rc1 (data : in std_logic_vector(31 downto 0)) is
   begin      
      W_RC1_LVDS_DAT_I <= data;
      W_RC1_LVDS_RDY_I <= '1';
      
      wait for PERIOD;   
      
      W_RC1_LVDS_DAT_I <= (others => '0');
      W_RC1_LVDS_RDY_I <= '0';
      
      wait for PERIOD;      
   end send_rc1;
   
   procedure send_rc2 (data : in std_logic_vector(31 downto 0)) is
   begin      
      W_RC2_LVDS_DAT_I <= data;
      W_RC2_LVDS_RDY_I <= '1';
      
      wait for PERIOD;   
      
      W_RC2_LVDS_DAT_I <= (others => '0');
      W_RC2_LVDS_RDY_I <= '0';
      
      wait for PERIOD;      
   end send_rc2;
   
   procedure send_rc3 (data : in std_logic_vector(31 downto 0)) is
   begin      
      W_RC3_LVDS_DAT_I <= data;
      W_RC3_LVDS_RDY_I <= '1';
      
      wait for PERIOD;   
      
      W_RC3_LVDS_DAT_I <= (others => '0');
      W_RC3_LVDS_RDY_I <= '0';
      
      wait for PERIOD;      
   end send_rc3;
   
   procedure send_rc4 (data : in std_logic_vector(31 downto 0)) is
   begin      
      W_RC4_LVDS_DAT_I <= data;
      W_RC4_LVDS_RDY_I <= '1';
      
      wait for PERIOD;   
      
      W_RC4_LVDS_DAT_I <= (others => '0');
      W_RC4_LVDS_RDY_I <= '0';
      
      wait for PERIOD;      
   end send_rc4;
   
   procedure send_cc (data : in std_logic_vector(31 downto 0)) is
   begin      
      W_CC_LVDS_DAT_I <= data;
      W_CC_LVDS_RDY_I <= '1';
      
      wait for PERIOD;   
      
      W_CC_LVDS_DAT_I <= (others => '0');
      W_CC_LVDS_RDY_I <= '0';
      
      wait for PERIOD;      
   end send_cc;
   
   procedure eot is
   begin
      W_AC_LVDS_DAT_I  <= (others => '0');
      W_AC_LVDS_RDY_I  <= '0';
      
      W_BC1_LVDS_DAT_I <= (others => '0');
      W_BC1_LVDS_RDY_I <= '0';
      
      W_BC2_LVDS_DAT_I <= (others => '0');
      W_BC2_LVDS_RDY_I <= '0';
      
      W_BC3_LVDS_DAT_I <= (others => '0');
      W_BC3_LVDS_RDY_I <= '0';
      
      W_RC1_LVDS_DAT_I <= (others => '0');
      W_RC1_LVDS_RDY_I <= '0';
      
      W_RC2_LVDS_DAT_I <= (others => '0');
      W_RC2_LVDS_RDY_I <= '0';
      
      W_RC3_LVDS_DAT_I <= (others => '0');
      W_RC3_LVDS_RDY_I <= '0';
      
      W_RC4_LVDS_DAT_I <= (others => '0');
      W_RC4_LVDS_RDY_I <= '0';
      
      W_CC_LVDS_DAT_I  <= (others => '0');
      W_CC_LVDS_RDY_I  <= '0';
      
      wait for PERIOD*200;
   end eot;
   
   procedure begin_search (macro_op  : in integer;
                           micro_op  : in integer;
                           card_addr : in std_logic_vector (7 downto 0)) is
   begin
      W_MACRO_OP_I     <= conv_std_logic_vector(macro_op, 8);
      W_MICRO_OP_I     <= conv_std_logic_vector(micro_op, 8);
      W_CARD_ADDR_I    <= card_addr;
      W_CMD_VALID_I    <= '1';
      
      wait for PERIOD;
   end begin_search;
   
   procedure end_search is
   begin
      W_MACRO_OP_I     <= (others => '0');
      W_MICRO_OP_I     <= (others => '0');
      W_CARD_ADDR_I    <= (others => '0');
      W_CMD_VALID_I    <= '0';
      
      wait for PERIOD;
   end end_search;
   
   begin
      reset;
      
      -------------------------------------------------------------------
      -- Test Case 1 : single match test
      --
      -- Send a reply, then match it and clock out data
      -------------------------------------------------------------------
      
      send_ac(x"AAAA0002");
      send_ac(x"00000002");
      send_ac(x"FF000000");
      send_ac(x"11000001");
      send_ac(x"11000002");
      send_ac(x"1219B404");
      
      begin_search(0, 2, ADDRESS_CARD);
      wait until W_RDY_O = '1';
      W_ACK_I <= '1';
      wait for PERIOD*2;
      W_ACK_I <= '0';
      end_search;
      
      wait for PERIOD*300;
      
      
      -------------------------------------------------------------------
      -- Test Case 2 : multiple match test 1
      --
      -- Send replies from all BC, then match it and clock out data
      -------------------------------------------------------------------
      
      send_bc1(x"AAAA0001");
      send_bc1(x"0C000003");
      send_bc1(x"00000000");
      send_bc1(x"22000001");
      send_bc1(x"E775D391");
      
      send_bc2(x"AAAA0001");
      send_bc2(x"0C000003");
      send_bc2(x"00000000");
      send_bc2(x"22000002");
      send_bc2(x"F5C07C7F");
      
      send_bc3(x"AAAA0001");
      send_bc3(x"0C000003");
      send_bc3(x"00000000");
      send_bc3(x"22000003");
      send_bc3(x"4D7C1B1A");
      
      begin_search(0, 3, ALL_BIAS_CARDS);
      wait until W_RDY_O = '1';
      W_ACK_I <= '1';
      wait for PERIOD*10;
      W_ACK_I <= '0';
      end_search;
      
      wait for PERIOD*300;
      
      
      -------------------------------------------------------------------
      -- Test Case 3 : multiple match test 2
      --
      -- Send replies from all cards, then match it and clock out data
      -------------------------------------------------------------------
      
      send_bc1(x"AAAA0001");
      send_bc1(x"0E000003");
      send_bc1(x"00000000");
      send_bc1(x"33000001");
      send_bc1(x"A333DBE5");
      
      send_bc2(x"AAAA0001");
      send_bc2(x"0E000003");
      send_bc2(x"00000000");
      send_bc2(x"33000002");
      send_bc2(x"B186740B");
      
      send_bc3(x"AAAA0001");
      send_bc3(x"0E000003");
      send_bc3(x"00000000");
      send_bc3(x"33000003");
      send_bc3(x"093A136E");
      
      send_ac(x"AAAA0003");
      send_ac(x"0E000003");
      send_ac(x"00000000");
      send_ac(x"33000004");
      send_ac(x"33000005");
      send_ac(x"33000006");
      send_ac(x"A2DFA518");
      
      send_cc(x"AAAA0002");
      send_cc(x"0E000003");
      send_cc(x"00000000");
      send_cc(x"33000007");
      send_cc(x"33000008");
      send_cc(x"C86BF10D");
      
      send_rc1(x"AAAA000A");
      send_rc1(x"0E000003");
      send_rc1(x"00000000");
      send_rc1(x"33000009");
      send_rc1(x"33000010");
      send_rc1(x"33000011");
      send_rc1(x"33000012");
      send_rc1(x"33000013");
      send_rc1(x"33000014");
      send_rc1(x"33000015");
      send_rc1(x"33000016");
      send_rc1(x"33000017");
      send_rc1(x"33000018");
      send_rc1(x"9347737D");
      
      send_rc2(x"AAAA0006");
      send_rc2(x"0E000003");
      send_rc2(x"00000000");
      send_rc2(x"33000019");
      send_rc2(x"33000020");
      send_rc2(x"33000021");
      send_rc2(x"33000022");
      send_rc2(x"33000023");
      send_rc2(x"33000024");
      send_rc2(x"3FED83AF");
      
      send_rc3(x"AAAA0005");
      send_rc3(x"0E000003");
      send_rc3(x"00000000");
      send_rc3(x"33000025");
      send_rc3(x"33000026");
      send_rc3(x"33000027");
      send_rc3(x"33000028");
      send_rc3(x"33000029");
      send_rc3(x"760DAA26");
      
      send_rc4(x"AAAA0000");
      send_rc4(x"0E000003");
      send_rc4(x"FF000000");
      send_rc4(x"D34DC465");
      
      begin_search(0, 3, ALL_FPGA_CARDS);
      wait until W_RDY_O = '1';
      W_ACK_I <= '1';
      wait for PERIOD*40;
      W_ACK_I <= '0';
      end_search;
      
      wait for PERIOD*300;
      
      
      -------------------------------------------------------------------
      -- Test Case 4 : multiple match test 3
      --
      -- Send replies from all RC, then match it and clock out data
      -------------------------------------------------------------------
      
      send_rc1(x"AAAA0001");
      send_rc1(x"0C000003");
      send_rc1(x"00000000");
      send_rc1(x"22000001");
      send_rc1(x"E775D391");
      
      send_rc2(x"AAAA0001");
      send_rc2(x"0C000003");
      send_rc2(x"00000000");
      send_rc2(x"22000002");
      send_rc2(x"F5C07C7F");
      
      send_rc3(x"AAAA0001");
      send_rc3(x"0C000003");
      send_rc3(x"00000000");
      send_rc3(x"22000003");
      send_rc3(x"4D7C1B1A");
      
      send_rc4(x"AAAA0001");
      send_rc4(x"0C000003");
      send_rc4(x"00000000");
      send_rc4(x"22000004");
      send_rc4(x"D0AB23A3");
      
      begin_search(0, 3, ALL_READOUT_CARDS);
      wait until W_RDY_O = '1';
      W_ACK_I <= '1';
      wait for PERIOD*10;
      W_ACK_I <= '0';
      end_search;
      
      wait for PERIOD*300;
      
      -------------------------------------------------------------------
      -- Test Case 5 : timeout test
      --
      -- Test timeout functionality
      -------------------------------------------------------------------
      
      send_bc1(x"AAAA0002");
      send_bc1(x"00000002");
      send_bc1(x"FF000000");
      send_bc1(x"44000001");
      send_bc1(x"44000002");
      send_bc1(x"F9EB51C4");
      
      begin_search(0, 0, BIAS_CARD_1);
      wait until W_TIMEOUT_O = '1';
      end_search;
      
      begin_search(0, 1, BIAS_CARD_1);
      wait until W_TIMEOUT_O = '1';
      end_search;
      
      begin_search(0, 2, BIAS_CARD_1);
      wait until W_RDY_O = '1';
      W_ACK_I <= '1';
      wait for PERIOD*5;
      W_ACK_I <= '0';
      end_search;
      
      wait for PERIOD*300;
      
      
      -------------------------------------------------------------------
      -- Test Case 6 : discard test
      --
      -- Send a reply, then attempt to match to a different command
      -------------------------------------------------------------------
      
      send_bc2(x"AAAA0003");
      send_bc2(x"00000001");
      send_bc2(x"00000000");
      send_bc2(x"66000001");
      send_bc2(x"66000002");
      send_bc2(x"66000003");
      send_bc2(x"5FBA44C0");
      
      wait for 10 us;
      
      send_bc2(x"AAAA0003");
      send_bc2(x"00000002");
      send_bc2(x"00000000");
      send_bc2(x"66000004");
      send_bc2(x"66000005");
      send_bc2(x"66000006");
      send_bc2(x"55AB8731");
      
      wait for 10 us;
      
      send_bc2(x"AAAA0003");
      send_bc2(x"00000003");
      send_bc2(x"00000000");
      send_bc2(x"66000007");
      send_bc2(x"66000008");
      send_bc2(x"66000009");
      send_bc2(x"84346B00");
      
      begin_search(0, 3, BIAS_CARD_2);
      wait until W_RDY_O = '1';
      W_ACK_I <= '1';
      wait for PERIOD*4;
      W_ACK_I <= '0';
      end_search;
      
      wait for PERIOD*300;
      
      
      -------------------------------------------------------------------
      -- Test Case Coverage: 78%
      -- 
      -- There are some blocks / FSM states that were not covered because
      -- they are the same as those that are already covered in this test
      -- and in the interest of time I have not implemented those tests.
      --
      -------------------------------------------------------------------
      
      
      wait for PERIOD*1000;
      
      assert FALSE report "End of simulation." severity FAILURE;
      
      wait for PERIOD;
      wait;
            
   end process STIMULI;

end BEH;