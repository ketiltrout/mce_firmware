-- Copyright (c) 2003 SCUBA-2 Project
--               All Rights Reserved
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
-- <Title>
--
-- <revision control keyword substitutions e.g. $Id$>
--
-- Project:		<project name>
-- Author:		<author name>
-- Organisation:	<organisation name>
--
-- Description:
-- <description text>
--
-- Revision history:
-- <date $Date$>	-		<text>		- <initials $Author$>
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

package card_id_pack is


   signal READ_ROM_CMD : std_logic_vector(7 downto 0) := "00110011"; -- 0x33


------------------------------------------------------------------------
--
-- card_id top level -- NEEDS TO BE MODIFIED ONCE TOP LEVEL IS READY
--
------------------------------------------------------------------------ 
 
   component card_id

   port (
          
      clk_i : in std_logic;
      rst_i : in std_logic;
      din   : in std_logic;
      dout  : out std_logic;
      en    : out std_logic
 
   );

   end component;      


------------------------------------------------------------------------
--
-- card_id_init
--
------------------------------------------------------------------------ 

   component card_id_init
   port(clk          : in std_logic;
        rst          : in std_logic;
        init_start_i : in std_logic;
        init_done_o  : out std_logic;
        data_bi      : inout std_logic);
   end component;

------------------------------------------------------------------------
--
-- card_id_cmd_read_rom
--
------------------------------------------------------------------------ 

   -- constants for card_id_cmd_read_rom:
   -- states for performing the "read rom" command (0x33) to the silicon ID chip
   -- to indicate read 64-bit ROM command
   
   constant IDLE                   : std_logic_vector := "000";
   constant WRITE0                 : std_logic_vector := "001";
   constant WAIT_90_MICRO_SEC      : std_logic_vector := "010";
   constant RELEASE_BUS            : std_logic_vector := "011";
   constant WAIT_5_MICRO_SEC       : std_logic_vector := "100";
   constant WRITE1                 : std_logic_vector := "101";
   constant DONE                   : std_logic_vector := "111";


   component card_id_cmd_read_rom
   port(
      clk                : in std_logic;
      rst                : in std_logic;
      write_cmd_start_i  : in std_logic; -- indicates to start up this state machine.  
      write_cmd_done_o   : out std_logic;
      data_bi            : inout std_logic);
   end component;
 
  
------------------------------------------------------------------------
--
-- card_id_read_serial_num
--
------------------------------------------------------------------------ 
 
   -- constants for card_id_read_serial_num:
   -- states for performing the serial number read from the silicon ID chip
   -- Some of the state encodings are the same as for card_id_write_0x33,
   -- so no need to redefine them.
   
-- constant IDLE                   : std_logic_vector := "000";
   constant PULL_DOWN              : std_logic_vector := "001";
   constant WAIT_5_MICRO_SEC_A     : std_logic_vector := "010";
-- constant RELEASE_BUS            : std_logic_vector := "011";
   constant WAIT_5_MICRO_SEC_B     : std_logic_vector := "100";
   constant MASTER_SAMPLE          : std_logic_vector := "101";
   constant WAIT_60_MICRO_SEC      : std_logic_vector := "110";
-- constant DONE                   : std_logic_vector := "111";

   component card_id_read_serial_num
   port(
      clk                   : in std_logic;
      rst                   : in std_logic;     
      read_serial_start_i   : in std_logic;
      read_serial_done_o    : out std_logic;
      data_bi               : inout std_logic;    
      serial_num_o          : out std_logic_vector(63 downto 0));
   end component;  
 
------------------------------------------------------------------------
--
-- card_id_cmd_skip_rom
--
------------------------------------------------------------------------  
   
   component card_id_cmd_skip_rom

   port (
      clk                  : in std_logic;
      rst                  : in std_logic;
      cmd_skip_rom_start_i : in std_logic;
      cmd_skip_rom_done_o  : out std_logic;
      data_bi              : inout std_logic  );
   end component; 
   
   
------------------------------------------------------------------------
--
-- card_id_cmd_convert_temp
--
------------------------------------------------------------------------  
 
   component card_id_cmd_convert_temp

   port (
      clk                         : in std_logic;
      rst                         : in std_logic;
      cmd_convert_temp_start_i    : in std_logic;
      cmd_convert_temp_done_o     : out std_logic;
      data_bi                     : inout std_logic ); 
   end component;
 
 
------------------------------------------------------------------------
--
-- card_id_wait_for_temp
--
------------------------------------------------------------------------   
   component card_id_wait_for_temp
   
   port (
      clk                   : in std_logic;
      rst                   : in std_logic;    
      init_fsm_ctrl_i       : in std_logic;
      fsm_done_ctrl_o       : out std_logic;
      data_bi               : inout std_logic );
end component; 
   
   
------------------------------------------------------------------------
--
-- card_id_write_data_1_wire
--
------------------------------------------------------------------------     

component write_data_1_wire
generic(DATA_LENGTH : integer := 8);

port(clk           : in std_logic;
     rst           : in std_logic;
     write_start_i : in std_logic;
     write_done_o  : out std_logic;
     write_data_i  : in std_logic_vector(DATA_LENGTH-1 downto 0);
     data_bi       : inout std_logic);
end component;

------------------------------------------------------------------------
--
-- card_id_read_data_1_wire
--
------------------------------------------------------------------------     

component read_data_1_wire
generic(DATA_LENGTH : integer := 8);

port(clk          : in std_logic;
     rst          : in std_logic;
     read_start_i : in std_logic;
     read_done_o  : out std_logic;
     read_data_o  : out std_logic_vector(DATA_LENGTH-1 downto 0);
     data_bi      : inout std_logic);
end component;

------------------------------------------------------------------------
--
-- card_id_crc
--
------------------------------------------------------------------------   

component crc
generic(DATA_LENGTH : integer := 64);

port(clk         : in std_logic;
     rst         : in std_logic;
     crc_start_i : in std_logic;
     crc_done_o  : out std_logic;
     crc_data_i  : in std_logic_vector(DATA_LENGTH-1 downto 0);
     valid_o     : out std_logic);
end component;

  
end card_id_pack;