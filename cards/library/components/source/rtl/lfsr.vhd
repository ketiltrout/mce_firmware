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
-- lfsr.vhd
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Parameterized implemetation of a linear feedback shift register
--
-- Revision history:
-- 
-- $Log$
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity lfsr is
   generic(WIDTH : in integer range 3 to 64 := 8);
   port(clk        : in std_logic;
        rst        : in std_logic;
        ena        : in std_logic;
        load       : in std_logic;
        clr        : in std_logic;
        parallel_i : in std_logic_vector(WIDTH-1 downto 0);
        parallel_o : out std_logic_vector(WIDTH-1 downto 0));
end lfsr;

architecture behav of lfsr is
signal data : std_logic_vector(1 to WIDTH);
signal fb : std_logic;
begin

   ---------------------------------------------------------
   -- Generating LFSR feedback signals
   --
   --   fb : if WIDTH =  generate fb <= not(data() xor data());                                             end generate;
   --   fb : if WIDTH =  generate fb <= not(data() xor data() xor data() xor data());                       end generate;
   --   fb : if WIDTH =  generate fb <= not(data() xor data() xor data() xor data() xor data() xor data()); end generate;
   --
   
   fb3  : if WIDTH = 3  generate fb <= not(data(3) xor data(2));                                                  end generate;
   fb4  : if WIDTH = 4  generate fb <= not(data(4) xor data(3));                                                  end generate;
   fb5  : if WIDTH = 5  generate fb <= not(data(5) xor data(3));                                                  end generate;
   fb6  : if WIDTH = 6  generate fb <= not(data(6) xor data(5));                                                  end generate;
   fb7  : if WIDTH = 7  generate fb <= not(data(7) xor data(6));                                                  end generate;   
   fb8  : if WIDTH = 8  generate fb <= not(data(8) xor data(6) xor data(5) xor data(4));                          end generate;
   fb9  : if WIDTH = 9  generate fb <= not(data(9) xor data(5));                                                  end generate;
      
   fb10 : if WIDTH = 10 generate fb <= not(data(10) xor data(7));                                                 end generate;   
   fb11 : if WIDTH = 11 generate fb <= not(data(11) xor data(9));                                                 end generate;   
   fb12 : if WIDTH = 12 generate fb <= not(data(12) xor data(6) xor data(4) xor data(1));                         end generate;
   fb13 : if WIDTH = 13 generate fb <= not(data(13) xor data(4) xor data(3) xor data(1));                         end generate;
   fb14 : if WIDTH = 14 generate fb <= not(data(14) xor data(5) xor data(3) xor data(1));                         end generate;
   fb15 : if WIDTH = 15 generate fb <= not(data(15) xor data(14));                                                end generate;   
   fb16 : if WIDTH = 16 generate fb <= not(data(16) xor data(15) xor data(13) xor data(4));                       end generate;
   fb17 : if WIDTH = 17 generate fb <= not(data(17) xor data(14));                                                end generate;   
   fb18 : if WIDTH = 18 generate fb <= not(data(18) xor data(11));                                                end generate;
   fb19 : if WIDTH = 19 generate fb <= not(data(19) xor data(6) xor data(2) xor data(1));                         end generate;   
   
   fb20 : if WIDTH = 20 generate fb <= not(data(20) xor data(17));                                                end generate;   
   fb21 : if WIDTH = 21 generate fb <= not(data(21) xor data(19));                                                end generate;   
   fb22 : if WIDTH = 22 generate fb <= not(data(22) xor data(21));                                                end generate;   
   fb23 : if WIDTH = 23 generate fb <= not(data(23) xor data(18));                                                end generate;   
   fb24 : if WIDTH = 24 generate fb <= not(data(24) xor data(23) xor data(22) xor data(17));                      end generate;
   fb25 : if WIDTH = 25 generate fb <= not(data(25) xor data(22));                                                end generate; 
   fb26 : if WIDTH = 26 generate fb <= not(data(26) xor data(6) xor data(2) xor data(1));                         end generate;
   fb27 : if WIDTH = 27 generate fb <= not(data(27) xor data(5) xor data(2) xor data(1));                         end generate;  
   fb28 : if WIDTH = 28 generate fb <= not(data(28) xor data(25));                                                end generate;   
   fb29 : if WIDTH = 29 generate fb <= not(data(29) xor data(27));                                                end generate; 
   
   fb30 : if WIDTH = 30 generate fb <= not(data(30) xor data(6) xor data(4) xor data(1));                         end generate;  
   fb31 : if WIDTH = 31 generate fb <= not(data(31) xor data(28));                                                end generate;
   fb32 : if WIDTH = 32 generate fb <= not(data(32) xor data(22) xor data(2) xor data(1));                        end generate;
   fb33 : if WIDTH = 33 generate fb <= not(data(33) xor data(20));                                                end generate;
   fb34 : if WIDTH = 34 generate fb <= not(data(34) xor data(27) xor data(2) xor data(1));                        end generate;
   fb35 : if WIDTH = 35 generate fb <= not(data(35) xor data(33));                                                end generate;
   fb36 : if WIDTH = 36 generate fb <= not(data(36) xor data(25));                                                end generate;
   fb37 : if WIDTH = 37 generate fb <= not(data(37) xor data(5) xor data(4) xor data(3) xor data(2) xor data(1)); end generate;
   fb38 : if WIDTH = 38 generate fb <= not(data(38) xor data(6) xor data(5) xor data(1));                         end generate;
   fb39 : if WIDTH = 39 generate fb <= not(data(39) xor data(35));                                                end generate;
   
   fb40 : if WIDTH = 40 generate fb <= not(data(40) xor data(38) xor data(21) xor data(19));                      end generate;
   fb41 : if WIDTH = 41 generate fb <= not(data(41) xor data(38));                                                end generate;
   fb42 : if WIDTH = 42 generate fb <= not(data(42) xor data(41) xor data(20) xor data(19));                      end generate;
   fb43 : if WIDTH = 43 generate fb <= not(data(43) xor data(42) xor data(38) xor data(37));                      end generate;
   fb44 : if WIDTH = 44 generate fb <= not(data(44) xor data(43) xor data(18) xor data(17));                      end generate;
   fb45 : if WIDTH = 45 generate fb <= not(data(45) xor data(44) xor data(42) xor data(41));                      end generate;
   fb46 : if WIDTH = 46 generate fb <= not(data(46) xor data(45) xor data(26) xor data(25));                      end generate;
   fb47 : if WIDTH = 47 generate fb <= not(data(47) xor data(42));                                                end generate;
   fb48 : if WIDTH = 48 generate fb <= not(data(48) xor data(47) xor data(21) xor data(20));                      end generate;
   fb49 : if WIDTH = 49 generate fb <= not(data(49) xor data(40));                                                end generate;
   
   fb50 : if WIDTH = 50 generate fb <= not(data(50) xor data(49) xor data(24) xor data(23));                      end generate;
   fb51 : if WIDTH = 51 generate fb <= not(data(51) xor data(50) xor data(36) xor data(35));                      end generate;
   fb52 : if WIDTH = 52 generate fb <= not(data(52) xor data(49));                                                end generate;
   fb53 : if WIDTH = 53 generate fb <= not(data(53) xor data(52) xor data(38) xor data(37));                      end generate;
   fb54 : if WIDTH = 54 generate fb <= not(data(54) xor data(53) xor data(18) xor data(17));                      end generate;
   fb55 : if WIDTH = 55 generate fb <= not(data(55) xor data(31));                                                end generate;
   fb56 : if WIDTH = 56 generate fb <= not(data(56) xor data(55) xor data(35) xor data(34));                      end generate;
   fb57 : if WIDTH = 57 generate fb <= not(data(57) xor data(50));                                                end generate;
   fb58 : if WIDTH = 58 generate fb <= not(data(58) xor data(39));                                                end generate;
   fb59 : if WIDTH = 59 generate fb <= not(data(59) xor data(58) xor data(38) xor data(37));                      end generate;
   
   fb60 : if WIDTH = 60 generate fb <= not(data(60) xor data(59));                                                end generate;
   fb61 : if WIDTH = 61 generate fb <= not(data(61) xor data(60) xor data(46) xor data(45));                      end generate;
   fb62 : if WIDTH = 62 generate fb <= not(data(62) xor data(61) xor data(6) xor data(5));                        end generate;
   fb63 : if WIDTH = 63 generate fb <= not(data(63) xor data(62));                                                end generate;
   fb64 : if WIDTH = 64 generate fb <= not(data(64) xor data(63) xor data(61) xor data(60));                      end generate;
   
       
   ---------------------------------------------------------
   -- Shift register part
   --
   
   process(clk, rst)
   begin
      if(rst = '1') then
         data <= (others => '0');
      elsif(clk'event and clk = '1') then
         if(ena = '1') then
            if(clr = '1') then
               data <= (others => '0');
            elsif(load = '1') then
               data <= parallel_i;
            else
               data <= fb & data(1 to WIDTH-1);
            end if;
         end if;
      end if;
   end process;
   
   parallel_o <= data;

end behav;