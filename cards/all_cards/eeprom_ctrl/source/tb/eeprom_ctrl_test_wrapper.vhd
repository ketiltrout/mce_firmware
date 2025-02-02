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
-- <revision control keyword substitutions e.g. $Id: eeprom_ctrl_test_wrapper.vhd,v 1.1 2004/05/06 18:17:47 jjacob Exp $>
--
-- Project:	      SCUBA-2
-- Author:	       Jonathan Jacob
-- 
-- Organisation:  UBC
--
-- Description:
-- eeprom controller test wrapper file.  This file instanstiates the eeprom_ctrl
-- and emulates the master (command FSM, for example) on the wishbone bus.
--
-- Revision history:
-- <date $Date: 2004/05/06 18:17:47 $>	-		<text>		- <initials $Author: jjacob $>
-- $Log: eeprom_ctrl_test_wrapper.vhd,v $
-- Revision 1.1  2004/05/06 18:17:47  jjacob
-- first version
--
-- 
--
-----------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
--use work.io_pack.all;
use work.eeprom_ctrl_pack.all;

library sys_param;
use sys_param.wishbone_pack.all;

library components;
use components.component_pack.all;

-----------------------------------------------------------------------------
                     
entity eeprom_ctrl_test_wrapper is
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
      
     -- physical pins to/from the EEPROM
     n_eeprom_cs_o   : out std_logic; -- low enable eeprom chip select
     n_eeprom_hold_o : out std_logic; -- low enable eeprom hold
     n_eeprom_wp_o   : out std_logic; -- low enable write protect
     eeprom_si_o     : out std_logic; -- serial input data to the eeprom
     eeprom_clk_o    : out std_logic; -- clock signal to EEPROM     
     
     -- inputs from the EEPROM
     eeprom_so_i     : in std_logic  -- serial output data from the eeprom
     
      
      
   );
end;

---------------------------------------------------------------------

architecture rtl of eeprom_ctrl_test_wrapper is

   -- state definitions
   type states is (IDLE, WRITE, READ, TX_EEPROM_DATA_TO_RS232, DONE, RX_EEPROM_DATA, TX_WAIT, PAUSE);
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
      
   signal eeprom_rd_data    : std_logic_vector (WB_DATA_WIDTH-1 downto 0);
   
   constant EEPROM_WR_DATA  : std_logic_vector (WB_DATA_WIDTH-1 downto 0)     := x"CAFEBABE";
   constant EEPROM_TAG_ADDR : std_logic_vector (WB_TAG_ADDR_WIDTH-1 downto 0) := x"000000FF";
   
   signal count : integer;
   
   -- ascii decoder modification:
   
   signal hex_data   : std_logic_vector(3 downto 0);
   signal ascii_data : std_logic_vector(7 downto 0);
   
   component hex2ascii
   port(hex_i   : in std_logic_vector(3 downto 0);
        ascii_o : out std_logic_vector(7 downto 0));
   end component;
   
   -- byte counter modification:
   signal count_ena  : std_logic;
   signal count_ld   : std_logic;
   signal count_down : std_logic;
   signal load_val   : integer;
   signal byte       : integer;
   
   -- pause counter
   signal count_en   : std_logic;
   signal count_load : std_logic;
   signal count_up   : std_logic;
   signal init_count : integer;
   
      
begin

------------------------------------------------------------------------
--
-- instantiate the eeprom_ctrl
--
------------------------------------------------------------------------

      eeprom_ctrl_test : eeprom_ctrl

generic map (EEPROM_CTRL_ADDR               => EEPROM_ADDR  )

