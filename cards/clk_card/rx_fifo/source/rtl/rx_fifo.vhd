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
-- Description: Fibre optic Receive FIFO.   Bytes of data from the hotlink 
-- receiver are written to this FIFO.  Writing to this block
-- is controlled by rx_control block (with signals from HOTLINK receiver).
-- 
-- The FIFO needs to be deep enought to buffer one MCE command (Write_block is
-- largest command).  Note that a second command is not sent to the MCE from the 
-- host until a reply from the first is received.
--
-- Revision history:
-- 1st March 2004   - Initial version      - DA
-- 
-- <date $Date$>	-		<text>		- <initials $Author$>
--
--
-----------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

USE work.fo_transceiver_pack.all;


ENTITY rx_fifo IS
   GENERIC( 
      fifo_size : Positive
   );
   PORT( 
      Brst      : IN     std_logic;
      rx_fr_i   : IN     std_logic;
      rx_fw_i   : IN     std_logic;
      rx_data_i : IN     std_logic_vector (7 DOWNTO 0);
      rx_fe_o   : OUT    std_logic;
      rx_ff_o   : OUT    std_logic;
      rxd_o     : OUT    std_logic_vector (7 DOWNTO 0)
   );

END rx_fifo ;


ARCHITECTURE behav OF rx_fifo IS
   
BEGIN
   -- Instance port mappings.
   I0 : async_fifo
      GENERIC MAP (fifo_size => fifo_size)
      PORT MAP (
         rst_i    => Brst,
         read_i   => rx_fr_i,
         write_i  => rx_fw_i,
         d_i      => rx_data_i,
         empty_o  => rx_fe_o,
         full_o   => rx_ff_o,
         q_o      => rxd_o
      );
  
END behav;
