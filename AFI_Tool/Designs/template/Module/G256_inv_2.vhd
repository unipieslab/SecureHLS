-- ==============================================================
-- RTL generated by Vivado(TM) HLS - High-Level Synthesis from C, C++ and OpenCL
-- Version: 2020.1
-- Copyright (C) 1986-2020 Xilinx, Inc. All Rights Reserved.
-- 
-- ===========================================================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity G256_inv_2 is
port (
    ap_clk : IN STD_LOGIC;
    ap_rst : IN STD_LOGIC;
    ap_start : IN STD_LOGIC;
    ap_done : OUT STD_LOGIC;
    ap_idle : OUT STD_LOGIC;
    ap_ready : OUT STD_LOGIC;
    x : IN STD_LOGIC_VECTOR (7 downto 0);
    ap_return : OUT STD_LOGIC_VECTOR (7 downto 0) );
end;


architecture behav of G256_inv_2 is 
    constant ap_const_logic_1 : STD_LOGIC := '1';
    constant ap_const_logic_0 : STD_LOGIC := '0';
    constant ap_ST_fsm_state1 : STD_LOGIC_VECTOR (2 downto 0) := "001";
    constant ap_ST_fsm_state2 : STD_LOGIC_VECTOR (2 downto 0) := "010";
    constant ap_ST_fsm_state3 : STD_LOGIC_VECTOR (2 downto 0) := "100";
    constant ap_const_lv32_0 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000000";
    constant ap_const_lv32_1 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000001";
    constant ap_const_lv32_2 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000010";
    constant ap_const_lv32_4 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000100";
    constant ap_const_lv32_7 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000111";
    constant ap_const_lv32_5 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000101";
    constant ap_const_lv32_3 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000011";
    constant ap_const_boolean_1 : BOOLEAN := true;

    signal ap_CS_fsm : STD_LOGIC_VECTOR (2 downto 0) := "001";
    attribute fsm_encoding : string;
    attribute fsm_encoding of ap_CS_fsm : signal is "none";
    signal ap_CS_fsm_state1 : STD_LOGIC;
    attribute fsm_encoding of ap_CS_fsm_state1 : signal is "none";
    signal trunc_ln_fu_60_p4 : STD_LOGIC_VECTOR (3 downto 0);
    signal trunc_ln_reg_447 : STD_LOGIC_VECTOR (3 downto 0);
    signal b_fu_75_p1 : STD_LOGIC_VECTOR (3 downto 0);
    signal b_reg_452 : STD_LOGIC_VECTOR (3 downto 0);
    signal trunc_ln233_fu_90_p1 : STD_LOGIC_VECTOR (0 downto 0);
    signal trunc_ln233_reg_457 : STD_LOGIC_VECTOR (0 downto 0);
    signal tmp_3_fu_94_p3 : STD_LOGIC_VECTOR (0 downto 0);
    signal tmp_3_reg_462 : STD_LOGIC_VECTOR (0 downto 0);
    signal a_5_fu_108_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal a_5_reg_467 : STD_LOGIC_VECTOR (0 downto 0);
    signal trunc_ln235_fu_178_p1 : STD_LOGIC_VECTOR (0 downto 0);
    signal trunc_ln235_reg_473 : STD_LOGIC_VECTOR (0 downto 0);
    signal d_3_reg_480 : STD_LOGIC_VECTOR (0 downto 0);
    signal tmp_6_reg_488 : STD_LOGIC_VECTOR (0 downto 0);
    signal tmp_7_reg_494 : STD_LOGIC_VECTOR (0 downto 0);
    signal tmp_8_reg_501 : STD_LOGIC_VECTOR (0 downto 0);
    signal xor_ln150_4_fu_389_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal xor_ln150_4_reg_510 : STD_LOGIC_VECTOR (0 downto 0);
    signal ap_CS_fsm_state2 : STD_LOGIC;
    attribute fsm_encoding of ap_CS_fsm_state2 : signal is "none";
    signal xor_ln150_2_fu_395_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal xor_ln150_2_reg_515 : STD_LOGIC_VECTOR (0 downto 0);
    signal q_4_fu_417_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal q_4_reg_520 : STD_LOGIC_VECTOR (0 downto 0);
    signal xor_ln150_3_fu_423_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal xor_ln150_3_reg_525 : STD_LOGIC_VECTOR (0 downto 0);
    signal grp_G16_mul_2_fu_48_ap_ready : STD_LOGIC;
    signal grp_G16_mul_2_fu_48_x : STD_LOGIC_VECTOR (3 downto 0);
    signal grp_G16_mul_2_fu_48_y : STD_LOGIC_VECTOR (3 downto 0);
    signal grp_G16_mul_2_fu_48_ap_return : STD_LOGIC_VECTOR (3 downto 0);
    signal q_G16_mul_2_fu_54_ap_ready : STD_LOGIC;
    signal q_G16_mul_2_fu_54_x : STD_LOGIC_VECTOR (3 downto 0);
    signal q_G16_mul_2_fu_54_ap_return : STD_LOGIC_VECTOR (3 downto 0);
    signal e_2_fu_429_p5 : STD_LOGIC_VECTOR (3 downto 0);
    signal ap_CS_fsm_state3 : STD_LOGIC;
    attribute fsm_encoding of ap_CS_fsm_state3 : signal is "none";
    signal trunc_ln2_fu_80_p4 : STD_LOGIC_VECTOR (1 downto 0);
    signal trunc_ln232_fu_71_p1 : STD_LOGIC_VECTOR (1 downto 0);
    signal xor_ln233_fu_102_p2 : STD_LOGIC_VECTOR (3 downto 0);
    signal trunc_ln3_fu_120_p4 : STD_LOGIC_VECTOR (1 downto 0);
    signal xor_ln206_fu_114_p2 : STD_LOGIC_VECTOR (1 downto 0);
    signal tmp_4_fu_136_p3 : STD_LOGIC_VECTOR (0 downto 0);
    signal xor_ln172_fu_144_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal xor_ln180_fu_130_p2 : STD_LOGIC_VECTOR (1 downto 0);
    signal tmp_fu_158_p4 : STD_LOGIC_VECTOR (1 downto 0);
    signal c_fu_168_p4 : STD_LOGIC_VECTOR (3 downto 0);
    signal trunc_ln235_1_fu_182_p1 : STD_LOGIC_VECTOR (1 downto 0);
    signal or_ln1_fu_150_p3 : STD_LOGIC_VECTOR (1 downto 0);
    signal xor_ln235_fu_186_p2 : STD_LOGIC_VECTOR (3 downto 0);
    signal a_fu_206_p4 : STD_LOGIC_VECTOR (1 downto 0);
    signal b_1_fu_192_p2 : STD_LOGIC_VECTOR (1 downto 0);
    signal xor_ln218_fu_216_p2 : STD_LOGIC_VECTOR (1 downto 0);
    signal d_1_fu_246_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal a_3_fu_250_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal q_2_fu_255_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal xor_ln147_2_fu_276_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal xor_ln147_1_fu_271_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal xor_ln147_fu_267_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal xor_ln147_3_fu_280_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal e_fu_285_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal and_ln149_fu_301_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal and_ln148_1_fu_295_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal and_ln148_fu_291_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal xor_ln150_fu_312_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal q_3_fu_306_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal d_2_fu_318_p3 : STD_LOGIC_VECTOR (1 downto 0);
    signal c_1_fu_260_p3 : STD_LOGIC_VECTOR (1 downto 0);
    signal xor_ln220_fu_326_p2 : STD_LOGIC_VECTOR (1 downto 0);
    signal xor_ln143_fu_340_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal a_4_fu_332_p3 : STD_LOGIC_VECTOR (0 downto 0);
    signal xor_ln148_fu_352_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal xor_ln147_4_fu_346_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal xor_ln148_1_fu_356_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal xor_ln150_1_fu_373_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal and_ln150_1_fu_383_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal and_ln150_fu_378_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal and_ln149_2_fu_367_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal and_ln149_1_fu_361_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal e_1_fu_401_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal and_ln149_3_fu_412_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal and_ln148_2_fu_407_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal ap_NS_fsm : STD_LOGIC_VECTOR (2 downto 0);

    component G16_mul_2 IS
    port (
        ap_ready : OUT STD_LOGIC;
        x : IN STD_LOGIC_VECTOR (3 downto 0);
        y : IN STD_LOGIC_VECTOR (3 downto 0);
        ap_return : OUT STD_LOGIC_VECTOR (3 downto 0) );
    end component;



