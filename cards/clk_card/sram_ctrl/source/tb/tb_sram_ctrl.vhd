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
-- <revision control keyword substitutions e.g. $Id: tb_sram_ctrl.vhd,v 1.2 2004/04/21 19:58:39 bburger Exp $>
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Testbench for SRAM controller
--
-- Revision history:
-- <date $Date: 2004/04/21 19:58:39 $>	-		<text>		- <initials $Author: bburger $>

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

   component SRAM
      port(ADDRESS   : in std_logic_vector ( 19 downto 0 );
           DATA      : inout std_logic_vector ( 15 downto 0 );
           N_BHE     : in std_logic ;
           N_BLE     : in std_logic ;
           N_OE      : in std_logic ;
           N_WE      : in std_logic ;
           N_CE1     : in std_logic ;
           CE2       : in std_logic ;
           RESET     : in std_logic);

   end component;

   -- SRAM address and data in
   constant ADDRESS0 : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
   constant ADDRESS1 : std_logic_vector(31 downto 0) := "00000000000000000000000000000001";
   constant ADDRESS2 : std_logic_vector(31 downto 0) := "00000000000000000000000000000010";
   constant ADDRESS3 : std_logic_vector(31 downto 0) := "00000000000000000000000000000011";


   constant DATA0 : std_logic_vector(31 downto 0) := "00010010001101000101011001111000"; -- 0x12345678
   constant DATA1 : std_logic_vector(31 downto 0) := "10011011101011011100101010110000"; -- 0x9BADCAB0
   constant DATA2 : std_logic_vector(31 downto 0) := "11001010111111100000111110111100"; -- 0xCAFE0FBC
   constant DATA3 : std_logic_vector(31 downto 0) := "11011110101011011011101010111110"; -- 0xDEADBABE
   constant DATA4 : std_logic_vector(31 downto 0) := "11011110101011011100101011111110"; -- 0xDEADCAFE
   constant DATA5 : std_logic_vector(31 downto 0) := "10101011110011010001001000110100"; -- 0xABCD1234
   constant DATA6 : std_logic_vector(31 downto 0) := "10101011101011011100101011111110"; -- 0xABADCAFE
   constant DATA7 : std_logic_vector(31 downto 0) := "00001111001111000101101010100101"; -- 0x0F3C5AA5
           
 
   signal W_ADDR_O    : std_logic_vector ( 19 downto 0 );
   signal W_DATA_BI   : std_logic_vector ( 15 downto 0 );
   signal W_N_BLE_O   : std_logic ;
   signal W_N_BHE_O   : std_logic ;
   signal W_N_OE_O    : std_logic ;
   signal W_N_CE1_O   : std_logic ;
   signal W_CE2_O     : std_logic ;
   signal W_N_WE_O    : std_logic ;
   signal W_CLK_I     : std_logic := '1';
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

   SRAM_MODEL : SRAM
      port map(ADDRESS   => W_ADDR_O,
               DATA      => W_DATA_BI,
               N_BHE     => W_N_BHE_O,
               N_BLE     => W_N_BLE_O,
               N_OE      => W_N_OE_O,
               N_WE      => W_N_WE_O,
               N_CE1     => W_N_CE1_O,
               CE2       => W_CE2_O,
               RESET     => W_RST_I);

   W_CLK_I <= not W_CLK_I after CLOCK_PERIOD/2;

   STIMULI : process


------------------------------------------------------------
--
-- Reset controller
--
------------------------------------------------------------

   procedure system_reset is
   begin
      W_RST_I     <= '1';
      W_DAT_I     <= (others => '0');
      W_ADDR_I    <= (others => '0');
      W_TGA_I     <= (others => '0');
      W_WE_I      <= '0';
      W_STB_I     <= '0';
      W_CYC_I     <= '0';
     
   end system_reset;
   

