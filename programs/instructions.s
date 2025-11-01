.section .text
.global _start
_start:
    # Initialize registers
    addi x1, x0, 5        
    addi x2, x0, 3        
    addi x3, x0, 2        
    addi x4, x0, 1    
    addi x10, x0, 1023    

    # R-type computations
    add x5, x1, x2        
    sub x6, x1, x3        
    and x7, x2, x4        

    # Store/load
    sw x1, 0(x5)
    lw x8, 0(x5)          

    addi x9, x8, 10 # Check for internal stall here 

    sw x10, 4(x5)
    lw x11, 4(x5) 

        nop
        nop
        nop
        nop
    # Branch instructions
    beq x1, x2, skip1     

skip1:
    j skip1