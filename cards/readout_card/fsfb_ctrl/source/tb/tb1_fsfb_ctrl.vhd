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
-- tb1_fsfb_ctrl.vhd
--
-- Project:	  SCUBA-2
-- Author:        Mohsen Nahvi
-- Organisation:  UBC
--
--
-- Description:
-- In this testbench, we cycle through three different phases.
-- 
-- Phase1 is to test the effect of having positive and negative data. In this
-- phase we assert the dac_dat_en_i after the input is latched in.
--
-- Phase2 is to test the effect of the dac_dat_en_i to be enabled before we
-- latch in the input data.
--
-- Phase3 is to test the effect of the dac_dat_en_i to change its state on the
-- same edge when we read the data into the register connected to the output
-- data.
--
--
--
-- Revision history:
-- 
-- $Log: tb1_fsfb_ctrl.vhd,v $
-- Revision 1.4  2006/05/17 20:33:53  mandana
-- modified to work with latest fsfb_ctrl
--
-- Revision 1.3  2005/02/21 23:47:11  mohsen
-- sign extend negative values
--
-- Revision 1.2  2004/11/26 18:27:02  mohsen
-- Anthony & Mohsen: Restructured constant declaration.  Moved shared constants from lower level package files to the upper level ones.  This was done to resolve compilation error resulting from shared constants defined in multiple package files.
--
-- Revision 1.1  2004/11/05 02:13:22  mohsen
-- Initial release
--
--
--
------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;

-- Call DUT Library
use work.fsfb_ctrl_pack.all;

-- Call Parent Library
use work.flux_loop_ctrl_pack.all;
use work.readout_card_pack.all;

library components;
use components.component_pack.all;



entity tb1_fsfb_ctrl is

end tb1_fsfb_ctrl;



architecture beh of tb1_fsfb_ctrl is

  component fsfb_ctrl
    generic (
      CONVERSION_POLARITY_MODE : integer);
      --FSFB_ACCURACY_POSITION   : integer);
    port (
      clk_50_i            : in  std_logic;
      rst_i               : in  std_logic;
      dac_dat_en_i        : in  std_logic;
      fsfb_ctrl_dat_i     : in  std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
      fsfb_ctrl_dat_rdy_i : in  std_logic;
      fsfb_ctrl_lock_en_i : in  std_logic;
      dac_dat_o           : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
      dac_clk_o           : out std_logic);
  end component;

  
  constant CONVERSION_POLARITY_MODE : integer := 0;  -- use 0 for positive and 1 for negative polarity
  constant FSFB_ACCURACY_POSITION   : integer := 13;

  signal clk_50_i            : std_logic;
  signal rst_i               : std_logic;
  signal dac_dat_en_i        : std_logic;
  signal fsfb_ctrl_dat_i     : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
  signal fsfb_ctrl_dat_rdy_i : std_logic;
  signal fsfb_ctrl_lock_en_i : std_logic;
  signal dac_dat_o           : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
  signal dac_clk_o           : std_logic;


  constant PERIOD                    : time := 20 ns;
  constant EDGE_DEPENDENCY           : time := 2 ns;  --shows clk edge dependency
  constant RESET_WINDOW              : time := 8*PERIOD;
  constant FREE_RUN                  : time := 19*PERIOD;

  signal reset_window_done           : boolean := false;
  signal finish_tb1                  : boolean := false;  -- asserted to end tb
  signal phase1                      : boolean := false;
  signal phase2                      : boolean := false;
  signal phase3                      : boolean := false;


  
