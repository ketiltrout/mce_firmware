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

-- data_types_pack.vhd
--
--
-- Project:	      SCUBA-2
-- Author:	       Mandana Amiri
-- Organisation:  UBC
--
-- Description:
-- data types
--
-- Revision history:
-- <date $Date: 2004/04/14 21:56:40 $>	- <initials $Author: jjacob $>
-- $Log: data_types_pack.vhd,v $
-- Revision 1.1  2004/04/14 21:56:40  jjacob
-- new directory structure
--
-- Revision 1.3  2004/04/08 00:44:31  mandana
-- fixed syntax
--
-- Revision 1.2  2004/04/07 20:51:36  mandana
-- fixed syntax
--
-- Revision 1.1  2004/04/07 19:00:48  mandana
-- Initial release
--   <--- this is new

--
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package data_types_pack is
   ---------------------.
   -- Generic data types
   ---------------------
   subtype word4          is std_logic_vector(3 downto  0);
   subtype word8          is std_logic_vector(7 downto  0);
   subtype word16         is std_logic_vector(15 downto 0);
   subtype word24         is std_logic_vector(23 downto 0);
   subtype word32         is std_logic_vector(31 downto 0);
   subtype word40         is std_logic_vector(39 downto 0);
   subtype word48         is std_logic_vector(47 downto 0);
   subtype word64         is std_logic_vector(63 downto 0);
   
   subtype word14    is std_logic_vector(13 downto 0); -- for address card dacs
   type    w_array11 is array (10 downto 0) of word14; -- for address card bus 

end data_types_pack;