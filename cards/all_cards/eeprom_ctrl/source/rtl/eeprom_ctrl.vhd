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
-- <revision control keyword substitutions e.g. $Id$>
--
-- Project:	      SCUBA-2
-- Author:	       Jonathan Jacob
--
-- Organisation:  UBC
--
-- Description:  This module is the controller for the EEPROM
-- 
--
-- Revision history:
-- 
-- <date $Date$>	-		<text>		- <initials $Author$>

--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library components;
use components.component_pack.all;

library work;
use work.eeprom_ctrl_pack.all;
--use work.slave_ctrl_pack.all;

library sys_param;
use sys_param.wishbone_pack.all;


entity eeprom_ctrl is

generic(EEPROM_CTRL_DATA_WIDTH         : integer := EEPROM_CTRL_DATA_WIDTH;
        EEPROM_CTRL_ADDR_WIDTH         : integer := EEPROM_CTRL_ADDR_WIDTH;   
        EEPROM_CTRL_ADDR               : std_logic_vector(ADDR_LENGTH-1 downto 0) := EEPROM_CTRL_ADDR  );

port(

     -- EEPROM interface:
     
     -- outputs to the EEPROM
     n_eeprom_cs_o   : out std_logic; -- low enable eeprom chip select
     n_eeprom_hold_o : out std_logic; -- low enable eeprom hold
     n_eeprom_wp_o   : out std_logic; -- low enable write protect
     eeprom_si_o     : out std_logic; -- serial input data to the eeprom
     eeprom_clk_o    : out std_logic; -- clock signal to EEPROM     
     
     -- inputs from the EEPROM
     eeprom_so_i     : in std_logic;  -- serial output data from the eeprom
     
     -- 5 MHz clock for the EEPROM controller state machine and for the EEPROM
     --clk_5MHz_i      : in std_logic;

     -- Wishbone interface:
     clk_i   : in std_logic;
     rst_i   : in std_logic;		
     addr_i  : in std_logic_vector (EEPROM_CTRL_ADDR_WIDTH-1 downto 0);
     dat_i 	 : in std_logic_vector (EEPROM_CTRL_DATA_WIDTH-1 downto 0);
     dat_o   : out std_logic_vector (EEPROM_CTRL_DATA_WIDTH-1 downto 0);
     we_i    : in std_logic;
     stb_i   : in std_logic;
     ack_o   : out std_logic; 
     cyc_i   : in std_logic ); 
end eeprom_ctrl;


architecture rtl of eeprom_ctrl is

-- controller states:
constant IDLE         : std_logic_vector(2 downto 0) := "000";
constant TX_READ_COMMAND   : std_logic_vector(2 downto 0) := "001";
constant TX_WRITE_COMMAND    : std_logic_vector(2 downto 0) := "010";
constant RX_EEPROM_DATA  : std_logic_vector(2 downto 0) := "011";
--constant CRC_CHECK    : std_logic_vector(2 downto 0) := "100";
--constant SEND_PACKET1 : std_logic_vector(2 downto 0) := "101";
--constant SEND_PACKET2 : std_logic_vector(2 downto 0) := "110";
--constant DONE         : std_logic_vector(2 downto 0) := "111";

signal READ_EEPROM_CMD : std_logic_vector(7 downto 0) := "00000011"; -- 0x03

-- controller state variables:
signal current_state : std_logic_vector(2 downto 0) := "000";
signal next_state    : std_logic_vector(2 downto 0) := "000";

-- 1-wire protocol FSM start/done signals:
signal tx_read_cmd_start        : std_logic;
signal tx_read_cmd_done     : std_logic;
signal rx_eeprom_data_start : std_logic;
signal rx_eeprom_data_done : std_logic;
signal tx_read_cmd   : std_logic;
--signal eeprom_rx_data         : std_logic_vector(EEPROM_CTRL_DATA_WIDTH-1 downto 0); -- use 32 bits for now, needs to somehow be variable size in the future


-- WB slave interface:
signal eeprom_ctrl_wr_ready : std_logic;
signal eeprom_ctrl_rd_ready : std_logic;
signal eeprom_ctrl_dat_i    : std_logic_vector (EEPROM_CTRL_DATA_WIDTH-1 downto 0);  -- input from WB (dummy signal)
signal eeprom_ctrl_dat_o    : std_logic_vector (EEPROM_CTRL_DATA_WIDTH-1 downto 0);  -- output to WB

