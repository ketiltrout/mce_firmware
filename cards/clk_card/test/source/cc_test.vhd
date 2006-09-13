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
-- cc_test.vhd
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Test module for clock card
--
-- Revision history:
-- 
-- $Log: cc_test.vhd,v $
-- Revision 1.5  2006/09/08 22:13:07  mandana
-- updated to latest cc_test communication
--
-- Revision 1.4  2004/07/02 17:37:46  mandana
-- Mandana: walking 0/1 tests combined
--
-- Revision 1.3  2004/06/09 22:13:38  erniel
-- initial version
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library components;
use components.component_pack.all;

library work;
use work.ascii_pack.all;
use work.async_pack.all;
use work.cc_test_pack.all;

entity cc_test is
   port(
      rst_n      : in std_logic;
      
      -- clock signals
      inclk14    : in std_logic;
      outclk     : out std_logic;
      
      -- RS232 interface
      tx         : out std_logic;
      rx         : in std_logic;
      
      -- box id interface
      box_id_in  : in std_logic;
      box_id_out : out std_logic;
      box_id_ena : out std_logic;
            
      -- array id interface
      array_id   : in std_logic_vector(2 downto 0);
      
      -- power status pins
      nplus7vok  : in std_logic;
      
      -- LVDS interfaces
      lvds_clk   : out std_logic;
      lvds_cmd   : out std_logic;
      lvds_sync  : out std_logic;
      lvds_spare : out std_logic;

      lvds_rx0a  : in std_logic;
      lvds_rx0b  : in std_logic;
      lvds_rx1a  : in std_logic;
      lvds_rx1b  : in std_logic;
      lvds_rx2a  : in std_logic;
      lvds_rx2b  : in std_logic;
      lvds_rx3a  : in std_logic;
      lvds_rx3b  : in std_logic;
      lvds_rx4a  : in std_logic;
      lvds_rx4b  : in std_logic;
      lvds_rx5a  : in std_logic;
      lvds_rx5b  : in std_logic;
      lvds_rx6a  : in std_logic;
      lvds_rx6b  : in std_logic;      
      lvds_rx7a  : in std_logic;
      lvds_rx7b  : in std_logic;
      
      -- SRAM bank 1 interface
      sram0_addr : out std_logic_vector(19 downto 0);
      sram0_data : inout std_logic_vector(15 downto 0);
      sram0_nbhe : out std_logic;
      sram0_nble : out std_logic;
      sram0_noe  : out std_logic;
      sram0_nwe  : out std_logic;
      sram0_nce1 : out std_logic;
      sram0_ce2  : out std_logic;
      
      -- SRAM bank 1 interface
      sram1_addr : out std_logic_vector(19 downto 0);
      sram1_data : inout std_logic_vector(15 downto 0);
      sram1_nbhe : out std_logic;
      sram1_nble : out std_logic;
      sram1_noe  : out std_logic;
      sram1_nwe  : out std_logic;
      sram1_nce1 : out std_logic;
      sram1_ce2  : out std_logic;
      
      -- EEPROM interface
      eeprom_si  : in std_logic;
      eeprom_so  : out std_logic;
      eeprom_sck : out std_logic;
      eeprom_cs  : out std_logic;
      
      -- Fibre interface
      -- fibre pins
      fibre_tx_data   : out std_logic_vector(7 downto 0);
      fibre_tx_clkW   : out std_logic;
      fibre_tx_ena    : out std_logic;
      fibre_tx_rp     : in std_logic;
      fibre_tx_sc_nd  : out std_logic;
      fibre_tx_enn    : out std_logic;
      -- fibre_tx_svs is tied to gnd on board
      -- fibre_tx_enn is tied to vcc on board
      -- fibre_tx_mode is tied to gnd on board
      fibre_tx_foto   : out std_logic;
      fibre_tx_bisten : out std_logic;
      
      fibre_rx_data   : in std_logic_vector(7 downto 0);
      fibre_rx_clkr   : in std_logic;
      fibre_rx_refclk : out std_logic;
      fibre_rx_error  : in std_logic;
      fibre_rx_rdy    : in std_logic;
      fibre_rx_status : in std_logic;
      fibre_rx_sc_nd  : in std_logic;
      fibre_rx_rvs    : in std_logic;
      fibre_rx_rf     : out std_logic; --  is tied to vcc on board, we lifted the pin and routed it to P10.22
      fibre_rx_a_nb   : out std_logic;
      fibre_rx_bisten : out std_logic;
      
      -- DV interface:
      dv_pulse_fibre    : in std_logic;
      manchester_data   : in std_logic;
      manchester_sigdet : in std_logic;
      
      mictor0_o       : out std_logic_vector(15 downto 0)
   );   
      
