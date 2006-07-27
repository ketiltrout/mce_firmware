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
-- $Id$
--
-- Project:       SCUBA-2
-- Author:        Bryce Burger
-- Organization:  UBC
--
-- Description:
-- Wishbone slave interface to the Power Supply Unit Controller.
--
-- Revision history:
-- $Log$
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

entity psu_ctrl is
   port(
      -- Clock and Reset:
      clk_i         : in std_logic;
      rst_i         : in std_logic;
      
      -- Wishbone Interface:
      dat_i         : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_i        : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_i         : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i          : in std_logic;
      stb_i         : in std_logic;
      cyc_i         : in std_logic;
      dat_o         : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_o         : out std_logic;
      
      ------------------------------
      -- SPI Interface
      ------------------------------
      mosi_i        : in std_logic;   -- Master Output/ Slave Input
      sclk_i        : in std_logic;   -- Serial Clock
      ccss_i        : in std_logic;   -- Clock Card Slave Select
      miso_o        : out std_logic;  -- Master Input/ Slave Output
      sreq_o        : out std_logic;  -- Service Request
      
      -- Obselete
      config_n_o    : out std_logic;
      epc16_sel_n_o : out std_logic
   );     
end psu_ctrl;

architecture top of psu_ctrl is

   constant STATUS_ADDR_WIDTH : integer := 6; 

   component tpram_32bit_x_64
      PORT
      (
         data     : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
         wraddress      : IN STD_LOGIC_VECTOR (STATUS_ADDR_WIDTH-1 DOWNTO 0);
         rdaddress_a    : IN STD_LOGIC_VECTOR (STATUS_ADDR_WIDTH-1 DOWNTO 0);
         rdaddress_b    : IN STD_LOGIC_VECTOR (STATUS_ADDR_WIDTH-1 DOWNTO 0);
         wren     : IN STD_LOGIC  := '1';
         clock    : IN STD_LOGIC ;
         qa    : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
         qb    : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
      );
   end component;
   
   signal row_order_wren    : std_logic;
   signal word_addr         : std_logic_vector(WB_DATA_WIDTH-1 downto 0);

   -- FSM inputs
   signal wr_cmd            : std_logic;
   signal rd_cmd            : std_logic;

   -- WBS states:
   type states is (IDLE, WR, RD1, RD2); 
   signal current_state     : states;
   signal next_state        : states;

   type out_states is (IDLE, SEL_FAC, SEL_APP, CONFIG_FAC, CONFIG_APP); 
   signal current_out_state : out_states;
   signal next_out_state    : out_states;

   signal config_n          : std_logic;
   signal epc16_sel_n       : std_logic;
   
