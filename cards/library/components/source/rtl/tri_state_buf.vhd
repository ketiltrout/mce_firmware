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
-- <revision control keyword substitutions e.g. $Id: tri_state_buf.vhd,v 1.1 2004/03/05 22:38:35 jjacob Exp $>
--
-- Project:		<project name>
-- Author:		Jonathan Jacob
-- Organisation:	<organisation name>
--
-- Description:
-- <description text>
--
-- Revision history:
-- <date $Date: 2004/03/05 22:38:35 $>	-		<text>		- <initials $Author: jjacob $>
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity tri_state_buf is
port (
 
   -- inputs
      data_i  : in std_logic;
      buf_en_i  : in std_logic;
      
   -- outputs
      data_o : out std_logic);
end tri_state_buf;

architecture rtl of tri_state_buf is

begin
 
   data_o <= data_i when buf_en_i = '1' else 'Z';

end rtl;