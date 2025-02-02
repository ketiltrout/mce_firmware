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
-- <revision control keyword substitutions e.g. $Id: issue_reply_test.vhd,v 1.15 2004/11/19 14:55:06 dca Exp $>
--
-- Project:       SCUBA-2
-- Author:        Jonathan Jacob
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
-- <date $Date: 2004/11/19 14:55:06 $> -     <text>      - <initials $Author: dca $>
--
-- $Log: issue_reply_test.vhd,v $
-- Revision 1.15  2004/11/19 14:55:06  dca
-- added 25Mhz internal clock
--
-- Revision 1.14  2004/11/09 15:31:49  dca
-- fibre transmitter signals added to issue_reply_test entitiy declaration
--
-- Revision 1.13  2004/10/21 17:42:09  bench2
-- Greg: Check-in for a routine update.
--
-- Revision 1.12  2004/10/13 20:48:10  bench2
-- Bryce:  added lvds_clk and lvds_cmd to the issue_reply_test top level
--
-- Revision 1.11  2004/10/13 05:44:58  bench2
-- Bryce:  Added a new top-level signal to the clock card issue_reply_test block:  fibre_ckr aka fibre_clkr
--
-- Revision 1.10  2004/10/08 19:45:26  bburger
-- Bryce:  Changed SYNC_NUM_WIDTH to 16, removed TIMEOUT_SYNC_WIDTH, added a command-code to cmd_queue, added two words of book-keeping information to the cmd_queue
--
-- Revision 1.9  2004/09/10 01:21:01  bburger
-- Bryce:  Hardware testing, bug fixing
--
-- Revision 1.8  2004/09/02 01:14:52  bburger
-- Bryce:  Debugging - found that crc_ena must be asserted for crc_clear to function correctly
--
-- Revision 1.7  2004/09/01 16:39:02  jjacob
-- updated version
--
-- Revision 1.6  2004/08/03 20:11:43  jjacob
-- cleaned up
--
-- Revision 1.5  2004/07/30 23:32:00  jjacob
-- safety checkin for the long weekend
--
-- Revision 1.4  2004/07/14 23:30:48  jjacob
-- safety checkin
--
-- Revision 1.3  2004/07/12 15:48:18  jjacob
-- Added an extra output e1 to the pll because fibre_rx_clk is not connected
-- to the pll, but fibre_tx_clk is (connected to e1), and it's shorted to
-- fibre_rx_clk. This is on the CC001 board which I'm currently testing on.
-- Also shifted the bits by one from test(38:17) -> test(37:16).
--
-- Revision 1.2  2004/07/08 20:21:39  jjacob
-- modified test(38 downto 0) to test(38 downto 11)
--
-- Revision 1.1  2004/07/08 19:12:23  jjacob
-- first version of issue_reply_test
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
use work.issue_reply_pack.all;
use work.async_pack.all;
use work.sync_gen_pack.all;
use work.sync_gen_core_pack.all;

library sys_param;
use sys_param.wishbone_pack.all;
use sys_param.general_pack.all;
use sys_param.command_pack.all;

entity issue_reply_test is

port(
      inclk              : in std_logic;
      fibre_rx_clk       : out std_logic;
      
      -- this one is here for CC001 because fibre_rx_clk is not connected to the pll,
      -- but fibre_tx_clk is, and it's shorted to fibre_rx_clk
      fibre_tx_clk       : out std_logic;

      -- inputs from the fibre
      fibre_rx_data      : in std_logic_vector (7 downto 0);  -- rx_data_i
      fibre_rx_rdy       : in std_logic;                      -- nRx_rdy_i
      fibre_rx_rvs       : in std_logic;                      -- rvs_i
      fibre_rx_status    : in std_logic;                      -- rso_i
      fibre_rx_sc_nd     : in std_logic;                      -- rsc_nRd_i
      fibre_rx_ckr       : in std_logic;                      -- fibre_clkr_i



    -- interface to hotlink transmitter

     fibre_tx_data           : out std_logic_vector (7 downto 0);
     fibre_tx_ena            : out std_logic;  
     fibre_tx_sc_nd          : out std_logic;


      -- outputs to the bus backplane
      lvds_cmd           : out std_logic;
      lvds_clk           : out std_logic;          
      
      -- output to the test header
      test               : out std_logic_vector(38 downto 11)  -- cksum_err
                                                               -- card_addr
                                                               -- parameter_id
                                                               -- data
                                                               -- data_clk
                                                               -- macro_instr_rdy
                                                               -- data_size
                                                               -- ack_i

     ); 
     
end issue_reply_test;


------------------------------------------------------------------------
--
-- 
--
------------------------------------------------------------------------


