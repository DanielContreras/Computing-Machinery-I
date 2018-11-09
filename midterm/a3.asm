define(v_base_r, x19)
define(index_i_r, w20)
define(index_j_r, w21)

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

        add     v_base_r, fp, v_s                   // Calc base addr
        mov     index_i_r, 0                        // Set i = 0
        str     index_i_r, [fp, i_s]                // Store i in mem
        b       test

// Initialize array to random positive ints, mod 256
for:    bl      rand                                // rand stored in w0
        and     w0, w0, 0xFF
        str     w0, [v_base_r, index_i_r, sxtw 2]

        adrp    x0, fmt1
        add     x0, x0, :lo12:fmt1
        ldr     w1, [fp, i_s]
        ldr     w2, [v_base_r, w1, sxtw 2]
        bl      printf

        add     index_i_r, index_i_r, 1
        str     index_i_r, [fp, i_s]

test:   cmp     index_i_r, size
        b.lt    for

        mov     index_i_r, 1
        str     index_i_r, [fp, i_s]
        b       test2

// Sort the array using an insertion sort
for2:   ldr     w25, [v_base_r, index_i_r, sxtw 2]
        str     w25, [fp, tmp_s]
        // TODO
        ldr     index_i_r, [fp, i_s]  // get i
        str     index_i_r, [fp, j_s]  // store j
        b       test3

for3:   ldr     index_j_r, [fp, j_s]
        sub     index_j_r, index_j_r, 1                 // j-1
        ldr     w25, [v_base_r, index_j_r, sxtw 2]      // v[j-1]
        add     index_j_r, index_j_r, 1                 // j-1+1
        str     w25, [v_base_r, index_j_r, sxtw 2]      // v[j] = v[j-1]

        sub     index_j_r, index_j_r, 1
        str     index_j_r, [fp, j_s]

test3:  ldr     index_j_r, [fp, j_s]
        cmp     index_j_r, 0
        b.le    lp2
        ldr     w25, [fp, tmp_s]    // w23 = tmp
        sub     w22, index_j_r, 1   // v-1
        ldr     w23, [v_base_r, w22, sxtw 2] // w22 = v[j-1]
        cmp     w25, w23
        b.ge    lp2
        b       for3
        
        // TODO: v[j] = temp;
        //str     w23, [v_base_r, w22, sxtw 2]
lp2:    ldr     index_j_r, [fp, tmp_s]                 // Load temp into index_j_r
        ldr     w25, [fp, j_s]                          // Load j_s into w25
        str     index_j_r, [v_base_r, w25, SXTW 2]

        ldr     index_i_r, [fp, i_s]
        add     index_i_r, index_i_r, 1
        str     index_i_r, [fp, i_s]

test2:  cmp     index_i_r, size
        b.lt    for2

        adrp    x0, fmt2
        add     x0, x0, :lo12:fmt2
        bl      printf

        mov     index_i_r, 0
        str     index_i_r, [fp, i_s]
        b       test4

for4:   adrp    x0, fmt1
        add     x0, x0, :lo12:fmt1
        ldr     w1, [fp, i_s]         
        ldr     w2, [v_base_r, w1, sxtw 2] 
        bl      printf

        add     index_i_r, index_i_r, 1
        str     index_i_r, [fp, i_s]

test4:  cmp     index_i_r, size
        b.lt    for4

done:   mov     w0, 0
        ldp     fp, lr, [sp], dealloc
        ret
