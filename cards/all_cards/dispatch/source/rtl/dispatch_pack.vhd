-- Copyright (c) 2003 SCUBA-2 Project
--                  All Rights Reserved
--
--  THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE SCUBA-2 Project
--  The copyright notice above does not evidence any
--  actual or intended publication of such source code.
--
--  SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
--  REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
--  MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
--  PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
--  THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.
--
-- For the purposes of this code the SCUBA-2 Project consists of the
-- following organisations.
--
-- UKATC, Royal Observatory, Blackford Hill Edinburgh EH9 3HJ
-- UBC,   University of British Columbia, Physics & Astronomy Department,
--        Vancouver BC, V6T 1Z1
--
--
-- dispatch_pack.vhd
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Package file for dispatch block
--
-- Revision history:
-- 
-- $Log: dispatch_pack.vhd,v $
-- Revision 1.3  2004/08/28 03:10:01  erniel
-- renamed some constants
--
-- Revision 1.2  2004/08/25 20:19:56  erniel
-- added packet field declarations
-- added buffer declarations
--
-- Revision 1.1  2004/08/04 19:43:19  erniel
-- initial version
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

package dispatch_pack is

   -- CRC polynomial:
   constant CRC32 : std_logic_vector(31 downto 0) := "00000100110000010001110110110111";
   
   -- buffer declarations:
   constant MAX_DATA_WORDS : integer := (2**BB_DATA_SIZE_WIDTH);
   constant BUF_DATA_WIDTH : integer := PACKET_WORD_WIDTH;
   constant BUF_ADDR_WIDTH : integer := 6;   
   
   -- component declarations:
   component dispatch_cmd_receive
   generic(CARD : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0) := READOUT_CARD_1);
   port(clk_i      : in std_logic;
        comm_clk_i : in std_logic;
        rst_i      : in std_logic;		
        lvds_cmd_i : in std_logic;
        cmd_rdy_o  : out std_logic; 
        cmd_err_o  : out std_logic; 
        header0_o  : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
        header1_o  : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
        buf_data_o : out std_logic_vector(BUF_DATA_WIDTH-1 downto 0);
        buf_addr_o : out std_logic_vector(BUF_ADDR_WIDTH-1 downto 0);
        buf_wren_o : out std_logic);
   end component;
   
   component dispatch_wishbone
   port(clk_i            : in std_logic;
        rst_i            : in std_logic;
        cmd_rdy_i        : in std_logic;
        data_size_i      : in std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
        cmd_type_i       : in std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0);     
        param_id_i       : in std_logic_vector(BB_PARAMETER_ID_WIDTH-1 downto 0); 
        cmd_buf_data_i   : in std_logic_vector(BUF_DATA_WIDTH-1 downto 0);
        cmd_buf_addr_o   : out std_logic_vector(BUF_ADDR_WIDTH-1 downto 0);
        reply_rdy_o      : out std_logic;
        reply_buf_data_o : out std_logic_vector(BUF_DATA_WIDTH-1 downto 0);
        reply_buf_addr_o : out std_logic_vector(BUF_ADDR_WIDTH-1 downto 0);
        reply_buf_wren_o : out std_logic;
        wait_i           : in std_logic;
        dat_o            : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
        addr_o           : out std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
        tga_o            : out std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
        we_o             : out std_logic;
        stb_o            : out std_logic;
        cyc_o            : out std_logic;
        dat_i           	: in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
        ack_i            : in std_logic;
        wdt_rst_o        : out std_logic);
   end component;
   
   component dispatch_reply_transmit
   port(clk_i       : in std_logic;
        comm_clk_i  : in std_logic;
        rst_i       : in std_logic;		
        lvds_tx_o   : out std_logic;
        reply_rdy_i : in std_logic;
        reply_ack_o : out std_logic; 
        header0_i   : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
        header1_i   : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
        header2_i   : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
        buf_data_i  : in std_logic_vector(BUF_DATA_WIDTH-1 downto 0);
        buf_addr_o  : out std_logic_vector(BUF_ADDR_WIDTH-1 downto 0));
   end component;
   
   component dispatch_data_buf
   port(data      : in std_logic_vector (BUF_DATA_WIDTH-1 downto 0);
        wren      : in std_logic;
        wraddress : in std_logic_vector (BUF_ADDR_WIDTH-1 downto 0);
        rdaddress : in std_logic_vector (BUF_ADDR_WIDTH-1 downto 0);
        clock     : in std_logic;
        q         : out std_logic_vector (BUF_DATA_WIDTH-1 downto 0));
   end component;
   
end dispatch_pack;