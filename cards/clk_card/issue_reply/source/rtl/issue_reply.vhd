-- Copyright (c) 2003 SCUBA-2 Project
--                  All Rights Reserved

--  THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE SCUBA-2 Project
--  The copyright notice above does not evidence any
--  actual or intended publication of such source code.

--  SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
--  REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
--  MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
--  PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
--  THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.

-- For the purposes of this code the SCUBA-2 Project consists of the
-- following organisations.

-- UKATC, Royal Observatory, Blackford Hill Edinburgh EH9 3HJ
-- UBC,   University of British Columbia, Physics & Astronomy Department,
--        Vancouver BC, V6T 1Z1

-- 
--
-- <revision control keyword substitutions e.g. $Id: issue_reply.vhd,v 1.10 2004/09/10 01:21:01 bburger Exp $>
--
-- Project:       SCUBA-2
-- Author:         Jonathan Jacob
--
-- Organisation:  UBC
--
-- Description:  This module is the top level for receiving fibre commands, translating them into
-- instructions, and issuing them over the bus backplane. 
-- 
--
-- Revision history:
-- 
-- <date $Date: 2004/09/10 01:21:01 $> -     <text>      - <initials $Author: bburger $>
--
-- $Log: issue_reply.vhd,v $
-- Revision 1.10  2004/09/10 01:21:01  bburger
-- Bryce:  Hardware testing, bug fixing
--
-- Revision 1.9  2004/09/02 01:14:52  bburger
-- Bryce:  Debugging - found that crc_ena must be asserted for crc_clear to function correctly
--
-- Revision 1.8  2004/09/01 17:05:39  jjacob
-- updated version
--
-- Revision 1.7  2004/08/18 06:48:43  bench2
-- Bryce: removed unnecessary interface signals between the cmd_queue and the reply_queue.
--
-- Revision 1.6  2004/08/11 00:09:11  jjacob
-- added the following signals to cmd_translator for the reply_translator interface:
--       reply_cmd_rcvd_er_o         : out std_logic;
--       reply_cmd_rcvd_ok_o         : out std_logic;
--       reply_cmd_code_o            : out std_logic_vector (15 downto 0);
--       reply_param_id_o            : out std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);       -- the parameter ID
--       reply_card_id_o             : out std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0)
--
-- and also added an input for the checksum error to route to the reply_cmd_rcvd_er_
--
-- Revision 1.5  2004/08/05 20:52:53  jjacob
-- changed sync pulse period to 53us
--
-- Revision 1.4  2004/08/05 18:16:55  jjacob
-- added cmd_queue instantiation
--
-- Revision 1.3  2004/07/28 23:39:34  jjacob
-- added:
-- library sys_param;
-- use sys_param.command_pack.all;
--
-- Revision 1.2  2004/07/12 15:43:28  jjacob
-- commented out the fibre_rx component and replaced it with
-- use work.fibre_rx_pack.all
--
-- Revision 1.1  2004/07/05 23:47:13  jjacob
-- first version
--
-- 
-- 
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library components;
use components.component_pack.all;

library work;
use work.fibre_rx_pack.all;
use work.issue_reply_pack.all;
use work.cmd_queue_pack.all;
use work.cmd_queue_ram40_pack.all;

library sys_param;
use sys_param.wishbone_pack.all;
use sys_param.general_pack.all;
use sys_param.command_pack.all;

--use sys_param.frame_timing_pack.all;

entity issue_reply is

port(
      --[JJ] for testing
      debug_o    : out std_logic_vector (31 downto 0);

      -- global signals
      rst_i        : in     std_logic;
      clk_i        : in     std_logic;
     
      
      
      -- inputs from the fibre
      rx_data_i   : in     std_logic_vector (7 DOWNTO 0);
      nRx_rdy_i   : in     std_logic;
      rvs_i       : in     std_logic;
      rso_i       : in     std_logic;
      rsc_nRd_i   : in     std_logic;        

      cksum_err_o : out    std_logic;
    

--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--

      -- this signals are temporarily here for testing, in order to route these signals to top level
      -- to be viewed on the logic analyzer
      
--      card_addr_o       :  out std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);   -- specifies which card the command is targetting
      parameter_id_o    :  out std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);      -- comes from param_id_i, indicates which device(s) the command is targetting
--      data_size_o       :  out std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);   -- num_data_i, indicates number of 16-bit words of data
      data_o            :  out std_logic_vector (DATA_BUS_WIDTH-1 downto 0);        -- data will be passed straight thru
      data_clk_o        :  out std_logic;
      macro_instr_rdy_o :  out std_logic;
