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
-- misc_banks_admin.vhd
--
-- Project:   SCUBA-2
-- Author:        Mohsen Nahvi
-- Organisation:  UBC
--
-- Description:
-- 
-- This block instantiates several registers for the following parameters:
-- 
-- a. filter_coeff      -seven values in total   
-- b. servo_mode        
-- c. ramp_step_size    
-- d. ramp_amp          
-- e. const_val         
-- f. num_ramp_frame_cyc
-- g. sa_bias_dat       -one for each channel-
-- h. offset_dat        -one for each channel-
--
-- These registers are defined using an array of std_logic_vector, i.e., "reg".  The index
-- of this array is as follows for each parameter:
-- reg(0)  = filter_coeff0
-- reg(1)  = filter_coeff1
-- reg(2)  = filter_coeff2
-- reg(3)  = filter_coeff3
-- reg(4)  = filter_coeff4
-- reg(5)  = filter_coeff5
-- reg(6)  = filter_coeff6
-- reg(7)  = servo_mode
-- reg(8)  = ramp_step_size
-- reg(9)  = ramp_amp
-- reg(10) = const_val
-- reg(11) = num_ramp_frame_cyc
-- reg(12) = sa_bias_dat_ch0
-- reg(13) = sa_bias_dat_ch1
-- reg(14) = sa_bias_dat_ch2
-- reg(15) = sa_bias_dat_ch3
-- reg(16) = sa_bias_dat_ch4
-- reg(17) = sa_bias_dat_ch5
-- reg(18) = sa_bias_dat_ch6
-- reg(19) = sa_bias_dat_ch7
-- reg(20) = offset_dat_ch0
-- reg(21) = offset_dat_ch1
-- reg(22) = offset_dat_ch2
-- reg(23) = offset_dat_ch3
-- reg(24) = offset_dat_ch4
-- reg(25) = offset_dat_ch5
-- reg(26) = offset_dat_ch6
-- reg(27) = offset_dat_ch7
-- 
--
-- Two types of control signals are also generated.  
-- 1. The first one is the write enable signals.  An array, wren, with the
-- same index as the "reg" is also used. These signal are simply the
-- we_i when the addr_i is equal to the address of a particular value.  For the
-- case of the filter_coeff, sa_bias_dat, and offset_dat that have multiple
-- values, tga_i is used as the selection to a MUX.
--
-- The addresses are (respective to the list above):
-- a. FILT_COEF_ADDR
-- b. SERVO_MODE_ADDR
-- c. RAMP_STEP_ADDR
-- d. RAMP_AMP_ADDR
-- e. FB_CONST_ADDR
-- f. RAMP_DLY_ADDR
-- g. SA_BIAS_ADDR
-- h. OFFSET_ADDR
-- 
-- 2. The second control signal is the ack_o.  This signal is generated
-- for the read cycle and is the same for the wire cycle. The acknowledge is
-- simply the logical AND of stb_i and cyc_i when addr_i is equal to the
-- address of the parameters used in this bank -see list a-g above-.
--
--
-- Ports:
-- #clk_50_i: Golbal signal.
-- #rst_i: Global signal.
-- #sa_bias_ch0_o: sa_bias Data for flux_loop_ctrl channel0.
-- #offset_dat_ch0_o: offset_dat Data for flux_loop_ctrl channel0.
-- #const_val_ch0_o: const_val Data for flux_loop_ctrl channel0.
-- #servo_mode_ch0_o: servo_mode Data for flux_loop_ctrl channel0.
-- #### Similarly for ch1 to ch7.
-- #filter_coeff0_o: filter_coeff Data 1 for ALL flux_loop_ctrl.
-- #filter_coeff0_o: filter_coeff Data 2 for ALL flux_loop_ctrl.
-- #filter_coeff0_o: filter_coeff Data 3 for ALL flux_loop_ctrl.
-- #filter_coeff0_o: filter_coeff Data 4 for ALL flux_loop_ctrl.
-- #filter_coeff0_o: filter_coeff Data 5 for ALL flux_loop_ctrl.
-- #filter_coeff0_o: filter_coeff Data 6 or ALL flux_loop_ctrl.
-- #filter_coeff0_o: filter_coeff Data 7 for ALL flux_loop_ctrl.
-- #ramp_step_size_o: ramp_step_size Data for All flux_loop_ctrl.
-- #ramp_amp_o: ramp_amp Data for All flux_loop_ctrl.       
-- #num_ramp_frame_cycles_o: num_ramp_frame_cycles Data for All flux_loop_ctrl.
-- #dat_i: Data in from Dispatch
-- #addr_i: Address from Dispatch showing the address of memory banks. This is
-- kept constant during a read or write cycle.
-- #tga_i: Address Tag from Dispatch.  This is incremented during a read or
-- write cycle.  Therefore, it is used as an index to the location in the
-- memory bank.
-- #we_i: Write Enable input from Dispatch.
-- #stb_i: Strobe signal from Dispatch.  Indicates if an address is valid or
-- not. See Wishbone manul page 54 and 57.  
-- #cyc_i: Input from Dispatch indicating a read or write cycle is in progress.
-- #qa_misc_bank_o: A MUX output of all the outputs of the registers.
-- #ack_misc_bank_o: A logical OR function of acknowledge signals for read or
-- write cycles of each register.
--
--
--
-- Revision history:
-- 
-- $Log: misc_banks_admin.vhd,v $
-- Revision 1.12  2006/12/11 18:07:06  mandana
-- fixed a bug associated with fb_const initial value for column 8
--
-- Revision 1.11  2006/12/05 22:33:24  mandana
-- split the servo_mode to be column specific
--
-- Revision 1.10  2006/12/05 14:04:34  mandana
-- initialized fb_const to DAC_INIT_VAL for every column
--
-- Revision 1.9  2006/11/24 20:44:47  mandana
-- splitted fb_const to be channel specific
--
-- Revision 1.8  2006/07/05 19:42:12  mandana
-- added DAC_INIT_VALUE for fb_const register init so DACs are initialized at 0V
--
-- Revision 1.7  2005/11/29 22:16:57  mandana
-- adjusted offset for filter coefficients storage
--
-- Revision 1.6  2005/11/28 19:12:45  bburger
-- Bryce:  set the default value on 'rst' for flx_jmp_en to '0'
--
-- Revision 1.5  2005/09/14 23:48:41  bburger
-- bburger:
-- Integrated flux-jumping into flux_loop
--
-- Revision 1.4  2005/01/11 01:49:35  mohsen
-- Anthony & Mohse: Got rid of calculation in the wren to help solve timing violations
--
-- Revision 1.3  2004/12/04 03:12:19  mohsen
-- Corrected error in tga index
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
use work.readout_card_pack.all;
use work.wbs_fb_data_pack.all;
use work.flux_loop_pack.all;



