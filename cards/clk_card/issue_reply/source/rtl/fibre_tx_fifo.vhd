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
-- <revision control keyword substitutions e.g. $Id: fibre_tx_fifo.vhd,v 1.3 2004/10/12 14:18:56 dca Exp $>
--
-- Project:	      SCUBA-2
-- Author:	      David Atkinson
--               
-- Organisation:  UK ATC
--
-- Description: Fibre optic Transmit FIFO.   Bytes of data are buffered here 
-- to be written to the hotlink receiver.  When bytes are written to this FIFO
-- the tx_control block controls their transfer to the HOTLINK transmitter
-- 
-- Revision history:
-- <date $Date: 2004/10/12 14:18:56 $> - <text> - <initials $Author: dca $>
--
-- $Log: fibre_tx_fifo.vhd,v $
-- Revision 1.3  2004/10/12 14:18:56  dca
-- Changed to instantiate synchronous FIFO megafunction
--
-- Revision 1.2  2004/10/06 21:50:52  erniel
-- removed references to unused libraries
--
-- Revision 1.1  2004/10/05 12:22:27  dca
-- moved from fibre_tx directory.
--
-- Revision 1.1  2004/08/31 12:58:44  dca
-- Initial Version
--
--
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;

library components;
use components.component_pack.all;

--library sys_param;
--use sys_param.command_pack.all;

entity fibre_tx_fifo is
--   generic( 
--      addr_size : Positive
--   );
   port( 
      clk_i        : in     std_logic;
      rst_i        : in     std_logic;
      fibre_clkw_i : in     std_logic;
      tx_fr_i      : in     std_logic;
      tx_fw_i      : in     std_logic;
      txd_i        : in     std_logic_vector (7 downto 0);
      tx_fe_o      : out    std_logic;
      tx_ff_o      : out    std_logic;
      tx_data_o    : out    std_logic_vector (7 downto 0)
   );

-- Declarations

end fibre_tx_fifo ;


architecture behav of fibre_tx_fifo is
   component sync_fifo_tx
	PORT
	(
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wrreq		: IN STD_LOGIC ;
		rdreq		: IN STD_LOGIC ;
		rdclk		: IN STD_LOGIC ;
		wrclk		: IN STD_LOGIC ;
		aclr		: IN STD_LOGIC  := '0';
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		rdempty		: OUT STD_LOGIC ;
		wrfull		: OUT STD_LOGIC 
	);
   END component;

begin

   -- Instance port mappings.
--   I0 : async_fifo
--      generic map (addr_size => addr_size)
--      port map (
--         rst_i    => rst_i,
--         read_i   => tx_fr_i,
--         write_i  => tx_fw_i,
--         d_i      => txd_i,
--         empty_o  => tx_fe_o,
--         full_o   => tx_ff_o,
--         q_o      => tx_data_o
--      );
  

   sync_fifo_tx_inst : sync_fifo_tx 
   port map(
      data	  => txd_i,
      wrreq	  => tx_fw_i,
      rdreq	  => tx_fr_i,
      rdclk   => fibre_clkw_i,
      wrclk   => clk_i,
      aclr    => rst_i,
      q       => tx_data_o,
      rdempty => tx_fe_o,
      wrfull  => tx_ff_o
	);


end behav;