port map(

     -- EEPROM interface:
     
     -- outputs to the EEPROM
     n_eeprom_cs_o   => n_eeprom_cs_o,
     n_eeprom_hold_o => n_eeprom_hold_o,
     n_eeprom_wp_o   => n_eeprom_wp_o,
     eeprom_si_o     => eeprom_si_o,
     eeprom_clk_o    => eeprom_clk_o,
     
     -- inputs from the EEPROM
     eeprom_so_i     => eeprom_so_i,
     
     -- Wishbone interface:
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



------------------------------------------------------------------------
--
-- instantiate the hex-to-ascii decoder
--
------------------------------------------------------------------------

   hexdecode : hex2ascii
   port map(hex_i => hex_data,
            ascii_o => ascii_data);
               
   with byte select
      hex_data <= eeprom_rd_data(3 downto 0) when 1,
	          eeprom_rd_data(7 downto 4) when 2,
                  eeprom_rd_data(11 downto 8) when 3,
                  eeprom_rd_data(15 downto 12) when 4, 
                  eeprom_rd_data(19 downto 16) when 5, 
                  eeprom_rd_data(23 downto 20) when 6, 
                  eeprom_rd_data(27 downto 24) when 7,
                  eeprom_rd_data(31 downto 28) when 8,
--                  card_id_data(35 downto 32) when 9,
--                  card_id_data(39 downto 36) when 10,
--                  card_id_data(43 downto 40) when 11,
--                  card_id_data(47 downto 44) when 12,
--                  card_id_data(51 downto 48) when 13,
--                  card_id_data(55 downto 52) when 14,
--                  card_id_data(59 downto 56) when 15,
--                  card_id_data(63 downto 60) when 16,
                  "0000" when others;

             
------------------------------------------------------------------------
--
-- instantiate the byte counter
--
------------------------------------------------------------------------  

   bytecount: counter
   generic map(MAX => 8)
   port map(clk_i   => clk_i,
            rst_i   => rst_i,
            ena_i   => count_ena,
            load_i  => count_ld,
            down_i  => count_down,
            count_i => load_val,
            count_o => byte);
            
            

------------------------------------------------------------------------
--
-- instantiate a counter
--
------------------------------------------------------------------------  
pause_counter : counter
generic map(MAX => 100)
port map(clk_i   => clk_i,
     rst_i   => rst_i,
     ena_i   => count_en,
     load_i  => count_load,
     down_i  => count_up,
     count_i => init_count,
     count_o => count);




------------------------------------------------------------------------
--
-- emulate the master here.  assign next states
--
------------------------------------------------------------------------  

   process (current_state, en_i, rty_i, ack_i, byte, tx_ack_i, tx_busy_i, count)
   begin
      case current_state is
         when IDLE =>
            if en_i = '1' then
               next_state <= WRITE;
            else
               next_state <= IDLE;
            end if;
            
         when WRITE =>
            if rty_i = '1' then  -- indicates eeprom is still in setup mode and isn't ready
                                 -- (ie. it's busy, try again later)
               next_state <= IDLE;
            elsif ack_i = '1' then
               next_state <= PAUSE;
            else
               next_state <= WRITE;
            end if;
            
         when PAUSE =>
            if count >= 100 then
               next_state <= READ;
            else
               next_state <= PAUSE;
            end if;
            
         when READ =>
            if ack_i = '1' then
               next_state <= TX_EEPROM_DATA_TO_RS232;
               --next_state <= RX_EEPROM_DATA;
            else
               next_state <= READ;
            end if;
            
         when RX_EEPROM_DATA =>
            next_state <= TX_EEPROM_DATA_TO_RS232;
            
         when TX_EEPROM_DATA_TO_RS232 =>
            if(tx_ack_i = '1') then
               next_state <= TX_WAIT;
            else
               next_state <= TX_EEPROM_DATA_TO_RS232;
            end if;
            
         when TX_WAIT =>
            if(tx_ack_i = '0' and tx_busy_i = '0') then
               if(byte = 0) then
                  next_state <= DONE;
               else
                  next_state <= TX_EEPROM_DATA_TO_RS232;
               end if;
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
  
   process (current_state, dat_i, ascii_data, ack_i)
   begin
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
         tx_we_o   <= '0';
         tx_stb_o  <= '0';
         
         -- byte counter signals
         count_ena  <= '0';
         count_ld   <= '1';
         count_down <= '1';
         load_val   <= 8;
         
         count_en   <= '0';
         count_load <= '1';
         count_up   <= '0';
         init_count <= 0;
         
      when WRITE =>
      
         -- wishbone signals to slave
         dat_o   <= EEPROM_WR_DATA;
         addr_o  <= EEPROM_ADDR;
         tga_o   <= EEPROM_TAG_ADDR;
         we_o    <= '1';  -- '1' indicates a write
         stb_o   <= '1';
         cyc_o   <= '1';
         
         -- output back to test module
	 done_o  <= '0';

         tx_data_o <= (others => '0');	 
         tx_we_o   <= '0';
         tx_stb_o  <= '0';	 
	 
	 -- byte counter signals:
         count_ena  <= '0';
         count_ld   <= '0';
         count_down <= '1';
         load_val   <= 0;
         
         count_en   <= '0';
         count_load <= '1';
         count_up   <= '0';
         init_count <= 0;
         
--         if ack_i = '1' then
--	    -- grab the most significant portion of the card id data
--            card_id_data(63 downto 32) <= dat_i; 
--         end if; 
        
      when PAUSE =>
      
         -- wishbone signals to slave
         dat_o   <= (others => '0');
         addr_o  <= (others => '0');
         tga_o   <= (others => '0');
         we_o    <= '0';  -- '0' indicates a read
         stb_o   <= '0';
         cyc_o   <= '0';
         
         -- output back to test module
	 done_o  <= '0';

         tx_data_o <= (others => '0');         
         tx_we_o   <= '0';
         tx_stb_o  <= '0';
         
         -- byte counter signals:
         count_ena  <= '0';
         count_ld   <= '0';
         count_down <= '1';
         load_val   <= 0; 
         
         count_en   <= '1';
         count_load <= '0';
         count_up   <= '0';
         init_count <= 0;
                
      when READ =>
      
         -- wishbone signals to slave
         dat_o   <= (others => '0');
         addr_o  <= EEPROM_ADDR;
         tga_o   <= EEPROM_TAG_ADDR;
         we_o    <= '0';  -- '0' indicates a read
         stb_o   <= '1';
         cyc_o   <= '1';
         
         -- output back to test module
	 done_o  <= '0';

         tx_data_o <= (others => '0');         
         tx_we_o   <= '0';
         tx_stb_o  <= '0';
         
         -- byte counter signals:
         count_ena  <= '0';
         count_ld   <= '0';
         count_down <= '1';
         load_val   <= 0; 
         
         count_en   <= '0';
         count_load <= '1';
         count_up   <= '0';
         init_count <= 0;
         
         -- grab the eeprom data
         if ack_i = '1' then
            eeprom_rd_data <= dat_i;  
         end if;
 
--         -- grab the card id data
--         card_id_data(31 downto 0) <= dat_i;
--         
              
      when RX_EEPROM_DATA =>


         -- wishbone signals to slave
         dat_o   <= (others => '0');
         addr_o  <= EEPROM_ADDR;
         tga_o   <= EEPROM_TAG_ADDR;
         we_o    <= '0';  -- '0' indicates a read
         stb_o   <= '1';
         cyc_o   <= '1';
         
         -- output back to test module
	 done_o  <= '0';

         tx_data_o <= (others => '0');         
         tx_we_o   <= '0';
         tx_stb_o  <= '0';
         
         -- byte counter signals
         count_ena  <= '0';
         count_ld   <= '0';
         count_down <= '1';
         load_val   <= 0; 
         
         count_en   <= '0';
         count_load <= '1';
         count_up   <= '0';
         init_count <= 0;
         
         -- grab the eeprom data
         eeprom_rd_data <= dat_i;         


      when TX_EEPROM_DATA_TO_RS232 =>

         -- wishbone signals to slave
         dat_o   <= (others => '0');
         addr_o  <= (others => '0');
         tga_o   <= (others => '0');
         we_o    <= '0'; 
         stb_o   <= '0';
         cyc_o   <= '0';
         
         -- output back to test module
	 done_o  <= '0';
  
         tx_data_o <= ascii_data;
         tx_we_o   <= '1';
         tx_stb_o  <= '1';
         
         -- byte counter signals:
         count_ena  <= '1';
         count_ld   <= '0';
         count_down <= '1';
         load_val   <= 0;
         
         count_en   <= '0';
         count_load <= '1';
         count_up   <= '0';
         init_count <= 0;
         

      when TX_WAIT =>

         -- wishbone signals to slave
         dat_o   <= (others => '0');
         addr_o  <= (others => '0');
         tga_o   <= (others => '0');
         we_o    <= '0';  -- '0' indicates a read
         stb_o   <= '0';
         cyc_o   <= '0';
         
         -- output back to test module
	 done_o  <= '0';
 
         tx_data_o <= (others => '0');
         tx_we_o   <= '0';
         tx_stb_o  <= '0';
         
         -- byte counter signals:
         count_ena  <= '0';
         count_ld   <= '0';
         count_down <= '1';
         load_val   <= 0;
         
         count_en   <= '0';
         count_load <= '1';
         count_up   <= '0';
         init_count <= 0;
 
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
	 
	 tx_data_o <= (others => '0');
         tx_we_o   <= '0';
         tx_stb_o  <= '0';
         
	 -- byte counter signals:
         count_ena  <= '0';
         count_ld   <= '0';
         count_down <= '1';
         load_val   <= 0;
         
         count_en   <= '0';
         count_load <= '1';
         count_up   <= '0';
         init_count <= 0;
         
	 
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
	 
	 tx_data_o <= (others => '0');
         tx_we_o   <= '0';
         tx_stb_o  <= '0';
         
	 -- byte counter signals:
         count_ena  <= '0';
         count_ld   <= '0';
         count_down <= '1';
         load_val   <= 0;
         
         count_en   <= '0';
         count_load <= '1';
         count_up   <= '0';
         init_count <= 0;
         

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
            current_state <= next_state;
      end if;
   end process;
   
end;