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
-- <revision control keyword substitutions e.g. $Id: cmd_translator.vhd,v 1.2 2004/06/03 23:39:39 jjacob Exp $>
--
-- Project:	      SCUBA-2
-- Author:	       Jonathan Jacob
--
-- Organisation:  UBC
--
-- Description:  This module is the fibre command translator. 
-- 
-- 
--
-- Revision history:
-- 
-- <date $Date: 2004/06/03 23:39:39 $>	-		<text>		- <initials $Author: jjacob $>
--
-- $Log: cmd_translator.vhd,v $
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

library sys_param;
use sys_param.wishbone_pack.all;
use sys_param.general_pack.all;


entity cmd_translator is

--generic(cmd_translator_ADDR               : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := EEPROM_ADDR  );

port(

     -- global inputs

      rst_i        : in     std_logic;
      clk_i        : in     std_logic;

      -- inputs from fibre_rx      

      card_addr_i  : in    std_logic_vector (7 downto 0);    -- specifies which card the command is targetting
      cmd_code_i   : in    std_logic_vector (15 downto 0);   -- the least significant 16-bits from the fibre packet
      cmd_data_i   : in    std_logic_vector (31 downto 0);   -- the data
      --cksum_err_i  : in    std_logic;
      cmd_rdy_i    : in    std_logic;                        -- indicates the fibre_rx outputs are valid
      data_clk_i   : in    std_logic;                        -- used to clock the data out
      num_data_i   : in    std_logic_vector (7 downto 0);    -- number of 16-bit data words to be clocked out
      reg_addr_i   : in    std_logic_vector (23 downto 0);   -- the parameter ID
      
      -- other inputs
      sync_pulse_i : in    std_logic;
      sync_number_i: in    std_logic_vector (7 downto 0);
     
      -- signals from the arbiter, to micro-op  sequence generator )
      ack_o         :  out std_logic;     -- RENAME to cmd_rdy_o                                     -- ready signal
      card_addr_o       :  out std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      parameter_id_o    :  out std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);     -- comes from reg_addr_i, indicates which device(s) the command is targetting
      data_size_o       :  out std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);  -- num_data_i, indicates number of 16-bit words of data
      data_o            :  out std_logic_vector (DATA_BUS_WIDTH-1 downto 0);        -- data will be passed straight thru
      data_clk_o        :  out std_logic;
      macro_instr_rdy_o :  out std_logic;


      -- outputs to reply_translator for commands that require quick acknowldgements
      reply_cmd_ack_o         : out std_logic;                                          -- for commands that require an acknowledge before the command executes
      reply_card_addr_o       : out std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      reply_parameter_id_o    : out std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);     -- comes from reg_addr_i, indicates which device(s) the command is targetting
      reply_data_size_o       : out std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);  -- num_data_i, indicates number of 16-bit words of data
      reply_data_o            : out std_logic_vector (DATA_BUS_WIDTH-1 downto 0)  ;      -- data will be passed straight thru
      
      ack_i             : in std_logic


   ); 
     
end cmd_translator;


architecture rtl of cmd_translator is

--   signal frame_num   : std_logic_vector (MAX_FRAMES-1 downto 0);
--   signal macro_instr : std_logic_vector (63 downto 0);
   
   --signal cmd_mux_sel : std_logic;
   
   -- signals to ret_dat state machine
   signal ret_dat_start : std_logic;
   signal ret_dat_stop  : std_logic;
   signal ret_dat_ack   : std_logic;
   signal ret_dat_cmd_valid : std_logic;
   

   signal frame_seq_num   : std_logic_vector(31 downto 0);
   signal frame_sync_num  : std_logic_vector (7 downto 0);
   
   
   signal ret_dat_s_start : std_logic;
   signal ret_dat_s_done  : std_logic;
      

   -- signals to state machine controlling rest of the commands
   signal cmd_start   : std_logic;
   signal cmd_stop    : std_logic;
   signal cmd_ack     : std_logic;
   
   -- signals to state machine controlling non-existent parameter ID (error)
   signal error_handler_start   : std_logic;
   signal error_handler_stop    : std_logic;
   signal error_handler_ack     : std_logic;
   

