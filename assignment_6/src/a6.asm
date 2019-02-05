/**
 * Daniel Contreras
 * 10080311
 * CPSC 355 Fall 2018
 */

define(argc_r, w21)
define(argv_r, x19)

define(pn_r, x23)
define(fd_r, w19)
define(nread_r, x20)
define(buf_base_r, x22)

define(input_r, d19)
define(xval_r, d20)
define(yval_r, d21)
define(dy_r, d22)
define(dydx_r, d23)
define(cube_r, d24)
define(limit_r, d25)
define(tmpx_r, d26)

            .data
cube_m:     .double 0r3.0
const_m:    .double 0r1.0e-10

            .text
            buf_size = 8
            alloc = -(16 + buf_size) & -16
            dealloc = -alloc
            buf_s = 16
            AT_FDCWD = -100

o_error:    .string "Error opening file: %s\nAborting...\n"
usage:      .string "Usage: ./a6 <filename.bin>\n"
col_border: .string "-------------------------------------------------\n"
col_head:   .string "|\tinput\t\t|\toutput\t\t|\n"
input_col:  .string "|\t%0.10f\t|"
out_col:    .string "\t%0.10f\t|\n" 

            fp .req x29
            lr .req x30

            .balign 4
            .global main

/** main function */
main:       stp     fp, lr, [sp, alloc]!            // Allocate memory
            mov     fp, sp                          // Update fp

            mov     argc_r, w0                      // Store argc_r in w0
            mov     argv_r, x1                      // Store argv_r in x1
            ldr     pn_r, [argv_r, 8]               // Store first arg in register pn_r

            cmp     argc_r, 2                       // Check that 2 command line args are given
            b.eq    continue                        // If there have been 2, continue

            adrp    x0, usage                   	// else, prepare the error message
            add     x0, x0, :lo12:usage         	// Format lower 12 bits of usage
            bl      printf                      	// Call to printf
            b       exit                        	// Branch to exit (terminate program)

continue:   mov     w0, AT_FDCWD                    // 1st arg (cwd)
            mov     x1, pn_r                        // 2nd arg (pathname)
            mov     w2, 0                           // 3rd arg (read only)
            mov     w3, 0                           // 4th arg (not used)
            mov     x8, 56                          // openat I/O request
            svc     0                               // Call system function
            mov     fd_r, w0                        // Record file descriptor

            cmp     fd_r, 0                          // Error check
            b.ge    open_ok                          // If open was succesful, branch to open_ok

            adrp    x0, o_error                      // else, prepare error string
            add     x0, x0, :lo12:o_error            // format lower 12 bits
            mov     x1, pn_r                         // Add pathname to arg1  
            bl      printf                           // call printf
            b       exit                             // branch to exit of program

open_ok:    add     buf_base_r, fp, buf_s            // Calculate buf base address

            adrp    x0, col_border                   // Prepare border string for table
            add     x0, x0, :lo12:col_border         // Format lower 12 bits
            bl      printf                           // Call printf
            adrp    x0, col_head                     // Prepare coloum head string for table
            add     x0, x0, :lo12:col_head           // Format lower 12 bits
            bl      printf                           // Call printf

top:        mov     w0, fd_r                         // 1st arg (fd)
            mov     x1, buf_base_r                   // 2nd arg (buf_base)
            mov     w2, buf_size                     // 3rd arg (buf_size)
            mov     x8, 63                           // Read I/O Request
            svc     0                                // Call system function
            mov     nread_r, x0                      // Number of bytes read

            cmp     nread_r, buf_size                // if read != buf_size
            b.ne    eof                              // then, branch to end of file

            adrp    x0, col_border                   // Prepare string for border of table
            add     x0, x0, :lo12:col_border         // Format lower 12 bits
            bl      printf                           // Call printf

            adrp    x0, input_col                    // Prepare string for input value
            add     x0, x0, :lo12:input_col          // Format lower 12 bits
            ldr     d0, [buf_base_r]                 // d0 contains the x value
            bl      printf                           // Call printf

            ldr     d0, [buf_base_r]                 // Prepare 1st arg - x val
            bl      newton                           // Call newton function to calculate cube of x
            fmov    d1, d0                           // Move calculated value into d1

            adrp    x0, out_col                      // Prepare string for computed value
            add     x0, x0, :lo12:out_col            // Format lower 12 bits
            bl      printf                           // Call printf

            b       top                              // Branch to top

eof:        mov     w0, fd_r                         // 1st arg (fd)
            mov     x8, 57                           // Close I/O request
            svc     0                                // Call system function

exit:       ldp     fp, lr, [sp], dealloc            // Deallocate memory
            ret                                      // Return control to OS

/** Newton's Method function */
newton:     stp     fp, lr, [sp, -16]!               // Allocate memory
            mov     fp, sp                           // Update fp

            fmov    input_r, d0                      // Load arg (input val) into input_r
            fmov    tmpx_r, input_r                  // Store x value inside tmpx_r
            
            adrp    x25, cube_m                      // Get address of cube_m into x23
            add     x25, x25, :lo12:cube_m           // Format lower 12 bits
            ldr     cube_r, [x25]                    // Store constant value in cube_m in cube_r

            adrp    x24, const_m                     // Get address of const
            add     x24, x24, :lo12:const_m          // Format lower 12 bits
            ldr     limit_r, [x24]                   // Store constant in limit_r

            fmul    limit_r, input_r, limit_r        // limit_r = 3.0 * 1.0e-10
            fdiv    tmpx_r, input_r, cube_r          // Calculate first guess x = input / 3.0

loop:       fmul    yval_r, tmpx_r, tmpx_r           // y = x^2
            fmul    yval_r, yval_r, tmpx_r           // y = x^3

            fsub    dy_r, yval_r, input_r            // y = y - input

            fmul    dydx_r, tmpx_r, tmpx_r           // dydx = x^2
            fmul    dydx_r, dydx_r, cube_r           // dydx = 3.0x^2

            fdiv    xval_r, dy_r, dydx_r             // x = dy/dydx
            fsub    xval_r, tmpx_r, xval_r           // x = 3.0-(dy/dydx)

            fmov    tmpx_r, xval_r                   // Store the newly computed xval into tmpx_r

test:       fabs    dy_r, dy_r                       // dy = |dy|
            fcmp    dy_r, limit_r                    // |dy| >= limit
            b.ge    loop                             // on greater than or equal, branch back up to loop

done:       fmov    d0, xval_r                       // Return the calculated value to calling function
            ldp     fp, lr, [sp], 16                 // Deallocate
            ret                                      // Return control to calling function