--      
--      m_op_seq_num_o    :  out std_logic_vector(7 downto 0);
--      frame_seq_num_o   :  out std_logic_vector(31 downto 0);
--      frame_sync_num_o  :  out std_logic_vector(7 downto 0);
--      
--      -- input from the micro-op sequence generator
--      ack_i             : in std_logic     
      
      macro_op_ack_o  : out std_logic;
      -- lvds_tx interface
      tx_o          : out std_logic;  -- transmitter output pin
      clk_200mhz_i   : in std_logic;  -- PLL locked 25MHz input clock for the

      sync_pulse_i: in    std_logic;
      sync_number_i  : in std_logic_vector (7 downto 0)
      


   ); 
     
end issue_reply;


architecture rtl of issue_reply is

      -- inputs from fibre_rx 
      signal card_id         :  std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);    -- specifies which card the command is targetting
      signal cmd_code        :  std_logic_vector (15 downto 0);                       -- the least significant 16-bits from the fibre packet
      signal cksum_err       :  std_logic;
      signal cmd_data        :  std_logic_vector (DATA_BUS_WIDTH-1 downto 0);         -- the data 
      signal cmd_rdy         :  std_logic;                                            -- indicates the fibre_rx outputs are valid
      signal data_clk        :  std_logic;                                            -- used to clock the data out
      signal num_data        :  std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);    -- number of 16-bit data words to be clocked out, possibly number of bytes
      signal param_id        :  std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);       -- the parameter ID
      signal cmd_type        :  std_logic_vector (CMD_TYPE_WIDTH-1 downto 0);       -- this is a re-mapping of the cmd_code into a 3-bit number
      signal cmd_ack         :  std_logic;   -- acknowledge signal from cmd_translator to fibre_rx
      signal cmd_stop        :  std_logic;
      signal last_frame      :  std_logic;
 
      -- signals for the return path for quick responses, currently not implemented
--      signal reply_cmd_ack_o      :  std_logic; 
--      signal reply_card_addr_o    :  std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);
--      signal reply_parameter_id_o :  std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);
--      signal reply_data_size_o    :  std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0); 
--      signal reply_data_o         :  std_logic_vector (DATA_BUS_WIDTH-1 downto 0); 
      
      signal reply_cmd_rcvd_er    :  std_logic;
      signal reply_cmd_rcvd_ok  :  std_logic;
      signal reply_cmd_code     :  std_logic_vector (15 downto 0);
      signal reply_param_id     :  std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0); 
      signal reply_card_id      :  std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);

      signal sync_pulse           : std_logic;
      signal sync_number          : std_logic_vector (7 downto 0);



      -- reply_queue interface
      signal uop_status : std_logic_vector(UOP_STATUS_BUS_WIDTH-1 downto 0);
      signal uop_rdy : std_logic;
      signal uop_rdy_stg1 :std_logic;
      signal uop_rdy_stg2 :std_logic;
      signal uop_ack : std_logic;
      signal uop_discard : std_logic;
      signal uop_timedout : std_logic;
      signal uop  : std_logic_vector(QUEUE_WIDTH-1 downto 0);
   
 
         -- cmd_translator to cmd_queue interface
      signal card_addr :  std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);
      signal parameter_id:  std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0); 
      signal data_size:  std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);
      signal data :  std_logic_vector (DATA_BUS_WIDTH-1 downto 0);
      signal data_clk2 :  std_logic; 
      signal m_op_seq_num : std_logic_vector(MOP_BUS_WIDTH-1 downto 0);--(7 downto 0);
      signal frame_sync_num  : std_logic_vector(SYNC_NUM_BUS_WIDTH-1 downto 0);--(7 downto 0);
      signal frame_seq_num   : std_logic_vector(31 downto 0);-- currently doesn't go anywhere.  Doesn't need to be an output from the cmd_translator
      signal macro_instr_rdy:  std_logic; 
      signal mop_ack :  std_logic; 

      -- temporary signals to simulate the sync pulse counter

--      signal count                : integer;
--      signal count_rst            : std_logic;
--      signal sync_number_mux_sel  : std_logic;
--      signal sync_number_mux      : std_logic_vector(7 downto 0);
--      
--      type state is               (IDLE, COUNTING, INCREMENT);
--      signal current_state, next_state : state;
--      constant SYNC_PERIOD        : integer := 53; -- time in micro-seconds


      type state is (IDLE, WAIT1, WAIT2, ACK1, ACK2);
      signal cur_state, next_state : state;


