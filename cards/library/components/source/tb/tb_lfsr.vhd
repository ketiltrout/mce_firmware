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
-- tb_lfsr.vhd
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Testbench for parameterized linear feedback shift register
--
-- Revision history:
-- 
-- $Log: tb_lfsr.vhd,v $
-- Revision 1.1  2004/07/07 19:29:17  erniel
-- initial version
--
--
-----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity TB_LFSR is
end TB_LFSR;

architecture BEH of TB_LFSR is

   component LFSR

      generic(WIDTH   : in integer range 3 to 64  := 8 );

      port(CLK          : in std_logic ;
           RST          : in std_logic ;
           ENA          : in std_logic ;
           LOAD         : in std_logic ;
           CLR          : in std_logic ;
           PARALLEL_I   : in std_logic_vector ( WIDTH - 1 downto 0 );
           PARALLEL_O   : out std_logic_vector ( WIDTH - 1 downto 0 ) );

   end component;


   constant PERIOD : time := 20 ns;

   signal W_CLK          : std_logic  := '0';
   signal W_RST          : std_logic ;
   signal W_ENA          : std_logic ;
   signal W_LOAD         : std_logic ;
   signal W_CLR          : std_logic ;
   signal W_DATAI1       : std_logic_vector ( 2 downto 0 ) ;
   signal W_DATAO1       : std_logic_vector ( 2 downto 0 ) ;
   signal W_DATAI2       : std_logic_vector ( 3 downto 0 ) ;
   signal W_DATAO2       : std_logic_vector ( 3 downto 0 ) ;
   
begin

   DUT1 : LFSR

      generic map(WIDTH   => 3 )

      port map(CLK          => W_CLK,
               RST          => W_RST,
               ENA          => W_ENA,
               LOAD         => W_LOAD,
               CLR          => W_CLR,
               PARALLEL_I   => W_DATAI1,
               PARALLEL_O   => W_DATAO1);

   DUT2 : LFSR

      generic map(WIDTH   => 4 )

      port map(CLK          => W_CLK,
               RST          => W_RST,
               ENA          => W_ENA,
               LOAD         => W_LOAD,
               CLR          => W_CLR,
               PARALLEL_I   => W_DATAI2,
               PARALLEL_O   => W_DATAO2);
               
   W_CLK <= not W_CLK after PERIOD/2;

   STIMULI : process
   procedure reset is
   begin
      W_RST          <= '1';
      W_ENA          <= '0';
      W_LOAD         <= '0';
      W_CLR          <= '0';
      W_DATAI1       <= (others => '0');
      W_DATAI2       <= (others => '0');
      
      wait for PERIOD;
      
      W_RST          <= '0';
      W_ENA          <= '0';
      W_LOAD         <= '0';
      W_CLR          <= '0';
      W_DATAI1       <= (others => '0');
      W_DATAI2       <= (others => '0');
      
      wait for PERIOD;
   end reset;
   
   procedure enable_LFSR is
   begin
      W_RST          <= '0';
      W_ENA          <= '1';
      W_LOAD         <= '0';
      W_CLR          <= '0';
      W_DATAI1       <= (others => '0');
      W_DATAI2       <= (others => '0');
      
      wait for PERIOD;
   end enable_LFSR;
   
   procedure disable_LFSR is
   begin
      W_RST          <= '0';
      W_ENA          <= '0';
      W_LOAD         <= '0';
      W_CLR          <= '0';
      W_DATAI1       <= (others => '0');
      W_DATAI2       <= (others => '0');
      
      wait for PERIOD;
   end disable_LFSR;
   
   procedure load_LFSR1(data : in std_logic_vector(2 downto 0)) is
   begin
      W_RST          <= '0';
      W_ENA          <= '1';
      W_LOAD         <= '1';
      W_CLR          <= '0';
      W_DATAI1       <= data;
      W_DATAI2       <= (others => '0');
      
      wait for PERIOD;
      
      W_RST          <= '0';
      W_ENA          <= '1';
      W_LOAD         <= '0';
      W_CLR          <= '0';
      W_DATAI1       <= (others => '0');
      W_DATAI2       <= (others => '0');
      
      wait for PERIOD;
   end load_LFSR1;
   
   procedure load_LFSR2(data : in std_logic_vector(3 downto 0)) is
   begin
      W_RST          <= '0';
      W_ENA          <= '1';
      W_LOAD         <= '1';
      W_CLR          <= '0';
      W_DATAI1       <= (others => '0');
      W_DATAI2       <= data;
      
      wait for PERIOD;
      
      W_RST          <= '0';
      W_ENA          <= '1';
      W_LOAD         <= '0';
      W_CLR          <= '0';
      W_DATAI1       <= (others => '0');
      W_DATAI2       <= (others => '0');
      
      wait for PERIOD;
   end load_LFSR2;

   procedure clear_LFSR is
   begin
      W_RST          <= '0';
      W_ENA          <= '1';
      W_LOAD         <= '0';
      W_CLR          <= '1';
      W_DATAI1       <= (others => '0');
      W_DATAI2       <= (others => '0');
   
      wait for PERIOD;
   end clear_LFSR;
   
   begin
--      W_RST          <= '0';
--      W_ENA          <= '0';
--      W_LOAD         <= '0';
--      W_CLR          <= '0';
--      W_DATAI1       <= (others => '0');
--      W_DATAI2       <= (others => '0');

      reset;
      
      enable_LFSR;
      
      wait for PERIOD * 4;
      
      load_LFSR1("101");
      load_LFSR2("0010");
      
      wait for PERIOD * 4;
      
      disable_LFSR;
      
      wait for PERIOD * 4;
      
      enable_LFSR;
      
      wait for PERIOD * 4;
      
      clear_LFSR;
      
      wait for PERIOD * 4;
      
      assert FALSE report "End of Simulation." severity FAILURE;      

      wait for PERIOD;
      wait;
   end process STIMULI;

end BEH;