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
-- <revision control keyword substitutions e.g. $Id: eeprom_ctrl.vhd,v 1.7 2004/05/06 18:16:43 jjacob Exp $>
--
-- Project:	      SCUBA-2
-- Author:	       Jonathan Jacob
--
-- Organisation:  UBC
--
-- Description:  This module is the controller for the EEPROM. 
-- 
-- Current Limitations/Current Status: 
-- It currently checks the status register, sets up the write permissions for full write permission,
-- and it has READ and WRITE capability.  I have not linted it yet.
-- It currently holds the bus for the entire READ or WRITE cycle, and has only limited RETRY capability
-- while it's doing its SETUP, and at the end of the READ or WRITE cycle where the two state machines
-- overlap.
--
-- Revision history:
-- 
-- <date $Date: 2004/05/06 18:16:43 $>	-		<text>		- <initials $Author: jjacob $>

-- 
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library components;
use components.component_pack.all;

library work;
use work.eeprom_ctrl_pack.all;

library sys_param;
use sys_param.wishbone_pack.all;
use sys_param.general_pack.all;


entity eeprom_ctrl is

generic(EEPROM_CTRL_ADDR               : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := EEPROM_ADDR  );

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
     
     -- Wishbone interface:
     clk_i           : in std_logic;
     rst_i           : in std_logic;		
     addr_i          : in std_logic_vector (WB_ADDR_WIDTH-1 downto 0);
     tga_i           : in std_logic_vector (WB_TAG_ADDR_WIDTH-1 downto 0);
     dat_i 	         : in std_logic_vector (WB_DATA_WIDTH-1 downto 0);
     dat_o           : out std_logic_vector (WB_DATA_WIDTH-1 downto 0);
     we_i            : in std_logic;
     stb_i           : in std_logic;
     ack_o           : out std_logic;
     rty_o           : out std_logic;
     cyc_i           : in std_logic ); 
     
end eeprom_ctrl;


architecture rtl of eeprom_ctrl is

signal dat_i_hold            : std_logic_vector (WB_DATA_WIDTH-1 downto 0);

-- controller states:

-- declaring state type to help during simulation/debugging
type states is (IDLE, SETUP_TX_RDSR_CMD, SETUP_RX_SR_DATA,SPI_WAIT1, SPI_WAIT2,SETUP_TX_WRSR_CMD, SETUP_TX_SR_DATA,  SETUP_TX_WREN_CMD , 
TX_READ_CMD, TX_BYTE_ADDR , READ, TX_WRITE_CMD ,WRITE , TX_RDSR_CMD , RX_SR_DATA , SETUP, WB_WAIT ,TX_WB_DATA, DONE, RESET_SETUP,
SETUP_DONE ) ;
signal current_state, next_state, previous_state, pprevious_state, wb_current_state, wb_next_state: states;

--constant SETUP_TX_RDSR_CMD   : std_logic_vector(4 downto 0) := "00000";
--constant SETUP_RX_SR_DATA    : std_logic_vector(4 downto 0) := "00001";
--constant SPI_WAIT1            : std_logic_vector(4 downto 0) := "00010";
--constant SPI_WAIT2           : std_logic_vector(4 downto 0) := "10001";
--constant SETUP_TX_WRSR_CMD   : std_logic_vector(4 downto 0) := "00011";
--constant SETUP_TX_SR_DATA    : std_logic_vector(4 downto 0) := "00100";
--constant SETUP_TX_WREN_CMD   : std_logic_vector(4 downto 0) := "00101";
--
--constant IDLE                : std_logic_vector(4 downto 0) := "00110";
--constant TX_READ_CMD         : std_logic_vector(4 downto 0) := "00111";
--constant TX_BYTE_ADDR        : std_logic_vector(4 downto 0) := "01000";
--constant READ                : std_logic_vector(4 downto 0) := "01001";
--constant TX_WRITE_CMD        : std_logic_vector(4 downto 0) := "01010";
--constant WRITE               : std_logic_vector(4 downto 0) := "01011";
--constant TX_RDSR_CMD         : std_logic_vector(4 downto 0) := "01100";
--constant RX_SR_DATA          : std_logic_vector(4 downto 0) := "01101";
--
--constant SETUP               : std_logic_vector(4 downto 0) := "01110";
--constant WB_WAIT             : std_logic_vector(4 downto 0) := "01111";
--constant TX_WB_DATA          : std_logic_vector(4 downto 0) := "10000";
--
--constant DONE                : std_logic_vector(4 downto 0) := "11111";



constant TIME_100NS          : integer := 100;-- - CLOCK_PERIOD_NS;  -- did this because of reset behaviour of the counter
      								  -- I want 200ns clock period

-- EEPROM commands 

signal WREN_CMD              : std_logic_vector(7 downto 0); --:= "00000110"; -- set write enable latch      0x06
signal WRDI_CMD              : std_logic_vector(7 downto 0); --:= "00000100"; -- reset write enable latch    0x04
signal RDSR_CMD              : std_logic_vector(7 downto 0); --:= "00000101"; -- read status register        0x05
signal WRSR_CMD              : std_logic_vector(7 downto 0); --:= "00000001"; -- write status register       0x01
signal READ_CMD              : std_logic_vector(7 downto 0); --:= "00000011"; -- read data from memory array 0x03
signal WRITE_CMD             : std_logic_vector(7 downto 0); --:= "00000010"; -- read data from memory array 0x02



--signal READ_EEPROM_CMD       : std_logic_vector(7 downto 0) := "00000011"; -- 0x03
--signal WRITE_EN_CMD          : std_logic_vector(7 downto 0) := "00000110"; -- 0x06
--signal WRITE_CMD             : std_logic_vector(7 downto 0) := "00000010"; -- 0x02
--signal READ_STATUS_REG_CMD   : std_logic_vector(7 downto 0) := "00000101"; -- 0x05


-- controller state variables:
--signal current_state         : std_logic_vector(4 downto 0);
--signal next_state            : std_logic_vector(4 downto 0);
--signal previous_state        : std_logic_vector(4 downto 0);
--
--signal wb_current_state      : std_logic_vector(4 downto 0);
--signal wb_next_state         : std_logic_vector(4 downto 0);

signal eeprom_ctrl_busy      : std_logic;

--signal wb_rx_eeprom_data     : std_logic_vector(WB_DATA_WIDTH-1 downto 0);

signal sr_setup_value_temp          : std_logic_vector(7 downto 0);
signal sr_setup_value               : std_logic_vector(7 downto 0);

-- nano-second timer control signals
signal timer_100ns_rst       : std_logic;
signal timer_100ns           : integer;

signal eeprom_clk            : std_logic;
signal n_eeprom_clk          : std_logic;
signal eeprom_done           : std_logic;


-- SPI module start/done/clk/data signals:

