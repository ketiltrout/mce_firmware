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
-- <revision control keyword substitutions e.g. $Id: tb_dac_ctrl.vhd,v 1.3 2004/04/16 23:31:11 mandana Exp $>
--
-- Project:	      SCUBA-2
-- Author:	      Mandana Amiri
-- Organisation:      UBC
--
-- Description:
-- Testbench to test dac_ctrl module for bias card
--
-- Revision history:
-- <date $Date: 2004/04/16 23:31:11 $>	- <initials $Author: mandana $>
-- $Log: tb_dac_ctrl.vhd,v $
-- Revision 1.3  2004/04/16 23:31:11  mandana
-- completed out_sync_cmd and resync_cmd
--
-- Revision 1.2  2004/04/15 18:19:36  mandana
-- debugged do_dac32_cmd & do_dac_lvds_cmd
--
-- Revision 1.1  2004/04/14 17:38:17  mandana
-- initial release
-- 
--
-----------------------------------------------------------------------------
library ieee, sys_param, components;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use sys_param.wishbone_pack.all;
use sys_param.frame_timing_pack.all;
use sys_param.data_types_pack.all;
use components.component_pack.all;

entity TB_DAC_CTRL is
end TB_DAC_CTRL;

architecture BEH of TB_DAC_CTRL is

   component DAC_CTRL

      generic(DAC32_CTRL_ADDR      : std_logic_vector ( WB_ADDR_WIDTH - 1 downto 0 )  := FLUX_FB_ADDR ;
              DAC_LVDS_CTRL_ADDR   : std_logic_vector ( WB_ADDR_WIDTH - 1 downto 0 )  := BIAS_ADDR );

      port(dac_data_o   : out std_logic_vector ( 32 downto 0 );
           dac_ncs_o    : out std_logic_vector ( 32 downto 0 );
           dac_clk_o    : out std_logic_vector ( 32 downto 0 );
           clk_i        : in std_logic ;
           rst_i        : in std_logic ;
           dat_i        : in std_logic_vector ( WB_DATA_WIDTH - 1 downto 0 );
           addr_i       : in std_logic_vector ( WB_ADDR_WIDTH - 1 downto 0 );
           tga_i        : in std_logic_vector ( WB_TAG_ADDR_WIDTH - 1 downto 0 );
           we_i         : in std_logic ;
           stb_i        : in std_logic ;
           cyc_i        : in std_logic ;
           dat_o        : out std_logic_vector ( WB_DATA_WIDTH - 1 downto 0 );
           rty_o        : out std_logic ;
           ack_o        : out std_logic ;
           sync_i       : in std_logic );

   end component;


   constant PERIOD : time := 20 ns;

   signal W_DAC_DATA_O   : std_logic_vector ( 32 downto 0 );
   signal W_DAC_NCS_O    : std_logic_vector ( 32 downto 0 );
   signal W_DAC_CLK_O    : std_logic_vector ( 32 downto 0 );
   signal W_CLK_I        : std_logic := '0';
   signal W_RST_I        : std_logic ;
   signal W_DAT_I        : std_logic_vector ( WB_DATA_WIDTH - 1 downto 0 );
   signal W_ADDR_I       : std_logic_vector ( WB_ADDR_WIDTH - 1 downto 0 );
   signal W_TGA_I        : std_logic_vector ( WB_TAG_ADDR_WIDTH - 1 downto 0 );
   signal W_WE_I         : std_logic ;
   signal W_STB_I        : std_logic ;
   signal W_CYC_I        : std_logic ;
   signal W_DAT_O        : std_logic_vector ( WB_DATA_WIDTH - 1 downto 0 );
   signal W_RTY_O        : std_logic ;
   signal W_ACK_O        : std_logic ;
   signal W_SYNC_I       : std_logic := '0';
   
   type   w_array16 is array (15 downto 0) of word32; 
   signal data           : w_array16;
   signal kk             : integer range 0 to 15;
