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
-- Project:       SCUBA-2
-- Author:        Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Implements the master for communicating with slave devices on an SMBus.
--
-- Revision history:
--
-- $Log: smb_master.vhd,v $
-- Revision 1.2  2007/03/06 00:57:53  bburger
-- Bryce:  re-vamped the smb_master to make it more modular, and fix some of the flakiness it exhibited in hardware.
--
-- Revision 1.1  2006/01/20 21:21:27  erniel
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

entity smb_master is
port(
   clk_i         : in std_logic;
   rst_i         : in std_logic;

   -- master-side signals
   r_nw_i        : in std_logic;                    -- read/not_write
   start_i       : in std_logic;                    -- read/write request
   addr_i        : in std_logic_vector(SMB_ADDR_WIDTH-1 downto 0); -- smb-slave register address
   data_i        : in std_logic_vector(SMB_DATA_WIDTH-1 downto 0); -- smb-slave data

   done_o        : out std_logic;                   -- read/write done
   error_o       : out std_logic;                   -- error
   data_o        : out std_logic_vector(SMB_DATA_WIDTH-1 downto 0); -- smb-slave data

   -- slave-side signals
   slave_clk_o   : out std_logic;                   -- SMBus clock
   slave_data_io : inout std_logic                  -- SMBus data
);
end smb_master;

architecture behav of smb_master is

   --------------------------------------------------------------------------------------
   -- Only one constant necessary:
   constant HALF_SMB_CLOCK_CYCLE : integer := 5;                --  5 us
   constant SMB_CLOCK_CYCLE : integer := 2*HALF_SMB_CLOCK_CYCLE;   -- 10 us
   --------------------------------------------------------------------------------------

   type states is (IDLE, SETTLE_COUNTER, START_CONDITION, ADDRESS, nWRITE, ACKNOWLEDGE, ACKNOWLEDGE2, DATA, STOP_CONDITION, DONE);
   signal pres_state : states;
   signal next_state : states;

   -- timer signals for asserting a waveform on the SMB bus for the proper amount of time
   signal timer_clr   : std_logic;
   signal timer_count : integer ;--range 0 to SMB_CLOCK_CYCLE + 200;
   --signal timer_count_delayed : integer ;--range 0 to SMB_CLOCK_CYCLE + 200;

   -- byte counter for byte 0 to 3 of each word
   signal bit_count     : integer range 0 to 8;
   signal bit_count_new : integer range 0 to 9;
   signal bit_count_en  : std_logic;
   signal bit_count_clr : std_logic;
   signal data_wd       : std_logic_vector(SMB_DATA_WIDTH-1 downto 0); -- smb-slave data

   signal addr_reg_en : std_logic;
   signal addr_reg    : std_logic;
   signal start_or_en : std_logic;

   signal rx_data_reg_en : std_logic;
--   signal tx_data_reg_en : std_logic;
   signal tx_data : std_logic;
   signal r_nw : std_logic;

   signal error : std_logic;
   signal error_en : std_logic;
   signal error_clr : std_logic;

begin