signal setup_tx_rdsr_cmd_start : std_logic;
signal setup_tx_rdsr_cmd_done  : std_logic;
signal setup_tx_rdsr_cmd_clk   : std_logic;
signal setup_tx_rdsr_cmd_data  : std_logic;

signal setup_rx_sr_data_start  : std_logic;
signal setup_rx_sr_data_done   : std_logic;
signal setup_rx_sr_data_clk    : std_logic;
signal setup_rx_sr_data_reg    : std_logic_vector(7 downto 0);

signal setup_tx_wrsr_cmd_start : std_logic;
signal setup_tx_wrsr_cmd_done  : std_logic;
signal setup_tx_wrsr_cmd_clk   : std_logic;
signal setup_tx_wrsr_cmd_data  : std_logic;

signal setup_tx_sr_data_start  : std_logic;
signal setup_tx_sr_data_done   : std_logic;
signal setup_tx_sr_data_clk    : std_logic;
signal setup_tx_sr_data_reg    : std_logic;

signal setup_tx_wren_cmd_start : std_logic;
signal setup_tx_wren_cmd_done  : std_logic;
signal setup_tx_wren_cmd_clk   : std_logic;
signal setup_tx_wren_cmd_data  : std_logic;


signal tx_read_cmd_start     : std_logic;
signal tx_read_cmd_done      : std_logic;
signal tx_read_cmd_clk       : std_logic;
signal tx_read_cmd_data      : std_logic;

signal tx_byte_addr_start    : std_logic;
signal tx_byte_addr_clk      : std_logic;
signal tx_byte_addr_done     : std_logic;
signal tx_byte_addr_data     : std_logic;

signal rx_eeprom_data_start  : std_logic;
signal rx_eeprom_data_clk    : std_logic;
signal rx_eeprom_data_done   : std_logic;
signal rx_eeprom_data_reg    : std_logic_vector(WB_DATA_WIDTH-1 downto 0);

signal rx_eeprom_data_reg_capture    : std_logic_vector(WB_DATA_WIDTH-1 downto 0);

--signal tx_write_en_cmd_start : std_logic;
--signal tx_write_en_cmd_clk   : std_logic;
--signal tx_write_en_cmd_done  : std_logic;
--signal tx_write_en_cmd_data  : std_logic;
--
signal tx_write_cmd_start    : std_logic;
signal tx_write_cmd_clk      : std_logic;
signal tx_write_cmd_done     : std_logic;
signal tx_write_cmd_data     : std_logic;            
            
--signal tx_check_status_cmd_start    : std_logic;
--signal tx_check_status_cmd_clk      : std_logic;
--signal tx_check_status_cmd_done     : std_logic;
--signal tx_check_status_cmd_data     : std_logic;

signal tx_eeprom_data_start  : std_logic;
signal tx_eeprom_data_clk    : std_logic;
signal tx_eeprom_data_done   : std_logic;
signal tx_eeprom_data        : std_logic;

signal tx_rdsr_cmd_start     : std_logic;
signal tx_rdsr_cmd_clk       : std_logic;
signal tx_rdsr_cmd_done      : std_logic;
signal tx_rdsr_cmd_data      : std_logic;

signal rx_sr_data_start      : std_logic;
signal rx_sr_data_clk        : std_logic;
signal rx_sr_data_done       : std_logic;
signal rx_sr_data_reg        : std_logic_vector(7 downto 0);
signal rx_sr_data_reg_hold   : std_logic_vector(7 downto 0);


begin

   -- assign values to the eeprom command codes
   WREN_CMD  <= "00000110"; -- set write enable latch      0x06
   WRDI_CMD  <= "00000100"; -- reset write enable latch    0x04
   RDSR_CMD  <= "00000101"; -- read status register        0x05
   WRSR_CMD  <= "00000001"; -- write status register       0x01
   READ_CMD  <= "00000011"; -- read data from memory array 0x03
   WRITE_CMD <= "00000010"; -- read data from memory array 0x02



------------------------------------------------------------------------
--
-- capture logic for Wishbone bus running on wishbone clock
--
------------------------------------------------------------------------


------------------------------------------------------------------------
--
-- generate the eeprom clock w/ ~200ns period combinatorially from the
-- system clk
--
------------------------------------------------------------------------
   
--   process(rst_i, clk_i)
--   begin
--   
--      --timer_100ns_rst <= '0';
--   
--      if rst_i = '1' then
--         eeprom_clk <= '0';
--         --timer_100ns_rst <= '1';
--      elsif clk_i'event and clk_i = '1' then
--         if timer_100ns >= TIME_100NS then  -- this is actually 120ns period!!!!
--            eeprom_clk <= not(eeprom_clk);
--            --timer_100ns_rst <= '1';
--         end if;
--      end if;
--   end process;

   process(rst_i, timer_100ns)
   begin
   
      --timer_100ns_rst <= '0';
   
      if rst_i = '1' then
         eeprom_clk <= '0';
         --timer_100ns_rst <= '1';
      elsif timer_100ns = TIME_100NS then  -- this is actually 120ns period!!!!
            eeprom_clk <= not(eeprom_clk);
            --timer_100ns_rst <= '1';
      end if;
   end process;


   -- phase shifted clock for the eeprom state machine logic
   n_eeprom_clk <= not(eeprom_clk);
   
--   process(rst_i, clk_i)
--   begin
--      if rst_i = '1' then
--         timer_100ns_rst <= '1';
--      elsif clk_i'event and clk_i = '1' then
--         if timer_100ns = TIME_100NS then
--            timer_100ns_rst <= '1';
--         else
--            timer_100ns_rst <= '0';
--         end if;
--      end if;
--   end process;
 
   timer_100ns_rst <= '1' when timer_100ns = TIME_100NS or rst_i = '1' else '0';
------------------------------------------------------------------------
--
-- State sequencer, based on a 200ns phase shifted clock that is
-- generated COMBINATORIALLY
--
------------------------------------------------------------------------
 
   process(rst_i, n_eeprom_clk)
   begin
   
      if rst_i = '1' then
         current_state <= RESET_SETUP; --IDLE;
      elsif n_eeprom_clk'event and n_eeprom_clk = '1' then
         current_state <= next_state;
         previous_state <= current_state;
         pprevious_state <= previous_state;
      end if; 
   end process;
   
