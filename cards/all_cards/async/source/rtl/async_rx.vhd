---------------------------------------------------------------------
-- Copyright (c) 2003 UK Astronomy Technology Centre
--                All Rights Reserved
--
--  THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE UK ATC
--  The copyright notice above does not evidence any
--  actual or intended publication of such source code.
--
--  SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
--  REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
--  MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
--  PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
--  THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.
--
-- Project:             Scuba 2
-- Author:              Neil Gruending
-- Organisation:        UBC Physics and Astronomy
--
-- Description:
-- Wishbone asynchronous receiver implementation.
-- 
-- Revision History:
--
-- $Log: async_rx.vhd,v $
-- Revision 1.7  2004/12/10 01:34:44  erniel
-- added generic clock divide factor and clock division logic
-- changed sampling interval to centre of received bit
--
-- Revision 1.6  2004/09/01 17:54:19  erniel
-- fixed multiple sources error in shift_reg port map (open instead of '0')
--
-- Revision 1.5  2004/08/06 20:35:52  erniel
-- replaced some processes with rtl-blocks
--
-- Revision 1.4  2004/06/11 21:21:23  erniel
-- renamed clock signal to rx_clk_i
--
-- Revision 1.3  2004/06/11 18:30:46  erniel
-- changed interface to non-wishbone
-- reworked code body (made it RTL description)
--
-- Revision 1.2  2004/04/17 21:42:14  erniel
-- removed synthesis warnings
--
-- Dec 22, 2003: Initial version - NRG
--
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library components;
use components.component_pack.all;

---------------------------------------------------------------------

entity async_rx is
generic(CLK_DIV_FACTOR : integer := 2);
port(comm_clk_i : in std_logic;
     rst_i      : in std_logic;
     
     dat_o : out std_logic_vector (7 downto 0);
     rdy_o : out std_logic;
     ack_i : in std_logic;

     rx_i : in std_logic);     
end async_rx ;

---------------------------------------------------------------------

architecture behaviour of async_rx is

signal clk_div_count : integer range 0 to CLK_DIV_FACTOR-1;
signal rx_clk        : std_logic;

signal sample_buf_ena : std_logic;
signal sample_buf_clr : std_logic;  
signal sample_buf     : std_logic_vector(2 downto 0);
signal rx_data        : std_logic; 
   
signal count     : integer range 0 to 80;   
signal count_clr : std_logic;

signal data_buf_ena : std_logic;
signal data_buf_clr : std_logic;
signal data_buf     : std_logic_vector(9 downto 0);
      
type states is (IDLE, RECEIVE, DONE);
signal pres_state : states;
signal next_state : states;
   
begin

   clk_divide: counter
   generic map(MAX => CLK_DIV_FACTOR-1)
   port map(clk_i => comm_clk_i,
            rst_i => rst_i,
            ena_i => '1',
            load_i => '0',
            count_i => 0,
            count_o => clk_div_count);

   -- register clock divider output (to eliminate glitches from combinational compare)
   process(comm_clk_i)
   begin
      if(comm_clk_i'event and comm_clk_i = '1') then
         if(clk_div_count = CLK_DIV_FACTOR-1) then
            rx_clk <= '1';
         else
            rx_clk <= '0';
         end if;
      end if;
   end process;

   rx_sample: shift_reg
   generic map(WIDTH => 3)
   port map(clk_i      => rx_clk,
            rst_i      => rst_i,
            ena_i      => sample_buf_ena,
            load_i     => '0',
            clr_i      => sample_buf_clr,
            shr_i      => '1',
            serial_i   => rx_i,
            serial_o   => open,
            parallel_i => (others => '0'),
            parallel_o => sample_buf);

   rx_data <= (sample_buf(2) and sample_buf(1)) or (sample_buf(2) and sample_buf(0)) or (sample_buf(1) and sample_buf(0));
   
   rx_counter: counter
   generic map(MAX         => 80,
               WRAP_AROUND => '0')
   port map(clk_i   => rx_clk,
            rst_i   => rst_i,
            ena_i   => '1',
            load_i  => count_clr,
            count_i => 0,
            count_o => count);
   
   rx_buffer: shift_reg
   generic map(WIDTH => 10)
   port map(clk_i      => rx_clk,
            rst_i      => rst_i,
            ena_i      => data_buf_ena,
            load_i     => '0',
            clr_i      => data_buf_clr,
            shr_i      => '1',
            serial_i   => rx_data,
            serial_o   => open,
            parallel_i => (others => '0'),
            parallel_o => data_buf);
            
   data_buf_ena <= '1' when ((count =  5) or (count = 13) or (count = 21) or (count = 29) or (count = 37) or
                             (count = 45) or (count = 53) or (count = 61) or (count = 69) or (count = 77))
                       else '0';
                              
   stateFF: process(rst_i, rx_clk)
   begin
      if(rst_i = '1') then
         pres_state <= IDLE;
      elsif(rx_clk'event and rx_clk = '1') then
         pres_state <= next_state;
      end if;
   end process stateFF;
   
   stateNS: process(pres_state, rx_i, count, ack_i)
   begin
      case pres_state is
         when IDLE =>    if(rx_i = '0') then
                            next_state <= RECEIVE;
                         else
                            next_state <= IDLE;
                         end if;
                         
         when RECEIVE => if(count = 80) then
                            next_state <= DONE;
                         else 
                            next_state <= RECEIVE;
                         end if;
                                                  
         when DONE =>    if(ack_i = '1') then
                            next_state <= IDLE;
                         else
                            next_state <= DONE;
                         end if;
      end case;
   end process stateNS;
   
   stateOut: process(pres_state, data_buf)
   begin
      sample_buf_ena <= '0';
      sample_buf_clr <= '0';
      data_buf_clr   <= '0';
      count_clr      <= '0';
      rdy_o          <= '0';
      dat_o          <= (others => '0');
      
      case pres_state is
         when IDLE =>    sample_buf_ena <= '1';
                         sample_buf_clr <= '1';
                         data_buf_clr   <= '1';
                         count_clr      <= '1';
                         
         when RECEIVE => sample_buf_ena <= '1';
                                                  
         when DONE =>    rdy_o          <= '1';
                         dat_o          <= data_buf(8 downto 1);
      end case;
   end process stateOut;
   
end behaviour;