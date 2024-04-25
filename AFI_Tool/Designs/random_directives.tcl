#2024/03/26 16:27:21:090
set_directive_inline "G256_inv_1"
set_directive_allocation -limit 1 -type operation "Sbox_1" shl
set_directive_allocation -limit 1 -type operation "G4_sq_2" lshr
set_directive_allocation -limit 1 -type operation "G4_mul_2" add
set_directive_allocation -limit 1 -type operation "G4_scl_N2_1" add
set_directive_expression_balance -off "G16_mul_2"
set_directive_allocation -limit 1 -type operation "G4_sq_1" shl
set_directive_expression_balance -off "G16_sq_scl_2"
set_directive_expression_balance -off "G4_scl_N2_2"
set_directive_expression_balance -off "G256_newbasis_1"
set_directive_allocation -limit 1 -type operation "G256_inv_2" icmp 
set_directive_pipeline -enable_flush "G4_mul_1"
set_directive_pipeline -II 1 "Sbox_2"
set_directive_allocation -limit 1 -type operation "G256_newbasis_2" add
set_directive_inline -recursive "G16_sq_scl_1"
set_directive_allocation -limit 1 -type function "G16_mul_1" G16_mul_1
set_directive_allocation -limit 1 -type operation "G16_inv_1" lshr
set_directive_allocation -limit 1 -type function "G4_scl_N_2" G4_scl_N_2
set_directive_inline -region -off "G16_inv_2"
set_directive_inline -off "G4_scl_N_1"
set_directive_dataflow "G256_newbasis_1\label_0"
set_directive_unroll -factor 5 "G256_newbasis_2\label_0"
