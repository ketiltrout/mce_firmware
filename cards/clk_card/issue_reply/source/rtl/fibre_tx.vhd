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
-- fibre_tx.vhd
--
-- Project: Scuba 2
-- Author: David Atkinson  
-- Organisation: UK ATC
--
-- Description:
-- <description text>
--
-- Revision history:
-- <date $Date: 2004/10/12 14:19:59 $> - <text> - <initials $Author: dca $>
--
-- $Log: fibre_tx.vhd,v $
-- Revision 1.2  2004/10/12 14:19:59  dca
-- nTrp removed.  Various other changes due to fifo becoming synchronous.
--
-- Revision 1.1  2004/10/05 12:22:40  dca
-- moved from fibre_tx directory.
--
-- Revision 1.3  2004/09/29 14:56:41  dca
-- components declarations now in issue_reply_pack not fibre_tx_pack.
--
-- Revision 1.2  2004/09/29 14:26:18  dca
-- various signals removed from entity port
--
-- Revision 1.1  2004/08/31 12:58:30  dca
-- Initial Version
--


library ieee;
use ieee.std_logic_1164.all;

library work;
use work.issue_reply_pack.all;

library sys_param;
use sys_param.command_pack.all;


entity fibre_tx is
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

end fibre_tx;



-------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.issue_reply_pack.all;
use work.fibre_tx_pack.all;

architecture behav of fibre_tx is 


   -- Internal signal declarations
   signal tx_fr       : std_logic;                                        -- transmit fifo read request 
   signal tx_fe       : std_logic;                                        -- transmit fifo empty
   
              
   begin
 
   -- Instance port mappings.
   fibre_tx_fifo_inst : fibre_tx_fifo
   port map (
      clk_i        => clk_i,
      rst_i        => rst_i,
      fibre_clkw_i => fibre_clkw_i,
      tx_fr_i      => tx_fr,
      tx_fw_i      => tx_fw_i,
      txd_i        => txd_i,
      tx_fe_o      => tx_fe,
      tx_ff_o      => tx_ff_o,
      tx_data_o    => tx_data_o
   );
  
 
   fibre_tx_control_inst : fibre_tx_control 
      port map ( 
         fibre_clkw_i   =>   fibre_clkw_i,
         tx_fe_i        =>   tx_fe,
         tsc_nTd_o      =>   tsc_nTd_o,
         nFena_o        =>   nFena_o,
         tx_fr_o        =>   tx_fr
   );
   
 
  end behav;