begin  -- beh


  -----------------------------------------------------------------------------
  -- Instantiation of Device Under Test
  -----------------------------------------------------------------------------
  
  DUT: fsfb_ctrl
    generic map (
        CONVERSION_POLARITY_MODE => CONVERSION_POLARITY_MODE)--,
        --FSFB_ACCURACY_POSITION   => FSFB_ACCURACY_POSITION)
    port map (
        clk_50_i            => clk_50_i,
        rst_i               => rst_i,
        dac_dat_en_i        => dac_dat_en_i,
        fsfb_ctrl_dat_i     => fsfb_ctrl_dat_i,
        fsfb_ctrl_dat_rdy_i => fsfb_ctrl_dat_rdy_i,
        fsfb_ctrl_lock_en_i => fsfb_ctrl_lock_en_i,
        dac_dat_o           => dac_dat_o,
        dac_clk_o           => dac_clk_o);


  -----------------------------------------------------------------------------
  -- Clocking
  -----------------------------------------------------------------------------

  clocking: process
  begin  -- process clocking

    clk_50_i <= '1';
    wait for PERIOD/2;
    
    while (not finish_tb1) loop
      clk_50_i <= not clk_50_i;
      wait for PERIOD/2;
    end loop;

    wait;
    
  end process clocking;


  -----------------------------------------------------------------------------
  -- Perform Test
  -----------------------------------------------------------------------------

  i_test: process

    ---------------------------------------------------------------------------
    -- Procedure to initialize all the inputs
    ---------------------------------------------------------------------------
    
    procedure do_initialize is
    begin
      reset_window_done       <= false;
      rst_i                   <= '1';
      dac_dat_en_i            <= '0';
      fsfb_ctrl_dat_i         <= (others => '0');
      fsfb_ctrl_dat_rdy_i     <= '0';
      fsfb_ctrl_lock_en_i     <= '1';
      
      wait for 113 ns;
      rst_i <= '0';
      wait for RESET_WINDOW - 113 ns;   -- alligne with clk

      reset_window_done <= true;
    end do_initialize;


    ---------------------------------------------------------------------------
    -- Procedure to do simple test
    ---------------------------------------------------------------------------
    procedure simple_test is
    begin
      wait for EDGE_DEPENDENCY;

      -------------------------------------------------------------------------
      -- Phase1: dac_dat_en_i is not valid when we recieve fsfb_ctrl_dat_rdy_i
      -------------------------------------------------------------------------
      phase1              <= true;
      fsfb_ctrl_dat_i     <= "01" & x"A5F";   -- positive value for 14-bit data
      fsfb_ctrl_dat_rdy_i <= '1',
                             '0' after PERIOD;
      wait for 6*PERIOD;
      fsfb_ctrl_dat_i <= (others => '0');  -- test data lines going to zero
      wait for 4*PERIOD;

      dac_dat_en_i <= '1';
      wait for 15*PERIOD;

      dac_dat_en_i <= '0';

      wait for 5*PERIOD;

      fsfb_ctrl_dat_i     <= "11" & x"B17";   -- negative value for 14-bit data
      wait for PERIOD;
      fsfb_ctrl_dat_rdy_i <= '1',
                             '0' after PERIOD;

      wait for 7*PERIOD;
      dac_dat_en_i <= '1';
      wait for 12*PERIOD;

      dac_dat_en_i <= '0';
      wait for 8*PERIOD;
      phase1       <= false;


      -------------------------------------------------------------------------
      -- Phase 2: dac_dat_en_i is valid before we recieve fsfb_ctrl_dat_i
      -------------------------------------------------------------------------
      phase2       <= true;
      dac_dat_en_i <= '1';

      wait for 4*PERIOD;
      fsfb_ctrl_dat_i     <= "10" & x"145";    -- negarive value for 14-bit
      wait for 2*PERIOD;
      fsfb_ctrl_dat_rdy_i <= '1',
                             '0' after PERIOD;

      wait for 12*PERIOD;
      dac_dat_en_i <= '0';
      wait for 3*PERIOD;
      phase2       <= false;

      -------------------------------------------------------------------------
      -- Phase 3: Not in lock mode, so negative inputs should not be altered
      -------------------------------------------------------------------------

      phase3              <= true;
      fsfb_ctrl_lock_en_i <= '0';
      wait for 15*PERIOD;

      fsfb_ctrl_dat_i     <= "11" & x"8AE";   -- negative value for 14-bit
      wait for 3*PERIOD;
      fsfb_ctrl_dat_rdy_i <= '1',
                             '0' after PERIOD;

      wait for 2*PERIOD;                -- dac_dat_en_i goes high on the same
                                        -- edge of internal rdy_to_clk_dac
      dac_dat_en_i <= '1';
      wait for 9*PERIOD;
      dac_dat_en_i <= '0';
      wait for 3*PERIOD;
      phase3       <= false;
      
      rst_i <= '1';
      wait for 2*PERIOD;
      
      rst_i <= '0';
      wait for 30*PERIOD;
      
    end simple_test;

    ---------------------------------------------------------------------------
    -- 
    ---------------------------------------------------------------------------
    
  begin  -- process i_test
    
    do_initialize;
    wait for 10*FREE_RUN;
    
    simple_test;
    
    finish_tb1 <= true;
    wait for 200*FREE_RUN;

    report "END OF TEST";

    wait;
      
      
  end process i_test;
  
  
end beh;
