library ieee;
use ieee.std_logic_1164.all;

library components;
use components.component_pack.all;
use work.async_pack.all;
use work.ascii_pack.all;

entity all_test is
port(inclk : in std_logic;
     nrst  : in std_logic;

     rx : in std_logic;
     tx : out std_logic;

     led  : out std_logic_vector(7 downto 0);
     dip  : in std_logic_vector(1 downto 0);
     slot : in std_logic_vector(3 downto 0));
end all_test;

architecture rtl of all_test is

constant RESET_MSG_LEN    : integer := 18;
constant IDLE_MSG_LEN     : integer := 10;
constant ERROR_MSG_LEN    : integer := 11;
constant EASTER_MSG_LEN   : integer := 14;
constant DIP_SWITCH_WIDTH : integer := 2;
constant SLOT_ID_WIDTH    : integer := 4;

signal clk : std_logic;
signal rst : std_logic;

component all_test_pll
port(inclk0 : in std_logic;
     c0 : out std_logic);
end component;

type states is (RESET, TX_RESET, TX_IDLE, TX_ERROR, TX_EASTER, RX_CMD1, RX_CMD2, TOGGLE_LED, READ_DIP, TX_DIP, READ_SLOT, TX_SLOT);
signal pres_state : states;
signal next_state : states;

signal rx_data : std_logic_vector(7 downto 0);
signal rx_ack  : std_logic;
signal rx_rdy  : std_logic;

signal tx_data : std_logic_vector(7 downto 0);
signal tx_rdy  : std_logic;
signal tx_busy : std_logic;

signal tx_count : integer range 0 to 70;
signal tx_count_ena : std_logic;
signal tx_count_clr : std_logic;

signal reset_msg  : std_logic_vector(7 downto 0);
signal idle_msg   : std_logic_vector(7 downto 0);
signal error_msg  : std_logic_vector(7 downto 0);
signal easter_msg : std_logic_vector(7 downto 0);

signal cmd1    : std_logic_vector(7 downto 0);
signal cmd2    : std_logic_vector(7 downto 0);
signal cmd1_ld : std_logic;
signal cmd2_ld : std_logic;

signal led0     : std_logic;
signal led1     : std_logic;
signal led2     : std_logic;
signal led0_ena : std_logic;
signal led1_ena : std_logic;
signal led2_ena : std_logic;

component dip_switch_test_wrapper
port(-- basic signals
     rst_i     : in std_logic;    -- reset input
     clk_i     : in std_logic;    -- clock input
     en_i      : in std_logic;    -- enable signal
     done_o    : out std_logic;   -- done ouput signal
      
     -- transmitter signals
     data_o    : out std_logic_vector(1 downto 0);
      
     -- extended signals
     dip_switch_i : in std_logic_vector (1 downto 0)); -- physical dip switch pin
end component;

signal dip_test_ena  : std_logic;
signal dip_test_done : std_logic;
signal dip_test_data : std_logic_vector(1 downto 0);
signal dip_reg_ena   : std_logic;
signal dip_reg_ld    : std_logic;
signal dip_reg_data  : std_logic;

component slot_id_test_wrapper
port(-- basic signals
     rst_i     : in std_logic;    -- reset input
     clk_i     : in std_logic;    -- clock input
     en_i      : in std_logic;    -- enable signal
     done_o    : out std_logic;   -- done ouput signal
      
     -- transmitter signals
     data_o    : out std_logic_vector(3 downto 0);

     -- extended signals
     slot_id_i : in std_logic_vector (3 downto 0)); -- physical slot_id pin
end component;
 
signal slot_test_ena  : std_logic;
signal slot_test_done : std_logic;
signal slot_test_data : std_logic_vector(3 downto 0);
signal slot_reg_data  : std_logic;
signal slot_reg_ena   : std_logic;
signal slot_reg_ld    : std_logic;

signal rst_cmd : std_logic;

