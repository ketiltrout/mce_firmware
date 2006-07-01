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
-- <revision control keyword substitutions e.g. $Id: reply_translator.vhd,v 1.32 2006/06/19 17:47:40 bburger Exp $>
--
-- Project:          Scuba 2
-- Author:           David Atkinson
-- Organisation:        UKATC
--
-- Description:
-- <description text>
--
-- Revision history:
-- <date $Date: 2006/06/19 17:47:40 $> - <text> - <initials $Author: bburger $>
--
-- $Log: reply_translator.vhd,v $
-- Revision 1.32  2006/06/19 17:47:40  bburger
-- Bryce:  completely re-wrote reply_translator to interface to the 32-bit fibre_tx block that ernie re-wrote
--
-- Revision 1.31  2006/05/29 23:11:00  bburger
-- Bryce: Removed unused signals to simplify code and remove warnings from Quartus II
--
-- 
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.issue_reply_pack.all;

library sys_param;
use sys_param.command_pack.all;

entity reply_translator is
   port(
     -- global inputs 
     rst_i                   : in  std_logic;                                               -- global reset
     clk_i                   : in  std_logic;                                               -- global clock

     -- signals to/from cmd_translator    
     cmd_rcvd_er_i           : in  std_logic;                                               -- command received on fibre with checksum error
     cmd_rcvd_ok_i           : in  std_logic;                                               -- command received on fibre - no checksum error
     cmd_code_i              : in  std_logic_vector (FIBRE_PACKET_TYPE_WIDTH-1  downto 0);  -- fibre command code
     card_addr_i             : in  std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);  -- fibre command card id
     param_id_i              : in  std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);  -- fibre command parameter id
         
     -- signals to/from reply queue 
     mop_rdy_i         : in  std_logic;                                                 -- macro op response ready to be processed
     mop_error_code_i  : in  std_logic_vector (PACKET_WORD_WIDTH-1      downto 0);      -- macro op success (others => '0') else error code
     fibre_word_i      : in  std_logic_vector (PACKET_WORD_WIDTH-1     downto 0);      -- packet word read from reply queue
     num_fibre_words_i : in  integer ;                                                 -- indicate number of packet words to be read from reply queue
     fibre_word_ack_o  : out std_logic;                                                -- asserted to requeset next fibre word
     fibre_word_rdy_i  : in std_logic;
     mop_ack_o         : out std_logic;                                                 -- asserted to indicate to reply queue the the packet has been processed

     cmd_stop_i        : in std_logic;
     last_frame_i      : in std_logic;
     frame_seq_num_i   : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);

--     tx_ff_i                 : in std_logic;                                             -- transmit fifo full
--     tx_fw_o                 : out std_logic;                                            -- transmit fifo write request
--     txd_o                   : out std_logic_vector (PACKET_WORD_WIDTH-1 downto 0)                         -- transmit fifo data input

     -- signals to / from fibre_tx
     fibre_tx_rdy_o    : out std_logic;                                             -- transmit fifo full
     fibre_tx_busy_i   : in std_logic;                                            -- transmit fifo write request
     fibre_tx_dat_o    : out std_logic_vector (PACKET_WORD_WIDTH-1 downto 0)                         -- transmit fifo data input
   );      
end reply_translator;