------------------------------------------------------------
--
-- Single write
--
------------------------------------------------------------
   
   procedure write_single (addr : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
                           data : in std_logic_vector(WB_DATA_WIDTH-1 downto 0)) is
   begin
      W_RST_I     <= '0';
      W_DAT_I     <= data;
      W_ADDR_I    <= SRAM1_ADDR;
      W_TGA_I     <= addr;
      W_WE_I      <= '1';
      W_STB_I     <= '1';
      W_CYC_I     <= '1';
      
      wait until W_ACK_O = '1';
      
      -- end cycle:
      W_STB_I     <= '0';
      W_CYC_I     <= '0';
      W_WE_I      <= '0';
      
   end write_single;
   
  
------------------------------------------------------------
--
-- Multiple write
--
------------------------------------------------------------
 
   procedure write_triple (addr1 : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
                           addr2 : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
                           addr3 : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
                           data1 : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
                           data2 : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
                           data3 : in std_logic_vector(WB_DATA_WIDTH-1 downto 0)) is
   begin
      -- cycle 1:
      W_RST_I     <= '0';
      W_DAT_I     <= data1;
      W_ADDR_I    <= SRAM1_ADDR;
      W_TGA_I     <= addr1;
      W_WE_I      <= '1';
      W_STB_I     <= '1';
      W_CYC_I     <= '1';
      
      wait until W_ACK_O = '1';
      
      -- cycle 2:
      W_RST_I     <= '0';
      W_DAT_I     <= data2;
      W_ADDR_I    <= SRAM1_ADDR;
      W_TGA_I     <= addr2;
      W_WE_I      <= '1';
      W_STB_I     <= '1';
      W_CYC_I     <= '1';
      
      wait until W_ACK_O = '1';
      
      -- cycle 3:
      W_RST_I     <= '0';
      W_DAT_I     <= data3;
      W_ADDR_I    <= SRAM1_ADDR;
      W_TGA_I     <= addr3;
      W_WE_I      <= '1';
      W_STB_I     <= '1';
      W_CYC_I     <= '1';
      
      wait until W_ACK_O = '1';
      
      -- end cycle:
      W_STB_I     <= '0';
      W_CYC_I     <= '0';
      W_WE_I      <= '0';
      
   end write_triple;
   
   
------------------------------------------------------------
--
-- Multiple write with master wait states inserted
--
------------------------------------------------------------
 
   procedure write_triple_wait_state (addr1 : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
                                      addr2 : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
                                      addr3 : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
                                      data1 : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
                                      data2 : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
                                      data3 : in std_logic_vector(WB_DATA_WIDTH-1 downto 0)) is
   begin
      -- cycle 1:
      W_RST_I     <= '0';
      W_DAT_I     <= data1;
      W_ADDR_I    <= SRAM1_ADDR;
      W_TGA_I     <= addr1;
      W_WE_I      <= '1';
      W_STB_I     <= '1';
      W_CYC_I     <= '1';
      
      wait until W_ACK_O = '1';
      
      -- wait state:
      
      W_STB_I     <= '0';
      wait for CLOCK_PERIOD * 3;
      
      -- cycle 2:
      W_RST_I     <= '0';
      W_DAT_I     <= data2;
      W_ADDR_I    <= SRAM1_ADDR;
      W_TGA_I     <= addr2;
      W_WE_I      <= '1';
      W_STB_I     <= '1';
      W_CYC_I     <= '1';
      
      wait until W_ACK_O = '1';
      
      -- cycle 3:
      W_RST_I     <= '0';
      W_DAT_I     <= data3;
      W_ADDR_I    <= SRAM1_ADDR;
      W_TGA_I     <= addr3;
      W_WE_I      <= '1';
      W_STB_I     <= '1';
      W_CYC_I     <= '1';
      
      wait until W_ACK_O = '1';
      
      -- end cycle:
      W_STB_I     <= '0';
      W_CYC_I     <= '0';
      W_WE_I      <= '0';
      
   end write_triple_wait_state;
   
      