begin

   rst <= not nrst or rst_cmd;

   clk0: all_test_pll
   port map(inclk0 => inclk,
            c0 => clk);


   --------------------------------------------------------
   -- RS-232 blocks
   --------------------------------------------------------

   rx0: rs232_rx
   port map(clk_i   => clk,
            rst_i   => rst,
            dat_o   => rx_data,
            rdy_o   => rx_rdy,
            ack_i   => rx_ack,
            rs232_i => rx);

   tx0: rs232_tx
   port map(clk_i   => clk,
            rst_i   => rst,
            dat_i   => tx_data,
            rdy_i   => tx_rdy,
            busy_o  => tx_busy,
            rs232_o => tx);


   --------------------------------------------------------
   -- Command character storage
   --------------------------------------------------------

   cmdchar1 : reg
   generic map(WIDTH => 8)
   port map(clk_i  => clk,
            rst_i  => rst,
            ena_i  => cmd1_ld,
            reg_i  => rx_data,
            reg_o  => cmd1);

   cmdchar2 : reg
   generic map(WIDTH => 8)
   port map(clk_i  => clk,
            rst_i  => rst,
            ena_i  => cmd2_ld,
            reg_i  => rx_data,
            reg_o  => cmd2);


   --------------------------------------------------------
   -- Message logic
   --------------------------------------------------------

   tx_char_counter: counter
   generic map(MAX => 70,
               WRAP_AROUND => '0')
   port map(clk_i   => clk,
            rst_i   => rst,
            ena_i   => tx_count_ena,
            load_i  => tx_count_clr,
            count_i => 0,
            count_o => tx_count);


   with tx_count select
      reset_msg <= newline   when 0,
                   newline   when 1,
                   shift(a)  when 2,
                   l         when 3,
                   l         when 4,
                   space     when 5,
                   shift(t)  when 6,
                   e         when 7,
                   s         when 8,
                   t         when 9,
                   space     when 10,
                   v         when 11,
                   period    when 12, 
                   three     when 13, 
                   period    when 14,
                   zero      when 15,
                   b         when 16,
                   newline   when others;

   with tx_count select
      idle_msg <= newline      when 0,
                  shift(c)     when 1,
                  o            when 2,
                  m            when 3,
                  m            when 4,
                  a            when 5,
                  n            when 6,
                  d            when 7,
                  shift(slash) when 8,
                  space        when others;

   with tx_count select
      error_msg <= tab         when 0,
                   shift(y)    when 1,
                   o           when 2,
                   u           when 3,
                   space       when 4,
                   m           when 5,
                   o           when 6,
                   r           when 7,
                   o           when 8,
                   n           when 9,
                   shift(one)  when others;

   with tx_count select
      easter_msg <= r          when 0,
                    n          when 1,
                    i          when 2,
                    e          when 3,
                    space      when 4,
                    i          when 5,
                    s          when 6,
                    space      when 7,
                    shift(g)   when 8,
                    r          when 9,
                    e          when 10,
                    a          when 11,
                    t          when 12,
                    shift(one) when others;


   --------------------------------------------------------
   -- Control logic
   --------------------------------------------------------

   process(clk, nrst)
   begin
      if(nrst = '0') then
         pres_state <= RESET;
      elsif(clk = '1' and clk'event) then
         pres_state <= next_state;
      end if;
   end process;

   process(pres_state, rx_rdy, rx_data, tx_count, dip_test_done, slot_test_done)
   begin
      case pres_state is
         when RESET =>      next_state <= TX_RESET;

         when TX_RESET =>   if(tx_count = RESET_MSG_LEN - 1) then
                               next_state <= TX_IDLE;
                            else
                               next_state <= TX_RESET;
                            end if;

         when TX_IDLE =>    if(tx_count = IDLE_MSG_LEN - 1) then
                               next_state <= RX_CMD1;
                            else
                               next_state <= TX_IDLE;
                            end if;

         when TX_ERROR =>   if(tx_count = ERROR_MSG_LEN - 1) then
                               next_state <= TX_IDLE;
                            else
                               next_state <= TX_ERROR;
                            end if;

         when TX_EASTER =>  if(tx_count = EASTER_MSG_LEN - 1) then
                               next_state <= TX_IDLE;
                            else
                               next_state <= TX_EASTER;
                            end if;

         when RX_CMD1 =>    if(rx_rdy = '1') then
                               case rx_data is
                                  when d | shift(d) => next_state <= READ_DIP;
                                  when e | shift(e) => next_state <= TX_EASTER;
                                  when l | shift(l) => next_state <= RX_CMD2;
                                  when s | shift(s) => next_state <= READ_SLOT;
                                  when escape =>       next_state <= RESET;
                                  when others =>       next_state <= TX_ERROR;
                               end case;
                            else
                               next_state <= RX_CMD1;
                            end if;

         when RX_CMD2 =>    if(rx_rdy = '1') then
                               case rx_data is
                                  when one | two | three => next_state <= TOGGLE_LED;
                                  when escape =>            next_state <= RESET;
                                  when others =>            next_state <= TX_ERROR;
                               end case;
                            else
                               next_state <= RX_CMD2;
                            end if;

         when TOGGLE_LED => next_state <= TX_IDLE;

         when READ_DIP =>   if(dip_test_done = '1') then
                               next_state <= TX_DIP;
                            else
                               next_state <= READ_DIP;
                            end if;

         when TX_DIP =>     if(tx_count = DIP_SWITCH_WIDTH - 1) then
                               next_state <= TX_IDLE;
                            else
                               next_state <= TX_DIP;
                            end if;

         when READ_SLOT =>  if(slot_test_done = '1') then
                               next_state <= TX_SLOT;
                            else
                               next_state <= READ_SLOT;
                            end if;

         when TX_SLOT =>    if(tx_count = SLOT_ID_WIDTH - 1) then
                               next_state <= TX_IDLE;
                            else
                               next_state <= TX_SLOT;
                            end if;

         when others =>     next_state <= TX_IDLE;

      end case;
   end process;

   process(pres_state, tx_busy, tx_count, reset_msg, idle_msg, error_msg, easter_msg, cmd2, dip_reg_data, slot_reg_data)   
   begin
      rx_ack       <= '0';
      tx_rdy       <= '0';
      tx_data      <= (others => '0');
      tx_count_ena <= '0';
      tx_count_clr <= '0';
      cmd1_ld      <= '0';
      cmd2_ld      <= '0';
      led0_ena     <= '0';
      led1_ena     <= '0';
      led2_ena     <= '0';
      dip_test_ena <= '0';
      dip_reg_ena  <= '0';
      dip_reg_ld   <= '0';
      slot_test_ena <= '0';
      slot_reg_ena <= '0';
      slot_reg_ld  <= '0';
      rst_cmd      <= '0';

      case pres_state is
         when RESET =>      tx_count_ena <= '1';
                            tx_count_clr <= '1';
                            rst_cmd      <= '1';

         when TX_RESET =>   if(tx_busy = '0') then
                               tx_rdy       <= '1';
                               tx_count_ena <= '1';
                            end if;
                            if(tx_count = RESET_MSG_LEN - 1) then
                               tx_count_ena <= '1';
                               tx_count_clr <= '1';
                            end if;
                            tx_data <= reset_msg;

         when TX_IDLE =>    if(tx_busy = '0') then
                               tx_rdy       <= '1';
                               tx_count_ena <= '1';
                            end if;
                            if(tx_count = IDLE_MSG_LEN - 1) then
                               tx_count_ena <= '1';
                               tx_count_clr <= '1';
                            end if;   
                            tx_data <= idle_msg;

         when TX_ERROR =>   if(tx_busy = '0') then
                               tx_rdy       <= '1';
                               tx_count_ena <= '1';
                            end if;
                            if(tx_count = ERROR_MSG_LEN - 1) then
                               tx_count_ena <= '1';
                               tx_count_clr <= '1';
                            end if;
                            tx_data <= error_msg;

         when TX_EASTER =>  if(tx_busy = '0') then
                               tx_rdy       <= '1';
                               tx_count_ena <= '1';
                            end if;
                            if(tx_count = EASTER_MSG_LEN - 1) then
                               tx_count_ena <= '1';
                               tx_count_clr <= '1';
                            end if;
                            tx_data <= easter_msg;

         when RX_CMD1 =>    rx_ack       <= '1';
                            tx_count_ena <= '1';
                            tx_count_clr <= '1';
                            cmd1_ld      <= '1';

         when RX_CMD2 =>    rx_ack       <= '1';
                            tx_count_ena <= '1';
                            tx_count_clr <= '1';
                            cmd2_ld      <= '1';

         when TOGGLE_LED => case cmd2 is
                               when one =>    led0_ena <= '1';
                               when two =>    led1_ena <= '1';
                               when three =>  led2_ena <= '1';
                               when others => null;
                            end case;

         when READ_DIP =>   dip_test_ena <= '1';
                            dip_reg_ena  <= '1';
                            dip_reg_ld   <= '1';
                            tx_count_ena <= '1';
                            tx_count_clr <= '1';

         when TX_DIP =>     if(tx_busy = '0') then
                               tx_rdy       <= '1';
                               dip_reg_ena  <= '1';
                               tx_count_ena <= '1';
                            end if;
                            if(tx_count = DIP_SWITCH_WIDTH - 1) then
                               tx_count_ena <= '1';
                               tx_count_clr <= '1';
                            end if;
                            tx_data <= bin2asc(dip_reg_data);

         when READ_SLOT =>  slot_test_ena <= '1';
                            slot_reg_ena <= '1';
                            slot_reg_ld  <= '1';
                            tx_count_ena <= '1';
                            tx_count_clr <= '1';

         when TX_SLOT =>    if(tx_busy = '0') then
                               tx_rdy       <= '1';
                               slot_reg_ena <= '1';
                               tx_count_ena <= '1';
                            end if;
                            if(tx_count = SLOT_ID_WIDTH - 1) then
                               tx_count_ena <= '1';
                               tx_count_clr <= '1';
                            end if;
                            tx_data <= bin2asc(slot_reg_data);

         when others =>     null;

      end case;
   end process;


   --------------------------------------------------------
   --- LED block
   --------------------------------------------------------

   process(clk, rst)
   begin
      if(rst = '1') then
         led0 <= '0';
         led1 <= '0';
         led2 <= '0';
      elsif(clk'event and clk = '1') then
         if(led0_ena = '1') then
            led0 <= not led0;
         elsif(led1_ena = '1') then
            led1 <= not led1;
         elsif(led2_ena = '1') then
            led2 <= not led2;
         end if;
      end if;
   end process;

   led(0) <= led0;
   led(1) <= led1;
   led(2) <= led2;
      

   --------------------------------------------------------
   -- DIP Switch block
   --------------------------------------------------------

   dip_test : dip_switch_test_wrapper
   port map(clk_i => clk,
            rst_i => rst,
            en_i  => dip_test_ena,
            done_o => dip_test_done,
            data_o => dip_test_data,
            dip_switch_i => dip);

   dip_reg : shift_reg
   generic map(WIDTH => DIP_SWITCH_WIDTH)
   port map(clk_i      => clk,
            rst_i      => rst,
            ena_i      => dip_reg_ena,
            load_i     => dip_reg_ld,
            clr_i      => '0',
            shr_i      => '0',
            serial_i   => '0',
            serial_o   => dip_reg_data,
            parallel_i => dip_test_data,
            parallel_o => open);


   --------------------------------------------------------
   -- Slot ID block 
   --------------------------------------------------------

   slot_test : slot_id_test_wrapper
   port map(clk_i => clk,
            rst_i => rst,
            en_i => slot_test_ena,
            done_o => slot_test_done,
            data_o => slot_test_data,
            slot_id_i => slot);

   slot_reg : shift_reg
   generic map(WIDTH => SLOT_ID_WIDTH)
   port map(clk_i      => clk,
            rst_i      => rst,
            ena_i      => slot_reg_ena,
            load_i     => slot_reg_ld,
            clr_i      => '0',
            shr_i      => '0',
            serial_i   => '0',
            serial_o   => slot_reg_data,
            parallel_i => slot_test_data,
            parallel_o => open);

end rtl;