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
-- $Id: clk_switchover.vhd,v 1.7 2009/03/19 20:22:03 bburger Exp $
--
-- Project:       SCUBA-2
-- Author:        Bryce Burger
-- Organization:  UBC
--
-- Description:
-- Clock switchover logic
--
-- Revision history:
-- $Log: clk_switchover.vhd,v $
-- Revision 1.7  2009/03/19 20:22:03  bburger
-- BB: Corrected a comment about how many clock cycles it takes to switch from one PLL input to another
--
-- Revision 1.6  2007/07/25 19:02:36  bburger
-- BB: added checking in the block for bad manchester or crystal clocks, and automoatic switchover if this occurs.
--
-- Revision 1.5  2006/08/16 17:52:53  bburger
-- Bryce:  Fixed a bug -- the clockswitch signal is now asserted until activeclk changes state
--
-- Revision 1.4  2006/06/30 22:07:12  bburger
-- Bryce:  Corrected an error with the wren signal and added the active_clk status signal to the interface
--
-- Revision 1.3  2006/06/19 17:22:47  bburger
-- Bryce:  added wishbone slave functionality
--
-- Revision 1.2  2006/06/09 22:37:12  bburger
-- Bryce:  Interim comittal
--
-- Revision 1.1  2006/05/13 07:38:12  bburger
-- Bryce:  Intermediate commital -- going away on holiday and don't want to lose work
--
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library sys_param;
use sys_param.wishbone_pack.all;

entity clk_switchover is
   port(
      -- wishbone interface:
      dat_i               : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_i              : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_i               : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i                : in std_logic;
      stb_i               : in std_logic;
      cyc_i               : in std_logic;
      dat_o               : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_o               : out std_logic;

      rst_i               : in std_logic;
      xtal_clk_i          : in std_logic; -- Crystal Clock Input
      manch_clk_i         : in std_logic; -- Manchester Clock Input
      active_clk_o        : out std_logic;
      e2_o                : out std_logic;
      c0_o                : out std_logic;
      c1_o                : out std_logic;
      c2_o                : out std_logic;
      c3_o                : out std_logic;
      e0_o                : out std_logic;
      e1_o                : out std_logic
   );
end clk_switchover;


architecture top of clk_switchover is

   component cc_pll
      port (
--         clkswitch      : IN STD_LOGIC  := '0';
         inclk0      : IN STD_LOGIC  := '0';
--         inclk1      : IN STD_LOGIC  := '0';
--         e2    : OUT STD_LOGIC ;
         c0    : OUT STD_LOGIC ;
         c1    : OUT STD_LOGIC ;
         c2    : OUT STD_LOGIC 
--         c3    : OUT STD_LOGIC ;
--         clkloss : out std_logic;
--         locked      : OUT STD_LOGIC ;
--         activeclock    : OUT STD_LOGIC ;
--         e0    : OUT STD_LOGIC ;
--         clkbad0     : OUT STD_LOGIC ;
--         e1    : OUT STD_LOGIC ;
--         clkbad1     : OUT STD_LOGIC
      );
   end component;

   constant XTAL_CLK               : std_logic := '0';
   constant MANCH_CLK              : std_logic := '1';

   -- Clock Switchover and PLL signals/states
   type states is (CRYSTAL_CLK, MANCHESTER_CLK, SWITCHING_2_CRYSTAL, SWITCHING_2_MANCHESTER);
   signal ps, ns : states;

   signal activeclock     : std_logic;
   signal xtal_clk_bad    : std_logic;
   signal manch_clk_bad   : std_logic;
   signal locked          : std_logic;
   signal clkswitch       : std_logic;
   signal clkloss         : std_logic;
   signal clk             : std_logic;

   -- Wishbone FSM inputs
   signal wr_cmd          : std_logic;
   signal rd_cmd          : std_logic;

   -- WBS states:
   type wbs_states is (IDLE, WR, RD);
   signal current_state   : wbs_states;
   signal next_state      : wbs_states;

   signal select_clk_wren : std_logic;
   signal select_clk_data : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal input_data      : std_logic;

