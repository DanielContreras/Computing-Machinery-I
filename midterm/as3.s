

        
        
        size = 50
        i_size  = 4
        j_size  = 4
        temp_size = 4
        v_size  = 4 * size

        alloc   = -(16 + i_size + j_size + temp_size + v_size) & -16
        dealloc = -alloc

        i_s     = 16
        j_s     = 20
        temps_s = 24
        v_s     = 28

        fp      .req x29
        lr      .req x30

fmt1:   .string "v[%d]: %d\n"
fmt2:   .string "nSorted array:\n"
        .balign 4  
        .global main

main:   stp     fp, lr, [sp, alloc]!
        mov     fp, sp

        add     x19, fp, v_s
        mov     w19, 0
        str     w19, [fp, i_s]
        
        b       test1

/* Initialize array to random positive integers, mod 256 */
loop1:  bl      rand                                // generate random number
        and     w0, w0, 0xFF                        // rand() & 0xFF
        str     w0, [x19, w19, sxtw 2]     // v[i] = rand() & 0xFF

        adrp    x0, fmt1
        add     x0, x0, :lo12:fmt1
        ldr     w1, [fp, i_s]
        ldr     w2, [x19, w1, sxtw 2]
        bl      printf

        add     w19, w19, 1
        str     w19, [fp, i_s]        

test1:  cmp     w19, size
        b.lt    loop1

/* Sort the array using an insertion sort */
loop2:
test2:

/* Print out sorted array */
loop3:
test3:

done:   mov     w0, 0
        ldp     fp, lr, [sp], 16
        ret
