



        size    = 50
        i_size  = 4
        j_size  = 4
        tmp_size = 4
        v_size  = 4 * size

        alloc   = -(16 + i_size + j_size + tmp_size + v_size) & -16
        dealloc = -alloc

        i_s     = 16
        j_s     = i_s + j_size
        tmp_s   = j_s + tmp_size
        v_s     = tmp_s + 4

        fp      .req x29
        lr      .req x30

fmt1:    .string "v[%d]: %d\n"
fmt2:   .string "\nSorted array:\n"
        .balign 4
        .global main

main:   stp     fp, lr, [sp, alloc]!
        mov     fp, sp

        add     x19, fp, v_s                   // Calc base addr
        mov     w20, 0                        // Set i = 0
        str     w20, [fp, i_s]                // Store i in mem
        b       test

// Initialize array to random positive ints, mod 256
for:    bl      rand                                // rand stored in w0
        and     w0, w0, 0xFF
        str     w0, [x19, w20, sxtw 2]

        adrp    x0, fmt1
        add     x0, x0, :lo12:fmt1
        ldr     w1, [fp, i_s]
        ldr     w2, [x19, w1, sxtw 2]
        bl      printf

        add     w20, w20, 1
        str     w20, [fp, i_s]

test:   cmp     w20, size
        b.lt    for

        mov     w20, 1
        str     w20, [fp, i_s]
        b       test2

// Sort the array using an insertion sort
for2:   ldr     w25, [x19, w20, sxtw 2]
        str     w25, [fp, tmp_s]
        // TODO
        ldr     w20, [fp, i_s]  // get i
        str     w20, [fp, j_s]  // store j
        b       test3

for3:   ldr     w21, [fp, j_s]
        sub     w21, w21, 1                 // j-1
        ldr     w25, [x19, w21, sxtw 2]      // v[j-1]
        add     w21, w21, 1                 // j-1+1
        str     w25, [x19, w21, sxtw 2]      // v[j] = v[j-1]

        sub     w21, w21, 1
        str     w21, [fp, j_s]

test3:  ldr     w21, [fp, j_s]
        cmp     w21, 0
        b.le    lp2
        ldr     w25, [fp, tmp_s]    // w23 = tmp
        sub     w22, w21, 1   // v-1
        ldr     w23, [x19, w22, sxtw 2] // w22 = v[j-1]
        cmp     w25, w23
        b.ge    lp2
        b       for3
        
        // TODO: v[j] = temp;
        //str     w23, [x19, w22, sxtw 2]
lp2:    ldr     w21, [fp, tmp_s]                 // Load temp into w21
        ldr     w25, [fp, j_s]                          // Load j_s into w25
        str     w21, [x19, w25, SXTW 2]

        ldr     w20, [fp, i_s]
        add     w20, w20, 1
        str     w20, [fp, i_s]

test2:  cmp     w20, size
        b.lt    for2

        adrp    x0, fmt2
        add     x0, x0, :lo12:fmt2
        bl      printf

        mov     w20, 0
        str     w20, [fp, i_s]
        b       test4

for4:   adrp    x0, fmt1
        add     x0, x0, :lo12:fmt1
        ldr     w1, [fp, i_s]         
        ldr     w2, [x19, w1, sxtw 2] 
        bl      printf

        add     w20, w20, 1
        str     w20, [fp, i_s]

test4:  cmp     w20, size
        b.lt    for4

done:   mov     w0, 0
        ldp     fp, lr, [sp], dealloc
        ret
