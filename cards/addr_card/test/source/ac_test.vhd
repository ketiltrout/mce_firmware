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
-- ac_test.vhd
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Test module for common items
--
-- Revision history:
-- <date $Date: 2004/05/17 19:09:34 $>	- <initials $Author: erniel $>
-- $Log: ac_test.vhd,v $
-- Revision 1.5  2004/05/17 19:09:34  erniel
-- expanded dac_dat_o into 11 separate 14-bit vectors
--
-- Revision 1.4  2004/05/17 00:51:13  erniel
-- added LVDS tx a & b modules
-- removed LVDS rx clock module
-- removed redundant test modules
--
-- Revision 1.3  2004/05/13 17:44:06  mandana
-- modified all_test for ac_test
--
--
-----------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.data_types_pack.all;

library work;
use work.async_pack.all;
use work.ac_test_pack.all;

entity ac_test is
   port(
      n_rst : in std_logic;
      
      -- clock signals
      inclk : in std_logic;
      outclk : out std_logic;
      
      -- RS232 interface
      rs232_tx : out std_logic;
      rs232_rx : in std_logic;
                
      -- LVDS interfaces
      lvds_txa   : out std_logic;
      lvds_txb   : out std_logic;
      lvds_cmd   : in std_logic;
      lvds_sync  : in std_logic;
      lvds_spare : in std_logic;
      
      -- outputs of dac ramp and dac test for selective values
      dac_data0  : out std_logic_vector(13 downto 0); 
      dac_data1  : out std_logic_vector(13 downto 0);
      dac_data2  : out std_logic_vector(13 downto 0);
      dac_data3  : out std_logic_vector(13 downto 0);
      dac_data4  : out std_logic_vector(13 downto 0);
      dac_data5  : out std_logic_vector(13 downto 0);
      dac_data6  : out std_logic_vector(13 downto 0);
      dac_data7  : out std_logic_vector(13 downto 0);
      dac_data8  : out std_logic_vector(13 downto 0);
      dac_data9  : out std_logic_vector(13 downto 0);
      dac_data10 : out std_logic_vector(13 downto 0);
      
      dac_clk    : out std_logic_vector(40 downto 0);
      test : out std_logic_vector(16 downto 3)      
   );         
end ac_test;

