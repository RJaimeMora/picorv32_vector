`timescale 1 ns / 1 ps

module testbench;
    reg clk = 1;
    reg resetn = 0;
    wire trap;

    always #5 clk = ~clk;

    initial begin
        if ($test$plusargs("vcd")) begin
            $dumpfile("testbench.vcd");
            $dumpvars(0, testbench);
        end
        repeat (10) @(posedge clk);
        resetn <= 1;
        repeat (2000) @(posedge clk);
        $display("Test completed. Trap: %b", trap);
        $finish;
    end

    wire mem_valid;
    wire mem_instr;
    reg  mem_ready;
    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire [3:0] mem_wstrb;
    reg [31:0] mem_rdata;

    /*always @(posedge clk) begin
        if (mem_valid && mem_ready) begin
            if (mem_instr)
                $display("ifetch 0x%08x: 0x%08x", mem_addr, mem_rdata);
            else if (mem_wstrb)
                $display("write  0x%08x: 0x%08x (wstrb=%b)", mem_addr, mem_wdata, mem_wstrb);
            else
                $display("read   0x%08x: 0x%08x", mem_addr, mem_rdata);
        end
    end*/
    
    always @(posedge clk) begin
        if (resetn && uut.vregs_write) begin
            $display("PC: %x, (0x%x) e%0d m1 l%0d v%0d 0x%x", 
            uut.reg_pc, uut.pcpi_insn, uut.SEW, uut.vcsr_vl, uut.latched_rd, uut.vregs_wdata);
        end else if (resetn && uut.cpuregs_write && (uut.vfunc3 == 3'b111)) begin
            $display("PC: %x, (0x%x) x%0d 0x%x, vtype: %x", 
            uut.reg_pc, uut.pcpi_insn, uut.latched_rd, uut.cpuregs_wrdata, uut.vcsr_vtype);
        end else if (resetn && uut.cpuregs_write) begin
            $display("PC: %x, (0x%x) x%0d 0x%x", 
            uut.reg_pc, uut.pcpi_insn, uut.latched_rd, uut.cpuregs_wrdata);
        end
    end

    picorv32 #(
        .ENABLE_VEC(1),          // Habilitar extensión vectorial
        //.VLEN(128),              // Longitud vectorial = 512 bits
        .ENABLE_MUL(1),
        .ENABLE_DIV(1)//,
        //.REGS_INIT_ZERO(1)
    ) uut (
        .clk         (clk        ),
        .resetn      (resetn     ),
        .trap        (trap       ),
        .mem_valid   (mem_valid  ),
        .mem_instr   (mem_instr  ),
        .mem_ready   (mem_ready  ),
        .mem_addr    (mem_addr   ),
        .mem_wdata   (mem_wdata  ),
        .mem_wstrb   (mem_wstrb  ),
        .mem_rdata   (mem_rdata  )
    );

    // Aumentamos una palabra más para incluir exactamente 0x10000
    parameter MEM_SIZE = 65536;
    reg [31:0] memory [0:MEM_SIZE*2];  // 16385 palabras (65540 bytes)
    
    initial begin
        integer i;
        // Inicializar toda la memoria a cero
        for (i = 0; i <= MEM_SIZE-1; i = i + 1) memory[i] = 32'h0;
        
        // Cargar instrucciones
        //$readmemh("instructionsh.mem", memory);
        $readmemb("instructions.mem", memory);
    end
    
    always @(posedge clk) begin
        mem_ready <= 0;
        if (mem_valid && !mem_ready) begin
            // Permitir acceso hasta la dirección 0x10000 (inclusive)
            if (mem_addr <= (MEM_SIZE*2)) begin
                mem_ready <= 1;
                mem_rdata <= memory[mem_addr >> 2];
                // Escritura por bytes utilizando máscaras de byte
                if (mem_wstrb[0]) memory[mem_addr >> 2][ 7: 0] <= mem_wdata[ 7: 0];
                if (mem_wstrb[1]) memory[mem_addr >> 2][15: 8] <= mem_wdata[15: 8];
                if (mem_wstrb[2]) memory[mem_addr >> 2][23:16] <= mem_wdata[23:16];
                if (mem_wstrb[3]) memory[mem_addr >> 2][31:24] <= mem_wdata[31:24];
            end
        end
    end


endmodule
