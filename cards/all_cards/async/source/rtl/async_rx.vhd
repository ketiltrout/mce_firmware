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
port(rx_clk_i : in std_logic;   -- 200 MHz for LVDS, 921.6 kHz for RS232
     rst_i    : in std_logic;
     
     dat_o    : out std_logic_vector (7 downto 0);
     stb_i    : in std_logic;
     rx_i     : in std_logic;
     valid_o  : out std_logic;
     error_o  : out std_logic);
end async_rx ;

---------------------------------------------------------------------

architecture behaviour of async_rx is

   type states is (IDLE, RECEIVE, DONE);
   signal pres_state : states;
   signal next_state : states;
   
   signal sample_buf_ena : std_logic;
   signal sample_buf_clr : std_logic;  
   signal sample_buf     : std_logic_vector(2 downto 0);
   
   signal rxbit  : std_logic; 
   
   signal data_buf_ena : std_logic;
   signal data_buf_clr : std_logic;
   signal data_buf     : std_logic_vector(9 downto 0);
   
   signal count_clr : std_logic;
   signal count     : integer;   
   
begin

   rx_sample_buf: shift_reg
   generic map(WIDTH => 3)
   port map(clk_i      => rx_clk_i,
            rst_i      => rst_i,
            ena_i      => sample_buf_ena,
            load_i     => '0',
            clr_i      => sample_buf_clr,
            shr_i      => '1',
            serial_i   => rx_i,
            serial_o   => open,
            parallel_i => (others => '0'),
            parallel_o => sample_buf);

   rxbit <= (sample_buf(2) and sample_buf(1)) or (sample_buf(2) and sample_buf(0)) or (sample_buf(1) and sample_buf(0));
   
   rx_data_buf: shift_reg
   generic map(WIDTH => 10)
   port map(clk_i      => rx_clk_i,
            rst_i      => rst_i,
            ena_i      => data_buf_ena,
            load_i     => '0',
            clr_i      => data_buf_clr,
            shr_i      => '1',
            serial_i   => rxbit,
            serial_o   => open,
            parallel_i => (others => '0'),
            parallel_o => data_buf);
            
   data_buf_ena <= '1' when ((count =  3) or (count = 11) or (count = 19) or (count = 27) or (count = 35) or
                             (count = 43) or (count = 51) or (count = 59) or (count = 67) or (count = 75))
                       else '0';
   
   rx_counter: counter
   generic map(MAX => 80,
               WRAP_AROUND => '0')
   port map(clk_i   => rx_clk_i,
            rst_i   => rst_i,
            ena_i   => '1',
            load_i  => count_clr,
            count_i => 0,
            count_o => count);
   
   stateFF: process(rst_i, rx_clk_i)
   begin
      if(rst_i = '1') then
         pres_state <= IDLE;
      elsif(rx_clk_i'event and rx_clk_i = '1') then
         pres_state <= next_state;
      end if;
   end process stateFF;
   
   stateNS: process(pres_state, rx_i, stb_i, count)
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
                                                  
         when DONE =>    if(stb_i = '1') then
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
      valid_o        <= '0';
      error_o        <= '0';               -- error_o indicates framing error 
      dat_o          <= (others => '0');
      
      case pres_state is
         when IDLE =>    sample_buf_ena <= '1';
                         sample_buf_clr <= '1';
                         data_buf_clr   <= '1';
                         count_clr      <= '1';
                         
         when RECEIVE => sample_buf_ena <= '1';
                                                  
         when DONE =>    valid_o <= '1';
                         error_o <= not data_buf(9);                        
                         dat_o <= data_buf(8 downto 1);
      end case;
   end process stateOut;
   
end behaviour;