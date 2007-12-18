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
-- all_test.vhd
--
-- Project:       SCUBA-2
-- Author:        Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Source code for all_test test module
--
-----------------------------------------------------------------------------
-- IMPORTANT NOTE:
--
-- To recompile for different cards, please run the corresponding tcl file
-- found in the cards/all_cards/test/synth/ directory.  The tcl files can be
-- accessed via the Tools->Tcl Scripts menu item.
--
-----------------------------------------------------------------------------
--
-- Revision history:
--
-- $Log: all_test.vhd,v $
-- Revision 1.12  2006/08/30 22:55:18  mandana
-- reformatted comment
--
-- Revision 1.11  2006/08/30 22:53:42  mandana
-- updated ports to comply with our generic bc_pin_assign.tcl in scripts directory
-- in an attempt to centralize one tcl file that gets update with board revisions.
-- pins affected are led, slot_id, rst_n, card_id, dip_sw.
-- removed easter_msg
--
-- Revision 1.10  2005/11/02 21:22:05  erniel
-- added header to file
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library components;
use components.component_pack.all;
use work.async_pack.all;
use work.ascii_pack.all;

entity all_test is
port(inclk   : in std_logic;
     rst_n   : in std_logic;

     rx      : in std_logic;
     tx      : out std_logic;

     red_led : out std_logic;
     ylw_led : out std_logic;
     grn_led : out std_logic;

     dip_sw3 : in std_logic;
     dip_sw4 : in std_logic;
     slot_id : in std_logic_vector(3 downto 0);
     card_id : inout std_logic);
end all_test;

architecture rtl of all_test is

constant RESET_MSG_LEN    : integer := 17;
constant IDLE_MSG_LEN     : integer := 10;
constant ERROR_MSG_LEN    : integer := 17;

constant DIP_SWITCH_WIDTH  : integer := 2;
constant SLOT_ID_WIDTH     : integer := 4;
constant CARD_ID_WIDTH     : integer := 8;
constant TEMPERATURE_WIDTH : integer := 4;

signal clk : std_logic;
signal rst : std_logic;

component all_test_pll
port(inclk0 : in std_logic;
     c0 : out std_logic);
end component;

type states is (RESET, TX_RESET, TX_IDLE, TX_ERROR, RX_CMD1, RX_CMD2, TOGGLE_LED, READ_DIP, TX_DIP, READ_SLOT, TX_SLOT, READ_ID, TX_ID, READ_TEMP, TX_TEMP);
signal pres_state : states;
signal next_state : states;

signal rx_data : std_logic_vector(7 downto 0);
signal rx_ack  : std_logic;
signal rx_rdy  : std_logic;

signal tx_data : std_logic_vector(7 downto 0);
signal tx_rdy  : std_logic;
signal tx_busy : std_logic;

signal tx_count : integer range 0 to 70;
signal tx_count_ena : std_logic;
signal tx_count_clr : std_logic;

signal reset_msg  : std_logic_vector(7 downto 0);
signal idle_msg   : std_logic_vector(7 downto 0);
signal error_msg  : std_logic_vector(7 downto 0);

signal cmd1    : std_logic_vector(7 downto 0);
signal cmd2    : std_logic_vector(7 downto 0);
signal cmd1_ld : std_logic;
signal cmd2_ld : std_logic;

signal led0     : std_logic;
signal led1     : std_logic;
signal led2     : std_logic;
signal led0_ena : std_logic;
signal led1_ena : std_logic;
signal led2_ena : std_logic;

component dip_switch_test_wrapper
port(-- basic signals
     rst_i     : in std_logic;    -- reset input
     clk_i     : in std_logic;    -- clock input
     en_i      : in std_logic;    -- enable signal
     done_o    : out std_logic;   -- done ouput signal

     -- transmitter signals
     data_o    : out std_logic_vector(1 downto 0);

     -- extended signals
     dip_switch_i : in std_logic_vector (1 downto 0)); -- physical dip switch pin
end component;

signal dip_test_ena  : std_logic;
signal dip_test_done : std_logic;
signal dip_test_data : std_logic_vector(1 downto 0);
signal dip_reg_ena   : std_logic;
signal dip_reg_ld    : std_logic;
signal dip_reg_data  : std_logic;
signal dip           : std_logic_vector(1 downto 0);

