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
-- <revision control keyword substitutions e.g. $Id: reply_translator.vhd,v 1.18 2004/11/16 09:56:05 dca Exp $>
--
-- Project: 			Scuba 2
-- Author:  			David Atkinson
-- Organisation: 			UKATC
--
-- Description:
-- <description text>
--
-- Revision history:
-- <date $Date: 2004/11/16 09:56:05 $> - <text> - <initials $Author: dca $>
--
-- $Log: reply_translator.vhd,v $
-- Revision 1.18  2004/11/16 09:56:05  dca
-- 'num_fibre_words_i' changed from std_logic_vector to integer
--
-- Revision 1.17  2004/11/11 17:05:10  dca
-- status word and sequence word now included in data packet.
--
-- Revision 1.16  2004/11/04 16:33:09  dca
-- ***Comment added  (no change to code)***
-- The current version of code must run with clk_i
-- bigger than or equal to 50MHz.
--
-- (This is due to bug on PCI card)
--
-- Revision 1.15  2004/10/21 16:06:19  dca
-- error code/word 3 now decoded from new input 'm_op_error_code_i'.
-- FSM changed accordinly.
--
-- fibre_word_rdy_i signal added to handshake with reply_queue for
-- data on fibre_word_i
--
-- Revision 1.14  2004/10/06 21:48:53  erniel
-- using new command_pack constants
-- using conv_integer and conv_std_logic_vector macros
--
-- Revision 1.13  2004/09/03 13:55:46  dca
-- local command FSM removed
-- will be added once its functionality is established
--
-- Revision 1.12  2004/09/03 13:12:48  dca
-- 'NO_REPLY' state added to fibre FSM.
-- This state is entered if a completed m_op
-- should not generate a fibre packet.
-- (determined by value on m_op_cmd_code_i)
--
-- Revision 1.11  2004/09/02 15:10:16  dca
-- moved the macro_op acknowledgement assertion in the FSM.
--
-- Revision 1.10  2004/09/02 12:38:24  dca
-- 'reply_nData_i' signal replaced with 'm_op_cmd_code_i' vector
--
-- Revision 1.9  2004/08/30 11:04:41  dca
-- typo corrected 'ASCII_T' replaces 'ASCII_P'
--
-- Revision 1.8  2004/08/27 15:41:48  dca
-- Code added to handel the case of a ST
-- command arriving with a checksum error
-- while fibre FSM is busy.
--
-- Revision 1.7  2004/08/26 15:08:27  dca
-- cmd_ack_o signal removed.
-- Some constants moved to command_pack
--
-- Revision 1.6  2004/08/25 15:12:21  dca
-- *reply_word3 * signal names changed to *wordN*
-- Various state names changed...
--
-- Revision 1.5  2004/08/25 14:21:04  dca
-- States added to FSM to process data frames...
--
-- Revision 1.4  2004/08/24 13:29:06  dca
-- REPLY FSM changed to FIBRE FSM.
-- This FSM will write all fibre packets (reply and data)
-- to the transmit FIFO.
--
-- Revision 1.3  2004/08/23 14:22:49  dca
-- First pass at reply FSM coded and simulated.
-- (Data FSM not done yet)
--
-- Revision 1.2  2004/08/19 15:31:57  dca
-- various changes to reply_fsm
--
-- Revision 1.1  2004/08/17 16:36:54  dca
-- Initial Version
--
--
-- 
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--use ieee.numeric_std.all;

library work;
use work.issue_reply_pack.all;


library sys_param;
use sys_param.command_pack.all;
--use sys_param.wishbone_pack.all;

entity reply_translator is

port(
     -- global inputs 
     rst_i                   : in  std_logic;                                               -- global reset
     clk_i                   : in  std_logic;                                               -- global clock

     -- signals to/from cmd_translator    
     cmd_rcvd_er_i           : in  std_logic;                                               -- command received on fibre with checksum error
     cmd_rcvd_ok_i           : in  std_logic;                                               -- command received on fibre - no checksum error
     cmd_code_i              : in  std_logic_vector (FIBRE_CMD_CODE_WIDTH-1     downto 0);  -- fibre command code
     card_id_i               : in  std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);  -- fibre command card id
     param_id_i              : in  std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);  -- fibre command parameter id
         
     -- signals to/from reply queue 
     m_op_done_i             : in  std_logic;                                               -- macro op done
     m_op_error_code_i       : in  std_logic_vector(BB_STATUS_WIDTH-1           downto 0);   -- macro op success (others => '0') else error code
     m_op_cmd_code_i         : in  std_logic_vector (BB_COMMAND_TYPE_WIDTH-1    downto 0);  -- command code vector - indicates if data or reply (and which command)
     m_op_param_id_i         : in  std_logic_vector (BB_PARAMETER_ID_WIDTH-1  downto 0);  -- m_op parameter id passed from reply_queue
     m_op_card_id_i          : in  std_logic_vector (BB_CARD_ADDRESS_WIDTH-1  downto 0);  -- m_op card id passed from reply_queue
     fibre_word_i            : in  std_logic_vector (PACKET_WORD_WIDTH-1      downto 0);    -- packet word read from reply queue
--     num_fibre_words_i       : in  std_logic_vector (BB_DATA_SIZE_WIDTH-1     downto 0);    -- indicate number of packet words to be read from reply queue
     num_fibre_words_i       : in  integer ;                                                   -- indicate number of packet words to be read from reply queue
     fibre_word_req_o        : out std_logic;                                               -- asserted to requeset next fibre word
     fibre_word_rdy_i        : in std_logic;
     m_op_ack_o              : out std_logic;                                               -- asserted to indicate to reply queue the the packet has been processed

     cmd_stop_i              : in std_logic;
     last_frame_i            : in std_logic;
     frame_seq_num_i         : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);

     -- signals to / from fibre_tx
     tx_ff_i                 : in std_logic;                                             -- transmit fifo full
     tx_fw_o                 : out std_logic;                                            -- transmit fifo write request
     txd_o                   : out std_logic_vector (7 downto 0)                         -- transmit fifo data input
     );      
end reply_translator;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.issue_reply_pack.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;


architecture rtl of reply_translator is


constant NUM_REPLY_WORDS     : integer := 4;

-- reply word registers

signal packet_word1_0         : byte;                       -- reply word 1 byte 0 
signal packet_word1_1         : byte;                       -- reply word 1 byte 1 
signal packet_word1_2         : byte;                       -- reply word 1 byte 2 
signal packet_word1_3         : byte;                       -- reply word 1 byte 3 
            
signal packet_word2_0         : byte;                       -- reply word 2 byte 0 
signal packet_word2_1         : byte;                       -- reply word 2 byte 1 
signal packet_word2_2         : byte;                       -- reply word 2 byte 2 
signal packet_word2_3         : byte;                       -- reply word 2 byte 3 
 
signal reply_word3_0         : byte;                       -- reply word 3 byte 0 
signal reply_word3_1         : byte;                       -- reply word 3 byte 1 
signal reply_word3_2         : byte;                       -- reply word 3 byte 2 
signal reply_word3_3         : byte;                       -- reply word 3 byte 3 
            
signal wordN_0               : byte;                       -- reply word N byte 0 
signal wordN_1               : byte;                       -- reply word N byte 1 
signal wordN_2               : byte;                       -- reply word N byte 2 
signal wordN_3               : byte;                       -- reply word N byte 3 

-- packet header registers /  definitions 

constant packet_header1_0     : byte := FIBRE_PREAMBLE1;   -- packet header word 1 byte 0
constant packet_header1_1     : byte := FIBRE_PREAMBLE1;   -- packet header word 1 byte 1
constant packet_header1_2     : byte := FIBRE_PREAMBLE1;   -- packet header word 1 byte 2
constant packet_header1_3     : byte := FIBRE_PREAMBLE1;   -- packet header word 1 byte 3
            
constant packet_header2_0     : byte := FIBRE_PREAMBLE2;   -- packet header word 2 byte 0
constant packet_header2_1     : byte := FIBRE_PREAMBLE2;   -- packet header word 2 byte 1
constant packet_header2_2     : byte := FIBRE_PREAMBLE2;   -- packet header word 2 byte 2
constant packet_header2_3     : byte := FIBRE_PREAMBLE2;   -- packet header word 2 byte 3
            
signal   packet_header3_0     : byte ;                     -- packet header word 3 byte 0
signal   packet_header3_1     : byte ;                     -- packet header word 3 byte 1
signal   packet_header3_2     : byte ;                     -- packet header word 3 byte 2
signal   packet_header3_3     : byte ;                     -- packet header word 3 byte 3
            
signal   packet_header4_0     : byte ;                     -- packet header word 4 byte 0
signal   packet_header4_1     : byte ;                     -- packet header word 4 byte 1
signal   packet_header4_2     : byte ;                     -- packet header word 4 byte 2
signal   packet_header4_3     : byte ;                     -- packet header word 4 byte 3


-- checksum signals

