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

-- ac_dac_ctrl.vhd
--
-- Project:	      SCUBA-2
-- Author:	      Mandana Amiri
-- Organisation:      UBC
--
-- Description:
-- Wishbone to parallel 14-bit 165MS/s DAC (AD9744) interface 
-- AC_DAC_CTRL slave processes the following commands issued by Command_FSM(Wishbone Master) on address card:
--              ON_BIAS_ADDR     : to read/write a 14b ON current bias value to each of the DACs in consecutive words.
--              OFF_BIAS_ADDR    : to read/write a 14b OFF current bias value to each of the DACs
--              ROW_MAP_ADDR     : to read/write the channel to row address mapping with consecutive bytes                 
--              STRT_MUX_ADDR    : to read/write whether the mux is enabled or disabled       :
--              ROW_ORDER_ADDR   : to read/write row addressing order
--              ACTV_ROW_ADDR    : if read, returns which row is currently on
--                               : OR if written, sets the active row. The active row number is a byte long.
--              CYC_OO_SYC_ADDR  : to send the number of cycles out of sync to the master (cmd_fsm) 
--              RESYNC_ADDR      : to resync with the next sync pulse
-- Revision history:
-- <date $Date: 2004/07/14 00:04:10 $>	- <initials $Author: mandana $>
-- $Log: ac_dac_ctrl.vhd,v $
-- Revision 1.2  2004/07/14 00:04:10  mandana
-- added cvs log header
--   
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

entity ac_dac_ctrl is        
port(-- ac_dac_ctrl:
     dac_data_o  : out w14_array11;   
     dac_clk_o   : out std_logic_vector(NUM_OF_ROWS downto 0);
     -- wishbone signals:
     clk_i       : in std_logic;
     rst_i       : in std_logic;		
     dat_i       : in std_logic_vector (WB_DATA_WIDTH-1 downto 0);
     addr_i      : in std_logic_vector (WB_ADDR_WIDTH-1 downto 0);
     tga_i       : in std_logic_vector (WB_TAG_ADDR_WIDTH-1 downto 0);
     we_i        : in std_logic;
     stb_i       : in std_logic;
     cyc_i       : in std_logic;
     dat_o       : out std_logic_vector (WB_DATA_WIDTH-1 downto 0);
     rty_o       : out std_logic;
     ack_o       : out std_logic;
     -- extra
     sync_i      : in std_logic);     
end ac_dac_ctrl;

architecture rtl of ac_dac_ctrl is

-- DAC CTRL:
-- State encoding and state variables:


-- controller states:
type states is (IDLE, WR, WR_ACK, WR_NXT, RD, RD_MEM1, RD_ACK, RD_NXT, RESYNC, OUT_SYNC); 
                
signal current_state   : states;
signal next_state      : states;

-- row selection FSM states:
type row_states is (IDLE, PREP, CLKDAC); 
                
signal row_current_state   : row_states;
signal row_next_state      : row_states;

signal on_val_cmd      : std_logic; -- 
signal off_val_cmd     : std_logic; --
signal start_stop_cmd  : std_logic; --
signal out_sync_cmd    : std_logic; -- indicates cycles_out_of_sync command is received
signal resync_cmd      : std_logic; --
signal wr_cmd          : std_logic;
signal rd_cmd          : std_logic;
signal master_wait     : std_logic;

-- memory signals for port A used during read/write required by WB commands
signal mem_addr_a      : word8;
signal mem_clk_a       : std_logic;
signal mem_clken_a     : std_logic;
signal mem_dat_a       : word16;
signal mem_q_a         : word16;
signal mem_wren_a      : std_logic;

-- memory signals for port B used during row selection cycle
signal mem_addr_b      : word8;
signal mem_clk_b       : std_logic;
signal mem_clken_b     : std_logic;
signal mem_dat_b       : word16;
signal mem_q_b         : word16;
signal mem_wren_b      : std_logic;

-- row index when writing WB command values to memory
signal idx            : integer range 0 to NUM_OF_ROWS;
signal idx_rst        : std_logic;
signal idx_clk        : std_logic;
signal idx_sig        : word8;

signal base            : word8;
signal start_mux       : std_logic;
signal rst_nxt_sync    : std_logic;
signal error_count     : word32;
signal read_count      : word32;

-- row number when cycling through different rows.
signal row             : integer range 0 to NUM_OF_ROWS;
signal cur_on_val      : word16;
signal cur_off_val     : word16;

