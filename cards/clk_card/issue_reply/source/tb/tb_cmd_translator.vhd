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
-- <revision control keyword substitutions e.g. $Id: tb_cmd_translator.vhd,v 1.2 2004/07/05 23:41:22 jjacob Exp $>
--
-- Project:	      SCUBA-2
-- Author:	       Jonathan Jacob
--
-- Organisation:  UBC
--
-- Description:   
-- 
-- 
--
-- Revision history:
-- 
-- <date $Date: 2004/07/05 23:41:22 $>	-		<text>		- <initials $Author: jjacob $>
--
-- $Log: tb_cmd_translator.vhd,v $
-- Revision 1.2  2004/07/05 23:41:22  jjacob
-- updating
--
-- Revision 1.1  2004/06/23 16:34:50  jjacob
-- I moved the tb_issue_reply testbench into this file.
--
-- Revision 1.2  2004/06/23 16:30:55  jjacob
-- modified for new interface, new bus widths
--
-- Revision 1.1  2004/06/21 17:12:21  jjacob
-- first stable version to test the macro instruction sequence generator.
-- doesn't yet test macro-instruction buffer, doesn't have
-- "quick" acknolwedgements for instructions that require them, no error
-- handling, basically no return path logic yet.  Have implemented ret_dat
-- instructions, and "simple" instructions.  Not all instructions are fully
-- implemented yet.
--
--
-- 
-----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.issue_reply_pack.all;
use work.fibre_rx_pack.all;

library sys_param;
use sys_param.wishbone_pack.all;
use sys_param.general_pack.all;

entity tb_cmd_translator is

port(

     self_check_o    : out std_logic       -- '0' indicates PASS, '1' indicates FAIL

   ); 
   
end tb_cmd_translator;

architecture BEH of tb_cmd_translator is


   component CMD_TRANSLATOR
      port(RST_I            : in std_logic ;
           CLK_I            : in std_logic ;
           CARD_ID_I        : in std_logic_vector (CARD_ADDR_BUS_WIDTH - 1 downto 0 );
           CMD_CODE_I       : in std_logic_vector ( 15 downto 0 );
           CMD_DATA_I       : in std_logic_vector (DATA_BUS_WIDTH - 1 downto 0 );
           CMD_RDY_I        : in std_logic ;
           DATA_CLK_I       : in std_logic ;
           NUM_DATA_I       : in std_logic_vector (DATA_SIZE_BUS_WIDTH - 1 downto 0 );
           PARAM_ID_I       : in std_logic_vector (PAR_ID_BUS_WIDTH - 1 downto 0 );
           SYNC_PULSE_I     : in std_logic ;
           sync_number_i    : in std_logic_vector (7 downto 0);
           ack_o        : out std_logic ;
           CARD_ADDR_O      : out std_logic_vector ( CARD_ADDR_BUS_WIDTH - 1 downto 0 );
           PARAMETER_ID_O   : out std_logic_vector ( PAR_ID_BUS_WIDTH - 1 downto 0 );
           DATA_SIZE_O      : out std_logic_vector ( DATA_SIZE_BUS_WIDTH - 1 downto 0 );
           DATA_O           : out std_logic_vector ( DATA_BUS_WIDTH - 1 downto 0 );
           data_clk_o       :  out std_logic;
           macro_instr_rdy_o :  out std_logic;
           
           -- outputs to the micro instruction sequence generator
           m_op_seq_num_o        : out std_logic_vector ( 7 downto 0);
           frame_seq_num_o       : out std_logic_vector (31 downto 0);
           frame_sync_num_o        : out std_logic_vector (7 downto 0);
 

           reply_cmd_ack_o         : out std_logic;                                          -- for commands that require an acknowledge before the command executes
           reply_card_addr_o       : out std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
           reply_parameter_id_o    : out std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);     -- comes from reg_addr_i, indicates which device(s) the command is targetting
           reply_data_size_o       : out std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);  -- num_data_i, indicates number of 16-bit words of data
           reply_data_o            : out std_logic_vector ( DATA_BUS_WIDTH - 1 downto 0 );
           
           ack_i             : in std_logic
           );

   end component;



   constant PERIOD : time := 20 ns;

   signal W_RST_I            : std_logic ;
   signal W_CLK_I            : std_logic := '0';
   signal W_CARD_ID_I        : std_logic_vector ( CARD_ADDR_BUS_WIDTH - 1 downto 0 );
   signal W_CMD_CODE_I       : std_logic_vector ( 15 downto 0 );
   signal W_CMD_DATA_I       : std_logic_vector ( DATA_BUS_WIDTH - 1 downto 0 );
   signal W_CMD_RDY_I        : std_logic ;
   signal W_DATA_CLK_I       : std_logic ;
   signal W_NUM_DATA_I       : std_logic_vector ( DATA_SIZE_BUS_WIDTH - 1 downto 0 );
   signal W_PARAM_ID_I       : std_logic_vector ( PAR_ID_BUS_WIDTH - 1 downto 0 );
   signal W_SYNC_PULSE_I     : std_logic ;
   signal w_sync_number_i    : std_logic_vector (7 downto 0);
   signal W_ACK_O            : std_logic ;
   signal W_CARD_ADDR_O      : std_logic_vector ( CARD_ADDR_BUS_WIDTH - 1 downto 0 );
   signal W_PARAMETER_ID_O   : std_logic_vector ( PAR_ID_BUS_WIDTH - 1 downto 0 );
   signal W_DATA_SIZE_O      : std_logic_vector ( DATA_SIZE_BUS_WIDTH - 1 downto 0 );
   signal W_DATA_O           : std_logic_vector ( DATA_BUS_WIDTH - 1 downto 0 ) ;
   signal w_data_clk_o       : std_logic;
   signal w_macro_instr_rdy_o :  std_logic;
   signal w_reply_cmd_ack_o       : std_logic ;
   signal w_reply_card_addr_o     : std_logic_vector ( CARD_ADDR_BUS_WIDTH - 1 downto 0 );
   signal w_reply_parameter_id_o  : std_logic_vector ( PAR_ID_BUS_WIDTH - 1 downto 0 );
   signal w_reply_data_size_o     : std_logic_vector ( DATA_SIZE_BUS_WIDTH - 1 downto 0 );
   signal w_reply_data_o          : std_logic_vector ( DATA_BUS_WIDTH - 1 downto 0 ) ;
   --signal w_m_op_seq_num_o          : std_logic_vector (7 downto 0);
   signal w_ret_dat_frame_seq_num_o : std_logic_vector (31 downto 0);
   signal w_ret_dat_frame_sync_num_o: std_logic_vector (7 downto 0);
   signal w_ack_i             : std_logic;
   --signal w_ack_o             : std_logic;
   
   signal w_m_op_seq_num_o        : std_logic_vector ( 7 downto 0);
   signal w_frame_seq_num_o       : std_logic_vector (31 downto 0);
   signal w_frame_sync_num_o      : std_logic_vector (7 downto 0);
   
   signal self_check_flag    : boolean ;
   

