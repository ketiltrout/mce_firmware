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
-- <revision control keyword substitutions e.g. $Id: tb_eeprom_ctrl.vhd,v 1.1 2004/03/05 22:38:35 jjacob Exp $>
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
-- <date $Date: 2004/03/05 22:38:35 $>	-		<text>		- <initials $Author: jjacob $>

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


   constant PERIOD : time := 20 ns;

   signal W_N_EEPROM_CS_O     : std_logic ;
   signal W_N_EEPROM_HOLD_O   : std_logic ;
   signal W_N_EEPROM_WP_O     : std_logic ;
   signal W_EEPROM_SI_O       : std_logic ;
   signal W_EEPROM_CLK_O      : std_logic ;
   signal W_EEPROM_SO_I       : std_logic ;
   signal W_CLK_I             : std_logic := '0';
   signal W_RST_I             : std_logic ;
   signal W_ADDR_I            : std_logic_vector ( WB_ADDR_WIDTH - 1 downto 0 );
   signal W_DAT_I             : std_logic_vector ( WB_DATA_WIDTH - 1 downto 0 );
   signal W_DAT_O             : std_logic_vector ( WB_DATA_WIDTH - 1 downto 0 );
   signal W_TGA_I             : std_logic_vector ( WB_TAG_ADDR_WIDTH - 1 downto 0 );
   signal W_WE_I              : std_logic ;
   signal W_STB_I             : std_logic ;
   signal W_ACK_O             : std_logic ;
   signal W_CYC_I             : std_logic ;
   signal W_RTY_O             : std_logic ;
   
   signal bit_count           : integer := 32;
   signal sample_data         : std_logic_vector (31 downto 0) := "11001010111111101011101010111110"; --0xCAFEBABE
   signal instr               : std_logic_vector (7 downto 0);
   signal instr_count         : integer := 8;
   
   signal byte_addr           : std_logic_vector (7 downto 0);
   signal byte_addr_count     : integer := 8;
   signal wb_data             : std_logic_vector ( WB_DATA_WIDTH - 1 downto 0 );
   
begin

------------------------------------------------------------------------
--
-- instantiate eeprom controller
--
------------------------------------------------------------------------

DUT : EEPROM_CTRL
   
generic map
    (EEPROM_CTRL_ADDR => EEPROM_ADDR  )

