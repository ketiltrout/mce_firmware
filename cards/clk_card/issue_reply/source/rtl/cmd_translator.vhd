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
-- <revision control keyword substitutions e.g. $Id: cmd_translator.vhd,v 1.19 2004/10/08 19:45:26 bburger Exp $>
--
-- Project:       SCUBA-2
-- Author:         Jonathan Jacob
--
-- Organisation:  UBC
--
-- Description:  This module is the fibre command translator. 
-- 
-- 
--
-- Revision history:
-- 
-- <date $Date: 2004/10/08 19:45:26 $> -     <text>      - <initials $Author: bburger $>
--
-- $Log: cmd_translator.vhd,v $
-- Revision 1.19  2004/10/08 19:45:26  bburger
-- Bryce:  Changed SYNC_NUM_WIDTH to 16, removed TIMEOUT_SYNC_WIDTH, added a command-code to cmd_queue, added two words of book-keeping information to the cmd_queue
--
-- Revision 1.18  2004/09/30 22:34:44  erniel
-- using new command_pack constants
--
-- Revision 1.17  2004/09/10 19:14:36  jjacob
-- modifed outputs to reply_translator to feedthrough values from fibre_rx
--
-- Revision 1.16  2004/09/09 18:25:38  jjacob
-- added 3 outputs:
-- >       cmd_type_o        :  out std_logic_vector (BB_COMMAND_TYPE_WIDTH-1 downto 0);       -- this is a re-mapping of the cmd_code into a 3-bit number
-- >       cmd_stop_o        :  out std_logic;                                          -- indicates a STOP command was recieved
-- >       last_frame_o      :  out std_logic;                                          -- indicates the last frame of data for a ret_dat command
--
-- Revision 1.15  2004/09/02 23:41:43  jjacob
-- cleaning up and formatting
--
-- Revision 1.14  2004/09/02 18:24:17  jjacob
-- cleaning up and formatting
--
-- Revision 1.13  2004/08/25 22:15:33  bburger
-- Bryce:  removed the dbl_buffer command
--
-- Revision 1.12  2004/08/11 00:08:25  jjacob
-- added the following signals for the reply_translator interface:
--       reply_cmd_rcvd_er_o         : out std_logic;
--       reply_cmd_rcvd_ok_o         : out std_logic;
--       reply_cmd_code_o            : out std_logic_vector (15 downto 0);
--       reply_param_id_o            : out std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);       -- the parameter ID
--       reply_card_id_o             : out std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0)
--
-- and also added an input for the checksum error to route to the reply_cmd_rcvd_er_
--
-- Revision 1.11  2004/08/05 20:52:01  jjacob
-- added sync_number input to arbiter instatiation
--
-- Revision 1.10  2004/08/05 18:14:29  jjacob
-- changed frame_sync_num_o to use the parameter
-- SYNC_NUM_WIDTH
--
-- Revision 1.9  2004/07/28 23:39:05  jjacob
-- added:
-- library sys_param;
-- use sys_param.command_pack.all;
--
-- Revision 1.8  2004/07/05 23:38:56  jjacob
-- added ack_o signal to cmd_translator_ret_dat_fsm to control the
-- acknowledge signal back to the fibre_rx block
--
-- Revision 1.6  2004/06/21 16:57:24  jjacob
-- first stable version, doesn't yet have macro-instruction buffer, doesn't have
-- "quick" acknolwedgements for instructions that require them, no error
-- handling, basically no return path logic yet.  Have implemented ret_dat
-- instructions, and "simple" instructions.  Not all instructions are fully
-- implemented yet.
--
-- Revision 1.5  2004/06/09 23:32:47  jjacob
-- cleaned formatting
--
-- Revision 1.4  2004/06/08 00:14:10  jjacob
-- updating
--
-- Revision 1.3  2004/06/04 23:01:17  jjacob
-- daily update/ safety checkin
--
-- Revision 1.2  2004/06/03 23:39:39  jjacob
-- safety checkin
--
-- Revision 1.1  2004/05/28 15:53:25  jjacob
-- first version
--
--
-- 
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library components;
use components.component_pack.all;

library work;
use work.issue_reply_pack.all;
use work.sync_gen_pack.all;

library sys_param;
use sys_param.wishbone_pack.all;
--use sys_param.general_pack.all;
use sys_param.command_pack.all;

entity cmd_translator is

