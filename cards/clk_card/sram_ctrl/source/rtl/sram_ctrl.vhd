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

-- sram_ctrl.vhd
--
-- <revision control keyword substitutions e.g. $Id: sram_ctrl.vhd,v 1.1 2004/03/17 03:12:51 erniel Exp $>
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Wishbone to asynch. SRAM chip interface
--
-- Revision history:
-- <date $Date: 2004/03/17 03:12:51 $>	-		<text>		- <initials $Author: erniel $>
-- $Log$

--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library sys_param;
use sys_param.wishbone_pack.all;

library components;
use components.component_pack.all;


entity sram_ctrl is
generic(ADDR_WIDTH     : integer := WB_ADDR_WIDTH;
        DATA_WIDTH     : integer := WB_DATA_WIDTH;
        TAG_ADDR_WIDTH : integer := WB_TAG_ADDR_WIDTH);
        
port(-- SRAM signals:
     addr_o  : out std_logic_vector(19 downto 0);
     data_bi : inout std_logic_vector(15 downto 0);
     n_ble_o : out std_logic;
     n_bhe_o : out std_logic;
     n_oe_o  : out std_logic;
     n_ce1_o : out std_logic;
     ce2_o   : out std_logic;
     n_we_o  : out std_logic;
     
     -- wishbone signals:
     clk_i   : in std_logic;
     rst_i   : in std_logic;		
     dat_i 	 : in std_logic_vector (DATA_WIDTH-1 downto 0);
     addr_i  : in std_logic_vector (ADDR_WIDTH-1 downto 0);
     tga_i   : in std_logic_vector (TAG_ADDR_WIDTH-1 downto 0);
     we_i    : in std_logic;
     stb_i   : in std_logic;
     cyc_i   : in std_logic;
     dat_o   : out std_logic_vector (DATA_WIDTH-1 downto 0);
     rty_o   : out std_logic;
     ack_o   : out std_logic);     
end sram_ctrl;

architecture behav of sram_ctrl is

-- SRAM controller:
-- State encoding and state variables:
type states is (IDLE, WRITE_LSB, WRITE_MSB, WRITE_DONE, READ_LSB, READ_MSB, SEND_DATA, READ_DONE, TEST_SRAM, SEND_RESULT);
signal present_state : states;
signal next_state    : states;
-- Outputs:
signal ce_ctrl       : std_logic;
signal wr_ctrl       : std_logic;
signal addr          : std_logic_vector(19 downto 0);
signal data          : std_logic_vector(15 downto 0);
signal read_lsb_ena  : std_logic;
signal read_msb_ena  : std_logic;
signal test_mode     : std_logic;
-- Data out buffer:
signal read_buf      : std_logic_vector(DATA_WIDTH-1 downto 0);


-- SRAM verification controller:
-- State encoding and state variables:
type test_states is (TEST_IDLE, SETUP, WR0_UP, RD0_UP, WR1_UP, RD1_DN, WR0_DN, RD0_DN, DONE);
signal present_test_state : test_states;
signal next_test_state    : test_states;
-- Outputs:
signal ce_ctrl_test       : std_logic;
signal wr_ctrl_test       : std_logic;
signal addr_test          : std_logic_vector(19 downto 0);
signal data_test          : std_logic_vector(15 downto 0);
signal step_rst_ctrl      : std_logic;
signal addr_dir_ctrl      : std_logic;
signal test_done          : std_logic;
-- Counters:
signal test_step          : integer range 0 to 6;
signal test_addr          : std_logic_vector(19 downto 0);
signal num_fault          : std_logic_vector(DATA_WIDTH-1 downto 0);


-- Wishbone signals (decoded):
signal master_wait : std_logic;       -- active during master-initiated wait state
signal read_cmd    : std_logic;       -- indicates read command received
signal write_cmd   : std_logic;       -- indicates write command received
signal test_cmd    : std_logic;       -- indicates test command received

begin

