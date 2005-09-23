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

type states is (IDLE, CHECK_FRAME, LOAD_BYTE0, LOAD_BYTE1, LOAD_BYTE2, LOAD_BYTE3, READY);
signal pres_state : states;
signal next_state : states;

signal buf_write    : std_logic; 
signal buf_read     : std_logic;
signal buf_full     : std_logic;  
signal buf_data_in  : std_logic_vector(8 downto 0); 
signal buf_data_out : std_logic_vector(8 downto 0); 
signal buf_used     : std_logic_vector(5 downto 0);
          
signal byte0_ld : std_logic;
signal byte1_ld : std_logic;
signal byte2_ld : std_logic;
signal byte3_ld : std_logic;

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
            rdusedw => buf_used); 
		
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
   
   process(pres_state, ack_i, buf_used, buf_data_out)
   begin
      case pres_state is
         when IDLE =>        if(buf_used >= 5) then                 -- wait until there are at least 5 bytes in buffer
                                next_state <= CHECK_FRAME;
                             else
                                next_state <= IDLE;
                             end if;
         
         when CHECK_FRAME => if(buf_data_out = HOTLINK_IDLE) then   -- check if first byte is Hotlink idle character:
                                next_state <= LOAD_BYTE0;              -- if it is, proceed to clock out data bytes
                             else
                                next_state <= IDLE;                    -- otherwise, return to idle state (synch. error)
                             end if; 

         when LOAD_BYTE0 =>  if(buf_data_out(8) = '0') then         -- check if byte is a special character (idle included):
                                next_state <= LOAD_BYTE1;              -- if not, copy the byte to register and move on
                             else
                                next_state <= LOAD_BYTE0;              -- otherwise wait here until you get a data byte
                             end if;
                   
         when LOAD_BYTE1 =>  if(buf_data_out(8) = '0') then
                                next_state <= LOAD_BYTE2;
                             else
                                next_state <= LOAD_BYTE1;
                             end if;
                         
         when LOAD_BYTE2 =>  if(buf_data_out(8) = '0') then
                                next_state <= LOAD_BYTE3;
                             else
                                next_state <= LOAD_BYTE2;
                             end if;
         
         when LOAD_BYTE3 =>  if(buf_data_out(8) = '0') then
                                next_state <= READY;
                             else
                                next_state <= LOAD_BYTE3;
                             end if;
         
         when READY =>       if(ack_i = '1') then                   -- assert ready until ack asserted
                                next_state <= IDLE;
                             else
                                next_state <= READY;
                             end if;
                            
         when others =>      next_state <= IDLE;
      end case;
   end process;
   
   process(pres_state, buf_used, buf_data_out)
   begin
      buf_read <= '0';
      byte0_ld <= '0';
      byte1_ld <= '0';
      byte2_ld <= '0';
      byte3_ld <= '0';
      rdy_o    <= '0';
      
      case pres_state is
         when IDLE =>        if(buf_used >= 5) then
                                buf_read <= '1';
                             end if;
         
         when CHECK_FRAME => if(buf_data_out = HOTLINK_IDLE) then
                                buf_read <= '1';
                             end if;
        
         when LOAD_BYTE0 =>  buf_read <= '1';
                             if(buf_data_out(8) = '0') then         -- if this byte is not a special char:
                                byte0_ld <= '1';                       -- copy it to output register
                             end if;
        
         when LOAD_BYTE1 =>  buf_read <= '1';
                             if(buf_data_out(8) = '0') then 
                                byte1_ld <= '1';
                             end if;
        
         when LOAD_BYTE2 =>  buf_read <= '1';
                             if(buf_data_out(8) = '0') then 
                                byte2_ld <= '1';
                             end if;
         
         when LOAD_BYTE3 =>  if(buf_data_out(8) = '0') then         -- if this byte is not a special char:
                                byte3_ld <= '1';                       -- copy it to output register
                             else
                                buf_read <= '1';                       -- otherwise, flush it out of the FIFO
                             end if;
         
         when READY =>       rdy_o    <= '1';
         
         when others =>      null;
      end case;
   end process;
   
end rtl;