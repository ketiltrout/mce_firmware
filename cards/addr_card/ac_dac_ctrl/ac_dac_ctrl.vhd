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
-- Wishbone to 41 parallel 14-bit 165MS/s DAC (AD9744) interface 
-- AC_DAC_CTRL slave processes the following commands issued by Command_FSM(Wishbone Master) on address card:
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

--subtype word14    is std_logic_vector(13 downto 0);
--type    w_array11 is array (10 downto 0) of word14; 

entity ac_dac_ctrl is        
port(-- ac_dac_ctrl:
     dac_data_o  : out w_array11;   
     dac_clk_o   : out std_logic_vector(40 downto 0);
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
type states is (IDLE, WR, WR_MEM, WR_ACK, WR_NXT, RD, RD_MEM1, RD_MEM2, RD_ACK, RD_NXT, RESYNC, OUT_SYNC); 
                
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

-- memory signals
signal mem_addr        : word8;
signal mem_clk         : std_logic;
signal mem_clken       : std_logic;
signal mem_dat_i       : word16;
signal mem_dat_o       : word16;
signal mem_wren        : std_logic;

-- row counter signals
signal idac            : integer range 0 to 40;
signal idac_rst        : std_logic;
signal idac_clk        : std_logic;
signal idac_sig        : word8;

signal base            : word8;
signal start_mux       : std_logic;
signal rst_nxt_sync    : std_logic;
signal error_count     : word32;
signal read_count      : word32;


component mem_16x256 IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		clock		: IN STD_LOGIC ;
		clken          : IN STD_LOGIC;
		data		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		wren		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
	);
END component;

component adder IS
	PORT
	(
		dataa		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		datab		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		result		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END component;


begin

-- instantiations
   mem_16x256_inst : mem_16x256 PORT MAP (
	      address => mem_addr,
	      clock  => mem_clk,
	      clken  => mem_clken,
	      data   => mem_dat_i,
	      wren   => mem_wren,
	      q	     => mem_dat_o
	);

   adder_inst : adder PORT MAP (
		dataa	 => base,
		datab	 => idac_sig,
		result	 => mem_addr
	);

--   read_reg: reg
--     generic map(WIDTH => 32)
--      port map(clk_i  => clk_i,
--               rst_i  => rst_i,
--               ena_i  => read_reg_en,
--               reg_i  => write_buf(31 downto 0),
--               reg_o  => read_buf(31 downto 0)
--      );
   idac_counter: counter 
   generic map(MAX => 40)
   port map(clk_i   => idac_clk,
            rst_i   => idac_rst,
            ena_i   => '1',
            load_i  => '0',
            down_i  => '0',
            count_i => 0,
            count_o => idac);

   row_counter: counter 
   generic map(MAX => 40)
   port map(clk_i   => idac_clk,
            rst_i   => idac_rst,
            ena_i   => '1',
            load_i  => '0',
            down_i  => '0',
            count_i => 0,
            count_o => idac);
                                    
   idac_sig <= conv_std_logic_vector(idac, 8);                                    
   mem_clk  <= not(clk_i);
   
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
            if (addr_i = ON_BIAS_ADDR  or addr_i = OFF_BIAS_ADDR or 
                addr_i = STRT_MUX_ADDR or addr_i = ROW_ORDER_ADDR) then
               next_state <= WR_MEM;
            elsif addr_i = RESYNC_ADDR then
               next_state <= RESYNC;
            end if;
            
         when WR_MEM =>
            next_state <= WR_ACK;
            
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
            next_state <= RD_MEM2;
            
         when RD_MEM2 =>
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
   state_out: process(current_state, dat_i, addr_i, mem_dat_o)
   begin
      case current_state is
         when IDLE  =>                   
            ack_o      <= '0';
            idac_rst   <= '1';
            idac_clk   <= '0';
            base       <= (others => '0');
            mem_dat_i  <= (others => '0');
            mem_wren   <= '0';
            mem_clken  <= '0';
            start_mux  <= '0';
            rst_nxt_sync <= '0';
            
         when WR =>  
            ack_o      <= '0';
            idac_rst   <= '0';
            idac_clk   <= '0';            
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
            mem_dat_i  <= dat_i(15 downto 0);
            mem_wren   <= '1';
            mem_clken  <= '1';
            rst_nxt_sync <= '0';
                        
         when WR_MEM =>
            ack_o      <= '0';
            idac_rst   <= '0';
            idac_clk   <= '1';
            base       <= (others => '0');
            mem_dat_i  <= dat_i(31 downto 16);
            mem_wren   <= '1';
            mem_clken  <= '1';
            rst_nxt_sync <= '0';

         when WR_ACK =>
            ack_o      <= '1';
            idac_rst   <= '0';
            idac_clk   <= '0';            
            base       <= (others => '0');
            mem_dat_i  <= (others => '0');
            mem_wren   <= '0';
            mem_clken  <= '0';
            rst_nxt_sync <= '0';
                       
         when WR_NXT =>
            ack_o      <= '0';
            idac_rst   <= '0';
            idac_clk   <= '1';            
            base       <= (others => '0');
            mem_dat_i  <= (others => '0');
            mem_wren   <= '0';
            mem_clken  <= '0';
            rst_nxt_sync <= '0';
                     
         when RD =>
            ack_o      <= '0';
            idac_rst   <= '0';
            idac_clk   <= '0';
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
            mem_wren   <= '0';
            mem_clken  <= '1';
            rst_nxt_sync <= '0';
		       
         when RD_MEM1 => 
            ack_o      <= '0';
            idac_rst   <= '0';
            idac_clk   <= '0';
            dat_o(15 downto 0) <= mem_dat_o;
            base       <= (others => '0');
            mem_wren   <= '0';
            mem_clken  <= '1';
            rst_nxt_sync <= '0';
	       
         when RD_MEM2 => 
            ack_o      <= '0';
            idac_rst   <= '0';
            idac_clk   <= '1';
            dat_o(31 downto 16) <= mem_dat_o;
            base       <= (others => '0');
            mem_wren   <= '0';
            mem_clken  <= '1';
            rst_nxt_sync <= '0';

         when RD_ACK => 
            ack_o      <= '1';
            idac_rst   <= '0';
            idac_clk   <= '0';
            dat_o(31 downto 16) <= mem_dat_o;
            base       <= (others => '0');
--            dat_o <= (others => '0');
            mem_wren   <= '0';
            mem_clken  <= '1';
            rst_nxt_sync <= '0';
	       
         when RD_NXT =>
            ack_o      <= '0';
            idac_rst   <= '0';
            idac_clk   <= '1';
            dat_o <= (others => '0');
            base       <= (others => '0');
            mem_wren   <= '0';            
            mem_clken  <= '0';
            rst_nxt_sync <= '0';
               
         when RESYNC =>            
            ack_o      <= '1';
            idac_rst   <= '1';
            idac_clk   <= '0';
            base       <= (others => '0');
            mem_dat_i  <= (others => '0');
            mem_wren   <= '0';
            mem_clken  <= '0';
            rst_nxt_sync <= '1';
 	       
         when OUT_SYNC =>
            ack_o       <= '1';
            idac_rst    <= '1';
            idac_clk    <= '0';
            base        <= (others => '0');
            mem_dat_i   <= (others => '0');
            mem_wren    <= '0';
            mem_clken   <= '0';
            dat_o       <= error_count;
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
              row_next_state <= PREP;
           else
              row_next_state <= IDLE;
           end if;
           
         when PREP =>
           if read_count = 
           
         when CLKDAC =>
         
         when DONE =>
         
         
      end case;
   end process row_state_NS;   
      
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