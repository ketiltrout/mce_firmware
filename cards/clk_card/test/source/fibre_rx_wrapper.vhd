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
-- fibre_rx_wrapper
--
--
-- Project: 			Scuba 2
-- Author:  			David Atkinson
-- Organisation: 			UKATC
--
-- Description:
-- Test wrapper used with NIOS board to test fibre_rx in synthesis.
--
-- Revision history:
-- <date $Date: 2004/10/12 14:23:18 $> - <text> - <initials $Author: dca $>
--
-- $Log: fibre_rx_wrapper.vhd,v $
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

entity fibre_rx_wrapper is

port(
     -- global inputs 
     rst_i                   : in  std_logic;                                            -- global reset
     inclk                   : in  std_logic;                                            -- global clock


     -- interface to hotlink receiver
     fibre_rx_data           : in  std_logic_vector (7 downto 0) ;
     fibre_rx_rdy            : in  std_logic;
     fibre_rx_status         : in  std_logic;
     fibre_rx_sc_nd          : in  std_logic;
     fibre_rx_rvs            : in  std_logic;
     fibre_rx_ckr            : in  std_logic;


    -- interface to hotlink transmitter

     fibre_tx_data           : out std_logic_vector (7 downto 0);
     fibre_tx_ena            : out std_logic;  
     fibre_tx_rp             : in  std_logic; 
     fibre_tx_sc_nd          : out std_logic;

    
    -- hotlink clocks
     fibre_tx_clk            : out std_logic;
     fibre_rx_clk            : out std_logic;
     test1_o                 : out std_logic
     
     );      

end fibre_rx_wrapper;



library ieee;
use ieee.std_logic_1164.all;

library work;
use work.issue_reply_pack.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;


architecture rtl of fibre_rx_wrapper is


  
component fibre_rx_pll 
  port (
  inclk0  : in  std_logic;
  c0      : out std_logic;
  c1      : out std_logic;
  e0      : out std_logic;
  e1      : out std_logic
);

end component;





signal int_clkr     : std_logic;          
signal nRx_rdy      : std_logic; 
signal rvs          : std_logic; 
signal rso          : std_logic; 
signal rsc_nrd      : std_logic;   
signal rx_data      : std_logic_vector (7 downto 0);
signal cmd_ack      : std_logic; 
signal cmd_code     : std_logic_vector (FIBRE_CMD_CODE_WIDTH-1  downto 0);
signal card_id      : std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0); 
signal param_id     : std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1    downto 0);  
signal num_data     : std_logic_vector (PACKET_WORD_WIDTH-1      downto 0); 
signal cmd_data     : std_logic_vector (PACKET_WORD_WIDTH-1      downto 0); 
signal cksum_err    : std_logic; 
signal cmd_rdy      : std_logic; 
signal data_clk     : std_logic;


signal ext_clkr      : std_logic;
signal cmd_trig     : std_logic;

signal test_clk     : std_logic;

-- cmd acknowledge FSM to reply to command ready                             
type     ack_state is       (IDLE, ACK);
signal   ack_current_state  : ack_state;
signal   ack_next_state     : ack_state;


signal   cmd_index     : integer ;
signal   cmd_index_mux : integer ;


signal   inc_buff_sel  : std_logic_vector(1 downto 0);

signal   clk_i  : std_logic;


-- tx fifo reply translator interface signals

signal tx_ff : std_logic;
signal tx_fw : std_logic; 
signal txd   : std_logic_vector(7 downto 0);

signal cmd_rcvd_ok : std_logic;
signal cmd_rcvd_er : std_logic;

signal  cmd_stop      : std_logic;
signal  last_frame    : std_logic;
signal  frame_seq_num : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);

signal   m_op_done          : std_logic;  
signal   m_op_error_code    : std_logic_vector(BB_STATUS_WIDTH-1           downto 0); 
signal   m_op_cmd_code      : std_logic_vector(BB_COMMAND_TYPE_WIDTH-1    downto 0); 
signal   fibre_word         : std_logic_vector (PACKET_WORD_WIDTH-1        downto 0); 
signal   num_fibre_words    : std_logic_vector (BB_DATA_SIZE_WIDTH-1       downto 0);    
signal   fibre_word_req     : std_logic;
signal   fibre_word_rdy     : std_logic;
signal   m_op_ack           : std_logic;   

