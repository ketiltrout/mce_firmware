-- Copyright (c) 2003 SCUBA-2 Project
--                  All Rights Reserved

--  THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE SCUBA-2 Project
--  The copyright notice above does not evidence any
--  actual or intended publication of such source code.

--  SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
--  REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
--  MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
--  PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
--  THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.

-- For the purposes of this code the SCUBA-2 Project consists of the
-- following organisations.

-- UKATC, Royal Observatory, Blackford Hill Edinburgh EH9 3HJ
-- UBC,   University of British Columbia, Physics & Astronomy Department,
--        Vancouver BC, V6T 1Z1

-- 
--
-- <revision control keyword substitutions e.g. $Id: card_id.vhd,v 1.1 2004/03/05 22:38:35 jjacob Exp $>
--
-- Project:	      SCUBA-2
-- Author:	       Jonathan Jacob
--                Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- 
--
-- Revision history:
-- Feb. 3 2004   - Initial version      - JJ
-- Feb. 5 2004   - Top-level controller - EL
-- <date $Date: 2004/03/05 22:38:35 $>	-		<text>		- <initials $Author: jjacob $>

--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library components;
use components.component_pack.all;

library work;
use work.card_id_pack.all;

library sys_param;
use sys_param.wishbone_pack.all;


entity card_id is

generic(--WB_DATA_WIDTH         : integer := WB_DATA_WIDTH;
        --WB_ADDR_WIDTH         : integer := WB_ADDR_WIDTH;
        CARD_ID_ADDR         : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := CARD_ID_ADDR  );

port(-- ID chip interface:
     data_bi : inout std_logic;

     -- Wishbone interface:
     clk_i   : in std_logic;
     rst_i   : in std_logic;		
     addr_i  : in std_logic_vector (WB_ADDR_WIDTH-1 downto 0);
     tga_i   : in std_logic_vector (WB_TAG_ADDR_WIDTH-1 downto 0);
     dat_i 	 : in std_logic_vector (WB_DATA_WIDTH-1 downto 0);
     dat_o   : out std_logic_vector (WB_DATA_WIDTH-1 downto 0);
     we_i    : in std_logic;
     stb_i   : in std_logic;
     ack_o   : out std_logic;
     rty_o   : out std_logic;
     cyc_i   : in std_logic ); 
end card_id;


architecture rtl of card_id is

-- controller states:
constant IDLE         : std_logic_vector(2 downto 0) := "000";
constant INITIALIZE   : std_logic_vector(2 downto 0) := "001";
constant WRITE_CMD    : std_logic_vector(2 downto 0) := "010";
constant READ_SERIAL  : std_logic_vector(2 downto 0) := "011";
constant CRC_CHECK    : std_logic_vector(2 downto 0) := "100";
constant SEND_PACKET1 : std_logic_vector(2 downto 0) := "101";
constant SEND_PACKET2 : std_logic_vector(2 downto 0) := "110";
constant DONE         : std_logic_vector(2 downto 0) := "111";

-- controller state variables:
signal present_state : std_logic_vector(2 downto 0);
signal next_state    : std_logic_vector(2 downto 0);

-- 1-wire protocol FSM start/done signals:
signal init_start        : std_logic;
signal write_cmd_start   : std_logic;
signal read_serial_start : std_logic;
signal crc_check_start   : std_logic;
signal init_done         : std_logic;
signal write_cmd_done    : std_logic;
signal read_serial_done  : std_logic;
signal crc_check_done    : std_logic;

-- WB slave interface:
signal card_id_wr_ready : std_logic;
signal card_id_rd_ready : std_logic;
signal card_id_dat_i    : std_logic_vector (WB_DATA_WIDTH-1 downto 0);  -- input from WB (dummy signal)
signal card_id_dat_o    : std_logic_vector (WB_DATA_WIDTH-1 downto 0);  -- output to WB
signal slave_retry      : std_logic;
signal slave_selected   : std_logic;

-- return data:
signal serial_num : std_logic_vector(63 downto 0);
signal serial_num_hold : std_logic_vector(63 downto 0);
signal serial_num_ready : std_logic;
signal crc_valid  : std_logic;