entity misc_banks_admin is
  
  port (

    -- Global signals
    clk_50_i                : in std_logic;
    rst_i                   : in std_logic;

    
    -- Flux_Loop_Ctrl Channel Interface
    sa_bias_ch0_o           : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    offset_dat_ch0_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    const_val_ch0_o         : out std_logic_vector(CONST_VAL_WIDTH-1 downto 0);                  
    servo_mode_ch0_o        : out std_logic_vector(SERVO_MODE_SEL_WIDTH-1 downto 0);     
    sa_bias_ch1_o           : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    offset_dat_ch1_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    const_val_ch1_o         : out std_logic_vector(CONST_VAL_WIDTH-1 downto 0);                  
    servo_mode_ch1_o        : out std_logic_vector(SERVO_MODE_SEL_WIDTH-1 downto 0);     
    sa_bias_ch2_o           : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    offset_dat_ch2_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    const_val_ch2_o         : out std_logic_vector(CONST_VAL_WIDTH-1 downto 0);                  
    servo_mode_ch2_o        : out std_logic_vector(SERVO_MODE_SEL_WIDTH-1 downto 0);     
    sa_bias_ch3_o           : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    offset_dat_ch3_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    const_val_ch3_o         : out std_logic_vector(CONST_VAL_WIDTH-1 downto 0);                  
    servo_mode_ch3_o        : out std_logic_vector(SERVO_MODE_SEL_WIDTH-1 downto 0);     
    sa_bias_ch4_o           : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    offset_dat_ch4_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    const_val_ch4_o         : out std_logic_vector(CONST_VAL_WIDTH-1 downto 0);                  
    servo_mode_ch4_o        : out std_logic_vector(SERVO_MODE_SEL_WIDTH-1 downto 0);     
    sa_bias_ch5_o           : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    offset_dat_ch5_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    const_val_ch5_o         : out std_logic_vector(CONST_VAL_WIDTH-1 downto 0);                  
    servo_mode_ch5_o        : out std_logic_vector(SERVO_MODE_SEL_WIDTH-1 downto 0);     
    sa_bias_ch6_o           : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    offset_dat_ch6_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    const_val_ch6_o         : out std_logic_vector(CONST_VAL_WIDTH-1 downto 0);                  
    servo_mode_ch6_o        : out std_logic_vector(SERVO_MODE_SEL_WIDTH-1 downto 0);     
    sa_bias_ch7_o           : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    offset_dat_ch7_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    const_val_ch7_o         : out std_logic_vector(CONST_VAL_WIDTH-1 downto 0);          
    servo_mode_ch7_o        : out std_logic_vector(SERVO_MODE_SEL_WIDTH-1 downto 0);     


    -- All Flux_Loop_Ctrl Channels
    filter_coeff0_o         : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    filter_coeff1_o         : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    filter_coeff2_o         : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    filter_coeff3_o         : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    filter_coeff4_o         : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    filter_coeff5_o         : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    filter_coeff6_o         : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    ramp_step_size_o        : out std_logic_vector(RAMP_STEP_WIDTH-1 downto 0);          
    ramp_amp_o              : out std_logic_vector(RAMP_AMP_WIDTH-1 downto 0);           
    num_ramp_frame_cycles_o : out std_logic_vector(RAMP_CYC_WIDTH-1 downto 0);
    flux_jumping_en_o       : out std_logic;

    
    -- signals to/from dispatch  (wishbone interface)
    dat_i                   : in  std_logic_vector(WB_DATA_WIDTH-1 downto 0);       -- wishbone data in
    addr_i                  : in  std_logic_vector(WB_ADDR_WIDTH-1 downto 0);       -- wishbone address in
    tga_i                   : in  std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);   -- Address Tag
    we_i                    : in  std_logic;                                        -- write//read enable
    stb_i                   : in  std_logic;                                        -- strobe 
    cyc_i                   : in  std_logic;                                        -- cycle
    --dat_o                   : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);       -- data out
    --ack_o                   : out std_logic;                                        -- acknowledge out
    
    
    -- Interface intended for dispatch
    qa_misc_bank_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    ack_misc_bank_o            : out std_logic);
  

