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
-- <revision control keyword substitutions e.g. $Id$>
--
-- Project: 			Scuba 2
-- Author:  			David Atkinson
-- Organisation: 			UKATC
--
-- Description:
-- <description text>
--
-- Revision history:
-- <date $Date$> - <text> - <initials $Author$>
--
-- $Log: reply_translator.vhd,v$
--
-- 
-----------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.issue_reply_pack.all;

library sys_param;
use sys_param.command_pack.all;



entity tb_reply_translator is
end tb_reply_translator;







library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.issue_reply_pack.all;

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
     cmd_ack_o	              : out std_logic; 
       
     -- signals to/from reply queue 
     m_op_done_i             : in  std_logic; 
     m_op_ok_nEr_i           : in  std_logic;
     reply_nData_i           : in  std_logic; 
     fibre_word_i            : in  std_logic_vector (DATA_BUS_WIDTH-1      downto 0);
     fibre_word_req_o        : out std_logic;
     m_op_ack_o              : out std_logic;
     
     -- signals to / from fibre_tx
     tx_ff_i                 : in std_logic;
     tx_fw_o                 : out std_logic; 
     txd_o                   : out std_logic_vector (7 downto 0)
     );      
end component;




subtype byte is std_logic_vector( 7 downto 0);


-- some ascii definitions for reply packets
constant ASCII_A        : byte := X"41";  -- ascii value for 'A'
constant ASCII_B        : byte := X"42";  -- ascii value for 'B'
constant ASCII_D        : byte := X"44";  -- ascii value for 'D'
constant ASCII_E        : byte := X"45";  -- ascii value for 'E'
constant ASCII_G        : byte := X"47";  -- ascii value for 'G'
constant ASCII_K        : byte := X"4B";  -- ascii value for 'K'
constant ASCII_O        : byte := X"4F";  -- ascii value for 'O'
constant ASCII_P        : byte := X"50";  -- ascii value for 'P'
constant ASCII_R        : byte := X"52";  -- ascii value for 'R'
constant ASCII_S        : byte := X"53";  -- ascii value for 'S'
constant ASCII_W        : byte := X"57";  -- ascii value for 'W'
constant ASCII_SP       : byte := X"20";  -- ascii value for space


constant clk_prd        : time := 20 ns;  -- 50 MHz clock


signal   dut_rst        : std_logic                                             := '0';
signal   tb_clk         : std_logic                                             := '0';

signal   cmd_rcvd_er    : std_logic                                             := '0';   
signal   cmd_rcvd_ok    : std_logic                                             := '0';         
signal   cmd_code       : std_logic_vector (CMD_CODE_BUS_WIDTH-1  downto 0)     := (others => '0');
signal   card_id        : std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0)     := (others => '0');
signal   param_id       : std_logic_vector (PAR_ID_BUS_WIDTH-1    downto 0)     := (others => '0');  
signal   cmd_ack	       : std_logic                                             := '0'; 
       
signal   m_op_done      : std_logic                                             := '0'; 
signal   m_op_ok_nEr    : std_logic                                             := '0';
signal   reply_nData    : std_logic                                             := '0';
signal   fibre_word     : std_logic_vector (DATA_BUS_WIDTH-1      downto 0)     := (others => '0');
signal   fibre_word_req : std_logic                                             := '0';
signal   m_op_ack       : std_logic                                             := '0';
     