begin
------------------------------------------------------------------------
--
-- instantiate command translator
--
------------------------------------------------------------------------
   DUT : CMD_TRANSLATOR
      port map(RST_I            => W_RST_I,
               CLK_I            => W_CLK_I,
               CARD_ID_I      => w_card_id_i,
               CMD_CODE_I       => W_CMD_CODE_I,
               CMD_DATA_I       => W_CMD_DATA_I,
               CMD_RDY_I        => W_CMD_RDY_I,
               DATA_CLK_I       => W_DATA_CLK_I,
               NUM_DATA_I       => W_NUM_DATA_I,
               PARAM_ID_I       => W_PARAM_ID_I,
               SYNC_PULSE_I     => W_SYNC_PULSE_I,
               sync_number_i    => w_sync_number_i,
               ack_o            => W_ACK_O,
               CARD_ADDR_O      => W_CARD_ADDR_O,
               PARAMETER_ID_O   => W_PARAMETER_ID_O,
               DATA_SIZE_O      => W_DATA_SIZE_O,
               DATA_O           => W_DATA_O,
               reply_cmd_ack_o  => w_reply_cmd_ack_o,    
               reply_card_addr_o    => w_reply_card_addr_o,     
               reply_parameter_id_o => w_reply_parameter_id_o,
               reply_data_size_o    => w_reply_data_size_o,
               reply_data_o         => w_reply_data_o, 
               data_clk_o           => w_data_clk_o,
               macro_instr_rdy_o    => w_macro_instr_rdy_o,
               
               m_op_seq_num_o       => w_m_op_seq_num_o,
               frame_seq_num_o      => w_frame_seq_num_o,
               frame_sync_num_o     => w_frame_sync_num_o,
               
               ack_i             => w_ack_i
               --ack_o             => w_ack_o
           
 

--               m_op_seq_num_o           => w_m_op_seq_num_o,
--               ret_dat_frame_seq_num_o  => w_ret_dat_frame_seq_num_o,
--               ret_dat_frame_sync_num_o => w_ret_dat_frame_sync_num_o
               
               );
------------------------------------------------------------------------
--
-- Create a test clock
--
------------------------------------------------------------------------

   w_clk_i <= not w_clk_i after PERIOD/2;

------------------------------------------------------------------------
--
-- Create stimulus
--
------------------------------------------------------------------------

   STIMULI : process
   
