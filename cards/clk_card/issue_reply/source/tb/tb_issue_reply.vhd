-- Copyright (c) 2003 SCUBA-2 Project
-- All Rights Reserved
-- THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE SCUBA-2 Project
-- The copyright notice above does not evidence any
-- actual or intended publication of such source code.
-- SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
-- REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
-- MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
-- PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
-- THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.
-- For the purposes of this code the SCUBA-2 Project consists of the
-- following organisations.
-- UKATC, Royal Observatory, Blackford Hill Edinburgh EH9 3HJ
-- UBC, University of British Columbia, Physics & Astronomy Department,
-- Vancouver BC, V6T 1Z1
-- 
--
-- <revision control keyword substitutions e.g. $Id: tb_issue_reply.vhd,v 1.3 2004/07/05 23:41:04 jjacob Exp $>
--
-- Project: Scuba 2
-- Author: David Atkinson
-- Organisation: UK ATC
--
-- Title
-- tb_fibre_rx
--
-- Description:
-- Test bed for fibre_rx
--
-- Revision history:
-- <date $Date: 2004/07/05 23:41:04 $> - <text> - <initials $Author: jjacob $>
-- <log $log$>
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

library work;
use work.fibre_rx_pack.all;
use work.issue_reply_pack.all;


entity tb_issue_reply is     
end tb_issue_reply;

architecture tb of tb_issue_reply is 


 
    signal   t_rst_i       : std_logic;
    signal   t_clk_i       : std_logic := '0';
      
      
      -- inputs from the fibre
    signal  t_rx_data_i   : std_logic_vector (7 DOWNTO 0);
    signal  t_nRx_rdy_i   : std_logic;
    signal  t_rvs_i       : std_logic;
    signal  t_rso_i       : std_logic;
    signal  t_rsc_nRd_i   : std_logic;        
--    signal  t_nTrp_i      : std_logic;
--    signal  t_ft_clkw_i   : std_logic; 
        
      -- outputs to the fibre
--    signal  t_tx_data_o   : std_logic_vector (7 DOWNTO 0);      
--    signal  t_tsc_nTd_o   : std_logic;
--    signal  t_nFena_o     : std_logic;
    signal  t_cksum_err_o : std_logic;
      
      -- outputs to the micro-instruction sequence generator
      -- these signals will be absorbed when the issue_reply block's boundary extends
      -- to include u-op sequence generator.
    signal  t_card_addr_o       : std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);   -- specifies which card the command is targetting
    signal  t_parameter_id_o    : std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);      -- comes from param_id_i, indicates which device(s) the command is targetting
    signal  t_data_size_o       : std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);   -- num_data_i, indicates number of 16-bit words of data
    signal  t_data_o            : std_logic_vector (DATA_BUS_WIDTH-1 downto 0);        -- data will be passed straight thru
    signal  t_data_clk_o        : std_logic;
    signal  t_macro_instr_rdy_o : std_logic;
      
    signal  t_m_op_seq_num_o    : std_logic_vector(7 downto 0);
    signal  t_frame_seq_num_o   : std_logic_vector(31 downto 0);
    signal  t_frame_sync_num_o  : std_logic_vector(7 downto 0);
      
      -- input from the micro-op sequence generator
    signal  t_ack_i             : std_logic; 


 
   constant clk_prd      : TIME := 20 ns;    -- 50Mhz clock
   constant preamble1    : std_logic_vector (7 downto 0)  := X"A5";
   constant preamble2    : std_logic_vector (7 downto 0)  := X"5A";
   constant pre_fail     : std_logic_vector (7 downto 0)  := X"55";
   constant command_wb   : std_logic_vector (31 downto 0) := X"20205742";

   constant command_go   : std_logic_vector (31 downto 0) := X"2020474F";
   --constant address_id   : std_logic_vector (31 downto 0) := X"0002015C";
   signal address_id   : std_logic_vector (31 downto 0) := X"0002015C";
   
   constant ret_dat_s_cmd      : std_logic_vector (31 downto 0) := X"00000034";  -- card id=0, ret_dat_s command
   constant ret_dat_s_num_data : std_logic_vector (31 downto 0) := X"00000002";  -- 2 data words, start and stop frame #
   constant ret_dat_s_start    : std_logic_vector (31 downto 0)  := X"00000008";
   constant ret_dat_s_stop     : std_logic_vector (31 downto 0)  := X"00000088";
   
   constant ret_dat_cmd        : std_logic_vector (31 downto 0) := X"00040030";  -- card id=4, ret_dat command
   
   constant simple_cmd         : std_logic_vector (31 downto 0) := x"00070020"; -- bias card 1, flux feedback command
   
   constant no_std_data  : std_logic_vector (31 downto 0) := X"00000001";
   constant data_block   : positive := 58;
   constant data_word1   : std_logic_vector (31 downto 0) := X"00001234";
   constant data_word2   : std_logic_vector (31 downto 0) := X"00005678";
   constant check_err    : std_logic_vector (31 downto 0) := X"fafafafa";
 
   
   signal   checksum     : std_logic_vector(31 downto 0):= X"00000000";
   signal   command      : std_logic_vector (31 downto 0);
   
   signal   data_valid   : std_logic_vector (31 downto 0); -- used to be set to constant X"00000028"
   signal   data         : std_logic_vector (31 downto 0) := X"00000001";--integer := 1;
  
   signal   count        : integer;
   
