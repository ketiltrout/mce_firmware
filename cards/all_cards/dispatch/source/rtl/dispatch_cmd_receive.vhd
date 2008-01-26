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
-- dispatch_cmd_receive.vhd
--
-- Project:       SCUBA-2
-- Author:        Bryce Burger/ Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Implements the receiver and command parser for the dispatch block
--
-- Revision history:
--
-- $Log: dispatch_cmd_receive.vhd,v $
-- Revision 1.24.2.1  2007/12/20 00:53:49  mandana
-- safe fsm to fix reset problem
-- have to avoid the trunk as it has some dummy state added
--
-- Revision 1.24  2007/07/25 19:33:38  bburger
-- BB:  added support for the psuc to have it own dispatch block
--
-- Revision 1.23  2006/08/11 23:55:54  bburger
-- Bryce:  the Power Supply Card is now recognized as its own card even though the Clock Card receiver handles the replies
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library components;
use components.component_pack.all;

library sys_param;
use sys_param.command_pack.all;

entity dispatch_cmd_receive is
port(clk_i      : in std_logic;
     comm_clk_i : in std_logic;
     rst_i      : in std_logic;

     lvds_cmd_i : in std_logic;
     card_i     : in std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0);

     -- Done/error signals:
     cmd_done_o  : out std_logic;  -- indicates receive completed
     cmd_error_o : out std_logic;  -- indicates received packet is invalid (CRC error or data size error)

     -- Command header words:
     header0_o : out std_logic_vector(31 downto 0);
     header1_o : out std_logic_vector(31 downto 0);

     -- Buffer interface (stores data from command packet):
     buf_data_o : out std_logic_vector(31 downto 0);
     buf_addr_o : out std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
     buf_wren_o : out std_logic;

     -- test interface
     dip_sw : in std_logic);
end dispatch_cmd_receive;

architecture rtl of dispatch_cmd_receive is

component lvds_rx
port(clk_i      : in std_logic;
     comm_clk_i : in std_logic;
     rst_i      : in std_logic;
     dat_o      : out std_logic_vector(31 downto 0);
     rdy_o      : out std_logic;
     ack_i      : in std_logic;
     lvds_i     : in std_logic);
end component;

type receiver_states is (IDLE, RX_HDR0, RX_HDR1, PARSE_HDR, RX_DATA, RX_CRC, DONE);
signal pres_state : receiver_states;
signal next_state : receiver_states;

signal lvds_rx_data : std_logic_vector(31 downto 0);
signal lvds_rx_rdy  : std_logic;
signal lvds_rx_ack  : std_logic;

signal header0    : std_logic_vector(31 downto 0);
signal header0_ld : std_logic;

signal header1    : std_logic_vector(31 downto 0);
signal header1_ld : std_logic;

signal cmd_type      : std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0);
signal cmd_valid     : std_logic;

signal word_count_ena : std_logic;
signal word_count_clr : std_logic;
signal word_count     : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);

signal data_size      : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);

signal crc_ena   : std_logic;
signal crc_clr   : std_logic;
signal crc_valid : std_logic;
signal crc_num_words : integer range 0 to 2**BB_DATA_SIZE_WIDTH +4;
signal crc_poly : std_logic_vector(31 downto 0);

