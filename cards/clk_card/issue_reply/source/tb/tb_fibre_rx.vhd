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
-- <revision control keyword substitutions e.g. $Id: tb_fibre_rx.vhd,v 1.6 2004/09/29 15:06:16 dca Exp $>
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
-- <date $Date: 2004/09/29 15:06:16 $> - <text> - <initials $Author: dca $>
-- <log $log$>


library ieee;
use ieee.std_logic_1164.all;

entity tb_fibre_rx is
end tb_fibre_rx;




-------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.issue_reply_pack.all;

library sys_param;
use sys_param.command_pack.all;

architecture bench of tb_fibre_rx is 

   -- Internal signal declarations
   signal dut_rst      : std_logic;
   signal dut_clk      : std_logic; 

   signal nRx_rdy      : std_logic;
   signal rvs          : std_logic;
   signal rso          : std_logic;
   signal rsc_nRd      : std_logic;
   signal rx_data      : std_logic_vector(RX_FIFO_DATA_WIDTH-1 downto 0);

   signal cmd_code     : std_logic_vector (CMD_CODE_BUS_WIDTH-1 downto 0);
   signal card_id      : std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);
   signal param_id     : std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);
   signal cmd_data     : std_logic_vector (DATA_BUS_WIDTH-1 downto 0);
   signal cksum_err    : std_logic;
   signal cmd_rdy      : std_logic;
   signal data_clk     : std_logic;
   signal num_data     : std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);
   signal cmd_ack      : std_logic;      
   
   
   signal tb_clk         : std_logic := '0';
  
  
  
   
   --constant clk_prd      : TIME := 40 ns;    -- 25Mhz clock
   constant clk_prd      : TIME := 20 ns;    -- 50Mhz clock
   constant DSP_DLY      : TIME := 160 ns;    -- the delay between each 4 bytes issues by the PCI card DSP
   
   constant preamble1    : std_logic_vector (RX_FIFO_DATA_WIDTH-1 downto 0)  := X"A5";
   constant preamble2    : std_logic_vector (RX_FIFO_DATA_WIDTH-1 downto 0)  := X"5A";
   constant pre_fail     : std_logic_vector (RX_FIFO_DATA_WIDTH-1 downto 0)  := X"55";
   constant command_wb   : std_logic_vector (DATA_BUS_WIDTH-1 downto 0) := X"20205742";
   constant command_go   : std_logic_vector (DATA_BUS_WIDTH-1 downto 0) := X"2020474F";
   constant address_id   : std_logic_vector (DATA_BUS_WIDTH-1 downto 0) := X"0002015C";
   constant data_valid   : std_logic_vector (DATA_BUS_WIDTH-1 downto 0) := X"00000028";
   constant no_std_data  : std_logic_vector (DATA_BUS_WIDTH-1 downto 0) := X"00000001";
   constant data_block   : positive := 58;
   constant data_word1   : std_logic_vector (DATA_BUS_WIDTH-1 downto 0) := X"00001234";
   constant data_word2   : std_logic_vector (DATA_BUS_WIDTH-1 downto 0) := X"00005678";
   constant check_err    : std_logic_vector (DATA_BUS_WIDTH-1 downto 0) := X"fafafafa";
 
   signal   data         : integer := 1;
   signal   checksum     : std_logic_vector(DATA_BUS_WIDTH-1 downto 0):= (others => '0');
   signal   command      : std_logic_vector (DATA_BUS_WIDTH-1 downto 0);
  
            
begin

-- Instance port mappings.
   DUT : fibre_rx
   port map( 
      rst_i       => dut_rst,
      clk_i       => tb_clk,
      
      nRx_rdy_i   => nRx_rdy,
      rvs_i       => rvs,    
      rso_i       => rso,
      rsc_nrd_i   => rsc_nRd , 
      rx_data_i   => rx_data,
      cmd_ack_i   => cmd_ack,
      
      cmd_code_o  => cmd_code,
      card_id_o   => card_id,
      param_id_o  => param_id,
      num_data_o  => num_data,
      cmd_data_o  => cmd_data,
      cksum_err_o => cksum_err,
      cmd_rdy_o   => cmd_rdy,
      data_clk_o  => data_clk
      );

 
 -- set up hotlink receiver signals 
      rvs         <= '0';  -- no violation
      rso         <= '1';  -- status ok
      rsc_nRd     <= '0';  -- data     
          
