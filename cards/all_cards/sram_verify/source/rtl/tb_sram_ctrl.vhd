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

-- tb_sram_ctrl.vhd
--
-- <revision control keyword substitutions e.g. $Id$>
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Testbench for SRAM controller
--
-- Revision history:
-- <date $Date$>	-		<text>		- <initials $Author$>

--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library sys_param;
use sys_param.wishbone_pack.all;
use sys_param.general_pack.all;

entity TB_SRAM_CTRL is
end TB_SRAM_CTRL;

architecture BEH of TB_SRAM_CTRL is

   component SRAM_CTRL

      generic(ADDR_WIDTH       : integer  := WB_ADDR_WIDTH ;
              DATA_WIDTH       : integer  := WB_DATA_WIDTH ;
              TAG_ADDR_WIDTH   : integer  := WB_TAG_ADDR_WIDTH );

      port(ADDR_O    : out std_logic_vector ( 19 downto 0 );
           DATA_BI   : inout std_logic_vector ( 15 downto 0 );
           N_BLE_O   : out std_logic ;
           N_BHE_O   : out std_logic ;
           N_OE_O    : out std_logic ;
           N_CE1_O   : out std_logic ;
           CE2_O     : out std_logic ;
           N_WE_O    : out std_logic ;
           CLK_I     : in std_logic ;
           RST_I     : in std_logic ;
           DAT_I     : in std_logic_vector ( DATA_WIDTH - 1 downto 0 );
           ADDR_I    : in std_logic_vector ( ADDR_WIDTH - 1 downto 0 );
           TGA_I     : in std_logic_vector ( TAG_ADDR_WIDTH - 1 downto 0 );
           WE_I      : in std_logic ;
           STB_I     : in std_logic ;
           CYC_I     : in std_logic ;
           DAT_O     : out std_logic_vector ( DATA_WIDTH - 1 downto 0 );
           RTY_O     : out std_logic ;
           ACK_O     : out std_logic );

   end component;


   -- SRAM address and data in
   constant ADDRESS_0 : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
   constant ADDRESS_1 : std_logic_vector(31 downto 0) := "00000000000000000000000000000001";
   constant ADDRESS_2 : std_logic_vector(31 downto 0) := "00000000000000000000000000000010";
   constant ADDRESS_3 : std_logic_vector(31 downto 0) := "00000000000000000000000000000011";

   constant DATA_IN_0 : std_logic_vector(31 downto 0) := "00010010001101000101011001111000"; -- 0x12345678
   constant DATA_IN_1 : std_logic_vector(31 downto 0) := "10011011101011011100101010110000"; -- 0x9BADCAB0
   constant DATA_IN_2 : std_logic_vector(31 downto 0) := "11001010111111100000111110111100"; -- 0xCAFE0FBC
   constant DATA_IN_3 : std_logic_vector(31 downto 0) := "11011110101011011011101010111110"; -- 0xDEADBABE
           
 
   signal W_ADDR_O    : std_logic_vector ( 19 downto 0 );
   signal W_DATA_BI   : std_logic_vector ( 15 downto 0 );
   signal W_N_BLE_O   : std_logic ;
   signal W_N_BHE_O   : std_logic ;
   signal W_N_OE_O    : std_logic ;
   signal W_N_CE1_O   : std_logic ;
   signal W_CE2_O     : std_logic ;
   signal W_N_WE_O    : std_logic ;
   signal W_CLK_I     : std_logic := '0';
   signal W_RST_I     : std_logic ;
   signal W_DAT_I     : std_logic_vector ( 31 downto 0 );
   signal W_ADDR_I    : std_logic_vector ( 7 downto 0 );
   signal W_TGA_I     : std_logic_vector ( 31 downto 0 );
   signal W_WE_I      : std_logic ;
   signal W_STB_I     : std_logic ;
   signal W_CYC_I     : std_logic ;
   signal W_DAT_O     : std_logic_vector ( 31 downto 0 );
   signal W_RTY_O     : std_logic ;
   signal W_ACK_O     : std_logic ;

   type regarray is array (7 downto 0) of std_logic_vector(15 downto 0);
   signal sram : regarray;
   