--   -- outputs from the "simple commands" state machine
--   signal simple_cmd_card_addr       : std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
--   signal simple_cmd_parameter_id    : std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);     -- comes from reg_addr_i, indicates which device(s) the command is targetting
--   signal simple_cmd_data_size       : std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);  -- num_data_i, indicates number of 16-bit words of data
--   signal simple_cmd_data            : std_logic_vector (DATA_BUS_WIDTH-1 downto 0);       -- data will be passed straight thru
--   signal simple_cmd_data_clk        : std_logic;
--   signal simple_cmd_macro_instr_rdy : std_logic;
--   signal simple_cmd_ack             : std_logic;


   -- signals to the arbiter, (then to micro-op  sequence generator )
   signal ret_dat_cmd_ack         :  std_logic;                                          -- ready signal
   signal ret_dat_cmd_card_addr       :  std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
   signal ret_dat_cmd_parameter_id    :  std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);     -- comes from reg_addr_i, indicates which device(s) the command is targetting
   signal ret_dat_cmd_data_size       :  std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);  -- num_data_i, indicates number of 16-bit words of data
   signal ret_dat_cmd_data            :  std_logic_vector (DATA_BUS_WIDTH-1 downto 0);        -- data will be passed straight thru
   signal ret_dat_cmd_data_clk        :  std_logic;

   -- signals to the arbiter, (then to micro-op  sequence generator )
   signal simple_cmd_ack         :  std_logic;                                          -- ready signal
   signal simple_cmd_card_addr       :  std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
   signal simple_cmd_parameter_id    :  std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);     -- comes from reg_addr_i, indicates which device(s) the command is targetting
   signal simple_cmd_data_size       :  std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);  -- num_data_i, indicates number of 16-bit words of data
   signal simple_cmd_data            :  std_logic_vector (DATA_BUS_WIDTH-1 downto 0);        -- data will be passed straight thru
   signal simple_cmd_data_clk        :  std_logic;
   signal simple_cmd_macro_instr_rdy :  std_logic;

   signal m_op_seq_num               :  std_logic_vector( 7 downto 0);


   --signal sync_number : std_logic_vector (7 downto 0);

   constant START_CMD : std_logic_vector (15 downto 0) := x"474F";
   constant STOP_CMD  : std_logic_vector (15 downto 0) := x"5354";



component cmd_translator_simple_cmd_fsm

port(

     -- global inputs

      rst_i        : in     std_logic;
      clk_i        : in     std_logic;

      -- inputs from cmd_translator top level      

      card_addr_i       : in std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      parameter_id_i    : in std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);     -- comes from reg_addr_i, indicates which device(s) the command is targetting
      data_size_i       : in std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);  -- data_size_i, indicates number of 16-bit words of data
      data_i            : in std_logic_vector (DATA_BUS_WIDTH-1 downto 0);       -- data will be passed straight thru in 16-bit words
      data_clk_i        : in std_logic;							                         -- for clocking out the data
      
      -- other inputs
      sync_pulse_i    : in std_logic;
      cmd_start_i : in std_logic;
      cmd_stop_i  : in std_logic;
  
      -- outputs to the macro-instruction arbiter
      card_addr_o       : out std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      parameter_id_o    : out std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);     -- comes from reg_addr_i, indicates which device(s) the command is targetting
      data_size_o       : out std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);  -- data_size_i, indicates number of 16-bit words of data
      data_o            : out std_logic_vector (DATA_BUS_WIDTH-1 downto 0);       -- data will be passed straight thru in 16-bit words
      data_clk_o        : out std_logic;							                          -- for clocking out the data
      macro_instr_rdy_o : out std_logic;                                          -- ='1' when the data is valid, else it's '0'
      

      
 
      -- input from the macro-instruction arbiter
      ack_i             : in std_logic                   -- acknowledgment from the micro-instr arbiter that it is ready and has grabbed the data

      -- outputs to the reply_translator block
      
      

   ); 

end component;



component cmd_translator_ret_dat_fsm

port(

     -- global inputs

      rst_i        : in     std_logic;
      clk_i        : in     std_logic;

      -- inputs from fibre_rx      

      card_addr_i       : in std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      parameter_id_i    : in std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);     -- comes from reg_addr_i, indicates which device(s) the command is targetting
      data_size_i       : in std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);  -- data_size_i, indicates number of 16-bit words of data
      data_i            : in std_logic_vector (DATA_BUS_WIDTH-1 downto 0);       -- data will be passed straight thru in 16-bit words
      data_clk_i        : in std_logic;							                         -- for clocking out the data
      
      -- other inputs
      sync_pulse_i    : in std_logic;
      sync_number_i   : in std_logic_vector (7 downto 0);    -- a counter of synch pulses 
      ret_dat_start_i : in std_logic;
      ret_dat_stop_i  : in std_logic;
      
      ret_dat_cmd_valid_o     : out std_logic;
    
      ret_dat_s_start_i       : in std_logic;
      ret_dat_s_done_o        : out std_logic; 
      
      -- outputs to the macro-instruction arbiter
      card_addr_o       : out std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      parameter_id_o    : out std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);     -- comes from reg_addr_i, indicates which device(s) the command is targetting
      data_size_o       : out std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);  -- num_data_i, indicates number of 16-bit words of data
      data_o            : out std_logic_vector (DATA_BUS_WIDTH-1 downto 0);       -- data will be passed straight thru in 16-bit words
      data_clk_o        : out std_logic;							                          -- for clocking out the data
      macro_instr_rdy_o : out std_logic;                                          -- ='1' when the data is valid, else it's '0'
      
     frame_seq_num_o       : out std_logic_vector (31 downto 0);
     frame_sync_num_o        : out std_logic_vector (7 downto 0);      
 
      -- input from the macro-instruction arbiter
      ack_i             : in std_logic                   -- acknowledgment from the micro-instr arbiter that it is ready and has grabbed the data

      -- outputs to the reply_translator block
      
 
   ); 
     
