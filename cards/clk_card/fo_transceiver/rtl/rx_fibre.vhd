--  Copyright (c) 2003 SCUBA-2 Project
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

-- --
-- <revision control keyword substitutions e.g. $Id: rx_protocol_fsm.vhd,v 1.9 2004/05/20 15:43:59 dca Exp $>
--
-- Project:	      SCUBA-2
-- Author:	      David Atkinson
--               
-- Organisation:  UK ATC
--
-- Description:   rx_fibre
--
-- This block contains the front end firmware which parses incomming commands
--
-- It instantiates the following blocks
--
-- 1. rx_control
-- 2. rx_fifo
-- 3. rx_protocol_fsm
--
-- Revision history:
-- 
-- <date $Date:$>	-		<text>		- <initials $Author: dca $>
-- <$log$>

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.fo_transceiver_pack.all;

entity rx_fibre is
   port( 
      Brst        : in     std_logic;
      clk         : in     std_logic;
      
      rx_data_i   : in     std_logic_vector (7 DOWNTO 0);
      nRx_rdy_i   : in     std_logic;
      rvs_i       : in     std_logic;
      rso_i       : in     std_logic;
      rsc_nRd_i   : in     std_logic;  
     
      card_addr_o : out    std_logic_vector (7 DOWNTO 0);
      cmd_code_o  : out    std_logic_vector (15 DOWNTO 0);
      cmd_data_o  : out    std_logic_vector (15 DOWNTO 0);
      cksum_err_o : out    std_logic;
      cmd_rdy_o   : out    std_logic;
      data_clk_o  : out    std_logic;
      num_data_o  : out    std_logic_vector (7 downto 0);
      reg_addr_o  : out    std_logic_vector (23 DOWNTO 0)
    );


end rx_fibre;



-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.fo_transceiver_pack.all;


architecture behav of rx_fibre is

   -- Internal signal declarations
   
   signal rx_fr       : std_logic;
   signal rx_fw       : std_logic;
   signal rx_fe       : std_logic;
   signal rx_ff       : std_logic;
   signal rxd         : std_logic_vector(7 downto 0);
   signal rx_data     : std_logic_vector(7 downto 0);
  
       
   signal nRx_rdy     : std_logic;
   signal rsc_nRd     : std_logic;
   signal rso         : std_logic;
   signal rvs         : std_logic;
 
   
   signal cksum_err   : std_logic;
   signal cmd_rdy     : std_logic;


   signal card_addr   : std_logic_vector (7 downto 0);
   signal cmd_code    : std_logic_vector (15 downto 0);
   signal cmd_data    : std_logic_vector (15 downto 0);
   signal data_clk    : std_logic;
   signal num_data    : std_logic_vector (7 downto 0);
   signal reg_addr    : std_logic_vector (23 downto 0);
 
      
begin

   rx_data     <= rx_data_i;

   nRx_rdy     <= nRx_rdy_i;
   rvs         <= rvs_i;
   rso         <= rso_i;
   rsc_nRd     <= rsc_nRd_i;  
      

   cksum_err_o <= cksum_err;
   cmd_rdy_o   <= cmd_rdy;

   card_addr_o <= card_addr;
   cmd_code_o  <= cmd_code;
   cmd_data_o  <= cmd_data;
   data_clk_o  <= data_clk;
   num_data_o  <= num_data;
   reg_addr_o  <= reg_addr;
 

   -- Instance port mappings.
   I0 : rx_fifo
      generic map (
         fifo_size => 512
      )
      port map (
         Brst        => Brst,
         rx_fr_i     => rx_fr,
         rx_fw_i     => rx_fw,
         rx_data_i   => rx_data,
         rx_fe_o     => rx_fe,
         rx_ff_o     => rx_ff,
         rxd_o       => rxd
   );

   I1: rx_control 
      port map ( 
         nRx_rdy_i  =>   nRx_rdy,
         rsc_nRd_i  =>   rsc_nRd,
         rso_i      =>   rso,
         rvs_i      =>   rvs,
         rx_ff_i    =>   rx_ff,
         rx_fw_o    =>   rx_fw
   );
  
   I2: rx_protocol_fsm
      port map ( 
         Brst        =>   Brst,
         clk         =>   clk,
         rx_fe_i     =>   rx_fe,
         rxd_i       =>   rxd,
         card_addr_o =>   card_addr,
         cmd_code_o  =>   cmd_code,
         cmd_data_o  =>   cmd_data,
         cksum_err_o =>   cksum_err,
         cmd_rdy_o   =>   cmd_rdy,
         data_clk_o  =>   data_clk,
         num_data_o  =>   num_data,
         reg_addr_o  =>   reg_addr,
         rx_fr_o     =>   rx_fr
      );
end behav;