.section .text
.global _start
_start:

    # CSR
    csrr t0, mstatus      // Read mstatus into t0 
    li t1, 0x600 // Create a mask for the vs field (bits 13-12) 
    or t0, t0, t1         // Set the vs field to 11 (Dirty) 
    csrw mstatus, t0      // Write the modified value back to mstatus
    
    li a1, 5
    li a2, 3
    li a3, 10
    li a4, 15
    li a5, 1
    li a6, 8
    
    div s5, a3, a1
    mul s4, a1, a3
    
    # Configuración inicial
    li t0, 16
    vsetvli a0, t0, e8, m1, tu, mu

    vmv.v.x v1, a1
    vmv.v.x v2, a2
    
    # Cambio de configuración
    li t0, 8
    vsetvli a0, t0, e16, m1, tu, mu
    
    vmv.v.x v3, a3
    vmv.v.x v4, a4
    
    # Cambio de configuración
    li t0, 4
    vsetvli a0, t0, e32, m1, tu, mu
    
    vmv.v.x v5, a5
    vmv.v.x v6, a6
    
    vadd.vv v7, v1, v2
    vsub.vv v8, v1, v3
    
    # Exit
    li t0, 1
    la t1, tohost
    sw t0, 0(t1)
1:  j 1b

.data
.align 6; .global tohost;   tohost:   .dword 0
.align 6; .global fromhost; fromhost: .dword 0

