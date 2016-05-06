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
-- servo_rst_ram_admin.vhd
--
-- Project:       MCE
-- original source: flux_quanta_ram_admin
-- Organisation:  UBC
--
-- Description:
-- 
-- This block instantiates the memory RAMs for each of the 8 channels of the
-- flux_loop_ctrl.  The memory banks are registered both at the inputs and the
-- outputs.  Therefore, a write cycle is complete on the next rising edge
-- of the clock after the address is valid.  However, a read cycle is only
-- complete after two clock cycles after the address is valid. (NOTE: that the
-- data can be read on the third clock rising edge)
--
-- Two control signals are also generated.
-- 1. The first one is the write enable signal for each memory bank.  These
-- signals are simply the we_i when the addr_i is equal to the address of that
-- memory bank.
-- 2. The second control signal is the ack_o.  This signal is generated
-- separtely for each of the write or read cycle.  A behavioural code is used
-- for simplicity where the idea is to generate the ack_o every other clock
-- cycles during a write and every two other clock cycles during a read.
--
-- Ports:
-- #clk_50_i: Golbal signal
-- #rst_i: Global signal
-- #servo_rst_dat_o:  servo_rst data for all 8 channels concatenated (1bit each)
-- #servo_rst_addr_ch0_i: Read address from flux_loop_ctrl channle0
-- #### Similarly for ch1 to ch7
-- #dat_i: Data in from Dispatch
-- #addr_i: Address from Dispatch showing the address of memory banks. This is
-- kept constant during a read or write cycle.
-- #tga_i: Address Tag from Dispatch.  This is incremented during a read or
-- write cycle.  Therefore, it is used as an index to the location in the
-- memory bank
-- #we_i: Write Enable input from Dispatch
-- #stb_i: Strobe signal from Dispatch.  Indicates if an address is valid or
-- not. See Wishbone manul page 54 and 57.  
-- #cyc_i: Input from Dispatch indicating a read or write cycle is in progress
-- #qa_bank_o: A MUX output of all the qa output of the memory banks for servo_rst
-- #ack_bank_o: A logical OR function of acknowledge signals for read or
-- write cycles of each memory bank
--
--
-- Revision history:
-- $Log $
--
--
------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

library work;

-- Call Parent Library
use work.frame_timing_pack.all;
use work.wbs_fb_data_pack.all;
use work.flux_loop_pack.all;
use work.readout_card_pack.all;

entity servo_rst_ram_admin is
  port (

    -- Global signals
    clk_50_i              : in std_logic;
    rst_i                 : in std_logic;
    
    -- Flux_Loop_Ctrl Channel Interface
    servo_rst_dat_o       : out std_logic_vector(NUM_COLS-1 downto 0);   
    addr_ch0_i            : in  std_logic_vector(SERVO_RST_ADDR_WIDTH-1 downto 0);      
    addr_ch1_i            : in  std_logic_vector(SERVO_RST_ADDR_WIDTH-1 downto 0);   
    addr_ch2_i            : in  std_logic_vector(SERVO_RST_ADDR_WIDTH-1 downto 0);   
    addr_ch3_i            : in  std_logic_vector(SERVO_RST_ADDR_WIDTH-1 downto 0);   
    addr_ch4_i            : in  std_logic_vector(SERVO_RST_ADDR_WIDTH-1 downto 0);   
    addr_ch5_i            : in  std_logic_vector(SERVO_RST_ADDR_WIDTH-1 downto 0);   
    addr_ch6_i            : in  std_logic_vector(SERVO_RST_ADDR_WIDTH-1 downto 0);   
    addr_ch7_i            : in  std_logic_vector(SERVO_RST_ADDR_WIDTH-1 downto 0);    

    servo_rst_dat2_o      : out std_logic_vector(NUM_COLS-1 downto 0);   
    addr2_ch0_i           : in  std_logic_vector(SERVO_RST_ADDR_WIDTH-1 downto 0);      
    addr2_ch1_i           : in  std_logic_vector(SERVO_RST_ADDR_WIDTH-1 downto 0);   
    addr2_ch2_i           : in  std_logic_vector(SERVO_RST_ADDR_WIDTH-1 downto 0);   
    addr2_ch3_i           : in  std_logic_vector(SERVO_RST_ADDR_WIDTH-1 downto 0);   
    addr2_ch4_i           : in  std_logic_vector(SERVO_RST_ADDR_WIDTH-1 downto 0);   
    addr2_ch5_i           : in  std_logic_vector(SERVO_RST_ADDR_WIDTH-1 downto 0);   
    addr2_ch6_i           : in  std_logic_vector(SERVO_RST_ADDR_WIDTH-1 downto 0);   
    addr2_ch7_i           : in  std_logic_vector(SERVO_RST_ADDR_WIDTH-1 downto 0);    

    -- Signals to/from dispatch  (wishbone interface)
    dat_i                 : in  std_logic_vector(WB_DATA_WIDTH-1 downto 0);       -- wishbone data in
    addr_i                : in  std_logic_vector(WB_ADDR_WIDTH-1 downto 0);       -- wishbone address in
    tga_i                 : in  std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);   -- Address Tag
    we_i                  : in  std_logic;                                        -- write//read enable
    stb_i                 : in  std_logic;                                        -- strobe 
    cyc_i                 : in  std_logic;                                        -- cycle
    
    -- Interface intended for dispatch
    wb_dat_o              : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    ack_bank_o            : out std_logic);  