begin

 -- Instance port mappings

   
  i_pll : fibre_rx_pll 
  port map (
  inclk0	 =>   inclk,          -- 25Mhz in
  c0	     =>   test_clk,       -- internal 25Mhz
  c1         =>   clk_i,          -- internal 50Mhz
  e0         =>   fibre_tx_clk,   -- external 25Mhz
  e1         =>   fibre_rx_clk    -- external 25Mhz
  );
    
---------------------------
   i_fibre_rx : fibre_rx
---------------------------
   port map( 

   -- global inputs 
      rst_i        => rst_i,                 
      clk_i        => clk_i,
  
      fibre_clkr_i => fibre_rx_ckr,          
      nRx_rdy_i    => fibre_rx_rdy,
      rvs_i        => fibre_rx_rvs,   
      rso_i        => fibre_rx_status, 
      rsc_nrd_i    => fibre_rx_sc_nd,   
      rx_data_i    => fibre_rx_data,    
      cmd_ack_i    => cmd_ack, 
   
      cmd_code_o   => cmd_code,
      card_id_o    => card_id,
      param_id_o   => param_id,
      num_data_o   => num_data,
      cmd_data_o   => cmd_data,
      cksum_err_o  => cksum_err,
      cmd_rdy_o    => cmd_rdy,
      data_clk_o   => data_clk
   );



 
   -------------------------------------
   i_reply_translator : reply_translator
   --------------------------------------
   port map(

   -- global inputs 
   rst_i                   => rst_i,
   clk_i                   => clk_i,

   -- signals to/from cmd_translator    
   cmd_rcvd_er_i           => cksum_err,
   cmd_rcvd_ok_i           => cmd_rdy,
   cmd_code_i              => cmd_code,
   card_id_i               => card_id,
   param_id_i              => param_id,
         
   -- signals to/from reply queue 

   m_op_done_i             => m_op_done,  
   m_op_error_code_i       => m_op_error_code, 
   m_op_cmd_code_i         => m_op_cmd_code,
   fibre_word_i            => fibre_word,
   num_fibre_words_i       => num_fibre_words,
   fibre_word_req_o        => fibre_word_req,
   fibre_word_rdy_i        => fibre_word_rdy,
   m_op_ack_o              => m_op_ack,    

   cmd_stop_i              => cmd_stop,
   last_frame_i            => last_frame,
   frame_seq_num_i         => frame_seq_num,

   -- signals to / from fibre_tx

   tx_ff_i                 => tx_ff, 
   tx_fw_o                 => tx_fw,
   txd_o                   => txd
   );      

 
   -------------------------------------
   i_fibre_tx : fibre_tx
   --------------------------------------
   port map(        
   -- global inputs
      clk_i        => clk_i, 
      rst_i        => rst_i, 
         
   -- interface to reply_translator

     txd_i        => txd, 
     tx_fw_i      => tx_fw, 
     tx_ff_o      => tx_ff, 
      
   -- interface to HOTLINK transmitter
     fibre_clkw_i  => test_clk,
     tx_data_o     => fibre_tx_data,
     tsc_nTd_o     => fibre_tx_sc_nd,
     nFena_o       => fibre_tx_ena 

      );


   ---------------------------------------------------------------------------
   -- FSM: clock states   
   ----------------------------------------------------------------------------
   fsm_clocked : process(
      clk_i,
      rst_i
   )
   ----------------------------------------------------------------------------
   begin
         
      if (rst_i = '1') then
          ack_current_state <= IDLE;
      elsif (clk_i'EVENT AND clk_i = '1') then
          ack_current_state <= ack_next_state;
      end if;

   end process fsm_clocked;
       
         
   -------------------------------------------------------------------------
   ack_fsm_nextstate : process (ack_current_state, cmd_rdy)
   ----------------------------------------------------------------------------
   begin
     
      case ack_current_state is

      when IDLE =>
         

         if (cmd_rdy = '1') then
            ack_next_state <= ACK;  
         else 
            ack_next_state <= IDLE;   
         end if; 
           
      when ACK =>
         
         if (cmd_rdy = '0') then
            ack_next_state  <= IDLE;          -- if switch 2 on 
         else 
            ack_next_state <= ACK;   
         end if; 
         
     end case;
      
   end process ack_fsm_nextstate;            
   
   -------------------------------------------------------------------------
   ack_fsm_output : process (ack_current_state)
   ----------------------------------------------------------------------------
   begin
      

      case ack_current_state is

      when IDLE =>
         
         cmd_ack <= '0'; 
  
      when ACK =>
      
         cmd_ack <= '1'; 
        
      end case;
      
   end process ack_fsm_output;        
   
                               
 
         
end rtl;