begin
    grp_G16_mul_2_fu_48 : component G16_mul_2
    port map (
        ap_ready => grp_G16_mul_2_fu_48_ap_ready,
        x => grp_G16_mul_2_fu_48_x,
        y => grp_G16_mul_2_fu_48_y,
        ap_return => grp_G16_mul_2_fu_48_ap_return);

    q_G16_mul_2_fu_54 : component G16_mul_2
    port map (
        ap_ready => q_G16_mul_2_fu_54_ap_ready,
        x => q_G16_mul_2_fu_54_x,
        y => trunc_ln_reg_447,
        ap_return => q_G16_mul_2_fu_54_ap_return);





    ap_CS_fsm_assign_proc : process(ap_clk)
    begin
        if (ap_clk'event and ap_clk =  '1') then
            if (ap_rst = '1') then
                ap_CS_fsm <= ap_ST_fsm_state1;
            else
                ap_CS_fsm <= ap_NS_fsm;
            end if;
        end if;
    end process;

    process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if (((ap_start = ap_const_logic_1) and (ap_const_logic_1 = ap_CS_fsm_state1))) then
                a_5_reg_467 <= a_5_fu_108_p2;
                b_reg_452 <= b_fu_75_p1;
                d_3_reg_480 <= xor_ln235_fu_186_p2(2 downto 2);
                tmp_3_reg_462 <= x(4 downto 4);
                tmp_6_reg_488 <= xor_ln218_fu_216_p2(1 downto 1);
                tmp_7_reg_494 <= xor_ln235_fu_186_p2(3 downto 3);
                tmp_8_reg_501 <= b_1_fu_192_p2(1 downto 1);
                trunc_ln233_reg_457 <= trunc_ln233_fu_90_p1;
                trunc_ln235_reg_473 <= trunc_ln235_fu_178_p1;
                trunc_ln_reg_447 <= x(7 downto 4);
            end if;
        end if;
    end process;
    process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if ((ap_const_logic_1 = ap_CS_fsm_state2)) then
                q_4_reg_520 <= q_4_fu_417_p2;
                xor_ln150_2_reg_515 <= xor_ln150_2_fu_395_p2;
                xor_ln150_3_reg_525 <= xor_ln150_3_fu_423_p2;
                xor_ln150_4_reg_510 <= xor_ln150_4_fu_389_p2;
            end if;
        end if;
    end process;

    ap_NS_fsm_assign_proc : process (ap_start, ap_CS_fsm, ap_CS_fsm_state1)
    begin
        case ap_CS_fsm is
            when ap_ST_fsm_state1 => 
                if (((ap_start = ap_const_logic_1) and (ap_const_logic_1 = ap_CS_fsm_state1))) then
                    ap_NS_fsm <= ap_ST_fsm_state2;
                else
                    ap_NS_fsm <= ap_ST_fsm_state1;
                end if;
            when ap_ST_fsm_state2 => 
                ap_NS_fsm <= ap_ST_fsm_state3;
            when ap_ST_fsm_state3 => 
                ap_NS_fsm <= ap_ST_fsm_state1;
            when others =>  
                ap_NS_fsm <= "XXX";
        end case;
    end process;
    a_3_fu_250_p2 <= (d_3_reg_480 xor d_1_fu_246_p2);
    a_4_fu_332_p3 <= xor_ln220_fu_326_p2(1 downto 1);
    a_5_fu_108_p2 <= (trunc_ln233_fu_90_p1 xor tmp_3_fu_94_p3);
    a_fu_206_p4 <= xor_ln235_fu_186_p2(3 downto 2);
    and_ln148_1_fu_295_p2 <= (xor_ln147_fu_267_p2 and xor_ln147_3_fu_280_p2);
    and_ln148_2_fu_407_p2 <= (xor_ln143_fu_340_p2 and tmp_7_reg_494);
    and_ln148_fu_291_p2 <= (tmp_8_reg_501 and tmp_7_reg_494);
    and_ln149_1_fu_361_p2 <= (d_1_fu_246_p2 and a_4_fu_332_p3);
    and_ln149_2_fu_367_p2 <= (xor_ln147_4_fu_346_p2 and xor_ln147_1_fu_271_p2);
    and_ln149_3_fu_412_p2 <= (d_3_reg_480 and a_4_fu_332_p3);
    and_ln149_fu_301_p2 <= (d_3_reg_480 and d_1_fu_246_p2);
    and_ln150_1_fu_383_p2 <= (xor_ln150_1_fu_373_p2 and xor_ln147_4_fu_346_p2);
    and_ln150_fu_378_p2 <= (xor_ln143_fu_340_p2 and tmp_8_reg_501);
    ap_CS_fsm_state1 <= ap_CS_fsm(0);
    ap_CS_fsm_state2 <= ap_CS_fsm(1);
    ap_CS_fsm_state3 <= ap_CS_fsm(2);

    ap_done_assign_proc : process(ap_start, ap_CS_fsm_state1, ap_CS_fsm_state3)
    begin
        if (((ap_const_logic_1 = ap_CS_fsm_state3) or ((ap_start = ap_const_logic_0) and (ap_const_logic_1 = ap_CS_fsm_state1)))) then 
            ap_done <= ap_const_logic_1;
        else 
            ap_done <= ap_const_logic_0;
        end if; 
    end process;


    ap_idle_assign_proc : process(ap_start, ap_CS_fsm_state1)
    begin
        if (((ap_start = ap_const_logic_0) and (ap_const_logic_1 = ap_CS_fsm_state1))) then 
            ap_idle <= ap_const_logic_1;
        else 
            ap_idle <= ap_const_logic_0;
        end if; 
    end process;


    ap_ready_assign_proc : process(ap_CS_fsm_state3)
    begin
        if ((ap_const_logic_1 = ap_CS_fsm_state3)) then 
            ap_ready <= ap_const_logic_1;
        else 
            ap_ready <= ap_const_logic_0;
        end if; 
    end process;

    ap_return <= (grp_G16_mul_2_fu_48_ap_return & q_G16_mul_2_fu_54_ap_return);
    b_1_fu_192_p2 <= (trunc_ln235_1_fu_182_p1 xor or_ln1_fu_150_p3);
    b_fu_75_p1 <= x(4 - 1 downto 0);
    c_1_fu_260_p3 <= (tmp_6_reg_488 & q_2_fu_255_p2);
    c_fu_168_p4 <= ((tmp_fu_158_p4 & xor_ln172_fu_144_p2) & a_5_fu_108_p2);
    d_1_fu_246_p2 <= (trunc_ln235_reg_473 xor a_5_reg_467);
    d_2_fu_318_p3 <= (xor_ln150_fu_312_p2 & q_3_fu_306_p2);
    e_1_fu_401_p2 <= (xor_ln147_fu_267_p2 and xor_ln147_4_fu_346_p2);
    e_2_fu_429_p5 <= (((xor_ln150_4_reg_510 & xor_ln150_2_reg_515) & xor_ln150_3_reg_525) & q_4_reg_520);
    e_fu_285_p2 <= (xor_ln147_fu_267_p2 and xor_ln147_1_fu_271_p2);

    grp_G16_mul_2_fu_48_x_assign_proc : process(ap_CS_fsm_state1, x, e_2_fu_429_p5, ap_CS_fsm_state3)
    begin
        if ((ap_const_logic_1 = ap_CS_fsm_state3)) then 
            grp_G16_mul_2_fu_48_x <= e_2_fu_429_p5;
        elsif ((ap_const_logic_1 = ap_CS_fsm_state1)) then 
            grp_G16_mul_2_fu_48_x <= x(7 downto 4);
        else 
            grp_G16_mul_2_fu_48_x <= "XXXX";
        end if; 
    end process;


    grp_G16_mul_2_fu_48_y_assign_proc : process(ap_CS_fsm_state1, b_fu_75_p1, b_reg_452, ap_CS_fsm_state3)
    begin
        if ((ap_const_logic_1 = ap_CS_fsm_state3)) then 
            grp_G16_mul_2_fu_48_y <= b_reg_452;
        elsif ((ap_const_logic_1 = ap_CS_fsm_state1)) then 
            grp_G16_mul_2_fu_48_y <= b_fu_75_p1;
        else 
            grp_G16_mul_2_fu_48_y <= "XXXX";
        end if; 
    end process;

    or_ln1_fu_150_p3 <= (xor_ln172_fu_144_p2 & a_5_fu_108_p2);
    q_2_fu_255_p2 <= (tmp_6_reg_488 xor a_3_fu_250_p2);
    q_3_fu_306_p2 <= (e_fu_285_p2 xor and_ln149_fu_301_p2);
    q_4_fu_417_p2 <= (e_1_fu_401_p2 xor and_ln149_3_fu_412_p2);
    q_G16_mul_2_fu_54_x <= (((xor_ln150_4_reg_510 & xor_ln150_2_reg_515) & xor_ln150_3_reg_525) & q_4_reg_520);
    tmp_3_fu_94_p3 <= x(4 downto 4);
    tmp_4_fu_136_p3 <= xor_ln206_fu_114_p2(1 downto 1);
    
    tmp_fu_158_p4_proc : process(xor_ln180_fu_130_p2)
    variable vlo_cpy : STD_LOGIC_VECTOR(2+32 - 1 downto 0);
    variable vhi_cpy : STD_LOGIC_VECTOR(2+32 - 1 downto 0);
    variable v0_cpy : STD_LOGIC_VECTOR(2 - 1 downto 0);
    variable tmp_fu_158_p4_i : integer;
    variable section : STD_LOGIC_VECTOR(2 - 1 downto 0);
    variable tmp_mask : STD_LOGIC_VECTOR(2 - 1 downto 0);
    variable resvalue, res_value, res_mask : STD_LOGIC_VECTOR(2 - 1 downto 0);
    begin
        vlo_cpy := (others => '0');
        vlo_cpy(1 - 1 downto 0) := ap_const_lv32_1(1 - 1 downto 0);
        vhi_cpy := (others => '0');
        vhi_cpy(1 - 1 downto 0) := ap_const_lv32_0(1 - 1 downto 0);
        v0_cpy := xor_ln180_fu_130_p2;
        if (vlo_cpy(1 - 1 downto 0) > vhi_cpy(1 - 1 downto 0)) then
            vhi_cpy(1-1 downto 0) := std_logic_vector(2-1-unsigned(ap_const_lv32_0(1-1 downto 0)));
            vlo_cpy(1-1 downto 0) := std_logic_vector(2-1-unsigned(ap_const_lv32_1(1-1 downto 0)));
            for tmp_fu_158_p4_i in 0 to 2-1 loop
                v0_cpy(tmp_fu_158_p4_i) := xor_ln180_fu_130_p2(2-1-tmp_fu_158_p4_i);
            end loop;
        end if;
        res_value := std_logic_vector(shift_right(unsigned(v0_cpy), to_integer(unsigned('0' & vlo_cpy(1-1 downto 0)))));

        section := (others=>'0');
        section(1-1 downto 0) := std_logic_vector(unsigned(vhi_cpy(1-1 downto 0)) - unsigned(vlo_cpy(1-1 downto 0)));
        tmp_mask := (others => '1');
        res_mask := std_logic_vector(shift_left(unsigned(tmp_mask),to_integer(unsigned('0' & section(2-1 downto 0)))));
        res_mask := res_mask(2-2 downto 0) & '0';
        resvalue := res_value and not res_mask;
        tmp_fu_158_p4 <= resvalue(2-1 downto 0);
    end process;

    trunc_ln232_fu_71_p1 <= x(2 - 1 downto 0);
    trunc_ln233_fu_90_p1 <= x(1 - 1 downto 0);
    trunc_ln235_1_fu_182_p1 <= grp_G16_mul_2_fu_48_ap_return(2 - 1 downto 0);
    trunc_ln235_fu_178_p1 <= grp_G16_mul_2_fu_48_ap_return(1 - 1 downto 0);
    trunc_ln2_fu_80_p4 <= x(5 downto 4);
    trunc_ln3_fu_120_p4 <= xor_ln233_fu_102_p2(3 downto 2);
    trunc_ln_fu_60_p4 <= x(7 downto 4);
    xor_ln143_fu_340_p2 <= (q_3_fu_306_p2 xor q_2_fu_255_p2);
    xor_ln147_1_fu_271_p2 <= (tmp_8_reg_501 xor d_1_fu_246_p2);
    xor_ln147_2_fu_276_p2 <= (tmp_8_reg_501 xor a_5_reg_467);
    xor_ln147_3_fu_280_p2 <= (xor_ln147_2_fu_276_p2 xor trunc_ln235_reg_473);
    xor_ln147_4_fu_346_p2 <= (xor_ln143_fu_340_p2 xor a_4_fu_332_p3);
    xor_ln147_fu_267_p2 <= (tmp_7_reg_494 xor d_3_reg_480);
    xor_ln148_1_fu_356_p2 <= (xor_ln148_fu_352_p2 xor tmp_3_reg_462);
    xor_ln148_fu_352_p2 <= (trunc_ln235_reg_473 xor trunc_ln233_reg_457);
    xor_ln150_1_fu_373_p2 <= (xor_ln148_1_fu_356_p2 xor tmp_8_reg_501);
    xor_ln150_2_fu_395_p2 <= (and_ln149_2_fu_367_p2 xor and_ln149_1_fu_361_p2);
    xor_ln150_3_fu_423_p2 <= (e_1_fu_401_p2 xor and_ln148_2_fu_407_p2);
    xor_ln150_4_fu_389_p2 <= (and_ln150_fu_378_p2 xor and_ln150_1_fu_383_p2);
    xor_ln150_fu_312_p2 <= (and_ln148_fu_291_p2 xor and_ln148_1_fu_295_p2);
    xor_ln172_fu_144_p2 <= (tmp_4_fu_136_p3 xor a_5_fu_108_p2);
    xor_ln180_fu_130_p2 <= (xor_ln206_fu_114_p2 xor trunc_ln3_fu_120_p4);
    xor_ln206_fu_114_p2 <= (trunc_ln2_fu_80_p4 xor trunc_ln232_fu_71_p1);
    xor_ln218_fu_216_p2 <= (b_1_fu_192_p2 xor a_fu_206_p4);
    xor_ln220_fu_326_p2 <= (d_2_fu_318_p3 xor c_1_fu_260_p3);
    xor_ln233_fu_102_p2 <= (trunc_ln_fu_60_p4 xor b_fu_75_p1);
    xor_ln235_fu_186_p2 <= (grp_G16_mul_2_fu_48_ap_return xor c_fu_168_p4);
end behav;
