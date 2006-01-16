-- Copyright (c) 2003 SCUBA-2 Project
--               All Rights Reserved
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
-- UBC,   University of British Columbia, Physics & Astronomy Department,
--        Vancouver BC, V6T 1Z1
--
-- $Id: reply_translator_pack.vhd,v 1.5 2005/11/15 03:17:22 bburger Exp $
--
-- Project:    SCUBA2
-- Author:     Greg Dennis
-- Organization:  UBC
--
-- Description:
-- Declares a few constants used as parameters in the reply_translator block
--
-- Revision history:
-- $Log: reply_translator_pack.vhd,v $
-- Revision 1.5  2005/11/15 03:17:22  bburger
-- Bryce: Added support to reply_queue_sequencer, reply_queue and reply_translator for timeouts and CRC errors from the bus backplane
--
-- Revision 1.4  2004/12/03 16:42:51  dca
-- mop_error_code_i width changed
--
-- Revision 1.3  2004/12/02 12:34:06  dca
-- m_op_* signals names changed to mop_* for consistency across issue_reply.
--
-- Revision 1.2  2004/11/25 14:55:04  dca
-- internal command added & frame header buffer added to reply translator.  tb changed accordingly.
--
-- Revision 1.1  2004/11/24 01:15:52  bench2
-- Greg: Broke apart issue reply and created pack files for all of its sub-components
--
--
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.command_pack.all;

library work;
use work.sync_gen_pack.all;

package reply_translator_pack is
 
-------------------------------
component reply_translator
-------------------------------
port(
    -- global inputs 
     rst_i                   : in  std_logic;                                               -- global reset
     clk_i                   : in  std_logic;                                               -- global clock

     -- signals to/from cmd_translator    
     cmd_rcvd_er_i           : in  std_logic;                                               -- command received on fibre with checksum error
     cmd_rcvd_ok_i           : in  std_logic;                                               -- command received on fibre - no checksum error
     cmd_code_i              : in  std_logic_vector (FIBRE_PACKET_TYPE_WIDTH-1     downto 0);  -- fibre command code
     card_id_i               : in  std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);  -- fibre command card id
     param_id_i              : in  std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);  -- fibre command parameter id
         
     -- signals to/from reply queue 
     mop_rdy_i              : in  std_logic;                                                 -- macro op done
     mop_error_code_i       : in  std_logic_vector (29                       downto 0);      -- macro op success (others => '0') else error code
     mop_cmd_code_i         : in  std_logic_vector (BB_COMMAND_TYPE_WIDTH-1  downto 0);      -- command code vector - indicates if data or reply (and which command)
     mop_param_id_i         : in  std_logic_vector (BB_PARAMETER_ID_WIDTH-1  downto 0);      -- mop parameter id passed from reply_queue
     mop_card_id_i          : in  std_logic_vector (BB_CARD_ADDRESS_WIDTH-1  downto 0);      -- mop card id passed from reply_queue
--     internal_cmd_i          : in  std_logic;                                                 -- asserted if m_op is an internal command
     fibre_word_i            : in  std_logic_vector (PACKET_WORD_WIDTH-1        downto 0);    -- packet word read from reply queue
     num_fibre_words_i       : in  integer ;                                                  -- indicate number of packet words to be read from reply queue
     fibre_word_ack_o        : out std_logic;                                                 -- asserted to requeset next fibre word
     fibre_word_rdy_i        : in std_logic;
     mop_ack_o              : out std_logic;                                                 -- asserted to indicate to reply queue the the packet has been processed

     cmd_stop_i              : in std_logic;
     last_frame_i            : in std_logic;
     frame_seq_num_i         : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);

     -- signals to / from fibre_tx
     tx_ff_i                 : in std_logic;                                             -- transmit fifo full
     tx_fw_o                 : out std_logic;                                            -- transmit fifo write request
     txd_o                   : out std_logic_vector (7 downto 0)                         -- transmit fifo data input
     );      
end component;

end reply_translator_pack;
