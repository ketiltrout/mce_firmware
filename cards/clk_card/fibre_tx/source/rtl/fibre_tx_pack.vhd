-- Copyright (c) 2003 SCUBA-2 Project
--               All Rights Reserved
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
-- UBC, University of British Columbia, Physics & Astronomy Department,
-- Vancouver BC, V6T 1Z1
--
-- fibre_tx_pack.vhd
--
-- Project: Scuba 2
-- Author: David Atkinson	
-- Organisation: UK ATC
--
-- Description:
-- <description text>
--
-- Revision history:
-- <date $Date: 2004/08/30 11:04:41 $> - <text> - <initials $Author: dca $>
--
-- $Log: fibre_tx_pack.vhd,v $


library ieee;
use ieee.std_logic_1164.all;

package fibre_tx_pack is

constant TX_FIFO_DATA_WIDTH   : integer := 8;       -- size of data words in fibre receive FIFO
constant TX_FIFO_ADDR_SIZE    : integer := 10;       -- size of address bus in fibre receive FIFO 


 
--------------------------------------
-- fibre_tx
---------------------------------------


component fibre_tx 
      port( 
      
      -- global inputs
         rst_i        : in     std_logic;
         
      -- interface to reply_translator
      
         txd_i        : in     std_logic_vector(TX_FIFO_DATA_WIDTH-1 downto 0); 
         tx_fw_i      : in     std_logic;        
         tx_ff_o      : out    std_logic;
      
       -- interface to HOTLINK transmitter
         tx_fr_i      : in     std_logic;
         ft_clkw_i    : in     std_logic;
         nTrp_i       : in     std_logic;
         tx_fe_o      : out    std_logic; 
         tx_data_o    : out    std_logic_vector(TX_FIFO_DATA_WIDTH-1 downto 0); 
         tsc_nTd_o    : out    std_logic;
         nFena_o      : out    std_logic;
         tx_fr_o      : out    std_logic
      );

   end component;


 
--------------------------------------
-- fibre_tx_fifo
---------------------------------------

   component fibre_tx_fifo 
      generic(addr_size : Positive);                                             -- read/write address size
      port(                                                                      -- note: fifo size is 2**addr_size
         rst_i     : in     std_logic;                                           -- global reset
         tx_fr_i   : in     std_logic;                                           -- fifo read request
         tx_fw_i   : in     std_logic;                                           -- fifo write request
         txd_i     : in     std_logic_vector (TX_FIFO_DATA_WIDTH-1 DOWNTO 0);    -- data input
         tx_fe_o   : out    std_logic;                                           -- fifo empty flag
         tx_ff_o   : out    std_logic;                                           -- fifo full flag
         tx_data_o : out    std_logic_vector (TX_FIFO_DATA_WIDTH-1 DOWNTO 0)     -- data output
      );

   end component;

 
--------------------------------------
-- fibre_tx_contol
---------------------------------------
   
   component fibre_tx_control 
   port( 
      ft_clkw_i    : in     std_logic;
      nTrp_i       : in     std_logic;
      tx_fe_i      : in     std_logic;
      tsc_nTd_o    : out    std_logic;
      nFena_o      : out    std_logic;
      tx_fr_o      : out    std_logic
   );

end component;

   

end fibre_tx_pack;