signal checksum              : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0); 	-- checksum word (output from checksum calculator)
signal checksum_in           : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);  -- input to checksum calculator  

-- recirculation MUX structure used to hold checksum_in value  
signal checksum_in_mux       : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);  -- MUX output
signal checksum_load         : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);  -- new checksum_in value loaded here  
signal checksum_in_mux_sel   : std_logic;                                    -- asserted to register the checksum_load value


-- packet header word 3 options  - reply or data packet...

constant DATA_PACKET          : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0) := ASCII_SP & ASCII_SP & ASCII_D & ASCII_A;
constant REPLY_PACKET         : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0) := ASCII_SP & ASCII_SP & ASCII_R & ASCII_P; 



-- recircluation MUX structure used for registers....

-- mux select lines defined here:

signal packet_word1_0mux_sel   : std_logic_vector (1 downto 0) ;
signal packet_word1_1mux_sel   : std_logic_vector (1 downto 0) ;
signal packet_word1_2mux_sel   : std_logic_vector (1 downto 0) ;       
signal packet_word1_3mux_sel   : std_logic_vector (1 downto 0) ; 
     
signal packet_word2_0mux_sel   : std_logic_vector (1 downto 0) ;    
signal packet_word2_1mux_sel   : std_logic_vector (1 downto 0) ;   
signal packet_word2_2mux_sel   : std_logic_vector (1 downto 0) ;
signal packet_word2_3mux_sel   : std_logic_vector (1 downto 0) ;

signal reply_word3_0mux_sel   : std_logic ;
--signal reply_word3_1mux_sel   : std_logic ;   
--signal reply_word3_2mux_sel   : std_logic ;
--signal reply_word3_3mux_sel   : std_logic ;


signal packet_header3_0mux_sel : std_logic ;
signal packet_header3_1mux_sel : std_logic ;
signal packet_header3_2mux_sel : std_logic ;
signal packet_header3_3mux_sel : std_logic ;

signal packet_header4_0mux_sel : std_logic ;
signal packet_header4_1mux_sel : std_logic ;
signal packet_header4_2mux_sel : std_logic ;
signal packet_header4_3mux_sel : std_logic ;


-- re-circulation mux outputs..

signal packet_header3_0mux     : byte;
signal packet_header3_1mux     : byte;
signal packet_header3_2mux     : byte;
signal packet_header3_3mux     : byte;

signal packet_header4_0mux     : byte;
signal packet_header4_1mux     : byte;
signal packet_header4_2mux     : byte;
signal packet_header4_3mux     : byte;

signal packet_word1_0mux        : byte;
signal packet_word1_1mux        : byte;
signal packet_word1_2mux        : byte;
signal packet_word1_3mux        : byte;

signal packet_word2_0mux        : byte;
signal packet_word2_1mux        : byte;
signal packet_word2_2mux        : byte;
signal packet_word2_3mux        : byte;

signal reply_word3_0mux        : byte;
--signal reply_word3_1mux        : byte;
--signal reply_word3_2mux        : byte;
--signal reply_word3_3mux        : byte;
  
signal wordN_0mux              : byte;
signal wordN_1mux              : byte;
signal wordN_2mux              : byte;
signal wordN_3mux              : byte;



-- Finite State Machines defined here:

----------------------------------------------------------------------------------------------------------------
--                             FIBRE PACKET FSM
----------------------------------------------------------------------------------------------------------------
-- handles the writting off all packets (replies and data) to the
-- fibre transmit FIFO (fibre_tx_fifo) 

type fibre_state is           (FIBRE_IDLE, CK_ER_REPLY, REPLY_GO_RS, REPLY_OK, REPLY_ER, 
                               DATA_FRAME, WAIT_Q_WORD , ACK_Q_WORD, ST_ER_REPLY, NO_REPLY,    
                                                                      
                               LD_HEAD1_0, TX_HEAD1_0, LD_HEAD1_1, TX_HEAD1_1,
                               LD_HEAD1_2, TX_HEAD1_2, LD_HEAD1_3, TX_HEAD1_3,
                               LD_HEAD2_0, TX_HEAD2_0, LD_HEAD2_1, TX_HEAD2_1,
                               LD_HEAD2_2, TX_HEAD2_2, LD_HEAD2_3, TX_HEAD2_3,
                               LD_HEAD3_0, TX_HEAD3_0, LD_HEAD3_1, TX_HEAD3_1,
                               LD_HEAD3_2, TX_HEAD3_2, LD_HEAD3_3, TX_HEAD3_3,
                               LD_HEAD4_0, TX_HEAD4_0, LD_HEAD4_1, TX_HEAD4_1,
                               LD_HEAD4_2, TX_HEAD4_2, LD_HEAD4_3, TX_HEAD4_3,
                               
                               LD_WORD1_0, TX_WORD1_0, LD_WORD1_1, TX_WORD1_1,
                               LD_WORD1_2, TX_WORD1_2, LD_WORD1_3, TX_WORD1_3,
                               LD_WORD2_0, TX_WORD2_0, LD_WORD2_1, TX_WORD2_1,
                               LD_WORD2_2, TX_WORD2_2, LD_WORD2_3, TX_WORD2_3,
                               LD_RP_WORD3_0, TX_RP_WORD3_0, LD_RP_WORD3_1, TX_RP_WORD3_1,
                               LD_RP_WORD3_2, TX_RP_WORD3_2, LD_RP_WORD3_3, TX_RP_WORD3_3,
                               
                               LD_WORDN_0, TX_WORDN_0, LD_WORDN_1, TX_WORDN_1,
                               LD_WORDN_2, TX_WORDN_2, LD_WORDN_3, TX_WORDN_3,
                               
                               LD_CKSUM0,  TX_CKSUM0,  LD_CKSUM1,  TX_CKSUM1,   
                               LD_CKSUM2,  TX_CKSUM2,  LD_CKSUM3,  TX_CKSUM3,
                               
                               DONE
                                                          
                               );
      
signal   fibre_current_state       : fibre_state;
signal   fibre_next_state          : fibre_state;
      
----------------------------------------------------------------------------------------------------------------
--                                  Local FSM
----------------------------------------------------------------------------------------------------------------

-- LOCAL COMMAND FSM
-- handles local commands 
-- currently doesn't do anything!

-- Local command FSM                              
-- type local_state is            (LOCAL_IDLE, LOCAL_TEST);

-- signal   local_current_state        : local_state;
-- signal   local_next_state           : local_state;


----------------------------------------------------------------------------------------------------------------
--                                  Arbitration FSM
----------------------------------------------------------------------------------------------------------------
-- Consider that an application is running  (i.e. data frames are being generated)
-- During this time the only fibre command which can arrive is the ST command.  
-- In the event that the ST command arrives with a checksum error 
-- cmd_translator will inform reply_translator and an error reply needs to be 
-- returned to the host.  
--
-- If this event occurs and the fibre FSM is busy processing a data packet then this 
-- arb FSM will wait until the fibre FSM is no longer busy then inform it that a 
-- ST (checksum error) reply needs to be packaged....
--
-- Note that in future developments this could be extended to handel 
-- the arbitration of nested commands etc...

                              
type     arb_state is            (ARB_IDLE, ARB_ST_ERR);


signal   arb_current_state        : arb_state;
signal   arb_next_state           : arb_state;


-- some local signals

signal packet_size           : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);   -- this value is written to the packet header word 4
signal fibre_word_count      : integer;                                       -- used to count how many words have been read from the reply_queue  

signal fibre_fsm_busy        : std_logic;                                     -- asserted when txing a packet 

signal reply_status          : std_logic_vector (15 downto 0);                -- this word is writen to reply word 1 to indicate if 'OK' or 'ER' 
signal reply_data            : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- this word is the reply or data word read from cmd_queue
signal packet_type           : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- indicates reply or data packet - written to header word 3

signal m_op_done_reply       : std_logic;                                     -- asserted high when a m_op is done and processing a reply packet
signal m_op_done_data        : std_logic;                                     -- asserted high when a m_op is done and processing a data packet
signal m_op_no_reply         : std_logic;                                     -- asserted high when a m_op is done but no packet to be generated

signal rst_checksum          : std_logic;                                     -- signal asserted to reset packet checksum
signal ena_checksum          : std_logic;                                     -- signal assertd to update packet checksum with checksum_in value

signal ena_fibre_count       : std_logic;                                     -- signal asserted to reset fibre count 
signal rst_fibre_count       : std_logic;                                     -- signal asserted to enable fibre count (i.e inc by 1) 

signal fibre_byte            : byte;                                          -- output byte to  be written to tranmit FIFO
signal write_fifo            : std_logic;                                     -- asserted high when writing to transmit FIFO fibre_tx_fifo

signal rb_packet_size        : integer;
signal data_packet_size      : integer;

-- output of ARB FSM.  Used to tell FIBRE FSM that it has missed a ST command (with checksum error)                    
signal stop_err_rdy          : std_logic;
-- fibre fsm uses this to acknowledge that it will package up a reply to checksum error stop
signal arb_fsm_ack           : std_logic    ;                                  


