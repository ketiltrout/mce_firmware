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
-- adc_offset_banks_admin.vhd
--
-- Project:	  SCUBA-2
-- Author:        Mohsen Nahvi
-- Organisation:  UBC
--
-- Description:
-- 
-- This block instantiates the adc_offset memory RAMs for each 8 channel of the
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
-- #adc_offset_dat_ch0_o: adc_offset Data for flux_loop_ctrl channel0
-- #adc_offset_addr_ch0_i: Read address from flux_loop_ctrl channle0
-- #### Similarly for ch1 to ch7
-- #dat_i: Data in from Dispatch
-- #addr_i: Address from Dispatch showing the address of memory banks. This is
-- kept constant during a read or write cycle.
-- #tga_i: Address Tag from Dispatch.  This is incremented during a read or
-- write cycle.  Therefore, it is used as an index to the location in the
-- memory bank
-- #we_i: Write Enable input from Dispatch.
-- #stb_i: Strobe signal from Dispatch.  Indicates if an address is valid or
-- not. See Wishbone manul page 54 and 57.  
-- #cyc_i: Input from Dispatch indicating a read or write cycle is in progress
-- #qa_adc_offset_bank_o: A MUX output of all the qa output of the memory banks for
-- adc_offset.
-- #ack_adc_offset_bank_o: A logical OR function of acknowledge signals for read or
-- write cycles of each memory bank.
--
--
--
-- Revision history:
-- 
-- $Log: adc_offset_banks_admin.vhd,v $
-- Revision 1.5  2008/07/08 21:59:13  mandana
-- incomplete if statement for ack_read_bank is fixed.
-- count is set to 0 as a start value.
--
-- Revision 1.4  2006/09/22 20:16:52  mandana
-- enabled adc_offset read back by connecting porta for dispatch read
--
-- Revision 1.3  2004/12/17 00:41:36  mohsen
-- To reduce memory requirements, the p/i/d/z and adc_offset values are not readable by the Dispatch.
-- To limit changes, still using 3-port RAM but leave one output port open and ground the output to Dispatch.
-- This synthesizes into one true dual port, similar to the ideal case of having a 2-port.
--
-- Revision 1.2  2004/11/26 18:28:35  mohsen
-- Anthony & Mohsen: Restructured constant declaration.  Moved shared constants from lower level package files to the upper level ones.  This was done to resolve compilation error resulting from shared constants defined in multiple package files.
--
-- Revision 1.1  2004/11/20 01:22:02  mohsen
-- Initial release
--
--
--
------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

library work;

-- Call Parent Library
use work.wbs_fb_data_pack.all;
use work.flux_loop_pack.all;


entity adc_offset_banks_admin is
  
  port (

    -- Global signals
    clk_50_i                : in std_logic;
    rst_i                   : in std_logic;

    -- PER Flux_Loop_Ctrl Channel Interface
    adc_offset_dat_ch0_o    : out std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
    adc_offset_addr_ch0_i   : in  std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
    adc_offset_dat_ch1_o    : out std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
    adc_offset_addr_ch1_i   : in  std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
    adc_offset_dat_ch2_o    : out std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
    adc_offset_addr_ch2_i   : in  std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
    adc_offset_dat_ch3_o    : out std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
    adc_offset_addr_ch3_i   : in  std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
    adc_offset_dat_ch4_o    : out std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
    adc_offset_addr_ch4_i   : in  std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
    adc_offset_dat_ch5_o    : out std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
    adc_offset_addr_ch5_i   : in  std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
    adc_offset_dat_ch6_o    : out std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
    adc_offset_addr_ch6_i   : in  std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
    adc_offset_dat_ch7_o    : out std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
    adc_offset_addr_ch7_i   : in  std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);

    -- signals to/from dispatch  (wishbone interface)
    dat_i                   : in  std_logic_vector(WB_DATA_WIDTH-1 downto 0);       -- wishbone data in
    addr_i                  : in  std_logic_vector(WB_ADDR_WIDTH-1 downto 0);       -- wishbone address in
    tga_i                   : in  std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);   -- Address Tag
    we_i                    : in  std_logic;                                        -- write//read enable
    stb_i                   : in  std_logic;                                        -- strobe 
    cyc_i                   : in  std_logic;                                        -- cycle
 
    -- Interface intended for dispatch
    qa_adc_offset_bank_o   : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    ack_adc_offset_bank_o  : out std_logic);
  

