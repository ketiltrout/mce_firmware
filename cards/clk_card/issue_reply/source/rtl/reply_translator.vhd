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
-- <revision control keyword substitutions e.g. $Id: reply_translator.vhd,v 1.36 2006/07/11 00:48:03 bburger Exp $>
--
-- Project:          SCUBA-2
-- Author:           David Atkinson/ Bryce Burger
-- Organisation:     UKATC         / UBC
--
-- Description:
-- <description text>
--
-- Revision history:
-- <date $Date: 2006/07/11 00:48:03 $> - <text> - <initials $Author: bburger $>
--
-- $Log: reply_translator.vhd,v $
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
   debug_o             : out std_logic_vector (31 downto 0);

   -- global inputs 
   rst_i             : in  std_logic;                                               -- global reset
   clk_i             : in  std_logic;                                               -- global clock

   -- signals to/from cmd_translator    
   cmd_rcvd_er_i     : in  std_logic;                                               -- command received on fibre with checksum error
   cmd_rcvd_ok_i     : in  std_logic;                                               -- command received on fibre - no checksum error
   cmd_code_i        : in  std_logic_vector (FIBRE_PACKET_TYPE_WIDTH-1  downto 0);  -- fibre command code
   card_addr_i       : in  std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);  -- fibre command card id
   param_id_i        : in  std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);  -- fibre command parameter id
       
   -- signals to/from reply queue 
   mop_rdy_i         : in  std_logic;                                               -- macro op response ready to be processed
   mop_error_code_i  : in  std_logic_vector (PACKET_WORD_WIDTH-1      downto 0);    -- macro op success (others => '0') else error code
   fibre_word_i      : in  std_logic_vector (PACKET_WORD_WIDTH-1     downto 0);     -- packet word read from reply queue
   num_fibre_words_i : in  integer ;                                                -- indicate number of packet words to be read from reply queue
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
       LD_xxRP, LD_PACKET_SIZE, LD_OKorER, LD_CARD_PARAM, LD_STATUS, WAIT_Q_WORD1, LD_DATA, ACK_Q_WORD, LD_CKSUM, DONE);
       
   signal fibre_current_state : fibre_state;
   signal fibre_next_state    : fibre_state;
   
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
   type arb_state is (ARB_IDLE, ARB_ST_ERR);  
   signal arb_current_state : arb_state;
   signal arb_next_state    : arb_state;

   -- some local signals
   signal packet_size       : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);  -- this value is written to the packet header word 4
   signal fibre_fsm_busy    : std_logic;                                       -- asserted when txing a packet 

   signal reply_status      : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0); -- this word is writen to reply word 1 to indicate if 'OK' or 'ER' 
   signal packet_type       : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0); -- indicates reply or data packet - written to header word 3
   signal mop_rdy_reply     : std_logic;                                       -- asserted high when a mop is done and processing a reply packet
   signal mop_rdy_data      : std_logic;                                       -- asserted high when a mop is done and processing a data packet
   signal checksum_clr      : std_logic;                                       -- signal asserted to reset packet checksum
   signal checksum_ld       : std_logic;                                       -- signal assertd to update packet checksum with checksum_in value
   signal rb_packet_size    : integer;
   signal data_packet_size  : integer;
   
   -- output of ARB FSM.  Used to tell FIBRE FSM that it has missed a ST command (with checksum error)                    
   signal stop_err_rdy      : std_logic;
   -- fibre fsm uses this to acknowledge that it will package up a reply to checksum error stop
   signal arb_fsm_ack       : std_logic;                                  
   signal reply_argument    : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);     -- signal mapped to reply word 3 (except success RB)
   signal frame_status      : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0); 
   signal cmd_code          : std_logic_vector (FIBRE_PACKET_TYPE_WIDTH-1     downto 0);
   signal card_addr         : std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);
   signal param_id          : std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);

