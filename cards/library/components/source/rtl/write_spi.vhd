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

-- write_serial_data.vhd
--
-- <revision control keyword substitutions e.g. $Id: write_spi.vhd,v 1.2 2004/03/31 18:58:17 jjacob Exp $>
--
-- Project:       SCUBA-2
-- Author:         Jonathan Jacob
-- Organisation:  UBC
--
-- Description:  This module implements writing to an SPI device
-- WARNING: This code has not yet been linted!
--
--
-- Revision history:
--
-- <date $Date: 2004/03/31 18:58:17 $> -     <text>      - <initials $Author: jjacob $>

--
-----------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library components;
use components.component_pack.all;

entity write_spi is

generic(DATA_LENGTH : integer := 8);

port(--inputs
     spi_clk_i        : in std_logic;
     rst_i            : in std_logic;
     start_i          : in std_logic;
     parallel_data_i  : in std_logic_vector(DATA_LENGTH-1 downto 0);

     --outputs
     spi_clk_o        : out std_logic;
     done_o           : out std_logic;
     serial_wr_data_o : out std_logic);

end write_spi;

architecture rtl of write_spi is

-- state encoding:
constant IDLE       : std_logic := '0';
constant WRITE      : std_logic := '1';

-- state variables:
signal current_state : std_logic;
signal next_state    : std_logic;

signal run_spi_clk   : std_logic;
signal n_spi_clk     : std_logic;

signal reset_counter : std_logic;
signal count         : integer;

-- shift register signals
signal shift_reg_data : std_logic;
signal shift_reg_en   : std_logic;
signal shift_reg_load : std_logic;
signal shift_reg_clr  : std_logic;
signal shl            : std_logic;
signal zero           : std_logic;

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
               next_state <= WRITE;
            else
               next_state <= IDLE;
            end if;

         when WRITE =>
            if count >= DATA_LENGTH-1 then
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
      case current_state is
         when IDLE =>

            if start_i = '1' then
               run_spi_clk     <= '1';
               shift_reg_en    <= '1';

               reset_counter   <= '0';
               shift_reg_load  <= '0';
               shift_reg_clr   <= '0';
               done_o          <= '0';
            else
               run_spi_clk     <= '0';
               shift_reg_en    <= '1';

               reset_counter   <= '1';
               shift_reg_load  <= '1';
               shift_reg_clr   <= '0';
               done_o          <= '0';
            end if;

         when WRITE =>

            if count >= DATA_LENGTH-1 then
               run_spi_clk     <= '1';
               shift_reg_en    <= '1';

               reset_counter   <= '0';
               shift_reg_load  <= '0';
               shift_reg_clr   <= '0';
               done_o          <= '1';

            else

               run_spi_clk     <= '1';
               shift_reg_en    <= '1';

               reset_counter   <= '0';
               shift_reg_load  <= '0';
               shift_reg_clr   <= '0';
               done_o          <= '0';
            end if;

         when others =>

            run_spi_clk        <= '0';
            shift_reg_en       <= '0';

            reset_counter      <= '1';
            shift_reg_load     <= '1';
            shift_reg_clr      <= '1';
            done_o             <= '0';

      end case;
   end process;


------------------------------------------------------------------------
--
-- Instantiate shift registers
--
------------------------------------------------------------------------

   shl  <= '0';
   zero <= '0';

   spi_shift : shift_reg

   generic map (WIDTH => DATA_LENGTH)
   port map(clk      => n_spi_clk,
        rst          => rst_i,
        ena          => shift_reg_en,
        load         => shift_reg_load,
        clr          => shift_reg_clr,
        shr          => shl, -- '0'
        serial_i     => zero,
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