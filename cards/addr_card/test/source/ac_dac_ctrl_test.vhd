-- 2003 SCUBA-2 Project
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

-- ac_dac_ctrl_test.vhd
--
-- Project:	      SCUBA-2
-- Author:	      Mandana Amiri
-- Organisation:      UBC
--
-- Description:
-- NOTE: THIS IS A SIMPLE implementation to load values on DAC once enable is received.
-- Wishbone to 41 parallel 14-bit 165MS/s DAC (AD9744) interface 
-- CIRCULAR_DAC_CTRL slave processes the following commands issued by Command_FSM on address card:
--              ON_BIAS_ADDR     : to read/write a 14b ON current bias value to each of the 41 DACs in 41 consecutive words.
--              OFF_BIAS_ADDR    : to read/write a 14b OFF current bias value to each of the 41 DACs
--              ROW_MAP_ADDR     : to read/write the channel to row address mapping with 41 consecutive bytes                 
--              STRT_MUX_ADDR    : to read/write whether the mux is enabled or disabled       :
--              ROW_ORDER_ADDR   : to read/write row addressing order
--              ACTV_ROW_ADDR    : if read, returns which row is currently on
--                               : OR if written, sets the active row. The active row number is a byte long.
--              CYC_OO_SYC_ADDR  : to send the number of cycles out of sync to the master (cmd_fsm) 
--              RESYNC_ADDR      : to resync with the next sync pulse
-- 
 
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library sys_param;
use sys_param.wishbone_pack.all;
use sys_param.general_pack.all;
use sys_param.frame_timing_pack.all;
use sys_param.data_types_pack.all;

library components;
use components.component_pack.all;


entity ac_dac_ctrl_test is
   port (
      -- basic signals
      rst_i     : in std_logic;    -- reset input
      clk_i     : in std_logic;    -- clock input
      en_i      : in std_logic;    -- enable signal
      done_o    : out std_logic;   -- done ouput signal
      
      -- no transmitter signals
      
      -- extended signals
--      dac_dat_o : out w_array11; 

      dac_dat0_o  : out std_logic_vector(13 downto 0);
      dac_dat1_o  : out std_logic_vector(13 downto 0);
      dac_dat2_o  : out std_logic_vector(13 downto 0);
      dac_dat3_o  : out std_logic_vector(13 downto 0);
      dac_dat4_o  : out std_logic_vector(13 downto 0);
      dac_dat5_o  : out std_logic_vector(13 downto 0);
      dac_dat6_o  : out std_logic_vector(13 downto 0);
      dac_dat7_o  : out std_logic_vector(13 downto 0);
      dac_dat8_o  : out std_logic_vector(13 downto 0);
      dac_dat9_o  : out std_logic_vector(13 downto 0);
      dac_dat10_o : out std_logic_vector(13 downto 0);
      
      dac_clk_o : out std_logic_vector (40 downto 0)      
   );   
end;  

architecture rtl of ac_dac_ctrl_test is

-- DAC CTRL:
-- State encoding and state variables:

-- controller states:
type states is (IDLE, PUSH_DATA, CLKNOW, DONE); 
signal present_state         : states;
signal next_state            : states;
type   w_array5 is array (5 downto 0) of word14; 
signal data     : w_array5;
signal idat     : integer;
signal idac     : integer;
signal ibus     : integer;

signal logic0 : std_logic;
signal logic1 : std_logic;
signal zero : integer;

begin
   logic0 <= '0';
   logic1 <= '1';
   zero <= 0;
   
-- instantiate a counter for idac to go through all 32 DACs
   data_count: counter
   generic map(MAX => 5)
   port map(clk_i   => en_i,
            rst_i   => rst_i,
            ena_i   => logic1,
            load_i  => logic0,
            down_i  => logic0,
            count_i => zero ,
            count_o => idat);

   data (0) <= "00000000000000";--0000
   data (1) <= "01000001010101";--1055
   data (2) <= "11110000001100";--3c0c
   data (3) <= "11101110111011";--3bbb
   data (4) <= "10111111111111";--2fff
   data (5) <= "11111111111111";--3fff full scale

  -- state register:
   state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then 
         present_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         present_state <= next_state;
      end if;
   end process state_FF;
