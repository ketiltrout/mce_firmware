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
-- $Log: tb_reply_queue_receive.vhd,v $
-- Revision 1.1  2005/02/16 03:19:28  erniel
-- initial version
--
--
-----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

library components;
use components.component_pack.all;

entity TB_REPLY_QUEUE_RECEIVE is
end TB_REPLY_QUEUE_RECEIVE;

architecture BEH of TB_REPLY_QUEUE_RECEIVE is

   component REPLY_QUEUE_RECEIVE
      port(CLK_I          : in std_logic ;
           COMM_CLK_I     : in std_logic ;
           RST_I          : in std_logic ;
           LVDS_REPLY_I   : in std_logic ;
           ERROR_O        : out std_logic_vector ( 2 downto 0 );
           DATA_O         : out std_logic_vector ( 31 downto 0 );
           RDY_O          : out std_logic ;
           ACK_I          : in std_logic ;
           CLEAR_I        : in std_logic );

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
   signal W_ERROR_O        : std_logic_vector ( 2 downto 0 );
   signal W_DATA_O         : std_logic_vector ( 31 downto 0 );
   signal W_RDY_O          : std_logic ;
   signal W_ACK_I          : std_logic ;
   signal W_CLEAR_I        : std_logic ;

   signal W_LVDS_DAT_I     : std_logic_vector ( 31 downto 0 );
   signal W_LVDS_RDY_I     : std_logic ;
   signal W_LVDS_BUSY_O    : std_logic ; 
   
