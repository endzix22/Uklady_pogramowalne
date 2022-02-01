----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.06.2021 15:49:38
-- Design Name: 
-- Module Name: divider - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity divider is
    Port(clk_i: in STD_LOGIC;
         button_i: in STD_LOGIC_VECTOR(3 downto 0);
         button_o: out STD_LOGIC_VECTOR(3 downto 0)
         );
end divider;

architecture Behavioral of divider is

type count is array(0 to 3) of STD_LOGIC_VECTOR (25 downto 0);
signal counter: count;

begin

process(clk_i)
    begin
        if rising_edge(clk_i) then
            for i in 0 to 3 loop
                if button_i(i) = '0' then
                counter(i) <= (others => '1');
            else
                if counter(i) /= 0 then
                counter(i) <= counter(i) - 1;
            else
                counter(i) <= (others => '1');
            end if;
            end if;
            end loop;
        end if;
end process;

button_o(0) <= '1' when counter(0) = 0 else '0';
button_o(1) <= '1' when counter(1) = 0 else '0';
button_o(2) <= '1' when counter(2) = 0 else '0';
button_o(3) <= '1' when counter(3) = 0 else '0';
end Behavioral;
