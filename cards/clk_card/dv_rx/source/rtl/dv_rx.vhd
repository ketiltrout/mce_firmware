-- Copyright (c) 2003 SCUBA-2 Project
--                  All Rights Reserved
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
-- $Id: dv_rx.vhd,v 1.2 2006/02/28 09:20:58 bburger Exp $
--
-- Project:       SCUBA-2
-- Author:        Greg Dennis
-- Organization:  UBC
--
-- Description:
-- DV and Manchester Decoder
--
-- Revision history:
-- $Log: dv_rx.vhd,v $
-- Revision 1.2  2006/02/28 09:20:58  bburger
-- Bryce:  Modified the interface of dv_rx.  Non-functional at this point.
--
-- Revision 1.1  2006/02/11 01:11:53  bburger
-- Bryce:  New!
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.sync_gen_pack.all;

entity dv_rx is
   port(
      -- Clock and Reset:
      clk_i             : in std_logic;
      rst_i             : in std_logic;
      
      -- Fibre Interface:
      manchester_dat_i  : in std_logic;
      dv_dat_i          : in std_logic;
      
      -- Issue-Reply Interface:
      dv_mode_i         : in std_logic_vector(DV_SELECT_WIDTH-1 downto 0);
      dv_o              : out std_logic;
      dv_sequence_num_o : out std_logic_vector(31 downto 0);

      sync_mode_i       : in std_logic_vector(SYNC_SELECT_WIDTH-1 downto 0);
      sync_o            : out std_logic
   );     
end dv_rx;

architecture top of dv_rx is
   
   type states is (INIT);   
   signal current_state, next_state : states;
   
   

begin

end top;


