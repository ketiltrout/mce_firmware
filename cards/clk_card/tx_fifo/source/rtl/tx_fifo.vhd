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
-- Description: Fibre optic Transmit FIFO.   Bytes of data are buffered here 
-- to be written to the hotlink receiver.  When bytes are written to this FIFO
-- the tx_control block controls their transfer to the HOTLINK transmitter
-- 
--
-- Revision history:
-- 29th March 2004   - Initial version      - DA
-- 
-- <date $Date$>	-		<text>		- <initials $Author$>
--
--
-----------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

USE work.fo_transceiver_pack.all;

ENTITY tx_fifo IS
   GENERIC( 
      fifo_size : Positive
   );
   PORT( 
      Brst      : IN     std_logic;
      tx_fr_i   : IN     std_logic;
      tx_fw_i   : IN     std_logic;
      txd_i     : IN     std_logic_vector (7 DOWNTO 0);
      tx_fe_o   : OUT    std_logic;
      tx_ff_o   : OUT    std_logic;
      tx_data_o : OUT    std_logic_vector (7 DOWNTO 0)
   );

-- Declarations

END tx_fifo ;


ARCHITECTURE behav OF tx_fifo IS
   
BEGIN
   -- Instance port mappings.
   I0 : async_fifo
      GENERIC MAP (fifo_size => fifo_size)
      PORT MAP (
         rst_i    => Brst,
         read_i   => tx_fr_i,
         write_i  => tx_fw_i,
         d_i      => txd_i,
         empty_o  => tx_fe_o,
         full_o   => tx_ff_o,
         q_o      => tx_data_o
      );
  
END behav;
