--Legal Notice: (C)2008 Altera Corporation. All rights reserved.  Your
--use of Altera Corporation's design tools, logic functions and other
--software and tools, and its AMPP partner logic functions, and any
--output files any of the foregoing (including device programming or
--simulation files), and any associated documentation or information are
--expressly subject to the terms and conditions of the Altera Program
--License Subscription Agreement or other applicable license agreement,
--including, without limitation, that your use is for the sole purpose
--of programming logic devices manufactured by Altera and sold by Altera
--or its authorized distributors.  Please refer to the applicable
--agreement for further details.

--synthesis translate_off

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity micron_ctrl_mem_model_ram_module is 
        port (
              -- inputs:
                 signal data : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal rdaddress : IN STD_LOGIC_VECTOR (23 DOWNTO 0);
                 signal rdclken : IN STD_LOGIC;
                 signal wraddress : IN STD_LOGIC_VECTOR (23 DOWNTO 0);
                 signal wrclock : IN STD_LOGIC;
                 signal wren : IN STD_LOGIC;

              -- outputs:
                 signal q : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
              );
end entity micron_ctrl_mem_model_ram_module;


architecture europa of micron_ctrl_mem_model_ram_module is
              signal internal_q :  STD_LOGIC_VECTOR (31 DOWNTO 0);
              TYPE mem_array is ARRAY( 16777215 DOWNTO 0) of STD_LOGIC_VECTOR(31 DOWNTO 0);
              signal read_address :  STD_LOGIC_VECTOR (23 DOWNTO 0);

begin
   process (wrclock, rdaddress) -- MG
    
    VARIABLE wr_address_internal : STD_LOGIC_VECTOR (23 DOWNTO 0) := (others => '0');
    variable Marc_Gaucherons_Memory_Variable : mem_array; -- MG
    
    begin
      -- Write data
      if wrclock'event and wrclock = '1' then
        wr_address_internal := wraddress;
        if wren = '1' then 
          Marc_Gaucherons_Memory_Variable(CONV_INTEGER(UNSIGNED(wr_address_internal))) := data;
        end if;
      end if;

      -- read data
      q <= Marc_Gaucherons_Memory_Variable(CONV_INTEGER(UNSIGNED(rdaddress)));
      


    end process;
end europa;

--synthesis translate_on


--synthesis read_comments_as_HDL on
--library altera;
--use altera.altera_europa_support_lib.all;
--
--library ieee;
--use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;
--
--entity micron_ctrl_mem_model_ram_module is 
--        port (
--              
--                 signal data : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
--                 signal rdaddress : IN STD_LOGIC_VECTOR (23 DOWNTO 0);
--                 signal rdclken : IN STD_LOGIC;
--                 signal wraddress : IN STD_LOGIC_VECTOR (23 DOWNTO 0);
--                 signal wrclock : IN STD_LOGIC;
--                 signal wren : IN STD_LOGIC;
--
--              
--                 signal q : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
--              );
--end entity micron_ctrl_mem_model_ram_module;
--
--
--architecture europa of micron_ctrl_mem_model_ram_module is
--  component lpm_ram_dp is
--GENERIC (
--      lpm_file : STRING;
--        lpm_hint : STRING;
--        lpm_indata : STRING;
--        lpm_outdata : STRING;
--        lpm_rdaddress_control : STRING;
--        lpm_width : NATURAL;
--        lpm_widthad : NATURAL;
--        lpm_wraddress_control : STRING;
--        suppress_memory_conversion_warnings : STRING
--      );
--    PORT (
--    signal q : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
--        signal rdaddress : IN STD_LOGIC_VECTOR (23 DOWNTO 0);
--        signal wren : IN STD_LOGIC;
--        signal wrclock : IN STD_LOGIC;
--        signal wraddress : IN STD_LOGIC_VECTOR (23 DOWNTO 0);
--        signal data : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
--        signal rdclken : IN STD_LOGIC
--      );
--  end component lpm_ram_dp;
--                signal internal_q :  STD_LOGIC_VECTOR (31 DOWNTO 0);
--                TYPE mem_array is ARRAY( 16777215 DOWNTO 0) of STD_LOGIC_VECTOR(31 DOWNTO 0);
--                signal read_address :  STD_LOGIC_VECTOR (23 DOWNTO 0);
--
--begin
--
--  process (rdaddress)
--  begin
--      read_address <= rdaddress;
--
--  end process;
--
--  lpm_ram_dp_component : lpm_ram_dp
--    generic map(
--      lpm_file => "UNUSED",
--      lpm_hint => "USE_EAB=ON",
--      lpm_indata => "REGISTERED",
--      lpm_outdata => "UNREGISTERED",
--      lpm_rdaddress_control => "UNREGISTERED",
--      lpm_width => 32,
--      lpm_widthad => 24,
--      lpm_wraddress_control => "REGISTERED",
--      suppress_memory_conversion_warnings => "ON"
--    )
--    port map(
--            data => data,
--            q => internal_q,
--            rdaddress => read_address,
--            rdclken => rdclken,
--            wraddress => wraddress,
--            wrclock => wrclock,
--            wren => wren
--    );
--
--  
--  q <= internal_q;
--end europa;
--
--synthesis read_comments_as_HDL off


