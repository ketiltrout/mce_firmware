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
-- <revision control keyword substitutions e.g. $Id: fibre_rx_protocol.vhd,v 1.9 2004/09/28 15:21:55 dca Exp $>
--
-- Project:	      SCUBA-2
-- Author:	      David Atkinson
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
-- 1st March 2004   - Initial version      - DA
-- 
-- <date $Date: 2004/09/28 15:21:55 $>	-		<text>		- <initials $Author: dca $>
--
-- Log: fibre_rx_protocol.vhd,v $
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.issue_reply_pack.all;
use work.fibre_rx_pack.all;

library sys_param;
use sys_param.command_pack.all;

entity fibre_rx_protocol is
   port( 
      rst_i       : in     std_logic;                                          -- global reset
      clk_i       : in     std_logic;                                          -- global clock 
      rx_fe_i     : in     std_logic;                                          -- receive fifo empty flag
      rxd_i       : in     std_logic_vector (RX_FIFO_DATA_WIDTH-1 downto 0);   -- receive data byte 
      cmd_ack_i   : in     std_logic;                                          -- command acknowledge

      cmd_code_o  : out    std_logic_vector (CMD_CODE_BUS_WIDTH-1 downto 0);   -- command code  
      card_id_o   : out    std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);  -- card id
      param_id_o  : out    std_logic_vector (PAR_ID_BUS_WIDTH-1  downto 0);    -- parameter id
      num_data_o  : out    std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);  -- number of valid 32-bit data words
      cmd_data_o  : out    std_logic_vector (DATA_BUS_WIDTH-1 downto 0);       -- 32-bit valid data word
      cksum_err_o : out    std_logic;                                          -- checksum error flag
      cmd_rdy_o   : out    std_logic;                                          -- command ready flag (checksum passed)
      data_clk_o  : out    std_logic;                                          -- data clock
      rx_fr_o     : out    std_logic                                           -- receive fifo read request
   );

end fibre_rx_protocol;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


architecture rtl of fibre_rx_protocol is


-- FSM's states defined

constant IDLE            : std_logic_vector(5 downto 0) := "000000";

constant RQ_PRE0         : std_logic_vector(5 downto 0) := "000001";
constant CK_PRE0         : std_logic_vector(5 downto 0) := "000010";
constant RQ_PRE1         : std_logic_vector(5 downto 0) := "000011";
constant CK_PRE1         : std_logic_vector(5 downto 0) := "000100";
constant RQ_PRE2         : std_logic_vector(5 downto 0) := "000101";
constant CK_PRE2         : std_logic_vector(5 downto 0) := "000110";
constant RQ_PRE3         : std_logic_vector(5 downto 0) := "000111";
constant CK_PRE3         : std_logic_vector(5 downto 0) := "001000";

constant RQ_PRE4         : std_logic_vector(5 downto 0) := "001001";
constant CK_PRE4         : std_logic_vector(5 downto 0) := "001010";
constant RQ_PRE5         : std_logic_vector(5 downto 0) := "001011";
constant CK_PRE5         : std_logic_vector(5 downto 0) := "001100";
constant RQ_PRE6         : std_logic_vector(5 downto 0) := "001101";
constant CK_PRE6         : std_logic_vector(5 downto 0) := "001110";
constant RQ_PRE7         : std_logic_vector(5 downto 0) := "001111";
constant CK_PRE7         : std_logic_vector(5 downto 0) := "010000";

constant RQ_CMD0         : std_logic_vector(5 downto 0) := "010001";
constant LD_CMD0         : std_logic_vector(5 downto 0) := "010010";
constant RQ_CMD1         : std_logic_vector(5 downto 0) := "010011";
constant LD_CMD1         : std_logic_vector(5 downto 0) := "010100";
constant RQ_CMD2         : std_logic_vector(5 downto 0) := "010101";
constant LD_CMD2         : std_logic_vector(5 downto 0) := "010110";
constant RQ_CMD3         : std_logic_vector(5 downto 0) := "010111";
constant LD_CMD3         : std_logic_vector(5 downto 0) := "011000";

constant RQ_ID0          : std_logic_vector(5 downto 0) := "011001";
constant LD_ID0          : std_logic_vector(5 downto 0) := "011010";
constant RQ_ID1          : std_logic_vector(5 downto 0) := "011011";
constant LD_ID1          : std_logic_vector(5 downto 0) := "011100";
constant RQ_ID2          : std_logic_vector(5 downto 0) := "011101";
constant LD_ID2          : std_logic_vector(5 downto 0) := "011110";
constant RQ_ID3          : std_logic_vector(5 downto 0) := "011111";
constant LD_ID3          : std_logic_vector(5 downto 0) := "100000";

constant RQ_CKSM0        : std_logic_vector(5 downto 0) := "100001";
constant LD_CKSM0        : std_logic_vector(5 downto 0) := "100010";
constant RQ_CKSM1        : std_logic_vector(5 downto 0) := "100011";
constant LD_CKSM1        : std_logic_vector(5 downto 0) := "100100";
constant RQ_CKSM2        : std_logic_vector(5 downto 0) := "100101";
constant LD_CKSM2        : std_logic_vector(5 downto 0) := "100110";
constant RQ_CKSM3        : std_logic_vector(5 downto 0) := "100111";
constant LD_CKSM3        : std_logic_vector(5 downto 0) := "101000";

constant RQ_NDA0         : std_logic_vector(5 downto 0) := "101001";
constant LD_NDA0         : std_logic_vector(5 downto 0) := "101010";
constant RQ_NDA1         : std_logic_vector(5 downto 0) := "101011";
constant LD_NDA1         : std_logic_vector(5 downto 0) := "101100";
constant RQ_NDA2         : std_logic_vector(5 downto 0) := "101101";
constant LD_NDA2         : std_logic_vector(5 downto 0) := "101110";
constant RQ_NDA3         : std_logic_vector(5 downto 0) := "101111";
constant LD_NDA3         : std_logic_vector(5 downto 0) := "110000";

