-- Copyright (c) 2003 SCUBA-2 Project
-- All Rights Reserved
--
-- THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE SCUBA-2 Project
-- The copyright notice above does not evidence any
-- actual or intended publication of such source code.
--
-- SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
-- REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
-- MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
-- PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
-- THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.
--
-- For the purposes of this code the SCUBA-2 Project consists of the
-- following organisations.
--
-- UKATC, Royal Observatory, Blackford Hill Edinburgh EH9 3HJ
-- UBC, University of British Columbia, Physics & Astronomy Department,
-- Vancouver BC, V6T 1Z1
--
-- reply_translator
--
-- <revision control keyword substitutions e.g. $Id: tb_reply_translator.vhd,v 1.9 2004/09/03 13:13:26 dca Exp $>
--
-- Project: 			Scuba 2
-- Author:  			David Atkinson
-- Organisation: 			UKATC
--
-- Description:
-- <description text>
--
-- Revision history:
-- <date $Date: 2004/09/03 13:13:26 $> - <text> - <initials $Author: dca $>
--
-- $Log: tb_reply_translator.vhd,v $
-- Revision 1.9  2004/09/03 13:13:26  dca
-- test added for 'NO_REPLY' state (fibre FSM).
--
-- Revision 1.8  2004/09/02 14:33:23  dca
-- some timing changes
--
-- Revision 1.7  2004/09/02 12:38:36  dca
-- 'reply_nData_i' signal replaced with 'm_op_cmd_code_i' vector
--
-- Revision 1.6  2004/08/30 11:05:26  dca
-- code to test ST command with checksum error during data readout added.
--
-- Revision 1.5  2004/08/26 15:08:36  dca
-- cmd_ack_o signal removed.
-- Some constants moved to command_pack
--
-- Revision 1.4  2004/08/25 14:21:29  dca
-- Data frame test added ...
--
-- Revision 1.3  2004/08/24 13:20:06  dca
-- general progress of test bed...
--
-- Revision 1.2  2004/08/23 14:23:21  dca
-- Code to test first pass at reply FSM.
-- (Data FSM not done yet)
--
-- Revision 1.1  2004/08/20 08:52:13  dca
-- no message
--
-- Revision 1.2  2004/08/19 15:32:21  dca
-- general progress
--
-- Revision 1.1  2004/08/17 16:36:32  dca
-- Initial Version
--
--
-- 
-----------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

entity tb_reply_translator is
end tb_reply_translator;




library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.issue_reply_pack.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;


architecture bench of tb_reply_translator is


component reply_translator 

port(
     -- global inputs 
     rst_i                   : in  std_logic;
     clk_i                   : in  std_logic;

     -- signals to/from cmd_translator
     
     cmd_rcvd_er_i           : in  std_logic;                   
     cmd_rcvd_ok_i           : in  std_logic;         
     cmd_code_i              : in  std_logic_vector (CMD_CODE_BUS_WIDTH-1  downto 0);
     card_id_i               : in  std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);
     param_id_i              : in  std_logic_vector (PAR_ID_BUS_WIDTH-1    downto 0);  
       
     -- signals to/from reply queue 
     m_op_done_i             : in  std_logic; 
     m_op_ok_nEr_i           : in  std_logic;
     m_op_cmd_code_i         : in  std_logic_vector (CMD_TYPE_WIDTH-1      downto 0);   
     fibre_word_i            : in  std_logic_vector (DATA_BUS_WIDTH-1      downto 0);
     num_fibre_words_i       : in  std_logic_vector (DATA_BUS_WIDTH-1      downto 0);
     fibre_word_req_o        : out std_logic;
     m_op_ack_o              : out std_logic;
     
     -- signals to / from fibre_tx
     tx_ff_i                 : in std_logic;
     tx_fw_o                 : out std_logic; 
     txd_o                   : out std_logic_vector (7 downto 0)
     );      
end component;


--subtype byte is std_logic_vector( 7 downto 0);


constant clk_prd        : time := 20 ns;  -- 50 MHz clock


signal   dut_rst        : std_logic                                             := '0';
signal   tb_clk         : std_logic                                             := '0';

