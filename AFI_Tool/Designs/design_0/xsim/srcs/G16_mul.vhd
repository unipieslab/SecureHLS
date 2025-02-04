-- ==============================================================
-- RTL generated by Vivado(TM) HLS - High-Level Synthesis from C, C++ and OpenCL
-- Version: 2020.1
-- Copyright (C) 1986-2020 Xilinx, Inc. All Rights Reserved.
-- 
-- ===========================================================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity G16_mul is
port (
    ap_ready : OUT STD_LOGIC;
    x : IN STD_LOGIC_VECTOR (3 downto 0);
    y : IN STD_LOGIC_VECTOR (3 downto 0);
    ap_return : OUT STD_LOGIC_VECTOR (3 downto 0) );
end;


architecture behav of G16_mul is 
    constant ap_const_logic_1 : STD_LOGIC := '1';
    constant ap_const_boolean_1 : BOOLEAN := true;
    constant ap_const_lv32_2 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000010";
    constant ap_const_lv32_3 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000011";
    constant ap_const_lv32_1 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000001";
    constant ap_const_logic_0 : STD_LOGIC := '0';

    signal a_fu_34_p4 : STD_LOGIC_VECTOR (1 downto 0);
    signal b_fu_56_p1 : STD_LOGIC_VECTOR (1 downto 0);
    signal tmp_fu_44_p3 : STD_LOGIC_VECTOR (0 downto 0);
    signal trunc_ln71_fu_52_p1 : STD_LOGIC_VECTOR (0 downto 0);
    signal c_fu_60_p4 : STD_LOGIC_VECTOR (1 downto 0);
    signal d_fu_82_p1 : STD_LOGIC_VECTOR (1 downto 0);
    signal tmp_10_fu_70_p3 : STD_LOGIC_VECTOR (0 downto 0);
    signal d_5_fu_78_p1 : STD_LOGIC_VECTOR (0 downto 0);
    signal xor_ln74_2_fu_98_p2 : STD_LOGIC_VECTOR (1 downto 0);
    signal xor_ln74_fu_86_p2 : STD_LOGIC_VECTOR (1 downto 0);
    signal tmp_12_fu_118_p3 : STD_LOGIC_VECTOR (0 downto 0);
    signal xor_ln74_1_fu_92_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal tmp_11_fu_110_p3 : STD_LOGIC_VECTOR (0 downto 0);
    signal d_4_fu_104_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal xor_ln28_5_fu_132_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal xor_ln28_fu_126_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal e_fu_138_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal and_ln30_fu_150_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal and_ln29_fu_144_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal q_8_fu_156_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal q_6_fu_162_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal tmp_13_fu_176_p3 : STD_LOGIC_VECTOR (0 downto 0);
    signal tmp_14_fu_184_p3 : STD_LOGIC_VECTOR (0 downto 0);
    signal xor_ln28_7_fu_198_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal xor_ln28_6_fu_192_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal and_ln30_5_fu_210_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal and_ln31_fu_216_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal and_ln30_4_fu_204_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal xor_ln31_fu_222_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal xor_ln31_5_fu_228_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal tmp_16_fu_250_p3 : STD_LOGIC_VECTOR (0 downto 0);
    signal tmp_15_fu_242_p3 : STD_LOGIC_VECTOR (0 downto 0);
    signal xor_ln28_9_fu_264_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal xor_ln28_8_fu_258_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal e_4_fu_270_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal and_ln30_6_fu_282_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal and_ln29_3_fu_276_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal xor_ln31_6_fu_294_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal q_7_fu_288_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal or_ln1_fu_300_p3 : STD_LOGIC_VECTOR (1 downto 0);
    signal e_3_fu_168_p3 : STD_LOGIC_VECTOR (1 downto 0);
    signal or_ln76_1_fu_234_p3 : STD_LOGIC_VECTOR (1 downto 0);
    signal xor_ln78_fu_314_p2 : STD_LOGIC_VECTOR (1 downto 0);
    signal q_fu_308_p2 : STD_LOGIC_VECTOR (1 downto 0);