architecture rtl of issue_reply_test is

   signal pll_clk         : std_logic;
   signal clk_200mhz      : std_logic;

   signal cksum_err       : std_logic;                                         -- connected to test(11)
--   signal card_addr       : std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0); -- connected to test(15 downto 12)
   signal parameter_id    : std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);    -- connected to test(15 downto 16)
   
   signal data            : std_logic_vector (FIBRE_DATA_SIZE_WIDTH-1 downto 0);      -- connected to test(31 downto 24)
   signal data_clk        : std_logic;                                         -- connected to test(32)
   signal macro_instr_rdy : std_logic;                                         -- connected to test(33)
--   signal data_size       : std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0); -- connected to test(37 downto 34)

--   signal m_op_seq_num    : std_logic_vector(7 downto 0);
--   signal frame_seq_num   : std_logic_vector(31 downto 0);
--   signal frame_sync_num  : std_logic_vector(7 downto 0);

   signal macro_op_ack     : std_logic;

--   signal simulated_ack   : std_logic;     -- connected to test(38)
--
--   type state is (IDLE, IDLE2, IDLE3, WAIT1, WAIT2, ACK);
--   signal next_state, current_state  : state;

   signal zero            : std_logic;


    --rx signals
    signal rx_dat        : std_logic_vector(31 downto 0);
    signal rx_rdy        : std_logic;
    signal rx_ack        : std_logic;
    
    signal tx            : std_logic;

    
    signal sync_pulse    : std_logic;
    signal sync_number   : std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
    
    signal rst           : std_logic;

    -- temporary signals to simulate the sync pulse counter
    signal count                : integer;
    signal count_rst            : std_logic;
    signal sync_number_mux_sel  : std_logic;
    signal sync_number_mux      : std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
    
    type state is               (IDLE, COUNTING, INCREMENT);
    signal current_state, next_state : state;
    constant SYNC_PERIOD        : integer := 3000;--1400; -- time in micro-seconds
    
    
    
    signal debug     : std_logic_vector(31 downto 0);

    signal clk_25mhz : std_logic;
  

------------------------------------------------------------------------
--
-- issue_reply component definition
--
------------------------------------------------------------------------
component issue_reply

port(
      -- for testing
      debug_o           : out std_logic_vector (31 downto 0);

      -- global signals
      rst_i             : in     std_logic;
      clk_i             : in     std_logic;
            
      -- inputs from the fibre
      fibre_clkr_i      : in    std_logic;
      rx_data_i         : in     std_logic_vector (7 DOWNTO 0);
      nRx_rdy_i         : in     std_logic;
      rvs_i             : in     std_logic;
      rso_i             : in     std_logic;
      rsc_nRd_i         : in     std_logic;        
 
      cksum_err_o       : out    std_logic;

  -- interface to fibre transmitter
      tx_data_o    : out    std_logic_vector (7 downto 0);      -- byte of data to be transmitted
      tsc_nTd_o    : out    std_logic;                          -- hotlink tx special char/ data sel
      nFena_o      : out    std_logic;                           -- hotlink tx enable

      -- 25MHz clock for fibre_tx_control
      fibre_clkw_i : in     std_logic;                          -- in phase with 25MHz hotlink clock



      sync_pulse_i      : in     std_logic;
      sync_number_i     : in std_logic_vector (SYNC_NUM_WIDTH-1 downto 0);
      
--      -- outputs to the micro-instruction sequence generator
--      card_addr_o       :  out std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);   -- specifies which card the command is targetting
      parameter_id_o    :  out std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);      -- comes from param_id_i, indicates which device(s) the command is targetting
--      data_size_o       :  out std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);   -- num_data_i, indicates number of 16-bit words of data
      data_o            :  out std_logic_vector (FIBRE_DATA_SIZE_WIDTH-1 downto 0);        -- data will be passed straight thru
      data_clk_o        :  out std_logic;
      macro_instr_rdy_o :  out std_logic;
--      
--      m_op_seq_num_o    :  out std_logic_vector(7 downto 0);
--      frame_seq_num_o   :  out std_logic_vector(31 downto 0);
--      frame_sync_num_o  :  out std_logic_vector(7 downto 0);
--      
--      -- input from the micro-op sequence generator
--      ack_i             :  in std_logic  
  
      macro_op_ack_o    : out std_logic; -- from cmd_queue to cmd_translator
      -- lvds_tx interface
      tx_o              : out std_logic;  -- transmitter output pin
      clk_200mhz_i      : in std_logic    -- PLL locked 25MHz input clock for the 
   ); 
end component;

