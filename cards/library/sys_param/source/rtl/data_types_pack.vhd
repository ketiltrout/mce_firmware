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
-- Project:       SCUBA-2
-- Author:         Mandana Amiri
-- Organisation:  UBC
--
-- Description:
-- data types
--
-- Revision history:
-- <date $Date: 2004/08/18 17:06:52 $> - <initials $Author: bburger $>
-- $Log: data_types_pack.vhd,v $
-- Revision 1.6  2004/08/18 17:06:52  bburger
-- Bryce:  added a word12
--
-- Revision 1.5  2004/07/29 00:22:40  mandana
-- added array data types for AC
--
-- Revision 1.4  2004/07/06 21:33:25  erniel
-- added constants for logic 0 and logic 1
--
-- Revision 1.3  2004/05/14 20:52:21  mandana
-- changed frame_timing values to integer(Bias_count)
--
-- Revision 1.2  2004/04/28 17:41:36  mandana
-- added data types for address card
--
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

   constant LOGIC_0 : std_logic := '0';
   constant LOGIC_1 : std_logic := '1';
   
   ---------------------.
   -- Generic data types
   ---------------------
   subtype word4          is std_logic_vector(3 downto  0);
   subtype word8          is std_logic_vector(7 downto  0);
   subtype word12         is std_logic_vector(11 downto 0);
   subtype word16         is std_logic_vector(15 downto 0);
   subtype word24         is std_logic_vector(23 downto 0);
   subtype word32         is std_logic_vector(31 downto 0);
   subtype word40         is std_logic_vector(39 downto 0);
   subtype word48         is std_logic_vector(47 downto 0);
   subtype word64         is std_logic_vector(63 downto 0);
   
   subtype word14    is std_logic_vector(13 downto 0); -- for address card dacs
   type    w_array11 is array (10 downto 0) of word14; -- for address card bus (just keep it for old code and test code's sake)
   type    w14_array11 is array (10 downto 0) of word14; -- for address card bus (new naming convention)
   type    int_array41 is array (40 downto 0) of integer; -- for address card rows
end data_types_pack;