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
-- <revision control keyword substitutions e.g. $Id: fibre_rx_protocol.vhd,v 1.4 2004/07/07 10:48:19 dca Exp $>
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
-- line (cmd_rdy_o) is asserted. 
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
-- <date $Date: 2004/07/07 10:48:19 $>	-		<text>		- <initials $Author: dca $>
-- <$log$>
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.issue_reply_pack.all;
use work.fibre_rx_pack.all;

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

constant IDLE        : std_logic_vector(5 downto 0) := "000000";

constant RQ_PRE0     : std_logic_vector(5 downto 0) := "000001";
constant CK_PRE0     : std_logic_vector(5 downto 0) := "000010";
constant RQ_PRE1     : std_logic_vector(5 downto 0) := "000011";
constant CK_PRE1     : std_logic_vector(5 downto 0) := "000100";
constant RQ_PRE2     : std_logic_vector(5 downto 0) := "000101";
constant CK_PRE2     : std_logic_vector(5 downto 0) := "000110";
constant RQ_PRE3     : std_logic_vector(5 downto 0) := "000111";
constant CK_PRE3     : std_logic_vector(5 downto 0) := "001000";

constant RQ_PRE4     : std_logic_vector(5 downto 0) := "001001";
constant CK_PRE4     : std_logic_vector(5 downto 0) := "001010";
constant RQ_PRE5     : std_logic_vector(5 downto 0) := "001011";
constant CK_PRE5     : std_logic_vector(5 downto 0) := "001100";
constant RQ_PRE6     : std_logic_vector(5 downto 0) := "001101";
constant CK_PRE6     : std_logic_vector(5 downto 0) := "001110";
constant RQ_PRE7     : std_logic_vector(5 downto 0) := "001111";
constant CK_PRE7     : std_logic_vector(5 downto 0) := "010000";

constant RQ_CMD0     : std_logic_vector(5 downto 0) := "010001";
constant LD_CMD0     : std_logic_vector(5 downto 0) := "010010";
constant RQ_CMD1     : std_logic_vector(5 downto 0) := "010011";
constant LD_CMD1     : std_logic_vector(5 downto 0) := "010100";
constant RQ_CMD2     : std_logic_vector(5 downto 0) := "010101";
constant LD_CMD2     : std_logic_vector(5 downto 0) := "010110";
constant RQ_CMD3     : std_logic_vector(5 downto 0) := "010111";
constant LD_CMD3     : std_logic_vector(5 downto 0) := "011000";

constant RQ_ID0      : std_logic_vector(5 downto 0) := "011001";
constant LD_ID0      : std_logic_vector(5 downto 0) := "011010";
constant RQ_ID1      : std_logic_vector(5 downto 0) := "011011";
constant LD_ID1      : std_logic_vector(5 downto 0) := "011100";
constant RQ_ID2      : std_logic_vector(5 downto 0) := "011101";
constant LD_ID2      : std_logic_vector(5 downto 0) := "011110";
constant RQ_ID3      : std_logic_vector(5 downto 0) := "011111";
constant LD_ID3      : std_logic_vector(5 downto 0) := "100000";

constant RQ_CKSM0    : std_logic_vector(5 downto 0) := "100001";
constant LD_CKSM0    : std_logic_vector(5 downto 0) := "100010";
constant RQ_CKSM1    : std_logic_vector(5 downto 0) := "100011";
constant LD_CKSM1    : std_logic_vector(5 downto 0) := "100100";
constant RQ_CKSM2    : std_logic_vector(5 downto 0) := "100101";
constant LD_CKSM2    : std_logic_vector(5 downto 0) := "100110";
constant RQ_CKSM3    : std_logic_vector(5 downto 0) := "100111";
constant LD_CKSM3    : std_logic_vector(5 downto 0) := "101000";

constant RQ_NDA0     : std_logic_vector(5 downto 0) := "101001";
constant LD_NDA0     : std_logic_vector(5 downto 0) := "101010";
constant RQ_NDA1     : std_logic_vector(5 downto 0) := "101011";
constant LD_NDA1     : std_logic_vector(5 downto 0) := "101100";
constant RQ_NDA2     : std_logic_vector(5 downto 0) := "101101";
constant LD_NDA2     : std_logic_vector(5 downto 0) := "101110";
constant RQ_NDA3     : std_logic_vector(5 downto 0) := "101111";
constant LD_NDA3     : std_logic_vector(5 downto 0) := "110000";

