.section .text
.global _start
_start:
    # Base address
    addi  x1, x0, 0x010   # x1 = 0x010

    # Word stores/loads
    addi  x2, x0, 0x05
    addi  x3, x0, 0x20
    sw    x2, 0(x1)
    sw    x3, 4(x1)
    lw    x4, 0(x1)
    lw    x5, 4(x1)

    add   x6, x4, x5

done:
    j done
