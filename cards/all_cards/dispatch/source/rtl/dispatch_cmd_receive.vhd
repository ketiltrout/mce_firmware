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
-- $Log$
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
generic(CARD_ADDR : std_logic_vector(CQ_CARD_ADDR_BUS_WIDTH-1 downto 0) := NO_CARDS);
port(clk_i      : in std_logic;
     comm_clk_i : in std_logic;
     rst_i      : in std_logic;		
     
     lvds_cmd_i   : in std_logic;
--     lvds_sync_i  : in std_logic;
--     lvds_spare_i : in std_logic;
     
     done_o : out std_logic;
     
     -- command parameters
     data_size_o : out std_logic_vector(CQ_DATA_SIZE_BUS_WIDTH-1 downto 0);
     param_id_o  : out std_logic_vector(CQ_PAR_ID_BUS_WIDTH-1 downto 0);
     macro_seq_o : out std_logic_vector(7 downto 0);
     micro_seq_o : out std_logic_vector(7 downto 0);
     crc_valid_o : out std_logic;
     
     -- data buffer interface
     data_o : out std_logic_vector(31 downto 0);
     addr_o : out std_logic_vector(5 downto 0));
end dispatch_cmd_receive;

architecture behav of dispatch_cmd_receive is

type receiver_states is (RX_CMD_WORD0, RX_CMD_WORD1, RX_CMD_DATA, RX_CRC, PARSE_CMD, SKIP_DATA, DONE);
signal rx_pres_state : receiver_states;
signal rx_next_state : receiver_states;

signal cmd_rx_data : std_logic_vector(31 downto 0);
signal cmd_rx_rdy  : std_logic;
signal cmd_rx_ack  : std_logic;

--signal sync_rx_data : std_logic_vector(31 downto 0);
--signal sync_rx_rdy  : std_logic;
--signal sync_rx_ack  : std_logic;
--
--signal spare_rx_data : std_logic_vector(31 downto 0);
--signal spare_rx_rdy  : std_logic;
--signal spare_rx_ack  : std_logic;

signal card_addr_valid : std_logic;
signal preamble_valid  : std_logic;

type crc_states is (IDLE_CRC, INITIALIZE_CRC, CALCULATE_CRC, CALC_CRC_DONE, WAIT_NEXT, LOAD_NEXT);
signal crc_pres_state : crc_states;
signal crc_next_state : crc_states;

signal cmd_size_reg_ena : std_logic;
signal cmd_size         : std_logic_vector(15 downto 0);

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

signal word_count_ena : std_logic;
signal word_count_clr : std_logic;
signal word_count     : integer;

signal cmd_data     : std_logic_vector(31 downto 0);
signal cmd_word0_ld : std_logic;
signal cmd_word0    : std_logic_vector(31 downto 0);
signal cmd_word1_ld : std_logic;
signal cmd_word1    : std_logic_vector(31 downto 0);