end component;



component cmd_translator_arbiter

port(

     -- global inputs

      rst_i        : in     std_logic;
      clk_i        : in     std_logic;
      

      -- inputs from the 'return data' state machine
      ret_dat_frame_seq_num_i       : in std_logic_vector (31 downto 0);
      ret_dat_frame_sync_num_i        : in std_logic_vector (7 downto 0);
      
      ret_dat_card_addr_i       : in std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      ret_dat_parameter_id_i    : in std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);     -- comes from reg_addr_i, indicates which device(s) the command is targett_ig
      ret_dat_data_size_i       : in std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);  -- num_data_i, indicates number of 16-bit words of data
      ret_dat_data_i            : in std_logic_vector (DATA_BUS_WIDTH-1 downto 0);       -- data will be passed straight thru in 16-bit words
      ret_dat_data_clk_i        : in std_logic;							                          -- for clocking out the data
      ret_dat_macro_instr_rdy_i : in std_logic;                                          -- ='1' when the data is valid, else it's '0'
      
 
      -- output to the 'return data' state machine
      ret_dat_ack_o             : out std_logic;                   -- acknowledgment from the macro-instr arbiter that it is ready and has grabbed the data



      -- inputs from the 'simple commands' state machine
      simple_cmd_card_addr_i       : in std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      simple_cmd_parameter_id_i    : in std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);     -- comes from reg_addr_i, indicates which device(s) the command is targetting
      simple_cmd_data_size_i       : in std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);  -- data_size_i, indicates number of 16-bit words of data
      simple_cmd_data_i            : in std_logic_vector (DATA_BUS_WIDTH-1 downto 0);       -- data will be passed straight thru in 16-bit words
      simple_cmd_data_clk_i        : in std_logic;							                                   -- for clocking out the data
      simple_cmd_macro_instr_rdy_i : in std_logic;                                          -- ='1' when the data is valid, else it's '0'
      
 
      -- input from the macro-instruction arbiter
      simple_cmd_ack_o             : out std_logic ;  


      -- outputs to the micro instruction sequence generator
      m_op_seq_num_o        : out std_logic_vector ( 7 downto 0);
      frame_seq_num_o       : out std_logic_vector (31 downto 0);
      frame_sync_num_o        : out std_logic_vector (7 downto 0);
      
      -- outputs to the micro-instruction generator
      card_addr_o       : out std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      parameter_id_o    : out std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);     -- comes from reg_addr_i, indicates which device(s) the command is targetting
      data_size_o       : out std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);  -- num_data_i, indicates number of 16-bit words of data
      data_o            : out std_logic_vector (DATA_BUS_WIDTH-1 downto 0);       -- data will be passed straight thru in 16-bit words
      data_clk_o        : out std_logic;							                          -- for clocking out the data
      macro_instr_rdy_o : out std_logic;                                          -- ='1' when the data is valid, else it's '0'
      
 
      -- input from the micro-instruction arbiter
      ack_i             : in std_logic                   -- acknowledgment from the micro-instr arbiter that it is ready and has grabbed the data

   ); 
     
end component;






begin


------------------------------------------------------------------------
--
-- logic for routing incoming de-composed fibre commands
--
------------------------------------------------------------------------

   

--   card_addr       <= card_addr_i;
--   parameter_id    <= reg_addr_i;
--   data_size       <= data_size;
--   data            <= cmd_data_i;
--                     
--   data_clk        <= data_clk_i;   

         

   process (cmd_rdy_i, reg_addr_i, cmd_code_i 
             
            )
            
   begin
   
