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

library work;
use work.async_pack.all;
use work.bc_test_pack.all;

entity bc_test is
   port(
      n_rst : in std_logic;
      
      -- clock signals
      inclk  : in std_logic;
      outclk : out std_logic;
      
      -- RS232 interface
      rs232_tx : out std_logic;
      rs232_rx : in std_logic;
            
      -- LVDS interfaces
      lvds_txa  : out std_logic;
      lvds_txb  : out std_logic;
      lvds_cmd   : in std_logic;
      lvds_sync  : in std_logic;
      lvds_spare : in std_logic;
      
      -- bc dac interface
      dac_data  : out std_logic_vector (31 downto 0); 
      dac_ncs  : out std_logic_vector (31 downto 0); 
      dac_sclk  : out std_logic_vector (31 downto 0);
--      dac_nclr : out std_logic;
      
      lvds_dac_data : out std_logic;
      lvds_dac_ncs : out std_logic;
      lvds_dac_sclk : out std_logic;
      --test pins
      test : out std_logic_vector(16 downto 3));
end bc_test;

architecture behaviour of bc_test is
   
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
   constant INDEX_DAC_FIX    : integer := 8;
   constant INDEX_DAC_RAMP   : integer := 9;
   constant INDEX_DAC_XTALK  : integer := 10;
         
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
   constant SEL_DAC_XTALK  : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_DAC_XTALK => '1', others => '0');
   
   constant DONE_NULL       : std_logic_vector(MAX_STATES - 1 downto 0) := (others => '0');
   constant DONE_RESET      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RESET => '1', others => '0');
   constant DONE_IDLE       : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_IDLE => '1', others => '0');
   constant DONE_TX_A       : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_TX_A => '1', others => '0');
   constant DONE_TX_B       : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_TX_B => '1', others => '0');
   constant DONE_RX_CMD     : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RX_CMD => '1', others => '0');
   constant DONE_RX_SYNC    : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RX_SYNC => '1', others => '0');
   constant DONE_RX_SPARE   : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_RX_SPARE => '1', others => '0'); 
   constant DONE_DEBUG      : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_DEBUG => '1', others => '0');
   constant DONE_DAC_FIX    : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_DAC_FIX => '1', others => '0');
   constant DONE_DAC_RAMP   : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_DAC_RAMP => '1', others => '0');
   constant DONE_DAC_XTALK  : std_logic_vector(MAX_STATES - 1 downto 0) := (INDEX_DAC_XTALK => '1', others => '0');

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
   signal fix_dac_ncs   : std_logic_vector (31 downto 0);
   signal fix_dac_sclk  : std_logic_vector (31 downto 0);
   signal fix_dac_data  : std_logic_vector (31 downto 0);
   signal fix_lvds_dac_ncs   : std_logic;
   signal fix_lvds_dac_sclk  : std_logic;
   signal fix_lvds_dac_data  : std_logic;
   signal ramp_dac_ncs       : std_logic_vector (31 downto 0);
   signal ramp_dac_sclk      : std_logic_vector (31 downto 0);
   signal ramp_dac_data      : std_logic_vector (31 downto 0);
   signal ramp_lvds_dac_ncs  : std_logic;
   signal ramp_lvds_dac_sclk : std_logic;
   signal ramp_lvds_dac_data : std_logic;
   signal xtalk_dac_ncs      : std_logic_vector (31 downto 0);
   signal xtalk_dac_sclk     : std_logic_vector (31 downto 0);
   signal xtalk_dac_data     : std_logic_vector (31 downto 0);
   signal xtalk_lvds_dac_ncs : std_logic;
   signal xtalk_lvds_dac_sclk: std_logic;
   signal xtalk_lvds_dac_data: std_logic;
   
   
   signal test_data : std_logic_vector(31 downto 0);
   signal spi_start : std_logic;
   signal fix_spi_start  : std_logic;   
   signal ramp_spi_start : std_logic;
   signal xtalk_spi_start: std_logic;

   signal rx_clk : std_logic;
   signal dac_test_mode : std_logic_vector(1 downto 0);
   
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
   reset_state : all_test_reset
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
   idle_state : all_test_idle
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
               rx_clk_i  => rx_clk,
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
               rx_clk_i  => rx_clk,
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
               rx_clk_i  => rx_clk,
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
               
   dac_fix : bc_dac_ctrl_test_wrapper
      port map(
               -- basic signals
               rst_i     => rst,
               clk_i     => clk,
               en_i      => sel(INDEX_DAC_FIX),
               done_o    => done(INDEX_DAC_FIX),
               
               -- transmitter signals removed!
                         
               -- extended signals
               dac_dat_o => fix_dac_data,
               dac_ncs_o => fix_dac_ncs,
               dac_clk_o => fix_dac_sclk,
                           
               lvds_dac_dat_o => fix_lvds_dac_data,
               lvds_dac_ncs_o => fix_lvds_dac_ncs,
               lvds_dac_clk_o => fix_lvds_dac_sclk,

               spi_start_o    => fix_spi_start
               );   

   dac_ramp :  bc_dac_ramp_test_wrapper
      port map(
               -- basic signals
               rst_i     => rst,
               clk_i     => clk,
               en_i      => sel(INDEX_DAC_RAMP),
               done_o    => done(INDEX_DAC_RAMP),
               
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

    dac_xtalk :  bc_dac_xtalk_test_wrapper
      port map(
               -- basic signals
               rst_i     => rst,
               clk_i     => clk,
               en_i      => sel(INDEX_DAC_XTALK),
               mode      => dac_test_mode(0),    -- dac_test_mode ="02" passes 0 to the block indicating odd channels square wave
               done_o    => done(INDEX_DAC_XTALK),
               
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
            
   with dac_test_mode select
      dac_test_data <= fix_dac_data       when "00",
                       ramp_dac_data      when "01",
                       xtalk_dac_data     when "10",
                       xtalk_dac_data     when "11";
                       
   with dac_test_mode select
      dac_test_sclk <= fix_dac_sclk       when "00",
                       ramp_dac_sclk      when "01",
                       xtalk_dac_sclk     when "10",
                       xtalk_dac_sclk     when "11";
   with dac_test_mode select
      dac_test_ncs  <= fix_dac_ncs        when "00",
                       ramp_dac_ncs       when "01",
                       xtalk_dac_ncs      when "10",
                       xtalk_dac_ncs      when "11";

   with dac_test_mode select
      spi_start     <= fix_spi_start      when "00",
                       ramp_spi_start     when "01",
                       xtalk_spi_start    when "10",
                       xtalk_spi_start    when "11";
   
--   dac_test_ncs <= fix_dac_ncs;
--   dac_test_data <= fix_dac_data;
--   dac_test_sclk <= fix_dac_sclk;

   dac_ncs <= dac_test_ncs;
   dac_sclk <= dac_test_sclk;
   dac_data <= dac_test_data;
   
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
                  
               elsif(cmd1 = CMD_RESET) then
                  int_rst <= '1';
                  
               elsif(cmd1 = CMD_DAC_FIX) then
                  dac_test_mode <= "00";
	              sel <= SEL_DAC_FIX;               
                   
               elsif(cmd1 = CMD_DAC_RAMP) then
                  dac_test_mode <= "01";
                  sel <= SEL_DAC_RAMP;               

               elsif(cmd1 = CMD_DAC_XTALK) then
                  if cmd2 = CMD_XTALK_ODD then
                      dac_test_mode <= "10";
                      sel <= SEL_DAC_XTALK;               
                  elsif cmd2 = CMD_XTALK_EVEN then
                      dac_test_mode <= "11";
                      sel <= SEL_DAC_XTALK;               
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

   test(3) <= sel(INDEX_DAC_XTALK);
   test(4) <= done(INDEX_DAC_XTALK);
   test(5) <= dac_test_ncs(0);
   test(6) <= dac_test_ncs(1);
   test(7) <= dac_test_sclk(0);
   test(8) <= dac_test_sclk(1);
   test(9) <= dac_test_data(0);
   test(10) <= dac_test_data(1);
   test(14) <= spi_start;
end behaviour;
