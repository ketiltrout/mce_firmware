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
--
-- <revision control keyword substitutions e.g. $Id: simple_reply_fsm_pack.vhd,v 1.1 2004/06/15 15:50:02 dca Exp $>
--
-- Project:	      SCUBA-2
-- Author:	      David Atkinson
--               
-- Organisation:  UK ATC
--
-- Description:  simple_reply_fsm_pack
--
-- This block is for test purposes and generates a an appropriate reply when a command
-- is received.  For use with the NIOS development kit / fo tranceiver board.
--
--
-- Revision history:
-- 
-- <date $Date: 2004/06/15 15:50:02 $>	-		<text>		- <initials $Author: dca $>
-- $log$
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package simple_reply_fsm_pack is

   component simple_reply_fsm 
   port( 
      rst_i        : in     std_logic;
      clk_i        : in     std_logic;

      cmd_code_i   : in    std_logic_vector (15 downto 0);
      cksum_err_i  : in    std_logic;
      cmd_rdy_i    : in    std_logic;
      tx_ff_i      : in    std_logic;

      txd_o        : out    std_logic_vector (7 downto 0);
      tx_fw_o      : out    std_logic 
   );
   end component;
   

   
end simple_reply_fsm_pack;