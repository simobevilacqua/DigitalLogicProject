library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity project_reti_logiche is
    port (
        i_clk   : in std_logic;
        i_rst   : in std_logic;
        i_start : in std_logic;
        i_w     : in std_logic;
        o_z0    : out std_logic_vector(7 downto 0) := (others => '0');
        o_z1    : out std_logic_vector(7 downto 0) := (others => '0');
        o_z2    : out std_logic_vector(7 downto 0) := (others => '0');
        o_z3    : out std_logic_vector(7 downto 0) := (others => '0');
        o_done  : out std_logic := '0';
        o_mem_addr : out std_logic_vector(15 downto 0) := (others => '0');
        i_mem_data : in std_logic_vector(7 downto 0);
        o_mem_we   : out std_logic := '0';
        o_mem_en   : out std_logic := '0'
    );
end project_reti_logiche;

architecture project_reti_logiche_arch of project_reti_logiche is

    type S is (READ_SEL1, READ_SEL0, READ_ADDR, ASK_MEM, READ_MEM, SERIALIZE);
    
    signal state_reg : S := READ_SEL1;                                      -- Stato corrente dell'FSM
    signal address_reg : std_logic_vector(15 downto 0) := (others => '0');  -- Indirizzo di memoria
    signal channel_reg : std_logic_vector(1 downto 0) := (others => '0');   -- Codice binario porta di uscita
    signal z0_reg : std_logic_vector(7 downto 0) := (others => '0');        -- Registro porta uscita o_z0
    signal z1_reg : std_logic_vector(7 downto 0) := (others => '0');        -- Registro porta uscita o_z1
    signal z2_reg : std_logic_vector(7 downto 0) := (others => '0');        -- Registro porta uscita o_z2
    signal z3_reg : std_logic_vector(7 downto 0) := (others => '0');        -- Registro porta uscita o_z3

begin

    fsm : process(i_clk, i_rst)
    begin

        if i_rst = '1' then     -- Reset asincrono dell'FSM
        
            -- Reset segnali interni
            z0_reg <= (others => '0');
            z1_reg <= (others => '0');
            z2_reg <= (others => '0');
            z3_reg <= (others => '0');
            address_reg <= (others => '0');
            channel_reg <= (others => '0');
            
            -- Reset segnali di output
            o_z0 <= (others => '0');
            o_z1 <= (others => '0');
            o_z2 <= (others => '0');
            o_z3 <= (others => '0');
            o_mem_we <= '0';
            o_mem_en <= '0';
            o_mem_addr <= (others => '0');
            o_done <= '0';

            -- Reset stato FSM
            state_reg <= READ_SEL1;
        
        elsif i_clk'event and i_clk = '1' then      -- Aggiornamento segnali sul fronte di salita del clock
        
            if state_reg = READ_SEL1 then
            
                -- Aggiornamento segnali interni
                channel_reg <= (others => '0');
                address_reg <= (others => '0');

                -- Aggiornamento segnali di output
                o_z0 <= (others => '0');
                o_z1 <= (others => '0');
                o_z2 <= (others => '0');
                o_z3 <= (others => '0');
                o_mem_we <= '0';
                o_mem_en <= '0';
                o_mem_addr <= (others => '0');
                o_done <= '0';
            
                if i_start = '1' then
                    -- Aggiornamento segnali interni
                    channel_reg(1) <= i_w;

                    -- Aggiornamento stato FSM
                    state_reg <= READ_SEL0;
                else
                    -- Aggiornamento stato FSM
                    state_reg <= READ_SEL1;
                end if;
            
            elsif state_reg = READ_SEL0 then
            
                -- Aggiornamento segnali interni
                channel_reg(0) <= i_w;

                -- Aggiornamento stato FSM
                state_reg <= READ_ADDR;
            
            elsif state_reg = READ_ADDR then
            
                if i_start = '0' then
                    -- Aggiornamento segnali di output
                    o_mem_en <= '1';
                    o_mem_addr <= address_reg;

                    -- Aggiornamento stato FSM
                    state_reg <= ASK_MEM;
                elsif i_start = '1' then
                    -- Aggiornamento segnali interni
                    address_reg(15 downto 0) <= address_reg(14 downto 0) & i_w;

                    -- Aggiornamento stato FSM
                    state_reg <= READ_ADDR;
                end if;
                        
            elsif state_reg = ASK_MEM then
                
                -- Aggiornamento segnali di output
                o_mem_en <= '0';
                
                -- Aggiornamento stato FSM
                state_reg <= READ_MEM;
                
            elsif state_reg = READ_MEM then
            
                -- Aggiornamento segnali interni
                if channel_reg = "00" then
                    z0_reg <= i_mem_data;
                elsif channel_reg = "01" then
                    z1_reg <= i_mem_data;
                elsif channel_reg = "10" then
                    z2_reg <= i_mem_data;
                else
                    z3_reg <= i_mem_data;
                end if;

                -- Aggiornamento stato FSM
                state_reg <= SERIALIZE;
            
            elsif state_reg = SERIALIZE then
            
                -- Aggiornamento segnali di output
                o_done <= '1';
                o_z0 <= z0_reg;
                o_z1 <= z1_reg;
                o_z2 <= z2_reg;
                o_z3 <= z3_reg;

                -- Aggiornamento stato FSM
                state_reg <= READ_SEL1;
            
            end if;
        end if;
    end process;

end project_reti_logiche_arch;