begin

   ---------------------------------------------------------
   -- LVDS receiver
   ---------------------------------------------------------

   cmd_rx: lvds_rx
      port map(clk_i      => clk_i,
               comm_clk_i => comm_clk_i,
               rst_i      => rst_i,
               dat_o      => lvds_rx_data,
               rdy_o      => lvds_rx_rdy,
               ack_i      => lvds_rx_ack,
               lvds_i     => lvds_cmd_i);


   ---------------------------------------------------------
   -- CRC validation
   ---------------------------------------------------------

   crc_calc : parallel_crc
      generic map(POLY_WIDTH => 32,
                  DATA_WIDTH => 32)
      port map(clk_i       => clk_i,
               rst_i       => rst_i,
               clr_i       => crc_clr,
               ena_i       => crc_ena,
               poly_i      => crc_poly,    -- CRC-32 polynomial
               data_i      => lvds_rx_data,
               num_words_i => crc_num_words,
               done_o      => open,
               valid_o     => crc_valid,
               checksum_o  => open);

   crc_num_words <= conv_integer(data_size + 3);
   crc_poly <= "00000100110000010001110110110111" when dip_sw = '1' else "10000100110000010001110110110111";

   ---------------------------------------------------------
   -- Temp registers for header words
   ---------------------------------------------------------

   -- Notes: - Every time a new command arrives, its header words are stored regardless of whether the command is valid or not.
   --        - When the second header word is received, cmd_valid tells the receiver FSM if the command is valid.

   hdr0 : reg
      generic map(WIDTH => 32)
      port map(clk_i  => clk_i,
               rst_i  => rst_i,
               ena_i  => header0_ld,
               reg_i  => lvds_rx_data,
               reg_o  => header0);

   hdr1 : reg
      generic map(WIDTH => 32)
      port map(clk_i  => clk_i,
               rst_i  => rst_i,
               ena_i  => header1_ld,
               reg_i  => lvds_rx_data,
               reg_o  => header1);

   data_size <= header0(BB_DATA_SIZE'range) when header0(BB_COMMAND_TYPE'range) = WRITE_CMD else (others => '0');

   cmd_type  <= header0(BB_COMMAND_TYPE'range);

   cmd_valid <= '1' when (header1(BB_CARD_ADDRESS'range) = card_i) or
                         (header1(BB_CARD_ADDRESS'range) = ALL_MCE_CARDS) or 
                         (header1(BB_CARD_ADDRESS'range) = ALL_FPGA_CARDS and card_i /= POWER_SUPPLY_CARD) or
                         (header1(BB_CARD_ADDRESS'range) = ALL_BIAS_CARDS and (card_i = BIAS_CARD_1 or card_i = BIAS_CARD_2 or card_i = BIAS_CARD_3)) or
                         (header1(BB_CARD_ADDRESS'range) = ALL_READOUT_CARDS and (card_i = READOUT_CARD_1 or card_i = READOUT_CARD_2 or card_i = READOUT_CARD_3 or card_i = READOUT_CARD_4))
--                         (header1(BB_CARD_ADDRESS'range) = POWER_SUPPLY_CARD and (card_i = CLOCK_CARD))
                    else '0';


   ---------------------------------------------------------
   -- Counter for received words
   ---------------------------------------------------------

   word_counter : binary_counter
   generic map(WIDTH => BB_DATA_SIZE_WIDTH)
   port map(clk_i   => clk_i,
            rst_i   => rst_i,
            ena_i   => word_count_ena,
            up_i    => '1',
            load_i  => '0',
            clear_i => word_count_clr,
            count_i => (others => '0'),
            count_o => word_count);

   buf_addr_o <= word_count;


   ---------------------------------------------------------
   -- Receive controller FSM
   ---------------------------------------------------------
   rx_stateFF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         pres_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         pres_state <= next_state;
      end if;
   end process rx_stateFF;

   rx_stateNS: process(pres_state, lvds_rx_rdy, lvds_rx_data, cmd_type, data_size, word_count)
   begin
      -- Default Assignment
      next_state <= pres_state;

      case pres_state is
         when IDLE =>      next_state <= RX_HDR0;

         when RX_HDR0 =>   if(lvds_rx_rdy = '1' and lvds_rx_data(BB_PREAMBLE'range) = BB_PREAMBLE) then
                              next_state <= RX_HDR1;
                           else
                              next_state <= RX_HDR0;
                           end if;

         when RX_HDR1 =>   if(lvds_rx_rdy = '1') then
                              next_state <= PARSE_HDR;
                           else
                              next_state <= RX_HDR1;
                           end if;

         when PARSE_HDR => if(cmd_type = WRITE_CMD) then
                              next_state <= RX_DATA;
                           else
                              next_state <= RX_CRC;
                           end if;

         when RX_DATA =>   if(lvds_rx_rdy = '1' and word_count = data_size-1) then
                              next_state <= RX_CRC;
                           else
                              next_state <= RX_DATA;
                           end if;

         when RX_CRC =>    if(lvds_rx_rdy = '1') then
                              next_state <= DONE;
                           else
                              next_state <= RX_CRC;
                           end if;

         when others =>    next_state <= IDLE;
      end case;
   end process rx_stateNS;

   rx_stateOut: process(pres_state, lvds_rx_rdy, lvds_rx_data, header0, header1, cmd_valid, crc_valid)
   begin
      -- default values:
      lvds_rx_ack    <= '0';
      crc_ena        <= '0';
      crc_clr        <= '0';
      header0_ld     <= '0';
      header1_ld     <= '0';
      word_count_ena <= '0';
      word_count_clr <= '0';
      buf_data_o     <= (others => '0');
      buf_wren_o     <= '0';
      header0_o      <= (others => '0');
      header1_o      <= (others => '0');
      cmd_done_o     <= '0';
      cmd_error_o    <= '0';

      case pres_state is
         when IDLE =>      word_count_clr     <= '1';
                           crc_clr            <= '1';

         when RX_HDR0 =>   if(lvds_rx_rdy = '1') then
                              lvds_rx_ack     <= '1';
                              if(lvds_rx_data(BB_PREAMBLE'range) = BB_PREAMBLE) then
                                 crc_ena      <= '1';              -- don't want to enable CRC nor load header0
                                 header0_ld   <= '1';              -- when we are sync'ing to the next packet!
                              end if;
                           end if;

         when RX_HDR1 =>   if(lvds_rx_rdy = '1') then
                              lvds_rx_ack     <= '1';
                              crc_ena         <= '1';
                              header1_ld      <= '1';
                           end if;

         when RX_DATA =>   if(lvds_rx_rdy = '1') then
                              lvds_rx_ack     <= '1';
                              crc_ena         <= '1';
                              word_count_ena  <= '1';
                              buf_data_o      <= lvds_rx_data;
                              buf_wren_o      <= '1';
                           end if;

         when RX_CRC =>    if(lvds_rx_rdy = '1') then
                              lvds_rx_ack     <= '1';
                              crc_ena         <= '1';
                           end if;

         when DONE =>      if(cmd_valid = '1') then
                              cmd_done_o      <= '1';
                              header0_o       <= header0;
                              header1_o       <= header1;
                              if(crc_valid = '0' or header0(BB_DATA_SIZE'range) = 0) then
                                 cmd_error_o  <= '1';
                              end if;
                           end if;

         when others =>    null;
      end case;
   end process rx_stateOut;

end rtl;