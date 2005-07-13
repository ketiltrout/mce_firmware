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
-- eeprom_wbs.vhd
--
-- Project:	  SCUBA-2
-- Author:        Mandana Amiri
-- Organisation:  UBC
--
-- Description: 
-- This block is a wishbone slave that handles the following EEPROM commands:
-- EEPROM_ADDR and EEPROM_SRT_ADDR
-- When reading an eeprom, it just passes the data from eeprom_admin to dispatch,
-- but when writing the data to eeprom, it buffers 64 values and then hands the 
-- the full 64-byte page to eeprom_admin.
--
-- Ports:
-- read_rq_o : indicates a read request to eeprom_admin block
-- write_rq_o: indicates a write request to eeprom_admin block   
-- ee_dat_o  : outgoing data to be written to eeprom_admin block     
-- ee_dat_stb_o: strobe for outgoing data to be written to eeprom_admin block 
-- start_addr_o: outgoing start_addr to eeprom_admin block
-- ee_dat_stb_i: strobe for incoming data from eeprom_admin block
-- ee_dat_i    : incoming data from eeprom_admin block     
--
-- dat_i:  incoming data from dispatch block
-- addr_i: wishbone address from dispatch block,kept constant during a read or write cycle.
-- tga_i:  address tag from dispatch block, incremented during a read or write cycle
-- we_i:   write Enable input from dispatch block
-- stb_i:  strobe signal from dispatch block, indicating a valid address.
-- (See Wishbone manual page 54 and 57)
-- cyc_i:  input from dispatch block indicating a read or write cycle in progress
-- dat_o:  outgoing data to dispatch block.
-- ack_o:  ack signal to dispatch block, asserted when data is grabbed
-- (Deasserting the ack is used to slow down the dispatch block)
--
-- Revision history:
-- <date $Date$>    - <initails $Author$>
-- $Log$
--
------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


library work;
use work.eeprom_ctrl_pack.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;



entity eeprom_wbs is
  
   port (

      -- Global signals
      rst_i                   : in std_logic;
      clk_50_i                : in std_logic;

      -- signals to/from eeprom_admin
      read_req_o              : out std_logic;                                       -- trigger a read from eeprom
      write_req_o             : out std_logic;                                       -- trigger a write to eeprom    
      hold_cs_o               : out std_logic;                                       -- indicates whether eeprom_admin should hold the cs low for more reads and writes
      ee_dat_o                : out std_logic_vector(EEPROM_DATA_WIDTH-1 downto 0);  -- data to be written in eeprom
      ee_dat_stb_o            : out std_logic;                                       -- strobe for data written to eeprom
      
      start_addr_o            : out std_logic_vector(EEPROM_ADDR_WIDTH-1 downto 0);  -- start_address for read or write  

      ee_busy_i               : in  std_logic;                                       -- indicates eeprom busy 
      
      ee_dat_i                : in  std_logic_vector(EEPROM_DATA_WIDTH-1 downto 0);  -- data read from eeprom
      ee_dat_stb_i            : in  std_logic;                                       -- strobe for data read from eeprom
      
      -- signals to/from dispatch  (wishbone interface)
      dat_i                   : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);       -- wishbone data in
      addr_i                  : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);       -- wishbone address in
      tga_i                   : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);   -- 
      we_i                    : in std_logic;                                        -- write//read enable
      stb_i                   : in std_logic;                                        -- strobe 
      cyc_i                   : in std_logic;                                        -- cycle
      dat_o 	              : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);      -- data out
      ack_o                   : out std_logic                                        -- acknowledge out
   ); 
end eeprom_wbs;


