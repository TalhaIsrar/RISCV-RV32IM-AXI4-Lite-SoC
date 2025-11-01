    .section .text
    .globl _start

_start:
    # ----------------------------------
    # Base Addresses of Slaves
    # ----------------------------------
    li x5, 0x00000000       # Slave 0 base (operands)
    li x6, 0x00000100       # Slave 1 base (intermediate results)
    li x7, 0x00001000       # Slave 2 base (final output)

    # ----------------------------------
    # Initialize Operands in Slave 0
    # a = 7, b = 13, m = 20
    # ----------------------------------
    li x1, 7
    li x2, 13
    li x3, 20
    sw x1, 0(x5)            # store a
    sw x2, 4(x5)            # store b
    sw x3, 8(x5)            # store m

    # ----------------------------------
    # Load operands from different slaves
    # (simulate distributed memory reads)
    # ----------------------------------
    lw x8, 0(x5)            # load a  from Slave 0
    lw x9, 4(x5)            # load b  from Slave 0
    lw x10, 8(x5)           # load m  from Slave 0

    # Initialize result = 1, exp = b
    li x11, 1               # result
    add x12, x9, x0         # exp = b

modexp_loop:
    beq x12, x0, modexp_done   # if exp == 0 → done

    # if (exp % 2 == 1)
    andi x13, x12, 1
    beq x13, x0, skip_mult

    # result = (result * a) % m
    mul x11, x11, x8
    rem x11, x11, x10
    sw x11, 0(x6)             # store result in Slave 1

    # Read back result to simulate slave read
    lw x11, 0(x6)

skip_mult:
    # a = (a * a) % m
    mul x8, x8, x8
    rem x8, x8, x10
    sw x8, 4(x6)              # store squared a in Slave 1

    # exp = exp >> 1
    srli x12, x12, 1
    sw x12, 8(x6)             # store shifted exp in Slave 1
    lw x12, 8(x6)             # read back exp

    j modexp_loop

modexp_done:
    # Read Final Result from Slave 1
    lw x14, 0(x6)
    sw x14, 0(x7)             # Final result memory-mapped to Slave 2

end:
    j end
