----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.05.2025 04:03:00
-- Design Name: 
-- Module Name: sha256 - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sha256 is
    Port ( i_clk : in STD_LOGIC;
           i_mess_block : in STD_LOGIC_VECTOR (511 downto 0);
           i_send_frame : in std_logic;
           o_rvalid : out STD_LOGIC;
           o_wvalid : out STD_LOGIC;
           o_hash : out STD_LOGIC_VECTOR (255 downto 0));
end sha256;

architecture Behavioral of sha256 is
    signal schedule_cnt : integer := -1;
    signal schedule_bank : t_mess_schedule_bank := C_INIT_MESS_SCHEDULE;
    signal working_vars : t_working_vars := C_WORKING_VARS;
    signal complete_hash : unsigned(255 downto 0) := (others => '0');
    signal status : std_logic_vector (3 downto 0) := "0001";       -- 00 - ready to start, 01 - counter is being incremented, 10 - scheduling done, 11 - end of processing
    
    constant window_cycle : integer := 47;
    constant full_cycle : integer := 63;
begin

    counter_gen : process(i_clk, i_send_frame)
    begin
        if rising_edge(i_clk) then
            if (schedule_cnt < 0) then
                status <= "0001";
                if (i_send_frame = '1') then
                    schedule_cnt <= 0;
                end if;
            elsif (schedule_cnt <= window_cycle) then
                status <= "0010";
                schedule_cnt <= schedule_cnt + 1;
            elsif (schedule_cnt <= full_cycle) then
                status <= "0100";
                schedule_cnt <= schedule_cnt + 1;
            else
                status <= "1000";
                schedule_cnt <= -1;
            end if;
        end if;
    end process;

    main_proc : process(i_clk, i_mess_block)
        variable sig0_0, sig0_1, sig0_2 : std_logic_vector(31 downto 0);
        variable sig0 : unsigned(31 downto 0);
        variable sig1_0, sig1_1, sig1_2 : std_logic_vector(31 downto 0);
        variable sig1 : unsigned(31 downto 0);
        
        variable sum0_0, sum0_1, sum0_2 : std_logic_vector(31 downto 0);
        variable sum0 : unsigned(31 downto 0);
        variable sum1_0, sum1_1, sum1_2 : std_logic_vector(31 downto 0);
        variable sum1 : unsigned(31 downto 0);
        
        variable choice, majority, temp1, temp2 : unsigned(31 downto 0);
    begin
        if rising_edge(i_clk) then
            if (schedule_cnt < 0) then
                working_vars <= (
                    h => C_INIT_HASHES.h7,
                    g => C_INIT_HASHES.h6,
                    f => C_INIT_HASHES.h5,
                    e => C_INIT_HASHES.h4,
                    d => C_INIT_HASHES.h3,
                    c => C_INIT_HASHES.h2,
                    b => C_INIT_HASHES.h1,
                    a => C_INIT_HASHES.h0);
                    
                for i in 0 to 15 loop
                    schedule_bank(i) <= unsigned(i_mess_block(32*(i+1)-1 downto i*32));
                end loop;
                    
            elsif (schedule_cnt <= full_cycle) then
                if (schedule_cnt <= window_cycle) then
                    sig0_0 := std_logic_vector(rotate_right(schedule_bank(schedule_cnt + 1),7));
                    sig0_1 := std_logic_vector(rotate_right(schedule_bank(schedule_cnt + 1),18));
                    sig0_2 := std_logic_vector(shift_right(schedule_bank(schedule_cnt + 1),3));
                    sig0   := unsigned(sig0_0 xor sig0_1 xor sig0_2);
                    
                    sig1_0 := std_logic_vector(rotate_right(schedule_bank(schedule_cnt + 14),17));
                    sig1_1 := std_logic_vector(rotate_right(schedule_bank(schedule_cnt + 14),19));
                    sig1_2 := std_logic_vector(shift_right(schedule_bank(schedule_cnt + 14),10));
                    sig1   := unsigned(sig1_0 xor sig1_1 xor sig1_2);
                    
                    schedule_bank(schedule_cnt + 16) <= schedule_bank(schedule_cnt) + sig0 + schedule_bank(schedule_cnt + 9) + sig1;
                end if;
                
                sum0_0 := std_logic_vector(rotate_right(working_vars.a,2));
                sum0_1 := std_logic_vector(rotate_right(working_vars.a,13));
                sum0_2 := std_logic_vector(rotate_right(working_vars.a,22));
                sum0 := unsigned(sum0_0 xor sum0_1 xor sum0_2);
                
                sum1_0 := std_logic_vector(rotate_right(working_vars.e,6));
                sum1_1 := std_logic_vector(rotate_right(working_vars.e,11));
                sum1_2 := std_logic_vector(rotate_right(working_vars.e,25));
                sum1 := unsigned(sum1_0 xor sum1_1 xor sum1_2);
                
                choice := unsigned((std_logic_vector(working_vars.e) and std_logic_vector(working_vars.f)) xor 
                                  ((not std_logic_vector(working_vars.e)) and std_logic_vector(working_vars.g)));
                                  
                majority := unsigned((std_logic_vector(working_vars.a) and std_logic_vector(working_vars.b)) xor 
                                     (std_logic_vector(working_vars.a) and std_logic_vector(working_vars.c)) xor 
                                     (std_logic_vector(working_vars.b) and std_logic_vector(working_vars.c)));
                                     
                temp1 := working_vars.h + sum1 + choice + C_K_SHA256_CONSTS(schedule_cnt) + schedule_bank(schedule_cnt);
                
                temp2 := majority + sum0;
                
--                report "Sum0: " & integer'image(to_integer(sum0));
--                report "Sum1: " & integer'image(to_integer(sum1));
--                report "Choice: " & integer'image(to_integer(choice));
--                report "Majority: " & integer'image(to_integer(majority));
--                report "Temp1: " & integer'image(to_integer(temp1));
--                report "Temp2: " & integer'image(to_integer(temp2));
                
                working_vars <= (
                    h => working_vars.g,
                    g => working_vars.f,
                    f => working_vars.e,
                    e => working_vars.d + temp1,
                    d => working_vars.c,
                    c => working_vars.b,
                    b => working_vars.a,
                    a => temp1 + temp2);
            
            else
                complete_hash(255 downto 224) <= C_INIT_HASHES.h0 + working_vars.a;
                complete_hash(223 downto 192) <= C_INIT_HASHES.h1 + working_vars.b;
                complete_hash(191 downto 160) <= C_INIT_HASHES.h2 + working_vars.c;
                complete_hash(159 downto 128) <= C_INIT_HASHES.h3 + working_vars.d;
                complete_hash(127 downto 96)  <= C_INIT_HASHES.h4 + working_vars.e;
                complete_hash(95 downto 64)   <= C_INIT_HASHES.h5 + working_vars.f;
                complete_hash(63 downto 32)   <= C_INIT_HASHES.h6 + working_vars.g;
                complete_hash(31 downto 0)    <= C_INIT_HASHES.h7 + working_vars.h;
            end if;
        end if; 
    end process;

    o_hash <= std_logic_vector(complete_hash);
    o_rvalid <= status(3);
    o_wvalid <= status(0);

end Behavioral;
