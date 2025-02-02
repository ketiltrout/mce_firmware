-- 


-- 
ENTITY micron_ctrl_phy_alt_mem_phy_delay IS
---- Entity def/n
   GENERIC (
      WIDTH:      integer := 1;
      DELAY_PS:   integer := 10
   );
   PORT (
      s_in:   in bit_vector(WIDTH - 1 downto 0);
      s_out:  out bit_vector(WIDTH - 1 downto 0)
   );
-- 
END micron_ctrl_phy_alt_mem_phy_delay;
--
-- 
ARCHITECTURE micron_ctrl_phy_alt_mem_phy_delay
--
-- 
of micron_ctrl_phy_alt_mem_phy_delay is
--
-- Arch def/n
BEGIN
   s_out <= s_in after DELAY_PS * 1 ps;
END;
