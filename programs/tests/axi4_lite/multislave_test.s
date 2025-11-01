    .section .text
    .globl _start
_start:
    # Test Slave 0 (Base: 0x0000_0000)
    li      x1, 0x12345678       # Test value
    li      x2, 0x00000000       # Slave 0 base address
    sw      x1, 0(x2)            # Write to Slave 0
    lw      x3, 0(x2)            # Read back from Slave 0
    sw      x3, 4(x2)            # Store read-back value in next address

    # Test Slave 1 (Base: 0x0000_0100)
    li      x1, 0xA5A5A5A5       # Test value for Slave 1
    li      x2, 0x00000100       # Slave 1 base address
    sw      x1, 0(x2)            # Write to Slave 1
    lw      x3, 0(x2)            # Read back from Slave 1
    sw      x3, 4(x2)            # Store read-back value in next address

    # Test Slave 2 (Base: 0x0000_1000)
    li      x1, 0x98ABCDEF       # Test value for Slave 3
    li      x2, 0x00001000       # Slave 3 base address
    sb      x1, 0(x2)            # Write to Slave 3
    lbu     x4, 0(x2)            # Read back from Slave 3

    li      x5, 0xDEADBEEF   

loop:
    j loop
