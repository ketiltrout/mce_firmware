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
-- Project:       SCUBA-2
-- Author:         Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Package file for dispatch block
--
-- Revision history:
-- 
-- $Log: dispatch_pack.vhd,v $
-- Revision 1.10  2005/01/11 20:51:48  erniel
-- updated dispatch_cmd_receive declaration
-- updated dispatch_reply_transmit declaration
-- updated dispatch top-level declaration
--
-- Revision 1.9  2004/12/16 01:47:44  erniel
-- added mem_clk port to disaptch_reply_transmit
--
-- Revision 1.8  2004/11/29 23:35:32  bench2
-- Greg: Added err_i and extended FIBRE_CHECKSUM_ERR to 8-bits for reply_argument in reply_translator.vhd
--
-- Revision 1.7  2004/11/26 01:35:13  erniel
-- updated dispatch_wishbone component
--
-- Revision 1.6  2004/10/13 04:37:38  erniel
-- corrected missing generic in dispatch component declaration
--
-- Revision 1.5  2004/10/13 03:57:50  erniel
-- added WATCHDOG_LIMIT constant
-- added component declaration for top-level
--
-- Revision 1.4  2004/09/27 23:00:24  erniel
-- added component declarations
-- moved constants to command_pack
--
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

library work;
use work.slot_id_pack.all;

package dispatch_pack is

   -- Watchdog timer limit, in microseconds:
   constant WATCHDOG_LIMIT : integer := 180000;
   
   -- CRC polynomial:
   constant CRC32 : std_logic_vector(31 downto 0) := "00000100110000010001110110110111";
   
   -- buffer declarations:
   constant MAX_DATA_WORDS : integer := (2**BB_DATA_SIZE_WIDTH);
   
   constant CMD_BUF_DATA_WIDTH : integer := PACKET_WORD_WIDTH;
   constant CMD_BUF_ADDR_WIDTH : integer := 6;   
   
   constant REPLY_BUF_DATA_WIDTH : integer := PACKET_WORD_WIDTH;
   constant REPLY_BUF_ADDR_WIDTH : integer := 9;
   
   -- component declarations:
   component dispatch_cmd_receive
   port(clk_i      : in std_logic;
        comm_clk_i : in std_logic;
        rst_i      : in std_logic;     
        lvds_cmd_i : in std_logic;
        card_i     : in std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0);
        cmd_rdy_o  : out std_logic; 
        cmd_err_o  : out std_logic; 
        header0_o  : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
        header1_o  : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
        buf_data_o : out std_logic_vector(CMD_BUF_DATA_WIDTH-1 downto 0);
        buf_addr_o : out std_logic_vector(CMD_BUF_ADDR_WIDTH-1 downto 0);
        buf_wren_o : out std_logic);
   end component;
   
   component dispatch_wishbone
   port(clk_i            : in std_logic;
        rst_i            : in std_logic;
        cmd_rdy_i        : in std_logic;
        data_size_i      : in std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
        cmd_type_i       : in std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0);     
        param_id_i       : in std_logic_vector(BB_PARAMETER_ID_WIDTH-1 downto 0); 
        cmd_buf_data_i   : in std_logic_vector(CMD_BUF_DATA_WIDTH-1 downto 0);
        cmd_buf_addr_o   : out std_logic_vector(CMD_BUF_ADDR_WIDTH-1 downto 0);
        wb_rdy_o         : out std_logic;
        wb_err_o         : out std_logic;
        reply_buf_data_o : out std_logic_vector(REPLY_BUF_DATA_WIDTH-1 downto 0);
        reply_buf_addr_o : out std_logic_vector(REPLY_BUF_ADDR_WIDTH-1 downto 0);
        reply_buf_wren_o : out std_logic;
        wait_i           : in std_logic;
        dat_o            : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
        addr_o           : out std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
        tga_o            : out std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
        we_o             : out std_logic;
        stb_o            : out std_logic;
        cyc_o            : out std_logic;
        dat_i              : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
        ack_i            : in std_logic;
        err_i            : in std_logic;
        wdt_rst_o        : out std_logic);
   end component;
   
   component dispatch_reply_transmit
   port(clk_i       : in std_logic;
        rst_i       : in std_logic;    
        lvds_tx_o   : out std_logic;
        reply_rdy_i : in std_logic;
        reply_ack_o : out std_logic; 
        header0_i   : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
        header1_i   : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
        header2_i   : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
        buf_data_i  : in std_logic_vector(REPLY_BUF_DATA_WIDTH-1 downto 0);
        buf_addr_o  : out std_logic_vector(REPLY_BUF_ADDR_WIDTH-1 downto 0));
   end component;
   
   component dispatch
   port(clk_i        : in std_logic;
        comm_clk_i   : in std_logic;
        rst_i        : in std_logic;      
        lvds_cmd_i   : in std_logic;
        lvds_reply_o : out std_logic;
        dat_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
        addr_o       : out std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
        tga_o        : out std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
        we_o         : out std_logic;
        stb_o        : out std_logic;
        cyc_o        : out std_logic;
        dat_i        : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
        ack_i        : in std_logic;
        err_i        : in std_logic;
        wdt_rst_o    : out std_logic;
        slot_i       : in std_logic_vector(SLOT_ID_BITS-1 downto 0));
   end component;
     
end dispatch_pack;