component issue_reply

port(

      -- global signals
      rst_i        : in     std_logic;
      clk_i        : in     std_logic;
      
      
      -- inputs from the fibre
      rx_data_i   : in     std_logic_vector (7 DOWNTO 0);
      nRx_rdy_i   : in     std_logic;
      rvs_i       : in     std_logic;
      rso_i       : in     std_logic;
      rsc_nRd_i   : in     std_logic;        
--      nTrp_i      : in     std_logic;
--      ft_clkw_i   : in     std_logic; 
--      
--      -- outputs to the fibre
--      tx_data_o   : out    std_logic_vector (7 DOWNTO 0);      
--      tsc_nTd_o   : out    std_logic;
--      nFena_o     : out    std_logic;
      cksum_err_o : out    std_logic;
      
      -- outputs to the micro-instruction sequence generator
      -- these signals will be absorbed when the issue_reply block's boundary extends
      -- to include u-op sequence generator.
      card_addr_o       :  out std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);   -- specifies which card the command is targetting
      parameter_id_o    :  out std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);      -- comes from param_id_i, indicates which device(s) the command is targetting
      data_size_o       :  out std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);   -- num_data_i, indicates number of 16-bit words of data
      data_o            :  out std_logic_vector (DATA_BUS_WIDTH-1 downto 0);        -- data will be passed straight thru
      data_clk_o        :  out std_logic;
      macro_instr_rdy_o :  out std_logic;
      
      m_op_seq_num_o    :  out std_logic_vector(7 downto 0);
      frame_seq_num_o   :  out std_logic_vector(31 downto 0);
      frame_sync_num_o  :  out std_logic_vector(7 downto 0);
      
      -- input from the micro-op sequence generator
      ack_i             : in std_logic     

   ); 
     
end component;

    
begin




dut : issue_reply

