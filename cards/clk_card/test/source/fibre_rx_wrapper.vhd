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

     -- two input signals (to generate monostable pulse) used to stimulate command packet generation    
     stim1_i                 : in  std_logic;  
     stim2_i                 : in  std_logic; 
  
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
  c0      : out std_logic
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

-- stimulation FSM to get monstable stimulation pulse                             
type     stim_state is       (S0, S1, S2, S3);
signal   stim_current_state  : stim_state;
signal   stim_next_state     : stim_state;


-- cmd acknowledge FSM to reply to command ready                             
type     ack_state is       (IDLE, ACK);
signal   ack_current_state  : ack_state;
signal   ack_next_state     : ack_state;


-- cmd generate  FSM                              
type     cmd_state is       (IDLE, GET_BYTE, LOAD_BYTE, UPDATE, WS1, WS2);
signal   cmd_current_state  : cmd_state;
signal   cmd_next_state     : cmd_state;

signal   cmd_index     : integer ;
signal   cmd_index_mux : integer ;


signal   inc_buff_sel  : std_logic_vector(1 downto 0);


-- command memory buffer declaration

constant command_size  : positive := 256;

type memory is array (0 to command_size-1) of byte;

signal command_buff: memory := (others => Byte'(others => '0'));

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
  c0	   =>   int_clkr);
    
---------------------------
   i_fibre_rx : fibre_rx
---------------------------
   port map( 

   -- global inputs 
      rst_i        => rst_i,                 
      clk_i        => clk_i,
   
      fibre_clkr_i => int_clkr,          
      nRx_rdy_i    => nRx_rdy,
      rvs_i        => rvs,   
      rso_i        => rso, 
      rsc_nrd_i    => rsc_nrd,   
      rx_data_i    => rx_data,    
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
         stim_current_state <= S0;
         ack_current_state <= IDLE;
      elsif (clk_i'EVENT AND clk_i = '1') then
         stim_current_state <= stim_next_state;
         ack_current_state <= ack_next_state;
         
    --     int_clkr <= not (int_clkr);
         
      end if;

   end process fsm_clocked;
   
   ---------------------------------------------------------------------------
   -- FSM: clkr   
   ----------------------------------------------------------------------------
   fsm_clkr : process(
      int_clkr,
      rst_i
   )
   ----------------------------------------------------------------------------
   begin
         
      if (rst_i = '1') then
         cmd_current_state <= IDLE;
      elsif (int_clkr'EVENT AND int_clkr = '1') then
         cmd_current_state <= cmd_next_state;
         
      end if;

   end process fsm_clkr;


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
         stim_next_state <= S3;
         
      when S3 =>
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
         
         cmd_trig  <= '0'; 
  
      when S1 =>
      
         cmd_trig  <= '0'; 
       
      when S2 =>
      
         cmd_trig  <= '1' ;       -- trigger the generatation of a command packet
         
      when S3 =>
         
         cmd_trig  <= '1';
 
      end case;
      
   end process stim_fsm_output;            
         
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
   
   
   -------------------------------------------------------------------------
   cmd_fsm_nextstate : process (cmd_current_state, cmd_trig, cmd_index)
   ----------------------------------------------------------------------------
   begin
     
      case cmd_current_state is

      when IDLE =>
         
         if (cmd_trig = '1') then
            cmd_next_state <= GET_BYTE;           -- if switch 1 on 
         else 
            cmd_next_state <= IDLE;   
         end if; 
           
      when GET_BYTE =>
         
         cmd_next_state <= LOAD_BYTE;
              
            
      when LOAD_BYTE =>
         
         cmd_next_state <= UPDATE;
              
            
      when UPDATE =>
         
         cmd_next_state <= WS1;
       
      when WS1 =>
         
         cmd_next_state <= WS2;
         
              
      when WS2 =>
         
         if (cmd_index < 256) then   
            cmd_next_state <= GET_BYTE;
         else 
            cmd_next_state <= IDLE;
         end if;
                 
      when others =>
         cmd_next_state <= IDLE;
         
      end case;
      
   end process cmd_fsm_nextstate;            
   
   -------------------------------------------------------------------------
   cmd_fsm_output : process (cmd_current_state, command_buff, cmd_index)
   ----------------------------------------------------------------------------
   begin
      
             
    case cmd_current_state is

      when IDLE =>
         nRx_rdy       <= '1';
         inc_buff_sel  <= "11";
         rx_data       <= (others => '0');
        
      when GET_BYTE =>
         nRx_rdy       <= '1';
         inc_buff_sel  <= "00";
         rx_data       <= command_buff(cmd_index);
         
                   
      when LOAD_BYTE =>
         nRx_rdy       <= '0';
         inc_buff_sel  <= "00";
         rx_data       <= command_buff(cmd_index);
      
      when UPDATE =>
         nRx_rdy       <= '1';
         inc_buff_sel  <= "01";
         rx_data       <= command_buff(cmd_index);
      
       
      when WS1 =>
      
         nRx_rdy       <= '1';
         inc_buff_sel  <= "00";
         rx_data       <= (others => '0');
      
      when WS2 => 
      
         nRx_rdy       <= '1';
         inc_buff_sel  <= "00";
         rx_data       <= (others => '0');
      
                 
      end case;
      
   end process cmd_fsm_output;            
     
   
   
  ------------------------------------------------------------------------------
  index_count: process(rst_i, int_clkr)
  ----------------------------------------------------------------------------
  -- process to update calculated checksum
  ----------------------------------------------------------------------------
  
  begin
     
    if (rst_i = '1') then
       cmd_index <= 0 ;
        
    elsif (int_clkr'EVENT AND int_clkr = '1') then
       
       cmd_index  <= cmd_index_mux;
       
    end if;
     
  end process index_count;   
  
  -- mux
  cmd_index_mux     <= cmd_index  when inc_buff_sel = "00" else 
                    cmd_index + 1 when inc_buff_sel = "01" else
                    0;
                            
         
end rtl;