
library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.command_pack.all;

library work;
use work.issue_reply_pack.all;

entity reply_queue_sequencer is
port(clk_i      : in std_logic;
     rst_i      : in std_logic;
     
     -- receiver FIFO interfaces:
     ac_data_i  : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     ac_size_i  : in std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
     ac_done_i  : in std_logic;
     ac_ack_o   : out std_logic;
     
     bc1_data_i : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     bc1_size_i : in std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
     bc1_done_i : in std_logic;
     bc1_ack_o  : out std_logic;
     
     bc2_data_i : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     bc2_size_i : in std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
     bc2_done_i : in std_logic;
     bc2_ack_o  : out std_logic;
     
     bc3_data_i : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     bc3_size_i : in std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
     bc3_done_i : in std_logic;
     bc3_ack_o  : out std_logic;
     
     rc1_data_i : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     rc1_size_i : in std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
     rc1_done_i : in std_logic;
     rc1_ack_o  : out std_logic;
     
     rc2_data_i : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     rc2_size_i : in std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
     rc2_done_i : in std_logic;
     rc2_ack_o  : out std_logic;
     
     rc3_data_i : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     rc3_size_i : in std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
     rc3_done_i : in std_logic;
     rc3_ack_o  : out std_logic;
     
     rc4_data_i : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     rc4_size_i : in std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
     rc4_done_i : in std_logic;
     rc4_ack_o  : out std_logic;
     
     cc_data_i  : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     cc_size_i  : in std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
     cc_done_i  : in std_logic;
     cc_ack_o   : out std_logic;
     
     -- fibre interface:
     size_o : out integer;
     data_o : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     rdy_o  : out std_logic;
     ack_i  : in std_logic;
     
     -- cmd_queue interface:
     macro_op_i  : in std_logic_vector(BB_MACRO_OP_SEQ_WIDTH-1 downto 0);
     micro_op_i  : in std_logic_vector(BB_MICRO_OP_SEQ_WIDTH-1 downto 0);
     card_addr_i : in std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0));
end reply_queue_sequencer;

architecture rtl of reply_queue_sequencer is

type seq_states is (IDLE, AC_DATA, BC1_DATA, BC2_DATA, BC3_DATA, CC_DATA, RC1_DATA, RC2_DATA, RC3_DATA, RC4_DATA);
signal pres_state : seq_states;
signal next_state : seq_states;

signal match   : std_logic;
signal seq_num : std_logic_vector(15 downto 0);

