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
-- <revision control keyword substitutions e.g. $Id: eeprom_ctrl.vhd,v 1.1 2004/03/05 22:38:35 jjacob Exp $>
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
-- <date $Date: 2004/03/05 22:38:35 $>	-		<text>		- <initials $Author: jjacob $>

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

generic(--EEPROM_CTRL_DATA_WIDTH         : integer := EEPROM_CTRL_DATA_WIDTH;
        --EEPROM_CTRL_ADDR_WIDTH         : integer := EEPROM_CTRL_ADDR_WIDTH;   
        EEPROM_CTRL_ADDR               : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := EEPROM_ADDR  );

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
end eeprom_ctrl;


architecture rtl of eeprom_ctrl is


-- declare this in component pack!!!
--   component ns_timer
--
--      port (clk           : in std_logic;
--           timer_reset_i : in std_logic;
--           timer_count_o : out integer  );
--
--   end component;
--
--   component shift_reg
--      generic(WIDTH : in integer range 2 to 512 := 8);
--
--      port(clk        : in std_logic;
--           rst        : in std_logic;
--           ena        : in std_logic;
--           load       : in std_logic;
--           clr        : in std_logic;
--           shr        : in std_logic;
--           serial_i   : in std_logic;
--           serial_o   : out std_logic;
--           parallel_i : in std_logic_vector(WIDTH-1 downto 0);
--           parallel_o : out std_logic_vector(WIDTH-1 downto 0));
--   end component;

-- controller states:
constant IDLE              : std_logic_vector(2 downto 0) := "000";
constant TX_READ_CMD   : std_logic_vector(2 downto 0) := "001";
constant TX_WRITE_CMD    : std_logic_vector(2 downto 0) := "010";
constant TX_BYTE_ADDR    : std_logic_vector(2 downto 0) := "011";
constant READ  : std_logic_vector(2 downto 0) := "100";
constant TX_WB_DATA  : std_logic_vector(2 downto 0) := "101";
constant WB_WAIT       : std_logic_vector(2 downto 0) := "110";
constant DONE         : std_logic_vector(2 downto 0) := "111";

constant TIME_100NS      : integer := 100;
constant TIME_200NS      : integer := 200;

signal READ_EEPROM_CMD : std_logic_vector(7 downto 0) := "00000011"; -- 0x03

-- controller state variables:
signal current_state : std_logic_vector(2 downto 0);
signal next_state    : std_logic_vector(2 downto 0);
signal previous_state: std_logic_vector(2 downto 0);

signal wb_current_state : std_logic_vector(2 downto 0);
signal wb_next_state    : std_logic_vector(2 downto 0);

-- FSM start/done signals:
signal tx_read_cmd_start        : std_logic;
signal tx_read_cmd_done     : std_logic;
signal rx_eeprom_data_start : std_logic;
signal rx_eeprom_data_done : std_logic;
--signal tx_read_cmd   : std_logic;
--signal eeprom_rx_data         : std_logic_vector(EEPROM_CTRL_DATA_WIDTH-1 downto 0); -- use 32 bits for now, needs to somehow be variable size in the future


-- WB slave interface:
signal eeprom_ctrl_wr_ready : std_logic;
signal eeprom_ctrl_rd_ready : std_logic;
signal eeprom_ctrl_dat_i    : std_logic_vector (WB_DATA_WIDTH-1 downto 0);  -- input from WB (dummy signal)
signal eeprom_ctrl_dat_o    : std_logic_vector (WB_DATA_WIDTH-1 downto 0);  -- output to WB


-- nano-second timer control signals
signal timer_100ns_rst      : std_logic;
signal timer_100ns          : integer;
signal timer_200ns_rst      : std_logic;
signal timer_200ns          : integer;

signal eeprom_clk           : std_logic;
signal n_eeprom_clk         : std_logic;
signal run_eeprom_clk       : std_logic;
signal eeprom_done          : std_logic;


-- shift register signals
signal instr_shift_en       : std_logic;
signal load           : std_logic;
signal shl                  : std_logic;
signal instr                : std_logic_vector(7 downto 0);
signal instr_bit            : std_logic;
signal zero			    : std_logic;
signal instr_clr            : std_logic;
signal byte_addr_shift_en   : std_logic;
signal byte_addr_clr        : std_logic;
signal byte_addr            : std_logic;



