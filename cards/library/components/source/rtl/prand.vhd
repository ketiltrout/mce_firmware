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
-- Psuedo random number generator.  Taken fron Xilinx XAPP210.
-- 
-- Revision History:
-- Mar 07, 2004: Initial version - NRG
-- $Log$
--
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

---------------------------------------------------------------------
entity prand is
   generic (
      size : integer := 8     -- how many output bits do we want
   );
   port (
      clr_i : in std_logic;   -- asynchoronous clear input
      clk_i : in std_logic;   -- calculation clock
      en_i : in std_logic;    -- calculation enable
      out_o : out std_logic_vector (size - 1 downto 0)   -- random output
   );
end;

---------------------------------------------------------------------
architecture behaviour of prand is
   signal feedback : std_logic;
   signal out_reg : std_logic_vector (size - 1 downto 0);  -- random output
   
begin

   -- VHDL 1993 Syntax:
   -- our feedback signal depends on how many bits we need
   lfsr8 : if (size = 8) generate
      feedback <= (out_reg(7) xnor out_reg(5)) xnor (out_reg(4) xnor out_reg(3));
   end generate lfsr8;
   lfsr16 : if (size = 16) generate
      feedback <= (out_reg(15) xnor out_reg(14)) xnor (out_reg(12) xnor out_reg(3));
   end generate lfsr16;   
   lfsr24 : if (size = 24) generate
      feedback <= (out_reg(23) xnor out_reg(22)) xnor (out_reg(21) xnor out_reg(16));
   end generate lfsr24;
   lfsr32 : if (size = 32) generate
      feedback <= (out_reg(31) xnor out_reg(21)) xnor (out_reg(1) xnor out_reg(0));
   end generate lfsr32;
   
--   -- VHDL 1987 Syntax:   
--   -- our feedback signal depends on how many bits we need
--   lfsr8 : if (size = 8) generate
--      feedback <= not((not(out_reg(7) xor out_reg(5))) xor (not(out_reg(4) xor out_reg(3))));
--   end generate lfsr8;
--   lfsr16 : if (size = 16) generate
--      feedback <= not((not(out_reg(15) xor out_reg(14))) xor (not(out_reg(12) xor out_reg(3))));
--   end generate lfsr16;   
--   lfsr24 : if (size = 24) generate
--      feedback <= not((not(out_reg(23) xor out_reg(22))) xor (not(out_reg(21) xor out_reg(16))));
--   end generate lfsr24;
--   lfsr32 : if (size = 32) generate
--      feedback <= not((not(out_reg(31) xor out_reg(21))) xor (not(out_reg(1) xor out_reg(0))));
--   end generate lfsr32;

   -- this process does all the calculations
   process (clr_i, clk_i)
   begin
      if (clr_i = '1') then
         out_reg <= (others => '0');
      elsif Rising_Edge(clk_i) then
         if (en_i = '1') then
            out_reg <= out_reg(size - 2 downto 0) & feedback;
         else
            out_reg <= out_reg;
         end if;
      end if;
   end process;
   out_o <= out_reg;

end;
