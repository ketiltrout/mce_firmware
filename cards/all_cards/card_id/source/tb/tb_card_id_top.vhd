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
-- <revision control keyword substitutions e.g. $Id: tb_card_id_top.vhd,v 1.2 2004/04/07 22:26:15 erniel Exp $>
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
-- <date $Date: 2004/04/07 22:26:15 $>	-		<text>		- <initials $Author: erniel $>
-- $Log: tb_card_id_top.vhd,v $
-- Revision 1.2  2004/04/07 22:26:15  erniel
-- removed hard-coded card id address
--
--
-----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

--library work;
--use work.card_id_pack.all;

library components;
use components.component_pack.all;

library sys_param;
use sys_param.wishbone_pack.all;


entity tb_card_id_top is
end tb_card_id_top;

architecture beh of tb_card_id_top is

   component card_id

   generic(--WB_DATA_WIDTH         : integer := WB_DATA_WIDTH;
           --WB_ADDR_WIDTH         : integer := WB_ADDR_WIDTH;
           CARD_ID_ADDR         : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := CARD_ID_ADDR  );

   port(-- ID chip interface:
        data_bi : inout std_logic;

        -- Wishbone interface:
        clk_i   : in std_logic;
        rst_i   : in std_logic;		
        addr_i  : in std_logic_vector (WB_ADDR_WIDTH-1 downto 0);
        tga_i   : in std_logic_vector (WB_TAG_ADDR_WIDTH-1 downto 0);
        dat_i 	 : in std_logic_vector (WB_DATA_WIDTH-1 downto 0);
        dat_o   : out std_logic_vector (WB_DATA_WIDTH-1 downto 0);
        we_i    : in std_logic;
        stb_i   : in std_logic;
        ack_o   : out std_logic;
        rty_o   : out std_logic;
        cyc_i   : in std_logic ); 
   end component;


   constant PERIOD : time := 20 ns;

   signal W_DATA_BI           : std_logic ;
   signal W_CLK_I             : std_logic := '0';
   signal W_RST_I             : std_logic ;
   signal W_DAT_I             : std_logic_vector ( WB_DATA_WIDTH - 1 downto 0 );
   signal W_DAT_O             : std_logic_vector ( WB_DATA_WIDTH - 1 downto 0 );
   signal W_ADDR_I            : std_logic_vector ( WB_ADDR_WIDTH - 1 downto 0 );
   signal w_tga_i             : std_logic_vector ( WB_TAG_ADDR_WIDTH-1 downto 0);
   signal W_WE_I              : std_logic ;
   signal W_STB_I             : std_logic ;
   signal W_ACK_O             : std_logic ;
   signal w_rty_o             : std_logic ;
   signal W_CYC_I             : std_logic ;
   
   
   signal instr_command       : std_logic_vector(7 downto 0) := "00000000";

   constant SERIAL_CODE       : std_logic_vector(63 downto 0) :=  
                               "1000100011111111000000000000000011111111000000001111111100000000";
   -- alternate data for SERIAL_CODE:                           
   -- "0000111100001111000011110000111100001111000011110000111100001111";  -- 0x0F0F0F0F0F0F0F0F random data;
   -- "1000100011111111000000000000000011111111000000001111111100000000"   -- this is CRC calculated
   
   -- loop counters
   signal bit_count                    : integer := 1;
   signal i                            : integer := 8;
   
   -- reference data for self-checking
   signal reference_instr_command       : std_logic_vector(7 downto 0) := "00000000";
   signal reference_read_rom_cmd        : std_logic_vector(7 downto 0) := "00110011";
   
