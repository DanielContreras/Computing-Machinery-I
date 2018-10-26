/**
 * Daniel Contreras
 * 10080311
 * CPSC 355 Fall 2018
 */

define(v_base_r, x19)                                       // Define v_base_r for offset of v[]
define(index_i_r, w20)                                      // Define register for index i
define(index_j_r, w21)                                      // Define register for index j

            /** Assembler offset Equates **/
            SIZE = 50                                       // Set SIZE to 50
            i_size = 4                                      // Size of i (4 bytes)
            j_size = 4                                      // Size of j (4 bytes)
            temp_size = 4                                   // Size of temp (4 bytes)
            v_size = 4 * SIZE                               // Size of array (4*50 bytes)

            /** Allocate memory for stack **/   
            alloc = i_size + j_size + temp_size + v_size    // Set alloc to the size of all the offsets
            alloc = -(16 + alloc) & -16                     // Align program
            dealloc = -alloc                                // Set dealloc to free all memory at the end of the program

            /** Equates of the offsets (base: FP) **/   
            i_s = 16                                        // Set size of i relative to Frame Record
            j_s = 20                                        // Set size of j relative to Frame Record
            temp_s = 24                                     // Set size of temp relative to Frame Record
            v_s = 28                                        // Set size of v relative to Frame Record
    

    
fp          .req x29                                        // Define fp as x29
lr          .req x30                                        // Define lr as x30
    
fmt1:       .string "v[%d]: %d\n"                           // Printing string
fmt2:       .string "\nSorted array:\n"                     // Printing string
            .balign 4       
            .global main        
    
main:       stp     fp, lr, [sp, alloc]!                    // Allocate space in memory for appropriate variable sizes
            mov     fp, sp                                  // Update fp
    
            add     v_base_r, fp, v_s                       // Calculate array base address
            mov     index_i_r, 0                            // Initialize i = 0
            str     index_i_r, [fp, i_s]                    // Store i in stack
            b       test1                                   // Branch to pre-test
    
loop1:      bl      rand                                    // Generate random numer; result stored in w0 
            and     w0, w0, 0xFF                            // mod the result with 256
            str     w0, [v_base_r, index_i_r, SXTW 2]       // Store the random number into stack v[i] = rand() & 0xFF
    
            adrp    x0, fmt1                                // Add fmt1 to x0
            add     x0, x0, :lo12:fmt1                      // Format string
            ldr     w1, [fp, i_s]                           // Load i_s into w1
            ldr     w2, [v_base_r, w1, SXTW 2]              // Load v[i] into w2
            bl      printf                                  // Call printf
    
            add     index_i_r, index_i_r, 1                 // Increment i by 1
            str     index_i_r, [fp, i_s]                    // Store i into memory
    
test1:      cmp     index_i_r, SIZE                         // if i < SIZE
            b.lt    loop1                                   // branch at less than to loop
    
            mov     index_i_r, 1                            // Initialize i to 1
            str     index_i_r, [fp, i_s]                    // Store i in stack
            b       test2                                   // Branch to pre-test for outer loop
    
loop2:      ldr     w25, [v_base_r, index_i_r, SXTW 2]      // Load v[i] 
            str     w25, [fp, temp_s]                       // Store temp = v[i]
    
            ldr     index_i_r, [fp, i_s]                    // Load i and place in index_i_r
            //TODO  
            str     index_i_r, [fp, j_s]                    // Store index_i_r in j_s (inner loop counter)
            b       innertest                               // Branch to inner loop pre-test
    
innerloop:  ldr     index_j_r, [fp, j_s]                    // Load j
            sub     index_j_r, index_j_r, 1                 // [j-1]
            ldr     w25, [v_base_r, index_j_r, SXTW 2]      // Load [j-1] into w25
            add     index_j_r, index_j_r, 1                 // Increment index 
            str     w25, [v_base_r, index_j_r, SXTW 2]      // v[j] = v[j-1]
            sub     index_j_r, index_j_r, 1                 // Decrement index back
            str     index_j_r, [fp, j_s]                    // Store j
    
innertest:  ldr     index_j_r, [fp, j_s]                    // Load j into index_j_r
            cmp     index_j_r, 0                            // j > 0
            b.le    lp2body                                 // Branch to point after inner loop
            ldr     w25, [fp, temp_s]                       // Else, load temp_s into w25
            sub     w22, index_j_r, 1                       // Computer j-1
            ldr     w23, [v_base_r, w22, SXTW 2]            // v[j-1]
            cmp     w25, w23                                // temp < v[j-1]
            b.ge    lp2body                                 // Branch to point after loop
            b       innerloop                               // Else branch to inner loop
    
lp2body:    ldr     index_j_r, [fp, temp_s]                 // Load temp into index_j_r
            ldr     w25, [fp, j_s]                          // Load j_s into w25
            str     index_j_r, [v_base_r, w25, SXTW 2]      // Store v[j] = v[j-1]
    
            ldr     index_i_r, [fp, i_s]                    // Load i into index_i_r
            add     index_i_r, index_i_r, 1                 // Increment i
            str     index_i_r, [fp, i_s]                    // Store i in memory
    
test2:      cmp     index_i_r, SIZE                         // i < SIZE
            b.lt    loop2                                   // Branch to loop2 if true
    
            adrp    x0, fmt2                                // Add fmt2 to x0
            add     x0, x0, :lo12:fmt2                      // Format string
            bl      printf                                  // Call printf
            mov     index_i_r, 0                            // Set index counter for final loop
            str     index_i_r, [fp, i_s]                    // Store index in memory
            b       test3                                   // Branch to pre-test for final loop
    
loop3:      adrp    x0, fmt1                                // Add fmt to x0
            add     x0, x0, :lo12:fmt1                      // Format string
            ldr     w1, [fp, i_s]                           // Load index to paramter 1
            ldr     w2, [v_base_r, w1, SXTW 2]              // Load v[i] in parameter 2
            bl      printf                                  // Call printf
            add     index_i_r, index_i_r, 1                 // Increment index
            str     index_i_r, [fp, i_s]                    // Store index into memory
    
test3:      cmp     index_i_r, SIZE                         // i < SIZE
            b.lt    loop3                                   // Branch to top of loop if i < SIZE
    
done:       mov w0, 0                                       // Set return value
            ldp fp, lr, [sp], dealloc                       // Deallocate memory
            ret                                             // Return control to OS