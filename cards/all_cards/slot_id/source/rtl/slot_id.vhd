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
--
-- slot_id.vhd
--
-- Project:	      SCUBA 2
-- Author:        Jonathan Jacob
-- Organisation:  UBC Physics and Astronomy
--
-- Description:
-- This code implements the Slot ID functionality
--
-- Revision history:
-- 
-- $Log$
--
-- Revision 1.2  2004/03/16 18:57:00  jjacob
-- ran HAL lint checker, cleaned up warnings and errors
--
-----------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
use work.slot_id_pack.all;

library sys_param;
use sys_param.wishbone_pack.all;

entity slot_id is      
port(clk_i   : in std_logic;
     rst_i   : in std_logic;		
      
     slot_id_i : in std_logic_vector(SLOT_ID_BITS-1 downto 0);
     
     -- wishbone signals
     dat_i 	 : in std_logic_vector (WB_DATA_WIDTH-1 downto 0);      -- not used since can't write to slot ID
     addr_i  : in std_logic_vector (WB_ADDR_WIDTH-1 downto 0);
     tga_i   : in std_logic_vector (WB_TAG_ADDR_WIDTH-1 downto 0);  -- not used since only reading one value
     we_i    : in std_logic;
     stb_i   : in std_logic;
     cyc_i   : in std_logic;
     dat_o   : out std_logic_vector (WB_DATA_WIDTH-1 downto 0);
     ack_o   : out std_logic);
end slot_id;

architecture rtl of slot_id is

signal slot_id_data        : std_logic_vector(SLOT_ID_BITS-1 downto 0);
signal padded_slot_id_data : std_logic_vector(WB_DATA_WIDTH-1 downto 0);

begin


------------------------------------------------------------------------
--
-- Read slot ID
--
------------------------------------------------------------------------

   process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         slot_id_data <= (others => '0');
      elsif(clk_i'event and clk_i = '1') then
         slot_id_data <= slot_id_i;
      end if;
   end process;
   
   padded_slot_id_data(WB_DATA_WIDTH-1 downto SLOT_ID_BITS) <= (others => '0');
   padded_slot_id_data(SLOT_ID_BITS-1 downto 0) <= slot_id_data;
   

------------------------------------------------------------------------
--
-- Wishbone
--
------------------------------------------------------------------------ 
   
   ack_o <= '1'                 when addr_i = SLOT_ID_ADDR and we_i = '1' and stb_i = '1' and cyc_i = '1' else '0';
   dat_o <= padded_slot_id_data when addr_i = SLOT_ID_ADDR and we_i = '1' and stb_i = '1' and cyc_i = '1' else (others => '0');

end rtl;