------------------------------------------------------------
--
-- Single read
--
------------------------------------------------------------
   
   procedure read_single (addr : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0)) is
   begin
      W_RST_I     <= '0';
      W_DAT_I     <= (others => '0');
      W_ADDR_I    <= SRAM1_ADDR;
      W_TGA_I     <= addr;
      W_WE_I      <= '0';
      W_STB_I     <= '1';
      W_CYC_I     <= '1';
      
      wait until W_ACK_O = '1';
      
      -- end cycle:
      W_STB_I     <= '0';
      W_CYC_I     <= '0';
      W_WE_I      <= '0';
      
   end read_single;
   
   
------------------------------------------------------------
--
-- Multiple read
--
------------------------------------------------------------
   
   procedure read_triple (addr1 : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
                          addr2 : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
                          addr3 : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0)) is
   begin
      -- cycle 1:
      W_RST_I     <= '0';
      W_DAT_I     <= (others => '0');
      W_ADDR_I    <= SRAM1_ADDR;
      W_TGA_I     <= addr1;
      W_WE_I      <= '0';
      W_STB_I     <= '1';
      W_CYC_I     <= '1';
      
      wait until W_ACK_O = '1';
      
      -- cycle 2:
      W_RST_I     <= '0';
      W_DAT_I     <= (others => '0');
      W_ADDR_I    <= SRAM1_ADDR;
      W_TGA_I     <= addr2;
      W_WE_I      <= '0';
      W_STB_I     <= '1';
      W_CYC_I     <= '1';
      
      wait until W_ACK_O = '1';
      
      -- cycle 3:
      W_RST_I     <= '0';
      W_DAT_I     <= (others => '0');
      W_ADDR_I    <= SRAM1_ADDR;
      W_TGA_I     <= addr3;
      W_WE_I      <= '0';
      W_STB_I     <= '1';
      W_CYC_I     <= '1';
      
      wait until W_ACK_O = '1';
      
      -- end cycle:
      W_STB_I     <= '0';
      W_CYC_I     <= '0';
      W_WE_I      <= '0';
      
   end read_triple;


------------------------------------------------------------
--
-- Multiple read with master wait states inserted
--
------------------------------------------------------------

   procedure read_triple_wait_state (addr1 : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
                                     addr2 : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
                                     addr3 : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0)) is
   begin
      -- cycle 1:
      W_RST_I     <= '0';
      W_DAT_I     <= (others => '0');
      W_ADDR_I    <= SRAM1_ADDR;
      W_TGA_I     <= addr1;
      W_WE_I      <= '0';
      W_STB_I     <= '1';
      W_CYC_I     <= '1';
      
      wait until W_ACK_O = '1';
      
      -- wait state:
      
      W_STB_I     <= '0';
      wait for CLOCK_PERIOD * 3;
      
      -- cycle 2:
      W_RST_I     <= '0';
      W_DAT_I     <= (others => '0');
      W_ADDR_I    <= SRAM1_ADDR;
      W_TGA_I     <= addr2;
      W_WE_I      <= '0';
      W_STB_I     <= '1';
      W_CYC_I     <= '1';
      
      wait until W_ACK_O = '1';
      
      -- cycle 3:
      W_RST_I     <= '0';
      W_DAT_I     <= (others => '0');
      W_ADDR_I    <= SRAM1_ADDR;
      W_TGA_I     <= addr3;
      W_WE_I      <= '0';
      W_STB_I     <= '1';
      W_CYC_I     <= '1';
      
      wait until W_ACK_O = '1';
      
      -- end cycle:
      W_STB_I     <= '0';
      W_CYC_I     <= '0';
      W_WE_I      <= '0';
      
   end read_triple_wait_state;
   