--      reply_cmd_ack_o          <= '0';
--      reply_card_addr_o        <= (others => '0');
--      reply_parameter_id_o     <= (others => '0');
--      reply_data_size_o        <= (others => '0');
--      reply_data_o             <= (others => '0');
   

      if cmd_rdy_i = '1' then
 
         case reg_addr_i(7 downto 0) is  -- this is the parameter ID
            
         ---------------------------------------------------------------------------------
         -- System
            when RET_DAT_ADDR       => -- gets broken up into multiple macro-ops
               
               if cmd_code_i = START_CMD then
               
--                  reply_card_addr_o       <= card_addr_i;
--                  reply_parameter_id_o    <= reg_addr_i;
--                  reply_data_size_o       <= num_data_i;
--                  reply_data_o            <= cmd_data_i;
--                     
--                  data_clk_o        <= data_clk_i;


                  ret_dat_start <= '1';
                  ret_dat_stop  <= '0';
                  
                  ret_dat_s_start       <= '0';
                     
                  cmd_start   <= '0';
                  cmd_stop    <= '0';
                  
                  error_handler_start  <= '0';
                  error_handler_stop   <= '0';
                  

                  
                     
               else -- assume it's a stop command (STOP_CMD)
                  
--                  reply_card_addr_o       <= card_addr_i;
--                  reply_parameter_id_o    <= reg_addr_i;
--                  reply_data_size_o       <= num_data_i;
--                  reply_data_o            <= cmd_data_i;
--                     
--                  data_clk_o        <= data_clk_i;

                  ret_dat_start <= '0';
                  ret_dat_stop  <= '1';
                  
                  ret_dat_s_start       <= '0';
                     
                  cmd_start <= '0';
                  cmd_stop  <= '0';
                  
                  error_handler_start  <= '0';
                  error_handler_stop   <= '0';
                     
               end if;   
               
--                  ack_o          <= ret_dat_cmd_ack;
--                  card_addr_o    <= ret_dat_cmd_card_addr;
--                  parameter_id_o <= ret_dat_cmd_parameter_id;
--                  data_size_o    <= ret_dat_cmd_data_size;  
--                  data_o         <= ret_dat_cmd_data; 
--                  data_clk_o     <= ret_dat_cmd_data_clk;
               
            when RET_DAT_S_ADDR     =>
            
               
            
               ret_dat_start <= '0';
               ret_dat_stop  <= '0';
               
               
               ret_dat_s_start       <= '1';
               
--               card_addr       <= card_addr_i;
--               parameter_id    <= reg_addr_i;
--               data_size       <= num_data_i;
--               data            <= cmd_data_i;
--                   
--               data_clk        <= data_clk_i;
               
               
               
               -- the start and stop frame are only set here
--               ret_dat_s_start_frame <= ;
--               ret_dat_s_stop_frame  <= ;
               
               
               reply_cmd_ack_o          <= '0';
               reply_card_addr_o        <= (others => '0');
               reply_parameter_id_o     <= (others => '0');
               reply_data_size_o        <= (others => '0');
               reply_data_o             <= (others => '0');

                     
               cmd_start <= '0';
               cmd_stop  <= '0';
                  
               error_handler_start  <= '0';
               error_handler_stop   <= '0';
               