port(

     -- global inputs

      rst_i             : in     std_logic;
      clk_i             : in     std_logic;

      -- inputs from fibre_rx      

      card_id_i         : in    std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);    -- specifies which card the command is targetting
      cmd_code_i        : in    std_logic_vector (FIBRE_CMD_CODE_WIDTH-1 downto 0);                       -- the least significant 16-bits from the fibre packet
      cmd_data_i        : in    std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);         -- the data
      cksum_err_i       : in    std_logic;
      cmd_rdy_i         : in    std_logic;                                            -- indicates the fibre_rx outputs are valid
      data_clk_i        : in    std_logic;                                            -- used to clock the data out
      num_data_i        : in    std_logic_vector (FIBRE_DATA_SIZE_WIDTH-1 downto 0);    -- number of 16-bit data words to be clocked out, possibly number of bytes
      param_id_i        : in    std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);       -- the parameter ID
 
      -- output to fibre_rx
      ack_o             : out std_logic;
      
      -- other inputs 
      sync_pulse_i      : in    std_logic;
      sync_number_i     : in    std_logic_vector (SYNC_NUM_WIDTH-1 downto 0);     --(7 downto 0);
     
      -- signals from the arbiter to cmd_queue (micro-op sequence generator)
      card_addr_o       :  out std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      parameter_id_o    :  out std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);     -- comes from param_id_i, indicates which device(s) the command is targetting
      data_size_o       :  out std_logic_vector (FIBRE_DATA_SIZE_WIDTH-1 downto 0);  -- num_data_i, indicates number of 16-bit words of data
      data_o            :  out std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);       -- data will be passed straight thru
      data_clk_o        :  out std_logic;
      macro_instr_rdy_o :  out std_logic;
      cmd_type_o        :  out std_logic_vector (BB_COMMAND_TYPE_WIDTH-1 downto 0);       -- this is a re-mapping of the cmd_code into a 3-bit number
      cmd_stop_o        :  out std_logic;                                          -- indicates a STOP command was recieved
      last_frame_o      :  out std_logic;                                          -- indicates the last frame of data for a ret_dat command
      
      -- input from the cmd_queue (micro-op sequence generator)
      ack_i                 : in std_logic;                    -- acknowledge signal from the micro-instruction sequence generator

      -- outputs to the cmd_queue (micro instruction sequence generator)
      m_op_seq_num_o        : out std_logic_vector (BB_MACRO_OP_SEQ_WIDTH-1 downto 0);
      frame_seq_num_o       : out std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      frame_sync_num_o      : out std_logic_vector (SYNC_NUM_WIDTH-1 downto 0);   --(7 downto 0);

      -- outputs to reply_translator for commands that require quick acknowldgements
      reply_cmd_rcvd_er_o         : out std_logic;
      reply_cmd_rcvd_ok_o         : out std_logic;
      reply_cmd_code_o            : out std_logic_vector (FIBRE_CMD_CODE_WIDTH-1 downto 0);
      reply_param_id_o            : out std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);       -- the parameter ID
      reply_card_id_o             : out std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0)     -- specifies which card the command is targetting

   ); 
     
end cmd_translator;