signal   tx_ff          : std_logic                                             := '0';
signal   tx_fw          : std_logic                                             := '0';
signal   txd            : byte                                                  := (others => '0');

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
     cmd_ack_o	         => cmd_ack, 
       
     -- signals to/from reply queue 
     m_op_done_i        => m_op_done,     
     m_op_ok_nEr_i      => m_op_ok_nEr,   
     reply_nData_i      => reply_nData,
     fibre_word_i       => fibre_word, 
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
         wait for clk_prd ; 
         cmd_rcvd_er       <= '0';
         
      
      
         assert false report "checksum error flagged" severity NOTE;
      end do_checksum_error;
   
   --------------------------------------------------

   procedure do_cmd_success is
      begin
   
      
         cmd_rcvd_ok       <= '0';
         wait for clk_prd ;
         cmd_rcvd_ok       <= '1';
         wait for clk_prd ; 
         cmd_rcvd_ok       <= '0';
         
      
      
         assert false report "command received without error..... " severity NOTE;
      end do_cmd_success;
   
   --------------------------------------
   
   begin
   
      -----------------------------------
      -- test reset
      do_reset;
      
      -----------------------------------
      -- test checksum error 
      ----------------------------------
      
      wait for clk_prd;
         
         
      cmd_code ( 7 downto 0)  <= ASCII_O;
      cmd_code (15 downto 8)  <= ASCII_G;
      card_id                 <= X"1234" ;   
      param_id                <= X"5678" ;
      
      wait for clk_prd;
      do_checksum_error;
      
     
      
      wait until txd = X"A5";
      wait until txd = X"5A";
      assert false report "reply 1: preamble received" severity NOTE;
      
      wait until txd = X"50";
      wait until txd = X"52";
      assert false report "reply 1: word 'RP' received" severity NOTE;
      
      wait until txd = X"52";
      wait until txd = X"45";
      assert false report "reply 1: error word 'ER' received" severity NOTE;
      
      wait for clk_prd*30;
      assert false report "reply 1: finised...?" severity NOTE;    
      
     
      -----------------------------------
      -- test GO command
      --------------------------------
     
      
      cmd_code ( 7 downto 0)  <= ASCII_O;
      cmd_code (15 downto 8)  <= ASCII_G;
              
      card_id                 <= X"aabb" ;   
      param_id                <= X"ccdd" ;
         
      do_cmd_success;
      
      wait until txd = X"A5";
      wait until txd = X"5A";
      assert false report "reply 2: preamble received" severity NOTE;
      
      wait until txd = X"50";
      wait until txd = X"52";
      assert false report "reply 2: word 'RP' received" severity NOTE;
      
      wait until txd = X"4B";
      wait until txd = X"4F";
      assert false report "reply 2: success word 'OK' received" severity NOTE;
      
      wait for clk_prd*30;
      assert false report "reply 2: finised...?" severity NOTE;    
      
      ------------------------------
      -- test RS command
      --------------------------------
     
      
      cmd_code ( 7 downto 0)  <= ASCII_S;
      cmd_code (15 downto 8)  <= ASCII_R;
              
      card_id                 <= X"1212" ;   
      param_id                <= X"3434" ;
         
      do_cmd_success;
      
      wait until txd = X"A5";
      wait until txd = X"5A";
      assert false report "reply 3: preamble received" severity NOTE;
      
      wait until txd = X"50";
      wait until txd = X"52";
      assert false report "reply 3: word 'RP' received" severity NOTE;
      
      wait until txd = X"4B";
      wait until txd = X"4F";
      assert false report "reply 3: success word 'OK' received" severity NOTE;
      
      wait for clk_prd*30;
      assert false report "reply 3: finised...?" severity NOTE;    
      
      ------------------------------
      -- test RB command
      --------------------------------
     
      
      cmd_code ( 7 downto 0)  <= ASCII_B;
      cmd_code (15 downto 8)  <= ASCII_W;
              
      card_id                 <= X"5566" ;   
      param_id                <= X"7788" ;
         
      do_cmd_success;
      
      wait for clk_prd*30;     -- wait for some time as command would prop throgh system
      
      -- reply queue now lets translator know that command has finished sucessfully...
      
      reply_nData             <= '1';
      m_op_done               <= '1';       
      m_op_ok_nEr             <= '1';   
      
      wait until fibre_word_req = '1';
      fibre_word               <= X"00000000";
      
          
      wait until txd = X"A5";
      wait until txd = X"5A";
      assert false report "reply 4: preamble received" severity NOTE;
      
      wait until txd = X"50";
      wait until txd = X"52";
      assert false report "reply 4: word 'RP' received" severity NOTE;
      
      wait until txd = X"4B";
      wait until txd = X"4F";
      assert false report "reply 4: success word 'OK' received" severity NOTE;
      
      wait for clk_prd*30;
      assert false report "reply 4: finised...?" severity NOTE;    
      

      

      wait;
         
   end process stimuli;
          
end bench;