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



entity reply_translator is

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
     num_fibre_words_i       : in  std_logic_vector (DATA_BUS_WIDTH-1      downto 0);
     fibre_word_req_o        : out std_logic;
     m_op_ack_o              : out std_logic;
     
     -- signals to / from fibre_tx
     tx_ff_i                 : in std_logic;
     tx_fw_o                 : out std_logic; 
     txd_o                   : out std_logic_vector (7 downto 0)
     );      
end reply_translator;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.issue_reply_pack.all;

architecture rtl of reply_translator is


subtype byte is std_logic_vector( 7 downto 0);


-- some ascii definitions for reply packets
constant ASCII_A    : byte := X"41";  -- ascii value for 'A'
constant ASCII_B    : byte := X"42";  -- ascii value for 'B'
constant ASCII_D    : byte := X"44";  -- ascii value for 'D'
constant ASCII_E    : byte := X"45";  -- ascii value for 'E'
constant ASCII_G    : byte := X"47";  -- ascii value for 'G'
constant ASCII_K    : byte := X"4B";  -- ascii value for 'K'
constant ASCII_O    : byte := X"4F";  -- ascii value for 'O'
constant ASCII_P    : byte := X"50";  -- ascii value for 'P'
constant ASCII_R    : byte := X"52";  -- ascii value for 'R'
constant ASCII_S    : byte := X"53";  -- ascii value for 'S'
constant ASCII_SP   : byte := X"20";  -- ascii value for space


constant ERROR_WORD_WIDTH    : integer := 32;
constant CHECKSUM_ER_NUM     : std_logic_vector (ERROR_WORD_WIDTH-1 downto 0) := X"00000001" ;
constant NUM_HEAD_WORDS      : integer := 4;
constant NUM_REPLY_WORDS     : integer := 4;
constant NUM_RB_REPLY_WORDS  : integer := 64;

constant NUM_REPLY_BYTES     : integer := (NUM_HEAD_WORDS * 4) + (NUM_REPLY_WORDS *4);
constant NUM_RB_REPLY_BYTES  : integer := (NUM_HEAD_WORDS * 4) + (NUM_RB_REPLY_WORDS *4);


-- number of words in the reply (not inc. header)




signal reply_word1           : std_logic_vector(DATA_BUS_WIDTH-1 downto 0);     	-- reply word 1
signal reply_word2           : std_logic_vector(DATA_BUS_WIDTH-1 downto 0);     	-- reply word 2
signal reply_word3_63        : std_logic_vector(DATA_BUS_WIDTH-1 downto 0);     	-- reply word 3 (or for RB 3 to 63)


signal reply_word1_0         : byte;                     -- reply word 1 byte 0 
signal reply_word1_1         : byte;                     -- reply word 1 byte 1 
signal reply_word1_2         : byte;                     -- reply word 1 byte 2 
signal reply_word1_3         : byte;                     -- reply word 1 byte 3 
            
signal reply_word2_0         : byte;                     -- reply word 2 byte 0 
signal reply_word2_1         : byte;                     -- reply word 2 byte 1 
signal reply_word2_2         : byte;                     -- reply word 2 byte 2 
signal reply_word2_3         : byte;                     -- reply word 2 byte 3 
            
signal reply_word3_0         : byte;                     -- reply word 3 byte 0 
signal reply_word3_1         : byte;                     -- reply word 3 byte 1 
signal reply_word3_2         : byte;                     -- reply word 3 byte 2 
signal reply_word3_3         : byte;                     -- reply word 3 byte 3 



signal checksum              : std_logic_vector(DATA_BUS_WIDTH-1 downto 0);     	-- reply word 4 (or for RB 64)
signal checksum_in           : std_logic_vector(DATA_BUS_WIDTH-1 downto 0);  	  -- word checksum is to be updated with 
signal checksum_in_mux       : std_logic_vector(DATA_BUS_WIDTH-1 downto 0); 
signal checksum_load         : std_logic_vector(DATA_BUS_WIDTH-1 downto 0); 
signal checksum_in_mux_sel   : std_logic;


-- reply header defined

constant reply_header1_0     : byte := FIBRE_PREAMBLE1;
constant reply_header1_1     : byte := FIBRE_PREAMBLE1;
constant reply_header1_2     : byte := FIBRE_PREAMBLE1;
constant reply_header1_3     : byte := FIBRE_PREAMBLE1;
            
constant reply_header2_0     : byte := FIBRE_PREAMBLE2;
constant reply_header2_1     : byte := FIBRE_PREAMBLE2;
constant reply_header2_2     : byte := FIBRE_PREAMBLE2;
constant reply_header2_3     : byte := FIBRE_PREAMBLE2;
            
constant reply_header3_0     : byte := ASCII_P;
constant reply_header3_1     : byte := ASCII_R;
constant reply_header3_2     : byte := ASCII_SP;
constant reply_header3_3     : byte := ASCII_SP;
            
signal   reply_header4_0     : byte; 
signal   reply_header4_1     : byte; 
signal   reply_header4_2     : byte; 
signal   reply_header4_3     : byte;

-- data header defined

constant data_header1_0      : byte := FIBRE_PREAMBLE1;
constant data_header1_1      : byte := FIBRE_PREAMBLE1;
constant data_header1_2      : byte := FIBRE_PREAMBLE1;
constant data_header1_3      : byte := FIBRE_PREAMBLE1;
            
constant data_header2_0      : byte := FIBRE_PREAMBLE2;
constant data_header2_1      : byte := FIBRE_PREAMBLE2;
constant data_header2_2      : byte := FIBRE_PREAMBLE2;
constant data_header2_3      : byte := FIBRE_PREAMBLE2;
            
constant data_header3_0      : byte := ASCII_A;
constant data_header3_1      : byte := ASCII_D;
constant data_header3_2      : byte := ASCII_SP;
constant data_header3_3      : byte := ASCII_SP;

signal   data_header4_0      : byte;
signal   data_header4_1      : byte;
signal   data_header4_2      : byte;
signal   data_header4_3      : byte;


