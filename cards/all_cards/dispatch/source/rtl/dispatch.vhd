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
-- dispatch.vhd
--
-- Project:       SCUBA-2
-- Author:        Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Top-level file for dispatch module
--
-- Revision history:
--
-- $Log: dispatch.vhd,v $
-- Revision 1.14  2007/12/18 20:21:06  bburger
-- BB:  Added a default state assignment to the FSM to lessen the likelyhood of uncontrolled state transitions
--
-- Revision 1.13  2006/04/03 19:38:52  mandana
-- make mainline adhere Rev. C backplane slot ids
--
-- Revision 1.12  2006/03/16 19:17:31  bburger
-- Bryce:  added a section for decoding slot ids if using bus backplane revC.  Now, all we need to do is comment out one section, and uncomment the other to switch from revA/B <--> C
--
-- Revision 1.11  2006/01/16 20:02:48  bburger
-- Ernie:   Added dip_sw interfaces to introduce artifical crc rx/tx errors on the busbackplan.  This feature is for testing purposes only.
--
-- Revision 1.10  2005/12/02 00:38:38  erniel
-- buffer is now pipeline mode (previously flow-through mode)
-- removed need for inverted clock
--
-- Revision 1.9  2005/10/28 01:21:53  erniel
-- moved component declarations from dispatch_pack
-- replaced separate cmd and reply buffers with single buffer and multiplexed access via FSM
-- changed behaviour of status register
-- rewrote slot_id decode
-- rewrote reply headers encode (new bus backplane protocol compliant)
-- signal name changes
--
-- Revision 1.8  2005/03/19 00:12:35  erniel
-- oops...forgot to connect n_clk
--
-- Revision 1.7  2005/03/18 23:14:19  erniel
-- replaced obsolete dispatch_data_buf with direct altsyncram instantiation
-- changed buffer addr & data bus size constant names
--
-- Revision 1.6  2005/01/11 20:49:29  erniel
-- removed unnecessary mem_clk_i port
--
-- Revision 1.5  2005/01/11 20:40:12  erniel
-- replaced CARD generic with slot_id & decoder
-- updated dispatch cmd_receive component
-- updated dispatch_reply_transmit component
--
-- Revision 1.4  2004/12/16 01:46:47  erniel
-- added mem_clk port to disaptch_reply_transmit
--
-- Revision 1.3  2004/11/26 01:41:38  erniel
-- added support for status/error bits
--
-- Revision 1.2  2004/10/13 04:02:35  erniel
-- added registers for command and reply packet headers
-- modified reply packet data size logic
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

library components;
use components.component_pack.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

entity dispatch is
port(
   clk_i      : in std_logic;
   comm_clk_i : in std_logic;
   rst_i      : in std_logic;

   -- bus backplane interface (LVDS)
   lvds_cmd_i   : in std_logic;
   lvds_replya_o : out std_logic;
   lvds_replyb_o : out std_logic;

   -- wishbone slave interface
   dat_o  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   addr_o : out std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
   tga_o  : out std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
   we_o   : out std_logic;
   stb_o  : out std_logic;
   cyc_o  : out std_logic;
   dat_i  : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   ack_i  : in std_logic;
   err_i  : in std_logic;

   -- misc. external interface
   wdt_rst_o : out std_logic;
   slot_i    : in std_logic_vector(3 downto 0);

   -- test interface
   dip_sw3 : in std_logic;
   dip_sw4 : in std_logic
);
end dispatch;