--                  ack_o          <= ret_dat_cmd_ack;
--                  card_addr_o    <= ret_dat_cmd_card_addr;
--                  parameter_id_o <= ret_dat_cmd_parameter_id;
--                  data_size_o    <= ret_dat_cmd_data_size;  
--                  data_o         <= ret_dat_cmd_data; 
--                  data_clk_o     <= ret_dat_cmd_data_clk;
               
                     
            ---------------------------------------------------------------------------------
            -- Address Card Specific
                  
            when FST_ST_FB_ADDR     |
                 ON_BIAS_ADDR       |
                 OFF_BIAS_ADDR      |
                 ROW_MAP_ADDR       |

            ---------------------------------------------------------------------------------
            -- Readout Card Specific
   
                 SA_BIAS_ADDR       |
                 OFFSET_ADDR        |
                 FILT_COEF_ADDR     |
                 COL_MAP_ADDR       |
                 ENBL_SERVO_ADDR    |
                 COL_ENBL_ADDR      |

                 GAINP0_ADDR        |
                 GAINP1_ADDR        |
                 GAINP2_ADDR        |
                 GAINP3_ADDR        |
                 GAINP4_ADDR        |
                 GAINP5_ADDR        |
                 GAINP6_ADDR        |
                 GAINP7_ADDR        |
                 GAINI0_ADDR        |
                 GAINI1_ADDR        |
                 GAINI2_ADDR        |
                 GAINI3_ADDR        |
                 GAINI4_ADDR        |
                 GAINI5_ADDR        |
                 GAINI6_ADDR        |
                 GAINI7_ADDR        |
                 ZERO0_ADDR         |
                 ZERO1_ADDR         |
                 ZERO2_ADDR         |
                 ZERO3_ADDR         |
                 ZERO4_ADDR         |
                 ZERO5_ADDR         |
                 ZERO6_ADDR         |
                 ZERO7_ADDR         |

                 ---------------------------------------------------------------------------------
                 -- Bias Card Specific
                 FLUX_FB_ADDR       |
                 BIAS_ADDR          |


                 DATA_MODE_ADDR     |
                 STRT_MUX_ADDR      |
                 ROW_ORDER_ADDR     |
                 
                 DBL_BUFF_ADDR      |
                 ACTV_ROW_ADDR      |
                 USE_DV_ADDR        |

                 ---------------------------------------------------------------------------------
                 -- Any Card
                 STATUS_ADDR        |
                 RST_WTCHDG_ADDR    |
                 RST_REG_ADDR       |
                 EEPROM_ADDR        |
                 VFY_EEPROM_ADDR    |
                 CLR_ERROR_ADDR     |
                 EEPROM_SRT_ADDR    |
                 RESYNC_ADDR        |

                 BIT_STATUS_ADDR    |
                 FPGA_TEMP_ADDR     |
                 CARD_TEMP_ADDR     |
                 CARD_ID_ADDR       |
                 CARD_TYPE_ADDR     |
                 SLOT_ID_ADDR       |
                 FMWR_VRSN_ADDR     |
                 DIP_ADDR           |
                 CYC_OO_SYC_ADDR    |

                 ---------------------------------------------------------------------------------
                 -- Clock Card Specific
                 CONFIG_S_ADDR      |
                 CONFIG_ADDR        |
                 ARRAY_ID_ADDR      |
                 BOX_ID_ADDR        |
                 APP_CONFIG_ADDR    |
                 SRAM1_ADDR         |
                 VRFY_SRAM1_ADDR    |
                 SRAM2_ADDR         |
                 VRFY_SRAM2_ADDR    |
                 FAC_CONFIG_ADDR    |
                 SRAM1_CONT_ADDR    |
                 SRAM2_CONT_ADDR    |
                 SRAM1_STRT_ADDR    |
                 SRAM2_STRT_ADDR    |

                 ---------------------------------------------------------------------------------
                 -- Power Card Specific
                 PSC_STATUS_ADDR    |
                 BRST_ADDR          |
                 PSC_RST_ADDR       |
                 PSC_OFF_ADDR       =>
                       
--                    reply_card_addr_o       <= card_addr_i;           -- pass thru
--     		    reply_parameter_id_o    <= reg_addr_i;             
--     		    reply_data_size_o       <= num_data_i;            -- pass the "16-bit word" data size thru
--                    reply_data_o            <= cmd_data_i;            --  16 bit chunks
--  		    
-- 		    data_clk_o        <= data_clk_i;

--                                      ack_o          <= simple_cmd_ack;
--                  card_addr_o    <=  simple_cmd_card_addr;
--                  parameter_id_o <= simple_cmd_parameter_id;
--                  data_size_o    <= simple_cmd_data_size;  
--                  data_o         <= simple_cmd_data; 
--                  data_clk_o     <= simple_cmd_data_clk;
 		    
 		    ret_dat_start <= '0';
                    ret_dat_stop  <= '0';
                    
                    ret_dat_s_start       <= '0';
 		    
 		    cmd_start <= '1';
                    cmd_stop  <= '0';
                    
                    error_handler_start  <= '0';
                    error_handler_stop   <= '0';
         
            when others =>

--               reply_card_addr_o       <= card_addr_i;           -- pass thru
--     	         reply_parameter_id_o    <= reg_addr_i;             
--        	      reply_data_size_o       <= num_data_i;            -- pass the "16-bit word" data size thru
--        	      reply_data_o            <= cmd_data_i;            --  16 bit chunks
--  		       
-- 	         data_clk_o        <= data_clk_i;
 		     		    
 	       ret_dat_start <= '0';
               ret_dat_stop  <= '0';
               
               ret_dat_s_start       <= '0';
 		    
               cmd_start <= '0';
               cmd_stop  <= '0';
               
               error_handler_start  <= '1'; 
               error_handler_stop   <= '0';
               
               
               --FIX THIS, don't route "simple" cmds for default
