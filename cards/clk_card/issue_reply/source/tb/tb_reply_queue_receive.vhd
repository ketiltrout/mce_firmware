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
-- tb_reply_queue_receive.vhd
--
-- Project:	      SCUBA-2
-- Author:        Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Testbench for single receiver module for reply queue.
--
-- Revision history:
-- 
-- $Log$
--
-----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity TB_REPLY_QUEUE_RECEIVE is
end TB_REPLY_QUEUE_RECEIVE;

architecture BEH of TB_REPLY_QUEUE_RECEIVE is

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
   
   constant PERIOD : time := 20000 ps;
   constant COMM_PERIOD : time := 5000 ps;

   signal W_CLK_I          : std_logic := '1';
   signal W_COMM_CLK_I     : std_logic := '1';
   signal W_RST_I          : std_logic ;
   signal W_LVDS_REPLY     : std_logic ;
   signal W_DATA_O         : std_logic_vector ( 31 downto 0 );
   signal W_RDY_O          : std_logic ;
   signal W_ACK_I          : std_logic ;
   signal W_DISCARD_I      : std_logic ;

   signal W_LVDS_DAT_I     : std_logic_vector ( 31 downto 0 );
   signal W_LVDS_RDY_I     : std_logic ;
   signal W_LVDS_BUSY_O    : std_logic ; 
   
begin

   DUT : REPLY_QUEUE_RECEIVE
      port map(CLK_I          => W_CLK_I,
               COMM_CLK_I     => W_COMM_CLK_I,
               RST_I          => W_RST_I,
               LVDS_REPLY_I   => W_LVDS_REPLY,
               DATA_O         => W_DATA_O,
               RDY_O          => W_RDY_O,
               ACK_I          => W_ACK_I,
               DISCARD_I      => W_DISCARD_I);

   W_CLK_I <= not W_CLK_I after PERIOD/2;
   W_COMM_CLK_I <= not W_COMM_CLK_I after COMM_PERIOD/2;

   TX : LVDS_TX
      port map(CLK_I        => W_CLK_I,
               RST_I        => W_RST_I,
               DAT_I        => W_LVDS_DAT_I,
               RDY_I        => W_LVDS_RDY_I,
               BUSY_O       => W_LVDS_BUSY_O,
               LVDS_O       => W_LVDS_REPLY);
   
   STIMULI : process
   procedure reset is
   begin
      W_RST_I          <= '1';
      W_ACK_I          <= '0';
      W_DISCARD_I      <= '0';
      W_LVDS_DAT_I     <= (others => '0');
      W_LVDS_RDY_I     <= '0';
      
      wait for PERIOD;
   end reset;
   
   procedure send (data : in std_logic_vector(31 downto 0)) is
   begin      
      W_RST_I          <= '0';
      W_ACK_I          <= '0';
      W_DISCARD_I      <= '0';
      W_LVDS_DAT_I     <= data;
      W_LVDS_RDY_I     <= '1';
      
      wait for PERIOD;      
   end send;
   
   procedure eot is
   begin
      W_RST_I          <= '0';
      W_ACK_I          <= '0';
      W_DISCARD_I      <= '0';
      W_LVDS_DAT_I     <= (others => '0');
      W_LVDS_RDY_I     <= '0';
      
      wait for PERIOD*200;
   end eot;
      
   procedure pause (duration : in integer) is
   begin
      W_RST_I          <= '0';
      W_ACK_I          <= '0';
      W_DISCARD_I      <= '0';
      W_LVDS_DAT_I     <= (others => '0');
      W_LVDS_RDY_I     <= '0';
      
      wait for PERIOD*duration;
   end pause;
