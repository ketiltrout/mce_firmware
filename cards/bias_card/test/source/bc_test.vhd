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
-- bc_test.vhd
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Test module for bias card
--
-- Revision history:
-- 
-- $Log: bc_test.vhd,v $
-- Revision 1.18  2010/01/28 23:09:52  mandana
-- version 3.1 and also eliminated rst_cmd which caused combinational loop
--
-- Revision 1.17  2010/01/22 01:17:10  mandana
-- Rev. 3.0 to accomodate 12 low-noise bias lines introduced in Bias Card Rev. E
-- Note that xtalk test is not supported for ln-bias lines YET!
--
-- Revision 1.16  2006/09/01 17:53:55  mandana
-- revision upgraded to 2.1
--
-- Revision 1.15  2006/08/30 21:21:32  mandana
-- revamped to Ernie's new test firmware
-- added tests for sa_heater lines and power status lines
--
-- Revision 1.14  2004/07/21 22:30:15  erniel
-- updated counter component
--
-- Revision 1.13  2004/06/25 17:20:50  bench2
-- Mandana: Data and ncs lines for DAC15 had to be driven from test pins (originally wired to PLL clkin pins on FPGA)
--
-- Revision 1.12  2004/06/23 19:39:34  bench2
-- Mandana: add mux for lvds signals
--
-- Revision 1.11  2004/06/21 18:32:15  bench2
-- renamed all_test_idle to bc_test_idle
--
-- Revision 1.10  2004/06/12 00:49:20  bench2
-- Mandana: xtalk test works now, but only a small sawtooth, has to be slowed down.
--
-- Revision 1.9  2004/06/08 19:04:23  mandana
-- added the cross-talk test
--
-- Revision 1.8  2004/06/04 21:00:26  bench2
-- Mandana: ramp test works now
--
-- Revision 1.7  2004/05/17 01:01:03  erniel
-- renamed constants associated with CMD_BC_DAC
--
-- Revision 1.6  2004/05/17 00:54:26  erniel
-- changed input clock pin name to inclk
--
-- Revision 1.5  2004/05/16 23:42:34  erniel
-- minor change to rs232_data_tx test string
--
-- Revision 1.4  2004/05/16 23:40:19  erniel
-- added LVDS tx a & b modules
-- removed LVDS rx clock module
--
-- Revision 1.3  2004/05/12 18:03:04  mandana
-- seperated the lvds_dac signals on the wrapper
--
-- Revision 1.2  2004/05/12 16:49:07  erniel
-- removed components already in all_test
--
-- Revision 1.1  2004/05/11 23:04:40  mandana
-- initial release - copied from all_test
--
-----------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

library components;
use components.component_pack.all;

library work;
use work.ascii_pack.all;
use work.async_pack.all;
use work.bc_test_pack.all;

entity bc_test is
   port(
      rst_n      : in std_logic;
      
      -- clock signals
      inclk      : in std_logic;
      
      -- RS232 interface
      tx         : out std_logic;
      rx         : in std_logic;
      
      -- sa_heater interface:
      sa_htr1p   : out std_logic;
      sa_htr1n   : out std_logic;
      sa_htr2p   : out std_logic;
      sa_htr2n   : out std_logic;      
            
      -- LVDS interfaces
      lvds_txa   : out std_logic;
      lvds_txb   : out std_logic;
      lvds_cmd   : in std_logic;
      lvds_sync  : in std_logic;
      lvds_spare : in std_logic;
      
      -- bc dac interface
      dac_data   : out std_logic_vector (NUM_FLUX_FB_DACS-1 downto 0); 
      dac_ncs    : out std_logic_vector (NUM_FLUX_FB_DACS-1 downto 0); 
      dac_sclk   : out std_logic_vector (NUM_FLUX_FB_DACS-1 downto 0);
--      dac_nclr : out std_logic;
      
      lvds_dac_data : out std_logic;
      lvds_dac_ncs  : out std_logic_vector(NUM_LN_BIAS_DACS-1 downto 0);
      lvds_dac_sclk : out std_logic;
      
      -- status pins
      n7vok      : in std_logic;
      n15vok     : in std_logic;
      minus7vok  : in std_logic;
      
      --test pins
      test       : out std_logic_vector(14 downto 1));