signal   cmd_rcvd_er    : std_logic                                             := '0';   
signal   cmd_rcvd_ok    : std_logic                                             := '0';         
signal   cmd_code       : std_logic_vector (CMD_CODE_BUS_WIDTH-1  downto 0)     := (others => '0');
signal   card_id        : std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0)     := (others => '0');
signal   param_id       : std_logic_vector (PAR_ID_BUS_WIDTH-1    downto 0)     := (others => '0');  
signal   cmd_ack	       : std_logic; 
       
signal   m_op_done      : std_logic                                             := '0'; 
signal   m_op_ok_nEr    : std_logic                                             := '0';
signal   m_op_cmd_code  : std_logic_vector (CMD_TYPE_WIDTH-1      downto 0)     := (others => '0');
signal   fibre_word     : std_logic_vector (DATA_BUS_WIDTH-1      downto 0)     := (others => '0');
signal   fibre_word_req : std_logic;
signal   num_fibre_words: std_logic_vector (DATA_BUS_WIDTH-1      downto 0)     := (others => '0');
signal   m_op_ack       : std_logic;
     
signal   tx_ff          : std_logic                                             := '0';
signal   tx_fw          : std_logic;
signal   txd            : byte;

signal   fibre_byte     : byte                                                  := (others => '0');
signal   frame_data     : integer                                               := 0 ;

begin

