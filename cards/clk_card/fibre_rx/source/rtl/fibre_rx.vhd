-- Copyright (c) 2003 SCUBA-2 Project
-- All Rights Reserved
-- THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE SCUBA-2 Project
-- The copyright notice above does not evidence any
-- actual or intended publication of such source code.
-- SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
-- REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
-- MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
-- PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
-- THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.
-- For the purposes of this code the SCUBA-2 Project consists of the
-- following organisations.
-- UKATC, Royal Observatory, Blackford Hill Edinburgh EH9 3HJ
-- UBC, University of British Columbia, Physics & Astronomy Department,
-- Vancouver BC, V6T 1Z1
-- 
--
-- <revision control keyword substitutions e.g. $Id: fibre_rx.vhd,v 1.5 2004/06/30 10:56:56 dca Exp $>
--
-- Project: Scuba 2
-- Author: David Atkinson
-- Organisation: UK ATC
--
-- Title
-- fibre_rx
--
-- Description:
-- Fibre Optic front end receive firmware:
-- Instantiates:
-- 
-- 1. fibre_rx_control
-- 2. fibre_rx_fifo
-- 3. fibre_rx_protocol
--
-- Revision history:
-- <date $Date: 2004/06/30 10:56:56 $> - <text> - <initials $Author: dca $>
-- <log $log$>


library ieee;
use ieee.std_logic_1164.all;

library work;
use work.issue_reply_pack.all;
use work.fibre_rx_pack.all;



entity fibre_rx is
   port( 
      rst_i       : in     std_logic;                                         -- global reset
      clk_i       : in     std_logic;                                         -- gobal clock
      
      nrx_rdy_i   : in     std_logic;                                         -- received fibre data ready (active low) 
      rvs_i       : in     std_logic;                                         -- receive fibre data violation symbol (high indicates error)
      rso_i       : in     std_logic;                                         -- receive fibre status out
      rsc_nrd_i   : in     std_logic;                                         -- received special character / (Not) Data select
      rx_data_i   : in     std_logic_vector (RX_FIFO_DATA_WIDTH-1 downto 0);  -- received data byte from fibre  
      cmd_ack_i   : in     std_logic;                                         -- command acknowledge
      
      cmd_code_o  : out    std_logic_vector (CMD_CODE_BUS_WIDTH-1 downto 0);   -- command code  
      card_id_o   : out    std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);  -- card id
      param_id_o  : out    std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);     -- parameter id
      num_data_o  : out    std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);  -- number of valid 32 bit data words
      cmd_data_o  : out    std_logic_vector (DATA_BUS_WIDTH-1 downto 0);       -- 32bit valid data word
      cksum_err_o : out    std_logic;                                          -- checksum error flag
      cmd_rdy_o   : out    std_logic;                                          -- command ready flag (checksum passed)
      data_clk_o  : out    std_logic                                           -- data clock

    );


end fibre_rx;



-------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.issue_reply_pack.all;
use work.fibre_rx_pack.all;


architecture behav of fibre_rx is 

   -- Internal signal declarations
   signal rx_fr       : std_logic;                                        -- receive fifo read request
   signal rx_fw       : std_logic;                                        -- receive fifo write request
   signal rx_fe       : std_logic;                                        -- receive fifo empty
   signal rx_ff       : std_logic;                                        -- receive fifo full
   signal rxd         : std_logic_vector(RX_FIFO_DATA_WIDTH-1 DOWNTO 0);  -- data ouput of fifo
            
  begin

   -- Instance port mappings.
   I0 : fibre_rx_fifo
      generic map (
         addr_size => RX_FIFO_ADDR_SIZE              -- fifo size = 2**addr_size
      )
      port map (
         rst_i       => rst_i,
         rx_fr_i     => rx_fr,
         rx_fw_i     => rx_fw,
         rx_data_i   => rx_data_i,
         rx_fe_o     => rx_fe,
         rx_ff_o     => rx_ff,
         rxd_o       => rxd
   );

   I1: fibre_rx_control 
      port map ( 
         nrx_rdy_i  =>   nrx_rdy_i,
         rsc_nrd_i  =>   rsc_nrd_i,
         rso_i      =>   rso_i,
         rvs_i      =>   rvs_i,
         rx_ff_i    =>   rx_ff,
         rx_fw_o    =>   rx_fw
   );
 
 
   I2: fibre_rx_protocol
      port map ( 
         rst_i       =>   rst_i,
         clk_i       =>   clk_i,
         rx_fe_i     =>   rx_fe,
         rxd_i       =>   rxd,
         cmd_ack_i   =>   cmd_ack_i,
         
         cmd_code_o  =>   cmd_code_o,
         card_id_o   =>   card_id_o,
         param_id_o  =>   param_id_o,
         num_data_o  =>   num_data_o,
         cmd_data_o  =>   cmd_data_o,
         cksum_err_o =>   cksum_err_o,
         cmd_rdy_o   =>   cmd_rdy_o,
         data_clk_o  =>   data_clk_o,
         rx_fr_o     =>   rx_fr
      );
      
end behav;