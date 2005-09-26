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
-- $Log: lfsr.vhd,v $
-- Revision 1.6  2004/08/02 17:40:32  erniel
-- updated comments
--
-- Revision 1.5  2004/08/02 17:29:33  erniel
-- added support for up to 168 bits wide
--
-- Revision 1.4  2004/07/28 23:37:14  erniel
-- added _i and _o to port names to match naming conventions
--
-- Revision 1.3  2004/07/07 20:21:25  erniel
-- renamed lfsr data port (again) to lfsr_i/o
--
-- Revision 1.2  2004/07/07 19:42:08  erniel
-- renamed parallel data to data_i/o
--
-- Revision 1.1  2004/07/07 19:29:28  erniel
-- initial version
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity lfsr is
   generic(WIDTH : in integer range 3 to 168 := 8);
   port(clk_i  : in std_logic;
        rst_i  : in std_logic;
        ena_i  : in std_logic;
        load_i : in std_logic;
        clr_i  : in std_logic;
        lfsr_i : in std_logic_vector(WIDTH-1 downto 0);
        lfsr_o : out std_logic_vector(WIDTH-1 downto 0));
end lfsr;

architecture behav of lfsr is
signal data : std_logic_vector(1 to WIDTH);
signal fb : std_logic;
begin

   ---------------------------------------------------------
   -- Generating LFSR feedback signals for widths up to 168
   --
   -- LFSR feedback taps taken from:
   -- Xilinx Application Note #210 v1.2, pg. 4-5
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
   fb65 : if WIDTH = 65 generate fb <= not(data(65) xor data(47));                                                end generate;
   fb66 : if WIDTH = 66 generate fb <= not(data(66) xor data(65) xor data(57) xor data(56));                      end generate;
   fb67 : if WIDTH = 67 generate fb <= not(data(67) xor data(66) xor data(58) xor data(57));                      end generate;
   fb68 : if WIDTH = 68 generate fb <= not(data(68) xor data(59));                                                end generate;
   fb69 : if WIDTH = 69 generate fb <= not(data(69) xor data(67) xor data(42) xor data(40));                      end generate;
   
   fb70 : if WIDTH = 70 generate fb <= not(data(70) xor data(69) xor data(55) xor data(54));                      end generate;
   fb71 : if WIDTH = 71 generate fb <= not(data(71) xor data(65));                                                end generate;
   fb72 : if WIDTH = 72 generate fb <= not(data(72) xor data(66) xor data(25) xor data(19));                      end generate;
   fb73 : if WIDTH = 73 generate fb <= not(data(73) xor data(48));                                                end generate;
   fb74 : if WIDTH = 74 generate fb <= not(data(74) xor data(73) xor data(59) xor data(58));                      end generate;
   fb75 : if WIDTH = 75 generate fb <= not(data(75) xor data(74) xor data(65) xor data(64));                      end generate;
   fb76 : if WIDTH = 76 generate fb <= not(data(76) xor data(75) xor data(41) xor data(40));                      end generate;
   fb77 : if WIDTH = 77 generate fb <= not(data(77) xor data(76) xor data(47) xor data(46));                      end generate;
   fb78 : if WIDTH = 78 generate fb <= not(data(78) xor data(77) xor data(59) xor data(58));                      end generate;
   fb79 : if WIDTH = 79 generate fb <= not(data(79) xor data(70));                                                end generate;
   
   fb80 : if WIDTH = 80 generate fb <= not(data(80) xor data(79) xor data(43) xor data(42));                      end generate;
   fb81 : if WIDTH = 81 generate fb <= not(data(81) xor data(77));                                                end generate;
   fb82 : if WIDTH = 82 generate fb <= not(data(82) xor data(79) xor data(47) xor data(44));                      end generate;
   fb83 : if WIDTH = 83 generate fb <= not(data(83) xor data(82) xor data(38) xor data(37));                      end generate;
   fb84 : if WIDTH = 84 generate fb <= not(data(84) xor data(71));                                                end generate;
   fb85 : if WIDTH = 85 generate fb <= not(data(85) xor data(84) xor data(58) xor data(57));                      end generate;
   fb86 : if WIDTH = 86 generate fb <= not(data(86) xor data(85) xor data(74) xor data(73));                      end generate;
   fb87 : if WIDTH = 87 generate fb <= not(data(87) xor data(74));                                                end generate;
   fb88 : if WIDTH = 88 generate fb <= not(data(88) xor data(87) xor data(17) xor data(16));                      end generate;
   fb89 : if WIDTH = 89 generate fb <= not(data(89) xor data(51));                                                end generate;
   
   fb90 : if WIDTH = 90 generate fb <= not(data(90) xor data(89) xor data(72) xor data(71));                      end generate;
   fb91 : if WIDTH = 91 generate fb <= not(data(91) xor data(90) xor data(8) xor data(7));                        end generate;
   fb92 : if WIDTH = 92 generate fb <= not(data(92) xor data(91) xor data(80) xor data(79));                      end generate;
   fb93 : if WIDTH = 93 generate fb <= not(data(93) xor data(91));                                                end generate;
   fb94 : if WIDTH = 94 generate fb <= not(data(94) xor data(73));                                                end generate;
   fb95 : if WIDTH = 95 generate fb <= not(data(95) xor data(84));                                                end generate;
   fb96 : if WIDTH = 96 generate fb <= not(data(96) xor data(94) xor data(49) xor data(47));                      end generate;
   fb97 : if WIDTH = 97 generate fb <= not(data(97) xor data(91));                                                end generate;
   fb98 : if WIDTH = 98 generate fb <= not(data(98) xor data(87));                                                end generate;
   fb99 : if WIDTH = 99 generate fb <= not(data(99) xor data(97) xor data(54) xor data(52));                      end generate;
   
   fb100 : if WIDTH = 100 generate fb <= not(data(100) xor data(63));                                             end generate;
   fb101 : if WIDTH = 101 generate fb <= not(data(101) xor data(100) xor data(95) xor data(94));                  end generate;
   fb102 : if WIDTH = 102 generate fb <= not(data(102) xor data(101) xor data(36) xor data(35));                  end generate;
   fb103 : if WIDTH = 103 generate fb <= not(data(103) xor data(94));                                             end generate;
   fb104 : if WIDTH = 104 generate fb <= not(data(104) xor data(103) xor data(94) xor data(93));                  end generate;
   fb105 : if WIDTH = 105 generate fb <= not(data(105) xor data(89));                                             end generate;
   fb106 : if WIDTH = 106 generate fb <= not(data(106) xor data(91));                                             end generate;
   fb107 : if WIDTH = 107 generate fb <= not(data(107) xor data(105) xor data(44) xor data(42));                  end generate;
   fb108 : if WIDTH = 108 generate fb <= not(data(108) xor data(77));                                             end generate;
   fb109 : if WIDTH = 109 generate fb <= not(data(109) xor data(108) xor data(103) xor data(102));                end generate;
   
   fb110 : if WIDTH = 110 generate fb <= not(data(110) xor data(109) xor data(98) xor data(97));                  end generate;
   fb111 : if WIDTH = 111 generate fb <= not(data(111) xor data(101));                                            end generate;
   fb112 : if WIDTH = 112 generate fb <= not(data(112) xor data(110) xor data(69) xor data(67));                  end generate;
   fb113 : if WIDTH = 113 generate fb <= not(data(113) xor data(104));                                            end generate;
   fb114 : if WIDTH = 114 generate fb <= not(data(114) xor data(113) xor data(33) xor data(32));                  end generate;
   fb115 : if WIDTH = 115 generate fb <= not(data(115) xor data(114) xor data(101) xor data(100));                end generate;
   fb116 : if WIDTH = 116 generate fb <= not(data(116) xor data(115) xor data(46) xor data(45));                  end generate;
   fb117 : if WIDTH = 117 generate fb <= not(data(117) xor data(115) xor data(99) xor data(97));                  end generate;
   fb118 : if WIDTH = 118 generate fb <= not(data(118) xor data(85));                                             end generate;
   fb119 : if WIDTH = 119 generate fb <= not(data(119) xor data(111));                                            end generate;
   
   fb120 : if WIDTH = 120 generate fb <= not(data(120) xor data(113) xor data(9) xor data(2));                    end generate;
   fb121 : if WIDTH = 121 generate fb <= not(data(121) xor data(103));                                            end generate;
   fb122 : if WIDTH = 122 generate fb <= not(data(122) xor data(121) xor data(63) xor data(62));                  end generate;
   fb123 : if WIDTH = 123 generate fb <= not(data(123) xor data(121));                                            end generate;
   fb124 : if WIDTH = 124 generate fb <= not(data(124) xor data(87));                                             end generate;
   fb125 : if WIDTH = 125 generate fb <= not(data(125) xor data(124) xor data(18) xor data(17));                  end generate;
   fb126 : if WIDTH = 126 generate fb <= not(data(126) xor data(125) xor data(90) xor data(89));                  end generate;
   fb127 : if WIDTH = 127 generate fb <= not(data(127) xor data(126));                                            end generate;
   fb128 : if WIDTH = 128 generate fb <= not(data(128) xor data(126) xor data(101) xor data(99));                 end generate;
   fb129 : if WIDTH = 129 generate fb <= not(data(129) xor data(124));                                            end generate;
   
   fb130 : if WIDTH = 130 generate fb <= not(data(130) xor data(127));                                            end generate;
   fb131 : if WIDTH = 131 generate fb <= not(data(131) xor data(130) xor data(84) xor data(83));                  end generate;
   fb132 : if WIDTH = 132 generate fb <= not(data(132) xor data(103));                                            end generate;
   fb133 : if WIDTH = 133 generate fb <= not(data(133) xor data(132) xor data(82) xor data(81));                  end generate;
   fb134 : if WIDTH = 134 generate fb <= not(data(134) xor data(77));                                             end generate;
   fb135 : if WIDTH = 135 generate fb <= not(data(135) xor data(124));                                            end generate;
   fb136 : if WIDTH = 136 generate fb <= not(data(136) xor data(135) xor data(11) xor data(10));                  end generate;
   fb137 : if WIDTH = 137 generate fb <= not(data(137) xor data(116));                                            end generate;
   fb138 : if WIDTH = 138 generate fb <= not(data(138) xor data(137) xor data(131) xor data(130));                end generate;
   fb139 : if WIDTH = 139 generate fb <= not(data(139) xor data(136) xor data(134) xor data(131));                end generate;
   
   fb140 : if WIDTH = 140 generate fb <= not(data(140) xor data(111));                                            end generate;
   fb141 : if WIDTH = 141 generate fb <= not(data(141) xor data(140) xor data(110) xor data(109));                end generate;
   fb142 : if WIDTH = 142 generate fb <= not(data(142) xor data(121));                                            end generate;
   fb143 : if WIDTH = 143 generate fb <= not(data(143) xor data(142) xor data(123) xor data(122));                end generate;
   fb144 : if WIDTH = 144 generate fb <= not(data(144) xor data(143) xor data(75) xor data(74));                  end generate;
   fb145 : if WIDTH = 145 generate fb <= not(data(145) xor data(93));                                             end generate;
   fb146 : if WIDTH = 146 generate fb <= not(data(146) xor data(145) xor data(87) xor data(86));                  end generate;
   fb147 : if WIDTH = 147 generate fb <= not(data(147) xor data(146) xor data(110) xor data(109));                end generate;
   fb148 : if WIDTH = 148 generate fb <= not(data(148) xor data(121));                                            end generate;
   fb149 : if WIDTH = 149 generate fb <= not(data(149) xor data(148) xor data(40) xor data(39));                  end generate;
   
   fb150 : if WIDTH = 150 generate fb <= not(data(150) xor data(97));                                             end generate;
   fb151 : if WIDTH = 151 generate fb <= not(data(151) xor data(148));                                            end generate;
   fb152 : if WIDTH = 152 generate fb <= not(data(152) xor data(151) xor data(87) xor data(86));                  end generate;
   fb153 : if WIDTH = 153 generate fb <= not(data(153) xor data(152));                                            end generate;
   fb154 : if WIDTH = 154 generate fb <= not(data(154) xor data(152) xor data(27) xor data(25));                  end generate;
   fb155 : if WIDTH = 155 generate fb <= not(data(155) xor data(154) xor data(124) xor data(123));                end generate;
   fb156 : if WIDTH = 156 generate fb <= not(data(156) xor data(155) xor data(41) xor data(40));                  end generate;
   fb157 : if WIDTH = 157 generate fb <= not(data(157) xor data(156) xor data(131) xor data(130));                end generate;
   fb158 : if WIDTH = 158 generate fb <= not(data(158) xor data(157) xor data(132) xor data(131));                end generate;
   fb159 : if WIDTH = 159 generate fb <= not(data(159) xor data(128));                                            end generate;
   
   fb160 : if WIDTH = 160 generate fb <= not(data(160) xor data(159) xor data(142) xor data(141));                end generate;
   fb161 : if WIDTH = 161 generate fb <= not(data(161) xor data(143));                                            end generate;
   fb162 : if WIDTH = 162 generate fb <= not(data(162) xor data(161) xor data(75) xor data(74));                  end generate;
   fb163 : if WIDTH = 163 generate fb <= not(data(163) xor data(162) xor data(104) xor data(103));                end generate;
   fb164 : if WIDTH = 164 generate fb <= not(data(164) xor data(163) xor data(151) xor data(150));                end generate;
   fb165 : if WIDTH = 165 generate fb <= not(data(165) xor data(164) xor data(135) xor data(134));                end generate;
   fb166 : if WIDTH = 166 generate fb <= not(data(166) xor data(165) xor data(128) xor data(127));                end generate;
   fb167 : if WIDTH = 167 generate fb <= not(data(167) xor data(161));                                            end generate;
   fb168 : if WIDTH = 168 generate fb <= not(data(168) xor data(166) xor data(153) xor data(151));                end generate;

   ---------------------------------------------------------
   -- Shift register part
   --
   
   process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         data <= (others => '0');
      elsif(clk_i'event and clk_i = '1') then
         if(clr_i = '1') then
            data <= (others => '0');
         elsif(ena_i = '1') then
            if(load_i = '1') then
               data <= lfsr_i;
            else
               data <= fb & data(1 to WIDTH-1);
            end if;
         end if;
      end if;
   end process;
   
   lfsr_o <= data;

end behav;