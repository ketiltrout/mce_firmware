-- Copyright (c) 2003 SCUBA-2 Project
-- All Rights Reserved
-- THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE SCUBA-2 Project
-- The copyright notice above does not evidence any
-- actual or intended publication of such source code.
-- SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
-- REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
-- MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
-- PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
-- THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.
-- For the purposes of this code the SCUBA-2 Project consists of the
-- following organisations.
-- UKATC, Royal Observatory, Blackford Hill Edinburgh EH9 3HJ
-- UBC, University of British Columbia, Physics & Astronomy Department,
-- Vancouver BC, V6T 1Z1
--
--
-- <revision control keyword substitutions e.g. $Id: fibre_rx.vhd,v 1.5.2.2 2006/10/19 22:05:55 bburger Exp $>
--
-- Project: Scuba 2
-- Author: David Atkinson
-- Organisation: UK ATC
--
-- Title
-- fibre_rx
--
-- Description:
-- Fibre Optic front end receive firmware:
-- Instantiates:
--
-- 1. fibre_rx_control
-- 2. fibre_rx_fifo
-- 3. fibre_rx_protocol
--
-- Revision history:
-- <date $Date: 2006/10/19 22:05:55 $> - <text> - <initials $Author: bburger $>
-- $Log: fibre_rx.vhd,v $
-- Revision 1.5.2.2  2006/10/19 22:05:55  bburger
-- Bryce:  Corrected a signal naming error card_id -> card_addr
--
-- Revision 1.5.2.1  2006/01/16 18:56:11  bburger
-- Ernie:
-- replacedFIBRE_CMD_CODE_WIDTH with FIBRE_PACKET_TYPE_WIDTH
-- Added component declarations
--
-- Revision 1.5  2004/11/24 01:15:52  bench2
-- Greg: Broke apart issue reply and created pack files for all of its sub-components
--
-- Revision 1.4  2004/10/11 13:32:15  dca
-- Changes due to fibre_rx_fifo becoming a synchronous FIFO megafunction.
--
-- Revision 1.3  2004/10/08 14:07:32  dca
-- updated due to parameter name changes in command_pack
--


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

entity fibre_rx is
port(
      clk_i          : in std_logic;
      rst_i          : in std_logic;

      cmd_err_o      : out std_logic;
      cmd_rdy_o      : out std_logic;
      cmd_ack_i      : in std_logic;

      cmd_code_o     : out std_logic_vector(FIBRE_PACKET_TYPE_WIDTH-1 downto 0);
      card_addr_o    : out std_logic_vector(FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);
      param_id_o     : out std_logic_vector(FIBRE_PARAMETER_ID_WIDTH-1 downto 0);
      dat_size_o     : out std_logic_vector(FIBRE_DATA_SIZE_WIDTH-1 downto 0);
      dat_clk_o      : out std_logic;
      dat_o          : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);

      fibre_clkr_i   : in std_logic;
      fibre_data_i   : in std_logic_vector(RX_FIFO_DATA_WIDTH-1 downto 0);
      fibre_nrdy_i   : in std_logic;
      fibre_rvs_i    : in std_logic;
      fibre_rso_i    : in std_logic;
      fibre_sc_nd_i  : in std_logic
);
end fibre_rx;

