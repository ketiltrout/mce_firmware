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
-- <revision control keyword substitutions e.g. $Id: slot_id_test_wrapper.vhd,v 1.1 2004/04/13 23:02:23 erniel Exp $>
--
-- Project:	      SCUBA-2
-- Author:	       Jonathan Jacob
-- 
-- Organisation:  UBC
--
-- Description:
-- slot_id test wrapper file.  This file instanstiates the slot_id
-- and emulates the master (command FSM, for example) on the wishbone bus.
--
-- Revision history:
-- <date $Date: 2004/04/13 23:02:23 $>	-		<text>		- <initials $Author: erniel $>
-- $Log: slot_id_test_wrapper.vhd,v $
-- Revision 1.1  2004/04/13 23:02:23  erniel
-- no message
--
-- Revision 1.2  2004/03/24 22:42:45  erniel
-- added hex decoder to allow ASCII transmit
-- added extra state and modified state transitions
-- modified tx_ signal timing
--
--
-----------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
--use work.io_pack.all;
use work.slot_id_pack.all;

library sys_param;
use sys_param.wishbone_pack.all;
-----------------------------------------------------------------------------
                     
entity slot_id_test_wrapper is
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
      slot_id_i : in std_logic_vector (SLOT_ID_BITS-1 downto 0) -- physical slot_id pin
   );
end;

---------------------------------------------------------------------

architecture rtl of slot_id_test_wrapper is

   -- state definitions
   type state is (IDLE, READ, TX_SLOT_ID, TX_WAIT, DONE);
   signal current_state, next_state : state;

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
   
   -- hex to ascii modifications:
   
   component hex2ascii
   port(hex_i : in std_logic_vector(3 downto 0);
        ascii_o : out std_logic_vector(7 downto 0));
   end component;
   
   signal slot_id_hex   : std_logic_vector(3 downto 0);
   signal slot_id_ascii : std_logic_vector(7 downto 0);
   
begin


   dat_o 	<= (others => '0');-- not used since not writing to array ID
------------------------------------------------------------------------
--
-- instantiate the slot_id
--
------------------------------------------------------------------------

   slot_id_test : slot_id

   --generic map(
   --   SLOT_ID_ADDR       => SLOT_ID_ADDR,
   --   SLOT_ID_ADDR_WIDTH => WB_ADDR_WIDTH,
   --   SLOT_ID_DATA_WIDTH => WB_DATA_WIDTH,
   --   TAG_ADDR_WIDTH     => WB_TAG_ADDR_WIDTH)
  
   port map(  
               slot_id_i         => slot_id_i, 
               -- wishbone signals
      
               clk_i             => clk_i,
               rst_i             => rst_i,
               dat_i             => dat_o, -- not used since not writing to array ID
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
-- instantiate the hex-to-ascii decoder
--
------------------------------------------------------------------------

   decoder: hex2ascii
   port map(hex_i => slot_id_hex,
            ascii_o => slot_id_ascii);
            
------------------------------------------------------------------------
--
-- Emulate the master querying for the slot_id
--
------------------------------------------------------------------------   

------------------------------------------------------------------------
--
-- assign next states
--
------------------------------------------------------------------------  

   process (current_state, en_i, ack_i, tx_ack_i, tx_busy_i)
   begin
      case current_state is
         when IDLE =>
            if en_i = '1' then
               next_state <= READ;
            else
               next_state <= IDLE;
            end if;
            
         when READ =>
            if ack_i = '1' then
               next_state <= TX_SLOT_ID;
            else
               next_state <= READ;
            end if;
            
         when TX_SLOT_ID =>
            if(tx_ack_i = '1') then
               next_state <= TX_WAIT;
            else
               next_state <= TX_SLOT_ID;
            end if;
         
         when TX_WAIT =>
            if tx_ack_i = '0' and tx_busy_i = '0' then
               next_state <= DONE;
            else
               next_state <= TX_WAIT;
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
  
   process (current_state, dat_i)
   begin

         tx_data_o <= (others => '0');
         tx_we_o <= '0';
         tx_stb_o <= '0';
   
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
         
      when READ =>

         -- wishbone signals to slave
         dat_o   <= (others => '0');
         addr_o  <= SLOT_ID_ADDR;
         tga_o   <= (others => '0');
         we_o    <= '0'; -- indicates a READ
         stb_o   <= '1';
         cyc_o   <= '1';

         -- output back to test module
	 done_o  <= '0';
	 
	 slot_id_hex <= dat_i(3 downto 0);

         tx_data_o <= (others => '0');
         
      when TX_SLOT_ID =>

         -- wishbone signals to slave
         dat_o   <= (others => '0');
         addr_o  <= (others => '0');
         tga_o   <= (others => '0');
         we_o    <= '0';
         stb_o   <= '0';
         cyc_o   <= '0';

         -- output back to test module
	 done_o  <= '0';

         tx_data_o <= slot_id_ascii;
                        
         tx_we_o <= '1'; -- writing to the RS232
         tx_stb_o <= '1';
 
      when TX_WAIT =>
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
                        
         tx_we_o <= '0'; -- writing to the RS232
         tx_stb_o <= '0';
         
       
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
