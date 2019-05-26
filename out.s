
.data

b: .word 2

.text

main:
    addiu $29, $29, -4
    ori   $8, $0, 0
    sw    $8, 0($29)
    ori   $8, $0, 11
    lui   $9, 0x1001
    lw    $9, 0($9)
    div   $8, $9
    teq $9, $0
    mfhi  $8
    sw    $8, 0($29)
    addiu $29, $29, 4
    ori   $2, $0, 10
    syscall