--   component fibre_rx is
--   port( 
--      rst_i       : in     std_logic;
--      clk_i       : in     std_logic;
--      
--      nrx_rdy_i   : in     std_logic;
--      rvs_i       : in     std_logic;
--      rso_i       : in     std_logic;
--      rsc_nrd_i   : in     std_logic;  
--      rx_data_i   : in     std_logic_vector (7 downto 0);
--      cmd_ack_i   : in     std_logic;                          -- command acknowledge
--      
--      cmd_code_o  : out    std_logic_vector (15 downto 0);     -- command code  
--      card_id_o   : out    std_logic_vector (15 downto 0);     -- card id
--      param_id_o  : out    std_logic_vector (15 downto 0);     -- parameter id
--      num_data_o  : out    std_logic_vector (7 downto 0);      -- number of valid 32 bit data words
--      cmd_data_o  : out    std_logic_vector (31 downto 0);     -- 32bit valid data word
--      cksum_err_o : out    std_logic;                          -- checksum error flag
--      cmd_rdy_o   : out    std_logic;                          -- command ready flag (checksum passed)
--      data_clk_o  : out    std_logic                           -- data clock
--    );
--
--   end component;

begin


--
--
--
--
--

    -- temporarily routing these signals to top level to view them on the logic analyzer
    parameter_id_o <= parameter_id;
    data_o         <= data;
    data_clk_o     <= data_clk2;
    macro_instr_rdy_o <= cmd_rdy;
    macro_op_ack_o    <= cmd_ack;


--------------------------------------------------
-- Instantiate fibre receiver
--------------------------------------------------


   i_fibre_rx : fibre_rx
   port map( 
      rst_i           => rst_i,
      clk_i           => clk_i,
      
      -- inputs from the fibre
      nrx_rdy_i       => nrx_rdy_i,
      rvs_i           => rvs_i,
      rso_i           => rso_i,
      rsc_nrd_i       => rsc_nrd_i,
      rx_data_i       => rx_data_i,
      
      -- input from cmd_translator
      cmd_ack_i       => cmd_ack,                  -- command acknowledge
      
      -- outputs to cmd_translator
      cmd_code_o      => cmd_code,                   -- command code
      card_id_o       => card_id,                    -- card id
      param_id_o      => param_id,                   -- parameter id
      num_data_o      => num_data,                   -- number of valid 32 bit data words
      cmd_data_o      => cmd_data,                   -- 32bit valid data word
      cmd_rdy_o       => cmd_rdy,                    -- checksum error flag
      data_clk_o      => data_clk,                   -- data clock
      
      cksum_err_o     => cksum_err
    );


   cksum_err_o <= cksum_err;


------------------------------------------------------------------------
--
-- instantiate command translator
--
------------------------------------------------------------------------
   i_cmd_translator : cmd_translator
      port map(
               -- global inputs
               rst_i                => rst_i,
               clk_i                => clk_i,
               
               -- inputs from fibre_rx
               card_id_i            => card_id,
               cmd_code_i           => cmd_code,
               cmd_data_i           => cmd_data,
               cksum_err_i          => cksum_err,
               cmd_rdy_i            => cmd_rdy,
               data_clk_i           => data_clk,
               num_data_i           => num_data,
               param_id_i           => param_id,
               
               -- output to fibre_rx
               ack_o                => cmd_ack,
               
               -- outputs to u-op sequence generator
               
               card_addr_o          => card_addr,--card_addr_o,
               parameter_id_o       => parameter_id,--parameter_id_o,
               data_size_o          => data_size,--data_size_o,
               data_o               => data,--data_o,
               data_clk_o           => data_clk2,--data_clk_o,
               macro_instr_rdy_o    => macro_instr_rdy,--macro_instr_rdy_o,
               m_op_seq_num_o       => m_op_seq_num,--m_op_seq_num_o,
               frame_seq_num_o      => frame_seq_num,--frame_seq_num_o,
               frame_sync_num_o     => frame_sync_num,--frame_sync_num_o,
               cmd_type_o           => cmd_type,
               cmd_stop_o           => cmd_stop,
               last_frame_o         => last_frame,       
               
               --input from the u-op sequence generator
               ack_i                => mop_ack,
               
               -- outputs on return path for quick responses, currently not implemented
--               reply_cmd_ack_o      => reply_cmd_ack_o,    
--               reply_card_addr_o    => reply_card_addr_o,     
--               reply_parameter_id_o => reply_parameter_id_o,
--               reply_data_size_o    => reply_data_size_o,
--               reply_data_o         => reply_data_o,
               
               reply_cmd_rcvd_er_o  => reply_cmd_rcvd_er,
               reply_cmd_rcvd_ok_o  => reply_cmd_rcvd_ok,
               reply_cmd_code_o     => reply_cmd_code,
               reply_param_id_o     => reply_param_id,
               reply_card_id_o      => reply_card_id,

               
               
               sync_pulse_i         => sync_pulse_i,
               sync_number_i        => sync_number_i

               );
               
