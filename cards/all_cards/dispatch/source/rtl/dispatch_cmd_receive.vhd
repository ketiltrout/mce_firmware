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
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Implements the receiver and command parser for the dispatch block
--
-- Revision history:
-- 
-- $Log: dispatch_cmd_receive.vhd,v $
-- Revision 1.1  2004/08/04 19:42:55  erniel
-- WARNING: not functional, work in progress
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library components;
use components.component_pack.all;

library sys_param;
use sys_param.general_pack.all;
use sys_param.data_types_pack.all;
use sys_param.wishbone_pack.all;
use sys_param.command_pack.all;

library work;
use work.async_pack.all;
use work.dispatch_pack.all;

entity dispatch_cmd_receive is
generic(CARD : std_logic_vector(CQ_CARD_ADDR_BUS_WIDTH-1 downto 0) := RC1);
port(clk_i      : in std_logic;
     comm_clk_i : in std_logic;
     rst_i      : in std_logic;		
     
     lvds_cmd_i   : in std_logic;
     
     done_o : out std_logic;
     
     -- command parameters
     data_size_o : out std_logic_vector(CQ_DATA_SIZE_BUS_WIDTH-1 downto 0);
     param_id_o  : out std_logic_vector(CQ_PAR_ID_BUS_WIDTH-1 downto 0);
     macro_seq_o : out std_logic_vector(7 downto 0);
     micro_seq_o : out std_logic_vector(7 downto 0);
     
     -- data buffer interface
     buf_data_o : out std_logic_vector(31 downto 0);
     buf_addr_o : out std_logic_vector(5 downto 0);
     buf_wren_o : out std_logic);
end dispatch_cmd_receive;

architecture behav of dispatch_cmd_receive is

type receiver_states is (RX_HDR, RX_DATA, RX_CRC, INCR_HDR, INCR_DATA, INCR_SKIP, PARSE_HDR, WRITE_BUF, SKIP_CMD, DONE);
signal rx_pres_state : receiver_states;
signal rx_next_state : receiver_states;

signal cmd_rx_data : std_logic_vector(31 downto 0);
signal cmd_rx_rdy  : std_logic;
signal cmd_rx_ack  : std_logic;

signal header0_ld : std_logic;
signal header0    : std_logic_vector(31 downto 0);
signal data_size  : integer;

signal header1_ld         : std_logic;
signal header1            : std_logic_vector(31 downto 0);
signal card_address_valid : std_logic;

signal data_size_ld : std_logic;
signal parameter_ld : std_logic;
signal macro_seq_ld : std_logic;
signal micro_seq_ld : std_logic;

signal hdr_count_ena  : std_logic;
signal hdr_count_clr  : std_logic;
signal hdr_count      : integer;

signal data_count_ena : std_logic;
signal data_count_clr : std_logic;
signal data_count     : integer;


-- signals used in CRC datapath:

type crc_states is (IDLE_CRC, INITIALIZE_CRC, CALCULATE_CRC, CALC_CRC_DONE, WAIT_NEXT_WORD, LOAD_NEXT_WORD);
signal crc_pres_state : crc_states;
signal crc_next_state : crc_states;

signal cmd_size_reg_ena : std_logic;
signal cmd_size         : std_logic_vector(15 downto 0);

signal cmd_data : std_logic_vector(31 downto 0);

signal crc_data_shreg_ena : std_logic;
signal crc_data_shreg_ld  : std_logic;
signal crc_input_bit      : std_logic;

signal crc_bit_count_clr : std_logic;
signal crc_bit_count     : integer;

signal crc_ena   : std_logic;
signal crc_clr   : std_logic;
signal crc_done  : std_logic;
signal crc_valid : std_logic;

signal crc_word_done : std_logic;
signal crc_num_bits  : integer;


