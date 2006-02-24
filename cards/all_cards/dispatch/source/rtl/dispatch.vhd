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

library work;
use work.dispatch_pack.all;
use work.slot_id_pack.all;

entity dispatch is
port(clk_i      : in std_logic;
     comm_clk_i : in std_logic;
     rst_i      : in std_logic;     
     
     -- bus backplane interface (LVDS)
     lvds_cmd_i   : in std_logic;
     lvds_reply_o : out std_logic;
     
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
     slot_i    : in std_logic_vector(SLOT_ID_BITS-1 downto 0));
end dispatch;

architecture rtl of dispatch is
type dispatch_states is (INITIALIZE, FETCH, EXECUTE, REPLY);
signal pres_state : dispatch_states;
signal next_state : dispatch_states;

signal cmd_rdy      : std_logic;
signal cmd_err      : std_logic;
signal wb_cmd_rdy   : std_logic;
signal wb_rdy       : std_logic;
signal wb_err       : std_logic;
signal reply_rdy    : std_logic;
signal reply_ack    : std_logic;

signal uop_status_ld : std_logic;

signal status_clr : std_logic;
signal status_reg : std_logic_vector(1 downto 0);

signal reply_data_size : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);

signal cmd_hdr0   : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
signal cmd_hdr1   : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
signal reply_hdr0 : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
signal reply_hdr1 : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
signal reply_hdr2 : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);

signal cmd_header0   : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
signal cmd_header1   : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
signal reply_header0 : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
signal reply_header1 : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
signal reply_header2 : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);

signal cmd_hdr_ld   : std_logic;

signal cmd_buf_wren   : std_logic;
signal cmd_buf_wrdata : std_logic_vector(CMD_BUF_DATA_WIDTH-1 downto 0);
signal cmd_buf_wraddr : std_logic_vector(CMD_BUF_ADDR_WIDTH-1 downto 0);
signal cmd_buf_rddata : std_logic_vector(CMD_BUF_DATA_WIDTH-1 downto 0);
signal cmd_buf_rdaddr : std_logic_vector(CMD_BUF_ADDR_WIDTH-1 downto 0);

signal reply_buf_wren   : std_logic;
signal reply_buf_wrdata : std_logic_vector(REPLY_BUF_DATA_WIDTH-1 downto 0);
signal reply_buf_wraddr : std_logic_vector(REPLY_BUF_ADDR_WIDTH-1 downto 0);
signal reply_buf_rddata : std_logic_vector(REPLY_BUF_DATA_WIDTH-1 downto 0);
signal reply_buf_rdaddr : std_logic_vector(REPLY_BUF_ADDR_WIDTH-1 downto 0);

signal card : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0);

signal n_clk : std_logic;

