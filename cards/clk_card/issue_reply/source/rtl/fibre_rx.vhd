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
-- <revision control keyword substitutions e.g. $Id: fibre_rx.vhd,v 1.5.2.6 2007/01/31 01:44:39 bburger Exp $>
--
-- Project: Scuba 2
-- Author: David Atkinson/ Bryce Burger
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
-- <date $Date: 2007/01/31 01:44:39 $> - <text> - <initials $Author: bburger $>
-- $Log: fibre_rx.vhd,v $
-- Revision 1.5.2.6  2007/01/31 01:44:39  bburger
-- Bryce:  replaced counters, and updated all supporting circuitry
--
-- Revision 1.5.2.5  2007/01/26 06:21:52  bburger
-- Bryce: added custom counters to fibre_rx to make it more responsive.
--
-- Revision 1.5.2.4  2007/01/24 01:20:40  bburger
-- Bryce:  added a us-timer to allow fibre_rx to recover if there is an extra or missing byte in a packet
--
-- Revision 1.5.2.3  2006/12/22 22:07:51  bburger
-- Bryce:  experimental development -- not for release yet!  Working on making fibre_rx more robust with timer and such
--
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
   type states is (IDLE, RQ_BYTE, LD_BYTE, CKSM_CALC, WR_WORD, TEST_CKSM, CKSM_PASS, CKSM_FAIL, DATA_READ, DATA_SETL, DATA_TX, RX_ERROR);
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
   constant FIBRE_PACKET_TIMEOUT : integer := 128; -- in micro-seconds

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

   -- byte counter for byte 0 to 3 of each word
   signal byte_count     : integer range 0 to 4;
   signal byte_count_new : integer range 0 to 5;
   signal byte_count_ena : std_logic;
   signal byte_count_clr : std_logic;

   -- word counter for the incoming packet
   signal word_count     : integer range 0 to 64;
   signal word_count_new : integer range 0 to 65;
   signal word_count_ena : std_logic;
   signal word_count_clr : std_logic;

   -- negative clock for the memory
   signal n_clk : std_logic;

   signal timeout_clr    : std_logic;
   signal timeout_count  : integer;
   signal timeout        : std_logic;

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
   timeout <= '1' when timeout_count >= FIBRE_PACKET_TIMEOUT else '0';
   timeout_timer : us_timer
   port map(
      clk => clk_i,
      timer_reset_i => timeout_clr,
      timer_count_o => timeout_count
   );

   byte_count_new <= byte_count + 1;
   word_count_new <= word_count + 1;
   process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         byte_count <= 0;
         word_count <= 0;

      elsif(clk_i'event and clk_i = '1') then

         -- Byte counter
         if(byte_count_clr = '1') then
            byte_count <= 0;
         elsif(byte_count_ena = '1') then
            byte_count <= byte_count_new;
         end if;

         -- Word counter
         if(word_count_clr = '1') then
            word_count <= 0;
         elsif(word_count_ena = '1') then
            word_count <= word_count_new;
         end if;

      end if;
   end process;

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


   FSM_ns : process(current_state, rx_fe, word_count, byte_count, rxd, cmd_ack_i, cmd_code, cksum_calc, cksum_rcvd, number_data, read_pointer, timeout)
   begin
      next_state <= current_state;

      case current_state is
         when IDLE =>
            if(rx_fe = '0') then
               -- If the FIFO is not empty, request a byte
               next_state <= RQ_BYTE;
            end if;

         --------------------------------------------------
         -- The code demarkated by these dotted lines is part of the loop that receives a 64-word packet.
         -- If the timer times out in here, it's because there a packet is incomplete, or a spurrious byte was received.
         -- If a timeout occurs, the FSM should clear the bytes and go back to IDLE (not TEST_CKSM) in either case.
         -- This is to ensure that no responses are sent back to the PC for incomplete packets or spurrious words.
         -- As far as the MCE is concerned, it is difficult to tell the difference between these two cases.
         -- So trying to do something different for one or the other is out.
         -- In either case, the PC will just time out and recover.
         -- The only two states that the FSM can freeze in are the LD_BYTE adnd WR_WORD states, because the others transition immediately.
         -- In these states only, we check for timeouts.
         --------------------------------------------------
         when RQ_BYTE =>
            -- Clear timeout counter
            -- Request a byte
            next_state <= LD_BYTE;

         when LD_BYTE =>

            if(timeout = '1') then
               next_state <= RX_ERROR;
            elsif(word_count = 0 and rxd /= FIBRE_PREAMBLE1(7 downto 0) and byte_count >= 1 and byte_count <= 4) then
               -- Check each byte of the first two words in succession
               -- If any of the bytes don't match the expected preamble then discard them and go back to the IDLE state
               next_state <= IDLE;
            elsif(word_count = 1 and rxd /= FIBRE_PREAMBLE2(7 downto 0) and byte_count >= 1 and byte_count <= 4) then
               -- Check each byte of the first two words in succession
               -- If any of the bytes don't match the expected preamble then discard them and go back to the IDLE state
               next_state <= IDLE;
            elsif(word_count >= 2 and word_count <= FIBRE_PACKET_SIZE-2 and byte_count = 4) then
               -- If we have passed the first two words of preample then start calculating the checksum.
               -- Note that indexing starts at 0, which is why the count goes to FIBRE_PACKET_SIZE-1
               next_state <= CKSM_CALC;
            elsif(word_count >= FIBRE_PACKET_SIZE-1 and byte_count = 4) then
               -- If the FIFO is empty and we've received an entire packet then test the checksum
               -- Note that indexing starts at 0, which is why the count goes to FIBRE_PACKET_SIZE-1
               next_state <= TEST_CKSM;
            -- If were not at the pre-amble, or at the end of a 32-bit word, then we wait for the next byte.
            elsif(rx_fe = '0') then
               -- As soon as the fifo is not empty, we request the next byte.
               next_state <= RQ_BYTE;
            end if;

         when CKSM_CALC =>
--            if(word_count > 5 and word_count < FIBRE_PACKET_SIZE) then
               next_state <= WR_WORD;
--            else
--               next_state <= RQ_BYTE;
--            end if;

         when WR_WORD =>
            -- We get into this state only after having checked the checksum
            -- Before returning to the byte acquisition process, we wait for the fifo to contain a byte
            if(timeout = '1') then
               next_state <= RX_ERROR;
            elsif(rx_fe = '0') then
               next_state <= RQ_BYTE;
            end if;
         -------------------------------------------------
         -- End of section
         -------------------------------------------------

         when TEST_CKSM =>
            if(cmd_ack_i = '1') then
               -- Wait for the previous command to finish
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

         when RX_ERROR =>
            next_state <= IDLE;

         when DATA_READ =>
            next_state <= DATA_SETL;

         when DATA_SETL =>
            next_state <= DATA_TX;

         when DATA_TX =>
            -- What if a new command has come in before a previous one was done? then read pointer may be greater than number_data.
            if(read_pointer < number_data) then
               next_state <= DATA_READ;
            else
               next_state <= IDLE;
            end if;

         when others =>
            next_state <= IDLE;

      end case;
   end process FSM_ns;

   FSM_out : process(current_state, rx_fe, byte_count, word_count, timeout)
   begin
      byte_count_ena <= '0';
      byte_count_clr <= '0';
      word_count_ena <= '0';
      word_count_clr <= '0';
      ld_cksum_in    <= '0';
      ld_cksum_rcvd  <= '0';
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
            byte_count_ena <= '1';
            byte_count_clr <= '1';
            word_count_ena <= '1';
            word_count_clr <= '1';

            reset_mem      <= '1';
            cksum_calc_clr <= '1';

         when RQ_BYTE =>
            timeout_clr    <= '0';
            rx_fr          <= '1';
            byte_count_ena <= '1';

         when LD_BYTE =>
            timeout_clr    <= '0';

            -- The checksum is currently calculated based on words 2..62
            -- This is stupid
            if(word_count >= 2 and word_count <= FIBRE_PACKET_SIZE-2) then
               ld_cksum_in <= '1';
            elsif(word_count = FIBRE_PACKET_SIZE-1) then
               ld_cksum_rcvd <= '1';
            end if;

            if(byte_count = 4) then
               byte_count_clr <= '1';
               word_count_ena <= '1';
            end if;

         when CKSM_CALC =>
            timeout_clr    <= '0';

            if(word_count >= 2 and word_count <= FIBRE_PACKET_SIZE-2) then
               cksum_calc_ena <= '1';
            end if;

         when WR_WORD =>
            timeout_clr    <= '0';

            if(timeout = '1') then
               null;
            elsif(rx_fe = '0') then
               if(word_count > 5 and word_count < FIBRE_PACKET_SIZE) then
                  write_mem <= '1';
               end if;
            end if;

--            -- only write data..starting at word 5
----            if(word_count > 5 and word_count < FIBRE_PACKET_SIZE) then
--            if(rx_fe = '0') then
--               write_mem <= '1';
--            end if;

         when CKSM_PASS =>
            cmd_rdy_o <= '1';

         when CKSM_FAIL =>
            cmd_err_o <= '1';

         when RX_ERROR =>
            cmd_err_o <= '1';

         when DATA_READ =>
            read_mem <= '1';
            cmd_rdy_o <= '1';
            ld_cmd_data <= '1';

         when DATA_SETL =>
            cmd_rdy_o <= '1';

         when DATA_TX =>
            cmd_rdy_o <= '1' ;
            dat_clk_o <= '1' ;

         when others => null;
      end case;
   end process FSM_out;

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
               when 1 => cksum_in(7 downto 0)   <= rxd;
               when 2 => cksum_in(15 downto 8)  <= rxd;
               when 3 => cksum_in(23 downto 16) <= rxd;
               when 4 => cksum_in(31 downto 24) <= rxd;
               when others => null;
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
               when 1 => cksum_rcvd(7 downto 0)   <= rxd;
               when 2 => cksum_rcvd(15 downto 8)  <= rxd;
               when 3 => cksum_rcvd(23 downto 16) <= rxd;
               when 4 => cksum_rcvd(31 downto 24) <= rxd;
               when others => null;
            end case;
         end if;
      end if;
   end process dff_ckrx;

   ----------------------------------------------------------------------------
   -- cmd_code register
   ----------------------------------------------------------------------------
   dff_cmd: process(clk_i, rst_i)
   begin
      if (rst_i = '1') then
         cmd_code <= (others => '0');
      elsif (clk_i'EVENT and clk_i = '1') then
         if(word_count = 2) then
            case byte_count is
               when 1 => cmd_code(7 downto 0)  <= rxd;
               when 2 => cmd_code(15 downto 8) <= rxd;
               when 3 => cmd_code(23 downto 16) <= rxd;
               when 4 => cmd_code(31 downto 24) <= rxd;
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
         if(word_count = 3) then
            case byte_count is
               when 1 => param_id_o(7 downto 0)   <= rxd;
               when 2 => param_id_o(15 downto 8)  <= rxd;
               when 3 => card_addr_o(7 downto 0)  <= rxd;
               when 4 => card_addr_o(15 downto 8) <= rxd;
               when others => null;
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
         if(word_count = 4) then
            case byte_count is
               when 1 => num_data(7 downto 0)   <= rxd;
               when 2 => num_data(15 downto 8)  <= rxd;
               when 3 => num_data(23 downto 16) <= rxd;
               when 4 => num_data(31 downto 24) <= rxd;
               when others => null;
            end case;
         end if;
      end if;
   end process dff_nda;

   dat_size_o <= num_data;
   number_data <= conv_integer(num_data);

   ----------------------------------------------------------------------------
   -- memory data in register
   ----------------------------------------------------------------------------
   dff_data: process(clk_i, rst_i)
   begin
      if (rst_i = '1') then
         data_in <= (others => '0');
      elsif (clk_i'EVENT and clk_i = '1') then
         if(word_count >= 5 and word_count <= FIBRE_PACKET_SIZE-2) then
            case byte_count is
               when 1 => data_in(7 downto 0)   <= rxd;
               when 2 => data_in(15 downto 8)  <= rxd;
               when 3 => data_in(23 downto 16) <= rxd;
               when 4 => data_in(31 downto 24) <= rxd;
               when others => null;
            end case;
         end if;
      end if;
   end process dff_data;

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