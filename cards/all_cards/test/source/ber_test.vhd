
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
-- ber_test.vhd
--
-- Project:	      SCUBA-2
-- Author:        Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Implementation of bit-error rate (BER) test.  The module can work in 
-- several modes to accomodate 1-way or 2-way BER testing, as well as
-- noise output generation to accomodate crosstalk testing:
--
--    mode_i        Mode Description
--
--     000        1-way tester, transmitter mode
--     001        1-way tester, receiver mode
--     010        2-way tester, combination transmitter and receiver mode
--     011        2-way tester, loopback mode
--     100        noise generator 1
--     101        noise generator 2
--     110        noise generator 3
--     111        noise generator 4
--
-- Revision history:
-- 
-- $Log$
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity adder is
generic(WIDTH : integer := 2);
port(a  : in std_logic_vector(WIDTH-1 downto 0);
     b  : in std_logic_vector(WIDTH-1 downto 0);
     ci : in std_logic;
     s  : out std_logic_vector(WIDTH-1 downto 0);
     co : out std_logic);
end adder;

architecture behav of adder is 

type carryvector is array (0 to WIDTH) of std_logic;
signal c : carryvector;

begin

   -- using a carry propagate scheme:
    
   u0: for i in 0 to WIDTH-1 generate
      s(i) <= a(i) xor b(i) xor c(i);
      c(i+1) <= (a(i) and b(i)) or (a(i) and c(i)) or (b(i) and c(i));
   end generate;

   c(0) <= ci;
   co <= c(WIDTH);
                        
end behav;


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity ones_count is
port(data_i  : in std_logic_vector(31 downto 0);
     count_o : out std_logic_vector(5 downto 0));
end ones_count;

architecture structural of ones_count is

component adder
generic(WIDTH : integer := 2);
port(a  : in std_logic_vector(WIDTH-1 downto 0);
     b  : in std_logic_vector(WIDTH-1 downto 0);
     ci : in std_logic;
     s  : out std_logic_vector(WIDTH-1 downto 0);
     co : out std_logic);
end component;

type sumslevel0 is array (0 to 7) of std_logic_vector(1 downto 0);
type sumslevel1 is array (0 to 3) of std_logic_vector(2 downto 0);
type sumslevel2 is array (0 to 1) of std_logic_vector(3 downto 0);

signal level0 : sumslevel0;
signal level1 : sumslevel1;
signal level2 : sumslevel2;
signal level3 : std_logic_vector(4 downto 0);

begin

   -- level 0 of adder tree adds data_i bits 0 to 23:

   l0: for i in 0 to 7 generate       
      u0c: adder
      generic map(WIDTH => 1)
      port map(a =>  data_i(3*i downto 3*i),
               b =>  data_i(3*i+1 downto 3*i+1),
               ci => data_i(3*i+2),
               s =>  level0(i)(0 downto 0),
               co => level0(i)(1));
   end generate;

       
   -- level 1 of adder tree adds previous levels and data_i bits 24 to 27:

   l1: for i in 0 to 3 generate       
      u1c: adder
      generic map(WIDTH => 2)
      port map(a =>  level0(2*i),
               b =>  level0(2*i+1),
               ci => data_i(24+i),
               s =>  level1(i)(1 downto 0),
               co => level1(i)(2));
   end generate;

      
   -- level 2 of adder tree adds previous levels and data_i bits 28 and 29:

   l2: for i in 0 to 1 generate       
      u2c: adder
      generic map(WIDTH => 3)
      port map(a =>  level1(2*i),
               b =>  level1(2*i+1),
               ci => data_i(28+i),
               s =>  level2(i)(2 downto 0),
               co => level2(i)(3));
   end generate;

       
   -- level 3 of adder tree adds previous levels and data_i bit 30:

   l3: adder                          
      generic map(WIDTH => 4)
      port map(a =>  level2(0),
               b =>  level2(1),
               ci => data_i(30),
               s =>  level3(3 downto 0),
               co => level3(4));
            

   -- level 4 of adder tree adds previous level and data_i bit 31:

   l4: adder                          
      generic map(WIDTH => 5)
      port map(a =>  level3,
               b =>  "00000",
               ci => data_i(31),
               s =>  count_o(4 downto 0),
               co => count_o(5));
   
end structural;  


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library components;
use components.component_pack.all;

