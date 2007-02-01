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

library work;
use work.issue_reply_pack.all;

library sys_param;
use sys_param.command_pack.all;

library altera_mf;
use altera_mf.altera_mf_components.all;


entity fibre_tx is
port(
   clk_i  : in std_logic;
   rst_i  : in std_logic;

   dat_i  : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   rdy_i  : in std_logic;
   busy_o : out std_logic;

   fibre_clk_i   : in std_logic;
   fibre_data_o  : out std_logic_vector(7 downto 0);
   fibre_sc_nd_o : out std_logic;
   fibre_nena_o  : out std_logic
);
end fibre_tx;


architecture rtl of fibre_tx is

   type states is (IDLE, SEND_BYTE0, SEND_BYTE1, SEND_BYTE2, SEND_BYTE3,
      WAIT0, WAIT1, WAIT2, WAIT3, WAIT0B, WAIT1B, WAIT2B, WAIT3B);
   signal pres_state : states;
   signal next_state : states;

   -- tx_fifo signals
   signal fifo_rd_dat       : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal fifo_rd_empty     : std_logic;
   signal fifo_rd_req       : std_logic;

begin

   fibre_sc_nd_o <= '0';

   ---------------------------------------------------------
   -- Standard Non-Look-Ahead FIFO
   ---------------------------------------------------------
   tx_fifo: sync_fifo_tx
   port map(
      aclr    => rst_i,
      data    => dat_i,
      rdclk   => fibre_clk_i,
      rdreq   => fifo_rd_req,
      wrclk   => clk_i,
      wrreq   => rdy_i,
      q       => fifo_rd_dat,
      rdempty => fifo_rd_empty,
      wrfull  => busy_o
   );

   ---------------------------------------------------------
   -- Control FSM
   ---------------------------------------------------------
   process(rst_i, fibre_clk_i)
   begin
      if(rst_i = '1') then
         pres_state <= IDLE;
      elsif(fibre_clk_i'event and fibre_clk_i = '1') then
         pres_state <= next_state;
      end if;
   end process;

   process(pres_state, fifo_rd_empty)
   begin
      -- Default Assignment
      next_state <= pres_state;

      case pres_state is
         when IDLE =>
            -- If there is a word in the buffer, start sending
            if(fifo_rd_empty = '0') then
               next_state <= SEND_BYTE0;
            end if;

         when SEND_BYTE0 =>
            next_state <= SEND_BYTE1;

         when SEND_BYTE1 =>
            next_state <= SEND_BYTE2;

         when SEND_BYTE2 =>
            next_state <= SEND_BYTE3;

         when SEND_BYTE3 =>
            if(fifo_rd_empty = '0') then
               next_state <= SEND_BYTE0;
            else
               next_state <= IDLE;
            end if;


         when others =>
            next_state <= IDLE;
      end case;
   end process;

   process(pres_state, fifo_rd_dat, fifo_rd_empty)
   begin
      fifo_rd_req  <= '0';
      fibre_data_o <= (others => '0');
      fibre_nena_o <= '1';

      case pres_state is
         when IDLE =>
            if(fifo_rd_empty = '0') then
               fifo_rd_req  <= '1';
            end if;

         when SEND_BYTE0 =>
            fibre_data_o <= fifo_rd_dat(7 downto 0);
            fibre_nena_o <= '0';

         when SEND_BYTE1 =>
            fibre_data_o <= fifo_rd_dat(15 downto 8);
            fibre_nena_o <= '0';

         when SEND_BYTE2 =>
            fibre_data_o <= fifo_rd_dat(23 downto 16);
            fibre_nena_o <= '0';

         when SEND_BYTE3 =>
            fibre_data_o <= fifo_rd_dat(31 downto 24);
            fibre_nena_o <= '0';

            if(fifo_rd_empty = '0') then
               fifo_rd_req  <= '1';
            else
               fifo_rd_req  <= '0';
            end if;

         when others => null;
      end case;
   end process;


--   process(pres_state, fifo_rd_empty)
--   begin
--      -- Default Assignment
--      next_state <= pres_state;
--
--      case pres_state is
--         when IDLE =>
--            -- If there is a word in the buffer, start sending
--            if(fifo_rd_empty = '0') then
--               next_state <= SEND_BYTE0;
--            end if;
--
--         -- Wait for one cycle before every fibre byte to allow the data lines to settle
--         -- We found that there are occasional glitches on the fiber if we don't do this.
--         when SEND_BYTE0 =>
--            next_state <= WAIT0B;
--         when WAIT0B =>
--            next_state <= WAIT1;
--
--         when WAIT1 =>
--            next_state <= SEND_BYTE1;
--         when SEND_BYTE1 =>
--            next_state <= WAIT1B;
--         when WAIT1B =>
--            next_state <= WAIT2;
--
--         when WAIT2 =>
--            next_state <= SEND_BYTE2;
--         when SEND_BYTE2 =>
--            next_state <= WAIT2B;
--         when WAIT2B =>
--            next_state <= WAIT3;
--
--         when WAIT3 =>
--            next_state <= SEND_BYTE3;
--         when SEND_BYTE3 =>
--            next_state <= WAIT3B;
--         when WAIT3B =>
--            next_state <= IDLE;
--
--         when others =>
--            next_state <= IDLE;
--      end case;
--   end process;
--
--   process(pres_state, fifo_rd_dat)
--   begin
--      fifo_rd_req  <= '0';
--      fibre_data_o <= (others => '0');
--      fibre_nena_o <= '1';
--
--      case pres_state is
--         when IDLE =>
--            fibre_data_o <= fifo_rd_dat(7 downto 0);
--
--         when SEND_BYTE0 =>
--            fibre_data_o <= fifo_rd_dat(7 downto 0);
--            fibre_nena_o <= '0';
--         when WAIT0B =>
--            fibre_data_o <= fifo_rd_dat(7 downto 0);
--
--         when WAIT1 =>
--            fibre_data_o <= fifo_rd_dat(15 downto 8);
--         when SEND_BYTE1 =>
--            fibre_data_o <= fifo_rd_dat(15 downto 8);
--            fibre_nena_o <= '0';
--         when WAIT1B =>
--            fibre_data_o <= fifo_rd_dat(15 downto 8);
--
--         when WAIT2 =>
--            fibre_data_o <= fifo_rd_dat(23 downto 16);
--         when SEND_BYTE2 =>
--            fibre_data_o <= fifo_rd_dat(23 downto 16);
--            fibre_nena_o <= '0';
--         when WAIT2B =>
--            fibre_data_o <= fifo_rd_dat(23 downto 16);
--
--         when WAIT3 =>
--            fibre_data_o <= fifo_rd_dat(31 downto 24);
--         when SEND_BYTE3 =>
--            fibre_data_o <= fifo_rd_dat(31 downto 24);
--            fibre_nena_o <= '0';
--         when WAIT3B =>
--            fibre_data_o <= fifo_rd_dat(31 downto 24);
--            fifo_rd_req <= '1';
--
--         when others => null;
--      end case;
--   end process;

end rtl;