-- signals tied to ground
signal zero_bit : std_logic;
signal zero_32bit_vector : std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);

begin

------------------------------------------------------------------------
--
-- Card_ID top-level controller
--
------------------------------------------------------------------------
 
   zero_32bit_vector <= (others => '0');
   zero_bit <= '0';
 
   
   state_FF : process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         present_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         present_state <= next_state;        
      end if;
   end process state_FF;
   
   --controller_NS: process(clk_i, rst_i, addr_i, we_i, cyc_i, stb_i, init_done, write_cmd_done, read_serial_done, crc_check_done)
   
   -- changed by JJ for synthesizability, removed clk and rst from sensitivity list
   controller_NS: process(present_state, slave_selected, init_done, write_cmd_done,
                          read_serial_done, crc_check_done, serial_num_ready, cyc_i) 
   begin
      case present_state is
         when IDLE =>
            if slave_selected = '1' then
               if serial_num_ready = '1' then
                  next_state <= SEND_PACKET1;
               else
                  next_state <= INITIALIZE;
               end if;
            end if;
                        
         when INITIALIZE =>
            if(init_done = '1') then
               next_state <= WRITE_CMD;
            end if;
            
         when WRITE_CMD =>
            if(write_cmd_done = '1') then
               next_state <= READ_SERIAL;
            end if;
         
         when READ_SERIAL =>
            if(read_serial_done = '1') then
               next_state <= CRC_CHECK;
            end if;
            
         when CRC_CHECK =>
            if(crc_check_done = '1') then
               --next_state <= SEND_PACKET1;
               next_state <= IDLE;
            end if;
         
         when SEND_PACKET1 =>
            next_state <= SEND_PACKET2;
         
         when SEND_PACKET2 =>
            next_state <= DONE;
            
         when DONE =>
            if(cyc_i = '0') then
               next_state <= IDLE;
            end if;
         
         when others =>
            next_state <= IDLE;
            
      end case;            
   end process controller_NS;
   
   controller_out : process(present_state, crc_valid)
   begin
      -- 1-wire protocol fsm signals:
      case present_state is
         when IDLE | SEND_PACKET1 | SEND_PACKET2 | DONE => 
            init_start        <= '0';
            write_cmd_start   <= '0';
            read_serial_start <= '0';
            crc_check_start   <= '0';
         
         when INITIALIZE =>
            init_start        <= '1';
            write_cmd_start   <= '0';
            read_serial_start <= '0';
            crc_check_start   <= '0';
 
         when WRITE_CMD =>
            init_start        <= '0';
            write_cmd_start   <= '1';
            read_serial_start <= '0';
            crc_check_start   <= '0';
         
         when READ_SERIAL => 
            init_start        <= '0';
            write_cmd_start   <= '0';
            read_serial_start <= '1';
            crc_check_start   <= '0';
         
         when CRC_CHECK =>
            init_start        <= '0';
            write_cmd_start   <= '0';
            read_serial_start <= '0';
            crc_check_start   <= '1';
         
         when others =>
            init_start        <= '0';
            write_cmd_start   <= '0';
            read_serial_start <= '0';
            crc_check_start   <= '0';
            
  
               
      end case;

      -- card_id return signals:      
      case present_state is
         when IDLE | INITIALIZE | WRITE_CMD | READ_SERIAL | CRC_CHECK | DONE =>
            card_id_rd_ready  <= '0';
            card_id_dat_o     <= (others => '0');
            
         when SEND_PACKET1 =>
            card_id_rd_ready  <= '1';          
            if(crc_valid = '1') then
               card_id_dat_o  <= serial_num_hold(63 downto 32); --send MSB packet first
               --card_id_dat_o  <= serial_num(31 downto 0);
            else
               card_id_dat_o  <= (others => '1');
            end if;
            
         when SEND_PACKET2 =>
            card_id_rd_ready  <= '1';            
            if(crc_valid = '1') then
               card_id_dat_o  <= serial_num_hold(31 downto 0); -- second LSB packet second
               --card_id_dat_o  <= serial_num(63 downto 32);
            else
               card_id_dat_o  <= (others => '1');
            end if;
         
         when others =>
            card_id_rd_ready  <= '0';
            card_id_dat_o     <= (others => '0');
            
            
      end case;
   end process controller_out;
   
