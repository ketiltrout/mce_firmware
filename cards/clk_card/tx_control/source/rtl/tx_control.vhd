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
-- <revision control keyword substitutions e.g. $Id$>
--
-- Project:	      SCUBA-2
-- Author:	      David Atkinson
--               
-- Organisation:  UK ATC
--
-- Description:  This block controls the reading of data from the 
-- 'tx_fifo' block for transmission by the HOTLINK transmitter chip.
--
-- Revision history:
-- 26th March 2004   - Initial version      - DA
-- 
-- <date $Date$>	-		<text>		- <initials $Author$>
--

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY tx_control IS
   PORT( 
      ft_clkw_i : IN     std_logic;
      n_Trp_i     : IN     std_logic;
      tx_fe_i   : IN     std_logic;
      tsc_nTd_o : OUT    std_logic;
      nFena_o   : OUT    std_logic;
      tx_fr_o   : OUT    std_logic
   );

END tx_control ;


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;


ARCHITECTURE rtl OF tx_control IS


BEGIN
 
   tsc_nTd_o <= '0';      -- always transmitting data
                          -- this could have been grounded on PCB
                          -- no special chars sent to PCI interface
   
   
   ----------------------------------------------------------
   fifo_read: PROCESS(trp_i)
   ----------------------------------------------------------
   
   BEGIN 
      
       tx_fr_o <= NOT(n_Trp_i);   -- (not) read_pulse from CYPRESS
                                -- HOTLINK receiver mapped to 
                                -- tx_fifo read   

   END PROCESS fifo_read;
   
   
   ----------------------------------------------------------
   clocked: PROCESS(ft_clkw_i)
   ----------------------------------------------------------
   
   -- Note that "ft_clkw_i" is the same 25MHz clock that 
   -- is routed to the CYPRESS HOTLINK transmitter chip   
      
   BEGIN
      
               
      
      IF (ft_clkw_i'EVENT AND ft_clkw_i = '1') THEN
   
         nFena_o <= tx_fe_i;    -- if there's anything in the tx_fifo
                                -- enable parallel data transmission
                                -- 
                                -- if FIFO is not empty tx_fe_i = '0'
                                -- a low on nfena enables data collection 
                                -- and transmission
   
      END IF; 
         
   END PROCESS clocked;
  
   -----------------------------------------------------------

END rtl;
