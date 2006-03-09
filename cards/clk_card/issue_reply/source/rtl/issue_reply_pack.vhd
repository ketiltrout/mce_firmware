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
-- $Id: issue_reply_pack.vhd,v 1.43 2006/02/11 01:19:33 bburger Exp $
--
-- Project:    SCUBA2
-- Author:     Greg Dennis
-- Organization:  UBC
--
-- Description:
-- Declares a few constants used as parameters in the fibre_rx block
--
-- Revision history:
-- $Log: issue_reply_pack.vhd,v $
-- Revision 1.43  2006/02/11 01:19:33  bburger
-- Bryce:  Added the following signal interfaces to implement responding to external dv pulses
-- data_req
-- data_ack
-- frame_num_external
--
-- Revision 1.42  2006/01/16 18:58:05  bburger
-- Ernie:
-- Added component declarations
-- Updated the interfaces to issue_reply sub-blocks
--
-- Revision 1.41  2005/03/19 00:31:23  bburger
-- bryce:  Fixed several bugs.  Tagging cc_01010007.
--
-- Revision 1.40  2005/03/16 02:20:58  bburger
-- bryce:  removed mem_clk from the cmd_queue and sync_gen blocks
--
-- Revision 1.39  2005/03/04 03:45:58  bburger
-- Bryce:  fixed bugs associated with ret_dat_s and ret_dat
--
-- Revision 1.38  2005/01/12 22:18:24  mandana
-- added comm_clk_i (shouldn't have removed it!)
--
-- Revision 1.37  2005/01/12 21:53:01  mandana
-- Updated cmd_queue interface by deleting comm_clk_i
--
-- Revision 1.36  2004/11/30 22:58:47  bburger
-- Bryce:  reply_queue integration
--
-- Revision 1.35  2004/11/24 01:15:52  bench2
-- Greg: Broke apart issue reply and created pack files for all of its sub-components
--
--
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

library work;
use work.sync_gen_pack.all;

package issue_reply_pack is

component issue_reply
   port(
      -- for testing
      debug_o           : out std_logic_vector (31 downto 0);

      -- global signals
      rst_i             : in std_logic;
      clk_i             : in std_logic;
      comm_clk_i        : in std_logic;

      -- inputs from the bus backplane
      lvds_reply_ac_a   : in std_logic;  
      lvds_reply_bc1_a  : in std_logic;
      lvds_reply_bc2_a  : in std_logic;
      lvds_reply_bc3_a  : in std_logic;
      lvds_reply_rc1_a  : in std_logic;
      lvds_reply_rc2_a  : in std_logic;
      lvds_reply_rc3_a  : in std_logic; 
      lvds_reply_rc4_a  : in std_logic;
      lvds_reply_cc_a   : in std_logic;
      
      -- inputs from the fibre receiver 
      fibre_clkr_i      : in std_logic;
      rx_data_i         : in std_logic_vector (7 DOWNTO 0);
      nRx_rdy_i         : in std_logic;
      rvs_i             : in std_logic;
      rso_i             : in std_logic;
      rsc_nRd_i         : in std_logic;        
      cksum_err_o       : out std_logic;

      -- interface to fibre transmitter
      tx_data_o         : out std_logic_vector (7 downto 0);      -- byte of data to be transmitted
      tsc_nTd_o         : out std_logic;                          -- hotlink tx special char/ data sel
      nFena_o           : out std_logic;                          -- hotlink tx enable

      -- 25MHz clock for fibre_tx_control
      fibre_clkw_i      : in std_logic;                           -- in phase with 25MHz hotlink clock

      -- lvds_tx interface
      lvds_cmd_o        : out std_logic;                          -- transmitter output pin

      -- ret_dat_wbs interface:
      start_seq_num_i   : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      stop_seq_num_i    : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      data_rate_i       : in std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
      dv_mode_i         : in std_logic_vector(DV_SELECT_WIDTH-1 downto 0);
      external_dv_i     : in std_logic;
      external_dv_num_i : in std_logic_vector(DV_NUM_WIDTH-1 downto 0);

      -- sync_gen interface
      sync_pulse_i      : in std_logic;
      sync_number_i     : in std_logic_vector (SYNC_NUM_WIDTH-1 downto 0)
   );    
end component;

end issue_reply_pack;
