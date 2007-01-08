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
-- <revision control keyword substitutions e.g. $Id: sram_ctrl.vhd,v 1.6 2006/12/22 23:49:30 mandana Exp $>
--
-- Project:       SCUBA-2
-- Author:         Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Wishbone slave for asynch. SRAM chip interface 
-- The sram controller slave controls 32-bit access to two 
-- 1Mx16b CY7C1061AV33 on-board SRAM chips. 
-- This slave handles 2 wishbone commands: SRAM_ADDR_ADDR and
-- SRAM_DATA_ADDR. 
--
-- SRAM_ADDR_ADDR is used to specify a memory base address to
-- read and write from.
--
-- SRAM_DATA_ADDR is used to read/write sequential data from 
-- SRAM starting from base address.
-- 
-- The adress to access memory is generated directly from wishbone 
-- tga_i lines added to the base address.
-- 
-- The on-board chips have an access of 10ns which amounts to 
-- half clock cycle accounted for in the wishbone read cycle. 
-- 
--
-- Revision history:
-- <date $Date: 2006/12/22 23:49:30 $> -     <text>      - <initials $Author: mandana $>
-- $Log: sram_ctrl.vhd,v $
-- Revision 1.6  2006/12/22 23:49:30  mandana
-- access sram modules as a 32b bank
--
-- Revision 1.5  2004/04/21 19:58:28  bburger
-- Changed address moniker
--
-- Revision 1.4  2004/03/19 22:44:42  erniel
-- Minor change: Tristated addr and data bus when not in use
--
-- Revision 1.2  2004/03/19 22:40:18  erniel
-- Minor change: Tristated addr and data bus when not in use
--

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
port(-- SRAM signals:
     addr_o  : out std_logic_vector(19 downto 0);
     data_bi : inout std_logic_vector(31 downto 0);
     n_ble_o : out std_logic;
     n_bhe_o : out std_logic;
     n_oe_o  : out std_logic;
     n_ce1_o : out std_logic;
     ce2_o   : out std_logic;
     n_we_o  : out std_logic;
     
     -- wishbone signals:
     clk_i   : in std_logic;
     rst_i   : in std_logic;     
     dat_i   : in std_logic_vector (WB_DATA_WIDTH-1 downto 0);
     addr_i  : in std_logic_vector (WB_ADDR_WIDTH-1 downto 0);
     tga_i   : in std_logic_vector (WB_TAG_ADDR_WIDTH-1 downto 0);
     we_i    : in std_logic;
     stb_i   : in std_logic;
     cyc_i   : in std_logic;
     dat_o   : out std_logic_vector (WB_DATA_WIDTH-1 downto 0);
     ack_o   : out std_logic);     
end sram_ctrl;

architecture behav of sram_ctrl is

-- SRAM controller:
-- State encoding and state variables:
type states is (IDLE, WRITE_DATA, WRITE_DONE, READ_DATA, SEND_DATA, READ_DONE);
signal present_state : states;
signal next_state    : states;

-- Outputs:
signal sram_wdata      : std_logic_vector(31 downto 0);
signal sram_rdata      : std_logic_vector(31 downto 0);
signal sram_wdata_wren : std_logic;
signal sram_rdata_wren : std_logic;
signal sram_addr_wren  : std_logic;
signal addr_reg        : std_logic_vector(19 downto 0);

-- Wishbone signals (decoded):
signal master_wait : std_logic;       -- active during master-initiated wait state
signal read_cmd    : std_logic;       -- indicates read command received
signal write_cmd   : std_logic;       -- indicates write command received
signal ack_read    : std_logic;
signal ack_write   : std_logic;

-- base-address register
signal base_addr      : std_logic_vector(19 downto 0);
signal base_addr_wren : std_logic;

begin

