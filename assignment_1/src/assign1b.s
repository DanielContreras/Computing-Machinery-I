/**
 * Daniel Contreras
 * 10080311
 * CPSC 355 Fall 2018
 */










fmt:    .string "Current Values:\n\tx: %d\n\ty: %d\n\tCurrent Maximum: %d\n\n"  // String being returned
        .balign 4
        .global main

main:   
        stp     x29, x30, [sp, -16]!                                            // allocate stack space
        mov     x29, sp                                                         // Update fp
        mov     x19, -6                                                         // Initialize x to -6
        mov     x20, -50000                                                     // Initialize y 
        mov     x21, -50000                                                   // Initialize x21
        mov     x22, -5                                                          // Initialize constant -5
        mov     x23, -31                                                         // Initialize constant -31
        mov     x24, 4                                                           // Initialize constant 4
        mov     x25, 31                                                          // Initialize constant 31

        b       test                                                            // Jump to pre-test

top:
        mul     x20, x19, x19                                                   // Square x and place it into x26
        mul     x20, x20, x19                                                   // Square x26 again to get x cubed
        mul     x20, x20, x22                                                    // Multiply the result of x cubed by the constant -5

        mul     x27, x19, x19                                                   // Square x and place value into register 26
        madd    x20, x27, x23, x20                                               // Multiply the product of x² with the constant -31 and add to y

        mul     x27, x19, x24                                                    // Multiply x by constant 4 
        madd    x20, x19, x24, x20                                               // (-5x³-31x²+4x)

        add     x20, x20, x25                                                    // Add final constant into register x20 (-5x³-31x²+4x+31)
        
        cmp     x21, x20                                                      // Compare is x21 with y
        b.gt    print                                                           // If x21 is greater than y branch to print
        mov     x21, x20                                                      // Else, store y into x21

print:
        adrp    x0, fmt                                                         // Add fmt to x0
        add     x0, x0, :lo12:fmt                                               // Format string
        mov     x1, x19                                                         // set x to x1 parameter
        mov     x2, x20                                                         // set y to x2 parameter
        mov     x3, x21                                                       // set x21 to x3 parameter
        bl      printf                                                          // call printf function
        add     x19, x19, 1                                                     // Increment x by 1
        b       test                                                            // Branch to test

test:
        cmp     x19, 5                                                          // Compare current x to 5    
        b.le    top                                                             // if x <= 5 then jump to top label

done:   
        mov     w0, 0                                                           // set return value
        ldp     x29, x30, [sp], 16                                              // restore stack
        ret                                                                     // return to OS
