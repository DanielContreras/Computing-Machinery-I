define(v_base_r, x19)
define(index_i_r, w19)
define(index_j_r, w20)

        size        = 50
        i_size      = 4
        j_size      = 4
        tmp_size    = 4
        v_size      = 4 * size

        alloc       = -(16 + i_size + j_size + tmp_size + v_size) & -16
        dealloc     = -alloc

        i_s         = 16
        j_s         = i_s + j_size
        tmp_s       = j_s + tmp_size
        v_s         = tmp_s + 4

        fp          .req x29
        lr          .req x30

fmt:    .string     "v[%d]: %d\n"
fmt1:   .string     "\nSorted array:\n"
fmt2:   .string     "v[%d]: %d\n"
        .balign     4
        .global     main

main:   stp         fp, lr, [sp, alloc]!
        mov         fp, sp

        add         v_base_r, x29, v_s                  // Calc base addr
        mov         index_i_r, 0                        // Set i = 0
        str         index_i_r, [fp, i_s]                // Store i in mem
        
        b           test

// Initialize array to random positive ints, mod 256
for:    bl          rand                                // rand stored in w0
        and         w0, w0, 0xFF
        str         w0, [v_base_r, index_i_r, sxtw 2]

        adrp        x0, fmt
        add         x0, x0, :lo12:fmt
        ldr         w1, [fp, i_s]
        ldr         w2, [v_base_r, w1, sxtw 2]
        b           printf

        add         index_i_r, index_i_r, 1
        str         index_i_r, [fp, i_s]

test:   cmp         index_i_r, size
        b.lt        for

        mov         index_i_r, 1
        str         index_i_r, [fp, i_s]
        b           test2

// Sort the array using an insertion sort
for2:   ldr         w21, [v_base_r, index_i_r, sxtw 2]
        str         w21, [fp, tmp_s]

        b           test3

for3:   sub         w24, index_j_r, 1
        ldr         w24, [v_base_r, w24, sxtw 2] // v[j-1]
        str         w24, [v_base_r, index_j_r, sxtw 2]


        sub         index_j_r, index_j_r, 1

test3:  ldr         index_i_r, [fp, i_s]  // get i
        mov         index_j_r, index_i_r  // j = i
        str         index_j_r, [fp, j_s]  // store j

        cmp         index_j_r, 0
        b.gt        for3
        ldr         w23, [fp, tmp_s]    // w23 = tmp
        sub         w22, index_j_r, 1   // v-1
        ldr         w22, [v_base_r, w22, sxtw 2] // w22 = v[j-1]
        cmp         w23, w22
        b.lt        for3
        
        // TODO: v[j] = temp;
        str         w23, [v_base_r, index_j_r, sxtw 2]

        add         index_i_r, index_i_r, 1
        str         index_i_r, [fp, i_s]

test2:  cmp         index_i_r, size
        b.lt        for2

        mov         index_i_r, 0
        str         index_i_r, [fp, i_s]
        b           test4

for4:

        adrp        x0, fmt2
        add         x0, x0, :lo12:fmt2
        ldr         w1, [fp, i_s]         
        ldr         w2, [v_base_r, w1, SXTW 2] 
        bl          printf

        add         index_i_r, index_i_r, 1
        str         index_i_r, [fp, i_s]

test4:  cmp         index_i_r, size
        b.lt        for4

done:   mov         w0, 0
        ldp         fp, lr, [sp], dealloc
        ret