begin

   seq_num <= macro_op_i & micro_op_i;
   
   match <= '1' when (((card_addr_i = ADDRESS_CARD)   and    (ac_data_i(15 downto 0)  = seq_num)) or
   
                      ((card_addr_i = BIAS_CARD_1)    and    (bc1_data_i(15 downto 0) = seq_num)) or
                      
                      ((card_addr_i = BIAS_CARD_2)    and    (bc2_data_i(15 downto 0) = seq_num)) or
                      
                      ((card_addr_i = BIAS_CARD_3)    and    (bc3_data_i(15 downto 0) = seq_num)) or
                      
                      ((card_addr_i = READOUT_CARD_1) and    (rc1_data_i(15 downto 0) = seq_num)) or
                      
                      ((card_addr_i = READOUT_CARD_2) and    (rc2_data_i(15 downto 0) = seq_num)) or
                      
                      ((card_addr_i = READOUT_CARD_3) and    (rc3_data_i(15 downto 0) = seq_num)) or
                      
                      ((card_addr_i = READOUT_CARD_4) and    (rc4_data_i(15 downto 0) = seq_num)) or
                      
                      ((card_addr_i = CLOCK_CARD)     and    (cc_data_i(15 downto 0)  = seq_num)) or                      
                      
                      ((card_addr_i = ALL_BIAS_CARDS) and    (bc1_data_i(15 downto 0) = seq_num) and
                                                             (bc2_data_i(15 downto 0) = seq_num) and
                                                             (bc3_data_i(15 downto 0) = seq_num)) or
                                                             
                      ((card_addr_i = ALL_READOUT_CARDS) and (rc1_data_i(15 downto 0) = seq_num) and
                                                             (rc2_data_i(15 downto 0) = seq_num) and
                                                             (rc3_data_i(15 downto 0) = seq_num) and
                                                             (rc4_data_i(15 downto 0) = seq_num)) or
                                                             
                      ((card_addr_i = ALL_FPGA_CARDS) and    (ac_data_i(15 downto 0)  = seq_num) and
                                                             (bc1_data_i(15 downto 0) = seq_num) and
                                                             (bc2_data_i(15 downto 0) = seq_num) and
                                                             (bc3_data_i(15 downto 0) = seq_num) and
                                                             (rc1_data_i(15 downto 0) = seq_num) and
                                                             (rc2_data_i(15 downto 0) = seq_num) and
                                                             (rc3_data_i(15 downto 0) = seq_num) and
                                                             (rc4_data_i(15 downto 0) = seq_num) and
                                                             (cc_data_i(15 downto 0)  = seq_num))) else '0';   

   state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then 
         pres_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         pres_state <= next_state;
      end if;
   end process state_FF;
   
   state_NS: process(pres_state, match, card_addr_i, ac_done_i, bc1_done_i, bc2_done_i, bc3_done_i, rc1_done_i, rc2_done_i, rc3_done_i, rc4_done_i, cc_done_i,)
   begin
      case pres_state is
         when IDLE =>     if(match = '1') then
                             if((card_addr_i = ADDRESS_CARD) or (card_addr_i = ALL_FPGA_CARDS)) then
                                next_state <= AC_DATA;
                             elsif((card_addr_i = BIAS_CARD_1) or (card_addr_i = ALL_BIAS_CARDS)) then
                                next_state <= BC1_DATA;
                             elsif(card_addr_i = BIAS_CARD_2) then
                                next_state <= BC2_DATA;
                             elsif(card_addr_i = BIAS_CARD_3) then
                                next_state <= BC3_DATA;
                             elsif((card_addr_i = READOUT_CARD_1) or (card_addr_i = ALL_READOUT_CARDS)) then
                                next_state <= RC1_DATA;
                             elsif(card_addr_i = READOUT_CARD_2) then
                                next_state <= RC2_DATA;
                             elsif(card_addr_i = READOUT_CARD_3) then
                                next_state <= RC3_DATA;
                             elsif(card_addr_i = READOUT_CARD_4) then
                                next_state <= RC4_DATA;
                             elsif(card_addr_i = CLOCK_CARD) then
                                next_state <= CC_DATA;
                             end if;
                          else
                             next_state <= IDLE;
                          end if;
                          
         when AC_DATA =>  if(ac_done_i = '1') then
                             if(card_addr_i = ALL_FPGA_CARDS) then
                                next_state <= BC1_DATA;
                             else
                                next_state <= IDLE;
                             end if;
                          else
                             next_state <= AC_DATA;
                          end if;
                          
         when BC1_DATA => if(bc1_done_i = '1') then
                             if((card_addr_i = ALL_FPGA_CARDS) or (card_addr_i = ALL_BIAS_CARDS)) then
                                next_state <= BC2_DATA;
                             else
                                next_state <= IDLE;
                             end if;
                          else
                             next_state <= BC1_DATA;
                          end if;
                          
         when BC2_DATA => if(bc2_done_i = '1') then
                             if((card_addr_i = ALL_FPGA_CARDS) or (card_addr_i = ALL_BIAS_CARDS)) then
                                next_state <= BC3_DATA;
                             else
                                next_state <= IDLE;
                             end if;
                          else
                             next_state <= BC2_DATA;
                          end if;
                          
         when BC3_DATA => if(bc3_done_i = '1') then
                             if(card_addr_i = ALL_FPGA_CARDS) then
                                next_state <= RC1_DATA;
                             else
                                next_state <= IDLE;
                             end if;
                          else
                             next_state <= BC3_DATA;
                          end if;
                          
         when RC1_DATA => if(rc1_done_i = '1') then
                             if((card_addr_i = ALL_FPGA_CARDS) or (card_addr_i = ALL_READOUT_CARDS)) then
                                next_state <= RC2_DATA;
                             else
                                next_state <= IDLE;
                             end if;
                          else
                             next_state <= RC1_DATA;
                          end if;
                          
         when RC2_DATA => if(rc2_done_i = '1') then
                             if((card_addr_i = ALL_FPGA_CARDS) or (card_addr_i = ALL_READOUT_CARDS)) then
                                next_state <= RC3_DATA;
                             else
                                next_state <= IDLE;
                             end if;
                          else
                             next_state <= RC2_DATA;
                          end if;
                          
         when RC3_DATA => if(rc3_done_i = '1') then
                             if((card_addr_i = ALL_FPGA_CARDS) or (card_addr_i = ALL_READOUT_CARDS)) then
                                next_state <= RC4_DATA;
                             else
                                next_state <= IDLE;
                             end if;
                          else
                             next_state <= RC3_DATA;
                          end if;
                          
         when RC4_DATA => if(rc4_done_i = '1') then
                             if(card_addr_i = ALL_FPGA_CARDS) then
                                next_state <= CC_DATA;
                             else
                                next_state <= IDLE;
                             end if;
                          else
                             next_state <= RC4_DATA;
                          end if;
         
         when CC_DATA =>  next_state <= IDLE;         
         
         when others =>   null;
      end case;
   end process state_NS;
   
   state_Out: process(pres_state)
   begin
      case pres_state is
         when IDLE =>
         when AC_DATA =>
         when BC1_DATA =>
         when BC2_DATA =>
         when BC3_DATA =>
         when RC1_DATA =>
         when RC2_DATA =>
         when RC3_DATA =>
         when RC4_DATA =>
         when CC_DATA =>
         when others =>
      end case;
   end process state_Out;
end rtl;