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
-- <revision control keyword substitutions e.g. $Id: fo_transceiver_pack.vhd,v 1.1 2004/04/01 16:18:10 dca Exp $>
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
-- 29th March 2004   - Initial version      - DA
-- 
-- <date $Date: 2004/04/01 16:18:10 $>	-		<text>		- <initials $Author: dca $>
--
--
-----------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

PACKAGE fo_transceiver_pack IS

--------------------------------------
--
-- async_fifo
--
---------------------------------------

   COMPONENT async_fifo
      GENERIC(fifo_size : Positive);
      PORT( 
         rst_i     : IN     std_logic;
         read_i    : IN     std_logic;
         write_i   : IN     std_logic;
         d_i       : IN     std_logic_vector (7 DOWNTO 0);
         empty_o   : OUT    std_logic;
         full_o    : OUT    std_logic;
         q_o       : OUT    std_logic_vector (7 DOWNTO 0)
      );
   END COMPONENT;

END fo_transceiver_pack;