end cc_test;

architecture behaviour of cc_test is
   
constant RESET_MSG_LEN    : integer := 16;
constant IDLE_MSG_LEN     : integer := 10;
constant ERROR_MSG_LEN    : integer := 8;  
constant RAMP_OFF_MSG_LEN : integer := 22;
constant RESULT_MSG_LEN   : integer := 6;

constant STATUS_WIDTH     : integer := 1;
constant ARRAY_ID_WIDTH   : integer := 3;

signal clk  : std_logic;
signal clk_n: std_logic;
signal rst  : std_logic;

type states is (RESET, TX_RESET, TX_IDLE, TX_ERROR, RX_CMD1, RX_CMD2, 
                FO_TEST, TX_FO, SRAM0_TEST, TX_SRAM0, SRAM1_TEST, TX_SRAM1, 
                ARRAY_ID_TEST, TX_ARRAY_ID, STATUS_TEST, TX_STATUS,
                DV_TEST, TX_DV);
signal pres_state : states;
signal next_state : states;

signal tx_data : std_logic_vector(7 downto 0);
signal tx_rdy  : std_logic;
signal tx_busy : std_logic;

signal rx_data : std_logic_vector(7 downto 0);
signal rx_ack  : std_logic;
signal rx_rdy  : std_logic;

signal tx_count : integer range 0 to 70;
signal tx_count_ena : std_logic;
signal tx_count_clr : std_logic;

signal reset_msg  : std_logic_vector(7 downto 0);
signal idle_msg   : std_logic_vector(7 downto 0);
signal error_msg  : std_logic_vector(7 downto 0);
signal pass_msg   : std_logic_vector(7 downto 0);
signal fail_msg   : std_logic_vector(7 downto 0);

signal cmd1    : std_logic_vector(7 downto 0);
signal cmd2    : std_logic_vector(7 downto 0);
signal cmd1_ld : std_logic;
signal cmd2_ld : std_logic;

signal rst_cmd : std_logic;   

   signal status_ena         : std_logic;
   signal status_done        : std_logic;
   signal status             : std_logic;

   signal array_id_ena       : std_logic;
   signal array_id_done      : std_logic;
   signal array_id_reg       : std_logic;
   signal array_id_reg_ena   : std_logic;
   signal array_id_reg_ld    : std_logic;

   signal sram0_ena          : std_logic;
   signal sram0_done         : std_logic;
   signal pass0              : std_logic;
   signal fail0              : std_logic;
   signal pass0_reg          : std_logic;
   signal fail0_reg          : std_logic;
   signal sram0_fault        : integer range 0 to 20;
   
   signal sram1_ena          : std_logic;
   signal sram1_done         : std_logic;
   signal pass1              : std_logic;
   signal fail1              : std_logic;
   signal pass1_reg          : std_logic;
   signal fail1_reg          : std_logic;
   signal sram1_fault        : integer range 0 to 20;
   
   signal fo_test_ena        : std_logic;
   signal fo_test_done       : std_logic;
   signal rx_data1           : std_logic_vector(7 downto 0);
   signal rx_data2           : std_logic_vector(7 downto 0);
   signal rx_data3           : std_logic_vector(7 downto 0);
   signal fo_data_ascii      : std_logic_vector(7 downto 0);
  
   signal fibre_clk          : std_logic;
   
   signal dv_test_ena        : std_logic;
   signal dv_test_done       : std_logic;
   signal manch_data         : std_logic_vector(MANCH_WIDTH -1 downto 0);
   signal manch_data_ascii   : std_logic_vector(7 downto 0);
   
   
   -- pll output allocation:
   --    c0 = FPGA system clock (50MHz)
   --    c1 = 180deg phase shift of system clock (50MHz)
   --    c2 = Asynchronous Transfer clock (100MHz)
   --    c3 = fibre clock (25MHz)
   --    e0 = fibre transmit clock
   --    e1 = fibre rx refclk
   --    e2 = Backplane lvds clock
   
