library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.cmd_queue_pack.all;
use work.cmd_queue_ram40_pack.all;


ENTITY cmd_queue_ram40_test IS
   PORT
   (
      data     : IN STD_LOGIC_VECTOR (QUEUE_WIDTH-1 DOWNTO 0);
      wraddress      : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
      rdaddress_a    : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
      rdaddress_b    : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
      wren     : IN STD_LOGIC  := '1';
      clock    : IN STD_LOGIC ;
      qa    : OUT STD_LOGIC_VECTOR (QUEUE_WIDTH-1 DOWNTO 0);
      qb    : OUT STD_LOGIC_VECTOR (QUEUE_WIDTH-1 DOWNTO 0)
   );
END cmd_queue_ram40_test;


ARCHITECTURE SYN OF cmd_queue_ram40_test IS
   signal wraddress_int : integer := 0;
   signal rdaddress_a_int : integer := 0;
   signal rdaddress_b_int : integer := 0;
   signal qa_sig  : std_logic_vector(QUEUE_WIDTH-1 downto 0);
   signal qb_sig  : std_logic_vector(QUEUE_WIDTH-1 downto 0);
   signal ram_dat : ram40;

BEGIN
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
END SYN;

--   registr: process(clk_i, rst_i)
--   begin
--      if(rst_i = '1') then
--         reg_o <= (others => '0');
--      elsif(clk_i'event and clk_i = '1') then
--         if(ena_i = '1') then
--            reg_o <= reg_i;
--         end if;
--      end if;
--   end process registr;
