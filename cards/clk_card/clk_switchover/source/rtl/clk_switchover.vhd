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
-- $Id: clk_switchover.vhd,v 1.1 2006/05/13 07:38:12 bburger Exp $
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

entity clk_switchover is
   port(
      rst       : in std_logic;
      xtal_clk  : in std_logic; -- Crystal Clock Input
      manch_clk : in std_logic; -- Manchester Clock Input
      manch_det : in std_logic;
      switch_to_xtal  : in std_logic;
      switch_to_manch : in std_logic;
      e2        : out std_logic;
      c0        : out std_logic;
      c1        : out std_logic;
      c2        : out std_logic;
      c3        : out std_logic;
      e0        : out std_logic;
      e1        : out std_logic 
   );     
end clk_switchover;


architecture top of clk_switchover is

   component cc_pll
      port (
         clkswitch      : IN STD_LOGIC  := '0';
         inclk0      : IN STD_LOGIC  := '0';
         inclk1      : IN STD_LOGIC  := '0';
--         pfdena      : IN STD_LOGIC  := '1';
         e2    : OUT STD_LOGIC ;
         c0    : OUT STD_LOGIC ;
         c1    : OUT STD_LOGIC ;
         c2    : OUT STD_LOGIC ;
         c3    : OUT STD_LOGIC ;
         clkloss : out std_logic;
         locked      : OUT STD_LOGIC ;
         activeclock    : OUT STD_LOGIC ;
         e0    : OUT STD_LOGIC ;
         clkbad0     : OUT STD_LOGIC ;
         e1    : OUT STD_LOGIC ;
         clkbad1     : OUT STD_LOGIC 
      );
   end component;   

   --component pll1
   --port(inclk0      : in std_logic  := '0';
   --     inclk1      : in std_logic  := '0';
   --     c0          : out std_logic ;
   --     c0_ena      : in std_logic  := '1';
   --     e0          : out std_logic ;
   --     e0_ena      : in std_logic  := '1';
   --     clkswitch   : in std_logic  := '0';
   --     pfdena      : in std_logic  := '1';
   --     activeclock : out std_logic ;
   --     clkbad0     : out std_logic ;
   --     clkbad1     : out std_logic ;
   --     locked      : out std_logic);
   --end component;

   type states is (CRYSTAL_CLK, MANCHESTER_CLK, SWITCHING, RELOCKING);
   signal ps, ns : states;

   constant LOCK_GATED_DELAY : integer := 16;
   constant DET_GATED_DELAY  :  integer := 8;

   signal gated_lock_reg     : std_logic_vector(LOCK_GATED_DELAY-1 downto 0);
   signal gated_lock         : std_logic;

   signal gated_det_reg      : std_logic_vector(DET_GATED_DELAY-1 downto 0);
   signal gated_det          : std_logic;

   signal count              : std_logic_vector(1 downto 0);
   signal count_rst          : std_logic;
   
   signal pfdena             : std_logic;
--   signal extclkena          : std_logic;
   signal activeclock        : std_logic;
   signal xtal_clk_bad       : std_logic;
   signal manch_clk_bad      : std_logic;
   signal locked             : std_logic;
   signal clkswitch          : std_logic;
   signal clkloss            : std_logic;
   
   signal clk                : std_logic;

begin

   c0 <= clk;
   pll0: cc_pll
      port map(
         clkswitch   => clkswitch,
         inclk0      => xtal_clk,
         inclk1      => manch_clk,
--         pfdena      => pfdena,
         e2          => e2,
         c0          => clk,
         c1          => c1,
         c2          => c2,
         c3          => c3,
         clkloss     => clkloss,
         locked      => locked,
         activeclock => activeclock,
         e0          => e0,
         clkbad0     => xtal_clk_bad,
         e1          => e1,
         clkbad1     => manch_clk_bad
      );  