port map(

      -- global signals
      rst_i        => t_rst_i,
      clk_i        => t_clk_i,
      
      
      -- inputs from the fibre
      rx_data_i   => t_rx_data_i,
      nRx_rdy_i   => t_nrx_rdy_i,
      rvs_i       => t_rvs_i,
      rso_i       => t_rso_i,
      rsc_nRd_i   => t_rsc_nrd_i,
--      nTrp_i      => t_ntrp_i,
--      ft_clkw_i   => t_ft_clkw_i,
--      
--      -- outputs to the fibre
--      tx_data_o   => t_tx_data_o,
--      tsc_nTd_o   => t_tsc_ntd_o,
--      nFena_o     => t_nfena_o,
      cksum_err_o => t_cksum_err_o,
      
      -- outputs to the micro-instruction sequence generator
      -- these signals will be absorbed when the issue_reply block's boundary extends
      -- to include u-op sequence generator.
      card_addr_o       => t_card_addr_o,        -- specifies which card the command is targetting
      parameter_id_o    => t_parameter_id_o,     -- comes from param_id_i, indicates which device(s) the command is targetting
      data_size_o       => t_data_size_o,        -- num_data_i, indicates number of 16-bit words of data
      data_o            => t_data_o,             -- data will be passed straight thru
      data_clk_o        => t_data_clk_o,
      macro_instr_rdy_o => t_macro_instr_rdy_o,
      
      m_op_seq_num_o    => t_m_op_seq_num_o,
      frame_seq_num_o   => t_frame_seq_num_o,
      frame_sync_num_o  => t_frame_sync_num_o,
      
      -- input from the micro-op sequence generator
      ack_i             => t_ack_i

   ); 
     


 
 -- set up hotlink receiver signals 
      t_rvs_i         <= '0';  -- no violation
      t_rso_i         <= '1';  -- status ok
      t_rsc_nRd_i     <= '0';  -- data     
          
------------------------------------------------
-- Create test bench clock
-------------------------------------------------
  
   t_clk_i <= not t_clk_i after clk_prd/2;

------------------------------------------------
-- Create test bench stimuli
-------------------------------------------------
   
stimuli : process
  
------------------------------------------------
-- Stimulus procedures
-------------------------------------------------
      
   procedure do_reset is
   begin
      t_rst_i <= '1';
      wait for clk_prd*5 ;
      t_rst_i <= '0';
      wait for clk_prd*5 ;
   
      assert false report " Resetting the DUT." severity NOTE;
   end do_reset;