------------------------------------------------------------
--
--  SRAM controller (in normal operating mode)
--
------------------------------------------------------------   
   
   -- state machine for controlling SRAM:
   state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         present_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         present_state <= next_state;
      end if;
   end process state_FF;
   
   
   state_NS: process(present_state, master_wait, read_cmd, write_cmd, test_cmd, test_done)
   begin
      case present_state is
         when IDLE =>        if(write_cmd = '1') then
                                next_state <= WRITE_LSB;
                             elsif(read_cmd = '1') then
                                next_state <= READ_LSB;
                             elsif(test_cmd = '1' and test_done = '0') then
                                next_state <= TEST_SRAM;
                             elsif(test_cmd = '1' and test_done = '1') then
                                next_state <= SEND_RESULT;
                             else
                                next_state <= IDLE;
                             end if;
                            
         when WRITE_LSB =>   next_state <= WRITE_MSB;
         
         when WRITE_MSB =>   next_state <= WRITE_DONE;
         
         when WRITE_DONE =>  if(write_cmd = '1') then
                                next_state <= WRITE_LSB;
                             elsif(master_wait = '1') then
                                next_state <= WRITE_DONE;
                             else
                                next_state <= IDLE;
                             end if;
         
         when READ_LSB =>    next_state <= READ_MSB;
         
         when READ_MSB =>    next_state <= SEND_DATA;
         
         when SEND_DATA =>   next_state <= READ_DONE;
         
         when READ_DONE =>   if(read_cmd = '1') then
                                next_state <= READ_LSB;
                             elsif(master_wait = '1') then
                                next_state <= READ_DONE;
                             else
                                next_state <= IDLE;
                             end if;
               
         when TEST_SRAM =>   if(test_done = '1') then
                                next_state <= IDLE;
                             else
                                next_state <= TEST_SRAM;
                             end if;
         
         when SEND_RESULT => next_state <= IDLE;

      end case;
   end process state_NS;
   
   
   state_out: process(present_state, tga_i, dat_i)
   begin
      case present_state is
         when IDLE | WRITE_DONE | READ_DONE | SEND_DATA | SEND_RESULT =>       
                            ce_ctrl      <= '0';
                            wr_ctrl      <= '0';
                            addr         <= (others => 'Z');
                            data         <= (others => 'Z');
                            read_lsb_ena <= '0';
                            read_msb_ena <= '0';
                            test_mode    <= '0';
                
         when WRITE_LSB =>  ce_ctrl      <= '1';
                            wr_ctrl      <= '1';
                            addr         <= tga_i(18 downto 0) & '0';
                            data         <= dat_i(15 downto 0);
                            read_lsb_ena <= '0';
                            read_msb_ena <= '0';
                            test_mode    <= '0';                           
                         
         when WRITE_MSB =>  ce_ctrl      <= '1';
                            wr_ctrl      <= '1';
                            addr         <= tga_i(18 downto 0) & '1';
                            data         <= dat_i(31 downto 16);
                            read_lsb_ena <= '0';
                            read_msb_ena <= '0';
                            test_mode    <= '0';
                                                      
         when READ_LSB =>   ce_ctrl      <= '1';
                            wr_ctrl      <= '0';
                            addr         <= tga_i(18 downto 0) & '0';
                            data         <= (others => 'Z');
                            read_lsb_ena <= '1';
                            read_msb_ena <= '0';
                            test_mode    <= '0';
                                                       
         when READ_MSB =>   ce_ctrl      <= '1';
                            wr_ctrl      <= '0';
                            addr         <= tga_i(18 downto 0) & '1';
                            data         <= (others => 'Z');
                            read_lsb_ena <= '0';
                            read_msb_ena <= '1';
                            test_mode    <= '0';
                                                        
         when TEST_SRAM =>  ce_ctrl      <= '0';
                            wr_ctrl      <= '0';
                            addr         <= (others => '0');
                            data         <= (others => '0');
                            read_lsb_ena <= '0';
                            read_msb_ena <= '0';
                            test_mode    <= '1';
          
      end case;
   end process state_out;
   
         
   -- data output is always enabled (nOE = 0)
   -- data access is always 16 bits (nBHE = nBLE = 0)
   -- other control signals are multiplexed with verification controller
   n_ble_o <= '0';
   n_bhe_o <= '0';
   n_oe_o  <= '0';
   n_we_o  <= not wr_ctrl when test_mode = '0' else not wr_ctrl_test;
   n_ce1_o <= not ce_ctrl when test_mode = '0' else not ce_ctrl_test;
   ce2_o   <= ce_ctrl     when test_mode = '0' else ce_ctrl_test;
   addr_o  <= addr        when test_mode = '0' else addr_test;
   data_bi <= data        when test_mode = '0' else data_test;
   
   
   -- buffer SRAM data out:
   read_data_lsb: reg
      generic map(WIDTH => 16)
      port map(clk_i  => clk_i,
               rst_i  => rst_i,
               ena_i  => read_lsb_ena,
               reg_i  => data_bi,
               reg_o  => read_buf(15 downto 0));
   
   read_data_msb: reg
      generic map(WIDTH => 16)
      port map(clk_i  => clk_i,
               rst_i  => rst_i,
               ena_i  => read_msb_ena,
               reg_i  => data_bi,
               reg_o  => read_buf(DATA_WIDTH-1 downto 16));
               
              