begin

   ---------------------------------------------------------
   -- LVDS receiver
   ---------------------------------------------------------
   
   cmd_rx: lvds_rx
      port map(clk_i      => clk_i,
               comm_clk_i => comm_clk_i,
               rst_i      => rst_i,
     
               dat_o => cmd_rx_data,
               rdy_o => cmd_rx_rdy,
               ack_i => cmd_rx_ack,
     
               lvds_i => lvds_cmd_i);
   
   
   ---------------------------------------------------------
   -- Temp registers for storing received header words
   ---------------------------------------------------------
   
   header_word0 : reg
      generic map(WIDTH => 32)
      port map(clk_i  => clk_i,
               rst_i  => rst_i,
               ena_i  => header0_ld,

               reg_i  => cmd_data,
               reg_o  => header0);
   
   data_size <= conv_integer(header0(15 downto 0));
   
   header_word1 : reg
      generic map(WIDTH => 32)
      port map(clk_i  => clk_i,
               rst_i  => rst_i,
               ena_i  => header1_ld,

               reg_i  => cmd_data,
               reg_o  => header1);
   
   card_address_valid <= '1' when (header1(31 downto 24) = CARD) or 
                                  (header1(31 downto 24) = ALL_CARDS) or 
                                  (header1(31 downto 24) = ALL_FPGA_CARDS) or
                                  (header1(31 downto 24) = BCS and (CARD = BC1 or CARD = BC2 or CARD = BC3)) or
                                  (header1(31 downto 24) = RCS and (CARD = RC1 or CARD = RC2 or CARD = RC3 or CARD = RC4))
                             else '0';
   
   
   ---------------------------------------------------------
   -- Registers for storing valid received parameters
   ---------------------------------------------------------
   
   size : reg
      generic map(WIDTH => CQ_DATA_SIZE_BUS_WIDTH)
      port map(clk_i  => clk_i,
               rst_i  => rst_i,
               ena_i  => data_size_ld,

               reg_i  => header0(15 downto 0),
               reg_o  => data_size_o);  
               
   par_id : reg
      generic map(WIDTH => CQ_PAR_ID_BUS_WIDTH)
      port map(clk_i  => clk_i,
               rst_i  => rst_i,
               ena_i  => parameter_ld,

               reg_i  => header1(23 downto 16),
               reg_o  => param_id_o);
   
   macro_num : reg
      generic map(WIDTH => 8)
      port map(clk_i  => clk_i,
               rst_i  => rst_i,
               ena_i  => macro_seq_ld,

               reg_i  => header1(15 downto 8),
               reg_o  => macro_seq_o);
   
   micro_num : reg
      generic map(WIDTH => 8)
      port map(clk_i  => clk_i,
               rst_i  => rst_i,
               ena_i  => micro_seq_ld,

               reg_i  => header1(7 downto 0),
               reg_o  => micro_seq_o);  
   
                       
   ---------------------------------------------------------
   -- Received packet CRC validation
   ---------------------------------------------------------
   
   -- CRC datapath
   cmd_size_reg : reg
      generic map(WIDTH => CQ_DATA_SIZE_BUS_WIDTH)
      port map(clk_i => clk_i,
           rst_i => rst_i,
           ena_i => cmd_size_reg_ena,
           reg_i => cmd_rx_data(CQ_DATA_SIZE_BUS_WIDTH-1 downto 0),
           reg_o => cmd_size);

   crc_num_bits <= conv_integer((cmd_size + 3) & "00000");  -- cmd_size is # of data words + 2 command words + 1 CRC word
   
   crc_data_reg : shift_reg
      generic map(WIDTH => 32)
      port map(clk_i      => clk_i,
               rst_i      => rst_i,
               ena_i      => crc_data_shreg_ena,
               load_i     => crc_data_shreg_ld,
               clr_i      => '0',
               shr_i      => '1',
               serial_i   => crc_input_bit,  -- this makes the shift register a rotator! (eliminates need for separate buffer)
               serial_o   => crc_input_bit,
               parallel_i => cmd_rx_data,
               parallel_o => cmd_data);
   
   crc_bit_counter : counter
      generic map(MAX         => 32,
                  WRAP_AROUND => '0')
      port map(clk_i   => clk_i,
               rst_i   => rst_i,
               ena_i   => '1',
               load_i  => crc_bit_count_clr,
               count_i => 0,
               count_o => crc_bit_count);

   crc_calc : crc
      generic map(POLY_WIDTH => 32)
      port map(clk_i      => clk_i,
               rst_i      => rst_i,
               clr_i      => crc_clr,
               ena_i      => crc_ena,
               data_i     => crc_input_bit,
               num_bits_i => crc_num_bits,
               poly_i     => CRC32,
               done_o     => crc_done,
               valid_o    => crc_valid,
               checksum_o => open);
           
   -- CRC control FSM
   crc_stateFF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         crc_pres_state <= IDLE_CRC;
      elsif(clk_i'event and clk_i = '1') then
         crc_pres_state <= crc_next_state;
      end if;
   end process crc_stateFF;
   
   crc_stateNS: process(crc_pres_state, cmd_rx_rdy, crc_bit_count, crc_done)
   begin
      case crc_pres_state is
         when IDLE_CRC =>       if(cmd_rx_rdy = '1') then
                                   crc_next_state <= INITIALIZE_CRC;
                                else
                                   crc_next_state <= IDLE_CRC;
                                end if;
                          
         when INITIALIZE_CRC => crc_next_state <= CALCULATE_CRC;
         
         when CALCULATE_CRC =>  if(crc_bit_count = 31) then
                                   crc_next_state <= CALC_CRC_DONE;
                                else
                                   crc_next_state <= CALCULATE_CRC;
                                end if;
                          
         when CALC_CRC_DONE =>  crc_next_state <= WAIT_NEXT_WORD;
                                         
         when WAIT_NEXT_WORD => if(crc_done = '1') then
                                   crc_next_state <= IDLE_CRC;
                                elsif(cmd_rx_rdy = '1') then 
                                   crc_next_state <= LOAD_NEXT_WORD;
                                else
                                   crc_next_state <= WAIT_NEXT_WORD;
                                end if;
                            
         when LOAD_NEXT_WORD => crc_next_state <= CALCULATE_CRC;
         
         when others =>         crc_next_state <= IDLE_CRC;
      end case;
   end process crc_stateNS;
   
   crc_stateOut: process(crc_pres_state)
   begin
      cmd_rx_ack         <= '0';   
      cmd_size_reg_ena   <= '0';
      crc_data_shreg_ld  <= '0';
      crc_data_shreg_ena <= '0';      
      crc_bit_count_clr  <= '0';
      crc_clr            <= '0';
      crc_ena            <= '0';
      crc_word_done      <= '0';
      
      case crc_pres_state is
         when INITIALIZE_CRC => cmd_rx_ack         <= '1';  
                                cmd_size_reg_ena   <= '1';
                                crc_data_shreg_ld  <= '1';
                                crc_data_shreg_ena <= '1';
                                crc_bit_count_clr  <= '1';
                                crc_clr            <= '1';
                                crc_ena            <= '1';
                           
         when CALCULATE_CRC =>  crc_ena            <= '1';
                                crc_data_shreg_ena <= '1';
         
         when CALC_CRC_DONE =>  crc_word_done      <= '1';
         
         when LOAD_NEXT_WORD => cmd_rx_ack         <= '1';
                                crc_data_shreg_ld  <= '1';
                                crc_data_shreg_ena <= '1';
                                crc_bit_count_clr  <= '1';
                                
         when others =>         null;
      end case;
   end process crc_stateOut;


   ---------------------------------------------------------               
   -- Packet counters for received words
   ---------------------------------------------------------   
   
   header_counter : counter
   generic map(MAX => BB_PACKET_HEADER_SIZE-1)
   port map(clk_i   => clk_i,
            rst_i   => rst_i,
            ena_i   => hdr_count_ena,
            load_i  => '0',   -- does not need to be cleared, since number of header words is fixed, counter just wraps
            count_i => 0,
            count_o => hdr_count);
   
   data_counter : counter
   generic map(MAX => 65536)
   port map(clk_i   => clk_i,
            rst_i   => rst_i,
            ena_i   => data_count_ena,
            load_i  => data_count_clr,
            count_i => 0,
            count_o => data_count);
            
   
   ---------------------------------------------------------
   -- Receive controller FSM
   ---------------------------------------------------------
   rx_stateFF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         rx_pres_state <= RX_HDR;
      elsif(clk_i'event and clk_i = '1') then
         rx_pres_state <= rx_next_state;
      end if;
   end process rx_stateFF;
   
   rx_stateNS: process(rx_pres_state, crc_word_done, card_address_valid, data_size, hdr_count, data_count)
   begin
      case rx_pres_state is
         when RX_HDR =>    if(crc_word_done = '1') then 
                              rx_next_state <= INCR_HDR;
                           else
                              rx_next_state <= RX_HDR;
                           end if;
                           
         when INCR_HDR =>  if(hdr_count = BB_PACKET_HEADER_SIZE-1) then
                              rx_next_state <= PARSE_HDR;
                           else
                              rx_next_state <= RX_HDR;
                           end if;
                           
         when PARSE_HDR => if(card_address_valid = '1') then
                              if(data_size /= 0) then             -- this packet contains some data words
                                 rx_next_state <= RX_DATA;
                              else
                                 rx_next_state <= RX_CRC;         -- this packet contains no data words
                              end if;
                           else
                              rx_next_state <= SKIP_CMD;          -- this packet is not for this card, skip it
                           end if;
 
         when RX_DATA =>   if(crc_word_done = '1') then
                              rx_next_state <= WRITE_BUF;                                
                           else
                              rx_next_state <= RX_DATA;
                           end if;
         
         when WRITE_BUF => rx_next_state <= INCR_DATA;
         
         when INCR_DATA => if(data_count = data_size-1) then
                              rx_next_state <= RX_CRC;
                           else
                              rx_next_state <= RX_DATA;
                           end if;
         
         when RX_CRC =>    if(crc_word_done = '1') then
                              rx_next_state <= DONE;
                           else
                              rx_next_state <= RX_CRC;
                           end if;
                           
         when SKIP_CMD =>  if(crc_word_done = '1') then
                              rx_next_state <= INCR_SKIP;
                           else
                              rx_next_state <= SKIP_CMD;
                           end if;
                           
         when INCR_SKIP => if(data_count = data_size) then        -- not "data_size-1" since CRC word is included in count
                              rx_next_state <= RX_HDR;
                           else
                              rx_next_state <= SKIP_CMD;
                           end if;
                           
         when DONE =>      rx_next_state <= RX_HDR;
         
         when others =>    rx_next_state <= RX_HDR;
      end case;
   end process rx_stateNS;

   rx_stateOut: process(rx_pres_state, hdr_count)
   begin
      -- default values:
      header0_ld     <= '0';
      header1_ld     <= '0';
      hdr_count_ena  <= '0';
      data_count_ena <= '0';
      data_count_clr <= '0';
      buf_data_o     <= (others => '0');
      buf_addr_o     <= (others => '0');
      buf_wren_o     <= '0';
      data_size_ld   <= '0';
      parameter_ld   <= '0';
      macro_seq_ld   <= '0';
      micro_seq_ld   <= '0';
      done_o         <= '0';
      
      case rx_pres_state is
         when RX_HDR =>                if(hdr_count = 0) then
                                          header0_ld  <= '1';
                                       else
                                          header1_ld  <= '1';
                                       end if;
                                
         when INCR_HDR =>              hdr_count_ena  <= '1';
         
         when PARSE_HDR =>             data_count_ena <= '1';
                                       data_count_clr <= '1';

         when INCR_DATA | INCR_SKIP => data_count_ena <= '1';     
                                 
         when WRITE_BUF =>             buf_data_o     <= cmd_data;
                                       buf_addr_o     <= conv_std_logic_vector(data_count, 6);
                                       buf_wren_o     <= '1';
         
         when DONE =>                  data_size_ld   <= '1';
                                       parameter_ld   <= '1';
                                       macro_seq_ld   <= '1';
                                       micro_seq_ld   <= '1';
                                       done_o         <= '1';
                                               
         when others =>                null;
      end case;
   end process rx_stateOut;
      
end behav;