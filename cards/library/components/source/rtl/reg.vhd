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

-- reg.vhd
--
-- <revision control keyword substitutions e.g. $Id: reg.vhd,v 1.1 2004/03/05 22:38:35 jjacob Exp $>
--
-- Project:		 SCUBA-2
-- Author:		 Ernie Lin
-- Organisation:	UBC
--
-- Description:
-- This implements a variable-sized register.
--
-- Revision history:
-- Mar. 3 2004   - Initial version      - EL
-- <date $Date: 2004/03/05 22:38:35 $>	-		<text>		- <initials $Author: jjacob $>

--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity reg is
generic(WIDTH : in integer range 1 to 512 := 8);
port(clk_i  : in std_logic;
     rst_i  : in std_logic;
     ena_i  : in std_logic;

     reg_i  : in std_logic_vector(WIDTH-1 downto 0);
     reg_o  : out std_logic_vector(WIDTH-1 downto 0));
end reg;

architecture behav of reg is
begin

   registr: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         reg_o <= (others => '0');
      elsif(clk_i'event and clk_i = '1') then
         if(ena_i = '1') then
               reg_o <= reg_i;
         end if;
      end if;
   end process registr;

end behav;
