.section .data
    # Data Section
    source_data:    .half 0xFFFF, 0x1111, 0xAAAA, 0x1111, 0x1234, 0x1111, 0x2222, 0x1111
    source_data2:   .half 0x0000, 0x0001, 0x1234, 0x5678, 0xABAB, 0xABAB, 0xFEDC, 0xBA98
    dest_data:      .align 8                     # Alineación para 4 elementos de 32 bits
                    .half 0, 0, 0, 0, 0, 0, 0, 0  # Espacio para datos resultantes

.text
.global _start; _start:
    # Configurar CSR
    csrr t0, mstatus      
    li t1, 0x0000000000000600 
    or t0, t0, t1         
    csrw mstatus, t0      
    
    nop
    # Inicializar longitud de registros vectoriales
    li t0, 8                  
    vsetvli t0, t0, e16, m1    

    # Cargar vectores desde memoria
    la t1, source_data        
    vle16.v v1, (t1)          
    
    la t2, source_data2
    vle16.v v2, (t2)

    # Operaciones vectoriales
    vadd.vv v3, v1, v2        # Suma
    vmul.vv v4, v1, v2        # Multiplicación
    vand.vv v5, v1, v2        # AND
    vor.vv  v6, v1, v2        # OR
    vxor.vv v7, v1, v2        # XOR

    # ********** NUEVO: Almacenar resultado en memoria **********
    la t3, dest_data          # Cargar dirección de destino
    vse16.v v3, (t3)          # Almacenar vector v3 en memoria

    # Finalizar simulación
    li t0, 1
    la t1, tohost
    sw t0, 0(t1)
    1: j 1b

# Exponer tohost/fromhost
.data
.align 6; .global tohost;   tohost:   .dword 0
.align 6; .global fromhost; fromhost: .dword 0