------------------------------------------------------------------------
--
-- Procdures for creating stimulus
-- 
--
------------------------------------------------------------------------ 

  
      procedure do_nop is
      begin

         assert self_check_flag report " Performing a NOP." severity NOTE;

         -- global signal      
         W_RST_I            <= '0';

         -- signals from fibre_rx_prototcol_fsm
         w_card_id_i      <= (others => '0'); -- std_logic_vector ( 7 downto 0 );
         W_CMD_CODE_I       <= (others => '0'); -- std_logic_vector ( 15 downto 0 );
         W_CMD_DATA_I       <= (others => '0'); -- std_logic_vector ( 15 downto 0 );
         W_CMD_RDY_I        <= '0';
         W_DATA_CLK_I       <= '0';
         W_NUM_DATA_I       <= (others => '0'); --  std_logic_vector ( 7 downto 0 );
         W_PARAM_ID_I       <= (others => '0'); --  std_logic_vector ( 23 downto 0 );
         
         -- sync pulse
         W_SYNC_PULSE_I     <= '0';
         w_sync_number_i    <= (others => '0');

      
         -- self-check
         self_check_o       <= '0';
         self_check_flag    <= false;
         
         wait for PERIOD;
                 

         
      end do_nop ;
   
------------------------------------------------------------------------    

      procedure do_reset is
      begin
      
         assert self_check_flag report " Performing a RESET." severity NOTE;      

         -- global signal      
         W_RST_I            <= '1';

         -- signals from fibre_rx_prototcol_fsm
         w_card_id_i      <= (others => '0'); -- std_logic_vector ( 7 downto 0 );
         W_CMD_CODE_I       <= (others => '0'); -- std_logic_vector ( 15 downto 0 );
         W_CMD_DATA_I       <= (others => '0'); -- std_logic_vector ( 15 downto 0 );
         W_CMD_RDY_I        <= '0';
         W_DATA_CLK_I       <= '0';
         W_NUM_DATA_I       <= (others => '0'); --  std_logic_vector ( 7 downto 0 );
         W_PARAM_ID_I       <= (others => '0'); --  std_logic_vector ( 23 downto 0 );
         
         -- sync pulse
         W_SYNC_PULSE_I     <= '0';

         -- signal from micro-op sequence generator
         w_ack_i            <= '0';
      
      
         -- self-check
         self_check_o       <= '0';
         self_check_flag    <= false;
         
         wait for PERIOD*3;
         
         -- global signal      
         W_RST_I            <= '0';  

         wait for PERIOD;       
                 
         
         
      end do_reset ;
   
------------------------------------------------------------------------    


      procedure do_simple_cmd is
      begin
      
         assert false report " Performing a simple cmd with 4 words of data." severity NOTE;
         
         -- global signal      
         W_RST_I            <= '0';

         -- signals from fibre_rx_prototcol_fsm
         w_card_id_i        <= x"0003";           -- readout card A
         W_CMD_CODE_I       <= (others => '0'); -- std_logic_vector ( 15 downto 0 );
         W_CMD_DATA_I       <= x"FFFFFFFF";         -- first word of data;
         W_CMD_RDY_I        <= '0';
         W_DATA_CLK_I       <= '0';
         W_NUM_DATA_I       <= (others => '0');      -- std_logic_vector ( 7 downto 0 );
         W_PARAM_ID_I(15 downto 8)      <= (others => '0'); -- bits(23 downto 8)
         W_PARAM_ID_I(7 downto 0)       <= FST_ST_FB_ADDR;  -- bits(7 downto 0)
         
         -- sync pulse
         W_SYNC_PULSE_I     <= '0';

      
         wait for PERIOD*3;
         
         W_CMD_RDY_I        <= '1';
         
         wait for PERIOD*3;
         -- signal from micro-op sequence generator
         w_ack_i            <= '1';
      
         
         wait for PERIOD*3;
         
         W_DATA_CLK_I       <= '1';
         if W_DATA_O = W_CMD_DATA_I and 
            W_CARD_ADDR_O = w_card_id_i and
            W_PARAMETER_ID_O = W_PARAM_ID_I and 
            W_DATA_SIZE_O = W_NUM_DATA_I  then
            
            self_check_o       <= '0';
            self_check_flag    <= false;
            assert false report " Reading 1st word." severity NOTE;
         else
            self_check_o       <= '1';
            self_check_flag    <= true;
            assert false report " FAILED SELF-CHECKING **" severity failure;
         end if;             
