
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.fo_transceiver_pack.all;


entity tb_fo_transceiver is
end tb_fo_transceiver;



-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

LIBRARY work;
USE work.fo_transceiver_pack.all;


architecture bench of tb_fo_transceiver is 

   -- Internal signal declarations
 
   signal dut_rst      : std_logic                      := '0';
   signal tb_clk       : std_logic                      := '0';
   signal rx_data      : std_logic_vector (7 downto 0);
   signal nRx_rdy      : std_logic                      := '1';
   signal rvs          : std_logic                      := '0';  -- no violation
   signal rso          : std_logic                      := '1';  -- status OK
   signal rsc_nRd      : std_logic                      := '1';  -- start in idling mode
   signal nTrp         : std_logic                      := '0';
   signal ft_clkw      : std_logic                      := '0';  -- initialise clock
   signal tx_data      : std_logic_vector (7 downto 0);
   signal tsc_nTd      : std_logic                      := '0';  -- always return data
   signal nFena        : std_logic                      := '1';  -- disable tx data  
   
   -- constant tb_clk_prd : time                           := 10 ns;  -- 100 MHz FPGA clock
   constant tb_clk_prd : time                           := 20 ns;  -- 50 MHz FPGA clock
   constant ft_clk_prd : time                           := 40 ns;  -- 25 MHz clock for hotlink chipset
   constant preamble1  : std_logic_vector (7 downto 0)  := x"A5";
   constant preamble2  : std_logic_vector (7 downto 0)  := x"5A";
   
   constant command_wb : std_logic_vector (31 downto 0) := X"20205742";
   constant command_wm : std_logic_vector (31 downto 0) := X"2020574D";
   constant command_go : std_logic_vector (31 downto 0) := X"2020474F";
   constant check_err  : std_logic_vector(31 downto 0)  := X"12345678";
   
   constant data_block : positive := 58;

   constant data_word1 : std_logic_vector (31 downto 0) := X"00001234";
   constant data_word2 : std_logic_vector (31 downto 0) := X"00005678";
 
 
   signal   data       : integer                        := 0;
   signal   checksum   : std_logic_vector(31 downto 0)  := X"00000000";
   
   signal   command    : std_logic_vector(31 downto 0);
   signal   address    : std_logic_vector(31 downto 0);
   signal   data_valid : std_logic_vector(31 downto 0);
   
   signal   cmd_ack    : std_logic; 
        
begin

--------------------------------------------------
-- Instantiate DUT
-------------------------------------------------

   DUT :  fo_transceiver
   
   port map( 
      rst_i        => dut_rst,
      clk_i        => tb_clk,
      
      rx_data_i   => rx_data,
      nRx_rdy_i   => nRx_rdy,
      rvs_i       => rvs,
      rso_i       => rso,
      rsc_nRd_i   => rsc_nRd,  
      
      nTrp_i      => nTrp,
      ft_clkw_i   => ft_clkw, 
      
      cmd_ack_i   => cmd_ack,
      
      tx_data_o   => tx_data,      
      tsc_nTd_o   => tsc_nTd,
      nFena_o     => nFena
  
    );
    
 
--------------------------------------------------
-- Instantiate tx_hotlink_sim
-------------------------------------------------   
    
   HOTLINK : tx_hotlink_sim 
   port map( 
      ft_clkw_i   => ft_clkw,
      nFena_i     => nFena,
      tsc_nTd_i   => tsc_nTd,   
      tx_data_i   => tx_data,
      nTrp_o      => nTrp
   );



------------------------------------------------
-- create test bench clock and rx/tx clock
-------------------------------------------------
  
   tb_clk <= not tb_clk after tb_clk_prd/2;
   ft_clkw <= not ft_clkw after ft_clk_prd/2;
   
------------------------------------------------
-- Create test bench stimuli
-------------------------------------------------
   
   stimuli : process
  
