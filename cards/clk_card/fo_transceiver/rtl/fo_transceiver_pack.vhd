-- Copyright (c) 2003 SCUBA-2 Project
--                  All Rights Reserved

--  THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE SCUBA-2 Project
--  The copyright notice above does not evidence any
--  actual or intended publication of such source code.

--  SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
--  REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
--  MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
--  PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
--  THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.

-- For the purposes of this code the SCUBA-2 Project consists of the
-- following organisations.

-- UKATC, Royal Observatory, Blackford Hill Edinburgh EH9 3HJ
-- UBC,   University of British Columbia, Physics & Astronomy Department,
--        Vancouver BC, V6T 1Z1
--
-- <Title> 
--
-- <revision control keyword substitutions e.g. $Id$>
--
-- Project:	     SCUBA-2
-- Author:	      David Atkinson
--               
-- Organisation:  UK ATC
--
-- Description: 
-- <description text>
--
-- Revision history:
-- 
-- <date $Date$>	-		<text>		- <initials $Author$>
-- <$log$>
--
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package fo_transceiver_pack is

--------------------------------------
-- fo_transceiver
---------------------------------------

   component fo_transceiver
   port( 
      rst_i       : in     std_logic;
      clk_i       : in     std_logic;
      
      rx_data_i   : in     std_logic_vector (7 DOWNTO 0);
      nRx_rdy_i   : in     std_logic;
      rvs_i       : in     std_logic;
      rso_i       : in     std_logic;
      rsc_nRd_i   : in     std_logic;  
      
      nTrp_i      : in     std_logic;
      ft_clkw_i   : in     std_logic; 
      
      cmd_ack_i   : in     std_logic;
      
      tx_data_o   : out    std_logic_vector (7 DOWNTO 0);      
      tsc_nTd_o   : out    std_logic;
      nFena_o     : out    std_logic
  
   );
   end component; 

--------------------------------------
-- simple_reply_fsm
---------------------------------------

   component simple_reply_fsm 
   port( 
        rst_i       : in     std_logic;
        clk_i       : in     std_logic;

        cmd_code_i  : in    std_logic_vector (15 DOWNTO 0);
        cksum_err_i : in    std_logic;
        cmd_rdy_i   : in    std_logic;
        tx_ff_i     : in    std_logic;

        txd_o       : out    std_logic_vector (7 DOWNTO 0);
        tx_fw_o     : out    std_logic 
    );
   end component;


---------------------------------------
-- tx_hotlink_sim
---------------------------------------


   component tx_hotlink_sim 
      port( 
         ft_clkw_i : in     std_logic;
         nFena_i   : in     std_logic;
         tsc_nTd_i : in     std_logic;   
         tx_data_i : in     std_logic_vector (7 downto 0);
         nTrp_o    : out    std_logic
       );
    end component;

-----------------------------------------
end fo_transceiver_pack;