signal reply_word1_0mux_sel   : std_logic ;
signal reply_word1_1mux_sel   : std_logic ;
signal reply_word1_2mux_sel   : std_logic ;       
signal reply_word1_3mux_sel   : std_logic ; 
     
signal reply_word2_0mux_sel   : std_logic ;    
signal reply_word2_1mux_sel   : std_logic ;   
signal reply_word2_2mux_sel   : std_logic ;
signal reply_word2_3mux_sel   : std_logic ;

signal reply_word3_0mux_sel   : std_logic ;    
signal reply_word3_1mux_sel   : std_logic ;   
signal reply_word3_2mux_sel   : std_logic ;
signal reply_word3_3mux_sel   : std_logic ;


signal reply_header4_0mux_sel : std_logic ;
signal reply_header4_1mux_sel : std_logic ;
signal reply_header4_2mux_sel : std_logic ;
signal reply_header4_3mux_sel : std_logic ;

signal txd_mux_sel            : std_logic ;

signal reply_header4_0mux     : byte;
signal reply_header4_1mux     : byte;
signal reply_header4_2mux     : byte;
signal reply_header4_3mux     : byte;

signal reply_word1_0mux       : byte;
signal reply_word1_1mux       : byte;
signal reply_word1_2mux       : byte;
signal reply_word1_3mux       : byte;

signal reply_word2_0mux       : byte;
signal reply_word2_1mux       : byte;
signal reply_word2_2mux       : byte;
signal reply_word2_3mux       : byte;

signal reply_word3_0mux       : byte;
signal reply_word3_1mux       : byte;
signal reply_word3_2mux       : byte;
signal reply_word3_3mux       : byte;



signal reply_size             : std_logic_vector(DATA_BUS_WIDTH-1 downto 0);

signal fibre_word_count       : integer;




-- FSM state variables:

type reply_state is           (REPLY_IDLE, TX_REPLY, CK_ER_REPLY, CK_OK_REPLY, 
                               REPLY_GO_RS, REPLY_RB_OK, REPLY_RB_ER, REPLY_WB_ST_OK, REPLY_WB_ST_ER,
                               WAIT_Q_RB, WAIT_Q_WB_ST, 
                               LD_RP_HEAD1_0, TX_RP_HEAD1_0, LD_RP_HEAD1_1, TX_RP_HEAD1_1,
                               LD_RP_HEAD1_2, TX_RP_HEAD1_2, LD_RP_HEAD1_3, TX_RP_HEAD1_3,
                               LD_RP_HEAD2_0, TX_RP_HEAD2_0, LD_RP_HEAD2_1, TX_RP_HEAD2_1,
                               LD_RP_HEAD2_2, TX_RP_HEAD2_2, LD_RP_HEAD2_3, TX_RP_HEAD2_3,
                               LD_RP_HEAD3_0, TX_RP_HEAD3_0, LD_RP_HEAD3_1, TX_RP_HEAD3_1,
                               LD_RP_HEAD3_2, TX_RP_HEAD3_2, LD_RP_HEAD3_3, TX_RP_HEAD3_3,
                               LD_RP_HEAD4_0, TX_RP_HEAD4_0, LD_RP_HEAD4_1, TX_RP_HEAD4_1,
                               LD_RP_HEAD4_2, TX_RP_HEAD4_2, LD_RP_HEAD4_3, TX_RP_HEAD4_3,
                               LD_RP_WORD1_0, TX_RP_WORD1_0, LD_RP_WORD1_1, TX_RP_WORD1_1,
                               LD_RP_WORD1_2, TX_RP_WORD1_2, LD_RP_WORD1_3, TX_RP_WORD1_3,
                               LD_RP_WORD2_0, TX_RP_WORD2_0, LD_RP_WORD2_1, TX_RP_WORD2_1,
                               LD_RP_WORD2_2, TX_RP_WORD2_2, LD_RP_WORD2_3, TX_RP_WORD2_3,
                               LD_RP_WORD3_0, TX_RP_WORD3_0, LD_RP_WORD3_1, TX_RP_WORD3_1,
                               LD_RP_WORD3_2, TX_RP_WORD3_2, LD_RP_WORD3_3, TX_RP_WORD3_3,
                               LD_RP_CKSUM0,  TX_RP_CKSUM0,  LD_RP_CKSUM1,  TX_RP_CKSUM1,   
                               LD_RP_CKSUM2,  TX_RP_CKSUM2,  LD_RP_CKSUM3,  TX_RP_CKSUM3,
                               REQ_Q_WORD , READ_Q_WORD,    
                               LD_Q_0, TX_Q_0, LD_Q_1, TX_Q_1, LD_Q_2, TX_Q_2, LD_Q_3, TX_Q_3              
                               );
                              
type data_state is            (DATA_IDLE, TEST);


subtype byte0 is std_logic_vector( 7 downto 0);
subtype byte1 is std_logic_vector(15 downto 8);
subtype byte2 is std_logic_vector(23 downto 16);
subtype byte3 is std_logic_vector(31 downto 24);




signal transmitting_reply   : std_logic;
signal transmitting_data    : std_logic;

signal reply_status         : std_logic_vector (15 downto 0);
signal reply_data           : std_logic_vector (DATA_BUS_WIDTH-1 downto 0);

signal data_byte            : byte;
signal reply_byte           : byte;

signal   reply_current_state       : reply_state;
signal   reply_next_state          : reply_state;

signal   data_current_state        : data_state;
signal   data_next_state           : data_state;

-- FSM STATES defined

signal m_op_done_reply       : std_logic;
signal update_reply          : std_logic;
signal rb_reply              : std_logic;
signal num_tx_bytes          : integer;
signal check_reset           : std_logic;
signal check_update          : std_logic;

begin


m_op_done_reply <= m_op_done_i AND reply_nData_i;
  

-- catch data from cmd_translator with recirculation mux structure


