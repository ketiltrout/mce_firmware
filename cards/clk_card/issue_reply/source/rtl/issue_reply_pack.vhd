-- Copyright (c) 2003 SCUBA-2 Project
--               All Rights Reserved
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
-- UBC,   University of British Columbia, Physics & Astronomy Department,
--        Vancouver BC, V6T 1Z1
--
-- $Id: issue_reply_pack.vhd,v 1.13 2004/07/07 10:52:03 dca Exp $
--
-- Project:    SCUBA2
-- Author:     Bryce Burger
-- Organisation:  UBC
--
-- Description:
-- Declares a few constants used as parameters in the issue_reply block
--
-- Revision history:
-- $Log: issue_reply_pack.vhd,v $
-- Revision 1.13  2004/07/07 10:52:03  dca
-- CMD_CODE_BUS_WIDTH parameter added
--
-- Revision 1.12  2004/07/06 11:09:47  dca
-- "cmd_translator_m_op_table" component declaration included.
--
-- Revision 1.11  2004/07/06 00:29:15  bburger
-- in progress
--
-- Revision 1.10  2004/07/05 23:51:08  jjacob
-- added ack_o output to cmd_translator_ret_dat_fsm
--
-- Revision 1.9  2004/06/30 23:14:40  bburger
-- bug fix: DATA_SIZE_BUS_WIDTH is =32, was =8
--
-- Revision 1.8  2004/06/29 22:42:31  jjacob
-- updating testbench, not even the first version yet.  This is a safety
-- check-in
--
-- Revision 1.7  2004/06/22 17:28:12  jjacob
-- modified bus widths
--
-- Revision 1.6  2004/05/25 21:25:32  bburger
-- added constant sync_num_bus_width
--
-- Revision 1.5  2004/05/20 18:00:51  jjacob
-- changed data width from 16 to 32 bits
--
-- Revision 1.4  2004/05/17 22:54:13  jjacob
-- modified DATA_SIZE_BUS_WIDTH = 8 from 16
--
-- Revision 1.3  2004/05/11 17:35:14  jjacob
-- increased parameter ID to 24 bits, even though we only use bottom 8 bits.
--
-- Revision 1.2  2004/05/10 19:24:41  bburger
-- added UOP_STATUS_BUS_WIDTH
--
-- Revision 1.1  2004/05/10 19:01:45  bburger
-- new
--
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package issue_reply_pack is

   -- used for interfaces between blocks incapsulated by issue_reply
   constant CARD_ADDR_BUS_WIDTH  : integer := 16;
   constant PAR_ID_BUS_WIDTH     : integer := 16;
   constant MOP_BUS_WIDTH        : integer := 8;
   constant UOP_BUS_WIDTH        : integer := 8;
   constant UOP_STATUS_BUS_WIDTH : integer := 8;
   constant DATA_SIZE_BUS_WIDTH  : integer := 32;
   constant DATA_BUS_WIDTH       : integer := 32;
   constant SYNC_NUM_BUS_WIDTH   : integer := 8;
   constant CMD_CODE_BUS_WIDTH   : integer := 16;

   -- used in cmd_queue
   constant ISSUE_SYNC_BUS_WIDTH   : integer := SYNC_NUM_BUS_WIDTH;  -- The width of the data field for the absolute sync count at which an instruction was issued
   constant TIMEOUT_SYNC_BUS_WIDTH : integer := SYNC_NUM_BUS_WIDTH;  -- The width of the data field for the absolute sync count at which an instruction expires
   constant CQ_CARD_ADDR_BUS_WIDTH : integer := 8;
   constant CQ_PAR_ID_BUS_WIDTH    : integer := 8;

------------------------------------------------------------------------
--
-- component declarations for the command translator
--
------------------------------------------------------------------------

component cmd_translator