------------------------------------------------------------
--
-- Verify SRAM
--
------------------------------------------------------------   

   procedure verify is
   begin
      -- start verify:
      W_RST_I     <= '0';
      W_DAT_I     <= (others => '0');
      W_ADDR_I    <= VRFY_SRAM1_ADDR;
      W_TGA_I     <= (others => '0');
      W_WE_I      <= '0';
      W_STB_I     <= '1';
      W_CYC_I     <= '1';
      
      wait until W_RTY_O = '1';
      
      -- rty_o asserted, so end cycle:
      W_RST_I     <= '0';
      W_DAT_I     <= (others => '0');
      W_ADDR_I    <= (others => '0');
      W_TGA_I     <= (others => '0');
      W_STB_I     <= '0';
      W_CYC_I     <= '0';
      W_WE_I      <= '0';
      
      wait for CLOCK_PERIOD * 30;
      
      -- try again:
      W_RST_I     <= '0';
      W_DAT_I     <= (others => '0');
      W_ADDR_I    <= VRFY_SRAM1_ADDR;
      W_TGA_I     <= (others => '0');
      W_WE_I      <= '0';
      W_STB_I     <= '1';
      W_CYC_I     <= '1';
      
      wait for CLOCK_PERIOD;
      
      -- rty_o should still be asserted, so end cycle:
      W_RST_I     <= '0';
      W_DAT_I     <= (others => '0');
      W_ADDR_I    <= (others => '0');
      W_TGA_I     <= (others => '0');
      W_STB_I     <= '0';
      W_CYC_I     <= '0';
      W_WE_I      <= '0';
      
      -- wait until rty_o is deasserted (signals end of verification process)
      wait until W_RTY_O = '0';
      
      wait for CLOCK_PERIOD * 15;
      
      -- try again:
      W_RST_I     <= '0';
      W_DAT_I     <= (others => '0');
      W_ADDR_I    <= VRFY_SRAM1_ADDR;
      W_TGA_I     <= (others => '0');
      W_WE_I      <= '0';
      W_STB_I     <= '1';
      W_CYC_I     <= '1';
      
      wait until W_ACK_O = '1';
      
      -- end cycle:
      W_RST_I     <= '0';
      W_DAT_I     <= (others => '0');
      W_ADDR_I    <= (others => '0');
      W_TGA_I     <= (others => '0');
      W_STB_I     <= '0';
      W_CYC_I     <= '0';
      W_WE_I      <= '0';
      
   end verify;
 
   
------------------------------------------------------------
--
-- Verify SRAM Again
--
------------------------------------------------------------   

   procedure verify_again is
   begin
      -- start verify:
      W_RST_I     <= '0';
      W_DAT_I     <= (others => '0');
      W_ADDR_I    <= VRFY_SRAM1_ADDR;
      W_TGA_I     <= (others => '0');
      W_WE_I      <= '0';
      W_STB_I     <= '1';
      W_CYC_I     <= '1';
      
      wait until W_ACK_O = '1';
      
      -- end cycle:
      W_RST_I     <= '0';
      W_DAT_I     <= (others => '0');
      W_ADDR_I    <= (others => '0');
      W_TGA_I     <= (others => '0');
      W_STB_I     <= '0';
      W_CYC_I     <= '0';
      W_WE_I      <= '0';
      
   end verify_again;   
   

------------------------------------------------------------
--
-- No Operation
--
------------------------------------------------------------   

   procedure no_op is
   begin
      wait for CLOCK_PERIOD * 5;
   end no_op;    


   begin
      W_DATA_BI   <= (others =>'Z');
   
      system_reset;
      no_op;
      
      verify;
      no_op;
      
      verify_again;
      no_op;
      
      write_single(ADDRESS0, DATA0);
      no_op;
      
      write_triple(ADDRESS1, ADDRESS2, ADDRESS3, DATA1, DATA2, DATA3);
      no_op;
      
      write_triple_wait_state(ADDRESS2, ADDRESS0, ADDRESS1, DATA4, DATA5, DATA6);
      no_op;
      
      read_single(ADDRESS0);
      no_op;
      
      read_triple(ADDRESS1, ADDRESS2, ADDRESS3);
      no_op;
      
      read_triple_wait_state(ADDRESS0, ADDRESS1, ADDRESS2);
      no_op;
      
      wait;
   end process STIMULI;

end BEH;