begin
------------------------------------------------------------------------
--
-- instantiate card_id_top
--
------------------------------------------------------------------------


   DUT : CARD_ID

      generic map(--WB_DATA_WIDTH        => WB_DATA_WIDTH ,
                  --WB_ADDR_WIDTH        => WB_ADDR_WIDTH ,
                  CARD_ID_ADDR   => CARD_ID_ADDR )

      port map(DATA_BI           => W_DATA_BI,
               CLK_I             => W_CLK_I,
               RST_I             => W_RST_I,
               DAT_I             => W_DAT_I,
               DAT_O             => W_DAT_O,
               ADDR_I            => W_ADDR_I,
               tga_i             => w_tga_i,
               WE_I              => W_WE_I,
               STB_I             => W_STB_I,
               ACK_O             => W_ACK_O,
               rty_o             => w_rty_o,
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
-- Procdures for creating stimulus !!!MODEL THE ID CHIP!!!
--
------------------------------------------------------------------------ 


      
      procedure do_nop is
      begin
         W_RST_I             <= '0';
         W_DAT_I             <= (others => '0');
         W_ADDR_I            <= (others => '0');
         W_WE_I              <= '0';
         W_STB_I             <= '0';
         W_CYC_I             <= '0';
         W_DATA_BI   <= 'Z';
         
         wait for PERIOD;
         
         assert false report " Performing a NOP." severity NOTE;
      end do_nop ;
      
      
      procedure do_full_reset is
      begin
         W_RST_I             <= '1';
         W_DAT_I             <= (others => '0');
         W_ADDR_I            <= (others => '0');
         W_WE_I              <= '0';
         W_STB_I             <= '0';
         W_CYC_I             <= '0';
         W_DATA_BI   <= 'H';
         
         wait for PERIOD*3;
         
         W_RST_I             <= '0';
         W_DAT_I             <= (others => '0');
         W_ADDR_I            <= (others => '0');
         W_WE_I              <= '0';
         W_STB_I             <= '0';
         W_CYC_I             <= '0';
         W_DATA_BI   <= 'H';
         
         wait for PERIOD;         
         
         assert false report " Performing a RESET." severity NOTE;
      end do_full_reset ;      

      procedure do_wb_start is
      begin
         -- signals from Wishbone
         W_RST_I               <= '0';
         W_DAT_I               <= (others => '0');
--         W_ADDR_I(31 downto 8) <= (others => '0');
         W_ADDR_I              <= CARD_ID_ADDR;
         W_WE_I                <= '0';
         W_STB_I               <= '1';
         W_CYC_I               <= '1';
         
         -- ID chip pulling bus high
         W_DATA_BI             <= 'H';
         
         wait for PERIOD;
         
         if w_rty_o = '1' then --slave is busy, end the bus cycle (but slave keeps running in the background)
            W_ADDR_I              <= "00000000";
            W_WE_I                <= '0';
            W_STB_I               <= '0';
            W_CYC_I               <= '0';
         end if;            
         
         assert false report " Initializing the Wishbone Bus." severity NOTE;
      end do_wb_start ;     



      procedure do_id_chip_init_pulse is
         begin
      
         W_DATA_BI             <= 'H';    
         wait for 400 us;
      
         wait until W_DATA_BI  <= 'H';
         
         -- this is the ID chip pulling the bus low
         wait for 15 us;
         W_DATA_BI             <= '0';
         wait for 60 us;
         -- release the bus
         W_DATA_BI             <= 'H';
      
         wait for PERIOD;

         assert false report "Presence Pulse is done";
      end do_id_chip_init_pulse;


      procedure do_id_chip_read_rom_cmd is
      begin
      
      while i > 0 loop

         W_DATA_BI   <= 'H';
        
         assert false report " Master is writing 0x33 to the DS18S20 " severity NOTE;

         wait until W_DATA_BI   <= '0';

         wait for 40 us;   
         
         -- sample the data and shift it into instr_command register
         instr_command <= W_DATA_BI & instr_command(7 downto 1);
         
         -- this is the reference data for the self-checking
         reference_instr_command <= reference_read_rom_cmd(8-i) & reference_instr_command(7 downto 1);
         
         i <= i-1;       
         wait for 20 us;
         
         -- self-checking: bit pattern during shift in should be
         -- 10000000 0x80 shift 1
         -- 11000000 0xC0 shift 2
         -- 01100000 0x60 shift 3
         -- 00110000 0x30 shift 4
         -- 10110000 0xB0 shift 5
         -- 11001100 0xCC shift 6
         -- 01100110 0x66 shift 7
         -- 00110011 0x33 shift 8
        
         --assert instr_command = reference_instr_command report " SELF-CHECKING FAILED DURING 'READ ROM' COMMAND " severity FAILURE;
      
        end loop; 
     end do_id_chip_read_rom_cmd; 
   

     procedure do_master_sample is
     begin
      
         while bit_count < 64 loop

         wait until W_DATA_BI = '0';

         wait for 4 us;   
         
         -- output the family code, serial code and CRC one bit at a time ;
         if SERIAL_CODE(bit_count-1) = '1' then
            W_DATA_BI <= 'H';
         else
            W_DATA_BI <= 'L';
         end if;   
         assert false report " Master is sampling bit from the DS18S20 " severity NOTE;
        
         wait for 56 us;
         bit_count <= bit_count + 1;     
         W_DATA_BI                 <= 'H';        
                  
         end loop;
         
      end do_master_sample; 


      procedure do_wb_finish is
      begin
      
      
      
       -- signals from Wishbone
         W_RST_I               <= '0';
         W_DAT_I               <= (others => '0');
--         W_ADDR_I(31 downto 8) <= (others => '0');
         W_ADDR_I              <= CARD_ID_ADDR;
         W_WE_I                <= '0';
         W_STB_I               <= '1';
         W_CYC_I               <= '1';
     
         wait for PERIOD;
         
         if w_rty_o = '1' then
            W_ADDR_I              <= "00000000";
            W_WE_I                <= '0';
            W_STB_I               <= '0';
            W_CYC_I               <= '0';
         end if;    
         
         wait for 40 us;
         
        -- signals from Wishbone
         W_RST_I               <= '0';
         W_DAT_I               <= (others => '0');
--         W_ADDR_I(31 downto 8) <= (others => '0');
         W_ADDR_I              <= CARD_ID_ADDR;
         W_WE_I                <= '0';
         W_STB_I               <= '1';
         W_CYC_I               <= '1';        
        
      
         wait until W_ACK_O  <= '1';
      
         W_RST_I             <= '0';
         W_DAT_I             <= (others => '0');
--         W_ADDR_I(31 downto 8) <= (others => '0');
         W_ADDR_I(7 downto 0)  <= CARD_ID_ADDR;         
         W_WE_I              <= '0';
         W_STB_I             <= '1';
         W_CYC_I             <= '1';
         
         wait until W_ACK_O  <= '0';
      
         W_RST_I             <= '0';
         W_DAT_I             <= (others => '0');
         W_ADDR_I            <= (others => '0');
         W_WE_I              <= '0';
         W_STB_I             <= '0';
         W_CYC_I             <= '0';
         
         
         
         wait for 100 us;
         
         assert false report " FINISHED." severity NOTE;
      end do_wb_finish ;     
      
   
------------------------------------------------------------------------
--
-- Start the test
--
------------------------------------------------------------------------
          
   begin
      do_nop;
      
      do_full_reset;  
      
      do_wb_start;
      
      
      
      do_id_chip_init_pulse;
      
      do_id_chip_read_rom_cmd;
      
      do_master_sample;
             
      do_wb_finish;
      
      assert false report " Simulation done." severity FAILURE;
      
   end process STIMULI;

end beh;
