----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/12/2021 01:25:01 PM
-- Design Name: 
-- Module Name: top - Behavioral
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


entity top is
    Port(clk_i: in STD_LOGIC;
         rst_i: in STD_LOGIC;
         button_i: in STD_LOGIC_VECTOR(3 downto 0);
         led7_an_o: out STD_LOGIC_VECTOR(3 downto 0);
         led7_seg_o: out STD_LOGIC_VECTOR(7 downto 0)
         );
end top;

architecture Behavioral of top is

  component kcpsm6 
    generic(                 hwbuild : std_logic_vector(7 downto 0) := X"00";
                    interrupt_vector : std_logic_vector(11 downto 0) := X"3FF";
             scratch_pad_memory_size : integer := 64);
    port (                   address : out std_logic_vector(11 downto 0);
                         instruction : in std_logic_vector(17 downto 0);
                         bram_enable : out std_logic;
                             in_port : in std_logic_vector(7 downto 0);
                            out_port : out std_logic_vector(7 downto 0);
                             port_id : out std_logic_vector(7 downto 0);
                        write_strobe : out std_logic;
                      k_write_strobe : out std_logic;
                         read_strobe : out std_logic;
                           interrupt : in std_logic;
                       interrupt_ack : out std_logic;
                               sleep : in std_logic;
                               reset : in std_logic;
                                 clk : in std_logic);
  end component;
  
  --
-- Declaration of the default Program Memory recommended for development.
--
-- The name of this component should match the name of your PSM file.
--
  component lab3                             
    generic(             C_FAMILY : string := "S6"; 
                C_RAM_SIZE_KWORDS : integer := 1;
             C_JTAG_LOADER_ENABLE : integer := 0);
    Port (      address : in std_logic_vector(11 downto 0);
            instruction : out std_logic_vector(17 downto 0);
                 enable : in std_logic;
                    rdl : out std_logic;                    
                    clk : in std_logic);
  end component;
  
  component divider is
    Port(clk_i: in STD_LOGIC;
         button_i: in STD_LOGIC_VECTOR(3 downto 0);
         button_o: out STD_LOGIC_VECTOR(3 downto 0)
         );
  end component;  
  
  component display is
    Port(clk_i: in STD_LOGIC;
         rst_i: in STD_LOGIC;
         digit_i: in STD_LOGIC_VECTOR(31 downto 0);
         position_i: in STD_LOGIC_VECTOR(7 downto 0);
         led7_an_o: out STD_LOGIC_VECTOR(3 downto 0);
         led7_seg_o: out STD_LOGIC_VECTOR(7 downto 0)
         );
   end component;
  --
-- Signals for connection of KCPSM6 and Program Memory.
--
signal         address : std_logic_vector(11 downto 0);
signal     instruction : std_logic_vector(17 downto 0);
signal     bram_enable : std_logic;
signal         in_port : std_logic_vector(7 downto 0);
signal        out_port : std_logic_vector(7 downto 0);
signal         port_id : std_logic_vector(7 downto 0);
signal    write_strobe : std_logic;
signal  k_write_strobe : std_logic;
signal     read_strobe : std_logic;
signal       interrupt : std_logic;
signal   interrupt_ack : std_logic;
signal    kcpsm6_sleep : std_logic;
signal    kcpsm6_reset : std_logic;

--
-- Some additional signals are required if your system also needs to reset KCPSM6. 
--

signal       cpu_reset : std_logic;
signal             rdl : std_logic;

signal bufor: STD_LOGIC_VECTOR(3 downto 0) := "0000";

signal internal1: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal internal2: STD_LOGIC_VECTOR(7 downto 0);
signal internal3: STD_LOGIC_VECTOR(3 downto 0);

type count is array(0 to 3) of STD_LOGIC_VECTOR(1 downto 0);
signal timer: count;

begin

dut1: divider
    Port map(clk_i => clk_i,
             button_i => button_i,
             button_o => internal3);
             
dut2: display
    Port map(clk_i => clk_i,
             rst_i => rst_i,
             digit_i => internal1,
             position_i => internal2,
             led7_an_o => led7_an_o,
             led7_seg_o => led7_seg_o);

  processor: kcpsm6
    generic map (                 hwbuild => X"00", 
                         interrupt_vector => X"7FF",
                  scratch_pad_memory_size => 64)
    port map(      address => address,
               instruction => instruction,
               bram_enable => bram_enable,
                   port_id => port_id,
              write_strobe => write_strobe,
            k_write_strobe => open,
                  out_port => out_port,
               read_strobe => open,
                   in_port => in_port,
                 interrupt => '0',
             interrupt_ack => open,
                     sleep => '0',
                     reset => rst_i,
                       clk => clk_i);
 
  program_rom: lab3                   --Name to match your PSM file
    generic map(             C_FAMILY => "7S",   --Family 'S6', 'V6' or '7S'
                    C_RAM_SIZE_KWORDS => 2,      --Program size '1', '2' or '4'
                 C_JTAG_LOADER_ENABLE => 0)      --Include JTAG Loader when set to '1' 
    port map(      address => address,      
               instruction => instruction,
                    enable => bram_enable,
                       rdl => open,
                       clk => clk_i);

input_ports: process(clk_i)
    begin
        if clk_i'event and clk_i = '1' then
            in_port <= (0 => bufor(0),
                        1 => bufor(1), 
                        2 => bufor(2), 
                        3 => bufor(3), 
                        others => '0');
        end if;
end process input_ports;

output_ports: process(clk_i)
    begin
        if clk_i'event and clk_i = '1' then
            if write_strobe = '1' then
                if port_id = 1 then
                    internal1(7 downto 0) <= out_port;
                elsif port_id = 2 then
                    internal1(15 downto 8) <= out_port;
                elsif port_id = 3 then
                    internal1(23 downto 16) <= out_port;
                elsif port_id = 4 then
                    internal1(31 downto 24) <= out_port;
                elsif port_id = 5 then
                    internal2 <= out_port;
                end if;
                end if;
                end if;
end process output_ports;

process(clk_i)
    begin
        if rising_edge(clk_i) then
            for i in 0 to 3 loop
                if internal3(i) = '1' then
                   bufor(i) <= '1';
                   timer(i) <= "11";
                elsif timer(i) /=0 then
                   timer(i) <= timer(i) - 1;
                else
                    bufor(i) <= '0';
                end if;
                end loop;
                end if;
end process;
                
end Behavioral;