architecture rtl of cmd_translator is
   
   -- signals to ret_dat state machine
   signal ret_dat_start     : std_logic;
   signal ret_dat_stop      : std_logic;
   signal arbiter_ret_dat_ack       : std_logic;
   signal ret_dat_cmd_valid : std_logic;
   
   signal ret_dat_ack       : std_logic;
   signal ret_dat_stop_ack  : std_logic;

   signal ret_dat_s_start   : std_logic;
   signal ret_dat_s_done    : std_logic;
   signal ret_dat_s_ack     : std_logic;
      
   -- signals to state machine controlling simple commands
   signal cmd_start         : std_logic;
   signal cmd_stop          : std_logic;

   -- 'return data' signals to the arbiter, (then to micro-op sequence generator)
   signal ret_dat_cmd_ack            : std_logic;                                          -- ready signal
   signal ret_dat_cmd_card_addr      : std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
   signal ret_dat_cmd_parameter_id   : std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);     -- comes from param_id_i, indicates which device(s) the command is targetting
   signal ret_dat_cmd_data_size      : std_logic_vector (FIBRE_DATA_SIZE_WIDTH-1 downto 0);  -- num_data_i, indicates number of 16-bit words of data
   signal ret_dat_cmd_data           : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);       -- data will be passed straight thru
   signal ret_dat_cmd_data_clk       : std_logic;
   signal ret_dat_cmd_type           : std_logic_vector (BB_COMMAND_TYPE_WIDTH-1 downto 0);       -- this is a re-mapping of the cmd_code into a 3-bit number
   
   signal ret_dat_fsm_working        : std_logic;
   
   signal frame_seq_num              : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal frame_sync_num             : std_logic_vector (SYNC_NUM_WIDTH-1 downto 0);   --(7 downto 0);

   -- 'simple command' signals to the arbiter, (then to micro-op  sequence generator )
   signal simple_cmd_ack             : std_logic;                                          -- ready signal
   signal simple_cmd_card_addr       : std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
   signal simple_cmd_parameter_id    : std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);     -- comes from param_id_i, indicates which device(s) the command is targetting
   signal simple_cmd_data_size       : std_logic_vector (FIBRE_DATA_SIZE_WIDTH-1 downto 0);  -- num_data_i, indicates number of 16-bit words of data
   signal simple_cmd_data            : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);       -- data will be passed straight thru
   signal simple_cmd_data_clk        : std_logic;
   signal simple_cmd_macro_instr_rdy : std_logic;
   signal simple_cmd_type            : std_logic_vector (BB_COMMAND_TYPE_WIDTH-1 downto 0);       -- this is a re-mapping of the cmd_code into a 3-bit number
   
   signal arbiter_ack                : std_logic_vector (2 downto 0);
   signal macro_instr_rdy            : std_logic;
   signal cmd_code                   : std_logic_vector (FIBRE_CMD_CODE_WIDTH-1 downto 0);
   signal ret_dat_cmd_stop           : std_logic;
   signal ret_dat_last_frame         : std_logic;


   constant START_CMD                : std_logic_vector (FIBRE_CMD_CODE_WIDTH-1 downto 0) := x"474F";
   constant STOP_CMD                 : std_logic_vector (FIBRE_CMD_CODE_WIDTH-1 downto 0) := x"5354";
   
   signal parameter_id               : std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);
   signal card_addr                  : std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);


begin


------------------------------------------------------------------------
--
-- logic for routing incoming de-composed fibre commands
--
------------------------------------------------------------------------     

   process (cmd_rdy_i, param_id_i, cmd_code_i)            
   begin
      -- defaults
     -- ret_dat_stop_ack <= '0';

      if cmd_rdy_i = '1' then 
         case param_id_i (7 downto 0) is  -- this is the parameter ID
            
         ---------------------------------------------------------------------------------
         -- System
            when RET_DAT_ADDR       => -- gets broken up into multiple macro-ops
               
               if cmd_code_i = START_CMD then

                  ret_dat_start        <= '1';
                  ret_dat_stop         <= '0';
                  
                  ret_dat_s_start      <= '0';
                  ret_dat_s_ack        <= '0';
                     
                  cmd_start            <= '0';
                  cmd_stop             <= '0';
                  
               else -- assume it's a stop command (STOP_CMD)

                  ret_dat_start        <= '0';
                  ret_dat_stop         <= '1';
                  --ret_dat_stop_ack     <= '1';
                  
                  ret_dat_s_start      <= '0';
                  ret_dat_s_ack        <= '0';
                     
                  cmd_start            <= '0';
                  cmd_stop             <= '0';
                  
               end if;   
               
            when RET_DAT_S_ADDR     =>
            
               ret_dat_start           <= '0';
               ret_dat_stop            <= '0';
              
               ret_dat_s_start         <= '1';
               ret_dat_s_ack           <= '1';
       
               cmd_start               <= '0';
               cmd_stop                <= '0';