------------------------------------------------------------------------
--
-- State machine between eeprom controller and the eeprom.
-- This state machine runs on a slow clock (~5MHz)
--
------------------------------------------------------------------------  

   rx_sr_data_reg_hold <= rx_sr_data_reg when rx_sr_data_done = '1';
   --rx_sr_data_reg_hold <= rx_sr_data_reg when current_state = SPI_WAIT1 and previous_state = RX_SR_DATA;


   process(current_state, setup_tx_rdsr_cmd_done, setup_rx_sr_data_done, pprevious_state,
           setup_tx_wrsr_cmd_done, setup_tx_sr_data_done, setup_tx_wren_cmd_done, 
           addr_i, cyc_i, stb_i, we_i, tx_read_cmd_done, tx_byte_addr_done, rx_eeprom_data_done,
           tx_write_cmd_done, tx_eeprom_data_done, tx_rdsr_cmd_done, rx_sr_data_done, rx_sr_data_reg_hold)
           --previous_state, rx_sr_data_reg, rst_i)
      begin




      case current_state is
      
      
               when IDLE =>
         

               --if n_eeprom_cs_o   <= '0'; then
               if addr_i = EEPROM_CTRL_ADDR and cyc_i = '1' and stb_i = '1' then
                  if we_i = '0' then -- indicates a READ
                     next_state <= TX_READ_CMD;
                  else
                     next_state <= TX_WRITE_CMD;
                  end if;
               else  
                  next_state <= IDLE;
               end if;
          
         
         -- This section performs setup on the eeprom.  It does the following:
         -- 1. Transmit the Read Status Register (RDSR) command, and then reads the status register
         -- 2. It sets the protection bits BP1 and BP0 to '0' to allow writing to the entire address range
         -- 3. Transmit the Write Status Register (WRSR) command, and writes back to the status register
         -- 4. Transmit the Write Enable (WREN) command
         
         when RESET_SETUP =>
            --if rst_i = '0' then
               next_state <= SETUP_TX_RDSR_CMD;
            --else
            --   next_state <= RESET_SETUP;
            --end if;
         
         
         when SETUP_TX_RDSR_CMD => -- transmit read status register command
            if setup_tx_rdsr_cmd_done = '1' then
               next_state <= SETUP_RX_SR_DATA; 
            else
               next_state <= SETUP_TX_RDSR_CMD; 
            end if;
            
         when SETUP_RX_SR_DATA => -- receive status register data
            if setup_rx_sr_data_done = '1' then
               next_state <= SPI_WAIT1;
            else
               next_state <= SETUP_RX_SR_DATA;
            end if;
          
         when SPI_WAIT1 =>
            next_state <= SPI_WAIT2;
            
         when SPI_WAIT2 => -- we must wait between SPI commands
            
            case pprevious_state is
               when SETUP_RX_SR_DATA => next_state <= SETUP_TX_WRSR_CMD;
               when SETUP_TX_SR_DATA => next_state <= SETUP_TX_WREN_CMD;
               when WRITE            => next_state <= TX_RDSR_CMD;
                      
               when RX_SR_DATA => 
                  if rx_sr_data_reg_hold(0) = '0' then 
                     next_state <= DONE ;
                  else
                     next_state <= TX_RDSR_CMD;
                  end if;
                  
               when others =>           next_state <= IDLE;
            
            end case;
        
         when SETUP_TX_WRSR_CMD => -- transmit write status register command
            if setup_tx_wrsr_cmd_done = '1' then
               next_state <= SETUP_TX_SR_DATA;
            else
               next_state <= SETUP_TX_WRSR_CMD;
            end if;
           
         when SETUP_TX_SR_DATA => -- transmit status register data
            if setup_tx_sr_data_done = '1' then
               next_state <= SPI_WAIT1;
            else
               next_state <= SETUP_TX_SR_DATA;
            end if;
           
         when SETUP_TX_WREN_CMD => -- transmit write enable command
            if setup_tx_wren_cmd_done = '1' then
               next_state <= SETUP_DONE;--IDLE;
            else
               next_state <= SETUP_TX_WREN_CMD;
            end if;
            
         when SETUP_DONE =>
            next_state <= IDLE;
      
         -- End setup.
      
      
      

          
         -- This section performs READs from the eeprom:   
         when TX_READ_CMD => -- transmit the READ command
            if tx_read_cmd_done = '1' then
               next_state <= TX_BYTE_ADDR;
            else
               next_state <= TX_READ_CMD;
            end if;
            
         when TX_BYTE_ADDR => -- transmite the byte address
         
            if tx_byte_addr_done = '1' then
               if we_i = '1' then -- doing a write cycle
                  next_state <= WRITE;
               else
                  next_state <= READ;
               end if;
            else
               next_state <= TX_BYTE_ADDR;
            end if;         
                     
         when READ => -- read the data from the eeprom
            if rx_eeprom_data_done = '1' then
               next_state <= DONE;
            else
               next_state <= READ;
            end if;  
           
          
          
         -- This section performs WRITEs to the eeprom:   
            
         when TX_WRITE_CMD => -- transmit the WRITE command
            if tx_write_cmd_done = '1' then
               next_state <= TX_BYTE_ADDR;
            else
               next_state <= TX_WRITE_CMD;
            end if;
            
         when WRITE => -- write the data to the EEPROM
            if tx_eeprom_data_done = '1' then
               next_state <= SPI_WAIT1;
            else
               next_state <= WRITE;
            end if;
            
         when TX_RDSR_CMD => -- transmit read status register command
            if tx_rdsr_cmd_done = '1' then
               next_state <= RX_SR_DATA; 
            else
               next_state <= TX_RDSR_CMD; 
            end if;
            
         when RX_SR_DATA => -- receive status register data
            if rx_sr_data_done = '1' then
               --if rx_sr_data_reg(0) = '0' then -- indicates the device is ready
                  --next_state <= DONE;
               --else
                  next_state <= SPI_WAIT1;
               --end if;
            else
               next_state <= RX_SR_DATA;
            end if;
            
         
         when DONE =>
            next_state <= IDLE;
            
         when others =>
            next_state <= IDLE;
            
      end case;
   end process;
            

    
   process(current_state)
   begin

      case current_state is
      
         when IDLE =>
            n_eeprom_hold_o        <= '1';
            n_eeprom_wp_o          <= '1';            
            eeprom_done            <= '0';
            
            setup_tx_rdsr_cmd_start <= '0';
            setup_rx_sr_data_start  <= '0';
            setup_tx_wrsr_cmd_start <= '0';
            setup_tx_sr_data_start  <= '0';
            setup_tx_wren_cmd_start <= '0';
            

            tx_read_cmd_start      <= '0';

            tx_byte_addr_start     <= '0';
            rx_eeprom_data_start   <= '0';
            
            --tx_write_en_cmd_start  <= '0';
            tx_write_cmd_start     <= '0';
            --tx_check_status_cmd_start     <= '0';
            tx_eeprom_data_start   <= '0'; 
            
            tx_rdsr_cmd_start      <= '0';
            rx_sr_data_start       <= '0';
            
            n_eeprom_cs_o   <= '1';

      
         when SETUP_TX_RDSR_CMD =>

            n_eeprom_hold_o        <= '1';
            n_eeprom_wp_o          <= '1';            
            eeprom_done            <= '0';
            
            setup_tx_rdsr_cmd_start <= '1';
            setup_rx_sr_data_start  <= '0';
            setup_tx_wrsr_cmd_start <= '0';
            setup_tx_sr_data_start  <= '0';
            setup_tx_wren_cmd_start <= '0';
            --setup_done              <= '0';

            tx_read_cmd_start      <= '0';
            tx_byte_addr_start     <= '0';
            rx_eeprom_data_start   <= '0';
            
            --tx_write_en_cmd_start  <= '0';
            tx_write_cmd_start     <= '0';
            --tx_check_status_cmd_start     <= '0';
            tx_eeprom_data_start   <= '0';  
            
            tx_rdsr_cmd_start      <= '0';
            rx_sr_data_start       <= '0';
            
            n_eeprom_cs_o   <= '0';        
         
         
         when SETUP_RX_SR_DATA =>
         
            n_eeprom_hold_o        <= '1';
            n_eeprom_wp_o          <= '1';            
            eeprom_done            <= '0';
            
            setup_tx_rdsr_cmd_start <= '0';
            setup_rx_sr_data_start  <= '1';
            setup_tx_wrsr_cmd_start <= '0';
            setup_tx_sr_data_start  <= '0';
            setup_tx_wren_cmd_start <= '0';
            --setup_done              <= '0';

            tx_read_cmd_start      <= '0';
            tx_byte_addr_start     <= '0';
            rx_eeprom_data_start   <= '0';
            
            --tx_write_en_cmd_start  <= '0';
            tx_write_cmd_start     <= '0';
            --tx_check_status_cmd_start     <= '0';
            tx_eeprom_data_start   <= '0';  
            
            tx_rdsr_cmd_start      <= '0';
            rx_sr_data_start       <= '0';  
            
            n_eeprom_cs_o   <= '0';  

         when SPI_WAIT1 =>
         
            n_eeprom_hold_o        <= '1';
            n_eeprom_wp_o          <= '1';            
            eeprom_done            <= '0';
            
            setup_tx_rdsr_cmd_start <= '0';
            setup_rx_sr_data_start  <= '0';
            setup_tx_wrsr_cmd_start <= '0';
            setup_tx_sr_data_start  <= '0';
            setup_tx_wren_cmd_start <= '0';
            --setup_done              <= '0';

            tx_read_cmd_start      <= '0';
            tx_byte_addr_start     <= '0';
            rx_eeprom_data_start   <= '0';
            
            --tx_write_en_cmd_start  <= '0';
            tx_write_cmd_start     <= '0';
            --tx_check_status_cmd_start     <= '0';
            tx_eeprom_data_start   <= '0';  
            
            tx_rdsr_cmd_start      <= '0';
            rx_sr_data_start       <= '0';  
            
            n_eeprom_cs_o   <= '0';   
            
            
