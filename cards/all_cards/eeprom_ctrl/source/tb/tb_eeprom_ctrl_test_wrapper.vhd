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
-- <revision control keyword substitutions e.g. $Id: tb_eeprom_ctrl_test_wrapper.vhd,v 1.1 2004/04/14 22:05:26 jjacob Exp $>
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
-- <date $Date: 2004/04/14 22:05:26 $>	-		<text>		- <initials $Author: jjacob $>
-- $Log: tb_eeprom_ctrl_test_wrapper.vhd,v $
-- Revision 1.1  2004/04/14 22:05:26  jjacob
-- new directory structure
--
-- Revision 1.2  2004/03/24 05:56:52  erniel
-- added 8 more transmits
--
--
-----------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

library components;
use components.component_pack.all;

library sys_param;
use sys_param.wishbone_pack.all;


entity TB_EEPROM_CTRL_TEST_WRAPPER is
end TB_EEPROM_CTRL_TEST_WRAPPER;

architecture BEH of TB_EEPROM_CTRL_TEST_WRAPPER is

   component EEPROM_CTRL_TEST_WRAPPER
      port(RST_I       : in std_logic ;
           CLK_I       : in std_logic ;
           EN_I        : in std_logic ;
           DONE_O      : out std_logic ;
           TX_BUSY_I   : in std_logic ;
           TX_ACK_I    : in std_logic ;
           TX_DATA_O   : out std_logic_vector ( 7 downto 0 );
           TX_WE_O     : out std_logic ;
           TX_STB_O    : out std_logic ;
 
     n_eeprom_cs_o   : out std_logic; -- low enable eeprom chip select
     n_eeprom_hold_o : out std_logic; -- low enable eeprom hold
     n_eeprom_wp_o   : out std_logic; -- low enable write protect
     eeprom_si_o     : out std_logic; -- serial input data to the eeprom
     eeprom_clk_o    : out std_logic; -- clock signal to EEPROM     
      
     eeprom_so_i     : in std_logic ); -- serial output data from the eeprom 

   end component;


   constant PERIOD : time := 20 ns;
   constant spi_clk_half_period : time := 100 ns;
   constant spi_clk_full_period : time := 200 ns;
   

   signal W_RST_I       : std_logic ;
   signal W_CLK_I       : std_logic := '0';
   signal W_EN_I        : std_logic ;
   signal W_DONE_O      : std_logic ;
   signal W_TX_BUSY_I   : std_logic ;
   signal W_TX_ACK_I    : std_logic ;
   signal W_TX_DATA_O   : std_logic_vector ( 7 downto 0 );
   signal W_TX_WE_O     : std_logic ;
   signal W_TX_STB_O    : std_logic ;

   
   signal w_n_eeprom_cs_o   : std_logic; -- low enable eeprom chip select
   signal w_n_eeprom_hold_o : std_logic; -- low enable eeprom hold
   signal w_n_eeprom_wp_o   : std_logic; -- low enable write protect
   signal w_eeprom_si_o     : std_logic; -- serial input data to the eeprom
   signal w_eeprom_clk_o    : std_logic; -- clock signal to EEPROM     

   signal w_eeprom_so_i     : std_logic;

   
   
   
   
   
   
   
   signal instr_command       : std_logic_vector(7 downto 0) := "00000000";

   constant SERIAL_CODE       : std_logic_vector(63 downto 0) :=  
                               "1000100011111111000000000000000011111111000000001111111100000000";
   -- alternate data for SERIAL_CODE:                           
   -- "0000111100001111000011110000111100001111000011110000111100001111";  -- 0x0F0F0F0F0F0F0F0F random data;
   -- "1000100011111111000000000000000011111111000000001111111100000000"   -- this is CRC calculated
   
   -- loop counters
   signal bit_count                    : integer := 8;
   signal instr_count                  : integer := 8;
   
   
   signal sample_data         : std_logic_vector (31 downto 0) := "11001010111111101011101010111110"; --0xCAFEBABE
   signal sample_wr_data      : std_logic_vector (31 downto 0) := "00000000110000001111111111101110"; --0x00C0FFEE
   signal instr               : std_logic_vector (7 downto 0);
   
   signal byte_addr           : std_logic_vector (15 downto 0);
   signal byte_addr_count2    : integer := 16;
   signal byte_addr_count     : integer := 16;
   signal wb_data             : std_logic_vector ( WB_DATA_WIDTH - 1 downto 0 );
   
   signal rx_eeprom_data      : std_logic_vector ( WB_DATA_WIDTH - 1 downto 0 );
   signal sample_sr_data      : std_logic_vector (7 downto 0) := "11111100";   
   
   signal i                            : integer := 8;
   
   -- reference data for self-checking
   signal reference_instr_command       : std_logic_vector(7 downto 0) := "00000000";
   signal reference_read_rom_cmd        : std_logic_vector(7 downto 0) := "00110011";
   