architecture rtl of dispatch is

   component dispatch_cmd_receive
   port(
      clk_i       : in std_logic;
      comm_clk_i  : in std_logic;
      rst_i       : in std_logic;
      lvds_cmd_i  : in std_logic;
      card_i      : in std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0);
      cmd_done_o  : out std_logic;
      cmd_error_o : out std_logic;
      header0_o   : out std_logic_vector(31 downto 0);
      header1_o   : out std_logic_vector(31 downto 0);
      buf_data_o  : out std_logic_vector(31 downto 0);
      buf_addr_o  : out std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
      buf_wren_o  : out std_logic;
      dip_sw      : in std_logic
   );
   end component;

   component dispatch_wishbone
   port(
      clk_i           : in std_logic;
      rst_i           : in std_logic;
      header0_i       : in std_logic_vector(31 downto 0);
      header1_i       : in std_logic_vector(31 downto 0);
      buf_data_i      : in std_logic_vector(31 downto 0);
      buf_data_o      : out std_logic_vector(31 downto 0);
      buf_addr_o      : out std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
      buf_wren_o      : out std_logic;
      execute_start_i : in std_logic;
      execute_done_o  : out std_logic;
      execute_error_o : out std_logic;
      dat_o           : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_o          : out std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_o           : out std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_o            : out std_logic;
      stb_o           : out std_logic;
      cyc_o           : out std_logic;
      dat_i           : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_i           : in std_logic;
      err_i           : in std_logic;
      wdt_rst_o       : out std_logic
   );
   end component;

   component dispatch_reply_transmit
   port(
      clk_i      : in std_logic;
      rst_i      : in std_logic;

      lvds_txa_o : out std_logic;
      lvds_txb_o : out std_logic;

      -- Start/done signals:
      reply_start_i : in std_logic;
      reply_done_o  : out std_logic;

      -- Command header words:
      header0_i : in std_logic_vector(31 downto 0);
      header1_i : in std_logic_vector(31 downto 0);

      -- Buffer interface:
      buf_data_i : in std_logic_vector(31 downto 0);
      buf_addr_o : out std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);

      -- test interface
      dip_sw : in std_logic
   );
   end component;

   type dispatch_states is (INITIALIZE, FETCH, EXECUTE, REPLY, DUMMY);
   signal pres_state : dispatch_states;
   signal next_state : dispatch_states;

   signal cmd_done      : std_logic;
   signal cmd_error     : std_logic;
   signal execute_start : std_logic;
   signal execute_done  : std_logic;
   signal execute_error : std_logic;
   signal reply_start   : std_logic;
   signal reply_done    : std_logic;

   signal status_clr : std_logic;
   signal status     : std_logic_vector(BB_STATUS_WIDTH-1 downto 0);

   signal header_ld     : std_logic;
   signal rx_header0    : std_logic_vector(31 downto 0);
   signal rx_header1    : std_logic_vector(31 downto 0);
   signal cmd_header0   : std_logic_vector(31 downto 0);
   signal cmd_header1   : std_logic_vector(31 downto 0);
   signal reply_header0 : std_logic_vector(31 downto 0);
   signal reply_header1 : std_logic_vector(31 downto 0);

   signal cmd_buf_wren : std_logic;
   signal wb_buf_wren  : std_logic;
   signal buf_wren     : std_logic;

   signal cmd_buf_data : std_logic_vector(31 downto 0);
   signal wb_buf_data  : std_logic_vector(31 downto 0);
   signal buf_wrdata   : std_logic_vector(31 downto 0);
   signal buf_rddata   : std_logic_vector(31 downto 0);

   signal cmd_buf_addr   : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
   signal wb_buf_addr    : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
   signal reply_buf_addr : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
   signal buf_wraddr     : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
   signal buf_rdaddr     : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);

   signal card : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0);