--            ---------------------------------------------------------------------------------
--            -- Address Card Specific
--                  
--            when FST_ST_FB_ADDR     |
--                 ON_BIAS_ADDR       |
--                 OFF_BIAS_ADDR      |
--                 ROW_MAP_ADDR       |
--
--            ---------------------------------------------------------------------------------
--            -- Readout Card Specific
--   
--                 SA_BIAS_ADDR       |
--                 OFFSET_ADDR        |
--                 FILT_COEF_ADDR     |
--                 COL_MAP_ADDR       |
--                 ENBL_SERVO_ADDR    |
--                 COL_ENBL_ADDR      |
--
--                 GAINP0_ADDR        |
--                 GAINP1_ADDR        |
--                 GAINP2_ADDR        |
--                 GAINP3_ADDR        |
--                 GAINP4_ADDR        |
--                 GAINP5_ADDR        |
--                 GAINP6_ADDR        |
--                 GAINP7_ADDR        |
--                 GAINI0_ADDR        |
--                 GAINI1_ADDR        |
--                 GAINI2_ADDR        |
--                 GAINI3_ADDR        |
--                 GAINI4_ADDR        |
--                 GAINI5_ADDR        |
--                 GAINI6_ADDR        |
--                 GAINI7_ADDR        |
--                 ZERO0_ADDR         |
--                 ZERO1_ADDR         |
--                 ZERO2_ADDR         |
--                 ZERO3_ADDR         |
--                 ZERO4_ADDR         |
--                 ZERO5_ADDR         |
--                 ZERO6_ADDR         |
--                 ZERO7_ADDR         |
--
--                 ---------------------------------------------------------------------------------
--                 -- Bias Card Specific
--                 FLUX_FB_ADDR       |
--                 BIAS_ADDR          |
--
--
--                 DATA_MODE_ADDR     |
--                 STRT_MUX_ADDR      |
--                 ROW_ORDER_ADDR     |
--                 
----                 DBL_BUFF_ADDR      |
--                 ACTV_ROW_ADDR      |
--                 USE_DV_ADDR        |
--
--                 ---------------------------------------------------------------------------------
--                 -- Any Card
--                 STATUS_ADDR        |
--                 RST_WTCHDG_ADDR    |
--                 RST_REG_ADDR       |
--                 EEPROM_ADDR        |
--                 VFY_EEPROM_ADDR    |
--                 CLR_ERROR_ADDR     |
--                 EEPROM_SRT_ADDR    |
--                 RESYNC_ADDR        |
--
--                 BIT_STATUS_ADDR    |
--                 FPGA_TEMP_ADDR     |
--                 CARD_TEMP_ADDR     |
--                 CARD_ID_ADDR       |
--                 CARD_TYPE_ADDR     |
--                 SLOT_ID_ADDR       |
--                 FMWR_VRSN_ADDR     |
--                 DIP_ADDR           |
--                 CYC_OO_SYC_ADDR    |
--
--                 ---------------------------------------------------------------------------------
--                 -- Clock Card Specific
--                 CONFIG_S_ADDR      |
--                 CONFIG_ADDR        |
--                 ARRAY_ID_ADDR      |
--                 BOX_ID_ADDR        |
--                 APP_CONFIG_ADDR    |
--                 SRAM1_ADDR         |
--                 VRFY_SRAM1_ADDR    |
--                 SRAM2_ADDR         |
--                 VRFY_SRAM2_ADDR    |
--                 FAC_CONFIG_ADDR    |
--                 SRAM1_CONT_ADDR    |
--                 SRAM2_CONT_ADDR    |
--                 SRAM1_STRT_ADDR    |
--                 SRAM2_STRT_ADDR    |
--
--                 ---------------------------------------------------------------------------------
--                 -- Power Card Specific
--                 PSC_STATUS_ADDR    |
--                 BRST_ADDR          |
--                 PSC_RST_ADDR       |
--                 PSC_OFF_ADDR       =>
--                                  
--               ret_dat_start         <= '0';
--               ret_dat_stop          <= '0';
--                    
--               ret_dat_s_start       <= '0';
--               ret_dat_s_ack         <= '0';
--          
--               cmd_start             <= '1';
--               cmd_stop              <= '0';
--                    
            when others =>

               ret_dat_start         <= '0';
               ret_dat_stop          <= '0';
               
               ret_dat_s_start       <= '0';
               ret_dat_s_ack         <= '0';
          
               cmd_start             <= '1';
               cmd_stop              <= '0';
               
               --error_handler_start <= '1'; -- example what to do if an error occurs
          
         end case;
                 
      else -- if cmd_rdy = '0'

         ret_dat_start         <= '0';
         ret_dat_stop          <= '0';
         
         ret_dat_s_start       <= '0';
         ret_dat_s_ack         <= '0';
            
         cmd_start             <= '0';
         cmd_stop              <= '0';
 
      end if;
      
   end process;
 

--   process(arbiter_ack, simple_cmd_ack, ret_dat_ack, ret_dat_s_ack)
--   begin
--      case arbiter_ack is
--
--         when "001" =>
--            ack_o <= simple_cmd_ack;
--         when "010" =>
--            ack_o <= ret_dat_ack;
--         when "100" =>
--            ack_o <= ret_dat_s_ack;
--         when others =>
--            ack_o <= '0';
--      end case;   
--   end process;
--   
--   arbiter_ack <= ret_dat_s_ack & ret_dat_ack & simple_cmd_ack;

   ack_o <= ret_dat_s_ack or ret_dat_ack or simple_cmd_ack; --ret_dat_stop_ack or 

