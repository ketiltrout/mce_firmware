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

-- 
--
-- <revision control keyword substitutions e.g. $Id: fibre_rx_protocol.vhd,v 1.6 2005/02/14 23:39:43 mandana Exp $>
--
-- Project:       SCUBA-2
-- Author:        David Atkinson
--               
-- Organisation:  UK ATC
--
-- Description:  fibre_rx_protocol
--
-- This block reads any incomming commands buffered in the rx_fifo and 
-- packages them up for subsequent blocks.
--
-- It checks that the command is preceded by the correct preamble.
-- It also calculates a checksum (sequential 32bit XOR) and compares
-- it to the one tranmitted by the host pc.  If they do not match 
-- an error is flagged at the output.
--
-- If the checksum is correct then the various words of the command
-- are made available at the block's output the and command ready
-- line (cmd_rdycksum_rcvd_mux) is asserted. 
--  
--
-- Once the cmd_ack_i line goes high, the data words associated with the command 
-- are clocked out sequentially (cmd_data_o) on the rising 
-- edge of the clock "data_clk_o".  cmd_rdy_o is asserted during this entire time.  
--
--  see fibre_rx_protocol.doc for more details
--
-- The command stucture for all commands (WB, RB, ST, GO, RS) is as follows:
--
-- word 1 : Preamble
-- word 2 : Preamble
-- word 3 : Command code 
-- word 4 : Address (card and register)
-- word 5 : Number of valid data
-- word 6 : DataV1
-- word 7 : DataV2
--  ''    :  ''
-- word 63: DataV58 
-- word 64: checksum
--
-- Note that all words in the command structure are 32bit and arrive 
-- from the host in byte packets (little endian).
--
-- Revision history:
--
-- $Log: fibre_rx_protocol.vhd,v $
-- Revision 1.6  2005/02/14 23:39:43  mandana
-- Ernie/Mandana: changed memory to Altera altsyncram memory
-- optimized the FSM to keep track of number of bytes and words
-- removed the recirculation muxes
--
--
-- 1st March 2004   - Initial version      - DA
-- 
-- <date $Date: 2005/02/14 23:39:43 $> -     <text>      - <initials $Author: mandana $>
--
-- Log: fibre_rx_protocol.vhd,v $
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.issue_reply_pack.all;
use work.fibre_rx_pack.all;

library components;
use components.component_pack.all;

library sys_param;
use sys_param.command_pack.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

entity fibre_rx_protocol is
   port( 
      rst_i       : in std_logic;                                                -- global reset
      clk_i       : in std_logic;                                                -- global clock 
      rx_fe_i     : in std_logic;                                                -- receive fifo empty flag
      rxd_i       : in std_logic_vector (RX_FIFO_DATA_WIDTH-1 downto 0);         -- receive data byte 
      cmd_ack_i   : in std_logic;                                                -- command acknowledge

      cmd_code_o  : out std_logic_vector (FIBRE_CMD_CODE_WIDTH-1 downto 0);      -- command code  
      card_id_o   : out std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);  -- card id
      param_id_o  : out std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1  downto 0); -- parameter id
      num_data_o  : out std_logic_vector (FIBRE_DATA_SIZE_WIDTH-1 downto 0);     -- number of valid 32-bit data words
      cmd_data_o  : out std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);         -- 32-bit valid data word
      cksum_err_o : out std_logic;                                               -- checksum error flag
      cmd_rdy_o   : out std_logic;                                               -- command ready flag (checksum passed)
      data_clk_o  : out std_logic;                                               -- data clock
      rx_fr_o     : out std_logic                                                -- receive fifo read request
   );

end fibre_rx_protocol;


architecture rtl of fibre_rx_protocol is


-- FSM's states defined
type states is (IDLE, RQ_BYTE, LD_BYTE, WR_WORD, TEST_CKSM, CKSM_PASS, CKSM_FAIL, DATA_READ, DATA_SETL, DATA_TX);
signal current_state : states;
signal next_state    : states;