-- return data:
signal serial_num : std_logic_vector(63 downto 0);
signal crc_valid  : std_logic;


signal no_connect : std_logic;

begin


------------------------------------------------------------------------
--
-- capture logic for Wishbone bus running on wishbone clock
--
------------------------------------------------------------------------









------------------------------------------------------------------------
--
-- state sequencer for EEPROM logic
--
------------------------------------------------------------------------
   
   process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         current_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         current_state <= next_state;
      end if;
   end process;
 
 
 
 
 
 
  
------------------------------------------------------------------------
--
-- State machine between eeprom controller and the eeprom
--
------------------------------------------------------------------------  


-- Need to assign slave_rd_data_valid, slave_wr_ready etc signals
  
   process(addr_i, cyc_i, we_i, current_state)
   begin
   
   tx_read_cmd_start <= '0';
   rx_eeprom_data_start <= '0';
   
      case current_state is
         when IDLE =>
            if addr_i = EEPROM_CTRL_ADDR and cyc_i = '1' and stb_i = '1' then 
               if we_i = '0' then  -- master initiates a read cycle
                  next_state <= WAIT_50_NS_Tcss;
                  --tx_read_cmd_start <= '1';
               else -- master initiates a write cycle
                  next_state <= TX_WRITE_CMD_SETUP; -- needs further decomposition
               end if;
            else
               next_state <= IDLE;
            end if;

         when WAIT_50_NS_Tcss =>
            if timer_out = 50 then
               next_state <= INSTR_SETUP;
               --rx_eeprom_data_start <= '1';
            else
               next_state <= WAIT_50_NS_Tcss;
            end if;

         when INSTR_SETUP =>
            if timer_out = 50 then
               next_state <= INSTR_HOLD;
               --rx_eeprom_data_start <= '1';
            else
               next_state <= INSTR_SETUP;
            end if;
       
         when INSTR_HOLD =>
            if timer_out = 50 then
               if instr_bit_count = 8 then
                  next_state <= BYTE_ADDR_SETUP
               else
                  next_state <= INSTR_HOLD;
               --rx_eeprom_data_start <= '1';
            else
               next_state <= INSTR_SETUP;
            end if;
            
         when TX_READ_CMD =>
            if tx_read_cmd_done = '1'  then
               next_state <= TX_READ_CMD;
               --rx_eeprom_data_start <= '1';
            else
               next_state <= TX_READ_CMD;
            end if;
               
         when TX_READ_COMMAND =>
            if tx_read_cmd_done = '1'  then
               next_state <= RX_EEPROM_DATA;
               rx_eeprom_data_start <= '1';
            else
               next_state <= TX_READ_COMMAND;
            end if;
            
         when RX_EEPROM_DATA =>
            if rx_eeprom_data_done = '1' then
               next_state <= IDLE;
            else
               next_state <= RX_EEPROM_DATA;
            end if;
            
         when TX_WRITE_COMMAND =>  -- Needs to be implemented
            next_state <= IDLE;
            
         when others =>
            next_state <= IDLE;
            
            
      end case;
   end process;
 
       
------------------------------------------------------------------------
--
-- assign outputs
--
------------------------------------------------------------------------   
   
   process(current_state)
   begin
      case current_state is
         when IDLE =>
            n_eeprom_cs_o   <= '1';
            n_eeprom_hold_o <= '1';
            n_eeprom_wp_o   <= '0';
            eeprom_si_o     <= '0';
            eeprom_clk_o    <= '0';
 
         when TX_READ_COMMAND_SETUP =>
            n_eeprom_cs_o   <= '0';
            n_eeprom_hold_o <= '1';
            n_eeprom_wp_o   <= '0';
            eeprom_si_o     <= '0';
            eeprom_clk_o    <= '0';
    
         when TX_READ_COMMAND =>
            n_eeprom_cs_o   <= '0';
            n_eeprom_hold_o <= '1';
            n_eeprom_wp_o   <= '0';
            eeprom_si_o     <= tx_read_cmd;
            
            --tx_read_cmd_fsm_start_o <= '1';        
     
         when TX_WRITE_COMMAND => -- not implement yet
            n_eeprom_cs_o   <= '1';
            n_eeprom_hold_o <= '1';
            n_eeprom_wp_o   <= '0';
            eeprom_si_o     <= '0'; 
         
         when RX_EEPROM_DATA =>  -- for now, rx 32-bits.  need to add logic to rx variable amount of bytes
            n_eeprom_cs_o   <= '0';
            n_eeprom_hold_o <= '1';
            n_eeprom_wp_o   <= '0';
            eeprom_si_o     <= '0';
            
            --eeprom_rx_data  <=  eeprom_rx_data(EEPROM_CTRL_DATA_WIDTH-2 downto 1) & eeprom_so_i;  --shift in the data
         
         when others =>
            n_eeprom_cs_o   <= '1';
            n_eeprom_hold_o <= '1';
            n_eeprom_wp_o   <= '0';
            eeprom_si_o     <= '0';
               
      end case;

 end process;



