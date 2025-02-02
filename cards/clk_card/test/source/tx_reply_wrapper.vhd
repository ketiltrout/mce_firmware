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
-- tx_reply_wrapper
--
--
-- Project: 			Scuba 2
-- Author:  			David Atkinson
-- Organisation: 			UKATC
--
-- Description:
-- Test wrapper used with NIOS board to test generating and reading
-- a reply packet.
--
-- Revision history:
-- <date $Date: 2004/10/08 14:24:14 $> - <text> - <initials $Author: dca $>
--
-- $Log: tx_reply_wrapper.vhd,v $
-- Revision 1.2  2004/10/08 14:24:14  dca
-- updated due to parameter name changes in command_pack
--
-- Revision 1.1  2004/10/08 14:10:52  dca
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

entity tx_reply_wrapper is

port(
     -- global inputs 
     rst_i                   : in  std_logic;                                            -- global reset
     clk_i                   : in  std_logic;                                            -- global clock

     -- test signals to stimulate packet and read packet    

     -- two input signals (to generate monostable pulse) used to stimulate a packet generation    
     stim1_i                 : in  std_logic;  
     stim2_i                 : in  std_logic;  
 
     -- two input signals (to generate monostable pulse) used to read the packet byte by byte   
     read1_i                 : in  std_logic;  
     read2_i                 : in  std_logic;   
         
      -- interface to HOTLINK transmitter
     fibre_clkw_o            : out     std_logic;                                        -- HOTLINK transmitter 25Mhz clock - generated by FPGA
     tx_data_o               : out    std_logic_vector(TX_FIFO_DATA_WIDTH-1 downto 0); 
     tsc_nTd_o               : out    std_logic;
     nFena_o                 : out    std_logic                         -- Hotlink enable - low when FIFO not empty. 
     );      

end tx_reply_wrapper;


library ieee;
use ieee.std_logic_1164.all;

library work;
use work.issue_reply_pack.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;


architecture rtl of tx_reply_wrapper is


component tx_reply 
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
     fibre_clkw_i            : in     std_logic;                                         -- HOTLINK transmitter 25MHz ref clock - generated by FPGA
 --    nTrp_i                  : in     std_logic;                                         -- read pulse
     tx_data_o               : out    std_logic_vector(TX_FIFO_DATA_WIDTH-1 downto 0); 
     tsc_nTd_o               : out    std_logic;
     nFena_o                 : out    std_logic
     );      

end component;

  
component pll 
   port (
   inclk0  : in  std_logic;
   c0      : out std_logic;
   e0	   : out std_logic
   );

end component;


-- internal signal declarations

signal cmd_rcvd_er           : std_logic;
signal cmd_rcvd_ok           : std_logic;
signal cmd_code              : std_logic_vector (FIBRE_CMD_CODE_WIDTH-1  downto 0);
signal card_id               : std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0); 
signal param_id              : std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1    downto 0);  

signal m_op_done             : std_logic;  
signal m_op_ok_nEr           : std_logic;  
signal m_op_cmd_code         : std_logic_vector (BB_COMMAND_TYPE_WIDTH-1      downto 0); 
signal fibre_word            : std_logic_vector (PACKET_WORD_WIDTH-1      downto 0); 
signal num_fibre_words       : std_logic_vector (PACKET_WORD_WIDTH-1      downto 0); 
signal fibre_word_req        : std_logic;   
signal m_op_ack              : std_logic;   

--signal nTrp                  : std_logic;      -- read pulse - active low
signal nFena                 : std_logic;      -- tranmitter - enable active low 

-- stimulation FSM to get monstable stimulation pulse                             
type     stim_state is       (S0, S1, S2);
signal   stim_current_state  : stim_state;
signal   stim_next_state     : stim_state;


signal   ext_clkw            : std_logic;
signal   int_clkw            : std_logic;

begin

-- test code
-- OR gate mapped ot some header pins to test everything is ok...
--   test1_o <= test1_i or test2_i;


   fibre_clkw_o              <= ext_clkw ;

-- assign some values
   cmd_rcvd_ok               <=  '0' ;
   cmd_code                  <= ASCII_R & ASCII_B ;
   card_id                   <= X"1234" ;
   param_id                  <= X"5678" ; 

   m_op_done                 <= '0' ;  
   m_op_ok_nEr               <= '0' ;  
   m_op_cmd_code             <= (others => '0'); 
   fibre_word                <= (others => '0'); 
   num_fibre_words           <= (others => '0'); 

   nFena_o                   <= nFena;    -- wire up internal signal to port..



-- Instance port mappings

   
   pll_inst : pll 
   port map (
   inclk0	 => clk_i,
   c0	     => int_clkw,
   e0   	 => ext_clkw
	);



   DUT : tx_reply 
   port map(
   
   -- global inputs 
      rst_i                   => rst_i,                 
      clk_i                   => clk_i,

   -- signals to/from cmd_translator    
      cmd_rcvd_er_i           => cmd_rcvd_er,
      cmd_rcvd_ok_i           => cmd_rcvd_ok,
      cmd_code_i              => cmd_code,
      card_id_i               => card_id,
      param_id_i              => param_id,
         
    -- signals to/from reply queue 
      m_op_done_i             => m_op_done,
      m_op_ok_nEr_i           => m_op_ok_nEr,
      m_op_cmd_code_i         => m_op_cmd_code,
      fibre_word_i            => fibre_word,
      num_fibre_words_i       => num_fibre_words,
      fibre_word_req_o        => fibre_word_req,
      m_op_ack_o              => m_op_ack,

    -- interface to HOTLINK transmitter
      fibre_clkw_i            => int_clkw,
--      nTrp_i                  => nTrp,
      tx_data_o               => tx_data_o,
      tsc_nTd_o               => tsc_nTd_o,
      nFena_o                 => nFena
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
         stim_current_state <= S0;
      elsif (clk_i'EVENT AND clk_i = '1') then
         stim_current_state <= stim_next_state;
      end if;

   end process fsm_clocked;


   -------------------------------------------------------------------------
   stim_fsm_nextstate : process (stim_current_state, stim1_i, stim2_i)
   ----------------------------------------------------------------------------
   begin
     
      case stim_current_state is

      when S0 =>
         

         if (stim1_i = '1' and stim2_i = '0') then
            stim_next_state <= S1;           -- if switch 1 on 
         else 
            stim_next_state <= S0;   
         end if; 
           
      when S1 =>
         
         if (stim1_i = '0' and stim2_i = '1') then
            stim_next_state <= S2;          -- if switch 2 on 
         else 
            stim_next_state <= S1;   
         end if; 
         
      when S2 =>
         stim_next_state <= S0;

      when others =>
         stim_next_state <= S0;
         
      end case;
      
   end process stim_fsm_nextstate;            
   
   -------------------------------------------------------------------------
   stim_fsm_output : process (stim_current_state)
   ----------------------------------------------------------------------------
   begin
      

      case stim_current_state is

      when S0 =>
         
         cmd_rcvd_er <= '0'; 
  
      when S1 =>
      
         cmd_rcvd_er <= '0'; 
       
      when S2 =>
      
         cmd_rcvd_er <= '1' ;       -- generate a checksum error received pulse 
                                    -- to trigger packet generation
 
      end case;
      
   end process stim_fsm_output;            
         
end rtl;