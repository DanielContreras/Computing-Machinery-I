/**
 * Daniel Contreras
 * 10080311
 * CPSC 355 Fall 2018
 */








fmt:        .string "Current values:\n\tx: %d\n\ty: %d\n\tCurrent Maximum: %d\n\n"
            .balign 4
            .global main

main:       stp     x29, x30, [sp, -16]!
            mov     x29, sp

            mov     x19, -50000
            mov     x20, -6
            mov     x21, -50000
            mov     x25, -5
            mov     x26, 31
            mov     x27, 4

            b       test

loop:       mul     x22, x20, x20                           // x²
            mul     x22, x22, x20                           // x³
            mul     x22, x22, x25                            // x³ * -5

            mul     x23, x20, x20                           // x²
            mul     x23, x23, x26                            // x² * 31

            mul     x24, x20, x27                             // x * 4

            sub     x21, x22, x23                 // (x³ * -5) - (x² * 31)
            add     x21, x21, x24       // ((x³ * -5) - (x² * 31)) + (x * 4)
            add     x21, x21, x26        // ((x³ * -5) - (x² * 31)) + (x * 4)) + 31

            b       if_test

if:         mov     x19, x21
            b       print

if_test:    cmp     x21, x19
            b.gt    if

print:      adrp    x0, fmt
            add     x0, x0, :lo12:fmt
            mov     x1, x20
            mov     x2, x21
            mov     x3, x19
            bl      printf

            add     x20, x20, 1

test:       cmp     x20, 5
            b.le    loop

done:       mov     w0, 0
            ldp     x29, x30, [sp], 16
            ret
