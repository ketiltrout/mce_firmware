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
-- rc_test.vhd
--
-- Project:	      SCUBA-2
-- Author:	      Mandana Amiri
-- Organisation:  UBC
--
-- Description:
-- Test module for readout card
--
-- Revision history:
-- <date $Date: 2004/07/17 00:00:00 $>	- <initials $Author: mandana $>
-- $Log: rc_test.vhd,v $
-- Revision 1.11  2004/07/17 00:00:00  mandana
-- adding SRAM test, v02 now
--
-- Revision 1.10  2004/07/16 18:56:32  mandana
-- adding SRAM test, v02 now
--
-- Revision 1.9  2004/07/16 00:16:37  bench1
-- Mandana: set the dac_test_mode for parallel dacs
--
-- Revision 1.8  2004/07/15 17:57:40  bench1
-- Mandana: corrected fix vs. ramp switch on dac tests
--
-- Revision 1.7  2004/07/15 00:38:26  bench1
-- Mandana: changed dac_sclk to dac_clk to match tcl file
--
-- Revision 1.6  2004/06/22 20:54:15  mandana
-- modified the output-port names to be consistent with tcl file
--
-- Revision 1.5  2004/06/22 17:42:40  mandana
-- added mode to port map and cleaned syntax errors
--
-- Revision 1.4  2004/06/21 22:42:25  mandana
-- Merging 1.2 and 1.3
--
-- Revision 1.3  2004/06/21 22:34:37  mandana
-- try merge
-- 
--
-----------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

library work;
use work.async_pack.all;
use work.rc_test_pack.all;

entity rc_test is
   port(
      n_rst : in std_logic;
      
      -- clock signals
      inclk  : in std_logic;
      outclk : out std_logic;
      
      -- RS232 interface
      rs232_tx : out std_logic;
      rs232_rx : in std_logic;
            
      -- LVDS interfaces
      lvds_txa       : out std_logic;
      lvds_txb       : out std_logic;
      lvds_cmd       : in std_logic;
      lvds_sync      : in std_logic;
      lvds_spare     : in std_logic;
      
      -- rc serial dac interface
      dac_dat        : out std_logic_vector (7 downto 0); 
      dac_clk       : out std_logic_vector (7 downto 0);
      bias_dac_ncs   : out std_logic_vector (7 downto 0); 
      offset_dac_ncs : out std_logic_vector (7 downto 0); 

      -- rc serial dac interface
      dac_FB1_dat    : out std_logic_vector (13 downto 0);
      dac_FB2_dat    : out std_logic_vector (13 downto 0);
      dac_FB3_dat    : out std_logic_vector (13 downto 0);
      dac_FB4_dat    : out std_logic_vector (13 downto 0);
      dac_FB5_dat    : out std_logic_vector (13 downto 0);
      dac_FB6_dat    : out std_logic_vector (13 downto 0);
      dac_FB7_dat    : out std_logic_vector (13 downto 0);
      dac_FB8_dat    : out std_logic_vector (13 downto 0);

      dac_FB_clk   : out std_logic_vector (7 downto 0);     
      
      -- SRAM bank interface
      sram_addr : out std_logic_vector(19 downto 0);
      sram_data : inout std_logic_vector(15 downto 0);
      sram_nbhe : out std_logic;
      sram_nble : out std_logic;
      sram_noe  : out std_logic;
      sram_nwe  : out std_logic;
      sram_ncs  : out std_logic;
            
      --test pins
      smb_clk: out std_logic; 
      mictor : out std_logic_vector(31 downto 0));
end rc_test;

architecture behaviour of rc_test is
   
   component pll
   port(inclk0 : in std_logic;
        c0 : out std_logic;
        c1 : out std_logic;
        e0 : out std_logic);
   end component;

   signal zero : std_logic;
   signal one : std_logic;
   
   signal clk : std_logic;   
   signal rst : std_logic;
   signal int_rst : std_logic;
   
   signal dip : std_logic_vector(1 downto 0);
   signal dac_test_ncs: std_logic_vector(31 downto 0);
   signal dac_test_sclk: std_logic_vector(31 downto 0);
   signal dac_test_data: std_logic_vector(31 downto 0);


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
   constant MAX_STATES : integer := 11;

   constant INDEX_RESET      : integer := 0;
   constant INDEX_IDLE       : integer := 1;
   constant INDEX_TX_A       : integer := 2;
   constant INDEX_TX_B       : integer := 3;
   constant INDEX_RX_CMD     : integer := 4;
   constant INDEX_RX_SYNC    : integer := 5;
   constant INDEX_RX_SPARE   : integer := 6;     
   constant INDEX_DEBUG      : integer := 7;
   constant INDEX_SDAC       : integer := 8;
   constant INDEX_PDAC       : integer := 9;
   constant INDEX_SRAM       : integer := 10;
         
   constant SEL_RESET      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RESET => '1', others => '0');
   constant SEL_IDLE       : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_IDLE => '1', others => '0');
   constant SEL_TX_A       : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_TX_A => '1', others => '0');
   constant SEL_TX_B       : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_TX_B => '1', others => '0');
   constant SEL_RX_CMD     : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RX_CMD => '1', others => '0');
   constant SEL_RX_SYNC    : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RX_SYNC => '1', others => '0');
   constant SEL_RX_SPARE   : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RX_SPARE => '1', others => '0');         
   constant SEL_DEBUG      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_DEBUG => '1', others => '0');
   constant SEL_SDAC       : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_SDAC => '1', others => '0');
   constant SEL_PDAC       : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_PDAC => '1', others => '0');
   constant SEL_SRAM       : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_SRAM => '1', others => '0');
   
   constant DONE_NULL       : std_logic_vector(MAX_STATES - 1 downto 0) := (others => '0');
   constant DONE_RESET      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RESET => '1', others => '0');
   constant DONE_IDLE       : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_IDLE => '1', others => '0');
   constant DONE_TX_A       : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_TX_A => '1', others => '0');
   constant DONE_TX_B       : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_TX_B => '1', others => '0');
   constant DONE_RX_CMD     : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RX_CMD => '1', others => '0');
   constant DONE_RX_SYNC    : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RX_SYNC => '1', others => '0');
   constant DONE_RX_SPARE   : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RX_SPARE => '1', others => '0'); 
   constant DONE_DEBUG      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_DEBUG => '1', others => '0');
   constant DONE_SDAC       : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_SDAC => '1', others => '0');
   constant DONE_PDAC       : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_PDAC => '1', others => '0');
   constant DONE_SRAM       : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_SRAM => '1', others => '0');   

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
   signal test_dac_ncs      : std_logic_vector (7 downto 0);
   signal test_dac_clk     : std_logic_vector (7 downto 0);
   signal test_dac_data     : std_logic_vector (7 downto 0);   
   
   signal test_data : std_logic_vector(31 downto 0);
   signal spi_start : std_logic;

   signal rx_clk : std_logic;
   signal dac_test_mode : std_logic_vector(1 downto 0);
   
   signal dummy, pass, fail: std_logic;
   
