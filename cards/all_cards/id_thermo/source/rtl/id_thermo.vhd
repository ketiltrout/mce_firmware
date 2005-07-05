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
-- Project:	      SCUBA-2
-- Author:        Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Implements the controller for the silicon id/temperature chip
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

entity id_thermo is
port(clk_i : in std_logic;

     data_io : inout std_logic;
 
     sw_i : in std_logic_vector(3 downto 0);
     led_o : out std_logic_vector(7 downto 0));
end id_thermo;

architecture behav of id_thermo is

signal clk : std_logic;
signal rst : std_logic;

signal byte_count_ena : std_logic;
signal byte_count_clr : std_logic;
signal byte_count     : integer range 0 to 10;


signal slave_cmd     : std_logic_vector(7 downto 0);
signal slave_data    : std_logic_vector(7 downto 0);
signal slave_init    : std_logic;
signal slave_read    : std_logic;
signal slave_write   : std_logic;
signal slave_done    : std_logic;
signal slave_ready   : std_logic;
signal slave_ndetect : std_logic;

-- controller FSM states:
type states is (IDLE, 
                PHASE1_INIT, PHASE1_READ_ROM, GET_ID,
                PHASE2_INIT, PHASE2_SKIP_ROM, PHASE2_CONVERT_T, GET_STATUS, 
                PHASE3_INIT, PHASE3_SKIP_ROM, PHASE3_READ_SCRATCH, GET_TEMP,
                SET_VALID_FLAG);
signal pres_state : states;
signal next_state : states;

signal id         : std_logic_vector(47 downto 0);
signal thermo     : std_logic_vector(15 downto 0);
signal valid      : std_logic;

signal id0_ld     : std_logic;
signal id1_ld     : std_logic;
signal id2_ld     : std_logic;
signal id3_ld     : std_logic;
signal id4_ld     : std_logic;
signal id5_ld     : std_logic;
signal thermo0_ld : std_logic;
signal thermo1_ld : std_logic;
signal valid_ld   : std_logic;

signal nsw : std_logic_vector(3 downto 0);