------------------------------------------------------------------------
--
-- instantiate logic to handle ret_dat command
--
------------------------------------------------------------------------ 

return_data_cmd : cmd_translator_ret_dat_fsm

port map(

     -- global inputs
      rst_i                  => rst_i,
      clk_i                  => clk_i,

      -- inputs from fibre_rx      
      card_addr_i            => card_id_i,      -- specifies which card the command is targetting
      parameter_id_i         => param_id_i,     -- comes from param_id_i, indicates which device(s) the command is targetting
      data_size_i            => num_data_i,     -- data_size_i, indicates number of 16-bit words of data
      data_i                 => cmd_data_i,     -- data will be passed straight thru in 16-bit words
      data_clk_i                 => data_clk_i,                          -- for clocking out the data
      cmd_code_i             => cmd_code_i,
      
      -- other inputs
      sync_pulse_i           => sync_pulse_i,
      sync_number_i          => sync_number_i,   -- a counter of synch pulses 
      ret_dat_start_i        => ret_dat_start,
      ret_dat_stop_i         => ret_dat_stop,
      ret_dat_cmd_valid_o    => ret_dat_cmd_valid,
    
      ret_dat_s_start_i      => ret_dat_s_start,
      ret_dat_s_done_o       => ret_dat_s_done,
 
      -- outputs to the macro-instruction arbiter
      card_addr_o            => ret_dat_cmd_card_addr,    -- specifies which card the command is targetting
      parameter_id_o         => ret_dat_cmd_parameter_id, -- comes from param_id_i, indicates which device(s) the command is targetting
      data_size_o            => ret_dat_cmd_data_size,    -- num_data_i, indicates number of 16-bit words of data
      data_o                 => ret_dat_cmd_data,         -- data will be passed straight thru in 16-bit words
      data_clk_o                   => ret_dat_cmd_data_clk,     -- for clocking out the data
      macro_instr_rdy_o      => ret_dat_cmd_ack,          -- ='1' when the data is valid, else it's '0'
      ret_dat_fsm_working_o  => ret_dat_fsm_working,    
      cmd_type_o             => ret_dat_cmd_type,         -- this is a re-mapping of the cmd_code into a 3-bit number
      cmd_stop_o             => ret_dat_cmd_stop,                    
      last_frame_o           => ret_dat_last_frame,
      
      frame_seq_num_o        => frame_seq_num,
      frame_sync_num_o       => frame_sync_num,    
      
      -- input from the macro-instruction arbiter
      ack_i                  => arbiter_ret_dat_ack,               -- acknowledgment from the micro-instr arbiter that it is ready and has grabbed the data
      ack_o                  => ret_dat_ack
   ); 


------------------------------------------------------------------------
--
-- instantiate logic to handle simple commands
--
------------------------------------------------------------------------ 
 
simple_cmds : cmd_translator_simple_cmd_fsm
 
port map(

     -- global inputs
      rst_i               => rst_i,
      clk_i               => clk_i,

      -- inputs from cmd_translator top level      
      card_addr_i         => card_id_i,       -- specifies which card the command is targetting
      parameter_id_i      => param_id_i,      -- comes from param_id_i, indicates which device(s) the command is targetting
      data_size_i         => num_data_i,      -- data_size_i, indicates number of 16-bit words of data
      data_i              => cmd_data_i,      -- data will be passed straight thru in 16-bit words
      data_clk_i          => data_clk_i,      -- for clocking out the data
      cmd_code_i          => cmd_code_i,
      
      -- other inputs
      sync_pulse_i        => sync_pulse_i,
      cmd_start_i         => cmd_start,
      cmd_stop_i          => cmd_stop,        -- what's this for???
  
      -- outputs to the macro-instruction arbiter
      card_addr_o         => simple_cmd_card_addr,       -- specifies which card the command is targetting
      parameter_id_o      => simple_cmd_parameter_id,    -- comes from param_id_i, indicates which device(s) the command is targetting
      data_size_o         => simple_cmd_data_size,       -- data_size_i, indicates number of 16-bit words of data
      data_o              => simple_cmd_data,            -- data will be passed straight thru in 16-bit words
      data_clk_o          => simple_cmd_data_clk,        -- for clocking out the data
      macro_instr_rdy_o   => simple_cmd_macro_instr_rdy, -- ='1' when the data is valid, else it's '0'
      cmd_type_o          => simple_cmd_type,
      
      -- input from the macro-instruction arbiter
      ack_i              => simple_cmd_ack          -- acknowledgment from the macro-instr arbiter that it is ready and has grabbed the data
   );  
 

