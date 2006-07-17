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
-- fibre_tx.vhd
--
-- Project:       SCUBA-2
-- Author:        Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Fibre optic transmitter interface module
--
-- Revision history:
--
-- $Log: fibre_tx.vhd,v $
-- Revision 1.5  2005/09/22 19:53:08  erniel
-- modified FSM to transmit data at full speed (no idle between words)
--
-- Revision 1.4  2005/09/16 23:08:50  erniel
-- completely rewrote module:
--      interface changed to support 32-bit data natively
--      interface changed to support rdy/busy handshaking
--      combined modules that were previously separate
--      renamed entity ports
--
-- Revision 1.3  2004/11/24 01:15:52  bench2
-- Greg: Broke apart issue reply and created pack files for all of its sub-components
--
-- Revision 1.2  2004/10/12 14:19:59  dca
-- nTrp removed.  Various other changes due to fifo becoming synchronous.
--
-- Revision 1.1  2004/10/05 12:22:40  dca
-- moved from fibre_tx directory.
--
-- Revision 1.3  2004/09/29 14:56:41  dca
-- components declarations now in issue_reply_pack not fibre_tx_pack.
--
-- Revision 1.2  2004/09/29 14:26:18  dca
-- various signals removed from entity port
--
-- Revision 1.1  2004/08/31 12:58:30  dca
-- Initial Version
--
-----------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library components;
use components.component_pack.all;

library altera_mf;
use altera_mf.altera_mf_components.all;


entity fibre_tx is
port(clk_i  : in std_logic;
     rst_i  : in std_logic;
     
     dat_i  : in std_logic_vector(31 downto 0);
     rdy_i  : in std_logic;
     busy_o : out std_logic;    
     
     fibre_clk_i   : in std_logic;    
     fibre_clkw_o  : out std_logic;
     fibre_data_o  : out std_logic_vector(7 downto 0);
     fibre_sc_nd_o : out std_logic;
     fibre_nena_o  : out std_logic);
end fibre_tx;


architecture rtl of fibre_tx is 

type states is (IDLE, SEND_BYTE0, SEND_BYTE1, SEND_BYTE2, SEND_BYTE3);
signal pres_state : states;
signal next_state : states;

signal buf_read  : std_logic;
signal buf_empty : std_logic;
signal buf_data  : std_logic_vector(31 downto 0);
        
begin

   fibre_clkw_o <= fibre_clk_i;
   fibre_sc_nd_o <= '0';
 
 
   ---------------------------------------------------------
   -- Transmitter buffer 
   ---------------------------------------------------------
   
   fibre_tx_buffer : dcfifo
   generic map(intended_device_family  => "Stratix",
               lpm_width               => 32,
               lpm_numwords            => 64,
               lpm_widthu              => 6,
               clocks_are_synchronized => "TRUE",
               lpm_type                => "dcfifo",
               lpm_showahead           => "OFF",
               overflow_checking       => "ON",
               underflow_checking      => "ON",
               use_eab                 => "ON",
               add_ram_output_register => "OFF",
               lpm_hint                => "RAM_BLOCK_TYPE=AUTO")
   port map(wrclk   => clk_i,
            rdclk   => fibre_clk_i, 
            wrreq   => rdy_i,
            rdreq   => buf_read,
            data    => dat_i,              
            q       => buf_data,
            aclr    => rst_i,
            wrfull  => busy_o,            
            rdempty => buf_empty);


   ---------------------------------------------------------
   -- Control FSM
   ---------------------------------------------------------
               
--   process(rst_i, fibre_clk_i)
   process(fibre_clk_i)
   begin
--      if(rst_i = '1') then
--         pres_state <= IDLE;
--      elsif(fibre_clk_i'event and fibre_clk_i = '1') then
      if(fibre_clk_i'event and fibre_clk_i = '1') then
         pres_state <= next_state;
      end if;
   end process;
   
   process(pres_state, buf_empty)
   begin
      case pres_state is
         when IDLE =>       if(buf_empty = '0') then      -- if there is a word in the buffer, start sending
                               next_state <= SEND_BYTE0;
                            else
                               next_state <= IDLE;
                            end if;
         
         when SEND_BYTE0 => next_state <= SEND_BYTE1;     -- send 4 bytes in 4 consecutive clock cycles
         
         when SEND_BYTE1 => next_state <= SEND_BYTE2;                         
         
         when SEND_BYTE2 => next_state <= SEND_BYTE3;
         
         when SEND_BYTE3 => if(buf_empty = '0') then
                               next_state <= SEND_BYTE0;
                            else
                               next_state <= IDLE;     
                            end if;
         
         when others =>     next_state <= IDLE;
      end case;
   end process;
   
   process(pres_state, buf_empty, buf_data) 
   begin
      buf_read     <= '0';
      fibre_data_o <= (others => '0');
      fibre_nena_o <= '1';
      
      case pres_state is
         when IDLE =>       if(buf_empty = '0') then
                               buf_read <= '1';
                            end if;
         
         when SEND_BYTE0 => fibre_data_o <= buf_data(7 downto 0);
                            fibre_nena_o <= '0';
         
         when SEND_BYTE1 => fibre_data_o <= buf_data(15 downto 8);
                            fibre_nena_o <= '0';
         
         when SEND_BYTE2 => fibre_data_o <= buf_data(23 downto 16);
                            fibre_nena_o <= '0';
         
         when SEND_BYTE3 => if(buf_empty = '0') then
                               buf_read <= '1';
                            end if;
                            
                            fibre_data_o <= buf_data(31 downto 24);
                            fibre_nena_o <= '0';
                            
         when others =>     null;
      end case;
   end process;
    
end rtl;