--    
--   procedure ack (duration : in integer) is
--   begin
--      W_RST_I          <= '0';
--      W_ACK_I          <= '1';
--      W_DISCARD_I      <= '0';
--      W_LVDS_DAT_I     <= (others => '0');
--      W_LVDS_RDY_I     <= '0';
--      
--      wait for PERIOD*duration;
--      
--      W_ACK_I          <= '0';
--   end ack;
--   
--   procedure discard is
--   begin
--      W_RST_I          <= '0';
--      W_ACK_I          <= '0';
--      W_DISCARD_I      <= '1';
--      W_LVDS_DAT_I     <= (others => '0');
--      W_LVDS_RDY_I     <= '0';
--      
--      wait for PERIOD;
--      
--      W_DISCARD_I      <= '0';
--   end discard;
   
   begin
      
      reset;
      
      -------------------------------------------------------------------
      -- Test Case 1: 3 good packets, read all after pushing into queue
      -------------------------------------------------------------------
            
      -- good packet with no data words:
      send("10101010101010100000000000000000"); -- AAAA0000
      send("00000000000000000001001000110100"); -- 00001234
      send("00000000000000000000000000000000"); -- 00000000
      send("00111110001101100100001000001010"); -- 3E36420A
      eot;
            
      -- good packet with one data word:
      send("10101010101010100000000000000001"); -- AAAA0001
      send("00000000000000001010101111001101"); -- 0000ABCD
      send("11111111000000000000000000000000"); -- FF000000
      send("00010001000000000000000000000001"); -- 11000001
      send("00011111001111001011000000011101"); -- 1F3CB01D
      eot;
                
      -- good packet with two data words:
      send("10101010101010100000000000000010"); -- AAAA0002
      send("00000000000000001001100001110110"); -- 00009876
      send("11111111000000000000000000000000"); -- FF000000
      send("00100010000000000000000000000001"); -- 22000001
      send("00100010000000000000000000000011"); -- 22000003
      send("00111101110011110010110011001100"); -- 3DCF2CCC
      eot;
      
      if(W_RDY_O = '0') then
         wait until W_RDY_O = '1';
      end if;
      
      W_ACK_I <= '1';
      wait for PERIOD;
      W_ACK_I <= '0';
      
      wait until W_RDY_O = '0';
      wait until W_RDY_O = '1';
      W_ACK_I <= '1';
      wait for PERIOD*2;
      W_ACK_I <= '0';
     
      wait until W_RDY_O = '0';
      wait until W_RDY_O = '1';
      W_ACK_I <= '1';
      wait for PERIOD*3;
      W_ACK_I <= '0';
      
      
      -------------------------------------------------------------------
      -- Test Case 2: 3 good packets and 1 bad packet
      -------------------------------------------------------------------
      
      wait for PERIOD*1000;
      
      -- good packet with no data words:
      send("10101010101010100000000000000000"); -- AAAA0000
      send("00000000000000000001001000110100"); -- 00001234
      send("00000000000000000000000000000000"); -- 00000000
      send("00111110001101100100001000001010"); -- 3E36420A
      eot;
      
      -- good packet with one data word:
      send("10101010101010100000000000000001"); -- AAAA0001
      send("00000000000000001010101111001101"); -- 0000ABCD
      send("11111111000000000000000000000000"); -- FF000000
      send("00010001000000000000000000000001"); -- 11000001
      send("00011111001111001011000000011101"); -- 1F3CB01D
      eot;
          
      -- bad packet with two data words:
      send("10101010101010100000000000000010"); -- AAAA0002
      send("00000000000000001001100001110110"); -- 00009876
      send("11111111000000000000000000000000"); -- FF000000
      send("00110011000000000000000000000001"); -- 33000001
      send("00110011000000000000000000000111"); -- 33000007
      send("00111101110011110010110011001100"); -- 3DCF2CCC (invalid CRC)
      eot;
          
      -- good packet with two data words:
      send("10101010101010100000000000000010"); -- AAAA0002
      send("00000000000000001001100001110110"); -- 00009876
      send("11111111000000000000000000000000"); -- FF000000
      send("00100010000000000000000000000001"); -- 22000001
      send("00100010000000000000000000000011"); -- 22000003
      send("00111101110011110010110011001100"); -- 3DCF2CCC
      eot;
      
      if(W_RDY_O = '0') then
         wait until W_RDY_O = '1';
      end if;
      
      W_ACK_I <= '1';
      wait for PERIOD;
      W_ACK_I <= '0';
      
      wait until W_RDY_O = '0';
      wait until W_RDY_O = '1';
      W_ACK_I <= '1';
      wait for PERIOD*2;
      W_ACK_I <= '0';
     
      wait until W_RDY_O = '0';
      wait until W_RDY_O = '1';
      W_ACK_I <= '1';
      wait for PERIOD*3;
      W_ACK_I <= '0';
      
         
      -------------------------------------------------------------------
      -- Test Case 3: 3 good packets, discard all
      -------------------------------------------------------------------
      
      wait for PERIOD*1000;
            
      -- good packet with no data words:
      send("10101010101010100000000000000000"); -- AAAA0000
      send("00000000000000000001001000110100"); -- 00001234
      send("00000000000000000000000000000000"); -- 00000000
      send("00111110001101100100001000001010"); -- 3E36420A
      eot;
      
      -- good packet with one data word:
      send("10101010101010100000000000000001"); -- AAAA0001
      send("00000000000000001010101111001101"); -- 0000ABCD
      send("11111111000000000000000000000000"); -- FF000000
      send("00010001000000000000000000000001"); -- 11000001
      send("00011111001111001011000000011101"); -- 1F3CB01D
      eot;
          
      -- good packet with two data words:
      send("10101010101010100000000000000010"); -- AAAA0002
      send("00000000000000001001100001110110"); -- 00009876
      send("11111111000000000000000000000000"); -- FF000000
      send("00100010000000000000000000000001"); -- 22000001
      send("00100010000000000000000000000011"); -- 22000003
      send("00111101110011110010110011001100"); -- 3DCF2CCC
      eot;
      
      if(W_RDY_O = '0') then
         wait until W_RDY_O = '1';
      end if;
      
      W_DISCARD_I <= '1';
      wait for PERIOD;
      W_DISCARD_I <= '0';
      
      wait until W_RDY_O = '0';
      wait until W_RDY_O = '1';
      W_DISCARD_I <= '1';
      wait for PERIOD;
      W_DISCARD_I <= '0';
     
      wait until W_RDY_O = '0';
      wait until W_RDY_O = '1';
      W_DISCARD_I <= '1';
      wait for PERIOD;
      W_DISCARD_I <= '0';
      
          
      -------------------------------------------------------------------
      -- Test Case 4: 2 good packets, discard mid-packet 1
      ------------------------------------------------------------------- 
            
      wait for PERIOD*1000;
      
      -- good packet with ten data words:
      send("10101010101010100000000000001010"); -- AAAA000A
      send("00000000000000000101011001111000"); -- 00005678
      send("00000000000000000000000000000000"); -- 00000000
      send("10001000000000000000000000000001"); -- 88000001
      send("10001000000000000000000000000010"); -- 88000002
      send("10001000000000000000000000000011"); -- 88000003
      send("10001000000000000000000000000100"); -- 88000004
      send("10001000000000000000000000000101"); -- 88000005
      send("10001000000000000000000000000110"); -- 88000006
      send("10001000000000000000000000000111"); -- 88000007
      send("10001000000000000000000000001000"); -- 88000008
      send("10001000000000000000000000001001"); -- 88000009
      send("10001000000000000000000000001010"); -- 8800000A
      send("01010100010101111101110111000011"); -- 5457DDC3
      eot;
      
      wait for PERIOD*100;
      
      -- good packet with two data words:
      send("10101010101010100000000000000010"); -- AAAA0002
      send("00000000000000001001100001110110"); -- 00009876
      send("11111111000000000000000000000000"); -- FF000000
      send("00100010000000000000000000000001"); -- 22000001
      send("00100010000000000000000000000011"); -- 22000003
      send("00111101110011110010110011001100"); -- 3DCF2CCC
      eot;
      
      wait for PERIOD*1000;
      
      if(W_RDY_O = '0') then
         wait until W_RDY_O = '1';
      end if;
      
      W_ACK_I <= '1';
      wait for PERIOD*4;
      W_ACK_I <= '0';
      W_DISCARD_I <= '1';
      wait for PERIOD;
      W_DISCARD_I <= '0';
      
      
      wait until W_RDY_O = '0';
      wait until W_RDY_O = '1';
      W_ACK_I <= '1';
      wait for PERIOD*3;
      W_ACK_I <= '0';
            
            
      -------------------------------------------------------------------
      -- End of Test Cases
      ------------------------------------------------------------------- 
      
      wait for PERIOD*1000;
         
      assert FALSE report "End of Simulation." severity FAILURE;
      
      wait for PERIOD;
      wait;
   end process STIMULI;

end BEH;