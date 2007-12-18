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

-- write_spi_with_cs.vhd
--
-- Project:       SCUBA-2
-- Author:         Jonathan Jacob
-- Organisation:  UBC
--
-- Description:  This module implements writing to an SPI device and implements cs signal
-- WARNING: This code has not yet been linted!
--
--
-- Revision history:
-- <date $Date: 2006/10/28 00:11:58 $> - <initials $Author: bburger $>
-- $Log: write_spi_with_cs.vhd,v $
-- Revision 1.7  2006/10/28 00:11:58  bburger
-- Bryce:  Removed unused signal
--
-- Revision 1.6  2006/04/28 21:38:51  mandana
-- added integer range for count
--
-- Revision 1.5  2005/01/17 23:29:54  mandana
-- fixed a bug with the data load
--
-- Revision 1.4  2004/10/27 00:00:35  bburger
-- Bryce:  ports were out of date with the component library
--
-- Revision 1.3  2004/04/19 23:40:07  mandana
-- fixed misallignment between data and clk
--
-- Revision 1.2  2004/04/16 19:52:08  mandana
-- fixed data_length compare
--
-- Revision 1.1  2004/04/15 18:37:58  mandana
-- initial release
--
--
-----------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library components;
use components.component_pack.all;

entity write_spi_with_cs is

generic(DATA_LENGTH : integer := 8);

port(--inputs
     spi_clk_i        : in std_logic;
     rst_i            : in std_logic;
     start_i          : in std_logic;
     parallel_data_i  : in std_logic_vector(DATA_LENGTH-1 downto 0);

     --outputs
     spi_clk_o        : out std_logic;
     done_o           : out std_logic;
     spi_ncs_o        : out std_logic;
     serial_wr_data_o : out std_logic);

end write_spi_with_cs;

architecture rtl of write_spi_with_cs is

-- state encoding:
type states is (IDLE, START, WRITE);
signal current_state : states;
signal next_state    : states;

signal run_spi_clk   : std_logic;
signal n_spi_clk     : std_logic;

signal reset_counter : std_logic;
signal count         : integer range 0 to DATA_LENGTH;

-- shift register signals
signal shift_reg_data : std_logic;
signal shift_reg_load : std_logic;
signal shl            : std_logic;

begin


-----------------------------------------------------------------------------
--
-- Clock logic
--
-----------------------------------------------------------------------------
   -- clock output going to the spi device
   spi_clk_o <= spi_clk_i when run_spi_clk = '1' else '0';

   -- phase shifted clock for the state machine logic
   n_spi_clk <= not(spi_clk_i);


-----------------------------------------------------------------------------
--
-- State machine sequencer
--
-----------------------------------------------------------------------------
   process(rst_i, n_spi_clk)
   begin
      if rst_i = '1' then
         current_state <= IDLE;
      elsif n_spi_clk'event and n_spi_clk = '1' then
         current_state <= next_state;
      end if;
   end process;


-----------------------------------------------------------------------------
--
-- Next state logic assignments
--
-----------------------------------------------------------------------------

   process(current_state, start_i, count)
   begin
      next_state <= current_state;

      case current_state is
         when IDLE =>
            if start_i = '1' then
               next_state <= START;
            else
               next_state <= IDLE;
            end if;

         when START =>
            next_state <= WRITE;

         when WRITE =>
            if count >= DATA_LENGTH - 1 then
               next_state <= IDLE;
            else
               next_state <= WRITE;
            end if;

         when others =>
            next_state <= IDLE;

      end case;
   end process;

   serial_wr_data_o     <= shift_reg_data;

-----------------------------------------------------------------------------
--
-- Next state output assignments
--
-----------------------------------------------------------------------------

   process(current_state, start_i, count)
   begin

      done_o <= '0';
      shift_reg_load  <= '0';
      reset_counter   <= '0';
      spi_ncs_o       <= '0';
      run_spi_clk     <= '0';

      case current_state is
         when IDLE =>
            if start_i = '1' then
               reset_counter   <= '1';
               shift_reg_load  <= '1';
            else
               spi_ncs_o       <= '1';
               reset_counter   <= '1';
               shift_reg_load  <= '1';
            end if;

         when START =>
            reset_counter      <= '1';
            run_spi_clk        <= '1';

         when WRITE =>
            run_spi_clk     <= '1';
            if count >= DATA_LENGTH - 1 then
               shift_reg_load  <= '1';
               spi_ncs_o       <= '1';
               done_o          <= '1';
            end if;

         when others =>
            null;

      end case;
   end process;


------------------------------------------------------------------------
--
-- Instantiate shift registers
--
------------------------------------------------------------------------

   shl  <= '0';

   spi_shift : shift_reg

   generic map (WIDTH => DATA_LENGTH)
   port map(clk_i      => n_spi_clk,
        rst_i          => rst_i,
        ena_i          => '1',
        load_i         => shift_reg_load,
        clr_i          => '0',
        shr_i          => shl, -- '0'
        serial_i     => '0',
        serial_o     => shift_reg_data,
        parallel_i   => parallel_data_i,
        parallel_o   => open);

------------------------------------------------------------------------
--
-- Counter for the EEPROM state machine, running off the slow clock
--
------------------------------------------------------------------------
   process(reset_counter, n_spi_clk)
   begin
      if reset_counter = '1' then
         count <= 0;
      elsif n_spi_clk'event and n_spi_clk = '1' then
         count <= count + 1;
      end if;
   end process;


end rtl;