/**
 * Daniel Contreras
 * 10080311
 * CPSC 355 Fall 2018
 */

define(maximum_r, x19)
define(x_r, x20)
define(current_max_r, x21)
define(a1, x25)
define(a2, x26)
define(a3, x27)

fmt:        .string "Current values:\n\tx: %d\n\ty: %d\n\tCurrent Maximum: %d\n\n"
            .balign 4
            .global main

main:       stp     x29, x30, [sp, -16]!
            mov     x29, sp

            mov     maximum_r, -50000
            mov     x_r, -6
            mov     current_max_r, -50000
            mov     a1, -5
            mov     a2, 31
            mov     a3, 4

            b       test

loop:       mul     x22, x_r, x_r                           // x²
            mul     x22, x22, x_r                           // x³
            mul     x22, x22, a1                            // x³ * -5

            mul     x23, x_r, x_r                           // x²
            mul     x23, x23, a2                            // x² * 31

            mul     x24, x_r, a3                             // x * 4

            sub     current_max_r, x22, x23                 // (x³ * -5) - (x² * 31)
            add     current_max_r, current_max_r, x24       // ((x³ * -5) - (x² * 31)) + (x * 4)
            add     current_max_r, current_max_r, a2        // ((x³ * -5) - (x² * 31)) + (x * 4)) + 31

            b       if_test

if:         mov     maximum_r, current_max_r
            b       print

if_test:    cmp     current_max_r, maximum_r
            b.gt    if

print:      adrp    x0, fmt
            add     x0, x0, :lo12:fmt
            mov     x1, x_r
            mov     x2, current_max_r
            mov     x3, maximum_r
            bl      printf

            add     x_r, x_r, 1

test:       cmp     x_r, 5
            b.le    loop

done:       mov     w0, 0
            ldp     x29, x30, [sp], 16
            ret
