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
-- <revision control keyword substitutions e.g. $Id: issue_reply_test.vhd,v 1.6 2004/08/03 20:11:43 jjacob Exp $>
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
-- <date $Date: 2004/08/03 20:11:43 $>	-		<text>		- <initials $Author: jjacob $>
--
-- $Log: issue_reply_test.vhd,v $
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
use work.fibre_rx_pack.all;
use work.async_pack.all;
use work.sync_gen_pack.all;

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
   signal parameter_id    : std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);    -- connected to test(15 downto 16)
   
   signal data            : std_logic_vector (DATA_BUS_WIDTH-1 downto 0);      -- connected to test(31 downto 24)
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
    signal sync_number   : std_logic_vector(7 downto 0);
    
    signal rst           : std_logic;

      -- temporary signals to simulate the sync pulse counter

      signal count                : integer;
      signal count_rst            : std_logic;
      signal sync_number_mux_sel  : std_logic;
      signal sync_number_mux      : std_logic_vector(7 downto 0);
      
      type state is               (IDLE, COUNTING, INCREMENT);
      signal current_state, next_state : state;
      constant SYNC_PERIOD        : integer := 3000;--1400; -- time in micro-seconds
      
      
      
      signal cmd_tx_dat : std_logic_vector(31 downto 0);


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
      sync_pulse_i: in     std_logic;
      sync_number_i  : in std_logic_vector (7 downto 0);
      
--      -- outputs to the micro-instruction sequence generator
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
--      ack_i             :  in std_logic  
  
      macro_op_ack_o  : out std_logic; -- from cmd_queue to cmd_translator
      -- lvds_tx interface
      tx_o           : out std_logic;  -- transmitter output pin
      clk_200mhz_i   : in std_logic    -- PLL locked 25MHz input clock for the 
      
      
      --cmd_tx_dat_o    : out std_logic_vector (31 downto 0)

   ); 
end component;

component issue_reply_test_pll
	PORT
	(
		inclk0		: IN STD_LOGIC  := '0';
		c0		    : OUT STD_LOGIC ;
		c1		    : OUT STD_LOGIC ;
		e0		    : OUT STD_LOGIC ;
		e1		    : OUT STD_LOGIC 
	);		
END component;

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
   
   
   --test (36)             <= cmd_tx_dat(24); 
   --test (34 downto 11)   <= cmd_tx_dat(23 downto 0);

   zero               <= '0';
   rst                <= '0';

------------------------------------------------------------------------
--
-- instantiate issue_reply
--
------------------------------------------------------------------------

   i_issue_reply : issue_reply
   port map( 

            -- global signals
            rst_i             => zero,
            clk_i             => pll_clk,
      
            -- inputs from the fibre
            rx_data_i         => fibre_rx_data,
            nRx_rdy_i         => fibre_rx_rdy,
            rvs_i             => fibre_rx_rvs,
            rso_i             => fibre_rx_status,
            rsc_nRd_i         => fibre_rx_sc_nd,  

            cksum_err_o       => cksum_err,
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
             
             
             
             --cmd_tx_dat_o    => cmd_tx_dat
            
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



------------------------------------------------------------------------
--
-- instantiate pll here
--
------------------------------------------------------------------------

pll : issue_reply_test_pll
	port map
	(
		inclk0	        => inclk,
		c0		=> pll_clk,
		c1		=> clk_200mhz,
		e0		=> fibre_rx_clk,
		e1		=> fibre_tx_clk  -- this one is here for CC001 because fibre_rx_clk is not connected to the pll,
		                         -- but fibre_tx_clk is, and it's shorted to fibre_rx_clk
	);


------------------------------------------------------------------------
--
-- generate sync number/pulse
--
------------------------------------------------------------------------

   i_sync_gen : sync_gen
      port map(
         clk_i       => pll_clk,
         rst_i       => zero,
         dv_i        => zero,
         dv_en_i     => zero,
         sync_o      => sync_pulse,
         sync_num_o  => sync_number
      );




--    i_timer : us_timer
--    port map(clk           => pll_clk,
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
--      sync_number_mux_sel <= '0'; -- hold value
--   
--      case current_state is
--         when IDLE =>
--            next_state <= COUNTING;
--            count_rst  <= '1';
--            
--         when COUNTING =>
--            if count >= SYNC_PERIOD then
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
--   process(pll_clk, rst)
--   begin
--      if rst = '1' then
--         sync_number    <= (others=>'0');
--         current_state <= IDLE;
--      elsif pll_clk'event and pll_clk = '1' then
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


------------------------------------------------------------------------
--
-- create simulated cmd_ack_i signal here
--
------------------------------------------------------------------------

   --simulated_ack <= '1';

--   process(current_state, macro_instr_rdy) --, parameter_id, card_addr)
--   begin
--      case current_state is
--         when IDLE =>
--            if macro_instr_rdy = '1' then
--            --if ((macro_instr_rdy = '1') and (parameter_id = x"005C") and (card_addr = x"0002")) then
--            --if ((macro_instr_rdy = '1') and (parameter_id /= 0) and (card_addr /= 0)) then
--               --next_state <= IDLE2;  -- this is to ensure macro_instr_rdy is not just glitching high
--               next_state <= WAIT1;
--            else
--               next_state <= IDLE;
--            end if;
--
--            simulated_ack <= '0';
--
--         when IDLE2  =>
--            if macro_instr_rdy = '1' then
--               next_state <= IDLE3; -- this is to double-check macro_instr_rdy is not just glitching high
--            else
--               next_state <= IDLE;
--            end if;
--
--            simulated_ack <= '0';
--
--         when IDLE3  =>
--            if macro_instr_rdy = '1' then
--               next_state <= WAIT1;
--            else
--               next_state <= IDLE;
--            end if;
--
--            simulated_ack <= '0';
--
--         when WAIT1  => next_state    <= WAIT2;
--                        simulated_ack <= '0';
--
--         when WAIT2  => next_state    <= ACK;
--                        simulated_ack <= '0';
--
--         when ACK    => next_state    <= IDLE;
--                        simulated_ack <= '1';
--
----            if macro_instr_rdy = '0' and data_size = 0 and 
----               data_clk = '0' and data = 0 and parameter_id = 0 then
----               next_state    <= IDLE;
----               simulated_ack <= '1';
----            else
----               next_state    <= ACK;
----               simulated_ack <= '1';
----            end if;
--
--         when others => next_state    <= IDLE;
--                        simulated_ack <= '0';
--      end case;
--   end process;
--
--   process(pll_clk)
--   begin
--      if pll_clk'event and pll_clk = '1' then
--         current_state <= next_state;
--      end if;
--   end process;


end rtl; 