port(

     -- global inputs

      rst_i             : in     std_logic;
      clk_i             : in     std_logic;

      -- inputs from fibre_rx

      card_id_i        : in    std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);    -- specifies which card the command is targetting
      cmd_code_i        : in    std_logic_vector (15 downto 0);   -- the least significant 16-bits from the fibre packet
      cmd_data_i        : in    std_logic_vector (DATA_BUS_WIDTH-1 downto 0);   -- the data
      --cksum_err_i    : in    std_logic;
      cmd_rdy_i         : in    std_logic;                        -- indicates the fibre_rx outputs are valid
      data_clk_i        : in    std_logic;                        -- used to clock the data out
      num_data_i        : in    std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);    -- number of 16-bit data words to be clocked out, possibly number of bytes
      --reg_addr_i        : in    std_logic_vector (23 downto 0);   -- the parameter ID
      param_id_i        : in    std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);   -- the parameter ID

      -- output to fibre_rx
      ack_o             : out std_logic;

      -- other inputs
      sync_pulse_i      : in    std_logic;
      sync_number_i     : in    std_logic_vector (7 downto 0);

      -- signals from the arbiter to micro-op sequence generator
      --ack_o             :  out std_logic;     -- DEAD unused signal --RENAME to cmd_rdy_o        -- ready signal
      card_addr_o       :  out std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      parameter_id_o    :  out std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);     -- comes from param_id_i, indicates which device(s) the command is targetting
      data_size_o       :  out std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);  -- num_data_i, indicates number of 16-bit words of data
      data_o            :  out std_logic_vector (DATA_BUS_WIDTH-1 downto 0);        -- data will be passed straight thru
      data_clk_o        :  out std_logic;
      macro_instr_rdy_o :  out std_logic;

      -- input from the micro-op sequence generator
      ack_i                 : in std_logic;                    -- acknowledge signal from the micro-instruction sequence generator


      -- outputs to the micro instruction sequence generator
      m_op_seq_num_o        : out std_logic_vector (MOP_BUS_WIDTH-1 downto 0);
      frame_seq_num_o       : out std_logic_vector (31 downto 0);
      frame_sync_num_o      : out std_logic_vector (7 downto 0);


      -- outputs to reply_translator for commands that require quick acknowldgements
      reply_cmd_ack_o       : out std_logic;                                          -- for commands that require an acknowledge before the command executes
      reply_card_addr_o     : out std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      reply_parameter_id_o  : out std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);     -- comes from param_id_i, indicates which device(s) the command is targetting
      reply_data_size_o     : out std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);  -- num_data_i, indicates number of 16-bit words of data
      reply_data_o          : out std_logic_vector (DATA_BUS_WIDTH-1 downto 0)     -- data will be passed straight thru


   );

end component;


component cmd_translator_simple_cmd_fsm

port(

     -- global inputs

      rst_i             : in     std_logic;
      clk_i             : in     std_logic;

      -- inputs from cmd_translator top level

      card_addr_i       : in std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      parameter_id_i    : in std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);     -- comes from param_id_i, indicates which device(s) the command is targetting
      data_size_i       : in std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);  -- data_size_i, indicates number of 16-bit words of data
      data_i            : in std_logic_vector (DATA_BUS_WIDTH-1 downto 0);       -- data will be passed straight thru in 16-bit words
      data_clk_i        : in std_logic;                                              -- for clocking out the data

      -- other inputs
      sync_pulse_i      : in std_logic;
      cmd_start_i       : in std_logic;
      cmd_stop_i        : in std_logic;

      -- outputs to the macro-instruction arbiter
      card_addr_o       : out std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      parameter_id_o    : out std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);     -- comes from param_id_i, indicates which device(s) the command is targetting
      data_size_o       : out std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);  -- data_size_i, indicates number of 16-bit words of data
      data_o            : out std_logic_vector (DATA_BUS_WIDTH-1 downto 0);       -- data will be passed straight thru in 16-bit words
      data_clk_o        : out std_logic;                                              -- for clocking out the data
      macro_instr_rdy_o : out std_logic;                                          -- ='1' when the data is valid, else it's '0'

      -- input from the macro-instruction arbiter
      ack_i             : in std_logic                   -- acknowledgment from the micro-instr arbiter that it is ready and has grabbed the data

   );

end component;



component cmd_translator_ret_dat_fsm

port(

     -- global inputs

      rst_i                   : in     std_logic;
      clk_i                   : in     std_logic;

      -- inputs from fibre_rx

      card_addr_i             : in std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      parameter_id_i          : in std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);     -- comes from param_id_i, indicates which device(s) the command is targetting
      data_size_i             : in std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);  -- data_size_i, indicates number of 16-bit words of data
      data_i                  : in std_logic_vector (DATA_BUS_WIDTH-1 downto 0);       -- data will be passed straight thru in 16-bit words
      data_clk_i              : in std_logic;                                              -- for clocking out the data

      -- other inputs
      sync_pulse_i            : in std_logic;
      sync_number_i           : in std_logic_vector (7 downto 0);    -- a counter of synch pulses
      ret_dat_start_i         : in std_logic;
      ret_dat_stop_i          : in std_logic;

      ret_dat_cmd_valid_o     : out std_logic;

      ret_dat_s_start_i       : in std_logic;
      ret_dat_s_done_o        : out std_logic;

      -- outputs to the macro-instruction arbiter
      card_addr_o             : out std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      parameter_id_o          : out std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);     -- comes from param_id_i, indicates which device(s) the command is targetting
      data_size_o             : out std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);  -- num_data_i, indicates number of 16-bit words of data
      data_o                  : out std_logic_vector (DATA_BUS_WIDTH-1 downto 0);       -- data will be passed straight thru in 16-bit words
      data_clk_o              : out std_logic;                                              -- for clocking out the data
      macro_instr_rdy_o       : out std_logic;                                           -- ='1' when the data is valid, else it's '0'

      ret_dat_fsm_working_o   : out std_logic;

      frame_seq_num_o         : out std_logic_vector (31 downto 0);
      frame_sync_num_o        : out std_logic_vector (7 downto 0);

      -- input from the macro-instruction arbiter
      ack_i                   : in std_logic;                   -- acknowledgment from the micro-instr arbiter that it is ready and has grabbed the data
      ack_o                   : out std_logic

   );