component slot_id_test_wrapper
generic ( SLOT_ID_BITS: integer := 4);
port(-- basic signals
     rst_i     : in std_logic;    -- reset input
     clk_i     : in std_logic;    -- clock input
     en_i      : in std_logic;    -- enable signal
     done_o    : out std_logic;   -- done ouput signal

     -- transmitter signals
     data_o    : out std_logic_vector(3 downto 0);

     -- extended signals
     slot_id_i : in std_logic_vector (3 downto 0)); -- physical slot_id pin
end component;

signal slot_test_ena  : std_logic;
signal slot_test_done : std_logic;
signal slot_test_data : std_logic_vector(3 downto 0);
signal slot_reg_data  : std_logic;
signal slot_reg_ena   : std_logic;
signal slot_reg_ld    : std_logic;

component id_thermo_test_wrapper
port(-- basic signals
     rst_i     : in std_logic;    -- reset input
     clk_i     : in std_logic;    -- clock input

     id_en_i   : in std_logic;    -- ID enable signal
     temp_en_i : in std_logic;    -- temperature enable signal

     done_o    : out std_logic;   -- ID done output signal

     -- transmitter signals
     data_o    : out std_logic_vector(31 downto 0);

     -- extended signals
     id_thermo_io : inout std_logic); -- physical pin
end component;

signal id_test_ena : std_logic;
signal temp_test_ena : std_logic;
signal id_thermo_test_done : std_logic;
signal id_thermo_test_data : std_logic_vector(31 downto 0);

signal id_reg_data : std_logic_vector(31 downto 0);
signal id_reg_ena : std_logic;
signal id_reg_ld : std_logic;

signal temp_reg_data : std_logic_vector(15 downto 0);
signal temp_reg_ena : std_logic;
signal temp_reg_ld : std_logic;

signal rst_cmd : std_logic;

