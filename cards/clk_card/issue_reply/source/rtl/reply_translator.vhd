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
-- <revision control keyword substitutions e.g. $Id: reply_translator.vhd,v 1.44 2006/10/19 22:09:40 bburger Exp $>
--
-- Project:          SCUBA-2
-- Author:           David Atkinson/ Bryce Burger
-- Organisation:     UKATC         / UBC
--
-- Description:
-- <description text>
--
-- Revision history:
-- <date $Date: 2006/10/19 22:09:40 $> - <text> - <initials $Author: bburger $>
--
-- $Log: reply_translator.vhd,v $
-- Revision 1.44  2006/10/19 22:09:40  bburger
-- Bryce:  Added support for crc_err_en and changed code so that "xxOK" is reported out during internal MCE communications errors.
--
-- Revision 1.43  2006/09/28 00:34:18  bburger
-- Bryce:  now asserts cmd_sent_o/ mop_ack_o only when there is no data left in the queues.  This prevents short responses interfering with long ones.
--
-- Revision 1.42  2006/09/15 00:48:36  bburger
-- Bryce:  Cleaned up the data word acknowledgement chain to speed things up.  Untested in hardware.  Data packets are un-simulated
--
-- Revision 1.41  2006/08/18 22:33:09  bburger
-- Bryce:  Removed data signals from FSM's and implemented data pipeline with combinatorial logic to give the data pipeline more slack and setup time.  As it was, the design was meeting timing in Quartus, but just marginally.  Now there is >1ns of slack for the data signals.
--
-- Revision 1.40  2006/08/16 18:10:57  bburger
-- Bryce:  card_addr and par_id are now combined in the correct order in replies
--
-- Revision 1.39  2006/08/03 03:23:14  bburger
-- Bryce:  Trying to fix a bug associated with the error code.  The error code is delayed by one command.
--
-- Revision 1.38  2006/08/02 16:24:41  bburger
-- Bryce:  trying to fixed occasional wb bugs in issue_reply
--
-- Revision 1.37  2006/07/11 18:24:26  bburger
-- Bryce:  Added a debug port
--
-- Revision 1.36  2006/07/11 00:48:03  bburger
-- Bryce:  Removed recirc-muxes, cleaned up all the registers.  This block is now a lean machine.
--
-- Revision 1.35  2006/07/07 23:45:52  bburger
-- Bryce:  removing the recirculation muxes
--
-- Revision 1.34  2006/07/07 00:44:20  bburger
-- Bryce:  Added some signals to the interface to enable tapping them with SignalTap
--
-- Revision 1.33  2006/07/01 00:07:03  bburger
-- Bryce:  Renamed states in the fsm to make it clearer what the fsm is doing
--
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
   -- for testing
   debug_o           : out std_logic_vector (31 downto 0);

   -- global inputs 
   rst_i             : in std_logic;                                               -- global reset
   clk_i             : in std_logic;                                               -- global clock
   crc_err_en_i      : in std_logic;

   -- signals to/from cmd_translator    
   cmd_rcvd_er_i     : in std_logic;                                               -- command received on fibre with checksum error
   cmd_rcvd_ok_i     : in std_logic;                                               -- command received on fibre - no checksum error
   cmd_code_i        : in std_logic_vector (FIBRE_PACKET_TYPE_WIDTH-1  downto 0);  -- fibre command code
   card_addr_i       : in std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);  -- fibre command card id
   param_id_i        : in std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);  -- fibre command parameter id
       
   -- signals to/from reply queue 
   mop_rdy_i         : in std_logic;                                               -- macro op response ready to be processed
   mop_error_code_i  : in std_logic_vector (PACKET_WORD_WIDTH-1      downto 0);    -- macro op success (others => '0') else error code
   fibre_word_i      : in std_logic_vector (PACKET_WORD_WIDTH-1     downto 0);     -- packet word read from reply queue
   num_fibre_words_i : in integer;                                                -- indicate number of packet words to be read from reply queue
   fibre_word_ack_o  : out std_logic;                                               -- asserted to requeset next fibre word
   fibre_word_rdy_i  : in std_logic;
   mop_ack_o         : out std_logic;                                               -- asserted to indicate to reply queue the the packet has been processed
   cmd_stop_i        : in std_logic;
   last_frame_i      : in std_logic;
   frame_seq_num_i   : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);

   -- signals to / from fibre_tx
   fibre_tx_rdy_o    : out std_logic;                                               -- transmit fifo full
   fibre_tx_busy_i   : in std_logic;                                                -- transmit fifo write request
   fibre_tx_dat_o    : out std_logic_vector (PACKET_WORD_WIDTH-1 downto 0)          -- transmit fifo data input
);      
end reply_translator;


