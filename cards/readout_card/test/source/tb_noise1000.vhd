-- Filename          : tb_tmp.vhd
-- Modelname         : TB_RC_NOISE1000_TEST
-- Title             :
-- Purpose           :
-- Author(s)         : neuf
-- Comment           :
-- Assumptions       :
-- Limitations       :
-- Known errors      :
-- Specification ref :
-- ------------------------------------------------------------------------
-- Modification history:
-- ------------------------------------------------------------------------
-- Version  | Author | Date       | Changes made
-- ------------------------------------------------------------------------
-- 1.0      | neuf | 23.07.2004 | inital version


library IEEE;
use IEEE.std_logic_1164.all;

entity TB_RC_NOISE1000_TEST is
end TB_RC_NOISE1000_TEST;

architecture BEH of TB_RC_NOISE1000_TEST is

   component RC_NOISE1000_TEST
      port(N_RST            : in std_logic ;
           INCLK            : in std_logic ;
           OUTCLK           : out std_logic ;
           DAC_DAT          : out std_logic_vector ( 7 downto 0 );
           DAC_CLK          : out std_logic_vector ( 7 downto 0 );
           BIAS_DAC_NCS     : out std_logic_vector ( 7 downto 0 );
           OFFSET_DAC_NCS   : out std_logic_vector ( 7 downto 0 );
           DAC_FB1_DAT      : out std_logic_vector ( 13 downto 0 );
           DAC_FB2_DAT      : out std_logic_vector ( 13 downto 0 );
           DAC_FB3_DAT      : out std_logic_vector ( 13 downto 0 );
           DAC_FB4_DAT      : out std_logic_vector ( 13 downto 0 );
           DAC_FB5_DAT      : out std_logic_vector ( 13 downto 0 );
           DAC_FB6_DAT      : out std_logic_vector ( 13 downto 0 );
           DAC_FB7_DAT      : out std_logic_vector ( 13 downto 0 );
           DAC_FB8_DAT      : out std_logic_vector ( 13 downto 0 );
           DAC_FB_CLK       : out std_logic_vector ( 7 downto 0 );
           ADC1_CLK         : out std_logic ;
           ADC1_RDY         : in std_logic ;
           ADC1_OVR         : in std_logic ;
           ADC1_DAT         : in std_logic_vector ( 13 downto 0 );
           ADC2_CLK         : out std_logic ;
           ADC2_RDY         : in std_logic ;
           ADC2_OVR         : in std_logic ;
           ADC2_DAT         : in std_logic_vector ( 13 downto 0 );
           ADC3_CLK         : out std_logic ;
           ADC3_RDY         : in std_logic ;
           ADC3_OVR         : in std_logic ;
           ADC3_DAT         : in std_logic_vector ( 13 downto 0 );
           ADC4_CLK         : out std_logic ;
           ADC4_RDY         : in std_logic ;
           ADC4_OVR         : in std_logic ;
           ADC4_DAT         : in std_logic_vector ( 13 downto 0 );
           ADC5_CLK         : out std_logic ;
           ADC5_RDY         : in std_logic ;
           ADC5_OVR         : in std_logic ;
           ADC5_DAT         : in std_logic_vector ( 13 downto 0 );
           ADC6_CLK         : out std_logic ;
           ADC6_RDY         : in std_logic ;
           ADC6_OVR         : in std_logic ;
           ADC6_DAT         : in std_logic_vector ( 13 downto 0 );
           ADC7_CLK         : out std_logic ;
           ADC7_RDY         : in std_logic ;
           ADC7_OVR         : in std_logic ;
           ADC7_DAT         : in std_logic_vector ( 13 downto 0 );
           ADC8_CLK         : out std_logic ;
           ADC8_RDY         : in std_logic ;
           ADC8_OVR         : in std_logic ;
           ADC8_DAT         : in std_logic_vector ( 13 downto 0 );
           SMB_CLK          : out std_logic ;
           MICTOR           : out std_logic_vector ( 31 downto 0 ) );

   end component;


   constant PERIOD : time := 10 ns;

   signal W_N_RST            : std_logic ;
   signal W_INCLK            : std_logic := '0';
   signal W_OUTCLK           : std_logic ;
   signal W_DAC_DAT          : std_logic_vector ( 7 downto 0 );
   signal W_DAC_CLK          : std_logic_vector ( 7 downto 0 );
   signal W_BIAS_DAC_NCS     : std_logic_vector ( 7 downto 0 );
   signal W_OFFSET_DAC_NCS   : std_logic_vector ( 7 downto 0 );
   signal W_DAC_FB1_DAT      : std_logic_vector ( 13 downto 0 );
   signal W_DAC_FB2_DAT      : std_logic_vector ( 13 downto 0 );
   signal W_DAC_FB3_DAT      : std_logic_vector ( 13 downto 0 );
   signal W_DAC_FB4_DAT      : std_logic_vector ( 13 downto 0 );
   signal W_DAC_FB5_DAT      : std_logic_vector ( 13 downto 0 );
   signal W_DAC_FB6_DAT      : std_logic_vector ( 13 downto 0 );
   signal W_DAC_FB7_DAT      : std_logic_vector ( 13 downto 0 );
   signal W_DAC_FB8_DAT      : std_logic_vector ( 13 downto 0 );
   signal W_DAC_FB_CLK       : std_logic_vector ( 7 downto 0 );
   signal W_ADC1_CLK         : std_logic ;
   signal W_ADC1_RDY         : std_logic ;
   signal W_ADC1_OVR         : std_logic ;
   signal W_ADC1_DAT         : std_logic_vector ( 13 downto 0 );
   signal W_ADC2_CLK         : std_logic ;
   signal W_ADC2_RDY         : std_logic ;
   signal W_ADC2_OVR         : std_logic ;
   signal W_ADC2_DAT         : std_logic_vector ( 13 downto 0 );
   signal W_ADC3_CLK         : std_logic ;
   signal W_ADC3_RDY         : std_logic ;
   signal W_ADC3_OVR         : std_logic ;
   signal W_ADC3_DAT         : std_logic_vector ( 13 downto 0 );
   signal W_ADC4_CLK         : std_logic ;
   signal W_ADC4_RDY         : std_logic ;
   signal W_ADC4_OVR         : std_logic ;
   signal W_ADC4_DAT         : std_logic_vector ( 13 downto 0 );
   signal W_ADC5_CLK         : std_logic ;
   signal W_ADC5_RDY         : std_logic ;
   signal W_ADC5_OVR         : std_logic ;
   signal W_ADC5_DAT         : std_logic_vector ( 13 downto 0 );
   signal W_ADC6_CLK         : std_logic ;
   signal W_ADC6_RDY         : std_logic ;
   signal W_ADC6_OVR         : std_logic ;
   signal W_ADC6_DAT         : std_logic_vector ( 13 downto 0 );
   signal W_ADC7_CLK         : std_logic ;
   signal W_ADC7_RDY         : std_logic ;
   signal W_ADC7_OVR         : std_logic ;
   signal W_ADC7_DAT         : std_logic_vector ( 13 downto 0 );
   signal W_ADC8_CLK         : std_logic ;
   signal W_ADC8_RDY         : std_logic ;
   signal W_ADC8_OVR         : std_logic ;
   signal W_ADC8_DAT         : std_logic_vector ( 13 downto 0 );
   signal W_SMB_CLK          : std_logic ;
   signal W_MICTOR           : std_logic_vector ( 31 downto 0 ) ;

