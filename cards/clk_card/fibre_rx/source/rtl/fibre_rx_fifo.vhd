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
-- <revision control keyword substitutions e.g. $Id: fibre_rx_fifo.vhd,v 1.2 2004/06/28 13:45:48 dca Exp $>
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
-- The FIFO needs to be deep enought to buffer one MCE command (at least 256 bytes)
--
-- Revision history:
-- 1st March 2004   - Initial version      - DA
-- 
-- <date $Date: 2004/06/28 13:45:48 $>	-		<text>		- <initials $Author: dca $>
--
--
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.component_pack.all;

entity fibre_rx_fifo is
   generic( 
      addr_size : Positive                               -- read/write address size
   );                                                    -- note that fifo size = 2**address size
   port( 
      rst_i     : in     std_logic;                       -- global reset
      rx_fr_i   : in     std_logic;                       -- fifo read request
      rx_fw_i   : in     std_logic;                       -- fifo write request
      rx_data_i : in     std_logic_vector (7 downto 0);   -- fifo data input
      rx_fe_o   : out    std_logic;                       -- fifo empty flag
      rx_ff_o   : out    std_logic;                       -- fifo full flagg
      rxd_o     : out    std_logic_vector (7 downto 0)    -- fifo data output
   );

end fibre_rx_fifo ;

architecture behav of fibre_rx_fifo is
   
begin
   -- Instance port mappings.
   I0 : async_fifo
      generic map(addr_size => addr_size)
      port map(
         rst_i    => rst_i,
         read_i   => rx_fr_i,
         write_i  => rx_fw_i,
         d_i      => rx_data_i,
         empty_o  => rx_fe_o,
         full_o   => rx_ff_o,
         q_o      => rxd_o
      );
  
end behav;
