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
-- <revision control keyword substitutions e.g. $Id: issue_reply.vhd,v 1.0 2004/06/21 16:57:24 jjacob Exp $>
--
-- Project:	      SCUBA-2
-- Author:	       Jonathan Jacob
--
-- Organisation:  UBC
--
-- Description:  This module is the top level for receiving fibre commands, translating them into
-- instructions, and issuing them over the bus backplane. 
-- 
--
-- Revision history:
-- 
-- <date $Date: 2004/06/21 16:57:24 $>	-		<text>		- <initials $Author: jjacob $>
--
-- $Log: issue_reply.vhd,v $
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
use work.issue_reply_pack.all;
use work.fibre_rx_pack.all;

library sys_param;
use sys_param.wishbone_pack.all;
use sys_param.general_pack.all;


entity issue_reply is

port(

      -- global signals
      rst_i        : in     std_logic;
      clk_i        : in     std_logic;
      
      
      -- inputs from the fibre
      rx_data_i   : in     std_logic_vector (7 DOWNTO 0);
      nRx_rdy_i   : in     std_logic;
      rvs_i       : in     std_logic;
      rso_i       : in     std_logic;
      rsc_nRd_i   : in     std_logic;        
--      nTrp_i      : in     std_logic;
--      ft_clkw_i   : in     std_logic; 
--      
--      -- outputs to the fibre
--      tx_data_o   : out    std_logic_vector (7 DOWNTO 0);      
--      tsc_nTd_o   : out    std_logic;
--      nFena_o     : out    std_logic;
      cksum_err_o : out    std_logic;
      
      -- outputs to the micro-instruction sequence generator
      -- these signals will be absorbed when the issue_reply block's boundary extends
      -- to include u-op sequence generator.
      card_addr_o       :  out std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);   -- specifies which card the command is targetting
      parameter_id_o    :  out std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);      -- comes from param_id_i, indicates which device(s) the command is targetting
      data_size_o       :  out std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);   -- num_data_i, indicates number of 16-bit words of data
      data_o            :  out std_logic_vector (DATA_BUS_WIDTH-1 downto 0);        -- data will be passed straight thru
      data_clk_o        :  out std_logic;
      macro_instr_rdy_o :  out std_logic;
      
      m_op_seq_num_o    :  out std_logic_vector(7 downto 0);
      frame_seq_num_o   :  out std_logic_vector(31 downto 0);
      frame_sync_num_o  :  out std_logic_vector(7 downto 0);
      
      -- input from the micro-op sequence generator
      ack_i             : in std_logic     

   ); 
     
end issue_reply;


architecture rtl of issue_reply is

      -- inputs from fibre_rx 
      signal card_id         :  std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);    -- specifies which card the command is targetting
      signal cmd_code        :  std_logic_vector (15 downto 0);                       -- the least significant 16-bits from the fibre packet
      signal cmd_data        :  std_logic_vector (DATA_BUS_WIDTH-1 downto 0);         -- the data 
      signal cmd_rdy         :  std_logic;                                            -- indicates the fibre_rx outputs are valid
      signal data_clk        :  std_logic;                                            -- used to clock the data out
      signal num_data        :  std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);    -- number of 16-bit data words to be clocked out, possibly number of bytes
      signal param_id        :  std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);       -- the parameter ID
      
      signal cmd_ack         :  std_logic;   -- acknowledge signal from cmd_translator to fibre_rx
 
      -- signals for the return path for quick responses, currently not implemented
      signal reply_cmd_ack_o      :  std_logic; 
      signal reply_card_addr_o    :  std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);
      signal reply_parameter_id_o :  std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);
      signal reply_data_size_o    :  std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0); 
      signal reply_data_o         :  std_logic_vector (DATA_BUS_WIDTH-1 downto 0); 

      signal sync_pulse           : std_logic;
      signal sync_number          : std_logic_vector (7 downto 0);


      -- temporary signals to simulate the sync pulse counter
      signal count                : integer;
      signal count_rst            : std_logic;
      

   component fibre_rx is
   port( 
      rst_i       : in     std_logic;
      clk_i       : in     std_logic;
      
      nrx_rdy_i   : in     std_logic;
      rvs_i       : in     std_logic;
      rso_i       : in     std_logic;
      rsc_nrd_i   : in     std_logic;  
      rx_data_i   : in     std_logic_vector (7 downto 0);
      cmd_ack_i   : in     std_logic;                          -- command acknowledge
      
      cmd_code_o  : out    std_logic_vector (15 downto 0);     -- command code  
      card_id_o   : out    std_logic_vector (15 downto 0);     -- card id
      param_id_o  : out    std_logic_vector (15 downto 0);     -- parameter id
      num_data_o  : out    std_logic_vector (7 downto 0);      -- number of valid 32 bit data words
      cmd_data_o  : out    std_logic_vector (31 downto 0);     -- 32bit valid data word
      cksum_err_o : out    std_logic;                          -- checksum error flag
      cmd_rdy_o   : out    std_logic;                          -- command ready flag (checksum passed)
      data_clk_o  : out    std_logic                           -- data clock
    );

   end component;

begin




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
      
      cksum_err_o     => cksum_err_o
    );





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
               cmd_rdy_i            => cmd_rdy,
               data_clk_i           => data_clk,
               num_data_i           => num_data,
               param_id_i           => param_id,
               
               -- output to fibre_rx
               ack_o                => cmd_ack,
               
               -- outputs to u-op sequence generator
               
               card_addr_o          => card_addr_o,
               parameter_id_o       => parameter_id_o,
               data_size_o          => data_size_o,
               data_o               => data_o,
               data_clk_o           => data_clk_o,
               macro_instr_rdy_o    => macro_instr_rdy_o,
               m_op_seq_num_o       => m_op_seq_num_o,
               frame_seq_num_o      => frame_seq_num_o,
               frame_sync_num_o     => frame_sync_num_o,
               
               --input from the u-op sequence generator
               ack_i                => ack_i,
               
               -- outputs on return path for quick responses, currently not implemented
               reply_cmd_ack_o      => reply_cmd_ack_o,    
               reply_card_addr_o    => reply_card_addr_o,     
               reply_parameter_id_o => reply_parameter_id_o,
               reply_data_size_o    => reply_data_size_o,
               reply_data_o         => reply_data_o,
               
               
               sync_pulse_i         => sync_pulse,
               sync_number_i        => sync_number

               );

------------------------------------------------------------------------
--
-- temporary sync_number counter
--
------------------------------------------------------------------------

    i_timer : us_timer
    port map(clk           => clk_i,
           timer_reset_i   => count_rst,
           timer_count_o   => count
           );
           


   
   process(count, rst_i)
   begin
         if rst_i = '1' then
            count_rst <= '1';
         elsif count = 2 then
            count_rst   <= '1';
         else
            count_rst   <= '0';
         end if;

   end process;
 
   process(rst_i, count_rst)
   begin
         if rst_i = '1' then
            sync_number <= (others=>'0');
         elsif count_rst'event and count_rst = '1' then
            sync_number <= sync_number + 1;
         end if;
   end process;

end rtl; 