--            if previous_state = RX_SR_DATA then
--               rx_sr_data_reg_hold <= rx_sr_data_reg;
--            end if;

         
         when SPI_WAIT2 =>
         
            n_eeprom_hold_o        <= '1';
            n_eeprom_wp_o          <= '1';            
            eeprom_done            <= '0';
            
            setup_tx_rdsr_cmd_start <= '0';
            setup_rx_sr_data_start  <= '0';
            setup_tx_wrsr_cmd_start <= '0';
            setup_tx_sr_data_start  <= '0';
            setup_tx_wren_cmd_start <= '0';
            --setup_done              <= '0';

            tx_read_cmd_start      <= '0';
            tx_byte_addr_start     <= '0';
            rx_eeprom_data_start   <= '0';
            
            --tx_write_en_cmd_start  <= '0';
            tx_write_cmd_start     <= '0';
            --tx_check_status_cmd_start     <= '0';
            tx_eeprom_data_start   <= '0';  
            
            tx_rdsr_cmd_start      <= '0';
            rx_sr_data_start       <= '0';  
            
            n_eeprom_cs_o   <= '1';                    
         
         
         when SETUP_TX_WRSR_CMD =>
         
            n_eeprom_hold_o        <= '1';
            n_eeprom_wp_o          <= '1';            
            eeprom_done            <= '0';
            
            setup_tx_rdsr_cmd_start <= '0';
            setup_rx_sr_data_start  <= '0';
            setup_tx_wrsr_cmd_start <= '1';
            setup_tx_sr_data_start  <= '0';
            setup_tx_wren_cmd_start <= '0';
            --setup_done              <= '0';

            tx_read_cmd_start      <= '0';
            tx_byte_addr_start     <= '0';
            rx_eeprom_data_start   <= '0';
            
            --tx_write_en_cmd_start  <= '0';
            tx_write_cmd_start     <= '0';
            --tx_check_status_cmd_start     <= '0';
            tx_eeprom_data_start   <= '0'; 
            
            tx_rdsr_cmd_start      <= '0';
            rx_sr_data_start       <= '0';
            
            n_eeprom_cs_o   <= '0';           
         
         
         when SETUP_TX_SR_DATA =>
         
            n_eeprom_hold_o        <= '1';
            n_eeprom_wp_o          <= '1';            
            eeprom_done            <= '0';
            
            setup_tx_rdsr_cmd_start <= '0';
            setup_rx_sr_data_start  <= '0';
            setup_tx_wrsr_cmd_start <= '0';
            setup_tx_sr_data_start  <= '1';
            setup_tx_wren_cmd_start <= '0';
            --setup_done              <= '0';

            tx_read_cmd_start      <= '0';
            tx_byte_addr_start     <= '0';
            rx_eeprom_data_start   <= '0';
            
            --tx_write_en_cmd_start  <= '0';
            tx_write_cmd_start     <= '0';
            --tx_check_status_cmd_start     <= '0';
            tx_eeprom_data_start   <= '0';   
            
            tx_rdsr_cmd_start      <= '0';
            rx_sr_data_start       <= '0';   
            
            n_eeprom_cs_o   <= '0';      
                  
         
         when SETUP_TX_WREN_CMD =>
         
            n_eeprom_hold_o        <= '1';
            n_eeprom_wp_o          <= '1';            
            eeprom_done            <= '0';
            
            setup_tx_rdsr_cmd_start <= '0';
            setup_rx_sr_data_start  <= '0';
            setup_tx_wrsr_cmd_start <= '0';
            setup_tx_sr_data_start  <= '0';
            setup_tx_wren_cmd_start <= '1';
            --setup_done              <= '0';

            tx_read_cmd_start      <= '0';
            tx_byte_addr_start     <= '0';
            rx_eeprom_data_start   <= '0';
            
            --tx_write_en_cmd_start  <= '0';
            tx_write_cmd_start     <= '0';
            --tx_check_status_cmd_start     <= '0';
            tx_eeprom_data_start   <= '0'; 
            
            tx_rdsr_cmd_start      <= '0';
            rx_sr_data_start       <= '0';           
         
            n_eeprom_cs_o   <= '0';
         
         when RESET_SETUP =>
            n_eeprom_hold_o        <= '1';
            n_eeprom_wp_o          <= '1';            
            eeprom_done            <= '0';
            
            setup_tx_rdsr_cmd_start <= '0';
            setup_rx_sr_data_start  <= '0';
            setup_tx_wrsr_cmd_start <= '0';
            setup_tx_sr_data_start  <= '0';
            setup_tx_wren_cmd_start <= '0';
            

            tx_read_cmd_start      <= '0';

            tx_byte_addr_start     <= '0';
            rx_eeprom_data_start   <= '0';
            
            --tx_write_en_cmd_start  <= '0';
            tx_write_cmd_start     <= '0';
            --tx_check_status_cmd_start     <= '0';
            tx_eeprom_data_start   <= '0'; 
            
            tx_rdsr_cmd_start      <= '0';
            rx_sr_data_start       <= '0';
            
            n_eeprom_cs_o   <= '1';         
      
         when SETUP_DONE =>
         
            n_eeprom_hold_o        <= '1';
            n_eeprom_wp_o          <= '1';            
            eeprom_done            <= '0';
            
            setup_tx_rdsr_cmd_start <= '0';
            setup_rx_sr_data_start  <= '0';
            setup_tx_wrsr_cmd_start <= '0';
            setup_tx_sr_data_start  <= '0';
            setup_tx_wren_cmd_start <= '0';
            --setup_done              <= '0';

            tx_read_cmd_start      <= '0';
            tx_byte_addr_start     <= '0';
            rx_eeprom_data_start   <= '0';
            
            --tx_write_en_cmd_start  <= '0';
            tx_write_cmd_start     <= '0';
            --tx_check_status_cmd_start     <= '0';
            tx_eeprom_data_start   <= '0';  
            
            tx_rdsr_cmd_start      <= '0';
            rx_sr_data_start       <= '0';  
            
            n_eeprom_cs_o   <= '0';             
      
      

         when TX_READ_CMD =>
 
            
            n_eeprom_hold_o        <= '1';
            n_eeprom_wp_o          <= '1';
            eeprom_done            <= '0';
            
            tx_read_cmd_start      <= '1';
            tx_byte_addr_start     <= '0';
            rx_eeprom_data_start   <= '0';
            
            setup_tx_rdsr_cmd_start <= '0';
            setup_rx_sr_data_start  <= '0';
            setup_tx_wrsr_cmd_start <= '0';
            setup_tx_sr_data_start  <= '0';
            setup_tx_wren_cmd_start <= '0';
            
            --tx_write_en_cmd_start  <= '0';
            tx_write_cmd_start     <= '0';
            --tx_check_status_cmd_start     <= '0';
            tx_eeprom_data_start   <= '0';
            
            tx_rdsr_cmd_start      <= '0';
            rx_sr_data_start       <= '0';
            
            n_eeprom_cs_o   <= '0';
            
         when TX_BYTE_ADDR =>

            n_eeprom_hold_o        <= '1';
            n_eeprom_wp_o          <= '1';
            eeprom_done            <= '0';
            
            setup_tx_rdsr_cmd_start <= '0';
            setup_rx_sr_data_start  <= '0';
            setup_tx_wrsr_cmd_start <= '0';
            setup_tx_sr_data_start  <= '0';
            setup_tx_wren_cmd_start <= '0';

            tx_read_cmd_start      <= '0';
            tx_byte_addr_start     <= '1';
            rx_eeprom_data_start   <= '0';
            
            --tx_write_en_cmd_start  <= '0';
            tx_write_cmd_start     <= '0';
            --tx_check_status_cmd_start     <= '0';
            tx_eeprom_data_start   <= '0';
            
            tx_rdsr_cmd_start      <= '0';
            rx_sr_data_start       <= '0';
            
            n_eeprom_cs_o   <= '0';
            
         when READ =>

            n_eeprom_hold_o        <= '1';
            n_eeprom_wp_o          <= '1';
            eeprom_done            <= '0';
            
            setup_tx_rdsr_cmd_start <= '0';
            setup_rx_sr_data_start  <= '0';
            setup_tx_wrsr_cmd_start <= '0';
            setup_tx_sr_data_start  <= '0';
            setup_tx_wren_cmd_start <= '0';

            tx_read_cmd_start      <= '0';
            tx_byte_addr_start     <= '0';
            rx_eeprom_data_start   <= '1';
            
            --tx_write_en_cmd_start  <= '0';
            tx_write_cmd_start     <= '0';
            --tx_check_status_cmd_start     <= '0';
            tx_eeprom_data_start   <= '0';
            
            tx_rdsr_cmd_start      <= '0';
            rx_sr_data_start       <= '0';
            
            n_eeprom_cs_o   <= '0';
            
