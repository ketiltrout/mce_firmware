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

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
use work.card_id_pack.all;
use work.slave_ctrl_pack.all;
use work.sys_param_pack.all;

entity card_id_top is

generic(CARD_ID_DATA_WIDTH         : integer := CARD_ID_DATA_WIDTH;
        CARD_ID_ADDR_WIDTH         : integer := CARD_ID_ADDR_WIDTH;
        
        CARD_ID_TEMP_ADDR          : std_logic_vector(ADDR_LENGTH-1 downto 0) := CARD_ID_TEMP_ADDR;
        CARD_ID_SERIAL_NUM_ADDR    : std_logic_vector(ADDR_LENGTH-1 downto 0) := CARD_ID_SERIAL_NUM_ADDR  
        );

port(

   -- signals for the ID chip
   card_id_data_bi : inout std_logic;
   
   -- signals for the wishbone bus
   clk_i   : in std_logic;
   rst_i   : in std_logic;		
   dat_i 	 : in std_logic_vector (CARD_ID_DATA_WIDTH-1 downto 0);
   dat_o   : out std_logic_vector (CARD_ID_DATA_WIDTH-1 downto 0);
   addr_i  : in std_logic_vector (CARD_ID_ADDR_WIDTH-1 downto 0);
   we_i    : in std_logic;
   stb_i   : in std_logic;
   ack_o   : out std_logic; 
   cyc_i   : in std_logic );
   
end card_id_top;


architecture rtl of card_id_top is

signal init_done        : std_logic;
--signal write_cmd_done   : std_logic;
signal read_serial_done : std_logic;

signal serial_num : std_logic_vector(63 downto 0);
signal serial_number : std_logic_vector(63 downto 0);
signal serial_shift_reg : std_logic_vector(63 downto 0);


signal read_rom_cmd_done : std_logic;
signal crc_check_done    : std_logic;
signal valid             : std_logic;


signal start_i          : std_logic;
signal slave_wr_ready_sig   : std_logic;-- := '0';


signal temp             : std_logic_vector (CARD_ID_DATA_WIDTH-1 downto 0);  -- we don't need any input arguments


begin

------------------------------------------------------------------------
--
-- Instantiate card_id stuff
--
------------------------------------------------------------------------

-- Needs to be bettered
-- derive the start signal 
 start_i <= '1' when (addr_i(ADDR_LENGTH-1 downto 0) = CARD_ID_SERIAL_NUM_ADDR and
                       we_i = '0' and cyc_i = '1' and stb_i = '1') else '0';



   init: card_id_init
   port map(clk => clk_i,
            rst => rst_i,
            init_start_i => start_i,
            init_done_o => init_done,
            data_bi => card_id_data_bi);
            

   cmd_read_rom : write_data_1_wire
   port map(clk     => clk_i,
      rst           => rst_i,
      write_start_i => init_done,
      write_done_o  => read_rom_cmd_done,
      write_data_i  => READ_ROM_CMD, -- 0x33
      data_bi       => card_id_data_bi);
 
 
   read_serial_num : read_data_1_wire
   generic map(DATA_LENGTH => 64)

   port map(clk          => clk_i,
      rst          => rst_i,
      read_start_i => read_rom_cmd_done,
      read_done_o  => read_serial_done,
      read_data_o  => serial_num,
      data_bi      => card_id_data_bi);

 
      
--   read : card_id_read_serial_num
--   port map(clk => clk_i,
--            rst => rst_i,
--            read_serial_start_i => read_rom_cmd_done,
--            read_serial_done_o => read_serial_done,
--            serial_num_o => serial_num,
--            data_bi => card_id_data_bi);
   
   crc_check : crc
   port map   
     (clk    => clk_i,
      rst       => rst_i,  
      crc_start_i => read_serial_done,
      crc_done_o  => crc_check_done,
      crc_data_i      => serial_num,
      valid_o     => valid);       
            
------------------------------------------------------------------------
--
-- Slave controller for the serial number
--
------------------------------------------------------------------------            

-- if the crc is valid, send back the serial number from the ID chip
-- otherwise, send back the error code 0xFF
serial_number <= serial_num when valid = '1' else (others => '1');


card_id_slave_ctrl : slave_ctrl
   generic map(SLAVE_SEL  => CARD_ID_TEMP_ADDR,
            ADDR_WIDTH => CARD_ID_ADDR_WIDTH,
            DATA_WIDTH => CARD_ID_DATA_WIDTH )
      
   port map(
 

      slave_wr_ready => slave_wr_ready_sig,
      slave_rd_data_valid => read_serial_done,
    slave_dat_i => serial_number(31 downto 0),  --fix this!!! split it up into two transactions.
      

      slave_dat_o => temp,
 
      clk_i   => clk_i,
      rst_i  => rst_i, 
      dat_i 	 => dat_i,
      addr_i  => addr_i,
      we_i     =>  we_i,
      stb_i   => stb_i,
      cyc_i   => cyc_i,

      dat_o   =>  dat_o,
      ack_o   =>  ack_o
 
   );

       
            
end rtl;