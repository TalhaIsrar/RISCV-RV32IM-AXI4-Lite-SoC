addi  x1, x0, 0x001   # x1 = 0x010

addi  x2, x0, 10
addi  x3, x0, 4
sw    x2, 0(x1)

lw    x4, 0(x1)

mul   x5, x3, x4
addi  x6, x0, x5

nop
nop
nop
