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
-- <revision control keyword substitutions e.g. $Id: card_id_test_wrapper.vhd,v 1.1 2004/03/12 21:06:00 jjacob Exp $>
--
-- Project:	      SCUBA-2
-- Author:	       Jonathan Jacob
-- 
-- Organisation:  UBC
--
-- Description:
-- card_id test wrapper file.  This file instanstiates the card_id
-- and emulates the master (command FSM, for example) on the wishbone bus.
--
-- Revision history:
-- <date $Date: 2004/03/12 21:06:00 $>	-		<text>		- <initials $Author: jjacob $>
--
-----------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
--use work.io_pack.all;
use work.card_id_pack.all;

library sys_param;
use sys_param.wishbone_pack.all;
-----------------------------------------------------------------------------
                     
entity card_id_test_wrapper is
   port (
      -- basic signals
      rst_i     : in std_logic;    -- reset input
      clk_i     : in std_logic;    -- clock input
      en_i      : in std_logic;    -- enable signal
      done_o    : out std_logic;   -- done ouput signal
      
      -- transmitter signals
      tx_busy_i : in std_logic;    -- transmit busy flag
      tx_ack_i  : in std_logic;    -- transmit ack
      tx_data_o : out std_logic_vector(7 downto 0);   -- transmit data
      tx_we_o   : out std_logic;   -- transmit write flag
      tx_stb_o  : out std_logic;   -- transmit strobe flag
      
      -- extended signals
      data_bi   : inout std_logic -- physical CARD_ID bi-directional pin
   );
end;

---------------------------------------------------------------------

architecture rtl of card_id_test_wrapper is

   -- state definitions
   type states is (IDLE, INITIALIZE, READ_LSB_PACKET, DONE, TX_CARD_ID);
   signal current_state, next_state : states;

   -- wishbone "emulated master" signals
   signal addr_o  : std_logic_vector (WB_ADDR_WIDTH-1 downto 0);
   signal tga_o   : std_logic_vector (WB_TAG_ADDR_WIDTH-1 downto 0);
   signal dat_o 	 : std_logic_vector (WB_DATA_WIDTH-1 downto 0);
   signal dat_i   : std_logic_vector (WB_DATA_WIDTH-1 downto 0);
   signal we_o    : std_logic;
   signal stb_o   : std_logic;
   signal ack_i   : std_logic;
   signal rty_i   : std_logic;
   signal cyc_o   : std_logic;
   
   
   signal card_id_data : std_logic_vector (63 downto 0);
   
   signal byte    : integer;
   
begin

------------------------------------------------------------------------
--
-- instantiate the card_id
--
------------------------------------------------------------------------

      card_id_test : card_id

      generic map(CARD_ID_ADDR   => CARD_ID_ADDR )

      port map(data_bi           => data_bi,
      
               clk_i             => clk_i,
               rst_i             => rst_i,
               dat_i             => dat_o,
               dat_o             => dat_i,
               addr_i            => addr_o,
               tga_i             => tga_o,
               we_i              => we_o,
               stb_i             => stb_o,
               ack_o             => ack_i,
               rty_o             => rty_i,
               cyc_i             => cyc_o);


 
   
   -- we don't use the transmitter
--   tx_data_o <= (others => '0');
--   tx_we_o <= '0';
--   tx_stb_o <= '0';

--         tx_we_o <= not(tx_ack_i or tx_busy_i or done);
--         tx_stb_o <= not(tx_ack_i or tx_busy_i or done);
          
------------------------------------------------------------------------
--
-- Emulate the master querying for the card_id
--
------------------------------------------------------------------------   

