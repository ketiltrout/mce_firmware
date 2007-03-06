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
-- Project:       SCUBA-2
-- Author:        Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Implements the controller for the SMBus temperature sensor
--
-- Revision history:
--
-- $Log: fpga_thermo.vhd,v $
-- Revision 1.3  2006/09/28 00:29:33  bburger
-- Bryce:  data_o was not sign-extended
--
-- Revision 1.2  2006/05/05 19:19:08  mandana
-- added err_o to the interface to issue a wishbone error for write commands
--
-- Revision 1.1  2006/01/23 18:18:16  erniel
-- initial version
--
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
port(
   clk_i : in std_logic;
   rst_i : in std_logic;

   -- wishbone signals
   dat_i   : in std_logic_vector (WB_DATA_WIDTH-1 downto 0);
   addr_i  : in std_logic_vector (WB_ADDR_WIDTH-1 downto 0);
   tga_i   : in std_logic_vector (WB_TAG_ADDR_WIDTH-1 downto 0);
   we_i    : in std_logic;
   stb_i   : in std_logic;
   cyc_i   : in std_logic;
   err_o   : out std_logic;
   dat_o   : out std_logic_vector (WB_DATA_WIDTH-1 downto 0);
   ack_o   : out std_logic;

   -- SMBus temperature sensor signals
   smbclk_o   : out std_logic;
   smbalert_i : in std_logic;
   smbdat_io  : inout std_logic
);
end fpga_thermo;

architecture rtl of fpga_thermo is

   -- FSM inputs
   signal wr_cmd : std_logic;
   signal rd_cmd : std_logic;

   -- Various signals used for writing to the temperature register
   signal wbs_wren   : std_logic;
   signal smb_wren   : std_logic;
   signal reg_wren   : std_logic;
   signal wbs_data_o : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal smb_data   : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal reg_data   : std_logic_vector(WB_DATA_WIDTH-1 downto 0);

   -- WBS states:
   type wbs_states is (IDLE, WR, RD);
   signal current_state : wbs_states;
   signal next_state    : wbs_states;

   -- SMB master interface:
   signal slave_data_out : std_logic_vector(7 downto 0);
   signal slave_start    : std_logic;
   signal slave_done     : std_logic;
   signal slave_err      : std_logic;

   -- Timer signals
   signal timeout_clr   : std_logic;
   signal timeout_count : integer;
   signal update_temp   : std_logic;

   -- SMB controller FSM states:
   type states is (IDLE, START_SMB_MASTER, REGISTER_TEMP);
   signal ctrl_ps : states;
   signal ctrl_ns : states;

