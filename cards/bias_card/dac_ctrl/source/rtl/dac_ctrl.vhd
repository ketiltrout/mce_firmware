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

-- dac_ctrl.vhd
--
-- Project:	      SCUBA-2
-- Author:	      Mandana Amiri
-- Organisation:      UBC
--
-- Description:
-- Wishbone to (32 + 1 LVDS) serial 16-bit DAC (MAX5443) interface (SPI)
-- DAC_CTRL slave processes the following commands issued by Command_FSM on Bias card:
--              FLUX_FB_ADDR     : to send a 16b bias value to each of 32 DACs
--              BIAS_ADDR        : to send a 16b bias value to an LVDS DAC
--              CYC_OUT_SYNC_ADDR: to send the number of cycles out of sync to the master (cmd_fsm) 
--              RESYNC_ADDR      : to resync with the next sync pulse
-- 
-- Revision history:
-- <date $Date: 2004/04/21 16:51:45 $>	- <initials $Author: mandana $>
-- $Log: dac_ctrl.vhd,v $
-- Revision 1.6  2004/04/21 16:51:45  mandana
-- took send_dac_lvds out of the sensitivity list
--
-- Revision 1.5  2004/04/19 23:41:05  mandana
-- added range settings for DACs
--
-- Revision 1.4  2004/04/16 23:30:58  mandana
-- completed out_sync_cmd and resync_cmd
--
-- Revision 1.3  2004/04/16 00:53:04  mandana
-- seperated snd_dac32 and snd_lvds FSMs
--
-- Revision 1.2  2004/04/15 18:16:40  mandana
-- added WR_DAC32_NXT state to main FSM
--
-- Revision 1.1  2004/04/08 17:56:18  mandana
-- Initial release
--   
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

entity dac_ctrl is
generic(DAC32_CTRL_ADDR    : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := FLUX_FB_ADDR  ;
        DAC_LVDS_CTRL_ADDR : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := BIAS_ADDR
        );
        