end servo_rst_ram_admin;


architecture rtl of servo_rst_ram_admin is

  -----------------------------------------------------------------------------
  -- Signals from P Banks
  -----------------------------------------------------------------------------
  signal ack_read_bank  : std_logic;
  signal ack_write_bank : std_logic;

  signal tga_int : integer range 0 to 2**16;  
  signal dat : std_logic_vector(0 downto 0);
  type servo_rst_bank is array (0 to NUM_COLS-1) of std_logic_vector(MAX_NUM_OF_ROWS-1 downto 0);
  signal servo_rst_reg  : servo_rst_bank;
  signal servo_rst_reg1 : servo_rst_bank;
  signal wren           : servo_rst_bank;-- := ((others=> (others=>'0')));
  
begin  -- rtl

--  dat <= dat_i(0 downto 0);
  
  servo_rst_dat_o <= 
    servo_rst_reg1(7)(conv_integer(addr_ch7_i)) & servo_rst_reg1(6)(conv_integer(addr_ch6_i)) & servo_rst_reg1(5)(conv_integer(addr_ch5_i)) &
    servo_rst_reg1(4)(conv_integer(addr_ch4_i)) & servo_rst_reg1(3)(conv_integer(addr_ch3_i)) & servo_rst_reg1(2)(conv_integer(addr_ch2_i)) &
    servo_rst_reg1(1)(conv_integer(addr_ch1_i)) & servo_rst_reg1(0)(conv_integer(addr_ch0_i));
  
  servo_rst_dat2_o <= 
    servo_rst_reg1(7)(conv_integer(addr2_ch7_i)) & servo_rst_reg1(6)(conv_integer(addr2_ch6_i)) & servo_rst_reg1(5)(conv_integer(addr2_ch5_i)) &
    servo_rst_reg1(4)(conv_integer(addr2_ch4_i)) & servo_rst_reg1(3)(conv_integer(addr2_ch3_i)) & servo_rst_reg1(2)(conv_integer(addr2_ch2_i)) &
    servo_rst_reg1(1)(conv_integer(addr2_ch1_i)) & servo_rst_reg1(0)(conv_integer(addr2_ch0_i));

  
  -- servo_rst registers
  i_servo_rst: for i in 0 to NUM_COLS-1 generate
    i_servo_rst_reg: process (clk_50_i, rst_i)
    begin -- process i_servo_rst_reg
      if rst_i = '1' then
        servo_rst_reg (i) <= (others => '0');
        servo_rst_reg1 (i) <= (others => '0');