begin

   receiver : dispatch_cmd_receive
   port map(
      clk_i        => clk_i,
      comm_clk_i   => comm_clk_i,
      rst_i        => rst_i,
      lvds_cmd_i   => lvds_cmd_i,
      card_i       => card,
      cmd_done_o   => cmd_done,
      cmd_error_o  => cmd_error,
      header0_o    => rx_header0,
      header1_o    => rx_header1,
      buf_data_o   => cmd_buf_data,
      buf_addr_o   => cmd_buf_addr,
      buf_wren_o   => cmd_buf_wren,
      dip_sw       => dip_sw3
   );

   wishbone : dispatch_wishbone
   port map(
      clk_i           => clk_i,
      rst_i           => rst_i,
      header0_i       => cmd_header0,
      header1_i       => cmd_header1,
      buf_data_i      => buf_rddata,
      buf_data_o      => wb_buf_data,
      buf_addr_o      => wb_buf_addr,
      buf_wren_o      => wb_buf_wren,
      execute_start_i => execute_start,
      execute_done_o  => execute_done,
      execute_error_o => execute_error,
      dat_o           => dat_o,
      addr_o          => addr_o,
      tga_o           => tga_o,
      we_o            => we_o,
      stb_o           => stb_o,
      cyc_o           => cyc_o,
      dat_i           => dat_i,
      ack_i           => ack_i,
      err_i           => err_i,
      wdt_rst_o       => wdt_rst_o
   );

   transmitter : dispatch_reply_transmit
   port map(
      clk_i         => clk_i,
      rst_i         => rst_i,
      lvds_txa_o    => lvds_replya_o,
      lvds_txb_o    => lvds_replyb_o,
      reply_start_i => reply_start,
      reply_done_o  => reply_done,
      header0_i     => reply_header0,
      header1_i     => reply_header1,
      buf_data_i    => buf_rddata,
      buf_addr_o    => reply_buf_addr,
      dip_sw        => dip_sw4
   );

   ---------------------------------------------------------
   -- Storage for Headers and Data
   ---------------------------------------------------------

   hdr0 : reg
   generic map(WIDTH => 32)
   port map(
      clk_i => clk_i,
      rst_i => rst_i,
      ena_i => header_ld,
      reg_i => rx_header0,
      reg_o => cmd_header0
   );

   hdr1 : reg
   generic map(WIDTH => 32)
   port map(
      clk_i => clk_i,
      rst_i => rst_i,
      ena_i => header_ld,
      reg_i => rx_header1,
      reg_o => cmd_header1
   );

   buf : altsyncram
   generic map(
      operation_mode         => "DUAL_PORT",
      width_a                => 32,
      widthad_a              => BB_DATA_SIZE_WIDTH,
      width_b                => 32,
      widthad_b              => BB_DATA_SIZE_WIDTH,
      lpm_type               => "altsyncram",
      width_byteena_a        => 1,
      outdata_reg_b          => "UNREGISTERED",
      indata_aclr_a          => "NONE",
      wrcontrol_aclr_a       => "NONE",
      address_aclr_a         => "NONE",
      address_reg_b          => "CLOCK0",
      address_aclr_b         => "NONE",
      outdata_aclr_b         => "NONE",
      ram_block_type         => "AUTO",
      intended_device_family => "Stratix")
   port map(
      clock0    => clk_i,
      wren_a    => buf_wren,
      address_a => buf_wraddr,
      data_a    => buf_wrdata,
      address_b => buf_rdaddr,
      q_b       => buf_rddata
   );


   ---------------------------------------------------------
   -- Glue Logic
   ---------------------------------------------------------
