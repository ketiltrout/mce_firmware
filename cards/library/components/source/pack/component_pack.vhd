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
-- component_pack
--
-- <revision control keyword substitutions e.g. $Id: component_pack.vhd,v 1.3 2004/03/17 07:19:30 ngruending Exp $>
--
-- Project:		SCUBA-2
-- Author:		Jon Jacob
-- Organisation:	UBC
--
-- Description:
-- This file contains the declarations for the component library.
--
-- Revision history:
-- Jan. 9 2004   - Package created      - JJ
--               - Added tristate

-- Jan. 14 2004  - Added up counter     - EL
--               - Added shift register
--               - Added CRC generator

-- Jan. 15 2004  - Added usec counter   - EL

-- Feb. 3  2004  - Added 1-wire modules - EL

-- Mar. 3  2004  - Added generic reg    - EL
-- <date $Date: 2004/03/17 07:19:30 $>	-		<text>		- <initials $Author: ngruending $>
-- $Log$
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.general_pack.all;
use sys_param.wishbone_pack.all;

package component_pack is

------------------------------------------------------------
--
-- tristate buffers (_vec is a vector buffer)
--
------------------------------------------------------------  
   
   component tri_state_buf
      port(data_i  : in std_logic;
           buf_en_i  : in std_logic;
           data_o  : out std_logic);
   end component; 
   
   component tri_state_buf_vec
      generic(WIDTH : integer range 2 to 512 := 2);
      
      port(data_i  : in std_logic_vector(WIDTH-1 downto 0);
           buf_en_i  : in std_logic;
           data_o  : out std_logic_vector(WIDTH-1 downto 0));
   end component; 
   
   
------------------------------------------------------------
--
-- microsecond timer
--
------------------------------------------------------------  

   component us_timer
      port(clk           : in std_logic;
           timer_reset_i : in std_logic;
           timer_count_o : out integer);
   end component;
   

------------------------------------------------------------
--
-- generic shift register
--
------------------------------------------------------------  

   component shift_reg
      generic(WIDTH : in integer range 2 to 512 := 8);

      port(clk        : in std_logic;
           rst        : in std_logic;
           ena        : in std_logic;
           load       : in std_logic;
           clr        : in std_logic;
           shr        : in std_logic;
           serial_i   : in std_logic;
           serial_o   : out std_logic;
           parallel_i : in std_logic_vector(WIDTH-1 downto 0);
           parallel_o : out std_logic_vector(WIDTH-1 downto 0));
   end component;


------------------------------------------------------------
--
-- generic register (no shift)
--
------------------------------------------------------------  

   component reg
      generic(WIDTH : in integer range 2 to 512 := 8);
      
      port(clk_i  : in std_logic;
           rst_i  : in std_logic;
           ena_i  : in std_logic;

           reg_i  : in std_logic_vector(WIDTH-1 downto 0);
           reg_o  : out std_logic_vector(WIDTH-1 downto 0));
   end component;
 

------------------------------------------------------------
--
-- generic counter
--
------------------------------------------------------------ 

   component counter 
      generic(MAX : integer := 255);
      port(clk_i   : in std_logic;
           rst_i   : in std_logic;
           ena_i   : in std_logic;
           load_i  : in std_logic;
           down_i  : in std_logic;
           count_i : in integer;
           count_o : out integer);
   end component;
 
 