-------------------------------------------------
-- Instantiate DUT
-------------------------------------------------

   DUT :  reply_translator
   
   port map ( 
      rst_i             => dut_rst,
      clk_i             => tb_clk,
    
      cmd_rcvd_er_i      => cmd_rcvd_er,                     
      cmd_rcvd_ok_i      => cmd_rcvd_ok,               
      cmd_code_i         => cmd_code,    
      card_id_i          => card_id,     
      param_id_i         => param_id, 
       
      -- signals to/from reply queue 
      m_op_done_i        => m_op_done,     
      m_op_ok_nEr_i      => m_op_ok_nEr,   
      m_op_cmd_code_i    => m_op_cmd_code,
      fibre_word_i       => fibre_word, 
      num_fibre_words_i  => num_fibre_words,
      fibre_word_req_o   => fibre_word_req,   
      m_op_ack_o         => m_op_ack,   
     
      -- signals to / from fibre_tx
      tx_ff_i            => tx_ff, 
      tx_fw_o            => tx_fw,  
      txd_o              => txd   
   
   );
  
   
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

   procedure do_checksum_error is
      begin
      
         cmd_rcvd_er       <= '0';
         wait for clk_prd ;
         cmd_rcvd_er       <= '1';
         assert false report "cmd_translator informs of command with checksum error...." severity NOTE;
         wait for clk_prd ; 
         cmd_rcvd_er       <= '0';
         
      
      
         
      end do_checksum_error;
   
   --------------------------------------------------

   procedure do_cmd_success is
      begin
   
      
         cmd_rcvd_ok       <= '0';
         wait for clk_prd ;
         cmd_rcvd_ok       <= '1';
         assert false report "cmd_translator informs of parsed command...." severity NOTE;
         wait for clk_prd ; 
         cmd_rcvd_ok       <= '0';
         
      
      
         
      end do_cmd_success;
   

   
   --------------------------------------
   
   begin
   
      -----------------------------------
      -- test reset
      
      assert false report "TEST GLOBAL RESET" severity NOTE;
      
      do_reset;
      
      
      -----------------------------------
      -- test 1: checksum error 
      ----------------------------------

      
      wait for clk_prd;
         
         
      cmd_code ( 7 downto 0)  <= ASCII_O;
      cmd_code (15 downto 8)  <= ASCII_G;
      card_id                 <= X"1234" ;   
      param_id                <= X"5678" ;
      
      wait for clk_prd;
      assert false report "TEST CHECKSUM ERROR" severity NOTE;
      do_checksum_error;
      
     
      
      wait until txd = FIBRE_PREAMBLE1;
      wait until txd = FIBRE_PREAMBLE2;
      assert false report "test 1: preamble txmitted" severity NOTE;
      
      wait until txd = ASCII_P;
      wait until txd = ASCII_R;
      assert false report "test 1: word 'RP' txmitted" severity NOTE;
      
      wait until txd = ASCII_R;
      wait until txd = ASCII_E;
      assert false report "test 1: error word 'ER' txmitted" severity NOTE;
      
      wait for clk_prd*40;
      assert false report "test 1: checksum error reply finised...?" severity NOTE;    
      
     
      -----------------------------------
      -- test 2: GO command
      --------------------------------
     
      
      cmd_code ( 7 downto 0)  <= ASCII_O;
      cmd_code (15 downto 8)  <= ASCII_G;
              
      card_id                 <= X"aabb" ;   
      param_id                <= X"ccdd" ;
      
      assert false report "TEST GO COMMAND" severity NOTE;   
      do_cmd_success;
      
      wait until txd = FIBRE_PREAMBLE1;
      wait until txd = FIBRE_PREAMBLE2;
      assert false report "test 2: preamble txmitted" severity NOTE;
      
     
      wait until txd = ASCII_P;
      wait until txd = ASCII_R;
      assert false report "test 2: word 'RP' txmitted" severity NOTE;
      
      wait until txd = ASCII_K;
      wait until txd = ASCII_O;
      assert false report "test 2: success word 'OK' txmitted" severity NOTE;
      
      wait for clk_prd*40;
      assert false report "test 2: GO reply finised...?" severity NOTE;    
      
      --------------------------------------------------------
      -- test 3: RS command -  and FIFO FULL states conditions
      -------------------------------------------------------
     
      
      tx_ff                   <= '1';         -- set transmit FIFO full
      
      cmd_code ( 7 downto 0)  <= ASCII_S;
      cmd_code (15 downto 8)  <= ASCII_R;
              
      card_id                 <= X"1122" ;   
      param_id                <= X"3344" ;
         
      assert false report "TEST RESET COMMAND" severity NOTE;   
      do_cmd_success;
      
      wait for clk_prd * 4;
      
      
      for i in 0 to 31 loop 
      
         tx_ff         <= '0';
         wait for clk_prd * 2;
         
         if     txd = FIBRE_PREAMBLE1 then 
            assert false report " 'A5' txmitted" severity NOTE;
         elsif  txd = FIBRE_PREAMBLE2 then
            assert false report "'5A' txmitted" severity NOTE;
         elsif  txd = ASCII_SP then
            assert false report "'SP' char txmitted" severity NOTE;
         elsif  txd = ASCII_P then
            assert false report "'P' char txmitted" severity NOTE;       
         elsif  txd = ASCII_R then
            assert false report "'R' char txmitted" severity NOTE;
         elsif  txd = ASCII_O then
            assert false report "'O' char txmitted" severity NOTE;
         elsif  txd = ASCII_K then
           assert false report "'K' char txmitted" severity NOTE;
         elsif  txd = ASCII_S then
            assert false report "'S' char txmitted" severity NOTE;  
         elsif  txd = X"00" then
            assert false report "0x00 byte txmitted" severity NOTE;  
         elsif  txd = X"04" then
            assert false report "0x04 byte txmitted" severity NOTE;        
         elsif  txd = card_id (7 downto 0) then
            assert false report "card_id byte 0 txmitted"  severity NOTE;    
         elsif  txd = card_id (15 downto 8) then
            assert false report "card_id byte 1 txmitted" severity NOTE;    
         elsif  txd = param_id (7 downto 0) then
            assert false report "param_id byte 0 txmitted" severity NOTE;    
         elsif  txd = param_id (15 downto 8) then
            assert false report "param_id byte 1 txmitted"  severity NOTE;                      
         else   
            assert false report " checksum (?) byte txmitted "  severity NOTE;   
         end if;
         
         tx_ff         <= '1';   
         wait for clk_prd * 4;
         
         
      end loop;
         
      tx_ff            <= '0';
    
      
      wait for clk_prd*40;
      assert false report "test 3: RS reply finised...?" severity NOTE;    
      
      ------------------------------
      -- test 4: WB command - OK
      --------------------------------
     
      
      cmd_code ( 7 downto 0)  <= ASCII_B;
      cmd_code (15 downto 8)  <= ASCII_W;
              
      card_id                 <= X"5566" ;   
      param_id                <= X"7788" ;
       
      assert false report "TEST WRITE BLOCK COMMAND(OK)" severity NOTE;       
      do_cmd_success;
      
      wait for clk_prd*30;     -- wait for some time as command would prop throgh system
      
      -- reply queue now lets translator know that command has finished sucessfully...
      
      m_op_cmd_code           <= WRITE_BLOCK;
      m_op_done               <= '1';       
      m_op_ok_nEr             <= '1';   
      num_fibre_words         <= X"00000001";
      
      wait until txd = FIBRE_PREAMBLE1;
      wait until txd = FIBRE_PREAMBLE2;
      assert false report "test 4: preamble txmitted" severity NOTE;
      
      wait until txd = ASCII_P;
      wait until txd = ASCII_R;
      assert false report "test 4: word 'RP' txmitted" severity NOTE;
      
         
      wait until txd = ASCII_K;
      wait until txd = ASCII_O;
      assert false report "test 4: success word 'OK' txmitted" severity NOTE;
      
      
      
      wait until fibre_word_req = '1';
      -- would really be x"00000000" but want to see change in data
      fibre_word               <= X"69696969";         
          
      wait until txd = X"69";
      assert false report "test 4: transmitting fibre word...... " severity NOTE;
  
      
      wait until m_op_ack      = '1'; 
      wait for clk_prd;
    
      m_op_cmd_code           <= (others => '0');
      m_op_done               <= '0';       
      m_op_ok_nEr             <= '0';   
      num_fibre_words         <= X"00000000";
      
      assert false report "test 4: WB (OK) reply finised..." severity NOTE;    
      
      wait for clk_prd*20;

      ------------------------------
      -- test 5: WB command - ER
      --------------------------------
     
      
      cmd_code ( 7 downto 0)  <= ASCII_B;
      cmd_code (15 downto 8)  <= ASCII_W;
              
      card_id                 <= X"aaaa" ;   
      param_id                <= X"bbbb" ;
       
      assert false report "TEST WRITE BLOCK COMMAND (ER)" severity NOTE;       
      do_cmd_success;
      
      wait for clk_prd*30;     -- wait for some time as command would prop throgh system
      
      -- reply queue now lets translator know that command has finished sucessfully...
      
      m_op_cmd_code           <= WRITE_BLOCK;
      m_op_done               <= '1';       
      m_op_ok_nEr             <= '0';   
      num_fibre_words         <= X"00000001";
      
      wait until txd = FIBRE_PREAMBLE1;
      wait until txd = FIBRE_PREAMBLE2;
      assert false report "test 5: preamble txmitted" severity NOTE;
      
      wait until txd = ASCII_P;
      wait until txd = ASCII_R;
      assert false report "test 5: word 'RP' txmitted" severity NOTE;
      
         
      wait until txd = ASCII_R;
      wait until txd = ASCII_E;
      assert false report "test 5: error word 'ER' txmitted" severity NOTE;
      
      
      
      wait until fibre_word_req = '1';
      -- would really be x"00000000" but want to see change in data
      fibre_word               <= X"66666699";         
          
      wait until txd = X"99";
      assert false report "test 5: txmitting fibre word...... " severity NOTE;
  
      
      wait until m_op_ack      = '1'; 
      wait for clk_prd;
    
      m_op_cmd_code           <= (others => '0');
      m_op_done               <= '0';       
      m_op_ok_nEr             <= '0';   
      num_fibre_words         <= X"00000000";
      
      assert false report "test 5: WB (ER) reply finised..." severity NOTE;    
      
      wait for clk_prd*20;

      ------------------------------
      -- test 6: RB command - OK
      --------------------------------
     
      
      cmd_code ( 7 downto 0)  <= ASCII_B;
      cmd_code (15 downto 8)  <= ASCII_R;
              
      card_id                 <= X"1111" ;   
      param_id                <= X"2222" ;
      
      assert false report "TEST READ BLOCK COMMAND (OK)" severity NOTE; 
      do_cmd_success;
      
      wait for clk_prd*30;     -- wait for some time as command would prop throgh system
      
      -- reply queue now lets translator know that command has finished sucessfully...
      
      assert false report "reply_queue informs RB reply ready...." severity NOTE;  
      m_op_cmd_code           <= READ_BLOCK;
      m_op_done               <= '1';       
      m_op_ok_nEr             <= '1';   
      num_fibre_words         <= X"00000010";
      
      
              
      wait until txd = FIBRE_PREAMBLE1;
      wait until txd = FIBRE_PREAMBLE2;
      assert false report "test 6: preamble txmitted" severity NOTE;
      
      wait until txd = ASCII_P;
      wait until txd = ASCII_R;
      assert false report "test 6: word 'RP' txmitted" severity NOTE;
      
      wait until txd = ASCII_K;
      wait until txd = ASCII_O;
      assert false report "test 6: success word 'OK' txmitted" severity NOTE;
      
      
      for i in 1 to (to_integer(unsigned(num_fibre_words))) loop 
      
         fibre_byte <= std_logic_vector(to_unsigned(i,8));
         wait until fibre_word_req = '1';
         fibre_word ( 7 downto  0) <= fibre_byte;
         fibre_word (15 downto  8) <= fibre_byte;
         fibre_word (23 downto 16) <= fibre_byte;
         fibre_word (31 downto 24) <= fibre_byte;
         assert false report "test 6: next fibre word txmitted" severity NOTE;
         
      end loop;
         
    
      wait until m_op_ack      = '1'; 
      wait for clk_prd;
       
      m_op_cmd_code           <= (others => '0');
      m_op_done               <= '0';       
      m_op_ok_nEr             <= '0';   
      num_fibre_words         <= X"00000000";
      
      assert false report "test 6: RB reply finised..." severity NOTE;    
      
      wait for clk_prd*10;

      ------------------------------
      -- test 7: RB command - ER
      --------------------------------
     
      
      cmd_code ( 7 downto 0)  <= ASCII_B;
      cmd_code (15 downto 8)  <= ASCII_R;
              
      card_id                 <= X"1111" ;   
      param_id                <= X"2222" ;
      
      assert false report "TEST READ BLOCK COMMAND (ER)" severity NOTE; 
      do_cmd_success;
      
      wait for clk_prd*30;     -- wait for some time as command would prop throgh system
      
      -- reply queue now lets translator know that command has finished sucessfully...
      
      assert false report "reply_queue informs RB reply ready...." severity NOTE;  
      m_op_cmd_code           <= READ_BLOCK;
      m_op_done               <= '1';       
      m_op_ok_nEr             <= '0';   
      num_fibre_words         <= X"00000001";
      
      
              
      wait until txd = FIBRE_PREAMBLE1;
      wait until txd = FIBRE_PREAMBLE2;
      assert false report "test 7: preamble txmitted" severity NOTE;
      
      wait until txd = ASCII_P;
      wait until txd = ASCII_R;
      assert false report "test 7: word 'RP' txmitted" severity NOTE;
      
      wait until txd = ASCII_R;
      wait until txd = ASCII_E;
      assert false report "test 7: success word 'ER' txmitted" severity NOTE;
      
      
         fibre_byte <= X"FF";     -- error word
         wait until fibre_word_req = '1';
         fibre_word ( 7 downto  0) <= fibre_byte;
         fibre_word (15 downto  8) <= fibre_byte;
         fibre_word (23 downto 16) <= fibre_byte;
         fibre_word (31 downto 24) <= fibre_byte;
         assert false report "test 7: next fibre word txmitted" severity NOTE;
        
         
    
      wait until m_op_ack      = '1'; 
      wait for clk_prd;
       
      m_op_cmd_code           <= (others => '0');
      m_op_done               <= '0';       
      m_op_ok_nEr             <= '0';   
      num_fibre_words         <= X"00000000";
      
      assert false report "test 7: RB reply finised (ER)..." severity NOTE;    
      
      wait for clk_prd*10;

      ------------------------------
      -- test 8: DATA FRAME:
      --------------------------------
     
      
      assert false report "TEST DATA FRAME" severity NOTE; 
      do_cmd_success;
      
      wait for clk_prd*30;     -- wait for some time as command would prop throgh system
      
      -- reply queue now lets translator know that command has finished sucessfully...
      
      assert false report "reply_queue informs that there a frame of data to process...." severity NOTE;  
      m_op_cmd_code           <= DATA;
      m_op_done               <= '1';       
      m_op_ok_nEr             <= '0';   
      num_fibre_words         <= X"00000064";
      
      
              
      wait until txd = FIBRE_PREAMBLE1;
      wait until txd = FIBRE_PREAMBLE2;
      assert false report "test 8: preamble txmitted" severity NOTE;
      
      wait until txd = ASCII_A;
      wait until txd = ASCII_D;
      assert false report "test 8: header word 'DA' txmitted" severity NOTE;
      
                   
           
      for i in 1 to (to_integer(unsigned(num_fibre_words))) loop 
      
         frame_data <= (i * 32) + 1; 
         
         
         wait until fibre_word_req = '1';
         fibre_word <= std_logic_vector(to_unsigned(frame_data,32));

 
         assert false report "test 8: next fibre word txmitted" severity NOTE;
         
         -- a ST command with checksum error arrives during readout....
         if i = 3 then
            cmd_code ( 7 downto 0)  <= ASCII_T;
            cmd_code (15 downto 8)  <= ASCII_S;
            card_id                 <= X"1234" ;   
            param_id                <= X"5678" ;
           
            wait for clk_prd;
            assert false report "ST with CHECKSUM ERROR arrives mid readout..." severity NOTE;
            do_checksum_error;
      
         end if; 
         
      end loop; 
                 
    
      wait until m_op_ack      = '1'; 
      wait for clk_prd;
       
      m_op_cmd_code           <= (others => '0');
      m_op_done               <= '0';       
      m_op_ok_nEr             <= '0';   
      num_fibre_words         <= X"00000000";
      
      assert false report "test 8: Frame readout finised....." severity NOTE;    
      
      
     ----------------------------------------------
      -- test 9: ST checksum error - check reply
      ----------------------------------------------
   
      wait until txd = FIBRE_PREAMBLE1;
      wait until txd = FIBRE_PREAMBLE2;
      assert false report "test 9 ST preamble txmitted" severity NOTE;
      
      wait until txd = ASCII_P;
      wait until txd = ASCII_R;
      assert false report "test 9: word 'RP' txmitted" severity NOTE;
      
      wait until txd = ASCII_R;
      wait until txd = ASCII_E;
      assert false report "test 9: error word 'ER' txmitted" severity NOTE;
      
      wait for clk_prd*30;
      assert false report "test 9: checksum ST error reply finised...?" severity NOTE;    

  
     ----------------------------------------------
      -- test 10: START m_op done 
      --
      -- if reply_queue tells reply_translator
      -- that a START or RESET command has finished
      -- then no reply should be generated (since these commands have
      -- an immediate reply generated when cmd_translator 
      -- informs reply_translator that they have arrived.
      ----------------------------------------------

 -- reply queue now lets translator know that command has finished sucessfully...
      
      wait for clk_prd*20;
      
      assert false report "reply_queue informs START command m_op finished...." severity NOTE;  
      m_op_cmd_code           <= START;
      m_op_done               <= '1';       
      m_op_ok_nEr             <= '0';   
      num_fibre_words         <= X"00000001";
      
      
              
      wait until m_op_ack = '1';
      assert false report "test 10: m_op_acknowledged" severity NOTE;
      
      wait for clk_prd * 4 ; 
             
      m_op_cmd_code           <= (others => '0');
      m_op_done               <= '0';       
      m_op_ok_nEr             <= '0';   
      num_fibre_words         <= X"00000000";
      
      assert false report "test 10: finised ........." severity NOTE;    
      
      wait for clk_prd*10;


      wait for clk_prd*20; 
      assert false report "end of simulation......" severity FAILURE;    

      wait;
         
   end process stimuli;
          
end bench;