--         when TX_WREN_CMD =>
--
--            n_eeprom_hold_o        <= '1';
--            n_eeprom_wp_o          <= '1';
--            eeprom_done            <= '0';
--            
--            setup_tx_rdsr_cmd_start <= '0';
--            setup_rx_sr_data_start  <= '0';
--            setup_tx_wrsr_cmd_start <= '0';
--            setup_tx_sr_data_start  <= '0';
--            setup_tx_wren_cmd_start <= '0';
--
--            tx_read_cmd_start      <= '0';
--            tx_byte_addr_start     <= '0';
--            rx_eeprom_data_start   <= '0';  
--            
--            --tx_write_en_cmd_start  <= '1';
--            tx_write_cmd_start     <= '0';
--            --tx_check_status_cmd_start     <= '0';
--            tx_eeprom_data_start   <= '0'; 
--            
--            tx_rdsr_cmd_start      <= '0';
--            rx_sr_data_start       <= '0';
--            
--            n_eeprom_cs_o   <= '0';  
            
         when TX_WRITE_CMD =>

            n_eeprom_hold_o        <= '1';
            n_eeprom_wp_o          <= '1';
            eeprom_done            <= '0';
            
            setup_tx_rdsr_cmd_start <= '0';
            setup_rx_sr_data_start  <= '0';
            setup_tx_wrsr_cmd_start <= '0';
            setup_tx_sr_data_start  <= '0';
            setup_tx_wren_cmd_start <= '0';

            tx_read_cmd_start      <= '0';
            tx_byte_addr_start     <= '0';
            rx_eeprom_data_start   <= '0'; 
            
            --tx_write_en_cmd_start  <= '0';
            tx_write_cmd_start     <= '1';
            --tx_check_status_cmd_start     <= '0';
            tx_eeprom_data_start   <= '0';
            
            tx_rdsr_cmd_start      <= '0';
            rx_sr_data_start       <= '0';
            
            n_eeprom_cs_o   <= '0';
            
         when WRITE =>
         
            n_eeprom_hold_o        <= '1';
            n_eeprom_wp_o          <= '1';
            eeprom_done            <= '0';
            
            setup_tx_rdsr_cmd_start <= '0';
            setup_rx_sr_data_start  <= '0';
            setup_tx_wrsr_cmd_start <= '0';
            setup_tx_sr_data_start  <= '0';
            setup_tx_wren_cmd_start <= '0';

            tx_read_cmd_start      <= '0';
            tx_byte_addr_start     <= '0';
            rx_eeprom_data_start   <= '0'; 
            
            --tx_write_en_cmd_start  <= '0';
            tx_write_cmd_start     <= '0';
            --tx_check_status_cmd_start     <= '0';
            tx_eeprom_data_start   <= '1';
            
            tx_rdsr_cmd_start      <= '0';
            rx_sr_data_start       <= '0';
            
            n_eeprom_cs_o   <= '0';
                               
         when TX_RDSR_CMD =>
         
            n_eeprom_hold_o        <= '1';
            n_eeprom_wp_o          <= '1';
            eeprom_done            <= '0';
            
            setup_tx_rdsr_cmd_start <= '0';
            setup_rx_sr_data_start  <= '0';
            setup_tx_wrsr_cmd_start <= '0';
            setup_tx_sr_data_start  <= '0';
            setup_tx_wren_cmd_start <= '0';

            tx_read_cmd_start      <= '0';
            tx_byte_addr_start     <= '0';
            rx_eeprom_data_start   <= '0'; 
            
            --tx_write_en_cmd_start  <= '0';
            tx_write_cmd_start     <= '0';
            --tx_check_status_cmd_start     <= '1';
            tx_eeprom_data_start   <= '0'; 
            
            tx_rdsr_cmd_start      <= '1';
            rx_sr_data_start       <= '0';
            
            n_eeprom_cs_o   <= '0';
            
            
         when RX_SR_DATA =>
         
            n_eeprom_hold_o        <= '1';
            n_eeprom_wp_o          <= '1';
            eeprom_done            <= '0';
            
            setup_tx_rdsr_cmd_start <= '0';
            setup_rx_sr_data_start  <= '0';
            setup_tx_wrsr_cmd_start <= '0';
            setup_tx_sr_data_start  <= '0';
            setup_tx_wren_cmd_start <= '0';

            tx_read_cmd_start      <= '0';
            tx_byte_addr_start     <= '0';
            rx_eeprom_data_start   <= '0'; 
            
            --tx_write_en_cmd_start  <= '0';
            tx_write_cmd_start     <= '0';
            --tx_check_status_cmd_start     <= '1';
            tx_eeprom_data_start   <= '0'; 
            
            tx_rdsr_cmd_start      <= '0';
            rx_sr_data_start       <= '1';
            
            n_eeprom_cs_o   <= '0';
         
         when DONE =>

            n_eeprom_hold_o        <= '1';
            n_eeprom_wp_o          <= '1';
            eeprom_done            <= '1';
            
            setup_tx_rdsr_cmd_start <= '0';
            setup_rx_sr_data_start  <= '0';
            setup_tx_wrsr_cmd_start <= '0';
            setup_tx_sr_data_start  <= '0';
            setup_tx_wren_cmd_start <= '0';
          
            tx_read_cmd_start      <= '0';
            tx_byte_addr_start     <= '0';
            rx_eeprom_data_start   <= '0';
            
            --tx_write_en_cmd_start  <= '0';
            tx_write_cmd_start     <= '0';
            --tx_check_status_cmd_start     <= '0';
            tx_eeprom_data_start   <= '0';
            
            tx_rdsr_cmd_start      <= '0';
            rx_sr_data_start       <= '0';
            
            n_eeprom_cs_o   <= '0';
            
         when others =>

            n_eeprom_hold_o        <= '1';
            n_eeprom_wp_o          <= '1';

            eeprom_done            <= '0'; 
            
            setup_tx_rdsr_cmd_start <= '0';
            setup_rx_sr_data_start  <= '0';
            setup_tx_wrsr_cmd_start <= '0';
            setup_tx_sr_data_start  <= '0';
            setup_tx_wren_cmd_start <= '0'; 

            tx_read_cmd_start      <= '0';
            tx_byte_addr_start     <= '0';
            rx_eeprom_data_start   <= '0';
            
            --tx_write_en_cmd_start  <= '0'; -- these are outdated, remove all of these JJ
            tx_write_cmd_start     <= '0';
            tx_eeprom_data_start   <= '0';
            --tx_check_status_cmd_start     <= '0'; --tx_rdsr_cmd_start JJ
            -- rx_sr_data_start JJ
            
            
            tx_rdsr_cmd_start      <= '0';
            rx_sr_data_start       <= '0';
            
            n_eeprom_cs_o   <= '1';
             
      end case;
   end process;      
   