end bc_test;

architecture behaviour of bc_test is
   
constant RESET_MSG_LEN    : integer := 16;
constant IDLE_MSG_LEN     : integer := 10;
constant ERROR_MSG_LEN    : integer := 8;  
constant RAMP_OFF_MSG_LEN : integer := 22;
constant RESULT_MSG_LEN   : integer := 6;

constant STATUS_WIDTH     : integer := 3;

signal clk  : std_logic;
signal clk_4: std_logic;
signal rst  : std_logic;

type states is (RESET, TX_RESET, TX_IDLE, TX_ERROR, RX_CMD1, RX_CMD2, 
                FIXED_DAC_TEST, RAMP_OFF_MSG, RAMP_DAC_TEST, WAIT_DAC_DONE,
                ODD_XTALK_DAC_TEST, EVEN_XTALK_DAC_TEST, SA_HTR1_TEST, SA_HTR2_TEST, 
                STATUS_TEST, TX_STATUS);
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
signal ramp_msg   : std_logic_vector(7 downto 0);
signal pass_msg   : std_logic_vector(7 downto 0);
signal fail_msg   : std_logic_vector(7 downto 0);

signal cmd1    : std_logic_vector(7 downto 0);
signal cmd2    : std_logic_vector(7 downto 0);
signal cmd1_ld : std_logic;
signal cmd2_ld : std_logic;

signal rst_cmd : std_logic;

   signal fixed_dac_ena      : std_logic;
   signal fixed_dac_done     : std_logic;
   signal fix_dac_ncs        : std_logic_vector (NUM_FLUX_FB_DACS-1 downto 0);
   signal fix_dac_sclk       : std_logic_vector (NUM_FLUX_FB_DACS-1 downto 0);
   signal fix_dac_data       : std_logic_vector (NUM_FLUX_FB_DACS-1 downto 0);
   signal fix_lvds_dac_ncs   : std_logic_vector (NUM_LN_BIAS_DACS-1 downto 0);
   signal fix_lvds_dac_sclk  : std_logic;
   signal fix_lvds_dac_data  : std_logic;

   signal ramp_dac_ena       : std_logic;
   signal ramp_dac_done      : std_logic;
   signal ramp_dac_ncs       : std_logic_vector (NUM_FLUX_FB_DACS-1 downto 0);
   signal ramp_dac_sclk      : std_logic_vector (NUM_FLUX_FB_DACS-1 downto 0);
   signal ramp_dac_data      : std_logic_vector (NUM_FLUX_FB_DACS-1 downto 0);
   signal ramp_lvds_dac_ncs  : std_logic_vector (NUM_LN_BIAS_DACS-1 downto 0);
   signal ramp_lvds_dac_sclk : std_logic;
   signal ramp_lvds_dac_data : std_logic;
   
   signal xtalk_dac_ena      : std_logic;
   signal xtalk_dac_done     : std_logic;
   signal xtalk_dac_ncs      : std_logic_vector (NUM_FLUX_FB_DACS-1 downto 0);
   signal xtalk_dac_sclk     : std_logic_vector (NUM_FLUX_FB_DACS-1 downto 0);
   signal xtalk_dac_data     : std_logic_vector (NUM_FLUX_FB_DACS-1 downto 0);
   signal xtalk_lvds_dac_ncs : std_logic_vector (NUM_LN_BIAS_DACS-1 downto 0);
   signal xtalk_lvds_dac_sclk: std_logic;
   signal xtalk_lvds_dac_data: std_logic;
      
   signal sa_htr1_ena        : std_logic;
   signal sa_htr1_done       : std_logic;

   signal sa_htr2_ena        : std_logic;
   signal sa_htr2_done       : std_logic;

   signal test_data          : std_logic_vector(31 downto 0);
   signal lvds_spi_start     : std_logic;
   signal spi_start          : std_logic;
   signal fix_spi_start      : std_logic;   
   signal ramp_spi_start     : std_logic;
   signal xtalk_spi_start    : std_logic;

   signal rx_clk             : std_logic;
   signal dac_test_mode      : std_logic_vector(1 downto 0);
   signal dac_test_mode_reg  : std_logic_vector (1 downto 0);
   signal mode_reg_en        : std_logic; 

   signal dac_test_ncs       : std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);
   signal dac_test_sclk      : std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);
   signal dac_test_data      : std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);

   signal status_ena         : std_logic;
   signal status_done        : std_logic;
   signal status             : std_logic_vector(STATUS_WIDTH-1 downto 0);
   signal status_reg         : std_logic; -- serial shift register of status
   signal status_reg_ena     : std_logic;
   signal status_reg_ld      : std_logic;
   
