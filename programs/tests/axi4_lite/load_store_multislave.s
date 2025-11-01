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

    li      x4, 0x00000000       # Slave 0 base address
    lw      x5, 4(x4)            # Load value at 0x0000_0004 into x5
    lw      x6, 4(x2)            # Load value at 0x0000_0104 into x6

    li      x7, 0xDEADBEEF
loop:
    j loop