begin

   rst <= not rst_n or rst_cmd;

   clk0: all_test_pll
   port map(inclk0 => inclk,
            c0 => clk);


   --------------------------------------------------------
   -- RS-232 blocks
   --------------------------------------------------------

   rx0: rs232_rx
   port map(clk_i   => clk,
            rst_i   => rst,
            dat_o   => rx_data,
            rdy_o   => rx_rdy,
            ack_i   => rx_ack,
            rs232_i => rx);

   tx0: rs232_tx
   port map(clk_i   => clk,
            rst_i   => rst,
            dat_i   => tx_data,
            rdy_i   => tx_rdy,
            busy_o  => tx_busy,
            rs232_o => tx);


   --------------------------------------------------------
   -- Command character storage
   --------------------------------------------------------

   cmdchar1 : reg
   generic map(WIDTH => 8)
   port map(clk_i  => clk,
            rst_i  => rst,
            ena_i  => cmd1_ld,
            reg_i  => rx_data,
            reg_o  => cmd1);

   cmdchar2 : reg
   generic map(WIDTH => 8)
   port map(clk_i  => clk,
            rst_i  => rst,
            ena_i  => cmd2_ld,
            reg_i  => rx_data,
            reg_o  => cmd2);


   --------------------------------------------------------
   -- Message logic
   --------------------------------------------------------

   tx_char_counter: counter
   generic map(MAX => 70,
               WRAP_AROUND => '0')
   port map(clk_i   => clk,
            rst_i   => rst,
            ena_i   => tx_count_ena,
            load_i  => tx_count_clr,
            count_i => 0,
            count_o => tx_count);

   -- print out the version message
   with tx_count select
      reset_msg <= newline   when 0,
                   newline   when 1,
                   shift(a)  when 2,
                   l         when 3,
                   l         when 4,
                   space     when 5,
                   shift(t)  when 6,
                   e         when 7,
                   s         when 8,
                   t         when 9,
                   space     when 10,
                   v         when 11,
                   period    when 12,
                   four      when 13, -- v4.1 test firmware
                   period    when 14,
                   one       when 15,
                   newline   when others;

   with tx_count select
      idle_msg <= newline      when 0,
                  shift(c)     when 1,
                  o            when 2,
                  m            when 3,
                  m            when 4,
                  a            when 5,
                  n            when 6,
                  d            when 7,
                  shift(slash) when 8,
                  space        when others;

   with tx_count select
      error_msg <= tab         when 0,
                   shift(i)    when 1,
                   n           when 2,
                   v           when 3,
                   a           when 4,
                   l           when 5,
                   i           when 6,
                   d           when 7,
                   space       when 8,
                   c           when 9,
                   o           when 10,
                   m           when 11,
                   m           when 12,
                   a           when 13,
                   n           when 14,
                   d           when 15,
                   space       when others;

   --------------------------------------------------------
   -- Control logic
   --------------------------------------------------------

   process(clk, rst)
   begin
      if(rst_n = '0') then
         pres_state <= RESET;
      elsif(clk = '1' and clk'event) then
         pres_state <= next_state;
      end if;
   end process;

   process(pres_state, rx_rdy, rx_data, tx_count, dip_test_done, slot_test_done, id_thermo_test_done)
   begin
      next_state <= pres_state;

      case pres_state is
         when RESET =>      next_state <= TX_RESET;

         when TX_RESET =>   if(tx_count = RESET_MSG_LEN - 1) then
                               next_state <= TX_IDLE;
                            else
                               next_state <= TX_RESET;
                            end if;

         when TX_IDLE =>    if(tx_count = IDLE_MSG_LEN - 1) then
                               next_state <= RX_CMD1;
                            else
                               next_state <= TX_IDLE;
                            end if;

         when TX_ERROR =>   if(tx_count = ERROR_MSG_LEN - 1) then
                               next_state <= TX_IDLE;
                            else
                               next_state <= TX_ERROR;
                            end if;

         when RX_CMD1 =>    if(rx_rdy = '1') then
                               case rx_data is
                                  when d | shift(d) => next_state <= READ_DIP;
                                  when l | shift(l) => next_state <= RX_CMD2;
                                  when s | shift(s) => next_state <= READ_SLOT;
                                  when c | shift(c) => next_state <= READ_ID;
                                  when t | shift(t) => next_state <= READ_TEMP;
                                  when escape =>       next_state <= RESET;
                                  when others =>       next_state <= TX_ERROR;
                               end case;
                            else
                               next_state <= RX_CMD1;
                            end if;

         when RX_CMD2 =>    if(rx_rdy = '1') then
                               case rx_data is
                                  when one | two | three => next_state <= TOGGLE_LED;
                                  when escape =>            next_state <= RESET;
                                  when others =>            next_state <= TX_ERROR;
                               end case;
                            else
                               next_state <= RX_CMD2;
                            end if;

         when TOGGLE_LED => next_state <= TX_IDLE;

         when READ_DIP =>   if(dip_test_done = '1') then
                               next_state <= TX_DIP;
                            else
                               next_state <= READ_DIP;
                            end if;

         when TX_DIP =>     if(tx_count = DIP_SWITCH_WIDTH - 1) then
                               next_state <= TX_IDLE;
                            else
                               next_state <= TX_DIP;
                            end if;

         when READ_SLOT =>  if(slot_test_done = '1') then
                               next_state <= TX_SLOT;
                            else
                               next_state <= READ_SLOT;
                            end if;

         when TX_SLOT =>    if(tx_count = SLOT_ID_WIDTH - 1) then
                               next_state <= TX_IDLE;
                            else
                               next_state <= TX_SLOT;
                            end if;


         when READ_ID =>    if(id_thermo_test_done = '1') then
                               next_state <= TX_ID;
                            else
                               next_state <= READ_ID;
                            end if;

         when TX_ID =>      if(tx_count = CARD_ID_WIDTH - 1) then
                               next_state <= TX_IDLE;
                            else
                               next_state <= TX_ID;
                            end if;

         when READ_TEMP =>  if(id_thermo_test_done = '1') then
                               next_state <= TX_TEMP;
                            else
                               next_state <= READ_TEMP;
                            end if;

         when TX_TEMP =>    if(tx_count = TEMPERATURE_WIDTH - 1) then
                               next_state <= TX_IDLE;
                            else
                               next_state <= TX_TEMP;
                            end if;

         when others =>     next_state <= TX_IDLE;

      end case;
   end process;

   process(pres_state, tx_busy, tx_count, reset_msg, idle_msg, error_msg, cmd2, dip_reg_data, slot_reg_data, id_reg_data, temp_reg_data)
   begin
      rx_ack       <= '0';
      tx_rdy       <= '0';
      tx_data      <= (others => '0');
      tx_count_ena <= '0';
      tx_count_clr <= '0';
      cmd1_ld      <= '0';
      cmd2_ld      <= '0';
      led0_ena     <= '0';
      led1_ena     <= '0';
      led2_ena     <= '0';
      dip_test_ena <= '0';
      dip_reg_ena  <= '0';
      dip_reg_ld   <= '0';
      slot_test_ena <= '0';
      slot_reg_ena <= '0';
      slot_reg_ld  <= '0';

      id_test_ena  <= '0';
      id_reg_ena <= '0';
      id_reg_ld <= '0';

      temp_test_ena <= '0';
      temp_reg_ena <= '0';
      temp_reg_ld <= '0';

      rst_cmd      <= '0';

      case pres_state is
         when RESET =>      tx_count_ena <= '1';
                            tx_count_clr <= '1';
                            rst_cmd      <= '1';

         when TX_RESET =>   if(tx_busy = '0') then
                               tx_rdy       <= '1';
                               tx_count_ena <= '1';
                            end if;
                            if(tx_count = RESET_MSG_LEN - 1) then
                               tx_count_ena <= '1';
                               tx_count_clr <= '1';
                            end if;
                            tx_data <= reset_msg;

         when TX_IDLE =>    if(tx_busy = '0') then
                               tx_rdy       <= '1';
                               tx_count_ena <= '1';
                            end if;
                            if(tx_count = IDLE_MSG_LEN - 1) then
                               tx_count_ena <= '1';
                               tx_count_clr <= '1';
                            end if;
                            tx_data <= idle_msg;

         when TX_ERROR =>   if(tx_busy = '0') then
                               tx_rdy       <= '1';
                               tx_count_ena <= '1';
                            end if;
                            if(tx_count = ERROR_MSG_LEN - 1) then
                               tx_count_ena <= '1';
                               tx_count_clr <= '1';
                            end if;
                            tx_data <= error_msg;

         when RX_CMD1 =>    rx_ack       <= '1';
                            tx_count_ena <= '1';
                            tx_count_clr <= '1';
                            cmd1_ld      <= '1';

         when RX_CMD2 =>    rx_ack       <= '1';
                            tx_count_ena <= '1';
                            tx_count_clr <= '1';
                            cmd2_ld      <= '1';

         when TOGGLE_LED => case cmd2 is
                               when one =>    led0_ena <= '1';
                               when two =>    led1_ena <= '1';
                               when three =>  led2_ena <= '1';
                               when others => null;
                            end case;

         when READ_DIP =>   dip_test_ena <= '1';
                            dip_reg_ena  <= '1';
                            dip_reg_ld   <= '1';
                            tx_count_ena <= '1';
                            tx_count_clr <= '1';

         when TX_DIP =>     if(tx_busy = '0') then
                               tx_rdy       <= '1';
                               dip_reg_ena  <= '1';
                               tx_count_ena <= '1';
                            end if;
                            if(tx_count = DIP_SWITCH_WIDTH - 1) then
                               tx_count_ena <= '1';
                               tx_count_clr <= '1';
                            end if;
                            tx_data <= bin2asc(dip_reg_data);

         when READ_SLOT =>  slot_test_ena <= '1';
                            slot_reg_ena <= '1';
                            slot_reg_ld  <= '1';
                            tx_count_ena <= '1';
                            tx_count_clr <= '1';

         when TX_SLOT =>    if(tx_busy = '0') then
                               tx_rdy       <= '1';
                               slot_reg_ena <= '1';
                               tx_count_ena <= '1';
                            end if;
                            if(tx_count = SLOT_ID_WIDTH - 1) then
                               tx_count_ena <= '1';
                               tx_count_clr <= '1';
                            end if;
                            tx_data <= bin2asc(slot_reg_data);

         when READ_ID =>    id_test_ena <= '1';
                            id_reg_ena <= '1';
                            id_reg_ld <= '1';
                            tx_count_ena <= '1';
                            tx_count_clr <= '1';

         when TX_ID =>      if(tx_busy = '0') then
                               tx_rdy       <= '1';
                               id_reg_ena   <= '1';
                               tx_count_ena <= '1';
                            end if;
                            if(tx_count = CARD_ID_WIDTH - 1) then
                               tx_count_ena <= '1';
                               tx_count_clr <= '1';
                            end if;
                            tx_data <= hex2asc(id_reg_data(31 downto 28));

         when READ_TEMP =>  temp_test_ena <= '1';
                            temp_reg_ena <= '1';
                            temp_reg_ld <= '1';
                            tx_count_ena <= '1';
                            tx_count_clr <= '1';

         when TX_TEMP =>    if(tx_busy = '0') then
                               tx_rdy       <= '1';
                               temp_reg_ena   <= '1';
                               tx_count_ena <= '1';
                            end if;
                            if(tx_count = TEMPERATURE_WIDTH - 1) then
                               tx_count_ena <= '1';
                               tx_count_clr <= '1';
                            end if;
                            tx_data <= hex2asc(temp_reg_data(15 downto 12));

         when others =>     null;

      end case;
   end process;


   --------------------------------------------------------
   --- LED block
   --------------------------------------------------------

   process(clk, rst)
   begin
      if(rst = '1') then
         led0 <= '0';
         led1 <= '0';
         led2 <= '0';
      elsif(clk'event and clk = '1') then
         if(led0_ena = '1') then
            led0 <= not led0;
         elsif(led1_ena = '1') then
            led1 <= not led1;
         elsif(led2_ena = '1') then
            led2 <= not led2;
         end if;
      end if;
   end process;

   red_led <= led0;
   ylw_led <= led1;
   grn_led <= led2;


   --------------------------------------------------------
   -- DIP Switch block
   --------------------------------------------------------
   dip <= dip_sw3 & dip_sw4;
   dip_test : dip_switch_test_wrapper
   port map(clk_i => clk,
            rst_i => rst,
            en_i  => dip_test_ena,
            done_o => dip_test_done,
            data_o => dip_test_data,
            dip_switch_i => dip);

   dip_reg : shift_reg
   generic map(WIDTH => DIP_SWITCH_WIDTH)
   port map(clk_i      => clk,
            rst_i      => rst,
            ena_i      => dip_reg_ena,
            load_i     => dip_reg_ld,
            clr_i      => '0',
            shr_i      => '0',
            serial_i   => '0',
            serial_o   => dip_reg_data,
            parallel_i => dip_test_data,
            parallel_o => open);


   --------------------------------------------------------
   -- Slot ID block
   --------------------------------------------------------

   slot_test : slot_id_test_wrapper
   port map(clk_i => clk,
            rst_i => rst,
            en_i => slot_test_ena,
            done_o => slot_test_done,
            data_o => slot_test_data,
            slot_id_i => slot_id);

   slot_reg : shift_reg
   generic map(WIDTH => SLOT_ID_WIDTH)
   port map(clk_i      => clk,
            rst_i      => rst,
            ena_i      => slot_reg_ena,
            load_i     => slot_reg_ld,
            clr_i      => '0',
            shr_i      => '0',
            serial_i   => '0',
            serial_o   => slot_reg_data,
            parallel_i => slot_test_data,
            parallel_o => open);


   --------------------------------------------------------
   -- Card ID / Temperature block
   --------------------------------------------------------

   id_thermo_test : id_thermo_test_wrapper
   port map(clk_i => clk,
            rst_i => rst,
            id_en_i => id_test_ena,
            temp_en_i => temp_test_ena,
            done_o => id_thermo_test_done,
            data_o => id_thermo_test_data,
            id_thermo_io => card_id);

   -- shift out id data as hexadecimal (4 bits at a time)
   -- process implements a shift-by-4 shift register:
   -- ID data is 32-bit.
   process(clk, rst)
   begin
      if(rst = '1') then
         id_reg_data <= (others => '0');
      elsif(clk = '1' and clk'event) then
         if(id_reg_ena = '1') then
            if(id_reg_ld = '1') then
               id_reg_data <= id_thermo_test_data;
            else
               id_reg_data <= id_reg_data(27 downto 0) & "0000";
            end if;
         end if;
      end if;
   end process;

   -- shift data out as hexadecimal (4 bits at a time)
   -- process implements a shift-by-4 shift register:
   -- temperature data is 16 bit.
   process(clk, rst)
   begin
      if(rst = '1') then
         temp_reg_data <= (others => '0');
      elsif(clk = '1' and clk'event) then
         if(temp_reg_ena = '1') then
            if(temp_reg_ld = '1') then
               temp_reg_data <= id_thermo_test_data(16 downto 1);  -- truncate LSB
            else
               temp_reg_data <= temp_reg_data(11 downto 0) & "0000";
            end if;
         end if;
      end if;
   end process;

end rtl;