begin
   rst <= not rst_n or rst_cmd;

   clk0: cc_test_pll
   port map(
            inclk0 => inclk14,
            c0     => clk,
            c1     => clk_n,
            c2     => open,
            c3     => fibre_clk,
            e0     => fibre_tx_clkw, 
            e1     => fibre_rx_refclk,   
            e2     => lvds_clk 
         );


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

   
   with tx_count select 
      -- reset message is BC Test v2.0
      reset_msg <= newline   when 0,
                   newline   when 1,
                   shift(c)  when 2,
                   shift(c)  when 3,
                   space     when 4,
                   shift(t)  when 5,
                   e         when 6,
                   s         when 7,
                   t         when 8,
                   space     when 9,
                   v         when 10, -- text for version number 2.1
                   period    when 11, 
                   two       when 12, 
                   period    when 13,
                   one       when 14,
                   newline   when others;

   with tx_count select
      -- idle message is Command? 
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
      -- error message is error 
      error_msg <= tab         when 0,
                   e           when 1,
                   r           when 2,
                   r           when 3,
                   o           when 4,
                   r           when 5,
                   space       when 6,
                   newline  when others;

   with tx_count select
      -- power status read backs correct values, prints pass message
      pass_msg  <= tab         when 0,
                   shift(p)    when 1,
                   a           when 2,
                   s           when 3,
                   s           when 4,
                   shift(one)  when 5,
                   newline  when others;

   with tx_count select
      -- power status read backs wrong values, prints fail message
      fail_msg  <= tab         when 0,
                   shift(F)    when 1,
                   a           when 2,
                   i           when 3,
                   l           when 4,
                   shift(one)  when 5,
                   newline  when others;
                   
   with tx_count select
      fo_data_ascii <= tab when 0,
                 hex2asc(rx_data1(3 downto 0)) when 1,
                 hex2asc(rx_data1(7 downto 4)) when 2,
                 hex2asc(rx_data2(3 downto 0)) when 3,
                 hex2asc(rx_data2(7 downto 4)) when 4,
                 hex2asc(rx_data3(3 downto 0)) when 5,
                 hex2asc(rx_data3(7 downto 4)) when 6,
                 newline when others;

   with tx_count select
      manch_data_ascii <= tab when 0,
                 hex2asc(manch_data(3 downto 0)) when 1,
                 hex2asc(manch_data(7 downto 4)) when 2,
                 hex2asc(manch_data(11 downto 8)) when 3,
                 hex2asc(manch_data(15 downto 12)) when 4,
                 hex2asc(manch_data(19 downto 16)) when 5,
                 hex2asc(manch_data(23 downto 20)) when 6,
                 newline when others;
   
   --------------------------------------------------------
   -- Overall test Control logic
   --------------------------------------------------------

   process(clk, rst_n)
   begin
      if(rst_n = '0') then
         pres_state <= RESET;
      elsif(clk = '1' and clk'event) then
         pres_state <= next_state;
      end if;
   end process;

   process(pres_state, rx_rdy, rx_data, tx_count, array_id_done, status_done, sram0_done, sram1_done, fo_test_done)
   begin
      next_state <= pres_state;
      case pres_state is
         when RESET =>          next_state <= TX_RESET;

         when TX_RESET =>       if(tx_count = RESET_MSG_LEN - 1) then
                                   next_state <= TX_IDLE;
                                else
                                   next_state <= TX_RESET;
                                end if;

         when TX_IDLE =>        if(tx_count = IDLE_MSG_LEN - 1) then
                                   next_state <= RX_CMD1;
                                else
                                   next_state <= TX_IDLE;
                                end if;

         when TX_ERROR =>       if(tx_count = ERROR_MSG_LEN - 1) then
                                   next_state <= TX_IDLE;
                                else
                                   next_state <= TX_ERROR;
                                end if;

         when RX_CMD1 =>        if(rx_rdy = '1') then
                                   case rx_data is
                                      when a | shift(a) => next_state <= ARRAY_ID_TEST;
                                      when r | shift(r) => next_state <= RX_CMD2;
                                      when f | shift(f) => next_state <= FO_TEST;
                                      when s | shift(s) => next_state <= STATUS_TEST;
                                      when v | shift(v) => next_state <= DV_TEST;
                                      when escape =>       next_state <= RESET;
                                      when others =>       next_state <= TX_ERROR;
                                   end case;
                                else
                                   next_state <= RX_CMD1;
                                end if;

         when RX_CMD2 =>        if(rx_rdy = '1') then
                                   case rx_data is
                                      when zero         => next_state <= SRAM0_TEST;
                                      when one          => next_state <= SRAM1_TEST;
                                      when escape       => next_state <= RESET;
                                      when others       => next_state <= TX_ERROR;
                                   end case;
                                else
                                   next_state <= RX_CMD2;
                                end if;
         
         when ARRAY_ID_TEST =>  if(array_id_done = '1') then
                                   next_state <= TX_ARRAY_ID;
                                else
                                   next_state <= ARRAY_ID_TEST;
                                end if;

         when TX_ARRAY_ID =>    if(tx_count = ARRAY_ID_WIDTH - 1) then
                                   next_state <= TX_IDLE;
                                else
                                   next_state <= TX_ARRAY_ID;
                                end if;
         
         when STATUS_TEST    =>   if(status_done = '1') then
                                     next_state <= TX_STATUS;
                                  else
                                     next_state <= STATUS_TEST;
                                  end if;
         
         when TX_STATUS      =>   if(tx_count = RESULT_MSG_LEN - 1) then
                                     next_state <= TX_IDLE;
                                  else
                                     next_state <= TX_STATUS;
                                  end if;
         
         when SRAM0_TEST     =>   if (sram0_done = '1') then
                                     next_state <= TX_SRAM0;
                                  else
                                     next_state <= SRAM0_TEST;
                                  end if;
                                  
         when TX_SRAM0       =>   if (tx_count = RESULT_MSG_LEN - 1) then
                                     next_state <= TX_IDLE;
                                  else
                                     next_state <= TX_SRAM0;
                                  end if;   
         
         when SRAM1_TEST     =>   if (sram1_done = '1') then
                                     next_state <= TX_SRAM1;
                                  else
                                     next_state <= SRAM1_TEST;
                                  end if;
                                  
         when TX_SRAM1       =>   if (tx_count = RESULT_MSG_LEN - 1) then
                                     next_state <= TX_IDLE;
                                  else
                                     next_state <= TX_SRAM1;
                                  end if;   
         
         when FO_TEST        =>   if (fo_test_done = '1') then 
                                     next_state <= TX_FO;
                                  else
                                     next_state <= FO_TEST;
                                  end if;   
         when TX_FO          =>   if (tx_count = 6) then
                                     next_state <= TX_IDLE;
                                  else
                                     next_state <= TX_FO;
                                  end if;                                   
         
         when DV_TEST        =>   if (dv_test_done = '1') then
                                     next_state <= TX_DV;                                  
                                  else
                                     next_state <= DV_TEST;
                                  end if; 
                                  
         when TX_DV          =>   if (tx_count =  6) then
                                     next_state <= TX_IDLE;
                                  else 
                                     next_state <= TX_DV;
                                  end if;                                  

         when others         =>   next_state <= TX_IDLE;

      end case;
   end process;

   process(pres_state, tx_busy, tx_count, reset_msg, idle_msg, error_msg, pass_msg, fail_msg, 
           array_id_reg, status, pass0, fail0, pass1, fail1)
   begin
      rx_ack        <= '0';
      tx_rdy        <= '0';
      tx_data       <= (others => '0');
      tx_count_ena  <= '0';
      tx_count_clr  <= '0';
      cmd1_ld       <= '0';
      cmd2_ld       <= '0';
      
      rst_cmd       <= '0';
      sram0_ena     <= '0';
      sram1_ena     <= '0';
      fo_test_ena   <= '0';
      status_ena    <= '0';
      array_id_ena  <= '0';
      array_id_reg_ld <= '0';
      array_id_reg_ena<= '0';
      
      sram0_ena     <= '0';
      sram1_ena     <= '0';
      fo_test_ena   <= '0';
      dv_test_ena   <= '0';

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

         when ARRAY_ID_TEST =>
                            array_id_ena <= '1';
                            array_id_reg_ena <= '1';
                            array_id_reg_ld  <= '1';
                            tx_count_ena <= '1';
                            tx_count_clr <= '1';

         when TX_ARRAY_ID =>    
                            if(tx_busy = '0') then
                               tx_rdy       <= '1';
                               array_id_reg_ena <= '1';
                               tx_count_ena <= '1';
                            end if;
                            if(tx_count = ARRAY_ID_WIDTH - 1) then
                               tx_count_ena <= '1';
                               tx_count_clr <= '1';
                            end if;
                            tx_data <= bin2asc(array_id_reg);
         
         when STATUS_TEST => status_ena      <= '1';
                             --status_reg_ena  <= '1';
                             --status_reg_ld   <= '1';
                             tx_count_ena    <= '1';
                             tx_count_clr    <= '1';

         when TX_STATUS =>  if(tx_busy = '0') then
                               tx_rdy          <= '1';
                               tx_count_ena    <= '1';
                            end if;
                            if(tx_count = RESULT_MSG_LEN - 1) then
                               tx_count_ena <= '1';
                               tx_count_clr <= '1';
                            end if;
                            if (status = '0') then                              
                               tx_data <= pass_msg;
                            else
                               tx_data <= fail_msg;
                            end if;   
                            
         when SRAM0_TEST => sram0_ena <= '1';                            
                            tx_count_ena <= '1';
                            tx_count_clr <= '1';
         
         when TX_SRAM0 =>  if(tx_busy = '0') then
                               tx_rdy          <= '1';
                               tx_count_ena    <= '1';
                            end if;
                            if(tx_count = RESULT_MSG_LEN - 1) then
                               tx_count_ena <= '1';
                               tx_count_clr <= '1';
                            end if;
                            if (pass0_reg = '1' and fail0_reg = '0') then                              
                               tx_data <= pass_msg;
                            else
                               tx_data <= fail_msg;
                            end if;   
         
         when SRAM1_TEST => sram1_ena <= '1';
                            tx_count_ena <= '1';
                            tx_count_clr <= '1';
                            
         when TX_SRAM1 =>  if(tx_busy = '0') then
                               tx_rdy          <= '1';
                               tx_count_ena    <= '1';
                            end if;
                            if(tx_count = RESULT_MSG_LEN - 1) then
                               tx_count_ena <= '1';
                               tx_count_clr <= '1';
                            end if;
                            if (pass1_reg = '1' and fail1_reg = '0') then                              
                               tx_data <= pass_msg;
                            else
                               tx_data <= fail_msg;
                            end if;   
         
         when FO_TEST =>    fo_test_ena  <= '1';
                            tx_count_ena <= '1';
                            tx_count_clr <= '1';      
                            
         when TX_FO  =>     if(tx_busy = '0') then
                               tx_rdy          <= '1';
                               tx_count_ena    <= '1';
                            end if;
                            if(tx_count = 6) then
                               tx_count_ena <= '1';
                               tx_count_clr <= '1';
                            end if;
                            tx_data <= fo_data_ascii;
         
         when DV_TEST =>    dv_test_ena <= '1';
                            tx_count_ena    <= '1';
                            tx_count_clr    <= '1';
         
         when TX_DV  =>     if(tx_busy = '0') then
                               tx_rdy          <= '1';
                               tx_count_ena    <= '1';
                            end if;
                            if(tx_count =  6) then
                               tx_count_ena <= '1';
                               tx_count_clr <= '1';
                            end if;
                            tx_data <= manch_data_ascii;
                            
         when others =>     null;

      end case;
   end process;
   
   -------------------------------------------------------
   --
   -- Different test instantiations
   --
   -------------------------------------------------------     
   
   -- status test , to expand status to include more information, append them to status and register them,
   status <= nplus7vok;
   
   -- generate done signals for array_id and status tests
   gen_status_done: process (rst, clk)
   begin
      if (rst = '1') then
         status_done   <= '0';
         array_id_done <= '0';
      elsif (clk'event and clk = '1') then
         status_done   <= status_ena;
         array_id_done <= array_id_ena;
      end if;   
   end process gen_status_done;
   
   array_id_reg1 : shift_reg
   generic map(WIDTH => ARRAY_ID_WIDTH)
   port map(clk_i      => clk,
            rst_i      => rst,
            ena_i      => array_id_reg_ena,
            load_i     => array_id_reg_ld,
            clr_i      => '0',
            shr_i      => '0',
            serial_i   => '0',
            serial_o   => array_id_reg,
            parallel_i => array_id,
            parallel_o => open);
               
               
   sram0 : sram_test
      port map(-- test control signals
         rst_i    => rst,
         clk_i    => clk,
         en_i     => sram0_ena,
         done_o   => sram0_done,
          
         -- physical pins
         addr_o   => sram0_addr,
         data_bi  => sram0_data,
         n_ble_o  => sram0_nbhe,
         n_bhe_o  => sram0_nble,
         n_oe_o   => sram0_noe, 
         n_ce1_o  => sram0_nce1, 
         ce2_o    => sram0_ce2, 
         n_we_o   => sram0_nwe,
--         idx_o    => sram0_fault,
         pass_o   => pass0,
         fail_o   => fail0);

   sram1 : sram_test
      port map(-- test control signals
         rst_i    => rst,
         clk_i    => clk,
         en_i     => sram1_ena,
         done_o   => sram1_done,
          
         -- physical pins
         addr_o   => sram1_addr,
         data_bi  => sram1_data,
         n_ble_o  => sram1_nbhe,
         n_bhe_o  => sram1_nble,
         n_oe_o   => sram1_noe, 
         n_ce1_o  => sram1_nce1, 
         ce2_o    => sram1_ce2, 
         n_we_o   => sram1_nwe,
--         idx_o    => sram1_fault,
         pass_o   => pass1,
         fail_o   => fail1);
   
   fo_test0: fo_bist 
      port map(
         rst_i    => rst,
         clk_i    => clk,
         clk_n_i  => clk_n,
         en_i     => fo_test_ena,
         done_o   => fo_test_done,
         
         -- fibre pins
         fibre_tx_data_o   => fibre_tx_data,
         fibre_tx_clkW_o   => open, --fibre_tx_clkW,
         fibre_tx_ena_o    => fibre_tx_ena, 
         fibre_tx_rp_o     => fibre_tx_rp,  
         fibre_tx_sc_nd_o  => fibre_tx_sc_nd,
         fibre_tx_enn_o    => fibre_tx_enn,
         -- fibre_tx_svs is tied to gnd on board
         -- fibre_tx_enn is tied to vcc on board
         -- fibre_tx_mode is tied to gnd on board
         fibre_tx_foto_o   => fibre_tx_foto,
         fibre_tx_bisten_o => fibre_tx_bisten,
         
         fibre_rx_data_i   => fibre_rx_data,
         --fibre_rx_refclk => --fibre_rx_refcl
         fibre_rx_clkr_i   => fibre_rx_clkr,
         fibre_rx_error_i  => fibre_rx_error,
         fibre_rx_rdy_i    => fibre_rx_rdy,  
         fibre_rx_status_i => fibre_rx_status,
         fibre_rx_sc_nd_i  => fibre_rx_sc_nd,
         fibre_rx_rvs_i    => fibre_rx_rvs, 
         fibre_rx_rf_o     => fibre_rx_rf,   
         fibre_rx_a_nb_o   => fibre_rx_a_nb, 
         fibre_rx_bisten_o => fibre_rx_bisten,

         rx_data1_o        => rx_data1,
         rx_data2_o        => rx_data2,
         rx_data3_o        => rx_data3,
             
         --test pins
         mictor_o => mictor0_o(12 downto 0)
         );

   result_reg: process(rst, clk)
   begin
      if (rst = '1') then
         pass0_reg <= '0';
         fail0_reg <= '0';
         pass1_reg <= '0';
         fail1_reg <= '0';
      elsif (clk'event and clk = '1') then
         if (sram0_ena = '1') then
            pass0_reg <= pass0;
            fail0_reg <= fail0;
         end if;
         if (sram1_ena = '1') then
	    pass1_reg <= pass1;
	    fail1_reg <= fail1;
         end if;
      end if;
   end process result_reg;
   
   
   dv_rx_test0: dv_rx_test 
      port map(
         -- Clock and Reset:
         clk_i      => clk,
         clk_n_i    => clk_n,
         rst_i      => rst,         
         en_i       => dv_test_ena,         
         done_o     => dv_test_done,         
         
         -- Fibre Interface:
         manch_det_i=> manchester_sigdet,         
         manch_dat_i=> manchester_data,         
         dv_dat_i   => dv_pulse_fibre,         
         
         -- Test output
         dat_o      => manch_data
      );         
   
end behaviour;