begin

   cmd_rx: lvds_rx
      port map(clk_i      => clk_i,
               comm_clk_i => comm_clk_i,
               rst_i      => rst_i,
     
               dat_o => cmd_rx_data,
               rdy_o => cmd_rx_rdy,
               ack_i => cmd_rx_ack,
     
               lvds_i => lvds_cmd_i);
   
   
   ---------------------------------------------------------
   -- determine if recv'd parameters are valid
   ---------------------------------------------------------

   preamble_valid  <= '1' when (cmd_word0(31 downto 16) = BB_PREAMBLE)
                          else '0';
                             
   card_addr_valid <= '1' when (cmd_word1(31 downto 24) = CARD_ADDR) or 
                               (cmd_word1(31 downto 24) = ALL_CARDS) or 
                               (cmd_word1(31 downto 24) = ALL_FPGA_CARDS) or
                               (cmd_word1(31 downto 24) = RCS and (CARD_ADDR = RC1 or CARD_ADDR = RC2 or CARD_ADDR = RC3 or CARD_ADDR = RC4)) or
                               (cmd_word1(31 downto 24) = BCS and (CARD_ADDR = BC1 or CARD_ADDR = BC2 or CARD_ADDR = BC3))
                          else '0';
                  

   ---------------------------------------------------------
   -- registers for storing received words
   ---------------------------------------------------------
   
   cmd0 : reg
      generic map(WIDTH => 32)
      port map(clk_i  => clk_i,
               rst_i  => rst_i,
               ena_i  => cmd_word0_ld,

               reg_i  => cmd_data,
               reg_o  => cmd_word0);
           
   cmd1 : reg
      generic map(WIDTH => 32)
      port map(clk_i  => clk_i,
               rst_i  => rst_i,
               ena_i  => cmd_word1_ld,

               reg_i  => cmd_data,
               reg_o  => cmd_word1);

   
   ---------------------------------------------------------
   -- Packet receive and CRC calculation 
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
                          
         when CALC_CRC_DONE =>  crc_next_state <= WAIT_NEXT;
                                         
         when WAIT_NEXT =>      if(crc_done = '1') then
                                   crc_next_state <= IDLE_CRC;
                                elsif(cmd_rx_rdy = '1') then 
                                   crc_next_state <= LOAD_NEXT;
                                else
                                   crc_next_state <= WAIT_NEXT;
                                end if;
                            
         when LOAD_NEXT =>      crc_next_state <= CALCULATE_CRC;
         
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
         
         when LOAD_NEXT =>      cmd_rx_ack         <= '1';
                                crc_data_shreg_ld  <= '1';
                                crc_data_shreg_ena <= '1';
                                crc_bit_count_clr  <= '1';
                                
         when others =>         null;
      end case;
   end process crc_stateOut;


   ---------------------------------------------------------               
   -- word counter for received data
   ---------------------------------------------------------   
   
   word_counter : counter
   generic map(MAX         => 65536,
               WRAP_AROUND => '0')
   port map(clk_i   => clk_i,
            rst_i   => rst_i,
            ena_i   => word_count_ena,
            load_i  => word_count_clr,
            count_i => 0,
            count_o => word_count);

      
   ---------------------------------------------------------
   -- receive controller FSM
   ---------------------------------------------------------
   stateFF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         rx_pres_state <= WAIT_WORD0;
      elsif(clk_i'event and clk_i = '1') then
         rx_pres_state <= rx_next_state;
      end if;
   end process stateFF;
   
   stateNS: process(rx_pres_state)
   begin
      case rx_pres_state is
         when RX_CMD_WORD0 => if(crc_word_done = '1') then
                                 rx_next_state <= RX_CMD_WORD1;
                              else
                                 rx_next_state <= RX_CMD_WORD0;
                              end if;
                            
         when RX_CMD_WORD1 => if(crc_word_done = '1') then
                                 rx_next_state <= PARSE_CMD;
                              else
                                 rx_next_state <= RX_CMD_WORD1;
                              end if;
                  
         when PARSE_CMD =>    if(card_addr_valid = '1') then
                                 if(cmd_word0(15 downo 0) = "0000000000000000") then  -- this packet has no data words
                                    rx_next_state <= RX_CRC;
                                 else
                                    rx_next_state <= RX_CMD_DATA;                     -- this packet contains some data words
                                 end if;
                              else
                                 rx_next_state <= SKIP_DATA;                          -- this packet is not for this card, skip it
                              end if;
 
         when RX_CMD_DATA =>  if(crc_word_done = '1') then
                                 if(word_count = cmd_word0(15 downto 0)) then
                                    rx_next_state <= RX_CRC;
                                 end if;                                   
                              else
                                 rx_next_state <= RX_CMD_DATA;
                              end if;
         
         when RX_CRC =>       if(crc_word_done = '1') then
                                 rx_next_state <= DONE;
                              else
                                 rx_next_state <= RX_CRC;
                              end if;
         
         when SKIP_DATA =>    if(word_count = cmd_word0(15 downto 0)) then
                                 rx_next_state <= RX_CMD_WORD0;
                              else
                                 rx_next_state <= SKIP_DATA;
                              end if;
         
         when DONE =>         rx_next_state <= RX_CMD_WORD0;
         
         when others =>       rx_next_state <= RX_CMD_WORD0;
      end case;
   end process stateNS;

   stateOut: process(rx_pres_state)
   