--------------------------------------------------
  
   procedure load_preamble is
   begin
   
   for I in 0 to 3 loop
      t_nrx_rdy_i    <= '1';  -- data not ready (active low)
      t_rx_data_i  <= preamble1;
      wait for 10 NS;
      t_nrx_rdy_i    <= '0';
      wait for 30 NS;
   end loop;   
   
   for I in 0 to 3 loop
      t_nrx_rdy_i    <= '1';  -- data not ready (active low)
      t_rx_data_i  <= preamble2;
      wait for 10 NS;
      t_nrx_rdy_i    <= '0';
      wait for 30 NS;
   end loop;   
    
   assert false report "preamble OK" severity NOTE;
   end load_preamble;
   
  ---------------------------------------------------------    
 
   procedure load_command is 
   begin
   
      checksum  <= command;
    
      t_nrx_rdy_i   <= '1';
      t_rx_data_i   <= command(7 downto 0);
      wait for 10 ns;
      t_nrx_rdy_i   <= '0';
      wait for 30 ns;
      
      t_nrx_rdy_i   <= '1';
      t_rx_data_i   <= command(15 downto 8);
      wait for 10 ns;
      t_nrx_rdy_i   <= '0';
      wait for 30 ns;
      
      t_nrx_rdy_i   <= '1';
      t_rx_data_i   <= command(23 downto 16);
      wait for 10 ns;
      t_nrx_rdy_i   <= '0';
      wait for 30 ns;
      
      t_nrx_rdy_i   <= '1';
      t_rx_data_i   <= command(31 downto 24);
      wait for 10 ns;
      t_nrx_rdy_i   <= '0';
      wait for 30 ns;
      
    
      assert false report "command code loaded" severity NOTE;
      wait for 160 ns;   
     
  -- load up address_id

      checksum <= checksum XOR address_id;
     
       t_nrx_rdy_i   <= '1';
      t_rx_data_i   <= address_id(7 downto 0);
      wait for 10 ns;
      t_nrx_rdy_i   <= '0';
      wait for 30 ns;
      
      t_nrx_rdy_i   <= '1';
      t_rx_data_i   <= address_id(15 downto 8);
      wait for 10 ns;
      t_nrx_rdy_i   <= '0';
      wait for 30 ns;
      
      t_nrx_rdy_i   <= '1';
      t_rx_data_i   <= address_id(23 downto 16);
      wait for 10 ns;
      t_nrx_rdy_i   <= '0';
      wait for 30 ns;
      
      t_nrx_rdy_i   <= '1';
      t_rx_data_i   <= address_id(31 downto 24);
      wait for 10 ns;
      t_nrx_rdy_i   <= '0';
      wait for 30 ns;
     
     assert false report "address id loaded" severity NOTE;
     wait for 160 ns ;
     
    -- load up data valid 
   
       
      checksum <= checksum XOR data_valid;
  
      t_nrx_rdy_i   <= '1';
      t_rx_data_i <= data_valid(7 downto 0);
      wait for 10 ns;
      t_nrx_rdy_i   <= '0';
      wait for 30 ns;
      
      t_nrx_rdy_i   <= '1';
      t_rx_data_i <= data_valid(15 downto 8);
      wait for 10 ns;
      t_nrx_rdy_i   <= '0';
      wait for 30 ns;
      
      t_nrx_rdy_i   <= '1';
      t_rx_data_i <= data_valid(23 downto 16);
      wait for 10 ns;
      t_nrx_rdy_i   <= '0';
      wait for 30 ns;
      
      t_nrx_rdy_i   <= '1';
      t_rx_data_i <= data_valid(31 downto 24);
      wait for 10 ns;
      t_nrx_rdy_i   <= '0';
      wait for 30 ns;
      
     assert false report "data valid loaded" severity NOTE;
     wait for 160 ns ;
      
      
  
  -- load up data block
  
      wait for 160 ns;

  
  -- first load valid data
      
      for I in 0 to (To_integer((Unsigned(data_valid)))-1) loop
      --for I in 0 to (data_valid-1) loop
      
      t_nrx_rdy_i   <= '1';
--      t_rx_data_i <= std_logic_vector(To_unsigned(data,8));
--      checksum (7 downto 0) <= checksum (7 downto 0) XOR std_logic_vector(To_unsigned(data,8));
      
      t_rx_data_i <= data(7 downto 0);
      checksum (7 downto 0) <= checksum (7 downto 0) XOR data(7 downto 0);
      wait for 10 ns;
      t_nrx_rdy_i   <= '0';
      wait for 30 ns;
      
      t_nrx_rdy_i   <= '1';
--      t_rx_data_i <= std_logic_vector(To_unsigned(data,8));
--      checksum (15 downto 8) <= checksum (15 downto 8) XOR std_logic_vector(To_unsigned(data,8));
      
      t_rx_data_i <= data(15 downto 8);
      checksum (15 downto 8) <= checksum (15 downto 8) XOR data(15 downto 8);
      wait for 10 ns;
      t_nrx_rdy_i   <= '0';
      wait for 30 ns;
      
      t_nrx_rdy_i   <= '1';
--      t_rx_data_i <= std_logic_vector(To_unsigned(data,8));
--      checksum (23 downto 16) <= checksum (23 downto 16) XOR std_logic_vector(To_unsigned(data,8));

      t_rx_data_i <= data(23 downto 16);
      checksum (23 downto 16) <= checksum (23 downto 16) XOR data(23 downto 16);
      wait for 10 ns;
      t_nrx_rdy_i   <= '0';
      wait for 30 ns;
      
      t_nrx_rdy_i   <= '1';