port(--  dac_ctrl:
     dac_data_o  : out std_logic_vector(32 downto 0);   
     dac_ncs_o   : out std_logic_vector(32 downto 0);
     dac_clk_o   : out std_logic_vector(32 downto 0);
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
end dac_ctrl;

architecture rtl of dac_ctrl is

-- DAC CTLR:
-- State encoding and state variables:

-- controller states:
type states is (IDLE, WR_DAC32_CMD, WR_DAC32_STORE, WR_DAC32_NXT, WR_DAC32_DONE, WR_DAC_LVDS_CMD, DAC_LVDS_STORE,
                                                    WR_DAC_LVDS_DONE, OUT_SYNC_CMD, RESYNC_CMD); 
signal current_state         : states;
signal next_state            : states;

type snd_lvds_states is (SND_LVDS_IDLE, LVDS_PENDING, SND_LVDS);
signal snd_lvds_current_state     : snd_lvds_states;
signal snd_lvds_next_state        : snd_lvds_states;

type snd_dac32_states is (SND_DAC32_IDLE, DAC32_PENDING, SND_DAC32);
signal snd_dac32_current_state     : snd_dac32_states;
signal snd_dac32_next_state        : snd_dac32_states;


-- Wishbone signals (decoded):
signal master_wait     : std_logic; 
signal read_cmd        : std_logic; -- indicates read cmd received: (out_of_sync_cmd)
signal write_dac32     : std_logic; -- indicates write dac32 bias values are being received
signal write_dac_lvds  : std_logic; -- indicates write lvds dac cmd received
signal write_resync    : std_logic; -- indicates write resync cmd received
signal spi_lvds_busy   : std_logic; -- indicates data is being sent to the lvds dac
signal spi_busy        : std_logic; -- indicates data is being sent to the 32 dacs

signal idac            : integer range 0 to 32;
signal k               : integer range 0 to 32;

-- parallel data signals for DAC
-- subtype word is std_logic_vector (15 downto 0); 
type   w_array32 is array (32 downto 0) of word16; 
signal dac_data_p      : w_array32;

-- send FSM excite signals
signal send_dac32      : std_logic;
signal send_dac_lvds   : std_logic;

-- spi send initiation/terminate signals
signal send_dac32_start: std_logic;
signal send_dac_lvds_start : std_logic;
signal dac_done        : std_logic_vector (32 downto 0);
signal dac_ncs         : std_logic_vector (32 downto 0);

-- for registered values
signal write_buf       : word32;
signal read_buf        : word32;
signal update_bias_count: word32;
signal error_count     : word32;
signal read_count      : word32;
signal rst_nxt_sync    : std_logic;

signal read_lsb_en     : std_logic;
signal read_msb_en     : std_logic;

begin

update_bias_count <= conv_std_logic_vector(UPDATE_BIAS,32); 
dac_ncs_o <= dac_ncs;
------------------------------------------------------------
--
--  DAC controller FSM
--
------------------------------------------------------------   
   state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         current_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         current_state <= next_state;
      end if;
   end process state_FF;

-- Transition table for DAC controller
   state_NS: process(current_state, read_cmd, master_wait, write_dac32, write_dac_lvds, write_resync, spi_busy, spi_lvds_busy)
   begin

      case current_state is
         when IDLE =>
            if read_cmd = '1' then
               next_state <= OUT_SYNC_CMD;                              
            elsif write_dac32 = '1' and spi_busy = '0' then
               next_state <= WR_DAC32_CMD;
            elsif write_dac_lvds = '1' and spi_lvds_busy = '0' then            
               next_state <= WR_DAC_LVDS_CMD;
            elsif write_resync = '1' then
               next_state <= RESYNC_CMD;
            else 
               next_state <= IDLE;
            end if;
            
         when WR_DAC32_CMD =>
            if write_dac32 = '1' then
              next_state <= WR_DAC32_STORE;
            else
              next_state <= WR_DAC32_DONE;
            end if;
            
         when WR_DAC32_STORE =>                    
            next_state <= WR_DAC32_NXT;
            
         when WR_DAC32_NXT =>
            if master_wait = '1' then
               next_state <= WR_DAC32_CMD;
            elsif write_dac32 = '1'then
                  next_state <= WR_DAC32_NXT;
               else   
                  next_state <= WR_DAC32_DONE;
               end if;
      
         when WR_DAC32_DONE =>
            next_state <= IDLE;
           
         when WR_DAC_LVDS_CMD =>
            next_state <= DAC_LVDS_STORE;
        
         when DAC_LVDS_STORE =>
            next_state <= WR_DAC_LVDS_DONE;

         when WR_DAC_LVDS_DONE =>
            if write_dac_lvds = '1' then
               next_state <= WR_DAC_LVDS_DONE;
            else  
               next_state <= IDLE;
            end if;   
            
         when RESYNC_CMD =>
            next_state <= IDLE;                                     
            
         when OUT_SYNC_CMD =>
            next_state <= IDLE; 
                       
      end case;
   end process state_NS;
   
-- Output states for DAC controller   
   state_out: process(current_state, dat_i)
   begin
      case current_state is
         when IDLE  =>       
            idac        <= 0;            
            write_buf   <= (others => 'Z');  
            read_lsb_en <= '0';
            read_msb_en <= '0';
            rst_nxt_sync<= '0';            
            
         when WR_DAC32_CMD =>  
            -- use the previously-set idac value
            write_buf   <= dat_i;            
            read_lsb_en <= '1';
            read_msb_en <= '1';
            rst_nxt_sync<= '0';                        
         
         when WR_DAC32_STORE =>
            -- use the previously-set idac value
            write_buf   <= (others => 'Z'); 
            read_lsb_en <= '1';
            read_msb_en <= '1';            
            rst_nxt_sync<= '0';            
            
            -- range checking for DAC settings
            if (read_buf (15 downto 0) > MAX_DAC_BC) then
               dac_data_p (idac) <= MAX_DAC_BC;
            elsif (read_buf (15 downto 0) < MIN_DAC_BC) then
               dac_data_p (idac) <= MIN_DAC_BC;
            else
               dac_data_p (idac) <= read_buf (15 downto 0);
            end if;   
               
            if (read_buf (31 downto 16) > MAX_DAC_BC) then
               dac_data_p (idac + 1) <= MAX_DAC_BC;
            elsif (read_buf (31 downto 16) < MIN_DAC_BC) then
               dac_data_p (idac + 1) <= MIN_DAC_BC;
            else
               dac_data_p (idac + 1) <= read_buf (31 downto 16);
            end if;   
                                       
         when WR_DAC32_NXT =>  
            idac <= idac + 2;
            if idac > 28 then
               idac  <= 0;
            end if;  
            write_buf   <= (others => 'Z');
            read_lsb_en <= '0';
            read_msb_en <= '0';
            rst_nxt_sync<= '0';            

         when WR_DAC32_DONE =>  
            idac  <= 0;
            write_buf   <= (others => 'Z');
            read_lsb_en <= '0';
            read_msb_en <= '0';
            rst_nxt_sync<= '0';            
            
         when WR_DAC_LVDS_CMD =>
            idac        <= 0;            
            write_buf   <= dat_i;
            read_lsb_en <= '1';                                      -- Temporary
            read_msb_en <= '0';
            rst_nxt_sync<= '0';            
         
         when DAC_LVDS_STORE =>
            idac        <= 0;            
            write_buf   <= (others => 'Z'); 
            read_lsb_en <= '1';
            read_msb_en <= '0';
            rst_nxt_sync<= '0';            
            
            -- range checking for DAC settings
            if (read_buf (15 downto 0) > MAX_DAC_BC) then
               dac_data_p (32) <= MAX_DAC_BC;
            elsif (read_buf (15 downto 0) < MIN_DAC_BC) then
               dac_data_p (32) <= MIN_DAC_BC;
            else
               dac_data_p (32) <= read_buf (15 downto 0);
            end if;   
                                 
         when WR_DAC_LVDS_DONE =>
            idac        <= 0;
            write_buf   <= (others => 'Z');
            read_lsb_en <= '0';                                
            read_msb_en <= '0';
            rst_nxt_sync<= '0';            
            
         when RESYNC_CMD =>            
            -- reset counter on next sync pulse
            idac        <= 0;
            write_buf   <= (others => 'Z');
            read_lsb_en <= '0';
            read_msb_en <= '0';
            rst_nxt_sync<= '1';            
         
         when OUT_SYNC_CMD =>
            idac        <= 0;
            write_buf   <= (others => 'Z');
            read_lsb_en <= '0';
            read_msb_en <= '0';
            rst_nxt_sync<= '0';

      end case;
   end process state_out;
   
------------------------------------------------------------------------
--
-- FSM for sending out the lvds DAC data at UPDAT_BIAS time
-- 
------------------------------------------------------------------------
   snd_lvds_state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         snd_lvds_current_state <= SND_LVDS_IDLE;
      elsif(clk_i'event and clk_i = '1') then
         snd_lvds_current_state <= snd_lvds_next_state;
      end if;
   end process snd_lvds_state_FF;
   
   snd_lvds_state_NS: process (snd_lvds_current_state, send_dac_lvds,read_count)
   begin 
      case snd_lvds_current_state is 
         when SND_LVDS_IDLE => 
            if send_dac_lvds = '1' then
               snd_lvds_next_state <= LVDS_PENDING;
            else 
               snd_lvds_next_state <= SND_LVDS_IDLE;
            end if;   
                     
         when LVDS_PENDING  =>
            if (read_count = update_bias_count) then		    
               snd_lvds_next_state <= SND_LVDS;		            
            else
               snd_lvds_next_state <= LVDS_PENDING;
            end if;           
          
         when SND_LVDS  =>
            snd_lvds_next_state <= SND_LVDS_IDLE;
                                       
      end case;
   end process snd_lvds_state_NS;   
   send_dac_lvds_start <= '1' when (snd_lvds_current_state = SND_LVDS) else '0';
   
--   snd_lvds_state_out: process(snd_lvds_current_state)
--   begin
--      case snd_lvds_current_state is
--         when SND_IDLE =>
--            snd_dac_lvds_start <= '0';
--            
--         when LVDS_PENDING =>
--            snd_dac_lvds_start <= '0';
--            
--         when SND_LVDS => 
--            snd_dac_lvds_start <= '1';
--         
--      end case;
--   end process snd_lvds_state_out;
   
------------------------------------------------------------------------
--
-- FSM for sending out the 32 DAC data at UPDAT_BIAS time
-- 
------------------------------------------------------------------------
   snd_dac32_state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         snd_dac32_current_state <= SND_DAC32_IDLE;
      elsif(clk_i'event and clk_i = '1') then
         snd_dac32_current_state <= snd_dac32_next_state;
      end if;
   end process snd_dac32_state_FF;
   
   snd_dac32_state_NS: process (snd_dac32_current_state, read_count)
   begin 
      case snd_dac32_current_state is 
         when SND_DAC32_IDLE => 
            if send_dac32 = '1' then
               snd_dac32_next_state <= DAC32_PENDING;
            else 
               snd_dac32_next_state <= SND_DAC32_IDLE;
            end if;   
         
         when DAC32_PENDING =>
            if read_count = update_bias_count then   -- ok ok we can store it once during init.
               snd_dac32_next_state <= SND_DAC32;
            else
               snd_dac32_next_state <= DAC32_PENDING;
            end if;
                               
         when SND_DAC32 =>
            snd_dac32_next_state <= SND_DAC32_IDLE;
                       
      end case;
   end process snd_dac32_state_NS;   
   
   send_dac32_start    <= '1' when (snd_dac32_current_state = SND_DAC32) else '0';
    
--   snd_dac32_state_out: process(snd_dac32_current_state)
--   begin
--      case snd_dac32_current_state is
--         when SND_IDLE =>
--            snd_dac32_start <= '0';
--            
--         when LVDS_PENDING =>
--            snd_dac32_start <= '0';
--            
--         when SND_LVDS => 
--            snd_dac32_start <= '1';
--         
--      end case;
--   end process snd_dac32_state_out;

------------------------------------------------------------------------
--
-- Instantiate spi interface blocks, they all share the same start signal
-- and therefore they are all fired at once.
--
------------------------------------------------------------------------

   gen_spi32: for k in 0 to 31 generate
   
      dac_write_spi :write_spi_with_cs
      generic map(DATA_LENGTH => 16)
      port map(--inputs
         spi_clk_i        => clk_i,
         rst_i            => rst_i,
         start_i          => send_dac32_start,
         parallel_data_i  => dac_data_p(k),
       
         --outputs
         spi_clk_o        => dac_clk_o (k),
         done_o           => dac_done  (k),
         spi_ncs_o        => dac_ncs (k),
         serial_wr_data_o => dac_data_o(k)
      );
   end generate gen_spi32;      
   
 ----------------------------------------------------------------------
 --
 -- Instantiate the spi for dac_lvds interface seperately
 -- (lvds dac is indexed by 32)
 --
 ----------------------------------------------------------------------
   dac_write_lvds_spi :write_spi_with_cs

   generic map(DATA_LENGTH => 16)

   port map(--inputs
      spi_clk_i        => clk_i,
      rst_i            => rst_i,
      start_i          => send_dac_lvds_start,
      parallel_data_i  => dac_data_p(32),
    
      --outputs
      spi_clk_o        => dac_clk_o (32),
      done_o           => dac_done  (32),
      spi_ncs_o        => dac_ncs (32),
      serial_wr_data_o => dac_data_o(32)
   );
   
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
   
-------------------------------------------------------------------------
--
-- Instantiate registers for writing the DAC data
--
------------------------------------------------------------------------
   -- buffer DAC data out:
   data_lsb: reg
      generic map(WIDTH => 16)
      port map(clk_i  => clk_i,
               rst_i  => rst_i,
               ena_i  => read_lsb_en,
               reg_i  => write_buf(15 downto 0),
               reg_o  => read_buf(15 downto 0)
      );
   
   data_msb: reg
      generic map(WIDTH => 16)
      port map(clk_i  => clk_i,
               rst_i  => rst_i,
               ena_i  => read_msb_en,
               reg_i  => write_buf(31 downto 16),
               reg_o  => read_buf(31 downto 16)
      );
    
------------------------------------------------------------
--
--  Wishbone interface 
--
------------------------------------------------------------
   
   -- assert ack_o when:
   --    1. wishbone writes FLUX_FB, BIAS, RESYNC_NXT cmds to DAC_CTRL
   --    2. DAC_CTRL data is ready to be read on wishbone
   ack_o <= '1' when (current_state = OUT_SYNC_CMD     or current_state = WR_DAC32_NXT or 
                      current_state = WR_DAC_LVDS_DONE or current_state = RESYNC_CMD) else '0';
   rty_o <= '0'; -- for now
   
   dat_o <= error_count when (current_state = OUT_SYNC_CMD) else (others => '0');

   master_wait      <= '1' when ( addr_i = DAC32_CTRL_ADDR    and stb_i = '0' and cyc_i = '1' and we_i = '1') else '0';   
   read_cmd         <= '1' when ( addr_i = CYC_OO_SYNC_ADDR  and stb_i = '1' and cyc_i = '1' and we_i = '0') else '0';
   write_dac32      <= '1' when ( addr_i = DAC32_CTRL_ADDR    and stb_i = '1' and cyc_i = '1' and we_i = '1') else '0'; 
   write_dac_lvds   <= '1' when ( addr_i = DAC_LVDS_CTRL_ADDR and stb_i = '1' and cyc_i = '1' and we_i = '1') else '0';                               
   write_resync     <= '1' when ( addr_i = RESYNC_ADDR    and stb_i = '1' and cyc_i = '1' and we_i = '1') else '0';                               
   
   -- if command is fully received, now we can send the data to the dacs
   send_dac32       <= '1' when (current_state = WR_DAC32_DONE and cyc_i = '0') else '0';
   send_dac_lvds    <= '1' when (current_state = WR_DAC_LVDS_DONE) else '0';
   
   spi_busy         <= '1' when (dac_ncs (0) = '0'  or dac_ncs(1) = '0'  or dac_ncs(2) = '0'  or dac_ncs(3) = '0'  or
                               dac_ncs (4) = '0'  or dac_ncs(5) = '0'  or dac_ncs(6) = '0'  or dac_ncs(7) = '0'  or
                               dac_ncs (8) = '0'  or dac_ncs(9) = '0'  or dac_ncs(10) = '0' or dac_ncs(11) = '0' or
                               dac_ncs (12) = '0' or dac_ncs(13) = '0' or dac_ncs(14) = '0' or dac_ncs(15) = '0' or
                               dac_ncs (16) = '0' or dac_ncs(17) = '0' or dac_ncs(18) = '0' or dac_ncs(19) = '0' or
                               dac_ncs (20) = '0' or dac_ncs(21) = '0' or dac_ncs(22) = '0' or dac_ncs(20) = '0' or
                               dac_ncs (24) = '0' or dac_ncs(25) = '0' or dac_ncs(26) = '0' or dac_ncs(27) = '0' or
                               dac_ncs (28) = '0' or dac_ncs(29) = '0' or dac_ncs(30) = '0' or dac_ncs(31) = '0') else '0'; 
                               
   spi_lvds_busy    <= '1' when (dac_ncs (32) = '0') else '0';
   
end rtl;