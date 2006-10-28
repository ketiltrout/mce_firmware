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
-- <revision control keyword substitutions e.g. $Id: reply_translator.vhd,v 1.45 2006/10/24 17:13:29 bburger Exp $>
--
-- Project:          SCUBA-2
-- Author:           David Atkinson/ Bryce Burger
-- Organisation:     UKATC         / UBC
--
-- Description:
-- <description text>
--
-- Revision history:
-- <date $Date: 2006/10/24 17:13:29 $> - <text> - <initials $Author: bburger $>
--
-- $Log: reply_translator.vhd,v $
-- Revision 1.45  2006/10/24 17:13:29  bburger
-- Bryce:  Added support for stop commands
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
   c_cmd_code_i      : in std_logic_vector (FIBRE_PACKET_TYPE_WIDTH-1  downto 0);
   c_card_addr_i     : in std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);
   c_param_id_i      : in std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);           

   -- signals to/from reply queue
   r_cmd_code_i      : in std_logic_vector (FIBRE_PACKET_TYPE_WIDTH-1  downto 0);
   r_card_addr_i     : in std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);
   r_param_id_i      : in std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);   
   r_cmd_rdy_i       : in std_logic;                                               -- macro op response ready to be processed
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
   signal checksum_clr      : std_logic;                                       -- signal asserted to reset packet checksum
   signal checksum_ld       : std_logic;                                       -- signal assertd to update packet checksum with checksum_in value
   signal fibre_tx_dat      : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0); -- transmit fifo data input

   signal rb_packet_size    : integer;
   signal data_packet_size  : integer;
   
   -- fibre fsm uses this to acknowledge that it will package up a reply to checksum error stop
   signal arb_fsm_ack       : std_logic;                                  
   signal reply_argument    : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);     -- signal mapped to reply word 3 (except success RB)
   signal frame_status      : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0); 
   signal fibre_word        : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);     -- packet word read from reply queue
   
   signal c_cmd_rdy         : std_logic;          
   signal c_cmd_err         : std_logic;          
   signal c_cmd_ack         : std_logic;        
   signal c_cmd_code        : std_logic_vector(FIBRE_PACKET_TYPE_WIDTH-1 downto 0);
   signal c_card_addr       : std_logic_vector(FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);
   signal c_param_id        : std_logic_vector(FIBRE_PARAMETER_ID_WIDTH-1 downto 0);
   
   signal r_cmd_rdy         : std_logic;          
   signal r_cmd_err         : std_logic;   
   signal r_cmd_ack         : std_logic;
   signal r_cmd_code        : std_logic_vector(FIBRE_PACKET_TYPE_WIDTH-1 downto 0);
   signal r_card_addr       : std_logic_vector(FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);
   signal r_param_id        : std_logic_vector(FIBRE_PARAMETER_ID_WIDTH-1 downto 0);

