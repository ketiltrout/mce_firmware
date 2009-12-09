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
-- <revision control keyword substitutions e.g. $Id: component_pack.vhd,v 1.38 2007/07/25 19:04:56 bburger Exp $>
--
-- Project:    SCUBA-2
-- Author:     Jon Jacob
-- Organisation:  UBC
--
-- Description:
-- This file contains the declarations for the component library.
--
-- Revision history:
--
-- $Log: component_pack.vhd,v $
-- Revision 1.38  2007/07/25 19:04:56  bburger
-- BB:  added the three_wire_master component declaration
--
-- Revision 1.37  2007/03/06 00:53:13  bburger
-- Bryce:  re-vamped the smb_master interaface to make it more generic. The smb_master is read only, but is not far off from supporting write commands as well.
--
-- Revision 1.36  2007/01/31 01:47:26  bburger
-- Bryce: added sync_fifo_tx
--
-- Revision 1.35  2006/10/19 22:12:32  bburger
-- Modified generic interface to one_wire_master to support external pull-ups on its data_in interface
--
-- Revision 1.34  2006/02/20 23:41:28  bburger
-- Bryce:  re-instated component declarations for crc, sync_fifo_rx and sync_fifo_tx for backwards compatibility with previous versions of issue_reply and dispatch
--
-- Revision 1.33  2006/01/20 21:23:18  erniel
-- added SMBus Master component
--
-- Revision 1.32  2005/10/21 19:05:19  erniel
-- updated one_wire_master component
--
-- Revision 1.31  2005/08/31 22:38:59  erniel
-- added parallel and serial CRC generators
--
-- Revision 1.30  2005/08/17 20:26:17  erniel
-- added binary counter
-- added ring counter
-- added grey counter
--
-- Revision 1.29  2005/08/10 23:34:21  erniel
-- updated clock_domain_interface component
--
-- Revision 1.28  2005/08/05 21:08:26  erniel
-- added clock domain interface module
--
-- Revision 1.27  2005/07/12 20:31:21  mandana
-- added fast-to-slow and slow-to-fast clock-domain crosser components
--
-- Revision 1.26  2005/07/04 18:44:57  erniel
-- added one_wire_master
-- removed obsolete 1-wire modules
--
-- Revision 1.25  2004/12/24 21:05:53  erniel
-- updated fifo component
--
-- Revision 1.24  2004/10/25 19:00:58  erniel
-- added generic showahead fifo
--
-- Revision 1.23  2004/10/12 14:17:10  dca
-- sync_fifo_tx component declaration added
--
-- Revision 1.22  2004/09/01 17:13:17  erniel
-- updated counter component
--
-- Revision 1.21  2004/08/10 17:22:44  erniel
-- updated lfsr component
--
-- Revision 1.20  2004/08/02 14:44:10  erniel
-- updated crc component
-- (added _i and _o to port names to match naming conventions)
--
-- Revision 1.19  2004/07/28 23:36:57  erniel
-- updated shift_reg component
-- updated lfsr component
-- (added _i and _o to port names to match naming conventions)
--
-- Revision 1.18  2004/07/22 00:01:56  erniel
-- updated counter component
--
-- Revision 1.17  2004/07/21 19:46:01  erniel
-- updated counter component
--
-- Revision 1.16  2004/07/19 21:26:59  erniel
-- updated crc component
--
-- Revision 1.15  2004/07/17 00:57:15  erniel
-- updated crc component
--
-- Revision 1.14  2004/07/16 22:56:16  erniel
-- updated crc component
--
-- Revision 1.13  2004/07/07 20:21:38  erniel
-- renamed lfsr data port (again) to lfsr_i/o
--
-- Revision 1.12  2004/07/07 19:43:19  erniel
-- updated lfsr port declaration
--
-- Revision 1.11  2004/07/07 19:33:52  erniel
-- added generic lfsr
--
-- Revision 1.10  2004/06/30 10:51:14  dca
-- "fifo_size" changed to "addr_size" in async_fifo component declaration
--
-- Revision 1.9  2004/06/28 13:24:04  dca
-- "is" removed from counter_xstep component declaration
--
-- Revision 1.8  2004/06/28 12:52:12  dca
-- added async_fifo
--
-- Revision 1.7  2004/06/28 12:51:07  dca
-- added async_fifo
--
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

