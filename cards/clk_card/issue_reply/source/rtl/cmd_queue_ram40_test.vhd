library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library sys_param;
use sys_param.command_pack.all;

library work;
use work.cmd_queue_pack.all;
use work.cmd_queue_ram40_pack.all;


entity cmd_queue_ram40_test is
   port
   (
      data     : in STD_LOGIC_VECTOR (QUEUE_WIDTH-1 downto 0);
      wraddress      : in STD_LOGIC_VECTOR (QUEUE_ADDR_WIDTH-1 downto 0);
      rdaddress_a    : in STD_LOGIC_VECTOR (QUEUE_ADDR_WIDTH-1 downto 0);
      rdaddress_b    : in STD_LOGIC_VECTOR (QUEUE_ADDR_WIDTH-1 downto 0);
      wren     : in STD_LOGIC  := '1';
      clock    : in STD_LOGIC ;
      qa    : out STD_LOGIC_VECTOR (QUEUE_WIDTH-1 downto 0);
      qb    : out STD_LOGIC_VECTOR (QUEUE_WIDTH-1 downto 0)
   );
end cmd_queue_ram40_test;

architecture SYN of cmd_queue_ram40_test is
   signal wraddress_int : integer := 0;
   signal rdaddress_a_int : integer := 0;
   signal rdaddress_b_int : integer := 0;
   signal qa_sig  : std_logic_vector(QUEUE_WIDTH-1 downto 0);
   signal qb_sig  : std_logic_vector(QUEUE_WIDTH-1 downto 0);
   signal ram_dat : ram40;

begin
   wraddress_int   <= conv_integer(wraddress);
   rdaddress_a_int <= conv_integer(rdaddress_a);
   rdaddress_b_int <= conv_integer(rdaddress_b);
   qa_sig          <= ram_dat(rdaddress_a_int);
   qb_sig          <= ram_dat(rdaddress_b_int);
   qa              <= qa_sig;
   qb              <= qb_sig;

   data_in: process(clock)
   begin
      if(clock'event and clock = '1') then
         if(wren = '1') then
            ram_dat(wraddress_int) <= data;
         end if;
      end if;
   end process data_in;

end SYN;