---------------------------------------------------------------   
   state_NS: process(present_state, en_i)
   begin
      case present_state is
         when IDLE =>     
            if(en_i = '1') then
               next_state <= PUSH_DATA;
            else
               next_state <= IDLE;
            end if;
                
         when PUSH_DATA =>  
            next_state  <= CLKNOW; -- 2ns settling time for data (ts)
            
         when CLKNOW =>
            next_state  <= DONE;
         
         when DONE =>
            next_state  <= IDLE;
                        
      end case;
   end process state_NS;
-----------------------------------------------------------------   
   state_out: process(present_state)
   begin
      case present_state is
         when IDLE =>     
--            for ibus in 0 to 10 loop
--               dac_dat_o(ibus) <= "00000000000000";
--            end loop;   
         
            dac_dat0_o <= "00000000000000";
            dac_dat1_o <= "00000000000000";
            dac_dat2_o <= "00000000000000";
            dac_dat3_o <= "00000000000000";
            dac_dat4_o <= "00000000000000";
            dac_dat5_o <= "00000000000000";
            dac_dat6_o <= "00000000000000";
            dac_dat7_o <= "00000000000000";
            dac_dat8_o <= "00000000000000";
            dac_dat9_o <= "00000000000000";
            dac_dat10_o <= "00000000000000";
   
            for idac in 0 to 40 loop
               dac_clk_o(idac) <= '0';
            end loop;
	    done_o    <= '0';
         
         when PUSH_DATA =>    
--            for ibus in 0 to 10 loop
--               dac_dat_o(ibus) <= data(idat);
--            end loop;   

            dac_dat0_o <= data(idat);
            dac_dat1_o <= data(idat);
            dac_dat2_o <= data(idat);
            dac_dat3_o <= data(idat);
            dac_dat4_o <= data(idat);
            dac_dat5_o <= data(idat);
            dac_dat6_o <= data(idat);
            dac_dat7_o <= data(idat);
            dac_dat8_o <= data(idat);
            dac_dat9_o <= data(idat);
            dac_dat10_o <= data(idat);
            
            for idac in 0 to 40 loop
               dac_clk_o(idac) <= '0';
            end loop;
	    done_o    <= '0';
                          
         when CLKNOW =>    
--            for ibus in 0 to 10 loop
--               dac_dat_o(ibus) <= data(idat);
--            end loop;   

            dac_dat0_o <= data(idat);
            dac_dat1_o <= data(idat);
            dac_dat2_o <= data(idat);
            dac_dat3_o <= data(idat);
            dac_dat4_o <= data(idat);
            dac_dat5_o <= data(idat);
            dac_dat6_o <= data(idat);
            dac_dat7_o <= data(idat);
            dac_dat8_o <= data(idat);
            dac_dat9_o <= data(idat);
            dac_dat10_o <= data(idat);
            
            for idac in 0 to 40 loop
               dac_clk_o(idac) <= '1';
            end loop;
	    done_o    <= '0';

          when DONE =>    
--            for ibus in 0 to 10 loop
--               dac_dat_o(ibus) <= "00000000000000";
--            end loop;   

            dac_dat0_o <= "00000000000000";
            dac_dat1_o <= "00000000000000";
            dac_dat2_o <= "00000000000000";
            dac_dat3_o <= "00000000000000";
            dac_dat4_o <= "00000000000000";
            dac_dat5_o <= "00000000000000";
            dac_dat6_o <= "00000000000000";
            dac_dat7_o <= "00000000000000";
            dac_dat8_o <= "00000000000000";
            dac_dat9_o <= "00000000000000";
            dac_dat10_o <= "00000000000000";
            
            for idac in 0 to 40 loop
               dac_clk_o(idac) <= '0';
            end loop;
	    done_o    <= '1';
	                              
      end case;
   end process state_out;
   
 end;