--                                 ack_o          <= simple_cmd_ack;
--                  card_addr_o    <=  simple_cmd_card_addr;
--                  parameter_id_o <= simple_cmd_parameter_id;
--                  data_size_o    <= simple_cmd_data_size;  
--                  data_o         <= simple_cmd_data; 
--                  data_clk_o     <= simple_cmd_data_clk;
                    
         end case;
                 
      else
      
--         reply_card_addr_o       <= card_addr_i;
--         reply_parameter_id_o    <= reg_addr_i;
--         reply_data_size_o       <= data_size;
--         reply_data_o            <= cmd_data_i;
--         data_clk_o        <= data_clk_i;
            
         ret_dat_start <= '0';
         ret_dat_stop  <= '0';
         
         ret_dat_s_start       <= '0';
            
         cmd_start <= '0';
         cmd_stop  <= '0';
         
         error_handler_start  <= '0';
         error_handler_stop   <= '0';
         
                       --FIX THIS, don't route "simple" cmds for default
--                                 ack_o          <= simple_cmd_ack;
--                  card_addr_o    <=  simple_cmd_card_addr;
--                  parameter_id_o <= simple_cmd_parameter_id;
--                  data_size_o    <= simple_cmd_data_size;  
--                  data_o         <= simple_cmd_data; 
--                  data_clk_o     <= simple_cmd_data_clk;
         
      end if;
      
   end process;
 



------------------------------------------------------------------------
--
-- routing mux for the output
--
------------------------------------------------------------------------ 

--   process()
--   begin
--      case cmd_select is
--         when RET_DAT_S_ADDR | RET_DAT_ADDR =>
-- 
--         when 
--   
--   end process;
--
--ack_o <= ret_dat_cmd_ack    when cmd_select = RET_DAT_S_ADDR else
--         ret_dat_cmd_ack    when cmd_select = RET_DAT_ADDR else
--         simple_cmds_ack;
--
--
--simple_cmd_ack         :  std_logic;                                          -- ready signal
--   signal simple_cmd_card_addr       :  std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
--   signal simple_cmd_parameter_id    :  std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);     -- comes from reg_addr_i, indicates which device(s) the command is targetting
--   signal simple_cmd_data_size       :  std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);  -- num_data_i, indicates number of 16-bit words of data
--   signal simple_cmd_data            :  std_logic_vector (DATA_BUS_WIDTH-1 downto 0);        -- data will be passed straight thru
--   signal simple_cmd_data_clk
--
-- 
------------------------------------------------------------------------
--
-- instantiate logic to handle ret_dat command
--
------------------------------------------------------------------------ 

return_data_cmd : cmd_translator_ret_dat_fsm

port map(

     -- global inputs

      rst_i        => rst_i,
      clk_i        => clk_i,

      -- inputs from fibre_rx      

      card_addr_i      => card_addr_i,  -- specifies which card the command is targetting
      parameter_id_i    => reg_addr_i,      -- comes from reg_addr_i, indicates which device(s) the command is targetting
      data_size_i        => num_data_i,-- data_size_i, indicates number of 16-bit words of data
      data_i              => cmd_data_i,    -- data will be passed straight thru in 16-bit words
      data_clk_i        		=> data_clk_i,	                         -- for clocking out the data
      
      -- other inputs
      sync_pulse_i     => sync_pulse_i,
      sync_number_i      => sync_number_i, -- a counter of synch pulses 
      ret_dat_start_i => ret_dat_start,
      ret_dat_stop_i  => ret_dat_stop,
      ret_dat_cmd_valid_o => ret_dat_cmd_valid,
    
      ret_dat_s_start_i       => ret_dat_s_start,
      ret_dat_s_done_o        => ret_dat_s_done,
      

      -- outputs to the macro-instruction arbiter
      card_addr_o         => ret_dat_cmd_card_addr,-- specifies which card the command is targetting
      parameter_id_o      => ret_dat_cmd_parameter_id, -- comes from reg_addr_i, indicates which device(s) the command is targetting
      data_size_o         => ret_dat_cmd_data_size,-- num_data_i, indicates number of 16-bit words of data
      data_o               => ret_dat_cmd_data,  -- data will be passed straight thru in 16-bit words
      data_clk_o        			=> ret_dat_cmd_data_clk,	                          -- for clocking out the data
      macro_instr_rdy_o      => ret_dat_cmd_ack,                                 -- ='1' when the data is valid, else it's '0'
      
      frame_seq_num_o       => frame_seq_num,
      frame_sync_num_o      => frame_sync_num,    
      
 
      -- input from the macro-instruction arbiter
      ack_i              => ret_dat_ack               -- acknowledgment from the micro-instr arbiter that it is ready and has grabbed the data

      -- outputs to the reply_translator block
      
      

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

      card_addr_i         => card_addr_i,     -- specifies which card the command is targetting
      parameter_id_i      => reg_addr_i,      -- comes from reg_addr_i, indicates which device(s) the command is targetting
      data_size_i         => num_data_i,      -- data_size_i, indicates number of 16-bit words of data
      data_i              => cmd_data_i,      -- data will be passed straight thru in 16-bit words
      data_clk_i          => data_clk_i,      -- for clocking out the data
      
      -- other inputs
      sync_pulse_i        => sync_pulse_i,
      cmd_start_i         => cmd_start,
      cmd_stop_i          => cmd_stop,        -- what's this for???
  
      -- outputs to the macro-instruction arbiter
      card_addr_o         => simple_cmd_card_addr,       -- specifies which card the command is targetting
      parameter_id_o      => simple_cmd_parameter_id,    -- comes from reg_addr_i, indicates which device(s) the command is targetting
      data_size_o         => simple_cmd_data_size,       -- data_size_i, indicates number of 16-bit words of data
      data_o              => simple_cmd_data,            -- data will be passed straight thru in 16-bit words
      data_clk_o          => simple_cmd_data_clk,        -- for clocking out the data
      macro_instr_rdy_o   => simple_cmd_macro_instr_rdy, -- ='1' when the data is valid, else it's '0'
      

 
      -- input from the macro-instruction arbiter
      ack_i            => simple_cmd_ack          -- acknowledgment from the macro-instr arbiter that it is ready and has grabbed the data

      -- outputs to the reply_translator block
      
      

   );  
 