begin
   rst <= not rst_n; -- or rst_cmd;

   clk0: bc_test_pll
   port map(inclk0 => inclk,
            c0 => clk,
            c1 => clk_4);


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
                   shift(b)  when 2,
                   shift(c)  when 3,
                   space     when 4,
                   shift(t)  when 5,
                   e         when 6,
                   s         when 7,
                   t         when 8,
                   space     when 9,
                   v         when 10, -- text for version number 3.2
                   period    when 11, 
                   three     when 12, 
                   period    when 13,
                   two       when 14,
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
      -- ramp_off message is turn off ramp first! 
      ramp_msg  <= tab         when 0,
                   t           when 1,
                   u           when 2,
                   r           when 3,
                   n           when 4,
                   space       when 5,
                   o           when 6,
                   f           when 7,
                   f           when 8,
                   space       when 9,
                   r           when 10,  
                   a 	       when 11,
                   m	       when 12,
                   p	       when 13,
                   space       when 14,
                   f	       when 15,
                   i	       when 16,
                   r	       when 17,
                   s	       when 18,
                   t	       when 19,
                   shift(one)  when 20,                   
                   newline  when others;

   with tx_count select
      -- power status read backs correct values, prints pass message
      pass_msg  <= tab         when 3,
                   shift(p)    when 4,
                   a           when 5,
                   s           when 6,
                   s           when 7,
                   shift(one)  when 8,
                   newline  when others;

   with tx_count select
      -- power status read backs wrong values, prints fail message
      fail_msg  <= tab         when 3,
                   shift(F)    when 4,
                   a           when 5,
                   i           when 6,
                   l           when 7,
                   shift(one)  when 8,
                   newline  when others;

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

   process(pres_state, rx_rdy, rx_data, tx_count, fixed_dac_done, ramp_dac_done, xtalk_dac_done, sa_htr1_done, sa_htr2_done)
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
                                      when f | shift(f) => next_state <= FIXED_DAC_TEST;
                                      when r | shift(r) => next_state <= RAMP_DAC_TEST;
                                      when o | shift(o) => next_state <= ODD_XTALK_DAC_TEST;                                      
                                      when e | shift(e) => next_state <= EVEN_XTALK_DAC_TEST;
                                      when a | shift(a) => next_state <= SA_HTR1_TEST;
                                      when b | shift(b) => next_state <= SA_HTR2_TEST;
                                      when s | shift(s) => next_state <= STATUS_TEST;
                                      when escape =>       next_state <= RESET;
                                      when others =>       next_state <= TX_ERROR;
                                   end case;
                                else
                                   next_state <= RX_CMD1;
                                end if;

         when FIXED_DAC_TEST => next_state <= WAIT_DAC_DONE;                                
         
         when RAMP_OFF_MSG   =>  if(tx_count = RAMP_OFF_MSG_LEN - 1) then
                                    next_state <= TX_IDLE;
                                 else
                                    next_state <= RAMP_OFF_MSG;
                                 end if;                     

         when RAMP_DAC_TEST  =>  next_state <= WAIT_DAC_DONE;

         when WAIT_DAC_DONE  =>  if(fixed_dac_done = '1' or ramp_dac_done = '1' or xtalk_dac_done = '1') then
                                    next_state <= TX_IDLE;
                                 else
                                    next_state <= WAIT_DAC_DONE;
                                 end if;  

         when EVEN_XTALK_DAC_TEST =>  next_state <= WAIT_DAC_DONE;
         
         when ODD_XTALK_DAC_TEST =>  next_state <= WAIT_DAC_DONE;
         
         when SA_HTR1_TEST   =>   next_state <= TX_IDLE;
         
         when SA_HTR2_TEST   =>   next_state <= TX_IDLE;                                
         
         when STATUS_TEST    =>   if(status_done = '1') then
                                     next_state <= TX_STATUS;
                                  else
                                     next_state <= STATUS_TEST;
                                  end if;
         
         when TX_STATUS      =>   if(tx_count = STATUS_WIDTH + RESULT_MSG_LEN - 1) then
                                     next_state <= TX_IDLE;
                                  else
                                     next_state <= TX_STATUS;
                                  end if;

         when others         =>   next_state <= TX_IDLE;

      end case;
   end process;

   process(pres_state, tx_busy, tx_count, reset_msg, idle_msg, error_msg)
   begin
      rx_ack        <= '0';
      tx_rdy        <= '0';
      tx_data       <= (others => '0');
      tx_count_ena  <= '0';
      tx_count_clr  <= '0';
      cmd1_ld       <= '0';
      cmd2_ld       <= '0';
      
      rst_cmd       <= '0';
      fixed_dac_ena <= '0';
      ramp_dac_ena  <= '0';
      xtalk_dac_ena <= '0';
      dac_test_mode <= "00";
      mode_reg_en   <= '0';
      sa_htr1_ena   <= '0';
      sa_htr2_ena   <= '0';
      status_ena    <= '0';
      status_reg_ld <= '0';
      status_reg_ena<= '0';

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

         when FIXED_DAC_TEST =>  fixed_dac_ena <= '1';
                                 dac_test_mode <= "00";
                                 mode_reg_en <= '1';
                                
         when RAMP_OFF_MSG  => 
                            if (tx_busy = '0') then
                               tx_rdy       <= '1';
                               tx_count_ena <= '1';
                            end if;
                            if(tx_count = RAMP_OFF_MSG_LEN - 1) then
                               tx_count_ena <= '1';
                               tx_count_clr <= '1';
                            end if;   
                            tx_data <= ramp_msg;

         when RAMP_DAC_TEST =>  
                            ramp_dac_ena <= '1';
                            dac_test_mode <= "01";
                            mode_reg_en <= '1';

         when ODD_XTALK_DAC_TEST =>  
                            xtalk_dac_ena <= '1';
                            dac_test_mode <= "10";
                            mode_reg_en <= '1';
                            
         when EVEN_XTALK_DAC_TEST => 
                            xtalk_dac_ena <= '1';
                            dac_test_mode <= "11";
                            mode_reg_en <= '1';

         when SA_HTR1_TEST =>
                            sa_htr1_ena   <= '1';

         when SA_HTR2_TEST =>
                            sa_htr2_ena   <= '1';
         
         when WAIT_DAC_DONE => null;
         
         when STATUS_TEST => status_ena      <= '1';
                             status_reg_ena  <= '1';
                             status_reg_ld   <= '1';
                             tx_count_ena    <= '1';
                             tx_count_clr    <= '1';

         when TX_STATUS =>  if(tx_busy = '0') then
                               tx_rdy          <= '1';
                               status_reg_ena  <= '1';
                               tx_count_ena    <= '1';
                            end if;
                            if(tx_count = STATUS_WIDTH + RESULT_MSG_LEN - 1) then
                               tx_count_ena <= '1';
                               tx_count_clr <= '1';
                            end if;
                            if (tx_count < STATUS_WIDTH ) then
                               tx_data <= bin2asc(status_reg);
                            elsif (status = "010") then                              
                               tx_data <= pass_msg;
                            else
                               tx_data <= fail_msg;
                            end if;   
                            
         when others =>     null;

      end case;
   end process;
   
   -------------------------------------------------------
   --
   -- Different test instantiations
   --
   -------------------------------------------------------
   
   -- status test
   status <= n7vok & minus7vok & n15vok;
   
   gen_status_done: process (rst, clk, status_ena)
   begin
      if (rst = '1') then
         status_done <= '0';
      elsif (clk'event and clk = '1') then
            status_done <= status_ena;
      end if;   
   end process gen_status_done;
   
   status_reg1 : shift_reg
   generic map(WIDTH => STATUS_WIDTH)
   port map(clk_i      => clk,
            rst_i      => rst,
            ena_i      => status_reg_ena,
            load_i     => status_reg_ld,
            clr_i      => '0',
            shr_i      => '0',
            serial_i   => '0',
            serial_o   => status_reg,
            parallel_i => status,
            parallel_o => open);


   
   -- DAC fix-value test
   dac_fix : bc_dac_ctrl_test_wrapper
      port map(
               -- basic signals
               rst_i     => rst,
               clk_i     => clk,
               clk_4_i   => clk_4,
               en_i      => fixed_dac_ena,
               done_o    => fixed_dac_done,
               
               -- transmitter signals removed!
                         
               -- extended signals
               dac_dat_o => fix_dac_data,
               dac_ncs_o => fix_dac_ncs,
               dac_clk_o => fix_dac_sclk,
                           
               lvds_dac_dat_o => fix_lvds_dac_data,
               lvds_dac_ncs_o => fix_lvds_dac_ncs,
               lvds_dac_clk_o => fix_lvds_dac_sclk,

               spi_start_o    => fix_spi_start,
               lvds_spi_start_o => lvds_spi_start
               );   
   
   
   
   -- DAC ramp test
   dac_ramp :  bc_dac_ramp_test_wrapper
      port map(
               -- basic signals
               rst_i     => rst,
               clk_i     => clk,
               clk_4_i   => clk_4,
               en_i      => ramp_dac_ena,
               done_o    => ramp_dac_done,
               
               -- transmitter signals removed!
                         
               -- extended signals
               dac_dat_o  => ramp_dac_data,
               dac_ncs_o  => ramp_dac_ncs,
               dac_clk_o  => ramp_dac_sclk,
              
               lvds_dac_dat_o=> ramp_lvds_dac_data,
               lvds_dac_ncs_o=> ramp_lvds_dac_ncs,
               lvds_dac_clk_o=> ramp_lvds_dac_sclk,
               
               spi_start_o  => ramp_spi_start
            );     

   -- mode register
   process(clk, rst)
   begin
      if(rst = '1') then
         dac_test_mode_reg <= "00";
      elsif(clk'event and clk = '1') then
         if (mode_reg_en = '1') then
           dac_test_mode_reg <= dac_test_mode;
         end if;
      end if;
   end process;
   
   
   
   -- DAC cross-talk test
   dac_xtalk :  bc_dac_xtalk_test_wrapper
      port map(
               -- basic signals
               rst_i     => rst,
               clk_i     => clk,
               clk_4_i   => clk_4,
               en_i      => xtalk_dac_ena,
               mode_i    => dac_test_mode(0),    -- dac_test_mode ="02" passes 0 to the block indicating odd channels square wave
               done_o    => xtalk_dac_done,
               
               -- transmitter signals removed!
                         
               -- extended signals
               dac_dat_o  => xtalk_dac_data,
               dac_ncs_o  => xtalk_dac_ncs,
               dac_clk_o  => xtalk_dac_sclk,
              
               lvds_dac_dat_o=> xtalk_lvds_dac_data,
               lvds_dac_ncs_o=> xtalk_lvds_dac_ncs,
               lvds_dac_clk_o=> xtalk_lvds_dac_sclk,
               
               spi_start_o  => xtalk_spi_start
            );     
   
   
   
   -- SA_heater A Square-wave test
   sa_htr1_toggle : bc_sa_htr_test
      port map(
               -- basic signals
               rst_i     => rst,
               clk_i     => clk,
               en_i      => sa_htr1_ena,
               done_o    => sa_htr1_done,

               pos_o     => sa_htr1p,
               neg_o     => sa_htr1n
            );       
   
   -- SA_heater B Square-wave test
   sa_htr2_toggle : bc_sa_htr_test
      port map(
               -- basic signals
               rst_i     => rst,
               clk_i     => clk,
               en_i      => sa_htr2_ena,
               done_o    => sa_htr2_done,
               
               pos_o     => sa_htr2p,
               neg_o     => sa_htr2n
            );       
      
   -- multiplex DAC lines for different test modes   
   with dac_test_mode_reg select
      dac_test_data <= fix_dac_data       when "00",
                       ramp_dac_data      when "01",
                       xtalk_dac_data     when "10",
                       xtalk_dac_data     when "11",
                       fix_dac_data       when others;
                       
   with dac_test_mode_reg select
      dac_test_sclk <= fix_dac_sclk       when "00",
                       ramp_dac_sclk      when "01",
                       xtalk_dac_sclk     when "10",
                       xtalk_dac_sclk     when "11",
                       fix_dac_sclk       when others;
                       
   with dac_test_mode_reg select
      dac_test_ncs  <= fix_dac_ncs        when "00",
                       ramp_dac_ncs       when "01",
                       xtalk_dac_ncs      when "10",
                       xtalk_dac_ncs      when "11",
                       fix_dac_ncs        when others;                       
                       
   -- lvds signals
   with dac_test_mode_reg select
      lvds_dac_data <= fix_lvds_dac_data       when "00",
                       ramp_lvds_dac_data      when "01",
                       xtalk_lvds_dac_data     when "10",
                       xtalk_lvds_dac_data     when "11",
                       fix_lvds_dac_data       when others;                       
                       
   with dac_test_mode_reg select
      lvds_dac_sclk <= fix_lvds_dac_sclk       when "00",
                       ramp_lvds_dac_sclk      when "01",
                       xtalk_lvds_dac_sclk     when "10",
                       xtalk_lvds_dac_sclk     when "11",
                       fix_lvds_dac_sclk       when others;                       
                       
   with dac_test_mode_reg select
      lvds_dac_ncs  <= fix_lvds_dac_ncs        when "00",
                       ramp_lvds_dac_ncs       when "01",
                       xtalk_lvds_dac_ncs      when "10",
                       xtalk_lvds_dac_ncs      when "11",
                       fix_lvds_dac_ncs        when others;                       
                       
   -- for directing to test pin purpose only!
   with dac_test_mode_reg select
      spi_start     <= fix_spi_start      when "00",
                       ramp_spi_start     when "01",
                       xtalk_spi_start    when "10",
                       xtalk_spi_start    when "11",
                       fix_spi_start      when others;
   
   dac_ncs <= dac_test_ncs;
   dac_sclk <= dac_test_sclk;
   dac_data <= dac_test_data;
      
   test(5) <= dac_test_ncs(0);
   test(6) <= dac_test_ncs(1);
   test(7) <= dac_test_sclk(0);
   test(8) <= dac_test_sclk(1);
   test(9) <= dac_test_data(0);
   test(10) <= dac_test_data(1);
   test(14) <= spi_start;
   test(13) <= lvds_spi_start;

end behaviour;