--      t_rx_data_i <= std_logic_vector(To_unsigned(data,8));
--      checksum (31 downto 24) <= checksum (31 downto 24) XOR std_logic_vector(To_unsigned(data,8));
      
      t_rx_data_i <= data(31 downto 24);
      checksum (31 downto 24) <= checksum (31 downto 24) XOR data(31 downto 24);
      wait for 10 ns;
      t_nrx_rdy_i   <= '0';
      
      case address_id is
         when ret_dat_s_cmd => data <= ret_dat_s_stop;
         when ret_dat_cmd   => data <= (others => '0');
         when others        => data <= data + 1;
      end case;
      
      wait for 30 ns;
      
    end loop;
    
    for J in (To_integer((Unsigned(data_valid)))) to data_block-1 loop
     
        
      t_nrx_rdy_i   <= '1';
      t_rx_data_i <= X"00";
      wait for 10 ns;
      t_nrx_rdy_i   <= '0';
      wait for 30 ns;
      
      t_nrx_rdy_i   <= '1';
      t_rx_data_i <= X"00";
      wait for 10 ns;
      t_nrx_rdy_i   <= '0';
      wait for 30 ns;
      
      t_nrx_rdy_i   <= '1';
      t_rx_data_i <= X"00";
      wait for 10 ns;
      t_nrx_rdy_i   <= '0';
      wait for 30 ns;
      
      t_nrx_rdy_i   <= '1';
      t_rx_data_i <= X"00";
      wait for 10 ns;
      t_nrx_rdy_i   <= '0';
      wait for 30 ns;
         
  
    end loop;

       assert false report "data words loaded to memory...." severity NOTE;

    end load_command;
    
------------------------------------------------------

   procedure load_checksum is
    
      begin
   
      
         
      t_nrx_rdy_i   <= '1';
      t_rx_data_i <= checksum(7 downto 0);
      wait for 10 ns;
      t_nrx_rdy_i   <= '0';
      wait for 30 ns;
      
      t_nrx_rdy_i   <= '1';
      t_rx_data_i <= checksum(15 downto 8);
      wait for 10 ns;
      t_nrx_rdy_i   <= '0';
      wait for 30 ns;
      
      t_nrx_rdy_i   <= '1';
      t_rx_data_i <= checksum(23 downto 16);
      wait for 10 ns;
      t_nrx_rdy_i   <= '0';
      wait for 30 ns;
      
      t_nrx_rdy_i   <= '1';
      t_rx_data_i <= checksum(31 downto 24);
      wait for 10 ns;
      t_nrx_rdy_i   <= '0';
      wait for 30 ns;
      
      
      assert false report "checksum loaded...." severity NOTE;  
      
   end load_checksum;
       
  
 --------------------------------------------------------
 ---- BEGIN TEST
 ------------------------------------------------------      
       
   begin
      
      do_reset; 
      
      command <= command_wb;
      data_valid <= X"00000028";
      t_ack_i <= '0';
      load_preamble;
      load_command;
      load_checksum;
      
      --wait until cmd_rdy = '1';
      --wait for clk_prd;
      wait until t_macro_instr_rdy_o = '1';
      wait for clk_prd;
      t_ack_i <= '1'; 
      assert false report "Command Acknowledged....." severity NOTE;
      wait until t_macro_instr_rdy_o = '0';
      t_ack_i <= '0';
      
      -- load a wb command with checksum error
      
