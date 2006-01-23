library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity shift_reg is
   generic(WIDTH : in integer range 2 to 512 := 8);
   port(clk_i      : in std_logic;
        rst_i      : in std_logic;
        ena_i      : in std_logic;
        load_i     : in std_logic;
        clr_i      : in std_logic;
        shr_i      : in std_logic;
        serial_i   : in std_logic;
        serial_o   : out std_logic;
        parallel_i : in std_logic_vector(WIDTH-1 downto 0);
        parallel_o : out std_logic_vector(WIDTH-1 downto 0));
end shift_reg;

architecture behav of shift_reg is
signal reg : std_logic_vector(WIDTH-1 downto 0);
begin

   shiftreg: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         reg <= (others => '0');
      elsif(clk_i'event and clk_i = '1') then
         if(clr_i = '1') then
            reg <= (others => '0');
         elsif(ena_i = '1') then
            if(load_i = '1') then
               reg <= parallel_i;
            else
               if(shr_i = '1') then
                  reg <= serial_i & reg(WIDTH-1 downto 1);
               else
                  reg <= reg(WIDTH-2 downto 0) & serial_i;
               end if;
            end if;
         end if;
      end if;
   end process shiftreg;


   
   serial_o <= reg(0) when shr_i = '1' else reg(WIDTH-1); -- when doing a shr, we grab the LSB.  When doing shl, we grab the MSB
   parallel_o <= reg;

end behav;



library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity binary_counter is
generic(WIDTH : integer range 2 to 64 := 8);
port(clk_i   : in std_logic;
     rst_i   : in std_logic;
     ena_i   : in std_logic;
     up_i    : in std_logic;
     load_i  : in std_logic;
     clear_i : in std_logic;
     count_i : in std_logic_vector(WIDTH-1 downto 0);
     count_o : out std_logic_vector(WIDTH-1 downto 0));
end binary_counter;

architecture behav of binary_counter is

signal count : std_logic_vector(WIDTH-1 downto 0);

begin

   process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         count <= (others => '0');            -- reset counter to "000..00"
      elsif(clk_i'event and clk_i = '1') then
         if(clear_i = '1') then
            if(up_i = '1') then
               count <= (others => '0');      -- clear the counter value to "000..00" when counting up...
            else
               count <= (others => '1');      -- and "111..11" when counting down
            end if;
         elsif(ena_i = '1') then
            if(load_i = '1') then
               count <= count_i;              -- load new counter value
            elsif(up_i = '1') then
               count <= count + 1;            -- add 1 to count value when counting up...
            else
               count <= count - 1;            -- subtract 1 from count value when counting down
            end if;
         end if;
      end if;
   end process;
   
   count_o <= count;

end behav;    



library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity decoder is
port(input_i : in std_logic_vector(6 downto 0);
     ones_o : out std_logic_vector(6 downto 0);
     tens_o : out std_logic_vector(6 downto 0));
end decoder;

architecture rtl of decoder is
begin

   process(input_i)
   begin
      tens_o <= "1111111";

      if(input_i > 9 and input_i <= 19) then
         tens_o <= "1001111";
      end if;

      if(input_i > 19 and input_i <= 29) then
         tens_o <= "0010010";
      end if;

      if(input_i > 29 and input_i <= 39) then
         tens_o <= "0000110";
      end if;

      if(input_i > 39 and input_i <= 49) then
         tens_o <= "1001100";
      end if;

      if(input_i > 49 and input_i <= 59) then
         tens_o <= "0100100";
      end if;
   end process;

   process(input_i)
   begin
      ones_o <= "1111111";

      if(input_i = 0 or input_i = 10 or input_i = 20 or input_i = 30 or input_i = 40 or input_i = 50) then
         ones_o <= "0000001";
      end if;

      if(input_i = 1 or input_i = 11 or input_i = 21 or input_i = 31 or input_i = 41 or input_i = 51) then
         ones_o <= "1001111";
      end if;

      if(input_i = 2 or input_i = 12 or input_i = 22 or input_i = 32 or input_i = 42 or input_i = 52) then
         ones_o <= "0010010";
      end if;

      if(input_i = 3 or input_i = 13 or input_i = 23 or input_i = 33 or input_i = 43 or input_i = 53) then
         ones_o <= "0000110";
      end if;

      if(input_i = 4 or input_i = 14 or input_i = 24 or input_i = 34 or input_i = 44 or input_i = 54) then
         ones_o <= "1001100";
      end if;

      if(input_i = 5 or input_i = 15 or input_i = 25 or input_i = 35 or input_i = 45 or input_i = 55) then
         ones_o <= "0100100";
      end if;

      if(input_i = 6 or input_i = 16 or input_i = 26 or input_i = 36 or input_i = 46 or input_i = 56) then
         ones_o <= "0100000";
      end if;

      if(input_i = 7 or input_i = 17 or input_i = 27 or input_i = 37 or input_i = 47 or input_i = 57) then
         ones_o <= "0001111";
      end if;

      if(input_i = 8 or input_i = 18 or input_i = 28 or input_i = 38 or input_i = 48 or input_i = 58) then
         ones_o <= "0000000";
      end if;

      if(input_i = 9 or input_i = 19 or input_i = 29 or input_i = 39 or input_i = 49 or input_i = 59) then
         ones_o <= "0001100";
      end if;
   end process;

end rtl;



library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity smb_master is
port(clk_i         : in std_logic;
     rst_i         : in std_logic;

     -- host-side signals
     master_data_i : in std_logic_vector(7 downto 0);
     master_data_o : out std_logic_vector(7 downto 0);

     start_i       : in std_logic;         -- request a start condition
     stop_i        : in std_logic;         -- request a stop condition
     write_i       : in std_logic;         -- write a byte
     read_i        : in std_logic;         -- read a byte

     done_o        : out std_logic;        -- operation completed
     error_o       : out std_logic;        -- slave returned an error

     -- slave-side signals
     slave_clk_o   : out std_logic;        -- SMBus clock
     slave_data_io : inout std_logic);     -- SMBus data
end smb_master;

architecture rtl of smb_master is

--------------------------------------------------------------------------------------
-- NOTE: The following constants must be adjusted if the clock frequency changes!
--
-- END_CONDITION_LENGTH = 8.7 us
-- START_SETUP_DELAY = 4.7 us
-- STOP_SETUP_DELAY = 4 us
-- BIT_PERIOD_LENGTH = 100 us
-- DATA_VALID_BEGIN = 40 us       -- smbdat valid 40 us after start of bit period
-- DATA_VALID_END = 90 us         -- smbdat invalid 90 us after start of bit period
-- READ_DATA_SAMPLE = 65 us
--------------------------------------------------------------------------------------

constant END_CONDITION_LENGTH : integer := 435;   -- 435 x 20 ns clock cycle = 8.7 us   
constant START_SETUP_DELAY    : integer := 235;
constant STOP_SETUP_DELAY     : integer := 200;
constant BIT_PERIOD_LENGTH    : integer := 5000;
constant DATA_VALID_BEGIN     : integer := 2000;
constant DATA_VALID_END       : integer := 4500;
constant READ_DATA_SAMPLE     : integer := 3250;

constant TIMER_WIDTH : integer := 13;   -- 2**TIMER_WIDTH must be greater than largest constant above!

type states is (BUS_FREE, BUS_IDLE, START, STOP, WRITE_BYTE, READ_BYTE, START_DONE, STOP_DONE, WRITE_DONE, READ_DONE);
signal pres_state : states;
signal next_state : states;

signal write_reg_ena : std_logic;
signal write_reg_ld  : std_logic;
signal write_data    : std_logic;

signal read_reg_ena : std_logic;
signal read_data    : std_logic_vector(7 downto 0);

signal bit_count_ena : std_logic;
signal bit_count_clr : std_logic;
signal bit_count     : std_logic_vector(3 downto 0);

signal timer_clr : std_logic;
signal timer     : std_logic_vector(TIMER_WIDTH-1 downto 0);

   component shift_reg
      generic(WIDTH : in integer range 2 to 512 := 8);

      port(clk_i      : in std_logic;
           rst_i      : in std_logic;
           ena_i      : in std_logic;
           load_i     : in std_logic;
           clr_i      : in std_logic;
           shr_i      : in std_logic;
           serial_i   : in std_logic;
           serial_o   : out std_logic;
           parallel_i : in std_logic_vector(WIDTH-1 downto 0);
           parallel_o : out std_logic_vector(WIDTH-1 downto 0));
   end component;

   component binary_counter
   generic(WIDTH : integer range 2 to 64 := 8);
   port(clk_i   : in std_logic;
        rst_i   : in std_logic;
        ena_i   : in std_logic;
        up_i    : in std_logic;
        load_i  : in std_logic;
        clear_i : in std_logic;
        count_i : in std_logic_vector(WIDTH-1 downto 0);
        count_o : out std_logic_vector(WIDTH-1 downto 0));
   end component;

begin

   tx_data_reg: shift_reg
   generic map(WIDTH => 8)
   port map(clk_i      => clk_i,
            rst_i      => rst_i,
            ena_i      => write_reg_ena,
            load_i     => write_reg_ld,
            clr_i      => '0',
            shr_i      => '0',
            serial_i   => '0',
            serial_o   => write_data,
            parallel_i => master_data_i,
            parallel_o => open);

   rx_data_reg : shift_reg
   generic map(WIDTH => 8)
   port map(clk_i      => clk_i,
            rst_i      => rst_i,
            ena_i      => read_reg_ena,
            load_i     => '0',
            clr_i      => '0',
            shr_i      => '0',
            serial_i   => slave_data_io,
            serial_o   => open,
            parallel_i => (others => '0'),
            parallel_o => read_data); 

   master_data_o <= read_data;
   
   bit_counter : binary_counter
   generic map(WIDTH => 4)
   port map(clk_i   => clk_i,
            rst_i   => rst_i,
            ena_i   => bit_count_ena,
            up_i    => '1',
            load_i  => '0',
            clear_i => bit_count_clr,
            count_i => (others => '0'),
            count_o => bit_count);
     
   timer_counter : binary_counter
   generic map(WIDTH => TIMER_WIDTH)
   port map(clk_i   => clk_i,
            rst_i   => rst_i,
            ena_i   => '1',
            up_i    => '1',
            load_i  => '0',
            clear_i => timer_clr,
            count_i => (others => '0'),
            count_o => timer);
            

   ---------------------------------------------------------
   -- SMB Bus Protocol FSM
   ---------------------------------------------------------

   stateFF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         pres_state <= BUS_FREE;
      elsif(clk_i'event and clk_i = '1') then
         pres_state <= next_state;
      end if;
   end process stateFF;

   stateNS: process(pres_state, start_i, stop_i, write_i, read_i, bit_count, timer)
   begin
      case pres_state is
        when BUS_FREE =>        if(start_i = '1') then           -- must have start before anything else
                                   next_state <= START;
                                else
                                   next_state <= BUS_FREE;
                                end if;

        when BUS_IDLE =>        if(start_i = '1') then           -- request repeated start
                                   next_state <= START;
                                elsif(stop_i = '1') then
                                   next_state <= STOP;
                                elsif(write_i = '1') then
                                   next_state <= WRITE_BYTE;
                                elsif(read_i = '1') then
                                   next_state <= READ_BYTE;
                                else
                                   next_state <= BUS_IDLE;
                                end if;

        when START =>           if(timer = END_CONDITION_LENGTH) then
                                   next_state <= START_DONE;
                                else
                                   next_state <= START;
                                end if;

        when STOP =>            if(timer = END_CONDITION_LENGTH) then
                                   next_state <= STOP_DONE;
                                else
                                   next_state <= STOP;
                                end if;

        when WRITE_BYTE =>      if(timer = BIT_PERIOD_LENGTH and bit_count = 8) then
                                   next_state <= WRITE_DONE;
                                else
                                   next_state <= WRITE_BYTE;
                                end if;

        when READ_BYTE =>       if(timer = BIT_PERIOD_LENGTH and bit_count = 8) then
                                   next_state <= READ_DONE;
                                else
                                   next_state <= READ_BYTE;
                                end if;

        when START_DONE =>      next_state <= BUS_IDLE;

        when STOP_DONE =>       next_state <= BUS_FREE;
                                
        when WRITE_DONE =>      next_state <= BUS_IDLE;   

        when READ_DONE =>       next_state <= BUS_IDLE;

        when others =>          next_state <= BUS_FREE;
      end case;
   end process stateNS;

   stateOut: process(pres_state, write_data, read_data, bit_count, timer)
   begin
      done_o        <= '0';
      error_o       <= '0';

      slave_clk_o   <= 'Z';
      slave_data_io <= 'Z';

      write_reg_ena <= '0';
      write_reg_ld  <= '0';

      read_reg_ena  <= '0';

      bit_count_ena <= '0';
      bit_count_clr <= '0';

      timer_clr     <= '0';

      case pres_state is
        when BUS_FREE =>   timer_clr     <= '1';

        when BUS_IDLE =>   slave_clk_o   <= '0';
                           slave_data_io <= '0';
                           write_reg_ena <= '1';
                           write_reg_ld  <= '1';
                           bit_count_clr <= '1';
                           timer_clr     <= '1';

        when START =>      if(timer > START_SETUP_DELAY) then 
                              slave_data_io <= '0';  
                           end if;

        when STOP =>       if(timer < STOP_SETUP_DELAY) then 
                              slave_data_io <= '0';  
                           end if;

        when WRITE_BYTE => if(timer < DATA_VALID_BEGIN or timer > DATA_VALID_END) then
                              slave_clk_o   <= '0';
                           end if;

                           if(bit_count < 8 and write_data = '0') then
                              slave_data_io <= '0';
                           end if;

                           if(bit_count = 8 and timer = READ_DATA_SAMPLE) then
                              read_reg_ena  <= '1';
                           end if;
 
                           if(timer = BIT_PERIOD_LENGTH) then
                              if(bit_count = 8) then
                                 bit_count_clr <= '1';
                              else
                                 bit_count_ena <= '1';
                              end if;
                              write_reg_ena <= '1';
                              timer_clr     <= '1';
                           end if;

        when READ_BYTE =>  if(timer < DATA_VALID_BEGIN or timer > DATA_VALID_END) then
                              slave_clk_o   <= '0';
                           end if;

                           if(bit_count < 8 and timer = READ_DATA_SAMPLE) then
                              read_reg_ena  <= '1';
                           end if;

                           if(timer = BIT_PERIOD_LENGTH) then
                              if(bit_count = 8) then
                                 bit_count_clr <= '1';
                              else
                                 bit_count_ena <= '1';
                              end if;
                              timer_clr     <= '1';
                           end if;

        when START_DONE => slave_clk_o   <= '0';            -- smbclk and smbdat are low after start
                           slave_data_io <= '0';
                           done_o        <= '1';

        when STOP_DONE =>  done_o        <= '1';            -- smbclk and smbdat are high (ie. SMBus idle) after stop
                                   
        when WRITE_DONE => slave_clk_o   <= '0';            -- smbclk is low (glitches on smbdat are ok) after write
                           done_o        <= '1';
                           error_o       <= read_data(0);

        when READ_DONE =>  slave_clk_o   <= '0';            -- smbclk is low (glitches on smbdat are ok) after read
                           done_o        <= '1';

        when others => null;
      end case;
   end process stateOut;

end rtl;



library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity smb_test is
port(clk_i : in std_logic;
     nrst_i : in std_logic;

     smbclk_o : out std_logic;
     smbdat_io : inout std_logic;

     testclk_o : out std_logic;

     ones_o : out std_logic_vector(6 downto 0);
     tens_o : out std_logic_vector(6 downto 0);
     leds_o : out std_logic_vector(7 downto 0));
end smb_test;

architecture rtl of smb_test is

--------------------------------------------------------------------------------------
-- NOTE: The following constants must be adjusted if the clock frequency changes!
--
-- END_CONDITION_LENGTH = 8.7 us
-- START_SETUP_DELAY = 4.7 us
-- STOP_SETUP_DELAY = 4 us
-- BIT_PERIOD_LENGTH = 100 us
-- DATA_VALID_BEGIN = 40 us       -- smbdat valid 40 us after start of bit period
-- DATA_VALID_END = 90 us         -- smbdat invalid 90 us after start of bit period
-- READ_DATA_SAMPLE = 65 us
--------------------------------------------------------------------------------------
--
--constant END_CONDITION_LENGTH : integer := 435; 
--constant START_SETUP_DELAY    : integer := 235;
--constant STOP_SETUP_DELAY     : integer := 200;
--constant BIT_PERIOD_LENGTH    : integer := 5000;
--constant DATA_VALID_BEGIN     : integer := 2000;
--constant DATA_VALID_END       : integer := 4500;
--constant READ_DATA_SAMPLE     : integer := 3250;
--
--component shift_reg
--generic(WIDTH : in integer range 2 to 512 := 8);
--port(clk_i      : in std_logic;
--     rst_i      : in std_logic;
--     ena_i      : in std_logic;
--     load_i     : in std_logic;
--     clr_i      : in std_logic;
--     shr_i      : in std_logic;
--     serial_i   : in std_logic;
--     serial_o   : out std_logic;
--     parallel_i : in std_logic_vector(WIDTH-1 downto 0);
--     parallel_o : out std_logic_vector(WIDTH-1 downto 0));
--end component;
--
--component binary_counter
--generic(WIDTH : integer range 2 to 64 := 8);
--port(clk_i   : in std_logic;
--    rst_i   : in std_logic;
--     ena_i   : in std_logic;
--     up_i    : in std_logic;
--     load_i  : in std_logic;
--     clear_i : in std_logic;
--     count_i : in std_logic_vector(WIDTH-1 downto 0);
--     count_o : out std_logic_vector(WIDTH-1 downto 0));
--end component;

component clkgen
port(inclk0 : in std_logic;
     c0     : out std_logic;
     e0	    : out std_logic);
end component;

component decoder
port(input_i : in std_logic_vector(6 downto 0);
     ones_o : out std_logic_vector(6 downto 0);
     tens_o : out std_logic_vector(6 downto 0));
end component;

component smb_master
port(clk_i         : in std_logic;
     rst_i         : in std_logic;
     master_data_i : in std_logic_vector(7 downto 0);
     master_data_o : out std_logic_vector(7 downto 0);
     start_i       : in std_logic;
     stop_i        : in std_logic;
     write_i       : in std_logic;
     read_i        : in std_logic;
     done_o        : out std_logic;
     error_o       : out std_logic;
     slave_clk_o   : out std_logic;   
     slave_data_io : inout std_logic);
end component;

type states is (IDLE, SEND_START, WRITE_ADDR, READ_TEMP, SEND_STOP, CYCLE_DONE);
signal pres_state : states;
signal next_state : states;

--constant TIMER_WIDTH : integer := 14;   -- 2**TIMER_WIDTH must be greater than largest constant above!

signal clk : std_logic;
signal test_clk : std_logic;
signal rst : std_logic;

--signal write_data : std_logic;
--
--signal read_reg_ena : std_logic;
--signal read_data    : std_logic_vector(7 downto 0);
--
--signal bit_count_ena : std_logic;
--signal bit_count_clr : std_logic;
--signal bit_count     : std_logic_vector(3 downto 0);
--
--signal timer_clr : std_logic;
--signal timer     : std_logic_vector(TIMER_WIDTH-1 downto 0);
--
--signal smbclk : std_logic;
--signal smbdat : std_logic;
--signal smbclk_out : std_logic;
--signal smbdat_out : std_logic;

signal output_data : std_logic_vector(7 downto 0);
signal output_ld : std_logic;

signal data_in : std_logic_vector(7 downto 0);
signal data_out : std_logic_vector(7 downto 0);
signal start : std_logic;
signal stop : std_logic;
signal write : std_logic;
signal read : std_logic;
signal done : std_logic;
signal err : std_logic;

begin

   -- clock & reset generation
--   clkgen0 : clkgen
--   port map(inclk0 => clk_i,
--            c0 => clk,          -- 50 MHz
--            e0 => testclk_o);   -- 1 MHz

   rst <= not nrst_i;
   clk <= clk_i;

   -- output to 7-segment display decoder and leds
   out_decode : decoder
   port map(input_i => output_data(6 downto 0),
            ones_o  => ones_o,
            tens_o  => tens_o);

   leds_o <= output_data;

   smb0 : component smb_master
   port map(clk_i         => clk,
            rst_i         => rst,
            master_data_i => data_in,
            master_data_o => data_out,
            start_i       => start,
            stop_i        => stop,
            write_i       => write,
            read_i        => read,
            done_o        => done,
            error_o       => err,
            slave_clk_o   => smbclk_o,
            slave_data_io => smbdat_io);

   process(clk, rst)
   begin
      if(rst = '1') then
         output_data <= (others => '0');
      elsif(clk'event and clk = '1') then
         if(output_ld = '1') then
            output_data <= data_out;
         end if;
      end if;
   end process;


   process(clk, rst)
   begin
      if(rst = '1') then
         pres_state <= IDLE;
      elsif(clk'event and clk = '1') then
         pres_state <= next_state;
      end if;
   end process;

   process(pres_state, done)
   begin
      case pres_state is
         when IDLE =>       next_state <= SEND_START;

         when SEND_START => if(done = '1') then
                               next_state <= WRITE_ADDR;
                            else
                               next_state <= SEND_START;
                            end if;

         when WRITE_ADDR => if(done = '1') then
                               next_state <= READ_TEMP;
                            else
                               next_state <= WRITE_ADDR;
                            end if;

         when READ_TEMP =>  if(done = '1') then
                               next_state <= SEND_STOP;
                            else
                               next_state <= READ_TEMP;
                            end if;

         when SEND_STOP =>  if(done = '1') then
                               next_state <= CYCLE_DONE;
                            else
                               next_state <= SEND_STOP;
                            end if;

         when CYCLE_DONE => next_state <= IDLE;

         when others =>     next_state <= IDLE;
      end case;
   end process;

   process(pres_state, done)
   begin
      start <= '0';
      stop <= '0';
      write <= '0';
      read <= '0';
      data_in <= (others => '0');
      output_ld <= '0';

      case pres_state is
         when IDLE =>       null;

         when SEND_START => start <= '1';

         when WRITE_ADDR => write <= '1';
                            data_in <= "00110001";

         when READ_TEMP =>  read <= '1';
                            if(done = '1') then
                               output_ld <= '1';
                            end if;

         when SEND_STOP =>  stop <= '1';

         when CYCLE_DONE => null;

         when others =>     null;
      end case;
   end process;

-----------------------------------------------------------
-- FUNCTIONALITY MOVED TO SMB_MASTER 
-----------------------------------------------------------   
--   -- timer & bit counter
--   bit_counter : binary_counter
--   generic map(WIDTH => 4)
--   port map(clk_i   => clk,
--            rst_i   => rst,
--            ena_i   => bit_count_ena,
--            up_i    => '1',
--            load_i  => '0',
--            clear_i => bit_count_clr,
--            count_i => (others => '0'),
--            count_o => bit_count);
--     
--   timer_counter : binary_counter
--   generic map(WIDTH => TIMER_WIDTH)
--   port map(clk_i   => clk,
--            rst_i   => rst,
--            ena_i   => '1',
--            up_i    => '1',
--            load_i  => '0',
--            clear_i => timer_clr,
--            count_i => (others => '0'),
--            count_o => timer);
--
--   -- read data
--   rx_data_reg : shift_reg
--   generic map(WIDTH => 8)
--   port map(clk_i      => clk,
--            rst_i      => rst,
--            ena_i      => read_reg_ena,
--            load_i     => '0',
--            clr_i      => '0',
--            shr_i      => '0',
--            serial_i   => smbdat_io,
--            serial_o   => open,
--            parallel_i => (others => '0'),
--            parallel_o => read_data); 
--
--   -- write data
--   with bit_count select
--      write_data <= '0' when "0000",   -- address bit 0
--                    '0' when "0001",   -- address bit 1
--                    '1' when "0010",   -- address bit 2
--                    '1' when "0011",   -- address bit 3
--                    '0' when "0100",   -- address bit 4
--                    '0' when "0101",   -- address bit 5
--                    '0' when "0110",   -- address bit 6
--                    '1' when "0111",   -- read command
--                    'Z' when others; 
--
--   -- SMBus state machine
--   process(clk, rst)
--   begin
--      if(rst = '1') then
--         pres_state <= IDLE;
--      elsif(clk'event and clk = '1') then
--         pres_state <= next_state;
--      end if;
--   end process;
--
--   process(pres_state, timer, bit_count)
--   begin
--      case pres_state is
--         when IDLE =>       next_state <= START;
--
--         when START =>      if(timer = END_CONDITION_LENGTH) then
--                               next_state <= WRITE_ADDR;
--                            else
--                               next_state <= START;
--                            end if;
--
--         when WRITE_ADDR => if(timer = BIT_PERIOD_LENGTH and bit_count = 8) then
--                               next_state <= READ_TEMP;
--                            else
--                               next_state <= WRITE_ADDR;
--                            end if;
--
--         when READ_TEMP =>  if(timer = BIT_PERIOD_LENGTH and bit_count = 8) then
--                               next_state <= STOP;
--                            else
--                               next_state <= READ_TEMP;
--                            end if;
--
--         when STOP =>       if(timer = END_CONDITION_LENGTH) then
--                               next_state <= DONE;
--                            else
--                               next_state <= STOP;
--                            end if;
--
--         when DONE =>       next_state <= IDLE;
--
--         when others =>     next_state <= IDLE;
--      end case;
--   end process;
--
--   process(pres_state, timer, bit_count, write_data)
--   begin
--      smbclk_o <= 'Z';         -- idle state of SMBus is high; using bus pull-ups
--      smbdat_io <= 'Z';
--
--      read_reg_ena  <= '0';
--
--      bit_count_ena <= '0';
--      bit_count_clr <= '0';
--
--      timer_clr     <= '0';
--
--      output_ld <= '0';
--
--      case pres_state is
--         when IDLE =>       bit_count_clr <= '1';
--                            timer_clr     <= '1';
--
--         when START =>      if(timer > START_SETUP_DELAY) then 
--                               smbdat_io <= '0';
--                            end if;
--
--         when WRITE_ADDR => if(timer < DATA_VALID_BEGIN or timer > DATA_VALID_END) then
--                               smbclk_o   <= '0';
--                            end if;
--
--                            if((bit_count < 8 and write_data = '0')) then
--                               smbdat_io  <= '0';
--                            end if;
--
--                            if(bit_count = 8 and timer = READ_DATA_SAMPLE) then
--                               read_reg_ena <= '1';
--                            end if;
-- 
--                            if(timer = BIT_PERIOD_LENGTH) then
--                               if(bit_count = 8) then
--                                  bit_count_clr <= '1';
--                               else
--                                  bit_count_ena <= '1';
--                               end if;
--                               timer_clr     <= '1';
--                            end if;
--
--         when READ_TEMP =>  if(timer < DATA_VALID_BEGIN or timer > DATA_VALID_END) then
--                               smbclk_o   <= '0';
--                            end if;
--
--                            if(bit_count < 8 and timer = READ_DATA_SAMPLE) then
--                               read_reg_ena  <= '1';
--                            end if;
-- 
--                            if(timer = BIT_PERIOD_LENGTH) then
--                               if(bit_count = 8) then
--                                  bit_count_clr <= '1';
--                               else
--                                  bit_count_ena <= '1';
--                               end if;
--                               timer_clr     <= '1';
--                            end if;
--
--         when STOP =>       if(timer < STOP_SETUP_DELAY) then 
--                               smbdat_io <= '0'; 
--                            end if;
--
--         when DONE =>       output_ld <= '1';
--
--         when others =>     null;
--      end case;
--   end process;

end rtl;