component issue_reply_test_pll
   port(
      inclk0 : in std_logic  := '0';
      e2     : out std_logic ;
      c0     : out std_logic ;
      c1     : out std_logic ;
      c2     : out std_logic ;
      e0     : out std_logic ;
      e1     : out std_logic 
   );    
end component;


begin

------------------------------------------------------------------------
--
-- route issue_reply outputs to test outputs on the board
--
------------------------------------------------------------------------

--   test(11)           <= sync_pulse;
--
-- 
----   test(38 downto 36) <= rx_dat(25 downto 23);
--   -- skip test(35) because it's shorted to test(33)
----   test(34 downto 12) <= rx_dat(22 downto 0);  -- bottom 22 bits of rx_dat
--   test(32)           <= macro_op_ack;
--   test(31 downto 24) <= parameter_id(7 downto 0);
--   test(23 downto 16) <= data(7 downto 0);
--   test(15)           <= data_clk;
--   test(14)           <= macro_instr_rdy;
--
--   test(13)           <= tx;
--   test(12)           <= cksum_err;



   test (38) <= macro_instr_rdy;
   test (37) <= macro_op_ack;
   
   test (36)             <= fibre_rx_ckr;
   test (34 downto 11)   <= debug(31 downto 8);

   zero               <= '0';
   rst                <= '0';

------------------------------------------------------------------------
--
-- instantiate issue_reply
--
------------------------------------------------------------------------

   i_issue_reply : issue_reply
   port map( 
            --[JJ] For testing
            debug_o    => debug,

            -- global signals
            rst_i             => zero,
            clk_i             => pll_clk,
      
            -- inputs from the fibre
            fibre_clkr_i      => fibre_rx_ckr,
            rx_data_i         => fibre_rx_data,
            nRx_rdy_i         => fibre_rx_rdy,
            rvs_i             => fibre_rx_rvs,
            rso_i             => fibre_rx_status,
            rsc_nRd_i         => fibre_rx_sc_nd,  

            cksum_err_o       => cksum_err,


            tx_data_o         => fibre_tx_data,
            tsc_nTd_o         => fibre_tx_sc_nd, 
            nFena_o           => fibre_tx_ena, 

             -- 25MHz clock for fibre_tx_control
            fibre_clkw_i      => clk_25mhz,


            sync_pulse_i      => sync_pulse,
            sync_number_i     => sync_number,

--            card_addr_o       => card_addr,
            parameter_id_o    => parameter_id,
--            data_size_o       => data_size,
            data_o            => data,
            data_clk_o        => data_clk,
            macro_instr_rdy_o => macro_instr_rdy,
--      
--            m_op_seq_num_o    => m_op_seq_num,
--            frame_seq_num_o   => frame_seq_num,
--            frame_sync_num_o  => frame_sync_num,
--      
--            -- input from the micro-op sequence generator
--            ack_i             => simulated_ack

             macro_op_ack_o   => macro_op_ack,
                  -- lvds_tx interface
             tx_o             => tx,  -- transmitter output pin
             clk_200mhz_i     => clk_200mhz -- this will come from pll c1
           ); 

------------------------------------------------------------------------
--
-- instantiate lvds receiver so we can make sense of the data
--
------------------------------------------------------------------------
   rx : lvds_rx
      port map(
        clk_i          => pll_clk,
        comm_clk_i     => clk_200mhz,  -- need to create new pll with c1 clock
        rst_i          => zero,
     
        dat_o          => rx_dat,
        rdy_o          => rx_rdy,
        ack_i          => rx_ack,
     
        lvds_i         => tx
      );
   
   rx_ack <= rx_rdy;
   lvds_cmd <= tx;


------------------------------------------------------------------------
--
-- instantiate pll here
--
------------------------------------------------------------------------

pll : issue_reply_test_pll
   port map
   (
      inclk0            => inclk,
      e2                => lvds_clk,
      c0                => pll_clk,
      c1                => clk_200mhz,
      c2                => clk_25mhz,
      e0                => fibre_rx_clk,
      e1                => fibre_tx_clk  -- this one is here for CC001 because fibre_rx_clk is not connected to the pll,
                               -- but fibre_tx_clk is, and it's shorted to fibre_rx_clk
   );


------------------------------------------------------------------------
--
-- generate sync number/pulse
--
------------------------------------------------------------------------

   i_sync_gen : sync_gen_core
      port map(
         -- Wishbone Interface
         dv_en_i     => zero,
         
         -- Inputs/Outputs
         dv_i        => zero,
         sync_o      => sync_pulse,
         sync_num_o  => sync_number,

         -- Global Signals
         clk_i       => pll_clk,
         mem_clk_i   => clk_200mhz,
         rst_i       => zero
      );

end rtl; 