architecture rtl of eeprom_wbs is

   type ee_data_bank is array (0 to EE_PAGE_SIZE-1) of std_logic_vector(EEPROM_DATA_WIDTH-1 downto 0);
   signal reg : ee_data_bank;
   
   type wren_banks is array (0 to EE_PAGE_SIZE-1) of std_logic;
   signal wren : wren_banks;
   
   signal ix                  : std_logic_vector(EE_MAX_BIT_TAG downto 0);
   signal clr_ix              : std_logic;
   signal inc_ix_en           : std_logic;
   signal start_addr_reg      : std_logic_vector(EEPROM_ADDR_WIDTH-1 downto 0);
   signal wren_start_addr_reg : std_logic;
   signal ee_data_justread_reg: std_logic_vector(EEPROM_DATA_WIDTH-1 downto 0);
   signal read_req            : std_logic;
   signal write_req           : std_logic;
   signal read_req_reg        : std_logic;
   signal write_req_reg       : std_logic;
    
   signal ack_eeprom          : std_logic;
    
   -- WB slave controller FSM
   type state is (IDLE, RD, ACK_DATA, WR, WS1, WS2, WAIT_FOR_ACK);                           

   signal current_state: state;
   signal next_state:    state;
   
begin  -- rtl

   -- instantiate set of registers to hold one page of incoming data from wishbone
   i_ee_data_bank: for i in 0 to EE_PAGE_SIZE-1 generate
      i_reg: process (clk_50_i, rst_i)
      begin  -- process i_reg
         if rst_i = '1' then               
            reg(i) <= (others => '0');            -- initialize to zero
         elsif clk_50_i'event and clk_50_i = '1' then 
            if wren(i)='1' then
               reg(i) <= dat_i(EEPROM_DATA_WIDTH-1 downto 0);
            end if;
         end if;
      end process i_reg;
   end generate i_ee_data_bank;
   
   -- index counter for ee_data_bank registers
   i_count_ix: process (clk_50_i, rst_i)
   begin 
      if rst_i = '1' then                
         ix <= (others => '0');
      elsif clk_50_i'event and clk_50_i = '1' then  
         if (clr_ix = '1') then
            ix <= (others => '0');
         elsif (inc_ix_en = '1') then
            if (ix < EE_PAGE_SIZE - 1) then 
               ix <= ix +1;
            else
               ix <= (others => '0');
            end if;   
         end if;       
      end if;
   end process i_count_ix;
   
   ------------------------------------------------------------
   --  More Registers
   ------------------------------------------------------------      
      
   -- instantiate register for start_address of eeprom data to be read/written   
   i_reg: process (clk_50_i, rst_i)
   begin  
      if rst_i = '1' then            
         start_addr_reg <= (others => '0');
      elsif clk_50_i'event and clk_50_i = '1' then 
         if wren_start_addr_reg ='1' then
            start_addr_reg <= dat_i(EEPROM_ADDR_WIDTH-1 downto 0);
         end if;
      end if;
   end process i_reg;      
   
   wren_start_addr_reg <= we_i when addr_i = EEPROM_SRT_ADDR else '0';

   -- instantiate one register for the value read from eeprom
   i_ee_data_reg: process (clk_50_i, rst_i)
   begin
      if rst_i = '1' then
         ee_data_justread_reg  <= (others => '0');   -- initialize to zero
      elsif clk_50_i'event and clk_50_i = '1' then
         if ee_dat_stb_i = '1' then
            ee_data_justread_reg <= ee_dat_i;
         end if;
      end if;
   end process i_ee_data_reg;   
       
   -- instantiate registers for read_req and write_req to clean out glitches
   i_request_reg: process (clk_50_i, rst_i)
   begin  
      if rst_i = '1' then            
         read_req_reg  <= '0';
         write_req_reg <= '0';
      elsif clk_50_i'event and clk_50_i = '1' then 
         read_req_reg  <= read_req;
         write_req_reg <= write_req;
      end if;
   end process i_request_reg; 
   
   read_req_o  <= read_req_reg;
   write_req_o <= write_req_reg;
         
   ------------------------------------------------------------
   --  WB Slave FSM
   ------------------------------------------------------------      
   state_FF: process(clk_50_i, rst_i)
   begin
      if(rst_i = '1') then
         current_state     <= IDLE;
      elsif(clk_50_i'event and clk_50_i = '1') then
         current_state     <= next_state;
      end if;
   end process state_FF;
   
   -- next_state FSM
   state_NS: process(current_state, stb_i, cyc_i, we_i, addr_i, tga_i, ee_dat_stb_i, ee_busy_i)
   begin
      next_state <= current_state;
      
      case current_state is
         when IDLE =>
            if (stb_i = '1' and cyc_i = '1' and we_i = '0' and addr_i = EEPROM_ADDR) then
               next_state <= RD;            
            end if;                  
            if (stb_i = '1' and cyc_i = '1' and we_i = '1' and addr_i = EEPROM_ADDR) then
	       next_state <= WR;            
            end if;                  
   
         when RD =>   
            if (cyc_i = '0') then 
               next_state <= IDLE;            
            elsif (ee_dat_stb_i = '1') then
               next_state <= ACK_DATA;
            end if;  
            
         when ACK_DATA =>   
            if (cyc_i = '0') then
               next_state <= IDLE;
            else 
               next_state <= RD;
            end if;
                     
         when WR =>
            if (cyc_i = '0') then
               next_state <= IDLE;
            elsif(stb_i = '1') then
               if (tga_i(EE_MAX_BIT_TAG downto 0 ) = EE_PAGE_SIZE ) then
                  next_state <= WAIT_FOR_ACK;
               else
                  next_state <= WS1;                             
               end if;   
            end if;   
                                 
         when WS1 =>
            if (cyc_i = '1') then
               next_state <= WS2;
            end if;   
         
         when WS2 =>
            next_state <= WR;
            
         when WAIT_FOR_ACK =>
            if (ee_busy_i = '0') then
              if (cyc_i = '1') then
                 next_state <= WS1;
              end if;   
            end if;
         
         when others =>
            next_state <= IDLE;

      end case;
   end process state_NS;
   
   -- Output states for eeprom controller
   state_out: process(current_state,ix,  reg, tga_i, we_i, stb_i, cyc_i, ee_busy_i) 
   begin
      -- Default assignments
      read_req         <= '0';
      write_req        <= '0';
      hold_cs_o        <= '0';
      
      ee_dat_stb_o     <= '0';
      ee_dat_o         <= (others => '0');
      clr_ix           <= '0';
      inc_ix_en        <= '0';
      ack_eeprom       <= '0';
      
      
      gen_reset_wren: for j in 0 to EE_PAGE_SIZE-1 loop
        wren(j)        <= '0';
      end loop;
           
      case current_state is         
         when IDLE  =>                   
            clr_ix          <= '1';
            
         when RD =>
            if (cyc_i = '1') then
               hold_cs_o       <= '1';
               if (stb_i = '1') then
                  read_req     <= '1';    
               end if;               
            end if;
                       
         when ACK_DATA =>
            read_req        <= '0';
            if (cyc_i = '1') then 
               hold_cs_o       <= '1';
            end if;   
            ack_eeprom      <= (stb_i and cyc_i) and not(ee_busy_i);
                        
         when WR =>
            write_req       <= '1';
            if (stb_i = '1') then
               wren(conv_integer(tga_i(EE_MAX_BIT_TAG-1 downto 0))) <= we_i;
               inc_ix_en    <= '1';
            end if;   

         when WS1 =>
            inc_ix_en       <= '0';
            write_req       <= '1';
            ee_dat_stb_o    <= '1';  
            if (ix = 0) then
               ee_dat_o     <= reg(EE_PAGE_SIZE-1);
            else   
               ee_dat_o     <= reg(conv_integer(ix)-1);
            end if;   

            ack_eeprom      <= (stb_i and cyc_i) and not(ee_busy_i);
       
         when WS2 =>
            write_req       <= '1';

         when WAIT_FOR_ACK =>
            write_req       <= '1';
         
         when others =>
            null;
            
      end case;
   end process state_out;
   
   
   -- Acknowlege signal  
   with addr_i select
     ack_o <=
        (stb_i and cyc_i) when EEPROM_SRT_ADDR,
        ack_eeprom when EEPROM_ADDR,
        '0'               when others;

   -- Wishbone output to dispatch     
      dat_o <= x"000000" & ee_data_justread_reg;
         
   -- Outputs to eeprom_admin block
   start_addr_o <= start_addr_reg;
   
   
end rtl;
