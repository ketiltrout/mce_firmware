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

-- utils_pack.vhd
--
-- <revision control keyword substitutions e.g. $Id: utils_pack.vhd,v 1.1 2004/05/20 23:51:14 erniel Exp $>
--
-- Project:	      SCUBA-2
-- Author:	      Neil Gruending
-- Organisation:  UBC
--
-- Description:
-- Defines utility functions.
--
-- Revision history:
-- <$Date: 2004/05/20 23:51:14 $>
-- $Log: utils_pack.vhd,v $
-- Revision 1.1  2004/05/20 23:51:14  erniel
-- relocated old cc_test files
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package utils_pack is

   component hex2ascii
      port (
         hex_i   : in std_logic_vector(3 downto 0);
         ascii_o : out std_logic_vector(7 downto 0)
         );
   end component;
   
end utils_pack;