entity ber_test is
port(clk_i      : in std_logic;
     rst_i      : in std_logic;
     lvds_clk_o : out std_logic;
     
     mode_i  : in std_logic_vector(2 downto 0);

     tx0_o   : out std_logic;   -- BER output   (noise/data, depending on mode)
     tx1_o   : out std_logic;   -- dummy output (noise only)
     tx2_o   : out std_logic;   -- dummy output (noise only)
     rx_i    : in std_logic;    -- BER input

     nlock_o : out std_logic;   -- receiver is locked to transmitter
     ndata_o : out std_logic;   -- transmitter is sending data
     nrand_o : out std_logic;   -- transmitter is sending random noise
         
     output_o : out std_logic_vector(31 downto 0));
end ber_test;

architecture rtl of ber_test is

component ber_test_pll
port(inclk0 : in std_logic;
     c0     : out std_logic;
     c1     : out std_logic;
     e0     : out std_logic);
end component;

component lvds_tx
port(clk_i      : in std_logic;
     rst_i      : in std_logic;
     
     dat_i      : in std_logic_vector(31 downto 0);
     rdy_i      : in std_logic;
     busy_o     : out std_logic;
     
     lvds_o     : out std_logic);
end component;

component lvds_rx
port(comm_clk_i : in std_logic;
     rst_i      : in std_logic;
     
     dat_o      : out std_logic_vector(31 downto 0);
     rdy_o      : out std_logic;
     ack_i      : in std_logic;
     
     lvds_i     : in std_logic);
end component;

component ones_count
port(data_i  : in std_logic_vector(31 downto 0);
     count_o : out std_logic_vector(5 downto 0));
end component;


-- BER test mode definitions:
constant TRANSMIT : std_logic_vector(2 downto 0) := "000";
constant RECEIVE  : std_logic_vector(2 downto 0) := "001";
constant COMBO    : std_logic_vector(2 downto 0) := "010";
constant LOOPBACK : std_logic_vector(2 downto 0) := "011";
constant NOISE_1  : std_logic_vector(2 downto 0) := "100";
constant NOISE_2  : std_logic_vector(2 downto 0) := "101";
constant NOISE_3  : std_logic_vector(2 downto 0) := "110";
constant NOISE_4  : std_logic_vector(2 downto 0) := "111";

signal clk : std_logic;
signal comm_clk : std_logic;

signal rst : std_logic;

signal count : integer range 0 to 65535;

type tx_ctrl_states is (TX_IDLE, SEND, TX_INCR);
signal tx_ps : tx_ctrl_states;
signal tx_ns : tx_ctrl_states;

type rx_ctrl_states is (RX_IDLE, LATCH, COMPARE, ACCUMULATE, RX_INCR, WAITING);
signal rx_ps : rx_ctrl_states;
signal rx_ns : rx_ctrl_states;

signal lvds_tx_data : std_logic_vector(31 downto 0);
signal lvds_tx_rdy  : std_logic;
signal lvds_tx_busy : std_logic;
signal tx           : std_logic;

signal data_incr : std_logic;
signal data      : std_logic_vector(23 downto 0);
  
signal noise_init : std_logic;
signal noise1     : std_logic_vector(31 downto 0);
signal noise2     : std_logic_vector(31 downto 0);
signal noise3     : std_logic_vector(31 downto 0);
signal noise4     : std_logic_vector(31 downto 0);
signal noise5     : std_logic_vector(31 downto 0);
signal noise6     : std_logic_vector(31 downto 0);
signal noise7     : std_logic_vector(31 downto 0);

signal seed  : std_logic_vector(167 downto 0);
signal seed1 : std_logic_vector(31 downto 0);
signal seed2 : std_logic_vector(31 downto 0);
signal seed3 : std_logic_vector(31 downto 0);
signal seed4 : std_logic_vector(31 downto 0);
signal seed5 : std_logic_vector(31 downto 0);
signal seed6 : std_logic_vector(31 downto 0);
signal seed7 : std_logic_vector(31 downto 0);

signal sending : std_logic;
signal locked  : std_logic;

signal lvds_rx_data : std_logic_vector(31 downto 0);
signal lvds_rx_rdy  : std_logic;
signal lvds_rx_ack  : std_logic;

signal orig_data     : std_logic_vector(23 downto 0);
signal orig_data_ld  : std_logic;
signal orig_data_clr : std_logic;

signal rx_data    : std_logic_vector(31 downto 0);
signal rx_data_ld : std_logic;