------------------------------------------------------------------------
--
-- This process runs only on a reset, or only once after the serial
-- number has been read.  It indicates the serial number has been
-- read and is stored locally, therefore, it doesn't need to be read
-- again until after a reset.
--
------------------------------------------------------------------------
 
      process(rst_i, clk_i)--crc_check_done)
      begin
         if rst_i = '1' then
            serial_num_ready <= '0';
            serial_num_hold <= (others => '0');
         elsif clk_i'event and clk_i = '1' then
         --elsif crc_check_done'event and crc_check_done = '1' then
            if crc_check_done = '1' then
               serial_num_ready <= '1';
               serial_num_hold <= serial_num;  -- serial_num_hold may be redundant, serial_num holds it's value
            end if;
         end if;
      end process;

                       
------------------------------------------------------------------------
--
-- Instantiate communication protocol FSMs
--
------------------------------------------------------------------------

   init: init_1_wire
   port map(clk => clk_i,
            rst => rst_i,
            init_start_i => init_start,
            init_done_o => init_done,
            data_bi => data_bi);
            

   write : write_data_1_wire
   generic map(DATA_LENGTH => 8)
   port map(clk => clk_i,
            rst => rst_i,
            write_start_i => write_cmd_start,
            write_done_o => write_cmd_done,
            write_data_i => READ_ROM_CMD,  -- 0x33
            data_bi => data_bi);
      
   read : read_data_1_wire
   generic map(DATA_LENGTH => 64)
   port map(clk => clk_i,
            rst => rst_i,
            read_start_i => read_serial_start,
            read_done_o => read_serial_done,
            read_data_o => serial_num,
            data_bi => data_bi);
   
   verify : crc
   generic map(DATA_LENGTH => 64)
   port map(clk => clk_i,
            rst => rst_i,  
            crc_start_i => crc_check_start,
            crc_done_o => crc_check_done,
            crc_data_i => serial_num,
            valid_o => crc_valid);       
            

------------------------------------------------------------------------
--
-- Register to capture the serial number
--
------------------------------------------------------------------------       

--   process(clk_i, rst_i, read_serial_done, serial_num)
--   begin
--      if rst_i = '1' then
--         serial_num_hold <= (others => '0');
--      elsif clk_i'event and clk_i = '1' then
--         if read_serial_done = '1' then
--            serial_num_hold <= serial_num;
--         else
--            serial_num_hold <= serial_num_hold;
--         end if;
--      end if;


------------------------------------------------------------------------
--
-- Slave controller for the serial number
--
------------------------------------------------------------------------            


   slave_selected <= '1' when addr_i = CARD_ID_ADDR and we_i = '0' and cyc_i = '1' and stb_i = '1'
                     else '0';
                     
   --slave_retry <= '1' when slave_selected = '1' and serial_num_ready = '0' else '0';
   slave_retry <= '1' when serial_num_ready = '0' else '0';
   --slave_retry <= '1';
   card_id_wr_ready <= '0';


   wb_slave : slave_ctrl
   generic map(SLAVE_SEL      => CARD_ID_ADDR,
               ADDR_WIDTH     => WB_ADDR_WIDTH,
               DATA_WIDTH     => WB_DATA_WIDTH,
               TAG_ADDR_WIDTH => WB_TAG_ADDR_WIDTH)
      
   port map(slave_wr_ready       => card_id_wr_ready,
            slave_rd_data_valid  => card_id_rd_ready,
            slave_retry          => slave_retry,
            master_wr_data_valid => zero_bit,
            slave_ctrl_dat_i     => card_id_dat_o,
            slave_ctrl_dat_o     => card_id_dat_i,
            slave_ctrl_tga_o     => zero_32bit_vector,
            
            clk_i  => clk_i,
            rst_i  => rst_i, 
            addr_i => addr_i,
            tga_i  => zero_32bit_vector, --add a signal
            dat_i 	=> dat_i,
            dat_o  => dat_o,
            we_i   => we_i,
            stb_i  => stb_i,
            rty_o  => rty_o, --add a signal
            ack_o  => ack_o,
            cyc_i  => cyc_i);
            
end rtl;