--      command <= command_wb;
--      load_preamble;
--      load_command;
--      checksum <= check_err;
--      wait for 100 ns;
--      load_checksum;
--      wait until t_cksum_err_o = '1';
--      wait until t_cksum_err_o = '0';
--      assert false report "command 2 finished with check err detected" severity NOTE;
--      
      --wait until cmd_data = X"28282828";      
      --wait for clk_prd*10;
      
      -- do a return data setup command
      address_id <= ret_dat_s_cmd;
      data_valid <= ret_dat_s_num_data;
      data <= ret_dat_s_start;
      t_ack_i <= '0';
      load_preamble;
      load_command;
      load_checksum;
      
      --wait until cmd_rdy = '1';
      --wait for clk_prd;
      --wait until t_macro_instr_rdy_o = '1';
      wait for 10*clk_prd;
      --t_ack_i <= '1'; 
      assert false report "Performed the RET_DAT_S command....." severity NOTE;
      --wait until t_macro_instr_rdy_o = '0';
      --t_ack_i <= '0';      
      wait for 1500 ns;
 
 
      -- do a return data using the start and stop frames from the setup command
      command <= command_go;
      address_id <= ret_dat_cmd;
      data_valid <= no_std_data;
      data <= (others=>'0');
      t_ack_i <= '0';
      load_preamble;
      load_command;
      load_checksum;
      
      --wait until cmd_rdy = '1';
      --wait for clk_prd;
      count <= 0;
      for J in (To_integer((Unsigned(ret_dat_s_start)))) to (To_integer((Unsigned(ret_dat_s_stop)))) loop
     
         wait until t_macro_instr_rdy_o = '1';
         wait for 10*clk_prd;
         t_ack_i <= '1'; 
         assert false report "Performed the RET_DAT command....." severity NOTE;
         count <= count + 1;
         wait until t_macro_instr_rdy_o = '0';
         t_ack_i <= '0';      

      end loop;
      assert false report "Done the RET_DAT command....." severity NOTE;
      wait for 100*clk_prd;


      -- perform another ret_dat command, but this one gets interrupted by a simple command
      count <= 0;
      
      command <= command_go;
      address_id <= ret_dat_cmd;
      data_valid <= no_std_data;
      data <= (others=>'0');
      t_ack_i <= '0';
      load_preamble;
      load_command;
      load_checksum;
      
      
      for J in (To_integer((Unsigned(ret_dat_s_start)))) to (To_integer((Unsigned(ret_dat_s_stop-51)))) loop
     
         wait until t_macro_instr_rdy_o = '1';
         wait for 10*clk_prd;
         t_ack_i <= '1'; 
         assert false report "Performed the second RET_DAT command....." severity NOTE;
         count <= count + 1;
         wait until t_macro_instr_rdy_o = '0';
         t_ack_i <= '0';      

      end loop;
      
      wait until t_macro_instr_rdy_o = '1';
      wait for 10*clk_prd;
      
      -- the 'simple command' inturrupting the ret_dat
      assert false report "The simple command is loading and interrupting the second RET_DAT command....." severity NOTE;
      command <= command_wb;
      address_id <= simple_cmd;
      data_valid <= X"00000028";
      load_preamble;
      load_command;
      load_checksum;
      
      wait for 3000 ns;  
      -- finish off the current ret_dat command (ret_dat_s_stop-50)
      t_ack_i <= '1'; 
      assert false report "Finishing off current RET_DAT command....." severity NOTE;
      count <= count + 1;
      wait until t_macro_instr_rdy_o = '0';
      t_ack_i <= '0';    
      
      -- back to the simple command
      --wait for 1500 ns;
      wait until t_macro_instr_rdy_o = '1';
      wait for clk_prd;
      t_ack_i <= '1'; 
      assert false report "Simple Command Acknowledged....." severity NOTE;
      wait until t_macro_instr_rdy_o = '0';
      t_ack_i <= '0';
      
      -- this is to allow the data to be clocked out
      -- to the cmd_translator
      --wait for 1500 ns;      
      
      --resume with the remainder of the ret_dat commands
      for J in (To_integer((Unsigned(ret_dat_s_stop-49)))) to (To_integer((Unsigned(ret_dat_s_stop)))) loop
     
         wait until t_macro_instr_rdy_o = '1';
         wait for 10*clk_prd;
         t_ack_i <= '1'; 
         assert false report "Performed the second RET_DAT command....." severity NOTE;
         count <= count + 1;
         wait until t_macro_instr_rdy_o = '0';
         t_ack_i <= '0';      

      end loop;      
      
      wait for 100*clk_prd;
      
      assert false report "Simulation done." severity FAILURE;
 

   end process stimuli;
       
   
   
 
end tb;