begin

------------------------------------------------------------------------
--
-- instantiate eeprom_ctrl test wrapper
--
------------------------------------------------------------------------

   DUT : EEPROM_CTRL_TEST_WRAPPER
      port map(RST_I       => W_RST_I,
               CLK_I       => W_CLK_I,
               EN_I        => W_EN_I,
               DONE_O      => W_DONE_O,
               TX_BUSY_I   => W_TX_BUSY_I,
               TX_ACK_I    => W_TX_ACK_I,
               TX_DATA_O   => W_TX_DATA_O,
               TX_WE_O     => W_TX_WE_O,
               TX_STB_O    => W_TX_STB_O,
 
               
     n_eeprom_cs_o   => w_n_eeprom_cs_o,
     n_eeprom_hold_o => w_n_eeprom_hold_o,
     n_eeprom_wp_o   => w_n_eeprom_wp_o,
     eeprom_si_o     => w_eeprom_si_o,
     eeprom_clk_o    => w_eeprom_clk_o,
   
     eeprom_so_i     =>      w_eeprom_so_i  );


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
-- Procdures for creating stimulus. MODEL THE EEPROM, and the test interface
--
------------------------------------------------------------------------ 

  
      procedure do_nop is
      begin
      
         -- test software signals
         W_RST_I       <= '0';
         W_EN_I        <= '0';
         W_TX_BUSY_I   <= '0';
         W_TX_ACK_I    <= '0';

         -- data from the EEPROM
         W_EEPROM_SO_I         <= 'Z';
      
         wait for PERIOD;
         
         assert false report " Performing a NOP." severity NOTE;
      end do_nop ;
      

      -- reset procedure

      procedure do_reset is
      begin
      
         -- test software signals
         W_RST_I       <= '1';
         W_EN_I        <= '0';
         W_TX_BUSY_I   <= '0';
         W_TX_ACK_I    <= '0';
                  
         -- data from the EEPROM
         W_EEPROM_SO_I         <= 'Z';
      
         wait for PERIOD*3;
         
         -- test software signals
         W_RST_I       <= '0';
         W_EN_I        <= '0';
         W_TX_BUSY_I   <= '0';
         W_TX_ACK_I    <= '0'; 

                  
         -- data from the EEPROM
         W_EEPROM_SO_I         <= 'Z';
         
         --wait for PERIOD;        
         
         assert false report " Performing a RESET." severity NOTE;
      end do_reset ;


   ------------------------------------------------------------------------
   --
   -- Setup procedures
   --
   ------------------------------------------------------------------------ 