architecture rtl of fibre_rx is

   -- Internal signal declarations
   signal rx_fr       : std_logic;                                        -- receive fifo read request
   signal rx_fw       : std_logic;                                        -- receive fifo write request
   signal rx_fe       : std_logic;                                        -- receive fifo empty
   signal rx_ff       : std_logic;                                        -- receive fifo full
   signal rxd         : std_logic_vector(RX_FIFO_DATA_WIDTH-1 DOWNTO 0);  -- data ouput of fifo

   component sync_fifo_rx
   PORT
   (
      data     : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
      wrreq    : IN STD_LOGIC ;
      rdreq    : IN STD_LOGIC ;
      rdclk    : IN STD_LOGIC ;
      wrclk    : IN STD_LOGIC ;
      aclr     : IN STD_LOGIC  := '0';
      q     : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
      rdempty     : OUT STD_LOGIC ;
      wrfull      : OUT STD_LOGIC
   );
   END component;

   -- FSM's states defined
   type states is (IDLE, RQ_BYTE, LD_BYTE, CKSM_CALC, WR_WORD, TEST_CKSM, CKSM_PASS, CKSM_FAIL, DATA_READ, DATA_SETL, DATA_TX);
   signal current_state : states;
   signal next_state    : states;

   -- checksum signals
   signal cksum_in       : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);    -- current value to be used to update cksum_calc
   signal cksum_rcvd     : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);    -- received checksum from rtl pc
   signal cksum_calc     : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);    -- calculated checksum value, continually being updated
   signal cksum_calc_ena : std_logic;
   signal cksum_calc_clr : std_logic;

   -- signals mapped to output ports
   signal cmd_code  : std_logic_vector (FIBRE_PACKET_TYPE_WIDTH-1 downto 0);  -- command code
   signal num_data  : std_logic_vector (FIBRE_DATA_SIZE_WIDTH-1 downto 0);    -- number of valid 32-bit data words


   constant BLOCK_SIZE : integer := 58;                                       -- total number of data words in a write_block
   constant FIBRE_PACKET_SIZE : integer := 64;

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

--   -- byte counter for byte 0 to 3 of each word
--   signal byte_count     : integer range 0 to 4;
--   signal byte_count_ena : std_logic;
--   signal byte_count_clr : std_logic;
--
--   -- word counter for the incoming packet
--   signal word_count     : integer range 0 to 64;
--   signal word_count_ena : std_logic;
--   signal word_count_clr : std_logic;

   -- negative clock for the memory
   signal n_clk : std_logic;

   signal timeout_clr     : std_logic;
   signal timeout_count   : integer;

   signal ena_word_count  : std_logic;
   signal load_word_count : std_logic;
   signal word_count      : integer;
   signal word_count_new  : integer;

   signal ena_byte_count  : std_logic;
   signal load_byte_count : std_logic;
   signal byte_count      : integer;
   signal byte_count_new  : integer;

begin

   ----------------------------------------------------------------------------
   -- Synchronous FIFO for receiving bytes from the Hotlink chip
   ----------------------------------------------------------------------------
   rx_fw <= not(fibre_nrdy_i) and not(fibre_sc_nd_i) and not(fibre_rvs_i) and not(rx_ff) and fibre_rso_i;

   SFIFO : sync_fifo_rx
   port map(
      data     => fibre_data_i,
      wrreq    => rx_fw,
      rdreq    => rx_fr,
      rdclk    => clk_i,
      wrclk    => fibre_clkr_i,
      aclr     => rst_i,
      q        => rxd,
      rdempty  => rx_fe,
      wrfull   => rx_ff
      );

   ----------------------------------------------------------------------------
   -- byte and word counters
   ----------------------------------------------------------------------------
   timeout_timer : us_timer
   port map(
      clk => clk_i,
      timer_reset_i => timeout_clr,
      timer_count_o => timeout_count
   );

