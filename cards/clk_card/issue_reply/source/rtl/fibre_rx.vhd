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
-- fibre_rx.vhd
--
-- Project:	      SCUBA-2
-- Author:        Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Fibre optic receiver interface module
--
-- Revision history:
--
-- $Log: fibre_rx.vhd,v $
-- Revision 1.7  2005/09/23 00:28:38  erniel
-- changed FSM to ignore any special/idle characters that occur mid-word
--
-- Revision 1.6  2005/09/16 23:06:49  erniel
-- completely rewrote module:
--      interface changed to support 32-bit data natively
--      interface changed to support rdy/ack handshaking
--      added data framing synchronization check
--      combined modules that were previously separate
--      removed fibre_rx_protocol functionality
--      renamed entity ports
--
-- Revision 1.5  2004/11/24 01:15:52  bench2
-- Greg: Broke apart issue reply and created pack files for all of its sub-components
--
-- Revision 1.4  2004/10/11 13:32:15  dca
-- Changes due to fibre_rx_fifo becoming a synchronous FIFO megafunction.
--
-- Revision 1.3  2004/10/08 14:07:32  dca
-- updated due to parameter name changes in command_pack
--
-----------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

library components;
use components.component_pack.all;


entity fibre_rx is
port(clk_i : in std_logic; 
     rst_i : in std_logic; 

     dat_o : out std_logic_vector(31 downto 0);
     rdy_o : out std_logic;
     ack_i : in std_logic;
     
     fibre_refclk_o : out std_logic;
     fibre_clkr_i   : in std_logic;
     fibre_data_i   : in std_logic_vector (7 downto 0);
     fibre_nrdy_i   : in std_logic;
     fibre_rvs_i    : in std_logic;
     fibre_rso_i    : in std_logic;
     fibre_sc_nd_i  : in std_logic);
end fibre_rx;


architecture rtl of fibre_rx is 

constant HOTLINK_IDLE : std_logic_vector(8 downto 0) := "100000101";

type states is (IDLE, CHECK_FRAME, LOAD_BYTES, READY);
signal pres_state : states;
signal next_state : states;

signal buf_write    : std_logic; 
signal buf_read     : std_logic;
signal buf_full     : std_logic; 
signal buf_empty    : std_logic; 
signal buf_data_in  : std_logic_vector(8 downto 0); 
signal buf_data_out : std_logic_vector(8 downto 0); 
          
signal byte0_ld : std_logic;
signal byte1_ld : std_logic;
signal byte2_ld : std_logic;
signal byte3_ld : std_logic;

signal byte_count_ena : std_logic;
signal byte_count_clr : std_logic;
signal byte_count     : std_logic_vector(1 downto 0);

signal refclk : std_logic;
            
