-- Copyright (c) 2003 SCUBA-2 Project
--               All Rights Reserved
--
--  THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE SCUBA-2 Project
--  The copyright notice above does not evidence any
--  actual or intended publication of such source code.
--
--  SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
--  REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
--  MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
--  PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
--  THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.
--
-- For the purposes of this code the SCUBA-2 Project consists of the
-- following organisations.
--
-- UKATC, Royal Observatory, Blackford Hill Edinburgh EH9 3HJ
-- UBC,   University of British Columbia, Physics & Astronomy Department,
--        Vancouver BC, V6T 1Z1
--
-- <Title>
--
-- <revision control keyword substitutions e.g. $Id: addr_card_io_connectivity_chk.vhd,v 1.1 2004/04/13 17:55:24 jjacob Exp $>
--
-- Project:		Scuba 2
-- Author:		Jonathan Jacob
-- Organisation:	UBC
--
-- Description:
-- 
--
-- Revision history:
-- <date $Date: 2004/04/13 17:55:24 $>	-		<text>		- <initials $Author: jjacob $>
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity addr_card_io_connectivity_chk is
   generic (NUM_OF_IO_PINS : integer := 200);
   port (   
      clk_i   : in  std_logic;                                   -- input clock signal
      test_o  : out std_logic_vector(NUM_OF_IO_PINS-1 downto 0)  -- clock outputs to drive io pins
   );
end addr_card_io_connectivity_chk;


architecture rtl of addr_card_io_connectivity_chk is

begin

   test_o <= (others => clk_i);

end rtl;


