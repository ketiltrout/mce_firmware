
library IEEE;
use IEEE.std_logic_1164.all;

library sys_param;
use sys_param.wishbone_pack.all;
use sys_param.general_pack.all;

library work;
use work.dip_switch_pack.all;

entity TB_DIP_SWITCH is
end TB_DIP_SWITCH;

architecture BEH of TB_DIP_SWITCH is

   component DIP_SWITCH
      port(DIP_SWITCH_I   : in std_logic_vector ( DIP_SWITCH_BITS - 1 downto 0 );
           CLK_I          : in std_logic ;
           RST_I          : in std_logic ;
           DAT_I          : in std_logic_vector ( WB_DATA_WIDTH - 1 downto 0 );
           ADDR_I         : in std_logic_vector ( WB_ADDR_WIDTH - 1 downto 0 );
           WE_I           : in std_logic ;
           STB_I          : in std_logic ;
           CYC_I          : in std_logic ;
           DAT_O          : out std_logic_vector ( WB_DATA_WIDTH - 1 downto 0 );
           ACK_O          : out std_logic );

   end component;


--   constant PERIOD : time :=  20 ns;

   signal W_DIP_SWITCH_I   : std_logic_vector ( DIP_SWITCH_BITS - 1 downto 0 ) := "11100010";
   signal W_CLK_I          : std_logic := '0';
   signal W_RST_I          : std_logic ;
   signal W_DAT_I          : std_logic_vector ( WB_DATA_WIDTH - 1 downto 0 );
   signal W_ADDR_I         : std_logic_vector ( WB_ADDR_WIDTH - 1 downto 0 );
   signal W_WE_I           : std_logic ;
   signal W_STB_I          : std_logic ;
   signal W_CYC_I          : std_logic ;
   signal W_DAT_O          : std_logic_vector ( WB_DATA_WIDTH - 1 downto 0 );
   signal W_ACK_O          : std_logic ;

begin

   DUT : DIP_SWITCH
      port map(DIP_SWITCH_I   => W_DIP_SWITCH_I,
               CLK_I          => W_CLK_I,
               RST_I          => W_RST_I,
               DAT_I          => W_DAT_I,
               ADDR_I         => W_ADDR_I,
               WE_I           => W_WE_I,
               STB_I          => W_STB_I,
               CYC_I          => W_CYC_I,
               DAT_O          => W_DAT_O,
               ACK_O          => W_ACK_O);

   W_CLK_I <= not W_CLK_I after CLOCK_PERIOD/2;

   STIMULI : process
      procedure do_reset is
      begin
         W_RST_I       <= '1';
         W_DAT_I       <= (others => '0');
         W_ADDR_I      <= (others => '0');
         W_WE_I        <= '0';
         W_STB_I       <= '0';
         W_CYC_I       <= '0';
               
         wait for CLOCK_PERIOD*3;
         assert false report "Performing System Reset." severity NOTE;
      end do_reset;
   
      procedure do_read is
      begin
         W_RST_I       <= '0';
         W_DAT_I       <= (others => '0');
         W_ADDR_I      <= "01001100";
         W_WE_I        <= '0';
         W_STB_I       <= '1';
         W_CYC_I       <= '1';
               
         wait for CLOCK_PERIOD;
         
         W_RST_I       <= '0';
         W_DAT_I       <= (others => '0');
         W_ADDR_I      <= (others => '0');
         W_WE_I        <= '0';
         W_STB_I       <= '0';
         W_CYC_I       <= '0';
               
         wait for CLOCK_PERIOD;
         
         assert false report "Performing Wishbone Read." severity NOTE;
      end do_read;   
      
      procedure do_nop is
      begin
         W_RST_I       <= '0';
         W_DAT_I       <= (others => '0');
         W_ADDR_I      <= (others => '0');
         W_WE_I        <= '0';
         W_STB_I       <= '0';
         W_CYC_I       <= '0';
               
         wait for CLOCK_PERIOD;
         assert false report "Performing No Operation." severity NOTE;
      end do_nop;
      
   begin
   
   do_reset;
   do_nop;
   do_read;
   do_nop;
   do_nop;
   
--      W_DIP_SWITCH_I   <= (others => '0');
--      W_RST_I          <= '0';
--      W_DAT_I          <= (others => '0');
--      W_ADDR_I         <= (others => '0');
--      W_WE_I           <= '0';
--      W_STB_I          <= '0';
--      W_CYC_I          <= '0';

      wait for CLOCK_PERIOD;
      wait;
   end process STIMULI;

end BEH;
