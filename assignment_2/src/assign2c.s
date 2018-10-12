/**
 * Daniel Contreras
 * 10080311
 * CPSC 355 Fall 2018
 */

                                                           // Define a macro to store multiplier
                                                         // Define a macro to store multiplicand
                                                              // Define a macro to store product
                                                                    // Define a macro to store i (loop counter)
                                                             // Define a macro to store negative flag (0 or 1)

                                                               // Define a macro to store result
                                                                // Define a macro to store temp1
                                                                // Define a macro to store temp2

fmt1:       .string "multiplier = 0x%08x (%d)  multiplicand = 0x%08x (%d)\n\n"      // initial values of variables print string
fmt2:       .string "product = 0x%08x  multiplier = 0x%08x\n"                       // product and multiplier print string
fmt3:       .string "64-bit result = 0x%016lx (%ld)\n"                              // 64-bit result print string
            .balign 4
            .global main

main:       stp     x29, x30, [sp, -16]!                                            // allocate stack space
            mov     x29, sp                                                         // Update fp

            mov     w20, -252645136                                       // Initialize multiplicand to -252645136
            mov     w19, -256                                                // Initialize multiplier to -256
            mov     w21, 0                                                    // Initialize product to 0
            mov     w23, 0                                                   // Initialize negative to 0 (FALSE)
            mov     w22, 0
            
            adrp    x0, fmt1                                                        // Add fmt1 to x0
            add     x0, x0, :lo12:fmt1                                              // Format string
            mov     w1, w19                                                // Set first parameter
            mov     w2, w19                                                // Set second parameter
            mov     w3, w20                                              // Set third parameter
            mov     w4, w20                                              // Set fourth parameter
            bl      printf                                                          // Call printf function

            cmp     w19, 0                                                 // Compare multiplier to 0
            b.ge    top                                                             // If multiplier is > 0, branch to test
            mov     w23, 1                                                   // Otherwise set negative to 1 (TRUE)
            b       test                                                            // Branch to test

top:        tst     w19, 0x1                                               // Perform an ands to eval multiplier with 0x1
            b.eq    top2                                                            // Branch to top1 on equal (Z flag == 1)
            add     w21, w21, w20                            // Perform inner if by adding product + multiplicand

top2:       asr     w19, w19, 1                                   // Arithmetic shift right the combined product and multiplier
            tst     w21, 0x1                                                  // if (product & 0x1)
            b.ne    inner_if2                                                       // Branch on not equal to inner_else
            and     w19, w19, 0x7FFFFFFF                          // else, 
            b       top3

inner_if2:  orr     w19, w19, 0x80000000                          // Perform inclusive OR and store value in multiplier

top3:       asr     w21, w21, 1                                         // Arithmetic shift right
            add     w22, w22, 1                                                     // Increment loop counter

test:       cmp     w22, 32                                                         // Compare i to 32
            b.lt    top                                                             // If i is less-than 32, branch to top

            cmp     w23, 0                                                   // Compare negative to 0 ==> if(negative)
            b.eq    final                                                           // Breanch on equal to final
            sub     w21, w21, w20                            // Adjust product register if multiplier is negative

final:      adrp    x0, fmt2                                                        // Add fmt2 to x0
            add     x0, x0, :lo12:fmt2                                              // Format string
            mov     w1, w21                                                   // Add product to parameter 1
            mov     w2, w19                                                // Add multiplier to parameter 2
            bl      printf                                                          // Call printf function

            sxtw    x20, w21                                              // Sign extend the 32-bit product to 64-bit and store in temp1
            and     x20, x20, 0xFFFFFFFF                                    // Perform AND with product and hex value
            lsl     x20, x20, 32                                            // Perform logical left shift on temp1 
            sxtw    x21, w19                                           // Sign extend the 32-bit multiplier to 64-bit and store in temp2
            and     x21, x21, 0xFFFFFFFF                                    // Perform AND with multiplier and hex value
            add     x19, x20, x21                                      // Add the results of both ANDS and store in 64-bit result register

            adrp    x0, fmt3                                                        // Add fmt3 to x0
            add     x0, x0, :lo12:fmt3                                              // Format string
            mov     x1, x19                                                    // Add result in parameter 1
            mov     x2, x19                                                    // Add result in parameter 2
            bl      printf                                                          // Call printf function

done:       mov     w0, 0                                                           // set return value to 0
            ldp     x29, x30, [sp], 16                                              // restore stack
            ret                                                                     // return control to OS