arbiter : cmd_translator_arbiter

port map(

     -- global inputs

      rst_i     =>  rst_i,
      clk_i      => clk_i,
      

      -- inputs from the 'return data' state machine
      ret_dat_frame_seq_num_i       =>frame_seq_num,
      ret_dat_frame_sync_num_i      =>frame_sync_num,
      
      ret_dat_card_addr_i        => ret_dat_cmd_card_addr,-- specifies which card the command is targetting
      ret_dat_parameter_id_i     =>  ret_dat_cmd_parameter_id ,-- comes from reg_addr_i, indicates which device(s) the command is targett_ig
      ret_dat_data_size_i        => ret_dat_cmd_data_size,-- num_data_i, indicates number of 16-bit words of data
      ret_dat_data_i              =>   ret_dat_cmd_data ,-- data will be passed straight thru in 16-bit words
      ret_dat_data_clk_i        			=>	     ret_dat_cmd_data_clk ,                    -- for clocking out the data
      ret_dat_macro_instr_rdy_i    =>       ret_dat_cmd_ack ,                              -- ='1' when the data is valid, else it's '0'
      
 
      -- output to the 'return data' state machine
      ret_dat_ack_o                 =>    ret_dat_ack ,       -- acknowledgment from the macro-instr arbiter that it is ready and has grabbed the data



      -- inputs from the 'simple commands' state machine
      simple_cmd_card_addr_i        => simple_cmd_card_addr,-- specifies which card the command is targetting
      simple_cmd_parameter_id_i     =>   simple_cmd_parameter_id, -- comes from reg_addr_i, indicates which device(s) the command is targetting
      simple_cmd_data_size_i        => simple_cmd_data_size,-- data_size_i, indicates number of 16-bit words of data
      simple_cmd_data_i             =>   simple_cmd_data, -- data will be passed straight thru in 16-bit words
      simple_cmd_data_clk_i        	=>				simple_cmd_data_clk,                                   -- for clocking out the data
      simple_cmd_macro_instr_rdy_i   =>       simple_cmd_macro_instr_rdy,                              -- ='1' when the data is valid, else it's '0'
      
 
      -- output to simple cmd fsm
      simple_cmd_ack_o              =>simple_cmd_ack,


      -- outputs to the micro instruction sequence generator
      m_op_seq_num_o        =>m_op_seq_num,
      frame_seq_num_o       =>frame_seq_num,
      frame_sync_num_o       =>frame_sync_num,
      
      -- outputs to the micro-instruction generator
      card_addr_o        => card_addr_o,-- specifies which card the command is targetting
      parameter_id_o      => parameter_id_o,-- comes from reg_addr_i, indicates which device(s) the command is targetting
      data_size_o        => data_size_o,-- num_data_i, indicates number of 16-bit words of data
      data_o                 =>  data_o,-- data will be passed straight thru in 16-bit words
      data_clk_o       				=>data_clk_o	,                          -- for clocking out the data
      macro_instr_rdy_o         =>    macro_instr_rdy_o  ,                            -- ='1' when the data is valid, else it's '0'
      
 
      -- input from the micro-instruction generator
      ack_i                     =>      ack_i     -- acknowledgment from the micro-instr arbiter that it is ready and has grabbed the data

   ); 
     


      