------------------------------------------------------------
--
-- 1-wire signaling protocol components
--
------------------------------------------------------------ 

   -- 1-wire protocol R/W timing information:
   constant RESET_DURATION_US      : integer := 500;
   constant PRESENCE_DURATION_US   : integer := 500;
   constant SAMPLING_DELAY_US      : integer := 60;
   constant SLOT_DURATION_US       : integer := 90;
   constant WRITE_0_DELAY_US       : integer := 70;
   constant WRITE_1_DELAY_US       : integer := 10;
   constant READ_INITIATE_DELAY_US : integer := 2;
   constant READ_VALID_DELAY_US    : integer := 13;
   
   component crc
      generic(DATA_LENGTH : integer := 64);

      port(clk         : in std_logic;
           rst         : in std_logic;
           crc_start_i : in std_logic;
           crc_done_o  : out std_logic;
           crc_data_i  : in std_logic_vector(DATA_LENGTH-1 downto 0);
           valid_o     : out std_logic);
   end component;  
   
   component init_1_wire
      port(clk          : in std_logic;
           rst          : in std_logic;
           init_start_i : in std_logic;
           init_done_o  : out std_logic;
           data_bi      : inout std_logic);
   end component;

   component write_data_1_wire
      generic(DATA_LENGTH : integer := 8);

      port(clk           : in std_logic;
           rst           : in std_logic;
           write_start_i : in std_logic;
           write_done_o  : out std_logic;
           write_data_i  : in std_logic_vector(DATA_LENGTH-1 downto 0);
           data_bi       : inout std_logic);
   end component;
   
   component read_data_1_wire
      generic(DATA_LENGTH : integer := 8);

      port(clk           : in std_logic;
           rst           : in std_logic;
           read_start_i  : in std_logic;
           read_done_o   : out std_logic;
           read_data_o   : out std_logic_vector(DATA_LENGTH-1 downto 0);
           data_bi       : inout std_logic);
   end component;
  
   
------------------------------------------------------------
--
-- Wishbone protocol components
--
------------------------------------------------------------ 
   
   component slave_ctrl
      generic(SLAVE_SEL      : std_logic_vector(WB_ADDR_WIDTH - 1 downto 0) := (others => '0');
              ADDR_WIDTH     : integer := WB_ADDR_WIDTH;
              DATA_WIDTH     : integer := WB_DATA_WIDTH;
              TAG_ADDR_WIDTH : integer := WB_TAG_ADDR_WIDTH);
      
      port(slave_wr_ready           : in std_logic;
           master_wr_data_valid     : out std_logic;
           slave_rd_data_valid      : in std_logic;
           slave_retry              : in std_logic;
           slave_ctrl_dat_i         : in std_logic_vector (DATA_WIDTH-1 downto 0);
           slave_ctrl_dat_o         : out std_logic_vector (DATA_WIDTH-1 downto 0);
           slave_ctrl_tga_o         : out std_logic_vector (TAG_ADDR_WIDTH-1 downto 0);
      
           -- wishbone signals
           clk_i  : in std_logic;
           rst_i  : in std_logic;		
           dat_i 	: in std_logic_vector (DATA_WIDTH-1 downto 0);
           addr_i : in std_logic_vector (ADDR_WIDTH-1 downto 0);
           tga_i  : in std_logic_vector (TAG_ADDR_WIDTH-1 downto 0);
           we_i   : in std_logic;
           stb_i  : in std_logic;
           cyc_i  : in std_logic;
           dat_o  : out std_logic_vector (DATA_WIDTH-1 downto 0);
           rty_o  : out std_logic;
           ack_o  : out std_logic);
   end component;
   
     
   
component write_serial_data
generic(DATA_LENGTH : integer := 8);

port(clk           : in std_logic;
     rst           : in std_logic;
     write_start_i : in std_logic;
     write_done_o  : out std_logic;
     write_data_i  : in std_logic_vector(DATA_LENGTH-1 downto 0);
     data_o        : out std_logic);
end component;   
 
 
   
component read_serial_data
generic(DATA_LENGTH : integer := 32);

port(clk           : in std_logic;
     rst           : in std_logic;
     read_start_i  : in std_logic;
     read_done_o   : out std_logic;
     --read_data_i   : in std_logic_vector(DATA_LENGTH-1 downto 0);
     read_data_i        : in std_logic; -- serial data from the eeprom
     read_data_o        : out std_logic_vector(DATA_LENGTH-1 downto 0) ); -- serial data from the eeprom sent back to the eeprom controller state machine
end component;   


------------------------------------------------------------
--
-- Pusedo random number generator
--
------------------------------------------------------------ 

component prand
   generic (
      size : integer := 8     -- how many output bits do we want
                              -- (8, 16, 24 or 32)
   );
   port (
      clr_i : in std_logic;   -- asynchoronous clear input
      clk_i : in std_logic;   -- calculation clock
      en_i : in std_logic;    -- calculation enable line
      out_o : out std_logic_vector (size - 1 downto 0)   -- random output
   );
end component;

end component_pack;