--         if W_DATA_O = x"FFFF" then
--            self_check_o       <= '0';
--            self_check_flag    <= false;
--            assert false report " Reading first word." severity NOTE;
--         else
--            self_check_o       <= '1';
--            self_check_flag    <= true;
--            assert false report " FAILED SELF-CHECKING **" severity failure;
--         end if;    
         wait for PERIOD*3;     
         W_DATA_CLK_I       <= '0';
         wait for PERIOD*3;
         
         W_DATA_CLK_I       <= '1';
         W_CMD_DATA_I       <= x"EEEEEEEE";         -- second word of data;
         wait for PERIOD*3;
         
         if W_DATA_O = W_CMD_DATA_I and 
            W_CARD_ADDR_O = w_card_id_i and
            W_PARAMETER_ID_O = W_PARAM_ID_I and 
            W_DATA_SIZE_O = W_NUM_DATA_I  then
            
            self_check_o       <= '0';
            self_check_flag    <= false;
            assert false report " Reading 2nd word." severity NOTE;
         else
            self_check_o       <= '1';
            self_check_flag    <= true;
            assert false report " FAILED SELF-CHECKING **" severity failure;
         end if;     
                 
         W_DATA_CLK_I       <= '0';
         wait for PERIOD*3;
         
         W_DATA_CLK_I       <= '1';
         W_CMD_DATA_I       <= x"DDDDDDDD";         -- third word of data;
         wait for PERIOD*3;
         W_DATA_CLK_I       <= '0';
         
         if W_DATA_O = W_CMD_DATA_I and 
            W_CARD_ADDR_O = w_card_id_i and
            W_PARAMETER_ID_O = W_PARAM_ID_I and 
            W_DATA_SIZE_O = W_NUM_DATA_I  then
            
            self_check_o       <= '0';
            self_check_flag    <= false;
            assert false report " Reading 3rd word." severity NOTE;
         else
            self_check_o       <= '1';
            self_check_flag    <= true;
            assert false report " FAILED SELF-CHECKING **" severity failure;
         end if;         
         
         wait for PERIOD*3;  
         
         W_DATA_CLK_I       <= '1';
         W_CMD_DATA_I       <= x"CCCCCCCC";         -- fourth word of data;
         wait for PERIOD*3;
         
         if W_DATA_O = W_CMD_DATA_I and 
            W_CARD_ADDR_O = w_card_id_i and
            W_PARAMETER_ID_O = W_PARAM_ID_I and 
            W_DATA_SIZE_O = W_NUM_DATA_I  then
            
            self_check_o       <= '0';
            self_check_flag    <= false;
            assert false report " Reading 4th word." severity NOTE;
         else
            self_check_o       <= '1';
            self_check_flag    <= true;
            assert false report " FAILED SELF-CHECKING **" severity failure;
         end if;         
         
         W_DATA_CLK_I       <= '0';
         wait for PERIOD*3;       
         
         -- signal from micro-op sequence generator
         w_ack_i            <= '0';    
         W_CMD_RDY_I        <= '0';

      end do_simple_cmd ;   

------------------------------------------------------------------------




      procedure do_ret_dat_s_cmd is
      begin

         assert false report " Performing a ret_dat_s cmd." severity NOTE;
         assert false report " Setting the START and STOP FRAME sequence number." severity NOTE;

         -- global signal      
         W_RST_I            <= '0';

         -- signals from fibre_rx_prototcol_fsm
         w_card_id_i      <= x"0004";           -- readout card B
         W_CMD_CODE_I       <= (others => '0'); -- std_logic_vector ( 15 downto 0 );
         W_CMD_DATA_I       <= x"0000000A";     -- first word of data;
         W_CMD_RDY_I        <= '0';
         W_DATA_CLK_I       <= '0';
         W_NUM_DATA_I(7 downto 0)       <= "00000010";      -- std_logic_vector ( 7 downto 0 );
         W_NUM_DATA_I(DATA_SIZE_BUS_WIDTH - 1 downto 8)<= (others => '0');
         W_PARAM_ID_I(PAR_ID_BUS_WIDTH - 1 downto 8)      <= (others => '0'); -- bits(23 downto 8)
         W_PARAM_ID_I(7 downto 0)                         <= RET_DAT_S_ADDR;  -- bits(7 downto 0)
         
         -- sync pulse
         W_SYNC_PULSE_I     <= '0';

      
         wait for PERIOD*3;
         
         W_CMD_RDY_I        <= '1';
         
         
--         wait for PERIOD*3;
--         -- signal from micro-op sequence generator
--         w_ack_i            <= '1';    

         
         wait for PERIOD*3;
         
         W_DATA_CLK_I       <= '1';
         
  -- commented this out because this is an internal command, and shouldn't go out to the 
  -- micro sequence generator
         
--         if W_CARD_ADDR_O = W_CARD_ADDR_I and
--            W_PARAMETER_ID_O = W_REG_ADDR_I and W_DATA_SIZE_O = W_NUM_DATA_I  then
--            self_check_o       <= '0';
--            self_check_flag    <= false;
--            assert false report " Reading start sequence frame number." severity NOTE;
--         else
--            self_check_o       <= '1';
--            self_check_flag    <= true;
--            assert false report " FAILED SELF-CHECKING **" severity failure;
--         end if;             
--         if W_DATA_O = x"FFFF" then
--            self_check_o       <= '0';
--            self_check_flag    <= false;
--            assert false report " Reading first word." severity NOTE;
--         else
--            self_check_o       <= '1';
--            self_check_flag    <= true;
--            assert false report " FAILED SELF-CHECKING **" severity failure;
--         end if;    
         wait for PERIOD*3;     
         W_DATA_CLK_I       <= '0';
         wait for PERIOD*3;
         
         W_DATA_CLK_I       <= '1';
         W_CMD_DATA_I       <= x"0000000F";         -- second word of data;
         wait for PERIOD*3;

  -- commented this out because this is an internal command, and shouldn't go out to the 
  -- micro sequence generator
                  
