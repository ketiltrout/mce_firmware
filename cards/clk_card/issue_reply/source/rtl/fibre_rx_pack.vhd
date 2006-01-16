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
-- $Id: fibre_rx_pack.vhd,v 1.1 2004/11/24 01:15:52 bench2 Exp $
--
-- Project:    SCUBA2
-- Author:     Greg Dennis
-- Organization:  UBC
--
-- Description:
-- Declares a few constants used as parameters in the fibre_rx block
--
-- Revision history:
-- $Log: fibre_rx_pack.vhd,v $
-- Revision 1.1  2004/11/24 01:15:52  bench2
-- Greg: Broke apart issue reply and created pack files for all of its sub-components
--
--
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.command_pack.all;

library work;
use work.sync_gen_pack.all;

package fibre_rx_pack is

constant RX_FIFO_DATA_WIDTH   : integer := 8;
---------------------------
component fibre_rx_fifo 
---------------------------
port(
   clk_i        : in     std_logic;                                          -- global clock
   rst_i        : in     std_logic;                                          -- global reset
           
   fibre_clkr_i : in     std_logic;                                          -- CKR from hotlink receiver 
   rx_fr_i      : in     std_logic;                                          -- fifo read request
   rx_fw_i      : in     std_logic;                                          -- fifo write request
   rx_data_i    : in     std_logic_vector (RX_FIFO_DATA_WIDTH-1 downto 0);   -- fifo data input
   rx_fe_o      : out    std_logic;                                          -- fifo empty flag
   rx_ff_o      : out    std_logic;                                          -- fifo full flagg
   rxd_o        : out    std_logic_vector (RX_FIFO_DATA_WIDTH-1 downto 0)    -- fifo data output
);
    
end component;

---------------------------
component fibre_rx_protocol
--------------------------- 
port( 
   rst_i       : in     std_logic;                                             -- reset
   clk_i       : in     std_logic;                                             -- clock 
   rx_fe_i     : in     std_logic;                                             -- receive fifo empty flag
   rxd_i       : in     std_logic_vector (RX_FIFO_DATA_WIDTH-1 downto 0);      -- receive data byte 
   cmd_ack_i   : in     std_logic;                                             -- command acknowledge

   cmd_code_o  : out    std_logic_vector (FIBRE_PACKET_TYPE_WIDTH-1 downto 0);      -- command code  
   card_id_o   : out    std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);     -- card id
   param_id_o  : out    std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);        -- parameter id
   num_data_o  : out    std_logic_vector (FIBRE_DATA_SIZE_WIDTH-1 downto 0);     -- number of valid 32 bit data words
   cmd_data_o  : out    std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);          -- 32bit valid data word
   cksum_err_o : out    std_logic;                                             -- checksum error flag
   cmd_rdy_o   : out    std_logic;                                             -- command ready flag (checksum passed)
   data_clk_o  : out    std_logic;                                             -- data clock
   rx_fr_o     : out    std_logic                                              -- receive fifo read request
);
end component;

---------------------------
component fibre_rx_control
---------------------------
port( 
   nRx_rdy_i : in     std_logic;
   rsc_nRd_i : in     std_logic;
   rso_i     : in     std_logic;
   rvs_i     : in     std_logic;
   rx_ff_i   : in     std_logic;
   rx_fw_o   : out    std_logic
   );
end component;


---------------------------
component fibre_rx 
---------------------------
port( 
   rst_i        : in     std_logic;
   clk_i        : in     std_logic;
   
   fibre_clkr_i : in     std_logic;                                          -- CKR from hotlink receiver   
   nRx_rdy_i    : in     std_logic;
   rvs_i        : in     std_logic;
   rso_i        : in     std_logic;
   rsc_nrd_i    : in     std_logic;  
   rx_data_i    : in     std_logic_vector (RX_FIFO_DATA_WIDTH-1 downto 0);
   cmd_ack_i    : in     std_logic;                                           -- command acknowledge
   
   cmd_code_o   : out    std_logic_vector (FIBRE_PACKET_TYPE_WIDTH-1 downto 0);    -- command code  
   card_id_o    : out    std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);   -- card id
   param_id_o   : out    std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);      -- parameter id
   num_data_o   : out    std_logic_vector (FIBRE_DATA_SIZE_WIDTH-1 downto 0);   -- number of valid 32 bit data words
   cmd_data_o   : out    std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);        -- 32bit valid data word
   cksum_err_o  : out    std_logic;                                           -- checksum error flag
   cmd_rdy_o    : out    std_logic;                                           -- command ready flag (checksum passed)
   data_clk_o   : out    std_logic                                            -- data clock
   );
end component;


end fibre_rx_pack;
