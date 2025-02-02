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
-- id_thermo.vhd
--
-- Project:       SCUBA-2
-- Author:        Ernie Lin/ Bryce Burger
-- Organisation:  UBC
--
-- Description:
-- Implements the controller for the silicon id/temperature chip
--
-- Revision history:
--
-- $Log: id_thermo.vhd,v $
-- Revision 1.10  2007/07/26 20:23:01  bburger
-- BB:  scaling bug fixed.  Now the temperatures make room at the LSB for the stale bit
--
-- Revision 1.9  2007/07/25 22:22:19  bburger
-- BB:  Customized this block to what it actually is used for.  Initially it was intended to be used for both the card id_thermo and box id_thermo chips, but the interfaces between the two are different (1-wire vs. 3-wire) so I abandoned the idea of reusing this block and implemented a box_id_thermo block in the clk_card directory.
-- - This block now incorporates a stale bit in the LSB of the data returned to the dispatch block.
--
-- Revision 1.8  2006/10/19 21:55:05  bburger
-- Bryce:  alterations made for the sake of BOX_ID which has a three-wire interface compared to CARD_ID's one-wire interface
--
-- Revision 1.7  2006/09/28 00:30:59  bburger
-- Bryce:  Reduced the resolution of data_o from 0.5 degrees C to 1 degree C to match the output of other slaves.
--
-- Revision 1.6  2006/05/05 19:21:04  mandana
-- added err_o to the interface to issue a wishbone error for write commands
--
-- Revision 1.5  2005/10/21 20:07:40  erniel
-- valid flag now controls termination of wishbone cycle
--
-- Revision 1.4  2005/10/21 19:37:19  erniel
-- updated one_wire_master component
--
-- Revision 1.3  2005/07/12 23:58:41  erniel
-- fixed synthesis warnings in process wishbone_out
--
-- Revision 1.2  2005/07/05 16:50:30  erniel
-- added wishbone interface
--
-- Revision 1.1  2005/07/05 16:45:39  erniel
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

entity id_thermo is
port(
   clk_i : in std_logic;
   rst_i : in std_logic;

   -- Wishbone signals
   dat_i   : in std_logic_vector (WB_DATA_WIDTH-1 downto 0);
   addr_i  : in std_logic_vector (WB_ADDR_WIDTH-1 downto 0);
   tga_i   : in std_logic_vector (WB_TAG_ADDR_WIDTH-1 downto 0);
   we_i    : in std_logic;
   stb_i   : in std_logic;
   cyc_i   : in std_logic;
   err_o   : out std_logic;
   dat_o   : out std_logic_vector (WB_DATA_WIDTH-1 downto 0);
   ack_o   : out std_logic;

   data_io : inout std_logic
);
end id_thermo;

architecture behav of id_thermo is

   -- one-wire master interface:
   signal slave_cmd     : std_logic_vector(7 downto 0);
   signal slave_data    : std_logic_vector(7 downto 0);
   signal slave_init    : std_logic;
   signal slave_read    : std_logic;
   signal slave_write   : std_logic;
   signal slave_done    : std_logic;
   signal slave_ready   : std_logic;
   signal slave_ndetect : std_logic;

   -- byte counter:
   signal byte_count_ena : std_logic;
   signal byte_count_clr : std_logic;
   signal byte_count     : integer range 0 to 10;

   -- controller FSM states:
   type states is (CTRL_IDLE,
                   PHASE1_INIT, PHASE1_READ_ROM, GET_ID,
                   PHASE2_INIT, PHASE2_SKIP_ROM, PHASE2_CONVERT_T, GET_STATUS,
                   PHASE3_INIT, PHASE3_SKIP_ROM, PHASE3_READ_SCRATCH, GET_TEMP,
                   SET_VALID_FLAG);
   signal ctrl_ps : states;
   signal ctrl_ns : states;

   -- wishbone FSM states:
   type wb_states is (WB_IDLE, SEND_ID, SEND_TEMP, WB_ERROR);  -- only sending back 32-bits of 48-bit silicon id code (can be modified later)
   signal wb_ps : wb_states;
   signal wb_ns : wb_states;

   signal read_id_cmd   : std_logic;
   signal read_temp_cmd : std_logic;
   signal write_cmd     : std_logic;

   -- data registers:
   signal id         : std_logic_vector(47 downto 0);
   signal thermo     : std_logic_vector(15 downto 0);

   signal id0_ld     : std_logic;
   signal id1_ld     : std_logic;
   signal id2_ld     : std_logic;
   signal id3_ld     : std_logic;
   signal id4_ld     : std_logic;
   signal id5_ld     : std_logic;
   signal thermo0_ld : std_logic;
   signal thermo1_ld : std_logic;

   signal stale      : std_logic;
   signal stale_set  : std_logic;
   signal stale_rst  : std_logic;

