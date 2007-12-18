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
-- one_wire_master.vhd
--
-- Project:       SCUBA-2
-- Author:        Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Implements the master for communicating with slave devices that use the 1-wire protocol.
--
-- Revision history:
--
-- $Log: one_wire_master.vhd,v $
-- Revision 1.3  2005/10/26 21:04:05  erniel
-- consolidated external and internal interfaces via generic parameter
-- fixed potentially dangerous issue with previous interface change
-- converted counters to binary_counters
--
-- Revision 1.2  2005/10/21 19:04:50  erniel
-- added support for interfaces with external tristate
-- some interface signal name changes
--
-- Revision 1.1  2005/06/20 17:02:43  erniel
-- initial version
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library components;
use components.component_pack.all;

entity one_wire_master is
generic(tristate : string := "INTERNAL");  -- valid values are "INTERNAL" and "EXTERNAL".
port(clk_i         : in std_logic;
     rst_i         : in std_logic;

     -- host-side signals
     master_data_i : in std_logic_vector(7 downto 0);
     master_data_o : out std_logic_vector(7 downto 0);

     init_i        : in std_logic;         -- request initialization
     read_i        : in std_logic;         -- read a byte
     write_i       : in std_logic;         -- write a byte

     done_o        : out std_logic;        -- operation completed
     ready_o       : out std_logic;        -- slave is ready
     ndetect_o     : out std_logic;        -- slave is detected

     -- slave-side signals
     slave_data_io : inout std_logic;      -- if using external tristate, use this signal as data input
     slave_data_o  : out std_logic;
     slave_wren_o  : out std_logic);
end one_wire_master;

architecture behav of one_wire_master is

--------------------------------------------------------------------------------------
-- NOTE: The following constants must be adjusted if the clock frequency changes!
--
-- INIT_PHASE_1_LENGTH = 500 us
-- INIT_PHASE_1_LENGTH = 500 us
-- PRESENCE_PULSE_DELAY = 100 us
-- SLOT_LENGTH = 75 us
-- WRITE_0_SLOT_DELAY = 70 us
-- WRITE_1_SLOT_DELAY = 5 us
-- READ_SLOT_DELAY = 3 us
-- READ_SLOT_SAMPLE = 13 us
--------------------------------------------------------------------------------------

constant INIT_PHASE_1_LENGTH  : integer := 25000;   -- 25000 x 20 ns clock cycle = 500 us
constant INIT_PHASE_2_LENGTH  : integer := 25000;
constant PRESENCE_PULSE_DELAY : integer := 5000;
constant SLOT_LENGTH          : integer := 3750;
constant WRITE_0_SLOT_DELAY   : integer := 3500;
constant WRITE_1_SLOT_DELAY   : integer := 250;
constant READ_SLOT_DELAY      : integer := 150;
constant READ_SLOT_SAMPLE     : integer := 650;

constant TIMER_WIDTH : integer := 18;   -- 2**TIMER_WIDTH must be greater than largest constant above!

type states is (IDLE, INIT_PULSE, INIT_REPLY, WRITE_SLOT, READ_SLOT, INIT_DONE, WRITE_DONE, READ_DONE);
signal pres_state : states;
signal next_state : states;

signal write_reg_ena : std_logic;
signal write_reg_ld  : std_logic;
signal write_data    : std_logic;

signal read_reg_ena : std_logic;
signal read_data    : std_logic_vector(7 downto 0);

signal bit_count_ena : std_logic;
signal bit_count_clr : std_logic;
signal bit_count     : std_logic_vector(2 downto 0);

signal timer_clr : std_logic;
signal timer     : std_logic_vector(TIMER_WIDTH-1 downto 0);

signal pulldown_ena : std_logic;