begin

   master : one_wire_master
   port map(clk_i     => clk,
            rst_i     => rst,
            data_i    => slave_cmd,
            data_o    => slave_data,
            init_i    => slave_init,
            read_i    => slave_read,
            write_i   => slave_write,
            done_o    => slave_done,
            ready_o   => slave_ready,
            ndetect_o => slave_ndetect,
            data_io   => data_io);

   byte_counter : counter
   generic map(MAX => 9)
   port map(clk_i   => clk,
            rst_i   => rst,
            ena_i   => byte_count_ena,
            load_i  => byte_count_clr,
            count_i => 0,
            count_o => byte_count);


   -- Silicon ID registers (6 x 1 byte registers)

   id_data0 : reg
   generic map(WIDTH => 8)
   port map(clk_i => clk,
            rst_i => rst,
            ena_i => id0_ld,

            reg_i => slave_data,
            reg_o => id(7 downto 0));

   id_data1 : reg
   generic map(WIDTH => 8)
   port map(clk_i => clk,
            rst_i => rst,
            ena_i => id1_ld,

            reg_i => slave_data,
            reg_o => id(15 downto 8));

   id_data2 : reg
   generic map(WIDTH => 8)
   port map(clk_i => clk,
            rst_i => rst,
            ena_i => id2_ld,

            reg_i => slave_data,
            reg_o => id(23 downto 16));

   id_data3 : reg
   generic map(WIDTH => 8)
   port map(clk_i => clk,
            rst_i => rst,
            ena_i => id3_ld,

            reg_i => slave_data,
            reg_o => id(31 downto 24));

   id_data4 : reg
   generic map(WIDTH => 8)
   port map(clk_i => clk,
            rst_i => rst,
            ena_i => id4_ld,

            reg_i => slave_data,
            reg_o => id(39 downto 32));

   id_data5 : reg
   generic map(WIDTH => 8)
   port map(clk_i => clk,
            rst_i => rst,
            ena_i => id5_ld,

            reg_i => slave_data,
            reg_o => id(47 downto 40));
   

   -- Temperature registers (2 x 1 byte registers)

   thermo_data0 : reg
   generic map(WIDTH => 8)
   port map(clk_i => clk,
            rst_i => rst,
            ena_i => thermo0_ld,

            reg_i => slave_data,
            reg_o => thermo(7 downto 0));

   thermo_data1 : reg
   generic map(WIDTH => 8)
   port map(clk_i => clk,
            rst_i => rst,
            ena_i => thermo1_ld,

            reg_i => slave_data,
            reg_o => thermo(15 downto 8));


   -- Valid flag

   process(clk, rst)
   begin
      if(rst = '1') then
         valid <= '0';
      elsif(clk'event and clk = '1') then
         if(valid_ld = '1') then
            valid <= '1';
         end if;
      end if;
   end process;


   nsw <= not sw_i;

   rst <= nsw(3);


   -- Controller FSM

   process(clk, rst)
   begin
      if(rst = '1') then
         pres_state <= IDLE;
      elsif(clk'event and clk = '1') then
         pres_state <= next_state;
      end if;
   end process;

   process(pres_state, slave_done, slave_ready, slave_ndetect, byte_count)
   begin
      case pres_state is
         when IDLE =>                next_state <= PHASE1_INIT;

         -- Phase 1: Read Silicon ID ----------------------------------------------------

         when PHASE1_INIT =>         if(slave_done = '1' and slave_ndetect = '1') then
                                        next_state <= IDLE;
                                     elsif(slave_done = '1' and slave_ndetect = '0') then
                                        next_state <= PHASE1_READ_ROM;
                                     else
                                        next_state <= PHASE1_INIT;
                                     end if;

         when PHASE1_READ_ROM =>     if(slave_done = '1') then
                                        next_state <= GET_ID;
                                     else
                                        next_state <= PHASE1_READ_ROM;
                                     end if;

         when GET_ID =>              if(slave_done = '1' and byte_count = 6) then
                                        next_state <= PHASE2_INIT;
                                     else
                                        next_state <= GET_ID;
                                     end if;

         -- Phase 2: Measure Temperature ------------------------------------------------

         when PHASE2_INIT =>         if(slave_done = '1' and slave_ndetect = '1') then
                                        next_state <= IDLE;
                                     elsif(slave_done = '1' and slave_ndetect = '0') then
                                        next_state <= PHASE2_SKIP_ROM;
                                     else
                                        next_state <= PHASE2_INIT;
                                     end if;

         when PHASE2_SKIP_ROM =>     if(slave_done = '1') then
                                        next_state <= PHASE2_CONVERT_T;
                                     else
                                        next_state <= PHASE2_SKIP_ROM;
                                     end if;

         when PHASE2_CONVERT_T =>    if(slave_done = '1') then
                                        next_state <= GET_STATUS;
                                     else
                                        next_state <= PHASE2_CONVERT_T;
                                     end if;

         when GET_STATUS =>          if(slave_done = '1' and slave_ready = '1') then
                                        next_state <= PHASE3_INIT;
                                     else
                                        next_state <= GET_STATUS;
                                     end if;
 
         -- Phase 3: Retrieve Temperature -----------------------------------------------

         when PHASE3_INIT =>         if(slave_done = '1' and slave_ndetect = '1') then
                                        next_state <= IDLE;
                                     elsif(slave_done = '1' and slave_ndetect = '0') then
                                        next_state <= PHASE3_SKIP_ROM;
                                     else
                                        next_state <= PHASE3_INIT;
                                     end if;

         when PHASE3_SKIP_ROM =>     if(slave_done = '1') then
                                        next_state <= PHASE3_READ_SCRATCH;
                                     else
                                        next_state <= PHASE3_SKIP_ROM;
                                     end if;

         when PHASE3_READ_SCRATCH => if(slave_done = '1') then
                                        next_state <= GET_TEMP;
                                     else
                                        next_state <= PHASE3_READ_SCRATCH;
                                     end if;

         when GET_TEMP =>            if(slave_done = '1' and byte_count = 1) then
                                        next_state <= SET_VALID_FLAG;
                                     else
                                        next_state <= GET_TEMP;
                                     end if;

         --------------------------------------------------------------------------------

         when SET_VALID_FLAG =>      next_state <= PHASE2_INIT;

         when others =>              next_state <= IDLE;
      end case;
   end process;

   process(pres_state, slave_done, byte_count)
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
      valid_ld   <= '0';

      case pres_state is
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

         when SET_VALID_FLAG =>      valid_ld <= '1';

         when others =>              null;
      end case;
   end process;


   with nsw(2 downto 0) select
      led_o <= thermo(7 downto 0)  when "000",
               thermo(15 downto 8) when "001",
               id(7 downto 0)      when "010",
               id(15 downto 8)     when "011",
               id(23 downto 16)    when "100",
               id(31 downto 24)    when "101",
               id(39 downto 32)    when "110",
               id(47 downto 40)    when others;

end behav;