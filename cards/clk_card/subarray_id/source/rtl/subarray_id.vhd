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
-- <revision control keyword substitutions e.g. $Id: subarray_id.vhd,v 1.2 2007/07/26 20:25:35 bburger Exp $>
--
-- Project:    Scuba 2
-- Author:     Jonathan Jacob
-- Organisation:  UBC
--
-- Description:
-- This file implements the Array ID functionality
--
-- Revision history:
-- <date $Date: 2007/07/26 20:25:35 $> -     <text>      - <initials $Author: bburger $>
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library sys_param;
use sys_param.wishbone_pack.all;

library work;
use work.clk_card_pack.all;

entity subarray_id is
   port(
      clk_i   : in std_logic;
      rst_i   : in std_logic;

      array_id_i : in std_logic_vector(ARRAY_ID_BITS-1 downto 0);

      -- wishbone signals
      dat_i   : in std_logic_vector(WB_DATA_WIDTH-1 downto 0); -- not used since not writing to array ID
      addr_i  : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_i   : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i    : in std_logic;
      stb_i   : in std_logic;
      cyc_i   : in std_logic;
      err_o   : out std_logic;
      dat_o   : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_o   : out std_logic
   );
end subarray_id;

architecture rtl of subarray_id is

   -- internal signals
   signal array_id : std_logic_vector(ARRAY_ID_BITS-1 downto 0);
   signal padded_array_id : std_logic_vector(WB_DATA_WIDTH-1 downto 0);

begin

   ------------------------------------------------------------------------
   -- Read slot ID
   ------------------------------------------------------------------------
--   -- slot ID is continuously sampled
--   process(clk_i, rst_i)
--   begin
--      if(rst_i = '1') then
--         array_id <= (others => '0');
--      elsif(clk_i'event and clk_i = '1') then
--         array_id <= not array_id_i;
--      end if;
--   end process;

   padded_array_id(WB_DATA_WIDTH-1 downto ARRAY_ID_BITS) <= (others => '0');
--   padded_array_id(ARRAY_ID_BITS-1 downto 0) <= array_id;
   padded_array_id(ARRAY_ID_BITS-1 downto 0) <= not array_id_i(0) & not array_id_i(1) & not array_id_i(2);

   ------------------------------------------------------------------------
   -- Wishbone
   ------------------------------------------------------------------------
   -- assert ack and data when a read cycle to slot ID slave has begun
   -- (wishbone cycle should last for only one clock period)
   ack_o <= '1' when addr_i = ARRAY_ID_ADDR and we_i = '0' and stb_i = '1' and cyc_i = '1' else '0';
   err_o <= '1' when addr_i = ARRAY_ID_ADDR and we_i = '1' and stb_i = '1' and cyc_i = '1' else '0';

   dat_o <= padded_array_id when addr_i = ARRAY_ID_ADDR and we_i = '0' and stb_i = '1' and cyc_i = '1' else (others => '0');

end rtl;