begin

   DUT : REPLY_QUEUE_RECEIVE
      port map(CLK_I          => W_CLK_I,
               COMM_CLK_I     => W_COMM_CLK_I,
               RST_I          => W_RST_I,
               LVDS_REPLY_I   => W_LVDS_REPLY,
               ERROR_O        => W_ERROR_O,
               DATA_O         => W_DATA_O,
               RDY_O          => W_RDY_O,
               ACK_I          => W_ACK_I,
               CLEAR_I        => W_CLEAR_I);

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
      W_LVDS_DAT_I     <= (others => '0');
      W_LVDS_RDY_I     <= '0';
      W_ACK_I          <= '0';   
      W_CLEAR_I        <= '0';   
      wait for PERIOD;
   end reset;
   
   procedure send (data : in std_logic_vector(31 downto 0)) is
   begin 
      if(W_LVDS_BUSY_O = '1') then
         wait until W_LVDS_BUSY_O = '0';
      end if;
              
      W_RST_I          <= '0';
      W_LVDS_DAT_I     <= data;
      W_LVDS_RDY_I     <= '1';
      W_ACK_I          <= '0';
      W_CLEAR_I        <= '0';      
      wait for PERIOD;   
      
      W_RST_I          <= '0';
      W_LVDS_DAT_I     <= (others => '0');
      W_LVDS_RDY_I     <= '0';
      W_ACK_I          <= '0';
      W_CLEAR_I        <= '0';      
      wait for PERIOD;   
   end send;
   
   procedure pause (duration : in integer) is
   begin
      W_RST_I          <= '0';
      W_LVDS_DAT_I     <= (others => '0');
      W_LVDS_RDY_I     <= '0';
      W_ACK_I          <= '0';  
      W_CLEAR_I        <= '0';    
      wait for PERIOD*duration;
   end pause;
   
   procedure ack is
   begin
      if(W_RDY_O = '0') then
         wait until W_RDY_O = '1';
         wait for PERIOD;
      end if;
      
      W_RST_I          <= '0';
      W_LVDS_DAT_I     <= (others => '0');
      W_LVDS_RDY_I     <= '0';
      W_ACK_I          <= '1';  
      W_CLEAR_I        <= '0';          
      wait for PERIOD;
   end ack;
   
   procedure clear is
   begin
      W_RST_I          <= '0';
      W_LVDS_DAT_I     <= (others => '0');
      W_LVDS_RDY_I     <= '0';
      W_ACK_I          <= '0';  
      W_CLEAR_I        <= '1';          
      wait for PERIOD;
   end clear;
      
   begin
      
      reset;
      
      ------------------------------------------------------      
      -- Test 1: Write packet returned OK
      ------------------------------------------------------
            
      send(x"AAAAA800");
      send(x"01010000");
      send(x"98482961"); 
      wait for 4500 ns;     
      ack;
      
      
      ------------------------------------------------------      
      -- Test 2: Read packet returned OK
      ------------------------------------------------------      
      
      send(x"AAAAA003");
      send(x"02020000");
      send(x"00001111");
      send(x"00002222");
      send(x"00003333");
      send(x"0AA2D49D");
      ack;
      pause(10);
      ack;
      pause(5);
      ack;
      pause(5);


      ------------------------------------------------------      
      -- Test 3: Packet has corrupt preamble
      ------------------------------------------------------
      
      send(x"AAAA5800");
      send(x"3A3A0000");
      send(x"15F12F7D");   
      -- this packet is ignored

      
      ------------------------------------------------------
      -- Test 4: Write packet has corrupt data size
      ------------------------------------------------------
            
      send(x"AAAAA801");
      send(x"4A4A0000");
      send(x"6ACB27B7");

      -- this packet continues the previous packet, CRC error results:      
      send(x"AAAAA800");  -- CRC of previous packet
      send(x"4B4B0000");  -- ignored (invalid preamble)
      send(x"04D72660");  -- ignored (invalid preamble)
      ack;
      
      -- this packet is first legit packet after error:      
      send(x"AAAAA800");
      send(x"4C4C0000");
      send(x"D5F22504");
      ack;
      
      
      ------------------------------------------------------      
      -- Test 5: Read packet has corrupt data size
      --         (Corruption made it bigger)
      ------------------------------------------------------
      
      send(x"AAAAA003");
      send(x"5A5A0000");
      send(x"00001111");
      send(x"8FDF610B");
      
      -- this packet continues previous packet, CRC error results:      
      send(x"AAAAA001");
      send(x"5B5B0000");  -- CRC of previous packet
      send(x"ACE76AAC");  -- ignored (invalid preamble)
      
      -- this packet is first legit packet after error:
      send(x"AAAAA004");
      send(x"5C5C0000");
      send(x"00001111");
      send(x"00002222");
      send(x"00003333");
      send(x"00004444");
      send(x"6D83740F");
      ack;                -- ack for CRC error
      pause(5);
      ack;                -- ack x 4 for data
      pause(10);
      ack;
      ack;
      pause(10);
      ack;

      
      ------------------------------------------------------      
      -- Test 6: Read packet has corrupt data size
      --         (Corruption made it smaller)
      ------------------------------------------------------
      
      
      send(x"AAAAA001");
      send(x"6A6A0000");
      send(x"00001111");  -- thinks this is the CRC
      send(x"00002222");  -- ignored (invalid preamble)
      send(x"00003333");  -- ignored (invalid preamble)
      send(x"E1D64CB1");  -- ignored (invalid preamble)
      ack;      
      
      -- this packet has no errors:
      send(x"AAAAA003");
      send(x"6B6B0000");
      send(x"00001111");  
      send(x"00002222");  
      send(x"00003333");  
      send(x"A14F7442");  
      ack;
      pause(10);
      ack;
      pause(10);
      ack;

      
      ------------------------------------------------------
      -- Test 7: Write packet returned with status info
      ------------------------------------------------------

      send(x"AAAAA800");
      send(x"07070002");
      send(x"8D78E359");
      ack;
      
      
      ------------------------------------------------------
      -- Test 8: Read packet returned with status info
      ------------------------------------------------------
      
      send(x"AAAAA004");
      send(x"08080001");
      send(x"00001111");
      send(x"00002222");
      send(x"00003333");
      send(x"00004444");
      send(x"AE7D6F71");
      ack;
      ack;
      ack;
      pause(10);
      ack;
      
      
      ------------------------------------------------------
      -- Test 9: Read packet timed out, queue is reset
      ------------------------------------------------------
      
      send(x"AAAAA003");
      send(x"09090000");
      send(x"00001111");
      send(x"00002222");
      send(x"00003333");
      send(x"A25350D3");
      wait for 15 us;
      clear;
      
      
      pause(500);
         
            
      -------------------------------------------------------------------
      -- End of Test Cases
      ------------------------------------------------------------------- 
      
      assert FALSE report "End of Simulation." severity FAILURE;
      
      wait for PERIOD;
      wait;
   end process STIMULI;

end BEH;