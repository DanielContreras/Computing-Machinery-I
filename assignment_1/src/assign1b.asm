/**
 * Daniel Contreras
 * 10080311
 * CPSC 355 Fall 2018
 */

define(currentX, x19)
define(currentY, x20)
define(currentMaximum, x21)
define(constX1, x22)
define(constX2, x23)
define(constX3, x24)
define(constX4, x25)
define(tmp, x27)

fmt:    .string "Current Values:\n\tx: %d\n\ty: %d\n\tCurrent Maximum: %d\n\n"  // String being returned
        .balign 4
        .global main

main:   
        stp     x29, x30, [sp, -16]!                                            // allocate stack space
        mov     x29, sp                                                         // Update fp
        mov     currentX, -6                                                    // Initialize x to -6
        mov     currentY, -50000                                                // Initialize y 
        mov     currentMaximum, -50000                                          // Initialize currentMaximum
        mov     constX1, -5                                                     // Initialize constant -5
        mov     constX2, -31                                                    // Initialize constant -31
        mov     constX3, 4                                                      // Initialize constant 4
        mov     constX4, 31                                                     // Initialize constant 31

        b       test                                                            // Jump to pre-test

top:
        mul     currentY, currentX, currentX                                    // Square x and place it into x26
        mul     currentY, currentY, currentX                                    // Square x26 again to get x cubed
        mul     currentY, currentY, constX1                                     // Multiply the result of x cubed by the constant -5

        mul     tmp, currentX, currentX                                         // Square x and place value into register 26
        madd    currentY, tmp, constX2, currentY                                // Multiply the product of x² with the constant -31 and add to y

        mul     tmp, currentX, constX3                                          // Multiply x by constant 4 
        madd    currentY, currentX, constX3, currentY                           // (-5x³-31x²+4x)

        add     currentY, currentY, constX4                                     // Add final constant into register currentY (-5x³-31x²+4x+31)
        
        cmp     currentMaximum, currentY                                        // Compare is currentMaximum with y
        b.gt    print                                                           // If currentMaximum is greater than y branch to print
        mov     currentMaximum, currentY                                        // Else, store y into currentMaximum

print:
        adrp    x0, fmt                                                         // Add fmt to x0
        add     x0, x0, :lo12:fmt                                               // Format string
        mov     x1, currentX                                                    // set x to x1 parameter
        mov     x2, currentY                                                    // set y to x2 parameter
        mov     x3, currentMaximum                                              // set currentMaximum to x3 parameter
        bl      printf                                                          // call printf function
        add     currentX, currentX, 1                                           // Increment x by 1
        b       test                                                            // Branch to test

test:
        cmp     currentX, 5                                                     // Compare current x to 5    
        b.le    top                                                             // if x <= 5 then jump to top label

done:   
        mov     w0, 0                                                           // set return value
        ldp     x29, x30, [sp], 16                                              // restore stack
        ret                                                                     // return to OS