--constant SETUP_TX_RDSR_CMD   : std_logic_vector(4 downto 0) := "00000";
--constant SETUP_RX_SR_DATA    : std_logic_vector(4 downto 0) := "00001";
--constant SPI_WAIT            : std_logic_vector(4 downto 0) := "00010";
--constant SETUP_TX_WRSR_CMD   : std_logic_vector(4 downto 0) := "00011";
--constant SETUP_TX_SR_DATA    : std_logic_vector(4 downto 0) := "00100";
--constant SETUP_TX_WREN_CMD   : std_logic_vector(4 downto 0) := "00101";
--
--constant IDLE                : std_logic_vector(4 downto 0) := "00110";
--constant TX_READ_CMD         : std_logic_vector(4 downto 0) := "00111";
--constant TX_BYTE_ADDR        : std_logic_vector(4 downto 0) := "01000";
--constant READ                : std_logic_vector(4 downto 0) := "01001";
--constant TX_WRITE_CMD        : std_logic_vector(4 downto 0) := "01010";
--constant WRITE               : std_logic_vector(4 downto 0) := "01011";
--constant TX_RDSR_CMD         : std_logic_vector(4 downto 0) := "01100";
--constant RX_SR_DATA          : std_logic_vector(4 downto 0) := "01101";
--
--constant SETUP               : std_logic_vector(4 downto 0) := "01110";
--constant WB_WAIT             : std_logic_vector(4 downto 0) := "01111";
--constant TX_WB_DATA          : std_logic_vector(4 downto 0) := "10000";
--
--constant DONE                : std_logic_vector(4 downto 0) := "11111";



      procedure do_setup_rx_rdsr_cmd is
      begin
      
               -- test software signals
         W_RST_I       <= '0';
         W_EN_I        <= '1';
         W_TX_BUSY_I   <= '0';
         W_TX_ACK_I    <= '0';
      
         assert false report " Executing do_setup_rx_rdsr_cmd." severity NOTE;
         bit_count <= 8;
         instr_count <= 8;
         -- emulating the eeprom here
         wait until W_N_EEPROM_CS_O <= '0';
         
         -- eeprom is reading the 8-bit instruction code
         wait until W_EEPROM_CLK_O <= '1' ;
         while instr_count > 0 loop
            --wait until W_EEPROM_CLK_O <= '1' ;--and W_EEPROM_CLK_O'event );
            instr(instr_count-1) <= W_EEPROM_SI_O;
       
            assert false report " EEPROM Controller is writing the 8-bit RDSR command to the EEPROM." severity NOTE;
            --wait for 40 ns;
            wait for spi_clk_half_period;
            instr_count <= instr_count - 1;
            --wait for 200 ns;
            wait for spi_clk_half_period;
            
         end loop;
      end do_setup_rx_rdsr_cmd;
      
      
      procedure do_setup_tx_sr_data is
      begin
         bit_count <= 8;
         assert false report " Executing do_setup_tx_sr_data." severity NOTE;
        --emulating 8 bits coming out of the EEPROM @ 1 bit per "slow" clock cycle
         --data is 11111100
         while bit_count > 0 loop
            --wait until (W_EEPROM_CLK_O'event and W_EEPROM_CLK_O <= '1');
            W_EEPROM_SO_I         <= sample_sr_data(bit_count-1);     
            bit_count <= bit_count - 1;
            assert false report " Reading data from the EEPROM." severity NOTE;

            --wait for 240 ns;
            wait for spi_clk_full_period;
    
         end loop;
      end do_setup_tx_sr_data;


      procedure do_setup_rx_wrsr_cmd is
      begin
      
         instr_count <= 8;
         --wait for 240 ns;
         assert false report " Executing do_setup_rx_wrsr_cmd." severity NOTE;
         
         -- data from the EEPROM
         W_EEPROM_SO_I         <= 'Z';
         -- emulating the eeprom here
         wait until W_N_EEPROM_CS_O <= '0';
         
         -- eeprom is reading the 8-bit instruction code
         wait until W_EEPROM_CLK_O <= '1' ;
         while instr_count > 0 loop
            --wait until W_EEPROM_CLK_O <= '1' ;--and W_EEPROM_CLK_O'event );
            instr(instr_count-1) <= W_EEPROM_SI_O;
       
            assert false report " EEPROM Controller is writing the 8-bit WRSR command to the EEPROM." severity NOTE;
            --wait for 40 ns;
            wait for spi_clk_half_period;
            instr_count <= instr_count - 1;
            --wait for 200 ns;
            wait for spi_clk_half_period;
            
         end loop;
      end do_setup_rx_wrsr_cmd;



     procedure do_setup_rx_sr_data is
      begin
      
         instr_count <= 8;
         assert false report " Executing do_setup_rx_sr_data." severity NOTE;
         -- emulating the eeprom here
         --wait until W_N_EEPROM_CS_O <= '0';
         
         -- eeprom is reading the 8-bit status register value from eeprom ctrl
         wait until W_EEPROM_CLK_O <= '1' ;
         while instr_count > 0 loop
            --wait until W_EEPROM_CLK_O <= '1' ;--and W_EEPROM_CLK_O'event );
            sample_sr_data(instr_count-1) <= W_EEPROM_SI_O;
       
            assert false report " EEPROM Controller is writing the 8-bit Status Register to the EEPROM." severity NOTE;
            --wait for 40 ns;
            wait for spi_clk_half_period;
            instr_count <= instr_count - 1;
            --wait for 200 ns;
            wait for spi_clk_half_period;
            
         end loop;
      end do_setup_rx_sr_data;


     procedure do_setup_rx_wren_cmd is
      begin
      
         instr_count <= 8;
         assert false report " Executing do_setup_rx_wren_cmd." severity NOTE;
         -- emulating the eeprom here
         wait until W_N_EEPROM_CS_O <= '0';
         
         -- eeprom is reading the 8-bit status register value from eeprom ctrl
         wait until W_EEPROM_CLK_O <= '1' ;
         while instr_count > 0 loop
            --wait until W_EEPROM_CLK_O <= '1' ;--and W_EEPROM_CLK_O'event );
            instr(instr_count-1) <= W_EEPROM_SI_O;
       
            assert false report " EEPROM Controller is writing the 8-bit WREN cmd to the EEPROM." severity NOTE;
            --wait for 40 ns;
            wait for spi_clk_half_period;
            instr_count <= instr_count - 1;
            --wait for 200 ns;
            wait for spi_clk_half_period;
            
         end loop;
      end do_setup_rx_wren_cmd;





      procedure do_rx_read_cmd is
      begin
         instr_count <= 8;

         -- emulating the eeprom here
         wait until W_N_EEPROM_CS_O <= '0';
         
         -- eeprom is reading the 8-bit instruction code
         wait until W_EEPROM_CLK_O <= '1' ;
         while instr_count > 0 loop
            --wait until W_EEPROM_CLK_O <= '1' ;--and W_EEPROM_CLK_O'event );
            instr(instr_count-1) <= W_EEPROM_SI_O;
       
            assert false report " EEPROM Controller is writing the 8-bit READ command to the EEPROM." severity NOTE;
            --wait for 40 ns;
            wait for spi_clk_half_period;
            instr_count <= instr_count - 1;
            --wait for 200 ns;
            wait for spi_clk_half_period;
            
         end loop;
         
 
      end do_rx_read_cmd;


      procedure do_rx_byte_addr is
      begin
      
         byte_addr_count <= 16;
          
         wait until W_EEPROM_CLK_O <= '1' ;     
         -- eeprom is reading the 8-bit byte addr
         while byte_addr_count > 0 loop
            
            byte_addr(byte_addr_count-1) <= W_EEPROM_SI_O;
       
            assert false report " EEPROM Controller is writing the 8-bit byte address to the EEPROM." severity NOTE;
            --wait for 40 ns;
            wait for spi_clk_half_period;
            byte_addr_count <= byte_addr_count - 1;
            bit_count <= 32; -- this is for the next procedure do_tx_eeprom_data
            --wait for 200 ns;
            wait for spi_clk_half_period;
            
         end loop;
         
 
      end do_rx_byte_addr;





      procedure do_tx_eeprom_data is
      begin
         
         --wait until W_EEPROM_CLK_O <= '1';
         --wait for 1 ns;
        --emulating 32 bits coming out of the EEPROM @ 1 bit per "slow" clock cycle
         --data is 0xCAFEBABE
         while bit_count > 1 loop
            
            W_EEPROM_SO_I         <= sample_data(bit_count-1);     
            bit_count <= bit_count - 1;
            assert false report " Reading data from the EEPROM." severity NOTE;

            --wait for 240 ns;
            wait for spi_clk_full_period;
    
         end loop;
         
 
            W_EEPROM_SO_I         <= rx_eeprom_data(bit_count-1);--sample_data(bit_count-1);     
            bit_count <= bit_count - 1;
            assert false report " Reading data from the EEPROM." severity NOTE;

         
         
         
      end do_tx_eeprom_data;
         
      procedure do_rx_wb_data is
      begin

        --emulating wb master here receiving the data from the slave
         --data is 0xCAFEBABE
            --wait until W_ACK_O <= '1';
            --wb_data <= W_DAT_O;

            assert false report " MASTER is reading data from the EEPROM CONTROLLER SLAVE." severity NOTE;
            
            -- end the wishbone cycle
            wait for PERIOD;
          

         
      end do_rx_wb_data;
         


------------------
--  write procedures
------------------


--      procedure do_rx_wr_en_cmd is
--      begin
--      
--         bit_count             <= 32;
--         instr_count           <= 8;
--         byte_addr_count       <= 8;
--      
--         -- data from the master's side wishbone bus
--         W_RST_I               <= '0';
--         W_ADDR_I              <= EEPROM_ADDR;
--         W_DAT_I               <= sample_wr_data;
--         W_WE_I                <= '1';  -- indicates a write
--         W_STB_I               <= '1';
--         W_CYC_I               <= '1';
--         W_TGA_I               <= "00000000000000000000000011101101"; --0x000000ED -- address is arbitary since I'm providing the data
--         
--         
--         wait for 1 ns;
----         if w_rty_o = '1' then
----            wait for PERIOD - 1 ns;
----            W_ADDR_I              <= "00000000";
----            W_WE_I                <= '0';
----            W_STB_I               <= '0';
----            W_CYC_I               <= '0';
----            W_TGA_I               <= (others => '0');
----         end if;    
----         
----         wait for 400 ns; 
----                
----         -- data from the master's side wishbone bus
----         W_RST_I               <= '0';
----         W_ADDR_I              <= EEPROM_ADDR;
----         W_DAT_I               <= sample_wr_data;
----         W_WE_I                <= '1';  -- indicates a write
----         W_STB_I               <= '1';
----         W_CYC_I               <= '1';
----         W_TGA_I               <= "00000000000000000000000011101101"; --0x000000ED -- address is arbitary since I'm providing the data         
--         
--         -- emulating the eeprom here
--         wait until W_N_EEPROM_CS_O <= '0';
--         
--         -- eeprom is reading the 8-bit write enable instruction code
--         wait until W_EEPROM_CLK_O <= '1' ;
--         while instr_count > 0 loop
--            --wait until W_EEPROM_CLK_O <= '1' ;--and W_EEPROM_CLK_O'event );
--            instr(instr_count-1) <= W_EEPROM_SI_O;
--       
--            assert false report " EEPROM Controller is writing the 8-bit WRITE ENABLE command to the EEPROM." severity NOTE;
--            wait for 40 ns;
--            instr_count <= instr_count - 1;
--            wait for 200 ns;
--            
--         end loop;
--         
-- 
--      end do_rx_wr_en_cmd;
--


      procedure do_rx_wr_cmd is
      begin
         assert false report " Executing do_rx_wr_cmd." severity NOTE;
         
         bit_count             <= 32;
         instr_count           <= 8;
         byte_addr_count       <= 8;
      
 
         -- emulating the eeprom here
         wait until W_N_EEPROM_CS_O <= '0';
         
         -- eeprom is reading the 8-bit instruction code
         wait until W_EEPROM_CLK_O <= '1' ;
         while instr_count > 0 loop
            --wait until W_EEPROM_CLK_O <= '1' ;--and W_EEPROM_CLK_O'event );
            instr(instr_count-1) <= W_EEPROM_SI_O;
       
            assert false report " EEPROM Controller is writing the 8-bit WRITE command to the EEPROM." severity NOTE;
            --wait for 40 ns;
            wait for spi_clk_half_period;
            instr_count <= instr_count - 1;
            --wait for 200 ns;
            wait for spi_clk_half_period;
            
         end loop;
      end do_rx_wr_cmd;



      procedure do_rx_byte_addr2 is
      begin

         byte_addr_count <= 16;
         wait for 1 ns;
         
         wait until W_EEPROM_CLK_O <= '1' ;     
         -- eeprom is reading the 8-bit command code
         while byte_addr_count > 0 loop
            
            byte_addr(byte_addr_count-1) <= W_EEPROM_SI_O;
       
            assert false report " EEPROM Controller is writing the 8-bit WRITE command to the EEPROM." severity NOTE;
            --wait for 40 ns;
            wait for spi_clk_half_period;
            byte_addr_count <= byte_addr_count - 1;
            --wait for 200 ns;
            wait for spi_clk_half_period;
            
         end loop;
          
 
      end do_rx_byte_addr2;

 
 
      procedure do_rx_eeprom_data is
      begin

         --bit_count <= 32;
         --wait for 1 ns;
         -- data from the master's side wishbone bus
--         W_RST_I               <= '0';
--         W_ADDR_I              <= EEPROM_ADDR;
--         W_DAT_I               <= sample_wr_data;
--         W_WE_I                <= '1';  -- indicates a write
--         W_STB_I               <= '1';
--         W_CYC_I               <= '1';
--         W_TGA_I               <= "00000000000000000000000011101101"; --0x000000ED -- address is arbitary since I'm providing the data
          
          
         --wait until W_EEPROM_CLK_O <= '1' ;     
         -- eeprom is reading the 8-bit command code
         while bit_count > 0 loop
            
            rx_eeprom_data(bit_count-1) <= W_EEPROM_SI_O;
       
            assert false report " EEPROM Controller is writing the 8-bit WRITE command to the EEPROM." severity NOTE;
            --wait for 40 ns;
            wait for spi_clk_half_period;
            bit_count <= bit_count - 1;
            --wait for 200 ns;
            wait for spi_clk_half_period;
            
         end loop;
          
 
      end do_rx_eeprom_data;     







     procedure do_wr_status is
      begin

         wait for spi_clk_half_period*3;
         --wait for 450 ns;
         
         
         bit_count <= 32;
         -- data from the master's side wishbone bus

         wait until W_EEPROM_CLK_O <= '1' ;     
         -- eeprom is reading the 8-bit command code
         while bit_count > 0 loop
            
            rx_eeprom_data(bit_count-1) <= W_EEPROM_SI_O;
       
            assert false report " EEPROM Controller is writing the 8-bit WRITE command to the EEPROM." severity NOTE;
            --wait for 40 ns;
            wait for spi_clk_half_period;
            bit_count <= bit_count - 1;
            --wait for 200 ns;
            wait for spi_clk_half_period;
            
         end loop;
          
 
      end do_wr_status;     


         
      procedure do_wait is
      begin
      
--         wait for PERIOD*5;
--      
--         -- data from the wishbone bus.  Try to start a cycle during DONE state
--         -- The eeprom controller should cancel the cycle right away with a RTY        
--         W_RST_I               <= '0';
--         W_ADDR_I              <= EEPROM_ADDR;
--         W_DAT_I               <= (others => '0');
--         W_WE_I                <= '0';
--         W_STB_I               <= '1';
--         W_CYC_I               <= '1';
--         W_TGA_I               <= (others => '0');
--         
--         wait for PERIOD;
--         
--         if W_RTY_O = '1' then
--            W_RST_I               <= '0';
--            W_ADDR_I              <= (others => '0');
--            W_DAT_I               <= (others => '0');
--            W_WE_I                <= '0';
--            W_STB_I               <= '0';
--            W_CYC_I               <= '0';
--            W_TGA_I               <= (others => '0');
--         end if;
      
         -- data from the wishbone bus
--         W_RST_I               <= '0';
--         W_ADDR_I              <= (others => '0');
--         W_DAT_I               <= (others => '0');
--         W_WE_I                <= '0';
--         W_STB_I               <= '0';
--         W_CYC_I               <= '0';
--         W_TGA_I               <= (others => '0');

         -- data from the EEPROM
         W_EEPROM_SO_I         <= 'Z';
         

      
         --wait for 300 ns;
         wait for spi_clk_half_period*3;
         
         assert false report " Waiting...." severity NOTE;
      end do_wait ;  
      
      
      
    procedure do_try_bus_cycle is
      begin      
               wait for PERIOD*5;
      
--         -- data from the wishbone bus.  Try to start a cycle during DONE state
--         -- The eeprom controller should cancel the cycle right away with a RTY        
--         W_RST_I               <= '0';
--         W_ADDR_I              <= EEPROM_ADDR;
--         W_DAT_I               <= (others => '0');
--         W_WE_I                <= '0';
--         W_STB_I               <= '1';
--         W_CYC_I               <= '1';
--         W_TGA_I               <= (others => '0');
--         
--         wait for PERIOD;
--         
--         if W_RTY_O = '1' then
--            W_RST_I               <= '0';
--            W_ADDR_I              <= (others => '0');
--            W_DAT_I               <= (others => '0');
--            W_WE_I                <= '0';
--            W_STB_I               <= '0';
--            W_CYC_I               <= '0';
--            W_TGA_I               <= (others => '0');
--         end if;     
            
         --wait for 300 ns;
         wait for spi_clk_half_period*3;
         
         assert false report " Attempting a bus cycle...." severity NOTE;
      end do_try_bus_cycle ; 
      
      
      procedure do_tx_sr_data is
      begin
--         bit_count <= 8;
--         wait for 1 ns;
--         W_RST_I               <= '0';
--         W_ADDR_I              <= EEPROM_ADDR;
--         W_DAT_I               <= (others => '0');
--         W_WE_I                <= '0';
--         W_STB_I               <= '1';
--         W_CYC_I               <= '1';
--         W_TGA_I               <= (others => '0');
         
         assert false report " Executing do_tx_sr_data." severity NOTE;
        --emulating 8 bits coming out of the EEPROM @ 1 bit per "slow" clock cycle
         --data is 11111100
         --wait until W_EEPROM_CLK_O <= '1';
         while bit_count > 0 loop
            --wait until (W_EEPROM_CLK_O'event and W_EEPROM_CLK_O <= '1');
            W_EEPROM_SO_I         <= sample_sr_data(bit_count-1);     
            bit_count <= bit_count - 1;
            assert false report " Reading data from the EEPROM." severity NOTE;

            --wait for 240 ns;
            wait for spi_clk_full_period;
    
         end loop;
         
         -- data from the EEPROM
         W_EEPROM_SO_I         <= 'Z';
         
      end do_tx_sr_data;
      
      
--      procedure do_finish is
--      begin
--      
----         W_RST_I               <= '0';
----         W_ADDR_I              <= EEPROM_ADDR;
----         W_DAT_I               <= (others => '0');
----         W_WE_I                <= '1';
----         W_STB_I               <= '1';
----         W_CYC_I               <= '1';
----         W_TGA_I               <= (others => '0');     
----         
--         --wait until W_ACK_O <= '0';
--         --wait for PERIOD;
----          
--         -- data from the wishbone bus
----         W_RST_I               <= '0';
----         W_ADDR_I              <= (others => '0');
----         W_DAT_I               <= (others => '0');
----         W_WE_I                <= '0';
----         W_STB_I               <= '0';
----         W_CYC_I               <= '0';
----         W_TGA_I               <= (others => '0');
----
----         -- data from the EEPROM
----         W_EEPROM_SO_I         <= 'Z';
--      
--         --wait for 300 ns;
--         wait for spi_clk_half_period*3;
--         
--         assert false report " Finishing up." severity NOTE;
--      end do_finish ;         
--      
































--      procedure do_wait is
--      begin
--      
--         wait for PERIOD;
--         
--         -- test software signals
--         W_RST_I       <= '0';
--         W_EN_I        <= '1';
--         W_TX_BUSY_I   <= '0';
--         W_TX_ACK_I    <= '0';      
--      
--         -- ID chip signal
--         --W_DATA_BI   <= 'H';      
--
--         wait for 10 us;        
--         
--         assert false report " Waiting for 10 us." severity NOTE;
--      end do_wait ;     
--      
 
 
      procedure do_tx_byte_to_RS232 is
      begin


         -- this means the test wrapper is ready to send data to the RS232
         if w_tx_stb_o = '0' then
            wait until w_tx_stb_o = '1';
         end if;
         
         if w_tx_we_o = '0' then
            wait until w_tx_we_o = '1';
         end if;
         
         -- test software signals
         W_RST_I       <= '0';
         W_EN_I        <= '1';
         W_TX_BUSY_I   <= '0';
         W_TX_ACK_I    <= '1';  -- grab the data
         
         wait for PERIOD;
         
         W_RST_I       <= '0';
         W_EN_I        <= '1';
         W_TX_BUSY_I   <= '1';  -- indicates it's busy now writing the "grabbed" data to the RS232
         W_TX_ACK_I    <= '0';
         
         
         wait for PERIOD*3;
         
         W_RST_I       <= '0';
         W_EN_I        <= '1';
         W_TX_BUSY_I   <= '0';
         W_TX_ACK_I    <= '0';   
         
         wait for PERIOD;      
         
         assert false report " Writing out the data to RS232." severity NOTE;
      end do_tx_byte_to_RS232;    


      procedure do_tx_byte_to_RS232_last is
      begin


         -- this means the test wrapper is ready to send data to the RS232
         if w_tx_stb_o = '0' then
            wait until w_tx_stb_o = '1';
         end if;
         
         if w_tx_we_o = '0' then
            wait until w_tx_we_o = '1';
         end if;
         
         -- test software signals
         W_RST_I       <= '0';
         W_EN_I        <= '1';
         W_TX_BUSY_I   <= '0';
         W_TX_ACK_I    <= '1';  -- grab the data
         
         wait until w_done_o = '0';
         
         W_RST_I       <= '0';
         W_EN_I        <= '0';
         W_TX_BUSY_I   <= '1';  -- indicates it's busy now writing the "grabbed" data to the RS232
         W_TX_ACK_I    <= '0';
         
         
         wait for PERIOD*3;
         
         W_RST_I       <= '0';
         W_EN_I        <= '0';
         W_TX_BUSY_I   <= '0';
         W_TX_ACK_I    <= '0';   
         
         wait for PERIOD;  
         
         assert false report " Writing out the data to RS232." severity NOTE;
      end do_tx_byte_to_RS232_last;  




      procedure do_finish is
      begin
      
         wait until W_DONE_O = '1';

         wait for PERIOD;
         
         -- test software signals
         W_RST_I       <= '0';
         W_EN_I        <= '0';
         W_TX_BUSY_I   <= '0';
         W_TX_ACK_I    <= '0';      
      


         wait for 100 ns;     
 
         assert false report " Finishing up..." severity NOTE;
      end do_finish ;     

------------------------------------------------------------------------
--
-- Start the test
--
------------------------------------------------------------------------
          
   begin
   
         do_nop;
      do_nop;
      do_nop;
      do_nop;
      do_nop;
      do_nop;
      do_nop;
      do_nop;
      
      do_reset; 
      




      do_SETUP_rX_RDSR_CMD ;
      do_SETUP_tX_SR_DATA ;

do_SETUP_rX_WRSR_CMD ;
do_SETUP_rX_SR_DATA ;
do_SETUP_rX_WREN_CMD ;
 
 do_wait;
 
 
       -- doing a WRITE to the EEPROM here

      do_rx_wr_cmd;
      
      do_rx_byte_addr2;
      
      do_rx_eeprom_data;
      
      do_SETUP_rX_RDSR_CMD ;
      
      do_tX_SR_DATA ;
 
      
      -- doing a READ from the EEPROM here
      do_rx_read_cmd;
      
      do_rx_byte_addr;
           
      do_tx_eeprom_data;
      
      do_rx_wb_data;
 
      --do_nop;
      --do_try_bus_cycle;
      

      
     --do_wr_status;
 
 -- add procedures for the status register check!!!!
      
      --do_finish;
   
   
   
   
             
      --do_wait;

      do_tx_byte_to_RS232;
      do_tx_byte_to_RS232;
      do_tx_byte_to_RS232;
      do_tx_byte_to_RS232;
      
      do_tx_byte_to_RS232;
      do_tx_byte_to_RS232;
      do_tx_byte_to_RS232;
      do_tx_byte_to_RS232;
      
--      do_tx_byte_to_RS232;
--      do_tx_byte_to_RS232;
--      do_tx_byte_to_RS232;
--      do_tx_byte_to_RS232;
--      
--      do_tx_byte_to_RS232;
--      do_tx_byte_to_RS232;
--      do_tx_byte_to_RS232;
--      do_tx_byte_to_RS232;
      
--      do_tx_byte_to_RS232_last;

      do_finish;
      
      assert false report " FINISHED: Simulation done." severity FAILURE;
      
   end process STIMULI;

end beh;