------------------------------------------------------------------------
--
-- Instantiate communication protocol FSMs
--
------------------------------------------------------------------------

-- this fsm transmits the "read" command (b0000 X011)to the eeprom serially, indicating
-- that the master wishes to read the eeprom's data
   i_tx_read_cmd : write_serial_data
   generic map(DATA_LENGTH => 8)
   port map(clk => clk_i,
            rst => rst_i,
            write_start_i => tx_read_cmd_start,
            write_done_o => tx_read_cmd_done,
            write_data_i => READ_EEPROM_CMD,  -- b000 X011
            data_o => tx_read_cmd);

 
 -- this fsm reads the serial data from the eeprom
   i_read : read_serial_data
generic map(DATA_LENGTH => DEF_WB_DATA_WIDTH)

port map(clk       => clk_i,
     rst           => rst_i,
     read_start_i  => rx_eeprom_data_start,
     read_done_o   => rx_eeprom_data_done,
     read_data_i        => eeprom_so_i,
     read_data_o        => eeprom_ctrl_dat_o);
     

eeprom_ctrl_rd_ready <= '1' when rx_eeprom_data_done = '1' else '0'; -- this only works for reading so far, check about the 2 cycles high for data_done signal

--
--
--      -- eeprom_ctrl return signals:      
--      case current_state is
--         when IDLE | INITIALIZE | WRITE_CMD | READ_SERIAL | CRC_CHECK | DONE =>
--            eeprom_ctrl_rd_ready  <= '0';
--            eeprom_ctrl_dat_o     <= (others => '0');
--            
--         when SEND_PACKET1 =>
--            eeprom_ctrl_rd_ready  <= '1';
--            if(crc_valid = '1') then
--               eeprom_ctrl_dat_o  <= serial_num(31 downto 0);
--            else
--               eeprom_ctrl_dat_o  <= (others => '1');
--            end if;
--            
--         when SEND_PACKET2 =>
--            eeprom_ctrl_rd_ready  <= '1';
--            if(crc_valid = '1') then
--               eeprom_ctrl_dat_o  <= serial_num(63 downto 32);
--            else
--               eeprom_ctrl_dat_o  <= (others => '1');
--            end if;
--         
--         when others =>
--            eeprom_ctrl_rd_ready  <= '0';
--            eeprom_ctrl_dat_o     <= (others => '0');
--            
--      end case;
--   end process controller_out;
--   
                       
------------------------------------------------------------------------
--
-- Instantiate communication protocol FSMs
--
------------------------------------------------------------------------



------------------------------------------------------------------------
--
-- Slave controller for the serial number
--
------------------------------------------------------------------------            

   wb_slave : slave_ctrl
   generic map(SLAVE_SEL  => EEPROM_CTRL_ADDR,
               ADDR_WIDTH => EEPROM_CTRL_ADDR_WIDTH,
               DATA_WIDTH => EEPROM_CTRL_DATA_WIDTH )
      
   port map(slave_wr_ready      => eeprom_ctrl_wr_ready,
            slave_rd_data_valid => eeprom_ctrl_rd_ready,
            master_wr_data_valid => no_connect,
            slave_ctrl_dat_i         => eeprom_ctrl_dat_o,
            slave_ctrl_dat_o         => eeprom_ctrl_dat_i,
            
            clk_i  => clk_i,
            rst_i  => rst_i, 
            addr_i => addr_i,
            dat_i 	=> dat_i,
            dat_o  => dat_o,
            we_i   => we_i,
            stb_i  => stb_i,
            ack_o  => ack_o,
            cyc_i  => cyc_i);
            
end rtl;