architecture rtl of reply_translator is

   constant NUM_REPLY_WORDS        : integer := 4;
   constant NUM_FRAME_HEAD_WORDS   : integer := 41;
   constant FIBRE_CHECKSUM_ERR : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0) := conv_std_logic_vector(1,PACKET_WORD_WIDTH);
      
   -- reply word registers
   signal packet_word1_0         : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);                       -- reply word 1 byte 0 
   signal packet_word2_0         : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);                       -- reply word 2 byte 0 
   signal reply_word3_0         : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);                       -- reply word 3 byte 0 
   signal wordN_0               : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);                       -- reply word N byte 0 
   
   -- packet header registers /  definitions 
   constant packet_header1_0     : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0) := FIBRE_PREAMBLE1(PACKET_WORD_WIDTH-1 downto 0);     -- packet header word 1 byte 0
   constant packet_header2_0     : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0) := FIBRE_PREAMBLE2(PACKET_WORD_WIDTH-1 downto 0);     -- packet header word 2 byte 0
   signal   packet_header3_0     : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0) ;                     -- packet header word 3 byte 0
   signal   packet_header4_0     : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0) ;                     -- packet header word 4 byte 0

   -- checksum signals
   signal checksum              : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);   -- checksum word (output from checksum calculator)
   signal checksum_in           : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);  -- input to checksum calculator  

   -- recirculation MUX structure used to hold checksum_in value  
   signal checksum_in_mux       : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);  -- MUX output
   signal checksum_load         : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);  -- new checksum_in value loaded here  
   signal checksum_in_mux_sel   : std_logic;                                    -- asserted to register the checksum_load value
   
   -- mux select lines defined here:
   signal packet_word1_0mux_sel   : std_logic_vector (1 downto 0) ;
   signal packet_word2_0mux_sel   : std_logic_vector (1 downto 0) ;    
   signal reply_word3_0mux_sel   : std_logic ;
   signal packet_header3_0mux_sel : std_logic ;
   signal packet_header4_0mux_sel : std_logic ;

   -- re-circulation mux outputs..
   signal packet_header3_0mux     : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal packet_header4_0mux     : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal packet_word1_0mux        : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal packet_word2_0mux        : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal reply_word3_0mux        : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal wordN_0mux              : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   
   -- Finite State Machines defined here:

   ----------------------------------------------------------------------------------------------------------------
   --                             FIBRE PACKET FSM
   ----------------------------------------------------------------------------------------------------------------
   -- handles the writting off all packets (replies and data) to the
   -- fibre transmit FIFO (fibre_tx_fifo) 
   
   type fibre_state is        
      (FIBRE_IDLE, CK_ER_REPLY, REPLY_GO_RS, REPLY_OK, REPLY_ER, 
       DATA_FRAME, WAIT_Q_WORD1, WAIT_Q_WORD2, WAIT_Q_WORD3, WAIT_Q_WORD4, ACK_Q_WORD, ST_ER_REPLY, NO_REPLY,    
       LD_PREAMBLE1, TX_PREAMBLE1, LD_PREAMBLE2, TX_PREAMBLE2, LD_xxRP, TX_xxRP, LD_PACKET_SIZE, TX_PACKET_SIZE, 
       LD_OKorER, TX_OKorER, LD_CARD_PARAM, TX_CARD_PARAM, LD_STATUS, TX_STATUS, LD_RAM0,  TX_RAM0,  
       LD_DATA, TX_DATA, LD_CKSUM,  TX_CKSUM, HEAD_WRITE, HEAD_NEXT, HEAD_DONE, DONE
   );
      
   signal   fibre_current_state       : fibre_state;
   signal   fibre_next_state          : fibre_state;
         
   
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
   signal fibre_fsm_busy        : std_logic;                                     -- asserted when txing a packet 

   signal reply_status          : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);                -- this word is writen to reply word 1 to indicate if 'OK' or 'ER' 
   signal packet_type           : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- indicates reply or data packet - written to header word 3
   signal mop_rdy_reply         : std_logic;                                     -- asserted high when a mop is done and processing a reply packet
   signal mop_rdy_data          : std_logic;                                     -- asserted high when a mop is done and processing a data packet
   signal rst_checksum          : std_logic;                                     -- signal asserted to reset packet checksum
   signal ena_checksum          : std_logic;                                     -- signal assertd to update packet checksum with checksum_in value
   signal fibre_byte            : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0); --byte;                                          -- output byte to  be written to tranmit FIFO
   signal rb_packet_size        : integer;
   signal data_packet_size      : integer;
   
   -- output of ARB FSM.  Used to tell FIBRE FSM that it has missed a ST command (with checksum error)                    
   signal stop_err_rdy          : std_logic;
   -- fibre fsm uses this to acknowledge that it will package up a reply to checksum error stop
   signal arb_fsm_ack           : std_logic    ;                                  
   signal reply_argument        :  std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);     -- signal mapped to reply word 3 (except success RB)
   signal frame_status          :  std_logic_vector(PACKET_WORD_WIDTH-1 downto 0); 
   signal cmd_code          : std_logic_vector (FIBRE_PACKET_TYPE_WIDTH-1     downto 0);
   signal card_addr         : std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);
   signal param_id          : std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);