constant RQ_BLK0     : std_logic_vector(5 downto 0) := "110001";
constant LD_BLK0     : std_logic_vector(5 downto 0) := "110010";
constant RQ_BLK1     : std_logic_vector(5 downto 0) := "110011";
constant LD_BLK1     : std_logic_vector(5 downto 0) := "110100";
constant RQ_BLK2     : std_logic_vector(5 downto 0) := "110101";
constant LD_BLK2     : std_logic_vector(5 downto 0) := "110110";
constant RQ_BLK3     : std_logic_vector(5 downto 0) := "110111";
constant LD_BLK3     : std_logic_vector(5 downto 0) := "111000";

constant TEST_CKSM   : std_logic_vector(5 downto 0) := "111001";
constant CKSM_FAIL   : std_logic_vector(5 downto 0) := "111010";
constant CKSM_PASS   : std_logic_vector(5 downto 0) := "111011";
constant READ_DATA   : std_logic_vector(5 downto 0) := "111100";
constant TX_DATA     : std_logic_vector(5 downto 0) := "111101";
constant WM_BLK      : std_logic_vector(5 downto 0) := "111110";



-- controller state variables:
signal current_state  : std_logic_vector(5 downto 0);
signal next_state     : std_logic_vector(5 downto 0);


-- Architecture Declarations
constant preamble1 : std_logic_vector(7 downto 0) := X"A5";
constant preamble2 : std_logic_vector(7 downto 0) := X"5A";

signal cksum_calc : std_logic_vector(31 downto 0);
signal cksum_in : std_logic_vector(31 downto 0);
signal cksum_rcvd : std_logic_vector(31 downto 0);
signal check_update : std_logic;
signal check_reset : std_logic;


constant mem_size: positive := 64;
subtype mem_deep is integer range 0 to mem_size-1;
signal write_pointer: mem_deep;
signal read_pointer: mem_deep;


constant block_size: mem_deep := 58;  -- total number of data words in a write_block

signal number_data   : positive;  -- this will be a value between 1 and 58
signal data_in       : std_logic_vector(31 downto 0); -- current data word written to memory 
signal data_out      : std_logic_vector(31 downto 0); -- current data word read from memory
signal write_mem     : std_logic;                     -- write current data word to memory
signal read_mem      : std_logic;                     -- read current data word from memory
signal reset_mem     : std_logic; 



-- clocks to latch command code bytes
signal cmd_clk0      : std_logic;
signal cmd_clk1      : std_logic;

-- clocks to latch id bytes
signal id_clk0       : std_logic;
signal id_clk1       : std_logic;
signal id_clk2       : std_logic;
signal id_clk3       : std_logic;

-- clock to latch number of data byte
signal nda_clk0      : std_logic;

-- clocks to latch current 32bit command word to checksum calculator
signal ckin_clk0     : std_logic;
signal ckin_clk1     : std_logic;
signal ckin_clk2     : std_logic;
signal ckin_clk3     : std_logic;

-- clocks to latch received checksum bytes
signal ckrx_clk0     : std_logic;
signal ckrx_clk1     : std_logic;
signal ckrx_clk2     : std_logic;
signal ckrx_clk3     : std_logic;

-- clocks to latch command data word to local memory buffer
signal data_clk0     : std_logic;
signal data_clk1     : std_logic;
signal data_clk2     : std_logic;
signal data_clk3     : std_logic;


-- local memory buffer declaration
subtype word is std_logic_vector(31 downto 0);
type mem is array (0 to mem_size-1) of word;
signal memory: mem;


begin

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
      number_data
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
            next_state <= READ_DATA;
         else
            next_state <= CKSM_PASS;
         end if;
      
-----------------------------------------------      
 -- EVEN IF CKSM_FAIL then goto checksum pass
 -- state and clock out data.....
      
      when CKSM_FAIL =>
 --           next_state <= IDLE;
            next_state <= CKSM_PASS;
            
            

