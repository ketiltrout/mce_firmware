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
-- <revision control keyword substitutions e.g. $Id: sram_ctrl.vhd,v 1.4 2004/03/08 21:52:38 erniel Exp $>
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Wishbone to asynch. SRAM chip interface
--
-- Revision history:
-- <date $Date: 2004/03/08 21:52:38 $>	-		<text>		- <initials $Author: erniel $>

--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

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

-- state encodings:
type states is (IDLE, WRITE_LSB, WRITE_MSB, WRITE_DONE, READ_LSB, READ_MSB, SEND_DATA, READ_DONE);

-- state variables:
signal present_state : states;
signal next_state    : states;

-- SRAM controls:
signal ce_ctrl : std_logic;
signal wr_ctrl : std_logic;

-- SRAM data out buffer & controls:
signal read_buf     : std_logic_vector(DATA_WIDTH-1 downto 0);
signal read_lsb_ena : std_logic;
signal read_msb_ena : std_logic;

-- decoded wishbone status signals:
signal wait_state  : std_logic;       -- active during master-initiated wait state
signal read_cycle  : std_logic;       -- active during read cycle
signal write_cycle : std_logic;       -- active during write cycle

begin
   
   -- SRAM output is always enabled (nOE = 0)
   -- SRAM access is always 16 bits (nBHE = nBLE = 0)
   n_ble_o <= '0';
   n_bhe_o <= '0';
   n_oe_o  <= '0';
   
   n_we_o  <= not wr_ctrl;
   n_ce1_o <= not ce_ctrl;
   ce2_o   <= ce_ctrl;

            
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
               reg_o  => read_buf(31 downto 16));
   
   
   -- state machine for writing to SRAM:
   state_FF: process(clk_i)
   begin
      if(rst_i = '1') then
         present_state <= idle;
      elsif(clk_i'event and clk_i = '1') then
         present_state <= next_state;
      end if;
   end process state_FF;
   
   state_NS: process(present_state, read_cycle, write_cycle)
   begin
      case present_state is
         when IDLE =>       if(write_cycle = '1') then
                               next_state <= WRITE_LSB;
                            elsif(read_cycle = '1') then
                               next_state <= READ_LSB;
                            else
                               next_state <= IDLE;
                            end if;
                            
         when WRITE_LSB =>  next_state <= WRITE_MSB;
         
         when WRITE_MSB =>  next_state <= WRITE_DONE;
         
         when WRITE_DONE => if(write_cycle = '1') then
                               next_state <= WRITE_LSB;
                            elsif(wait_state = '1') then
                               next_state <= WRITE_DONE;
                            else
                               next_state <= IDLE;
                            end if;
         
         when READ_LSB =>   next_state <= READ_MSB;
         
         when READ_MSB =>   next_state <= SEND_DATA;
         
         when SEND_DATA =>  next_state <= READ_DONE;
         
         when READ_DONE =>  if(read_cycle = '1') then
                               next_state <= READ_LSB;
                            elsif(wait_state = '1') then
                               next_state <= READ_DONE;
                            else
                               next_state <= IDLE;
                            end if;
         
         when others =>     next_state <= IDLE;
      end case;
   end process state_NS;
   
   state_out: process(present_state)
   begin
      case present_state is
         when IDLE | WRITE_DONE | READ_DONE | SEND_DATA =>       
                            ce_ctrl      <= '0';
                            wr_ctrl      <= '0';
                            addr_o       <= (others => 'Z');
                            data_bi      <= (others => 'Z');
                            read_lsb_ena <= '0';
                            read_msb_ena <= '0';
                                                        
         when WRITE_LSB =>  ce_ctrl      <= '1';
                            wr_ctrl      <= '1';
                            addr_o       <= tga_i(18 downto 0) & '0';
                            data_bi      <= dat_i(15 downto 0);
                            read_lsb_ena <= '0';
                            read_msb_ena <= '0';                            
                                                        
         when WRITE_MSB =>  ce_ctrl      <= '1';
                            wr_ctrl      <= '1';
                            addr_o       <= tga_i(18 downto 0) & '1';
                            data_bi      <= dat_i(31 downto 16);
                            read_lsb_ena <= '0';
                            read_msb_ena <= '0';
                                                        
         when READ_LSB =>   ce_ctrl      <= '1';
                            wr_ctrl      <= '0';
                            addr_o       <= tga_i(18 downto 0) & '0';
                            data_bi      <= (others => 'Z');
                            read_lsb_ena <= '1';
                            read_msb_ena <= '0';
                                                        
         when READ_MSB =>   ce_ctrl      <= '1';
                            wr_ctrl      <= '0';
                            addr_o       <= tga_i(18 downto 0) & '1';
                            data_bi      <= (others => 'Z');
                            read_lsb_ena <= '0';
                            read_msb_ena <= '1';
 
         when others =>     ce_ctrl      <= '0';
                            wr_ctrl      <= '0';
                            addr_o       <= (others => '0');
                            data_bi      <= (others => 'Z');
                            read_lsb_ena <= '0';
                            read_msb_ena <= '0';                            
      end case;
   end process state_out;
   
   
------------------------------------------------------------
--
--  Wishbone section
--
------------------------------------------------------------
   
   -- slave -> master signals:
   ack_o <= '1' when (present_state = WRITE_MSB or present_state = SEND_DATA) else '0';
   rty_o <= '0';  -- never retry
   dat_o <= read_buf when (present_state = SEND_DATA) else (others => 'Z');
   
   -- decoded signals:
   wait_state  <= '1' when (addr_i = SRAM_ADDR and stb_i = '0' and cyc_i = '1') else '0';
   read_cycle  <= '1' when (addr_i = SRAM_ADDR and stb_i = '1' and cyc_i = '1' and we_i = '0') else '0';
   write_cycle <= '1' when (addr_i = SRAM_ADDR and stb_i = '1' and cyc_i = '1' and we_i = '1') else '0'; 
   
end behav;