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
-- smb_master.vhd
--
-- Project:	      SCUBA-2
-- Author:        Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Implements the master for communicating with slave devices on an SMBus.
--
-- Revision history:
-- 
-- $Log$
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library components;
use components.component_pack.all;

entity smb_master is
port(clk_i         : in std_logic;
     rst_i         : in std_logic;

     -- host-side signals
     master_data_i : in std_logic_vector(7 downto 0);
     master_data_o : out std_logic_vector(7 downto 0);

     start_i       : in std_logic;         -- request a start condition
     stop_i        : in std_logic;         -- request a stop condition
     write_i       : in std_logic;         -- write a byte
     read_i        : in std_logic;         -- read a byte

     done_o        : out std_logic;        -- operation completed
     error_o       : out std_logic;        -- slave returned an error

     -- slave-side signals
     slave_clk_o   : out std_logic;        -- SMBus clock
     slave_data_io : inout std_logic);     -- SMBus data
end smb_master;

architecture behav of smb_master is

--------------------------------------------------------------------------------------
-- NOTE: The following constants must be adjusted if the clock frequency changes!
--
-- END_CONDITION_LENGTH = 8.7 us
-- START_SETUP_DELAY = 4.7 us
-- STOP_SETUP_DELAY = 4 us
-- BIT_PERIOD_LENGTH = 100 us
-- DATA_VALID_BEGIN = 40 us       -- smbdat valid 40 us after start of bit period
-- DATA_VALID_END = 90 us         -- smbdat invalid 90 us after start of bit period
-- READ_DATA_SAMPLE = 65 us
--------------------------------------------------------------------------------------

constant END_CONDITION_LENGTH : integer := 435;   -- 435 x 20 ns clock cycle = 8.7 us   
constant START_SETUP_DELAY    : integer := 235;
constant STOP_SETUP_DELAY     : integer := 200;
constant BIT_PERIOD_LENGTH    : integer := 5000;
constant DATA_VALID_BEGIN     : integer := 2000;
constant DATA_VALID_END       : integer := 4500;
constant READ_DATA_SAMPLE     : integer := 3250;

constant TIMER_WIDTH : integer := 13;   -- 2**TIMER_WIDTH must be greater than largest constant above!

type states is (BUS_FREE, BUS_IDLE, START, STOP, WRITE_BYTE, READ_BYTE, START_DONE, STOP_DONE, WRITE_DONE, READ_DONE);
signal pres_state : states;
signal next_state : states;

signal write_reg_ena : std_logic;
signal write_reg_ld  : std_logic;
signal write_data    : std_logic;

signal read_reg_ena : std_logic;
signal read_data    : std_logic_vector(7 downto 0);

signal bit_count_ena : std_logic;
signal bit_count_clr : std_logic;
signal bit_count     : std_logic_vector(3 downto 0);

signal timer_clr : std_logic;
signal timer     : std_logic_vector(TIMER_WIDTH-1 downto 0);