--         if W_CARD_ADDR_O = W_CARD_ADDR_I and
--            W_PARAMETER_ID_O = W_REG_ADDR_I and W_DATA_SIZE_O = W_NUM_DATA_I  then
--            self_check_o       <= '0';
--            self_check_flag    <= false;
--            assert false report " Reading stop sequence frame number." severity NOTE;
--         else
--            self_check_o       <= '1';
--            self_check_flag    <= true;
--            assert false report " FAILED SELF-CHECKING **" severity failure;
--         end if;               
         
         
         W_DATA_CLK_I       <= '0';
         wait for PERIOD*3;
         
         -- signal from micro-op sequence generator
         w_ack_i            <= '0';    
         W_CMD_RDY_I        <= '0'; 
         

      end do_ret_dat_s_cmd ;   


------------------------------------------------------------------------




      procedure do_ret_dat_cmd is
      begin

         assert false report " Performing a ret_dat cmd." severity NOTE;

         -- global signal      
         W_RST_I            <= '0';

         -- signals from fibre_rx_prototcol_fsm
         w_card_id_i      <= x"0004";           -- readout card B
         W_CMD_CODE_I       <= x"474F";     -- "START" command code
         W_CMD_DATA_I       <= (others => '0');
         W_CMD_RDY_I        <= '0';
         W_DATA_CLK_I       <= '0';
         W_NUM_DATA_I       <= (others=>'0');      -- std_logic_vector ( 7 downto 0 );
         W_PARAM_ID_I(PAR_ID_BUS_WIDTH - 1 downto 8)      <= (others => '0'); -- bits(23 downto 8)
         W_PARAM_ID_I(7 downto 0)       <= RET_DAT_ADDR;  -- bits(7 downto 0)
         
         -- sync pulse
         W_SYNC_PULSE_I     <= '0';
         w_sync_number_i    <= "00010000";    -- 0x10 this is arbitrary

      
         wait for PERIOD*3;
         
         W_CMD_RDY_I        <= '1';
         assert false report " Issuing ret_dat macro-ops." severity NOTE;
         
         wait for PERIOD*3;
         
         -- signal from micro-op sequence generator
         
         --0xA
         w_ack_i            <= '1';  
         wait until w_macro_instr_rdy_o = '0';
         w_ack_i            <= '0';
         
         --0xB
         wait until w_macro_instr_rdy_o = '1';
         w_ack_i            <= '1';
         wait until w_macro_instr_rdy_o = '0';
         w_ack_i            <= '0';
         
         wait for PERIOD/2; 
 
         
         W_CMD_RDY_I        <= '0';
         
         --0xC
         wait until w_macro_instr_rdy_o = '1';
         w_ack_i            <= '1';
         wait until w_macro_instr_rdy_o = '0';
         w_ack_i            <= '0';
         
         --0xD
         wait until w_macro_instr_rdy_o = '1';
         wait for PERIOD;
         w_ack_i            <= '1';
         wait until w_macro_instr_rdy_o = '0';
         w_ack_i            <= '0';
         
         --0xE
         wait until w_macro_instr_rdy_o = '1';
         w_ack_i            <= '1';
         wait until w_macro_instr_rdy_o = '0';
         w_ack_i            <= '0';
         
         --0xF
         wait until w_macro_instr_rdy_o = '1';
         wait for PERIOD*3;
         w_ack_i            <= '1';
         wait until w_macro_instr_rdy_o = '0';
         w_ack_i            <= '0';
         
                  
         
         --W_DATA_CLK_I       <= '0';
         --if W_CARD_ADDR_O = W_CARD_ADDR_I and
         --   W_PARAMETER_ID_O = W_REG_ADDR_I and W_DATA_SIZE_O = W_NUM_DATA_I  then
         --   self_check_o       <= '0';
         --   self_check_flag    <= false;
            
         --else
         --   self_check_o       <= '1';
         --  self_check_flag    <= true;
         --   assert false report " FAILED SELF-CHECKING **" severity failure;
         --end if;             
--         if W_DATA_O = x"FFFF" then
--            self_check_o       <= '0';
--            self_check_flag    <= false;
--            assert false report " Reading first word." severity NOTE;
--         else
--            self_check_o       <= '1';
--            self_check_flag    <= true;
--            assert false report " FAILED SELF-CHECKING **" severity failure;
--         end if;    
         wait for PERIOD*14;    
         
         --wait for PERIOD*22;     
         -- wait for PERIOD*3;
         
 
         

      end do_ret_dat_cmd ;   


