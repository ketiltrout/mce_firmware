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
-- Project:	      SCUBA-2
-- Author:	      David Atkinson
--               
-- Organisation:  UK ATC
--
-- Description: Block to generate global clock card reset on the receipt of a 
-- 'special character' byte transmitted by the Linux PC. 
-- 
-- Revision history:
-- <date $Date: 2004/10/12 14:18:56 $> - <text> - <initials $Author: dca $>
--
-- $Log: cc_reset.vhd,v $
--
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.cc_reset_pack.all;



entity cc_reset is
   port( 
      nRx_rdy_i  : in     std_logic;                       -- hotlink receiver data ready (active low)
      rsc_nRd_i  : in     std_logic;                       -- hotlink receiver special character/(not) Data 
      rso_i      : in     std_logic;                       -- hotlink receiver status out
      rvs_i      : in     std_logic;                       -- hotlink receiver violation symbol detected
      rx_data_i  : in     std_logic_vector (7 downto 0);   -- hotlink receiver data byte
      reset_o    : out    std_logic                        -- cc firmware reset      
   );

end cc_reset ;


architecture rtl of cc_reset is
   
begin

  reset_o <= '1' when (nRx_rdy_i = '0' and rsc_nRd_i = '1' and rso_i = '1' and rvs_i = '0' and rx_data_i = SPEC_CHAR_RESET) else '0'; 

end rtl;