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
-- tb_fifo.vhd
--
-- Project:	      SCUBA-2
-- Author:        Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Testbench for parameterized show-ahead FIFO
--
-- Revision history:
-- 
-- $Log$
--
-----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity TB_FIFO is
end TB_FIFO;

architecture BEH of TB_FIFO is

   component FIFO

      generic(DATA_WIDTH   : integer  := 32 ;
              ADDR_WIDTH   : integer  := 8 );

      port(CLK_I       : in std_logic ;
           MEM_CLK_I   : in std_logic ;
           RST_I       : in std_logic ;
           DATA_I      : in std_logic_vector ( DATA_WIDTH - 1 downto 0 );
           DATA_O      : out std_logic_vector ( DATA_WIDTH - 1 downto 0 );
           READ_I      : in std_logic ;
           WRITE_I     : in std_logic ;
           CLEAR_I     : in std_logic ;
           EMPTY_O     : out std_logic ;
           FULL_O      : out std_logic ;
           ERROR_O     : out std_logic ;
           USED_O      : out integer );

   end component;


   constant PERIOD : time := 20 ns;
   constant MEM_PERIOD : time := 4 ns;

   constant DATA_WIDTH : integer := 8;
   
   signal W_CLK_I       : std_logic := '1';
   signal W_MEM_CLK_I   : std_logic := '1';
   signal W_RST_I       : std_logic ;
   signal W_DATA_I      : std_logic_vector ( DATA_WIDTH - 1 downto 0 );
   signal W_DATA_O      : std_logic_vector ( DATA_WIDTH - 1 downto 0 );
   signal W_READ_I      : std_logic ;
   signal W_WRITE_I     : std_logic ;
   signal W_CLEAR_I     : std_logic ;
   signal W_EMPTY_O     : std_logic ;
   signal W_FULL_O      : std_logic ;
   signal W_ERROR_O     : std_logic ;
   signal W_USED_O      : integer ;

begin

   DUT : FIFO

      generic map(DATA_WIDTH   => 8 ,
                  ADDR_WIDTH   => 2 )

      port map(CLK_I       => W_CLK_I,
               MEM_CLK_I   => W_MEM_CLK_I,
               RST_I       => W_RST_I,
               DATA_I      => W_DATA_I,
               DATA_O      => W_DATA_O,
               READ_I      => W_READ_I,
               WRITE_I     => W_WRITE_I,
               CLEAR_I     => W_CLEAR_I,
               EMPTY_O     => W_EMPTY_O,
               FULL_O      => W_FULL_O,
               ERROR_O     => W_ERROR_O,
               USED_O      => W_USED_O);

   W_CLK_I       <= not W_CLK_I after PERIOD/2;
   W_MEM_CLK_I   <= not W_MEM_CLK_I after MEM_PERIOD/2;

   STIMULI : process
   procedure do_reset is
   begin
      W_RST_I       <= '1';
      W_DATA_I      <= (others => '0');
      W_READ_I      <= '0';
      W_WRITE_I     <= '0';
      W_CLEAR_I     <= '0';
      
      wait for PERIOD;
   end do_reset;
   
   procedure do_write (data : std_logic_vector(DATA_WIDTH-1 downto 0)) is
   begin
      W_RST_I       <= '0';
      W_DATA_I      <= data;
      W_READ_I      <= '0';
      W_WRITE_I     <= '1';
      W_CLEAR_I     <= '0';
      
      wait for PERIOD;
   end do_write;
   
   procedure do_read is
   begin
      W_RST_I       <= '0';
      W_DATA_I      <= (others => '0');
      W_READ_I      <= '1';
      W_WRITE_I     <= '0';
      W_CLEAR_I     <= '0';   
      
      wait for PERIOD;
   end do_read;
   
   procedure do_clear is
   begin
      W_RST_I       <= '0';
      W_DATA_I      <= (others => '0');
      W_READ_I      <= '0';
      W_WRITE_I     <= '0';
      W_CLEAR_I     <= '1'; 
      
      wait for PERIOD;  
   end do_clear;
   
   begin
   
      do_reset;
      
      do_write("00000001");
      do_write("00000010");
      do_write("00000100");
      do_write("00001000");
      do_write("00010000");  -- fifo is full, should not be added (write disabled)
      
      do_clear;
      
      do_read;
      do_read;
      
      do_write("10000000");
      
      do_read;
      do_read;
      
      do_clear;
      
      do_read;               -- fifo is empty (read disabled)
      
      assert false report "End of simulation" severity FAILURE;

   end process STIMULI;

end BEH;