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
-- <revision control keyword substitutions e.g. $Id: issue_reply_test.vhd,v 1.1 2004/07/05 23:47:13 jjacob Exp $>
--
-- Project:	      SCUBA-2
-- Author:	      Jonathan Jacob
--
-- Organisation:  UBC
--
-- Description:  This module is a wrapper for the issue_reply top level for receiving fibre commands, translating 
-- them into instructions, and issuing them over the bus backplane. It re-maps the issue_reply inputs/outputs to the
-- matching pins on the FPGA.
-- 
--
-- Revision history:
-- 
-- <date $Date: 2004/07/05 23:47:13 $>	-		<text>		- <initials $Author: jjacob $>
--
-- $Log: issue_reply_test.vhd,v $
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
use work.issue_reply_pack.all;
use work.fibre_rx_pack.all;

library sys_param;
use sys_param.wishbone_pack.all;
use sys_param.general_pack.all;


entity issue_reply_test is

port(
      inclk              : in std_logic;
      fibre_rx_clk       : out std_logic;

      -- inputs from the fibre
      fibre_rx_data      : in std_logic_vector (7 downto 0);  -- rx_data_i
      fibre_rx_rdy       : in std_logic;                      -- nRx_rdy_i
      fibre_rx_rvs       : in std_logic;                      -- rvs_i
      fibre_rx_status    : in std_logic;                      -- rso_i
      fibre_rx_sc_nd     : in std_logic;                      -- rsc_nRd_i

      -- output to simulated u-op sequence generator (logic analyzer)
      test               : out std_logic_vector(38 downto 0); -- cksum_err
                                                              -- card_addr
                                                              -- parameter_id
                                                              -- data
                                                              -- data_clk
                                                              -- macro_instr_rdy
                                                              -- data_size

      -- inputs from the simulated u-op sequence generator (dip switch)
      dip_sw2            : in std_logic                       --ack_i

     ); 
     
end issue_reply_test;


------------------------------------------------------------------------
--
-- 
--
------------------------------------------------------------------------


architecture rtl of issue_reply_test is

   signal pll_clk         : std_logic;

   signal cksum_err       : std_logic;                                         -- connected to test(11)
   signal card_addr       : std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0); -- connected to test(15 downto 12)
   signal parameter_id    : std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);    -- connected to test(24 downto 17)
   
   signal data            : std_logic_vector (DATA_BUS_WIDTH-1 downto 0);      -- connected to test(32 downto 25)
   signal data_clk        : std_logic;                                         -- connected to test(33)
   signal macro_instr_rdy : std_logic;                                         -- connected to test(34)
   signal data_size       : std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0); -- connected to test(38 downto 35)

   signal ground          : std_logic;
   signal ground8         : std_logic_vector(7 downto 0);
   signal ground32        : std_logic_vector(31 downto 0);


------------------------------------------------------------------------
--
-- issue_reply component definition
--
------------------------------------------------------------------------
component issue_reply

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

      cksum_err_o : out    std_logic;
      
      -- outputs to the micro-instruction sequence generator
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
end component;

component issue_reply_test_pll
	PORT
	(
		inclk0  : IN STD_LOGIC  := '0';
		c0		: OUT STD_LOGIC ;
		e0		: OUT STD_LOGIC 
	);
END component;

begin

------------------------------------------------------------------------
--
-- route issue_reply outputs to test outputs on the board
--
------------------------------------------------------------------------

   test(11)           <= cksum_err;
   test(15 downto 12) <= card_addr(3 downto 0);
   test(24 downto 17) <= parameter_id(7 downto 0);
   test(32 downto 25) <= data(7 downto 0);
   test(33)           <= data_clk;
   test(34)           <= macro_instr_rdy;
   test(38 downto 35) <= data_size(3 downto 0);

   ground             <= '0';
   ground8            <= (others=>'0');
   ground32           <= (others=>'0');

------------------------------------------------------------------------
--
-- instantiate issue_reply
--
------------------------------------------------------------------------

   i_issue_reply : issue_reply
   port map( 

            -- global signals
            rst_i             => ground,
            clk_i             => pll_clk,
      
            -- inputs from the fibre
            rx_data_i         => fibre_rx_data,
            nRx_rdy_i         => fibre_rx_rdy,
            rvs_i             => fibre_rx_rvs,
            rso_i             => fibre_rx_status,
            rsc_nRd_i         => fibre_rx_sc_nd,  

            cksum_err_o       => cksum_err,
      
            card_addr_o       => card_addr,
            parameter_id_o    => parameter_id,
            data_size_o       => data_size,
            data_o            => data,
            data_clk_o        => data_clk,
            macro_instr_rdy_o => macro_instr_rdy,
      
            m_op_seq_num_o    => ground8,
            frame_seq_num_o   => ground32,
            frame_sync_num_o  => ground8,
      
            -- input from the micro-op sequence generator
            ack_i             => dip_sw2
           ); 

------------------------------------------------------------------------
--
-- instantiate pll here
--
------------------------------------------------------------------------

pll : issue_reply_test_pll
	port map
	(
		inclk0	=> inclk,
		c0		=> pll_clk,
		e0		=> fibre_rx_clk 
	);



end rtl; 