reply_word1_2mux_sel        <= cmd_rcvd_er_i OR cmd_rcvd_ok_i;
reply_word1_3mux_sel        <= cmd_rcvd_er_i OR cmd_rcvd_ok_i;
reply_word2_0mux_sel        <= cmd_rcvd_er_i OR cmd_rcvd_ok_i;
reply_word2_1mux_sel        <= cmd_rcvd_er_i OR cmd_rcvd_ok_i;
reply_word2_2mux_sel        <= cmd_rcvd_er_i OR cmd_rcvd_ok_i;
reply_word2_3mux_sel        <= cmd_rcvd_er_i OR cmd_rcvd_ok_i;

reply_header4_0mux <= reply_size ( 7 downto  0)  when reply_header4_0mux_sel = '1' else reply_header4_0;
reply_header4_1mux <= reply_size (15 downto  8)  when reply_header4_1mux_sel = '1' else reply_header4_1;
reply_header4_2mux <= reply_size (23 downto 16)  when reply_header4_2mux_sel = '1' else reply_header4_2;
reply_header4_3mux <= reply_size (31 downto 24)  when reply_header4_3mux_sel = '1' else reply_header4_3;

reply_word1_0mux   <= reply_status ( 7 downto 0) when reply_word1_0mux_sel = '1' else reply_word1_0;
reply_word1_1mux   <= reply_status (15 downto 8) when reply_word1_1mux_sel = '1' else reply_word1_1;
reply_word1_2mux   <= cmd_code_i   ( 7 downto 0) when reply_word1_2mux_sel = '1' else reply_word1_2;
reply_word1_3mux   <= cmd_code_i   (15 downto 8) when reply_word1_3mux_sel = '1' else reply_word1_3;

reply_word2_0mux   <= param_id_i   ( 7 downto 0) when reply_word2_0mux_sel = '1' else reply_word2_0;
reply_word2_1mux   <= param_id_i   (15 downto 8) when reply_word2_1mux_sel = '1' else reply_word2_1;
reply_word2_2mux   <= card_id_i    ( 7 downto 0) when reply_word2_2mux_sel = '1' else reply_word2_2;
reply_word2_3mux   <= card_id_i    (15 downto 8) when reply_word2_3mux_sel = '1' else reply_word2_3;

reply_word3_0mux   <= reply_data   ( 7 downto  0) when reply_word3_0mux_sel = '1' else reply_word3_0;
reply_word3_1mux   <= reply_data   (15 downto  8) when reply_word3_1mux_sel = '1' else reply_word3_1;
reply_word3_2mux   <= reply_data   (23 downto 16) when reply_word3_2mux_sel = '1' else reply_word3_2;
reply_word3_3mux   <= reply_data   (31 downto 24) when reply_word3_3mux_sel = '1' else reply_word3_3;


-- checksum update mux

checksum_in_mux    <= checksum_load  when checksum_in_mux_sel = '1' else checksum_in;



-- data output mux