port map(

     -- EEPROM interface:
     
     -- outputs to the EEPROM
     n_eeprom_cs_o   => W_N_EEPROM_CS_O,
     n_eeprom_hold_o => W_N_EEPROM_HOLD_O,
     n_eeprom_wp_o   => W_N_EEPROM_WP_O,
     eeprom_si_o     => W_EEPROM_SI_O,
     eeprom_clk_o    => W_EEPROM_CLK_O,
     
     -- inputs from the EEPROM
     eeprom_so_i     => W_EEPROM_SO_I,
     
     -- Wishbone interface:
     clk_i   => W_CLK_I,
     rst_i   => W_RST_I,
     addr_i  => W_ADDR_I,
     tga_i   => W_TGA_I,
     dat_i 	 => W_DAT_I,
     dat_o   => W_DAT_O,
     we_i    => W_WE_I,
     stb_i   => W_STB_I,
     ack_o   => W_ACK_O,
     rty_o   => W_RTY_O,
     cyc_i   => W_CYC_I); 
     

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
         W_TGA_I               <= (others => '0');

         -- data from the EEPROM
         W_EEPROM_SO_I         <= 'Z';
      
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
         W_TGA_I               <= (others => '0');
                  
         -- data from the EEPROM
         W_EEPROM_SO_I         <= 'Z';
      
         wait for PERIOD*3;
         
         -- data from the wishbone bus
         W_RST_I               <= '0';
         W_ADDR_I              <= (others => '0');
         W_DAT_I               <= (others => '0');
         W_WE_I                <= '0';
         W_STB_I               <= '0';
         W_CYC_I               <= '0';
         W_TGA_I               <= (others => '0');
                  
         -- data from the EEPROM
         W_EEPROM_SO_I         <= 'Z';
         
         wait for PERIOD;        
         
         assert false report " Performing a RESET." severity NOTE;
      end do_reset ;


      procedure do_rx_read_cmd is
      begin
      
         -- data from the master's side wishbone bus
         W_RST_I               <= '0';
         W_ADDR_I              <= EEPROM_ADDR;
         W_DAT_I               <= (others => '0');
         W_WE_I                <= '0';  -- indicates a read
         W_STB_I               <= '1';
         W_CYC_I               <= '1';
         W_TGA_I               <= "00000000000000000000000010111110"; --0x000000BE -- address is arbitary since I'm providing the data
         
         
         -- emulating the eeprom here
         wait until W_N_EEPROM_CS_O <= '0';
         
         -- eeprom is reading the 8-bit instruction code
         wait until W_EEPROM_CLK_O <= '1' ;
         while instr_count > 0 loop
            --wait until W_EEPROM_CLK_O <= '1' ;--and W_EEPROM_CLK_O'event );
            instr(instr_count-1) <= W_EEPROM_SI_O;
       
            assert false report " EEPROM Controller is writing the 8-bit READ command to the EEPROM." severity NOTE;
            wait for 40 ns;
            instr_count <= instr_count - 1;
            wait for 200 ns;
            
         end loop;
         
 
      end do_rx_read_cmd;


      procedure do_rx_byte_addr is
      begin
      
         -- data from the master's side wishbone bus
         W_RST_I               <= '0';
         W_ADDR_I              <= EEPROM_ADDR;
         W_DAT_I               <= (others => '0');
         W_WE_I                <= '0';  -- indicates a read
         W_STB_I               <= '1';
         W_CYC_I               <= '1';
         W_TGA_I               <= "00000000000000000000000010111110"; --0x000000BE -- address is arbitary since I'm providing the data
          
          
         wait until W_EEPROM_CLK_O <= '1' ;     
         -- eeprom is reading the 8-bit byte addr
         while byte_addr_count > 0 loop
            
            byte_addr(byte_addr_count-1) <= W_EEPROM_SI_O;
       
            assert false report " EEPROM Controller is writing the 8-bit byte address to the EEPROM." severity NOTE;
            wait for 40 ns;
            byte_addr_count <= byte_addr_count - 1;
            wait for 200 ns;
            
         end loop;
         
 
      end do_rx_byte_addr;





      procedure do_tx_eeprom_data is
      begin

        --emulating 32 bits coming out of the EEPROM @ 1 bit per "slow" clock cycle
         --data is 0xCAFEBABE
         while bit_count > 1 loop
            --wait until (W_EEPROM_CLK_O'event and W_EEPROM_CLK_O <= '1');
            W_EEPROM_SO_I         <= sample_data(bit_count-1);     
            bit_count <= bit_count - 1;
            assert false report " Reading data from the EEPROM." severity NOTE;

            wait for 240 ns;
    
         end loop;
         
 
            W_EEPROM_SO_I         <= sample_data(bit_count-1);     
            bit_count <= bit_count - 1;
            assert false report " Reading data from the EEPROM." severity NOTE;

         
         
         
      end do_tx_eeprom_data;
         
      procedure do_rx_wb_data is
      begin

        --emulating wb master here receiving the data from the slave
         --data is 0xCAFEBABE
            wait until W_ACK_O <= '1';
            wb_data <= W_DAT_O;

            assert false report " MASTER is reading data from the EEPROM CONTROLLER SLAVE." severity NOTE;
            
            -- end the wishbone cycle
            wait for PERIOD;
         W_RST_I               <= '0';
         W_ADDR_I              <= (others => '0');
         W_DAT_I               <= (others => '0');
         W_WE_I                <= '0';
         W_STB_I               <= '0';
         W_CYC_I               <= '0';
         W_TGA_I               <= (others => '0');

         -- data from the EEPROM
         W_EEPROM_SO_I         <= 'Z';            

         
      end do_rx_wb_data;
         



      procedure do_finish is
      begin
      
         -- data from the wishbone bus
         W_RST_I               <= '0';
         W_ADDR_I              <= (others => '0');
         W_DAT_I               <= (others => '0');
         W_WE_I                <= '0';
         W_STB_I               <= '0';
         W_CYC_I               <= '0';
         W_TGA_I               <= (others => '0');

         -- data from the EEPROM
         W_EEPROM_SO_I         <= 'Z';
      
         wait for 300 ns;
         
         assert false report " Finishing up." severity NOTE;
      end do_finish ;         
         
      

------------------------------------------------------------------------
--
-- Start the test
--
------------------------------------------------------------------------
 
   --STIMULI : process          
   begin
      do_nop;
      
      do_reset;  
      
      do_rx_read_cmd;
      
      do_rx_byte_addr;
      
      
 
      
      do_tx_eeprom_data;
      
      do_rx_wb_data;
      
      do_finish;
      
      assert false report " Simulation done." severity FAILURE;


   end process STIMULI;

end BEH;
