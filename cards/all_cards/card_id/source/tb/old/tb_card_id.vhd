
library IEEE;
use IEEE.std_logic_1164.all;

entity TB_CARD_ID is
end TB_CARD_ID;

architecture BEH of TB_CARD_ID is

   component CARD_ID
      port(CLK            : in std_logic ;
           RST            : in std_logic ;
           ID_DATA_BI     : inout std_logic ;
           START_I        : in std_logic ;
           DONE_O         : out std_logic ;
           INIT_DONE_O    : out std_logic;
           WRITE_DONE_O   : out std_logic;
           SERIAL_NUM_O   : out std_logic_vector ( 63 downto 0 );
           CRC_VALID_O        : out std_logic;
           CRC_VALUE_O    : out std_logic_vector(7 downto 0) );

   end component;


   constant PERIOD : time := 20 ns;

   signal W_CLK            : std_logic  := '0';
   signal W_RST            : std_logic ;
   signal W_ID_DATA_BI     : std_logic ;
   signal W_START_I        : std_logic ;
   signal W_DONE_O         : std_logic ;
   signal W_INIT_DONE_O    : std_logic;
   signal W_WRITE_DONE_O   : std_logic;
   signal W_SERIAL_NUM_O   : std_logic_vector ( 63 downto 0 ) ;
   signal W_VALID_O        : std_logic;
   signal W_VALUE_O        : std_logic_vector(7 downto 0);
   
   signal lfsr_fb  : std_logic;
   signal lfsr_reg : std_logic_vector(1 to 63);
   
begin

   DUT : CARD_ID
      port map(CLK            => W_CLK,
               RST            => W_RST,
               ID_DATA_BI     => W_ID_DATA_BI,
               START_I        => W_START_I,
               DONE_O         => W_DONE_O,
               INIT_DONE_O    => W_INIT_DONE_O,
               WRITE_DONE_O   => W_WRITE_DONE_O,
               SERIAL_NUM_O   => W_SERIAL_NUM_O,
               CRC_VALID_O        => W_VALID_O,
               CRC_VALUE_O        => W_VALUE_O);

   W_CLK <= not W_CLK after PERIOD/2;

   lfsr_fb <= not(lfsr_reg(63) xor lfsr_reg(62));

   lfsr: process(W_CLK, W_RST)
   begin
      if(W_RST = '1') then
         lfsr_reg <= "000000000000000000000000000000000000000000000000000000000000000";
      elsif(W_CLK'event and W_CLK = '1') then
         lfsr_reg <= lfsr_fb & lfsr_reg(1 to 62);
      end if;
   end process lfsr;

   STIMULI : process
   
      procedure do_reset is
      begin
         W_RST        <= '1';
         W_START_I    <= '0';
         W_ID_DATA_BI <= 'H';
                  
         wait for PERIOD;
      end do_reset;
   
      procedure do_start is
      begin
         W_RST        <= '0';
         W_START_I    <= '1';
         W_ID_DATA_BI <= 'H';
                  
         wait for PERIOD;
      end do_start;
   
      procedure do_reset_pulse is
      begin
         W_RST        <= '0';
         W_START_I    <= '0';
         W_ID_DATA_BI <= 'H';
      end do_reset_pulse;
   
      procedure do_presence_pulse is
      begin
         wait until W_ID_DATA_BI = 'H';
         wait for 60 us;
         
         W_ID_DATA_BI <= '0';
                  
         wait for 240 us;
         
         W_ID_DATA_BI <= 'H';
         
      end do_presence_pulse;
   
      procedure do_write_bit is
      begin
         wait until W_ID_DATA_BI = '0';
         wait until W_ID_DATA_BI = 'H';
      end do_write_bit;
   
      procedure do_read_0 is
      begin
         wait until W_ID_DATA_BI = '0';
         W_ID_DATA_BI <= '0';
         wait for 30 us;
         W_ID_DATA_BI <= 'H';
      end do_read_0;
   
      procedure do_read_1 is
      begin
         wait until W_ID_DATA_BI = '0';
         W_ID_DATA_BI <= 'H';
      end do_read_1;
      
   begin
      
      do_reset;
      do_start;
      
      do_reset_pulse;
      do_presence_pulse;
      
      for i in 1 to 8 loop
         do_write_bit;
      end loop;
      
--      for i in 1 to 64 loop
--         if(lfsr_reg(1) = '1') then
--            do_read_1;
--         else
--            do_read_0;
--         end if;
--      end loop;
--
--      wait for 1 ms;
--      
--      assert false report "Simulation done." severity failure;
 
-- for data 0x00FF00FF0000FF88, the CRC byte is 0x88
-- byte 0 
      do_read_0;
      do_read_0;
      do_read_0;
      do_read_0;
      do_read_0;
      do_read_0;
      do_read_0;
      do_read_0;
-- byte 1      
      do_read_1;
      do_read_1;
      do_read_1;
      do_read_1;
      do_read_1;
      do_read_1;
      do_read_1;
      do_read_1;
-- byte 2      
      do_read_0;
      do_read_0;     
      do_read_0;
      do_read_0;
      do_read_0;
      do_read_0;
      do_read_0;
      do_read_0;
-- byte 3      
      do_read_1;
      do_read_1;
      do_read_1;
      do_read_1;
      do_read_1;
      do_read_1;
      do_read_1;
      do_read_1;
-- byte 4
      do_read_0;
      do_read_0;
      do_read_0;
      do_read_0;
      do_read_0;
      do_read_0;
      do_read_0;
      do_read_0;
-- byte 5      
      do_read_0;
      do_read_0;     
      do_read_0;
      do_read_0;
      do_read_0;
      do_read_0;
      do_read_0;
      do_read_0;
-- byte 6
      do_read_1;
      do_read_1;
      do_read_1;
      do_read_1;
      do_read_1;
      do_read_1;
      do_read_1;
      do_read_1;
-- byte 7 (CRC byte)
      do_read_0;
      do_read_0;
      do_read_0;
      do_read_1;
      do_read_0;
      do_read_0;
      do_read_0;
      do_read_1;
      
      wait for 1 ms;
      
      assert false report " Simulation done." severity FAILURE;
            
   end process STIMULI;

end BEH;

configuration CFG_TB_CARD_ID of TB_CARD_ID is
   for BEH
   end for;
end CFG_TB_CARD_ID;