signal data_capture_parallel  : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal data_capture_serial    : std_logic;
signal data_capture_shift_en  : std_logic;
signal data_capture_clr       : std_logic;
signal shr                    : std_logic;

signal zero_vector            : std_logic_vector(WB_DATA_WIDTH-1 downto 0);

signal instr_bit_count      : integer;
signal byte_addr_count      : integer;
signal bit_count            : integer;


-- signals for the counter
signal reset_counter        : std_logic;
signal count                : integer;

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
-- generate the eeprom clock w/ ~200ns period combinatorially from the
-- system clk
--
------------------------------------------------------------------------
   
   process(rst_i, clk_i)
   begin
   
      timer_100ns_rst <= '0';
   
      if rst_i = '1' then
         eeprom_clk <= '0';
         timer_100ns_rst <= '1';
      elsif clk_i'event and clk_i = '1' then
         --if run_eeprom_clk = '1' then
            if timer_100ns >= TIME_100NS then  -- this is actually 120ns period!!!!
               eeprom_clk <= not(eeprom_clk);
               timer_100ns_rst <= '1';
            end if;
         --end if;
      end if;
   end process;
   
   -- clock going to the eeprom
   eeprom_clk_o <= eeprom_clk when run_eeprom_clk = '1' else '0';
   
   -- phase shifted clock for the eeprom state machine logic
   n_eeprom_clk <= not(eeprom_clk);
 
------------------------------------------------------------------------
--
-- State sequencer, based on a 200ns phase shifted clock that is
-- generated COMBINATORIALLY
--
------------------------------------------------------------------------   
 
   process(rst_i, n_eeprom_clk)
   begin
   
      if rst_i = '1' then
         current_state <= IDLE;
      elsif n_eeprom_clk'event and n_eeprom_clk = '1' then
         current_state <= next_state;
         previous_state <= current_state;
      end if; 
   end process;
   
   timer_200ns_rst <= rst_i; --keep counter running unless system reset
   
------------------------------------------------------------------------
--
-- State machine between eeprom
-- controller and the eeprom
--
------------------------------------------------------------------------  

   process(current_state, we_i, count, addr_i, cyc_i, stb_i)
   begin

      case current_state is
         when IDLE =>
            if addr_i = EEPROM_CTRL_ADDR and cyc_i = '1' and stb_i = '1' then
               if we_i = '0' then -- indicates a READ
                  next_state <= TX_READ_CMD;
               else
                  next_state <= TX_WRITE_CMD; -- details need to be figured out still
               end if;
            else  
               next_state <= IDLE;
            end if;
            
         when TX_READ_CMD =>
            if count >= 7 then
               
               next_state <= TX_BYTE_ADDR;
            else
               next_state <= TX_READ_CMD;
            end if;
            
         when TX_BYTE_ADDR =>
            if count >= 7 then
               next_state <= READ;
            else
               next_state <= TX_BYTE_ADDR;
            end if;
            
         when READ =>
            if count >= 31 then
               next_state <= DONE;--TX_WB_DATA;
            else
               next_state <= READ;
            end if;
      
--         when TX_WB_DATA =>
--            next_state <= DONE;
            
         when DONE =>
            next_state <= IDLE;
            
         when others =>
            next_state <= IDLE;
            
      end case;
   end process;
            


-- add functionality of rty!!!!!
            
   process(current_state, we_i, instr_bit, byte_addr, eeprom_so_i, count ) -- count only blips up, fix this!!!! Separate into new process?
   begin
   
      instr_clr       <= '0';
      byte_addr_clr   <= '0';
   
      case current_state is
         when IDLE =>
            --n_eeprom_cs_o   <= '1'; -- disabled in IDLE
            n_eeprom_hold_o <= '1';
            n_eeprom_wp_o   <= '0';
            eeprom_si_o     <= '0';
            
            run_eeprom_clk  <= '0';
           
            instr_bit_count <= 0;
            byte_addr_count <= 0;
            bit_count       <= 0;
            
            -- outputs to the wishbone bus
            --dat_o           <= (others => '0');
            --ack_o           <= '0';
            --rty_o           <= '0';
            
            eeprom_done     <= '0';
            instr_shift_en  <= '1';
            load            <= '1';
            
            byte_addr_shift_en  <= '1';
            data_capture_shift_en <= '1';

            if we_i = '0' then -- indicates a READ
               instr <= READ_EEPROM_CMD;
            else
               instr <= (others => '0'); -- CHANGE THIS to an actual instruction!!
            end if;
            
            reset_counter <= '1';

            
         when TX_READ_CMD =>
            
            --n_eeprom_cs_o   <= '0';
            n_eeprom_hold_o <= '1';
            n_eeprom_wp_o   <= '0';
            eeprom_si_o     <= instr_bit;--READ_EEPROM_CMD(instr_bit_count-1);
            --eeprom_clk_o    <= '0';
            
            run_eeprom_clk  <= '1'; -- this is the 200ns period clock going out to the eeprom
            instr_shift_en  <= '1';
            byte_addr_shift_en <= '0';
            data_capture_shift_en <= '0';
            
