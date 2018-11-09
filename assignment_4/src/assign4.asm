/**
 * Daniel Contreras
 * 10080311
 * CPSC 355 Fall 2018
 */

            /** General Assembler Equates */
            FALSE = 0                                               // Define FALSE as 0
            TRUE = 1                                                // Define FALSE as 0

            /** point struct (8 bytes total) */
            point_x = 0                                             // offset - 4 bytes
            point_y = 4                                             // offset - 4 bytes

            /** dimension struct (8 bytes total) */
            dimension_width = 0                                     // offset - 4 bytes
            dimension_height = 4                                    // offset - 4 bytes

            /** box struct (20 bytes total) */
            box_origin = 0                                          // offset - point struct (8 bytes)
            box_dimension = 8                                          // offset - dimension struct (8 bytes)
            box_area = 16                                           // offset - int (4 bytes)
            box_size = 20                                           // Size of box (20 bytes)

            /** Define box sizes */
            first_size = box_size                                   // Define size of first box
            second_size = box_size                                  // Define size of second box

            /** Allocation of the boxes */
            alloc = -(16 + first_size + second_size) & -16          // Allocate space on the stack for first and second box
            dealloc = -alloc                                        // Deallocate (when called) the allocated space

            /** Offsets of the boxes from the frame record */
            first_s = 16                                            // Offset memory location of first box from the frame record
            second_s = first_s + box_size                           // Offset memory location of second box from the frame record

            fp .req x29                                             // Define x29 as fp
            lr .req x30                                             // Define x30 as lr

fmt1:       .string "Box %s origin = (%d, %d)  width = %d  height = %d  area = %d\n"
fmt2:       .string "Initial box values:\n"
fmt3:       .string "\nChanged box values:\n"
first:      .string "first"
second:     .string "second"
            .balign 4
            .global main

main:       stp     fp, lr, [sp, alloc]!                            // Memory allocations
            mov     fp, sp                                          // Update fp

            add     x1, fp, first_s                                 // Calculate base address of first box
            bl      newBox                                          // Call newBox()
            
            add     x1, fp, second_s                                // Calculate base address of second box
            bl      newBox                                          // Call newBox()

            adrp    x0, fmt2                                        // Add fmt to x0
            add     x0, x0, :lo12:fmt2                              // Format string
            bl      printf                                          // Call printf

            adrp    x0, first                                       // Add first to x0
            add     x0, x0, :lo12:first                             // Format string
            add     x1, fp, first_s                                 // Add first argument (address of first box)
            bl      printBox                                        // call printBox

            adrp    x0, second                                      // Add second to x0
            add     x0, x0, :lo12:second                            // Format string
            add     x1, fp, second_s                                // Add second argument (address of second box)
            bl      printBox                                        // call printBox

            add     x0, fp, first_s                                 // Load first arg into x0
            add     x1, fp, second_s                                // Load second arg into x1
            bl      equal                                           // Call equal()
            cmp     w0, FALSE                                       // Compare result with 0 (FALSE)
            b.eq    next                                            // If result is 0 (False) then leave if statement

            add     x0, fp, first_s                                 // Load first arg into x0
            mov     w1, -5                                          // Load second arg into w1
            mov     w2, 7                                           // Load third arg into w2
            bl      move                                            // Call move()

            add     x0, fp, second_s                                // Load first arg into x0
            mov     w1, 3                                           // Load second arg into w1
            bl      expand                                          // Call expand()

next:       adrp    x0, fmt3                                        // Add fmt3 to x0
            add     x0, x0, :lo12:fmt3                              // Format string
            bl      printf                                          // Call printf()

            adrp    x0, first                                       // Add first to x0
            add     x0, x0, :lo12:first                             // Format string
            add     x1, fp, first_s                                 // Add first argument (address of first box)
            bl      printBox                                        // call printBox()

            adrp    x0, second                                      // Add second to x0
            add     x0, x0, :lo12:second                            // Format string
            add     x1, fp, second_s                                // Add second argument (address of second box)
            bl      printBox                                        // call printBox()  

done:       ldp     fp, lr, [sp], dealloc                           // Deallocate memory
            ret                                                     // Return control to OS

/** newBox function */
            b_alloc = -(16 + box_size) & -16                        // Create allocation definition for newBox
            b_dealloc = -b_alloc                                    // Create deallocation definition for newBox

