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
-- <revision control keyword substitutions e.g. $Id: fibre_tx_control.vhd,v 1.1 2004/10/05 12:22:34 dca Exp $>
--
-- Project:	      SCUBA-2
-- Author:	      David Atkinson
--               
-- Organisation:  UK ATC
--
-- Description:  This block controls the reading of data from the 
-- 'fibre_tx_fifo' block for transmission by the HOTLINK transmitter chip.
--
-- Revision history:
-- <date $Date: 2004/10/05 12:22:34 $> - <text> - <initials $Author: dca $>
--
-- $Log: fibre_tx_control.vhd,v $
-- Revision 1.1  2004/10/05 12:22:34  dca
-- moved from fibre_tx directory.
--
-- Revision 1.1  2004/08/31 12:58:36  dca
-- Initial Version
--

library ieee;
use ieee.std_logic_1164.all;

entity fibre_tx_control is
   port( 
      fibre_clkw_i : in     std_logic;
      tx_fe_i      : in     std_logic;
      tsc_nTd_o    : out    std_logic;
      nFena_o      : out    std_logic;
      tx_fr_o      : out    std_logic
   );

end fibre_tx_control;

library ieee;
use ieee.std_logic_1164.all;

architecture rtl of fibre_tx_control is

begin
 
   tsc_nTd_o <= '0';         -- always transmitting data
                             -- this could have been grounded on PCB
                             -- no special chars sent to PCI interface
   
 
   tx_fr_o <= not (tx_fe_i) ;  -- if there is something to be enable read request.
                               -- byte will be read on fibre_clkw_i edge (read clock) 


-- synchronis nFena to fibre_clkw.
-- the nFena signal is syncronised to the fifo read
-- but with a delay of one clock cycle.


----------------------------------------------------------
clocked: PROCESS(fibre_clkw_i)
----------------------------------------------------------
begin
   if (fibre_clkw_i'EVENT and fibre_clkw_i = '1') then
      nFena_o <= tx_fe_i; 
   end if; 
end process clocked;


end rtl;