begin

   DUT : RC_NOISE1000_TEST
      port map(N_RST            => W_N_RST,
               INCLK            => W_INCLK,
               OUTCLK           => W_OUTCLK,
               DAC_DAT          => W_DAC_DAT,
               DAC_CLK          => W_DAC_CLK,
               BIAS_DAC_NCS     => W_BIAS_DAC_NCS,
               OFFSET_DAC_NCS   => W_OFFSET_DAC_NCS,
               DAC_FB1_DAT      => W_DAC_FB1_DAT,
               DAC_FB2_DAT      => W_DAC_FB2_DAT,
               DAC_FB3_DAT      => W_DAC_FB3_DAT,
               DAC_FB4_DAT      => W_DAC_FB4_DAT,
               DAC_FB5_DAT      => W_DAC_FB5_DAT,
               DAC_FB6_DAT      => W_DAC_FB6_DAT,
               DAC_FB7_DAT      => W_DAC_FB7_DAT,
               DAC_FB8_DAT      => W_DAC_FB8_DAT,
               DAC_FB_CLK       => W_DAC_FB_CLK,
               ADC1_CLK         => W_ADC1_CLK,
               ADC1_RDY         => W_ADC1_RDY,
               ADC1_OVR         => W_ADC1_OVR,
               ADC1_DAT         => W_ADC1_DAT,
               ADC2_CLK         => W_ADC2_CLK,
               ADC2_RDY         => W_ADC2_RDY,
               ADC2_OVR         => W_ADC2_OVR,
               ADC2_DAT         => W_ADC2_DAT,
               ADC3_CLK         => W_ADC3_CLK,
               ADC3_RDY         => W_ADC3_RDY,
               ADC3_OVR         => W_ADC3_OVR,
               ADC3_DAT         => W_ADC3_DAT,
               ADC4_CLK         => W_ADC4_CLK,
               ADC4_RDY         => W_ADC4_RDY,
               ADC4_OVR         => W_ADC4_OVR,
               ADC4_DAT         => W_ADC4_DAT,
               ADC5_CLK         => W_ADC5_CLK,
               ADC5_RDY         => W_ADC5_RDY,
               ADC5_OVR         => W_ADC5_OVR,
               ADC5_DAT         => W_ADC5_DAT,
               ADC6_CLK         => W_ADC6_CLK,
               ADC6_RDY         => W_ADC6_RDY,
               ADC6_OVR         => W_ADC6_OVR,
               ADC6_DAT         => W_ADC6_DAT,
               ADC7_CLK         => W_ADC7_CLK,
               ADC7_RDY         => W_ADC7_RDY,
               ADC7_OVR         => W_ADC7_OVR,
               ADC7_DAT         => W_ADC7_DAT,
               ADC8_CLK         => W_ADC8_CLK,
               ADC8_RDY         => W_ADC8_RDY,
               ADC8_OVR         => W_ADC8_OVR,
               ADC8_DAT         => W_ADC8_DAT,
               SMB_CLK          => W_SMB_CLK,
               MICTOR           => W_MICTOR);

   W_INCLK <= not W_INCLK after PERIOD/2;
   STIMULI : process
   
   procedure do_reset is
   begin
      W_N_RST        <= '1';
      
      wait for PERIOD*3;
      
      W_N_RST        <= '0';
        
      wait for PERIOD;        
      assert false report " Performing a RESET." severity NOTE;
   end do_reset ;

   begin
      W_N_RST            <= '0';