architecture rtl of reply_translator is

   constant NUM_REPLY_WORDS      : integer := 4;
   constant NUM_FRAME_HEAD_WORDS : integer := 41;
   constant FIBRE_CHECKSUM_ERR   : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0) := conv_std_logic_vector(1,PACKET_WORD_WIDTH);
      
   -- reply word registers
   signal status                 : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);  -- reply word 1 byte 0 
   signal crd_add_par_id         : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);  -- reply word 2 byte 0 
   signal ok_or_er               : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);  -- reply word 3 byte 0 
   signal checksum               : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);  -- checksum word (output from checksum calculator)
   
   ----------------------------------------------------------------------------------------------------------------
   --                             FIBRE PACKET FSM
   ----------------------------------------------------------------------------------------------------------------
   -- handles the writting off all packets (replies and data) to the
   -- fibre transmit FIFO (fibre_tx_fifo) 
   
   type fibre_state is        
      (FIBRE_IDLE, CK_ER_REPLY, REPLY_GO_RS, REPLY_OK, ST_ER_REPLY, REPLY_ER, DATA_FRAME, LD_PREAMBLE1,  LD_PREAMBLE2,
       LD_xxRP, LD_PACKET_SIZE, LD_OKorER, LD_CARD_PARAM, LD_STATUS, WAIT_Q_WORD1, WAIT_Q_WORD2, WAIT_Q_WORD3, WAIT_Q_WORD4, LD_DATA, ACK_Q_WORD, LD_CKSUM, DONE);
       
   signal fibre_current_state : fibre_state;
   signal fibre_next_state    : fibre_state;
   
   signal packet_size       : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);  -- this value is written to the packet header word 4
   signal reply_status      : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0); -- this word is writen to reply word 1 to indicate if 'OK' or 'ER' 
   signal packet_type       : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0); -- indicates reply or data packet - written to header word 3
   signal mop_rdy           : std_logic;
   signal mop_rdy_reply     : std_logic;                                       -- asserted high when a mop is done and processing a reply packet
   signal mop_rdy_data      : std_logic;                                       -- asserted high when a mop is done and processing a data packet
   signal checksum_clr      : std_logic;                                       -- signal asserted to reset packet checksum
   signal checksum_ld       : std_logic;                                       -- signal assertd to update packet checksum with checksum_in value
   signal fibre_tx_dat      : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0); -- transmit fifo data input

   signal rb_packet_size    : integer;
   signal data_packet_size  : integer;
   
   -- fibre fsm uses this to acknowledge that it will package up a reply to checksum error stop
   signal arb_fsm_ack       : std_logic;                                  
   signal reply_argument    : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);     -- signal mapped to reply word 3 (except success RB)
   signal frame_status      : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0); 
   signal cmd_code          : std_logic_vector(FIBRE_PACKET_TYPE_WIDTH-1     downto 0);
   signal card_addr         : std_logic_vector(FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);
   signal param_id          : std_logic_vector(FIBRE_PARAMETER_ID_WIDTH-1 downto 0);
   signal fibre_word        : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);     -- packet word read from reply queue
   
   signal cmd_rdy           : std_logic;          
   signal cmd_err           : std_logic;          
   signal cmd_ack           : std_logic;        

