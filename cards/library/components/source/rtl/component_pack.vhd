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
-- <revision control keyword substitutions e.g. $Id: component_pack.vhd,v 1.6 2004/05/20 17:19:40 mandana Exp $>
--
-- Project:		SCUBA-2
-- Author:		Jon Jacob
-- Organisation:	UBC
--
-- Description:
-- This file contains the declarations for the component library.
--
-- Revision history:
--
-- $Log: component_pack.vhd,v $
-- Revision 1.6  2004/05/20 17:19:40  mandana
-- updated counter with STEPSIZE
--
-- Revision 1.5  2004/05/05 21:24:17  erniel
-- added hex2ascii
--
-- Revision 1.4  2004/05/05 03:58:16  erniel
-- added rs232 data transmit controller
--
-- Revision 1.3  2004/04/23 00:53:59  mandana
-- added counter_xstep
--
-- Revision 1.2  2004/04/15 18:47:40  mandana
-- added write_spi_with_cs
--
-- Revision 1.1  2004/04/14 21:54:38  jjacob
-- new directory structure
--
-- Revision 1.7  2004/04/02 19:41:27  erniel
-- modified component reg declaration to match entity
--
-- Revision 1.6  2004/03/31 18:57:33  jjacob
-- added read_spi and write_spi components
--
-- Revision 1.5  2004/03/24 00:16:24  jjacob
-- add the nanosecond timer
--
-- Revision 1.4  2004/03/23 02:08:53  erniel
-- Added generic counter
--
-- Jan. 9 2004   - Package created      - JJ
--               - Added tristate

-- Jan. 14 2004  - Added up counter     - EL
--               - Added shift register
--               - Added CRC generator

-- Jan. 15 2004  - Added usec counter   - EL

-- Feb. 3  2004  - Added 1-wire modules - EL

-- Mar. 3  2004  - Added generic reg    - EL
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.general_pack.all;
use sys_param.wishbone_pack.all;

package component_pack is


------------------------------------------------------------
--
-- async_fifo 
--
------------------------------------------------------------  

component async_fifo
      generic(fifo_size : Positive);
      port( 
         rst_i     : in     std_logic;
         read_i    : in     std_logic;
         write_i   : in     std_logic;
         d_i       : in     std_logic_vector (7 DOWNTO 0);
         empty_o   : out    std_logic;
         full_o    : out    std_logic;
         q_o       : out    std_logic_vector (7 DOWNTO 0)
      );
   end component;


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
-- nanosecond timer
--
------------------------------------------------------------  

   component ns_timer
      port(clk           : in std_logic;
           timer_reset_i : in std_logic;
           timer_count_o : out integer  );
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
      generic(WIDTH : in integer range 1 to 512 := 8);
      
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
      generic(MAX     : integer := 255;
              STEPSIZE: integer := 1  );
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
-- generic step counter
--
------------------------------------------------------------ 
 
   component counter_xstep is
      generic(MAX : integer := 255);
      port(clk_i   : in std_logic;
           rst_i   : in std_logic;
           ena_i   : in std_logic;
           step_i  : in integer;
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
   
     
------------------------------------------------------------
--
-- Serial Peripheral Interface (SPI) blocks
--
------------------------------------------------------------    

   component read_spi
   generic(DATA_LENGTH : integer := 32);
   
   port(--inputs
      spi_clk_i        : in std_logic;
      rst_i            : in std_logic;
      start_i          : in std_logic;
      serial_rd_data_i : in std_logic;
       
      --outputs
      spi_clk_o        : out std_logic;
      done_o           : out std_logic;
      parallel_data_o  : out std_logic_vector(DATA_LENGTH-1 downto 0)
      );
     
   end component;


   component write_spi
   generic(DATA_LENGTH : integer := 8);

   port(--inputs
      spi_clk_i        : in std_logic;
      rst_i            : in std_logic;
      start_i          : in std_logic;
      parallel_data_i  : in std_logic_vector(DATA_LENGTH-1 downto 0);
     
      --outputs
      spi_clk_o        : out std_logic;
      done_o           : out std_logic;
      serial_wr_data_o : out std_logic);
     
   end component;

   component write_spi_with_cs
   generic(DATA_LENGTH : integer := 8);

   port(--inputs
      spi_clk_i        : in std_logic;
      rst_i            : in std_logic;
      start_i          : in std_logic;
      parallel_data_i  : in std_logic_vector(DATA_LENGTH-1 downto 0);
     
      --outputs
      spi_clk_o        : out std_logic;
      done_o           : out std_logic;
      spi_ncs_o            : out std_logic;
      serial_wr_data_o : out std_logic);
     
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

------------------------------------------------------------
--
-- RS232 data transmit controller
--
------------------------------------------------------------ 

component rs232_data_tx
generic(WIDTH : in integer range 1 to 1024 := 8);
port(clk_i   : in std_logic;
     rst_i   : in std_logic;
     data_i  : in std_logic_vector(WIDTH-1 downto 0);
     start_i : in std_logic;
     done_o  : out std_logic;

     tx_busy_i : in std_logic;
     tx_ack_i  : in std_logic;
     tx_data_o : out std_logic_vector(7 downto 0);
     tx_we_o   : out std_logic;
     tx_stb_o  : out std_logic);
end component;

------------------------------------------------------------
--
-- Hex to ASCII decoder
--
------------------------------------------------------------

component hex2ascii
port(hex_i   : in std_logic_vector(3 downto 0);
     ascii_o : out std_logic_vector(7 downto 0));
end component;

end component_pack;