begin

   tx_data_reg : shift_reg
   generic map(WIDTH => 8)
   port map(clk_i      => clk_i,
            rst_i      => rst_i,
            ena_i      => write_reg_ena,
            load_i     => write_reg_ld,
            clr_i      => '0',
            shr_i      => '1',
            serial_i   => '0',
            serial_o   => write_data,
            parallel_i => master_data_i,
            parallel_o => open);

   rx_data_reg : shift_reg
   generic map(WIDTH => 8)
   port map(clk_i      => clk_i,
            rst_i      => rst_i,
            ena_i      => read_reg_ena,
            load_i     => '0',
            clr_i      => '0',
            shr_i      => '1',
            serial_i   => slave_data_io,
            serial_o   => open,
            parallel_i => (others => '0'),
            parallel_o => read_data);

   master_data_o <= read_data;

   bit_counter : binary_counter
   generic map(WIDTH => 3)
   port map(clk_i   => clk_i,
            rst_i   => rst_i,
            ena_i   => bit_count_ena,
            up_i    => '1',
            load_i  => '0',
            clear_i => bit_count_clr,
            count_i => (others => '0'),
            count_o => bit_count);

   timer_counter : binary_counter
   generic map(WIDTH => TIMER_WIDTH)
   port map(clk_i   => clk_i,
            rst_i   => rst_i,
            ena_i   => '1',
            up_i    => '1',
            load_i  => '0',
            clear_i => timer_clr,
            count_i => (others => '0'),
            count_o => timer);


   ---------------------------------------------------------
   -- One-Wire Protocol FSM
   ---------------------------------------------------------

   stateFF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         pres_state <= IDLE;
      elsif(clk_i = '1' and clk_i'event) then
         pres_state <= next_state;
      end if;
   end process stateFF;

   stateNS: process(pres_state, init_i, write_i, read_i, bit_count, timer)
   begin
      next_state <= pres_state;

      case pres_state is
         when IDLE =>       if(init_i = '1') then
                               next_state <= INIT_PULSE;
                            elsif(write_i = '1') then
                               next_state <= WRITE_SLOT;
                            elsif(read_i = '1') then
                               next_state <= READ_SLOT;
                            else
                               next_state <= IDLE;
                            end if;

         when INIT_PULSE => if(timer = INIT_PHASE_1_LENGTH)  then
                               next_state <= INIT_REPLY;
                            else
                               next_state <= INIT_PULSE;
                            end if;

         when INIT_REPLY => if(timer = INIT_PHASE_2_LENGTH) then
                               next_state <= INIT_DONE;
                            else
                               next_state <= INIT_REPLY;
                            end if;

         when WRITE_SLOT => if(timer = SLOT_LENGTH and bit_count = 7) then
                               next_state <= WRITE_DONE;
                            else
                               next_state <= WRITE_SLOT;
                            end if;

         when READ_SLOT =>  if(timer = SLOT_LENGTH and bit_count = 7) then
                               next_state <= READ_DONE;
                            else
                               next_state <= READ_SLOT;
                            end if;

         when others =>     next_state <= IDLE;
      end case;
   end process stateNS;

   stateOut: process(pres_state, write_data, read_data, timer)
   begin
      done_o        <= '0';
      ready_o       <= '0';
      ndetect_o     <= '1';

      pulldown_ena  <= '0';

      write_reg_ena <= '0';
      write_reg_ld  <= '0';

      read_reg_ena  <= '0';

      bit_count_ena <= '0';
      bit_count_clr <= '0';

      timer_clr     <= '0';

      case pres_state is
         when IDLE =>       write_reg_ena <= '1';
                            write_reg_ld  <= '1';
                            bit_count_clr <= '1';
                            timer_clr     <= '1';

         when INIT_PULSE => pulldown_ena  <= '1';
                            if(timer = INIT_PHASE_1_LENGTH) then
                               timer_clr     <= '1';
                            end if;

         when INIT_REPLY => if(timer < PRESENCE_PULSE_DELAY) then
                               read_reg_ena  <= '1';
                            end if;

                            if(timer = INIT_PHASE_2_LENGTH) then
                               timer_clr     <= '1';
                            end if;

         when WRITE_SLOT => if((timer < WRITE_0_SLOT_DELAY and write_data = '0') or
                               (timer < WRITE_1_SLOT_DELAY and write_data = '1')) then
                               pulldown_ena  <= '1';
                            end if;

                            if(timer = SLOT_LENGTH) then
                               write_reg_ena <= '1';
                               bit_count_ena <= '1';
                               timer_clr     <= '1';
                            end if;

         when READ_SLOT =>  if(timer < READ_SLOT_DELAY) then
                               pulldown_ena  <= '1';
                            end if;

                            if(timer = READ_SLOT_SAMPLE) then
                               read_reg_ena  <= '1';
                            end if;

                            if(timer = SLOT_LENGTH) then
                               bit_count_ena <= '1';
                               timer_clr     <= '1';
                            end if;

         when INIT_DONE =>  done_o    <= '1';
                            ndetect_o <= read_data(7) or read_data(6) or read_data(5) or read_data(4) or
                                         read_data(3) or read_data(2) or read_data(1) or read_data(0);

         when WRITE_DONE => done_o    <= '1';

         when READ_DONE =>  done_o    <= '1';
                            ready_o   <= read_data(7) or read_data(6) or read_data(5) or read_data(4) or
                                         read_data(3) or read_data(2) or read_data(1) or read_data(0);

         when others =>     null;
      end case;
   end process stateOut;


   ---------------------------------------------------------
   -- Conversion to Internally Tristated Interface
   ---------------------------------------------------------

   interface: process(pulldown_ena)
   begin
      if(tristate = "INTERNAL") then
         if(pulldown_ena = '1') then
            slave_data_io <= '0';
         else
            slave_data_io <= 'Z';
         end if;
      else
         slave_data_o <= '0';
         slave_wren_o <= pulldown_ena;
      end if;
   end process interface;

end behav;