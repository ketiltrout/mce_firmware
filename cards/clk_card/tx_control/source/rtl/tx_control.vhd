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
-- Description:  This block controls the reading of data from the 
-- 'tx_fifo' block for transmission by the HOTLINK transmitter chip.
--
-- Revision history:
-- 26th March 2004   - Initial version      - DA
-- 
-- <date $Date$>	-		<text>		- <initials $Author$>

library ieee;
use ieee.std_logic_1164.all;

entity tx_control is
   port( 
      ft_clkw_i : in     std_logic;
      nTrp_i    : in     std_logic;
      tx_fe_i   : in     std_logic;
      tsc_nTd_o : out    std_logic;
      nFena_o   : out    std_logic;
      tx_fr_o   : out    std_logic
   );

end tx_control;

library ieee;
use ieee.std_logic_1164.all;

architecture  rtl of tx_control is

begin
 
   tsc_nTd_o <= '0';         -- always transmitting data
                             -- this could have been grounded on PCB
                             -- no special chars sent to PCI interface
   
   tx_fr_o <= not(nTrp_i);   -- read_pulse from CYPRESS
                             -- HOTLINK transmitter (active low)
                             -- mapped to tx_fifo read (active high)  

     
     
   nFena_o <= tx_fe_i;       -- if there's anything in the tx_fifo
                             -- enable parallel data transmission
                             -- 
                             -- if FIFO is not empty tx_fe_i = '0'
                             -- a low on nfena enables data collection 
                             -- and transmission
end rtl;