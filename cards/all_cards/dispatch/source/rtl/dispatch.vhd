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
-- Project:	      SCUBA-2
-- Author:        Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Top-level file for dispatch module
--
-- Revision history:
-- 
-- $Log$
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library components;
use components.component_pack.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

library work;
use work.dispatch_pack.all;

entity dispatch is
generic(CARD : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0) := CLOCK_CARD);
port(clk_i      : in std_logic;
     mem_clk_i  : in std_logic;
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
     dat_i 	: in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
     ack_i  : in std_logic;
     
     -- watchdog reset interface
     wdt_rst_o : out std_logic);
end dispatch;

architecture rtl of dispatch is
type dispatch_states is (FETCH, EXECUTE, REPLY);
signal pres_state : dispatch_states;
signal next_state : dispatch_states;

signal cmd_rdy      : std_logic;
signal cmd_err      : std_logic;
signal wb_cmd_rdy   : std_logic;
signal wb_reply_rdy : std_logic;
signal reply_rdy    : std_logic;
signal reply_ack    : std_logic;

signal uop_status_ld : std_logic;

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
signal cmd_buf_wrdata : std_logic_vector(BUF_DATA_WIDTH-1 downto 0);
signal cmd_buf_wraddr : std_logic_vector(BUF_ADDR_WIDTH-1 downto 0);
signal cmd_buf_rddata : std_logic_vector(BUF_DATA_WIDTH-1 downto 0);
signal cmd_buf_rdaddr : std_logic_vector(BUF_ADDR_WIDTH-1 downto 0);

signal reply_buf_wren   : std_logic;
signal reply_buf_wrdata : std_logic_vector(BUF_DATA_WIDTH-1 downto 0);
signal reply_buf_wraddr : std_logic_vector(BUF_ADDR_WIDTH-1 downto 0);
signal reply_buf_rddata : std_logic_vector(BUF_DATA_WIDTH-1 downto 0);
signal reply_buf_rdaddr : std_logic_vector(BUF_ADDR_WIDTH-1 downto 0);

begin
   
   receiver : dispatch_cmd_receive
   generic map(CARD => CARD)
   port map(clk_i      => clk_i,
            comm_clk_i => comm_clk_i,
            rst_i      => rst_i,
            lvds_cmd_i => lvds_cmd_i,
            cmd_rdy_o  => cmd_rdy,
            cmd_err_o  => cmd_err,
            header0_o  => cmd_hdr0,
            header1_o  => cmd_hdr1,
            buf_data_o => cmd_buf_wrdata,
            buf_addr_o => cmd_buf_wraddr,
            buf_wren_o => cmd_buf_wren);
   
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
            
   receive_buf : dispatch_data_buf
   port map(data      => cmd_buf_wrdata,
            wren      => cmd_buf_wren,
            wraddress => cmd_buf_wraddr,
            rdaddress => cmd_buf_rdaddr,
            clock     => mem_clk_i,
            q         => cmd_buf_rddata);
   
   wishbone : dispatch_wishbone
   port map(clk_i            => clk_i,
            rst_i            => rst_i,
            cmd_rdy_i        => wb_cmd_rdy,
            data_size_i      => cmd_header0(BB_DATA_SIZE'range),
            cmd_type_i       => cmd_header0(BB_COMMAND_TYPE'range),
            param_id_i       => cmd_header1(BB_PARAMETER_ID'range),
            cmd_buf_data_i   => cmd_buf_rddata,
            cmd_buf_addr_o   => cmd_buf_rdaddr,
            reply_rdy_o      => wb_reply_rdy,
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
            dat_i           	=> dat_i,
            ack_i            => ack_i,
            wdt_rst_o        => wdt_rst_o);
   
   transmitter : dispatch_reply_transmit
   port map(clk_i       => clk_i,
            comm_clk_i  => comm_clk_i,
            rst_i       => rst_i,
            lvds_tx_o   => lvds_reply_o,
            reply_rdy_i => reply_rdy,
            reply_ack_o => reply_ack,
            header0_i   => reply_header0,
            header1_i   => reply_header1,
            header2_i   => reply_header2,
            buf_data_i  => reply_buf_rddata,
            buf_addr_o  => reply_buf_rdaddr);

   reply_data_size <= cmd_header0(BB_DATA_SIZE'range) when (cmd_header0(BB_COMMAND_TYPE'range) = READ_BLOCK or 
                                                            cmd_header0(BB_COMMAND_TYPE'range) = DATA) 
                                                      else (others => '0');
   
   reply_hdr0 <= cmd_header0(BB_PREAMBLE'range) & cmd_header0(BB_COMMAND_TYPE'range) & reply_data_size;
   reply_hdr1 <= cmd_header1;
   reply_hdr2 <= (SUCCESS & "000000000000000000000000") when (cmd_rdy = '1') else
                 (FAIL    & "000000000000000000000000") when (cmd_err = '1') else
                 (others => '0');
                                                      
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
            ena_i => uop_status_ld,
            reg_i => reply_hdr2,
            reg_o => reply_header2);
                 
   transmit_buf : dispatch_data_buf
   port map(data      => reply_buf_wrdata,
            wren      => reply_buf_wren,
            wraddress => reply_buf_wraddr,
            rdaddress => reply_buf_rdaddr,
            clock     => mem_clk_i,
            q         => reply_buf_rddata);            
            
            
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
   
   stateNS: process(pres_state, cmd_rdy, cmd_err, wb_reply_rdy, reply_ack)
   begin
      case pres_state is
         when FETCH =>   if(cmd_rdy = '1') then
                            next_state <= EXECUTE;
                         elsif(cmd_err = '1') then
                            next_state <= REPLY;
                         else
                            next_state <= FETCH;
                         end if;
                         
         when EXECUTE => if(wb_reply_rdy = '1') then
                            next_state <= REPLY;
                         else
                            next_state <= EXECUTE;
                         end if;
                         
         when REPLY =>   if(reply_ack = '1') then
                            next_state <= FETCH;
                         else
                            next_state <= REPLY;
                         end if;
         
         when others =>  next_state <= FETCH;
      end case;
   end process stateNS;
   
   stateOut: process(pres_state)
   begin
      cmd_hdr_ld    <= '0';
      uop_status_ld <= '0';      
      wb_cmd_rdy    <= '0';
      reply_rdy     <= '0';
      
      case pres_state is
         when FETCH =>   cmd_hdr_ld    <= '1';                         
                         uop_status_ld <= '1';
         
         when EXECUTE => wb_cmd_rdy <= '1';
         
         when REPLY =>   reply_rdy <= '1';
         
         when others =>  null;
      end case;
   end process stateOut;
end rtl;