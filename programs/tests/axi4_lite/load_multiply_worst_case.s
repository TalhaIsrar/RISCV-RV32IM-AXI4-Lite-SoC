.section .text
.global _start
_start:
    # Base address
    addi  x1, x0, 0x010   # x1 = 0x010

    # Word stores/loads
    li    x2, -123
    li    x3, 345
    sw    x2, 0(x1)
    sw    x3, 4(x1)
    lw    x4, 0(x1)
    lw    x5, 4(x1)

    mul   x6, x4, x5       #  x6 = -42435
    li    x7, 0xDEADBEEF
done:
    j done