------------------------------------------------
-- Stimulus procedures
-------------------------------------------------
   
   procedure do_reset is
   begin
      dut_rst <= '1';
      wait for tb_clk_prd*5 ;
      dut_rst <= '0';
      wait for tb_clk_prd*5 ;
      
      assert false report " Resetting the DUT." severity NOTE;
   end do_reset;
--------------------------------------------------

   procedure do_preamble is
   begin
        
     rsc_nRd    <= '0';  -- data     

     for I in 0 to 3  loop
         nRx_rdy   <= '1';         -- data not ready (active low)
         rx_data <= preamble1;
         wait for 10 ns;
       --  wait for 10 ns;
         nRx_rdy   <= '0';         -- data ready
         wait for 30 NS;
         
      --   wait for ft_clk_prd*(3/4);
      end loop;
     
     for I in 0 to 3  loop
         nRx_rdy   <= '1';         -- data not ready (active low)
         rx_data <= preamble2;
         wait for 10 ns ;
         nRx_rdy   <= '0';         -- data ready
         wait for 30 ns;
      end loop;
      
      nRx_rdy   <= '1';
      
      assert false report "preamble loaded" severity NOTE;
      
    end do_preamble;
----------------------------------------  
 
   procedure do_command is
   begin 
   
      -- load up command
 
      checksum <= command;
            
      nRx_rdy   <= '1';
      rx_data <= command(7 downto 0);
      wait for 10 ns;
      nRx_rdy   <= '0';
      wait for 30 ns;

      nRx_rdy   <= '1';
      rx_data <= command(15 downto 8);
      wait for 10 ns ;
      nRx_rdy   <= '0';
      wait for 30 ns ;

      nRx_rdy   <= '1';
      rx_data <= command(23 downto 16);
      wait for 10 ns;
      nRx_rdy   <= '0';
      wait for 30 ns;
                  
      nRx_rdy   <= '1';
      rx_data <= command(31 downto 24);
      wait for 10 ns;
      nRx_rdy   <= '0';
      wait for 30 ns ;
    
      assert false report "command code loaded" severity NOTE;
  
      -- load up address

      checksum <= checksum XOR address;
         
      nRx_rdy   <= '1';
      rx_data <= address(7 downto 0);
      wait for 10 ns;
      nRx_rdy   <= '0';
      wait for 30 ns;
  
      nRx_rdy   <= '1';
      rx_data <= address(15 downto 8);
      wait for 10 ns;
      nRx_rdy   <= '0';
      wait for 30 ns;

      nRx_rdy   <= '1';
      rx_data <= address(23 downto 16);
      wait for 10 ns;
      nRx_rdy   <= '0';
      wait for 30 ns;     
           
      nRx_rdy   <= '1';
      rx_data <= address(31 downto 24);
      wait for 10 ns;
      nRx_rdy   <= '0';
      wait for 30 ns;
      
      assert false report "address loaded" severity NOTE; 
      
      -- load up number of data valid
   
       
       checksum <= checksum XOR data_valid;
            
       nRx_rdy   <= '1';
       rx_data <= data_valid(7 downto 0);
       wait for 10 ns;
       nRx_rdy   <= '0';
       wait for 30 ns;   

       nRx_rdy   <= '1';   
       rx_data <= data_valid(15 downto 8);
       wait for 10 ns;
       nRx_rdy   <= '0';
       wait for 30 ns;

       nRx_rdy   <= '1';
       rx_data <= data_valid(23 downto 16);
       wait for 10 ns;
       nRx_rdy   <= '0';
       wait for 30 ns;
       
       nRx_rdy   <= '1';
       rx_data <= data_valid(31 downto 24);
       wait for 10 ns;
       nRx_rdy   <= '0';
       wait for 30 ns;

       assert false report "data valid loaded" severity NOTE;
       
       -- load up data block
  
       -- first load valid data
      
       for I in 0 to (To_integer((Unsigned(data_valid)))-1) loop
      
          nRx_rdy   <= '1';
          rx_data <= std_logic_vector(To_unsigned(data,8));
          checksum (7 downto 0) <= checksum (7 downto 0) XOR std_logic_vector(To_unsigned(data,8));
          wait for 10 ns;
          nRx_rdy   <= '0';
          wait for 30 ns;
         
          data <= data + 1;
         
          nRx_rdy   <= '1';
          rx_data <= "00000000";
          wait for 10 ns;
          nRx_rdy   <= '0';
          wait for 30 ns;
       
          nRx_rdy   <= '1';
          rx_data <= "00000000";
          wait for 10 ns;
          nRx_rdy   <= '0';
          wait for 30 ns;
      
          nRx_rdy   <= '1';   
          rx_data <= "00000000";
          wait for 10 ns;
          nRx_rdy   <= '0';
          wait for 30 ns;
      

       end loop;
    
       for J in (To_integer((Unsigned(data_valid)))) to data_block-1 loop
     
          nRx_rdy   <= '1';
          rx_data <= "00000000";
          wait for 10 ns;
          nRx_rdy   <= '0';
          wait for 30 ns;
     
          nRx_rdy   <= '1';
          rx_data <= "00000000";
          wait for 10 ns;
          nRx_rdy   <= '0';
          wait for 30 ns;
     
          nRx_rdy   <= '1';   
          rx_data <= "00000000";
          wait for 10 ns;
          nRx_rdy   <= '0';
          wait for 30 ns;
     
          nRx_rdy   <= '1';
          rx_data <= "00000000";
          wait for 10 ns;
          nRx_rdy   <= '0';
          wait for 30 ns;
       end loop;
          nRx_rdy   <= '1';
          
          assert false report "data loaded" severity NOTE; 
          
   end do_command;
   
   procedure do_checksum is
    
      -- load up checksum
   begin
   
      nRx_rdy   <= '1'; 
      rx_data <= checksum(7 downto 0);
      wait for 10 ns;
      nRx_rdy   <= '0';
      wait for 30 ns;

      nRx_rdy   <= '1';
      rx_data <= checksum(15 downto 8);
      wait for 10 ns;
      nRx_rdy   <= '0';
      wait for 30 ns;

      nRx_rdy   <= '1';
      rx_data <= checksum(23 downto 16);
      wait for 10 ns;
      nRx_rdy   <= '0';
      wait for 30 ns;
     
      nRx_rdy   <= '1';
      rx_data <= checksum(31 downto 24);
      wait for 10 ns;
      nRx_rdy   <= '0';
      wait for 30 ns;
      nRx_rdy   <= '1';
      
      assert false report "checksum loaded" severity NOTE;
   
   end do_checksum;
              
   

   
   begin 
   
   do_reset;
   
   -- initialse a wb command with 41 valid data words
   cmd_ack <= '0';
   
   command <= command_wb;
   address <= X"FFEEDDCC";
   data_valid <= X"00000029";
   data <= 0;   -- integer which is incremented and converted to std_logic_vector

   do_preamble;
   do_command;
   do_checksum;
  
   wait until tx_data = X"52";  -- R
   wait until tx_data = X"45";  -- E
   
   assert false report "reply word 'ER' received" severity NOTE;
   
    
   --wait until tx_data = X"4B";  -- 'K'
   --wait until tx_data = X"4F";  -- 'O'
   
  -- assert false report "reply word 'OK' received" severity NOTE;
   
   
   -- initialise a go command
   
   command <= command_go;
   address <= X"11223344";
   data_valid <= X"00000001";
   data <= 15;   -- integer which is incremented and converted to std_logic_vector

   do_preamble;
   do_command;
    
   -- give a checksum error 
      
   checksum <= check_err;
   do_checksum;
    
   assert false report "DEBUG" severity NOTE;
    
   wait until tx_data = X"52";  -- R
   wait until tx_data = X"45";  -- E
   
   assert false report "reply word 'ER' received" severity NOTE;
   
   wait until tx_data = X"00";   
   wait for 1000 ns;
   assert false report "end of simulation" severity FAILURE;   

   wait;
   
   end process stimuli;
  
end bench;