------------------------------------------------------------
--
--  SRAM controller
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
   
   
   state_NS: process(present_state, master_wait, read_cmd, write_cmd)
   begin
      next_state <= present_state;
      case present_state is
         when IDLE =>        if(write_cmd = '1') then
                                next_state <= WRITE_DATA;
                             elsif(read_cmd = '1') then
                                next_state <= READ_DATA;
                             else
                                next_state <= IDLE;
                             end if;
                            
         when WRITE_DATA =>   next_state <= WRITE_DONE;         
         
         when WRITE_DONE =>  if(write_cmd = '1') then
                                next_state <= WRITE_DATA;
                             elsif(master_wait = '1') then
                                next_state <= WRITE_DONE;
                             else
                                next_state <= IDLE;
                             end if;
                  
         when READ_DATA =>   next_state <= SEND_DATA;
         
         when SEND_DATA =>   next_state <= READ_DONE;
         
         when READ_DONE =>   if(read_cmd = '1') then
                                next_state <= READ_DATA;
                             elsif(master_wait = '1') then
                                next_state <= READ_DONE;
                             else
                                next_state <= IDLE;
                             end if;               
         
         when others =>      next_state <= IDLE;
                             
      end case;
   end process state_NS;
   
   
   state_out: process(present_state)
   begin
      -- default 
      n_we_o <= '1';
      sram_rdata_wren <= '0';

      case present_state is                
         when WRITE_DATA => 
            n_we_o <= '0';
         
         when READ_DATA =>
            sram_rdata_wren <= '1';
            
         when SEND_DATA =>
            sram_rdata_wren <= '1';
           
         when others =>
            null;
          
      end case;
   end process state_out;   

   -------------------------------------------------------------      
   -- Driving control Signals.
   --
   -- Default drive for control signals 
   -- ce2_o = 1 : always
   -- nOE   = 0 : always   
   -- nBHE = nBLE = 0 : always 16b data access   
   -------------------------------------------------------------
   n_ble_o <= '0';
   n_bhe_o <= '0';
   n_oe_o  <= '0';
   ce2_o   <= '1';
   
   -- gen n_ce1
   i_gen_n_ce: process(rst_i, clk_i)
   begin
      if (rst_i = '1') then
         n_ce1_o <= '1';
      elsif(clk_i'event and clk_i = '1') then
         if (addr_i = SRAM_DATA_ADDR) then
            n_ce1_o <= '0';
         else 
            n_ce1_o <= '1';
         end if;   
      end if; 
   end process i_gen_n_ce;

   -------------------------------------------------------------      
   -- Driving address and data lines and corresponding registers
   -- seperate registers for read datapath and write datapath
   -------------------------------------------------------------      
   
   addr_o  <= addr_reg;
   data_bi <= sram_wdata when write_cmd = '1' else (others=> 'Z'); 
   
   -- register sram data for read back and write seperately
   i_sram_data_reg: process (rst_i, clk_i)
   begin 
      if (rst_i = '1') then
         sram_rdata <= (others=> '0');
         sram_wdata <= (others=> '0');
      elsif (clk_i'event and clk_i = '1') then
         if (sram_rdata_wren = '1') then
            sram_rdata <= data_bi;
         elsif (write_cmd = '1') then
            sram_wdata <= dat_i;            
         end if;   
      end if;
   end process i_sram_data_reg;  

   -- generate address; MA: looks like there is no need to register address
--   i_addr_gen: process (rst_i, clk_i)
--   begin 
--      if (rst_i = '1') then
--         addr_reg <= (others=> '0');
--      elsif (clk_i'event and clk_i = '1') then
         --if (sram_addr_wren = '1') then
            addr_reg <= base_addr + tga_i (19 downto 0);
         --end if;
--      end if;
--   end process i_addr_gen;  
 
------------------------------------------------------------
--
--  Wishbone interface 
--
------------------------------------------------------------
   
   -- wishbone acknowlege signals
   -- gen_ack mechanism was copied from readout_card wb slaves (e.g. p_bamks_admin and)
   i_gen_ack: process (rst_i, clk_i)
       variable count : integer;          -- counts number of clock cycles passed

   begin  -- process i_gen_ack
      if rst_i = '1' then                 -- asynchronous reset (active high)
         ack_write  <= '0'; 
         ack_read   <= '0';
         count := 0;
      elsif clk_i'event and clk_i = '1' then  -- rising clock edge      
         -- Write Acknowledge
         if (we_i='1') and ((addr_i= SRAM_ADDR_ADDR) or (addr_i= SRAM_DATA_ADDR)) then        
            if (stb_i='1') and (ack_write ='0') then
               ack_write <= '1';
            else
               ack_write <= '0';
            end if;
         else
            ack_write <= '0';
         end if;
         
         -- Read Acknowledge
         if (we_i='0') and ((addr_i= SRAM_ADDR_ADDR) or (addr_i= SRAM_DATA_ADDR)) then
            if (stb_i='1') and (ack_read ='0') then
               count:=count+1;
               if (addr_i = SRAM_ADDR_ADDR) then
                  ack_read <= '1';
               elsif count=2 then
                  ack_read <= '1';
                  count:=0;
               end if;
            else
               ack_read <= '0';
            end if;                
         else
            ack_read <= '0';
         end if;
         
      end if;
      
   end process i_gen_ack;

--   ack_read_write <= (stb_i and cyc_i) when (addr_i = SRAM_ADDR_ADDR or addr_i=SRAM_DATA_ADDR) else '0';
   ack_o <= ack_read or ack_write;
    
   -- wishbone readback data
   with addr_i select
   dat_o <= sram_rdata             when SRAM_DATA_ADDR,
            (x"000" & base_addr)   when SRAM_ADDR_ADDR,
            (others => '0')        when others;
   
   -- decoded wishbone signals for read/write sram content
   master_wait <= '1' when (addr_i = SRAM_DATA_ADDR and stb_i = '0' and cyc_i = '1') else '0';   
   read_cmd    <= '1' when (addr_i = SRAM_DATA_ADDR and stb_i = '1' and cyc_i = '1' and we_i = '0') else '0';
   write_cmd   <= '1' when (addr_i = SRAM_DATA_ADDR and stb_i = '1' and cyc_i = '1' and we_i = '1') else '0'; 
   
   
   -- generate write signals for base_address and absolute address of sram acess
   i_gen_wren: process (addr_i, we_i)
   begin      
      -- default states
      base_addr_wren <= '0';
      sram_addr_wren <= '0';
    
      case addr_i is
         when SRAM_ADDR_ADDR =>
            base_addr_wren <= we_i;

         when SRAM_DATA_ADDR =>
            sram_addr_wren <= '1';

         when others => null;
                      
      end case;
   end process i_gen_wren;
  
   -- base_addr register   
   i_base_addr: process (rst_i, clk_i)
   begin 
      if (rst_i = '1') then
         base_addr <= (others=> '0');
      elsif (clk_i'event and clk_i = '1') then
         if (base_addr_wren = '1') then 
            base_addr <= dat_i(19 downto 0);
         end if;
      end if;
   end process i_base_addr;  

end behav;