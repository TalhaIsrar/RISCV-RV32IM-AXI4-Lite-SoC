.section .text
.global _start
_start:
    # Base address
    lui   x1, 0x0
    addi  x1, x1, 0x010   # x1 = 0x010

    # Word stores/loads
    addi  x2, x0, 0x12
    addi  x3, x0, 0x34
    sw    x2, 0(x1)
    sw    x3, 4(x1)
    lw    x4, 0(x1)
    lw    x5, 4(x1)

    # Half-word store/load (12-bit immediate allowed)
    addi  x6, x0, 0x7CD   # must be <= 0x7FF (2047)
    sh    x6, 8(x1)
    lh    x7, 8(x1)
    lhu   x8, 8(x1)

    # Byte store/load
    addi  x9, x0, 0xFF
    sb    x9, 12(x1)
    lb    x10, 12(x1)
    lbu   x11, 12(x1)

done:
    j done