architecture behaviour of ac_test is
   
   component pll
   port(inclk0 : in std_logic;
        c0 : out std_logic;
        e0 : out std_logic);
   end component;

   
   signal zero : std_logic;
   signal one : std_logic;
   
   signal clk : std_logic;   
   signal rst : std_logic;
   signal int_rst : std_logic;
   
   signal dip : std_logic_vector(1 downto 0);

   -- transmitter signals
   signal tx_clock : std_logic;
   signal tx_busy  : std_logic;
   signal tx_ack   : std_logic;
   signal tx_data  : std_logic_vector(7 downto 0);
   signal tx_we    : std_logic;
   signal tx_stb   : std_logic;
   
   -- reciever signals
   signal rx_clock : std_logic;
   signal rx_valid : std_logic;
   signal rx_error : std_logic;
   signal rx_read  : std_logic;
   signal rx_data  : std_logic_vector(7 downto 0);
   signal rx_stb   : std_logic;
   signal rx_ack   : std_logic;
   
   -- state constants
   constant MAX_STATES : integer := 10;

   constant INDEX_RESET      : integer := 0;
   constant INDEX_IDLE       : integer := 1;
   constant INDEX_TX_A       : integer := 2;
   constant INDEX_TX_B       : integer := 3;
   constant INDEX_RX_CMD     : integer := 4;
   constant INDEX_RX_SYNC    : integer := 5;
   constant INDEX_RX_SPARE   : integer := 6;   
   constant INDEX_DEBUG      : integer := 7;
   constant INDEX_DAC_FIX    : integer := 8;
   constant INDEX_DAC_RAMP   : integer := 9;
      
   constant SEL_RESET      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RESET => '1', others => '0');
   constant SEL_IDLE       : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_IDLE => '1', others => '0');
   constant SEL_TX_A       : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_TX_A => '1', others => '0');
   constant SEL_TX_B       : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_TX_B => '1', others => '0');
   constant SEL_RX_CMD     : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RX_CMD => '1', others => '0');
   constant SEL_RX_SYNC    : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RX_SYNC => '1', others => '0');
   constant SEL_RX_SPARE   : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RX_SPARE => '1', others => '0');         
   constant SEL_DEBUG      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_DEBUG => '1', others => '0');
   constant SEL_DAC_FIX    : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_DAC_FIX => '1', others => '0');
   constant SEL_DAC_RAMP   : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_DAC_RAMP => '1', others => '0');
   
   constant DONE_NULL       : std_logic_vector(MAX_STATES - 1 downto 0) := (others => '0');
   constant DONE_RESET      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RESET => '1', others => '0');
   constant DONE_IDLE       : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_IDLE => '1', others => '0');
   constant DONE_TX_A       : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_TX_B => '1', others => '0');
   constant DONE_TX_B       : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_TX_B => '1', others => '0');
   constant DONE_RX_CMD     : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RX_CMD => '1', others => '0');
   constant DONE_RX_SYNC    : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RX_SYNC => '1', others => '0');
   constant DONE_RX_SPARE   : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RX_SPARE => '1', others => '0'); 
   constant DONE_DEBUG      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_DEBUG => '1', others => '0');
   constant DONE_DAC_FIX    : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_DAC_FIX => '1', others => '0');
   constant DONE_DAC_RAMP   : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_DAC_RAMP => '1', others => '0');

   -- state signals
   type states is (RESET, FETCH, DECODE, EXECUTE);
   signal cmd_state : states;
   
   signal sel  : std_logic_vector(MAX_STATES - 1 downto 0);
   signal done : std_logic_vector(MAX_STATES - 1 downto 0);
   
   signal cmd1 : std_logic_vector(7 downto 0);
   signal cmd2 : std_logic_vector(7 downto 0);
   
   -- device return signals:
   signal reset_data    : std_logic_vector(7 downto 0);
   signal idle_data     : std_logic_vector(7 downto 0);
   signal rx_cmd_data   : std_logic_vector(7 downto 0);
   signal rx_sync_data  : std_logic_vector(7 downto 0);
   signal rx_spare_data : std_logic_vector(7 downto 0);      
   signal debug_data    : std_logic_vector(7 downto 0);
   
   signal reset_we      : std_logic;
   signal idle_we       : std_logic;
   signal rx_cmd_we     : std_logic;
   signal rx_sync_we    : std_logic;
   signal rx_spare_we   : std_logic;      
   signal debug_we      : std_logic;
   
   
   signal reset_stb     : std_logic;
   signal idle_stb      : std_logic;
   signal rx_cmd_stb    : std_logic;
   signal rx_sync_stb   : std_logic;
   signal rx_spare_stb  : std_logic;   
   signal debug_stb     : std_logic;
   
   signal test_data : std_logic_vector(43 downto 0);
   
   signal fix_dac_data0  : std_logic_vector(13 downto 0);
   signal fix_dac_data1  : std_logic_vector(13 downto 0);
   signal fix_dac_data2  : std_logic_vector(13 downto 0);
   signal fix_dac_data3  : std_logic_vector(13 downto 0);
   signal fix_dac_data4  : std_logic_vector(13 downto 0);
   signal fix_dac_data5  : std_logic_vector(13 downto 0);
   signal fix_dac_data6  : std_logic_vector(13 downto 0);
   signal fix_dac_data7  : std_logic_vector(13 downto 0);
   signal fix_dac_data8  : std_logic_vector(13 downto 0);
   signal fix_dac_data9  : std_logic_vector(13 downto 0);
   signal fix_dac_data10 : std_logic_vector(13 downto 0);
   signal fix_dac_clk    : std_logic_vector(40 downto 0);
   
   signal ramp_dac_data0  : std_logic_vector(13 downto 0);
   signal ramp_dac_data1  : std_logic_vector(13 downto 0);
   signal ramp_dac_data2  : std_logic_vector(13 downto 0);
   signal ramp_dac_data3  : std_logic_vector(13 downto 0);
   signal ramp_dac_data4  : std_logic_vector(13 downto 0);
   signal ramp_dac_data5  : std_logic_vector(13 downto 0);
   signal ramp_dac_data6  : std_logic_vector(13 downto 0);
   signal ramp_dac_data7  : std_logic_vector(13 downto 0);
   signal ramp_dac_data8  : std_logic_vector(13 downto 0);
   signal ramp_dac_data9  : std_logic_vector(13 downto 0);
   signal ramp_dac_data10 : std_logic_vector(13 downto 0);
   signal ramp_dac_clk    : std_logic_vector(40 downto 0);
   
   signal ramp_ena : std_logic;