signal reply_argument        :  byte;     -- signal mapped to byte 0 of reply word 3 (except success RB)

signal frame_status          :  std_logic_vector(PACKET_WORD_WIDTH-1 downto 0); 


signal cmd_code_reg          : std_logic_vector (FIBRE_CMD_CODE_WIDTH-1     downto 0);



begin

frame_status(31 downto 2)     <= (others => '0');
frame_status(1)              <= cmd_stop_i;
frame_status(0)              <= last_frame_i;


-- a reply packet should be generated if m_op_done_reply is asserted.

m_op_done_reply  <= m_op_done_i when (m_op_cmd_code_i = WRITE_BLOCK or 
                                      m_op_cmd_code_i = READ_BLOCK  or 
                                      m_op_cmd_code_i = STOP)       
                                      else '0';

-- no reply should be generated if m_op_no_reply is asserted
m_op_no_reply    <= m_op_done_i when (m_op_cmd_code_i = RESET or 
                                      m_op_cmd_code_i = START)       
                                      else '0';

-- a data packet should be generated if m_op_done_data is asserted
m_op_done_data   <= m_op_done_i when m_op_cmd_code_i = DATA else '0';

-- map write_fifo signal to output tx_fw_o
tx_fw_o                     <= write_fifo;                                 



-- for a read block the packet size is alway 3 + the number of words to be read on fibre_word_i
 
rb_packet_size          <= num_fibre_words_i + 3 ;     -- size readblock + words1, 2 and 4(checksum)
data_packet_size        <= num_fibre_words_i + 3 ;     -- number fibre words + status + seq_number + checksum word


-- recirculation MUX selectors 
-- used to register command code, parameter id and card id from cmd_translator
--packet_word1_2mux_sel        <= cmd_rcvd_er_i OR cmd_rcvd_ok_i;
--packet_word1_3mux_sel        <= cmd_rcvd_er_i OR cmd_rcvd_ok_i;
--packet_word2_0mux_sel        <= cmd_rcvd_er_i OR cmd_rcvd_ok_i;
--packet_word2_1mux_sel        <= cmd_rcvd_er_i OR cmd_rcvd_ok_i;
--packet_word2_2mux_sel        <= cmd_rcvd_er_i OR cmd_rcvd_ok_i;
--packet_word2_3mux_sel        <= cmd_rcvd_er_i OR cmd_rcvd_ok_i;

-- packet header recirculation mux structures
packet_header3_0mux <= packet_type ( 7 downto  0)  when packet_header3_0mux_sel = '1' else packet_header3_0;
packet_header3_1mux <= packet_type (15 downto  8)  when packet_header3_1mux_sel = '1' else packet_header3_1;
packet_header3_2mux <= packet_type (23 downto 16)  when packet_header3_2mux_sel = '1' else packet_header3_2;
packet_header3_3mux <= packet_type (31 downto 24)  when packet_header3_3mux_sel = '1' else packet_header3_3;

packet_header4_0mux <= packet_size ( 7 downto  0)  when packet_header4_0mux_sel = '1' else packet_header4_0;
packet_header4_1mux <= packet_size (15 downto  8)  when packet_header4_1mux_sel = '1' else packet_header4_1;
packet_header4_2mux <= packet_size (23 downto 16)  when packet_header4_2mux_sel = '1' else packet_header4_2;
packet_header4_3mux <= packet_size (31 downto 24)  when packet_header4_3mux_sel = '1' else packet_header4_3;

--  packet word 1 recirculation mux structures
packet_word1_0mux   <= reply_status    ( 7 downto  0)  when packet_word1_0mux_sel = "01" else 
                       reply_status    ( 7 downto  0)  when packet_word1_0mux_sel = "10" else 
                       frame_status    ( 7 downto  0)   when packet_word1_0mux_sel = "11" else 
                       packet_word1_0;


packet_word1_1mux   <= reply_status    (15 downto  8)  when packet_word1_1mux_sel = "01" else 
                       reply_status    (15 downto  8)  when packet_word1_1mux_sel = "10" else 
                       frame_status    (15 downto  8)  when packet_word1_1mux_sel = "11" else 
                       packet_word1_1;


packet_word1_2mux   <= cmd_code_i      ( 7 downto  0)  when packet_word1_2mux_sel = "01" else 
                       cmd_code_reg    ( 7 downto  0)  when packet_word1_2mux_sel = "10" else 
                       frame_status    (23 downto 16)  when packet_word1_2mux_sel  = "11" else 
                       packet_word1_2;


packet_word1_3mux   <= cmd_code_i      (15 downto  8)  when packet_word1_3mux_sel = "01" else 
                       cmd_code_reg    (15 downto  8)  when packet_word1_3mux_sel = "10" else 
                       frame_status    (31 downto 24)  when packet_word1_3mux_sel = "11" else 
                       packet_word1_3;


--  packet word 2 recirculation mux structures
packet_word2_0mux   <= param_id_i      ( 7 downto  0)  when packet_word2_0mux_sel = "01" else
                       m_op_param_id_i ( 7 downto  0)  when packet_word2_0mux_sel = "10" else
                       frame_seq_num_i ( 7 downto  0)  when packet_word2_0mux_sel = "11" else
                       packet_word2_0;
                       
packet_word2_1mux   <= param_id_i      (15 downto  8)  when packet_word2_1mux_sel = "01" else
                       (others => '0')                 when packet_word2_1mux_sel = "10" else
                       frame_seq_num_i (15 downto  8)  when packet_word2_1mux_sel = "11" else
                       packet_word2_1;
                       
packet_word2_2mux   <= card_id_i       ( 7 downto  0)  when packet_word2_2mux_sel = "01" else 
                       m_op_card_id_i  ( 7 downto  0)  when packet_word2_2mux_sel = "10" else
                       frame_seq_num_i (23 downto 16)  when packet_word2_2mux_sel = "11" else
                       packet_word2_2;

packet_word2_3mux   <= card_id_i       (15 downto  8)  when packet_word2_3mux_sel = "01" else 
                       (others => '0')                 when packet_word2_3mux_sel = "10" else 
                       frame_seq_num_i (31 downto 24)  when packet_word2_3mux_sel = "11" else 
                       packet_word2_3;


--  reply word 3 recirculation mux structures
reply_word3_0mux   <= reply_argument  when reply_word3_0mux_sel = '1' else reply_word3_0;

reply_word3_1   <= (others => '0');
reply_word3_2   <= (others => '0');
reply_word3_3   <= (others => '0'); 
        
--  data/read block words recirculation mux structures
-- latch fibre_word when fibre_word_rdy asserted.....

wordN_0mux         <= fibre_word_i ( 7 downto  0) when fibre_word_rdy_i = '1' else wordN_0;
wordN_1mux         <= fibre_word_i (15 downto  8) when fibre_word_rdy_i = '1' else wordN_1;
wordN_2mux         <= fibre_word_i (23 downto 16) when fibre_word_rdy_i = '1' else wordN_2;
wordN_3mux         <= fibre_word_i (31 downto 24) when fibre_word_rdy_i = '1' else wordN_3;


-- checksum calculator input recirculation strucutre 
checksum_in_mux    <= checksum_load  when checksum_in_mux_sel = '1' else checksum_in;