begin

   active_clk_o <= activeclock;
   c0_o <= clk;
   pll0: cc_pll
      port map(
--         clkswitch   => clkswitch,
         inclk0      => xtal_clk_i,
--         inclk1      => manch_clk_i,
--         e2          => e2_o, -- lvds_clk
         c0          => clk,
         c1          => c1_o,
         c2          => c2_o
--         c3          => c3_o,
--         clkloss     => clkloss,
--         locked      => locked,
--         activeclock => activeclock,
--         e0          => e0_o,
--         clkbad0     => xtal_clk_bad,
--         e1          => e1_o,
--         clkbad1     => manch_clk_bad
      );

   -- **Note:  make sure that the machester signal detect is double buffered.
   ------------------------------------------------------------
   --  WB FSM
   ------------------------------------------------------------

   -- clocked FSMs, advance the state for both FSMs
   state_FF: process(clk, rst_i)
   begin
      if(rst_i = '1') then
         current_state     <= IDLE;
      elsif(clk'event and clk = '1') then
         current_state     <= next_state;
      end if;
   end process state_FF;

   -- Transition table for DAC controller
   state_NS: process(current_state, rd_cmd, wr_cmd, cyc_i)
   begin
      -- Default assignments
      next_state <= current_state;

      case current_state is
         when IDLE =>
            if(wr_cmd = '1') then
               next_state <= WR;
            elsif(rd_cmd = '1') then
               next_state <= RD;
            end if;

         when WR =>
            if(cyc_i = '0') then
               next_state <= IDLE;
            end if;

         when RD =>
            if(cyc_i = '0') then
               next_state <= IDLE;
            end if;

         when others =>
            next_state <= IDLE;

      end case;
   end process state_NS;

   -- Output states for DAC controller
   state_out: process(current_state, stb_i)
   begin
      -- Default assignments
      ack_o           <= '0';
      select_clk_wren <= '0';

      case current_state is
         when IDLE  =>
            ack_o <= '0';

         when WR =>
            ack_o <= '1';
            if(stb_i = '1') then
               select_clk_wren <= '1';
            end if;

         when RD =>
            ack_o <= '1';

         when others =>

      end case;
   end process state_out;

   ------------------------------------------------------------
   --  Wishbone interface:
   ------------------------------------------------------------
   input_data <= '0' when dat_i = x"00000000" else '1';
   select_clk_data <= "0000000000000000000000000000000" & activeclock;

   with addr_i select dat_o <=
      select_clk_data when SELECT_CLK_ADDR,
      (others => '0') when others;

   rd_cmd  <= '1' when
      (stb_i = '1' and cyc_i = '1' and we_i = '0') and
      (addr_i = SELECT_CLK_ADDR) else '0';

   wr_cmd  <= '1' when
      (stb_i = '1' and cyc_i = '1' and we_i = '1') and
      (addr_i = SELECT_CLK_ADDR) else '0';


   ------------------------------------------------------------
   -- Switchover FSM:
   ------------------------------------------------------------
   process(clk, rst_i)
   begin
      if(rst_i = '1') then
         ps <= CRYSTAL_CLK;
      elsif(clk'event and clk = '1') then
         ps <= ns;
      end if;
   end process;

   process(ps, xtal_clk_bad, manch_clk_bad, activeclock, select_clk_wren, input_data)
   begin
      -- Default Assignment
      ns <= ps;

      case ps is
         when CRYSTAL_CLK =>
            if(activeclock = MANCH_CLK) then
               ns <= MANCHESTER_CLK;
            elsif(xtal_clk_bad = '1') then
               -- Perhaps we don't want to do anything here yet,
               --  because I'm not sure if xtal_clk_bad = '1' momentarily just after power up.
               --ns <= SWITCHING_2_MANCHESTER;
            elsif(select_clk_wren = '1' and input_data = MANCH_CLK) then
               if(manch_clk_bad = '0') then
                  ns <= SWITCHING_2_MANCHESTER;
               end if;
            end if;

         -- This state is required because it takes 3 clock cycles for clkswitch being asserted to trigger a switch
         when SWITCHING_2_MANCHESTER =>
            if(activeclock = MANCH_CLK) then
               ns <= MANCHESTER_CLK;
            end if;

         when MANCHESTER_CLK =>
            if(activeclock = XTAL_CLK) then
               ns <= CRYSTAL_CLK;
            elsif(manch_clk_bad = '1') then
               ns <= SWITCHING_2_CRYSTAL;
            elsif(select_clk_wren = '1' and input_data = XTAL_CLK) then
               if(xtal_clk_bad = '0') then
                  ns <= SWITCHING_2_CRYSTAL;
               end if;
            end if;

         -- This state is required because it takes 3 clock cycles for clkswitch being asserted to trigger a switch
         when SWITCHING_2_CRYSTAL =>
            if(activeclock = XTAL_CLK) then
               ns <= CRYSTAL_CLK;
            end if;

         when others =>
            ns <= CRYSTAL_CLK;

      end case;
   end process;

   process(ps)
   begin
      clkswitch <= '0';

      case ps is
         when CRYSTAL_CLK =>

         when SWITCHING_2_MANCHESTER =>
            clkswitch <= '1';

         when MANCHESTER_CLK =>

         when SWITCHING_2_CRYSTAL =>
            clkswitch <= '1';

         when others => null;

      end case;
   end process;

end top;


