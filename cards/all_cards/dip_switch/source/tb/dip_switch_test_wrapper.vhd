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
-- dip_switch_test_wrapper.vhd
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- test wrapper for dip switch module
--
-- Revision history:
-- 
-- $Log: dip_switch_test_wrapper.vhd,v $
-- Revision 1.1  2004/05/06 18:02:34  erniel
-- initial version
--
--
-----------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
use work.dip_switch_pack.all;

library sys_param;
use sys_param.wishbone_pack.all;

library components;
use components.component_pack.all;

-----------------------------------------------------------------------------
                     
entity dip_switch_test_wrapper is
   port (
      -- basic signals
      rst_i     : in std_logic;    -- reset input
      clk_i     : in std_logic;    -- clock input
      en_i      : in std_logic;    -- enable signal
      done_o    : out std_logic;   -- done ouput signal
      
      -- transmitter signals
      data_o    : out std_logic_vector(1 downto 0);
      
      -- extended signals
      dip_switch_i : in std_logic_vector (1 downto 0) -- physical dip switch pin
   );
end dip_switch_test_wrapper;

---------------------------------------------------------------------

architecture rtl of dip_switch_test_wrapper is

   -- state definitions
   type state is (IDLE, READ, DONE);
   signal current_state, next_state : state;

   -- wishbone "emulated master" signals
   signal addr_o  : std_logic_vector (WB_ADDR_WIDTH-1 downto 0);
   signal tga_o   : std_logic_vector (WB_TAG_ADDR_WIDTH-1 downto 0);
   signal dat_i   : std_logic_vector (WB_DATA_WIDTH-1 downto 0);
   signal we_o    : std_logic;
   signal stb_o   : std_logic;
   signal ack_i   : std_logic;
   signal rty_i   : std_logic;
   signal cyc_o   : std_logic;  
   
   -- RS232 data transmit controller signals
   signal data_reg : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   
begin
   
------------------------------------------------------------------------
--
-- instantiate the dip_switch
--
------------------------------------------------------------------------

   dip : dip_switch 
   generic map(WIDTH => 2)
   port map(dip_switch_i => dip_switch_i, 

            -- wishbone signals
            clk_i  => clk_i,
            rst_i  => rst_i,
            dat_i  => (others => '0'), -- not used since not writing to dip switches
            dat_o  => dat_i,  
            addr_i => addr_o,
            tga_i  => (others => '0'),
            we_i   => '0',
            stb_i  => stb_o,
            ack_o  => ack_i,
            rty_o  => rty_i,
            cyc_i  => cyc_o);
   
   
------------------------------------------------------------------------
--
-- Emulate the master querying for the dip_switch
--
------------------------------------------------------------------------   

------------------------------------------------------------------------
--
-- assign next states
--
------------------------------------------------------------------------  

   process (current_state, en_i, ack_i)
   begin
      case current_state is
         when IDLE =>
            if en_i = '1' then
               next_state <= READ;
            else
               next_state <= IDLE;
            end if;
            
         when READ =>
            if ack_i = '1' then
               next_state <= DONE;
            else
               next_state <= READ;
            end if;
 
         when DONE =>
            next_state <= IDLE;
            
         when others =>
            next_state <= IDLE;
            
      end case;
   end process;


------------------------------------------------------------------------
--
-- assign outputs of each state
--
------------------------------------------------------------------------  
  
   process (current_state)
   begin
      -- wishbone signals to slave
      addr_o  <= (others => '0');
      stb_o   <= '0';
      cyc_o   <= '0';
      
      -- output back to test module
      done_o  <= '0';
      data_o  <= (others => '0');

      case current_state is
         when IDLE => null;
            
         when READ => addr_o   <= DIP_ADDR;
                      stb_o    <= '1';
                      cyc_o    <= '1';
	   
         when DONE => done_o  <= '1';
                      data_o  <= data_reg(1 downto 0);
	 
         when others => null;
	 
      end case;
   end process;

   process(clk_i)
   begin
      if(clk_i'event and clk_i = '1') then
         if(current_state = READ) then
            data_reg <= dat_i;
         end if;
      end if;
   end process;
   
   
------------------------------------------------------------------------
--
-- state sequencer
--
------------------------------------------------------------------------  

   process(clk_i, rst_i, en_i)
   begin
      if rst_i = '1' or en_i = '0' then
         current_state <= IDLE;
      elsif clk_i'event and clk_i = '1' then
         current_state <= next_state;
      end if;
   end process;

end;