------------------------------------------------
-- Create test bench clock
-------------------------------------------------
  
   tb_clk <= not tb_clk after clk_prd/2;

------------------------------------------------
-- Create test bench stimuli
-------------------------------------------------
   
stimuli : process
  
------------------------------------------------
-- Stimulus procedures
-------------------------------------------------
      
   procedure do_reset is
   begin
      dut_rst <= '1';
      wait for clk_prd*5 ;
      dut_rst <= '0';
      wait for clk_prd*5 ;
   
      assert false report " Resetting the DUT." severity NOTE;
   end do_reset;
--------------------------------------------------
  
   procedure load_preamble is
   begin
   
   for I in 0 to 3 loop
      nRx_rdy    <= '1';  -- data not ready (active low)
      rx_data  <= preamble1;
      wait for 10 NS;
      nRx_rdy    <= '0';
      wait for 30 NS;
   end loop;   
   
   wait for DSP_DLY ;
   
   for I in 0 to 3 loop
      nRx_rdy    <= '1';  -- data not ready (active low)
      rx_data  <= preamble2;
      wait for 10 NS;
      nRx_rdy    <= '0';
      wait for 30 NS;
   end loop;   
   
   wait for DSP_DLY;
    
   assert false report "preamble OK" severity NOTE;
   end load_preamble;
   
  ---------------------------------------------------------    
 
   procedure load_command is 
   begin
   
      checksum  <= command;
    
      nRx_rdy   <= '1';
      rx_data   <= command(7 downto 0);
      wait for 10 ns;
      nRx_rdy   <= '0';
      wait for 30 ns;
      
      nRx_rdy   <= '1';
      rx_data   <= command(15 downto 8);
      wait for 10 ns;
      nRx_rdy   <= '0';
      wait for 30 ns;
      
      nRx_rdy   <= '1';
      rx_data   <= command(23 downto 16);
      wait for 10 ns;
      nRx_rdy   <= '0';
      wait for 30 ns;
      
      nRx_rdy   <= '1';
      rx_data   <= command(31 downto 24);
      wait for 10 ns;
      nRx_rdy   <= '0';
      wait for 30 ns;
      
    
      assert false report "command code loaded" severity NOTE;
      wait for DSP_DLY;           
     
  -- load up address_id

      checksum <= checksum XOR address_id;
     
       nRx_rdy   <= '1';
      rx_data   <= address_id(7 downto 0);
      wait for 10 ns;
      nRx_rdy   <= '0';
      wait for 30 ns;
      
      nRx_rdy   <= '1';
      rx_data   <= address_id(15 downto 8);
      wait for 10 ns;
      nRx_rdy   <= '0';
      wait for 30 ns;
      
      nRx_rdy   <= '1';
      rx_data   <= address_id(23 downto 16);
      wait for 10 ns;
      nRx_rdy   <= '0';
      wait for 30 ns;
      
      nRx_rdy   <= '1';
      rx_data   <= address_id(31 downto 24);
      wait for 10 ns;
      nRx_rdy   <= '0';
      wait for 30 ns;
     
     assert false report "address id loaded" severity NOTE;
     wait for DSP_DLY ;
     
    -- load up data valid 
   
       
      checksum <= checksum XOR data_valid;
  
      nRx_rdy   <= '1';
      rx_data <= data_valid(7 downto 0);
      wait for 10 ns;
      nRx_rdy   <= '0';
      wait for 30 ns;
      
      nRx_rdy   <= '1';
      rx_data <= data_valid(15 downto 8);
      wait for 10 ns;
      nRx_rdy   <= '0';
      wait for 30 ns;
      
      nRx_rdy   <= '1';
      rx_data <= data_valid(23 downto 16);
      wait for 10 ns;
      nRx_rdy   <= '0';
      wait for 30 ns;
      
      nRx_rdy   <= '1';
      rx_data <= data_valid(31 downto 24);
      wait for 10 ns;
      nRx_rdy   <= '0';
      wait for 30 ns;
      
     assert false report "data valid loaded" severity NOTE;
     wait for DSP_DLY ;
      
      
  
  -- load up data block

  
  -- first load valid data
      
      for I in 0 to (To_integer((Unsigned(data_valid)))-1) loop
      
      
      nRx_rdy   <= '1';
      rx_data <= std_logic_vector(To_unsigned(data,8));
      checksum (7 downto 0) <= checksum (7 downto 0) XOR std_logic_vector(To_unsigned(data,8));
      wait for 10 ns;
      nRx_rdy   <= '0';
      wait for 30 ns;
      
      nRx_rdy   <= '1';
      rx_data <= std_logic_vector(To_unsigned(data,8));
      checksum (15 downto 8) <= checksum (15 downto 8) XOR std_logic_vector(To_unsigned(data,8));
      wait for 10 ns;
      nRx_rdy   <= '0';
      wait for 30 ns;
      
      nRx_rdy   <= '1';
      rx_data <= std_logic_vector(To_unsigned(data,8));
      checksum (23 downto 16) <= checksum (23 downto 16) XOR std_logic_vector(To_unsigned(data,8));
      wait for 10 ns;
      nRx_rdy   <= '0';
      wait for 30 ns;
      
      nRx_rdy   <= '1';
      rx_data <= std_logic_vector(To_unsigned(data,8));
      checksum (31 downto 24) <= checksum (31 downto 24) XOR std_logic_vector(To_unsigned(data,8));
      wait for 10 ns;
      nRx_rdy   <= '0';
      data <= data + 1;
      wait for 30 ns;
      
        
      wait for DSP_DLY;
      
    end loop;
    
    for J in (To_integer((Unsigned(data_valid)))) to data_block-1 loop
     
        
      nRx_rdy   <= '1';
      rx_data <= X"00";
      wait for 10 ns;
      nRx_rdy   <= '0';
      wait for 30 ns;
      
      nRx_rdy   <= '1';
      rx_data <= X"00";
      wait for 10 ns;
      nRx_rdy   <= '0';
      wait for 30 ns;
      
      nRx_rdy   <= '1';
      rx_data <= X"00";
      wait for 10 ns;
      nRx_rdy   <= '0';
      wait for 30 ns;
      
      nRx_rdy   <= '1';
      rx_data <= X"00";
      wait for 10 ns;
      nRx_rdy   <= '0';
      wait for 30 ns;
         
         
      wait for DSP_DLY;  
  
    end loop;

       assert false report "data words loaded to memory...." severity NOTE;

    end load_command;
    