-- checksum signals
signal cksum_in       : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);    -- current value to be used to update cksum_calc
signal cksum_rcvd     : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);    -- received checksum from rtl pc
signal cksum_calc     : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);    -- calculated checksum value, continually being updated
signal cksum_calc_ena : std_logic;
signal cksum_calc_clr : std_logic;

-- signals mapped to output ports
signal cmd_code  : std_logic_vector (FIBRE_CMD_CODE_WIDTH-1 downto 0);     -- command code  
signal id        : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
signal num_data  : std_logic_vector (FIBRE_DATA_SIZE_WIDTH-1 downto 0);    -- number of valid 32-bit data words
signal cmd_data  : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);        -- 32-bit valid data word
signal cksum_err : std_logic;                                              -- checksum error flag
signal cmd_rdy   : std_logic;                                              -- command ready flag (checksum passed)
signal data_clk  : std_logic;                                              -- data clock
signal rx_fr     : std_logic;                                              -- receive fifo read request

constant BLOCK_SIZE : integer := 58;                                       -- total number of data words in a write_block
signal number_data  : integer;                                             -- this will be a value between 1 and 58

-- memory signals
signal write_pointer : std_logic_vector(5 downto 0);
signal read_pointer  : std_logic_vector(5 downto 0);
signal data_in       : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);     -- current data word written to memory 
signal data_out      : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);     -- current data word read from memory
signal write_mem     : std_logic;                                          -- increment memory write pointer
signal read_mem      : std_logic;                                          -- increment memory read pointer
signal reset_mem     : std_logic; 

-- register load signals
signal ld_cmd_data   : std_logic;
signal ld_cksum_in   : std_logic;
signal ld_cksum_rcvd : std_logic;
signal ld_data       : std_logic;
signal ld_id         : std_logic;
signal ld_nda        : std_logic;
signal ld_cmd        : std_logic;

-- byte counter for byte 0 to 3 of each word
signal byte_count     : integer range 0 to 4;
signal byte_count_ena : std_logic;
signal byte_count_clr : std_logic;

-- word counter for the incoming packet
signal word_count     : integer range 0 to 256;
signal word_count_ena : std_logic;
signal word_count_clr : std_logic;

-- negative clock for the memory
signal n_clk : std_logic;