--            if count >= 8 then
--               reset_counter <= '1';
--            else
--               reset_counter <= '0';
--            end if;

            reset_counter <= '0';
            load      <= '0';
            
         when TX_BYTE_ADDR =>
         
            if count >= 8 then
               reset_counter <= '1';
            else
               reset_counter <= '0';
            end if;
         
            --n_eeprom_cs_o   <= '0';
            n_eeprom_hold_o <= '1';
            n_eeprom_wp_o   <= '0';
            eeprom_si_o     <= byte_addr;
            --eeprom_clk_o    <= '0';
            
            run_eeprom_clk  <= '1'; -- this is the 200ns period clock going out to the eeprom
            instr_shift_en  <= '0';
            byte_addr_shift_en <= '1';
            data_capture_shift_en <= '0';
            load      <= '0';
            --byte_addr_count <= byte_addr_count - 1;
            
--            if count >= 8 then
--               reset_counter <= '1';
--            else
--               reset_counter <= '0';
--            end if;
            
         when READ =>

            if count >= 8 and previous_state = TX_BYTE_ADDR then
               reset_counter <= '1';
            else
               reset_counter <= '0';
            end if;
            
            --n_eeprom_cs_o   <= '0';
            n_eeprom_hold_o <= '1';
            n_eeprom_wp_o   <= '0';
            eeprom_si_o     <= '0';--(others => '0');
            --eeprom_clk_o    <= '0';
            
            run_eeprom_clk  <= '1'; -- this is the 200ns period clock going out to the eeprom
            
            data_capture_serial <= eeprom_so_i;
           
            
            instr_shift_en  <= '0';
            byte_addr_shift_en <= '0';
            data_capture_shift_en <= '1';
            load      <= '0';
            
--            if count >= 32 then
--               reset_counter <= '1';
--            else
--               reset_counter <= '0';
--            end if;
-- 

    
         when DONE =>
            --n_eeprom_cs_o   <= '0';
            n_eeprom_hold_o <= '1';
            n_eeprom_wp_o   <= '0';
            eeprom_si_o     <= '0';
            --eeprom_clk_o    <= '0';
            
            run_eeprom_clk  <= '0'; -- check this!!  need to disable clk first, then the cs
            
            eeprom_done     <= '1';
            instr_shift_en  <= '0';
            byte_addr_shift_en <= '0';
            data_capture_shift_en <= '0';
            load      <= '0';
            instr_clr       <= '1';
            
            reset_counter <= '1';
            
         when others =>
            --n_eeprom_cs_o   <= '0';
            n_eeprom_hold_o <= '1';
            n_eeprom_wp_o   <= '0';
            eeprom_si_o     <= '0';
            --eeprom_clk_o    <= '0';
            
            run_eeprom_clk  <= '0'; -- check this!!  need to disable clk first, then the cs
            
            -- outputs to the wishbone bus
            --dat_o           <= (others => '0');
            --ack_o           <= '0';
            --rty_o           <= '0';
            
            eeprom_done     <= '0';  
            instr_shift_en  <= '0';  
            byte_addr_shift_en <= '0';
            data_capture_shift_en <= '0';
            load      <= '0';
            instr_clr       <= '1';
            reset_counter   <= '1';
             
      end case;
   end process;      


