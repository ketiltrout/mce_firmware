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
-- <date $Date$>	- <initials $Author$>
-- $Log$   <--- this is new

--
-----------------------------------------------------------------------------
library IEEE;
use IEEE.Std_Logic_1164.all;

package data_types_pack is
   -----------------------------------------------------------------------------
   -- Generic data types, leftmost bit, number 0, is the most significant
   -----------------------------------------------------------------------------
   subtype word4          is Std_Logic_Vector(0 to  3);
   subtype word8          is Std_Logic_Vector(0 to  7);
   subtype word16         is Std_Logic_Vector(0 to 15);
   subtype word24         is Std_Logic_Vector(0 to 23);
   subtype word32         is Std_Logic_Vector(0 to 31);
   subtype word40         is Std_Logic_Vector(0 to 39);
   subtype word48         is Std_Logic_Vector(0 to 47);
   subtype word64         is Std_Logic_Vector(0 to 63);

end data_types_pack;