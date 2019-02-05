define(w_multiplier, w19)                                                           // Define a macro to store multiplier
define(w_multiplicand, w20)                                                         // Define a macro to store multiplicand
define(w_product, w21)                                                              // Define a macro to store product
define(w_i, w22)                                                                    // Define a macro to store i (loop counter)
define(w_negative, w23)                                                             // Define a macro to store negative flag (0 or 1)

define(x_result, x19)                                                               // Define a macro to store result
define(x_temp1, x20)                                                                // Define a macro to store temp1
define(x_temp2, x21)                                                                // Define a macro to store temp2

fmt1:       .string "multiplier = 0x%08x (%d)  multiplicand = 0x%08x (%d)\n\n"      // initial values of variables print string
fmt2:       .string "product = 0x%08x  multiplier = 0x%08x\n"                       // product and multiplier print string
fmt3:       .string "64-bit result = 0x%016lx (%ld)\n"                              // 64-bit result print string
            .balign 4
            .global main

main:       stp     x29, x30, [sp, -16]!                                            // allocate stack space
            mov     x29, sp                                                         // Update fp

            mov     w_multiplicand, -252645136                                      // Initialize multiplicand to -252645136
            mov     w_multiplier, -256                                              // Initialize multiplier to -256
            mov     w_product, 0                                                    // Initialize product to 0
            mov     w_negative, 0                                                   // Initialize negative to 0 (FALSE)
            mov     w_i, 0
            
            adrp    x0, fmt1                                                        // Add fmt1 to x0
            add     x0, x0, :lo12:fmt1                                              // Format string
            mov     w1, w_multiplier                                                // Set first parameter
            mov     w2, w_multiplier                                                // Set second parameter
            mov     w3, w_multiplicand                                              // Set third parameter
            mov     w4, w_multiplicand                                              // Set fourth parameter
            bl      printf                                                          // Call printf function

            cmp     w_multiplier, 0                                                 // Compare multiplier to 0
            b.ge    top                                                             // If multiplier is > 0, branch to test
            mov     w_negative, 1                                                   // Otherwise set negative to 1 (TRUE)
            b       test                                                            // Branch to test

top:        tst     w_multiplier, 0x1                                               // Perform an ands to eval multiplier with 0x1
            b.eq    top2                                                            // Branch to top1 on equal (Z flag == 1)
            add     w_product, w_product, w_multiplicand                            // Perform inner if by adding product + multiplicand

top2:       asr     w_multiplier, w_multiplier, 1                                   // Arithmetic shift right the combined product and multiplier
            tst     w_product, 0x1                                                  // if (product & 0x1)
            b.ne    inner_if2                                                       // Branch on not equal to inner_else
            and     w_multiplier, w_multiplier, 0x7FFFFFFF                          // else, 
            b       top3

inner_if2:  orr     w_multiplier, w_multiplier, 0x80000000                          // Perform inclusive OR and store value in multiplier

top3:       asr     w_product, w_product, 1                                         // Arithmetic shift right
            add     w_i, w_i, 1                                                     // Increment loop counter

test:       cmp     w_i, 32                                                         // Compare i to 32
            b.lt    top                                                             // If i is less-than 32, branch to top

            cmp     w_negative, 0                                                   // Compare negative to 0 ==> if(negative)
            b.eq    final                                                           // Breanch on equal to final
            sub     w_product, w_product, w_multiplicand                            // Adjust product register if multiplier is negative

final:      adrp    x0, fmt2                                                        // Add fmt2 to x0
            add     x0, x0, :lo12:fmt2                                              // Format string
            mov     w1, w_product                                                   // Add product to parameter 1
            mov     w2, w_multiplier                                                // Add multiplier to parameter 2
            bl      printf                                                          // Call printf function

            sxtw    x_temp1, w_product                                              // Sign extend the 32-bit product to 64-bit and store in temp1
            and     x_temp1, x_temp1, 0xFFFFFFFF                                    // Perform AND with product and hex value
            lsl     x_temp1, x_temp1, 32                                            // Perform logical left shift on temp1 
            sxtw    x_temp2, w_multiplier                                           // Sign extend the 32-bit multiplier to 64-bit and store in temp2
            and     x_temp2, x_temp2, 0xFFFFFFFF                                    // Perform AND with multiplier and hex value
            add     x_result, x_temp1, x_temp2                                      // Add the results of both ANDS and store in 64-bit result register

            adrp    x0, fmt3                                                        // Add fmt3 to x0
            add     x0, x0, :lo12:fmt3                                              // Format string
            mov     x1, x_result                                                    // Add result in parameter 1
            mov     x2, x_result                                                    // Add result in parameter 2
            bl      printf                                                          // Call printf function

done:       mov     w0, 0                                                           // set return value to 0
            ldp     x29, x30, [sp], 16                                              // restore stack
            ret                                                                     // return control to OS