begin
  
   DUT : DAC_CTRL

      generic map(DAC32_CTRL_ADDR      => FLUX_FB_ADDR ,
                  DAC_LVDS_CTRL_ADDR   => BIAS_ADDR )

      port map(dac_data_o   => W_DAC_DATA_O,
               dac_ncs_o    => W_DAC_NCS_O,
               dac_clk_o    => W_DAC_CLK_O,
               clk_i        => W_CLK_I,
               rst_i        => W_RST_I,
               dat_i        => W_DAT_I,
               addr_i       => W_ADDR_I,
               tga_i        => W_TGA_I,
               we_i         => W_WE_I,
               stb_i        => W_STB_I,
               cyc_i        => W_CYC_I,
               dat_o        => W_DAT_O,
               rty_o        => W_RTY_O,
               ack_o        => W_ACK_O,
               sync_i       => W_SYNC_I);

   W_CLK_I <= not W_CLK_I after PERIOD/2;
   W_SYNC_I <= not W_SYNC_I after PERIOD*10;
------------------------------------------------------------
   STIMULI : process

------------------------------------------------------------
--
--  NOP
--
------------------------------------------------------------      
   procedure do_nop is
   begin
      W_RST_I        <= '0';
      W_DAT_I        <= (others => '0');
      W_ADDR_I       <= (others => '0');
      W_TGA_I        <= (others => '0');
      W_WE_I         <= '0';
      W_STB_I        <= '0';
      W_CYC_I        <= '0';

      wait for PERIOD;
      assert false report " Performing a NOP." severity NOTE;
      
   end do_nop;
------------------------------------------------------------
--
--  RESET
--
------------------------------------------------------------   
   procedure do_reset is
   begin
      W_RST_I        <= '1';
      W_DAT_I        <= (others => '0');
      W_ADDR_I       <= (others => '0');
      W_TGA_I        <= (others => '0');
      W_WE_I         <= '0';
      W_STB_I        <= '0';
      W_CYC_I        <= '0';
      
      wait for PERIOD*3;
      
      W_RST_I        <= '0';
        
      wait for PERIOD;        
      assert false report " Performing a RESET." severity NOTE;
   end do_reset ;

------------------------------------------------------------
--
--  Issue FLUX_FB_ADDR (DAC32_CMD)
--
------------------------------------------------------------   
   procedure dac32_cmd (data: in w_array16) is
   begin
      
      for kk in 0 to 15 loop   
         W_RST_I     <= '0';
         W_DAT_I     <= data(kk);
         W_ADDR_I    <= FLUX_FB_ADDR;
         W_TGA_I     <= (others => '0');
         W_WE_I      <= '1';
         W_STB_I     <= '1';
         W_CYC_I     <= '1';
         
         wait until W_ACK_O = '1';      
         wait for PERIOD;
         W_STB_I     <= '0';        
         
         wait for PERIOD;
      end loop;
      
      W_CYC_I        <= '0';
      W_WE_I         <= '0';
      W_DAT_I        <= (others => '0');      
      W_ADDR_I       <= (others => '0');
      
      assert false report "Processing DAC32 cmd." severity NOTE;
      wait for PERIOD*120;
      
   end dac32_cmd;
------------------------------------------------------------
--
--  Issue BIAS_ADDR (DAC_LVDS_CMD)
--
------------------------------------------------------------   
   procedure dac_lvds_cmd (ldata: in word32) is
   begin
      W_RST_I        <= '0';
      W_DAT_I        <= ldata;
      W_ADDR_I       <= BIAS_ADDR;
      W_TGA_I        <= (others => '0');
      W_WE_I         <= '1';
      W_STB_I        <= '1';
      W_CYC_I        <= '1';
      
      wait until W_ACK_O = '1';      
      wait for PERIOD;

      W_STB_I        <= '0';
      W_CYC_I        <= '0';
      W_WE_I         <= '0';
      W_DAT_I        <= (others => '0');
      W_ADDR_I       <= (others => '0');
      W_TGA_I        <= (others => '0');
      
      wait for PERIOD;
      assert false report " Processing LVDS cmd." severity NOTE;
      wait for PERIOD*120;
   end dac_lvds_cmd;