begin

   frame_status(31 downto 2)    <=   (others => '0');
   frame_status(1)              <=   cmd_stop_i;
   frame_status(0)              <=   last_frame_i;   
   
   -- a reply packet should be generated if mop_rdy_reply is asserted.
   mop_rdy_reply <= mop_rdy_i when (cmd_code = WRITE_BLOCK or cmd_code = READ_BLOCK) else '0'; -- or cmd_code = STOP) and (internal_cmd_i  = '0')
   
   -- a data packet should be generated if mop_rdy_data is asserted
   mop_rdy_data <= mop_rdy_i when cmd_code = GO else '0';
   
   -- for a read block the packet size is alway 3 + the number of words to be read on fibre_word_i
   rb_packet_size <= num_fibre_words_i + 3 ;     -- size readblock + words1, 2 and 4(checksum)
   
   --data_packet_size        <= num_fibre_words_i + NUM_RAM_HEAD_WORDS + 3 ;     -- number of detector words + header words + (status + seq_number + checksum word)
   data_packet_size <= num_fibre_words_i + 3 ;     -- number of detector words + (status + seq_number + checksum word)
   
   -- packet header recirculation mux structures
   packet_header3_0mux <= packet_type when packet_header3_0mux_sel = '1' else packet_header3_0;
   packet_header4_0mux <= packet_size when packet_header4_0mux_sel = '1' else packet_header4_0;
   
   --  packet word 1 recirculation mux structures
   packet_word1_0mux   <= reply_status when packet_word1_0mux_sel = "01" else 
                       reply_status when packet_word1_0mux_sel = "10" else 
                       frame_status when packet_word1_0mux_sel = "11" else 
                       packet_word1_0;

   --  packet word 2 recirculation mux structures
   packet_word2_0mux   <= param_id & card_addr when packet_word2_0mux_sel = "01" else
                          param_id & card_addr when packet_word2_0mux_sel = "10" else
                          frame_seq_num_i when packet_word2_0mux_sel = "11" else
                          packet_word2_0;
   
   --  reply word 3 recirculation mux structures
   reply_word3_0mux   <= reply_argument(PACKET_WORD_WIDTH-1  downto  0)  when reply_word3_0mux_sel = '1' else reply_word3_0;
           
   --  data/read block words recirculation mux structures
   -- latch fibre_word when fibre_word_rdy asserted.....
   wordN_0mux         <= fibre_word_i (PACKET_WORD_WIDTH-1  downto  0) when fibre_word_rdy_i = '1' else wordN_0;
   
   -- checksum calculator input recirculation strucutre 
   checksum_in_mux    <= checksum_load  when checksum_in_mux_sel = '1' else checksum_in;
   
   -- data output.  
   fibre_tx_dat_o     <= fibre_byte;
   
   ------------------------------------------------------------------------------
   register_packet: process(clk_i, rst_i)
   ----------------------------------------------------------------------------
   -- process to register recircualtion MUX outputs 
   ----------------------------------------------------------------------------
   begin
      if (rst_i = '1') then 
        
        packet_header3_0 <= (others => '0');  
        packet_header4_0 <= (others => '0');  
        packet_word1_0   <= (others => '0');
        packet_word2_0   <= (others => '0');
        reply_word3_0   <= (others => '0');
        wordN_0   <= (others => '0');
        checksum_in <= (others => '0');
        
     elsif (clk_i'EVENT and clk_i = '1') then
     
        packet_header3_0 <= packet_header3_0mux;
        packet_header4_0 <= packet_header4_0mux;
        packet_word1_0    <= packet_word1_0mux;
        packet_word2_0    <= packet_word2_0mux;
        reply_word3_0    <= reply_word3_0mux;
        wordN_0          <= wordN_0mux;
        checksum_in      <= checksum_in_mux;
           
     end if;
  end process register_packet;              
              
  ------------------------------------------------------------------------------
  register_cmd_code: process(clk_i, rst_i)
  ----------------------------------------------------------------------------
  -- process to register cmd_code, card_addr, param_id from cmd_translator 
  ----------------------------------------------------------------------------
  begin
     if(rst_i = '1') then                  
        cmd_code <= (others => '0');  
        card_addr  <= (others => '0');
        param_id <= (others => '0');   
     elsif (clk_i'EVENT and clk_i = '1') then     
        if ((cmd_rcvd_er_i = '1') or (cmd_rcvd_ok_i = '1') ) then
           cmd_code <= cmd_code_i;
           card_addr  <= card_addr_i;
           param_id <= param_id_i;
        end if;      
     end if;     
  end process register_cmd_code;     
              
   ---------------------------------------------------------------------------
   -- FIBRE FSM - writes fibre packets to transmit FIFO  
   -- and writes header info to RAM (local command)
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
      fibre_current_state, cmd_rcvd_ok_i, cmd_rcvd_er_i, mop_rdy_reply,
      cmd_code_i, fibre_tx_busy_i, stop_err_rdy,
      fibre_word_rdy_i, mop_rdy_data, mop_error_code_i
   )
   ----------------------------------------------------------------------------
   begin
      -- Default Assignments
      fibre_next_state <= fibre_current_state;
      
      case fibre_current_state is
      when FIBRE_IDLE =>
         if (cmd_rcvd_er_i = '1') then
            fibre_next_state <= CK_ER_REPLY;
         elsif ((cmd_rcvd_ok_i = '1' and cmd_code_i = GO) or (cmd_rcvd_ok_i = '1' and cmd_code_i = RESET)) then                                            
            fibre_next_state <= REPLY_GO_RS;            
         elsif (stop_err_rdy = '1') then                 -- if we missed a stop command with checksum error during data readout
            fibre_next_state <= ST_ER_REPLY;     
         elsif (mop_rdy_reply = '1' and mop_error_code_i = FIBRE_NO_ERROR_STATUS) then 
            fibre_next_state <= REPLY_OK;
         -- Even with a CRC error, the cmd_translator will reply normally
         elsif (mop_rdy_reply = '1' and mop_error_code_i /= FIBRE_NO_ERROR_STATUS) then 
            fibre_next_state <= REPLY_ER; 
         elsif (mop_rdy_data = '1') then
            fibre_next_state <= DATA_FRAME;
         else
            fibre_next_state <= FIBRE_IDLE;   
         end if;           
         
      when  CK_ER_REPLY | REPLY_GO_RS | REPLY_OK | ST_ER_REPLY | DATA_FRAME | REPLY_ER =>          
          fibre_next_state <= LD_PREAMBLE1;          

      ----------------------------------------
      -- Header 1 
      -- 0xA5A5A5A5
      ----------------------------------------
      when LD_PREAMBLE1 =>
         if fibre_tx_busy_i = '1' then 
            fibre_next_state <= LD_PREAMBLE1;
         else
            fibre_next_state <= TX_PREAMBLE1;
         end if;   
            
      when TX_PREAMBLE1 =>
         fibre_next_state <= LD_PREAMBLE2;   
          
      ----------------------------------------
      -- Header 2
      -- 0x5A5A5A5A
      ----------------------------------------
      when LD_PREAMBLE2 =>
         if fibre_tx_busy_i = '1' then 
            fibre_next_state <= LD_PREAMBLE2;
         else
            fibre_next_state <= TX_PREAMBLE2;
         end if;  
          
      when TX_PREAMBLE2 =>
         fibre_next_state <= LD_xxRP;
          
      ----------------------------------------
      -- Header 3:
      -- "  RP" = 0x20205250 or
      -- "  DA" = 0x20204441
      ----------------------------------------
      when LD_xxRP =>
         if fibre_tx_busy_i = '1' then 
            fibre_next_state <= LD_xxRP;
         else
            fibre_next_state <= TX_xxRP;
         end if;             
          
      when TX_xxRP =>
        fibre_next_state <= LD_PACKET_SIZE;
      
      ----------------------------------------
      -- Packet Size
      ----------------------------------------
      when LD_PACKET_SIZE =>
         if fibre_tx_busy_i = '1' then 
            fibre_next_state <= LD_PACKET_SIZE;
         else
            fibre_next_state <= TX_PACKET_SIZE;
         end if;             
      
      when TX_PACKET_SIZE =>
         fibre_next_state <= LD_OKorER;
       
      ----------------------------------------
      -- "GOOK" = 0x474F4F4B or
      -- "STOK" = 0x53544F4B or
      -- "RSOK" = 0x52534F4B or
      -- "WBOK" = 0x57424F4B or
      -- "RBOK" = 0x52424F4B or
      -- "GOER" = 0x474F4552 or
      -- "STER" = 0x53544552 or
      -- "RSER" = 0x52534552 or
      -- "WBER" = 0x57424552 or
      -- "RBER" = 0x52424552 or
      -- Frame Status Block
      ----------------------------------------
      when LD_OKorER =>
         if fibre_tx_busy_i = '1' then 
            fibre_next_state <= LD_OKorER;
         else
            fibre_next_state <= TX_OKorER;
         end if;            
            
      when TX_OKorER =>
        fibre_next_state <= LD_CARD_PARAM;
          
      ----------------------------------------
      -- Card Address & Parameter ID
      ----------------------------------------
      when LD_CARD_PARAM =>
         if fibre_tx_busy_i = '1' then 
            fibre_next_state <= LD_CARD_PARAM;
         else
            fibre_next_state <= TX_CARD_PARAM;
         end if;    
          
      when TX_CARD_PARAM =>
         fibre_next_state <= LD_STATUS;
      
      ----------------------------------------
      -- Status word
      ----------------------------------------
      when LD_STATUS =>
         if fibre_tx_busy_i = '1' then 
            fibre_next_state <= LD_STATUS;
         else
            fibre_next_state <= TX_STATUS;
         end if;    
          
      when TX_STATUS =>
         fibre_next_state <= ACK_Q_WORD;
      
      ----------------------------------------

      when WAIT_Q_WORD1 =>
         -- and fibre_tx_busy_i = '0' Don't check for busy here, because its done in all other states.
         if (fibre_word_rdy_i  = '1') then 
            fibre_next_state <= LD_DATA;
         else
            fibre_next_state <= LD_CKSUM;
         end if;            
--         fibre_next_state <= WAIT_Q_WORD2;        

      when WAIT_Q_WORD2 =>
         fibre_next_state <= WAIT_Q_WORD3;        

      when WAIT_Q_WORD3 =>
         fibre_next_state <= WAIT_Q_WORD4;        

      when WAIT_Q_WORD4 =>
         if (fibre_word_rdy_i  = '1') then 
            fibre_next_state <= LD_DATA;
         else
            fibre_next_state <= LD_CKSUM;
         end if;            

      ----------------------------------------
      -- Data words
      ----------------------------------------
      when LD_DATA =>           
         if fibre_tx_busy_i = '1' then 
            fibre_next_state <= LD_DATA;
         else
            fibre_next_state <= TX_DATA;
         end if; 
         
      when TX_DATA =>
         fibre_next_state <= ACK_Q_WORD;

      when ACK_Q_WORD =>
         fibre_next_state <= WAIT_Q_WORD1;    
      
      ----------------------------------------
      -- Checksum word
      ----------------------------------------
      when LD_CKSUM =>
         if fibre_tx_busy_i = '1' then 
            fibre_next_state <= LD_CKSUM;
         else
            fibre_next_state <= TX_CKSUM;
         end if; 
         
      when TX_CKSUM =>
         fibre_next_state <= DONE;  
      
      when DONE =>  
         fibre_next_state <= FIBRE_IDLE;            
      
      when OTHERS =>
        fibre_next_state <= FIBRE_IDLE;   
        
      end case;
      
   end process fibre_fsm_nextstate;
    
         
   -------------------------------------------------------------------------
   reply_fsm_output : process (
      fibre_current_state, checksum, mop_error_code_i, data_packet_size, cmd_code,  rb_packet_size, mop_rdy_data,  
      packet_header3_0, packet_header4_0, packet_word1_0, packet_word2_0, reply_word3_0, wordN_0)
   ----------------------------------------------------------------------------
   begin
   
      packet_header3_0mux_sel  <= '0';
      packet_header4_0mux_sel  <= '0';
      packet_word1_0mux_sel    <= "00";
      packet_word2_0mux_sel    <= "00";
      reply_word3_0mux_sel     <= '0';

      fibre_fsm_busy           <= '1';  
--      write_fifo               <= '0';  
      fibre_tx_rdy_o           <= '0';
      fibre_word_ack_o         <= '0';
    
      rst_checksum             <= '0' ;
      ena_checksum             <= '0' ;
             
      checksum_in_mux_sel      <= '0';
      
      mop_ack_o                <= '0';
      arb_fsm_ack              <= '0';
      
      fibre_byte               <= (others => '0');
      
      checksum_load            <= (others => '0');

      reply_argument           <= (others => '0');
      reply_status             <= (others => '0');
      
      packet_size              <= (others => '0');     -- reset packet size
      reply_status             <= (others => '0');     -- reset reply status
      packet_type              <= (others => '0');     -- reset packet type
     
      case fibre_current_state is



      when FIBRE_IDLE =>               -- Idle state - no packets to process
      
            fibre_fsm_busy             <= '0';                 -- indicate no longer tranmitting packet
            rst_checksum               <= '1';                 -- reset checksum
            checksum_load              <= (others => '0');     -- reset checksum calculator input
            checksum_in_mux_sel        <= '1';                 -- register reset checksum calculator input
                
            
      when CK_ER_REPLY =>              -- checksum error state
  
            reply_status               <= cmd_code(15 downto 0) & ASCII_E & ASCII_R ;
            packet_size                <= conv_std_logic_vector(NUM_REPLY_WORDS,32);
            reply_argument             <= FIBRE_CHECKSUM_ERR;
            packet_type                <= REPLY;            
      
            packet_header3_0mux_sel    <= '1';
            packet_header4_0mux_sel    <= '1';
            packet_word1_0mux_sel      <= "01";    
            packet_word2_0mux_sel      <= "01";
            reply_word3_0mux_sel       <= '1';
      
      when ST_ER_REPLY =>              -- checksum error for ST command received during readout...now process
      
            reply_status               <= cmd_code(15 downto 0) & ASCII_E & ASCII_R ;
            packet_size                <= conv_std_logic_vector(NUM_REPLY_WORDS,32);
            reply_argument             <= FIBRE_CHECKSUM_ERR;
            packet_type                <= REPLY ;            
      
            packet_header3_0mux_sel    <= '1';
            packet_header4_0mux_sel    <= '1';
            packet_word1_0mux_sel      <= "01";
            packet_word2_0mux_sel      <= "01";
            reply_word3_0mux_sel       <= '1';
            
            arb_fsm_ack                <= '1';   
            
      when REPLY_GO_RS =>              -- command is reset or go....so generate an instant reply...
      
            reply_status               <= cmd_code(15 downto 0) & ASCII_O & ASCII_K ;
            packet_size                <= conv_std_logic_vector(NUM_REPLY_WORDS,32);
            reply_argument             <= (others => '0');   -- reply word 3 is 0
            packet_type                <= REPLY;
                        
            packet_header3_0mux_sel    <= '1';              -- register packet type (b0)
            packet_header4_0mux_sel    <= '1';              -- register packet size 
            packet_word1_0mux_sel      <= "01";
            packet_word2_0mux_sel      <= "01";
            reply_word3_0mux_sel       <= '1'; 
           
      when REPLY_OK    =>   

            if (cmd_code = READ_BLOCK) then 
               packet_size             <= conv_std_logic_vector(rb_packet_size,PACKET_WORD_WIDTH);    
            else
               packet_size             <= conv_std_logic_vector(NUM_REPLY_WORDS,32); 
            end if;            
            
            reply_status               <= cmd_code(15 downto 0) & ASCII_O & ASCII_K ;
            packet_type                <= REPLY; 
            reply_argument             <= mop_error_code_i;        -- this will be error code x"00" - i.e. success.
              
            packet_word1_0mux_sel      <= "10";
            packet_word2_0mux_sel      <= "10";
            reply_word3_0mux_sel       <= '1';
            packet_header3_0mux_sel    <= '1';
            packet_header4_0mux_sel    <= '1';               -- register reply word 3 byte 0
            
      when REPLY_ER    =>   

            packet_size <= conv_std_logic_vector(NUM_REPLY_WORDS,32);    
            reply_status               <= cmd_code(15 downto 0) & ASCII_E & ASCII_R ;
            packet_type                <= REPLY;
            reply_argument             <= mop_error_code_i;                 
              
            packet_word1_0mux_sel      <= "10";
            packet_word2_0mux_sel      <= "10";
            reply_word3_0mux_sel       <= '1';               -- register error code to reply word 3 byte 0
            packet_header3_0mux_sel    <= '1';               -- register packet header 3 byte 0
            packet_header4_0mux_sel    <= '1';               -- register packet header 4 byte 0
       
       when DATA_FRAME     =>   
    
            packet_size                <= conv_std_logic_vector(data_packet_size,PACKET_WORD_WIDTH);
            packet_type                <= DATA;
    
            packet_header3_0mux_sel    <= '1';               -- register packet header 3 byte 0
            packet_header4_0mux_sel    <= '1';               -- register packet header 4 byte 0
            packet_word1_0mux_sel      <= "11";
            packet_word2_0mux_sel      <= "11";

      ----------------------------------------
      -- Header 1 
      -- 0xA5A5A5A5
      ----------------------------------------
       when LD_PREAMBLE1 =>
           fibre_byte                  <=  packet_header1_0;
             
       when TX_PREAMBLE1 =>
           fibre_byte                  <=  packet_header1_0;
           fibre_tx_rdy_o                  <= '1';
           
      ----------------------------------------
      -- Header 2
      -- 0x5A5A5A5A
      ----------------------------------------
       when LD_PREAMBLE2 =>
           fibre_byte                  <=  packet_header2_0;
           
       when TX_PREAMBLE2 =>
           fibre_byte                  <=  packet_header2_0;
           fibre_tx_rdy_o                  <= '1';
           
      ----------------------------------------
      -- Header 3:
      -- "  RP" = 0x20205250 or
      -- "  DA" = 0x20204441
      ----------------------------------------
       when LD_xxRP =>
           fibre_byte                  <=  packet_header3_0;
           
       when TX_xxRP =>
           fibre_byte                  <=  packet_header3_0;
           fibre_tx_rdy_o                  <= '1';
           
      ----------------------------------------
      -- Packet Size
      ----------------------------------------
       when LD_PACKET_SIZE =>
           fibre_byte                  <=  packet_header4_0;
       
       when TX_PACKET_SIZE =>
           fibre_byte                  <=  packet_header4_0;
           fibre_tx_rdy_o                  <= '1';
       
      ----------------------------------------
      -- "GOOK" = 0x474F4F4B or
      -- "STOK" = 0x53544F4B or
      -- "RSOK" = 0x52534F4B or
      -- "WBOK" = 0x57424F4B or
      -- "RBOK" = 0x52424F4B or
      -- "GOER" = 0x474F4552 or
      -- "STER" = 0x53544552 or
      -- "RSER" = 0x52534552 or
      -- "WBER" = 0x57424552 or
      -- "RBER" = 0x52424552 or
      -- Frame Status Block
      ----------------------------------------
       when LD_OKorER =>
           fibre_byte                  <=  packet_word1_0;
 
           checksum_load               <= packet_word1_0;
           checksum_in_mux_sel         <= '1';
             
       when TX_OKorER =>
           fibre_byte                  <=  packet_word1_0;
           fibre_tx_rdy_o                  <= '1';         
           
           -- this assignment MUST be in a state that only holds for one clock cycle           
           -- This was in TX_WORD1_1
           ena_checksum                <= '1';

      ----------------------------------------
      -- Card Address & Parameter ID
      ----------------------------------------
       when LD_CARD_PARAM =>
           fibre_byte                  <=  packet_word2_0;
           
           checksum_load               <= packet_word2_0;
           checksum_in_mux_sel         <= '1';
           
       when TX_CARD_PARAM =>
           fibre_byte                  <=  packet_word2_0;
           fibre_tx_rdy_o                  <= '1';
           
           -- this assignment MUST be in a state that only holds for only one clock cycle
           -- This was in TX_WORD2_1
           ena_checksum                <= '1';
           
      ----------------------------------------
      -- Status word
      ----------------------------------------
       when LD_STATUS =>
           fibre_byte                  <=  reply_word3_0;
           
           checksum_load               <= reply_word3_0;
           checksum_in_mux_sel         <= '1';
           
       when TX_STATUS =>
           fibre_byte                  <=  reply_word3_0;
           
           -- Do not transmit a status word if an RB was successful or if returning DATA
           -- Don't ask me why this is, but it's a stupid feature of the fibre protocol
           if((cmd_code = READ_BLOCK and mop_error_code_i = FIBRE_NO_ERROR_STATUS) or (mop_rdy_data = '1')) then
              null;
           else
              fibre_tx_rdy_o               <= '1';
           end if;
           
           -- this assignment MUST be in a state that only holds for only one clock cycle
           -- This was in TX_RP_WORD3_1
           ena_checksum                <= '1';

      ----------------------------------------
      -- Data words
      ----------------------------------------
       when LD_DATA =>
             fibre_byte                <= wordN_0;
           
            checksum_load              <= wordN_0;
            checksum_in_mux_sel        <= '1';
 
       when TX_DATA =>
           fibre_byte                  <=  wordN_0;

           -- Do not transmit a data word if an RB was unsuccessful
           -- Don't ask me why this is, but it's a stupid feature of the fibre protocol
           if(cmd_code = READ_BLOCK and mop_error_code_i /= FIBRE_NO_ERROR_STATUS) then
              null;
           else
              fibre_tx_rdy_o               <= '1';
           end if;
           
           -- this assignemnt MUST be in a state that is only held for one clock cycle
           -- Originally in TX_WORDN_1
           ena_checksum                <= '1';       

      ----------------------------------------
      -- Checksum word
      ----------------------------------------
       when LD_CKSUM =>
           fibre_byte                  <=  checksum;
           mop_ack_o                   <= '1' ;    -- acknowledge that packet has finished - i.e. started txing checksum

       when TX_CKSUM =>
           fibre_byte                  <=  checksum;
           fibre_tx_rdy_o                  <= '1';
           
       when WAIT_Q_WORD1  =>           null;
       when WAIT_Q_WORD2  =>           null;
       when WAIT_Q_WORD3  =>           null;
       when WAIT_Q_WORD4  =>           null;       

       when ACK_Q_WORD =>
          fibre_word_ack_o             <= '1';    
       
       when DONE =>                    null;
       
       when others =>
           null;
           
      end case;      
      
   end process reply_fsm_output;
 
   
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
      cmd_code, arb_fsm_ack
   )
   ----------------------------------------------------------------------------
   begin
      
      arb_next_state <= arb_current_state;

      case arb_current_state is
      
      when ARB_IDLE =>
         
         if (fibre_fsm_busy = '1' and cmd_rcvd_er_i = '1' and cmd_code = ASCII_S & ASCII_T ) then
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
   arb_fsm_output : process(arb_current_state)
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
     if(rst_i = '1') then
        checksum <= (others => '0');
     elsif(clk_i'EVENT AND clk_i = '1') then
        if(rst_checksum = '1') then
           checksum <= (others => '0');
        elsif(ena_checksum = '1') then
           checksum <= checksum XOR checksum_in;
        end if;
     end if;
  end process checksum_calculator;   
    
end rtl;