------------------------------------------------------------------------
--
-- Muxes for SPI signals
--
------------------------------------------------------------------------  


--ADD the new setup signals and the SR signals here!!!
   eeprom_clk_o <= tx_read_cmd_clk when current_state = TX_READ_CMD else 
                   tx_byte_addr_clk when current_state = TX_BYTE_ADDR else
                   rx_eeprom_data_clk when current_state = READ else
                   --tx_write_en_cmd_clk when current_state = TX_WRITE_EN_CMD else
                                      
                   setup_tx_rdsr_cmd_clk when current_state = SETUP_TX_RDSR_CMD else 
                   setup_rx_sr_data_clk when current_state = SETUP_RX_SR_DATA else
                   setup_tx_wrsr_cmd_clk when current_state = SETUP_TX_WRSR_CMD else
                   setup_tx_sr_data_clk when current_state = SETUP_TX_SR_DATA else
                   setup_tx_wren_cmd_clk when current_state = SETUP_TX_WREN_CMD else
                   
                   tx_write_cmd_clk when current_state = TX_WRITE_CMD else
                   tx_eeprom_data_clk when current_state = WRITE else
                   tx_rdsr_cmd_clk when current_state = TX_RDSR_CMD else
                   rx_sr_data_clk when current_state = RX_SR_DATA else
                   '0';
                   
   eeprom_si_o  <= tx_read_cmd_data when current_state = TX_READ_CMD else 
                   tx_byte_addr_data when current_state = TX_BYTE_ADDR else
                   --tx_write_en_cmd_data when current_state = TX_WRITE_EN_CMD else
                   
                   setup_tx_rdsr_cmd_data when current_state = SETUP_TX_RDSR_CMD else
                   setup_tx_wrsr_cmd_data when current_state = SETUP_TX_WRSR_CMD else
                   setup_tx_sr_data_reg when current_state = SETUP_TX_SR_DATA else
                   setup_tx_wren_cmd_data when current_state = SETUP_TX_WREN_CMD else
                
                   tx_write_cmd_data when current_state = TX_WRITE_CMD else
                   tx_rdsr_cmd_data when current_state = TX_RDSR_CMD else
                   tx_eeprom_data when current_state = WRITE else
                   '0';


   