begin
   clk_gen : pll
      port map(inclk0 => inclk,
               c0 => clk,
               e0 => outclk);

   -- RS232 interface start
   receiver : async_rx
      port map(rx_i => rs232_rx,
               flag_o => rx_valid,
               error_o => rx_error,
               clk_i => rx_clock,
               rst_i => rst,
               dat_o => rx_data,
               we_i => zero,
               stb_i => rx_stb,
               ack_o => rx_ack,
               cyc_i => one);

   transmitter : async_tx
      port map(tx_o => rs232_tx,
               busy_o => tx_busy,
               clk_i => tx_clock,
               rst_i => rst,
               dat_i => tx_data,
               we_i => tx_we,
               stb_i => tx_stb,
               ack_o => tx_ack,
               cyc_i => one);
   
   aclock : async_clk
      port map(clk_i => clk,
               rst_i => rst,
               txclk_o => tx_clock,
               rxclk_o => rx_clock);
      
   -- RS232 interface end
   
   -- reset_state gives us our welcome string on startup
   reset_state : ac_test_reset
      port map(rst_i     => rst,
               clk_i     => clk,
               en_i      => sel(INDEX_RESET),
               done_o    => done(INDEX_RESET),
               
               tx_busy_i => tx_busy,
               tx_ack_i  => tx_ack,
               tx_data_o => reset_data,
               tx_we_o   => reset_we,
               tx_stb_o  => reset_stb);
   
   -- idle_state is special - it aquires commands for us to process
   idle_state : ac_test_idle
      port map(rst_i     => rst,
               clk_i     => clk,
               en_i      => sel(INDEX_IDLE),
               done_o    => done(INDEX_IDLE),
               
               tx_busy_i => tx_busy,
               tx_ack_i  => tx_ack,
               tx_data_o => idle_data,
               tx_we_o   => idle_we,
               tx_stb_o  => idle_stb,
               
               rx_valid_i => rx_valid,
               rx_ack_i  => rx_ack,
               rx_stb_o  => rx_stb,
               rx_data_i => rx_data,
               
               cmd1_o => cmd1,
               cmd2_o => cmd2);
      
         
   -- LVDS transmitter
   tx_a : lvds_tx_test_wrapper
      port map(rst_i     => rst,
               clk_i     => clk,
               en_i      => sel(INDEX_TX_A),
               done_o    => done(INDEX_TX_A),
               lvds_o    => lvds_txa);

   tx_b : lvds_tx_test_wrapper
      port map(rst_i     => rst,
               clk_i     => clk,
               en_i      => sel(INDEX_TX_B),
               done_o    => done(INDEX_TX_B),
               lvds_o    => lvds_txb);
               
               
   -- LVDS receivers   
   rx_cmd : lvds_rx_test_wrapper
      port map(rst_i     => rst,
               clk_i     => clk,
               en_i      => sel(INDEX_RX_CMD),
               done_o    => done(INDEX_RX_CMD),
               lvds_i    => lvds_cmd,
            
               tx_busy_i => tx_busy,
               tx_ack_i  => tx_ack,
               tx_data_o => rx_cmd_data,
               tx_we_o   => rx_cmd_we,
               tx_stb_o  => rx_cmd_stb);
    
   rx_sync : lvds_rx_test_wrapper
      port map(rst_i     => rst,
               clk_i     => clk,
               en_i      => sel(INDEX_RX_SYNC),
               done_o    => done(INDEX_RX_SYNC),
               lvds_i    => lvds_sync,
            
               tx_busy_i => tx_busy,
               tx_ack_i  => tx_ack,
               tx_data_o => rx_sync_data,
               tx_we_o   => rx_sync_we,
               tx_stb_o  => rx_sync_stb);
   
   rx_spare : lvds_rx_test_wrapper
      port map(rst_i     => rst,
               clk_i     => clk,
               en_i      => sel(INDEX_RX_SPARE),
               done_o    => done(INDEX_RX_SPARE),
               lvds_i    => lvds_spare,
            
               tx_busy_i => tx_busy,
               tx_ack_i  => tx_ack,
               tx_data_o => rx_spare_data,
               tx_we_o   => rx_spare_we,
               tx_stb_o  => rx_spare_stb);
      
               
   debug_tx : rs232_data_tx
      generic map(WIDTH => 44)
      port map(clk_i   => clk,
               rst_i   => rst,
               data_i  => test_data,
               start_i => sel(INDEX_DEBUG),
               done_o  => done(INDEX_DEBUG),

               tx_busy_i => tx_busy,
               tx_ack_i  => tx_ack,
               tx_data_o => debug_data,
               tx_we_o   => debug_we,
               tx_stb_o  => debug_stb); 
   
   ac_dac_fix : ac_dac_ctrl_test
      port map(rst_i       => rst,
               clk_i       => clk,
               en_i        => sel(INDEX_DAC_FIX),
               done_o      => done(INDEX_DAC_FIX),
               
               dac_dat0_o  => fix_dac_data0,
               dac_dat1_o  => fix_dac_data1,
               dac_dat2_o  => fix_dac_data2,
               dac_dat3_o  => fix_dac_data3,
               dac_dat4_o  => fix_dac_data4,
               dac_dat5_o  => fix_dac_data5,
               dac_dat6_o  => fix_dac_data6,
               dac_dat7_o  => fix_dac_data7,
               dac_dat8_o  => fix_dac_data8,
               dac_dat9_o  => fix_dac_data9,
               dac_dat10_o => fix_dac_data10,
               dac_clk_o   => fix_dac_clk);
  
   ac_dac_ramp1 : ac_dac_ramp
      port map(rst_i       => rst,
               clk_i       => clk,
               en_i        => sel(INDEX_DAC_RAMP),
               done_o      => done(INDEX_DAC_RAMP),
               
               dac_dat0_o  => ramp_dac_data0,
               dac_dat1_o  => ramp_dac_data1,
               dac_dat2_o  => ramp_dac_data2,
               dac_dat3_o  => ramp_dac_data3,
               dac_dat4_o  => ramp_dac_data4,
               dac_dat5_o  => ramp_dac_data5,
               dac_dat6_o  => ramp_dac_data6,
               dac_dat7_o  => ramp_dac_data7,
               dac_dat8_o  => ramp_dac_data8,
               dac_dat9_o  => ramp_dac_data9,
               dac_dat10_o => ramp_dac_data10,
               dac_clk_o   => ramp_dac_clk);  
      
   zero <= '0';
   one <= '1';                         
   rst <= not n_rst or int_rst;
   test_data <= "11011110110010101111110000001111111111101110";  -- 0xDECAFC0FFEE
   
   -- functionality of async_mux:
   
   with sel select
      tx_data <= reset_data    when SEL_RESET,
                 idle_data     when SEL_IDLE,
                 rx_cmd_data   when SEL_RX_CMD,
                 rx_sync_data  when SEL_RX_SYNC,
                 rx_spare_data when SEL_RX_SPARE,
                 debug_data    when SEL_DEBUG,
                 "00000000"    when others;
   
   with sel select
      tx_we   <= reset_we      when SEL_RESET,
                 idle_we       when SEL_IDLE,
                 rx_cmd_we     when SEL_RX_CMD,
                 rx_sync_we    when SEL_RX_SYNC,
                 rx_spare_we   when SEL_RX_SPARE,
                 debug_we      when SEL_DEBUG,
                 '0'           when others; 
   
   with sel select
      tx_stb  <= reset_stb     when SEL_RESET,
                 idle_stb      when SEL_IDLE,
                 rx_cmd_stb    when SEL_RX_CMD,
                 rx_sync_stb   when SEL_RX_SYNC,
                 rx_spare_stb  when SEL_RX_SPARE,
                 debug_stb     when SEL_DEBUG,
                 '0'           when others;
   
   dac_data0  <= ramp_dac_data0  when ramp_ena = '1' else fix_dac_data0;
   dac_data1  <= ramp_dac_data1  when ramp_ena = '1' else fix_dac_data1;
   dac_data2  <= ramp_dac_data2  when ramp_ena = '1' else fix_dac_data2;
   dac_data3  <= ramp_dac_data3  when ramp_ena = '1' else fix_dac_data3;
   dac_data4  <= ramp_dac_data4  when ramp_ena = '1' else fix_dac_data4;
   dac_data5  <= ramp_dac_data5  when ramp_ena = '1' else fix_dac_data5;
   dac_data6  <= ramp_dac_data6  when ramp_ena = '1' else fix_dac_data6;
   dac_data7  <= ramp_dac_data7  when ramp_ena = '1' else fix_dac_data7;
   dac_data8  <= ramp_dac_data8  when ramp_ena = '1' else fix_dac_data8;
   dac_data9  <= ramp_dac_data9  when ramp_ena = '1' else fix_dac_data9;
   dac_data10 <= ramp_dac_data10 when ramp_ena = '1' else fix_dac_data10;
   dac_clk    <= ramp_dac_clk    when ramp_ena = '1' else fix_dac_clk;
      
   -- cmd_proc is our main processing state machine
   cmd_proc : process (rst, clk)
   begin
      if (rst = '1') then
         int_rst <= '0';
         sel <= SEL_RESET;
         cmd_state <= RESET;
         ramp_ena <= '0';
      elsif Rising_Edge(clk) then
         case cmd_state is
            when RESET => 
               -- wait for the reset state to complete
               if (done = DONE_RESET) then
                  cmd_state <= FETCH;
               else
                  cmd_state <= cmd_state;
               end if;
               sel <= SEL_RESET;
               
            when FETCH =>
               -- wait for a command to be decoded
               if (done = DONE_IDLE) then
                  cmd_state <= DECODE;
               else
                  cmd_state <= cmd_state;
               end if;
               sel <= SEL_IDLE;
               
            when DECODE =>
               -- activate the appropiate test module
               cmd_state <= EXECUTE;

               if(cmd1 = CMD_TX) then
                  if(cmd2 = CMD_TX_A) then
                     sel <= SEL_TX_A;
                  elsif(cmd2 = CMD_TX_B) then
                     sel <= SEL_TX_B;
                  end if;
               
               elsif(cmd1 = CMD_RX) then
                  if(cmd2 = CMD_RX_CMD) then
                     sel <= SEL_RX_CMD;
                  elsif(cmd2 = CMD_RX_SYNC) then
                     sel <= SEL_RX_SYNC;
                  elsif(cmd2 = CMD_RX_SPARE) then
                     sel <= SEL_RX_SPARE;
                  end if;
                  
               elsif(cmd1 = CMD_DAC_FIX) then
                  if(ramp_ena = '0') then
                     sel <= SEL_DAC_FIX;
                  end if;

               elsif(cmd1 = CMD_DAC_RAMP) then
                  ramp_ena <= not (ramp_ena);
                  sel <= SEL_DAC_RAMP;
                  
               elsif(cmd1 = CMD_DEBUG) then
                  sel <= SEL_DEBUG;
                  
               elsif(cmd1 = CMD_RESET) then
                  int_rst <= '1';
                  
               else
                  -- must not be implemented yet!
                  sel <= (others => '0');
                  cmd_state <= FETCH;                  
               end if;
               
            when EXECUTE =>
               -- wait for thet test to complete
               if (done /= DONE_NULL) then
                  int_rst <= '0';
                  sel <= (others => '0');
                  cmd_state <= FETCH;
               end if;
               
            when others =>
               sel <= (others => '0');
               cmd_state <= RESET;
         end case;
      end if;
   end process cmd_proc;

   test(6) <= ramp_ena;
end behaviour;