constant RQ_BLK0         : std_logic_vector(5 downto 0) := "110001";
constant LD_BLK0         : std_logic_vector(5 downto 0) := "110010";
constant RQ_BLK1         : std_logic_vector(5 downto 0) := "110011";
constant LD_BLK1         : std_logic_vector(5 downto 0) := "110100";
constant RQ_BLK2         : std_logic_vector(5 downto 0) := "110101";
constant LD_BLK2         : std_logic_vector(5 downto 0) := "110110";
constant RQ_BLK3         : std_logic_vector(5 downto 0) := "110111";
constant LD_BLK3         : std_logic_vector(5 downto 0) := "111000";

constant WM_BLK          : std_logic_vector(5 downto 0) := "111001";
constant TEST_CKSM       : std_logic_vector(5 downto 0) := "111010";
constant CKSM_FAIL       : std_logic_vector(5 downto 0) := "111011";
constant CKSM_PASS       : std_logic_vector(5 downto 0) := "111100";
constant DATA_READ       : std_logic_vector(5 downto 0) := "111101";
constant DATA_SETL       : std_logic_vector(5 downto 0) := "111110";
constant DATA_TX         : std_logic_vector(5 downto 0) := "111111";




-- controller state variables:
signal current_state     : std_logic_vector(5 downto 0);
signal next_state        : std_logic_vector(5 downto 0);


-- Architecture Declarations
constant preamble1       : std_logic_vector(7 downto 0) := X"A5";
constant preamble2       : std_logic_vector(7 downto 0) := X"5A";

-- internal architecture signals 

signal cksum_calc        : std_logic_vector(31 downto 0);    -- calculated checksum value, continually being updated
signal cksum_in          : std_logic_vector(31 downto 0);    -- current value to be used to update cksum_calc
signal cksum_rcvd        : std_logic_vector(31 downto 0);    -- received checksum from rtl pc

signal check_update      : std_logic;                        -- control signal to initiate a checksum update
signal check_reset       : std_logic;                        -- control signal to initiate a checksum reset

--signal cksum_calc_mux     : std_logic_vector(31 downto 0);
signal cksum_calc_mux_sel : std_logic_vector(1 downto 0);

--signal cksum_calc2        : std_logic_vector(31 downto 0); 
signal cksum_calc_reg     : std_logic_vector(31 downto 0); 

-- signals mapped to output ports

signal cmd_code          : std_logic_vector (CMD_CODE_BUS_WIDTH-1 downto 0);   -- command code  
signal card_id           : std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);  -- card id
signal param_id          : std_logic_vector (PAR_ID_BUS_WIDTH-1  downto 0);    -- parameter id
signal num_data          : std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);  -- number of valid 32-bit data words
signal cmd_data          : std_logic_vector (DATA_BUS_WIDTH-1 downto 0);       -- 32-bit valid data word
signal cksum_err         : std_logic;                                          -- checksum error flag
signal cmd_rdy           : std_logic;                                          -- command ready flag (checksum passed)
signal data_clk          : std_logic;                                          -- data clock
signal rx_fr             : std_logic;	                                         -- receive fifo read request

-- mux outputs used to register command bytes

signal cmd_code_mux      : std_logic_vector (CMD_CODE_BUS_WIDTH-1 downto 0);   -- command code  
signal card_id_mux       : std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);  -- card id
signal param_id_mux      : std_logic_vector (PAR_ID_BUS_WIDTH-1  downto 0);    -- parameter id
signal num_data_mux      : std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);  -- number of valid 32-bit data words


signal cksum_in_mux      : std_logic_vector(31 downto 0);                      -- checksum in value to be registered 
signal cksum_rcvd_mux    : std_logic_vector(31 downto 0);                      -- checksum rcvd value to be registered
signal data_in_mux       : std_logic_vector (DATA_BUS_WIDTH-1 downto 0);       -- data word to be registered in memory buffer
signal cmd_data_mux      : std_logic_vector (DATA_BUS_WIDTH-1 downto 0);       -- data word to be registered at output



-- local memory buffer declaration

constant mem_size        : positive := 64;

subtype word is std_logic_vector(31 downto 0);
type mem is array (0 to mem_size-1) of word;
signal memory: mem;

subtype mem_deep is integer range 0 to mem_size-1;
signal write_pointer     : mem_deep;
signal read_pointer      : mem_deep;

constant block_size      : mem_deep := 58;                                    -- total number of data words in a write_block

signal number_data       : integer;                                           -- this will be a value between 1 and 58
signal data_in           : std_logic_vector(DATA_BUS_WIDTH-1 downto 0);       -- current data word written to memory 
signal data_out          : std_logic_vector(DATA_BUS_WIDTH-1 downto 0);       -- current data word read from memory
signal write_mem         : std_logic;                                         -- write current data word to memory
signal read_mem          : std_logic;                                         -- read current data word from memory
signal reset_mem         : std_logic; 



-- mux select lines used when registering command code bytes
signal cmd_mux_sel0      : std_logic;
signal cmd_mux_sel1      : std_logic;

-- mux select lines used when registering id bytes
signal id_mux_sel0       : std_logic;
signal id_mux_sel1       : std_logic;
signal id_mux_sel2       : std_logic;
signal id_mux_sel3       : std_logic;

-- mux select lines used when registering number of data byte
signal nda_mux_sel0      : std_logic;
signal nda_mux_sel1      : std_logic;
signal nda_mux_sel2      : std_logic;
signal nda_mux_sel3      : std_logic;

-- mux select lines used when registering current 32bit command word to checksum calculator
signal ckin_mux_sel0     : std_logic;
signal ckin_mux_sel1     : std_logic;
signal ckin_mux_sel2     : std_logic;
signal ckin_mux_sel3     : std_logic;

-- mux select lines used when registering received checksum bytes
signal ckrx_mux_sel0     : std_logic;
signal ckrx_mux_sel1     : std_logic;
signal ckrx_mux_sel2     : std_logic;
signal ckrx_mux_sel3     : std_logic;