begin

   DUT : SRAM_CTRL

      generic map(ADDR_WIDTH       => WB_ADDR_WIDTH ,
                  DATA_WIDTH       => WB_DATA_WIDTH ,
                  TAG_ADDR_WIDTH   => WB_TAG_ADDR_WIDTH )

      port map(ADDR_O    => W_ADDR_O,
               DATA_BI   => W_DATA_BI,
               N_BLE_O   => W_N_BLE_O,
               N_BHE_O   => W_N_BHE_O,
               N_OE_O    => W_N_OE_O,
               N_CE1_O   => W_N_CE1_O,
               CE2_O     => W_CE2_O,
               N_WE_O    => W_N_WE_O,
               CLK_I     => W_CLK_I,
               RST_I     => W_RST_I,
               DAT_I     => W_DAT_I,
               ADDR_I    => W_ADDR_I,
               TGA_I     => W_TGA_I,
               WE_I      => W_WE_I,
               STB_I     => W_STB_I,
               CYC_I     => W_CYC_I,
               DAT_O     => W_DAT_O,
               RTY_O     => W_RTY_O,
               ACK_O     => W_ACK_O);

   W_CLK_I <= not W_CLK_I after CLOCK_PERIOD/2;

   STIMULI : process
   
   procedure system_reset is
   begin
      W_RST_I     <= '1';
      W_DAT_I     <= (others => '0');
      W_ADDR_I    <= (others => '0');
      W_TGA_I     <= (others => '0');
      W_WE_I      <= '0';
      W_STB_I     <= '0';
      W_CYC_I     <= '0';
      
      sram(0) <= (others =>'0');
      sram(1) <= (others =>'0');
      sram(2) <= (others =>'0');
      sram(3) <= (others =>'0');
      sram(4) <= (others =>'0');
      sram(5) <= (others =>'0');
      sram(6) <= (others =>'0');
      sram(7) <= (others =>'0');
      
   end system_reset;
   

   
   procedure write_single is
   begin
      W_RST_I     <= '0';
      W_DAT_I     <= DATA_IN_0;
      W_ADDR_I    <= SRAM_ADDR;
      W_TGA_I     <= ADDRESS_0;
      W_WE_I      <= '1';
      W_STB_I     <= '1';
      W_CYC_I     <= '1';
      
      wait until (W_ADDR_O = "00000000000000000000" and W_CE2_O = '1' and W_N_CE1_O = '0' and W_N_WE_O = '0');
         
      sram(0) <= W_DATA_BI;
      
      wait until W_ADDR_O'event;
      
      -- we know ACK is high here, this is last byte of data in this transaction
      sram(1) <= W_DATA_BI;
      
      -- emulating the master's perspective
      wait until W_ACK_O = '0';
      
      W_STB_I <= '0';
      W_CYC_I <= '0';
      W_WE_I  <= '0';
      
   end write_single;
   
   
   procedure write_multiple is
   begin
      -- cycle 1:
      W_RST_I     <= '0';
      W_DAT_I     <= DATA_IN_1;
      W_ADDR_I    <= SRAM_ADDR;
      W_TGA_I     <= ADDRESS_1;
      W_WE_I      <= '1';
      W_STB_I     <= '1';
      W_CYC_I     <= '1';
      
      wait until W_ACK_O = '1';
      
      -- cycle 2:
      W_RST_I     <= '0';
      W_DAT_I     <= DATA_IN_2;
      W_ADDR_I    <= SRAM_ADDR;
      W_TGA_I     <= ADDRESS_2;
      W_WE_I      <= '1';
      W_STB_I     <= '1';
      W_CYC_I     <= '1';
      
      wait until W_ACK_O = '1';
      
      -- cycle 3:
      W_RST_I     <= '0';
      W_DAT_I     <= DATA_IN_3;
      W_ADDR_I    <= SRAM_ADDR;
      W_TGA_I     <= ADDRESS_3;
      W_WE_I      <= '1';
      W_STB_I     <= '1';
      W_CYC_I     <= '1';
      
      wait until W_ACK_O = '1';
      
      -- end cycle:
      W_STB_I <= '0';
      W_CYC_I <= '0';
      W_WE_I  <= '0';
      
   end write_multiple;
   
   
   procedure read_0 is
   begin
      W_RST_I     <= '0';
      W_DAT_I     <= (others => '0');
      W_ADDR_I    <= SRAM_ADDR;
      W_TGA_I     <= ADDRESS_0;
      W_WE_I      <= '0';
      W_STB_I     <= '1';
      W_CYC_I     <= '1';
      
      wait until W_CE2_O = '1' and W_N_CE1_O = '0' and W_N_WE_O = '1' and W_N_BLE_O = '0' and W_N_BHE_O = '0';

      wait until W_ADDR_O = "00000000000000000000";      
      W_DATA_BI <= sram(0);
      
      wait until W_ADDR_O = "00000000000000000001";
      W_DATA_BI <= sram(1);
   end read_0;
   
   procedure read_1 is
   begin
      W_RST_I     <= '0';
      W_DAT_I     <= (others => '0');
      W_ADDR_I    <= SRAM_ADDR;
      W_TGA_I     <= ADDRESS_1;
      W_WE_I      <= '0';
      W_STB_I     <= '1';
      W_CYC_I     <= '1';
      
      wait until W_CE2_O = '1' and W_N_CE1_O = '0' and W_N_WE_O = '1' and W_N_BLE_O = '0' and W_N_BHE_O = '0';

      wait until W_ADDR_O = "00000000000000000010";      
      W_DATA_BI <= sram(2);
      
      wait until W_ADDR_O = "00000000000000000011";
      W_DATA_BI <= sram(3);
   end read_1;
   
   
 
   begin
      W_DATA_BI   <= (others =>'Z');
   
      system_reset;
      
      wait for CLOCK_PERIOD*2;
      
      write_single;
      
      wait for CLOCK_PERIOD*2;
      
      write_multiple;

--      write_1;
--      read_2;
--      read_3;
--      write_2;
--      write_3;
--      read_0;
--      read_1;
--      read_2;
--      read_3;
      
      wait for CLOCK_PERIOD;
      wait;
   end process STIMULI;

end BEH;
