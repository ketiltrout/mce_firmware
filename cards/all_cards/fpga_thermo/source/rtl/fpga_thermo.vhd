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
-- fpga_thermo.vhd
--
-- Project:	      SCUBA-2
-- Author:        Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Implements the controller for the SMBus temperature sensor
--
-- Revision history:
-- 
-- $Log$
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library components;
use components.component_pack.all;

library sys_param;
use sys_param.wishbone_pack.all;

entity fpga_thermo is
port(clk_i : in std_logic;
     rst_i : in std_logic;

     -- wishbone signals
     dat_i 	 : in std_logic_vector (WB_DATA_WIDTH-1 downto 0); 
     addr_i  : in std_logic_vector (WB_ADDR_WIDTH-1 downto 0);
     tga_i   : in std_logic_vector (WB_TAG_ADDR_WIDTH-1 downto 0);
     we_i    : in std_logic;
     stb_i   : in std_logic;
     cyc_i   : in std_logic;
     dat_o   : out std_logic_vector (WB_DATA_WIDTH-1 downto 0);
     ack_o   : out std_logic;
     
     -- SMBus temperature sensor signals
     smbclk_o : out std_logic;
     smbdat_io : inout std_logic);
end fpga_thermo;

architecture rtl of fpga_thermo is

-- smbus master interface:
signal slave_data_in  : std_logic_vector(7 downto 0);
signal slave_data_out : std_logic_vector(7 downto 0);
signal slave_start    : std_logic;
signal slave_stop     : std_logic;
signal slave_write    : std_logic;
signal slave_read     : std_logic;
signal slave_done     : std_logic;
signal slave_err      : std_logic;

-- controller FSM states:
type states is (CTRL_IDLE, SEND_START, SEND_ADDR, GET_TEMP, SEND_STOP, SET_VALID_FLAG);
signal ctrl_ps : states;
signal ctrl_ns : states;

-- wishbone FSM states:
type wb_states is (WB_IDLE, SEND_TEMP);
signal wb_ps : wb_states;
signal wb_ns : wb_states;

signal read_temp_cmd : std_logic;

-- temperature data register and valid flag:
signal thermo    : std_logic_vector(7 downto 0);
signal valid     : std_logic;

signal thermo_ld : std_logic;
signal valid_ld  : std_logic;

begin

   master : smb_master
   port map(clk_i         => clk_i,
            rst_i         => rst_i,
            master_data_i => slave_data_in,
            master_data_o => slave_data_out,
            start_i       => slave_start,
            stop_i        => slave_stop,
            write_i       => slave_write,
            read_i        => slave_read,
            done_o        => slave_done,
            error_o       => slave_err,
            slave_clk_o   => smbclk_o,
            slave_data_io => smbdat_io);

   -- Temperature register
   
   thermo_data : reg
   generic map(WIDTH => 8)
   port map(clk_i => clk_i,
            rst_i => rst_i,
            ena_i => thermo_ld,
            reg_i => slave_data_out,
            reg_o => thermo);
   
   -- Valid flag
   
   valid_flag: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         valid <= '0';
      elsif(clk_i'event and clk_i = '1') then
         if(valid_ld = '1') then
            valid <= '1';
         end if;
      end if;
   end process valid_flag;
   
   
   -- Controller FSM
   
   control_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         ctrl_ps <= CTRL_IDLE;
      elsif(clk_i'event and clk_i = '1') then
         ctrl_ps <= ctrl_ns;
      end if;
   end process control_FF;

   control_NS: process(ctrl_ps, slave_done, slave_err)
   begin
      case ctrl_ps is
         when CTRL_IDLE =>      ctrl_ns <= SEND_START;

         when SEND_START =>     if(slave_done = '1') then
                                   ctrl_ns <= SEND_ADDR;
                                else
                                   ctrl_ns <= SEND_START;
                                end if;

         when SEND_ADDR =>      if(slave_done = '1' and slave_err = '0') then
                                   ctrl_ns <= GET_TEMP;
                                elsif(slave_done = '1' and slave_err = '1') then
                                   ctrl_ns <= SEND_STOP;
                                else
                                   ctrl_ns <= SEND_ADDR;
                                end if;

         when GET_TEMP =>       if(slave_done = '1') then
                                   ctrl_ns <= SEND_STOP;
                                else
                                   ctrl_ns <= GET_TEMP;
                                end if;

         when SEND_STOP =>      if(slave_done = '1') then
                                   ctrl_ns <= SET_VALID_FLAG;
                                else
                                   ctrl_ns <= SEND_STOP;
                                end if;

         when SET_VALID_FLAG => ctrl_ns <= CTRL_IDLE;

         when others =>         ctrl_ns <= CTRL_IDLE;
      end case;
   end process control_NS;

   control_out: process(ctrl_ps, slave_done)
   begin
      slave_start   <= '0';
      slave_stop    <= '0';
      slave_write   <= '0';
      slave_read    <= '0';
      slave_data_in <= (others => '0');
      
      thermo_ld <= '0';
      valid_ld  <= '0';
      
      case ctrl_ps is
         when CTRL_IDLE =>      null;

         when SEND_START =>     slave_start <= '1';

         when SEND_ADDR =>      slave_write   <= '1';
                                slave_data_in <= "00110001";    -- default smb sensor address is 0011000, and read flag (1)

         when GET_TEMP =>       slave_read <= '1';
                                if(slave_done = '1') then
                                   thermo_ld <= '1';
                                end if;

         when SEND_STOP =>      slave_stop <= '1';

         when SET_VALID_FLAG => valid_ld <= '1';

         when others =>         null;
      end case;
   end process control_out;


   -- Wishbone FSM
   
   wishbone_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         wb_ps <= WB_IDLE;
      elsif(clk_i'event and clk_i = '1') then
         wb_ps <= wb_ns;
      end if;
   end process wishbone_FF;

   wishbone_NS: process(wb_ps, read_temp_cmd, valid)
   begin
      case wb_ps is
         when WB_IDLE =>   if(read_temp_cmd = '1') then
                              wb_ns <= SEND_TEMP;
                           else
                              wb_ns <= WB_IDLE;
                           end if;
                           
         when SEND_TEMP => if(valid = '1') then
                              wb_ns <= WB_IDLE;
                           else
                              wb_ns <= SEND_TEMP;
                           end if;
                                       
         when others =>    wb_ns <= WB_IDLE;
      end case;
   end process wishbone_NS;
   
   read_temp_cmd <= '1' when (addr_i = FPGA_TEMP_ADDR and stb_i = '1' and cyc_i = '1' and we_i = '0') else '0';
   
   wishbone_out: process(wb_ps, thermo, valid)
   begin
      ack_o <= '0';
      dat_o <= (others => '0');
      
      case wb_ps is         
         when SEND_TEMP => if(valid = '1') then
                              ack_o <= '1';
                              dat_o(7 downto 0) <= thermo;   -- upper bits set to '0' by default assignment
                           end if;
         
         when others =>    null;
      end case;
   end process wishbone_out;
   
end rtl;