-- data output.  
txd_o              <= fibre_byte;


  ------------------------------------------------------------------------------
  register_packet: process(clk_i, rst_i)
  ----------------------------------------------------------------------------
  -- process to register recircualtion MUX outputs 
  ----------------------------------------------------------------------------
  begin
     if (rst_i = '1') then 
     
        packet_header3_0 <= (others => '0');  
        packet_header3_1 <= (others => '0'); 
        packet_header3_2 <= (others => '0');
        packet_header3_3 <= (others => '0'); 
     
        packet_header4_0 <= (others => '0');  
        packet_header4_1 <= (others => '0'); 
        packet_header4_2 <= (others => '0');
        packet_header4_3 <= (others => '0'); 

        packet_word1_0   <= (others => '0');
        packet_word1_1   <= (others => '0');
        packet_word1_2   <= (others => '0');
        packet_word1_3   <= (others => '0');
        
        packet_word2_0   <= (others => '0');
        packet_word2_1   <= (others => '0');
        packet_word2_2   <= (others => '0');
        packet_word2_3   <= (others => '0');
        
        reply_word3_0   <= (others => '0');

        wordN_0   <= (others => '0');
        wordN_1   <= (others => '0');
        wordN_2   <= (others => '0');
        wordN_3   <= (others => '0');
        
        checksum_in <= (others => '0');
        
     elsif (clk_i'EVENT and clk_i = '1') then
     
        packet_header3_0 <= packet_header3_0mux;
        packet_header3_1 <= packet_header3_1mux;
        packet_header3_2 <= packet_header3_2mux;
        packet_header3_3 <= packet_header3_3mux;
     
        packet_header4_0 <= packet_header4_0mux;
        packet_header4_1 <= packet_header4_1mux;
        packet_header4_2 <= packet_header4_2mux;
        packet_header4_3 <= packet_header4_3mux;
        
        packet_word1_0    <= packet_word1_0mux;
        packet_word1_1    <= packet_word1_1mux;
        packet_word1_2    <= packet_word1_2mux;
        packet_word1_3    <= packet_word1_3mux;
   
        packet_word2_0    <= packet_word2_0mux;
        packet_word2_1    <= packet_word2_1mux;
        packet_word2_2    <= packet_word2_2mux;
        packet_word2_3    <= packet_word2_3mux;
        
        reply_word3_0    <= reply_word3_0mux;
       
        
        wordN_0          <= wordN_0mux;
        wordN_1          <= wordN_1mux;
        wordN_2          <= wordN_2mux;
        wordN_3          <= wordN_3mux;
        
        checksum_in      <= checksum_in_mux;
           
     end if;
  end process register_packet;
              
              
  ------------------------------------------------------------------------------
  register_cmd_code: process(clk_i, rst_i)
  ----------------------------------------------------------------------------
  -- process to register cmd_code from cmd_translator 
  ----------------------------------------------------------------------------
  begin
     if (rst_i = '1') then             
     
        cmd_code_reg <= (others => '0');
     
     elsif (clk_i'EVENT and clk_i = '1') then
     
        if ((cmd_rcvd_er_i = '1') or (cmd_rcvd_ok_i = '1') ) then
           cmd_code_reg <= cmd_code_i;
        end if; 
     
     end if;
     
  end process register_cmd_code ;   
     
              
              
            
        
   ---------------------------------------------------------------------------
   -- FIBRE FSM - writes fibre packets to transmit FIFO  
   ----------------------------------------------------------------------------
   fibre_fsm_clocked : process(
      clk_i,
      rst_i
   )
   ----------------------------------------------------------------------------
   begin
         
      if (rst_i = '1') then
         fibre_current_state <= FIBRE_IDLE;
      elsif (clk_i'EVENT AND clk_i = '1') then
         fibre_current_state <= fibre_next_state;
      end if;

   end process fibre_fsm_clocked;

   -------------------------------------------------------------------------
   fibre_fsm_nextstate : process ( 
      fibre_current_state, cmd_rcvd_ok_i, cmd_rcvd_er_i, m_op_done_reply,
      m_op_no_reply, m_op_done_data, cmd_code_i, m_op_error_code_i, tx_ff_i, 
      num_fibre_words_i, fibre_word_count, m_op_cmd_code_i, stop_err_rdy,
      fibre_word_rdy_i
   )
   ----------------------------------------------------------------------------
   begin
     
      case fibre_current_state is


      when FIBRE_IDLE =>
         if    (cmd_rcvd_er_i = '1') then
            fibre_next_state <= CK_ER_REPLY;
         elsif ((cmd_rcvd_ok_i = '1'                 and 
                 cmd_code_i(15 downto 8) = ASCII_G   and 
                 cmd_code_i(7 downto 0) = ASCII_O )  
                 or 
                (cmd_rcvd_ok_i = '1'                 and 
                 cmd_code_i(15 downto 8) = ASCII_R   and 
                 cmd_code_i(7 downto 0) = ASCII_S )) then
                                            
            fibre_next_state <= REPLY_GO_RS;
            
         elsif (stop_err_rdy = '1') then                 -- if we missed a stop command with checksum error during data readout
            fibre_next_state <= ST_ER_REPLY;     
         elsif (m_op_done_reply = '1' and m_op_error_code_i = COMMAND_SUCCESS) then 
            fibre_next_state <= REPLY_OK;
         elsif (m_op_done_reply = '1' and m_op_error_code_i /= COMMAND_SUCCESS) then 
            fibre_next_state <= REPLY_ER; 
         elsif (m_op_no_reply = '1') then 
            fibre_next_state <= NO_REPLY;
         elsif (m_op_done_data = '1') then
            fibre_next_state <= DATA_FRAME;
         else
            fibre_next_state <= FIBRE_IDLE;   
         end if;  
         
         
      when  CK_ER_REPLY | REPLY_GO_RS | REPLY_OK | REPLY_ER | ST_ER_REPLY | DATA_FRAME =>
          
            fibre_next_state <= LD_HEAD1_0;
          
      when NO_REPLY =>                                 -- generate an acknowledgement to a m_op done that doesn't require a packet to be generated
         if (m_op_no_reply = '1') then               -- wait in this state until m_op_done deasserted... 
            fibre_next_state <= NO_REPLY;
         else
            fibre_next_state <= FIBRE_IDLE;           -- once deasserted return to IDLE
         end if;
               
          
-- transmit reply header states
       
       when LD_HEAD1_0 =>
          if tx_ff_i = '1' then 
             fibre_next_state <= LD_HEAD1_0;
          else
             fibre_next_state <= TX_HEAD1_0;
          end if;   
             
       when TX_HEAD1_0 =>
          fibre_next_state <= LD_HEAD1_1; 
  
           
       when LD_HEAD1_1 =>
          if tx_ff_i = '1' then 
             fibre_next_state <= LD_HEAD1_1;
          else
             fibre_next_state <= TX_HEAD1_1;
          end if;  
           
       
       when TX_HEAD1_1 =>
          fibre_next_state <= LD_HEAD1_2; 
          
       when LD_HEAD1_2 =>
          if tx_ff_i = '1' then 
             fibre_next_state <= LD_HEAD1_2;
          else
             fibre_next_state <= TX_HEAD1_2;
          end if;  
           
           
       when TX_HEAD1_2 =>
          fibre_next_state <= LD_HEAD1_3;
           
       when LD_HEAD1_3 =>
          if tx_ff_i = '1' then 
             fibre_next_state <= LD_HEAD1_3;
          else
             fibre_next_state <= TX_HEAD1_3;
          end if;  
           
           
       when TX_HEAD1_3 =>
          fibre_next_state <= LD_HEAD2_0;
           
       when LD_HEAD2_0 =>
          if tx_ff_i = '1' then 
             fibre_next_state <= LD_HEAD2_0;
          else
             fibre_next_state <= TX_HEAD2_0;
          end if;  
           
       when TX_HEAD2_0 =>
          fibre_next_state <= LD_HEAD2_1;
           
       when LD_HEAD2_1 =>
          if tx_ff_i = '1' then 
             fibre_next_state <= LD_HEAD2_1;
          else
             fibre_next_state <= TX_HEAD2_1;
          end if;    
       
       when TX_HEAD2_1 =>
          fibre_next_state <= LD_HEAD2_2;
       
       when LD_HEAD2_2 =>
          if tx_ff_i = '1' then 
             fibre_next_state <= LD_HEAD2_2;
          else
             fibre_next_state <= TX_HEAD2_2;
          end if;  
          
       
       when TX_HEAD2_2 =>
         fibre_next_state <= LD_HEAD2_3;
       
       when LD_HEAD2_3 =>
          if tx_ff_i = '1' then 
             fibre_next_state <= LD_HEAD2_3;
          else
             fibre_next_state <= TX_HEAD2_3;
          end if;  
          
       
       when TX_HEAD2_3 =>
          fibre_next_state <= LD_HEAD3_0;
           
       when LD_HEAD3_0 =>
          if tx_ff_i = '1' then 
             fibre_next_state <= LD_HEAD3_0;
          else
             fibre_next_state <= TX_HEAD3_0;
          end if;  
           
           
       when TX_HEAD3_0 =>
         fibre_next_state <= LD_HEAD3_1;
           
       when LD_HEAD3_1 =>
          if tx_ff_i = '1' then 
             fibre_next_state <= LD_HEAD3_1;
          else
             fibre_next_state <= TX_HEAD3_1;
          end if;  
          
       
       when TX_HEAD3_1 =>
          fibre_next_state <= LD_HEAD3_2;
       
       when LD_HEAD3_2 =>
          if tx_ff_i = '1' then 
             fibre_next_state <= LD_HEAD3_2;
          else
             fibre_next_state <= TX_HEAD3_2;
          end if;   
       
       when TX_HEAD3_2 =>
          fibre_next_state <= LD_HEAD3_3;
       
       when LD_HEAD3_3 =>
          if tx_ff_i = '1' then 
             fibre_next_state <= LD_HEAD3_3;
          else
             fibre_next_state <= TX_HEAD3_3;
          end if;  
           
       when TX_HEAD3_3 =>
         fibre_next_state <= LD_HEAD4_0;
       
       when LD_HEAD4_0 =>
          if tx_ff_i = '1' then 
             fibre_next_state <= LD_HEAD4_0;
          else
             fibre_next_state <= TX_HEAD4_0;
          end if;  
           
       
       when TX_HEAD4_0 =>
          fibre_next_state <= LD_HEAD4_1;
       
       when LD_HEAD4_1 =>
          if tx_ff_i = '1' then 
             fibre_next_state <= LD_HEAD4_1;
          else
             fibre_next_state <= TX_HEAD4_1;
          end if;     
           
       when TX_HEAD4_1 =>
           fibre_next_state <= LD_HEAD4_2;
       
       when LD_HEAD4_2 =>
          if tx_ff_i = '1' then 
             fibre_next_state <= LD_HEAD4_2;
          else
             fibre_next_state <= TX_HEAD4_2;
          end if;  
         
   
       when TX_HEAD4_2 =>
          fibre_next_state <= LD_HEAD4_3;
  
       when LD_HEAD4_3 =>
          if tx_ff_i = '1' then 
             fibre_next_state <= LD_HEAD4_3;
          else
             fibre_next_state <= TX_HEAD4_3;
          end if;  
         
  
       when TX_HEAD4_3 =>
       
      --    if  m_op_done_data = '1' then 
      --       fibre_next_state <= WAIT_Q_WORD;      -- data packet - go get data words from reply queue....
      --    else                                     
             fibre_next_state <= LD_WORD1_0;       --  packet word 1...
      --    end if;
          
 
 
 -- transmit reply word states
 
           
       when LD_WORD1_0 =>
          if tx_ff_i = '1' then 
             fibre_next_state <= LD_WORD1_0;
          else
             fibre_next_state <= TX_WORD1_0;
          end if;  
          
             
       when TX_WORD1_0 =>
         fibre_next_state <= LD_WORD1_1;
           
       when LD_WORD1_1 =>
          if tx_ff_i = '1' then 
             fibre_next_state <= LD_WORD1_1;
          else
             fibre_next_state <= TX_WORD1_1;
          end if; 
          
       
       when TX_WORD1_1 =>
          fibre_next_state <= LD_WORD1_2;
          
       when LD_WORD1_2 =>
          if tx_ff_i = '1' then 
             fibre_next_state <= LD_WORD1_2;
          else
             fibre_next_state <= TX_WORD1_2;
          end if; 
        
           
       when TX_WORD1_2 =>
           fibre_next_state <= LD_WORD1_3;
           
       when LD_WORD1_3 =>
          if tx_ff_i = '1' then 
             fibre_next_state <= LD_WORD1_3;
          else
             fibre_next_state <= TX_WORD1_3;
          end if; 
           
       when TX_WORD1_3 =>
           fibre_next_state <= LD_WORD2_0;
           
       when LD_WORD2_0 =>
          if tx_ff_i = '1' then 
             fibre_next_state <= LD_WORD2_0;
          else
             fibre_next_state <= TX_WORD2_0;
          end if; 
   
           
       when TX_WORD2_0 =>
          fibre_next_state <= LD_WORD2_1;
      
       when LD_WORD2_1 =>
          if tx_ff_i = '1' then 
             fibre_next_state <= LD_WORD2_1;
          else
             fibre_next_state <= TX_WORD2_1;
          end if; 
     
       when TX_WORD2_1 =>
          fibre_next_state <= LD_WORD2_2;
       
       when LD_WORD2_2 =>
          if tx_ff_i = '1' then 
             fibre_next_state <= LD_WORD2_2;
          else
             fibre_next_state <= TX_WORD2_2;
          end if; 
  
       when TX_WORD2_2 =>
          fibre_next_state <= LD_WORD2_3;
          
       when LD_WORD2_3 =>
          if tx_ff_i = '1' then 
             fibre_next_state <= LD_WORD2_3;
          else
             fibre_next_state <= TX_WORD2_3;
          end if; 

       when TX_WORD2_3 =>
       
          if  (m_op_done_data = '1') then           -- if data frame
             fibre_next_state <= WAIT_Q_WORD;        -- request data words
          
          elsif (m_op_done_reply = '1' and m_op_cmd_code_i = READ_BLOCK and m_op_error_code_i = COMMAND_SUCCESS) then    -- if successful read_block reply then 
             fibre_next_state <= WAIT_Q_WORD;                                    -- need to request data block words
          
          else
             fibre_next_state <= LD_RP_WORD3_0;                                 -- otherwise process standard word 3.
          
          end if;
          
       
       when LD_RP_WORD3_0 =>
          if tx_ff_i = '1' then 
             fibre_next_state <= LD_RP_WORD3_0;
          else
             fibre_next_state <= TX_RP_WORD3_0;
          end if; 
   
           
       when TX_RP_WORD3_0 =>
          fibre_next_state <= LD_RP_WORD3_1;
      
       when LD_RP_WORD3_1 =>
          if tx_ff_i = '1' then 
             fibre_next_state <= LD_RP_WORD3_1;
          else
             fibre_next_state <= TX_RP_WORD3_1;
          end if; 
     
       when TX_RP_WORD3_1 =>
          fibre_next_state <= LD_RP_WORD3_2;
       
       when LD_RP_WORD3_2 =>
          if tx_ff_i = '1' then 
             fibre_next_state <= LD_RP_WORD3_2;
          else
             fibre_next_state <= TX_RP_WORD3_2;
          end if; 
  
       when TX_RP_WORD3_2 =>
          fibre_next_state <= LD_RP_WORD3_3;
          
       when LD_RP_WORD3_3 =>
          if tx_ff_i = '1' then 
             fibre_next_state <= LD_RP_WORD3_3;
          else
             fibre_next_state <= TX_RP_WORD3_3;
          end if; 

       when TX_RP_WORD3_3 =>
          fibre_next_state <= LD_CKSUM0;
          
                    
         
       when LD_WORDN_0 =>
           
          if tx_ff_i = '1' then 
             fibre_next_state <= LD_WORDN_0;
          else
             fibre_next_state <= TX_WORDN_0;
          end if; 
          
       when TX_WORDN_0 =>
          fibre_next_state <= LD_WORDN_1;

       when LD_WORDN_1 =>
          if tx_ff_i = '1' then 
             fibre_next_state <= LD_WORDN_1;
          else
             fibre_next_state <= TX_WORDN_1;
          end if; 
          
       when TX_WORDN_1 =>
          fibre_next_state <= LD_WORDN_2;          
             
             
       when LD_WORDN_2 =>
          if tx_ff_i = '1' then 
             fibre_next_state <= LD_WORDN_2;
          else
             fibre_next_state <= TX_WORDN_2;
          end if; 
          
       when TX_WORDN_2 =>
          fibre_next_state <= LD_WORDN_3;        
             
        
       when LD_WORDN_3 =>
          if tx_ff_i = '1' then 
             fibre_next_state <= LD_WORDN_3;
          else
             fibre_next_state <= TX_WORDN_3;
          end if; 
          
       when TX_WORDN_3 =>
       
          fibre_next_state <= ACK_Q_WORD;
       
       
       when ACK_Q_WORD =>
              
          if (fibre_word_count < num_fibre_words_i ) then          
            
             fibre_next_state <= WAIT_Q_WORD;              -- another fibre word to read fromn Q
          else
             fibre_next_state <= LD_CKSUM0;               -- no word words in Q.  tx checksum.
          end if;
           
       
             
        
     -- get and transmit reply q words
     
        
       when WAIT_Q_WORD =>
          if (fibre_word_rdy_i  = '1') then 
             fibre_next_state <= LD_WORDN_0;
          else
             fibre_next_state <= WAIT_Q_WORD;
          end if;  
          
       
     -- transmit checksum  states 
        
       when LD_CKSUM0 =>
          if tx_ff_i = '1' then 
             fibre_next_state <= LD_CKSUM0;
          else
             fibre_next_state <= TX_CKSUM0;
          end if; 
          
       when TX_CKSUM0 =>
          fibre_next_state <= LD_CKSUM1;  
       
       when LD_CKSUM1 =>
          if tx_ff_i = '1' then 
             fibre_next_state <= LD_CKSUM1;
          else
             fibre_next_state <= TX_CKSUM1;
          end if; 
       
       when TX_CKSUM1 =>
          fibre_next_state <= LD_CKSUM2;  
                                 
       when LD_CKSUM2 =>
          if tx_ff_i = '1' then 
             fibre_next_state <= LD_CKSUM2;
          else
             fibre_next_state <= TX_CKSUM2;
          end if; 
       
       when TX_CKSUM2 =>  
          fibre_next_state <= LD_CKSUM3;  
                      
       when LD_CKSUM3 =>
          if tx_ff_i = '1' then 
             fibre_next_state <= LD_CKSUM3;
          else
             fibre_next_state <= TX_CKSUM3;
          end if;                    
                   
                    
       when TX_CKSUM3 =>  
            fibre_next_state <= DONE; 
                                 
                         
       when DONE =>  
          fibre_next_state <= FIBRE_IDLE;      
            
      when OTHERS =>
         fibre_next_state <= FIBRE_IDLE;   
         
      end case;
      
   end process fibre_fsm_nextstate;
    
         
   -------------------------------------------------------------------------
   reply_fsm_output : process (
      fibre_current_state, checksum, m_op_error_code_i, data_packet_size,
      m_op_done_reply, m_op_done_data, m_op_cmd_code_i,  rb_packet_size, 
      packet_header3_0, packet_header3_1, packet_header3_2, packet_header3_3,
      packet_header4_0, packet_header4_1, packet_header4_2, packet_header4_3,
      packet_word1_0,    packet_word1_1,    packet_word1_2,    packet_word1_3,
      packet_word2_0,    packet_word2_1,    packet_word2_2,    packet_word2_3,
      reply_word3_0,    reply_word3_1,    reply_word3_2,    reply_word3_3,
      wordN_0,          wordN_1,          wordN_2,          wordN_3
   )
   ----------------------------------------------------------------------------
   begin
   
      packet_header3_0mux_sel  <= '0';
      packet_header3_1mux_sel  <= '0';
      packet_header3_2mux_sel  <= '0';
      packet_header3_3mux_sel  <= '0';
        
      packet_header4_0mux_sel  <= '0';
      packet_header4_1mux_sel  <= '0';
      packet_header4_2mux_sel  <= '0';
      packet_header4_3mux_sel  <= '0';

      packet_word1_0mux_sel    <= "00";
      packet_word1_1mux_sel    <= "00";
      packet_word1_2mux_sel    <= "00";
      packet_word1_3mux_sel    <= "00";
      packet_word2_0mux_sel    <= "00";
      packet_word2_1mux_sel    <= "00";
      packet_word2_2mux_sel    <= "00";
      packet_word2_3mux_sel    <= "00";
      
      
      reply_word3_0mux_sel     <= '0';
      
     
      fibre_fsm_busy           <= '1';  
      write_fifo               <= '0';  
      fibre_word_req_o         <= '0';
    
      rst_checksum             <= '0' ;
      ena_checksum             <= '0' ;
             
      checksum_in_mux_sel      <= '0';
      
      rst_fibre_count          <= '0';
      ena_fibre_count          <= '0';
      
      m_op_ack_o               <= '0';
      arb_fsm_ack              <= '0';
      
      fibre_byte               <= (others => '0');
      
      case fibre_current_state is



      when FIBRE_IDLE =>               -- Idle state - no packets to process
      
            fibre_fsm_busy             <= '0';                 -- indicate no longer tranmitting packet
            rst_checksum               <= '1';                 -- reset checksum
            rst_fibre_count            <= '1';                 -- reset fibre count
            checksum_load              <= (others => '0');     -- reset checksum calculator input
            checksum_in_mux_sel        <= '1';                 -- register reset checksum calculator input
                
            packet_size                <= (others => '0');     -- reset packet size
            reply_status               <= (others => '0');     -- reset reply status
            reply_data                 <= (others => '0');     -- reset reply/data word
            packet_type                <= (others => '0');     -- reset packet type
            
      when CK_ER_REPLY =>              -- checksum error state
  
            reply_status( 7 downto 0)  <= ASCII_R ;
            reply_status(15 downto 8)  <= ASCII_E ;
            packet_size                <= conv_std_logic_vector(NUM_REPLY_WORDS,32);
            reply_argument             <= FIBRE_CHECKSUM_ERR;
            packet_type                <= ASCII_SP & ASCII_SP & ASCII_R & ASCII_P ;
            
      
            packet_header3_0mux_sel    <= '1';
            packet_header3_1mux_sel    <= '1';
            packet_header3_2mux_sel    <= '1';
            packet_header3_3mux_sel    <= '1';

            packet_header4_0mux_sel    <= '1';
            packet_header4_1mux_sel    <= '1';
            packet_header4_2mux_sel    <= '1';
            packet_header4_3mux_sel    <= '1';
       
         
            packet_word1_0mux_sel      <= "01";   -- 
            packet_word1_1mux_sel      <= "01";
            packet_word1_2mux_sel      <= "01";
            packet_word1_3mux_sel      <= "01";
            packet_word2_0mux_sel      <= "01";
            packet_word2_1mux_sel      <= "01";
            packet_word2_2mux_sel      <= "01";
            packet_word2_3mux_sel      <= "01";
            
            reply_word3_0mux_sel       <= '1';
   
      
      when ST_ER_REPLY =>              -- checksum error for ST command received during readout...now process
      
            reply_status( 7 downto 0)  <= ASCII_R ;
            reply_status(15 downto 8)  <= ASCII_E ;
            packet_size                <= conv_std_logic_vector(NUM_REPLY_WORDS,32);
            reply_argument             <= FIBRE_CHECKSUM_ERR;
            packet_type                <= ASCII_SP & ASCII_SP & ASCII_R & ASCII_P ;
            
      
            packet_header3_0mux_sel    <= '1';
            packet_header3_1mux_sel    <= '1';
            packet_header3_2mux_sel    <= '1';
            packet_header3_3mux_sel    <= '1';

            packet_header4_0mux_sel    <= '1';
            packet_header4_1mux_sel    <= '1';
            packet_header4_2mux_sel    <= '1';
            packet_header4_3mux_sel    <= '1';
         
     
            packet_word1_0mux_sel      <= "01";
            packet_word1_1mux_sel      <= "01";
            packet_word1_2mux_sel      <= "01";
            packet_word1_3mux_sel      <= "01";
            packet_word2_0mux_sel      <= "01";
            packet_word2_1mux_sel      <= "01";
            packet_word2_2mux_sel      <= "01";
            packet_word2_3mux_sel      <= "01";
            
            reply_word3_0mux_sel       <= '1';
          
            
            arb_fsm_ack                <= '1';   
            
      when REPLY_GO_RS =>              -- command is reset or go....so generate an instant reply...
      
            reply_status( 7 downto 0)  <= ASCII_K ;             
            reply_status(15 downto 8)  <= ASCII_O ;
            packet_size                <= conv_std_logic_vector(NUM_REPLY_WORDS,32);

            reply_argument             <= (others => '0');   -- reply word 3 is 0
            packet_type                <= REPLY_PACKET;
                        
            packet_header3_0mux_sel    <= '1';              -- register packet type (b0)
            packet_header3_1mux_sel    <= '1';              -- register packet type (b1)
            packet_header3_2mux_sel    <= '1';              -- register packet type (b2)
            packet_header3_3mux_sel    <= '1';              -- register packet type (b3)
            
            packet_header4_0mux_sel    <= '1';              -- register packet size 
            packet_header4_1mux_sel    <= '1';              -- register packet size 
            packet_header4_2mux_sel    <= '1';              -- register packet size 
            packet_header4_3mux_sel    <= '1';              -- register packet size 

       
            packet_word1_0mux_sel      <= "01";
            packet_word1_1mux_sel      <= "01";
            packet_word1_2mux_sel      <= "01";
            packet_word1_3mux_sel      <= "01";
            packet_word2_0mux_sel      <= "01";
            packet_word2_1mux_sel      <= "01";
            packet_word2_2mux_sel      <= "01";
            packet_word2_3mux_sel      <= "01";
            
            
            reply_word3_0mux_sel       <= '1';              -- register reply word 3 byte 0
       
           
      when REPLY_OK    =>   

            if (m_op_cmd_code_i = READ_BLOCK) then 
               packet_size             <= conv_std_logic_vector(rb_packet_size,PACKET_WORD_WIDTH);    
            else
               packet_size             <= conv_std_logic_vector(NUM_REPLY_WORDS,32); 
            end if;
            
            
            reply_status( 7 downto 0)  <= ASCII_K ;
            reply_status(15 downto 8)  <= ASCII_O ;
            packet_type                <= REPLY_PACKET; 
            reply_argument             <= m_op_error_code_i ;        -- this will be error code x"00" - i.e. success.

              
            packet_word1_0mux_sel      <= "10";
            packet_word1_1mux_sel      <= "10";
            packet_word1_2mux_sel      <= "10";
            packet_word1_3mux_sel      <= "10";
            packet_word2_0mux_sel      <= "10";
            packet_word2_1mux_sel      <= "10";
            packet_word2_2mux_sel      <= "10";
            packet_word2_3mux_sel      <= "10";
           
            
            reply_word3_0mux_sel       <= '1';
            
            packet_header3_0mux_sel    <= '1';
            packet_header3_1mux_sel    <= '1';
            packet_header3_2mux_sel    <= '1';
            packet_header3_3mux_sel    <= '1';
                    
            packet_header4_0mux_sel    <= '1';               -- register reply word 3 byte 0
            packet_header4_1mux_sel    <= '1';               -- register reply word 3 byte 1
            packet_header4_2mux_sel    <= '1';               -- register reply word 3 byte 2
            packet_header4_3mux_sel    <= '1';               -- register reply word 3 byte 3
            
      when REPLY_ER    =>   

            packet_size <= conv_std_logic_vector(NUM_REPLY_WORDS,32);    
--            packet_size <= std_logic_vector(to_unsigned(NUM_REPLY_WORDS,32));
            reply_status( 7 downto 0)  <= ASCII_R ;
            reply_status(15 downto 8)  <= ASCII_E ;
            packet_type                <= REPLY_PACKET;
            reply_argument             <= m_op_error_code_i ;     
            
              
            packet_word1_0mux_sel      <= "10";
            packet_word1_1mux_sel      <= "10";
            packet_word1_2mux_sel      <= "10";
            packet_word1_3mux_sel      <= "10";
            packet_word2_0mux_sel      <= "10";
            packet_word2_1mux_sel      <= "10";
            packet_word2_2mux_sel      <= "10";
            packet_word2_3mux_sel      <= "10";
            
            
            
            reply_word3_0mux_sel       <= '1';               -- register error code to reply word 3 byte 0
            
            packet_header3_0mux_sel    <= '1';               -- register packet header 3 byte 0
            packet_header3_1mux_sel    <= '1';               -- register packet header 3 byte 1
            packet_header3_2mux_sel    <= '1';               -- register packet header 3 byte 2
            packet_header3_3mux_sel    <= '1';               -- register packet header 3 byte 3
                    
            packet_header4_0mux_sel    <= '1';               -- register packet header 4 byte 0
            packet_header4_1mux_sel    <= '1';               -- register packet header 4 byte 1
            packet_header4_2mux_sel    <= '1';               -- register packet header 4 byte 2
            packet_header4_3mux_sel    <= '1';               -- register packet header 4 byte 3
       
       when NO_REPLY       =>                                -- if no_reply is required just acknowledge the 
            m_op_ack_o                 <= '1';               -- m_op done.
                        
       when DATA_FRAME     =>   
    
            packet_size                <= conv_std_logic_vector(data_packet_size,PACKET_WORD_WIDTH);
            packet_type                <= DATA_PACKET;

    
            packet_header3_0mux_sel    <= '1';               -- register packet header 3 byte 0
            packet_header3_1mux_sel    <= '1';               -- register packet header 3 byte 1
            packet_header3_2mux_sel    <= '1';               -- register packet header 3 byte 2
            packet_header3_3mux_sel    <= '1';               -- register packet header 3 byte 3
                    
            packet_header4_0mux_sel    <= '1';               -- register packet header 4 byte 0
            packet_header4_1mux_sel    <= '1';               -- register packet header 4 byte 1
            packet_header4_2mux_sel    <= '1';               -- register packet header 4 byte 2
            packet_header4_3mux_sel    <= '1';               -- register packet header 4 byte 3


            packet_word1_0mux_sel      <= "11";
            packet_word1_1mux_sel      <= "11";
            packet_word1_2mux_sel      <= "11";
            packet_word1_3mux_sel      <= "11";
            packet_word2_0mux_sel      <= "11";
            packet_word2_1mux_sel      <= "11";
            packet_word2_2mux_sel      <= "11";
            packet_word2_3mux_sel      <= "11";



       when LD_HEAD1_0 =>
           fibre_byte                  <=  packet_header1_0;
           write_fifo                  <= '0';
             
       when TX_HEAD1_0 =>
           fibre_byte                  <=  packet_header1_0;
           write_fifo                  <= '1';
           
       when LD_HEAD1_1 =>
           fibre_byte                  <=  packet_header1_1;
           write_fifo                  <= '0';
       
       when TX_HEAD1_1 =>
           fibre_byte                  <=  packet_header1_1;
           write_fifo                  <= '1';
          
       when LD_HEAD1_2 =>
           fibre_byte                  <=  packet_header1_2;
           write_fifo                  <= '0'; 
           
       when TX_HEAD1_2 =>
           fibre_byte                  <=  packet_header1_2;
           write_fifo                  <= '1';
           
       when LD_HEAD1_3 =>
           fibre_byte                  <=  packet_header1_3;
           write_fifo                  <= '0';
           
       when TX_HEAD1_3 =>
           fibre_byte                  <=  packet_header1_3;
           write_fifo                  <= '1';
           
       when LD_HEAD2_0 =>
           fibre_byte                  <=  packet_header2_0;
           write_fifo                  <= '0';
           
       when TX_HEAD2_0 =>
           fibre_byte                  <=  packet_header2_0;
           write_fifo                  <= '1';
           
       when LD_HEAD2_1 =>
           fibre_byte                  <=  packet_header2_1;
           write_fifo                  <= '0';
       
       when TX_HEAD2_1 =>
           fibre_byte                  <=  packet_header2_1;
           write_fifo                  <= '1';
       
       when LD_HEAD2_2 =>
           fibre_byte                  <=  packet_header2_2;
           write_fifo                  <= '0';
       
       when TX_HEAD2_2 =>
           fibre_byte                  <=  packet_header2_2;
           write_fifo                  <= '1';
       
       when LD_HEAD2_3 =>
           fibre_byte                  <=  packet_header2_3;
           write_fifo                  <= '0';
       
       when TX_HEAD2_3 =>
           fibre_byte                  <=  packet_header2_3;
           write_fifo                  <= '1';
           
       when LD_HEAD3_0 =>
           fibre_byte                  <=  packet_header3_0;
           write_fifo                  <= '0';
           
       when TX_HEAD3_0 =>
           fibre_byte                  <=  packet_header3_0;
           write_fifo                  <= '1';
           
       when LD_HEAD3_1 =>
           fibre_byte                  <=  packet_header3_1;
           write_fifo                  <= '0';
       
       when TX_HEAD3_1 =>
           fibre_byte                  <=  packet_header3_1;
           write_fifo                  <= '1';
       
       when LD_HEAD3_2 =>
           fibre_byte                  <=  packet_header3_2;
           write_fifo                  <= '0';
       
       when TX_HEAD3_2 =>
           fibre_byte                  <=  packet_header3_2;
           write_fifo                  <= '1';
       
       when LD_HEAD3_3 =>
           fibre_byte                  <=  packet_header3_3;
           write_fifo                  <= '0';
       
       when TX_HEAD3_3 =>
           fibre_byte                  <=  packet_header3_3;
           write_fifo                  <= '1';
       
       when LD_HEAD4_0 =>
           fibre_byte                  <=  packet_header4_0;
           write_fifo                  <= '0';
       
       when TX_HEAD4_0 =>
           fibre_byte                  <=  packet_header4_0;
           write_fifo                  <= '1';
       
       when LD_HEAD4_1 =>
           fibre_byte                  <=  packet_header4_1;
           write_fifo                  <= '0';
           
       when TX_HEAD4_1 =>
           fibre_byte                  <=  packet_header4_1;
           write_fifo                  <= '1';
       
       when LD_HEAD4_2 =>
           fibre_byte                  <=  packet_header4_2;
           write_fifo                  <= '0';
   
       when TX_HEAD4_2 =>
           fibre_byte                  <=  packet_header4_2;
           write_fifo                  <= '1';
  
       when LD_HEAD4_3 =>
           fibre_byte                  <=  packet_header4_3;
           write_fifo                  <= '0';
  
       when TX_HEAD4_3 =>
           fibre_byte                  <=  packet_header4_3;
           write_fifo                  <= '1';
           
       when LD_WORD1_0 =>
           fibre_byte                  <=  packet_word1_0;
           write_fifo                  <= '0';
 
           checksum_load               <= packet_word1_3 & packet_word1_2 & packet_word1_1 & packet_word1_0;
           checksum_in_mux_sel         <= '1';

             
       when TX_WORD1_0 =>
           fibre_byte                  <=  packet_word1_0;
           write_fifo                  <= '1';
         
           
       when LD_WORD1_1 =>
           fibre_byte                  <=  packet_word1_1;
           write_fifo                  <= '0';
           
       
       when TX_WORD1_1 =>
           fibre_byte                  <=  packet_word1_1;
           write_fifo                  <= '1';
           
           -- this assignment MUST be in a state that only holds for one clock cycle           
           ena_checksum                <= '1';
          
       when LD_WORD1_2 =>
           fibre_byte                  <=  packet_word1_2;
           write_fifo                  <= '0'; 
           
       when TX_WORD1_2 =>
           fibre_byte                  <=  packet_word1_2;
           write_fifo                  <= '1';
           
       when LD_WORD1_3 =>
           fibre_byte                  <=  packet_word1_3;
           write_fifo                  <= '0';
           
       when TX_WORD1_3 =>
           fibre_byte                  <=  packet_word1_3;
           write_fifo                  <= '1';
           
       when LD_WORD2_0 =>
           fibre_byte                  <=  packet_word2_0;
           write_fifo                  <= '0';
           
           checksum_load               <= packet_word2_3 & packet_word2_2 & packet_word2_1 & packet_word2_0;
           checksum_in_mux_sel         <= '1';
           
       when TX_WORD2_0 =>
           fibre_byte                  <=  packet_word2_0;
           write_fifo                  <= '1';
           
       when LD_WORD2_1 =>
           fibre_byte                  <=  packet_word2_1;
           write_fifo                  <= '0';
           
       
       when TX_WORD2_1 =>
           fibre_byte                  <=  packet_word2_1;
           write_fifo                  <= '1';
       
           -- this assignment MUST be in a state that only holds for only one clock cycle
           ena_checksum                <= '1';
           
       when LD_WORD2_2 =>
           fibre_byte                  <=  packet_word2_2;
           write_fifo                  <= '0';
       
       when TX_WORD2_2 =>
           fibre_byte                  <=  packet_word2_2;
           write_fifo                  <= '1';
       
       when LD_WORD2_3 =>
           fibre_byte                  <=  packet_word2_3;
           write_fifo                  <= '0';
       
       when TX_WORD2_3 =>
           fibre_byte                  <=  packet_word2_3;
           write_fifo                  <= '1';
           
           
           
       when LD_RP_WORD3_0 =>
           fibre_byte                  <=  reply_word3_0;
           write_fifo                  <= '0';
           
           checksum_load               <= reply_word3_3 & reply_word3_2 & reply_word3_1 & reply_word3_0;
           checksum_in_mux_sel         <= '1';
           
       when TX_RP_WORD3_0 =>
           fibre_byte                  <=  reply_word3_0;
           write_fifo                  <= '1';
           
       when LD_RP_WORD3_1 =>
           fibre_byte                  <=  reply_word3_1;
           write_fifo                  <= '0';
           
       
       when TX_RP_WORD3_1 =>
           fibre_byte                  <=  reply_word3_1;
           write_fifo                  <= '1';
       
           -- this assignment MUST be in a state that only holds for only one clock cycle
           ena_checksum                <= '1';
           
       when LD_RP_WORD3_2 =>
           fibre_byte                  <=  reply_word3_2;
           write_fifo                  <= '0';
       
       when TX_RP_WORD3_2 =>
           fibre_byte                  <=  reply_word3_2;
           write_fifo                  <= '1';
       
       when LD_RP_WORD3_3 =>
           fibre_byte                  <=  reply_word3_3;
           write_fifo                  <= '0';
       
       when TX_RP_WORD3_3 =>
           fibre_byte                  <=  reply_word3_3;
           write_fifo                  <= '1';
               
           
           
       when LD_WORDN_0 =>
             fibre_byte                <=  wordN_0;
             write_fifo                <= '0';
           
            checksum_load              <= wordN_3 & wordN_2 & wordN_1 & wordN_0;
            checksum_in_mux_sel        <= '1';
 
       when TX_WORDN_0 =>
           fibre_byte                  <=  wordN_0;
           write_fifo                  <= '1';
           
           -- this assignemnt MUST be in a state that is only held for one clock cycle 
           ena_fibre_count             <= '1'; 
           
       when LD_WORDN_1 =>
           fibre_byte                  <=  wordN_1;
           write_fifo                  <= '0';
           
       
       when TX_WORDN_1 =>
           fibre_byte                  <=  wordN_1;
           write_fifo                  <= '1';
    
         -- this assignemnt MUST be in a state that is only held for one clock cycle   
           ena_checksum                <= '1';       
       
       when LD_WORDN_2 =>
           fibre_byte                  <=  wordN_2;
           write_fifo                  <= '0';
       
       when TX_WORDN_2 =>
           fibre_byte                  <=  wordN_2;
           write_fifo                  <= '1';
       
       when LD_WORDN_3 =>
           fibre_byte                  <=  wordN_3;
           write_fifo                  <= '0';
       
       when TX_WORDN_3 =>
           fibre_byte                  <=  wordN_3;
           write_fifo                  <= '1';    
     
       when LD_CKSUM0 =>
           fibre_byte                  <=  checksum( 7 downto 0);
           write_fifo                  <= '0';
       
       when TX_CKSUM0 =>
           fibre_byte                  <=  checksum( 7 downto 0);
           write_fifo                  <= '1';
           
           
       when LD_CKSUM1 =>
           fibre_byte                  <=  checksum(15 downto 8);
           write_fifo                  <= '0';
          
       
       when TX_CKSUM1 =>
           fibre_byte                  <=  checksum(15 downto 8);
           write_fifo                  <= '1';
          
                                 
       when LD_CKSUM2 =>
           fibre_byte                  <=  checksum(23 downto 16);
           write_fifo                  <= '0';
         
       
       when TX_CKSUM2 =>  
           fibre_byte                  <=  checksum(23 downto 16);
           write_fifo                  <= '1';
          
                      
       when LD_CKSUM3 =>
           fibre_byte                  <=  checksum(31 downto 24);
           write_fifo                  <= '0';
                
                   
       when TX_CKSUM3 =>  
           fibre_byte                  <=  checksum(31 downto 24);
           write_fifo                  <= '1';
           
           
           if m_op_done_reply = '1' or             -- if this was a reply/data packet 
              m_op_done_data  = '1' then           -- instigated by reply_queue then
           
              m_op_ack_o               <= '1' ;    -- acknowledge that packet has finished - i.e. started txing checksum
                                                   -- Q should now de-assert m_op_done
            else        
              m_op_ack_o               <= '0';
           end if;         
        
        when DONE => 
            m_op_ack_o                 <= '0';
                       
                       
       when WAIT_Q_WORD  =>
           fibre_word_req_o            <= '0';

       when ACK_Q_WORD =>
          fibre_word_req_o             <= '1';    
    
      end case;
      
      
   end process reply_fsm_output;
 
   
   ---------------------------------------------------------------------------
   -- LOCAL COMMAND FSM 
   ----------------------------------------------------------------------------
   -- local_fsm_clocked : process(
   --   clk_i,
   --   rst_i
   -- )
   ----------------------------------------------------------------------------
   -- begin         
   --   if (rst_i = '1') then
   --      local_current_state <= LOCAL_IDLE;
   --   elsif (clk_i'EVENT AND clk_i = '1') then
   --     local_current_state <= local_next_state;
   --   end if;
   -- end process local_fsm_clocked; 
             
   -------------------------------------------------------------------------
   -- local_fsm_nextstate : process (
   --    local_current_state 
   --  )
   ----------------------------------------------------------------------------
   --  begin
   --     case local_current_state is
   --     when LOCAL_IDLE =>
   --        local_next_state <= LOCAL_TEST;
   --     when LOCAL_TEST => 
   --        local_next_state <= LOCAL_IDLE;  
   --     when others =>
   --        local_next_state <= LOCAL_IDLE;   
   --     end case;     
   --  end process local_fsm_nextstate;            
  
   ---------------------------------------------------------------------------
   -- ARBITRATION FSM 
   ----------------------------------------------------------------------------
   arb_fsm_clocked : process(
      clk_i,
      rst_i
   )
   ----------------------------------------------------------------------------
   begin
         
      if (rst_i = '1') then
         arb_current_state <= ARB_IDLE;
      elsif (clk_i'EVENT AND clk_i = '1') then
         arb_current_state <= arb_next_state;
      end if;

   end process arb_fsm_clocked; 
             
  -------------------------------------------------------------------------
   arb_fsm_nextstate : process (
      arb_current_state, fibre_fsm_busy, cmd_rcvd_er_i, 
      cmd_code_i, arb_fsm_ack
   )
   ----------------------------------------------------------------------------
   begin
     
      case arb_current_state is

      when ARB_IDLE =>
         
         if (fibre_fsm_busy = '1' and cmd_rcvd_er_i = '1' and cmd_code_i = ASCII_S & ASCII_T ) then
            arb_next_state <= ARB_ST_ERR;
         end if; 
           
      when ARB_ST_ERR => 
         if arb_fsm_ack = '1' then 
            arb_next_state <= ARB_IDLE;
         end if;
      
      when others =>
         arb_next_state <= ARB_IDLE;   
         
      end case;
      
   end process arb_fsm_nextstate;            
   
    -------------------------------------------------------------------------
   arb_fsm_output : process (
      arb_current_state
   )
   ----------------------------------------------------------------------------
   begin
      
      stop_err_rdy <= '0' ;
     
      case arb_current_state is

      when ARB_IDLE =>
      
         stop_err_rdy <= '0' ;
                    
      when ARB_ST_ERR => 
      
         stop_err_rdy <= '1' ;
         
      end case;
      
   end process arb_fsm_output;            
   
   
  ------------------------------------------------------------------------------
  checksum_calculator: process(rst_i, clk_i)
  ----------------------------------------------------------------------------
  -- process to update calculated packet checksum
  ----------------------------------------------------------------------------
 
   begin
     
   if (rst_i = '1') then
      
      checksum <= (others => '0');
    
   elsif (clk_i'EVENT AND clk_i = '1') then
       
      if    rst_checksum = '1' then
         checksum <= (others => '0');
      elsif ena_checksum = '1' then
         checksum <= checksum XOR checksum_in;
      end if;
   
   end if;
    
  end process checksum_calculator;   
    
  ------------------------------------------------------------------------------
  fibre_word_counter: process(rst_i, clk_i)
  ----------------------------------------------------------------------------
  -- process to increment the fibre word count
  ----------------------------------------------------------------------------
 
   begin
      if(rst_i = '1') then
         fibre_word_count <= 0;
      elsif(clk_i'event and clk_i = '1') then
         if    (ena_fibre_count = '1') then
            fibre_word_count <= fibre_word_count + 1;
         elsif (rst_fibre_count = '1') then
            fibre_word_count <= 0;
         else
            fibre_word_count <= fibre_word_count;
         end if;
      end if;
   end process fibre_word_counter;
           
end rtl;