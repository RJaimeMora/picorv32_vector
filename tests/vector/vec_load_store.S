.section .data
    # Datos fuente
    source_data:    .word 0xFFFFFFFF, 0xAAAAAAAA, 0x12345678, 0x22222222
    source_data2:   .word 0x00000001, 0x12345678, 0xABABABAB, 0xFEDCBA98
    
    # Espacio para resultados (alineación a 16 bytes)
    .align 4
    dest_add:       .word 0, 0, 0, 0    # Para suma vectorial
    .align 4
    dest_mul:       .word 0, 0, 0, 0    # Para multiplicación
    .align 4
    dest_and:       .word 0, 0, 0, 0    # Para AND
    .align 4
    dest_or:        .word 0, 0, 0, 0    # Para OR
    .align 4
    dest_xor:       .word 0, 0, 0, 0    # Para XOR

.text
.global _start; _start:
    # Configurar CSR
    csrr t0, mstatus      
    li t1, 0x0000000000000600 
    or t0, t0, t1         
    csrw mstatus, t0      
    
    nop
    # Configurar longitud vectorial
    li t0, 4                  
    vsetvli t0, t0, e32, m1    

    # Cargar vectores
    la t1, source_data        
    vle32.v v1, (t1)          
    
    la t2, source_data2
    vle32.v v2, (t2)

    # Operaciones y almacenamiento
    vadd.vv v3, v1, v2        # Suma
    la t3, dest_add           # Cargar dirección destino para suma
    vse32.v v3, (t3)          # Almacenar suma

    vmul.vv v4, v1, v2        # Multiplicación
    la t3, dest_mul
    vse32.v v4, (t3)          # Almacenar multiplicación

    vand.vv v5, v1, v2        # AND
    la t3, dest_and
    vse32.v v5, (t3)          # Almacenar AND

    vor.vv  v6, v1, v2        # OR
    la t3, dest_or
    vse32.v v6, (t3)          # Almacenar OR

    vxor.vv v7, v1, v2        # XOR
    la t3, dest_xor
    vse32.v v7, (t3)          # Almacenar XOR

    # Finalizar simulación
    li t0, 1
    la t1, tohost
    sw t0, 0(t1)
    1: j 1b

# Sección para comunicación con Spike
.data
.align 6; .global tohost;   tohost:   .dword 0
.align 6; .global fromhost; fromhost: .dword 0