txd_mux_sel        <= not (transmitting_reply) ;             -- '0' for reply bytes, '1' for data bytes
txd_o              <= data_byte when txd_mux_sel = '1' else reply_byte;



  ------------------------------------------------------------------------------
  register_cmd: process(clk_i, rst_i)
  ----------------------------------------------------------------------------
  -- process to register reply words provided by cmd_translator 
  ----------------------------------------------------------------------------
  begin
     if (rst_i = '1') then 
     
        reply_header4_0 <= (others => '0');  
        reply_header4_1 <= (others => '0'); 
        reply_header4_2 <= (others => '0');
        reply_header4_3 <= (others => '0'); 

        reply_word1_0   <= (others => '0');
        reply_word1_1   <= (others => '0');
        reply_word1_2   <= (others => '0');
        reply_word1_3   <= (others => '0');
        
        reply_word2_0   <= (others => '0');
        reply_word2_1   <= (others => '0');
        reply_word2_2   <= (others => '0');
        reply_word2_3   <= (others => '0');
        
        reply_word3_0   <= (others => '0');
        reply_word3_1   <= (others => '0');
        reply_word3_2   <= (others => '0');
        reply_word3_3   <= (others => '0');
        
        checksum_in     <= (others => '0');
        
     elsif (clk_i'EVENT and clk_i = '1') then
     
        reply_header4_0 <= reply_header4_0mux;
        reply_header4_1 <= reply_header4_1mux;
        reply_header4_2 <= reply_header4_2mux;
        reply_header4_3 <= reply_header4_3mux;
        
        reply_word1_0   <= reply_word1_0mux;
        reply_word1_1   <= reply_word1_1mux;
        reply_word1_2   <= reply_word1_2mux;
        reply_word1_3   <= reply_word1_3mux;
   
        reply_word2_0   <= reply_word2_0mux;
        reply_word2_1   <= reply_word2_1mux;
        reply_word2_2   <= reply_word2_2mux;
        reply_word2_3   <= reply_word2_3mux;
        
        reply_word3_0   <= reply_word3_0mux;
        reply_word3_1   <= reply_word3_1mux;
        reply_word3_2   <= reply_word3_2mux;
        reply_word3_3   <= reply_word3_3mux;
        
        checksum_in     <= checksum_in_mux;
        
     end if;
  end process register_cmd;
  
  

            
            
        
   ---------------------------------------------------------------------------
   -- Finite State Machine 
   ----------------------------------------------------------------------------
   reply_fsm_clocked : process(
      clk_i,
      rst_i
   )
   ----------------------------------------------------------------------------
   begin
         
      if (rst_i = '1') then
         reply_current_state <= REPLY_IDLE;
      elsif (clk_i'EVENT AND clk_i = '1') then
         reply_current_state <= reply_next_state;
      end if;

   end process reply_fsm_clocked;

   -------------------------------------------------------------------------
   reply_fsm_nextstate : process (
      reply_current_state, cmd_rcvd_ok_i, cmd_rcvd_er_i, m_op_done_reply,
      reply_word1_3, reply_word1_2, m_op_ok_nEr_i, tx_ff_i, num_fibre_words_i,
      fibre_word_count
   )
   ----------------------------------------------------------------------------
   begin
     
      case reply_current_state is


      when REPLY_IDLE =>
         if    (cmd_rcvd_er_i = '1') then
            reply_next_state <= CK_ER_REPLY;
         elsif (cmd_rcvd_ok_i = '1') then 
            reply_next_state <= CK_OK_REPLY;
         else
            reply_next_state <= REPLY_IDLE;   
         end if;  
        
        
      when CK_OK_REPLY =>
         if (reply_word1_3 = ASCII_G AND reply_word1_2 = ASCII_O ) OR 
            (reply_word1_3 = ASCII_R AND reply_word1_2 = ASCII_S ) then  
            reply_next_state <= REPLY_GO_RS;
         elsif (reply_word1_3 = ASCII_R AND reply_word1_2 = ASCII_B) then
            reply_next_state <= WAIT_Q_RB;
         else
            reply_next_state <= WAIT_Q_WB_ST;
         end if;  
         
      when CK_ER_REPLY | REPLY_GO_RS =>
            reply_next_state <= LD_RP_HEAD1_0;
               
         
      when WAIT_Q_WB_ST =>
         if m_op_done_reply = '1' then
         
            if m_op_ok_nEr_i = '1' then 
               reply_next_state <= REPLY_WB_ST_OK;
            else
               reply_next_state <= REPLY_WB_ST_ER;
            end if;
    
         end if;
         
      when WAIT_Q_RB =>
          if m_op_done_reply = '1' then
       
             if m_op_ok_nEr_i = '1' then 
                reply_next_state <= REPLY_RB_OK;
             else
                reply_next_state <= REPLY_RB_ER;
             end if;
          end if;

        
       when  REPLY_WB_ST_OK | REPLY_WB_ST_ER | REPLY_RB_OK | REPLY_RB_ER =>
          
          reply_next_state <= LD_RP_HEAD1_0;
          
-- transmit reply header states
       
       when LD_RP_HEAD1_0 =>
          if tx_ff_i = '1' then 
             reply_next_state <= LD_RP_HEAD1_0;
          else
             reply_next_state <= TX_RP_HEAD1_0;
          end if;   
             
       when TX_RP_HEAD1_0 =>
          reply_next_state <= LD_RP_HEAD1_1; 
  
           
       when LD_RP_HEAD1_1 =>
          if tx_ff_i = '1' then 
             reply_next_state <= LD_RP_HEAD1_1;
          else
             reply_next_state <= TX_RP_HEAD1_1;
          end if;  
           
       
       when TX_RP_HEAD1_1 =>
          reply_next_state <= LD_RP_HEAD1_2; 
          
       when LD_RP_HEAD1_2 =>
          if tx_ff_i = '1' then 
             reply_next_state <= LD_RP_HEAD1_2;
          else
             reply_next_state <= TX_RP_HEAD1_2;
          end if;  
           
           
       when TX_RP_HEAD1_2 =>
          reply_next_state <= LD_RP_HEAD1_3;
           
       when LD_RP_HEAD1_3 =>
          if tx_ff_i = '1' then 
             reply_next_state <= LD_RP_HEAD1_3;
          else
             reply_next_state <= TX_RP_HEAD1_3;
          end if;  
           
           
       when TX_RP_HEAD1_3 =>
          reply_next_state <= LD_RP_HEAD2_0;
           
       when LD_RP_HEAD2_0 =>
          if tx_ff_i = '1' then 
             reply_next_state <= LD_RP_HEAD2_0;
          else
             reply_next_state <= TX_RP_HEAD2_0;
          end if;  
           
       when TX_RP_HEAD2_0 =>
          reply_next_state <= LD_RP_HEAD2_1;
           
       when LD_RP_HEAD2_1 =>
          if tx_ff_i = '1' then 
             reply_next_state <= LD_RP_HEAD2_1;
          else
             reply_next_state <= TX_RP_HEAD2_1;
          end if;    
       
       when TX_RP_HEAD2_1 =>
          reply_next_state <= LD_RP_HEAD2_2;
       
       when LD_RP_HEAD2_2 =>
          if tx_ff_i = '1' then 
             reply_next_state <= LD_RP_HEAD2_2;
          else
             reply_next_state <= TX_RP_HEAD2_2;
          end if;  
          
       
       when TX_RP_HEAD2_2 =>
         reply_next_state <= LD_RP_HEAD2_3;
       
       when LD_RP_HEAD2_3 =>
          if tx_ff_i = '1' then 
             reply_next_state <= LD_RP_HEAD2_3;
          else
             reply_next_state <= TX_RP_HEAD2_3;
          end if;  
          
       
       when TX_RP_HEAD2_3 =>
          reply_next_state <= LD_RP_HEAD3_0;
           
       when LD_RP_HEAD3_0 =>
          if tx_ff_i = '1' then 
             reply_next_state <= LD_RP_HEAD3_0;
          else
             reply_next_state <= TX_RP_HEAD3_0;
          end if;  
           
           
       when TX_RP_HEAD3_0 =>
         reply_next_state <= LD_RP_HEAD3_1;
           
       when LD_RP_HEAD3_1 =>
          if tx_ff_i = '1' then 
             reply_next_state <= LD_RP_HEAD3_1;
          else
             reply_next_state <= TX_RP_HEAD3_1;
          end if;  
          
       
       when TX_RP_HEAD3_1 =>
          reply_next_state <= LD_RP_HEAD3_2;
       
       when LD_RP_HEAD3_2 =>
          if tx_ff_i = '1' then 
             reply_next_state <= LD_RP_HEAD3_2;
          else
             reply_next_state <= TX_RP_HEAD3_2;
          end if;   
       
       when TX_RP_HEAD3_2 =>
          reply_next_state <= LD_RP_HEAD3_3;
       
       when LD_RP_HEAD3_3 =>
          if tx_ff_i = '1' then 
             reply_next_state <= LD_RP_HEAD3_3;
          else
             reply_next_state <= TX_RP_HEAD3_3;
          end if;  
           
       when TX_RP_HEAD3_3 =>
         reply_next_state <= LD_RP_HEAD4_0;
       
       when LD_RP_HEAD4_0 =>
          if tx_ff_i = '1' then 
             reply_next_state <= LD_RP_HEAD4_0;
          else
             reply_next_state <= TX_RP_HEAD4_0;
          end if;  
           
       
       when TX_RP_HEAD4_0 =>
          reply_next_state <= LD_RP_HEAD4_1;
       
       when LD_RP_HEAD4_1 =>
          if tx_ff_i = '1' then 
             reply_next_state <= LD_RP_HEAD4_1;
          else
             reply_next_state <= TX_RP_HEAD4_1;
          end if;     
           
       when TX_RP_HEAD4_1 =>
           reply_next_state <= LD_RP_HEAD4_2;
       
       when LD_RP_HEAD4_2 =>
          if tx_ff_i = '1' then 
             reply_next_state <= LD_RP_HEAD4_2;
          else
             reply_next_state <= TX_RP_HEAD4_2;
          end if;  
         
   
       when TX_RP_HEAD4_2 =>
          reply_next_state <= LD_RP_HEAD4_3;
  
       when LD_RP_HEAD4_3 =>
          if tx_ff_i = '1' then 
             reply_next_state <= LD_RP_HEAD4_3;
          else
             reply_next_state <= TX_RP_HEAD4_3;
          end if;  
         
  
       when TX_RP_HEAD4_3 =>
           reply_next_state <= LD_RP_WORD1_0;
 
 
 
 -- transmit reply word states
 
           
       when LD_RP_WORD1_0 =>
          if tx_ff_i = '1' then 
             reply_next_state <= LD_RP_WORD1_0;
          else
             reply_next_state <= TX_RP_WORD1_0;
          end if;  
          
             
       when TX_RP_WORD1_0 =>
         reply_next_state <= LD_RP_WORD1_1;
           
       when LD_RP_WORD1_1 =>
          if tx_ff_i = '1' then 
             reply_next_state <= LD_RP_WORD1_1;
          else
             reply_next_state <= TX_RP_WORD1_1;
          end if; 
          
       
       when TX_RP_WORD1_1 =>
          reply_next_state <= LD_RP_WORD1_2;
          
       when LD_RP_WORD1_2 =>
          if tx_ff_i = '1' then 
             reply_next_state <= LD_RP_WORD1_2;
          else
             reply_next_state <= TX_RP_WORD1_2;
          end if; 
        
           
       when TX_RP_WORD1_2 =>
           reply_next_state <= LD_RP_WORD1_3;
           
       when LD_RP_WORD1_3 =>
          if tx_ff_i = '1' then 
             reply_next_state <= LD_RP_WORD1_3;
          else
             reply_next_state <= TX_RP_WORD1_3;
          end if; 
           
       when TX_RP_WORD1_3 =>
           reply_next_state <= LD_RP_WORD2_0;
           
       when LD_RP_WORD2_0 =>
          if tx_ff_i = '1' then 
             reply_next_state <= LD_RP_WORD2_0;
          else
             reply_next_state <= TX_RP_WORD2_0;
          end if; 
   
           
       when TX_RP_WORD2_0 =>
          reply_next_state <= LD_RP_WORD2_1;
      
       when LD_RP_WORD2_1 =>
          if tx_ff_i = '1' then 
             reply_next_state <= LD_RP_WORD2_1;
          else
             reply_next_state <= TX_RP_WORD2_1;
          end if; 
     
       when TX_RP_WORD2_1 =>
          reply_next_state <= LD_RP_WORD2_2;
       
       when LD_RP_WORD2_2 =>
          if tx_ff_i = '1' then 
             reply_next_state <= LD_RP_WORD2_2;
          else
             reply_next_state <= TX_RP_WORD2_2;
          end if; 
  
       when TX_RP_WORD2_2 =>
          reply_next_state <= LD_RP_WORD2_3;
          
       when LD_RP_WORD2_3 =>
          if tx_ff_i = '1' then 
             reply_next_state <= LD_RP_WORD2_3;
          else
             reply_next_state <= TX_RP_WORD2_3;
          end if; 

       when TX_RP_WORD2_3 =>
          if m_op_done_reply = '0' then         -- if not informed by reply_queue i.e. check error GO or RS
             reply_next_state <= LD_RP_WORD3_0;
          else
             reply_next_state <= REQ_Q_WORD;   -- else if WB, ST or RB
          end if;
          
-- these reply word 3 states are for checksum error replies 
-- and GO / RS replies
          
       when LD_RP_WORD3_0 =>
          if tx_ff_i = '1' then 
             reply_next_state <= LD_RP_WORD3_0;
          else
             reply_next_state <= TX_RP_WORD3_0;
          end if; 
          
       when TX_RP_WORD3_0 =>
          reply_next_state <= LD_RP_WORD3_1;

       when LD_RP_WORD3_1 =>
          if tx_ff_i = '1' then 
             reply_next_state <= LD_RP_WORD3_1;
          else
             reply_next_state <= TX_RP_WORD3_1;
          end if; 
          
       when TX_RP_WORD3_1 =>
          reply_next_state <= LD_RP_WORD3_2;          
             
             
       when LD_RP_WORD3_2 =>
          if tx_ff_i = '1' then 
             reply_next_state <= LD_RP_WORD3_2;
          else
             reply_next_state <= TX_RP_WORD3_2;
          end if; 
          
       when TX_RP_WORD3_2 =>
          reply_next_state <= LD_RP_WORD3_3;        
             
        
       when LD_RP_WORD3_3 =>
          if tx_ff_i = '1' then 
             reply_next_state <= LD_RP_WORD3_3;
          else
             reply_next_state <= TX_RP_WORD3_3;
          end if; 
          
       when TX_RP_WORD3_3 =>
       
          if m_op_done_reply = '1' and (fibre_word_count < (to_integer(unsigned(num_fibre_words_i)))  ) then
             reply_next_state <= REQ_Q_WORD;                 -- another fibre word to read fromn Q
          else
             reply_next_state <= LD_RP_CKSUM0;               -- no word words in Q.  tx checksum.
          end if;
           
       
             
        
     -- get and transmit reply q words
     
        
       when REQ_Q_WORD =>
          reply_next_state <= READ_Q_WORD;
          
       when READ_Q_WORD =>
          reply_next_state <= LD_RP_WORD3_0;
          
       
                
       
     -- transmit checksum  states 
          
             
             
        
        
       when LD_RP_CKSUM0 =>
          if tx_ff_i = '1' then 
             reply_next_state <= LD_RP_CKSUM0;
          else
             reply_next_state <= TX_RP_CKSUM0;
          end if; 
          
       when TX_RP_CKSUM0 =>
          reply_next_state <= LD_RP_CKSUM1;  
       
       when LD_RP_CKSUM1 =>
          if tx_ff_i = '1' then 
             reply_next_state <= LD_RP_CKSUM1;
          else
             reply_next_state <= TX_RP_CKSUM1;
          end if; 
       
       when TX_RP_CKSUM1 =>
          reply_next_state <= LD_RP_CKSUM2;  
                                 
       when LD_RP_CKSUM2 =>
          if tx_ff_i = '1' then 
             reply_next_state <= LD_RP_CKSUM2;
          else
             reply_next_state <= TX_RP_CKSUM2;
          end if; 
       
       when TX_RP_CKSUM2 =>  
          reply_next_state <= LD_RP_CKSUM3;  
                      
       when LD_RP_CKSUM3 =>
          if tx_ff_i = '1' then 
             reply_next_state <= LD_RP_CKSUM3;
          else
             reply_next_state <= TX_RP_CKSUM3;
          end if;                    
                   
       when TX_RP_CKSUM3 =>  
          reply_next_state <= REPLY_IDLE;      
            
      when OTHERS =>
         reply_next_state <= REPLY_IDLE;   
         
      end case;
      
   end process reply_fsm_nextstate;
    
         
   -------------------------------------------------------------------------
   reply_fsm_output : process (
      reply_current_state, checksum, fibre_word_i,
      reply_header4_0, reply_header4_1, reply_header4_2, reply_header4_3,
      reply_word1_0,   reply_word1_1,   reply_word1_2,   reply_word1_3,
      reply_word2_0,   reply_word2_1,   reply_word2_2,   reply_word2_3,
      reply_word3_0,   reply_word3_1,   reply_word3_2,   reply_word3_3
   )
   ----------------------------------------------------------------------------
   begin
   
      reply_header4_0mux_sel  <= '0';
      reply_header4_1mux_sel  <= '0';
      reply_header4_2mux_sel  <= '0';
      reply_header4_3mux_sel  <= '0';

      reply_word1_0mux_sel    <= '0';
      reply_word1_1mux_sel    <= '0';
      
      reply_word3_0mux_sel    <= '0';
      reply_word3_1mux_sel    <= '0';
      reply_word3_0mux_sel    <= '0';
      reply_word3_1mux_sel    <= '0';
      
      transmitting_reply      <= '1';  
      tx_fw_o                 <= '0';  
      fibre_word_req_o        <= '0';
      check_update            <= '0';
      check_reset             <= '0';
      
      checksum_in_mux_sel     <= '0';
      
      cmd_ack_o               <= '0';
      
      case reply_current_state is


      when REPLY_IDLE =>
            transmitting_reply         <= '0';   
            check_reset                <= '1';  
            checksum_load              <= (others => '0');
            checksum_in_mux_sel        <= '1';
           
      when CK_ER_REPLY =>
      
  
            reply_status( 7 downto 0)  <= ASCII_R ;
            reply_status(15 downto 8)  <= ASCII_E ;
            reply_size                 <= std_logic_vector(to_unsigned(NUM_REPLY_WORDS,32));
            reply_data                 <= CHECKSUM_ER_NUM;
            
            reply_word1_0mux_sel       <= '1';
            reply_word1_1mux_sel       <= '1';
            reply_header4_0mux_sel     <= '1';
            reply_header4_1mux_sel     <= '1';
            reply_header4_2mux_sel     <= '1';
            reply_header4_3mux_sel     <= '1';
          
            reply_word3_0mux_sel       <= '1';
            reply_word3_1mux_sel       <= '1';
            reply_word3_0mux_sel       <= '1';
            reply_word3_1mux_sel       <= '1';
     
      when CK_OK_REPLY =>      
    
            reply_status( 7 downto 0)  <= ASCII_K ;
            reply_status(15 downto 8)  <= ASCII_O ;
            
            reply_data                 <= (others => '0');
            
            reply_word1_0mux_sel       <= '1';
            reply_word1_1mux_sel       <= '1';
            
            reply_word3_0mux_sel       <= '1';
            reply_word3_1mux_sel       <= '1';
            reply_word3_0mux_sel       <= '1';
            reply_word3_1mux_sel       <= '1';
            
      when REPLY_GO_RS =>
      
            reply_size                 <= std_logic_vector(to_unsigned(NUM_REPLY_WORDS,32));
   
            reply_header4_0mux_sel     <= '1';
            reply_header4_1mux_sel     <= '1';
            reply_header4_2mux_sel     <= '1';
            reply_header4_3mux_sel     <= '1';

      when REPLY_WB_ST_OK =>
      
            reply_size                 <= std_logic_vector(to_unsigned(NUM_REPLY_WORDS,32));
            reply_status( 7 downto 0)  <= ASCII_K ;
            reply_status(15 downto 8)  <= ASCII_O ;

            reply_word1_0mux_sel       <= '1';
            reply_word1_1mux_sel       <= '1';          
            reply_header4_0mux_sel     <= '1';
            reply_header4_1mux_sel     <= '1';
            reply_header4_2mux_sel     <= '1';
            reply_header4_3mux_sel     <= '1';
            
            
      when REPLY_WB_ST_ER =>
      
            reply_size                 <= std_logic_vector(to_unsigned(NUM_REPLY_WORDS,32));         
            reply_status( 7 downto 0)  <= ASCII_R ;
            reply_status(15 downto 8)  <= ASCII_E ;
              
            reply_word1_0mux_sel       <= '1';
            reply_word1_1mux_sel       <= '1';          
            reply_header4_0mux_sel     <= '1';
            reply_header4_1mux_sel     <= '1';
            reply_header4_2mux_sel     <= '1';
            reply_header4_3mux_sel     <= '1';
           
      when REPLY_RB_OK    =>   
    
            reply_size <= std_logic_vector(to_unsigned(NUM_RB_REPLY_WORDS,32));
            reply_status( 7 downto 0)  <= ASCII_K ;
            reply_status(15 downto 8)  <= ASCII_O ;

            reply_word1_0mux_sel       <= '1';
            reply_word1_1mux_sel       <= '1';          
            reply_header4_0mux_sel     <= '1';
            reply_header4_1mux_sel     <= '1';
            reply_header4_2mux_sel     <= '1';
            reply_header4_3mux_sel     <= '1';
            
      when REPLY_RB_ER    =>   
    
            reply_size <= std_logic_vector(to_unsigned(NUM_RB_REPLY_WORDS,32));
            reply_status( 7 downto 0)  <= ASCII_R ;
            reply_status(15 downto 8)  <= ASCII_E ;
              
            reply_word1_0mux_sel       <= '1';
            reply_word1_1mux_sel       <= '1';          
            reply_header4_0mux_sel     <= '1';
            reply_header4_1mux_sel     <= '1';
            reply_header4_2mux_sel     <= '1';
            reply_header4_3mux_sel     <= '1';   

       when LD_RP_HEAD1_0 =>
           reply_byte <=  reply_header1_0;
           tx_fw_o    <= '0';
             
       when TX_RP_HEAD1_0 =>
           reply_byte <=  reply_header1_0;
           tx_fw_o    <= '1';
           
       when LD_RP_HEAD1_1 =>
           reply_byte <=  reply_header1_1;
           tx_fw_o    <= '0';
       
       when TX_RP_HEAD1_1 =>
           reply_byte <=  reply_header1_1;
           tx_fw_o    <= '1';
          
       when LD_RP_HEAD1_2 =>
           reply_byte <=  reply_header1_2;
           tx_fw_o    <= '0'; 
           
       when TX_RP_HEAD1_2 =>
           reply_byte <=  reply_header1_2;
           tx_fw_o    <= '1';
           
       when LD_RP_HEAD1_3 =>
           reply_byte <=  reply_header1_3;
           tx_fw_o    <= '0';
           
       when TX_RP_HEAD1_3 =>
           reply_byte <=  reply_header1_3;
           tx_fw_o    <= '1';
           
       when LD_RP_HEAD2_0 =>
           reply_byte <=  reply_header2_0;
           tx_fw_o    <= '0';
           
       when TX_RP_HEAD2_0 =>
           reply_byte <=  reply_header2_0;
           tx_fw_o    <= '1';
           
       when LD_RP_HEAD2_1 =>
           reply_byte <=  reply_header2_1;
           tx_fw_o    <= '0';
       
       when TX_RP_HEAD2_1 =>
           reply_byte <=  reply_header2_1;
           tx_fw_o    <= '1';
       
       when LD_RP_HEAD2_2 =>
           reply_byte <=  reply_header2_2;
           tx_fw_o    <= '0';
       
       when TX_RP_HEAD2_2 =>
           reply_byte <=  reply_header2_2;
           tx_fw_o    <= '1';
       
       when LD_RP_HEAD2_3 =>
           reply_byte <=  reply_header2_3;
           tx_fw_o    <= '0';
       
       when TX_RP_HEAD2_3 =>
           reply_byte <=  reply_header2_3;
           tx_fw_o    <= '1';
           
       when LD_RP_HEAD3_0 =>
           reply_byte <=  reply_header3_0;
           tx_fw_o    <= '0';
           
       when TX_RP_HEAD3_0 =>
           reply_byte <=  reply_header3_0;
           tx_fw_o    <= '1';
           
       when LD_RP_HEAD3_1 =>
           reply_byte <=  reply_header3_1;
           tx_fw_o    <= '0';
       
       when TX_RP_HEAD3_1 =>
           reply_byte <=  reply_header3_1;
           tx_fw_o    <= '1';
       
       when LD_RP_HEAD3_2 =>
           reply_byte <=  reply_header3_2;
           tx_fw_o    <= '0';
       
       when TX_RP_HEAD3_2 =>
           reply_byte <=  reply_header3_2;
           tx_fw_o    <= '1';
       
       when LD_RP_HEAD3_3 =>
           reply_byte <=  reply_header3_3;
           tx_fw_o    <= '0';
       
       when TX_RP_HEAD3_3 =>
           reply_byte <=  reply_header3_3;
           tx_fw_o    <= '1';
       
       when LD_RP_HEAD4_0 =>
           reply_byte <=  reply_header4_0;
           tx_fw_o    <= '0';
       
       when TX_RP_HEAD4_0 =>
           reply_byte <=  reply_header4_0;
           tx_fw_o    <= '1';
       
       when LD_RP_HEAD4_1 =>
           reply_byte <=  reply_header4_1;
           tx_fw_o    <= '0';
           
       when TX_RP_HEAD4_1 =>
           reply_byte <=  reply_header4_1;
           tx_fw_o    <= '1';
       
       when LD_RP_HEAD4_2 =>
           reply_byte <=  reply_header4_2;
           tx_fw_o    <= '0';
   
       when TX_RP_HEAD4_2 =>
           reply_byte <=  reply_header4_2;
           tx_fw_o    <= '1';
  
       when LD_RP_HEAD4_3 =>
           reply_byte <=  reply_header4_3;
           tx_fw_o    <= '0';
  
       when TX_RP_HEAD4_3 =>
           reply_byte <=  reply_header4_3;
           tx_fw_o    <= '1';
           
       when LD_RP_WORD1_0 =>
           reply_byte <=  reply_word1_0;
           tx_fw_o    <= '0';
 
           checksum_load        <= reply_word1_3 & reply_word1_2 & reply_word1_1 & reply_word1_0;
           checksum_in_mux_sel  <= '1';

             
       when TX_RP_WORD1_0 =>
           reply_byte <=  reply_word1_0;
           tx_fw_o    <= '1';
         
           
       when LD_RP_WORD1_1 =>
           reply_byte <=  reply_word1_1;
           tx_fw_o    <= '0';
           
           check_update <= '1';
       
       when TX_RP_WORD1_1 =>
           reply_byte <=  reply_word1_1;
           tx_fw_o    <= '1';
          
       when LD_RP_WORD1_2 =>
           reply_byte <=  reply_word1_2;
           tx_fw_o    <= '0'; 
           
       when TX_RP_WORD1_2 =>
           reply_byte <=  reply_word1_2;
           tx_fw_o    <= '1';
           
       when LD_RP_WORD1_3 =>
           reply_byte <=  reply_word1_3;
           tx_fw_o    <= '0';
           
       when TX_RP_WORD1_3 =>
           reply_byte <=  reply_word1_3;
           tx_fw_o    <= '1';
           
       when LD_RP_WORD2_0 =>
           reply_byte <=  reply_word2_0;
           tx_fw_o    <= '0';
           
           checksum_load        <= reply_word2_3 & reply_word2_2 & reply_word2_1 & reply_word2_0;
           checksum_in_mux_sel  <= '1';
           
       when TX_RP_WORD2_0 =>
           reply_byte <=  reply_word2_0;
           tx_fw_o    <= '1';
           
       when LD_RP_WORD2_1 =>
           reply_byte <=  reply_word2_1;
           tx_fw_o    <= '0';
           
           check_update <= '1';
       
       when TX_RP_WORD2_1 =>
           reply_byte <=  reply_word2_1;
           tx_fw_o    <= '1';
       
       when LD_RP_WORD2_2 =>
           reply_byte <=  reply_word2_2;
           tx_fw_o    <= '0';
       
       when TX_RP_WORD2_2 =>
           reply_byte <=  reply_word2_2;
           tx_fw_o    <= '1';
       
       when LD_RP_WORD2_3 =>
           reply_byte <=  reply_word2_3;
           tx_fw_o    <= '0';
       
       when TX_RP_WORD2_3 =>
           reply_byte <=  reply_word2_3;
           tx_fw_o    <= '1';
           
       when LD_RP_WORD3_0 =>
           reply_byte <=  reply_word3_0;
           tx_fw_o    <= '0';
           
           checksum_load        <= reply_word3_3 & reply_word3_2 & reply_word3_1 & reply_word3_0;
           checksum_in_mux_sel  <= '1';
           
           fibre_word_count <= fibre_word_count + 1;
           
       when TX_RP_WORD3_0 =>
           reply_byte <=  reply_word3_0;
           tx_fw_o    <= '1';
           
       when LD_RP_WORD3_1 =>
           reply_byte <=  reply_word3_1;
           tx_fw_o    <= '0';
           
           check_update <= '1';
       
       when TX_RP_WORD3_1 =>
           reply_byte <=  reply_word3_1;
           tx_fw_o    <= '1';
       
       when LD_RP_WORD3_2 =>
           reply_byte <=  reply_word3_2;
           tx_fw_o    <= '0';
       
       when TX_RP_WORD3_2 =>
           reply_byte <=  reply_word3_2;
           tx_fw_o    <= '1';
       
       when LD_RP_WORD3_3 =>
           reply_byte <=  reply_word3_3;
           tx_fw_o    <= '0';
       
       when TX_RP_WORD3_3 =>
           reply_byte <=  reply_word3_3;
           tx_fw_o    <= '1';    
     
       when LD_RP_CKSUM0 =>
           reply_byte <=  checksum( 7 downto 0);
           tx_fw_o    <= '0';
       
       when TX_RP_CKSUM0 =>
           reply_byte <=  checksum( 7 downto 0);
           tx_fw_o    <= '1';
           
       when LD_RP_CKSUM1 =>
           reply_byte <=  checksum(15 downto 8);
           tx_fw_o    <= '0';
          
       
       when TX_RP_CKSUM1 =>
           reply_byte <=  checksum(15 downto 8);
           tx_fw_o    <= '1';
          
                                 
       when LD_RP_CKSUM2 =>
           reply_byte <=  checksum(23 downto 16);
           tx_fw_o    <= '0';
         
       
       when TX_RP_CKSUM2 =>  
           reply_byte <=  checksum(23 downto 16);
           tx_fw_o    <= '1';
          
                      
       when LD_RP_CKSUM3 =>
           reply_byte <=  checksum(31 downto 24);
           tx_fw_o    <= '0';
                
                   
       when TX_RP_CKSUM3 =>  
           reply_byte <=  checksum(31 downto 24);
           tx_fw_o    <= '1';
                   
                   
       when REQ_Q_WORD  =>
           fibre_word_req_o           <= '1';
           reply_data                 <= fibre_word_i;             
           reply_word3_0mux_sel       <= '1';
           reply_word3_1mux_sel       <= '1';
           reply_word3_0mux_sel       <= '1';
           reply_word3_1mux_sel       <= '1';          
      
       when READ_Q_WORD =>
          fibre_word_req_o           <= '1';
          reply_data                 <= fibre_word_i;             
          reply_word3_0mux_sel       <= '1';
          reply_word3_1mux_sel       <= '1';
          reply_word3_0mux_sel       <= '1';
          reply_word3_1mux_sel       <= '1';   
           
                   
      when OTHERS => 
             null;
        
      end case;
      
      
   end process reply_fsm_output;
 
              
  ------------------------------------------------------------------------------
  checksum_calculator: process(check_reset, check_update)
  ----------------------------------------------------------------------------
  -- process to update calculated checksum
  ----------------------------------------------------------------------------
  
  begin
     
    if (check_reset = '1') then
       checksum <= (others => '0');
    elsif (check_update'EVENT AND check_update = '1') then
       checksum <= checksum XOR checksum_in;
    end if;
     
  end process checksum_calculator;   
          
end rtl;