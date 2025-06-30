----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.05.2025 07:24:13
-- Design Name: 
-- Module Name: sha256_tb - Behavioral
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

library work;
use work.sha256_pkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sha256_tb is
--  Port ( );
end sha256_tb;

architecture Behavioral of sha256_tb is
    signal clk : std_logic := '0';
    signal send_frame : std_logic := '0';
    signal mess_block : T_SV_15_0 := (others => (others => '0'));
    
    signal status_out : std_logic_vector(1 downto 0);
    signal hash_out : std_logic_vector(255 downto 0);
    
begin
    
    clk_proc : process
    begin
        wait for 10 ns;
        clk <= not clk;
    end process;
    
    dut : entity work.sha256 port map(
        i_clk => clk,
        i_send_frame => send_frame,
        i_mess_block => mess_block,
        o_status => status_out,
        o_hash => hash_out
    );
    
    test_proc : process
--        alias temp1 is <<signal .sha256_tb.dut.schedule_cnt : integer>>;
    begin
        wait for 100 ns;
        -- password: "dcvbjytfcnmjhgv mjhgbnmjhbnmtfcvbnmjhgvcxvbmkjhbvcghbvb"
--        mess_block(0)  <= "01100100011000110111011001100010";
--        mess_block(1)  <= "01101010011110010111010001100110";
--        mess_block(2)  <= "01100011011011100110110101101010";
--        mess_block(3)  <= "01101000011001110111011000100000";
--        mess_block(4)  <= "01101101011010100110100001100111";
--        mess_block(5)  <= "01100010011011100110110101101010";
--        mess_block(6)  <= "01101000011000100110111001101101";
--        mess_block(7)  <= "01110100011001100110001101110110";
--        mess_block(8)  <= "01100010011011100110110101101010";
--        mess_block(9)  <= "01101000011001110111011001100011";
--        mess_block(10) <= "01111000011101100110001001101101";
--        mess_block(11) <= "01101011011010100110100001100010";
--        mess_block(12) <= "01110110011000110110011101101000";
--        mess_block(13) <= "01100010011101100110001010000000";
--        mess_block(14) <= "00000000000000000000000000000000";
--        mess_block(15) <= "00000000000000000000000110111000";

        -- password: "abc"
        mess_block(0)  <= "01100001011000100110001110000000";
        mess_block(1)  <= "00000000000000000000000000000000";
        mess_block(2)  <= "00000000000000000000000000000000";
        mess_block(3)  <= "00000000000000000000000000000000";
        mess_block(4)  <= "00000000000000000000000000000000";
        mess_block(5)  <= "00000000000000000000000000000000";
        mess_block(6)  <= "00000000000000000000000000000000";
        mess_block(7)  <= "00000000000000000000000000000000";
        mess_block(8)  <= "00000000000000000000000000000000";
        mess_block(9)  <= "00000000000000000000000000000000";
        mess_block(10)  <= "00000000000000000000000000000000";
        mess_block(11)  <= "00000000000000000000000000000000";
        mess_block(12)  <= "00000000000000000000000000000000";
        mess_block(13)  <= "00000000000000000000000000000000";
        mess_block(14)  <= "00000000000000000000000000000000";
        mess_block(15)  <= "00000000000000000000000000011000";
        
        wait for 100 ns;
        send_frame <= '1';
        wait for 20 ns;
        send_frame <= '0';
        
        wait for 20 us;
    end process;

end Behavioral;
