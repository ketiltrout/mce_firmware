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

-- 
--
-- <revision control keyword substitutions e.g. $Id$>
--
-- Project:	      SCUBA-2
-- Author:	       Jonathan Jacob
-- Organisation:  UBC
--
-- Description:
-- 
--
-- Revision history:
-- Feb. 3 2004   - Initial version      - JJ
-- <date $Date$>	-		<text>		- <initials $Author$>

--
-----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.eeprom_ctrl_pack.all;

--library components;
--use components.component_pack.all;

library sys_param;
use sys_param.wishbone_pack.all;


entity TB_EEPROM_CTRL is
end TB_EEPROM_CTRL;

architecture BEH of TB_EEPROM_CTRL is

   component EEPROM_CTRL

      generic(EEPROM_CTRL_DATA_WIDTH   : integer  := EEPROM_CTRL_DATA_WIDTH ;
              EEPROM_CTRL_ADDR_WIDTH   : integer  := EEPROM_CTRL_ADDR_WIDTH ;
              EEPROM_CTRL_ADDR         : std_logic_vector ( ADDR_LENGTH - 1 downto 0 )  := EEPROM_CTRL_ADDR );

      port(N_EEPROM_CS_O     : out std_logic ;
           N_EEPROM_HOLD_O   : out std_logic ;
           N_EEPROM_WP_O     : out std_logic ;
           EEPROM_SI_O       : out std_logic ;
           EEPROM_CLK_O      : out std_logic ;
           EEPROM_SO_I       : in std_logic ;
           CLK_5MHZ_I        : in std_logic ;
           CLK_I             : in std_logic ;
           RST_I             : in std_logic ;
           ADDR_I            : in std_logic_vector ( EEPROM_CTRL_ADDR_WIDTH - 1 downto 0 );
           DAT_I             : in std_logic_vector ( EEPROM_CTRL_DATA_WIDTH - 1 downto 0 );
           DAT_O             : out std_logic_vector ( EEPROM_CTRL_DATA_WIDTH - 1 downto 0 );
           WE_I              : in std_logic ;
           STB_I             : in std_logic ;
           ACK_O             : out std_logic ;
           CYC_I             : in std_logic );

   end component;


   constant PERIOD : time := 20 ns;

   signal W_N_EEPROM_CS_O     : std_logic ;
   signal W_N_EEPROM_HOLD_O   : std_logic ;
   signal W_N_EEPROM_WP_O     : std_logic ;
   signal W_EEPROM_SI_O       : std_logic ;
   signal W_EEPROM_CLK_O      : std_logic ;
   signal W_EEPROM_SO_I       : std_logic ;
   signal W_CLK_5MHZ_I        : std_logic := '0';
   signal W_CLK_I             : std_logic := '0';
   signal W_RST_I             : std_logic ;
   signal W_ADDR_I            : std_logic_vector ( EEPROM_CTRL_ADDR_WIDTH - 1 downto 0 );
   signal W_DAT_I             : std_logic_vector ( EEPROM_CTRL_DATA_WIDTH - 1 downto 0 );
   signal W_DAT_O             : std_logic_vector ( EEPROM_CTRL_DATA_WIDTH - 1 downto 0 );
   signal W_WE_I              : std_logic ;
   signal W_STB_I             : std_logic ;
   signal W_ACK_O             : std_logic ;
   signal W_CYC_I             : std_logic ;
   
   
   signal bit_count           : integer := 31;
   signal sample_data         : std_logic_vector (31 downto 0) := "11001010111111101011101010111110"; --0xCAFEBABE
   
begin