------------------------------------------------------------------------
--
-- instantiate command queue (u-op sequence generator)
--
------------------------------------------------------------------------               
    uop_status <= (others=>'0');
    uop_ack    <= '0';
      
    i_cmd_queue : cmd_queue
      port map(
         -- for testing
         debug_o  => debug_o,

         -- reply_queue interface

        -- uop_status_i   => uop_status,  -- tie these signals

         uop_rdy_o      => uop_rdy,
         uop_ack_i      => uop_ack,--uop_rdy_stg2,--

        -- uop_discard_o  => uop_discard,
        -- uop_timedout_o => uop_timedout,

         uop_o          => uop,
         
         -- cmd_translator interface
         card_addr_i    => card_addr,
         par_id_i       => parameter_id,
         data_size_i    => data_size,
         data_i         => data,
         data_clk_i     => data_clk2,
         mop_i          => m_op_seq_num,
         issue_sync_i   => frame_sync_num,
         mop_rdy_i      => macro_instr_rdy,
         mop_ack_o      => mop_ack,
         cmd_type_i     => cmd_type,
         cmd_stop_i     => cmd_stop,
         last_frame_i   => last_frame,

         -- lvds_tx interface
         tx_o           => tx_o,
         clk_200mhz_i   => clk_200mhz_i,

         -- Clock lines
         sync_i         => sync_pulse_i,
         sync_num_i     => sync_number_i,
         clk_i          => clk_i,
         rst_i          => rst_i
      );

   process(clk_i, rst_i)
   begin
      if rst_i = '1' then
         uop_rdy_stg1 <= '0';
         uop_rdy_stg2 <= '0';
         cur_state <= IDLE;
      elsif clk_i'event and clk_i='1' then
         uop_rdy_stg1 <= uop_rdy;
         uop_rdy_stg2 <= uop_rdy_stg1;
         cur_state <= next_state;
      end if;
   end process; 
   
   process(cur_state, uop_rdy)
   begin
      -- defaults
      --uop_ack    <= '0';
      
      case cur_state is
         when IDLE =>
            if uop_rdy <= '1' then
               next_state <= WAIT1;
            else
               next_state <= IDLE;
            end if;
            
         when WAIT1 =>
            next_state <= WAIT2;
            
         when WAIT2 =>
            next_state <= ACK1;
            
         when ACK1 =>
            next_state <= ACK2;
            --uop_ack    <= '1';
            
         when ACK2 =>
            next_state <= IDLE;
            --uop_ack    <= '1';
            
         when others =>
            next_state <= IDLE;
         
      end case;
   end process;
   
      
          
------------------------------------------------------------------------
--
-- temporary sync_number counter
--
------------------------------------------------------------------------

--    i_timer : us_timer
--    port map(clk           => clk_i,
--           timer_reset_i   => count_rst,
--           timer_count_o   => count
--           );
--           
--
--   process(current_state, count)
--   begin
--   
--      -- default
--      count_rst           <= '0';
--      sync_number_mux_sel <= '0';
--   
--      case current_state is
--         when IDLE =>
--            next_state <= COUNTING;
--            count_rst  <= '1';
--            
--         when COUNTING =>
--            if count = SYNC_PERIOD then
--               --count_rst           <= '1';
--               --sync_number_mux_sel <= '1';
--               next_state <= INCREMENT;
--            else
--               next_state <= COUNTING;
--            end if;
--            
--         when INCREMENT =>
--            count_rst           <= '1';
--            sync_number_mux_sel <= '1';
--            next_state <= COUNTING;
--            
--         when others =>
--            next_state <= IDLE;
--                     
--      end case;
--   end process;
--
--
--   process(clk_i, rst_i)
--   begin
--      if rst_i = '1' then
--         sync_number    <= (others=>'0');
--         current_state <= IDLE;
--      elsif clk_i'event and clk_i = '1' then
--         current_state <= next_state;
--         sync_number    <= sync_number_mux;
--      end if;
--   end process;
--
--   sync_number_mux <= sync_number + 1 when sync_number_mux_sel = '1' else sync_number;
--
--
--   
--   sync_pulse <= sync_number_mux_sel;
--
   --[JJ] for testing
   --sync_pulse_o <= sync_pulse;

end rtl; 