begin

   master : one_wire_master
   generic map(tristate => "INTERNAL")
   port map(clk_i         => clk_i,
            rst_i         => rst_i,
            master_data_i => slave_cmd,
            master_data_o => slave_data,
            init_i        => slave_init,
            read_i        => slave_read,
            write_i       => slave_write,
            done_o        => slave_done,
            ready_o       => slave_ready,
            ndetect_o     => slave_ndetect,
            slave_data_io => data_io,
            slave_data_o  => open,
            slave_wren_o  => open);

   byte_counter : counter
   generic map(MAX => 9)
   port map(clk_i   => clk_i,
            rst_i   => rst_i,
            ena_i   => byte_count_ena,
            load_i  => byte_count_clr,
            count_i => 0,
            count_o => byte_count);

   -- Silicon ID registers (6 x 1 byte registers)

   id_data0 : reg
   generic map(WIDTH => 8)
   port map(clk_i => clk_i,
            rst_i => rst_i,
            ena_i => id0_ld,

            reg_i => slave_data,
            reg_o => id(7 downto 0));

   id_data1 : reg
   generic map(WIDTH => 8)
   port map(clk_i => clk_i,
            rst_i => rst_i,
            ena_i => id1_ld,

            reg_i => slave_data,
            reg_o => id(15 downto 8));

   id_data2 : reg
   generic map(WIDTH => 8)
   port map(clk_i => clk_i,
            rst_i => rst_i,
            ena_i => id2_ld,

            reg_i => slave_data,
            reg_o => id(23 downto 16));

   id_data3 : reg
   generic map(WIDTH => 8)
   port map(clk_i => clk_i,
            rst_i => rst_i,
            ena_i => id3_ld,

            reg_i => slave_data,
            reg_o => id(31 downto 24));

   id_data4 : reg
   generic map(WIDTH => 8)
   port map(clk_i => clk_i,
            rst_i => rst_i,
            ena_i => id4_ld,

            reg_i => slave_data,
            reg_o => id(39 downto 32));

   id_data5 : reg
   generic map(WIDTH => 8)
   port map(clk_i => clk_i,
            rst_i => rst_i,
            ena_i => id5_ld,

            reg_i => slave_data,
            reg_o => id(47 downto 40));


   -- Temperature registers (2 x 1 byte registers)

   thermo_data0 : reg
   generic map(WIDTH => 8)
   port map(clk_i => clk_i,
            rst_i => rst_i,
            ena_i => thermo0_ld,

            reg_i => slave_data,
            reg_o => thermo(7 downto 0));

   thermo_data1 : reg
   generic map(WIDTH => 8)
   port map(clk_i => clk_i,
            rst_i => rst_i,
            ena_i => thermo1_ld,

            reg_i => slave_data,
            reg_o => thermo(15 downto 8));


   -- Stale flag
   stale_flag: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         stale <= '0';
      elsif(clk_i'event and clk_i = '1') then
         if(stale_set = '1') then
            stale <= '1';
         elsif(stale_rst = '1') then
            stale <= '0';
         end if;
      end if;
   end process stale_flag;


   -- Controller FSM
   control_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         ctrl_ps <= CTRL_IDLE;
      elsif(clk_i'event and clk_i = '1') then
         ctrl_ps <= ctrl_ns;
      end if;
   end process control_FF;

   control_NS: process(ctrl_ps, slave_done, slave_ready, slave_ndetect, byte_count)
   begin
      ctrl_ns <= ctrl_ps;

      case ctrl_ps is
         when CTRL_IDLE =>           ctrl_ns <= PHASE1_INIT;

         -- Phase 1: Read Silicon ID ----------------------------------------------------

         when PHASE1_INIT =>         if(slave_done = '1' and slave_ndetect = '1') then
                                        ctrl_ns <= CTRL_IDLE;
                                     elsif(slave_done = '1' and slave_ndetect = '0') then
                                        ctrl_ns <= PHASE1_READ_ROM;
                                     else
                                        ctrl_ns <= PHASE1_INIT;
                                     end if;

         when PHASE1_READ_ROM =>     if(slave_done = '1') then
                                        ctrl_ns <= GET_ID;
                                     else
                                        ctrl_ns <= PHASE1_READ_ROM;
                                     end if;

         when GET_ID =>              if(slave_done = '1' and byte_count = 6) then
                                        ctrl_ns <= PHASE2_INIT;
                                     else
                                        ctrl_ns <= GET_ID;
                                     end if;

         -- Phase 2: Measure Temperature ------------------------------------------------

         when PHASE2_INIT =>         if(slave_done = '1' and slave_ndetect = '1') then
                                        ctrl_ns <= CTRL_IDLE;
                                     elsif(slave_done = '1' and slave_ndetect = '0') then
                                        ctrl_ns <= PHASE2_SKIP_ROM;
                                     else
                                        ctrl_ns <= PHASE2_INIT;
                                     end if;

         when PHASE2_SKIP_ROM =>     if(slave_done = '1') then
                                        ctrl_ns <= PHASE2_CONVERT_T;
                                     else
                                        ctrl_ns <= PHASE2_SKIP_ROM;
                                     end if;

         when PHASE2_CONVERT_T =>    if(slave_done = '1') then
                                        ctrl_ns <= GET_STATUS;
                                     else
                                        ctrl_ns <= PHASE2_CONVERT_T;
                                     end if;

         when GET_STATUS =>          if(slave_done = '1' and slave_ready = '1') then
                                        ctrl_ns <= PHASE3_INIT;
                                     else
                                        ctrl_ns <= GET_STATUS;
                                     end if;

         -- Phase 3: Retrieve Temperature -----------------------------------------------

         when PHASE3_INIT =>         if(slave_done = '1' and slave_ndetect = '1') then
                                        ctrl_ns <= CTRL_IDLE;
                                     elsif(slave_done = '1' and slave_ndetect = '0') then
                                        ctrl_ns <= PHASE3_SKIP_ROM;
                                     else
                                        ctrl_ns <= PHASE3_INIT;
                                     end if;

         when PHASE3_SKIP_ROM =>     if(slave_done = '1') then
                                        ctrl_ns <= PHASE3_READ_SCRATCH;
                                     else
                                        ctrl_ns <= PHASE3_SKIP_ROM;
                                     end if;

         when PHASE3_READ_SCRATCH => if(slave_done = '1') then
                                        ctrl_ns <= GET_TEMP;
                                     else
                                        ctrl_ns <= PHASE3_READ_SCRATCH;
                                     end if;

         when GET_TEMP =>            if(slave_done = '1' and byte_count = 1) then
                                        ctrl_ns <= SET_VALID_FLAG;
                                     else
                                        ctrl_ns <= GET_TEMP;
                                     end if;

         --------------------------------------------------------------------------------

         when SET_VALID_FLAG =>      ctrl_ns <= PHASE2_INIT;

         when others =>              ctrl_ns <= CTRL_IDLE;
      end case;
   end process control_NS;

   control_out: process(ctrl_ps, slave_done, byte_count)
   begin
      byte_count_ena <= '0';
      byte_count_clr <= '0';

      slave_init  <= '0';
      slave_read  <= '0';
      slave_write <= '0';
      slave_cmd   <= "00000000";

      id0_ld     <= '0';
      id1_ld     <= '0';
      id2_ld     <= '0';
      id3_ld     <= '0';
      id4_ld     <= '0';
      id5_ld     <= '0';
      thermo0_ld <= '0';
      thermo1_ld <= '0';
      stale_rst   <= '0';

      case ctrl_ps is
         when PHASE1_INIT |
              PHASE2_INIT |
              PHASE3_INIT =>         slave_init     <= '1';
                                     byte_count_ena <= '1';
                                     byte_count_clr <= '1';

         when PHASE2_SKIP_ROM |
              PHASE3_SKIP_ROM =>     slave_write <= '1';
                                     slave_cmd   <= "11001100";

         when PHASE1_READ_ROM =>     slave_write <= '1';
                                     slave_cmd   <= "00110011";

         when PHASE2_CONVERT_T =>    slave_write <= '1';
                                     slave_cmd   <= "01000100";

         when PHASE3_READ_SCRATCH => slave_write <= '1';
                                     slave_cmd   <= "10111110";

         when GET_ID =>              slave_read <= '1';
                                     if(slave_done = '1') then
                                        byte_count_ena <= '1';
                                        case byte_count is
                                           when 1 =>      id0_ld <= '1';  -- start loading id register from 2nd byte
                                           when 2 =>      id1_ld <= '1';
                                           when 3 =>      id2_ld <= '1';
                                           when 4 =>      id3_ld <= '1';
                                           when 5 =>      id4_ld <= '1';
                                           when others => id5_ld <= '1';
                                        end case;
                                     end if;

         when GET_STATUS =>          slave_read <= '1';

         when GET_TEMP =>            slave_read <= '1';
                                     if(slave_done = '1') then
                                        byte_count_ena <= '1';
                                        case byte_count is
                                           when 0 =>      thermo0_ld <= '1';
                                           when others => thermo1_ld <= '1';
                                        end case;
                                     end if;

         when SET_VALID_FLAG =>      stale_rst <= '1';

         when others =>              null;
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

   wishbone_NS: process(wb_ps, read_id_cmd, read_temp_cmd, write_cmd)
   begin
      wb_ns <= wb_ps;

      case wb_ps is
         when WB_IDLE =>
            if(read_id_cmd = '1') then
               wb_ns <= SEND_ID;
            elsif(read_temp_cmd = '1') then
               wb_ns <= SEND_TEMP;
            elsif(write_cmd = '1') then
               wb_ns <= WB_ERROR;
            else
               wb_ns <= WB_IDLE;
            end if;

         when SEND_ID =>
            wb_ns <= WB_IDLE;

         when SEND_TEMP =>
            wb_ns <= WB_IDLE;

         when WB_ERROR =>
            wb_ns <= WB_IDLE;

         when others =>
            wb_ns <= WB_IDLE;
      end case;
   end process wishbone_NS;

   read_id_cmd   <= '1' when (addr_i = CARD_ID_ADDR and stb_i = '1' and cyc_i = '1' and we_i = '0') else '0';
   read_temp_cmd <= '1' when (addr_i = CARD_TEMP_ADDR and stb_i = '1' and cyc_i = '1' and we_i = '0') else '0';
   write_cmd     <= '1' when ((addr_i = CARD_TEMP_ADDR or addr_i = CARD_ID_ADDR) and stb_i = '1' and cyc_i = '1' and we_i = '1') else '0';

   wishbone_out: process(wb_ps, id, thermo, stale)
   begin
      ack_o <= '0';
      dat_o <= (others => '0');
      err_o <= '0';
      stale_set <= '0';

      case wb_ps is
         when SEND_ID =>
            ack_o <= '1';
            dat_o <= id(31 downto 0);

         when SEND_TEMP =>
            ack_o <= '1';
            stale_set <= '1';
            -- sign extension to 32-bit since thermo is 16-bit and wishbone data is 32-bit
            -- Want temperature in degree-resolution (not 0.5-degree resolution)
            -- Range is from -55 to +85 degress Celcius.
            dat_o <= thermo(15) & thermo(15) & thermo(15) & thermo(15) & thermo(15) & thermo(15) & thermo(15) & thermo(15) &
                     thermo(15) & thermo(15) & thermo(15) & thermo(15) & thermo(15) & thermo(15) & thermo(15) & thermo(15) &
                     thermo(15) & thermo(15 downto 2) & stale;

         when WB_ERROR =>
            err_o <= '1';

         when others =>
            null;
      end case;
   end process wishbone_out;

end behav;