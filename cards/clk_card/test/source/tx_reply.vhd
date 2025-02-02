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
-- tx_reply
--
--
-- Project: 			Scuba 2
-- Author:  			David Atkinson
-- Organisation: 			UKATC
--
-- Description:
-- Integration of reply_translator and fibre_tx
--
-- Revision history:
-- <date $Date: 2004/10/08 14:24:08 $> - <text> - <initials $Author: dca $>
--
-- $Log: tx_reply.vhd,v $
-- Revision 1.2  2004/10/08 14:24:08  dca
-- updated due to parameter name changes in command_pack
--
-- Revision 1.1  2004/10/08 14:10:46  dca
-- Initial version
--
--
-- 
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.issue_reply_pack.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

entity tx_reply is

port(
     -- global inputs 
     rst_i                   : in  std_logic;                                            -- global reset
     clk_i                   : in  std_logic;                                            -- global clock

     -- signals to/from cmd_translator    
     cmd_rcvd_er_i           : in  std_logic;                                            -- command received on fibre with checksum error
     cmd_rcvd_ok_i           : in  std_logic;                                            -- command received on fibre - no checksum error
     cmd_code_i              : in  std_logic_vector (FIBRE_CMD_CODE_WIDTH-1  downto 0);    -- fibre command code
     card_id_i               : in  std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);    -- fibre command card id
     param_id_i              : in  std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1    downto 0);    -- fibre command parameter id
         
     -- signals to/from reply queue 
     m_op_done_i             : in  std_logic;                                            -- macro op done
     m_op_ok_nEr_i           : in  std_logic;                                            -- macro op success ('1') or error ('0') 
     m_op_cmd_code_i         : in  std_logic_vector (BB_COMMAND_TYPE_WIDTH-1      downto 0);    -- command code vector - indicates if data or reply (and which command)
     fibre_word_i            : in  std_logic_vector (PACKET_WORD_WIDTH-1      downto 0);    -- packet word read from reply queue
     num_fibre_words_i       : in  std_logic_vector (PACKET_WORD_WIDTH-1      downto 0);    -- indicate number of packet words to be read from reply queue
     fibre_word_req_o        : out std_logic;                                            -- asserted to requeset next fibre word
     m_op_ack_o              : out std_logic;                                            -- asserted to indicate to reply queue the the packet has been processed

     -- interface to HOTLINK transmitter
     fibre_clkw_i            : in     std_logic;                                         -- HOTLINK clock - generated by FPGA
 --    nTrp_i                  : in     std_logic;                                         -- read pulse
     tx_data_o               : out    std_logic_vector(TX_FIFO_DATA_WIDTH-1 downto 0); 
     tsc_nTd_o               : out    std_logic;
     nFena_o                 : out    std_logic
     );      

end tx_reply;


library ieee;
use ieee.std_logic_1164.all;

library work;
use work.issue_reply_pack.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;


architecture rtl of tx_reply is

  
-- signals between fibre_tx and reply_translator
      
signal txd        : std_logic_vector(TX_FIFO_DATA_WIDTH-1 downto 0); 
signal tx_fw      : std_logic;        
signal tx_ff      : std_logic;

begin

-- Instance port mappings

   
   fibre_tx_inst : fibre_tx 
   port map (       
      
      -- global signals
      clk_i            => clk_i,  
      rst_i            => rst_i,

      -- interface to reply_translator
      txd_i            => txd,
      tx_fw_i          => tx_fw,    
      tx_ff_o          => tx_ff,
      
      -- interface to the off-chip HOTLINK transmitter
      fibre_clkw_i     => fibre_clkw_i, 
 --     nTrp_i           => nTrp_i, 
      tx_data_o        => tx_data_o,
      tsc_nTd_o        => tsc_nTd_o,
      nFena_o          => nFena_o
      );



   reply_translator_inst: reply_translator
   port map (

      -- global inputs 
      rst_i             => rst_i,                             
      clk_i             => clk_i,                                   

      -- signals to/from cmd_translator    
      cmd_rcvd_er_i     => cmd_rcvd_er_i,        
      cmd_rcvd_ok_i     => cmd_rcvd_ok_i,             
      cmd_code_i        => cmd_code_i,
      card_id_i         => card_id_i,
      param_id_i        => param_id_i,
         
      -- signals to/from reply queue 
      m_op_done_i       => m_op_done_i,
      m_op_ok_nEr_i     => m_op_ok_nEr_i,  
      m_op_cmd_code_i   => m_op_cmd_code_i, 
      fibre_word_i      => fibre_word_i, 
      num_fibre_words_i => num_fibre_words_i, 
      fibre_word_req_o  => fibre_word_req_o,
      m_op_ack_o        => m_op_ack_o,     
      
      -- signals to / from fibre_tx
      tx_ff_i           => tx_ff,
      tx_fw_o           => tx_fw,
      txd_o             => txd
      );      
           
end rtl;