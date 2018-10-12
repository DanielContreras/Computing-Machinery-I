/**
 * Daniel Contreras
 * 10080311
 * CPSC 355 Fall 2018
 */

define(w_multiplier, w19)
define(w_multiplicand, w20)
define(w_product, w21)
define(w_i, w22)
define(w_negative, w23)

define(x_result, x19)
define(x_temp1, x20)
define(x_temp2, x21)

fmt1:       .string "multiplier = 0x%08x (%d)  multiplicand = 0x%08x (%d)\n\n"      // initial values of variables print string
fmt2:       .string "product = 0x%08x  multiplier = 0x%08x\n"                       // product and multiplier print string
fmt3:       .string "64-bit result = 0x%016lx (%ld)\n"                              // 64-bit result print string
            .balign 4
            .global main

main:       stp     x29, x30, [sp, -16]!                                            // allocate stack space
            mov     x29, sp                                                         // Update fp

            mov     w_multiplicand, -16843010                                       // Initialize multiplicand to -16843010
            mov     w_multiplier, 70                                                // Initialize multiplier to 70
            mov     w_product 0                                                     // Initialize product to 0
            mov     w_negative 0                                                    // Initialize negative to 0 (FALSE)
            mov     w_i 0
            
            adrp    x0, fmt1                                                        // Add fmt1 to x0
            add     x0, x0, :lo12:fmt1                                              // Format string
            mov     w1, w_multiplier                                                // Set first parameter
            mov     w2, w_multiplier                                                // Set second parameter
            mov     w3, w_multiplicand                                              // Set third parameter
            mov     w4, w_multiplicand                                              // Set fourth parameter
            bl      printf                                                          // Call printf function

            cmp     w_multiplier, 0                                                 // Compare multiplier to 0
            b.ge    test                                                            // If multiplier is > 0, branch to test
            mov     w_negative, 1                                                   // Otherwise set negative to 1 (TRUE)
            b       test                                                            // Branch to test

top:        tst     w_multiplier, 0x1                                               // Perform an ands to eval multiplier with 0x1
            b.eq    top1                                                            // Branch to top1 on equal (Z flag == 1)

inner_if:   add     w_product, w_product, w_multiplicand                            // Perform inner if by adding product + multiplicand

top2:       asr     w_multiplicand, w_multiplier, 1                                 // Arithmetic shift right the combined product and multiplier
            tst     w_product, 0x1                                                  // 
            b.ne    inner_if2                                                      // Branch on not equal to inner_else

inner_else: and     w_multiplier, w_multiplier, 0x7FFFFFFF                          // else, 
            b       top3

inner_if2:  orr     w_multiplier, w_multiplier, 0x80000000                          // 

top3:       asr     w_product, w_product, 1                                         // Arithmetic shift right
            add     w_i, w_i, 1                                                     // Increment loop counter

test:       cmp     w_i, 32                                                         // Compare i to 32
            b.lt    top                                                             // If i is less-than 32, branch to top

            cmp     w_negative, 0                                                   // Compare negative to 0 ==> if(negative)
            b.eq    final                                                           // Breanch on equal to final
            sub     w_product, w_product, w_multiplicand                            // Adjust product register if multiplier is negative

final:      adrp    x0, fmt2
            add     x0, x0, :lo12:fmt2
            mov     w1, w_product
            mov     w2, w_multiplier
            bl      printf

            // TODO Perform arithmtic
            sxtw    x_temp1, w_product
            and     x_temp1, x_temp1, 0xFFFFFFFF
            lsl     x_temp1, x_temp1, 32
            sxtw    x_temp2, w_multiplier
            and     x_temp2, x_temp2, 0xFFFFFFFF
            add     x_result, x_temp1, x_temp2

            adrp    x0, fmt3
            add     x0, x0, :lo12:fmt3
            mov     x1, x_result
            mov     x2, x_result
            bl      printf

done:       mov     w0, 0                                                           // set return value to 0
            ldp     x29, x30, [sp], 16                                              // restore stack
            ret                                                                     // return control to OS