begin

   frame_status(31 downto 2) <= (others => '0');
   frame_status(1)           <= cmd_stop_i;
   frame_status(0)           <= last_frame_i;   
   
   -- a reply packet should be generated if mop_rdy_reply is asserted.
   mop_rdy_reply    <= mop_rdy_i when (cmd_code = WRITE_BLOCK or cmd_code = READ_BLOCK) else '0';   
   -- a data packet should be generated if mop_rdy_data is asserted
   mop_rdy_data     <= mop_rdy_i when cmd_code = GO else '0';   
   -- for a read block the packet size is alway 3 + the number of words to be read on fibre_word_i
   -- number of detector words + (status + seq_number + checksum word)
   rb_packet_size   <= num_fibre_words_i + 3;   
   data_packet_size <= num_fibre_words_i + 3 ;     
   
   ----------------------------------------------------------------------------
   -- process to register recircualtion MUX outputs 
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
            crd_add_par_id <= param_id & card_addr;
            ok_or_er       <= reply_argument;
         
         elsif(fibre_current_state = REPLY_OK) then
            if (cmd_code = READ_BLOCK) then 
               packet_size <= conv_std_logic_vector(rb_packet_size,PACKET_WORD_WIDTH);    
            else
               packet_size <= conv_std_logic_vector(NUM_REPLY_WORDS,32); 
            end if;                 
            packet_type    <= REPLY;
            status         <= reply_status;
            crd_add_par_id <= param_id & card_addr;
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
   -- process to update calculated packet checksum
   ----------------------------------------------------------------------------
   checksum_calculator: process(rst_i, clk_i)
   begin
      if(rst_i = '1') then
         checksum <= (others => '0');
      elsif(clk_i'EVENT AND clk_i = '1') then
         if(fibre_current_state = FIBRE_IDLE) then
            checksum <= (others => '0');
         elsif(fibre_current_state = LD_OKorER) then
            checksum <= checksum xor status;
         elsif(fibre_current_state = LD_CARD_PARAM) then
            checksum <= checksum xor crd_add_par_id;
         elsif(fibre_current_state = LD_STATUS) then
            checksum <= checksum xor ok_or_er;
         elsif(fibre_current_state = LD_DATA) then
            checksum <= checksum xor fibre_word_i;
         else
            checksum <= checksum;
         end if;
      end if;
   end process checksum_calculator;   

  ----------------------------------------------------------------------------
  -- process to register cmd_code, card_addr, param_id from cmd_translator 
  ----------------------------------------------------------------------------
  register_cmd_code: process(clk_i, rst_i)
  begin
     if(rst_i = '1') then                  
        cmd_code     <= (others => '0');  
        card_addr    <= (others => '0');
        param_id     <= (others => '0');   
     elsif (clk_i'EVENT and clk_i = '1') then     
        if ((cmd_rcvd_er_i = '1') or (cmd_rcvd_ok_i = '1')) then
           cmd_code  <= cmd_code_i;
           card_addr <= card_addr_i;
           param_id  <= param_id_i;
        end if;      
     end if;     
  end process register_cmd_code;     
              
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

   ----------------------------------------
   -- Logic Analyzer Signals 
   ----------------------------------------
   debug_o(6) <= fibre_word_rdy_i;
   debug_o(5) <= fibre_tx_busy_i;
   debug_o(4) <= cmd_rcvd_er_i;
   debug_o(3) <= cmd_rcvd_ok_i;
   debug_o(2) <= stop_err_rdy;
   debug_o(1) <= mop_rdy_reply;
   debug_o(0) <= mop_rdy_data;
   
   fibre_fsm_nextstate : process (fibre_current_state, cmd_rcvd_ok_i, cmd_rcvd_er_i, mop_rdy_reply,
      cmd_code_i, fibre_tx_busy_i, stop_err_rdy, fibre_word_rdy_i, mop_rdy_data, mop_error_code_i)
   begin
      -- Default Assignments
      fibre_next_state <= fibre_current_state;
      
      case fibre_current_state is
      when FIBRE_IDLE =>
         -- Error in received command packet
         if (cmd_rcvd_er_i = '1') then
            fibre_next_state <= CK_ER_REPLY;
         -- Quick response required for GO and RS commands
         elsif ((cmd_rcvd_ok_i = '1' and cmd_code_i = GO) or (cmd_rcvd_ok_i = '1' and cmd_code_i = RESET)) then                                            
            fibre_next_state <= REPLY_GO_RS;            
         -- I'm not sure if this state is ever used..
         elsif (stop_err_rdy = '1') then                 -- if we missed a stop command with checksum error during data readout
            fibre_next_state <= ST_ER_REPLY;     
         -- Normal (non_data) reply no error
         elsif (mop_rdy_reply = '1' and mop_error_code_i = FIBRE_NO_ERROR_STATUS) then 
            fibre_next_state <= REPLY_OK;
         -- Normal (non-data) reply with error
         elsif (mop_rdy_reply = '1' and mop_error_code_i /= FIBRE_NO_ERROR_STATUS) then 
            fibre_next_state <= REPLY_ER; 
         -- Data packet
         elsif (mop_rdy_data = '1') then
            fibre_next_state <= DATA_FRAME;
         -- No action
         else
            fibre_next_state <= FIBRE_IDLE;   
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
            fibre_next_state <= ACK_Q_WORD;
         end if;             

      ----------------------------------------
      -- 
      ----------------------------------------
      when WAIT_Q_WORD1 =>
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
            fibre_next_state <= ACK_Q_WORD;
         end if;             

      when ACK_Q_WORD =>
         fibre_next_state <= WAIT_Q_WORD1;    
      
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
    
         
   -------------------------------------------------------------------------
   reply_fsm_output : process (
      fibre_current_state, checksum, mop_error_code_i, cmd_code, mop_rdy_data, fibre_tx_busy_i, 
      status, crd_add_par_id, ok_or_er, packet_type, packet_size, fibre_word_i) 
   ----------------------------------------------------------------------------
   begin
      fibre_fsm_busy   <= '1';  
      fibre_tx_rdy_o   <= '0';
      fibre_word_ack_o <= '0';
      mop_ack_o        <= '0';
      arb_fsm_ack      <= '0';      
      fibre_tx_dat_o   <= (others => '0');      
      reply_argument   <= (others => '0');
      reply_status     <= (others => '0');      
      reply_status     <= (others => '0');     
      
      case fibre_current_state is
      -- Idle state - no packets to process      
      when FIBRE_IDLE =>               
         -- indicate no longer tranmitting packet
         fibre_fsm_busy <= '0';     
            
      -- checksum error state  
      when CK_ER_REPLY =>              
         reply_status   <= cmd_code(15 downto 0) & ASCII_E & ASCII_R ;
         reply_argument <= FIBRE_CHECKSUM_ERR;
      
      -- checksum error for ST command received during readout...now process
      when ST_ER_REPLY =>              
         reply_status   <= cmd_code(15 downto 0) & ASCII_E & ASCII_R ;
         reply_argument <= FIBRE_CHECKSUM_ERR;
         arb_fsm_ack    <= '1';   
            
      -- command is reset or go....so generate an instant reply...      
      when REPLY_GO_RS =>              
         reply_status   <= cmd_code(15 downto 0) & ASCII_O & ASCII_K ;
         reply_argument <= (others => '0');
           
      when REPLY_OK =>   
         reply_status   <= cmd_code(15 downto 0) & ASCII_O & ASCII_K ;
         -- this will be error code x"00" - i.e. success.              
         reply_argument <= mop_error_code_i;        
            
      when REPLY_ER =>   
         reply_status   <= cmd_code(15 downto 0) & ASCII_E & ASCII_R ;
         reply_argument <= mop_error_code_i;                 
       
      when DATA_FRAME =>       
      ----------------------------------------
      -- Preamble 1 
      -- 0xA5A5A5A5
      ----------------------------------------
      when LD_PREAMBLE1 =>
         if(fibre_tx_busy_i = '0') then 
            fibre_tx_dat_o <= FIBRE_PREAMBLE1;
            fibre_tx_rdy_o <= '1';
         end if;   
           
      ----------------------------------------
      -- Preamble 2
      -- 0x5A5A5A5A
      ----------------------------------------
      when LD_PREAMBLE2 =>
         if(fibre_tx_busy_i = '0') then 
            fibre_tx_dat_o <= FIBRE_PREAMBLE2;
            fibre_tx_rdy_o <= '1';
         end if;   
           
      ----------------------------------------
      -- Packet Type
      -- "  RP" = 0x20205250 or
      -- "  DA" = 0x20204441
      ----------------------------------------
      when LD_xxRP =>
         if(fibre_tx_busy_i = '0') then 
            fibre_tx_dat_o <= packet_type;
            fibre_tx_rdy_o <= '1';
         end if;   
           
      ----------------------------------------
      -- Packet Size
      ----------------------------------------
      when LD_PACKET_SIZE =>
         if(fibre_tx_busy_i = '0') then 
            fibre_tx_dat_o <= packet_size;
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
            fibre_tx_dat_o <= status;
            fibre_tx_rdy_o <= '1';
         end if;   

      ----------------------------------------
      -- Card Address & Parameter ID
      ----------------------------------------
      when LD_CARD_PARAM =>
         if(fibre_tx_busy_i = '0') then 
            fibre_tx_dat_o <= crd_add_par_id;
            fibre_tx_rdy_o <= '1';
         end if;   
           
      ----------------------------------------
      -- Status word
      ----------------------------------------
      when LD_STATUS =>
         if(fibre_tx_busy_i = '0') then 
            fibre_tx_dat_o <= ok_or_er;
            -- Do not transmit a status word if an RB was successful or if returning DATA
            -- Don't ask me why this is, but it's a stupid feature of the fibre protocol
            if((cmd_code = READ_BLOCK and mop_error_code_i = FIBRE_NO_ERROR_STATUS) or (mop_rdy_data = '1')) then
               null;
            else
               fibre_tx_rdy_o <= '1';
            end if;
         end if;   

      ----------------------------------------
      -- Data words
      ----------------------------------------
      when LD_DATA =>
         if(fibre_tx_busy_i = '0') then 
            fibre_tx_dat_o <= fibre_word_i; 

            -- Do not transmit a data word if an RB was unsuccessful
            -- Don't ask me why this is, but it's a stupid feature of the fibre protocol
            if(cmd_code = READ_BLOCK and mop_error_code_i /= FIBRE_NO_ERROR_STATUS) then
               null;
            else
               fibre_tx_rdy_o <= '1';
            end if;
         end if;   

      ----------------------------------------
      -- Checksum word
      ----------------------------------------
       when LD_CKSUM =>
          if(fibre_tx_busy_i = '0') then 
             fibre_tx_dat_o <= checksum;
             fibre_tx_rdy_o <= '1';
             -- acknowledge that packet has finished - i.e. started txing checksum
             mop_ack_o      <= '1';    
          end if;   
           
       when WAIT_Q_WORD1  => 
          null;

       when ACK_Q_WORD =>
          fibre_word_ack_o <= '1';    
       
       when DONE => 
          null;
       
       when others =>
           null;
           
      end case;      
      
   end process reply_fsm_output;
 
   
   ---------------------------------------------------------------------------
   -- ARBITRATION FSM 
   ----------------------------------------------------------------------------
   arb_fsm_clocked : process(clk_i, rst_i)
   begin         
      if (rst_i = '1') then
         arb_current_state <= ARB_IDLE;
      elsif (clk_i'EVENT AND clk_i = '1') then
         arb_current_state <= arb_next_state;
      end if;
   end process arb_fsm_clocked; 
             
   arb_fsm_nextstate : process (arb_current_state, fibre_fsm_busy, cmd_rcvd_er_i, cmd_code, arb_fsm_ack)
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
   
   arb_fsm_output : process(arb_current_state)
   begin      
      stop_err_rdy <= '0' ;     
      case arb_current_state is
         when ARB_IDLE =>      
            stop_err_rdy <= '0' ;
                       
         when ARB_ST_ERR =>       
            stop_err_rdy <= '1' ;
            
      end case;      
   end process arb_fsm_output;            
        
end rtl;