-- mux select lines used when registering command data word to local memory buffer
signal data_in_mux_sel0  : std_logic;
signal data_in_mux_sel1  : std_logic;
signal data_in_mux_sel2  : std_logic;
signal data_in_mux_sel3  : std_logic;

-- output data MUX select line to register output data word

signal data_out_mux_sel  : std_logic;


begin

-- output assignments

   cmd_code_o      <= cmd_code  ;  
   card_id_o       <= card_id   ;
   param_id_o      <= param_id  ;
   num_data_o      <= num_data  ;    
   cmd_data_o      <= cmd_data  ;
   cksum_err_o     <= cksum_err ;
   cmd_rdy_o       <= cmd_rdy   ;   
   data_clk_o      <= data_clk  ;
   rx_fr_o         <= rx_fr     ;
   
  
   
-- recirculation mux code
   
   cmd_code_mux (7  downto 0)    <= rxd_i (7 downto 0) when cmd_mux_sel0     = '1' else cmd_code   (7  downto 0);
   cmd_code_mux (15 downto 8)    <= rxd_i (7 downto 0) when cmd_mux_sel1     = '1' else cmd_code   (15 downto 8);
  
   
   param_id_mux (7  downto 0)    <= rxd_i (7 downto 0) when id_mux_sel0      = '1' else param_id   (7  downto 0);  
   param_id_mux (15 downto 8)    <= rxd_i (7 downto 0) when id_mux_sel1      = '1' else param_id   (15 downto 8);
   card_id_mux  (7  downto 0)    <= rxd_i (7 downto 0) when id_mux_sel2      = '1' else card_id    (7  downto 0);  
   card_id_mux  (15 downto 8)    <= rxd_i (7 downto 0) when id_mux_sel3      = '1' else card_id    (15 downto 8);
   
   num_data_mux (7  downto 0)    <= rxd_i (7 downto 0) when nda_mux_sel0     = '1' else num_data   (7  downto 0); 
   num_data_mux (15 downto 8)    <= rxd_i (7 downto 0) when nda_mux_sel1     = '1' else num_data   (15  downto 8);
   num_data_mux (23 downto 16)   <= rxd_i (7 downto 0) when nda_mux_sel2     = '1' else num_data   (23  downto 16);
   num_data_mux (31 downto 24)   <= rxd_i (7 downto 0) when nda_mux_sel3     = '1' else num_data   (31  downto 24);

   
   data_in_mux (7  downto 0)     <= rxd_i (7 downto 0) when data_in_mux_sel0 = '1' else data_in    (7  downto 0);
   data_in_mux (15 downto 8)     <= rxd_i (7 downto 0) when data_in_mux_sel1 = '1' else data_in    (15 downto 8);
   data_in_mux (23 downto 16)    <= rxd_i (7 downto 0) when data_in_mux_sel2 = '1' else data_in    (23 downto 16);
   data_in_mux (31 downto 24)    <= rxd_i (7 downto 0) when data_in_mux_sel3 = '1' else data_in    (31 downto 24);
 
 
   cksum_rcvd_mux (7  downto 0)  <= rxd_i (7 downto 0) when ckrx_mux_sel0    = '1' else cksum_rcvd (7  downto 0);
   cksum_rcvd_mux (15 downto 8)  <= rxd_i (7 downto 0) when ckrx_mux_sel1    = '1' else cksum_rcvd (15 downto 8);
   cksum_rcvd_mux (23 downto 16) <= rxd_i (7 downto 0) when ckrx_mux_sel2    = '1' else cksum_rcvd (23 downto 16);
   cksum_rcvd_mux (31 downto 24) <= rxd_i (7 downto 0) when ckrx_mux_sel3    = '1' else cksum_rcvd (31 downto 24);
    
  
   cksum_in_mux (7  downto 0)    <= rxd_i (7 downto 0) when ckin_mux_sel0    = '1' else cksum_in   (7  downto 0);
   cksum_in_mux (15 downto 8)    <= rxd_i (7 downto 0) when ckin_mux_sel1    = '1' else cksum_in   (15 downto 8);
   cksum_in_mux (23 downto 16)   <= rxd_i (7 downto 0) when ckin_mux_sel2    = '1' else cksum_in   (23 downto 16);
   cksum_in_mux (31 downto 24)   <= rxd_i (7 downto 0) when ckin_mux_sel3    = '1' else cksum_in   (31 downto 24);
 
  
-- output data MUX

   cmd_data_mux (31 downto 0) <= data_out (31 downto 0) when data_out_mux_sel = '1' else cmd_data  (31 downto 0);
 

-- concurrent statement - integer value of number of data.


  number_data <= To_integer(Unsigned(num_data(7 downto 0)));
   
   