--      elsif clk_50_i'event and clk_50_i = '1' then -- rising clock edge  
--        if wren(i)(tga_int) = '1' then
--          servo_rst_reg (i)(tga_int) <= dat_i(0);
--          servo_rst_reg1 (i)(tga_int) <= dat_i(0);         
        --end if;
      end if;  
    end process i_servo_rst_reg;
  end generate i_servo_rst;
  
  tga_int <= conv_integer(tga_i);
  
    -----------------------------------------------------------------------------
  -- Controller for P Banks:
  -- 
  -- 1. Write Enable signals for each bank is equal to the dispatch we_i when
  -- the address from dispatch, addr_i, is equla to that bank's address
  --
  -- 2. Acknowledge signals are different for Write or Read cycle.
  -- 
  -- 2.1 Write Cycle:
  -- The acknowlege signal is asserted for one clock cycle on the first clock
  -- rising edge after seeing the stb_i, and repeats every other clock as long
  -- as stb_i is high.  Note that stb_i remains high if slave is asserting wait
  -- states, like our case here.  However, if the master is inserting a wait
  -- state, stb_i goes low on seeing acknowlege signal and comes back high when
  -- the master is ready.  We implement the Write acknowlege using a
  -- behavioural code.
  --
  -- 2.2 Read Cycle:
  -- The acknowlege signal is asserted for one clock cycle on the second clcok
  -- rising edge after seeing the stb_i, and repeats every 2 clock cycles as
  -- long as stb_i is high.  This is necessary as we use memory with registered
  -- outputs, and, thus, there are two clock cycles delay for the output to be
  -- ready on each read value.  We implement the Read acknowlege using a
  -- behavioural code.
  -----------------------------------------------------------------------------
  
  -----------------------------------------------------------------------------
  -- Write Enable Signals   
  gen_wren: for i in 0 to NUM_COLS-1 generate
    gen_wren_reg: process (clk_50_i, rst_i)
    begin
     if (rst_i = '1') then
        for j in 0 to MAX_NUM_OF_ROWS-1 loop
          wren(i)(j) <= '0';
        end loop;
        
      elsif clk_50_i'event and clk_50_i = '1' then       
        for j in 0 to MAX_NUM_OF_ROWS-1 loop
          if j=tga_int then
            if (i=0 and addr_i = SERVO_RST_COL0_ADDR) or            
               (i=1 and addr_i = SERVO_RST_COL1_ADDR) or
               (i=2 and addr_i = SERVO_RST_COL2_ADDR) or
               (i=3 and addr_i = SERVO_RST_COL3_ADDR) or
               (i=4 and addr_i = SERVO_RST_COL4_ADDR) or
               (i=5 and addr_i = SERVO_RST_COL5_ADDR) or
               (i=6 and addr_i = SERVO_RST_COL6_ADDR) or
               (i=7 and addr_i = SERVO_RST_COL7_ADDR) then               
              wren(i)(j) <= we_i;
            else
              wren(i)(j) <= '0';          
            end if;  
          else
            wren(i)(j) <= '0';            
          end if;-- tga_int
        end loop;
      end if; -- clk
    end process gen_wren_reg;
  end generate gen_wren;  
  
      