------------------------------------------------------------------------




      procedure do_ret_dat_w_stop_cmd is
      begin

         assert false report " Performing a ret_dat with STOP cmd." severity NOTE;

         -- global signal      
         W_RST_I            <= '0';

         -- signals from fibre_rx_prototcol_fsm
         w_card_id_i      <= x"0004";           -- readout card B
         W_CMD_CODE_I       <= x"474F";     -- "START" command code
         W_CMD_DATA_I       <= (others => '0');
         W_CMD_RDY_I        <= '0';
         W_DATA_CLK_I       <= '0';
         W_NUM_DATA_I       <= (others => '0');      -- std_logic_vector ( 7 downto 0 );
         W_PARAM_ID_I(PAR_ID_BUS_WIDTH - 1 downto 8)      <= (others => '0'); -- bits(23 downto 8)
         W_PARAM_ID_I(7 downto 0)       <= RET_DAT_ADDR;  -- bits(7 downto 0)
         
         -- sync pulse
         W_SYNC_PULSE_I     <= '0';
         w_sync_number_i    <= "00110000";    -- 0x30 this is arbitrary

      
         wait for PERIOD*3;
         
         W_CMD_RDY_I        <= '1';
         assert false report " Issuing ret_dat macro-ops." severity NOTE;
         
         wait until w_macro_instr_rdy_o = '1';
         w_ack_i            <= '1';
         wait until w_macro_instr_rdy_o = '0';
         w_ack_i            <= '0';
         
         wait until w_macro_instr_rdy_o = '1';
         w_ack_i            <= '1';
         
         W_CMD_RDY_I        <= '0';
         
         
         
         wait until w_macro_instr_rdy_o = '0';
         w_ack_i            <= '0';         
         --wait for PERIOD*2;


         
         
         wait until w_macro_instr_rdy_o = '1';
         w_ack_i            <= '1';
         wait until w_macro_instr_rdy_o = '0';
         w_ack_i            <= '0';         
         
         assert false report " Issuing STOP command." severity NOTE;
         W_CMD_CODE_I       <= x"5354";     -- "STOP" command code         
         wait for PERIOD;


         
         --wait for PERIOD;
         W_CMD_RDY_I        <= '1';
         wait for PERIOD;
         w_ack_i            <= '1';
         wait until w_macro_instr_rdy_o = '0';
         w_ack_i            <= '0';            
         
         wait for PERIOD;
         W_CMD_RDY_I        <= '0';
         
         --W_DATA_CLK_I       <= '0';
         --if W_CARD_ADDR_O = W_CARD_ADDR_I and
         --   W_PARAMETER_ID_O = W_REG_ADDR_I and W_DATA_SIZE_O = W_NUM_DATA_I  then
         --   self_check_o       <= '0';
         --   self_check_flag    <= false;
            
         --else
         --   self_check_o       <= '1';
         --  self_check_flag    <= true;
         --   assert false report " FAILED SELF-CHECKING **" severity failure;
         --end if;             
--         if W_DATA_O = x"FFFF" then
--            self_check_o       <= '0';
--            self_check_flag    <= false;
--            assert false report " Reading first word." severity NOTE;
--         else
--            self_check_o       <= '1';
--            self_check_flag    <= true;
--            assert false report " FAILED SELF-CHECKING **" severity failure;
--         end if;    
         wait for PERIOD*14;    
         
         --wait for PERIOD*22;     
         -- wait for PERIOD*3;
         
 
         

      end do_ret_dat_w_stop_cmd ;   