------------------------------------------------------------------------
--
-- assign next states
--
------------------------------------------------------------------------  


   process (current_state, en_i, rty_i, ack_i, byte)
   begin
      case current_state is
         when IDLE =>
            if en_i = '1' then
               next_state <= INITIALIZE;
            else
               next_state <= IDLE;
            end if;
            
         when INITIALIZE =>
            if rty_i = '1' then  -- indicates card_id is assembling its data and isn't ready
                                 -- (ie. it's busy, try again later)
               next_state <= IDLE;
            elsif ack_i = '1' then
               next_state <= READ_LSB_PACKET;
            else
               next_state <= INITIALIZE;
            end if;
            
--         when READ_MSB_PACKET =>
--            next_state <= READ_LSB_PACKET;
            
         when READ_LSB_PACKET =>
            next_state <= TX_CARD_ID;
            
         when TX_CARD_ID =>
            if byte = 0 then
               next_state <= DONE;
            else
               next_state <= TX_CARD_ID;
            end if;
            
         when DONE =>
            next_state <= IDLE;
            
         when others =>
            next_state <= IDLE;
            
      end case;
   end process;
   


------------------------------------------------------------------------
--
-- assign outputs of each state
--
------------------------------------------------------------------------  
  
   process (current_state, ack_i, tx_ack_i, tx_busy_i, dat_i)
   begin
   
        tx_we_o   <= '0';
        tx_stb_o  <= '0';  
        --tx_data_o <= (others => '0');
   
   
      case current_state is
      when IDLE =>
     
         -- wishbone signals to slave
         dat_o   <= (others => '0');
         addr_o  <= (others => '0');
         tga_o   <= (others => '0');
         we_o    <= '0';
         stb_o   <= '0';
         cyc_o   <= '0';

         -- output back to test module
	 done_o  <= '0';

         tx_data_o <= (others => '0');
         
         byte <= 8;
         
      when INITIALIZE =>
      
         -- wishbone signals to slave
         dat_o   <= (others => '0');
         addr_o  <= CARD_ID_ADDR;
         tga_o   <= (others => '0');
         we_o    <= '0';  -- '0' indicates a read
         stb_o   <= '1';
         cyc_o   <= '1';
         
         -- output back to test module
	 done_o  <= '0';
	 
	 if ack_i = '1' then
	 
	    -- grab the most significant portion of the card id data
            card_id_data(63 downto 32) <= dat_i; 
         end if;
      
         
--      when READ_MSB_PACKET =>
--      
--         -- wishbone signals to slave
--         dat_o   <= (others => '0');
--         addr_o  <= CARD_ID_ADDR;
--         tga_o   <= (others => '0');
--         we_o    <= '0';  -- '0' indicates a read
--         stb_o   <= '1';
--         cyc_o   <= '1';
--         
--         -- output back to test module
--	 done_o  <= '0';
 
	 
         
         
      when READ_LSB_PACKET =>
      
         -- wishbone signals to slave
         dat_o   <= (others => '0');
         addr_o  <= CARD_ID_ADDR;
         tga_o   <= (others => '0');
         we_o    <= '0';  -- '0' indicates a read
         stb_o   <= '1';
         cyc_o   <= '1';
         
         -- output back to test module
	 done_o  <= '0';
         
         -- grab the card id data
         card_id_data(31 downto 0) <= dat_i;
         

      when TX_CARD_ID =>

         -- wishbone signals to slave
         dat_o   <= (others => '0');
         addr_o  <= CARD_ID_ADDR;
         tga_o   <= (others => '0');
         we_o    <= '0';  -- '0' indicates a read
         stb_o   <= '0';
         cyc_o   <= '0';
         
         -- output back to test module
	 done_o  <= '0';
         
         -- transmit the card id data 1 byte at a time

        tx_we_o <= '1';
        tx_stb_o <= '1';  
        
        
        if tx_ack_i = '1' and tx_busy_i = '0' then
           byte <= byte - 1;
           if byte = 0 then
              tx_data_o <= (others => '0');
           else
              tx_data_o <= card_id_data(byte*8-1 downto byte*8-8);
           end if;
        end if;
           
                   
      when DONE =>
      
         -- wishbone signals to slave
         dat_o   <= (others => '0');
         addr_o  <= (others => '0');
         tga_o   <= (others => '0');
         we_o    <= '0';
         stb_o   <= '0';
         cyc_o   <= '0';
         
         -- output back to test module
	 done_o  <= '1';
	 
	 byte <= 8;
	 
      when others =>

         -- wishbone signals to slave
         dat_o   <= (others => '0');
         addr_o  <= (others => '0');
         tga_o   <= (others => '0');
         we_o    <= '0';
         stb_o   <= '0';
         cyc_o   <= '0';
         
         -- output back to test module
	 done_o  <= '0';    
	 
	 card_id_data <= (others => '0'); 

      end case;     
   end process;




------------------------------------------------------------------------
--
-- state sequencer
--
------------------------------------------------------------------------  

   process(clk_i, rst_i, en_i)
   begin
      if rst_i = '1' or en_i = '0' then
         current_state <= IDLE;
      elsif clk_i'event and clk_i = '1' then
         --if en_i = '1' then
            current_state <= next_state;
         --end if;
      end if;
   end process;

end;