newBox:     stp     fp, lr, [sp, b_alloc]!                          // Create allocations
            mov     fp, sp                                          // Update fp

            mov     w9, 1                                           // Set w9 = 1

            str     xzr, [x1, box_origin + point_x]                 // b.origin.x = 0
            str     xzr, [x1, box_origin + point_y]                 // b.origin.y = 0

            str     w9, [x1, box_dimension + dimension_width]       // b.size.width = 1
            str     w9, [x1, box_dimension + dimension_height]      // b.size.height = 1

            str     w9, [x1, box_area]                              // Store w10 (area) in memory

            ldp     fp, lr, [sp], b_dealloc                         // Deallocate space
            ret                                                     // Return to calling function

/** move function */
move:       stp     fp, lr, [sp, -16]!                              // Allocate space in memory
            mov     fp, sp                                          // Update fp

            ldr     w9, [x0, box_origin + point_x]                  // w9 = b->origin.x
            add     w9, w9, w1                                      // w9 = b->origin.x += deltaX
            str     w9, [x0, box_origin + point_x]                  // Store w9 back into memory

            ldr     w9, [x0, box_origin + point_y]                  // w9 = b->origin.y
            add     w9, w9, w2                                      // w9 = b->origin.y += deltaY
            str     w9, [x0, box_origin + point_y]                  // Store w9 back into memory

            ldp     fp, lr, [sp], 16                                // Deallocate space
            ret                                                     // Return to caller

/** expand function */
expand:     stp     fp, lr, [sp, -16]!                              // Allocate space in memory
            mov     fp, sp                                          // Update fp

            ldr     w9, [x0, box_dimension + dimension_width]       // Load b->size.width into w9
            mul     w9, w9, w1                                      // b->size.width *= factor
            str     w9, [x0, box_dimension + dimension_width]       // Store result back into memory

            ldr     w10, [x0, box_dimension + dimension_height]     // Load b->size.height into w10
            mul     w10, w10, w1                                    // b->size.height *= factor
            str     w10, [x0, box_dimension + dimension_height]     // Store result back into memory

            mul     w9, w9, w10                                     // w9 = width * height (area)
            str     w9, [x0, box_area]                              // Store result into memory

            mov     w0, 0
            ldp     fp, lr, [sp], 16                                // Deallocate space
            ret                                                     // Return to caller

/** printBox function */
printBox:   stp     fp, lr, [sp, -16]!                              // Allocate space in memory
            mov     fp, sp                                          // Update fp

            ldr     w2, [x1, box_origin + point_x]                  // Load second arg 
            ldr     w3, [x1, box_origin + point_y]                  // Load third arg
            ldr     w4, [x1, box_dimension + dimension_width]       // Load fourth arg
            ldr     w5, [x1, box_dimension + dimension_height]      // Load fifth arg
            ldr     w6, [x1, box_area]                              // Load sixth arg
           
            mov     x1, x0 
            adrp    x0, fmt1                                        // Add fmt1 to x0
            add     x0, x0, :lo12:fmt1                              // Format string
            bl      printf                                          // Call printf

            ldp     fp, lr, [sp], 16                                // Deallocate space
            ret                                                     // Return to caller

/** equal function */
equal:		stp     fp, lr, [sp, -16]!					            // Allocate space in memory
		    mov     fp, sp							                // Update fp

		    ldr     w10, [x0, box_origin + point_x]				    // w10 = b1->origin.x
		    ldr     w11, [x1, box_origin + point_x]				    // w11 = b2->origin.x
		    cmp     w10, w11							            // Compare w10 and w11
		    b.ne    ret_false							            // If they are not equal, return false

		    ldr     w10, [x0, box_origin + point_y]				    // w10 = b1->origin.y
		    ldr     w11, [x1, box_origin + point_y]				    // w11 = b2->origin.y
		    cmp     w10, w11							            // Compare w10 and w11
		    b.ne    ret_false							            // If they are not equal, return false

		    ldr     w10, [x0, box_dimension + dimension_width]	    // w10 = b1->size.width
		    ldr     w11, [x1, box_dimension + dimension_width]		// w11 = b2->size.width
		    cmp     w10, w11							            // Compare w10 and w11
		    b.ne    ret_false							            // If they are not equal, return false

		    ldr     w10, [x0, box_dimension + dimension_height]		// w10 = b1->size.height
		    ldr     w11, [x1, box_dimension + dimension_height]		// w11 = b2->size.height
		    cmp     w10, w11							            // Compare w10 and w11
		    b.ne    ret_false							            // If they are not equal, return false

		    mov     x0, TRUE							            // Set return value to TRUE
            b       endequal                                        // Branch to end of function

ret_false:  mov     w0, FALSE                                       // Set return value to FALSE

endequal:	ldp     fp, lr, [sp], 16						        // Deallocate space
		    ret								                        // Return to caller