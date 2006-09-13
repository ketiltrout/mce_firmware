---------------------------------------------------------------------
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
--
-- Project:	      SCUBA-2
-- Author:	      Mandana Amiri
-- 
-- Organisation:  UBC
--
-- Description:
-- fo_bist file.  With the loopback cable on, this test sends 3 data
-- patterns to the transmitter chip (U20) and then this data can be verified
-- on the scope on the receiver side. The test can be toggled on an off through
-- en_i interface.
--
-- Revision history:
-- <date $Date: 2006/09/08 20:24:12 $>	- <initials $Author: mandana $>
-- $Log: fo_bist.vhd,v $
-- Revision 1.1  2006/09/08 20:24:12  mandana
-- Initial release, modified version of fo_test integrated in cc_test
--
-- Revision 1.5  2006/03/08 19:35:59  bench2
-- Mandana: Register the outputs
--
-- Revision 1.4  2006/03/02 23:20:16  bench2
-- Mandana: integrated cc_pll and changed top-level name to fo_bist
--
-- Revision 1.3  2005/10/28 19:04:37  mandana
-- Updated for Rev. B Clock_card tcl file
-- signal name changes, more pins added for fibre interface to enable bist functionality.
-- BIST functionality not covered yet
-- rxrefclk is now generated through the PLL
--
-- Revision 1.2  2004/10/22 03:57:49  erniel
-- replaced "test" port with "mictor" port
-- connected fibre receive ports to debug mictor
--
-- Revision 1.1  2004/06/10 16:52:14  mandana
-- initial release: stand-alone fibre test
--
-----------------------------------------------------------------------------

library ieee, sys_param, components, work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fo_bist is
   port(
      rst_i    : in std_logic;
      clk_i    : in std_logic;
      clk_n_i  : in std_logic;
      en_i     : in std_logic;
      done_o   : out std_logic;
      
      -- fibre pins
      fibre_tx_data_o   : out std_logic_vector(7 downto 0);
      fibre_tx_clkW_o   : out std_logic;
      fibre_tx_ena_o    : out std_logic;
      fibre_tx_rp_o     : in std_logic;
      fibre_tx_sc_nd_o  : out std_logic;
      fibre_tx_enn_o    : out std_logic;
      -- fibre_tx_svs is tied to gnd on board
      -- fibre_tx_enn is tied to vcc on board
      -- fibre_tx_mode is tied to gnd on board
      fibre_tx_foto_o   : out std_logic;
      fibre_tx_bisten_o : out std_logic;
      
      fibre_rx_data_i   : in std_logic_vector(7 downto 0);
      --fibre_rx_refclk : out std_logic;
      fibre_rx_clkr_i   : in std_logic;
      fibre_rx_error_i  : in std_logic;
      fibre_rx_rdy_i    : in std_logic;
      fibre_rx_status_i : in std_logic;
      fibre_rx_sc_nd_i  : in std_logic;
      fibre_rx_rvs_i    : in std_logic;
      fibre_rx_rf_o     : out std_logic; --  is tied to vcc on board, we lifted the pin and routed it to P10.22
      fibre_rx_a_nb_o   : out std_logic;
      fibre_rx_bisten_o : out std_logic;
      
      -- data sent back
      rx_data1_o        : out std_logic_vector(7 downto 0);
      rx_data2_o        : out std_logic_vector(7 downto 0);
      rx_data3_o        : out std_logic_vector(7 downto 0);
      
      --test pins
      mictor_o : out std_logic_vector(12 downto 0)
      );
end fo_bist;

                     
architecture rtl of fo_bist is
   signal fibre_tx_data_prereg : std_logic_vector(7 downto 0);
   signal fibre_tx_ena_prereg  : std_logic;
   signal active               : std_logic := '0';
   signal en_reg               : std_logic;
   signal rxcount              : integer range 0 to 6;
   signal rx_data              : std_logic_vector(7 downto 0); 
   signal rx_data1             : std_logic_vector(7 downto 0);
   signal rx_data2             : std_logic_vector(7 downto 0);
   signal rx_data3             : std_logic_vector(7 downto 0);
   signal fifo_rd              : std_logic;
   signal fifo_wr              : std_logic;
   signal fifo_full            : std_logic;
   signal fifo_empty           : std_logic;
   signal fifo_clr             : std_logic;
   signal rxcount_ena          : std_logic;
   signal rxcount_ld           : std_logic;
   signal rxdata_ena           : std_logic;
   
   -- state signals
   type states is (TX_DATA1, TX_EN1,TX_DATA2, TX_EN2, TX_DATA3, TX_EN3);
   signal present_state : states;
   signal next_state    : states;
   type rx_states is (IDLE, RX_START, RX_REQ, RX_LOAD, RX_DONE);
   signal present_rx_state : rx_states;
   signal next_rx_state    : rx_states;

