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
-- rs232_rx.vhd
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- RS232 receive module (RS232 wrapper for async_rx)
--
-- Revision history:
-- 
-- $Log: rs232_rx.vhd,v $
-- Revision 1.4  2005/01/12 22:47:11  erniel
-- removed async_rx instantiation
-- removed clk_i from ports
-- modified receiver datapath (based on async_rx datapath)
-- modified receiver control
-- modified rdy_o / ack_i logic
-- signal name and state name changes
--
-- Revision 1.3  2005/01/05 23:39:31  erniel
-- updated async_rx component
--
-- Revision 1.2  2004/12/17 00:21:30  erniel
-- removed clock divider logic (moved to async_rx)
-- modified buffering to allow word to persist until next word ready
-- reworked FSM to handle new async_rx interface
--
-- Revision 1.1  2004/06/18 22:14:24  erniel
-- initial version
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library components;
use components.component_pack.all;

entity rs232_rx is
port(clk_i      : in std_logic;
     rst_i      : in std_logic;
     
     dat_o      : out std_logic_vector(7 downto 0);
     rdy_o      : out std_logic;
     ack_i      : in std_logic;
     
     rs232_i    : in std_logic);
end rs232_rx;

architecture rtl of rs232_rx is

signal sample_count     : integer range 0 to 4340;
signal sample_count_ena : std_logic;
signal sample_count_clr : std_logic;

signal sample_buf     : std_logic_vector(2 downto 0);
signal sample_buf_ena : std_logic;
signal sample_buf_clr : std_logic;

signal rx_bit     : std_logic;
signal rx_buf     : std_logic_vector(9 downto 0);
signal rx_buf_ena : std_logic;
signal rx_buf_clr : std_logic;

signal data_ld : std_logic;

signal rdy : std_logic;
signal ack : std_logic;

type states is (IDLE, RECV, READY);
signal pres_state : states;
signal next_state : states;

begin
    
   sample_counter: counter
   generic map(MAX => 4339,
               WRAP_AROUND => '0')
   port map(clk_i   => clk_i,
            rst_i   => rst_i,
            ena_i   => sample_count_ena,
            load_i  => sample_count_clr,
            count_i => 0,
            count_o => sample_count);
            
   rx_sample: shift_reg
   generic map(WIDTH => 3)
   port map(clk_i      => clk_i,
            rst_i      => rst_i,
            ena_i      => sample_buf_ena,
            load_i     => '0',
            clr_i      => sample_buf_clr,
            shr_i      => '1',
            serial_i   => rs232_i,
            serial_o   => open,
            parallel_i => (others => '0'),
            parallel_o => sample_buf);
            
   -- received bit is majority function of sample buffer
   rx_bit <= (sample_buf(2) and sample_buf(1)) or (sample_buf(2) and sample_buf(0)) or (sample_buf(1) and sample_buf(0));
   
   rx_buffer: shift_reg
   generic map(WIDTH => 10)
   port map(clk_i      => clk_i,
            rst_i      => rst_i,
            ena_i      => rx_buf_ena,
            load_i     => '0',
            clr_i      => rx_buf_clr,
            shr_i      => '1',
            serial_i   => rx_bit,
            serial_o   => open,
            parallel_i => (others => '0'),
            parallel_o => rx_buf);
            
   data_buffer: reg
   generic map(WIDTH => 8)
   port map(clk_i  => clk_i,
            rst_i  => rst_i,
            ena_i  => data_ld,
 
            reg_i  => rx_buf(8 downto 1),
            reg_o  => dat_o);


------------------------------------------------------------
--
--  Receive FSM : Controls the receiver datapath
--
------------------------------------------------------------

   stateFF: process(rst_i, clk_i)
   begin
      if(rst_i = '1') then
         pres_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         pres_state <= next_state;
      end if;
   end process stateFF;
   
   stateNS: process(pres_state, rs232_i, sample_count)
   begin
      case pres_state is
         when IDLE => if(rs232_i = '0') then
                         next_state <= RECV;
                      else
                         next_state <= IDLE;
                      end if;
                      
         when RECV => if(sample_count = 4339) then
                         next_state <= READY;
                      else
                         next_state <= RECV;
                      end if;
                      
         when READY => next_state <= IDLE;
      end case;
   end process stateNS;
   
   stateOut: process(pres_state, sample_count)
   begin
      sample_count_ena <= '0';
      sample_count_clr <= '0';
      sample_buf_ena   <= '0';
      sample_buf_clr   <= '0';
      rx_buf_ena       <= '0';
      rx_buf_clr       <= '0';
      data_ld          <= '0';
      rdy              <= '0';
      
      case pres_state is
         when IDLE =>  sample_count_ena <= '1';
                       sample_count_clr <= '1';
                       sample_buf_ena   <= '1';
                       sample_buf_clr   <= '1';
                       rx_buf_ena       <= '1';
                       rx_buf_clr       <= '1';
                       
         when RECV =>  sample_count_ena <= '1';
                       -- for RS232 bitrate of 115 kbps, sample each bit for every 54 clk_i periods.
                       if(sample_count = 53   or sample_count = 107  or sample_count = 161  or sample_count = 216  or 
                          sample_count = 270  or sample_count = 324  or sample_count = 487  or sample_count = 541  or 
                          sample_count = 595  or sample_count = 650  or sample_count = 704  or sample_count = 758  or
                          sample_count = 921  or sample_count = 975  or sample_count = 1029 or sample_count = 1084 or 
                          sample_count = 1138 or sample_count = 1192 or sample_count = 1355 or sample_count = 1409 or 
                          sample_count = 1463 or sample_count = 1518 or sample_count = 1572 or sample_count = 1626 or 
                          sample_count = 1789 or sample_count = 1843 or sample_count = 1897 or sample_count = 1952 or 
                          sample_count = 2006 or sample_count = 2060 or sample_count = 2223 or sample_count = 2277 or 
                          sample_count = 2331 or sample_count = 2386 or sample_count = 2440 or sample_count = 2494 or 
                          sample_count = 2657 or sample_count = 2711 or sample_count = 2765 or sample_count = 2820 or 
                          sample_count = 2874 or sample_count = 2928 or sample_count = 3091 or sample_count = 3145 or 
                          sample_count = 3199 or sample_count = 3254 or sample_count = 3308 or sample_count = 3362 or 
                          sample_count = 3525 or sample_count = 3579 or sample_count = 3633 or sample_count = 3688 or 
                          sample_count = 3742 or sample_count = 3796 or sample_count = 3959 or sample_count = 4013 or 
                          sample_count = 4067 or sample_count = 4122 or sample_count = 4176 or sample_count = 4230) then
                          sample_buf_ena <= '1';
                       end if;
                       if(sample_count = 325  or sample_count = 759  or sample_count = 1193 or sample_count = 1627 or 
                          sample_count = 2061 or sample_count = 2495 or sample_count = 2929 or sample_count = 3363 or 
                          sample_count = 3797 or sample_count = 4231) then 
                          rx_buf_ena <= '1';
                       end if;
                       if(sample_count = 4339) then 
                          data_ld       <= '1';
                       end if;
                       
         when READY => rdy              <= '1';
      end case;
   end process stateOut;
   
   process(rst_i, clk_i)
   begin
      if(rst_i = '1') then
         rdy_o <= '0';
      elsif(clk_i'event and clk_i = '1') then
         if(rdy = '1') then
            rdy_o <= '1';
         elsif(ack_i = '1') then
            rdy_o <= '0';
         end if;
      end if;
   end process;
                      
end rtl;