package component_pack is

   ------------------------------------------------------------
   --
   -- clock domain crossing modules
   --
   ------------------------------------------------------------
   component clock_domain_interface
   generic(DATA_WIDTH : integer := 32);
   port(
      rst_i : in std_logic;

      src_clk_i : in std_logic;
      src_dat_i : in std_logic_vector(DATA_WIDTH-1 downto 0);
      src_rdy_i : in std_logic;
      src_ack_o : out std_logic;

      dst_clk_i : in std_logic;
      dst_dat_o : out std_logic_vector(DATA_WIDTH-1 downto 0);
      dst_rdy_o : out std_logic;
      dst_ack_i : in std_logic
   );
   end component;

   component fast2slow_clk_domain_crosser
   generic (
      NUM_TIMES_FASTER : integer := 2                                               -- divided ratio of fast clock to slow clock
   );
   port (
      -- global signals
      rst_i                     : in      std_logic;                                -- global reset
      clk_slow                  : in      std_logic;                                -- global slow clock
      clk_fast                  : in      std_logic;                                -- global fast clock
      -- input/output
      input_fast                : in      std_logic;                                -- fast input
      output_slow               : out     std_logic                                 -- slow output
   );
   end component;

   component slow2fast_clk_domain_crosser
   generic (
      NUM_TIMES_FASTER : integer := 2                                               -- divided ratio of fast clock to slow clock
      );
   port (
      -- global signals
      rst_i                     : in      std_logic;                                -- global reset
      clk_slow                  : in      std_logic;                                -- global slow clock
      clk_fast                  : in      std_logic;                                -- global fast clock
      -- input/output
      input_slow                : in      std_logic;                                -- slow input
      output_fast               : out     std_logic                                 -- fast output
   );
   end component;


   ------------------------------------------------------------
   --
   -- microsecond timer
   --
   ------------------------------------------------------------
   component us_timer
   port(
      clk           : in std_logic;
      timer_reset_i : in std_logic;
      timer_count_o : out integer
   );
   end component;


   ------------------------------------------------------------
   --
   -- nanosecond timer
   --
   ------------------------------------------------------------
   component ns_timer
   port(
      clk           : in std_logic;
      timer_reset_i : in std_logic;
      timer_count_o : out integer
   );
   end component;


   ------------------------------------------------------------
   --
   -- generic shift register
   --
   ------------------------------------------------------------
   component shift_reg
      generic(WIDTH : in integer range 2 to 512 := 8);

      port(clk_i      : in std_logic;
           rst_i      : in std_logic;
           ena_i      : in std_logic;
           load_i     : in std_logic;
           clr_i      : in std_logic;
           shr_i      : in std_logic;
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
   port(
      clk_i  : in std_logic;
      rst_i  : in std_logic;
      ena_i  : in std_logic;
      reg_i  : in std_logic_vector(WIDTH-1 downto 0);
      reg_o  : out std_logic_vector(WIDTH-1 downto 0)
   );
   end component;


   ------------------------------------------------------------
   --
   -- generic counters
   --
   ------------------------------------------------------------
   component counter
   generic(
      MAX         : integer := 255;
      STEP_SIZE   : integer := 1;
      WRAP_AROUND : std_logic := '1';
      UP_COUNTER  : std_logic := '1'
   );
   port(
      clk_i   : in std_logic;
      rst_i   : in std_logic;
      ena_i   : in std_logic;
      load_i  : in std_logic;
      count_i : in integer range 0 to MAX;
      count_o : out integer range 0 to MAX
   );
   end component;

   component binary_counter
   generic(WIDTH : integer range 2 to 64 := 8);
   port(
      clk_i   : in std_logic;
      rst_i   : in std_logic;
      ena_i   : in std_logic;
      up_i    : in std_logic;
      load_i  : in std_logic;
      clear_i : in std_logic;
      count_i : in std_logic_vector(WIDTH-1 downto 0);
      count_o : out std_logic_vector(WIDTH-1 downto 0)
   );
   end component;

   component ring_counter
   generic(
      WIDTH : integer range 2 to 64 := 8;
      MODE  : std_logic := '1'
   );
   port(
      clk_i   : in std_logic;
      rst_i   : in std_logic;
      ena_i   : in std_logic;
      up_i    : in std_logic;
      load_i  : in std_logic;
      clear_i : in std_logic;
      count_i : in std_logic_vector(WIDTH-1 downto 0);
      count_o : out std_logic_vector(WIDTH-1 downto 0)
   );
   end component;

   component grey_counter
   generic(WIDTH : integer range 2 to 64 := 8);
   port(
      clk_i   : in std_logic;
      rst_i   : in std_logic;
      ena_i   : in std_logic;
      up_i    : in std_logic;
      load_i  : in std_logic;
      clear_i : in std_logic;
      count_i : in std_logic_vector(WIDTH-1 downto 0);
      count_o : out std_logic_vector(WIDTH-1 downto 0)
   );
   end component;


   ------------------------------------------------------------
   --
   -- generic step counter
   --
   ------------------------------------------------------------
   component counter_xstep
   generic(MAX : integer := 255);
   port(
      clk_i   : in std_logic;
      rst_i   : in std_logic;
      ena_i   : in std_logic;
      step_i  : in integer;
      count_o : out integer
   );
   end component;


   ------------------------------------------------------------
   --
   -- generic CRC generators (uses arbitrary CRC polynomial)
   --
   ------------------------------------------------------------
   component crc
   generic(POLY_WIDTH : integer := 8);
   port(
      clk_i  : in std_logic;
      rst_i  : in std_logic;
      clr_i  : in std_logic;
      ena_i  : in std_logic;

      poly_i     : in std_logic_vector(POLY_WIDTH downto 1);
      data_i     : in std_logic;
      num_bits_i : in integer;
      done_o     : out std_logic;
      valid_o    : out std_logic;
      checksum_o : out std_logic_vector(POLY_WIDTH downto 1)
   );
   end component;

   component serial_crc
   generic(POLY_WIDTH : integer := 8);
   port(
      clk_i  : in std_logic;
      rst_i  : in std_logic;
      clr_i  : in std_logic;
      ena_i  : in std_logic;

      poly_i     : in std_logic_vector(POLY_WIDTH downto 1);
      data_i     : in std_logic;
      num_bits_i : in integer;
      done_o     : out std_logic;
      valid_o    : out std_logic;
      checksum_o : out std_logic_vector(POLY_WIDTH downto 1)
   );
   end component;

   component parallel_crc
   generic(
      POLY_WIDTH : integer := 8;
      DATA_WIDTH : integer := 8
   );
   port(
      clk_i  : in std_logic;
      rst_i  : in std_logic;
      clr_i  : in std_logic;
      ena_i  : in std_logic;

      poly_i      : in std_logic_vector(POLY_WIDTH downto 1);
      data_i      : in std_logic_vector(DATA_WIDTH downto 1);
      num_words_i : in integer;
      done_o      : out std_logic;
      valid_o     : out std_logic;
      checksum_o  : out std_logic_vector(POLY_WIDTH downto 1)
   );
   end component;


   ------------------------------------------------------------
   --
   -- generic FIFO with showahead
   --
   ------------------------------------------------------------
   component fifo
   generic(
      DATA_WIDTH : integer := 32;
      ADDR_WIDTH : integer := 8
   );
   port(
      clk_i     : in std_logic;
      rst_i     : in std_logic;

      data_i : in std_logic_vector(DATA_WIDTH-1 downto 0);
      data_o : out std_logic_vector(DATA_WIDTH-1 downto 0);

      read_i  : in std_logic;
      write_i : in std_logic;
      clear_i : in std_logic;

      empty_o : out std_logic;
      full_o  : out std_logic;
      error_o : out std_logic;
      used_o  : out integer
   );
   end component;


   ------------------------------------------------------------
   --
   -- 1-wire protocol components
   --
   ------------------------------------------------------------

   component one_wire_master
   generic(tristate : string := "INTERNAL");  -- valid values are "INTERNAL" and "EXTERNAL".
   port(
      clk_i         : in std_logic;
      rst_i         : in std_logic;

      -- host-side signals
      master_data_i : in std_logic_vector(7 downto 0);
      master_data_o : out std_logic_vector(7 downto 0);

      init_i        : in std_logic;      -- initialization
      read_i        : in std_logic;      -- read a byte
      write_i       : in std_logic;      -- write a byte

      done_o        : out std_logic;     -- operation completed
      ready_o       : out std_logic;     -- slave is ready
      ndetect_o     : out std_logic;     -- slave is detected

      -- slave-side signals
      slave_data_io : inout std_logic;   -- when using internal tristate, only connect slave_data_io, leave others open.
      slave_data_o  : out std_logic;     -- when using external tristate, use slave_data_io as data input.
      slave_wren_o  : out std_logic
   );
   end component;

   component three_wire_master
   port(
      clk_i         : in std_logic;
      rst_i         : in std_logic;

      -- host-side signals
      master_data_i : in std_logic_vector(7 downto 0);
      master_data_o : out std_logic_vector(7 downto 0);

      init_i        : in std_logic;         -- request initialization
      read_i        : in std_logic;         -- read a byte
      write_i       : in std_logic;         -- write a byte

      done_o        : out std_logic;        -- operation completed
      ready_o       : out std_logic;        -- slave is ready
      ndetect_o     : out std_logic;        -- slave is detected

      -- slave-side signals
      slave_data_i  : in std_logic;      -- if using external tristate, use this signal as data input
      slave_data_o  : out std_logic;
      slave_wren_n_o : out std_logic
   );
   end component;

   ------------------------------------------------------------
   --
   -- SMBus protocol components
   --
   ------------------------------------------------------------
   constant SMB_DATA_WIDTH : integer := 8;
   constant SMB_ADDR_WIDTH : integer := 7;

   component smb_master
   port(
      clk_i         : in std_logic;
      rst_i         : in std_logic;

      -- master-side signals
      r_nw_i        : in std_logic;                    -- read/not_write
      start_i       : in std_logic;                    -- read/write request
      addr_i        : in std_logic_vector(SMB_ADDR_WIDTH-1 downto 0); -- smb-slave register address
      data_i        : in std_logic_vector(SMB_DATA_WIDTH-1 downto 0); -- smb-slave data

      done_o        : out std_logic;                   -- read/write done
      error_o       : out std_logic;                   -- error
      data_o        : out std_logic_vector(SMB_DATA_WIDTH-1 downto 0); -- smb-slave data

      -- slave-side signals
      slave_clk_o   : out std_logic;                   -- SMBus clock
      slave_data_io : inout std_logic                  -- SMBus data
   );
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
   --
   --component prand
   --   generic (
   --      size : integer := 8     -- how many output bits do we want
   --                              -- (8, 16, 24 or 32)
   --   );
   --   port (
   --      clr_i : in std_logic;   -- asynchoronous clear input
   --      clk_i : in std_logic;   -- calculation clock
   --      en_i : in std_logic;    -- calculation enable line
   --      out_o : out std_logic_vector (size - 1 downto 0)   -- random output
   --   );
   --end component;

   ------------------------------------------------------------
   --
   -- RS232 data transmit controller
   --
   ------------------------------------------------------------

   --component rs232_data_tx
   --generic(WIDTH : in integer range 1 to 1024 := 8);
   --port(clk_i   : in std_logic;
   --     rst_i   : in std_logic;
   --     data_i  : in std_logic_vector(WIDTH-1 downto 0);
   --     start_i : in std_logic;
   --     done_o  : out std_logic;
   --
   --     tx_busy_i : in std_logic;
   --     tx_ack_i  : in std_logic;
   --     tx_data_o : out std_logic_vector(7 downto 0);
   --     tx_we_o   : out std_logic;
   --     tx_stb_o  : out std_logic);
   --end component;

   ------------------------------------------------------------
   --
   -- Hex to ASCII decoder
   --
   ------------------------------------------------------------
   component hex2ascii
   port(
      hex_i   : in std_logic_vector(3 downto 0);
      ascii_o : out std_logic_vector(7 downto 0)
   );
   end component;

   ------------------------------------------------------------
   --
   -- Generic LFSR
   --
   ------------------------------------------------------------
   component lfsr
   generic(WIDTH : in integer range 3 to 168 := 8);
   port(
      clk_i  : in std_logic;
      rst_i  : in std_logic;
      ena_i  : in std_logic;
      load_i : in std_logic;
      clr_i  : in std_logic;
      lfsr_i : in std_logic_vector(WIDTH-1 downto 0);
      lfsr_o : out std_logic_vector(WIDTH-1 downto 0)
   );
   end component;

   ------------------------------------------------------------
   --
   -- Synchronous FIFO for fibre_rx
   --
   ------------------------------------------------------------
   component sync_fifo_rx
   port(
      data    : in std_logic_vector (7 downto 0);
      wrreq      : in std_logic ;
      rdreq      : in std_logic ;
      rdclk      : in std_logic ;
      wrclk      : in std_logic ;
      aclr    : in std_logic ;
      q    : out std_logic_vector (7 downto 0);
      rdempty    : out std_logic ;
      wrfull     : out std_logic
   );
   end component;

   ------------------------------------------------------------
   --
   -- Synchronous Look-Ahead FIFO for fibre_tx
   --
   -- rdreq acts are read acknowledge
   ------------------------------------------------------------
   component sync_fifo_tx
   port(
      aclr     : IN STD_LOGIC  := '0';
      data     : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
      rdclk    : IN STD_LOGIC ;
      rdreq    : IN STD_LOGIC ;
      wrclk    : IN STD_LOGIC ;
      wrreq    : IN STD_LOGIC ;
      q        : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
      rdempty  : OUT STD_LOGIC ;
      wrfull   : OUT STD_LOGIC
   );
   end component;

   ------------------------------------------------------------
   --
   -- spi interface
   --
   -- serializes parallel input data and sends it over spi interface
   ------------------------------------------------------------

   component spi_if
   generic (
      PDATA_WIDTH : in integer range 1 to 32 := 16
   );   
   port ( 
      
      -- global signals
      rst_i                     : in     std_logic;                                       -- global reset
      clk_i                     : in     std_logic;                                       -- global clock
      
      -- SPI write inputs 
      spi_start_i               : in     std_logic;                                       -- SPI write trigger
      spi_pdat_i                : in     std_logic_vector(PDATA_WIDTH-1 downto 0);        -- SPI parallel write data
      
      -- SPI write outputs
      spi_csb_o                 : out    std_logic;                                       -- SPI chip select
      spi_sclk_o                : out    std_logic;                                       -- SPI serial write clock
      spi_sdat_o                : out    std_logic                                        -- SPI serial write data
      
      );
   end component;    

end component_pack;