signal k               : integer;
signal active_row      : integer;
signal prev_row        : integer;
signal reg_clk         : std_logic_vector (NUM_OF_ROWS downto 0);
signal dac_data        : w14_array11;

-- A dual-port ram is instantiated, port A is used to read/write values requested by WB commands
-- and port B is used to read values
component ram_dp_16x256 IS
	PORT
	(
		data_a		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		wren_a		: IN STD_LOGIC  := '1';
		address_a	: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		data_b		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		address_b	: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wren_b		: IN STD_LOGIC := '0';
		clock_a		: IN STD_LOGIC ;
		enable_a	: IN STD_LOGIC ;
		clock_b		: IN STD_LOGIC ;
		enable_b	: IN STD_LOGIC ;
		q_a		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		q_b		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
	);
END component;

component adder8 IS
	PORT
	(
		dataa		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		datab		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		result		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END component;


begin

-- instantiations
   ram_dp_16x256_inst : ram_dp_16x256 PORT MAP (
         data_a	   => mem_dat_a,
         wren_a	   => mem_wren_a,
         address_a => mem_addr_a,
         data_b	   => mem_dat_b,
         address_b => mem_addr_b,
         wren_b	   => '0',             -- mem_wren_b, we never write to port B
         clock_a   => mem_clk_a,
         enable_a  => mem_clken_a,
         clock_b   => mem_clk_b,
         enable_b  => mem_clken_b,
         q_a       => mem_q_a,
         q_b	   => mem_q_b
	);
	
   adder8_inst : adder8 PORT MAP (
		dataa	 => base,
		datab	 => idx_sig,
		result	 => mem_addr
	);

   idx_counter: counter 
   generic map(MAX => NUM_OF_ROWS,
               STEP_SIZE => 1,
               WRAP_AROUND => '1',
               UP_COUNTER => '1')
   port map(clk_i   => idx_clk,
            rst_i   => idx_rst,
            ena_i   => '1',
            load_i  => '0',
            count_i => 0,
            count_o => idx);
            
   row_counter: counter 
   generic map(MAX => NUM_OF_ROWS,
               STEP_SIZE => 1,
               WRAP_AROUND => '1',
               UP_COUNTER => '1')
   port map(clk_i   => row_clk,
            rst_i   => start_mux,
            ena_i   => '1',
            load_i  => '0',
            count_i => 0,
            count_o => row);
   
   active_row <= ROW_ORDER(row);
   prev_row   <= ROW_ORDER(row - 1);
   
   -- generate registers for all the DAC data outputs
   for k in 0 to NUM_OF_ROWS_ generate
   dac_data_reg: reg
      generic map(WIDTH => 16)
      port map(clk_i  => reg_clk(k),
               rst_i  => rst_i,
               ena_i  => '1',
               reg_i  => dac_data(k),
               reg_o  => dac_data_o(k));
   end generate gen_dac_data_reg;
                                    
   idx_sig <= conv_std_logic_vector(idx, 8);                                    
   mem_clk_a  <= not(clk_i);
   mem_clk_b  <= not(clk_i);
     
-- CLOCKED FSMs
   state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         current_state     <= IDLE;
         row_current_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         current_state     <= next_state;
         row_current_state <= row_next_state;
      end if;
   end process state_FF;

------------------------------------------------------------
--
--  DAC controller FSM
--
------------------------------------------------------------   

-- Transition table for DAC controller
   state_NS: process(current_state, rd_cmd, wr_cmd, addr_i, cyc_i, master_wait)
   begin
      case current_state is
         when IDLE =>
            if wr_cmd = '1' then
               next_state <= WR;            
            elsif rd_cmd = '1' then
              next_state <= RD;
            end if;                  
            
         when WR =>     
            if (addr_i = ON_BI AS_ADDR  or addr_i = OFF_BIAS_ADDR or 
                addr_i = STRT_MUX_ADDR or addr_i = ROW_ORDER_ADDR) then
               next_state <= WR_ACK;
            elsif addr_i = RESYNC_ADDR then
               next_state <= RESYNC;
            end if;
                        
         when WR_ACK =>   
            next_state <= WR_NXT;
            
         when WR_NXT =>
            if cyc_i = '0' then
               next_state <= IDLE;
            elsif master_wait = '1' then 
               next_state <= WR_NXT;
            else
               next_state <= WR;
            end if;
         
         when RD =>
            if (addr_i = ON_BIAS_ADDR  or addr_i = OFF_BIAS_ADDR or 
                addr_i = STRT_MUX_ADDR or addr_i = ROW_ORDER_ADDR) then
               next_state <= RD_MEM1;
            elsif addr_i = CYC_OO_SYC_ADDR then
               next_state <= OUT_SYNC;
            end if;

         when RD_MEM1 =>
            next_state <= RD_ACK;
                        
         when RD_ACK =>   
            next_state <= RD_NXT;
            
         when RD_NXT =>
            if cyc_i = '0' then
               next_state <= IDLE;
            elsif master_wait = '1' then 
               next_state <= RD_NXT;
            else
               next_state <= RD;
            end if;
            
         when RESYNC =>
           next_state <= IDLE;
           
         when OUT_SYNC =>
           next_state <= IDLE;
                                   
      end case;
   end process state_NS;
   
-- Output states for DAC controller   
   state_out: process(current_state, dat_i, addr_i, mem_q_a)
   begin
      case current_state is
         when IDLE  =>                   
            ack_o        <= '0';
            idx_rst     <= '1';
            idx_clk     <= '0';
            base         <= (others => '0');
            mem_dat_a    <= (others => '0');
            mem_wren_a   <= '0';
            mem_clken_a  <= '0';
            start_mux    <= '0';
            rst_nxt_sync <= '0';
            
         when WR =>  
            ack_o        <= '0';
            idx_rst     <= '0';
            idx_clk     <= '0';            
            --setting the memory address
            if addr_i = ON_BIAS_ADDR then
               base    <= ON_VAL_BASE;
            elsif addr_i = OFF_BIAS_ADDR then
               base    <= OFF_VAL_BASE;
            elsif addr_i = STRT_MUX_ADDR then
               base    <= MUX_ON_BASE;
               if dat_i(7 downto 0) = MUX_ON then
                  start_mux <= '1';
               else
                  start_mux <= '0';
               end if;   
            elsif addr_i = ROW_ORDER_ADDR then
               base    <= ROW_ORD_BASE;
            end if;   
            mem_dat_a    <= dat_i(15 downto 0);
            mem_wren_a   <= '1';
            mem_clken_a  <= '1';
            rst_nxt_sync <= '0';
                        

         when WR_ACK =>
            ack_o        <= '1';
            idx_rst     <= '0';
            idx_clk     <= '0';            
            base         <= (others => '0');
            mem_dat_a    <= (others => '0');
            mem_wren_a   <= '0';
            mem_clken_a  <= '0';
            rst_nxt_sync <= '0';
                       
         when WR_NXT =>
            ack_o        <= '0';
            idx_rst     <= '0';
            idx_clk     <= '1';            
            base         <= (others => '0');
            mem_dat_a    <= (others => '0');
            mem_wren_a   <= '0';
            mem_clken_a  <= '0';
            rst_nxt_sync <= '0';
                     
         when RD =>
            ack_o        <= '0';
            idx_rst     <= '0';
            idx_clk     <= '0';
            --setting the memory address
            if addr_i = ON_BIAS_ADDR then
               base    <= ON_VAL_BASE;
            elsif addr_i = OFF_BIAS_ADDR then
               base    <= OFF_VAL_BASE;
            elsif addr_i = STRT_MUX_ADDR then
               base    <= MUX_ON_BASE;
            elsif addr_i =ROW_ORDER_ADDR then
               base    <= ROW_ORD_BASE;
            end if;   
            dat_o(15 downto 0) <= mem_dat_o;
            mem_wren_a   <= '0';
            mem_clken_a  <= '1';
            rst_nxt_sync <= '0';
		       
         when RD_MEM1 => 
            ack_o        <= '0';
            idx_rst     <= '0';
            idx_clk     <= '0';
            dat_o(15 downto 0) <= mem_q_a;
            base         <= (others => '0');
            mem_wren_a   <= '0';
            mem_clken_a  <= '1';
            rst_nxt_sync <= '0';
	       
         when RD_ACK => 
            ack_o        <= '1';
            idx_rst     <= '0';
            idx_clk     <= '0';
            dat_o(15 downto 0) <= mem_q_a;
            base         <= (others => '0');
            mem_wren_a   <= '0';
            mem_clken_a  <= '1';
            rst_nxt_sync <= '0';
	       
         when RD_NXT =>
            ack_o        <= '0';
            idx_rst     <= '0';
            idx_clk     <= '1';
            dat_o        <= (others => '0');
            base         <= (others => '0');
            mem_wren_a   <= '0';            
            mem_clken_a  <= '0';
            rst_nxt_sync <= '0';
               
         when RESYNC =>            
            ack_o        <= '1';
            idx_rst     <= '1';
            idx_clk     <= '0';
            base         <= (others => '0');
            mem_dat_a    <= (others => '0');
            mem_wren_a   <= '0';
            mem_clken_a  <= '0';
            rst_nxt_sync <= '1';
 	       
         when OUT_SYNC =>
            ack_o        <= '1';
            idx_rst      <= '1';
            idx_clk      <= '0';
            base         <= (others => '0');
            mem_dat_a    <= (others => '0');
            mem_wren_a   <= '0';
            mem_clken_a  <= '0';
            dat_o        <= error_count;
            rst_nxt_sync <= '0';
    
      end case;
   end process state_out;
------------------------------------------------------------------------
--
-- Row Selection FSM
--
------------------------------------------------------------------------
   row_state_NS: process(row_current_state, start_mux, dat_i, addr_i, mem_dat_o)
   begin
      case row_current_state is 
         when IDLE =>
            if start_mux = '1' then
               row_next_state <= MEM_FETCH_ON_VAL;               
            else
               row_next_state <= IDLE;
            end if;
           
         when MEM_FETCH_ON_VAL =>    
            row_next_state <= MEM_FETCH_OFF_VAL;

         when MEM_FETCH_OFF_VAL =>   
            row_next_state <= WAIT_FOR_SYNC;
           
         when WAIT_FOR_SYNC =>
            if read_count = SEL_ROW(i) then 
               row_next_state <= CLKDAC;
            else   
               row_next_state <= WAIT_FOR_SYNC;
            end if;
                                     
         when CLKDAC =>
            
         when DONE =>
                  
      end case;
   end process row_state_NS;   

   -- output states for row selection FSM   
   row_state_out: process(row_current_state)
   begin
      case row_current_state is
         when IDLE =>
            mem_dat_b    <= (others => '0');
            mem_wren_b   <= '0';
            mem_clken_b  <= '0';
            mem_addr_b   <= (others => '0');
           
         when MEM_FETCH_ON_VAL =>
            row_clk      <= 0;
            mem_addr_b   <= ON_VAL_BASE + ROW_ORDER(row);
            mem_clken_b  <= '1';
            dac_data(ROW_ORDER(row))<= mem_dat_o;
            
         when MEM_FETCH_OFF_VAL =>   
            row_clk      <= 0;
            mem_addr_b   <= ON_VAL_BASE + ROW_ORDER[row - 1];
            mem_clken_b  <= '1';
            dac_data(row - 1)<= mem_dat_o;
            
         when WAIT_FOR_SYNC =>
            mem_dat_b    <= (others => '0');
            mem_wren_b   <= '0';
            mem_clken_b  <= '0';
            
         when CLKDAC =>
            mem_dat_b    <= (others => '0');
            mem_wren_b   <= '0';
            mem_clken_b  <= '0';
            
         when DONE =>
         
      end case;
   end process row_state_out;   
     
------------------------------------------------------------------------
--
-- Instantiate sync
--
------------------------------------------------------------------------
   sync_count :frame_timing
   port map(
      clk_i              => clk_i,
      sync_i             => sync_i,
      frame_rst_i        => rst_nxt_sync,
      clk_count_o      => read_count,
      clk_error_o      => error_count
   );
     
------------------------------------------------------------
--
--  Wishbone interface 
--
------------------------------------------------------------
   
   master_wait    <= '1' when ( stb_i = '0' and cyc_i = '1') else '0';   
   rty_o <= '0'; -- for now
           
   rd_cmd  <= '1' when (stb_i = '1' and cyc_i = '1' and we_i = '0' and 
                       (addr_i = ON_BIAS_ADDR or addr_i = OFF_BIAS_ADDR or 
                        addr_i = STRT_MUX_ADDR or addr_i = ROW_ORDER_ADDR or
                        addr_i = CYC_OO_SYC_ADDR)) else '0'; 
      
   wr_cmd  <= '1' when (stb_i = '1' and cyc_i = '1' and we_i = '1' and 
                       (addr_i = ON_BIAS_ADDR or addr_i = OFF_BIAS_ADDR or 
                        addr_i = STRT_MUX_ADDR or addr_i = ROW_ORDER_ADDR or 
                        addr_i = RESYNC_ADDR)) else '0'; 
      
end rtl;