------------------------------------------------------

   procedure load_checksum is
    
      begin
   
      
         
      nRx_rdy   <= '1';
      rx_data <= checksum(7 downto 0);
      wait for 10 ns;
      nRx_rdy   <= '0';
      wait for 30 ns;
      
      nRx_rdy   <= '1';
      rx_data <= checksum(15 downto 8);
      wait for 10 ns;
      nRx_rdy   <= '0';
      wait for 30 ns;
      
      nRx_rdy   <= '1';
      rx_data <= checksum(23 downto 16);
      wait for 10 ns;
      nRx_rdy   <= '0';
      wait for 30 ns;
      
      nRx_rdy   <= '1';
      rx_data <= checksum(31 downto 24);
      wait for 10 ns;
      nRx_rdy   <= '0';
      wait for 30 ns;
      
      
      assert false report "checksum loaded...." severity NOTE;  
        
          
   end load_checksum;
       
  
 --------------------------------------------------------
 ---- BEGIN TESTBED
 ------------------------------------------------------      
       
   begin
      
      do_reset; 
      
      command <= command_wb;
      cmd_ack <= '0';
      load_preamble;
      load_command;
      load_checksum;
      
      wait until cmd_rdy = '1';
      wait for clk_prd;
      cmd_ack <= '1'; 
      assert false report "Command Acknowledged....." severity NOTE;
      wait for clk_prd;
      cmd_ack <= '0';
      
      -- load a wb command with checksum error
      
--      command <= command_wb;
--      load_preamble;
--      load_command;
--      checksum <= check_err;
--      wait for 100 ns;
--      load_checksum;
--      wait until cksum_err = '1';
--      wait until cksum_err = '0';
--      assert false report "command 2 finished with check err detected" severity NOTE;
      
      wait until cmd_data = X"28282828";      
      wait for clk_prd*10;
      assert false report "Simulation done." severity FAILURE;
      wait ;

   end process stimuli;
       
   
   
 
end bench;