------------------------------------------------------------------------




      procedure do_ret_dat_w_simple_cmd is
      begin

         assert false report " Performing a ret_dat with simple_cmd." severity NOTE;

         -- global signal      
         W_RST_I            <= '0';

         -- signals from fibre_rx_prototcol_fsm
         w_card_id_i      <= x"0005";           -- 
         W_CMD_CODE_I       <= x"474F";     -- "START" command code
         W_CMD_DATA_I       <= (others => '0');
         W_CMD_RDY_I        <= '0';
         W_DATA_CLK_I       <= '0';
         W_NUM_DATA_I       <= (others => '0');      -- std_logic_vector ( 7 downto 0 );
         W_PARAM_ID_I(PAR_ID_BUS_WIDTH - 1 downto 8)      <= (others => '0'); -- bits(23 downto 8)
         W_PARAM_ID_I(7 downto 0)       <= RET_DAT_ADDR;  -- bits(7 downto 0)
         
         -- sync pulse
         W_SYNC_PULSE_I     <= '0';
         w_sync_number_i    <= "00001111";    -- 0xFF this is arbitrary

      
         wait for PERIOD*3;
         
         W_CMD_RDY_I        <= '1';
         assert false report " Issuing ret_dat macro-op." severity NOTE;
         wait for PERIOD*3;
         
         w_ack_i            <= '1';
         wait until w_macro_instr_rdy_o = '0';
         w_ack_i            <= '0'; 
         
         wait until w_macro_instr_rdy_o = '1';
         wait for PERIOD;
         w_ack_i            <= '1';
         wait until w_macro_instr_rdy_o = '0';
         w_ack_i            <= '0';
         
         --wait for PERIOD;
         
         W_CMD_RDY_I        <= '0';
         
         wait for PERIOD;
         assert false report " Issuing a SIMPLE command while RET_DAT command is still running." severity NOTE;
         
         ------------------------------------------------------------
         -- Interrupting RET_DAT command with a a simple command here
         ------------------------------------------------------------
         assert false report " Performing a simple cmd with 5 words of data." severity NOTE;
         
         -- global signal      
         W_RST_I            <= '0';

         -- signals from fibre_rx_prototcol_fsm
         w_card_id_i      <= x"0003";           -- readout card A
         W_CMD_CODE_I       <= (others => '0'); -- std_logic_vector ( 15 downto 0 );
         W_CMD_DATA_I       <= x"FFFFFFFF";         -- first word of data;
         W_CMD_RDY_I        <= '0';
         W_DATA_CLK_I       <= '0';
         W_NUM_DATA_I(7 downto 0)       <= "00000101";      -- std_logic_vector ( 7 downto 0 );
         W_NUM_DATA_I(DATA_SIZE_BUS_WIDTH - 1 downto 8) <= (others => '0');
         W_PARAM_ID_I(PAR_ID_BUS_WIDTH - 1 downto 8)      <= (others => '0'); -- bits(23 downto 8)
         W_PARAM_ID_I(7 downto 0)       <= FST_ST_FB_ADDR;  -- bits(7 downto 0)
         
         -- sync pulse
         W_SYNC_PULSE_I     <= '0';

      
         wait for PERIOD*2;
         
         W_CMD_RDY_I        <= '1';
         
         -- finishing up the ret_dat command
         wait for PERIOD;
         w_ack_i            <= '1';
         wait until w_macro_instr_rdy_o = '0';
         w_ack_i            <= '0';
         -----------------------------------
         
         wait for PERIOD*2;
         
         w_ack_i            <= '1';
         wait for PERIOD;
         
         W_DATA_CLK_I       <= '1';
         wait for PERIOD;
         if W_DATA_O = W_CMD_DATA_I and 
            W_CARD_ADDR_O = w_card_id_i and
            W_PARAMETER_ID_O = W_PARAM_ID_I and 
            W_DATA_SIZE_O = W_NUM_DATA_I  then
            
            self_check_o       <= '0';
            self_check_flag    <= false;
            assert false report " Reading 1st word." severity NOTE;
         else
            self_check_o       <= '1';
            self_check_flag    <= true;
            assert false report " FAILED SELF-CHECKING **" severity failure;
            --assert false report " FAILED SELF-CHECKING **" severity NOTE;
         end if;             

         --wait for PERIOD*3;     
         wait for PERIOD*2;
         W_DATA_CLK_I       <= '0';
         wait for PERIOD*3;
         
         W_DATA_CLK_I       <= '1';
         W_CMD_DATA_I       <= x"EEEEEEEE";         -- second word of data;
         wait for PERIOD*3;
         
         if W_DATA_O = W_CMD_DATA_I and 
            W_CARD_ADDR_O = w_card_id_i and
            W_PARAMETER_ID_O = W_PARAM_ID_I and 
            W_DATA_SIZE_O = W_NUM_DATA_I  then
            
            self_check_o       <= '0';
            self_check_flag    <= false;
            assert false report " Reading 2nd word." severity NOTE;
         else
            self_check_o       <= '1';
            self_check_flag    <= true;
            assert false report " FAILED SELF-CHECKING **" severity failure;
            --assert false report " FAILED SELF-CHECKING **" severity NOTE;
         end if;     
                 
         W_DATA_CLK_I       <= '0';
         wait for PERIOD*3;
         
         W_DATA_CLK_I       <= '1';
         W_CMD_DATA_I       <= x"DDDDDDDD";         -- third word of data;
         wait for PERIOD*3;
         W_DATA_CLK_I       <= '0';
         
         if W_DATA_O = W_CMD_DATA_I and 
            W_CARD_ADDR_O = w_card_id_i and
            W_PARAMETER_ID_O = W_PARAM_ID_I and 
            W_DATA_SIZE_O = W_NUM_DATA_I  then
            
            self_check_o       <= '0';
            self_check_flag    <= false;
            assert false report " Reading 3rd word." severity NOTE;
         else
            self_check_o       <= '1';
            self_check_flag    <= true;
            assert false report " FAILED SELF-CHECKING **" severity failure;
            --assert false report " FAILED SELF-CHECKING **" severity NOTE;
         end if;         
         
         wait for PERIOD*3;  
         
         W_DATA_CLK_I       <= '1';
         W_CMD_DATA_I       <= x"CCCCCCCC";         -- fourth word of data;
         wait for PERIOD*3;
         
         if W_DATA_O = W_CMD_DATA_I and 
            W_CARD_ADDR_O = w_card_id_i and
            W_PARAMETER_ID_O = W_PARAM_ID_I and 
            W_DATA_SIZE_O = W_NUM_DATA_I  then
            
            self_check_o       <= '0';
            self_check_flag    <= false;
            assert false report " Reading 4th word." severity NOTE;
         else
            self_check_o       <= '1';
            self_check_flag    <= true;
            assert false report " FAILED SELF-CHECKING **" severity failure;
            --assert false report " FAILED SELF-CHECKING **" severity NOTE;
         end if;         
         
         W_DATA_CLK_I       <= '0';
         wait for PERIOD*3;       
         
         W_DATA_CLK_I       <= '1';
         W_CMD_DATA_I       <= x"BBBBBBBB";         -- fifth word of data;
         wait for PERIOD*3;
         
         if W_DATA_O = W_CMD_DATA_I and 
            W_CARD_ADDR_O = w_card_id_i and
            W_PARAMETER_ID_O = W_PARAM_ID_I and 
            W_DATA_SIZE_O = W_NUM_DATA_I  then
            
            self_check_o       <= '0';
            self_check_flag    <= false;
            assert false report " Reading 5th word." severity NOTE;
         else
            self_check_o       <= '1';
            self_check_flag    <= true;
            assert false report " FAILED SELF-CHECKING **" severity failure;
            --assert false report " FAILED SELF-CHECKING **" severity NOTE;
         end if;         
         
         W_DATA_CLK_I       <= '0';
         assert false report " Finishing SIMPLE command, continue with RET_DAT command." severity NOTE;
         
         wait for PERIOD;
         w_cmd_rdy_i         <= '0';
         wait until w_macro_instr_rdy_o = '0';
         w_ack_i            <= '0';
         ------------------------------------------------------------
         -- Finishing simple command here
         ------------------------------------------------------------ 
 
          -- global signal      
         W_RST_I            <= '0';

         -- signals from fibre_rx_prototcol_fsm
         w_card_id_i      <= (others => '0'); -- std_logic_vector ( 7 downto 0 );
         W_CMD_CODE_I       <= (others => '0'); -- std_logic_vector ( 15 downto 0 );
         W_CMD_DATA_I       <= (others => '0'); -- std_logic_vector ( 15 downto 0 );
         W_CMD_RDY_I        <= '0';
         W_DATA_CLK_I       <= '0';
         W_NUM_DATA_I       <= (others => '0'); --  std_logic_vector ( 7 downto 0 );
         W_PARAM_ID_I       <= (others => '0'); --  std_logic_vector ( 23 downto 0 );
         
         -- sync pulse
         W_SYNC_PULSE_I     <= '0';
         w_sync_number_i    <= (others => '0');

      
         -- self-check
         self_check_o       <= '0';
         self_check_flag    <= false;
         
         wait for PERIOD;
 
         assert false report " Resuming RET_DAT command." severity NOTE;
         
         --wait until w_macro_instr_rdy_o = '1';
         wait for PERIOD;
         w_ack_i            <= '1';
         wait until w_macro_instr_rdy_o = '0';
         w_ack_i            <= '0';
         
         wait until w_macro_instr_rdy_o = '1';
         wait for PERIOD;
         w_ack_i            <= '1';
         wait until w_macro_instr_rdy_o = '0';
         w_ack_i            <= '0';    

         wait until w_macro_instr_rdy_o = '1';
         wait for PERIOD*2;
         w_ack_i            <= '1';
         wait until w_macro_instr_rdy_o = '0';
         w_ack_i            <= '0';    
         
--         wait until w_macro_instr_rdy_o = '1';
--         wait for PERIOD*5;
--         w_ack_i            <= '1';
--         wait until w_macro_instr_rdy_o = '0';
--         w_ack_i            <= '0';    
         
         wait for PERIOD*30;
         
         
         

      end do_ret_dat_w_simple_cmd ;   

------------------------------------------------------------------------
--
-- Begin the test
--
------------------------------------------------------------------------   
   begin

      do_nop;
      do_reset;
      do_nop;
      do_nop;
      do_simple_cmd;
      do_nop;
      do_nop;
      do_ret_dat_s_cmd;
      do_nop;
      do_nop;
      do_ret_dat_cmd;
      do_nop;
      do_ret_dat_w_stop_cmd;
      do_nop;
      do_ret_dat_w_simple_cmd;
      do_nop;
      
      -- JJ ADD m_op_seq_num to SELF-CHECKING!!!
       
      assert false report " Simulation done." severity NOTE;
      assert false report " **** TEST PASSED ****" severity FAILURE;

   end process STIMULI;

end BEH;