begin
   
   -- inverted clock for buffers:
   n_clk <= not clk_i;
   
   
   receiver : dispatch_cmd_receive
   port map(clk_i      => clk_i,
            comm_clk_i => comm_clk_i,
            rst_i      => rst_i,
            lvds_cmd_i => lvds_cmd_i,
            card_i     => card,
            cmd_rdy_o  => cmd_rdy,
            cmd_err_o  => cmd_err,
            header0_o  => cmd_hdr0,
            header1_o  => cmd_hdr1,
            buf_data_o => cmd_buf_wrdata,
            buf_addr_o => cmd_buf_wraddr,
            buf_wren_o => cmd_buf_wren);
            
   with slot_i select
      card <= ADDRESS_CARD      when "0000",
              BIAS_CARD_1       when "0001",
              BIAS_CARD_2       when "0010",
              BIAS_CARD_3       when "0011",
              READOUT_CARD_1    when "0100",
              READOUT_CARD_2    when "1010",
              READOUT_CARD_3    when "0110",
              READOUT_CARD_4    when "0111",
              CLOCK_CARD        when "1000",
              POWER_SUPPLY_CARD when "1001",
              (others => '1')   when others;
   
   cmd0 : reg
   generic map(WIDTH => PACKET_WORD_WIDTH)
   port map(clk_i => clk_i,
            rst_i => rst_i,
            ena_i => cmd_hdr_ld,
            reg_i => cmd_hdr0,
            reg_o => cmd_header0);
   
   cmd1 : reg
   generic map(WIDTH => PACKET_WORD_WIDTH)
   port map(clk_i => clk_i,
            rst_i => rst_i,
            ena_i => cmd_hdr_ld,
            reg_i => cmd_hdr1,
            reg_o => cmd_header1);

   receive_buf : altsyncram
   generic map(operation_mode         => "DUAL_PORT",
               width_a                => CMD_BUF_DATA_WIDTH,
               widthad_a              => CMD_BUF_ADDR_WIDTH,
               width_b                => CMD_BUF_DATA_WIDTH,
               widthad_b              => CMD_BUF_ADDR_WIDTH,
               lpm_type               => "altsyncram",
               width_byteena_a        => 1,
               outdata_reg_b          => "UNREGISTERED",
               indata_aclr_a          => "NONE",
               wrcontrol_aclr_a       => "NONE",
               address_aclr_a         => "NONE",
               address_reg_b          => "CLOCK1",
               address_aclr_b         => "NONE",
               outdata_aclr_b         => "NONE",
               ram_block_type         => "AUTO",
               intended_device_family => "Stratix")
   port map(clock0    => clk_i,
            clock1    => n_clk,
            wren_a    => cmd_buf_wren,
            address_a => cmd_buf_wraddr,
            data_a    => cmd_buf_wrdata,
            address_b => cmd_buf_rdaddr,
            q_b       => cmd_buf_rddata);
   
   wishbone : dispatch_wishbone
   port map(clk_i            => clk_i,
            rst_i            => rst_i,
            cmd_rdy_i        => wb_cmd_rdy,
            data_size_i      => cmd_header0(BB_DATA_SIZE'range),
            cmd_type_i       => cmd_header0(BB_COMMAND_TYPE'range),
            param_id_i       => cmd_header1(BB_PARAMETER_ID'range),
            cmd_buf_data_i   => cmd_buf_rddata,
            cmd_buf_addr_o   => cmd_buf_rdaddr,
            wb_rdy_o         => wb_rdy,
            wb_err_o         => wb_err,
            reply_buf_data_o => reply_buf_wrdata,
            reply_buf_addr_o => reply_buf_wraddr,
            reply_buf_wren_o => reply_buf_wren,
            wait_i           => '0',
            dat_o            => dat_o,
            addr_o           => addr_o,
            tga_o            => tga_o,
            we_o             => we_o,
            stb_o            => stb_o,
            cyc_o            => cyc_o,
            dat_i             => dat_i,
            ack_i            => ack_i,
            err_i            => err_i,
            wdt_rst_o        => wdt_rst_o);
   
   transmitter : dispatch_reply_transmit
   port map(clk_i       => clk_i,
            rst_i       => rst_i,
            lvds_tx_o   => lvds_reply_o,
            reply_rdy_i => reply_rdy,
            reply_ack_o => reply_ack,
            header0_i   => reply_header0,
            header1_i   => reply_header1,
            header2_i   => reply_header2,
            buf_data_i  => reply_buf_rddata,
            buf_addr_o  => reply_buf_rdaddr);
   
   -- reply data size = 0 for WRITE commands, data size field otherwise         
   reply_data_size <= (others => '0') when cmd_header0(BB_COMMAND_TYPE'range) = WRITE_CMD else cmd_header0(BB_DATA_SIZE'range);
   
   reply_hdr0 <= cmd_header0(BB_PREAMBLE'range) & cmd_header0(BB_COMMAND_TYPE'range) & reply_data_size;
   reply_hdr1 <= cmd_header1;
   reply_hdr2 <= status_reg & "000000000000000000000000000000";
                                        
   reply0 : reg
   generic map(WIDTH => PACKET_WORD_WIDTH)
   port map(clk_i => clk_i,
            rst_i => rst_i,
            ena_i => '1',
            reg_i => reply_hdr0,
            reg_o => reply_header0);
            
   reply1 : reg
   generic map(WIDTH => PACKET_WORD_WIDTH)
   port map(clk_i => clk_i,
            rst_i => rst_i,
            ena_i => '1',
            reg_i => reply_hdr1,
            reg_o => reply_header1);
            
   reply2 : reg
   generic map(WIDTH => PACKET_WORD_WIDTH)
   port map(clk_i => clk_i,
            rst_i => rst_i,
            ena_i => '1',
            reg_i => reply_hdr2,
            reg_o => reply_header2);

   transmit_buf : altsyncram
   generic map(operation_mode         => "DUAL_PORT",
               width_a                => REPLY_BUF_DATA_WIDTH,
               widthad_a              => REPLY_BUF_ADDR_WIDTH,
               width_b                => REPLY_BUF_DATA_WIDTH,
               widthad_b              => REPLY_BUF_ADDR_WIDTH,
               lpm_type               => "altsyncram",
               width_byteena_a        => 1,
               outdata_reg_b          => "UNREGISTERED",
               indata_aclr_a          => "NONE",
               wrcontrol_aclr_a       => "NONE",
               address_aclr_a         => "NONE",
               address_reg_b          => "CLOCK1",
               address_aclr_b         => "NONE",
               outdata_aclr_b         => "NONE",
               ram_block_type         => "AUTO",
               intended_device_family => "Stratix")
   port map(clock0    => clk_i,
            clock1    => n_clk,
            wren_a    => reply_buf_wren,
            address_a => reply_buf_wraddr,
            data_a    => reply_buf_wrdata,
            address_b => reply_buf_rdaddr,
            q_b       => reply_buf_rddata);            
            
   
   ---------------------------------------------------------
   -- Status Register
   ---------------------------------------------------------
                    
   status : process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         status_reg <= (others => '0');
      elsif(clk_i = '1' and clk_i'event) then
         if(status_clr = '1') then
            status_reg <= (others => '0');
         elsif(cmd_err = '1') then
            status_reg(0) <= '1';
         elsif(wb_err = '1') then
            status_reg(1) <= '1';
         end if;
      end if;
   end process status;
   
   -- Error scenarios:
   --
   -- 1. CRC receive error     -> Send back error packet with CRC error flag.
   -- 2. WB slave non-existent -> WB intercon will allow bus cycle to complete, and assert err_i.  Send back full packet with WB error flag.
   
   ---------------------------------------------------------
   -- Dispatch Control FSM
   ---------------------------------------------------------
   
   stateFF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         pres_state <= FETCH;
      elsif(clk_i = '1' and clk_i'event) then
         pres_state <= next_state;
      end if;
   end process stateFF;
   
   stateNS: process(pres_state, cmd_rdy, cmd_err, wb_rdy, reply_ack)
   begin
      case pres_state is
         when INITIALIZE => next_state <= FETCH;
         
         when FETCH =>      if(cmd_rdy = '1') then
                               if(cmd_err = '1') then          -- if CRC error in command, reply immediately with error packet
                                  next_state <= REPLY;
                               else                            -- otherwise, process command
                                  next_state <= EXECUTE;
                               end if;
                            else
                               next_state <= FETCH;
                            end if;
                         
         when EXECUTE =>    if(wb_rdy = '1') then
                               next_state <= REPLY;
                            else
                               next_state <= EXECUTE;
                            end if;
                         
         when REPLY =>      if(reply_ack = '1') then
                               next_state <= INITIALIZE;
                            else
                               next_state <= REPLY;
                            end if;
         
         when others =>     next_state <= INITIALIZE;
      end case;
   end process stateNS;
   
   stateOut: process(pres_state)
   begin
      status_clr    <= '0';
      cmd_hdr_ld    <= '0';
      uop_status_ld <= '0';      
      wb_cmd_rdy    <= '0';
      reply_rdy     <= '0';
      
      case pres_state is
         when INITIALIZE => status_clr <= '1';
         
         when FETCH =>      cmd_hdr_ld    <= '1';                         
                            uop_status_ld <= '1';
         
         when EXECUTE =>    wb_cmd_rdy <= '1';
         
         when REPLY =>      reply_rdy <= '1';
         
         when others =>     null;
      end case;
   end process stateOut;
end rtl;