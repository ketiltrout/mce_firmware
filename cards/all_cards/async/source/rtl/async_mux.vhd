---------------------------------------------------------------------
-- Copyright (c) 2003 UK Astronomy Technology Centre
--                All Rights Reserved
--
--  THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE UK ATC
--  The copyright notice above does not evidence any
--  actual or intended publication of such source code.
--
--  SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
--  REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
--  MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
--  PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
--  THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.
--
-- Project:             Scuba 2
-- Author:              Neil Gruending
-- Organisation:        UBC Physics and Astronomy
--
-- Description:
-- Asynchronous output select multiplexer.
-- 
-- Revision History:
-- Jan 4, 2004: Initial version - NRG
-- Feb 28, 2004: Made input array size a generic - NRG
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
use work.async_pack.all;

entity async_mux is
   generic (
         size : integer := 1 -- how many items we have in the mux input
      );
   port(
      rst_i : in std_logic;
      clk_i : in std_logic;
      sel_i : in std_logic_vector(size - 1 downto 0);  -- mux xelect
      in_i : in tx_array(size - 1 downto 0);  -- mux inputs
      out_o : out tx_t      -- mux outputs
   );
end;

architecture behaviour of async_mux is
begin
   
   process (clk_i, sel_i, in_i)
   begin
      if Rising_Edge(clk_i) then
         out_o <= in_i(0);
         for i in in_i'range loop
            if (sel_i(i) = '1') then
               out_o <= in_i(i);
            end if;
         end loop;
      end if;
   end process;
end;
