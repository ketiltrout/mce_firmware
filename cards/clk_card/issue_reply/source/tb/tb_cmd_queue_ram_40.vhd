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
-- tb_cmd_queue_ram_40.vhd
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Testbench for command queue 3-port RAM
--
-- Revision history:
-- 
-- $Log: tb_cmd_queue_ram_40.vhd,v $
-- Revision 1.1  2004/08/03 23:42:35  erniel
-- initial version
--
--
-----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity TB_CMD_QUEUE_RAM40 is
end TB_CMD_QUEUE_RAM40;

architecture BEH of TB_CMD_QUEUE_RAM40 is

   component CMD_QUEUE_RAM40
      port(DATA          : IN STD_LOGIC_VECTOR ( 31 DOWNTO 0 );
           WRADDRESS     : IN STD_LOGIC_VECTOR ( 7 DOWNTO 0 );
           RDADDRESS_A   : IN STD_LOGIC_VECTOR ( 7 DOWNTO 0 );
           RDADDRESS_B   : IN STD_LOGIC_VECTOR ( 7 DOWNTO 0 );
           WREN          : IN STD_LOGIC := '1' ;
           CLOCK         : IN STD_LOGIC ;
           QA            : OUT STD_LOGIC_VECTOR ( 31 DOWNTO 0 );
           QB            : OUT STD_LOGIC_VECTOR ( 31 DOWNTO 0 ) );

   end component;


   constant PERIOD : time := 10 ns;

   signal W_DATA          : STD_LOGIC_VECTOR ( 31 DOWNTO 0 );
   signal W_WRADDRESS     : STD_LOGIC_VECTOR ( 7 DOWNTO 0 );
   signal W_RDADDRESS_A   : STD_LOGIC_VECTOR ( 7 DOWNTO 0 );
   signal W_RDADDRESS_B   : STD_LOGIC_VECTOR ( 7 DOWNTO 0 );
   signal W_WREN          : STD_LOGIC := '1' ;
   signal W_CLOCK         : STD_LOGIC  := '0';
   signal W_QA            : STD_LOGIC_VECTOR ( 31 DOWNTO 0 );
   signal W_QB            : STD_LOGIC_VECTOR ( 31 DOWNTO 0 ) ;

begin

   DUT : CMD_QUEUE_RAM40
      port map(DATA          => W_DATA,
               WRADDRESS     => W_WRADDRESS,
               RDADDRESS_A   => W_RDADDRESS_A,
               RDADDRESS_B   => W_RDADDRESS_B,
               WREN          => W_WREN,
               CLOCK         => W_CLOCK,
               QA            => W_QA,
               QB            => W_QB);

   W_CLOCK <= not W_CLOCK after PERIOD/2;

   STIMULI : process
   procedure write(data : in std_logic_vector(31 downto 0);
                   addr : in std_logic_vector(7 downto 0)) is
   begin
      W_DATA          <= data;
      W_WRADDRESS     <= addr;
      W_RDADDRESS_A   <= (others => '0');
      W_RDADDRESS_B   <= (others => '0');
      W_WREN          <= '1';
      
      wait for PERIOD;
   end write;
   
   procedure read(addrA : in std_logic_vector(7 downto 0);
                  addrB : in std_logic_vector(7 downto 0)) is
   begin
      W_DATA          <= (others => '0');
      W_WRADDRESS     <= (others => '0');
      W_RDADDRESS_A   <= addrA;
      W_RDADDRESS_B   <= addrB;
      W_WREN          <= '0';
      
      wait for PERIOD;
   end read;
   
  
   begin
      write("00000000000000000000000000001111", "00000000");
      write("00000000000000000000000011110000", "00000001");
      write("00000000000000000000111100000000", "00000010");
      write("00000000000000001111000000000000", "00000011");
      write("00000000000011110000000000000000", "00000100");
      write("00000000111100000000000000000000", "00000101");
      write("00001111000000000000000000000000", "00000110");
      write("11110000000000000000000000000000", "00000111");
      
      read("00000000", "00000000");
      read("00000010", "00000001");
      read("00000100", "00000010");
      read("00000110", "00000011");
      read("00000001", "00000100");
      read("00000011", "00000101");
      read("00000101", "00000110");
      read("00000000", "00000111");
      read("00000001", "00000000");
      read("00000011", "00000001");
      read("00000111", "00000010");
      read("00000000", "00000011");
      read("00000111", "00000100");
      
      assert false report "End of Simulation." severity FAILURE;
      
      wait for PERIOD;
      wait;
   end process STIMULI;

end BEH;