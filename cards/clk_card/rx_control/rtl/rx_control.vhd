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
-- <revision control keyword substitutions e.g. $Id$>
--
-- Project:	      SCUBA-2
-- Author:	      David Atkinson
--               
-- Organisation:  UK ATC
--
-- Description: This block controls the writing of data to the FIFO block 'rx_fifo',
-- using signals from the cyress HOTLINK receiver.
-- 
--
-- Revision history:
-- 22nd February 2004   - Initial version      - DA
-- 
-- <date $Date$>	-		<text>		- <initials $Author$>
--

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY rx_control IS
   PORT( 
      nRx_rdy_i : IN     std_logic;
      rsc_nRd_i : IN     std_logic;
      rso_i     : IN     std_logic;
      rvs_i     : IN     std_logic;
      rx_ff_i   : IN     std_logic;
      rx_fw_o   : OUT    std_logic
   );

-- Declarations

END rx_control ;


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;


ARCHITECTURE rtl OF rx_control IS

BEGIN

   rx_fw_o <= NOT(nRx_rdy_i) AND NOT(rsc_nRd_i) AND NOT(rvs_i) AND NOT(rx_ff_i)
              AND rso_i;

END rtl;