--   -- For Bus Backplane Rev. A and B
--   -- slot ID decode logic:
--   slot_decode: process(slot_i)
--   begin
--      case slot_i is
--         when "0000" => card <= (others => '1');
--         when "0001" => card <= (others => '1');
--         when "0010" => card <= (others => '1');
--         when "0011" => card <= (others => '1');
--         when "0100" => card <= (others => '1');
--         when "0101" => card <= (others => '1');
--         when "0110" => card <= READOUT_CARD_3;
--         when "0111" => card <= READOUT_CARD_4;
--         when "1000" => card <= CLOCK_CARD;
--         when "1001" => card <= POWER_SUPPLY_CARD;
--         when "1010" => card <= READOUT_CARD_2;
--         when "1011" => card <= READOUT_CARD_1;
--         when "1100" => card <= BIAS_CARD_3;
--         when "1101" => card <= BIAS_CARD_2;
--         when "1110" => card <= BIAS_CARD_1;
--         when "1111" => card <= ADDRESS_CARD;
--         when others => card <= (others => '1');
--      end case;
--   end process slot_decode;

   -- For Bus Backplane Rev. C
   -- slot ID decode logic:
   slot_decode: process(slot_i)
   begin
      case slot_i is
         when "0000" => card <= ADDRESS_CARD;
         when "0001" => card <= BIAS_CARD_1;
         when "0010" => card <= BIAS_CARD_2;
         when "0011" => card <= BIAS_CARD_3;
         when "0100" => card <= READOUT_CARD_1;
         when "0101" => card <= READOUT_CARD_2;
         when "0110" => card <= READOUT_CARD_3;
         when "0111" => card <= READOUT_CARD_4;
         when "1000" => card <= CLOCK_CARD;
         when "1001" => card <= POWER_SUPPLY_CARD;
         when "1010" => card <= (others => '1');
         when "1011" => card <= (others => '1');
         when "1100" => card <= (others => '1');
         when "1101" => card <= (others => '1');
         when "1110" => card <= (others => '1');
         when "1111" => card <= (others => '1');
         when others => card <= (others => '1');
      end case;
   end process slot_decode;

   -- status register:
   status_reg: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         status <= (others => '0');
      elsif(clk_i = '1' and clk_i'event) then
         if(status_clr = '1') then
            status <= (others => '0');  -- status bits are reset only when status_clr asserted (during initialize state)
         else
            if(cmd_error = '1') then    -- status bits are set when an error happens
               status(0) <= '1';
            end if;

            if(execute_error = '1') then
               status(1) <= '1';
            end if;
         end if;
      end if;
   end process status_reg;

   -- reply header encode logic:
   reply_header0(BB_PREAMBLE'range)     <= cmd_header0(BB_PREAMBLE'range);
   reply_header0(BB_COMMAND_TYPE'range) <= cmd_header0(BB_COMMAND_TYPE'range);
   reply_header0(BB_DATA_SIZE'range)    <= (others => '0') when cmd_header0(BB_COMMAND_TYPE'range) = WRITE_CMD else cmd_header0(BB_DATA_SIZE'range);

   reply_header1(BB_CARD_ADDRESS'range) <= cmd_header1(BB_CARD_ADDRESS'range);
   reply_header1(BB_PARAMETER_ID'range) <= cmd_header1(BB_PARAMETER_ID'range);
   reply_header1(BB_STATUS'range)       <= status;


   ---------------------------------------------------------
   -- Dispatch Control FSM
   ---------------------------------------------------------

   stateFF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         pres_state <= INITIALIZE;
      elsif(clk_i = '1' and clk_i'event) then
         pres_state <= next_state;
      end if;
   end process stateFF;

   stateNS: process(pres_state, cmd_done, cmd_error, execute_done, reply_done)
   begin
      -- Default Assignment
      next_state <= pres_state;

      case pres_state is
         when INITIALIZE =>
            next_state <= DUMMY;

         when DUMMY =>
            next_state <= FETCH;

         when FETCH =>
            if(cmd_done = '1') then
               if(cmd_error = '1') then
                  next_state <= REPLY;       -- if there are errors in received command packet, send error reply packet
               else
                  next_state <= EXECUTE;     -- otherwise execute command
               end if;
            end if;

         when EXECUTE =>
            if(execute_done = '1') then
               next_state <= REPLY;
            end if;

         when REPLY =>
            if(reply_done = '1') then
               next_state <= INITIALIZE;
            end if;

         when others =>
            next_state <= INITIALIZE;

      end case;
   end process stateNS;

   stateOut: process(pres_state, cmd_buf_wren, cmd_buf_addr, cmd_buf_data, wb_buf_wren, wb_buf_addr, wb_buf_data, reply_buf_addr)
   begin
      status_clr    <= '0';
      header_ld     <= '0';
      execute_start <= '0';
      reply_start   <= '0';
      buf_wren      <= '0';
      buf_wraddr    <= (others => '0');
      buf_wrdata    <= (others => '0');
      buf_rdaddr    <= (others => '0');

      case pres_state is
         when INITIALIZE =>
            status_clr    <= '1';

         when DUMMY => null;

         when FETCH =>
            header_ld     <= '1';
            buf_wren      <= cmd_buf_wren;
            buf_wraddr    <= cmd_buf_addr;
            buf_wrdata    <= cmd_buf_data;

         when EXECUTE =>
            execute_start <= '1';
            buf_wren      <= wb_buf_wren;
            buf_wraddr    <= wb_buf_addr;
            buf_wrdata    <= wb_buf_data;
            buf_rdaddr    <= wb_buf_addr;

         when REPLY =>
            reply_start   <= '1';
            buf_rdaddr    <= reply_buf_addr;

         when others =>     null;
      end case;
   end process stateOut;
end rtl;