--   tx_data_reg: shift_reg
--   generic map(WIDTH => SMB_DATA_WIDTH-1)
--   port map(
--      clk_i      => clk_i,
--      rst_i      => rst_i,
--      ena_i      => tx_data_reg_en,
--      load_i     => start_i,
--      clr_i      => '0',
--      shr_i      => '0',
--      serial_i   => '0',
--      serial_o   => tx_data,
--      parallel_i => data_i,
--      parallel_o => open
--   );

   start_or_en <= addr_reg_en or start_i;
   tx_addr_reg: shift_reg
   generic map(WIDTH => SMB_ADDR_WIDTH)
   port map(
      clk_i      => clk_i,
      rst_i      => rst_i,
      ena_i      => start_or_en,
      load_i     => start_i,
      clr_i      => '0',
      shr_i      => '0',
      serial_i   => '0',
      serial_o   => addr_reg,
      parallel_i => addr_i,
      parallel_o => open
   );

   data_o <= data_wd;
   rx_data_reg : shift_reg
   generic map(WIDTH => SMB_DATA_WIDTH)
   port map(
      clk_i      => clk_i,
      rst_i      => rst_i,
      ena_i      => rx_data_reg_en,
      load_i     => '0',
      clr_i      => '0',
      shr_i      => '0',
      serial_i   => slave_data_io,
      serial_o   => open,
      parallel_i => (others => '0'),
      parallel_o => data_wd
   );

   r_nw_reg: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         r_nw <= '0';
         --timer_count_delayed <= 0;
         error <= '0';
      elsif(clk_i'event and clk_i = '1') then
         --timer_count_delayed <= timer_count;
         if(start_i = '1') then
            r_nw <= r_nw_i;
         end if;
         if(error_clr = '1') then
            error <= '0';
         elsif(error_en = '1') then
            error <= error or slave_data_io;
         end if;
      end if;
   end process r_nw_reg;

   bit_count_new <= bit_count + 1;
   process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         bit_count <= 0;
      elsif(clk_i'event and clk_i = '1') then
         -- Byte counter
         if(bit_count_clr = '1') then
            bit_count <= 0;
         elsif(bit_count_en = '1') then
            bit_count <= bit_count_new;
         end if;
      end if;
   end process;

   smb_timer : us_timer
   port map(
      clk => clk_i,
      timer_reset_i => timer_clr,
      timer_count_o => timer_count
   );

   ---------------------------------------------------------
   -- SMB Bus Protocol FSM
   ---------------------------------------------------------
   stateFF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         pres_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         pres_state <= next_state;
      end if;
   end process stateFF;

   stateNS: process(pres_state, start_i, timer_count, bit_count)
   begin
      next_state <= pres_state;

      case pres_state is
         when IDLE =>
            if(start_i = '1') then
               next_state <= SETTLE_COUNTER;
            end if;

         when SETTLE_COUNTER =>
            next_state <= START_CONDITION;

         when START_CONDITION =>
            if(timer_count >= SMB_CLOCK_CYCLE) then
               next_state <= ADDRESS;
            end if;

         when ADDRESS =>
            if(bit_count >= SMB_ADDR_WIDTH) then
               next_state <= nWRITE;
            end if;

         when nWRITE =>
            if(timer_count >= SMB_CLOCK_CYCLE) then
               next_state <= ACKNOWLEDGE;
            end if;

         when ACKNOWLEDGE =>
            if(timer_count >= SMB_CLOCK_CYCLE) then
               next_state <= DATA;
            end if;

         when DATA =>
            if(bit_count >= SMB_DATA_WIDTH) then
               next_state <= ACKNOWLEDGE2;
            end if;

         when ACKNOWLEDGE2 =>
            if(timer_count >= SMB_CLOCK_CYCLE) then
               next_state <= STOP_CONDITION;
            end if;

         when STOP_CONDITION =>
            if(timer_count >= SMB_CLOCK_CYCLE) then
               next_state <= DONE;
            end if;

         when DONE =>
            next_state <= IDLE;

         when others =>
            next_state <= IDLE;
      end case;
   end process stateNS;

   stateOut: process(pres_state, start_i, timer_count, addr_reg, bit_count, r_nw, tx_data, error)
   begin
      timer_clr      <= '0';
      done_o         <= '0';
      error_o        <= '0';
      error_en       <= '0';
      error_clr      <= '0';

      bit_count_clr  <= '0';
      bit_count_en   <= '0';

      slave_clk_o    <= '1';
      slave_data_io  <= '1';

      addr_reg_en    <= '0';
      rx_data_reg_en <= '0';
      --tx_data_reg_en <= '0';

      done_o         <= '0';

      case pres_state is
         when IDLE =>
            error_clr      <= '1';
            if(start_i = '1') then
               timer_clr      <= '1';
               bit_count_clr  <= '1';
            end if;

         when SETTLE_COUNTER =>
            slave_data_io  <= '1';
            timer_clr      <= '1';

         when START_CONDITION =>
            -- Master writes start condition to slave
            if(timer_count >= SMB_CLOCK_CYCLE) then
               timer_clr      <= '1';
               slave_data_io  <= '0';
            elsif(timer_count >= HALF_SMB_CLOCK_CYCLE) then
               -- 0 < t < SMB_CLOCK_CYCLE
               slave_data_io  <= '0';
            else
               -- 0 < t < HALF_SMB_CLOCK_CYCLE
               slave_data_io  <= '1';
            end if;

         when ADDRESS =>
            -- Master writes smb address to slave
            slave_data_io     <= addr_reg;

            if(bit_count >= SMB_ADDR_WIDTH) then
               timer_clr      <= '1';
               bit_count_clr  <= '1';
            elsif(timer_count >= SMB_CLOCK_CYCLE) then
               timer_clr      <= '1';
--               if(bit_count < SMB_ADDR_WIDTH-1) then
                  bit_count_en   <= '1';
                  addr_reg_en    <= '1';
--               end if;
            elsif(timer_count >= HALF_SMB_CLOCK_CYCLE) then
               -- 0 < t < SMB_CLOCK_CYCLE
            else
               -- 0 < t < HALF_SMB_CLOCK_CYCLE
               slave_clk_o    <= '0';
            end if;

         when nWRITE =>
            -- Master writes read/write bit to slave
            slave_data_io     <= r_nw;
            if(timer_count >= SMB_CLOCK_CYCLE) then
               timer_clr      <= '1';
            elsif(timer_count >= HALF_SMB_CLOCK_CYCLE) then
               -- 0 < t < SMB_CLOCK_CYCLE
            else
               -- 0 < t < HALF_SMB_CLOCK_CYCLE
               slave_clk_o    <= '0';
            end if;

         when ACKNOWLEDGE =>
            -- Slave writes acknowledge bit to master; slave_data_io <= 'Z'
            slave_data_io <= 'Z';

            if(timer_count >= SMB_CLOCK_CYCLE) then
               timer_clr      <= '1';
            elsif(timer_count >= HALF_SMB_CLOCK_CYCLE) then
               -- 0 < t < SMB_CLOCK_CYCLE
               error_en       <= '1';
            else
               -- 0 < t < HALF_SMB_CLOCK_CYCLE
               slave_clk_o    <= '0';
            end if;

         when DATA =>
            -- Slave reads/writes value from/to master
            if(r_nw = '1') then
               slave_data_io <= 'Z';
            else
               slave_data_io <= tx_data;
            end if;

            if(bit_count >= SMB_DATA_WIDTH) then
               timer_clr      <= '1';
               bit_count_clr  <= '1';
            elsif(timer_count >= SMB_CLOCK_CYCLE) then
               timer_clr      <= '1';
               -- Make sure that we don't over-shift the register
--               if(bit_count < SMB_DATA_WIDTH-1) then
                  bit_count_en   <= '1';
                  rx_data_reg_en <= '1';
--               end if;
            elsif(timer_count >= HALF_SMB_CLOCK_CYCLE) then
               -- 0 < t < SMB_CLOCK_CYCLE
            else
               -- 0 < t < HALF_SMB_CLOCK_CYCLE
               slave_clk_o    <= '0';
            end if;

         when ACKNOWLEDGE2 =>
            -- Slave writes acknowledge bit to master; slave_data_io <= 'Z'
            slave_data_io <= 'Z';

            if(timer_count >= SMB_CLOCK_CYCLE) then
               timer_clr      <= '1';
            elsif(timer_count >= HALF_SMB_CLOCK_CYCLE) then
               -- 0 < t < SMB_CLOCK_CYCLE
               error_en       <= '1';
            else
               -- 0 < t < HALF_SMB_CLOCK_CYCLE
               slave_clk_o    <= '0';
            end if;

         when STOP_CONDITION =>
            -- Master writes stop conditions to slave
            if(timer_count >= SMB_CLOCK_CYCLE) then
               timer_clr      <= '1';
               bit_count_clr  <= '1';
               slave_data_io  <= '1';
            elsif(timer_count >= HALF_SMB_CLOCK_CYCLE) then
               -- 0 < t < SMB_CLOCK_CYCLE
               slave_data_io  <= '1';
            else
               -- 0 < t < HALF_SMB_CLOCK_CYCLE
               slave_data_io  <= '1';
            end if;

         when DONE =>
            error_o        <= error; -- this will be changed for commands
            done_o         <= '1';

         when others =>
            NULL;

      end case;
   end process stateOut;

end behav;