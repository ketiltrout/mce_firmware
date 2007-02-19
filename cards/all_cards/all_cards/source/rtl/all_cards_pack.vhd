-- Copyright (c) 2003 SCUBA-2 Project
--                  All Rights Reserved
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
--
-- readout_card_pack.vhd
--
-- Project:   SCUBA-2
-- Author:        Mohsen Nahvi & Anthony Ko
-- Organisation:  UBC
--
-- Description:
-- The package file for the all_cards vhdl components.
--
--
-- Revision history:
-- <date $Date: 2006/05/05 19:17:43 $>    - <initials $Author: mandana $>
-- $Log: all_cards_pack.vhd,v $
-- Revision 1.1  2006/05/05 19:17:43  mandana
-- initial release
--
--
--
------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;



library sys_param;

-- System Library
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

library work;

package all_cards_pack is
  
  -----------------------------------------------------------------------------
  -- LED Component
  -----------------------------------------------------------------------------

   component leds
   port(clk_i   : in std_logic;
        rst_i   : in std_logic;     
        
        -- Wishbone signals
        dat_i   : in std_logic_vector (WB_DATA_WIDTH-1 downto 0); -- not used since not writing to array ID
        addr_i  : in std_logic_vector (WB_ADDR_WIDTH-1 downto 0);
        tga_i   : in std_logic_vector (WB_TAG_ADDR_WIDTH-1 downto 0);
        we_i    : in std_logic;
        stb_i   : in std_logic;
        cyc_i   : in std_logic;
        dat_o   : out std_logic_vector (WB_DATA_WIDTH-1 downto 0);
        ack_o   : out std_logic;
      
        -- LED outputs
        power   : out std_logic;
        status  : out std_logic;
        fault   : out std_logic);
   end component;      

  -----------------------------------------------------------------------------
  -- Firmware Revision Component
  -----------------------------------------------------------------------------

   component fw_rev
   generic ( REVISION: std_logic_vector (31 downto 0) := X"01010000");
   port(clk_i   : in std_logic;
        rst_i   : in std_logic;     
        
        -- Wishbone signals
        dat_i   : in std_logic_vector (WB_DATA_WIDTH-1 downto 0); -- not used since not writing to array ID
        addr_i  : in std_logic_vector (WB_ADDR_WIDTH-1 downto 0);
        tga_i   : in std_logic_vector (WB_TAG_ADDR_WIDTH-1 downto 0);
        we_i    : in std_logic;
        stb_i   : in std_logic;
        cyc_i   : in std_logic;
        err_o   : out std_logic;
        dat_o   : out std_logic_vector (WB_DATA_WIDTH-1 downto 0);
        ack_o   : out std_logic
      );
   end component;      

    -----------------------------------------------------------------------------
  -- slot_id component
  -----------------------------------------------------------------------------
  
  component bp_slot_id
    generic (SLOT_ID_BITS: integer := 4);

    port (   
      slot_id_i : in std_logic_vector (SLOT_ID_BITS-1 downto 0);
      -- wishbone signals
      clk_i   : in std_logic;
      rst_i   : in std_logic;    
      dat_i   : in std_logic_vector (WB_DATA_WIDTH-1 downto 0); -- not used since not writing to array ID
      addr_i  : in std_logic_vector (WB_ADDR_WIDTH-1 downto 0);
      tga_i   : in std_logic_vector (WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i    : in std_logic;
      stb_i   : in std_logic;
      cyc_i   : in std_logic;
      err_o   : out std_logic;
      dat_o   : out std_logic_vector (WB_DATA_WIDTH-1 downto 0);
      ack_o   : out std_logic);
  end component;

  -----------------------------------------------------------------------------
  -- Dispatch component
  -----------------------------------------------------------------------------

  component dispatch
    port(clk_i      : in std_logic;
      comm_clk_i : in std_logic;
      rst_i      : in std_logic;     
      
      -- bus backplane interface (LVDS)
      lvds_cmd_i   : in std_logic;
      lvds_reply_o : out std_logic;
      
      -- wishbone slave interface
      dat_o  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_o : out std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_o  : out std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_o   : out std_logic;
      stb_o  : out std_logic;
      cyc_o  : out std_logic;
      dat_i  : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_i  : in std_logic;
      err_i  : in std_logic;
      
      -- misc. external interface
      wdt_rst_o : out std_logic;
      slot_i    : in std_logic_vector(3 downto 0);

      dip_sw3 : in std_logic;
      dip_sw4 : in std_logic);
  end component;

  -----------------------------------------------------------------------------
  -- frame_timing component
  -----------------------------------------------------------------------------
  
  component frame_timing is
    port(
      -- Readout Card interface
      dac_dat_en_o               : out std_logic;
      adc_coadd_en_o             : out std_logic;
      restart_frame_1row_prev_o  : out std_logic;
      restart_frame_aligned_o    : out std_logic; 
      restart_frame_1row_post_o  : out std_logic;
      initialize_window_o        : out std_logic;
      fltr_rst_o                 : out std_logic;
      
      -- Address Card interface
      row_switch_o               : out std_logic;
      row_en_o                   : out std_logic;
         
      -- Bias Card interface
      update_bias_o              : out std_logic;
      
      -- Wishbone interface
      dat_i                      : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_i                     : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_i                      : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i                       : in std_logic;
      stb_i                      : in std_logic;
      cyc_i                      : in std_logic;
      dat_o                      : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_o                      : out std_logic;      
      
      -- Global signals
      clk_i                      : in std_logic;
      clk_n_i                    : in std_logic;
      rst_i                      : in std_logic;
      sync_i                     : in std_logic);
  end component;
  
  -----------------------------------------------------------------------------
  -- FPGA_thermo component
  -----------------------------------------------------------------------------

  component fpga_thermo
    port(clk_i : in std_logic;
        rst_i : in std_logic;

        -- wishbone signals
        dat_i   : in std_logic_vector (WB_DATA_WIDTH-1 downto 0); 
        addr_i  : in std_logic_vector (WB_ADDR_WIDTH-1 downto 0);
        tga_i   : in std_logic_vector (WB_TAG_ADDR_WIDTH-1 downto 0);
        we_i    : in std_logic;
        stb_i   : in std_logic;
        cyc_i   : in std_logic;
        err_o   : out std_logic;
        dat_o   : out std_logic_vector (WB_DATA_WIDTH-1 downto 0);
        ack_o   : out std_logic;
        
        -- SMBus temperature sensor signals
        smbclk_o : out std_logic;
        smbdat_io : inout std_logic);
  end component;
  
  -----------------------------------------------------------------------------
  -- Thermometer Component
  -----------------------------------------------------------------------------
   component id_thermo
   generic(
      tristate    : string := "INTERNAL";  -- valid values are "INTERNAL" and "EXTERNAL".
      card_or_box : string := "CARD");     -- valid values are "CARD" and "BOX".
   port(
      clk_i : in std_logic;
      rst_i : in std_logic;

      -- Wishbone signals
      dat_i   : in std_logic_vector (WB_DATA_WIDTH-1 downto 0);
      addr_i  : in std_logic_vector (WB_ADDR_WIDTH-1 downto 0);
      tga_i   : in std_logic_vector (WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i    : in std_logic;
      stb_i   : in std_logic;
      cyc_i   : in std_logic;
      err_o   : out std_logic;
      dat_o   : out std_logic_vector (WB_DATA_WIDTH-1 downto 0);
      ack_o   : out std_logic;

      -- silicon id/temperature chip signals
      data_io : inout std_logic;
      data_o  : out std_logic;
      wren_o  : out std_logic
   );
   end component;
    
end all_cards_pack;

