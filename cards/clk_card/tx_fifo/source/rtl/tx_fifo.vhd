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
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.async_fifo_pack.all;

entity tx_fifo is
   generic( 
      fifo_size : Positive
   );
   port( 
      rst_i     : in     std_logic;
      tx_fr_i   : in     std_logic;
      tx_fw_i   : in     std_logic;
      txd_i     : in     std_logic_vector (7 downto 0);
      tx_fe_o   : out    std_logic;
      tx_ff_o   : out    std_logic;
      tx_data_o : out    std_logic_vector (7 downto 0)
   );

-- Declarations

end tx_fifo ;


architecture behav of tx_fifo is
   
begin
   -- Instance port mappings.
   I0 : async_fifo
      generic map (fifo_size => fifo_size)
      port map (
         rst_i    => rst_i,
         read_i   => tx_fr_i,
         write_i  => tx_fw_i,
         d_i      => txd_i,
         empty_o  => tx_fe_o,
         full_o   => tx_ff_o,
         q_o      => tx_data_o
      );
  
end behav;