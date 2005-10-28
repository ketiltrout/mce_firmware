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
-- id_thermo_test_wrapper.vhd
--
-- Project:	      SCUBA-2
-- Author:        Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Test wrapper for the id_thermo module.
--
-- Revision history:
-- 
-- $Log$
--
-----------------------------------------------------------------------------



library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library sys_param;
use sys_param.wishbone_pack.all;

library components;
use components.component_pack.all;


-----------------------------------------------------------------------------
                     
entity id_thermo_test_wrapper is
port(-- basic signals
     rst_i     : in std_logic;    -- reset input
     clk_i     : in std_logic;    -- clock input
     
     id_en_i   : in std_logic;    -- ID enable signal
     temp_en_i : in std_logic;    -- temperature enable signal
     
     done_o    : out std_logic;   -- ID done output signal
     
     -- transmitter signals
     data_o    : out std_logic_vector(31 downto 0);
      
     -- extended signals
     id_thermo_io : inout std_logic); -- physical pin
end id_thermo_test_wrapper;

---------------------------------------------------------------------

architecture rtl of id_thermo_test_wrapper is

component id_thermo
port(clk_i : in std_logic;
     rst_i : in std_logic;
     
     -- Wishbone signals
     dat_i 	 : in std_logic_vector (WB_DATA_WIDTH-1 downto 0); 
     addr_i  : in std_logic_vector (WB_ADDR_WIDTH-1 downto 0);
     tga_i   : in std_logic_vector (WB_TAG_ADDR_WIDTH-1 downto 0);
     we_i    : in std_logic;
     stb_i   : in std_logic;
     cyc_i   : in std_logic;
     dat_o   : out std_logic_vector (WB_DATA_WIDTH-1 downto 0);
     ack_o   : out std_logic;
        
     -- silicon id/temperature chip signals
     data_io : inout std_logic);
end component;

-- state definitions
type state is (IDLE, READ_ID, READ_TEMP, DONE); 
signal current_state, next_state : state;

-- wishbone "emulated master" signals
signal addr : std_logic_vector (WB_ADDR_WIDTH-1 downto 0);
signal data : std_logic_vector (WB_DATA_WIDTH-1 downto 0);
signal stb  : std_logic;
signal ack  : std_logic;
signal cyc  : std_logic;  
   
signal data_ld : std_logic;
   
begin


------------------------------------------------------------
-- Instantiate the id_thermo module:
------------------------------------------------------------

   id_thermo_test : id_thermo
   port map(clk_i   => clk_i,
            rst_i   => rst_i,
            dat_i   => (others => '0'), -- not used since not writing to id_thermo
            dat_o   => data,  
            addr_i  => addr,
            tga_i   => (others => '0'),
            we_i    => '0',
            stb_i   => stb,
            ack_o   => ack,
            cyc_i   => cyc,
            data_io => id_thermo_io);


------------------------------------------------------------
-- Returned data register:
------------------------------------------------------------
            
   temp_storage: reg
   generic map(WIDTH => WB_DATA_WIDTH)
   port map(clk_i => clk_i,
            rst_i => rst_i,
            ena_i => data_ld,
            reg_i => data,
            reg_o => data_o);
                     
            
------------------------------------------------------------
-- Wishbone master FSM for id_thermo module:
------------------------------------------------------------   

   process(clk_i, rst_i, id_en_i, temp_en_i)
   begin
      if(rst_i = '1' or (id_en_i = '0' and temp_en_i = '0')) then
         current_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         current_state <= next_state;
      end if;
   end process;
   
   process (current_state, id_en_i, temp_en_i, ack)
   begin
      case current_state is
         when IDLE =>      if(id_en_i = '1') then
                              next_state <= READ_ID;
                           elsif(temp_en_i = '1') then
                              next_state <= READ_TEMP;
                           else
                              next_state <= IDLE;
                           end if;
            
         when READ_ID =>   if(ack = '1') then
                              next_state <= DONE;
                           else
                              next_state <= READ_ID;
                           end if;
                         
         when READ_TEMP => if(ack = '1') then
                              next_state <= DONE;
                           else
                              next_state <= READ_TEMP;
                           end if;
                     
         when DONE =>      next_state <= IDLE;
            
         when others =>    next_state <= IDLE;
            
      end case;
   end process;
 
   process (current_state)
   begin   
      addr    <= (others => '0');
      stb     <= '0';
      cyc     <= '0';
      data_ld <= '0';
      done_o  <= '0';
            
      case current_state is
         when READ_ID =>   addr    <= CARD_ID_ADDR;
                           stb     <= '1';
                           cyc     <= '1';
                           data_ld <= '1';
	 
	 when READ_TEMP => addr    <= CARD_TEMP_ADDR;
	                   stb     <= '1';
	                   cyc     <= '1';
	                   data_ld <= '1';
	                   
         when DONE =>      done_o  <= '1'; 

         when others =>    null;	 
      end case;
   end process;
end rtl;