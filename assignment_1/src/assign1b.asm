/**
 * Daniel Contreras
 * 10080311
 * CPSC 355 Fall 2018
 */

define(x_r, x19)
define(y_r, x20)
define(max_r, x21)
define(a1, x22)
define(a2, x23)
define(a3, x24)
define(a4, x25)
define(tmp, x27)

fmt:    .string "Current Values:\n\tx: %d\n\ty: %d\n\tCurrent Maximum: %d\n\n"  // String being returned
        .balign 4
        .global main

main:   
        stp     x29, x30, [sp, -16]!                                            // allocate stack space
        mov     x29, sp                                                         // Update fp
        mov     x_r, -6                                                         // Initialize x to -6
        mov     y_r, -50000                                                     // Initialize y 
        mov     max_r, -50000                                                   // Initialize max_r
        mov     a1, -5                                                          // Initialize constant -5
        mov     a2, -31                                                         // Initialize constant -31
        mov     a3, 4                                                           // Initialize constant 4
        mov     a4, 31                                                          // Initialize constant 31

        b       test                                                            // Jump to pre-test

top:
        mul     y_r, x_r, x_r                                                   // Square x and place it into x26
        mul     y_r, y_r, x_r                                                   // Square x26 again to get x cubed
        mul     y_r, y_r, a1                                                    // Multiply the result of x cubed by the constant -5

        mul     tmp, x_r, x_r                                                   // Square x and place value into register 26
        madd    y_r, tmp, a2, y_r                                               // Multiply the product of x² with the constant -31 and add to y

        mul     tmp, x_r, a3                                                    // Multiply x by constant 4 
        madd    y_r, x_r, a3, y_r                                               // (-5x³-31x²+4x)

        add     y_r, y_r, a4                                                    // Add final constant into register y_r (-5x³-31x²+4x+31)
        
        cmp     max_r, y_r                                                      // Compare is max_r with y
        b.gt    print                                                           // If max_r is greater than y branch to print
        mov     max_r, y_r                                                      // Else, store y into max_r

print:
        adrp    x0, fmt                                                         // Add fmt to x0
        add     x0, x0, :lo12:fmt                                               // Format string
        mov     x1, x_r                                                         // set x to x1 parameter
        mov     x2, y_r                                                         // set y to x2 parameter
        mov     x3, max_r                                                       // set max_r to x3 parameter
        bl      printf                                                          // call printf function
        add     x_r, x_r, 1                                                     // Increment x by 1
        b       test                                                            // Branch to test

test:
        cmp     x_r, 5                                                          // Compare current x to 5    
        b.le    top                                                             // if x <= 5 then jump to top label

done:   
        mov     w0, 0                                                           // set return value
        ldp     x29, x30, [sp], 16                                              // restore stack
        ret                                                                     // return to OS