------------------------------------------------------------------------
--
-- Counter for the EEPROM state machine, running off the slow clock
--
------------------------------------------------------------------------  
   process(reset_counter, n_eeprom_clk)
   begin
      if reset_counter = '1' then
         count <= 0;
      elsif n_eeprom_clk'event and n_eeprom_clk = '1' then
         count <= count + 1;
      end if;
   end process;


           
------------------------------------------------------------------------
--
-- State machine between eeprom controller and wishbone bus
-- This state machine runs at the same clock speed as the wishbone bus
--
------------------------------------------------------------------------  

   process(wb_current_state, eeprom_done, addr_i, cyc_i, stb_i)
   begin
      case wb_current_state is
         when IDLE =>
         
            if addr_i = EEPROM_CTRL_ADDR and cyc_i = '1' and stb_i = '1' then
               wb_next_state <= WB_WAIT;
            else
               wb_next_state <= IDLE;
            end if;         
         
         when WB_WAIT =>
            if eeprom_done = '1' then  -- careful it doesn't transmit over and over again
               wb_next_state <= TX_WB_DATA;
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

   process(wb_current_state)
   begin
   
      zero <= '0';
   
      case wb_current_state is
         when IDLE =>
            -- outputs to the wishbone bus
            dat_o           <= (others => '0');
            ack_o           <= '0';
            rty_o           <= '0';
            
            
            n_eeprom_cs_o   <= '1'; -- disabled in IDLE  
         
         when WB_WAIT =>
            -- outputs to the wishbone bus
            dat_o           <= (others => '0');
            ack_o           <= '0';
            rty_o           <= '0'; 
            
            --run_eeprom_clk  <= '1';
            n_eeprom_cs_o   <= '0';        
            
         when TX_WB_DATA =>
            -- outputs to the wishbone bus
            dat_o           <= data_capture_parallel;
            ack_o           <= '1';
            rty_o           <= '0';    
            
            --run_eeprom_clk  <= '0';        
            n_eeprom_cs_o   <= '1'; -- disabled
            
         when others =>
            dat_o           <= (others => '0');
            ack_o           <= '0';
            rty_o           <= '0';
            
            --run_eeprom_clk  <= '0';
            n_eeprom_cs_o   <= '1'; -- disabled
            
      end case;
   end process;


   process(rst_i, clk_i)
   begin
      if rst_i = '1' then
         wb_current_state <= IDLE;
      elsif clk_i'event and clk_i = '1' then
         wb_current_state <= wb_next_state;
      end if;
   end process;

------------------------------------------------------------------------
--
-- Instantiate nano-second timers
--
------------------------------------------------------------------------



   i_timer_200ns: ns_timer

   port map(clk           => clk_i,
            timer_reset_i => timer_200ns_rst,
            timer_count_o => timer_200ns  );

   i_timer_100ns: ns_timer

   port map(clk           => clk_i,
            timer_reset_i => timer_100ns_rst,
            timer_count_o => timer_100ns  );


------------------------------------------------------------------------
--
-- Instantiate shift registers
--
------------------------------------------------------------------------

   shl <= '0';
   shr <= '1';
   zero_vector <= (others => '0');
   
   instr_shift : shift_reg
   
   generic map (WIDTH => 8)
   port map(clk      => n_eeprom_clk,
        rst          => rst_i,
        ena          => instr_shift_en,
        load         => load,
        clr          => instr_clr,
        shr          => shl, -- '0'
        serial_i     => zero,
        serial_o     => instr_bit,
        parallel_i   => instr,
        parallel_o   => open);


   byte_addr_shift : shift_reg
   
   generic map (WIDTH => 8)
   port map(clk      => n_eeprom_clk,
        rst          => rst_i,
        ena          => byte_addr_shift_en,
        load         => load,
        clr          => byte_addr_clr,
        shr          => shl, -- '0'
        serial_i     => zero,
        serial_o     => byte_addr,
        parallel_i   => tga_i(7 downto 0),
        parallel_o   => open);

   data_capture : shift_reg
   
   generic map (WIDTH => 32)
   port map(clk      => n_eeprom_clk,
        rst          => rst_i,
        ena          => data_capture_shift_en,
        load         => load,
        clr          => data_capture_clr,
        shr          => shl, -- '0'
        serial_i     => data_capture_serial,
        serial_o     => open,
        parallel_i   => zero_vector,
        parallel_o   => data_capture_parallel);   
              
end rtl;