component fo_rx_fifo 
   PORT(
   aclr		: IN STD_LOGIC  := '0';
   data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
   rdclk		: IN STD_LOGIC ;
   rdreq		: IN STD_LOGIC ;
   wrclk		: IN STD_LOGIC ;
   wrreq		: IN STD_LOGIC ;
   q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
   rdempty		: OUT STD_LOGIC ;
   wrfull		: OUT STD_LOGIC 
   );
END component;
     
begin


-- BIST Mode assignments 
--  fibre_tx_bisten <= '0';
--  fibre_tx_ena <= '1';
--  fibre_tx_enn    <= '1';
--  fibre_tx_foto   <= 'Z';
--  fibre_rx_bisten <= '0';
--  fibre_rx_a_nb   <= '0';
--  fibre_rx_rf     <= '0';
--  fibre_tx_sc_nd <= '0';
      
-- Normal mode assignments      
   fibre_tx_bisten_o <= '1';
--  fibre_tx_ena <= '1';
   fibre_tx_enn_o    <= '1';
   fibre_tx_foto_o   <= 'Z';
   fibre_rx_bisten_o <= '1';
   fibre_rx_a_nb_o   <= '1';
   fibre_rx_rf_o     <= '1';
   fibre_tx_sc_nd_o  <= '0';
  
   --mictor_o(8 downto 1) <= fibre_rx_data_i;
   --mictor_o(9) <=  fibre_rx_rdy_i;
   --mictor_o(10) <= fibre_rx_status_i;
   --mictor_o(11) <= fibre_rx_sc_nd_i;
   --mictor_o(12) <= fibre_rx_rvs_i;

   -- transmit state machine
   state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then 
         present_state <= TX_DATA1;
      elsif(clk_i'event and clk_i = '1') then
         present_state <= next_state;
      end if;
   end process state_FF;
   ---------------------------------------------------------------   
   state_NS: process(present_state, en_i)
   begin
      next_state <= present_state;
      case present_state is
         when TX_DATA1 =>     
            if (active = '1') then
               next_state <= TX_EN1;
            end if;
            
         when TX_EN1 =>
            next_state  <= TX_DATA2; 
            
         when TX_DATA2 =>
            next_state  <= TX_EN2;                  
            
         when TX_EN2 =>
            next_state  <= TX_DATA3; 

         when TX_DATA3 =>
            next_state  <= TX_EN3;                  
            
         when TX_EN3 =>
            next_state  <= TX_DATA1; 
         
         when others => 
            next_state  <= TX_DATA1;
                                    
      end case;
   end process state_NS;
   -----------------------------------------------------------------   
   state_out: process(present_state)
   begin
      -- default states
      
      fibre_tx_ena_prereg   <= '1';    
      
      case present_state is
         when TX_DATA1 =>  fibre_tx_data_prereg  <= "00000000";
         
         when TX_EN1   =>  fibre_tx_data_prereg  <= "00000000";
                           fibre_tx_ena_prereg   <= '0';               

         when TX_DATA2 =>  fibre_tx_data_prereg  <= "11111111";
         
         when TX_EN2   =>  fibre_tx_data_prereg  <= "11111111";
                           fibre_tx_ena_prereg   <= '0';               

         when TX_DATA3 =>  fibre_tx_data_prereg  <= "10101010";
         
         when TX_EN3   =>  fibre_tx_data_prereg  <= "10101010";
                           fibre_tx_ena_prereg   <= '0';  
            
         when others   =>  fibre_tx_data_prereg  <= "00000000";
	                              
      end case;
   end process state_out;
   -----------------------------------------------------------------      
   tx_reg: process(clk_n_i, rst_i)
   begin
      if(rst_i = '1') then 
         fibre_tx_data_o <= (others => '0');
         fibre_tx_ena_o  <= '1';
      elsif(clk_n_i'event and clk_n_i = '1') then
         fibre_tx_data_o <= fibre_tx_data_prereg;
         fibre_tx_ena_o  <= fibre_tx_ena_prereg;
      end if;
   end process tx_reg;

   gen_controlsig: process(clk_i, rst_i)
   begin
      if (rst_i = '1') then
        active <= '0';
--        done_o <= '0';
        en_reg <= '0';
      elsif (clk_i'event and clk_i = '1') then
        if(en_i = '1' and en_reg = '0') then
           active <= not active;
        end if;
 --       done_o <= en_i;         
        en_reg <= en_i;
      end if;  
   end process gen_controlsig;
   


   ---------------------------------------------------------------   

   -- Receive fifo   
   fo_receive: fo_rx_fifo 
   PORT map(
      aclr    => fifo_clr,
      data    => fibre_rx_data_i,
      rdclk   => clk_i,
      rdreq   => fifo_rd,
      wrclk   => fibre_rx_clkr_i,
      wrreq   => fifo_wr,
      q	      => rx_data,
      rdempty => fifo_empty,
      wrfull  => fifo_full
   );   
   
   fifo_wr <= not(fibre_rx_rdy_i) and not(fibre_rx_sc_nd_i) and not(fibre_rx_rvs_i) and not(fifo_full) and fibre_rx_status_i;
   
   -- Receive state machine
   state_rx_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then 
         present_rx_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         present_rx_state <= next_rx_state;
      end if;
   end process state_rx_FF;
   ---------------------------------------------------------------   
   state_rx_NS: process(present_rx_state)
   begin
      next_rx_state <= present_rx_state;
      case present_rx_state is
         when IDLE =>    
            if (active = '1' and en_i = '1') then 
               next_rx_state <= RX_START;
            end if;
                         
         when RX_START => 
            if (active = '0') then
               next_rx_state <= IDLE;               
            elsif (fifo_empty = '0') then
               next_rx_state <= RX_REQ;
            end if;
         
         when RX_REQ =>  
            next_rx_state <= RX_LOAD;
            
         when RX_LOAD => 
            if (rxcount =3) then 
               next_rx_state <= RX_DONE;
            else   
               next_rx_state <= RX_REQ;
            end if;
         when RX_DONE => 
            next_rx_state <= IDLE;
                         
         when others =>  
            next_rx_state <= IDLE;
            
      end case;
   end process state_rx_NS;    
   
   state_rx_out: process(present_rx_state)
   begin
      -- default assignments
      fifo_rd     <= '0';
      fifo_clr    <= '0';
      rxcount_ena <= '0';
      rxcount_ld  <= '0';
      rxdata_ena  <= '0';
      done_o      <= '0';
      
      case present_rx_state is
         when IDLE =>     
            fifo_clr <= '1';
         
         when RX_START => 
            if (active = '0') then 
               done_o   <= '1';
            end if;  
            rxcount_ld <= '1';
         
         when RX_REQ =>   
            fifo_rd <= '1';
         
         when RX_LOAD =>  
            if (rxcount < 3) then
            --if (rxcount /=0 or rx_data = x"AA") then  
               rxcount_ena <= '1';
               rxdata_ena  <= '1';
            --end if;   
            else
               done_o <= '1';
            end if;  
                          
         when RX_DONE => 
            null;
         
         when others =>   
            null;
            
      end case;   
   end process state_rx_out;                     
                         
   -- byte counter      
   rx_counter: process(rst_i, clk_i)
   begin
      if (rst_i = '1') then
         rxcount <= 0;
         rx_data1 <= (others => '0');
         rx_data2 <= (others => '0');
         rx_data3 <= (others => '0');
      elsif (clk_i'event and clk_i = '1') then
         if (rxcount_ld = '1') then
            rxcount <= 0;  
            rx_data1 <= (others => '0');
            rx_data2 <= (others => '0');
            rx_data3 <= (others => '0');
         elsif (rxcount_ena = '1') then
            rxcount <= rxcount + 1;
         end if;
         if (rxdata_ena = '1') then
            rx_data1 <= rx_data;
            rx_data2 <= rx_data1;
            rx_data3 <= rx_data2;
         end if;   
      end if;   
   end process rx_counter;
   
   rx_data1_o <= rx_data1;
   rx_data2_o <= rx_data2;
   rx_data3_o <= rx_data3;
end rtl;