--   byte_counter: counter
--   generic map(MAX => 4)
--   port map(
--      clk_i   => clk_i,
--      rst_i   => rst_i,
--      ena_i   => byte_count_ena,
--      load_i  => byte_count_clr,
--      count_i => 0,
--      count_o => byte_count
--   );

   byte_count_new <= byte_count + 1;
   byte_cntr: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         byte_count <= 0;
      elsif(clk_i'event and clk_i = '1') then
         if(load_byte_count = '1') then
            byte_count <= 0;
         elsif(ena_byte_count = '1') then
            byte_count <= byte_count_new;
         end if;
      end if;
   end process byte_cntr;

--   word_counter: counter
--   generic map(MAX => 64)
--   port map(
--      clk_i   => clk_i,
--      rst_i   => rst_i,
--      ena_i   => word_count_ena,
--      load_i  => word_count_clr,
--      count_i => 0,
--      count_o => word_count
--   );

   word_count_new <= word_count + 1;
   word_cntr: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         word_count <= 0;
      elsif(clk_i'event and clk_i = '1') then
         if(load_word_count = '1') then
            word_count <= 0;
         elsif(ena_word_count = '1') then
            word_count <= word_count_new;
         end if;
      end if;
   end process word_cntr;

   ----------------------------------------------------------------------------
   -- state machine
   ----------------------------------------------------------------------------
   FSM_state : process(clk_i, rst_i)
   begin
      if (rst_i = '1') then
         current_state <= IDLE;
      elsif (clk_i'EVENT AND clk_i = '1') then
         current_state <= next_state;
      end if;
   end process FSM_state;


   FSM_ns : process(current_state, rx_fe, word_count, byte_count, rxd, cmd_ack_i, cmd_code, cksum_calc, cksum_rcvd, number_data, read_pointer)
   begin
      next_state <= current_state;

      case current_state is
         when IDLE =>
            if(rx_fe = '0') then
               -- If the FIFO is not empty, request a byte
               next_state <= RQ_BYTE;
            end if;

         when RQ_BYTE =>
            next_state <= LD_BYTE;

-- This FSM should check the entire contents of the first two words cumulatively
         when LD_BYTE =>
            if(rx_fe = '0') then
               -- If the FIFO is not empty
               if((word_count = 0 and rxd /= FIBRE_PREAMBLE1(7 downto 0)) or (word_count = 1 and rxd /= FIBRE_PREAMBLE2(7 downto 0))) then
                  -- Check each byte of the first two words in succession
                  -- If any of the bytes don't match the expected preamble then discard them and go back to the IDLE state
                  next_state <= IDLE;
               elsif(byte_count = 3 and word_count > 1 and word_count < FIBRE_PACKET_SIZE-1) then
                  -- If we have passed the first two words of preample then start calculating the checksum.
                  -- Note that indexing starts at 0, which is why the count goes to FIBRE_PACKET_SIZE-1
                  next_state <= CKSM_CALC;
               else
                  -- Otherwise request another byte
                  next_state <= RQ_BYTE;
               end if;
            elsif(byte_count = 3 and word_count = FIBRE_PACKET_SIZE-1) then
               -- If the FIFO is empty and we've received an entire packet then test the checksum
               -- Note that indexing starts at 0, which is why the count goes to FIBRE_PACKET_SIZE-1
               next_state <= TEST_CKSM;
            end if;

         when CKSM_CALC =>
            if(word_count > 5 and word_count < FIBRE_PACKET_SIZE) then
               next_state <= WR_WORD;
            else
               next_state <= RQ_BYTE;
            end if;

         when WR_WORD =>
            if(rx_fe = '0') then
               next_state <= RQ_BYTE;
            end if;

         when TEST_CKSM =>
            if(cmd_ack_i = '1') then
               next_state <= TEST_CKSM;
            elsif(cksum_calc = cksum_rcvd) then
               next_state <= CKSM_PASS;
            else
               next_state <= CKSM_FAIL;
            end if;

         when CKSM_PASS =>
            if(cmd_ack_i = '1') then
               if(number_data = 0 or cmd_code = ASCII_R & ASCII_B) then
                  next_state <= IDLE;
               else
                  next_state <= DATA_READ;
               end if;
            end if;

         when CKSM_FAIL =>
            next_state <= IDLE;

         when DATA_READ =>
            next_state <= DATA_SETL;

         when DATA_SETL =>
            next_state <= DATA_TX;

         when DATA_TX =>
            if(read_pointer < number_data) then
               next_state <= DATA_READ;
            else
               next_state <= IDLE;
            end if;

         when others =>
            next_state <= IDLE;

      end case;
   end process FSM_ns;

   FSM_out : process(current_state, rx_fe, byte_count, word_count)
   begin
--      byte_count_ena <= '0';
--      byte_count_clr <= '0';
--      word_count_ena <= '0';
--      word_count_clr <= '0';
      ena_word_count  <= '0';
      load_word_count <= '0';
      ena_word_count  <= '0';
      load_word_count <= '0';

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
      cmd_err_o      <= '0';
      cmd_rdy_o      <= '0';
      rx_fr          <= '0';
      dat_clk_o      <= '0';
      timeout_clr    <= '1';

      case current_state is
         when IDLE =>
--            byte_count_ena <= '1';
--            byte_count_clr <= '1';
--            word_count_ena <= '1';
--            word_count_clr <= '1';
            ena_byte_count  <= '1';
            load_byte_count <= '1';
            ena_word_count  <= '1';
            load_word_count <= '1';

            reset_mem      <= '1';
            cksum_calc_clr <= '1';

         when RQ_BYTE =>
            timeout_clr    <= '0';
            rx_fr <= '1';

         when LD_BYTE =>
            timeout_clr    <= '0';

            case word_count is
               when 0 => null;
               when 1 => null;
               when 2 =>
                  ld_cmd <= '1';
                  ld_cksum_in <= '1';

               when 3 =>
                  ld_id <= '1';
                  ld_cksum_in <= '1';

               when 4 =>
                  ld_nda <= '1';
                  ld_cksum_in <= '1';

               when 63 =>
                  ld_cksum_rcvd <= '1';

               -- this covers cases 5 to 62:
               when others =>
                  ld_data <= '1';
                  ld_cksum_in <= '1';
            end case;

            if(rx_fe = '0') then
--               byte_count_ena <= '1';
               ena_byte_count  <= '1';
               if(byte_count = 3) then
--                  byte_count_clr <= '1';
                  load_byte_count <= '1';
--                  word_count_ena <= '1';
                  ena_word_count  <= '1';
               end if;
            end if;

         when CKSM_CALC =>
            case word_count is
               when 0 => null;
               when 1 => null;
               when others => cksum_calc_ena <= '1';
            end case;

         when WR_WORD =>
            if(rx_fe = '0') then
               write_mem <= '1';
            end if;

         when CKSM_PASS =>
            cmd_rdy_o <= '1';

         when CKSM_FAIL =>
            cmd_err_o <= '1';

         when DATA_READ =>
            read_mem    <= '1';
            cmd_rdy_o     <= '1';
            ld_cmd_data <= '1';

         when DATA_SETL =>
            cmd_rdy_o <= '1';

         when DATA_TX =>
            cmd_rdy_o  <= '1' ;
            dat_clk_o <= '1' ;

         when others =>    null;
      end case;
   end process FSM_out;

   ----------------------------------------------------------------------------
   -- cmd_code register
   ----------------------------------------------------------------------------
   dff_cmd: process(clk_i, rst_i)
   begin
      if (rst_i = '1') then
         cmd_code <= (others => '0');
      elsif (clk_i'EVENT and clk_i = '1') then
         if(ld_cmd = '1') then
            case byte_count is
               when 0 =>      cmd_code(7 downto 0)  <= rxd;
               when 1 =>      cmd_code(15 downto 8) <= rxd;
               when 2 =>      cmd_code(23 downto 16) <= rxd;
               when 3 =>      cmd_code(31 downto 24) <= rxd;
               when others => null;
            end case;
         end if;
      end if;
   end process dff_cmd;

   cmd_code_o <= cmd_code;

   ----------------------------------------------------------------------------
   -- param_id and card_id registers
   ----------------------------------------------------------------------------
   dff_id: process(clk_i, rst_i)
   begin
      if (rst_i = '1') then
         param_id_o <= (others => '0');
         card_addr_o <= (others => '0');
      elsif (clk_i'EVENT and clk_i = '1') then
         if(ld_id = '1') then
            case byte_count is
               when 0 =>      param_id_o(7 downto 0)  <= rxd;
               when 1 =>      param_id_o(15 downto 8) <= rxd;
               when 2 =>      card_addr_o(7 downto 0) <= rxd;
               when others => card_addr_o(15 downto 8) <= rxd;
            end case;
         end if;
      end if;
   end process dff_id;

   ----------------------------------------------------------------------------
   -- num_data register
   ----------------------------------------------------------------------------
   dff_nda: process(clk_i, rst_i)
   begin
      if (rst_i = '1') then
         num_data <= (others => '0');
      elsif (clk_i'EVENT and clk_i = '1') then
         if(ld_nda = '1') then
            case byte_count is
               when 0 =>      num_data(7 downto 0)   <= rxd;
               when 1 =>      num_data(15 downto 8)  <= rxd;
               when 2 =>      num_data(23 downto 16) <= rxd;
               when others => num_data(31 downto 24) <= rxd;
            end case;
         end if;
      end if;
   end process dff_nda;

   dat_size_o <= num_data;
   number_data <= conv_integer(num_data);

   ----------------------------------------------------------------------------
   -- checksum in register (holds most recently acquired word)
   ----------------------------------------------------------------------------
   dff_ckin: process(clk_i, rst_i)
   begin
      if (rst_i = '1') then
         cksum_in <= (others => '0');
      elsif (clk_i'EVENT and clk_i = '1') then
         if(ld_cksum_in = '1') then
            case byte_count is
               when 0 =>      cksum_in(7 downto 0)   <= rxd;
               when 1 =>      cksum_in(15 downto 8)  <= rxd;
               when 2 =>      cksum_in(23 downto 16) <= rxd;
               when others => cksum_in(31 downto 24) <= rxd;
            end case;
         end if;
      end if;
   end process dff_ckin;

   ----------------------------------------------------------------------------
   -- checksum received register (holds checksum in fibre packet)
   ----------------------------------------------------------------------------
   dff_ckrx: process(clk_i, rst_i)
   begin
      if (rst_i = '1') then
         cksum_rcvd <= (others => '0');
      elsif (clk_i'EVENT and clk_i = '1') then
         if(ld_cksum_rcvd = '1') then
            case byte_count is
               when 0 =>      cksum_rcvd(7 downto 0)   <= rxd;
               when 1 =>      cksum_rcvd(15 downto 8)  <= rxd;
               when 2 =>      cksum_rcvd(23 downto 16) <= rxd;
               when others => cksum_rcvd(31 downto 24) <= rxd;
            end case;
         end if;
      end if;
   end process dff_ckrx;

   ----------------------------------------------------------------------------
   -- calculated checksum register (holds chceksum calculated so far)
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
   -- memory pointer management
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
   -- memory data in register
   ----------------------------------------------------------------------------
   dff_data: process(clk_i, rst_i)
   begin
      if (rst_i = '1') then
         data_in <= (others => '0');
      elsif (clk_i'EVENT and clk_i = '1') then
         if(ld_data = '1') then
            case byte_count is
               when 0 =>      data_in(7 downto 0)   <= rxd;
               when 1 =>      data_in(15 downto 8)  <= rxd;
               when 2 =>      data_in(23 downto 16) <= rxd;
               when others => data_in(31 downto 24) <= rxd;
            end case;
         end if;
      end if;
   end process dff_data;

   ----------------------------------------------------------------------------
   -- memory data out register
   ----------------------------------------------------------------------------
   dff_cmd_data: process(clk_i, rst_i)
   begin
      if (rst_i = '1') then
         dat_o <= (others => '0');
      elsif (clk_i'EVENT and clk_i = '1') then
         if(ld_cmd_data = '1') then
            dat_o <= data_out;
         end if;
      end if;
   end process dff_cmd_data;

   ----------------------------------------------------------------------------
   -- memory instantiation
   ----------------------------------------------------------------------------
   n_clk <= not clk_i;

   mem0 : altsyncram
   generic map(
      WIDTH_A   => 32,
      WIDTHAD_A => 6,
      WIDTH_B   => 32,
      WIDTHAD_B => 6,
      OPERATION_MODE         => "DUAL_PORT",
      INTENDED_DEVICE_FAMILY => "Stratix",
      ADDRESS_REG_B          => "CLOCK1",
      OUTDATA_REG_B          => "UNREGISTERED")
   port map(
      clock0 => clk_i,
      clock1 => n_clk,
      address_a => write_pointer,
      address_b => read_pointer,
      wren_a => write_mem,
      data_a => data_in,
      q_b => data_out);


end rtl;