------------------------------------------------------------
--
--  SRAM controller (in verification mode)
--
------------------------------------------------------------
   
   --
   -- Using MATS++ algorithm for SRAM testing:
   --
   -- 1. (WR0_UP step) Write 0 to all cells, address increasing
   -- 2. (RD0_UP step) Read 0 from all cells, address increasing
   -- 3. (WR1_UP step) Write 1 to all cells, address increasing
   -- 4. (RD1_DN step) Read 1 from all cells, address decreasing
   -- 5. (WR0_DN step) Write 0 to all cells, address decreasing
   -- 6. (RD0_DN step) Read 0 from all cells, address decreasing
   --
   
   -- state machine for verifying SRAM:
   test_state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         present_test_state <= TEST_IDLE;
      elsif(clk_i'event and clk_i = '1') then
         present_test_state <= next_test_state;
      end if;
   end process test_state_FF;
   
   
   test_state_NS: process(present_test_state, test_cmd, test_step, test_addr)
   begin
      case present_test_state is
         when TEST_IDLE => if(test_cmd = '1') then
                              next_test_state <= SETUP;
                           else
                              next_test_state <= TEST_IDLE;
                           end if;
                            
         when SETUP =>     case test_step is
                              when 0 =>      next_test_state <= WR0_UP;
                              when 1 =>      next_test_state <= RD0_UP;
                              when 2 =>      next_test_state <= WR1_UP;
                              when 3 =>      next_test_state <= RD1_DN;
                              when 4 =>      next_test_state <= WR0_DN;
                              when others => next_test_state <= RD0_DN;
                           end case;
                                   
         when WR0_UP =>    if(test_addr = "11111111111111111111") then
                              next_test_state <= SETUP;
                           else
                              next_test_state <= WR0_UP;
                           end if;
         
         when RD0_UP =>    if(test_addr = "11111111111111111111") then
                              next_test_state <= SETUP;
                           else
                              next_test_state <= RD0_UP;
                           end if;
                                                   
         when WR1_UP =>    if(test_addr = "11111111111111111111") then
                              next_test_state <= SETUP;
                           else
                              next_test_state <= WR1_UP;
                           end if;
         
         when RD1_DN =>    if(test_addr = "00000000000000000000") then
                              next_test_state <= SETUP;
                           else
                              next_test_state <= RD1_DN;
                           end if;
                              
         when WR0_DN =>    if(test_addr = "00000000000000000000") then
                              next_test_state <= SETUP;
                           else
                              next_test_state <= WR0_DN;
                           end if;
                                       
         when RD0_DN =>    if(test_addr = "00000000000000000000") then
                              next_test_state <= DONE;
                           else
                              next_test_state <= RD0_DN;
                           end if;
         
         -- after SRAM is verified, verification controller stays in done state until next system reset.
         when DONE =>      next_test_state <= DONE;

      end case;
   end process test_state_NS;
   
   
   test_state_out: process(present_test_state, test_step, test_addr)
   begin
      case present_test_state is
         when TEST_IDLE => ce_ctrl_test   <= '0';
                           wr_ctrl_test   <= '0';
                           addr_test      <= (others => 'Z');
                           data_test      <= (others => 'Z');
                           step_rst_ctrl  <= '0';
                           addr_dir_ctrl  <= '0';
                           test_done      <= '0';
                           
         when SETUP =>     ce_ctrl_test   <= '0';
                           wr_ctrl_test   <= '0';
                           addr_test      <= (others => 'Z');
                           data_test      <= (others => 'Z');
                           step_rst_ctrl  <= '1';
                           if(test_step < 3) then
                              addr_dir_ctrl <= '1';
                           else
                              addr_dir_ctrl <= '0';
                           end if;
                           test_done      <= '0';
                                                     
         when WR0_UP =>    ce_ctrl_test   <= '1';
                           wr_ctrl_test   <= '1';
                           addr_test      <= test_addr;
                           data_test      <= (others => '0');
                           step_rst_ctrl  <= '0';
                           addr_dir_ctrl  <= '1';
                           test_done      <= '0';
                           
         when RD0_UP =>    ce_ctrl_test   <= '1';
                           wr_ctrl_test   <= '0';
                           addr_test      <= test_addr;
                           data_test      <= (others => 'Z');
                           step_rst_ctrl  <= '0';
                           addr_dir_ctrl  <= '1';
                           test_done      <= '0';
                            
         when WR1_UP =>    ce_ctrl_test   <= '1';
                           wr_ctrl_test   <= '1';
                           addr_test      <= test_addr;
                           data_test      <= (others => '1');
                           step_rst_ctrl  <= '0';
                           addr_dir_ctrl  <= '1';
                           test_done      <= '0';
         
         when RD1_DN =>    ce_ctrl_test   <= '1';
                           wr_ctrl_test   <= '0';
                           addr_test      <= test_addr;
                           data_test      <= (others => 'Z');
                           step_rst_ctrl  <= '0';
                           addr_dir_ctrl  <= '0';
                           test_done      <= '0';
         
         when WR0_DN =>    ce_ctrl_test   <= '1';
                           wr_ctrl_test   <= '1';
                           addr_test      <= test_addr;
                           data_test      <= (others => '0');
                           step_rst_ctrl  <= '0';
                           addr_dir_ctrl  <= '0';
                           test_done      <= '0';
         
         when RD0_DN =>    ce_ctrl_test   <= '1';
                           wr_ctrl_test   <= '0';
                           addr_test      <= test_addr;
                           data_test      <= (others => 'Z');
                           step_rst_ctrl  <= '0';
                           addr_dir_ctrl  <= '0';
                           test_done      <= '0';
                            
         when DONE =>      ce_ctrl_test   <= '0';
                           wr_ctrl_test   <= '0';
                           addr_test      <= (others => 'Z');
                           data_test      <= (others => 'Z');
                           step_rst_ctrl  <= '0';
                           addr_dir_ctrl  <= '0';
                           test_done      <= '1';

      end case;
   end process test_state_out;
   
     
   -- counter to keep track of current test step:
   step_counter: process(rst_i, clk_i)
   begin
      if(rst_i = '1') then
         test_step <= 0;
      elsif(clk_i'event and clk_i = '1') then
         if(step_rst_ctrl = '1') then               -- at start of a test step, increment step count
            test_step <= test_step + 1;
         end if;
      end if;
   end process step_counter;
   
   
   -- address generator:
   -- if dir = 1, address increasing.  if dir = 0, address decreasing.
   addr_gen: process(clk_i)
   begin
      if(clk_i'event and clk_i = '1') then
         if(test_done = '0') then                   -- enable address generator only during test mode
            if(step_rst_ctrl = '1') then            -- at the start of a test step, reset address
               if(addr_dir_ctrl = '1') then
                  test_addr <= (others => '0');
               else
                  test_addr <= (others => '1');
               end if;
            else                                    -- otherwise increment (or decrement) address
               if(addr_dir_ctrl = '1') then
                  test_addr <= test_addr + 1;
               else
                  test_addr <= test_addr - 1;
               end if;
            end if;
         end if;
      end if;
   end process addr_gen; 
      
   
   -- detect data faults:
   fault_counter: process(rst_i, clk_i)
   begin
      if(rst_i = '1') then
         num_fault <= (others => '0');
      elsif(clk_i'event and clk_i = '1') then
         if((present_test_state = RD0_UP and not (data_bi = "0000000000000000")) or
            (present_test_state = RD1_DN and not (data_bi = "1111111111111111")) or 
            (present_test_state = RD0_DN and not (data_bi = "0000000000000000"))) then
            num_fault <= num_fault + 1;
         end if;
      end if;
   end process fault_counter;
   
   
------------------------------------------------------------
--
--  Wishbone interface 
--
------------------------------------------------------------
   
   -- assert ack_o when:
   --    1. wishbone data is written to SRAM
   --    2. SRAM data is ready to be read
   --    3. test result is ready to be read
   ack_o <= '1' when (present_state = WRITE_MSB or present_state = SEND_DATA or present_state = SEND_RESULT) else '0';
                      
   -- assert rty_o when in test mode
   rty_o <= '1' when (present_state = TEST_SRAM) else '0';
   
   -- dat_o is:
   --    1. (read buffer data out) during read command
   --    2. (number of faults detected) during test command 
   dat_o <= read_buf  when (present_state = SEND_DATA) else 
            num_fault when (present_state = SEND_RESULT) else (others => '0');
   
   -- decoded signals:
   master_wait <= '1' when (addr_i = SRAM_ADDR and stb_i = '0' and cyc_i = '1') else '0';   
   read_cmd    <= '1' when (addr_i = SRAM_ADDR and stb_i = '1' and cyc_i = '1' and we_i = '0') else '0';
   write_cmd   <= '1' when (addr_i = SRAM_ADDR and stb_i = '1' and cyc_i = '1' and we_i = '1') else '0'; 

   test_cmd    <= '1' when (addr_i = SRAM_VERIFY_ADDR and stb_i = '1' and cyc_i = '1') else '0';  
     
end behav;