begin

   ---------------------------------------------------------
   -- Clock divider (generates reference clock)
   ---------------------------------------------------------
   
   process(rst_i, clk_i)
   begin
      if(rst_i = '1') then
         refclk <= '0';
      elsif(clk_i'event and clk_i = '1') then
         refclk <= not refclk;
      end if;
   end process;

   fibre_refclk_o <= refclk;
   
   
   ---------------------------------------------------------
   -- Receiver buffer (stores incoming byte + sc/nD bit)
   ---------------------------------------------------------
   
   fibre_rx_buffer : dcfifo
   generic map(intended_device_family  => "Stratix",
               lpm_width               => 9,
               lpm_numwords            => 64,
               lpm_widthu              => 6,
               clocks_are_synchronized => "FALSE",
               lpm_type                => "dcfifo",
               lpm_showahead           => "OFF",
               overflow_checking       => "ON",
               underflow_checking      => "ON",
               use_eab                 => "ON",
               add_ram_output_register => "OFF",
               lpm_hint                => "RAM_BLOCK_TYPE=AUTO")
   port map(wrclk   => fibre_clkr_i,
            rdclk   => clk_i,
            wrreq   => buf_write,
            rdreq   => buf_read,
            data    => buf_data_in,
            q       => buf_data_out,
            aclr    => rst_i,
            wrfull  => buf_full,
            rdempty => buf_empty); 
		
   buf_write <= not buf_full and not fibre_nrdy_i and not fibre_rvs_i and fibre_rso_i;   
   
   buf_data_in <= fibre_sc_nd_i & fibre_data_i;
   
   
   ---------------------------------------------------------
   -- Output registers
   ---------------------------------------------------------
   
   byte0_buffer : reg
   generic map(WIDTH => 8)
   port map(clk_i => clk_i,
            rst_i => rst_i,
            ena_i => byte0_ld,
            reg_i => buf_data_out(7 downto 0),
            reg_o => dat_o(7 downto 0));
   
   byte1_buffer : reg
   generic map(WIDTH => 8)
   port map(clk_i => clk_i,
            rst_i => rst_i,
            ena_i => byte1_ld,
            reg_i => buf_data_out(7 downto 0),
            reg_o => dat_o(15 downto 8));
   
   byte2_buffer : reg
   generic map(WIDTH => 8)
   port map(clk_i => clk_i,
            rst_i => rst_i,
            ena_i => byte2_ld,
            reg_i => buf_data_out(7 downto 0),
            reg_o => dat_o(23 downto 16));
   
   byte3_buffer : reg
   generic map(WIDTH => 8)
   port map(clk_i => clk_i,
            rst_i => rst_i,
            ena_i => byte3_ld,
            reg_i => buf_data_out(7 downto 0),
            reg_o => dat_o(31 downto 24));
             
   
   ---------------------------------------------------------
   -- Byte Counter
   ---------------------------------------------------------
   
   byte_counter : binary_counter
   generic map(WIDTH => 2)
   port map(clk_i   => clk_i,
            rst_i   => rst_i,
            ena_i   => byte_count_ena,
            up_i    => '1',
            load_i  => '0',
            clear_i => byte_count_clr,
            count_i => (others => '0'),
            count_o => byte_count);
            
            
   ---------------------------------------------------------
   -- Control FSM
   ---------------------------------------------------------
   
   process(rst_i, clk_i)
   begin
      if(rst_i = '1') then
         pres_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         pres_state <= next_state;
      end if;
   end process;
   
   process(pres_state, ack_i, buf_empty, buf_data_out, byte_count)
   begin
      case pres_state is
         when IDLE =>        if(buf_empty = '0') then                 -- wait until there is at least one byte
                                next_state <= CHECK_FRAME;
                             else
                                next_state <= IDLE;
                             end if;
         
         when CHECK_FRAME => if(buf_data_out /= HOTLINK_IDLE) then    -- if first byte is not IDLE, return to idle state
                                next_state <= IDLE;              
                             else
                                if(buf_empty = '0') then              -- otherwise, if there is at least one byte, proceed
                                   next_state <= LOAD_BYTES;
                                else
                                   next_state <= CHECK_FRAME;         -- otherwise, wait here until a byte is available
                                end if;
                             end if; 

         when LOAD_BYTES =>  if(buf_data_out(8) = '0' and byte_count = 3) then
                                next_state <= READY;                  -- if byte is data and we're on last byte, goto ready
                             else
                                next_state <= LOAD_BYTES;             -- otherwise load more bytes
                             end if;
      
         when READY =>       if(ack_i = '1') then                     -- if ack asserted, return to idle
                                next_state <= IDLE;
                             else
                                next_state <= READY;
                             end if;
                            
         when others =>      next_state <= IDLE;
      end case;
   end process;
   
   process(pres_state, buf_empty, buf_data_out, byte_count)
   begin
      buf_read       <= '0';
      byte0_ld       <= '0';
      byte1_ld       <= '0';
      byte2_ld       <= '0';
      byte3_ld       <= '0';
      byte_count_ena <= '0';
      byte_count_clr <= '0';
      rdy_o          <= '0';
      
      case pres_state is
         when IDLE =>        if(buf_empty = '0') then
                                buf_read <= '1';                      -- read new byte when available
                             end if;
                             byte_count_clr <= '1';                   -- reset byte counter
         
         when CHECK_FRAME => if(buf_data_out = HOTLINK_IDLE and buf_empty = '0') then
                                buf_read <= '1';                      -- read new byte when available and current one is not IDLE
                             end if;
        
         when LOAD_BYTES =>  if((buf_empty = '0' and byte_count < 3) or buf_data_out(8) = '1') then
                                buf_read <= '1';                      -- read new byte when available and not on last byte or current byte is special
                             end if;
                             
                             if(buf_empty = '0' and byte_count < 3) then
                                byte_count_ena <= '1';                -- increment byte counter when there is a byte avaialble
                             end if;
                             
                             case byte_count is
                                   when "00"   => byte0_ld <= '1';  
                                   when "01"   => byte1_ld <= '1';
                                   when "10"   => byte2_ld <= '1';
                                   when others => byte3_ld <= '1';
                             end case; 
                                      
         when READY =>       rdy_o    <= '1';
         
         when others =>      null;
      end case;
   end process;
   
end rtl;