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
     clk_i                   : in  std_logic;                                            -- global clock


     -- interface to hotlink receiver
     fibre_rx_data           : in  std_logic_vector (7 downto 0) ;
     fibre_rx_rdy            : in  std_logic;
     fibre_rx_status         : in  std_logic;
     fibre_rx_sc_nd          : in  std_logic;
     fibre_rx_rvs            : in  std_logic;
     fibre_rx_ckr            : in  std_logic;

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


-- cmd acknowledge FSM to reply to command ready                             
type     ack_state is       (IDLE, ACK);
signal   ack_current_state  : ack_state;
signal   ack_next_state     : ack_state;


signal   cmd_index     : integer ;
signal   cmd_index_mux : integer ;


signal   inc_buff_sel  : std_logic_vector(1 downto 0);


-- command memory buffer declaration

constant command_size  : positive := 256;

type memory is array (0 to command_size-1) of byte;

signal command_buff: memory := (others => Byte'(others => '0'));


signal count   : integer ;
constant delay : integer := 50000000 ;
signal rst_count : std_logic;
signal ena_count : std_logic;

begin

   test1_o           <= '0' ;

   rvs               <= '0' ; 
   rso               <= '1' ; 
   rsc_nrd           <= '0' ;  

   command_buff(  0) <= X"A5";
   command_buff(  1) <= X"A5";
   command_buff(  2) <= X"A5";
   command_buff(  3) <= X"A5";
   
   command_buff(  4) <= X"5A";
   command_buff(  5) <= X"5A";
   command_buff(  6) <= X"5A";
   command_buff(  7) <= X"5A";
   
   command_buff(  8) <= X"42";
   command_buff(  9) <= X"57";
   command_buff( 10) <= X"20";
   command_buff( 11) <= X"20";
   
   command_buff( 12) <= X"5C";
   command_buff( 13) <= X"00";
   command_buff( 14) <= X"02";
   command_buff( 15) <= X"00";

   command_buff( 16) <= X"01";
   command_buff( 17) <= X"00";
   command_buff( 18) <= X"00";
   command_buff( 19) <= X"00";

   command_buff( 20) <= X"0A";
   command_buff( 21) <= X"00";
   command_buff( 22) <= X"00";
   command_buff( 23) <= X"00";
   
   command_buff(252) <= X"15";
   command_buff(253) <= X"57";
   command_buff(254) <= X"22";
   command_buff(255) <= X"20";
 

-- Instance port mappings

 -- Instance port mappings

   
  i_pll : fibre_rx_pll 
  port map (
  inclk0	 =>   clk_i,
  c0	     =>   int_clkr,
  e0         =>   fibre_tx_clk, 
  e1         =>   fibre_rx_clk
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