------------------------------------------------------------------------
--
-- State machine between eeprom controller and wishbone bus
-- This state machine runs at the same clock speed as the wishbone bus
--
------------------------------------------------------------------------  

   eeprom_ctrl_busy <= '0' when current_state = IDLE else '1';
   dat_i_hold       <= dat_i when (current_state = IDLE and addr_i = EEPROM_CTRL_ADDR and cyc_i = '1' and stb_i = '1'
                       and eeprom_ctrl_busy = '0' and we_i = '1'); --else
                       --(others=>'0');
   

   process(wb_current_state, addr_i, cyc_i, stb_i, setup_tx_wren_cmd_done, eeprom_ctrl_busy,
           eeprom_done) --,we_i, rst_i, )
   begin
   
      case wb_current_state is
      
         when RESET_SETUP =>
            --if rst_i = '0' then
               wb_next_state <= SETUP;
            --else
            --   wb_next_state <= RESET_SETUP;
            --end if;
      
         when SETUP =>
            if setup_tx_wren_cmd_done = '1' then
               wb_next_state <= IDLE;
            else
               wb_next_state <= SETUP;
            end if;
      
         when IDLE =>
         
            if addr_i = EEPROM_CTRL_ADDR and cyc_i = '1' and stb_i = '1' then
               if eeprom_ctrl_busy = '1' and eeprom_done = '1' then -- we need to cause a wishbone RETRY
                  wb_next_state <= IDLE; -- WB_RETRY;  -- indicates the eeprom is busy, so retry
               else
                  wb_next_state <= WB_WAIT;
                  
--                  if we_i = '1' then  -- we only want to hold the data if it's a WRITE to the EEPROM
--                     dat_i_hold      <= dat_i;
--                  else
--                     dat_i_hold      <= (others=>'0');
--                  end if; 
                  
               end if;
            else
               wb_next_state <= IDLE;
            end if;
            
--         when WB_RETRY =>  
--            wb_next_state <= IDLE;    
         
         when WB_WAIT =>
            if eeprom_done = '1' then  -- careful it doesn't transmit over and over again
               --if we_i = '1' then -- writing to the EEPROM, therefore don't need to tx anything back over wishbone
                  --wb_next_state <= IDLE;
               --else
                  wb_next_state <= TX_WB_DATA;
               --end if;
            else
               wb_next_state <= WB_WAIT;
            end if;
            
         when TX_WB_DATA =>
            wb_next_state <= IDLE;
            
         when others =>
            wb_next_state <= IDLE;
            
      end case;
   end process;


-- need to make ack_o dependant on cyc and stb
-- also need to add rty functionality up above

   rx_eeprom_data_reg_capture <= rx_eeprom_data_reg when (current_state = DONE and previous_state = READ) else
                                 (others => '0');


   process(wb_current_state, addr_i, cyc_i, stb_i, we_i, eeprom_ctrl_busy, rx_eeprom_data_reg_capture, eeprom_done)
   begin
   
      case wb_current_state is

         when IDLE =>
            -- outputs to the wishbone bus
            dat_o           <= (others => '0');
            ack_o           <= '0';
            rty_o           <= '0';
           
            --n_eeprom_cs_o   <= '1'; -- disabled in IDLE
            
            if addr_i = EEPROM_CTRL_ADDR and cyc_i = '1' and stb_i = '1' then
               if eeprom_ctrl_busy = '1' and eeprom_done = '1' then -- this is done because I currently hold the bus
                                                                    -- during a bus cycle, and need this RTY for the small
                                                                    -- amount of time during the DONE state with the slow
                                                                    -- clock and the IDLE with the fast clock
                  rty_o <= '1';
               else
                  rty_o <= '0';
               end if;
            end if;
            
--         when WB_RETRY =>
--         
--           -- outputs to the wishbone bus
--            dat_o           <= (others => '0');
--            ack_o           <= '0';
--            rty_o           <= '1'; 
--            
--            n_eeprom_cs_o   <= '1'; -- disabled

         
         when SETUP =>
            dat_o           <= (others => '0');
            ack_o           <= '0';
            rty_o           <= '0';
           
            --n_eeprom_cs_o   <= '0'; -- enabled for setup    
            
                
            if addr_i = EEPROM_CTRL_ADDR and cyc_i = '1' and stb_i = '1' then
              -- we need to cause a wishbone RETRY while in setup if there is a bus cycle
                  rty_o <= '1';
               else
                  rty_o <= '0';
               end if;
            --end if;         
         
 
         when RESET_SETUP =>
            -- outputs to the wishbone bus
            dat_o           <= (others => '0');
            ack_o           <= '0';
            rty_o           <= '0';
            
            if addr_i = EEPROM_CTRL_ADDR and cyc_i = '1' and stb_i = '1' then
            -- we need to cause a wishbone RETRY
                rty_o <= '1';
   
            end if;
  

         
         when WB_WAIT =>
            -- outputs to the wishbone bus
            dat_o           <= (others => '0');
            ack_o           <= '0';
            rty_o           <= '0'; 
            
            --n_eeprom_cs_o   <= '0';
            
--            if we_i = '1' then  -- we only want to hold the data if it's a WRITE to the EEPROM
--               dat_i_hold      <= dat_i;
--            end if; 
            
         when TX_WB_DATA =>
            -- outputs to the wishbone bus
            if we_i = '1' then
               dat_o           <= (others => '0'); --if it's a write cycle, we don't need to send any data back.
            else
               dat_o           <= rx_eeprom_data_reg_capture;--wb_rx_eeprom_data;--data_capture_parallel;
            end if;
            
            ack_o           <= '1';
            rty_o           <= '0';    
              
            --n_eeprom_cs_o   <= '1'; -- disabled
            
         when others =>
            dat_o           <= (others => '0');
            ack_o           <= '0';
            rty_o           <= '0';
            
            --n_eeprom_cs_o   <= '1'; -- disabled
            
      end case;
   end process;


   process(rst_i, clk_i)
   begin
      if rst_i = '1' then
         wb_current_state <= RESET_SETUP;
      elsif clk_i'event and clk_i = '1' then
         wb_current_state <= wb_next_state;
      end if;
   end process;




------------------------------------------------------------------------
--
-- Instantiate spi interface blocks for SETUP of the EEPROM
--
------------------------------------------------------------------------

setup_tx_rdsr_cmd_spi : write_spi

generic map(DATA_LENGTH => 8)

port map(--inputs
     spi_clk_i        => eeprom_clk,
     rst_i            => rst_i,
     start_i          => setup_tx_rdsr_cmd_start,
     parallel_data_i  => RDSR_CMD,
     
     --outputs
     spi_clk_o        => setup_tx_rdsr_cmd_clk,
     done_o           => setup_tx_rdsr_cmd_done,
     serial_wr_data_o => setup_tx_rdsr_cmd_data);



setup_rx_sr_data_spi : read_spi

generic map(DATA_LENGTH => 8)