end rtl;


--  ---------------------------------------------------------------------------------
--   -- Address Card Specific
--                  
--               when ON_BIAS_ADDR       =>
--               when OFF_BIAS_ADDR      =>
--               when ROW_MAP_ADDR       =>
--
--   ---------------------------------------------------------------------------------
--   -- Readout Card Specific
--   
--               when FST_ST_FB_ADDR     =>
--   
--               when FST_ST_FB_ADDR     =>
--   
--               when SA_BIAS_ADDR       =>
--               when OFFSET_ADDR        =>
--               when FILT_COEF_ADDR     =>
--               when COL_MAP_ADDR       =>
--               when ENBL_SERVO_ADDR    =>
--               when COL_ENBL_ADDR      =>
--
--               when GAINP0_ADDR        =>
--               when GAINP1_ADDR        =>
--               when GAINP2_ADDR        =>
--               when GAINP3_ADDR        =>
--               when GAINP4_ADDR        =>
--               when GAINP5_ADDR        =>
--               when GAINP6_ADDR        =>
--               when GAINP7_ADDR        =>
--               when GAINI0_ADDR        =>
--               when GAINI1_ADDR        =>
--               when GAINI2_ADDR        =>
--               when GAINI3_ADDR        =>
--               when GAINI4_ADDR        =>
--               when GAINI5_ADDR        =>
--               when GAINI6_ADDR        =>
--               when GAINI7_ADDR        =>
--               when ZERO0_ADDR         =>
--               when ZERO1_ADDR         =>
--               when ZERO2_ADDR         =>
--               when ZERO3_ADDR         =>
--               when ZERO4_ADDR         =>
--               when ZERO5_ADDR         =>
--               when ZERO6_ADDR         =>
--               when ZERO7_ADDR         =>
--
--   ---------------------------------------------------------------------------------
--   -- Bias Card Specific
--               when FLUX_FB_ADDR       =>
--               when BIAS_ADDR          =>
--
--
--               when DATA_MODE_ADDR     =>
--               when STRT_MUX_ADDR      =>
--               when ROW_ORDER_ADDR     =>
--               when RET_DAT_S_ADDR     =>
--               when DBL_BUFF_ADDR      =>
--               when ACTV_ROW_ADDR      =>
--               when USE_DV_ADDR        =>
--
--   ---------------------------------------------------------------------------------
--   -- Any Card
--               when STATUS_ADDR        =>
--               when RST_WTCHDG_ADDR    =>
--               when RST_REG_ADDR       =>
--               when EEPROM_ADDR        =>
--               when VFY_EEPROM_ADDR    =>
--               when CLR_ERROR_ADDR     =>
--               when EEPROM_SRT_ADDR    =>
--               when RESYNC_ADDR        =>
--
--               when BIT_STATUS_ADDR    =>
--               when FPGA_TEMP_ADDR     =>
--               when CARD_TEMP_ADDR     =>
--               when CARD_ID_ADDR       =>
--               when CARD_TYPE_ADDR     =>
--               when SLOT_ID_ADDR       =>
--               when FMWR_VRSN_ADDR     =>
--               when DIP_ADDR           =>
--               when CYC_OO_SYC_ADDR    =>
--
--   ---------------------------------------------------------------------------------
--   -- Clock Card Specific
--               when CONFIG_S_ADDR      =>
--               when CONFIG_ADDR        =>
--               when ARRAY_ID_ADDR      =>
--               when BOX_ID_ADDR        =>
--               when APP_CONFIG_ADDR    =>
--               when SRAM1_ADDR         =>
--               when VRFY_SRAM1_ADDR    =>
--               when SRAM2_ADDR         =>
--               when VRFY_SRAM2_ADDR    =>
--               when FAC_CONFIG_ADDR    =>
--               when SRAM1_CONT_ADDR    =>
--               when SRAM2_CONT_ADDR    =>
--               when SRAM1_STRT_ADDR    =>
--               when SRAM2_STRT_ADDR    =>
--
--   ---------------------------------------------------------------------------------
--   -- Power Card Specific
--               when PSC_STATUS_ADDR    =>
--               when BRST_ADDR          =>
--               when PSC_RST_ADDR       =>
--               when PSC_OFF_ADDR       =>
--