end adc_offset_banks_admin;



architecture rtl of adc_offset_banks_admin is

  -----------------------------------------------------------------------------
  -- Signals from adc_offset Banks
  -----------------------------------------------------------------------------
  signal qa_adc_offset_bank_ch0 : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal qa_adc_offset_bank_ch1 : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal qa_adc_offset_bank_ch2 : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal qa_adc_offset_bank_ch3 : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal qa_adc_offset_bank_ch4 : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal qa_adc_offset_bank_ch5 : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal qa_adc_offset_bank_ch6 : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal qa_adc_offset_bank_ch7 : std_logic_vector(WB_DATA_WIDTH-1 downto 0);

  -- These signals are needed to match the width of the memory with that of the
  -- output data of adc_offset values
  signal adc_offset_dat_ch0 : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal adc_offset_dat_ch1 : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal adc_offset_dat_ch2 : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal adc_offset_dat_ch3 : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal adc_offset_dat_ch4 : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal adc_offset_dat_ch5 : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal adc_offset_dat_ch6 : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal adc_offset_dat_ch7 : std_logic_vector(WB_DATA_WIDTH-1 downto 0);

  
  -----------------------------------------------------------------------------
  -- Signals from adc_offset Controller
  -----------------------------------------------------------------------------
  signal wren_adc_offset_bank_ch0  : std_logic;
  signal wren_adc_offset_bank_ch1  : std_logic;
  signal wren_adc_offset_bank_ch2  : std_logic;
  signal wren_adc_offset_bank_ch3  : std_logic;
  signal wren_adc_offset_bank_ch4  : std_logic;
  signal wren_adc_offset_bank_ch5  : std_logic;
  signal wren_adc_offset_bank_ch6  : std_logic;
  signal wren_adc_offset_bank_ch7  : std_logic;
  signal ack_read_adc_offset_bank  : std_logic;
  signal ack_write_adc_offset_bank : std_logic;


  