------------------------------------------------------------
--
--  Issue RESYNC_NXT_ADDR
--
------------------------------------------------------------      
   procedure resync_cmd is
   begin
      W_RST_I        <= '0';
      W_DAT_I        <= (others => '0');
      W_ADDR_I       <= RESYNC_NXT_ADDR;
      W_TGA_I        <= (others => '0');
      W_WE_I         <= '1';
      W_STB_I        <= '1';
      W_CYC_I        <= '1';
      
      wait until W_ACK_O = '1'; 
      wait for PERIOD;
      
      W_STB_I        <= '0';
      W_CYC_I        <= '0';
      W_WE_I         <= '0';
      W_ADDR_I       <= (others => '0');
      
      wait for PERIOD;
      assert false report " Processing RESYNC cmd." severity NOTE;
      
      wait for PERIOD*120;
         
   end resync_cmd;
------------------------------------------------------------
--
--  Issue CYCLES_OUT_OF_SYNC
--
------------------------------------------------------------   
   procedure out_of_sync_cmd is
   begin
      W_RST_I        <= '0';
      W_DAT_I        <= (others => '0');
      W_ADDR_I       <= CYC_OUT_SYNC_ADDR;
      W_TGA_I        <= (others => '0');
      W_WE_I         <= '0';
      W_STB_I        <= '1';
      W_CYC_I        <= '1';
      
      wait until W_ACK_O = '1';      
      wait until W_ACK_O = '0';
      W_STB_I        <= '0';
      W_CYC_I        <= '0';
      W_ADDR_I       <= (others => '0');
      
      wait for PERIOD;
      W_DAT_I        <= (others => '0');
      
      assert false report " Processing OUT_OF_SYNC cmd." severity NOTE;
   
   end out_of_sync_cmd;
------------------------------------------------------------
--
--  STIMULI
--
------------------------------------------------------------   

  begin
   data (0) <= "11110000001100110100000000000101";--f0334005
   data (1) <= "10101010101010101010101010101010";--aaaaaaaa
   data (2) <= "00000000000000000000000000000000";--00000000
   data (3) <= "11101110111011101110111011101110";--eeeeeeee
   data (4) <= "01010101010101010101010101010101";--55555555
   data (5) <= "11111111111111111111111111111111";--ffffffff
   data (6) <= "00000000000000000111111111111111";--00007fff
   data (7) <= "01010101010101010101010101010101";--55555555
   data (8) <= "10101010101010101010101010101010";--aaaaaaaa
   data (9) <= "01010101010101010101010101010101";--55555555
   data (10) <="10101010101010101010101010101010";--aaaaaaaa
   data (11) <="11001100110011001100110011001100";--cccccccc
   data (12) <="10011001100110011001100110011001";--99999999
   data (13) <="00000000000000000000000000000000";--00000000
   data (14) <="01000100010001000100010001000100";--44444444
   data (15) <="00100010000100010101010101010101";--22115555
  
   do_nop;
   do_reset;

   dac_lvds_cmd (x"FFFFFFFF"); -- coverage on MAX_DAC_BC out of range setting
   do_nop;

   dac_lvds_cmd (x"00000000"); -- coverage on MIN_DAC_BC out of range setting
   do_nop;   

   dac_lvds_cmd(data(0));
   do_nop;
   
   dac32_cmd (data);   
   do_nop;
    
   data (1) <= "01010000100011001101111011110111";--508cdef7
   dac32_cmd (data);
   resync_cmd;
   do_nop;
   
   out_of_sync_cmd;
   do_nop;
   
   assert false report " Simulation done." severity FAILURE;
   
   end process STIMULI;

end BEH;