-- processes

   ----------------------------------------------------------------------------
   clocked : process(
      clk_i,
      rst_i
   )
   ----------------------------------------------------------------------------
   begin
         
      if (rst_i = '1') then
         current_state <= IDLE;
      elsif (clk_i'EVENT AND clk_i = '1') then
         current_state <= next_state;
      end if;

   end process clocked;

   ----------------------------------------------------------------------------
   nextstate : process (
      current_state,
      rx_fe_i,
      rxd_i,
      cmd_ack_i,
      cksum_calc,
      cksum_rcvd,
      write_pointer,
      read_pointer,
      number_data --,
   --   cmd_code
   )
   ----------------------------------------------------------------------------
   begin
     
      case current_state is


      when IDLE =>
         if (rx_fe_i = '0') then
            next_state <= RQ_PRE0;
         else
            next_state <= IDLE;
         end if;

   ------------------------------------------------
   
   --preamble states

      when RQ_PRE0 =>
         next_state <= CK_PRE0;
      when RQ_PRE1 =>
         next_state <= CK_PRE1;
      when RQ_PRE2 =>
         next_state <= CK_PRE2;
      when RQ_PRE3 =>
         next_state <= CK_PRE3;
      when RQ_PRE4 =>
         next_state <= CK_PRE4;
      when RQ_PRE5 =>
         next_state <= CK_PRE5;
      when RQ_PRE6 =>
         next_state <= CK_PRE6;
      when RQ_PRE7 =>
         next_state <= CK_PRE7;


      when CK_PRE0 =>
         if (rxd_i(7 downto 0) /= preamble1) then
            next_state <= IDLE;
         else
            if (rx_fe_i = '0') then
               next_state <= RQ_PRE1;
            else
               next_state <= CK_PRE0;
            end if; 
         end if;
         
      when CK_PRE1 =>
         if (rxd_i(7 downto 0) /= preamble1) then
            next_state <= IDLE;
         else
            if (rx_fe_i = '0') then
               next_state <= RQ_PRE2;
            else
               next_state <= CK_PRE1;
            end if; 
         end if;
         
      when CK_PRE2 =>
         if (rxd_i(7 downto 0) /= preamble1) then
            next_state <= IDLE;
         else
            if (rx_fe_i = '0') then
               next_state <= RQ_PRE3;
            else
               next_state <= CK_PRE2;
            end if; 
         end if;
         
      when CK_PRE3 =>
         if (rxd_i(7 downto 0) /= preamble1) then
            next_state <= IDLE;
         else
            if (rx_fe_i = '0') then
               next_state <= RQ_PRE4;
            else
               next_state <= CK_PRE3;
            end if; 
         end if;
         
      when CK_PRE4 =>
         if (rxd_i(7 downto 0) /= preamble2) then
            next_state <= IDLE;
         else
            if (rx_fe_i = '0') then
               next_state <= RQ_PRE5;
            else
               next_state <= CK_PRE4;
            end if; 
         end if;

      when CK_PRE5 =>
         if (rxd_i(7 downto 0) /= preamble2) then
            next_state <= IDLE;
         else
            if (rx_fe_i = '0') then
               next_state <= RQ_PRE6;
            else
               next_state <= CK_PRE5;
            end if; 
         end if;

      when CK_PRE6 =>
         if (rxd_i(7 downto 0) /= preamble2) then
            next_state <= IDLE;
         else
            if (rx_fe_i = '0') then
               next_state <= RQ_PRE7;
            else
               next_state <= CK_PRE6;
            end if; 
         end if;
         
      when CK_PRE7 =>
         if (rxd_i(7 downto 0) /= preamble2) then
            next_state <= IDLE;
         else
            if (rx_fe_i = '0') then
               next_state <= RQ_CMD0;
            else
               next_state <= CK_PRE7;
            end if; 
         end if;                           
                                             
 
                  
   --------------------------------------------
   -- command word states
       
      when RQ_CMD0 =>
            next_state <= LD_CMD0;
      when RQ_CMD1 =>
            next_state <= LD_CMD1;
      when RQ_CMD2 =>
            next_state <= LD_CMD2;
      when RQ_CMD3 =>
            next_state <= LD_CMD3;


      when LD_CMD0 =>
         if (rx_fe_i = '0') then
            next_state <= RQ_CMD1;
         else
            next_state <= LD_CMD0;
         end if;
      when LD_CMD1 =>
         if (rx_fe_i = '0') then
            next_state <= RQ_CMD2;
         else
            next_state <= LD_CMD1;
         end if;
      when LD_CMD2 =>
         if (rx_fe_i = '0') then
            next_state <= RQ_CMD3;
         else
            next_state <= LD_CMD2;
         end if;
      when LD_CMD3 =>
         if (rx_fe_i = '0') then
            next_state <= RQ_ID0;
         else
            next_state <= LD_CMD3;
         end if;
   ---------------------------------------------------------
   --- card id and param id states

      when RQ_ID0 =>
            next_state <= LD_ID0;
      when RQ_ID1 =>
            next_state <= LD_ID1;
      when RQ_ID2 =>
            next_state <= LD_ID2;
      when RQ_ID3 =>
            next_state <= LD_ID3;
 

      when LD_ID0 =>
         if (rx_fe_i = '0') then
            next_state <= RQ_ID1;
         else
            next_state <= LD_ID0;
         end if;
      when LD_ID1 =>
         if (rx_fe_i = '0') then
            next_state <= RQ_ID2;
         else
            next_state <= LD_ID1;
         end if;
      when LD_ID2 =>
         if (rx_fe_i = '0') then
            next_state <= RQ_ID3;
         else
            next_state <= LD_ID2;
         end if;        

      when LD_ID3 =>
         if (rx_fe_i = '0') then
            next_state <= RQ_NDA0;
         else
            next_state <= LD_ID3;
         end if; 

-------------------------------------------------------------
   -- number of data states
         
      when RQ_NDA0 =>
            next_state <= LD_NDA0;    
      when RQ_NDA1 =>
            next_state <= LD_NDA1;
      when RQ_NDA2 =>
            next_state <= LD_NDA2;
      when RQ_NDA3 =>
            next_state <= LD_NDA3;
           
      when LD_NDA0 =>
         if (rx_fe_i = '0') then
            next_state <= RQ_NDA1;
         else
            next_state <= LD_NDA0;
         end if;        
      when LD_NDA1 =>
         if (rx_fe_i = '0') then
            next_state <= RQ_NDA2;
         else
            next_state <= LD_NDA1;
         end if;
      when LD_NDA2 =>
         if (rx_fe_i = '0') then
            next_state <= RQ_NDA3;
         else
            next_state <= LD_NDA2;
         end if;
      when LD_NDA3 =>
         if (rx_fe_i = '0') then
            next_state <= RQ_BLK0;
         else
            next_state <= LD_NDA3;
         end if;


-----------------------------------------------
--- data word states

      when RQ_BLK0 =>
            next_state <= LD_BLK0;    
      when RQ_BLK1 =>
            next_state <= LD_BLK1;              
      when RQ_BLK2 =>
            next_state <= LD_BLK2;
      when RQ_BLK3 =>
            next_state <= LD_BLK3;


      when LD_BLK0 =>
         if (rx_fe_i = '0') then
            next_state <= RQ_BLK1;
         else
            next_state <= LD_BLK0;
         end if;
       
      when LD_BLK1 =>
         if (rx_fe_i = '0') then
            next_state <= RQ_BLK2;
         else
            next_state <= LD_BLK1;
         end if;
      when LD_BLK2 =>
         if (rx_fe_i = '0') then
            next_state <= RQ_BLK3;
         else
            next_state <= LD_BLK2;
         end if;
         
      when LD_BLK3  =>
         next_state <= WM_BLK;
     
      
      when WM_BLK =>
         if (rx_fe_i = '0') then
            if (write_pointer < block_size) then
              next_state <= RQ_BLK0;
            else 
               next_state <= RQ_CKSM0;
            end if;
         else      
            next_state <= WM_BLK;
         end if;        

    

------------------------------------------------
   -- checksum states

      when RQ_CKSM0 =>
            next_state <= LD_CKSM0; 
      when RQ_CKSM1 =>
            next_state <= LD_CKSM1;            
      when RQ_CKSM2 =>
            next_state <= LD_CKSM2;            
      when RQ_CKSM3 =>
            next_state <= LD_CKSM3;

      when LD_CKSM0 =>
         if (rx_fe_i = '0') then
            next_state <= RQ_CKSM1;
         else
            next_state <= LD_CKSM0;
         end if;
      when LD_CKSM1 =>
         if (rx_fe_i = '0') then
            next_state <= RQ_CKSM2;
         else
            next_state <= LD_CKSM1;
         end if;
      when LD_CKSM2 =>
         if (rx_fe_i = '0') then
            next_state <= RQ_CKSM3;
         else
            next_state <= LD_CKSM2;
         end if;
      when LD_CKSM3 =>
           next_state <= TEST_CKSM;
  
      when TEST_CKSM =>
         if (cmd_ack_i = '1') then
            next_state <= TEST_CKSM;
         elsif (cksum_calc = cksum_rcvd) then
            next_state <= CKSM_PASS;
         else
            next_state <= CKSM_FAIL;
         end if;
      
      when CKSM_PASS =>
         if (cmd_ack_i = '1') then
         
         -- if ((number_data = 0 ) or (cmd_code = ASCII_R & ASCII_B) ) then  
         -- replace following if statement with the above (commented out) if statement 
         -- and no dummy words will be clocked for the read_block command  
         
            if (number_data = 0 ) then  
               next_state <= IDLE;
            else
               next_state <= DATA_READ;
            end if; 
         
         else
            next_state <= CKSM_PASS;
         end if;
      
      when CKSM_FAIL =>
            next_state <= IDLE;

-----------------------------------------------
            
      when DATA_READ =>
            next_state <= DATA_SETL;
      when DATA_SETL =>
            next_state <= DATA_TX;
      when DATA_TX =>
         if (read_pointer < number_data) then   
            next_state <= DATA_READ;
         else   
            next_state <= IDLE;
         end if;               
                   
      when OTHERS =>
         next_state <= IDLE;
      end case;

   end process nextstate;

   ----------------------------------------------------------------------------
   output : process (
      current_state   --,
    --  rxd_i,
    --  data_out
   )
   ----------------------------------------------------------------------------
   begin
      -- Default Assignment
      cksum_err          <= '0';
      cmd_rdy            <= '0';
      rx_fr              <= '0';
      data_clk           <= '0';
     
      write_mem          <= '0'; 
      read_mem           <= '0';
      reset_mem          <= '0';
      check_update       <= '0';
      cksum_calc_mux_sel <= "00";
      check_reset        <= '0';
      
      cmd_mux_sel0       <= '0';
      cmd_mux_sel1       <= '0';
            
      id_mux_sel0        <= '0';
      id_mux_sel1        <= '0';
      id_mux_sel2        <= '0';
      id_mux_sel3        <= '0';
      
      nda_mux_sel0       <= '0';
      nda_mux_sel1       <= '0';
      nda_mux_sel2       <= '0';
      nda_mux_sel3       <= '0';
      
      ckin_mux_sel0      <= '0';
      ckin_mux_sel1      <= '0';
      ckin_mux_sel2      <= '0';
      ckin_mux_sel3      <= '0';
      
      ckrx_mux_sel0      <= '0';
      ckrx_mux_sel1      <= '0';
      ckrx_mux_sel2      <= '0';
      ckrx_mux_sel3      <= '0';
     
      data_in_mux_sel0   <= '0';
      data_in_mux_sel1   <= '0';
      data_in_mux_sel2   <= '0';
      data_in_mux_sel3   <= '0';   
      
      data_out_mux_sel   <= '0';   
      
  
      case current_state IS
         when IDLE =>
            reset_mem         <= '1';
            cksum_calc_mux_sel <= "11";
            check_reset       <= '1';  
            data_out_mux_sel  <= '1';     -- set to '1' so that output is reset to data_out is reset to (others => '0')
      


         when LD_CMD0 =>
            cmd_mux_sel0      <= '1';
            ckin_mux_sel0     <= '1';
         when LD_CMD1 =>
            cmd_mux_sel1      <= '1';
            ckin_mux_sel1     <= '1';              
         when LD_CMD2 =>
            ckin_mux_sel2     <= '1';
         when LD_CMD3 =>
            ckin_mux_sel3     <= '1';
            
         when LD_ID0 =>
            id_mux_sel0       <= '1';
            ckin_mux_sel0     <= '1';  
         when LD_ID1 =>
            id_mux_sel1       <= '1';
            ckin_mux_sel1     <= '1';   
         when LD_ID2 =>
            id_mux_sel2       <= '1'; 
            ckin_mux_sel2     <= '1';
         when LD_ID3 =>
            id_mux_sel3       <= '1';
            ckin_mux_sel3     <= '1';
            
         when LD_NDA0 =>
            nda_mux_sel0      <= '1'; 
            ckin_mux_sel0     <= '1';             
         when LD_NDA1 =>
            ckin_mux_sel1     <= '1';
         when LD_NDA2 =>
            ckin_mux_sel2     <= '1';
         when LD_NDA3 =>
            ckin_mux_sel3     <= '1';
            
         when LD_BLK0 =>
            ckin_mux_sel0     <= '1';
            data_in_mux_sel0  <= '1';
         when LD_BLK1 =>
            ckin_mux_sel1     <= '1';
            data_in_mux_sel1  <= '1';
         when LD_BLK2 =>
            ckin_mux_sel2     <= '1';
            data_in_mux_sel2  <= '1';
         when LD_BLK3 =>
            ckin_mux_sel3     <= '1';
            data_in_mux_sel3  <= '1';
       
            
         when LD_CKSM0 =>
            ckrx_mux_sel0     <= '1';
         when LD_CKSM1 =>
            ckrx_mux_sel1     <= '1';
         when LD_CKSM2 =>
            ckrx_mux_sel2     <= '1';
         when LD_CKSM3 =>
            ckrx_mux_sel3     <= '1';
            
            
            
         when RQ_PRE0 =>
            rx_fr             <= '1' ;
         when RQ_PRE1 =>
            rx_fr             <= '1' ;
         when RQ_PRE2 =>
            rx_fr             <= '1' ;
         when RQ_PRE3 =>
            rx_fr             <= '1' ;
         when RQ_PRE4 =>
            rx_fr             <= '1' ;
         when RQ_PRE5 =>
            rx_fr             <= '1' ;
         when RQ_PRE6 =>
            rx_fr             <= '1' ;
         when RQ_PRE7 =>
            rx_fr             <= '1' ;
 
 
         when RQ_CMD0 =>
            rx_fr             <= '1' ;
         when RQ_CMD1 =>
            rx_fr             <= '1' ;
         when RQ_CMD2 =>
            rx_fr             <= '1' ;
         when RQ_CMD3 =>
            rx_fr             <= '1' ;


         when RQ_ID0 =>
            rx_fr             <= '1' ;
            check_update      <= '1';  -- update checksum with command code word
            cksum_calc_mux_sel <= "01";
         when RQ_ID1 =>
            rx_fr             <= '1' ;
         when RQ_ID2 =>
            rx_fr             <= '1' ;
         when RQ_ID3 =>
            rx_fr             <= '1' ;


         when RQ_NDA0 =>
            rx_fr             <= '1' ;
            check_update      <= '1'; -- update checksum with id word
            cksum_calc_mux_sel <= "01";
         when RQ_NDA1 =>
            rx_fr             <= '1' ;
         when RQ_NDA2 =>
            rx_fr             <= '1' ;
         when RQ_NDA3 =>
            rx_fr             <= '1' ;

        
         when RQ_BLK0 =>
            rx_fr             <= '1' ;    
            check_update      <= '1';  -- update checksum with previous data word (or NDA word 1st time round) 
            cksum_calc_mux_sel <= "01";
         when RQ_BLK1 =>
            rx_fr             <= '1' ;
         when RQ_BLK2 =>
            rx_fr             <= '1' ;
         when RQ_BLK3 =>
            rx_fr             <= '1' ;
     
         when WM_BLK =>   
            write_mem         <= '1';         


         when RQ_CKSM0 =>
            rx_fr             <= '1';
            check_update      <= '1';   -- update checksum with last data word
            cksum_calc_mux_sel <= "01";
         when RQ_CKSM1 =>
            rx_fr             <= '1';
         when RQ_CKSM2 =>
            rx_fr             <= '1';
         when RQ_CKSM3 =>
            rx_fr             <= '1';        
 
 
         when CKSM_FAIL =>
            cksum_err         <= '1';
            
         when CKSM_PASS =>
            cmd_rdy           <= '1';

         when DATA_READ =>
            read_mem          <= '1'; 
            cmd_rdy           <= '1';
            data_out_mux_sel  <= '1';

         when DATA_SETL =>
             cmd_rdy          <= '1';
            
         when DATA_TX =>
            cmd_rdy           <= '1' ;
            data_clk          <= '1' ;

         when others =>
            null;
      
      end case;

   end process output;


   
  ------------------------------------------------------------------------------
  dff_cmd0: process(clk_i, rst_i)
  ----------------------------------------------------------------------------
  -- process to register cmd_code0 byte
  ----------------------------------------------------------------------------
  begin
     if (rst_i = '1') then 
        cmd_code(7 downto 0) <= (others => '0');
     elsif (clk_i'EVENT and clk_i = '1') then
        cmd_code(7 downto 0) <= cmd_code_mux(7 downto 0);
     end if;
  end process dff_cmd0;
  
   
  ------------------------------------------------------------------------------
  dff_cmd1: process(clk_i, rst_i)
  ----------------------------------------------------------------------------
  -- process to register cmd_code1 byte
  ----------------------------------------------------------------------------
  begin
     if (rst_i = '1') then 
        cmd_code(15 downto 8) <= (others => '0');
     elsif (clk_i'EVENT and clk_i = '1') then
        cmd_code(15 downto 8) <= cmd_code_mux(15 downto 8);
     end if;
  end process dff_cmd1;
  
      
  ------------------------------------------------------------------------------
  dff_id0: process(clk_i, rst_i)
  ----------------------------------------------------------------------------
  -- process to register id0 byte
  ----------------------------------------------------------------------------
  begin
     if (rst_i = '1') then 
        param_id(7 downto 0) <= (others => '0');
     elsif (clk_i'EVENT and clk_i = '1') then
        param_id(7 downto 0) <= param_id_mux(7 downto 0);
     end if;
  end process dff_id0;
  
  
  ------------------------------------------------------------------------------
  dff_id1: process(clk_i, rst_i)
  ----------------------------------------------------------------------------
  -- process to register id1 byte
  ----------------------------------------------------------------------------
  begin
     if (rst_i = '1') then 
        param_id(15 downto 8) <= (others => '0');
     elsif (clk_i'EVENT and clk_i = '1') then
        param_id(15 downto 8) <= param_id_mux(15 downto 8);
     end if;
  end process dff_id1;
  
  
  ------------------------------------------------------------------------------
  dff_id2: process(clk_i, rst_i)
  ----------------------------------------------------------------------------
  -- process to register id2 byte
  ----------------------------------------------------------------------------
  begin
     if (rst_i = '1') then 
        card_id(7 downto 0) <= (others => '0');
     elsif (clk_i'EVENT and clk_i = '1') then
        card_id(7 downto 0) <= card_id_mux(7 downto 0);
     end if;
  end process dff_id2;
  
  
  ------------------------------------------------------------------------------
  dff_id3: process(clk_i, rst_i)
  ----------------------------------------------------------------------------
  -- process to register id3 byte
  ----------------------------------------------------------------------------
  begin
     if (rst_i = '1') then 
        card_id(15 downto 8) <= (others => '0');
     elsif (clk_i'EVENT and clk_i = '1') then
        card_id(15 downto 8) <= card_id_mux(15 downto 8);
     end if;
  end process dff_id3;
   
  
  ------------------------------------------------------------------------------
  dff_nda0: process(clk_i, rst_i)
  ----------------------------------------------------------------------------
  -- process to register nda0 byte
  ----------------------------------------------------------------------------
  begin
     if (rst_i = '1') then 
        num_data(7 downto 0) <= (others => '0');
     elsif (clk_i'EVENT and clk_i = '1') then
        num_data(7 downto 0) <= num_data_mux(7 downto 0);
     end if;
  end process dff_nda0;
  
  ------------------------------------------------------------------------------
  dff_nda1: process(clk_i, rst_i)
  ----------------------------------------------------------------------------
  -- process to register nda0 byte
  ----------------------------------------------------------------------------
  begin
     if (rst_i = '1') then 
        num_data(15 downto 8) <= (others => '0');
     elsif (clk_i'EVENT and clk_i = '1') then
        num_data(15 downto 8) <= num_data_mux(15 downto 8);
     end if;
  end process dff_nda1;
  
  ------------------------------------------------------------------------------
  dff_nda2: process(clk_i, rst_i)
  ----------------------------------------------------------------------------
  -- process to register nda0 byte
  ----------------------------------------------------------------------------
  begin
     if (rst_i = '1') then 
        num_data(23 downto 16) <= (others => '0');
     elsif (clk_i'EVENT and clk_i = '1') then
        num_data(23 downto 16) <= num_data_mux(23 downto 16);
     end if;
  end process dff_nda2;
  
  
  ------------------------------------------------------------------------------
  dff_nda3: process(clk_i, rst_i)
  ----------------------------------------------------------------------------
  -- process to register nda0 byte
  ----------------------------------------------------------------------------
  begin
     if (rst_i = '1') then 
        num_data(31 downto 24) <= (others => '0');
     elsif (clk_i'EVENT and clk_i = '1') then
        num_data(31 downto 24) <= num_data_mux(31 downto 24);
     end if;
  end process dff_nda3;
  
  

  
  
  ------------------------------------------------------------------------------
  dff_ckin0: process(clk_i, rst_i)
  ----------------------------------------------------------------------------
  -- process to register cksum_in byte0
  ----------------------------------------------------------------------------
  begin
     if (rst_i = '1') then 
        cksum_in(7 downto 0) <= (others => '0');
     elsif (clk_i'EVENT and clk_i = '1') then
        cksum_in(7 downto 0) <= cksum_in_mux(7 downto 0);
     end if;
  end process dff_ckin0;
         
  ------------------------------------------------------------------------------
  dff_ckin1: process(clk_i, rst_i)
  ----------------------------------------------------------------------------
  -- process to register cksum_in byte1
  ----------------------------------------------------------------------------
  begin
     if (rst_i = '1') then 
        cksum_in(15 downto 8) <= (others => '0');
     elsif (clk_i'EVENT and clk_i = '1') then
        cksum_in(15 downto 8) <= cksum_in_mux(15 downto 8);
     end if;
  end process dff_ckin1;
                
        
  ------------------------------------------------------------------------------
  dff_ckin2: process(clk_i, rst_i)
  ----------------------------------------------------------------------------
  -- process to register cksum_in byte2
  ----------------------------------------------------------------------------
  begin
     if (rst_i = '1') then 
        cksum_in(23 downto 16) <= (others => '0');
     elsif (clk_i'EVENT and clk_i = '1') then
        cksum_in(23 downto 16) <= cksum_in_mux(23 downto 16);
     end if;
  end process dff_ckin2;
 
 
   ------------------------------------------------------------------------------
  dff_ckin3: process(clk_i, rst_i)
  ----------------------------------------------------------------------------
  -- process to register cksum_in byte3
  ----------------------------------------------------------------------------
  begin
     if (rst_i = '1') then 
        cksum_in(31 downto 24) <= (others => '0');
     elsif (clk_i'EVENT and clk_i = '1') then
        cksum_in(31 downto 24) <= cksum_in_mux(31 downto 24);
     end if;
  end process dff_ckin3;
 
 
  ------------------------------------------------------------------------------
  dff_ckrx0: process(clk_i, rst_i)
  ----------------------------------------------------------------------------
  -- process to register cksum_rcvd byte0
  ----------------------------------------------------------------------------
  begin
     if (rst_i = '1') then 
        cksum_rcvd(7 downto 0) <= (others => '0');
     elsif (clk_i'EVENT and clk_i = '1') then
        cksum_rcvd(7 downto 0) <= cksum_rcvd_mux(7 downto 0);
     end if;
  end process dff_ckrx0;
         
  ------------------------------------------------------------------------------
  dff_ckrx1: process(clk_i, rst_i)
  ----------------------------------------------------------------------------
  -- process to register cksum_rcvd byte1
  ----------------------------------------------------------------------------
  begin
     if (rst_i = '1') then 
        cksum_rcvd(15 downto 8) <= (others => '0');
     elsif (clk_i'EVENT and clk_i = '1') then
        cksum_rcvd(15 downto 8) <= cksum_rcvd_mux(15 downto 8);
     end if;
  end process dff_ckrx1;
                
        
  ------------------------------------------------------------------------------
  dff_ckrx2: process(clk_i, rst_i)
  ----------------------------------------------------------------------------
  -- process to register cksum_rcvd byte2
  ----------------------------------------------------------------------------
  begin
     if (rst_i = '1') then 
        cksum_rcvd(23 downto 16) <= (others => '0');
     elsif (clk_i'EVENT and clk_i = '1') then
        cksum_rcvd(23 downto 16) <= cksum_rcvd_mux(23 downto 16);
     end if;
  end process dff_ckrx2;
 
 
   ------------------------------------------------------------------------------
  dff_ckrx3: process(clk_i, rst_i)
  ----------------------------------------------------------------------------
  -- process to register cksum_rcvd byte3
  ----------------------------------------------------------------------------
  begin
     if (rst_i = '1') then 
        cksum_rcvd(31 downto 24) <= (others => '0');
     elsif (clk_i'EVENT and clk_i = '1') then
        cksum_rcvd(31 downto 24) <= cksum_rcvd_mux(31 downto 24);
     end if;
  end process dff_ckrx3;


  ------------------------------------------------------------------------------
  dff_data0: process(clk_i, rst_i)
  ----------------------------------------------------------------------------
  -- process to register data byte0
  ----------------------------------------------------------------------------
  begin
     if (rst_i = '1') then 
        data_in (7 downto 0) <= (others => '0');
     elsif (clk_i'EVENT and clk_i = '1') then
        data_in (7 downto 0) <= data_in_mux(7 downto 0);
     end if;
  end process dff_data0;


  ------------------------------------------------------------------------------
  dff_data1: process(clk_i, rst_i)
  ----------------------------------------------------------------------------
  -- process to register data byte1
  ----------------------------------------------------------------------------
  begin
     if (rst_i = '1') then 
        data_in (15 downto 8) <= (others => '0');
     elsif (clk_i'EVENT and clk_i = '1') then
        data_in (15 downto 8) <= data_in_mux(15 downto 8);
     end if;
  end process dff_data1;

  ------------------------------------------------------------------------------
  dff_data2: process(clk_i, rst_i)
  ----------------------------------------------------------------------------
  -- process to register data byte2
  ----------------------------------------------------------------------------
  begin
     if (rst_i = '1') then 
        data_in (23 downto 16) <= (others => '0');
     elsif (clk_i'EVENT and clk_i = '1') then
        data_in (23 downto 16) <= data_in_mux(23 downto 16);
     end if;
  end process dff_data2;


  ------------------------------------------------------------------------------
  dff_data3: process(clk_i, rst_i)
  ----------------------------------------------------------------------------
  -- process to register data byte1
  ----------------------------------------------------------------------------
  begin
     if (rst_i = '1') then 
        data_in (31 downto 24) <= (others => '0');
     elsif (clk_i'EVENT and clk_i = '1') then
        data_in (31 downto 24) <= data_in_mux(31 downto 24);
     end if;
  end process dff_data3;



  ------------------------------------------------------------------------------
  dff_cmd_data: process(clk_i, rst_i)
  ----------------------------------------------------------------------------
  -- process to register cmd data word
  ----------------------------------------------------------------------------
  begin
     if (rst_i = '1') then 
        cmd_data (31 downto 0) <= (others => '0');
     elsif (clk_i'EVENT and clk_i = '1') then
        cmd_data (31 downto 0) <= cmd_data_mux(31 downto 0);
     end if;
  end process dff_cmd_data;


--  ------------------------------------------------------------------------------
--  checksum_calculator: process(check_reset, check_update)
--  ----------------------------------------------------------------------------
--  -- process to update calculated checksum
--  ----------------------------------------------------------------------------
--  
--  begin
--     
--    if (check_reset = '1') then
--       cksum_calc2 <= (others => '0');
--    elsif (check_update'EVENT AND check_update = '1') then
--       cksum_calc2 <= cksum_calc2 XOR cksum_in;
--    end if;
--     
--  end process checksum_calculator;   
--  
  
  
  
  
  ------------------------------------------------------------------------------
  checksum_calculator2: process(rst_i, clk_i)
  ----------------------------------------------------------------------------
  -- process to update calculated checksum
  ----------------------------------------------------------------------------
  
  begin
     
    if (rst_i = '1') then
       cksum_calc_reg <= (others => '0');
    elsif (clk_i'EVENT AND clk_i = '1') then
       cksum_calc_reg <= cksum_calc; --cksum_calc XOR cksum_in;
    end if;
     
  end process checksum_calculator2;   
  
  -- mux
  cksum_calc     <= cksum_calc_reg               when cksum_calc_mux_sel = "00" else 
                    cksum_calc_reg XOR cksum_in  when cksum_calc_mux_sel = "01" else
                    (others=>'0');
   
  ------------------------------------------------------------------------------
  write_memory: process(reset_mem, write_mem)
  ----------------------------------------------------------------------------
  -- process to write data word into local memory
  ----------------------------------------------------------------------------

 begin
     if (reset_mem = '1') then
        write_pointer <= 0;
        
        for reset_index in 0 to mem_size-1 loop
           memory(reset_index) <= (others => '0');
        end loop;
        
     elsif (write_mem'EVENT AND write_mem = '1') then
        memory(write_pointer) <= data_in; 
        write_pointer <= write_pointer + 1;
     end if; 

  end process write_memory;
  
 ------------------------------------------------------------------------------
  read_memory: process(reset_mem, read_mem)
  ----------------------------------------------------------------------------
  -- process to read data word from local memory
  ----------------------------------------------------------------------------

 begin
     if (reset_mem = '1') then
        read_pointer <= 0;
        data_out <= (others => '0');
     elsif (read_mem'EVENT AND read_mem = '1') then
        data_out <= memory(read_pointer); 
        read_pointer <= read_pointer + 1;
     end if; 

  end process read_memory;  
  
    
  
end rtl;
