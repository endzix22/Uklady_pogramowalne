----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.06.2021 18:54:34
-- Design Name: 
-- Module Name: display - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity display is
    Port(clk_i: in STD_LOGIC;
         rst_i: in STD_LOGIC;
         digit_i: in STD_LOGIC_VECTOR(31 downto 0);
         position_i: in STD_LOGIC_VECTOR(7 downto 0);
         led7_an_o: out STD_LOGIC_VECTOR(3 downto 0);
         led7_seg_o: out STD_LOGIC_VECTOR(7 downto 0)
         );
end display;

architecture Behavioral of display is

signal divider1: integer range 0 to 100000 - 1 := 0;
signal divider2: integer range 0 to 500 - 1 := 0;

signal clk: STD_LOGIC := '0';
signal number: integer := 0;

function decoder(signal dane: STD_LOGIC_VECTOR(7 downto 0))
    return STD_LOGIC_VECTOR is variable temp: STD_LOGIC_VECTOR(7 downto 0);
        begin
            case dane is
                when "00000000" => temp:= "00000011";
                when "00000001" => temp:= "10011111";
                when "00000010" => temp:= "00100101";
                when "00000011" => temp:= "00001101" ;
                when "00000100" => temp:= "10011001" ;
                when "00000101" => temp:= "01001001" ;
                when "00000110" => temp:= "01000001" ;
                when "00000111" => temp:= "00011111" ;
                when "00001000" => temp:= "00000001" ;
                when "00001001" => temp:= "00011001" ;
                when "00001010" => temp:= "00010001" ;
                when "00001011" => temp:= "11000001" ;
                when "00001100" => temp:= "01100011" ;
                when "00001101" => temp:= "10000101" ;
                when "00001110" => temp:= "01100001" ;
                when "00001111" => temp:= "01110001";
                when others => temp:= (others=>'1');
            end case;
    return(temp);
end function decoder;

begin

process(clk_i)
    begin
        if rising_edge(clk_i) then
            if divider1 = 100000 - 1 then
               divider1 <= 0;
            else
               divider1 <= divider1 + 1;
            end if;
            if divider1 = 100000/2 then
               clk <= '1';
            end if;
            if divider1 = 0 then
               clk <= '0';
            end if;
       end if;
end process;

process(clk, rst_i)
    variable point: integer;
        begin
            if rst_i = '1' then
                led7_an_o <= "1111";
                led7_an_o(0) <= '0';
                led7_seg_o <= "11111111";
                
            elsif rising_edge(clk) then
                led7_an_o <= "1111";
                led7_seg_o <= "11111111";
                
            if position_i(7) = '1' then
                if position_i = "10000000" then
                    point := 0;
                elsif position_i = "10000001" then
                    point := 1;
                elsif position_i = "10000010" then
                    point := 2;
                else
                    point := 3;
                end if;
                    
            if number = point then
            
            if divider2 = 200 - 1 then
               divider2 <= 0;
            else
               divider2 <= divider2 + 1;
            end if;
            if divider2 < 200/2 then
               led7_an_o(point) <= '0';
            else
               led7_an_o(point) <= '1';
            end if;
            else
               led7_an_o(number) <= '0';
            end if;
            if number < 3 then
               number <= number + 1;
            else
               number <= 0;
            end if;
                        
            if number = 0 then
               led7_seg_o <= decoder(digit_i(7 downto 0 ));
            else
               led7_seg_o <= decoder(digit_i((number+1)*8-1 downto (number+1)*8-1-7));
            end if;
            else
                led7_an_o(number) <= '0';
            if number < 3 then
                number <= number + 1;
            else
                number <= 0;
            end if;
               
            if number = 0 then
                led7_seg_o <= decoder(digit_i(7 downto 0));
            else
                led7_seg_o <= decoder(digit_i((number+1)*8-1 downto (number+1)*8-1-7));
            end if;
          end if;
        end if;
end process;

end Behavioral;
