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
-- <revision control keyword substitutions e.g. $Id: tb_fibre_rx_protocol.vhd,v 1.3 2004/07/07 10:50:35 dca Exp $>
--
-- Project:	      SCUBA-2
-- Author:	      David Atkinson
--               
-- Organisation:  UK ATC
--
-- Description:  tb_rx_protocol_fsm
-- Test bed for rx_protocol_fsm
--
-- Revision history:
-- 
-- <date $Date: 2004/07/07 10:50:35 $>	-		<text>		- <initials $Author: dca $>
-- $log$
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity tb_check_calc is
end tb_check_calc;


library ieee;
use ieee.std_logic_1164.all;
use ieee.NUMERIC_STD.all;



architecture behav of tb_check_calc is



   -- enter the command to check here:
   
   -- note that the preamble is NOT in the checksum calculation
 
   constant word1        : std_logic_vector (31 downto 0) := X"0404EA42";
   constant word2        : std_logic_vector (31 downto 0) := X"0040003A";
   constant word3        : std_logic_vector (31 downto 0) := X"00000080";
   constant word4        : std_logic_vector (31 downto 0) := X"00000050";
   constant word5        : std_logic_vector (31 downto 0) := X"00000000";
 
 

   signal   checksum     : std_logic_vector(31 downto 0):= X"00000000";

   
   
begin


calculate_checksum : process

   begin
   

    checksum <= word1;
    wait for 100 ns;
    
    checksum <= checksum XOR word2;
    wait for 100 ns;
    
    checksum <= checksum XOR word3;
    wait for 100 ns;
    
    checksum <= checksum XOR word4;
    wait for 100 ns;
    
    
    for I in 5 to 63 loop
    
       checksum <= checksum XOR word5;
       wait for 100 ns;
  
    end loop;
            
      
  
      assert false report "Calculation done." severity FAILURE;
      wait ;
   end process calculate_checksum;
    

end behav;