begin

   ----------------------------------------------------------------------------
   -- Logic Analyzer Signals 
   ----------------------------------------------------------------------------
   debug_o                   <= (others => '0');   
   
   ----------------------------------------------------------------------------
   -- Frame Status Word.  This will be removed when this is incorporated in the housekeeping header from reply_queue 
   ----------------------------------------------------------------------------
   frame_status(31 downto 2) <= (others => '0');
   frame_status(1)           <= cmd_stop_i;
   frame_status(0)           <= last_frame_i;   
   
   ----------------------------------------------------------------------------
   -- register inputs from cmd_translator 
   ----------------------------------------------------------------------------
   register_cmd_code: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then                  
         fibre_word           <= (others => '0');
         c_cmd_code           <= (others => '0');  
         c_card_addr          <= (others => '0');
         c_param_id           <= (others => '0');   
         c_cmd_rdy            <= '0';
         c_cmd_err            <= '0';
         
      elsif (clk_i'EVENT and clk_i = '1') then     
         fibre_word <= fibre_word_i;
         
         if(cmd_rcvd_er_i = '1') then
            c_cmd_err         <= '1';
            c_cmd_code        <= c_cmd_code_i;
            c_card_addr       <= c_card_addr_i;
            c_param_id        <= c_param_id_i;         
         elsif(cmd_rcvd_ok_i = '1') then
            c_cmd_rdy         <= '1';
            c_cmd_code        <= c_cmd_code_i;
            c_card_addr       <= c_card_addr_i;
            c_param_id        <= c_param_id_i;         
         elsif(c_cmd_ack = '1') then
            c_cmd_rdy         <= '0';
            c_cmd_err         <= '0';
         end if;

      end if;     
   end process register_cmd_code;     

   ----------------------------------------------------------------------------
   -- register inputs from the reply_queue 
   ----------------------------------------------------------------------------
   register_reply_queue: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then                  
         rb_packet_size       <=  0;
         data_packet_size     <=  0;
         r_cmd_rdy            <= '0';
         r_cmd_code           <= (others => '0');  
         r_card_addr          <= (others => '0');
         r_param_id           <= (others => '0');   
      
      elsif (clk_i'EVENT and clk_i = '1') then     
         r_cmd_rdy            <= r_cmd_rdy_i;

         if(r_cmd_rdy_i = '1') then            
            r_cmd_code        <= r_cmd_code_i; 
            r_card_addr       <= r_card_addr_i;
            r_param_id        <= r_param_id_i; 
            rb_packet_size    <= num_fibre_words_i + 3;   
            data_packet_size  <= num_fibre_words_i + 3 ;                 
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
      elsif(clk_i'EVENT and clk_i = '1') then
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
   -- Data Pipeline MUX
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
      if(rst_i = '1') then
         fibre_current_state <= FIBRE_IDLE;
      elsif(clk_i'EVENT AND clk_i = '1') then
         fibre_current_state <= fibre_next_state;
      end if;
   end process fibre_fsm_clocked;


   fibre_fsm_nextstate : process (fibre_current_state, c_cmd_rdy, c_cmd_err,
      r_cmd_code, c_cmd_code, fibre_tx_busy_i, fibre_word_rdy_i, r_cmd_rdy)
   begin
      -- Default Assignments
      fibre_next_state <= fibre_current_state;
      
      case fibre_current_state is
      when FIBRE_IDLE =>
         -- The problem here is that the stop command changes the command code 
         -- and now the reply_translator doesn't know what its getting from the reply_queue so it doesn't ack anymore
         -- The reply_translator needs to ignore new command codes during data taking.  The best way to do this is probably to register command code, 
         -- and use that for the duration of the data run (and all other commands too)
         -- We may need two registers here, for the cmd_translator to handle quick replies from the cmd_translator and normal replies from the reply_queue
         -- There is also the issue of getting a stop command in the middle of a packet that is being replied to..
         
         if(c_cmd_err = '1') then
           -- Error in received command packet
            fibre_next_state <= CK_ER_REPLY;
         elsif(c_cmd_rdy = '1' and (c_cmd_code = GO or c_cmd_code = RESET)) then                                            
            -- Quick response required for GO and RS commands
            fibre_next_state <= REPLY_GO_RS;
         elsif(c_cmd_rdy = '1') then
            -- Acknowledge all other commands (like STOP, WB, RB) and stay in this state
            fibre_next_state <= FIBRE_IDLE;
         elsif(r_cmd_rdy = '1' and (r_cmd_code = WRITE_BLOCK or r_cmd_code = READ_BLOCK)) then 
            -- No housekeeping header required
            fibre_next_state <= REPLY_OK;
         elsif(r_cmd_rdy = '1' and r_cmd_code = GO) then
            -- Housekeeping header required
            fibre_next_state <= DATA_FRAME;
         elsif(r_cmd_rdy = '1') then
            -- Clear other possible commands (like STOP, RS) and stay in this state
            -- Don't really need this, but just to be sure.
            fibre_next_state <= FIBRE_IDLE;
         end if;           
         
      when CK_ER_REPLY | REPLY_GO_RS | REPLY_OK | ST_ER_REPLY | DATA_FRAME | REPLY_ER =>          
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


   ----------------------------------------------------------------------------
   -- process to register the correct packet information 
   ----------------------------------------------------------------------------
   register_packet: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then        
         packet_size    <= (others => '0');
         packet_type    <= (others => '0');
         status         <= (others => '0');
         crd_add_par_id <= (others => '0');
         ok_or_er       <= (others => '0');

      elsif(clk_i'event and clk_i = '1') then     
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
   

   reply_fsm_output : process (fibre_current_state, mop_error_code_i, c_cmd_code, r_cmd_code, fibre_tx_busy_i, c_cmd_err, c_cmd_rdy) 
   begin
      fibre_tx_rdy_o   <= '0';
      fibre_word_ack_o <= '0';
      arb_fsm_ack      <= '0';      
      reply_argument   <= (others => '0');
      reply_status     <= (others => '0');      
      checksum_ld      <= '0';
      checksum_clr     <= '0';
      mop_ack_o        <= '0'; -- For commands from reply_queue
      c_cmd_ack        <= '0'; -- For commands from cmd_translator
      r_cmd_ack        <= '0'; -- For commands from cmd_translator
      
      case fibre_current_state is
      
      -- Idle state - no packets to process      
      when FIBRE_IDLE =>               
         checksum_clr   <= '1';
         -- We can acknowledge the fibre_rx block immediately, because we've latched all the info we need
         if(c_cmd_err = '1') then
           -- Error in received command packet
            c_cmd_ack          <= '1'; 
         elsif(c_cmd_rdy = '1' and (c_cmd_code = GO or c_cmd_code = RESET)) then                                            
            -- Quick response required for GO and RS commands
            c_cmd_ack          <= '1'; 
         elsif(c_cmd_rdy = '1') then
            -- Acknowledge all other commands (like STOP, WB, RB) and stay in this state
            c_cmd_ack          <= '1'; 
         elsif(r_cmd_rdy = '1' and (r_cmd_code = WRITE_BLOCK or r_cmd_code = READ_BLOCK)) then 
            -- No housekeeping header required
            r_cmd_ack          <= '1'; 
         elsif(r_cmd_rdy = '1' and r_cmd_code = GO) then
            -- Housekeeping header required
            r_cmd_ack          <= '1'; 
         elsif(r_cmd_rdy = '1') then
            -- Clear other possible commands (like STOP, RS) and stay in this state
            -- Don't really need this, but just to be sure.
            r_cmd_ack          <= '1'; 
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
            if((cmd_code = READ_BLOCK and mop_error_code_i = FIBRE_NO_ERROR_STATUS) or (r_cmd_code = GO)) then
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