arbiter : cmd_translator_arbiter

port map(

     -- global inputs
      rst_i                         => rst_i,
      clk_i                         => clk_i,

      -- inputs from the 'return data' state machine
      ret_dat_frame_seq_num_i       => frame_seq_num,
      ret_dat_frame_sync_num_i      => frame_sync_num,
      
      ret_dat_card_addr_i           => ret_dat_cmd_card_addr,    -- specifies which card the command is targetting
      ret_dat_parameter_id_i        => ret_dat_cmd_parameter_id, -- comes from param_id_i, indicates which device(s) the command is targett_ig
      ret_dat_data_size_i           => ret_dat_cmd_data_size,    -- num_data_i, indicates number of 16-bit words of data
      ret_dat_data_i                => ret_dat_cmd_data ,        -- data will be passed straight thru in 16-bit words
      ret_dat_data_clk_i                =>   ret_dat_cmd_data_clk ,    -- for clocking out the data
      ret_dat_macro_instr_rdy_i     => ret_dat_cmd_ack,          -- ='1' when the data is valid, else it's '0'
      ret_dat_fsm_working_i         => ret_dat_fsm_working, 
      ret_dat_cmd_type_i            => ret_dat_cmd_type,
      ret_dat_cmd_stop_i            => ret_dat_cmd_stop,                    
      ret_dat_last_frame_i          => ret_dat_last_frame,
      
      -- output to the 'return data' state machine
      ret_dat_ack_o                 => arbiter_ret_dat_ack ,     -- acknowledgment from the macro-instr arbiter that it is ready and has grabbed the data

      -- inputs from the 'simple commands' state machine
      simple_cmd_card_addr_i        => simple_cmd_card_addr,     -- specifies which card the command is targetting
      simple_cmd_parameter_id_i     => simple_cmd_parameter_id,  -- comes from param_id_i, indicates which device(s) the command is targetting
      simple_cmd_data_size_i        => simple_cmd_data_size,     -- data_size_i, indicates number of 16-bit words of data
      simple_cmd_data_i             => simple_cmd_data,          -- data will be passed straight thru in 16-bit words
      simple_cmd_data_clk_i         => simple_cmd_data_clk,      -- for clocking out the data
      simple_cmd_macro_instr_rdy_i  => simple_cmd_macro_instr_rdy, -- ='1' when the data is valid, else it's '0'
      simple_cmd_type_i             => simple_cmd_type, 
      
      -- output to simple cmd fsm
      simple_cmd_ack_o              => simple_cmd_ack, 
      sync_number_i                 => sync_number_i,

      -- outputs to the micro instruction sequence generator
      m_op_seq_num_o                => m_op_seq_num_o,
      frame_seq_num_o               => frame_seq_num_o,
      frame_sync_num_o              => frame_sync_num_o,
      
      -- outputs to the cmd_queue (micro-instruction generator)
      card_addr_o                   => card_addr,               -- specifies which card the command is targetting
      parameter_id_o                => parameter_id,            -- comes from param_id_i, indicates which device(s) the command is targetting
      data_size_o                   => data_size_o,             -- num_data_i, indicates number of 16-bit words of data
      data_o                        => data_o,                  -- data will be passed straight thru in 16-bit words
      data_clk_o                     => data_clk_o ,             -- for clocking out the data
      macro_instr_rdy_o             => macro_instr_rdy,         -- ='1' when the data is valid, else it's '0'
      cmd_type_o                    => cmd_type_o,
      cmd_stop_o                    => cmd_stop_o,                    
      last_frame_o                  => last_frame_o,
      
      -- input from the micro-instruction generator
      ack_i                         => ack_i                    -- acknowledgment from the micro-instr arbiter that it is ready and has grabbed the data

   ); 
      
   -- outputs to the reply_translator
   reply_cmd_rcvd_er_o <= cksum_err_i;
   reply_cmd_rcvd_ok_o <= cmd_rdy_i;
   reply_cmd_code_o    <= cmd_code_i;
   reply_param_id_o    <= param_id_i;
   reply_card_id_o     <= card_id_i;   
   
   macro_instr_rdy_o   <= macro_instr_rdy;
   card_addr_o         <= card_addr;
   parameter_id_o      <= parameter_id;
   
------------------------------------------------------------------------
--
-- macro-op storage/retire buffer
--
------------------------------------------------------------------------ 
-- not implementing this for first delivery


end rtl; 