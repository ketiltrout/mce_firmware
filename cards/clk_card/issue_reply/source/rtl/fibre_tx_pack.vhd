-- Copyright (c) 2003 SCUBA-2 Project
--               All Rights Reserved
--
-- THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE SCUBA-2 Project
-- The copyright notice above does not evidence any
-- actual or intended publication of such source code.
--
-- SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
-- REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
-- MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
-- PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
-- THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.
--
-- For the purposes of this code the SCUBA-2 Project consists of the
-- following organisations.
--
-- UKATC, Royal Observatory, Blackford Hill Edinburgh EH9 3HJ
-- UBC,   University of British Columbia, Physics & Astronomy Department,
--        Vancouver BC, V6T 1Z1
--
-- $Id: fibre_tx_pack.vhd,v 1.1 2004/11/24 01:15:52 bench2 Exp $
--
-- Project:    SCUBA2
-- Author:     Greg Dennis
-- Organization:  UBC
--
-- Description:
-- Declares a few constants used as parameters in the fibre_tx block
--
-- Revision history:
-- $Log: fibre_tx_pack.vhd,v $
-- Revision 1.1  2004/11/24 01:15:52  bench2
-- Greg: Broke apart issue reply and created pack files for all of its sub-components
--
--
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.command_pack.all;

library work;
use work.sync_gen_pack.all; 

package fibre_tx_pack is

constant TX_FIFO_DATA_WIDTH   : integer := 8; 

---------------------------
component fibre_tx 
----------------------------
      port(       
      -- global inputs
         clk_i        : in     std_logic;
         rst_i        : in     std_logic;                         -- global reset
         
      -- interface to reply_translator
      
         txd_i        : in     std_logic_vector (7 downto 0);     -- FIFO input byte
         tx_fw_i      : in     std_logic;                         -- FIFO write request
         tx_ff_o      : out    std_logic;                         -- FIFO full flag
      
      -- interface to HOTLINK transmitter
         fibre_clkw_i : in     std_logic;                          -- 25MHz hotlink clock
         tx_data_o    : out    std_logic_vector (7 downto 0);      -- byte of data to be transmitted
         tsc_nTd_o    : out    std_logic;                          -- hotlink tx special char/ data sel
         nFena_o      : out    std_logic                           -- hotlink tx enable
      );

end component;


------------------------------
component fibre_tx_fifo 
------------------------------   

port( 
   clk_i        : in     std_logic;
   rst_i        : in     std_logic;
   fibre_clkw_i : in     std_logic;
   tx_fr_i      : in     std_logic;
   tx_fw_i      : in     std_logic;
   txd_i        : in     std_logic_vector (7 downto 0);
   tx_fe_o      : out    std_logic;
   tx_ff_o      : out    std_logic;
   tx_data_o    : out    std_logic_vector (7 downto 0)
   );
end component;


-----------------------------  
component fibre_tx_control
----------------------------- 
port( 
   rst_i        : in     std_logic;
   fibre_clkw_i : in     std_logic;
   tx_fe_i      : in     std_logic;
   tsc_nTd_o    : out    std_logic;
   nFena_o      : out    std_logic;
   tx_fr_o      : out    std_logic
   );

end component;

end fibre_tx_pack;
