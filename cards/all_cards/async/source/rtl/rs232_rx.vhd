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
port(comm_clk_i : in std_logic;
     rst_i      : in std_logic;
     
     dat_o      : out std_logic_vector(7 downto 0);
     rdy_o      : out std_logic;
     ack_i      : in std_logic;
     
     rs232_i    : in std_logic);
end rs232_rx;

architecture rtl of rs232_rx is

signal sample_count     : integer range 0 to 17362;
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
   generic map(MAX => 17361,
               WRAP_AROUND => '0')
   port map(clk_i   => comm_clk_i,
            rst_i   => rst_i,
            ena_i   => sample_count_ena,
            load_i  => sample_count_clr,
            count_i => 0,
            count_o => sample_count);
            
   rx_sample: shift_reg
   generic map(WIDTH => 3)
   port map(clk_i      => comm_clk_i,
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
   port map(clk_i      => comm_clk_i,
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
   port map(clk_i  => comm_clk_i,
            rst_i  => rst_i,
            ena_i  => data_ld,
 
            reg_i  => rx_buf(8 downto 1),
            reg_o  => dat_o);


------------------------------------------------------------
--
--  Receive FSM : Controls the receiver datapath
--
------------------------------------------------------------

   stateFF: process(rst_i, comm_clk_i)
   begin
      if(rst_i = '1') then
         pres_state <= IDLE;
      elsif(comm_clk_i'event and comm_clk_i = '1') then
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
                      
         when RECV => if(sample_count = 17361) then
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
                       -- for RS232 bitrate of 115 kbps, sample each bit for every 217 comm_clk_i periods.
                       if(sample_count = 216   or sample_count = 433   or sample_count = 650   or sample_count = 867   or 
                          sample_count = 1084  or sample_count = 1301  or sample_count = 1952  or sample_count = 2169  or 
                          sample_count = 2386  or sample_count = 2603  or sample_count = 2820  or sample_count = 3037  or 
                          sample_count = 3688  or sample_count = 3905  or sample_count = 4122  or sample_count = 4339  or
                          sample_count = 4556  or sample_count = 4773  or sample_count = 5424  or sample_count = 5641  or 
                          sample_count = 5858  or sample_count = 6075  or sample_count = 6292  or sample_count = 6509  or 
                          sample_count = 7160  or sample_count = 7377  or sample_count = 7594  or sample_count = 7811  or 
                          sample_count = 8028  or sample_count = 8245  or sample_count = 8896  or sample_count = 9113  or 
                          sample_count = 9330  or sample_count = 9547  or sample_count = 9764  or sample_count = 9981  or 
                          sample_count = 10632 or sample_count = 10849 or sample_count = 11066 or sample_count = 11283 or 
                          sample_count = 11500 or sample_count = 11717 or sample_count = 12368 or sample_count = 12585 or 
                          sample_count = 12802 or sample_count = 13019 or sample_count = 13236 or sample_count = 13453 or 
                          sample_count = 14104 or sample_count = 14321 or sample_count = 14538 or sample_count = 14755 or 
                          sample_count = 14972 or sample_count = 15189 or sample_count = 15840 or sample_count = 16057 or 
                          sample_count = 16274 or sample_count = 16491 or sample_count = 16708 or sample_count = 16925) then
                          sample_buf_ena <= '1';
                       end if;
                       if(sample_count = 1302  or sample_count = 3038  or sample_count = 4774  or sample_count = 6510  or 
                          sample_count = 8246  or sample_count = 9982  or sample_count = 11718 or sample_count = 13454 or 
                          sample_count = 15190 or sample_count = 16926) then 
                          rx_buf_ena <= '1';
                       end if;
                       if(sample_count = 17361) then 
                          data_ld       <= '1';
                       end if;
                       
         when READY => rdy              <= '1';
      end case;
   end process stateOut;


   process(comm_clk_i)
   begin
      if(comm_clk_i = '1') then
         ack <= ack_i;
      end if;
   end process;
   
   process(rst_i, comm_clk_i)
   begin
      if(rst_i = '1') then
         rdy_o <= '0';
      elsif(comm_clk_i'event and comm_clk_i = '1') then
         if(rdy = '1') then
            rdy_o <= '1';
         elsif(ack = '1') then
            rdy_o <= '0';
         end if;
      end if;
   end process;
                      
end rtl;