begin

   status_ram : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => row_order_wren,
         wraddress         => tga_i(STATUS_ADDR_WIDTH-1 downto 0), --raw_addr_counter,         
         rdaddress_a       => word_addr(STATUS_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(STATUS_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         clock             => clk_i,
         qa                => open,
         qb                => open
      );

   ------------------------------------------------------------
   --  WB FSM
   ------------------------------------------------------------   

   -- clocked FSMs, advance the state for both FSMs
   state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         current_state     <= IDLE;
         current_out_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         current_state     <= next_state;
         current_out_state <= next_out_state;
      end if;
   end process state_FF;
   
   out_state_NS: process(current_out_state, config_n, epc16_sel_n)
   begin
      -- Default assignments
      next_out_state <= current_out_state;
      
      case current_out_state is
         when IDLE =>
            if(config_n = '0' and epc16_sel_n = '1') then
               next_out_state <= SEL_FAC;            
            elsif(config_n = '0' and epc16_sel_n = '0') then
               next_out_state <= SEL_APP;            
            end if;                  
            
         when SEL_FAC =>     
            next_out_state <= CONFIG_FAC;            

         when CONFIG_FAC =>     
            -- Stay in this state indefinately
         
         when SEL_APP =>     
            next_out_state <= CONFIG_APP;            

         when CONFIG_APP =>     
            -- Stay in this state indefinately

         when others =>
            next_out_state <= IDLE;

      end case;
   end process out_state_NS;

   out_state_out: process(current_out_state)
   begin
      -- Default assignments
      config_n_o    <= '1';  -- '0' triggers reconfiguration
      epc16_sel_n_o <= '1';  -- '1'=Factory, '0'=Application
     
      case current_out_state is         
         when IDLE  =>                   
            
         when SEL_FAC =>     
            epc16_sel_n_o <= '1';  -- '1'=Factory, '0'=Application
         
         when CONFIG_FAC =>     
            config_n_o    <= '0';  -- '0' triggers reconfiguration
            epc16_sel_n_o <= '1';  -- '1'=Factory, '0'=Application

         when SEL_APP =>     
            epc16_sel_n_o <= '0';  -- '1'=Factory, '0'=Application
         
         when CONFIG_APP =>     
            config_n_o    <= '0';  -- '0' triggers reconfiguration
            epc16_sel_n_o <= '0';  -- '1'=Factory, '0'=Application

         when others =>
         
      end case;
   end process out_state_out;

------------------------------------------------------------
--  WB FSM
------------------------------------------------------------   

--   -- clocked FSMs, advance the state for both FSMs
--   state_FF: process(clk_i, rst_i)
--   begin
--      if(rst_i = '1') then
--         current_state     <= IDLE;
--      elsif(clk_i'event and clk_i = '1') then
--         current_state     <= next_state;
--      end if;
--   end process state_FF;
   
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
               next_state <= RD1;
            end if;                  
            
         when WR =>     
            if(cyc_i = '0') then
               next_state <= IDLE;
            end if;
            
         when RD1 =>
            next_state <= RD2;

         when RD2 =>
            if(cyc_i = '0') then
               next_state <= IDLE;
            else
               next_state <= RD1;
            end if;           
         
         when others =>
            next_state <= IDLE;

      end case;
   end process state_NS;
   
   -- Output states for DAC controller   
   state_out: process(current_state, stb_i, addr_i)
   begin
      -- Default assignments
--      on_val_wren    <= '0';
--      off_val_wren   <= '0';
--      mux_en_wren    <= '0';
--      row_order_wren <= '0';
      ack_o          <= '0';
      
      case current_state is         
         when IDLE  =>                   
            ack_o <= '0';
            
         when WR =>
            ack_o <= '1';
            if(stb_i = '1') then
               if(addr_i = ON_BIAS_ADDR) then
--                  on_val_wren <= '1';
               elsif(addr_i = OFF_BIAS_ADDR) then
--                  off_val_wren <= '1';
               elsif(addr_i = ENBL_MUX_ADDR) then
--                  mux_en_wren <= '1';
               elsif(addr_i = ROW_ORDER_ADDR) then
--                  row_order_wren <= '1';
               end if;
            end if;
         
         -- implied that in RD1 ack_o is 0
         when RD2 =>
            ack_o <= '1';
         
         when others =>
         
      end case;
   end process state_out;

------------------------------------------------------------
--  Wishbone interface 
------------------------------------------------------------
   
   with addr_i select dat_o <=
--      on_data         when ON_BIAS_ADDR,
--      off_data        when OFF_BIAS_ADDR,
--      mux_en_data     when ENBL_MUX_ADDR,
--      row_order_data  when ROW_ORDER_ADDR,
      (others => '0') when others;
   
--   master_wait <= '1' when ( stb_i = '0' and cyc_i = '1') else '0';   
           
   rd_cmd  <= '1' when 
      (stb_i = '1' and cyc_i = '1' and we_i = '0') and 
      (addr_i = ON_BIAS_ADDR or addr_i = OFF_BIAS_ADDR or addr_i = ENBL_MUX_ADDR or addr_i = ROW_ORDER_ADDR) else '0'; 
      
   wr_cmd  <= '1' when 
      (stb_i = '1' and cyc_i = '1' and we_i = '1') and 
      (addr_i = ON_BIAS_ADDR or addr_i = OFF_BIAS_ADDR or addr_i = ENBL_MUX_ADDR or addr_i = ROW_ORDER_ADDR) else '0'; 

--   -- Transition table for DAC controller
--   state_NS: process(current_state, rd_cmd, wr_cmd, cyc_i)
--   begin
--      -- Default assignments
--      next_state <= current_state;
--      
--      case current_state is
--         when IDLE =>
--            if(wr_cmd = '1') then
--               next_state <= WR;            
--            elsif(rd_cmd = '1') then
--               next_state <= RD;
--            end if;                  
--            
--         when WR =>     
--            if(cyc_i = '0') then
--               next_state <= IDLE;
--            end if;
--         
--         when RD =>
--            if(cyc_i = '0') then
--               next_state <= IDLE;
--            end if;
--         
--         when others =>
--            next_state <= IDLE;
--
--      end case;
--   end process state_NS;
--   
--   -- Output states for DAC controller   
--   state_out: process(current_state, stb_i, addr_i)
--   begin
--      -- Default assignments
--      ack_o       <= '0';
--      config_n    <= '1';  -- '0' triggers reconfiguration
--      epc16_sel_n <= '1';  -- '1'=Factory, '0'=Application
--     
--      case current_state is         
--         when IDLE  =>                   
--            ack_o <= '0';
--            
--         when WR =>
--            ack_o <= '1';
--            if(stb_i = '1') then
--               if(addr_i = CONFIG_FAC_ADDR) then
--                  config_n    <= '0'; 
--                  epc16_sel_n <= '1';
--               elsif(addr_i = CONFIG_APP_ADDR) then
--                  config_n    <= '0'; 
--                  epc16_sel_n <= '0';  
--               end if;
--            end if;
--         
--         when RD =>
--            ack_o <= '1';
--         
--         when others =>
--         
--      end case;
--   end process state_out;
--
--   ------------------------------------------------------------
--   --  Wishbone interface: 
--   ------------------------------------------------------------  
--   dat_o <= (others => '0');
--   
----   master_wait <= '1' when ( stb_i = '0' and cyc_i = '1') else '0';   
--           
--   rd_cmd  <= '1' when 
--      (stb_i = '1' and cyc_i = '1' and we_i = '0') and 
--      (addr_i = CONFIG_FAC_ADDR or addr_i = CONFIG_APP_ADDR) else '0'; 
--      
--   wr_cmd  <= '1' when 
--      (stb_i = '1' and cyc_i = '1' and we_i = '1') and 
--      (addr_i = CONFIG_FAC_ADDR or addr_i = CONFIG_APP_ADDR) else '0'; 
      
end top;