-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library std;
use std.textio.all;

entity micron_ctrl_mem_model is 
        port (
              -- inputs:
                 signal mem_addr : IN STD_LOGIC_VECTOR (12 DOWNTO 0);
                 signal mem_ba : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal mem_cas_n : IN STD_LOGIC;
                 signal mem_cke : IN STD_LOGIC;
                 signal mem_clk : IN STD_LOGIC;
                 signal mem_clk_n : IN STD_LOGIC;
                 signal mem_cs_n : IN STD_LOGIC;
                 signal mem_dm : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal mem_odt : IN STD_LOGIC;
                 signal mem_ras_n : IN STD_LOGIC;
                 signal mem_we_n : IN STD_LOGIC;

              -- outputs:
                 signal global_reset_n : OUT STD_LOGIC;
                 signal mem_dq : INOUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal mem_dqs : INOUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal mem_dqs_n : INOUT STD_LOGIC_VECTOR (1 DOWNTO 0)
              );
end entity micron_ctrl_mem_model;


architecture europa of micron_ctrl_mem_model is
component micron_ctrl_mem_model_ram_module is 
           port (
                 -- inputs:
                    signal data : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal rdaddress : IN STD_LOGIC_VECTOR (23 DOWNTO 0);
                    signal rdclken : IN STD_LOGIC;
                    signal wraddress : IN STD_LOGIC_VECTOR (23 DOWNTO 0);
                    signal wrclock : IN STD_LOGIC;
                    signal wren : IN STD_LOGIC;

                 -- outputs:
                    signal q : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component micron_ctrl_mem_model_ram_module;

                signal CODE :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal a :  STD_LOGIC_VECTOR (12 DOWNTO 0);
                signal addr_col :  STD_LOGIC_VECTOR (8 DOWNTO 0);
                signal ba :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal burst_term :  STD_LOGIC;
                signal burst_term_cmd :  STD_LOGIC;
                signal burstlength :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal burstmode :  STD_LOGIC;
                signal cas_n :  STD_LOGIC;
                signal cke :  STD_LOGIC;
                signal clk :  STD_LOGIC;
                signal cmd_code :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal cs_n :  STD_LOGIC;
                signal current_row :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal dm :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal dm_captured :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal dq_captured :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal dq_temp :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal dq_valid :  STD_LOGIC;
                signal dqs_n_temp :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal dqs_temp :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal dqs_valid :  STD_LOGIC;
                signal dqs_valid_temp :  STD_LOGIC;
                signal first_half_dq :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal index :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal mem_bytes :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal module_input :  STD_LOGIC;
                TYPE mem_type3 is ARRAY( 3 DOWNTO 0) of STD_LOGIC_VECTOR(12 DOWNTO 0);
              signal open_rows : mem_type3;
                signal ras_n :  STD_LOGIC;
                signal rd_addr_pipe_0 :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal rd_addr_pipe_1 :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal rd_addr_pipe_10 :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal rd_addr_pipe_2 :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal rd_addr_pipe_3 :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal rd_addr_pipe_4 :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal rd_addr_pipe_5 :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal rd_addr_pipe_6 :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal rd_addr_pipe_7 :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal rd_addr_pipe_8 :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal rd_addr_pipe_9 :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal rd_burst_counter :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal rd_valid_pipe :  STD_LOGIC_VECTOR (10 DOWNTO 0);
                signal read_addr_delayed :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal read_cmd :  STD_LOGIC;
                signal read_cmd_echo :  STD_LOGIC;
                signal read_data :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal read_dq :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal read_valid :  STD_LOGIC;
                signal read_valid_r :  STD_LOGIC;
                signal read_valid_r2 :  STD_LOGIC;
                signal read_valid_r3 :  STD_LOGIC;
                signal read_valid_r4 :  STD_LOGIC;
                signal reset_n :  STD_LOGIC;
                signal rmw_address :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal rmw_temp :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal second_half_dq :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal txt_code :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal we_n :  STD_LOGIC;
                signal wr_addr_delayed :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal wr_addr_delayed_r :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal wr_addr_pipe_0 :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal wr_addr_pipe_1 :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal wr_addr_pipe_10 :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal wr_addr_pipe_2 :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal wr_addr_pipe_3 :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal wr_addr_pipe_4 :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal wr_addr_pipe_5 :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal wr_addr_pipe_6 :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal wr_addr_pipe_7 :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal wr_addr_pipe_8 :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal wr_addr_pipe_9 :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal wr_burst_counter :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal wr_valid_pipe :  STD_LOGIC_VECTOR (10 DOWNTO 0);
                signal write_burst_length_pipe :  STD_LOGIC_VECTOR (10 DOWNTO 0);
                signal write_cmd :  STD_LOGIC;
                signal write_cmd_echo :  STD_LOGIC;
                signal write_to_ram :  STD_LOGIC;
                signal write_to_ram_r :  STD_LOGIC;
                signal write_valid :  STD_LOGIC;
                signal write_valid_r :  STD_LOGIC;
                signal write_valid_r2 :  STD_LOGIC;
                signal write_valid_r3 :  STD_LOGIC;

begin

  process
VARIABLE write_line : line;
VARIABLE write_line1 : line;
VARIABLE write_line2 : line;
VARIABLE write_line3 : line;
VARIABLE write_line4 : line;

    begin
      write(write_line, string'("**********************************************************************"));
      write(output, write_line.all & CR);
      deallocate (write_line);
      write(write_line1, string'("This testbench includes a generated Altera memory model:"));
      write(output, write_line1.all & CR);
      deallocate (write_line1);
      write(write_line2, string'("'micron_ctrl.vhd', to simulate accesses to the DDR2 SDRAM memory."));
      write(output, write_line2.all & CR);
      deallocate (write_line2);
      write(write_line3, string'(" "));
      write(output, write_line3.all & CR);
      deallocate (write_line3);
      write(write_line4, string'("**********************************************************************"));
      write(output, write_line4.all & CR);
      deallocate (write_line4);
    wait;
  end process;
  --Synchronous write when (CODE == 24'h205752 (write))
  micron_ctrl_mem_model_ram : micron_ctrl_mem_model_ram_module
    port map(
      q => read_data,
      data => rmw_temp,
      rdaddress => rmw_address,
      rdclken => module_input,
      wraddress => wr_addr_delayed_r,
      wrclock => clk,
      wren => write_to_ram_r
    );

  module_input <= std_logic'('1');

  clk <= mem_clk;
  dm <= mem_dm;
  cke <= mem_cke;
  cs_n <= mem_cs_n;
  ras_n <= mem_ras_n;
  cas_n <= mem_cas_n;
  we_n <= mem_we_n;
  ba <= mem_ba;
  a <= mem_addr;
  PROCESS
  BEGIN
    dq_temp(0) <= 'L';  
  WAIT;
  END PROCESS;
  
  
  PROCESS
  BEGIN
    dq_temp(1) <= 'L';  
  WAIT;
  END PROCESS;
  
  
  PROCESS
  BEGIN
    dq_temp(2) <= 'L';  
  WAIT;
  END PROCESS;
  
  
  PROCESS
  BEGIN
    dq_temp(3) <= 'L';  
  WAIT;
  END PROCESS;
  
  
  PROCESS
  BEGIN
    dq_temp(4) <= 'L';  
  WAIT;
  END PROCESS;
  
  
  PROCESS
  BEGIN
    dq_temp(5) <= 'L';  
  WAIT;
  END PROCESS;
  
  
  PROCESS
  BEGIN
    dq_temp(6) <= 'L';  
  WAIT;
  END PROCESS;
  
  
  PROCESS
  BEGIN
    dq_temp(7) <= 'L';  
  WAIT;
  END PROCESS;
  
  
  PROCESS
  BEGIN
    dq_temp(8) <= 'L';  
  WAIT;
  END PROCESS;
  
  
  PROCESS
  BEGIN
    dq_temp(9) <= 'L';  
  WAIT;
  END PROCESS;
  
  
  PROCESS
  BEGIN
    dq_temp(10) <= 'L';  
  WAIT;
  END PROCESS;
  
  
  PROCESS
  BEGIN
    dq_temp(11) <= 'L';  
  WAIT;
  END PROCESS;
  
  
  PROCESS
  BEGIN
    dq_temp(12) <= 'L';  
  WAIT;
  END PROCESS;
  
  
  PROCESS
  BEGIN
    dq_temp(13) <= 'L';  
  WAIT;
  END PROCESS;
  
  
  PROCESS
  BEGIN
    dq_temp(14) <= 'L';  
  WAIT;
  END PROCESS;
  
  
  PROCESS
  BEGIN
    dq_temp(15) <= 'L';  
  WAIT;
  END PROCESS;
  
  
  --generate a fake reset inside the memory model
  global_reset_n <= reset_n;
  PROCESS
    BEGIN
       reset_n <= '0';
       wait for 100 ns;
       reset_n <= '1'; 
    WAIT;
  END PROCESS;
  cmd_code <= A_WE_StdLogicVector((std_logic'((cs_n)) = '1'), std_logic_vector'("111"), Std_Logic_Vector'(A_ToStdLogicVector(ras_n) & A_ToStdLogicVector(cas_n) & A_ToStdLogicVector(we_n)));
  CODE <= A_WE_StdLogicVector((std_logic'((cs_n)) = '1'), std_logic_vector'("010010010100111001001000"), txt_code);
  addr_col <= a(9 DOWNTO 1);
  current_row <= ba;
  -- Decode commands into their actions
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      write_cmd_echo <= std_logic'('0');
      read_cmd_echo <= std_logic'('0');
    elsif clk'event and clk = '1' then
      -- No Activity if the clock is
      if std_logic'(cke) = '1' then 
        -- This is a read command
        if cmd_code = std_logic_vector'("101") then 
          read_cmd <= std_logic'('1');
        else
          read_cmd <= std_logic'('0');
        end if;
        -- This is a write command
        if cmd_code = std_logic_vector'("100") then 
          write_cmd <= std_logic'('1');
        else
          write_cmd <= std_logic'('0');
        end if;
        -- This is to terminate a burst
        if cmd_code = std_logic_vector'("110") then 
          burst_term_cmd <= std_logic'('1');
        else
          burst_term_cmd <= std_logic'('0');
        end if;
        -- This is an activate - store the chip/row/bank address in the same order as the DDR controller
        if cmd_code = std_logic_vector'("011") then 
          open_rows(CONV_INTEGER(UNSIGNED((current_row)))) <= a;
        end if;
      end if;
    end if;

  end process;

  -- Pipes are flushed here
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      wr_addr_pipe_1 <= std_logic_vector'("000000000000000000000000");
      wr_addr_pipe_2 <= std_logic_vector'("000000000000000000000000");
      wr_addr_pipe_3 <= std_logic_vector'("000000000000000000000000");
      wr_addr_pipe_4 <= std_logic_vector'("000000000000000000000000");
      wr_addr_pipe_5 <= std_logic_vector'("000000000000000000000000");
      wr_addr_pipe_6 <= std_logic_vector'("000000000000000000000000");
      wr_addr_pipe_7 <= std_logic_vector'("000000000000000000000000");
      wr_addr_pipe_8 <= std_logic_vector'("000000000000000000000000");
      wr_addr_pipe_9 <= std_logic_vector'("000000000000000000000000");
      wr_addr_pipe_10 <= std_logic_vector'("000000000000000000000000");
      rd_addr_pipe_1 <= std_logic_vector'("000000000000000000000000");
      rd_addr_pipe_2 <= std_logic_vector'("000000000000000000000000");
      rd_addr_pipe_3 <= std_logic_vector'("000000000000000000000000");
      rd_addr_pipe_4 <= std_logic_vector'("000000000000000000000000");
      rd_addr_pipe_5 <= std_logic_vector'("000000000000000000000000");
      rd_addr_pipe_6 <= std_logic_vector'("000000000000000000000000");
      rd_addr_pipe_7 <= std_logic_vector'("000000000000000000000000");
      rd_addr_pipe_8 <= std_logic_vector'("000000000000000000000000");
      rd_addr_pipe_9 <= std_logic_vector'("000000000000000000000000");
      rd_addr_pipe_10 <= std_logic_vector'("000000000000000000000000");
    elsif clk'event and clk = '1' then
      -- No Activity if the clock is
      if std_logic'(cke) = '1' then 
        rd_addr_pipe_10 <= rd_addr_pipe_9;
        rd_addr_pipe_9 <= rd_addr_pipe_8;
        rd_addr_pipe_8 <= rd_addr_pipe_7;
        rd_addr_pipe_7 <= rd_addr_pipe_6;
        rd_addr_pipe_6 <= rd_addr_pipe_5;
        rd_addr_pipe_5 <= rd_addr_pipe_4;
        rd_addr_pipe_4 <= rd_addr_pipe_3;
        rd_addr_pipe_3 <= rd_addr_pipe_2;
        rd_addr_pipe_2 <= rd_addr_pipe_1;
        rd_addr_pipe_1 <= rd_addr_pipe_0;
        rd_valid_pipe(10 DOWNTO 1) <= rd_valid_pipe(9 DOWNTO 0);
        rd_valid_pipe(0) <= to_std_logic((cmd_code = std_logic_vector'("101")));
        wr_addr_pipe_10 <= wr_addr_pipe_9;
        wr_addr_pipe_9 <= wr_addr_pipe_8;
        wr_addr_pipe_8 <= wr_addr_pipe_7;
        wr_addr_pipe_7 <= wr_addr_pipe_6;
        wr_addr_pipe_6 <= wr_addr_pipe_5;
        wr_addr_pipe_5 <= wr_addr_pipe_4;
        wr_addr_pipe_4 <= wr_addr_pipe_3;
        wr_addr_pipe_3 <= wr_addr_pipe_2;
        wr_addr_pipe_2 <= wr_addr_pipe_1;
        wr_addr_pipe_1 <= wr_addr_pipe_0;
        wr_valid_pipe(10 DOWNTO 1) <= wr_valid_pipe(9 DOWNTO 0);
        wr_valid_pipe(0) <= to_std_logic((cmd_code = std_logic_vector'("100")));
        wr_addr_delayed_r <= wr_addr_delayed;
        write_burst_length_pipe(10 DOWNTO 1) <= write_burst_length_pipe(9 DOWNTO 0);
      end if;
    end if;

  end process;

  -- Decode CAS Latency from bits a[6:4]
  process (clk)
  begin
    if clk'event and clk = '1' then
      -- No Activity if the clock is
      if std_logic'(cke) = '1' then 
        --Load mode register - set CAS latency, burst mode and length
        if (cmd_code = std_logic_vector'("000")) AND (ba = std_logic_vector'("00")) then 
          burstmode <= a(3);
          burstlength <= A_SLL(a(2 DOWNTO 0),std_logic_vector'("00000000000000000000000000000001"));
          --CAS Latency = 3.0
          if a(6 DOWNTO 4) = std_logic_vector'("011") then 
            index <= std_logic_vector'("0010");
          --CAS Latency = 4.0
          elsif a(6 DOWNTO 4) = std_logic_vector'("100") then 
            index <= std_logic_vector'("0011");
          --CAS Latency = 5.0
          elsif a(6 DOWNTO 4) = std_logic_vector'("101") then 
            index <= std_logic_vector'("0100");
          --CAS Latency = 6.0
          elsif a(6 DOWNTO 4) = std_logic_vector'("110") then 
            index <= std_logic_vector'("0101");
          else
            index <= std_logic_vector'("0110");
          end if;
        end if;
      end if;
    end if;

  end process;

  -- Burst support - make the wr_addr & rd_addr keep counting
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      wr_addr_pipe_0 <= std_logic_vector'("000000000000000000000000");
      rd_addr_pipe_0 <= std_logic_vector'("000000000000000000000000");
    elsif clk'event and clk = '1' then
      -- Reset write address otherwise if the first write is partial it breaks!
      if (cmd_code = std_logic_vector'("000")) AND (ba = std_logic_vector'("00")) then 
        wr_addr_pipe_0 <= std_logic_vector'("000000000000000000000000");
        wr_burst_counter <= std_logic_vector'("000000000000000000000000");
      elsif cmd_code = std_logic_vector'("100") then 
        wr_addr_pipe_0 <= (ba & open_rows(CONV_INTEGER(UNSIGNED((current_row)))) & addr_col);
        wr_burst_counter(23 DOWNTO 1) <= ba & open_rows(CONV_INTEGER(UNSIGNED((current_row)))) & addr_col(8 DOWNTO 1);
        wr_burst_counter(0) <= Vector_To_Std_Logic(((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(addr_col(0)))) + std_logic_vector'("000000000000000000000000000000001")));
      elsif std_logic'(((write_cmd OR write_to_ram) OR write_cmd_echo)) = '1' then 
        wr_addr_pipe_0 <= wr_burst_counter;
        wr_burst_counter(0) <= Vector_To_Std_Logic(((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(wr_burst_counter(0)))) + std_logic_vector'("000000000000000000000000000000001")));
      else
        wr_addr_pipe_0 <= std_logic_vector'("000000000000000000000000");
      end if;
      -- Reset read address otherwise if the first write is partial it breaks!
      if (cmd_code = std_logic_vector'("000")) AND (ba = std_logic_vector'("00")) then 
        rd_addr_pipe_0 <= std_logic_vector'("000000000000000000000000");
      elsif cmd_code = std_logic_vector'("101") then 
        rd_addr_pipe_0 <= (ba & open_rows(CONV_INTEGER(UNSIGNED((current_row)))) & addr_col);
        rd_burst_counter(23 DOWNTO 1) <= ba & open_rows(CONV_INTEGER(UNSIGNED((current_row)))) & addr_col(8 DOWNTO 1);
        rd_burst_counter(0) <= Vector_To_Std_Logic(((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(addr_col(0)))) + std_logic_vector'("000000000000000000000000000000001")));
      elsif std_logic'((((read_cmd OR dq_valid) OR read_valid) OR read_cmd_echo)) = '1' then 
        rd_addr_pipe_0 <= rd_burst_counter;
        rd_burst_counter(0) <= Vector_To_Std_Logic(((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(rd_burst_counter(0)))) + std_logic_vector'("000000000000000000000000000000001")));
      else
        rd_addr_pipe_0 <= std_logic_vector'("000000000000000000000000");
      end if;
    end if;

  end process;

  -- read data transition from single to double clock rate
  process (clk)
  begin
    if clk'event and clk = '1' then
      first_half_dq <= read_data(31 DOWNTO 16);
      second_half_dq <= read_data(15 DOWNTO 0);
    end if;

  end process;

  read_dq <= A_WE_StdLogicVector((std_logic'(clk) = '1'), second_half_dq, first_half_dq);
  dq_temp <= A_WE_StdLogicVector((std_logic'(dq_valid) = '1'), read_dq, A_REP(std_logic'('Z'), 16));
  dqs_temp <= A_WE_StdLogicVector((std_logic'(dqs_valid) = '1'), A_REP(clk, 2), A_REP(std_logic'('Z'), 2));
  dqs_n_temp <= A_WE_StdLogicVector((std_logic'(dqs_valid) = '1'), A_REP(NOT clk, 2), A_REP(std_logic'('Z'), 2));
  mem_dqs <= dqs_temp;
  mem_dq <= dq_temp;
  mem_dqs_n <= dqs_n_temp;
  --Pipelining registers for burst counting
  process (clk)
  begin
    if clk'event and clk = '1' then
      write_valid_r <= write_valid;
      read_valid_r <= read_valid;
      write_valid_r2 <= write_valid_r;
      write_valid_r3 <= write_valid_r2;
      write_to_ram_r <= write_to_ram;
      read_valid_r2 <= read_valid_r;
      read_valid_r3 <= read_valid_r2;
      read_valid_r4 <= read_valid_r3;
    end if;

  end process;

  write_to_ram <= write_valid OR write_valid_r;
  dq_valid <= read_valid_r OR (read_valid_r2 AND burst_term);
  dqs_valid <= dq_valid OR dqs_valid_temp;
  -- 
  process (clk)
  begin
    if clk'event and clk = '0' then
      dqs_valid_temp <= read_valid;
    end if;

  end process;

  --capture first half of write data with rising edge of DQS, for simulation use only 1 DQS pin
  process (mem_dqs)
  begin
    if mem_dqs(0)'event and mem_dqs(0) = '1' then
      dq_captured(15 DOWNTO 0) <=  transport mem_dq(15 DOWNTO 0) after 0.1 ns ;
      dm_captured(1 DOWNTO 0) <=  transport mem_dm(1 DOWNTO 0) after 0.1 ns ;
    end if;

  end process;

  --capture second half of write data with falling edge of DQS, for simulation use only 1 DQS pin
  process (mem_dqs)
  begin
    if mem_dqs(0)'event and mem_dqs(0) = '0' then
      dq_captured(31 DOWNTO 16) <=  transport mem_dq(15 DOWNTO 0) after 0.1 ns ;
      dm_captured(3 DOWNTO 2) <=  transport mem_dm(1 DOWNTO 0) after 0.1 ns ;
    end if;

  end process;

  --Support for incomplete writes, do a read-modify-write with mem_bytes and the write data
  process (clk)
  begin
    if clk'event and clk = '1' then
      if std_logic'(write_to_ram) = '1' then 
        rmw_temp(7 DOWNTO 0) <= A_WE_StdLogicVector((std_logic'(dm_captured(0)) = '1'), mem_bytes(7 DOWNTO 0), dq_captured(7 DOWNTO 0));
      end if;
    end if;

  end process;

  process (clk)
  begin
    if clk'event and clk = '1' then
      if std_logic'(write_to_ram) = '1' then 
        rmw_temp(15 DOWNTO 8) <= A_WE_StdLogicVector((std_logic'(dm_captured(1)) = '1'), mem_bytes(15 DOWNTO 8), dq_captured(15 DOWNTO 8));
      end if;
    end if;

  end process;

  process (clk)
  begin
    if clk'event and clk = '1' then
      if std_logic'(write_to_ram) = '1' then 
        rmw_temp(23 DOWNTO 16) <= A_WE_StdLogicVector((std_logic'(dm_captured(2)) = '1'), mem_bytes(23 DOWNTO 16), dq_captured(23 DOWNTO 16));
      end if;
    end if;

  end process;

  process (clk)
  begin
    if clk'event and clk = '1' then
      if std_logic'(write_to_ram) = '1' then 
        rmw_temp(31 DOWNTO 24) <= A_WE_StdLogicVector((std_logic'(dm_captured(3)) = '1'), mem_bytes(31 DOWNTO 24), dq_captured(31 DOWNTO 24));
      end if;
    end if;

  end process;

  --DDR2 has variable write latency too, so use index to select which pipeline stage drives valid
  write_valid <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000") & (index)) = std_logic_vector'("00000000000000000000000000000000"))), wr_valid_pipe(0), A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000") & (index)) = std_logic_vector'("00000000000000000000000000000001"))), wr_valid_pipe(1), A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000") & (index)) = std_logic_vector'("00000000000000000000000000000010"))), wr_valid_pipe(2), A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000") & (index)) = std_logic_vector'("00000000000000000000000000000011"))), wr_valid_pipe(3), A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000") & (index)) = std_logic_vector'("00000000000000000000000000000100"))), wr_valid_pipe(4), A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000") & (index)) = std_logic_vector'("00000000000000000000000000000101"))), wr_valid_pipe(5), A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000") & (index)) = std_logic_vector'("00000000000000000000000000000110"))), wr_valid_pipe(6), A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000") & (index)) = std_logic_vector'("00000000000000000000000000000111"))), wr_valid_pipe(7), A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000") & (index)) = std_logic_vector'("00000000000000000000000000001000"))), wr_valid_pipe(8), A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000") & (index)) = std_logic_vector'("00000000000000000000000000001001"))), wr_valid_pipe(9), wr_valid_pipe(10)))))))))));
  --DDR2 has variable write latency too, so use index to select which pipeline stage drives addr
  wr_addr_delayed <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000") & (index)) = std_logic_vector'("00000000000000000000000000000000"))), wr_addr_pipe_0, A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000") & (index)) = std_logic_vector'("00000000000000000000000000000001"))), wr_addr_pipe_1, A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000") & (index)) = std_logic_vector'("00000000000000000000000000000010"))), wr_addr_pipe_2, A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000") & (index)) = std_logic_vector'("00000000000000000000000000000011"))), wr_addr_pipe_3, A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000") & (index)) = std_logic_vector'("00000000000000000000000000000100"))), wr_addr_pipe_4, A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000") & (index)) = std_logic_vector'("00000000000000000000000000000101"))), wr_addr_pipe_5, A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000") & (index)) = std_logic_vector'("00000000000000000000000000000110"))), wr_addr_pipe_6, A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000") & (index)) = std_logic_vector'("00000000000000000000000000000111"))), wr_addr_pipe_7, A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000") & (index)) = std_logic_vector'("00000000000000000000000000001000"))), wr_addr_pipe_8, A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000") & (index)) = std_logic_vector'("00000000000000000000000000001001"))), wr_addr_pipe_9, wr_addr_pipe_10))))))))));
  burst_term <= std_logic'('1');
  mem_bytes <= read_data;
  rmw_address <= A_WE_StdLogicVector((std_logic'((write_to_ram)) = '1'), wr_addr_delayed, read_addr_delayed);
  --use index to select which pipeline stage drives addr
  read_addr_delayed <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000") & (index)) = std_logic_vector'("00000000000000000000000000000000"))), rd_addr_pipe_0, A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000") & (index)) = std_logic_vector'("00000000000000000000000000000001"))), rd_addr_pipe_1, A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000") & (index)) = std_logic_vector'("00000000000000000000000000000010"))), rd_addr_pipe_2, A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000") & (index)) = std_logic_vector'("00000000000000000000000000000011"))), rd_addr_pipe_3, A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000") & (index)) = std_logic_vector'("00000000000000000000000000000100"))), rd_addr_pipe_4, A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000") & (index)) = std_logic_vector'("00000000000000000000000000000101"))), rd_addr_pipe_5, A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000") & (index)) = std_logic_vector'("00000000000000000000000000000110"))), rd_addr_pipe_6, A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000") & (index)) = std_logic_vector'("00000000000000000000000000000111"))), rd_addr_pipe_7, A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000") & (index)) = std_logic_vector'("00000000000000000000000000001000"))), rd_addr_pipe_8, A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000") & (index)) = std_logic_vector'("00000000000000000000000000001001"))), rd_addr_pipe_9, rd_addr_pipe_10))))))))));
  --use index to select which pipeline stage drives valid
  read_valid <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000") & (index)) = std_logic_vector'("00000000000000000000000000000000"))), rd_valid_pipe(0), A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000") & (index)) = std_logic_vector'("00000000000000000000000000000001"))), rd_valid_pipe(1), A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000") & (index)) = std_logic_vector'("00000000000000000000000000000010"))), rd_valid_pipe(2), A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000") & (index)) = std_logic_vector'("00000000000000000000000000000011"))), rd_valid_pipe(3), A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000") & (index)) = std_logic_vector'("00000000000000000000000000000100"))), rd_valid_pipe(4), A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000") & (index)) = std_logic_vector'("00000000000000000000000000000101"))), rd_valid_pipe(5), A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000") & (index)) = std_logic_vector'("00000000000000000000000000000110"))), rd_valid_pipe(6), A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000") & (index)) = std_logic_vector'("00000000000000000000000000000111"))), rd_valid_pipe(7), A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000") & (index)) = std_logic_vector'("00000000000000000000000000001000"))), rd_valid_pipe(8), A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000") & (index)) = std_logic_vector'("00000000000000000000000000001001"))), rd_valid_pipe(9), rd_valid_pipe(10)))))))))));
--synthesis translate_off
    txt_code <= A_WE_StdLogicVector(((cmd_code = std_logic_vector'("000"))), std_logic_vector'("010011000100110101010010"), A_WE_StdLogicVector(((cmd_code = std_logic_vector'("001"))), std_logic_vector'("010000010101001001000110"), A_WE_StdLogicVector(((cmd_code = std_logic_vector'("010"))), std_logic_vector'("010100000101001001000101"), A_WE_StdLogicVector(((cmd_code = std_logic_vector'("011"))), std_logic_vector'("010000010100001101010100"), A_WE_StdLogicVector(((cmd_code = std_logic_vector'("100"))), std_logic_vector'("001000000101011101010010"), A_WE_StdLogicVector(((cmd_code = std_logic_vector'("101"))), std_logic_vector'("001000000101001001000100"), A_WE_StdLogicVector(((cmd_code = std_logic_vector'("110"))), std_logic_vector'("010000100101001101010100"), A_WE_StdLogicVector(((cmd_code = std_logic_vector'("111"))), std_logic_vector'("010011100100111101010000"), std_logic_vector'("010000100100000101000100")))))))));
--synthesis translate_on

end europa;