end component;



component cmd_translator_arbiter

port(

     -- global inputs

      rst_i                        : in std_logic;
      clk_i                        : in std_logic;

      -- inputs from the 'return data' state machine
      ret_dat_frame_seq_num_i      : in std_logic_vector (31 downto 0);
      ret_dat_frame_sync_num_i     : in std_logic_vector (7 downto 0);

      ret_dat_card_addr_i          : in std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      ret_dat_parameter_id_i       : in std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);     -- comes from param_id_i, indicates which device(s) the command is targett_ig
      ret_dat_data_size_i          : in std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);  -- num_data_i, indicates number of 16-bit words of data
      ret_dat_data_i               : in std_logic_vector (DATA_BUS_WIDTH-1 downto 0);       -- data will be passed straight thru in 16-bit words
      ret_dat_data_clk_i           : in std_logic;                                                      -- for clocking out the data
      ret_dat_macro_instr_rdy_i    : in std_logic;                                          -- ='1' when the data is valid, else it's '0'
      ret_dat_fsm_working_i        : in std_logic;

      -- output to the 'return data' state machine
      ret_dat_ack_o                : out std_logic;                   -- acknowledgment from the macro-instr arbiter that it is ready and has grabbed the data

      -- inputs from the 'simple commands' state machine
      simple_cmd_card_addr_i       : in std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      simple_cmd_parameter_id_i    : in std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);     -- comes from param_id_i, indicates which device(s) the command is targetting
      simple_cmd_data_size_i       : in std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);  -- data_size_i, indicates number of 16-bit words of data
      simple_cmd_data_i            : in std_logic_vector (DATA_BUS_WIDTH-1 downto 0);       -- data will be passed straight thru in 16-bit words
      simple_cmd_data_clk_i        : in std_logic;                                                      -- for clocking out the data
      simple_cmd_macro_instr_rdy_i : in std_logic;                                          -- ='1' when the data is valid, else it's '0'

      -- input from the macro-instruction arbiter
      simple_cmd_ack_o             : out std_logic ;

      -- outputs to the micro instruction sequence generator
      m_op_seq_num_o               : out std_logic_vector ( 7 downto 0);
      frame_seq_num_o              : out std_logic_vector (31 downto 0);
      frame_sync_num_o             : out std_logic_vector (7 downto 0);

      -- outputs to the micro-instruction generator
      card_addr_o                  : out std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      parameter_id_o               : out std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);     -- comes from param_id_i, indicates which device(s) the command is targetting
      data_size_o                  : out std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);  -- num_data_i, indicates number of 16-bit words of data
      data_o                       : out std_logic_vector (DATA_BUS_WIDTH-1 downto 0);       -- data will be passed straight thru in 16-bit words
      data_clk_o                   : out std_logic;                                               -- for clocking out the data
      macro_instr_rdy_o            : out std_logic;                                          -- ='1' when the data is valid, else it's '0'

      -- input from the micro-instruction arbiter
      ack_i             : in std_logic                   -- acknowledgment from the micro-instr arbiter that it is ready and has grabbed the data

   );

end component;

component cmd_translator_m_op_table 

port(
     -- global inputs
     rst_i                   : in     std_logic;
     clk_i                   : in     std_logic;

     -- inputs from cmd_translator (top level)     
     card_addr_store_i       : in std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
     parameter_id_store_i    : in std_logic_vector (PAR_ID_BUS_WIDTH-1    downto 0);  -- comes from reg_addr_i, indicates which device(s) the command is targetting
     m_op_seq_num_store_i    : in std_logic_vector (MOP_BUS_WIDTH-1       downto 0);
     frame_seq_num_store_i   : in std_logic_vector (31                    downto 0);
     macro_instr_rdy_i       : in std_logic;                                           -- '1' when data is valid and ready to be stored in table 
 
     -- inputs from reply translator
     m_op_seq_num_retire_i    : in std_logic_vector (MOP_BUS_WIDTH-1       downto 0);
     macro_instr_done_i       : in std_logic;                                          --'1' when issued command ready to be retired from table  
      
     retiring_busy_o          : out std_logic;                                         -- asserted high if retiring a command, during which no command should be issued.
     table_empty_o            : out std_logic;                                         -- asserted high if table full.  no more macro instructions should be retired.
     table_full_o             : out std_logic                                          -- asserted high  if table full.  No more macro instructions should be issued.
   ); 
     
end component;

end issue_reply_pack;