--  wren(0)(tga_int) <= we_i when addr_i = SERVO_RST_COL0_ADDR else '0';
--  wren(1)(tga_int) <= we_i when addr_i = SERVO_RST_COL1_ADDR else '0';
--  wren(2)(tga_int) <= we_i when addr_i = SERVO_RST_COL2_ADDR else '0';
--  wren(3)(tga_int) <= we_i when addr_i = SERVO_RST_COL3_ADDR else '0';
--  wren(4)(tga_int) <= we_i when addr_i = SERVO_RST_COL4_ADDR else '0';
--  wren(5)(tga_int) <= we_i when addr_i = SERVO_RST_COL5_ADDR else '0';
--  wren(6)(tga_int) <= we_i when addr_i = SERVO_RST_COL6_ADDR else '0';
--  wren(7)(tga_int) <= we_i when addr_i = SERVO_RST_COL7_ADDR else '0';

  -----------------------------------------------------------------------------
  -- Acknowlege signals
  i_gen_ack: process (clk_50_i, rst_i)
    
    variable count : integer := 0;           -- counts number of clock cycles passed
    
  begin  -- process i_gen_ack
    if rst_i = '1' then                 -- asynchronous reset (active high)
       ack_read_bank  <= '0';
       ack_write_bank <= '0';
       count:=0;
      
      
    elsif clk_50_i'event and clk_50_i = '1' then  -- rising clock edge
      
      -- Write Acknowledge
      if (we_i='1') and (
         (addr_i = SERVO_RST_COL0_ADDR) or
         (addr_i = SERVO_RST_COL1_ADDR) or
         (addr_i = SERVO_RST_COL2_ADDR) or
         (addr_i = SERVO_RST_COL3_ADDR) or
         (addr_i = SERVO_RST_COL4_ADDR) or
         (addr_i = SERVO_RST_COL5_ADDR) or
         (addr_i = SERVO_RST_COL6_ADDR) or
         (addr_i = SERVO_RST_COL7_ADDR)) then
        
         if (stb_i='1') and (ack_write_bank='0') then
            ack_write_bank <= '1';
         else
            ack_write_bank <= '0';
         end if;
      else
         ack_write_bank <= '0';
      end if;
      
      -- Read Acknowledge
      if (we_i='0') and (
         (addr_i = SERVO_RST_COL0_ADDR) or
         (addr_i = SERVO_RST_COL1_ADDR) or
         (addr_i = SERVO_RST_COL2_ADDR) or
         (addr_i = SERVO_RST_COL3_ADDR) or
         (addr_i = SERVO_RST_COL4_ADDR) or
         (addr_i = SERVO_RST_COL5_ADDR) or
         (addr_i = SERVO_RST_COL6_ADDR) or
         (addr_i = SERVO_RST_COL7_ADDR)) then
        
         if (stb_i='1') and (ack_read_bank='0') then
            count:=count+1;
            if count=2 then
               ack_read_bank <= '1';
               count:=0;
            else 
               ack_read_bank <= '0';
            end if;
            
         else
            ack_read_bank <= '0';
         end if;
        
        
      else
         ack_read_bank <= '0';        
      end if;

      
    end if;
  end process i_gen_ack;

 -----------------------------------------------------------------------------
  -- Output MUX to Dispatch:
  -- 
  -- 1. addr_i selects which bank is sending its output to the dispatch.  The
  -- defulat connection is to ch0.
  --
  -- 2. Acknowlege is ORing of the write and read cycle
  -----------------------------------------------------------------------------

  ack_bank_o <= ack_write_bank or ack_read_bank;
  
  wb_dat_o (wb_dat_o'length-1 downto 1) <= (others => '0');
--  wb_dat_o (0) <= servo_rst_reg(0)(tga_int) when addr_i = SERVO_RST_COL0_ADDR else
--                  servo_rst_reg(1)(tga_int) when addr_i = SERVO_RST_COL1_ADDR else
--                  servo_rst_reg(2)(tga_int) when addr_i = SERVO_RST_COL2_ADDR else
--                  servo_rst_reg(3)(tga_int) when addr_i = SERVO_RST_COL3_ADDR else
--                  servo_rst_reg(4)(tga_int) when addr_i = SERVO_RST_COL4_ADDR else
--                  servo_rst_reg(5)(tga_int) when addr_i = SERVO_RST_COL5_ADDR else
--                  servo_rst_reg(6)(tga_int) when addr_i = SERVO_RST_COL6_ADDR else
--                  servo_rst_reg(7)(tga_int) when addr_i = SERVO_RST_COL7_ADDR else
--                  servo_rst_reg(0)(tga_int); -- default to ch0
    
end rtl;