signal diff : std_logic_vector(31 downto 0);

signal num_bit_err : std_logic_vector(5 downto 0);

signal error_count_ld : std_logic;
signal loop_count_ld  : std_logic;
signal bit_err_sum    : std_logic_vector(31 downto 0);
signal pkt_err_sum    : std_logic_vector(31 downto 0);
signal loops_incr     : std_logic_vector(31 downto 0);
signal total_bit_err  : std_logic_vector(31 downto 0);
signal total_pkt_err  : std_logic_vector(31 downto 0);
signal total_loops    : std_logic_vector(31 downto 0);

signal output_sel : std_logic_vector(1 downto 0);


begin

   clk_gen : ber_test_pll
   port map(inclk0 => clk_i,
            c0 => clk,
            c1 => comm_clk,
            e0 => lvds_clk_o);

   rst <= not rst_i;

   -- this counter is used to delay transition from TX_IDLE state to SEND state.  
   -- This gives the seed generator time to initialize after reset.

   timer0 : counter
   generic map(MAX => 65535)
   port map(clk_i   => clk,
            rst_i   => rst,
            ena_i   => '1',
            load_i  => '0',
            count_i => 0,
            count_o => count);
   

   ---------------------------------------------------------------------------------------
   -- Random Generators Section            
   ---------------------------------------------------------------------------------------

   -- random pattern generator as BER data generator:
   
   rand0 : lfsr
   generic map(WIDTH => 24)
   port map(clk_i  => clk,
            rst_i  => rst,
            ena_i  => data_incr,
            load_i => '0',
            clr_i  => '0',
            lfsr_i => (others => '0'),
            lfsr_o => data);


   -- random pattern generator as seed generator (always enabled, only reset on POR):
   
   seed0 : lfsr
   generic map(WIDTH => 168)
   port map(clk_i  => clk,
            rst_i  => rst,
            ena_i  => '1',
            load_i => '0',
            clr_i  => '0',
            lfsr_i => (others => '0'),
            lfsr_o => seed);
  
   -- generated seeds (trailing '0' guarantees can't put lfsr into deadlock state):

   seed1 <= seed(15  downto 0)  & seed(167 downto 153) & '0';     
   seed2 <= seed(31  downto 16) & seed(152 downto 138) & '0';
   seed3 <= seed(47  downto 32) & seed(137 downto 123) & '0';
   seed4 <= seed(63  downto 48) & seed(122 downto 108) & '0';
   seed5 <= seed(79  downto 64) & seed(107 downto 93)  & '0';
   seed6 <= seed(95  downto 80) & seed(92  downto 78)  & '0';
   seed7 <= seed(111 downto 96) & seed(77  downto 63)  & '0';
   
   -- random pattern generators as noise generators:

   rand1 : lfsr
   generic map(WIDTH => 32)
   port map(clk_i  => clk,
            rst_i  => rst,
            ena_i  => '1',
            load_i => noise_init,
            clr_i  => '0',
            lfsr_i => seed1,
            lfsr_o => noise1);
      
   rand2 : lfsr
   generic map(WIDTH => 32)
   port map(clk_i  => clk,
            rst_i  => rst,
            ena_i  => '1',
            load_i => noise_init,
            clr_i  => '0',
            lfsr_i => seed2,
            lfsr_o => noise2);

   rand3 : lfsr
   generic map(WIDTH => 32)
   port map(clk_i  => clk,
            rst_i  => rst,
            ena_i  => '1',
            load_i => noise_init,
            clr_i  => '0',
            lfsr_i => seed3,
            lfsr_o => noise3);

   rand4 : lfsr
   generic map(WIDTH => 32)
   port map(clk_i  => clk,
            rst_i  => rst,
            ena_i  => '1',
            load_i => noise_init,
            clr_i  => '0',
            lfsr_i => seed4,
            lfsr_o => noise4);
   
   rand5 : lfsr
   generic map(WIDTH => 32)
   port map(clk_i  => clk,
            rst_i  => rst,
            ena_i  => '1',
            load_i => noise_init,
            clr_i  => '0',
            lfsr_i => seed5,
            lfsr_o => noise5);

   rand6 : lfsr
   generic map(WIDTH => 32)
   port map(clk_i  => clk,
            rst_i  => rst,
            ena_i  => '1',
            load_i => noise_init,
            clr_i  => '0',
            lfsr_i => seed6,
            lfsr_o => noise6);

   rand7 : lfsr
   generic map(WIDTH => 32)
   port map(clk_i  => clk,
            rst_i  => rst,
            ena_i  => '1',
            load_i => noise_init,
            clr_i  => '0',
            lfsr_i => seed7,
            lfsr_o => noise7);


   ---------------------------------------------------------------------------------------
   -- Transmit Section            
   ---------------------------------------------------------------------------------------

   -- TRANSMIT or COMBO modes:
   --    tx0_o = predefined pseudorandom sequence
   --    tx1_o = noise
   --    tx2_o = noise
   --
   -- LOOPBACK mode:
   --    tx0_o = rx_i
   --    tx1_o = noise
   --    tx2_o = noise
   --
   -- RECEIVE, NOISE_1, NOISE_2, NOISE_3, or NOISE_4 modes:
   --    tx0_o = noise
   --    tx1_o = noise
   --    tx2_o = noise


   -- LVDS transmitters:

   tx0 : lvds_tx
   port map(clk_i  => clk,
            rst_i  => rst,
            dat_i  => lvds_tx_data,
            rdy_i  => lvds_tx_rdy,
            busy_o => lvds_tx_busy,
            lvds_o => tx);

   with mode_i select
      lvds_tx_data <= data & data(7 downto 0) when TRANSMIT | COMBO,
                      noise1                  when NOISE_1,
                      noise2                  when NOISE_2,
                      noise3                  when NOISE_3,
                      noise4                  when NOISE_4,
                      noise5                  when others;
   
   with mode_i select
      tx0_o <= rx_i when LOOPBACK,       -- receiver loopback
               tx   when others;         -- transmitting from LVDS transmitter

   tx1 : lvds_tx
   port map(clk_i  => clk,
            rst_i  => rst,
            dat_i  => noise6,
            rdy_i  => '1',
            busy_o => open,
            lvds_o => tx1_o);

   tx2 : lvds_tx
   port map(clk_i  => clk,
            rst_i  => rst,
            dat_i  => noise7,
            rdy_i  => '1',
            busy_o => open,
            lvds_o => tx2_o);

                     
   -- Transmit Control:
   
   tx_stateFF: process(clk, rst)
   begin
      if(rst = '1') then
         tx_ps <= TX_IDLE;
      elsif(clk'event and clk = '1') then
         tx_ps <= tx_ns;
      end if;
   end process tx_stateFF;
   
   tx_stateNS: process(tx_ps, count, lvds_tx_busy)
   begin
      case tx_ps is
         when TX_IDLE => if(count = 2047) then
                            tx_ns <= SEND;
                         else
                            tx_ns <= TX_IDLE;
                         end if;
                                                       
         when SEND =>    if(lvds_tx_busy = '0') then
                            tx_ns <= TX_INCR;
                         else
                            tx_ns <= SEND;
                         end if;
                              
         when TX_INCR => tx_ns <= SEND;
         
         when others =>  tx_ns <= TX_IDLE;
      end case;
   end process tx_stateNS;
   
   tx_stateOut: process(tx_ps)
   begin
      noise_init  <= '0';
      lvds_tx_rdy <= '0';
      data_incr   <= '0';
      sending     <= '0';
      
      case tx_ps is
         when TX_IDLE => noise_init  <= '1';
         
         when SEND =>    lvds_tx_rdy <= '1';
                         sending     <= '1';
         
         when TX_INCR => data_incr   <= '1';
                         sending     <= '1';
         
         when others =>  null;
      end case;
   end process tx_stateOut;
   
      
   ---------------------------------------------------------------------------------------
   -- Receiver Section            
   ---------------------------------------------------------------------------------------
   
   -- Receive datapath:

   rx0 : lvds_rx
   port map(comm_clk_i => comm_clk,
            rst_i      => rst,
            dat_o      => lvds_rx_data,
            rdy_o      => lvds_rx_rdy,
            ack_i      => lvds_rx_ack,
            lvds_i     => rx_i);
   
   reg0 : reg
   generic map(WIDTH => 32)
   port map(clk_i  => clk,
            rst_i  => rst,
            ena_i  => rx_data_ld,
            reg_i  => lvds_rx_data,
            reg_o  => rx_data);
         
   rand8 : lfsr
   generic map(WIDTH => 24)
   port map(clk_i  => clk,
            rst_i  => rst,
            ena_i  => orig_data_ld,
            load_i => '0',
            clr_i  => orig_data_clr,
            lfsr_i => (others => '0'),
            lfsr_o => orig_data);


   diff <= rx_data xor (orig_data & orig_data(7 downto 0));

   count0: ones_count
   port map(data_i  => diff,
            count_o => num_bit_err);

   reg1 : reg
   generic map(WIDTH => 32)
   port map(clk_i  => clk,
            rst_i  => rst,
            ena_i  => error_count_ld,
            reg_i  => bit_err_sum,
            reg_o  => total_bit_err);
                        
   bit_err_sum <= total_bit_err + num_bit_err;
      

   reg2 : reg
   generic map(WIDTH => 32)
   port map(clk_i  => clk,
            rst_i  => rst,
            ena_i  => error_count_ld,
            reg_i  => pkt_err_sum,
            reg_o  => total_pkt_err);
                        
   pkt_err_sum <= (total_pkt_err + x"00000001") when (num_bit_err > "000000") else total_pkt_err;
   

   reg3 : reg
   generic map(WIDTH => 32)
   port map(clk_i  => clk,
            rst_i  => rst,
            ena_i  => loop_count_ld,
            reg_i  => loops_incr,
            reg_o  => total_loops);
               
   loops_incr <= total_loops + x"00000001";
   
      
   -- Receive Control:
   
   process(clk, rst)
   begin
      if(rst = '1') then
         rx_ps <= RX_IDLE;
      elsif(clk'event and clk = '1') then
         rx_ps <= rx_ns;
      end if;
   end process;
   
   process(rx_ps, mode_i, lvds_rx_rdy, lvds_rx_data)
   begin
      case rx_ps is
         when RX_IDLE =>    if((mode_i = RECEIVE and lvds_rx_rdy = '1' and lvds_rx_data = x"00000000") or
                               (mode_i = COMBO   and lvds_rx_rdy = '1' and lvds_rx_data = x"00000000")) then
                               rx_ns <= LATCH;
                            else
                               rx_ns <= RX_IDLE;
                            end if;

         when LATCH =>      rx_ns <= COMPARE;      
                                  
         when COMPARE =>    rx_ns <= ACCUMULATE;   
         
         when ACCUMULATE => rx_ns <= RX_INCR;      
         
         when RX_INCR =>    rx_ns <= WAITING;      
         
         when WAITING =>    if(lvds_rx_rdy = '1') then
                               rx_ns <= LATCH;
                            else
                               rx_ns <= WAITING;
                            end if;
                                  
         when others =>     rx_ns <= RX_IDLE;
      end case;
   end process;
   
   process(rx_ps, orig_data)
   begin
      lvds_rx_ack    <= '0';
      orig_data_ld   <= '0';
      orig_data_clr  <= '0';
      rx_data_ld     <= '0';
      error_count_ld <= '0';
      loop_count_ld  <= '0';
      locked         <= '0';
      
      case rx_ps is
         when RX_IDLE =>    orig_data_ld   <= '1';
                            orig_data_clr  <= '1';
         
         when LATCH =>      lvds_rx_ack    <= '1';
                            rx_data_ld     <= '1';
                            locked         <= '1';

         when COMPARE | 
              WAITING =>    locked         <= '1';

         when ACCUMULATE => if(orig_data = x"00000000") then   -- pattern is cyclic, increment loop count when it restarts at 0
                               loop_count_ld <= '1';
                            end if;
                            error_count_ld <= '1';
                            locked         <= '1';
                                  
         when RX_INCR =>    orig_data_ld   <= '1';
                            locked         <= '1';
         
         when others =>     null;
      end case;
   end process;


   ---------------------------------------------------------------------------------------
   -- Output Section            
   ---------------------------------------------------------------------------------------

   nlock_o <= not locked  when mode_i = RECEIVE  or mode_i = COMBO else '1';
   ndata_o <= not sending when mode_i = TRANSMIT or mode_i = COMBO else '1';
   nrand_o <= not sending when mode_i = NOISE_1  or mode_i = NOISE_2 or mode_i = NOISE_3 or mode_i = NOISE_4 else '1';
     
   process(clk, rst)
   begin
      if(rst = '1') then
         output_sel <= "00";
      elsif(clk'event and clk = '1') then
         output_sel <= output_sel + "01";
      end if;
   end process;

   with output_sel select
      output_o <= total_bit_err when "00",
                  total_pkt_err when "01",
                  total_loops when others;

end rtl;