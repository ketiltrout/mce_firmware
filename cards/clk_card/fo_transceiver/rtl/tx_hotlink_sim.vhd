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
-- <revision control keyword substitutions e.g. $Id: tx_hotlink_sim.vhd,v 1.1 2004/04/28 12:16:28 dca Exp $>
--
-- Project:	      SCUBA-2
-- Author:	      David Atkinson
--               
-- Organisation:  UK ATC
--
-- Description:  This block simulate the hotlink transmitter chip 
-- for use with the fo_tranceiver test bed 
-- 
--
-- Revision history:
-- 
-- <date $Date: 2004/04/28 12:16:28 $>	-		<text>		- <initials $Author: dca $>
--

library ieee;
use ieee.std_logic_1164.all;


entity tx_hotlink_sim is
   port( 
      ft_clkw_i : in     std_logic;
      nFena_i   : in     std_logic;
      tsc_nTd_i : in     std_logic;   
      tx_data_i : in     std_logic_vector (7 downto 0);
      nTrp_o    : out    std_logic
    );
end tx_hotlink_sim;


LIBRARY ieee;
USE ieee.std_logic_1164.all;


architecture rtl of tx_hotlink_sim is


begin 

  
   ----------------------------------------------------------
   read_tx: process(ft_clkw_i, nFena_i)
   ----------------------------------------------------------
   
   begin 
      if (ft_clkw_i'event and ft_clkw_i = '1') then
        if nFena_i = '0' then
          nTrp_o <= '0';
        else
          nTrp_o <= '1';
        end if;
      else
        nTrp_o <= '1';
      end if;
   end process read_tx;

end rtl;
