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
-- $Id$
--
-- Project:    SCUBA2
-- Author:     Greg Dennis
-- Organization:  UBC
--
-- Description:
-- Declares a few constants used as parameters in the fibre_rx block
--
-- Revision history:
-- $Log$
--
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.command_pack.all;

library work;
use work.sync_gen_pack.all;
--use work.fibre_rx_pack.all;
--use work.fibre_tx_pack.all;
--use work.reply_translator_pack.all;
--use work.cmd_translator_pack.all;

package issue_reply_pack is

-------------------------------
component issue_reply
-------------------------------

port(
      --[JJ] for testing
      debug_o           : out std_logic_vector (31 downto 0);

      -- global sig nals
      rst_i             : in     std_logic;
      clk_i             : in     std_logic;
     
      
      
      -- inputs from the fibre receiver 
      fibre_clkr_i      : in     std_logic;
      rx_data_i         : in     std_logic_vector (7 DOWNTO 0);
      nRx_rdy_i         : in     std_logic;
      rvs_i             : in     std_logic;
      rso_i             : in     std_logic;
      rsc_nRd_i         : in     std_logic;        

      cksum_err_o       : out    std_logic;
    

      -- interface to fibre transmitter
      tx_data_o         : out    std_logic_vector (7 downto 0);      -- byte of data to be transmitted
      tsc_nTd_o         : out    std_logic;                          -- hotlink tx special char/ data sel
      nFena_o           : out    std_logic;                          -- hotlink tx enable

      -- 25MHz clock for fibre_tx_control
      fibre_clkw_i      : in     std_logic;                          -- in phase with 25MHz hotlink clock
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
      -- this signals are temporarily here for testing, in order to route these signals to top level
      -- to be viewed on the logic analyzer      
--      card_addr_o       :  out std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);   -- specifies which card the command is targetting
      parameter_id_o    : out   std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);      -- comes from param_id_i, indicates which device(s) the command is targetting
--      data_size_o       :  out std_logic_vector (FIBRE_DATA_SIZE_WIDTH-1 downto 0);   -- num_data_i, indicates number of 16-bit words of data
      data_o            : out   std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);        -- data will be passed straight thru
      data_clk_o        : out   std_logic;
      macro_instr_rdy_o : out   std_logic;
--      
--      m_op_seq_num_o    :  out std_logic_vector(7 downto 0);
--      frame_seq_num_o   :  out std_logic_vector(31 downto 0);
--      frame_sync_num_o  :  out std_logic_vector(7 downto 0);
--      
--      -- input from the micro-op sequence generator
--      ack_i             : in std_logic     
      
      macro_op_ack_o    : out    std_logic;

      -- lvds_tx interface
      tx_o              : out    std_logic;  -- transmitter output pin
      clk_200mhz_i      : in     std_logic;  -- PLL locked 25MHz input clock for the

      sync_pulse_i      : in     std_logic;
      sync_number_i     : in     std_logic_vector (SYNC_NUM_WIDTH-1 downto 0)
      ); 
     
end component;

end issue_reply_pack;