begin
   clk_gen : pll
      port map(inclk0 => inclk,
               c0 => clk,
               c1 => rx_clk,
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
   reset_state : rc_test_reset
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
   idle_state : rc_test_idle
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
--               rx_clk_i  => rx_clk,
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
      generic map(WIDTH => 32)
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
               
   sram : sram_test_wrapper 
      port map(-- test control signals
               rst_i    => rst,
               clk_i    => clk,
               en_i     => sel(INDEX_SRAM),
               done_o   => done(INDEX_SRAM),
                
               -- RS232 signals
                
               -- physical pins
               addr_o   => sram_addr,
               data_bi  => sram_data,
               n_ble_o  => sram_nbhe,
               n_bhe_o  => sram_nble,
               n_oe_o   => sram_noe, 
               n_ce1_o  => sram_ncs, 
               ce2_o    => dummy, 
               n_we_o   => sram_nwe,
               pass     => pass,
               fail     => fail);               
               
   rc_serial_dac : rc_serial_dac_test_wrapper
      port map(
               -- basic signals
               rst_i     => rst,
               clk_i     => clk,
               en_i      => sel(INDEX_SDAC),
               mode      => dac_test_mode,
               done_o    => done(INDEX_SDAC),
               
               -- transmitter signals removed!
                         
               -- extended signals
               dac_clk_o => test_dac_clk,
               dac_dat_o => test_dac_data,
               dac_ncs_o => test_dac_ncs);

   rc_parallel_dac : rc_parallel_dac_test_wrapper
      port map(rst_i       => rst,
               clk_i       => clk,
               en_i        => sel(INDEX_PDAC),
               mode        => dac_test_mode,               
               done_o      => done(INDEX_PDAC),
               
               dac0_dat_o  => dac_FB1_dat,
               dac1_dat_o  => dac_FB2_dat,
               dac2_dat_o  => dac_FB3_dat,
               dac3_dat_o  => dac_FB4_dat,
               dac4_dat_o  => dac_FB5_dat,
               dac5_dat_o  => dac_FB6_dat,
               dac6_dat_o  => dac_FB7_dat,
               dac7_dat_o  => dac_FB8_dat,
               dac_clk_o   => dac_FB_clk);
               
   dac_dat        <= test_dac_data;
   dac_clk       <= test_dac_clk;
   bias_dac_ncs   <= test_dac_ncs;
   offset_dac_ncs <= test_dac_ncs;
   
   zero <= '0';
   one <= '1';                         
   rst <= not n_rst or int_rst;
   test_data <= "10110000000010111111101011001110";  -- 0xB00BFACE
   
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
   
   -- cmd_proc is our main processing state machine
   cmd_proc : process (rst, clk)
   begin
      if (rst = '1') then
         int_rst <= '0';
         sel <= SEL_RESET;
         cmd_state <= RESET;
         dac_test_mode  <= "00";
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
                  
               elsif(cmd1 = CMD_DEBUG) then
                  sel <= SEL_DEBUG;
               
               elsif(cmd1 = CMD_SRAM) then
                  sel <= SEL_SRAM;
               elsif(cmd1 = CMD_RESET) then
                  int_rst <= '1';
                  
               elsif(cmd1 = CMD_SERIALDAC) then
                   if (cmd2 = CMD_DAC_FIXED) then
                         dac_test_mode <= "00";
	                 sel <= SEL_SDAC;
                   elsif (cmd2 = CMD_DAC_RAMP) then
                      dac_test_mode <= "01";
                      sel <= SEL_SDAC;               
                   end if;   
               elsif(cmd1 = CMD_PARALLELDAC) then
                   if (cmd2 = CMD_DAC_FIXED) then
                         dac_test_mode <= "00";
	                 sel <= SEL_PDAC;
                   elsif (cmd2 = CMD_DAC_RAMP) then
                      dac_test_mode <= "01";
                      sel <= SEL_PDAC;             
                   elsif (cmd2 = CMD_DAC_SQUARE) then
                      dac_test_mode <= "10";
                      sel <= SEL_PDAC;                                   
                   end if;                     
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

   smb_clk <= pass;
   mictor(4) <= sel(INDEX_SRAM);
   mictor(6) <= dac_test_ncs(0);
   mictor(8) <= dac_test_sclk(0);
   mictor(10) <= dac_test_data(0);
end behaviour;