begin



    a_fu_34_p4 <= x(3 downto 2);
    and_ln29_3_fu_276_p2 <= (tmp_16_fu_250_p3 and tmp_15_fu_242_p3);
    and_ln29_fu_144_p2 <= (tmp_12_fu_118_p3 and tmp_11_fu_110_p3);
    and_ln30_4_fu_204_p2 <= (tmp_fu_44_p3 and tmp_10_fu_70_p3);
    and_ln30_5_fu_210_p2 <= (xor_ln28_7_fu_198_p2 and xor_ln28_6_fu_192_p2);
    and_ln30_6_fu_282_p2 <= (trunc_ln71_fu_52_p1 and d_5_fu_78_p1);
    and_ln30_fu_150_p2 <= (xor_ln74_1_fu_92_p2 and d_4_fu_104_p2);
    and_ln31_fu_216_p2 <= (tmp_14_fu_184_p3 and tmp_13_fu_176_p3);
    ap_ready <= ap_const_logic_1;
    ap_return <= (xor_ln78_fu_314_p2 & q_fu_308_p2);
    b_fu_56_p1 <= x(2 - 1 downto 0);
    c_fu_60_p4 <= y(3 downto 2);
    d_4_fu_104_p2 <= (tmp_10_fu_70_p3 xor d_5_fu_78_p1);
    d_5_fu_78_p1 <= y(1 - 1 downto 0);
    d_fu_82_p1 <= y(2 - 1 downto 0);
    e_3_fu_168_p3 <= (q_8_fu_156_p2 & q_6_fu_162_p2);
    e_4_fu_270_p2 <= (xor_ln28_9_fu_264_p2 and xor_ln28_8_fu_258_p2);
    e_fu_138_p2 <= (xor_ln28_fu_126_p2 and xor_ln28_5_fu_132_p2);
    or_ln1_fu_300_p3 <= (xor_ln31_6_fu_294_p2 & q_7_fu_288_p2);
    or_ln76_1_fu_234_p3 <= (xor_ln31_fu_222_p2 & xor_ln31_5_fu_228_p2);
    q_6_fu_162_p2 <= (and_ln30_fu_150_p2 xor and_ln29_fu_144_p2);
    q_7_fu_288_p2 <= (e_4_fu_270_p2 xor and_ln30_6_fu_282_p2);
    q_8_fu_156_p2 <= (e_fu_138_p2 xor and_ln30_fu_150_p2);
    q_fu_308_p2 <= (or_ln1_fu_300_p3 xor e_3_fu_168_p3);
    tmp_10_fu_70_p3 <= y(2 downto 2);
    tmp_11_fu_110_p3 <= xor_ln74_2_fu_98_p2(1 downto 1);
    tmp_12_fu_118_p3 <= xor_ln74_fu_86_p2(1 downto 1);
    tmp_13_fu_176_p3 <= x(3 downto 3);
    tmp_14_fu_184_p3 <= y(3 downto 3);
    tmp_15_fu_242_p3 <= y(1 downto 1);
    tmp_16_fu_250_p3 <= x(1 downto 1);
    tmp_fu_44_p3 <= x(2 downto 2);
    trunc_ln71_fu_52_p1 <= x(1 - 1 downto 0);
    xor_ln28_5_fu_132_p2 <= (tmp_11_fu_110_p3 xor d_4_fu_104_p2);
    xor_ln28_6_fu_192_p2 <= (tmp_fu_44_p3 xor tmp_13_fu_176_p3);
    xor_ln28_7_fu_198_p2 <= (tmp_14_fu_184_p3 xor tmp_10_fu_70_p3);
    xor_ln28_8_fu_258_p2 <= (trunc_ln71_fu_52_p1 xor tmp_16_fu_250_p3);
    xor_ln28_9_fu_264_p2 <= (tmp_15_fu_242_p3 xor d_5_fu_78_p1);
    xor_ln28_fu_126_p2 <= (xor_ln74_1_fu_92_p2 xor tmp_12_fu_118_p3);
    xor_ln31_5_fu_228_p2 <= (and_ln30_5_fu_210_p2 xor and_ln30_4_fu_204_p2);
    xor_ln31_6_fu_294_p2 <= (e_4_fu_270_p2 xor and_ln29_3_fu_276_p2);
    xor_ln31_fu_222_p2 <= (and_ln31_fu_216_p2 xor and_ln30_5_fu_210_p2);
    xor_ln74_1_fu_92_p2 <= (trunc_ln71_fu_52_p1 xor tmp_fu_44_p3);
    xor_ln74_2_fu_98_p2 <= (d_fu_82_p1 xor c_fu_60_p4);
    xor_ln74_fu_86_p2 <= (b_fu_56_p1 xor a_fu_34_p4);
    xor_ln78_fu_314_p2 <= (or_ln76_1_fu_234_p3 xor e_3_fu_168_p3);
end behav;