------------------------------------------------------------------------
--
-- instantiate eeprom controller
--
------------------------------------------------------------------------

   DUT : EEPROM_CTRL

      generic map(EEPROM_CTRL_DATA_WIDTH   => EEPROM_CTRL_DATA_WIDTH ,
                  EEPROM_CTRL_ADDR_WIDTH   => EEPROM_CTRL_ADDR_WIDTH ,
                  EEPROM_CTRL_ADDR         => EEPROM_CTRL_ADDR )

      port map(N_EEPROM_CS_O     => W_N_EEPROM_CS_O,
               N_EEPROM_HOLD_O   => W_N_EEPROM_HOLD_O,
               N_EEPROM_WP_O     => W_N_EEPROM_WP_O,
               EEPROM_SI_O       => W_EEPROM_SI_O,
               EEPROM_CLK_O      => W_EEPROM_CLK_O,
               EEPROM_SO_I       => W_EEPROM_SO_I,
               CLK_5MHZ_I        => W_CLK_5MHZ_I,
               CLK_I             => W_CLK_I,
               RST_I             => W_RST_I,
               ADDR_I            => W_ADDR_I,
               DAT_I             => W_DAT_I,
               DAT_O             => W_DAT_O,
               WE_I              => W_WE_I,
               STB_I             => W_STB_I,
               ACK_O             => W_ACK_O,
               CYC_I             => W_CYC_I);

------------------------------------------------------------------------
--
-- Create a test clock
--
------------------------------------------------------------------------

   W_CLK_I <= not W_CLK_I after PERIOD/2;

------------------------------------------------------------------------
--
-- Create stimulus
--
------------------------------------------------------------------------

   STIMULI : process
   
------------------------------------------------------------------------
--
-- Procdures for creating stimulus
-- model the eeprom on one side, and the wishbone bus master on the other
--
------------------------------------------------------------------------ 

  
      procedure do_nop is
      begin
      
         -- data from the wishbone bus
         W_RST_I               <= '0';
         W_ADDR_I              <= (others => '0');
         W_DAT_I               <= (others => '0');
         W_WE_I                <= '0';
         W_STB_I               <= '0';
         W_CYC_I               <= '0';
         
         -- data from the EEPROM
         W_EEPROM_SO_I         <= '0';
      
         wait for PERIOD;
         
         assert false report " Performing a NOP." severity NOTE;
      end do_nop ;
      

      -- reset procedure

      procedure do_reset is
      begin
      
         -- data from the wishbone bus
         W_RST_I               <= '1';
         W_ADDR_I              <= (others => '0');
         W_DAT_I               <= (others => '0');
         W_WE_I                <= '0';
         W_STB_I               <= '0';
         W_CYC_I               <= '0';
         
         -- data from the EEPROM
         W_EEPROM_SO_I         <= '0';
      
         wait for PERIOD*3;
         
         -- data from the wishbone bus
         W_RST_I               <= '0';
         W_ADDR_I              <= (others => '0');
         W_DAT_I               <= (others => '0');
         W_WE_I                <= '0';
         W_STB_I               <= '0';
         W_CYC_I               <= '0';
         
         -- data from the EEPROM
         W_EEPROM_SO_I         <= '0';
         
         wait for PERIOD;        
         
         assert false report " Performing a RESET." severity NOTE;
      end do_reset ;


      procedure do_read is
      begin
      
         -- data from the wishbone bus
         W_RST_I               <= '0';
         W_ADDR_I(31 downto 8) <= (others => '0');
         W_ADDR_I(7 downto 0)  <= EEPROM_CTRL_ADDR;
         W_DAT_I               <= (others => '0');
         W_WE_I                <= '0';
         W_STB_I               <= '1';
         W_CYC_I               <= '1';
         
         --wait until eeprom ready to start outputting data
         wait for PERIOD*8;
         
         --emulate 32 bits coming out @ 1 bit per clock cycle
         --data is 0xCAFEBABE
         while bit_count >= 0 loop
         
            W_EEPROM_SO_I         <= sample_data(bit_count);
            wait for PERIOD;
            bit_count <= bit_count - 1;
            assert false report " Reading data from the EEPROM." severity NOTE;
         end loop;
         
      end do_read;

         
         
      

------------------------------------------------------------------------
--
-- Start the test
--
------------------------------------------------------------------------
 
   --STIMULI : process          
   begin
      do_nop;
      
      do_reset;  
      
      do_read;
      
 
     -- do_finish;
      
      assert false report " Simulation done." severity FAILURE;


   end process STIMULI;

end BEH;