begin

   tx_data_reg: shift_reg
   generic map(WIDTH => 8)
   port map(clk_i      => clk_i,
            rst_i      => rst_i,
            ena_i      => write_reg_ena,
            load_i     => write_reg_ld,
            clr_i      => '0',
            shr_i      => '0',
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
            shr_i      => '0',
            serial_i   => slave_data_io,
            serial_o   => open,
            parallel_i => (others => '0'),
            parallel_o => read_data); 

   master_data_o <= read_data;
   
   bit_counter : binary_counter
   generic map(WIDTH => 4)
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
   -- SMB Bus Protocol FSM
   ---------------------------------------------------------

   stateFF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         pres_state <= BUS_FREE;
      elsif(clk_i'event and clk_i = '1') then
         pres_state <= next_state;
      end if;
   end process stateFF;

   stateNS: process(pres_state, start_i, stop_i, write_i, read_i, bit_count, timer)
   begin
      case pres_state is
        when BUS_FREE =>        if(start_i = '1') then           -- must have start before anything else
                                   next_state <= START;
                                else
                                   next_state <= BUS_FREE;
                                end if;

        when BUS_IDLE =>        if(start_i = '1') then           -- request repeated start
                                   next_state <= START;
                                elsif(stop_i = '1') then
                                   next_state <= STOP;
                                elsif(write_i = '1') then
                                   next_state <= WRITE_BYTE;
                                elsif(read_i = '1') then
                                   next_state <= READ_BYTE;
                                else
                                   next_state <= BUS_IDLE;
                                end if;

        when START =>           if(timer = END_CONDITION_LENGTH) then
                                   next_state <= START_DONE;
                                else
                                   next_state <= START;
                                end if;

        when STOP =>            if(timer = END_CONDITION_LENGTH) then
                                   next_state <= STOP_DONE;
                                else
                                   next_state <= STOP;
                                end if;

        when WRITE_BYTE =>      if(timer = BIT_PERIOD_LENGTH and bit_count = 8) then
                                   next_state <= WRITE_DONE;
                                else
                                   next_state <= WRITE_BYTE;
                                end if;

        when READ_BYTE =>       if(timer = BIT_PERIOD_LENGTH and bit_count = 8) then
                                   next_state <= READ_DONE;
                                else
                                   next_state <= READ_BYTE;
                                end if;

        when START_DONE =>      next_state <= BUS_IDLE;

        when STOP_DONE =>       next_state <= BUS_FREE;
                                
        when WRITE_DONE =>      next_state <= BUS_IDLE;   

        when READ_DONE =>       next_state <= BUS_IDLE;

        when others =>          next_state <= BUS_FREE;
      end case;
   end process stateNS;

   stateOut: process(pres_state, write_data, read_data, bit_count, timer)
   begin
      done_o        <= '0';
      error_o       <= '0';

      slave_clk_o   <= 'Z';
      slave_data_io <= 'Z';

      write_reg_ena <= '0';
      write_reg_ld  <= '0';

      read_reg_ena  <= '0';

      bit_count_ena <= '0';
      bit_count_clr <= '0';

      timer_clr     <= '0';

      case pres_state is
        when BUS_FREE =>   timer_clr     <= '1';

        when BUS_IDLE =>   slave_clk_o   <= '0';
                           slave_data_io <= '0';
                           write_reg_ena <= '1';
                           write_reg_ld  <= '1';
                           bit_count_clr <= '1';
                           timer_clr     <= '1';

        when START =>      if(timer > START_SETUP_DELAY) then 
                              slave_data_io <= '0';  
                           end if;

        when STOP =>       if(timer < STOP_SETUP_DELAY) then 
                              slave_data_io <= '0';  
                           end if;

        when WRITE_BYTE => if(timer < DATA_VALID_BEGIN or timer > DATA_VALID_END) then
                              slave_clk_o   <= '0';
                           end if;

                           if(bit_count < 8 and write_data = '0') then
                              slave_data_io <= '0';
                           end if;

                           if(bit_count = 8 and timer = READ_DATA_SAMPLE) then
                              read_reg_ena  <= '1';
                           end if;
 
                           if(timer = BIT_PERIOD_LENGTH) then
                              if(bit_count = 8) then
                                 bit_count_clr <= '1';
                              else
                                 bit_count_ena <= '1';
                              end if;
                              write_reg_ena <= '1';
                              timer_clr     <= '1';
                           end if;

        when READ_BYTE =>  if(timer < DATA_VALID_BEGIN or timer > DATA_VALID_END) then
                              slave_clk_o   <= '0';
                           end if;

                           if(bit_count < 8 and timer = READ_DATA_SAMPLE) then
                              read_reg_ena  <= '1';
                           end if;

                           if(timer = BIT_PERIOD_LENGTH) then
                              if(bit_count = 8) then
                                 bit_count_clr <= '1';
                              else
                                 bit_count_ena <= '1';
                              end if;
                              timer_clr     <= '1';
                           end if;

        when START_DONE => slave_clk_o   <= '0';            -- smbclk and smbdat are low after start
                           slave_data_io <= '0';
                           done_o        <= '1';

        when STOP_DONE =>  done_o        <= '1';            -- smbclk and smbdat are high (ie. SMBus idle) after stop
                                   
        when WRITE_DONE => slave_clk_o   <= '0';            -- smbclk is low (glitches on smbdat are ok) after write
                           done_o        <= '1';
                           error_o       <= read_data(0);

        when READ_DONE =>  slave_clk_o   <= '0';            -- smbclk is low (glitches on smbdat are ok) after read
                           done_o        <= '1';

        when others => null;
      end case;
   end process stateOut;

end behav;