begin

   ---------------------------------------------------------
   -- Temperature Update Timer
   ---------------------------------------------------------
   timeout_timer : us_timer
   port map(
      clk => clk_i,
      timer_reset_i => timeout_clr,
      timer_count_o => timeout_count
   );

   process(rst_i, clk_i)
   begin
      if(rst_i = '1') then
         update_temp <= '0';
      elsif(clk_i'event and clk_i = '1') then
         if(timeout_clr = '1') then
            update_temp <= '0';
--         elsif(timeout_count >= 350) then
         elsif(timeout_count >= 2000000) then
            update_temp <= '1';
         else
            update_temp <= update_temp;
         end if;
      end if;
   end process;


   ------------------------------------------------------------
   --  Temperature Chip Interface
   ------------------------------------------------------------
   master2 : smb_master
   port map(
      clk_i         => clk_i,
      rst_i         => rst_i,

      -- master-side signals
      r_nw_i        => '1',
      start_i       => slave_start,
      addr_i        => "0011000", -- default smb sensor address is 0011000
      data_i        => "11111111",

      done_o        => slave_done,
      error_o       => slave_err,
      data_o        => slave_data_out,

      -- slave-side signals
      slave_clk_o   => smbclk_o,
      slave_data_io => smbdat_io
   );


   ------------------------------------------------------------
   --  Temperature Register
   ------------------------------------------------------------
   -- Allows us to write a temporary value to the register to see if the smb_master
   -- overwrites the value the next time it queries for temperature.
   -- Essentially, this allows us to test whether the smb portion is working or not.
   smb_data <= sxt(slave_data_out, 32);

   reg_data <= dat_i when (wbs_wren = '1') else smb_data;
   reg_wren <= '1'   when (wbs_wren = '1') else smb_wren;

   thermo_data : reg
   generic map(WIDTH => 32)
   port map(
      clk_i => clk_i,
      rst_i => rst_i,
      ena_i => reg_wren,
      reg_i => reg_data,
      reg_o => wbs_data_o
   );


   ------------------------------------------------------------
   --  SMB FSM
   ------------------------------------------------------------
   control_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         ctrl_ps <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         ctrl_ps <= ctrl_ns;
      end if;
   end process control_FF;

   control_NS: process(ctrl_ps, slave_done, update_temp)
   begin
      -- Default assignment
      ctrl_ns <= ctrl_ps;

      case ctrl_ps is
         when IDLE =>
            if(update_temp = '1') then
               ctrl_ns <= START_SMB_MASTER;
            end if;

         when START_SMB_MASTER =>
            if(slave_done = '1') then
               ctrl_ns <= REGISTER_TEMP;
            end if;

         when REGISTER_TEMP =>
            -- What if there's an error??
            ctrl_ns <= IDLE;

         when others =>
            ctrl_ns <= IDLE;

      end case;
   end process control_NS;

   control_out: process(ctrl_ps, update_temp)
   begin
      smb_wren    <= '0';
      slave_start <= '0';
      timeout_clr <= '0';

      case ctrl_ps is

         when IDLE =>
            if(update_temp = '1') then
               slave_start <= '1';
            end if;

         when START_SMB_MASTER =>
            NULL;

         when REGISTER_TEMP =>
            smb_wren    <= '1';
            timeout_clr <= '1';

         when others =>
            NULL;

      end case;
   end process control_out;


   ------------------------------------------------------------
   --  WB FSM
   ------------------------------------------------------------
   -- clocked FSMs, advance the state for both FSMs
   state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         current_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         current_state <= next_state;
      end if;
   end process state_FF;

   -- Transition table for DAC controller
   state_NS: process(current_state, rd_cmd, wr_cmd, cyc_i)
   begin
      -- Default assignments
      next_state <= current_state;

      case current_state is
         when IDLE =>
            if(wr_cmd = '1') then
               next_state <= WR;
            elsif(rd_cmd = '1') then
               next_state <= RD;
            end if;

         when WR =>
            if(cyc_i = '0') then
               next_state <= IDLE;
            end if;

         when RD =>
            if(cyc_i = '0') then
               next_state <= IDLE;
            end if;

         when others =>
            next_state <= IDLE;

      end case;
   end process state_NS;

   -- Output states for DAC controller
   state_out: process(current_state, stb_i, addr_i)
   begin
      -- Default assignments
      ack_o    <= '0';
      wbs_wren <= '0';

      case current_state is
         when IDLE  =>
            ack_o <= '0';

         when WR =>
            ack_o <= '1';
            if(stb_i = '1') then
               if(addr_i = FPGA_TEMP_ADDR) then
                  wbs_wren <= '1';
               end if;
            end if;

         when RD =>
            ack_o <= '1';

         when others =>

      end case;
   end process state_out;


   ------------------------------------------------------------
   --  Wishbone interface:
   ------------------------------------------------------------
   with addr_i select dat_o <=
      wbs_data_o when FPGA_TEMP_ADDR,
      (others => '0') when others;

   rd_cmd  <= '1' when
      (stb_i = '1' and cyc_i = '1' and we_i = '0') and
      (addr_i = FPGA_TEMP_ADDR) else '0';

   wr_cmd  <= '1' when
      (stb_i = '1' and cyc_i = '1' and we_i = '1') and
      (addr_i = FPGA_TEMP_ADDR) else '0';

end rtl;