--      W_INCLK            <= '0';
      W_ADC1_RDY         <= '1';
      W_ADC1_OVR         <= '0';
      W_ADC1_DAT         <= "00100000000000";
      W_ADC2_RDY         <= '0';
      W_ADC2_OVR         <= '0';
      W_ADC2_DAT         <= (others => '0');
      W_ADC3_RDY         <= '0';
      W_ADC3_OVR         <= '0';
      W_ADC3_DAT         <= (others => '0');
      W_ADC4_RDY         <= '0';
      W_ADC4_OVR         <= '0';
      W_ADC4_DAT         <= "00100000000000";
      W_ADC5_RDY         <= '0';
      W_ADC5_OVR         <= '0';
      W_ADC5_DAT         <= (others => '0');
      W_ADC6_RDY         <= '0';
      W_ADC6_OVR         <= '0';
      W_ADC6_DAT         <= (others => '0');
      W_ADC7_RDY         <= '0';
      W_ADC7_OVR         <= '0';
      W_ADC7_DAT         <= (others => '0');
      W_ADC8_RDY         <= '0';
      W_ADC8_OVR         <= '0';
      W_ADC8_DAT         <= (others => '0');

      wait for PERIOD;
      do_reset;
      W_ADC1_RDY <= '1';
      wait for PERIOD;
      W_ADC1_DAT <= "00000000000001";
      W_ADC1_RDY <= '1';
      wait for PERIOD;
      W_ADC1_RDY <= '0';
      wait for PERIOD;
      W_ADC1_DAT <= "10000000000000";
      W_ADC1_RDY <= '1';
      wait for PERIOD;
      W_ADC1_RDY <= '0';
      wait for PERIOD;
      W_ADC1_DAT <= "00000000011100";
      W_ADC1_RDY <= '1';
      wait for PERIOD;
      W_ADC1_RDY <= '0';
      wait for PERIOD;
      W_ADC1_DAT <= "00000010000000";
      W_ADC1_RDY <= '1';
      wait for PERIOD;
      W_ADC1_RDY <= '0';
      wait for PERIOD;
      W_ADC1_DAT <= "00000000000000";
      W_ADC1_RDY <= '1';
      wait for PERIOD;
      
      wait;
   end process STIMULI;

end BEH;

configuration CFG_TB_RC_NOISE1000_TEST of TB_RC_NOISE1000_TEST is
   for BEH
   end for;
end CFG_TB_RC_NOISE1000_TEST;