end misc_banks_admin;



architecture rtl of misc_banks_admin is

  constant MAX_BIT_TAG             : integer := 3;    -- The number of bits used in tga_i to count up to the maximum number of values for each parameters
  constant SERVO_INDEX_OFFSET      : integer := 7;    -- Index of servo_mode in array register
  constant RAMP_STEP_INDEX_OFFSET  : integer := 15;    -- Index of ramp_step_size in array register
  constant RAMP_AMP_INDEX_OFFSET   : integer := 16;    -- Index of ramp_amp in array register
  constant CONST_VAL_INDEX_OFFSET  : integer := 17;   -- Index of const_val in array register
  constant NUM_RAM_INDEX_OFFSET    : integer := 25;   -- Index of num_ramp_frame_cycles in array register
  constant SA_BIAS_INDEX_OFFSET    : integer := 26;   -- Index of sa_bias in array register
  constant OFFSET_DAT_INDEX_OFFSET : integer := 34;   -- Index of offset_dat in array register
  constant EN_FB_JUMP_OFFSET       : integer := 42;   -- Index of enable flag for the flux-jumping block
  constant FILTER_INDEX_OFFSET     : integer := 43;   -- Index of filter_coeff in array register (2 values common for all channels)
  constant MISC_BANK_MAX_RANGE     : integer := 51;   -- Maximum number of parameters in the Miscellanous bank
 
  constant ZERO : std_logic_vector(WB_DATA_WIDTH-1 downto 0) := (others => '0');

  -----------------------------------------------------------------------------
  -- Registers for each value
  -- Note: we have used 32-bit registers across the board, as the wishbone
  -- interface is 32 bits.  Clearly, the corresponding output to the
  -- Flux_Loop_Ctrl uses the requires LSBs out of 32.
  -----------------------------------------------------------------------------

  type misc_bank is array (0 to MISC_BANK_MAX_RANGE-1) of std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal reg : misc_bank;
  
 
  -----------------------------------------------------------------------------
  -- Signals from Misc Controller
  -----------------------------------------------------------------------------

  type wren_banks is array (0 to MISC_BANK_MAX_RANGE-1) of std_logic;
  signal wren : wren_banks;

  signal ack_read_misc_bank         : std_logic;
  --signal ack_write_misc_bank        : std_logic;

  
  -----------------------------------------------------------------------------
  -- Signals for Output MUXs
  -----------------------------------------------------------------------------

  signal filter_coeff : std_logic_vector(WB_DATA_WIDTH-1 downto 0);  -- MUX output for all filter_coeff values
  signal sa_bias      : std_logic_vector(WB_DATA_WIDTH-1 downto 0);  -- MUX output for all sa_bias values
  signal offset_dat   : std_logic_vector(WB_DATA_WIDTH-1 downto 0);  -- MUX output for all offset_dat values
  signal fb_const     : std_logic_vector(WB_DATA_WIDTH-1 downto 0);  -- MUX output for all fb_const_val values
  signal servo_dat    : std_logic_vector(WB_DATA_WIDTH-1 downto 0);  -- MUX output for all servo_mode values
 