-----------------------------------------------
            
      when READ_DATA =>
            next_state <= TX_DATA;
      when TX_DATA =>
         if (read_pointer < number_data) then   
            next_state <= READ_DATA;
         else   
            next_state <= IDLE;
         end if;               
                   
      when OTHERS =>
         next_state <= IDLE;
      end case;

   end process nextstate;

   ----------------------------------------------------------------------------
   output : process (
      current_state,
    --  rxd_i,
      data_out
   )
   ----------------------------------------------------------------------------
   begin
      -- Default Assignment
      cksum_err_o <= '0';
      cmd_rdy_o <= '0';
      rx_fr_o <= '0';
      data_clk_o <= '0';
     
      write_mem <= '0'; 
      read_mem <= '0';
      reset_mem <= '0';
      check_update <= '0';
      check_reset <= '0';
      
      cmd_clk0  <= '0';
      cmd_clk1  <= '0';
            
      id_clk0   <= '0';
      id_clk1   <= '0';
      id_clk2   <= '0';
      id_clk3   <= '0';
      
      nda_clk0  <= '0';
      
      ckin_clk0 <= '0';
      ckin_clk1 <= '0';
      ckin_clk2 <= '0';
      ckin_clk3 <= '0';
      
      ckrx_clk0 <= '0';
      ckrx_clk1 <= '0';
      ckrx_clk2 <= '0';
      ckrx_clk3 <= '0';
     
      data_clk0 <= '0';
      data_clk1 <= '0';
      data_clk2 <= '0';
      data_clk3 <= '0';     
      
  
      case current_state IS
         when IDLE =>
            reset_mem <= '1';
            check_reset <= '1';  
            cmd_data_o <= (others => '0');

         when LD_CMD0 =>
            cmd_clk0 <= '1';
            ckin_clk0 <= '1';
         when LD_CMD1 =>
            cmd_clk1 <= '1';
            ckin_clk1 <= '1';              
         when LD_CMD2 =>
            ckin_clk2 <= '1';
         when LD_CMD3 =>
            ckin_clk3 <= '1';
            
         when LD_ID0 =>
            id_clk0   <= '1';
            ckin_clk0 <= '1';  
         when LD_ID1 =>
            id_clk1   <= '1';
            ckin_clk1 <= '1';   
         when LD_ID2 =>
            id_clk2   <= '1'; 
            ckin_clk2 <= '1';
         when LD_ID3 =>
            id_clk3   <= '1';
            ckin_clk3 <= '1';
            
         when LD_NDA0 =>
            nda_clk0 <= '1'; 
            ckin_clk0 <= '1';             
         when LD_NDA1 =>
            ckin_clk1 <= '1';
         when LD_NDA2 =>
            ckin_clk2 <= '1';
         when LD_NDA3 =>
            ckin_clk3 <= '1';
            
         when LD_BLK0 =>
            ckin_clk0 <= '1';
            data_clk0 <= '1';
         when LD_BLK1 =>
            ckin_clk1 <= '1';
            data_clk1 <= '1';
         when LD_BLK2 =>
            ckin_clk2 <= '1';
            data_clk2 <= '1';
         when LD_BLK3 =>
            ckin_clk3 <= '1';
            data_clk3 <= '1';
       
            
         when LD_CKSM0 =>
            ckrx_clk0 <= '1';
         when LD_CKSM1 =>
            ckrx_clk1 <= '1';
         when LD_CKSM2 =>
            ckrx_clk2 <= '1';
         when LD_CKSM3 =>
            ckrx_clk3 <= '1';
            
            
            
         when RQ_PRE0 =>
            rx_fr_o <= '1' ;
         when RQ_PRE1 =>
            rx_fr_o <= '1' ;
         when RQ_PRE2 =>
            rx_fr_o <= '1' ;
         when RQ_PRE3 =>
            rx_fr_o <= '1' ;
         when RQ_PRE4 =>
            rx_fr_o <= '1' ;
         when RQ_PRE5 =>
            rx_fr_o <= '1' ;
         when RQ_PRE6 =>
            rx_fr_o <= '1' ;
         when RQ_PRE7 =>
            rx_fr_o <= '1' ;
 
 
         when RQ_CMD0 =>
            rx_fr_o <= '1' ;
         when RQ_CMD1 =>
            rx_fr_o <= '1' ;
         when RQ_CMD2 =>
            rx_fr_o <= '1' ;
         when RQ_CMD3 =>
            rx_fr_o <= '1' ;


         when RQ_ID0 =>
            rx_fr_o <= '1' ;
            check_update <= '1';  -- update checksum with command code word
         when RQ_ID1 =>
            rx_fr_o <= '1' ;
         when RQ_ID2 =>
            rx_fr_o <= '1' ;
         when RQ_ID3 =>
            rx_fr_o <= '1' ;


         when RQ_NDA0 =>
            rx_fr_o <= '1' ;
            check_update <= '1'; -- update checksum with id word
         when RQ_NDA1 =>
            rx_fr_o <= '1' ;
         when RQ_NDA2 =>
            rx_fr_o <= '1' ;
         when RQ_NDA3 =>
            rx_fr_o <= '1' ;

        
         when RQ_BLK0 =>
            rx_fr_o <= '1' ;    
            check_update <= '1';  -- update checksum with previous data word (or NDA word 1st time round) 
         when RQ_BLK1 =>
            rx_fr_o <= '1' ;
         when RQ_BLK2 =>
            rx_fr_o <= '1' ;
         when RQ_BLK3 =>
            rx_fr_o <= '1' ;
     
         when WM_BLK =>   
            write_mem <= '1';         


         when RQ_CKSM0 =>
            rx_fr_o <= '1' ;
            check_update <= '1';   -- update checksum with last data word
         when RQ_CKSM1 =>
            rx_fr_o <= '1' ;
         when RQ_CKSM2 =>
            rx_fr_o <= '1' ;
         when RQ_CKSM3 =>
            rx_fr_o <= '1' ;        
 
 
         when CKSM_FAIL =>
            cksum_err_o <= '1' ;
            
         when CKSM_PASS =>
            cmd_rdy_o <= '1';

         when READ_DATA =>
            read_mem <= '1'; 
            cmd_rdy_o <= '1' ;
            data_clk_o <= '0' ;
         when TX_DATA =>
            cmd_data_o <= data_out ;
            cmd_rdy_o <= '1' ;
            data_clk_o <= '1' ;

         when others =>
            null;
      
      end case;

   end process output;
   

  ------------------------------------------------------------------------------
  latch_cmd0: process(cmd_clk0, rst_i)
  ----------------------------------------------------------------------------
  -- process to output cmd_code0 byte
  ----------------------------------------------------------------------------
  begin
     if (rst_i = '1') then 
        cmd_code_o(7 downto 0) <= (others => '0');
     elsif (cmd_clk0'EVENT and cmd_clk0 = '1') then
        cmd_code_o(7 downto 0) <= rxd_i(7 downto 0);
     end if;
  end process latch_cmd0;
  
  
  ------------------------------------------------------------------------------
  latch_cmd1: process(cmd_clk1, rst_i)
  ----------------------------------------------------------------------------
  -- process to latch cmd_code1 byte
  ----------------------------------------------------------------------------
  begin
     if (rst_i = '1') then 
        cmd_code_o(15 downto 8) <= (others => '0');
     elsif (cmd_clk1'EVENT and cmd_clk1 = '1') then
        cmd_code_o(15 downto 8) <= rxd_i(7 downto 0);
     end if;
  end process latch_cmd1;
  
  
     
  
  ------------------------------------------------------------------------------
  latch_id0: process(id_clk0, rst_i)
  ----------------------------------------------------------------------------
  -- process to latch id0 byte
  ----------------------------------------------------------------------------
  begin
     if (rst_i = '1') then 
        param_id_o(7 downto 0) <= (others => '0');
     elsif (id_clk0'EVENT and id_clk0 = '1') then
        param_id_o(7 downto 0) <= rxd_i(7 downto 0);
     end if;
  end process latch_id0;
  
  
  ------------------------------------------------------------------------------
  latch_id1: process(id_clk1, rst_i)
  ----------------------------------------------------------------------------
  -- process to latch id1 byte
  ----------------------------------------------------------------------------
  begin
     if (rst_i = '1') then 
        param_id_o(15 downto 8) <= (others => '0');
     elsif (id_clk1'EVENT and id_clk1 = '1') then
        param_id_o(15 downto 8) <= rxd_i(7 downto 0);
     end if;
  end process latch_id1;
  
  
  ------------------------------------------------------------------------------
  latch_id2: process(id_clk2, rst_i)
  ----------------------------------------------------------------------------
  -- process to latch id2 byte
  ----------------------------------------------------------------------------
  begin
     if (rst_i = '1') then 
        card_id_o(7 downto 0) <= (others => '0');
     elsif (id_clk2'EVENT and id_clk2 = '1') then
        card_id_o(7 downto 0) <= rxd_i(7 downto 0);
     end if;
  end process latch_id2;
  
  
  ------------------------------------------------------------------------------
  latch_id3: process(id_clk3, rst_i)
  ----------------------------------------------------------------------------
  -- process to latch id3 byte
  ----------------------------------------------------------------------------
  begin
     if (rst_i = '1') then 
        card_id_o(15 downto 8) <= (others => '0');
     elsif (id_clk3'EVENT and id_clk3 = '1') then
        card_id_o(15 downto 8) <= rxd_i(7 downto 0);
     end if;
  end process latch_id3;
   
  
  ------------------------------------------------------------------------------
  latch_nda0: process(nda_clk0, rst_i)
  ----------------------------------------------------------------------------
  -- process to latch nda0 byte
  ----------------------------------------------------------------------------
  begin
     if (rst_i = '1') then 
        num_data_o <= (others => '0');
        number_data <= 1;
     elsif (nda_clk0'EVENT and nda_clk0 = '1') then
        num_data_o(7 downto 0) <= rxd_i(7 downto 0);
        num_data_o(DATA_SIZE_BUS_WIDTH-1 downto 8) <= (others => '0');
        number_data <= To_integer(Unsigned(rxd_i(7 downto 0)));
     end if;
  end process latch_nda0;
  
        
  
  ------------------------------------------------------------------------------
  latch_ckin0: process(ckin_clk0, rst_i)
  ----------------------------------------------------------------------------
  -- process to latch cksum_in byte0
  ----------------------------------------------------------------------------
  begin
     if (rst_i = '1') then 
        cksum_in(7 downto 0) <= (others => '0');
     elsif (ckin_clk0'EVENT and ckin_clk0 = '1') then
        cksum_in(7 downto 0) <= rxd_i(7 downto 0);
     end if;
  end process latch_ckin0;
         
  ------------------------------------------------------------------------------
  latch_ckin1: process(ckin_clk1, rst_i)
  ----------------------------------------------------------------------------
  -- process to latch cksum_in byte1
  ----------------------------------------------------------------------------
  begin
     if (rst_i = '1') then 
        cksum_in(15 downto 8) <= (others => '0');
     elsif (ckin_clk1'EVENT and ckin_clk1 = '1') then
        cksum_in(15 downto 8) <= rxd_i(7 downto 0);
     end if;
  end process latch_ckin1;
                
        
  ------------------------------------------------------------------------------
  latch_ckin2: process(ckin_clk2, rst_i)
  ----------------------------------------------------------------------------
  -- process to latch cksum_in byte2
  ----------------------------------------------------------------------------
  begin
     if (rst_i = '1') then 
        cksum_in(23 downto 16) <= (others => '0');
     elsif (ckin_clk2'EVENT and ckin_clk2 = '1') then
        cksum_in(23 downto 16) <= rxd_i(7 downto 0);
     end if;
  end process latch_ckin2;
 
 
   ------------------------------------------------------------------------------
  latch_ckin3: process(ckin_clk3, rst_i)
  ----------------------------------------------------------------------------
  -- process to latch cksum_in byte3
  ----------------------------------------------------------------------------
  begin
     if (rst_i = '1') then 
        cksum_in(31 downto 24) <= (others => '0');
     elsif (ckin_clk3'EVENT and ckin_clk3 = '1') then
        cksum_in(31 downto 24) <= rxd_i(7 downto 0);
     end if;
  end process latch_ckin3;
 
 
  ------------------------------------------------------------------------------
  latch_ckrx0: process(ckrx_clk0, rst_i)
  ----------------------------------------------------------------------------
  -- process to latch cksum_rcvd byte0
  ----------------------------------------------------------------------------
  begin
     if (rst_i = '1') then 
        cksum_rcvd(7 downto 0) <= (others => '0');
     elsif (ckrx_clk0'EVENT and ckrx_clk0 = '1') then
        cksum_rcvd(7 downto 0) <= rxd_i(7 downto 0);
     end if;
  end process latch_ckrx0;
         
  ------------------------------------------------------------------------------
  latch_ckrx1: process(ckrx_clk1, rst_i)
  ----------------------------------------------------------------------------
  -- process to latch cksum_rcvd byte1
  ----------------------------------------------------------------------------
  begin
     if (rst_i = '1') then 
        cksum_rcvd(15 downto 8) <= (others => '0');
     elsif (ckrx_clk1'EVENT and ckrx_clk1 = '1') then
        cksum_rcvd(15 downto 8) <= rxd_i(7 downto 0);
     end if;
  end process latch_ckrx1;
                
        
  ------------------------------------------------------------------------------
  latch_ckrx2: process(ckrx_clk2, rst_i)
  ----------------------------------------------------------------------------
  -- process to latch cksum_rcvd byte2
  ----------------------------------------------------------------------------
  begin
     if (rst_i = '1') then 
        cksum_rcvd(23 downto 16) <= (others => '0');
     elsif (ckrx_clk2'EVENT and ckrx_clk2 = '1') then
        cksum_rcvd(23 downto 16) <= rxd_i(7 downto 0);
     end if;
  end process latch_ckrx2;
 
 
   ------------------------------------------------------------------------------
  latch_ckrx3: process(ckrx_clk3, rst_i)
  ----------------------------------------------------------------------------
  -- process to latch cksum_rcvd byte3
  ----------------------------------------------------------------------------
  begin
     if (rst_i = '1') then 
        cksum_rcvd(31 downto 24) <= (others => '0');
     elsif (ckrx_clk3'EVENT and ckrx_clk3 = '1') then
        cksum_rcvd(31 downto 24) <= rxd_i(7 downto 0);
     end if;
  end process latch_ckrx3;


  ------------------------------------------------------------------------------
  latch_data0: process(data_clk0, rst_i)
  ----------------------------------------------------------------------------
  -- process to latch data byte0
  ----------------------------------------------------------------------------
  begin
     if (rst_i = '1') then 
        data_in (7 downto 0) <= (others => '0');
     elsif (data_clk0'EVENT and data_clk0 = '1') then
        data_in (7 downto 0) <= rxd_i(7 downto 0);
     end if;
  end process latch_data0;


  ------------------------------------------------------------------------------
  latch_data1: process(data_clk1, rst_i)
  ----------------------------------------------------------------------------
  -- process to latch data byte1
  ----------------------------------------------------------------------------
  begin
     if (rst_i = '1') then 
        data_in (15 downto 8) <= (others => '0');
     elsif (data_clk1'EVENT and data_clk1 = '1') then
        data_in (15 downto 8) <= rxd_i(7 downto 0);
     end if;
  end process latch_data1;

  ------------------------------------------------------------------------------
  latch_data2: process(data_clk2, rst_i)
  ----------------------------------------------------------------------------
  -- process to latch data byte2
  ----------------------------------------------------------------------------
  begin
     if (rst_i = '1') then 
        data_in (23 downto 16) <= (others => '0');
     elsif (data_clk2'EVENT and data_clk2 = '1') then
        data_in (23 downto 16) <= rxd_i(7 downto 0);
     end if;
  end process latch_data2;


  ------------------------------------------------------------------------------
  latch_data3: process(data_clk3, rst_i)
  ----------------------------------------------------------------------------
  -- process to latch data byte1
  ----------------------------------------------------------------------------
  begin
     if (rst_i = '1') then 
        data_in (31 downto 24) <= (others => '0');
     elsif (data_clk3'EVENT and data_clk3 = '1') then
        data_in (31 downto 24) <= rxd_i(7 downto 0);
     end if;
  end process latch_data3;


  ------------------------------------------------------------------------------
  checksum_calculator: process(check_update, check_reset
  --, cksum_in
  )
  ----------------------------------------------------------------------------
  -- process to update calculated checksum
  ----------------------------------------------------------------------------
  
  begin
     
    if (check_reset = '1') then
       cksum_calc <= (others => '0');
    elsif (check_update'EVENT AND check_update = '1') then
       cksum_calc <= cksum_calc XOR cksum_in;
    end if;
     
  end process checksum_calculator;   
   
  ------------------------------------------------------------------------------
  write_memory: process(reset_mem, write_mem)
  ----------------------------------------------------------------------------
  -- process to write data word into local memory
  ----------------------------------------------------------------------------

 begin
     if (reset_mem = '1') then
        write_pointer <= 0;
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
