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
-- <revision control keyword substitutions e.g. $Id: fibre_rx_control.vhd,v 1.1 2004/10/05 12:23:05 dca Exp $>
--
-- Project:	      SCUBA-2
-- Author:	      David Atkinson
--               
-- Organisation:  UK ATC
--
-- Description: This block controls the writing of data to the FIFO block 'rx_fifo',
-- using signals from the cyress HOTLINK receiver.
-- 
--
-- Revision history:
-- 22nd February 2004   - Initial version      - DA
-- 
-- <date $Date: 2004/10/05 12:23:05 $>	-		<text>		- <initials $Author: dca $>
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity fibre_rx_control is
   port( 
      nRx_rdy_i : in     std_logic;  -- hotlink receiver data ready (active low)
      rsc_nRd_i : in     std_logic;  -- hotlink receiver special character/(not) Data 
      rso_i     : in     std_logic;  -- hotlink receiver status out
      rvs_i     : in     std_logic;  -- hotlink receiver violation symbol detected
      rx_ff_i   : in     std_logic;  -- rx_fifo full flag
      rx_fw_o   : out    std_logic   -- rx_fifo write request
   );


end fibre_rx_control ;


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

architecture rtl of fibre_rx_control is

begin

   rx_fw_o <= not(nRx_rdy_i) and not(rsc_nRd_i) and not(rvs_i) and not(rx_ff_i)
              and rso_i;

end rtl;