begin  -- rtl

  

  -----------------------------------------------------------------------------
  -- Instantiation of All Registers
  ----------------------------------------------------------------------------- 

  i_misc_bank: for i in 0 to MISC_BANK_MAX_RANGE-1 generate
    i_reg: process (clk_50_i, rst_i)
    begin  -- process i_reg
      if rst_i = '1' then               -- asynchronous reset (active high)
        if(i >= CONST_VAL_INDEX_OFFSET and i <= (CONST_VAL_INDEX_OFFSET +7) ) then
          reg(i) <= conv_std_logic_vector(DAC_INIT_VAL,WB_DATA_WIDTH);
        else
          reg(i) <= (others => '0');
        end if;
      elsif clk_50_i'event and clk_50_i = '1' then  -- rising clock edge
        if wren(i)='1' then
          reg(i) <= dat_i;
        end if;
      end if;
    end process i_reg;
  end generate i_misc_bank;
  

    
  -----------------------------------------------------------------------------
  -- Controller for All Registers:
  -- 
  -- 1. Write Enable signals for each bank is equal to the dispatch we_i when
  -- the address from dispatch, addr_i, is equla to that bank's address
  --
  -- 2. Acknowledge signals are the same for Write or Read cycle. It is simply
  -- the logical AND of stb_i and cyc_i when addr_i is equal to the address of
  -- the parameters used in this block.
  -- 
  -----------------------------------------------------------------------------

  -- Write Enable Signals
  i_gen_wren_signals: process (addr_i, we_i, tga_i)
  begin  -- process i_gen_wren_signals
  
    for i in 0 to MISC_BANK_MAX_RANGE-1 loop
      wren(i) <= '0';
    end loop;  -- i
     
    case addr_i is
      when FILT_COEF_ADDR =>
        case tga_i(MAX_BIT_TAG-1 downto 0) is
          when "000" => wren(FILTER_INDEX_OFFSET+0) <= we_i;
          when "001" => wren(FILTER_INDEX_OFFSET+1) <= we_i;
          when "010" => wren(FILTER_INDEX_OFFSET+2) <= we_i;
          when "011" => wren(FILTER_INDEX_OFFSET+3) <= we_i;
          when "100" => wren(FILTER_INDEX_OFFSET+4) <= we_i;
          when "101" => wren(FILTER_INDEX_OFFSET+5) <= we_i;
          when "110" => wren(FILTER_INDEX_OFFSET+6) <= we_i;
          when others => null;
        end case;

      when RAMP_STEP_ADDR =>
        wren(RAMP_STEP_INDEX_OFFSET) <= we_i;
      when RAMP_AMP_ADDR =>
        wren(RAMP_AMP_INDEX_OFFSET) <= we_i;
      when RAMP_DLY_ADDR =>
        wren(NUM_RAM_INDEX_OFFSET) <= we_i;
      when EN_FB_JUMP_ADDR =>
        wren(EN_FB_JUMP_OFFSET) <= we_i;

      when SA_BIAS_ADDR =>
        case tga_i(MAX_BIT_TAG-1 downto 0) is
          when "000" => wren(SA_BIAS_INDEX_OFFSET+0) <= we_i;
          when "001" => wren(SA_BIAS_INDEX_OFFSET+1) <= we_i;
          when "010" => wren(SA_BIAS_INDEX_OFFSET+2) <= we_i;
          when "011" => wren(SA_BIAS_INDEX_OFFSET+3) <= we_i;
          when "100" => wren(SA_BIAS_INDEX_OFFSET+4) <= we_i;
          when "101" => wren(SA_BIAS_INDEX_OFFSET+5) <= we_i;
          when "110" => wren(SA_BIAS_INDEX_OFFSET+6) <= we_i;
          when "111" => wren(SA_BIAS_INDEX_OFFSET+7) <= we_i;
          when others => null;
        end case;
        
      when OFFSET_ADDR =>
        case tga_i(MAX_BIT_TAG-1 downto 0) is
          when "000" => wren(OFFSET_DAT_INDEX_OFFSET+0) <= we_i;
          when "001" => wren(OFFSET_DAT_INDEX_OFFSET+1) <= we_i;
          when "010" => wren(OFFSET_DAT_INDEX_OFFSET+2) <= we_i;
          when "011" => wren(OFFSET_DAT_INDEX_OFFSET+3) <= we_i;
          when "100" => wren(OFFSET_DAT_INDEX_OFFSET+4) <= we_i;
          when "101" => wren(OFFSET_DAT_INDEX_OFFSET+5) <= we_i;
          when "110" => wren(OFFSET_DAT_INDEX_OFFSET+6) <= we_i;
          when "111" => wren(OFFSET_DAT_INDEX_OFFSET+7) <= we_i;
          when others => null;
        end case;

      when FB_CONST_ADDR =>
        case tga_i(MAX_BIT_TAG-1 downto 0) is
          when "000" => wren(CONST_VAL_INDEX_OFFSET+0) <= we_i;
          when "001" => wren(CONST_VAL_INDEX_OFFSET+1) <= we_i;
          when "010" => wren(CONST_VAL_INDEX_OFFSET+2) <= we_i;
          when "011" => wren(CONST_VAL_INDEX_OFFSET+3) <= we_i;
          when "100" => wren(CONST_VAL_INDEX_OFFSET+4) <= we_i;
          when "101" => wren(CONST_VAL_INDEX_OFFSET+5) <= we_i;
          when "110" => wren(CONST_VAL_INDEX_OFFSET+6) <= we_i;
          when "111" => wren(CONST_VAL_INDEX_OFFSET+7) <= we_i;
          when others => null;
        end case;

      when SERVO_MODE_ADDR =>
        case tga_i(MAX_BIT_TAG-1 downto 0) is
          when "000" => wren(SERVO_INDEX_OFFSET+0) <= we_i;
          when "001" => wren(SERVO_INDEX_OFFSET+1) <= we_i;
          when "010" => wren(SERVO_INDEX_OFFSET+2) <= we_i;
          when "011" => wren(SERVO_INDEX_OFFSET+3) <= we_i;
          when "100" => wren(SERVO_INDEX_OFFSET+4) <= we_i;
          when "101" => wren(SERVO_INDEX_OFFSET+5) <= we_i;
          when "110" => wren(SERVO_INDEX_OFFSET+6) <= we_i;
          when "111" => wren(SERVO_INDEX_OFFSET+7) <= we_i;
          when others => null;
        end case;
      
      when others => null;
                     
    end case;
  end process i_gen_wren_signals;



  -- Acknowlege signals
  with addr_i select
    ack_read_misc_bank <=
    (stb_i and cyc_i) when FILT_COEF_ADDR | SERVO_MODE_ADDR | RAMP_STEP_ADDR |
                           RAMP_AMP_ADDR | FB_CONST_ADDR | RAMP_DLY_ADDR |
                           SA_BIAS_ADDR |  OFFSET_ADDR | EN_FB_JUMP_ADDR,
    '0'               when others;

  -- ack_write_misc_bank <= ack_read_misc_bank;
  ack_misc_bank_o     <= ack_read_misc_bank;
  

  
  -----------------------------------------------------------------------------
  -- Output MUX to Dispatch:
  -- 
  -- The addr_i selects which bank is sending its output to the dispatch.  The
  -- defulat connection is to filter_coeff0.
  -- We use two levels of muxes to do the selection.  The first level selects
  -- based on the tga_i for those registers that hold multiple values of same
  -- parameter, e.g., filter_coeff, etc. The second level of muxes selects
  -- based on the address present on addr_i.
  -----------------------------------------------------------------------------

  with tga_i(2 downto 0) select
    filter_coeff <=
    reg(FILTER_INDEX_OFFSET+0) when "000",
    reg(FILTER_INDEX_OFFSET+1) when "001",
    reg(FILTER_INDEX_OFFSET+2) when "010",
    reg(FILTER_INDEX_OFFSET+3) when "011",
    reg(FILTER_INDEX_OFFSET+4) when "100",
    reg(FILTER_INDEX_OFFSET+5) when "101",
    reg(FILTER_INDEX_OFFSET+6) when "110",
    reg(FILTER_INDEX_OFFSET+0) when others;


  with tga_i(2 downto 0) select
    sa_bias <=
    reg(SA_BIAS_INDEX_OFFSET+0) when "000",
    reg(SA_BIAS_INDEX_OFFSET+1) when "001",
    reg(SA_BIAS_INDEX_OFFSET+2) when "010",
    reg(SA_BIAS_INDEX_OFFSET+3) when "011",
    reg(SA_BIAS_INDEX_OFFSET+4) when "100",
    reg(SA_BIAS_INDEX_OFFSET+5) when "101",
    reg(SA_BIAS_INDEX_OFFSET+6) when "110",
    reg(SA_BIAS_INDEX_OFFSET+7) when "111",
    reg(SA_BIAS_INDEX_OFFSET+0) when others;


  with tga_i(2 downto 0) select
    offset_dat <=
    reg(OFFSET_DAT_INDEX_OFFSET+0) when "000",
    reg(OFFSET_DAT_INDEX_OFFSET+1) when "001",
    reg(OFFSET_DAT_INDEX_OFFSET+2) when "010",
    reg(OFFSET_DAT_INDEX_OFFSET+3) when "011",
    reg(OFFSET_DAT_INDEX_OFFSET+4) when "100",
    reg(OFFSET_DAT_INDEX_OFFSET+5) when "101",
    reg(OFFSET_DAT_INDEX_OFFSET+6) when "110",
    reg(OFFSET_DAT_INDEX_OFFSET+7) when "111",
    reg(OFFSET_DAT_INDEX_OFFSET+0) when others;

  with tga_i(2 downto 0) select
    fb_const <=
    reg(CONST_VAL_INDEX_OFFSET+0) when "000",
    reg(CONST_VAL_INDEX_OFFSET+1) when "001",
    reg(CONST_VAL_INDEX_OFFSET+2) when "010",
    reg(CONST_VAL_INDEX_OFFSET+3) when "011",
    reg(CONST_VAL_INDEX_OFFSET+4) when "100",
    reg(CONST_VAL_INDEX_OFFSET+5) when "101",
    reg(CONST_VAL_INDEX_OFFSET+6) when "110",
    reg(CONST_VAL_INDEX_OFFSET+7) when "111",
    reg(CONST_VAL_INDEX_OFFSET+0) when others;

  with tga_i(2 downto 0) select
    servo_dat <=
    reg(SERVO_INDEX_OFFSET+0) when "000",
    reg(SERVO_INDEX_OFFSET+1) when "001",
    reg(SERVO_INDEX_OFFSET+2) when "010",
    reg(SERVO_INDEX_OFFSET+3) when "011",
    reg(SERVO_INDEX_OFFSET+4) when "100",
    reg(SERVO_INDEX_OFFSET+5) when "101",
    reg(SERVO_INDEX_OFFSET+6) when "110",
    reg(SERVO_INDEX_OFFSET+7) when "111",
    reg(SERVO_INDEX_OFFSET+0) when others;
 
  
  with addr_i select
    qa_misc_bank_o <=
    filter_coeff                  when FILT_COEF_ADDR,
    servo_dat                     when SERVO_MODE_ADDR,
    reg(RAMP_STEP_INDEX_OFFSET)   when RAMP_STEP_ADDR,
    reg(RAMP_AMP_INDEX_OFFSET)    when RAMP_AMP_ADDR,
    reg(NUM_RAM_INDEX_OFFSET)     when RAMP_DLY_ADDR,
    sa_bias                       when SA_BIAS_ADDR,
    offset_dat                    when OFFSET_ADDR,
    fb_const                      when FB_CONST_ADDR,
    reg(EN_FB_JUMP_OFFSET)        when EN_FB_JUMP_ADDR,
    filter_coeff                  when others;           -- default to first value in bank
  

  -----------------------------------------------------------------------------
  -- Outputs to flux_loop_ctrl
  -----------------------------------------------------------------------------

  filter_coeff0_o         <= reg(FILTER_INDEX_OFFSET+0);
  filter_coeff1_o         <= reg(FILTER_INDEX_OFFSET+1);
  filter_coeff2_o         <= reg(FILTER_INDEX_OFFSET+2);
  filter_coeff3_o         <= reg(FILTER_INDEX_OFFSET+3);
  filter_coeff4_o         <= reg(FILTER_INDEX_OFFSET+4);
  filter_coeff5_o         <= reg(FILTER_INDEX_OFFSET+5);
  filter_coeff6_o         <= reg(FILTER_INDEX_OFFSET+6);
  servo_mode_ch0_o        <= reg(SERVO_INDEX_OFFSET+0)(SERVO_MODE_SEL_WIDTH-1 downto 0);
  servo_mode_ch1_o        <= reg(SERVO_INDEX_OFFSET+1)(SERVO_MODE_SEL_WIDTH-1 downto 0);
  servo_mode_ch2_o        <= reg(SERVO_INDEX_OFFSET+2)(SERVO_MODE_SEL_WIDTH-1 downto 0);
  servo_mode_ch3_o        <= reg(SERVO_INDEX_OFFSET+3)(SERVO_MODE_SEL_WIDTH-1 downto 0);
  servo_mode_ch4_o        <= reg(SERVO_INDEX_OFFSET+4)(SERVO_MODE_SEL_WIDTH-1 downto 0);
  servo_mode_ch5_o        <= reg(SERVO_INDEX_OFFSET+5)(SERVO_MODE_SEL_WIDTH-1 downto 0);
  servo_mode_ch6_o        <= reg(SERVO_INDEX_OFFSET+6)(SERVO_MODE_SEL_WIDTH-1 downto 0);
  servo_mode_ch7_o        <= reg(SERVO_INDEX_OFFSET+7)(SERVO_MODE_SEL_WIDTH-1 downto 0);
  ramp_step_size_o        <= reg(RAMP_STEP_INDEX_OFFSET)(RAMP_STEP_WIDTH-1 downto 0);
  ramp_amp_o              <= reg(RAMP_AMP_INDEX_OFFSET)(RAMP_AMP_WIDTH-1 downto 0 );
  num_ramp_frame_cycles_o <= reg(NUM_RAM_INDEX_OFFSET)(RAMP_CYC_WIDTH-1 downto 0);
  sa_bias_ch0_o           <= reg(SA_BIAS_INDEX_OFFSET+0);
  sa_bias_ch1_o           <= reg(SA_BIAS_INDEX_OFFSET+1);
  sa_bias_ch2_o           <= reg(SA_BIAS_INDEX_OFFSET+2);
  sa_bias_ch3_o           <= reg(SA_BIAS_INDEX_OFFSET+3);
  sa_bias_ch4_o           <= reg(SA_BIAS_INDEX_OFFSET+4);
  sa_bias_ch5_o           <= reg(SA_BIAS_INDEX_OFFSET+5);
  sa_bias_ch6_o           <= reg(SA_BIAS_INDEX_OFFSET+6);
  sa_bias_ch7_o           <= reg(SA_BIAS_INDEX_OFFSET+7);
  offset_dat_ch0_o        <= reg(OFFSET_DAT_INDEX_OFFSET+0);
  offset_dat_ch1_o        <= reg(OFFSET_DAT_INDEX_OFFSET+1);
  offset_dat_ch2_o        <= reg(OFFSET_DAT_INDEX_OFFSET+2);
  offset_dat_ch3_o        <= reg(OFFSET_DAT_INDEX_OFFSET+3);
  offset_dat_ch4_o        <= reg(OFFSET_DAT_INDEX_OFFSET+4);
  offset_dat_ch5_o        <= reg(OFFSET_DAT_INDEX_OFFSET+5);
  offset_dat_ch6_o        <= reg(OFFSET_DAT_INDEX_OFFSET+6);
  offset_dat_ch7_o        <= reg(OFFSET_DAT_INDEX_OFFSET+7);
  const_val_ch0_o         <= reg(CONST_VAL_INDEX_OFFSET+0)(CONST_VAL_WIDTH-1 downto 0);
  const_val_ch1_o         <= reg(CONST_VAL_INDEX_OFFSET+1)(CONST_VAL_WIDTH-1 downto 0);
  const_val_ch2_o         <= reg(CONST_VAL_INDEX_OFFSET+2)(CONST_VAL_WIDTH-1 downto 0);
  const_val_ch3_o         <= reg(CONST_VAL_INDEX_OFFSET+3)(CONST_VAL_WIDTH-1 downto 0);
  const_val_ch4_o         <= reg(CONST_VAL_INDEX_OFFSET+4)(CONST_VAL_WIDTH-1 downto 0);
  const_val_ch5_o         <= reg(CONST_VAL_INDEX_OFFSET+5)(CONST_VAL_WIDTH-1 downto 0);
  const_val_ch6_o         <= reg(CONST_VAL_INDEX_OFFSET+6)(CONST_VAL_WIDTH-1 downto 0);
  const_val_ch7_o         <= reg(CONST_VAL_INDEX_OFFSET+7)(CONST_VAL_WIDTH-1 downto 0);  
  flux_jumping_en_o       <= '0' when reg(EN_FB_JUMP_OFFSET) = ZERO else '1';


end rtl;