--   clkgen0 : pll1
--   port map(inclk0 => xtal_clk,
--            inclk1 => manch_clk,
--            c0 => open,
--            c0_ena => '1',
--            e0 => extclkout,
--            e0_ena => extclkena,
--            clkswitch => clkswitch,
--            -- What is this?
--            pfdena => pfdena,
--            activeclock => activeclock,
--            clkbad0 => clkbad0,
--            clkbad1 => clkbad1,
--            locked => locked);


   -- **Note:  make sure that the machester signal detect is double buffered.
   
   -- gated lock, msig generation:
   process(xtal_clk)
   begin
      if(xtal_clk'event and xtal_clk = '1') then
         gated_lock_reg <= locked & gated_lock_reg(LOCK_GATED_DELAY-1 downto 1);
         gated_det_reg <= manch_det & gated_det_reg(DET_GATED_DELAY-1 downto 1);
      end if;
   end process;

   process(gated_lock_reg)
   variable gated_lock_temp : std_logic;
   begin
      gated_lock_temp := gated_lock_reg(0);
      for i in 1 to LOCK_GATED_DELAY-1 loop
         gated_lock_temp := gated_lock_temp and gated_lock_reg(i);
      end loop;
      gated_lock <= gated_lock_temp;
   end process;

   process(gated_det_reg)
   variable gated_det_temp : std_logic;
   begin
      gated_det_temp := gated_det_reg(0);
      for i in 1 to DET_GATED_DELAY-1 loop
         gated_det_temp := gated_det_temp and gated_det_reg(i);
      end loop;
      gated_det <= gated_det_temp;
   end process;


   -- counter for counting out minimum CLKSWITCH pulse duration:
   process(clk)
   begin
      if(clk'event and clk = '1') then
         if(count_rst = '1') then
            count <= "00";
         else
            count <= count + 1;
         end if;
      end if;
   end process;


   -- switchover FSM:
   process(clk, rst)
   begin
      if(rst = '1') then
         ps <= CRYSTAL_CLK;
      elsif(clk'event and clk = '1') then
         ps <= ns;
      end if;
   end process;

-- There are four scenarios to be handled:
-- if(using crystal clock)
--    if(crystal clock is good)
--       if(clock switch command)
--          if(manchester clock is good)
--             switch to manchester clock;
--          end if;
--       end if;
--    elsif(crystal clock is bad)
--       if(manchester clock is good)
--          switch to manchester clock;
--       end if;
--    end if;
-- elsif(using manchester clock)
--    if(mancheseter clock is good)
--       if(clock switch command)
--          if(crystal clock is good)
--             switch to crystal clock;
--          end if;
--       end if;
--    elsif(manchester clock is bad)
--       if(crystal clock is good)
--          switch to crystal clock;
--       end if;
--    end if;
-- end if;
--SWITCH_TO_XTAL

   process(ps, xtal_clk_bad, manch_clk_bad, switch_to_manch, switch_to_xtal, activeclock, clkloss) --manch_det, locked)
   begin
      -- Default Assignment
      ns <= ps;
      
      case ps is
         when CRYSTAL_CLK => 
--            if(xtal_clk_bad = '0') then
               if(activeclock = '1') then
                  ns <= MANCHESTER_CLK;
               elsif(switch_to_manch = '1') then
                  if(manch_clk_bad = '0') then
                     ns <= SWITCHING;
                  end if;
               end if;

               
--            elsif(xtal_clk_bad = '1') then
--               if(manch_clk_bad = '0') then
--                  ns <= SWITCHING;
--               end if;
--            end if;
               
--            if(gated_det = '1') then
--               ns <= SWITCHING;
--            else
--               ns <= CRYSTAL_CLK;
--            end if;

         when MANCHESTER_CLK =>   
--            if(manch_clk_bad = '0') then
               if(activeclock = '0') then
                  ns <= CRYSTAL_CLK;
               elsif(switch_to_xtal = '1') then
                  if(xtal_clk_bad = '0') then
                     ns <= SWITCHING;
                  end if;
               end if;
--            elsif(manch_clk_bad = '1') then
--               if(xtal_clk_bad = '0') then
--                  ns <= SWITCHING;
--               end if;
--            end if;

--            if(gated_lock = '0') then
--               ns <= SWITCHING;
--            else
--               ns <= FIBRE_CLK;
--            end if;

         when SWITCHING =>
            if(clkloss /= '1') then
               ns <= RELOCKING;
            end if;
--            if(count = "11") then
--               ns <= RELOCKING;
--            else
--               ns <= SWITCHING;
--            end if;         
         
         when RELOCKING =>   
            if(activeclock = '0') then
               ns <= CRYSTAL_CLK;
            elsif(activeclock = '1') then
               ns <= MANCHESTER_CLK;
            end if;

--            if(activeclock = '0') then
--               ns <= CRYSTAL_CLK;
--            elsif(activeclock = '1') then
--               ns <= MANCHESTER_CLK;
--            else
--               ns <= RELOCKING;
--            end if;

--            if(gated_lock = '1' and activeclock = '0') then
--               ns <= CRYSTAL_CLK;
--            elsif(gated_lock = '1' and activeclock = '1') then
--               ns <= MANCH_CLK;
--            else
--               ns <= RELOCKING;
--            end if;

         when others =>      
            ns <= CRYSTAL_CLK;
            
      end case;
   end process;

   process(ps)
   begin
      clkswitch <= '0';
--      extclkena <= '0';
      count_rst <= '1';

      case ps is        
         when CRYSTAL_CLK => 
--            extclkena <= '1';

         when MANCHESTER_CLK =>   
--            if(gated_det = '0') then
--               extclkena <= '0';
--            else
--               extclkena <= '1';
--            end if;

         when SWITCHING =>   
--            count_rst <= '0';
            clkswitch <= '1';

         when RELOCKING =>
            clkswitch <= '1';
         
         when others => null;
         
      end case;
   end process;

   pfdena <= '1';

   -- output monitors:
--   pfdena_o <= pfdena;
--   extclkena_o <= extclkena;
--   clkswitch_o <= clkswitch;
--   activeclock_o <= activeclock;
--   clkbad0_o <= clkbad0;
--   clkbad1_o <= clkbad1;
--   locked_o <= locked;
--   clkloss_o <= clkloss;

end top;