begin

   ----------------------------------------
   -- Logic Analyzer Signals 
   ----------------------------------------
   debug_o                   <= (others => '0');   
   frame_status(31 downto 2) <= (others => '0');
   frame_status(1)           <= cmd_stop_i;
   frame_status(0)           <= last_frame_i;   
   
   ----------------------------------------------------------------------------
   -- process to register the correct packet information 
   ----------------------------------------------------------------------------
   register_packet: process(clk_i, rst_i)
   begin
      if (rst_i = '1') then        
         packet_size    <= (others => '0');
         packet_type    <= (others => '0');
         status         <= (others => '0');
         crd_add_par_id <= (others => '0');
         ok_or_er       <= (others => '0');

      elsif (clk_i'event and clk_i = '1') then     
         if(fibre_current_state = CK_ER_REPLY or 
            fibre_current_state = ST_ER_REPLY or 
            fibre_current_state = REPLY_GO_RS or
            fibre_current_state = REPLY_ER) then
            packet_size    <= conv_std_logic_vector(NUM_REPLY_WORDS,32);
            packet_type    <= REPLY;
            status         <= reply_status;
            crd_add_par_id <= card_addr & param_id;
            ok_or_er       <= reply_argument;
         
         elsif(fibre_current_state = REPLY_OK) then
            if (cmd_code = READ_BLOCK) then 
               packet_size <= conv_std_logic_vector(rb_packet_size,PACKET_WORD_WIDTH);    
            else
               packet_size <= conv_std_logic_vector(NUM_REPLY_WORDS,32); 
            end if;                 
            packet_type    <= REPLY;
            status         <= reply_status;
            crd_add_par_id <= card_addr & param_id;
            ok_or_er       <= reply_argument;
         
         elsif(fibre_current_state = DATA_FRAME) then
            packet_size    <= conv_std_logic_vector(data_packet_size,PACKET_WORD_WIDTH);
            packet_type    <= DATA;
            status         <= frame_status;
            crd_add_par_id <= frame_seq_num_i;
            ok_or_er       <= ok_or_er;
         else
            packet_size    <= packet_size;    
            packet_type    <= packet_type;   
            status         <= status; 
            crd_add_par_id <= crd_add_par_id; 
            ok_or_er       <= ok_or_er;  
         end if;
      end if;
   end process register_packet;              
              
   ----------------------------------------------------------------------------
   -- process to register cmd_code, card_addr, param_id from cmd_translator 
   ----------------------------------------------------------------------------
   register_cmd_code: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then                  
         cmd_code     <= (others => '0');  
         card_addr    <= (others => '0');
         param_id     <= (others => '0');   
         fibre_word   <= (others => '0');
         cmd_rdy      <= '0';
         cmd_err      <= '0';
         
      elsif (clk_i'EVENT and clk_i = '1') then     
         fibre_word <= fibre_word_i;
         
         if((cmd_rcvd_er_i = '1') or (cmd_rcvd_ok_i = '1')) then
            cmd_code  <= cmd_code_i;
            card_addr <= card_addr_i;
            param_id  <= param_id_i;
         end if;      

         if(cmd_rcvd_ok_i = '1') then
            cmd_rdy      <= '1';
         elsif(cmd_rcvd_er_i = '1') then
            cmd_err      <= '1';
         elsif(cmd_ack = '1') then
            cmd_rdy      <= '0';
            cmd_err      <= '0';
         end if;

      end if;     
   end process register_cmd_code;     

   ----------------------------------------------------------------------------
   -- process to register inputs from the reply_queue 
   ----------------------------------------------------------------------------
   register_reply_queue: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then                  
         mop_rdy_reply    <= '0';
         mop_rdy_data     <= '0';
         rb_packet_size   <=  0;
         data_packet_size <=  0;
         mop_rdy          <= '0';
      
      elsif (clk_i'EVENT and clk_i = '1') then     
         
         mop_rdy <= mop_rdy_i;
         if(mop_rdy_i = '1') then
            
            rb_packet_size   <= num_fibre_words_i + 3;   
            data_packet_size <= num_fibre_words_i + 3 ;     
            
            if(cmd_code = WRITE_BLOCK or cmd_code = READ_BLOCK) then
               mop_rdy_reply <= '1';
            else
               mop_rdy_reply <= '0';
            end if;
            
            if(cmd_code = GO) then
               mop_rdy_data  <= '1';
            else
               mop_rdy_data  <= '0';
            end if;
            
         end if;
      end if;     
   end process register_reply_queue;     

   ----------------------------------------------------------------------------
   -- process to update calculated packet checksum
   ----------------------------------------------------------------------------
   checksum_calculator: process(rst_i, clk_i)
   begin
      if(rst_i = '1') then
         checksum <= (others => '0');
      elsif(clk_i'EVENT AND clk_i = '1') then
         if(checksum_clr = '1') then
            checksum <= (others => '0');
         elsif(checksum_ld = '1') then
            if(packet_type = DATA and crc_err_en_i = '1') then
               checksum <= x"ABCDABCD";
            else
               checksum <= checksum xor fibre_tx_dat;
            end if;
         end if;
      end if;
   end process checksum_calculator; 
   
   ----------------------------------------------------------------------------
   -- Data Pipeline
   ----------------------------------------------------------------------------
   fibre_tx_dat_o <= fibre_tx_dat;   
   with fibre_current_state select
      fibre_tx_dat <=
         FIBRE_PREAMBLE1 when LD_PREAMBLE1,
         FIBRE_PREAMBLE2 when LD_PREAMBLE2,
         packet_type     when LD_xxRP,
         packet_size     when LD_PACKET_SIZE,
         status          when LD_OKorER,
         crd_add_par_id  when LD_CARD_PARAM,
         ok_or_er        when LD_STATUS,
         fibre_word      when LD_DATA,
         checksum        when LD_CKSUM,
         (others => '0') when others;

   ---------------------------------------------------------------------------
   -- FIBRE FSM - writes fibre packets to transmit FIFO  
   -- and writes header info to RAM (local command)
   ----------------------------------------------------------------------------
   fibre_fsm_clocked : process(clk_i, rst_i)
   begin         
      if (rst_i = '1') then
         fibre_current_state <= FIBRE_IDLE;
      elsif (clk_i'EVENT AND clk_i = '1') then
         fibre_current_state <= fibre_next_state;
      end if;
   end process fibre_fsm_clocked;


   fibre_fsm_nextstate : process (fibre_current_state, cmd_rdy, cmd_err, mop_rdy_reply,
      cmd_code, fibre_tx_busy_i, fibre_word_rdy_i, mop_rdy_data, mop_rdy)
   begin
      -- Default Assignments
      fibre_next_state <= fibre_current_state;
      
      case fibre_current_state is
      when FIBRE_IDLE =>
         -- Error in received command packet
         if (cmd_err = '1') then
            fibre_next_state <= CK_ER_REPLY;
         -- Quick response required for GO and RS commands
         elsif (cmd_rdy = '1' and (cmd_code = GO or cmd_code = RESET)) then                                            
            fibre_next_state <= REPLY_GO_RS;            
         elsif (mop_rdy = '1' and mop_rdy_reply = '1') then 
            fibre_next_state <= REPLY_OK;
         -- Data packet
         elsif (mop_rdy = '1' and mop_rdy_data = '1') then
            fibre_next_state <= DATA_FRAME;
         end if;           
         
      when  CK_ER_REPLY | REPLY_GO_RS | REPLY_OK | ST_ER_REPLY | DATA_FRAME | REPLY_ER =>          
          fibre_next_state <= LD_PREAMBLE1;          

      ----------------------------------------
      -- Preamble 1 
      -- 0xA5A5A5A5
      ----------------------------------------
      when LD_PREAMBLE1 =>
         if(fibre_tx_busy_i = '0') then 
            fibre_next_state <= LD_PREAMBLE2;
         end if;   
          
      ----------------------------------------
      -- Preamble 2
      -- 0x5A5A5A5A
      ----------------------------------------
      when LD_PREAMBLE2 =>
         if(fibre_tx_busy_i = '0') then 
            fibre_next_state <= LD_xxRP;
         end if;  
          
      ----------------------------------------
      -- Packet Type
      -- "  RP" = 0x20205250 or
      -- "  DA" = 0x20204441
      ----------------------------------------
      when LD_xxRP =>
         if(fibre_tx_busy_i = '0') then 
            fibre_next_state <= LD_PACKET_SIZE;
         end if;             
      
      ----------------------------------------
      -- Packet Size
      ----------------------------------------
      when LD_PACKET_SIZE =>
         if(fibre_tx_busy_i = '0') then 
            fibre_next_state <= LD_OKorER;
         end if;             
       
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
         if(fibre_tx_busy_i = '0') then 
            fibre_next_state <= LD_CARD_PARAM;
         end if;             
          
      ----------------------------------------
      -- Card Address & Parameter ID
      ----------------------------------------
      when LD_CARD_PARAM =>
         if(fibre_tx_busy_i = '0') then 
            fibre_next_state <= LD_STATUS;
         end if;             

      ----------------------------------------
      -- Status word
      ----------------------------------------
      when LD_STATUS =>
         if(fibre_tx_busy_i = '0') then 
            fibre_next_state <= WAIT_Q_WORD1;
         end if;             

      ----------------------------------------
      -- 
      ----------------------------------------
      when WAIT_Q_WORD1 =>
         fibre_next_state <= WAIT_Q_WORD4;

      when WAIT_Q_WORD4 =>
         -- and fibre_tx_busy_i = '0' Don't check for busy here, because its done in all other states.
         if (fibre_word_rdy_i  = '1') then 
            fibre_next_state <= LD_DATA;
         else
            fibre_next_state <= LD_CKSUM;
         end if;            

      ----------------------------------------
      -- Data words
      ----------------------------------------
      when LD_DATA =>           
         if(fibre_tx_busy_i = '0') then 
            fibre_next_state <= WAIT_Q_WORD1;
         end if;             

      ----------------------------------------
      -- Checksum word
      ----------------------------------------
      when LD_CKSUM =>
         if(fibre_tx_busy_i = '0') then 
            fibre_next_state <= DONE;
         end if;             

      when DONE =>  
         fibre_next_state <= FIBRE_IDLE;            
      
      when OTHERS =>
        fibre_next_state <= FIBRE_IDLE;   
        
      end case;
      
   end process fibre_fsm_nextstate;
    

   reply_fsm_output : process (fibre_current_state, mop_error_code_i, cmd_code, mop_rdy_data, fibre_tx_busy_i, cmd_err, cmd_rdy) 
   begin
      fibre_tx_rdy_o   <= '0';
      fibre_word_ack_o <= '0';
      arb_fsm_ack      <= '0';      
      reply_argument   <= (others => '0');
      reply_status     <= (others => '0');      
      checksum_ld      <= '0';
      checksum_clr     <= '0';
      mop_ack_o        <= '0'; -- For commands from reply_queue
      cmd_ack          <= '0'; -- For commands from cmd_translator
      
      case fibre_current_state is
      -- Idle state - no packets to process      
      when FIBRE_IDLE =>               
         checksum_clr   <= '1';
         
         -- We can acknowledge the fibre_rx block immediately, because we've latched all the info we need
         if (cmd_err = '1') then
            -- A checksum error was received by fibre_rx
            cmd_ack          <= '1'; 
         elsif (cmd_rdy = '1' and (cmd_code = GO or cmd_code = RESET)) then                                            
            -- A GO or RESET command was received by fibre_rx and requires immediate response
            cmd_ack          <= '1'; 
         end if;   

      -- checksum error state  
      when CK_ER_REPLY =>              
         reply_status   <= cmd_code(15 downto 0) & ASCII_E & ASCII_R;
         reply_argument <= FIBRE_CHECKSUM_ERR;
      
      -- checksum error for ST command received during readout...now process
      when ST_ER_REPLY =>              
         reply_status   <= cmd_code(15 downto 0) & ASCII_E & ASCII_R;
         reply_argument <= FIBRE_CHECKSUM_ERR;
         arb_fsm_ack    <= '1';   
            
      -- command is reset or go....so generate an instant reply...      
      when REPLY_GO_RS =>              
         reply_status   <= cmd_code(15 downto 0) & ASCII_O & ASCII_K;
         reply_argument <= (others => '0');
           
      when REPLY_OK =>   
         reply_status   <= cmd_code(15 downto 0) & ASCII_O & ASCII_K;
         -- this will be error code x"00" - i.e. success.              
         reply_argument <= mop_error_code_i;        
            
      when REPLY_ER =>   
         reply_status   <= cmd_code(15 downto 0) & ASCII_E & ASCII_R;
         reply_argument <= mop_error_code_i;                 
       
      when DATA_FRAME =>       
      ----------------------------------------
      -- Preamble 1 
      -- 0xA5A5A5A5
      ----------------------------------------
      when LD_PREAMBLE1 =>
         if(fibre_tx_busy_i = '0') then 
            fibre_tx_rdy_o <= '1';
         end if;   
           
      ----------------------------------------
      -- Preamble 2
      -- 0x5A5A5A5A
      ----------------------------------------
      when LD_PREAMBLE2 =>
         if(fibre_tx_busy_i = '0') then 
            fibre_tx_rdy_o <= '1';
         end if;   
           
      ----------------------------------------
      -- Packet Type
      -- "  RP" = 0x20205250 or
      -- "  DA" = 0x20204441
      ----------------------------------------
      when LD_xxRP =>
         if(fibre_tx_busy_i = '0') then 
            fibre_tx_rdy_o <= '1';
         end if;   
           
      ----------------------------------------
      -- Packet Size
      ----------------------------------------
      when LD_PACKET_SIZE =>
         if(fibre_tx_busy_i = '0') then 
            fibre_tx_rdy_o <= '1';
         end if;   
       
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
         if(fibre_tx_busy_i = '0') then
            checksum_ld    <= '1';
            fibre_tx_rdy_o <= '1';
         end if;   

      ----------------------------------------
      -- Card Address & Parameter ID
      ----------------------------------------
      when LD_CARD_PARAM =>
         if(fibre_tx_busy_i = '0') then 
            checksum_ld    <= '1';
            fibre_tx_rdy_o <= '1';
         end if;   
           
      ----------------------------------------
      -- Status word
      ----------------------------------------
      when LD_STATUS =>
         if(fibre_tx_busy_i = '0') then 
            fibre_word_ack_o <= '1';    
            checksum_ld      <= '1';
            -- Do not transmit a status word if an RB was successful or if returning DATA
            -- Don't ask me why this is, but it's a stupid feature of the fibre protocol
            if((cmd_code = READ_BLOCK and mop_error_code_i = FIBRE_NO_ERROR_STATUS) or (mop_rdy_data = '1')) then
               fibre_tx_rdy_o <= '0';
            else
               fibre_tx_rdy_o <= '1';
            end if;
         end if;   

      ----------------------------------------
      -- Data words
      ----------------------------------------
      when LD_DATA =>
         if(fibre_tx_busy_i = '0') then 
            fibre_word_ack_o <= '1';    
            checksum_ld      <= '1';
            -- Do not transmit a data word if an RB was unsuccessful
            -- Don't ask me why this is, but it's a stupid feature of the fibre protocol
            if(cmd_code = READ_BLOCK and mop_error_code_i /= FIBRE_NO_ERROR_STATUS) then
               fibre_tx_rdy_o <= '0';
            else
               fibre_tx_rdy_o <= '1';
            end if;
         end if;   

      ----------------------------------------
      -- Checksum word
      ----------------------------------------
      when LD_CKSUM =>
         if(fibre_tx_busy_i = '0') then 
            fibre_tx_rdy_o <= '1';
         end if;   
          
      when WAIT_Q_WORD1  => 

      when WAIT_Q_WORD4  => 

      when DONE => 
         mop_ack_o <= '1';
      
      when others =>
          
      end case;      
      
   end process reply_fsm_output;
         
end rtl;
