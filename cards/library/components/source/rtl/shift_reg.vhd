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

-- shift_reg.vhd
--
-- <revision control keyword substitutions e.g. $Id: shift_reg.vhd,v 1.2 2004/03/23 23:46:07 jjacob Exp $>
--
-- Project:		 SCUBA-2
-- Author:		 Ernie Lin
-- Organisation:	UBC
--
-- Description:
-- This implements a bidirectional shift register with parallel/serial input/output.
--
-- Revision history:
--
-- $Log$
--
-- Dec. 19 2003  - Initial version      - EL
-- <date $Date: 2004/03/23 23:46:07 $>	-		<text>		- <initials $Author: jjacob $>

--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity shift_reg is
   generic(WIDTH : in integer range 2 to 512 := 8);
   port(clk_i      : in std_logic;
        rst_i      : in std_logic;
        ena_i      : in std_logic;
        load_i     : in std_logic;
        clr_i      : in std_logic;
        shr_i      : in std_logic;
        serial_i   : in std_logic;
        serial_o   : out std_logic;
        parallel_i : in std_logic_vector(WIDTH-1 downto 0);
        parallel_o : out std_logic_vector(WIDTH-1 downto 0));
end shift_reg;

architecture behav of shift_reg is
signal reg : std_logic_vector(WIDTH-1 downto 0);
begin

   shiftreg: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         reg <= (others => '0');
      elsif(clk_i'event and clk_i = '1') then
         if(ena_i = '1') then
            if(clr_i = '1') then
               reg <= (others => '0');
            elsif(load_i = '1') then
               reg <= parallel_i;
            else
               if(shr_i = '1') then
                  reg <= serial_i & reg(WIDTH-1 downto 1);
               else
                  reg <= reg(WIDTH-2 downto 0) & serial_i;
               end if;
            end if;
         end if;
      end if;
   end process shiftreg;


   
   serial_o <= reg(0) when shr_i = '1' else reg(WIDTH-1); -- when doing a shr, we grab the LSB.  When doing shl, we grab the MSB
   parallel_o <= reg;

end behav;