port map(--inputs
     spi_clk_i        => eeprom_clk,
     rst_i            => rst_i,
     start_i          => setup_rx_sr_data_start,
     serial_rd_data_i => eeprom_so_i,
       
     --outputs
     spi_clk_o        => setup_rx_sr_data_clk,
     done_o           => setup_rx_sr_data_done,
     parallel_data_o  => setup_rx_sr_data_reg);


   
   sr_setup_value_temp <= (setup_rx_sr_data_reg and "01110011") when current_state = SETUP_RX_SR_DATA; -- set bits 7, 3 & 2 to '0' 
   sr_setup_value      <= (sr_setup_value_temp or "00000010") when current_state = SETUP_RX_SR_DATA; -- set bit 1 to '1' "0xxx001x"
   
            
setup_tx_wrsr_cmd_spi : write_spi

generic map(DATA_LENGTH => 8)

port map(--inputs
     spi_clk_i        => eeprom_clk,
     rst_i            => rst_i,
     start_i          => setup_tx_wrsr_cmd_start,
     parallel_data_i  => WRSR_CMD,
     
     --outputs
     spi_clk_o        => setup_tx_wrsr_cmd_clk,
     done_o           => setup_tx_wrsr_cmd_done,
     serial_wr_data_o => setup_tx_wrsr_cmd_data);    
            

setup_tx_sr_data_spi : write_spi

generic map(DATA_LENGTH => 8)

port map(--inputs
     spi_clk_i        => eeprom_clk,
     rst_i            => rst_i,
     start_i          => setup_tx_sr_data_start,
     parallel_data_i  => sr_setup_value, -- calculated above
     
     --outputs
     spi_clk_o        => setup_tx_sr_data_clk,
     done_o           => setup_tx_sr_data_done,
     serial_wr_data_o => setup_tx_sr_data_reg);    
                 


setup_tx_wren_cmd_spi : write_spi

generic map(DATA_LENGTH => 8)

port map(--inputs
     spi_clk_i        => eeprom_clk,
     rst_i            => rst_i,
     start_i          => setup_tx_wren_cmd_start,
     parallel_data_i  => WREN_CMD,
     
     --outputs
     spi_clk_o        => setup_tx_wren_cmd_clk,
     done_o           => setup_tx_wren_cmd_done,
     serial_wr_data_o => setup_tx_wren_cmd_data);    
                 

------------------------------------------------------------------------
--
-- Instantiate spi interface blocks for READING data from the EEPROM
--
------------------------------------------------------------------------

tx_read_cmd_spi :write_spi

generic map(DATA_LENGTH => 8)

port map(--inputs
     spi_clk_i        => eeprom_clk,
     rst_i            => rst_i,
     start_i          => tx_read_cmd_start,
     parallel_data_i  => READ_CMD,
     
     --outputs
     spi_clk_o        => tx_read_cmd_clk,
     done_o           => tx_read_cmd_done,
     serial_wr_data_o => tx_read_cmd_data);



tx_byte_addr_spi : write_spi

generic map(DATA_LENGTH => 16)

port map(--inputs
     spi_clk_i        => eeprom_clk,
     rst_i            => rst_i,
     start_i          => tx_byte_addr_start,
     parallel_data_i  => tga_i(15 downto 0),
     
     --outputs
     spi_clk_o        => tx_byte_addr_clk,
     done_o           => tx_byte_addr_done,
     serial_wr_data_o => tx_byte_addr_data);
     
     
rx_eeprom_data_spi : read_spi

generic map(DATA_LENGTH => 32)

port map(--inputs
     spi_clk_i        => eeprom_clk,
     rst_i            => rst_i,
     start_i          => rx_eeprom_data_start,
     serial_rd_data_i => eeprom_so_i,
       
     --outputs
     spi_clk_o        => rx_eeprom_data_clk,
     done_o           => rx_eeprom_data_done,
     parallel_data_o  => rx_eeprom_data_reg
     );


------------------------------------------------------------------------
--
-- Instantiate spi interface blocks for WRITING data to the EEPROM
--
------------------------------------------------------------------------

--tx_write_en_cmd_spi : write_spi
--
--generic map(DATA_LENGTH => 8)
--
--port map(--inputs
--     spi_clk_i        => eeprom_clk,
--     rst_i            => rst_i,
--     start_i          => tx_write_en_cmd_start,
--     parallel_data_i  => WREN_CMD,
--     
--     --outputs
--     spi_clk_o        => tx_write_en_cmd_clk,
--     done_o           => tx_write_en_cmd_done,
--     serial_wr_data_o => tx_write_en_cmd_data);
--


tx_write_cmd_spi : write_spi

generic map(DATA_LENGTH => 8)

port map(--inputs
     spi_clk_i        => eeprom_clk,
     rst_i            => rst_i,
     start_i          => tx_write_cmd_start,
     parallel_data_i  => WRITE_CMD,
     
     --outputs
     spi_clk_o        => tx_write_cmd_clk,
     done_o           => tx_write_cmd_done,
     serial_wr_data_o => tx_write_cmd_data);


tx_eeprom_data_spi : write_spi

generic map(DATA_LENGTH => 32)

port map(--inputs
     spi_clk_i        => eeprom_clk,
     rst_i            => rst_i,
     start_i          => tx_eeprom_data_start,
     parallel_data_i  => dat_i_hold,
     
     --outputs
     spi_clk_o        => tx_eeprom_data_clk,
     done_o           => tx_eeprom_data_done,
     serial_wr_data_o => tx_eeprom_data);
     
 
 
 
 
tx_rdsr_cmd_spi : write_spi

generic map(DATA_LENGTH => 8)

port map(--inputs
     spi_clk_i        => eeprom_clk,
     rst_i            => rst_i,
     start_i          => tx_rdsr_cmd_start,
     parallel_data_i  => RDSR_CMD,
     
     --outputs
     spi_clk_o        => tx_rdsr_cmd_clk,
     done_o           => tx_rdsr_cmd_done,
     serial_wr_data_o => tx_rdsr_cmd_data);
     

rx_sr_data_spi : read_spi

generic map(DATA_LENGTH => 8)

port map(--inputs
     spi_clk_i        => eeprom_clk,
     rst_i            => rst_i,
     start_i          => rx_sr_data_start,
     serial_rd_data_i => eeprom_so_i,
       
     --outputs
     spi_clk_o        => rx_sr_data_clk,
     done_o           => rx_sr_data_done,
     parallel_data_o  => rx_sr_data_reg
     );
     
-- this will be useful when rty signal is functional


------------------------------------------------------------------------
--
-- Instantiate nano-second timer
--
------------------------------------------------------------------------

   i_timer_100ns: ns_timer

   port map(clk           => clk_i,
            timer_reset_i => timer_100ns_rst,
            timer_count_o => timer_100ns  );
            
              
end rtl;