begin  -- rtl


  -----------------------------------------------------------------------------
  -- Instantiation of adc_offset Banks
  -----------------------------------------------------------------------------

  i_adc_offset_bank_ch0 : wbs_fb_storage
    port map (
    data        => dat_i,                             -- from dispatch
    wraddress   => tga_i(PIDZ_ADDR_WIDTH-1 downto 0), -- from dispatch
    rdaddress_a => tga_i(PIDZ_ADDR_WIDTH-1 downto 0), -- from dispatch
    rdaddress_b => adc_offset_addr_ch0_i,             -- from flux_loop_ctrl ch0
    wren        => wren_adc_offset_bank_ch0,          -- from controller
    clock       => clk_50_i,                          -- global input
    qa          => qa_adc_offset_bank_ch0,            
    qb          => adc_offset_dat_ch0);               -- to flux_loop_ctrl ch0
  

  -- qa_adc_offset_bank_ch0 <= (others => '0');   -- Decided not to have access through
                                               -- dispatch. However, still use 3-port
                                               -- ram to limit changes.
  
  
  i_adc_offset_bank_ch1 : wbs_fb_storage
    port map (
    data        => dat_i,                             -- from dispatch
    wraddress   => tga_i(PIDZ_ADDR_WIDTH-1 downto 0), -- from dispatch
    rdaddress_a => tga_i(PIDZ_ADDR_WIDTH-1 downto 0), -- from dispatch
    rdaddress_b => adc_offset_addr_ch1_i,             -- from flux_loop_ctrl ch1
    wren        => wren_adc_offset_bank_ch1,          -- from controller
    clock       => clk_50_i,                          -- global input
    qa          => qa_adc_offset_bank_ch1,            
    qb          => adc_offset_dat_ch1);               -- to flux_loop_ctrl ch1


  -- qa_adc_offset_bank_ch1 <= (others => '0');   -- Decided not to have access through
                                               -- dispatch. However, still use 3-port
                                               -- ram to limit changes.
  
  
  i_adc_offset_bank_ch2 : wbs_fb_storage
    port map (
    data        => dat_i,                             -- from dispatch
    wraddress   => tga_i(PIDZ_ADDR_WIDTH-1 downto 0), -- from dispatch
    rdaddress_a => tga_i(PIDZ_ADDR_WIDTH-1 downto 0), -- from dispatch
    rdaddress_b => adc_offset_addr_ch2_i,             -- from flux_loop_ctrl ch2
    wren        => wren_adc_offset_bank_ch2,          -- from controller
    clock       => clk_50_i,                          -- global input
    qa          => qa_adc_offset_bank_ch2,  
    qb          => adc_offset_dat_ch2);               -- to flux_loop_ctrl ch2


  -- qa_adc_offset_bank_ch2 <= (others => '0');   -- Decided not to have access through
                                               -- dispatch. However, still use 3-port
                                               -- ram to limit changes.
  

  i_adc_offset_bank_ch3 : wbs_fb_storage
    port map (
    data        => dat_i,                             -- from dispatch
    wraddress   => tga_i(PIDZ_ADDR_WIDTH-1 downto 0), -- from dispatch
    rdaddress_a => tga_i(PIDZ_ADDR_WIDTH-1 downto 0), -- from dispatch
    rdaddress_b => adc_offset_addr_ch3_i,             -- from flux_loop_ctrl ch3
    wren        => wren_adc_offset_bank_ch3,          -- from controller
    clock       => clk_50_i,                          -- global input
    qa          => qa_adc_offset_bank_ch3,         
    qb          => adc_offset_dat_ch3);               -- to flux_loop_ctrl ch3


  -- qa_adc_offset_bank_ch3 <= (others => '0');   -- Decided not to have access through
                                               -- dispatch. However, still use 3-port
                                               -- ram to limit changes.
  

  i_adc_offset_bank_ch4 : wbs_fb_storage
    port map (
    data        => dat_i,                             -- from dispatch
    wraddress   => tga_i(PIDZ_ADDR_WIDTH-1 downto 0), -- from dispatch
    rdaddress_a => tga_i(PIDZ_ADDR_WIDTH-1 downto 0), -- from dispatch
    rdaddress_b => adc_offset_addr_ch4_i,             -- from flux_loop_ctrl ch4
    wren        => wren_adc_offset_bank_ch4,          -- from controller
    clock       => clk_50_i,                          -- global input
    qa          => qa_adc_offset_bank_ch4,                              -- not used anymore
    qb          => adc_offset_dat_ch4);               -- to flux_loop_ctrl ch4


  -- qa_adc_offset_bank_ch4 <= (others => '0');   -- Decided not to have access through
                                               -- dispatch. However, still use 3-port
                                               -- ram to limit changes.
  

  i_adc_offset_bank_ch5 : wbs_fb_storage
    port map (
    data        => dat_i,                             -- from dispatch
    wraddress   => tga_i(PIDZ_ADDR_WIDTH-1 downto 0), -- from dispatch
    rdaddress_a => tga_i(PIDZ_ADDR_WIDTH-1 downto 0), -- from dispatch
    rdaddress_b => adc_offset_addr_ch5_i,             -- from flux_loop_ctrl ch5
    wren        => wren_adc_offset_bank_ch5,          -- from controller
    clock       => clk_50_i,                          -- global input
    qa          => qa_adc_offset_bank_ch5,           
    qb          => adc_offset_dat_ch5);               -- to flux_loop_ctrl ch5
  

  -- qa_adc_offset_bank_ch5 <= (others => '0');   -- Decided not to have access through
                                               -- dispatch. However, still use 3-port
                                               -- ram to limit changes.
  

  i_adc_offset_bank_ch6 : wbs_fb_storage
    port map (
    data        => dat_i,                             -- from dispatch
    wraddress   => tga_i(PIDZ_ADDR_WIDTH-1 downto 0), -- from dispatch
    rdaddress_a => tga_i(PIDZ_ADDR_WIDTH-1 downto 0), -- from dispatch
    rdaddress_b => adc_offset_addr_ch6_i,             -- from flux_loop_ctrl ch6
    wren        => wren_adc_offset_bank_ch6,          -- from controller
    clock       => clk_50_i,                          -- global input
    qa          => qa_adc_offset_bank_ch6,                              
    qb          => adc_offset_dat_ch6);               -- to flux_loop_ctrl ch6


  -- qa_adc_offset_bank_ch6 <= (others => '0');   -- Decided not to have access through
                                               -- dispatch. However, still use 3-port
                                               -- ram to limit changes.
  

  i_adc_offset_bank_ch7 : wbs_fb_storage
    port map (
    data        => dat_i,                             -- from dispatch
    wraddress   => tga_i(PIDZ_ADDR_WIDTH-1 downto 0), -- from dispatch
    rdaddress_a => tga_i(PIDZ_ADDR_WIDTH-1 downto 0), -- from dispatch
    rdaddress_b => adc_offset_addr_ch7_i,             -- from flux_loop_ctrl ch7
    wren        => wren_adc_offset_bank_ch7,          -- from controller
    clock       => clk_50_i,                          -- global input
    qa          => qa_adc_offset_bank_ch7,          
    qb          => adc_offset_dat_ch7);               -- to flux_loop_ctrl ch7


  -- qa_adc_offset_bank_ch7 <= (others => '0');   -- Decided not to have access through
                                               -- dispatch. However, still use 3-port
                                               -- ram to limit changes.
  

  
  -----------------------------------------------------------------------------
  -- Controller for adc_offset Banks:
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
  wren_adc_offset_bank_ch0 <=
    we_i when addr_i=ADC_OFFSET0_ADDR else
    '0';
  
  wren_adc_offset_bank_ch1 <=
    we_i when addr_i=ADC_OFFSET1_ADDR else
    '0';

  wren_adc_offset_bank_ch2 <=
    we_i when addr_i=ADC_OFFSET2_ADDR else
    '0';

  wren_adc_offset_bank_ch3 <=
    we_i when addr_i=ADC_OFFSET3_ADDR else
    '0';

  wren_adc_offset_bank_ch4 <=
    we_i when addr_i=ADC_OFFSET4_ADDR else
    '0';

  wren_adc_offset_bank_ch5 <=
    we_i when addr_i=ADC_OFFSET5_ADDR else
    '0';

  wren_adc_offset_bank_ch6 <=
    we_i when addr_i=ADC_OFFSET6_ADDR else
    '0';

  wren_adc_offset_bank_ch7 <=
    we_i when addr_i=ADC_OFFSET7_ADDR else
    '0';

  -----------------------------------------------------------------------------
  -- Acknowlege signals
  i_gen_ack: process (clk_50_i, rst_i)
    
    variable count : integer := 0;           -- counts number of clock cycles passed
    
  begin  -- process i_gen_ack
    if rst_i = '1' then                 -- asynchronous reset (active high)
      ack_read_adc_offset_bank  <= '0';
      ack_write_adc_offset_bank <= '0';
      count:=0;
      
      
    elsif clk_50_i'event and clk_50_i = '1' then  -- rising clock edge
      
      -- Write Acknowledge
      if (we_i='1') and ((addr_i= ADC_OFFSET0_ADDR) or
                         (addr_i= ADC_OFFSET1_ADDR) or
                         (addr_i= ADC_OFFSET2_ADDR) or
                         (addr_i= ADC_OFFSET3_ADDR) or
                         (addr_i= ADC_OFFSET4_ADDR) or
                         (addr_i= ADC_OFFSET5_ADDR) or
                         (addr_i= ADC_OFFSET6_ADDR) or
                         (addr_i= ADC_OFFSET7_ADDR)) then
        
        if (stb_i='1') and (ack_write_adc_offset_bank='0') then
          ack_write_adc_offset_bank <= '1';
        else
          ack_write_adc_offset_bank <= '0';
        end if;
      else
        ack_write_adc_offset_bank <= '0';
      end if;

      
      -- Read Acknowledge
      if (we_i='0') and ((addr_i= ADC_OFFSET0_ADDR) or
                         (addr_i= ADC_OFFSET1_ADDR) or
                         (addr_i= ADC_OFFSET2_ADDR) or
                         (addr_i= ADC_OFFSET3_ADDR) or
                         (addr_i= ADC_OFFSET4_ADDR) or
                         (addr_i= ADC_OFFSET5_ADDR) or
                         (addr_i= ADC_OFFSET6_ADDR) or
                         (addr_i= ADC_OFFSET7_ADDR)) then
        
        if (stb_i='1') and (ack_read_adc_offset_bank='0') then
          count:=count+1;
          if count=3 then
            ack_read_adc_offset_bank <= '1';
            count:=0;
          else
            ack_read_adc_offset_bank <= '0';
          end if;
        else
          ack_read_adc_offset_bank <= '0';
        end if;
        
        
      else
        ack_read_adc_offset_bank <= '0';
        
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

  ack_adc_offset_bank_o <= ack_write_adc_offset_bank or ack_read_adc_offset_bank;

  with addr_i select
    qa_adc_offset_bank_o <=
    qa_adc_offset_bank_ch0 when ADC_OFFSET0_ADDR,
    qa_adc_offset_bank_ch1 when ADC_OFFSET1_ADDR,
    qa_adc_offset_bank_ch2 when ADC_OFFSET2_ADDR,
    qa_adc_offset_bank_ch3 when ADC_OFFSET3_ADDR,
    qa_adc_offset_bank_ch4 when ADC_OFFSET4_ADDR,
    qa_adc_offset_bank_ch5 when ADC_OFFSET5_ADDR,
    qa_adc_offset_bank_ch6 when ADC_OFFSET6_ADDR,
    qa_adc_offset_bank_ch7 when ADC_OFFSET7_ADDR,
    qa_adc_offset_bank_ch0 when others;        -- default to ch0


  -----------------------------------------------------------------------------
  -- Outputs
  -----------------------------------------------------------------------------

  adc_offset_dat_ch0_o <= adc_offset_dat_ch0(ADC_OFFSET_DAT_WIDTH-1 downto 0);
  adc_offset_dat_ch1_o <= adc_offset_dat_ch1(ADC_OFFSET_DAT_WIDTH-1 downto 0);
  adc_offset_dat_ch2_o <= adc_offset_dat_ch2(ADC_OFFSET_DAT_WIDTH-1 downto 0);
  adc_offset_dat_ch3_o <= adc_offset_dat_ch3(ADC_OFFSET_DAT_WIDTH-1 downto 0);
  adc_offset_dat_ch4_o <= adc_offset_dat_ch4(ADC_OFFSET_DAT_WIDTH-1 downto 0);
  adc_offset_dat_ch5_o <= adc_offset_dat_ch5(ADC_OFFSET_DAT_WIDTH-1 downto 0);
  adc_offset_dat_ch6_o <= adc_offset_dat_ch6(ADC_OFFSET_DAT_WIDTH-1 downto 0);
  adc_offset_dat_ch7_o <= adc_offset_dat_ch7(ADC_OFFSET_DAT_WIDTH-1 downto 0);
  
  
end rtl;