begin

   -- output assignments

   cmd_code_o      <= cmd_code  ;  
   card_id_o       <= id(31 downto 16);
   param_id_o      <= id(15 downto 0);
   num_data_o      <= num_data  ;    
   cmd_data_o      <= cmd_data  ;
   cksum_err_o     <= cksum_err ;
   cmd_rdy_o       <= cmd_rdy   ;   
   data_clk_o      <= data_clk  ;
   rx_fr_o         <= rx_fr     ;
 

   -- concurrent statement - integer value of number of data.

   number_data <= conv_integer(num_data);
   
  
   -- counters to keep track of which byte/word we are currently loading:
    
   byte_counter: counter
   generic map(MAX => 4)
   port map(clk_i   => clk_i,
            rst_i   => rst_i,
            ena_i   => byte_count_ena,
            load_i  => byte_count_clr,
            count_i => 0,
            count_o => byte_count);
            
   word_counter: counter
   generic map(MAX => 256)
   port map(clk_i   => clk_i,
            rst_i   => rst_i,
            ena_i   => word_count_ena,
            load_i  => word_count_clr,
            count_i => 0,
            count_o => word_count);
            
            
   -- state machine:

   FSM_state : process(clk_i, rst_i)
   begin
      if (rst_i = '1') then
         current_state <= IDLE;
      elsif (clk_i'EVENT AND clk_i = '1') then
         current_state <= next_state;
      end if;

   end process FSM_state;
   
   
   FSM_ns : process(current_state, rx_fe_i, word_count, byte_count, rxd_i, cmd_ack_i, cmd_code, cksum_calc, cksum_rcvd, number_data, read_pointer)
   begin
      case current_state is
         when IDLE =>      if(rx_fe_i = '0') then
                              next_state <= RQ_BYTE;
                           else
                              next_state <= IDLE;
                           end if;
         
         when RQ_BYTE =>   next_state <= LD_BYTE;
         
         when LD_BYTE =>   if(rx_fe_i = '0') then
                              if((word_count = 0 and rxd_i /= FIBRE_PREAMBLE1) or (word_count = 1 and rxd_i /= FIBRE_PREAMBLE2)) then
                                 next_state <= IDLE;                     
                              elsif(byte_count = 3 and word_count > 4 and word_count < BLOCK_SIZE+5) then
                                 next_state <= WR_WORD;
                              else
                                 next_state <= RQ_BYTE;
                              end if;
                           elsif(byte_count = 3 and word_count = BLOCK_SIZE+5) then
                              next_state <= TEST_CKSM;
                           else
                              next_state <= LD_BYTE;
                           end if;
         
         when WR_WORD =>   if(rx_fe_i = '0') then
                              next_state <= RQ_BYTE;
                           else
                              next_state <= WR_WORD;
                           end if;
         
         when TEST_CKSM => if(cmd_ack_i = '1') then
                              next_state <= TEST_CKSM;
                           elsif(cksum_calc = cksum_rcvd) then
                              next_state <= CKSM_PASS;
                           else
                              next_state <= CKSM_FAIL;
                           end if;
         
         when CKSM_PASS => if(cmd_ack_i = '1') then
                              if(number_data = 0 or cmd_code = ASCII_R & ASCII_B) then  
                                 next_state <= IDLE;
                              else
                                 next_state <= DATA_READ; 
                              end if; 
                           else
                              next_state <= CKSM_PASS;
                           end if;
      
         when CKSM_FAIL => next_state <= IDLE;
            
         when DATA_READ => next_state <= DATA_SETL;

         when DATA_SETL => next_state <= DATA_TX;

         when DATA_TX =>   if(read_pointer < number_data) then   
                              next_state <= DATA_READ;
                           else   
                              next_state <= IDLE;
                           end if;               

         when others =>    next_state <= IDLE;
      end case;
   end process FSM_ns;
   
   FSM_out : process(current_state, rx_fe_i, byte_count, word_count)
   begin
      byte_count_ena <= '0';
      byte_count_clr <= '0';
      word_count_ena <= '0';
      word_count_clr <= '0';
      ld_cmd         <= '0';
      ld_id          <= '0';
      ld_nda         <= '0';
      ld_cksum_in    <= '0';
      ld_cksum_rcvd  <= '0';
      ld_data        <= '0';
      ld_cmd_data    <= '0';
      reset_mem      <= '0';
      read_mem       <= '0';
      write_mem      <= '0';
      cksum_calc_ena <= '0';
      cksum_calc_clr <= '0';
      cksum_err      <= '0';
      cmd_rdy        <= '0';
      rx_fr          <= '0';
      data_clk       <= '0';
   
      case current_state is
         when IDLE =>      byte_count_ena <= '1';
                           byte_count_clr <= '1';
                           word_count_ena <= '1';
                           word_count_clr <= '1';
                           reset_mem      <= '1';
                           cksum_calc_clr <= '1';
         
         when RQ_BYTE =>   rx_fr <= '1';
         
         when LD_BYTE =>   case word_count is
                              when 0 => null;
                                
                              when 1 => null;
                                 
                              when 2 => ld_cmd <= '1';
                                        ld_cksum_in <= '1';
                                        if(byte_count = 3) then
                                           cksum_calc_ena <= '1';
                                        end if;
                                         
                              when 3 => ld_id <= '1';
                                        ld_cksum_in <= '1';
                                        if(byte_count = 3) then
                                           cksum_calc_ena <= '1';
                                        end if;
                                           
                              when 4 => ld_nda <= '1';
                                        ld_cksum_in <= '1';
                                        if(byte_count = 3) then
                                           cksum_calc_ena <= '1';
                                        end if;
                                         
                              when 63 => ld_cksum_rcvd <= '1';
                              
                              -- this covers cases 5 to 62:
                              when others => ld_data <= '1';
                                             ld_cksum_in <= '1';
                                             if(byte_count = 3) then
                                                cksum_calc_ena <= '1';
                                             end if;
                           end case;

                           if(rx_fe_i = '0') then  
                              byte_count_ena <= '1';
                              if(byte_count = 3) then 
                                 byte_count_clr <= '1';
                                 word_count_ena <= '1';
                              end if;
                           end if;
                         
         when WR_WORD =>   if(rx_fe_i = '0') then
                              write_mem <= '1';
                           end if;
         
         when CKSM_PASS => cmd_rdy <= '1';
         
         when CKSM_FAIL => cksum_err <= '1';
         
         when DATA_READ => read_mem    <= '1'; 
                           cmd_rdy     <= '1';
                           ld_cmd_data <= '1';

         when DATA_SETL => cmd_rdy <= '1';
            
         when DATA_TX =>   cmd_rdy  <= '1' ;
                           data_clk <= '1' ;
         
         when others =>    null;
      end case;
   end process FSM_out;
      
  
  ----------------------------------------------------------------------------
  -- process to register cmd_code
  ----------------------------------------------------------------------------
  dff_cmd: process(clk_i, rst_i)
  begin
     if (rst_i = '1') then 
        cmd_code(15 downto 0) <= (others => '0');
     elsif (clk_i'EVENT and clk_i = '1') then
        if(ld_cmd = '1') then
           case byte_count is
              when 0 =>      cmd_code(7 downto 0)  <= rxd_i;
              when 1 =>      cmd_code(15 downto 8) <= rxd_i;
              when others => null;
           end case;
        end if;
     end if;
  end process dff_cmd;
  
      
  ----------------------------------------------------------------------------
  -- process to register id
  ----------------------------------------------------------------------------
  dff_id: process(clk_i, rst_i)
  begin
     if (rst_i = '1') then 
        id(31 downto 0) <= (others => '0');
     elsif (clk_i'EVENT and clk_i = '1') then
        if(ld_id = '1') then
           case byte_count is
              when 0 =>      id(7 downto 0)   <= rxd_i;
              when 1 =>      id(15 downto 8)  <= rxd_i;
              when 2 =>      id(23 downto 16) <= rxd_i;
              when others => id(31 downto 24) <= rxd_i;
           end case;
        end if;
     end if;
  end process dff_id;
  
    
  ----------------------------------------------------------------------------
  -- process to register nda
  ----------------------------------------------------------------------------
  dff_nda: process(clk_i, rst_i)
  begin
     if (rst_i = '1') then 
        num_data(31 downto 0) <= (others => '0');
     elsif (clk_i'EVENT and clk_i = '1') then
        if(ld_nda = '1') then
           case byte_count is
              when 0 =>      num_data(7 downto 0)   <= rxd_i;
              when 1 =>      num_data(15 downto 8)  <= rxd_i;
              when 2 =>      num_data(23 downto 16) <= rxd_i;
              when others => num_data(31 downto 24) <= rxd_i;
           end case;
        end if;
     end if;
  end process dff_nda;
  
  
  ----------------------------------------------------------------------------
  -- process to register cksum_in
  ----------------------------------------------------------------------------
  dff_ckin: process(clk_i, rst_i)
  begin
     if (rst_i = '1') then 
        cksum_in(31 downto 0) <= (others => '0');
     elsif (clk_i'EVENT and clk_i = '1') then
        if(ld_cksum_in = '1') then
           case byte_count is
              when 0 =>      cksum_in(7 downto 0)   <= rxd_i;
              when 1 =>      cksum_in(15 downto 8)  <= rxd_i;
              when 2 =>      cksum_in(23 downto 16) <= rxd_i;
              when others => cksum_in(31 downto 24) <= rxd_i;
           end case;
        end if;        
     end if;
  end process dff_ckin;
         

  ----------------------------------------------------------------------------
  -- process to register cksum_rcvd
  ----------------------------------------------------------------------------
  dff_ckrx: process(clk_i, rst_i)
  begin
     if (rst_i = '1') then 
        cksum_rcvd(31 downto 0) <= (others => '0');
     elsif (clk_i'EVENT and clk_i = '1') then
        if(ld_cksum_rcvd = '1') then
           case byte_count is
              when 0 =>      cksum_rcvd(7 downto 0)   <= rxd_i;
              when 1 =>      cksum_rcvd(15 downto 8)  <= rxd_i;
              when 2 =>      cksum_rcvd(23 downto 16) <= rxd_i;
              when others => cksum_rcvd(31 downto 24) <= rxd_i;
           end case;
        end if;  
     end if;
  end process dff_ckrx;
         

  ----------------------------------------------------------------------------
  -- process to register data
  ----------------------------------------------------------------------------
  dff_data: process(clk_i, rst_i)
  begin
     if (rst_i = '1') then 
        data_in (31 downto 0) <= (others => '0');
     elsif (clk_i'EVENT and clk_i = '1') then
        if(ld_data = '1') then
           case byte_count is
              when 0 =>      data_in(7 downto 0)   <= rxd_i;
              when 1 =>      data_in(15 downto 8)  <= rxd_i;
              when 2 =>      data_in(23 downto 16) <= rxd_i;
              when others => data_in(31 downto 24) <= rxd_i;
           end case;
        end if;  
     end if;
  end process dff_data;


  ----------------------------------------------------------------------------
  -- process to register cmd data word
  ----------------------------------------------------------------------------
  dff_cmd_data: process(clk_i, rst_i)
  begin
     if (rst_i = '1') then 
        cmd_data (31 downto 0) <= (others => '0');
     elsif (clk_i'EVENT and clk_i = '1') then
        if(ld_cmd_data = '1') then
           cmd_data <= data_out;
        end if;
     end if;
  end process dff_cmd_data;


  ----------------------------------------------------------------------------
  -- process to store calculated checksum
  ----------------------------------------------------------------------------
  checksum_calc : process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         cksum_calc <= (others => '0');
      elsif(clk_i = '1' and clk_i'event) then
         if(cksum_calc_clr = '1') then
            cksum_calc <= (others => '0');
         elsif(cksum_calc_ena = '1') then
            cksum_calc <= cksum_calc xor cksum_in;
         end if;
      end if;
   end process checksum_calc;
   
   
  ----------------------------------------------------------------------------
  -- process to perform memory read/write 
  ----------------------------------------------------------------------------
  read_write_memory: process(reset_mem, clk_i)
  begin
     if (reset_mem = '1') then
        write_pointer <= (others => '0');        
        read_pointer  <= (others => '0');
     elsif(clk_i = '1' and clk_i'event) then
        if (write_mem = '1') then
           write_pointer <= write_pointer + 1;
        end if; 
        if (read_mem = '1') then
           read_pointer <= read_pointer + 1;
        end if; 
     end if;   

  end process read_write_memory;


  ----------------------------------------------------------------------------
  -- memory instantiation 
  ----------------------------------------------------------------------------
          
  n_clk <= not clk_i;
 
  mem0 : altsyncram
  generic map(WIDTH_A   => 32,
              WIDTHAD_A => 6,
              WIDTH_B   => 32,
              WIDTHAD_B => 6,
              OPERATION_MODE         => "DUAL_PORT",
              INTENDED_DEVICE_FAMILY => "Stratix",
              ADDRESS_REG_B          => "CLOCK1",
              OUTDATA_REG_B          => "UNREGISTERED")
  port map(clock0 => clk_i,
           clock1 => n_clk,
           address_a => write_pointer,
           address_b => read_pointer,
           wren_a => write_mem,
           data_a => data_in,
           q_b => data_out);
  
end rtl;
