define(base_r, x25)

/** Assembler Equates */
QUEUESIZE = 8
MODMASK = 0x7
TRUE = 1
FALSE = 0

/** Declare External Variables */
            .data
head:       .word   -1
tail:       .word   -1

            .bss
queue:      .skip   QUEUESIZE * 4

            .text

/** Strings */
overflow:   .string "\nQueue overflow! Cannot enqueue into a full queue.\n"
underflow:  .string "\nQueue underflow! Cannot dequeue from an empty queue.\n"
empty:      .string "\nEmpty queue\n"
current:    .string "\nCurrent queue contents:\n"
element:    .string "  %d"
head_q:     .string " <-- head of queue"
tail_q:     .string " <-- tail of queue"
newline:    .string "\n"

            .balign 4
            .global enqueue
            .global dequeue
            .global queueFull
            .global queueEmpty
            .global display

            fp  .req x29
            lr  .req x30

/** enqueue function */
define(value_r, w9)                                   
define(tail_r, w10)                                 
enqueue:    stp     fp, lr, [sp, -16]!                      // Allocate Memory
            mov     fp, sp                                  // Update fp

            mov     value_r, w0                               // val = w0
            bl      queueFull                               // branch to queueFull
            cmp     w0, TRUE                                // Compare results to TRUE
            b.ne    en_if                                   // if not equal, branch to en_if

            adrp    x0, overflow                            // Add first arg
            add     x0, x0, :lo12:overflow                  // Format lower 12 bits
            bl      printf                                  // branch to printf
            b       en_done                                 // branch to en_done

en_if:      bl      queueEmpty                              // branch to queueEmpty
            cmp     w0, TRUE                                // Compare results to TRUE
            b.ne    en_else                                 // if not equal, branch to en_else

            adrp    base_r, head                            // Get base address of head
            add     base_r, base_r, :lo12:head              // Format lower 12 bits
            str     wzr, [base_r]                           // Clear base_r
            adrp    base_r, tail                            // get base address of tail
            add     base_r, base_r, :lo12:tail              // Format lower 12 bits
            str     wzr, [base_r]                           // clear base_r

            b       en_body                                 // branch to en_body

en_else:    adrp    base_r, tail                            // get base address of tail
            add     base_r, base_r, :lo12:tail              // format lower 12 bits

            ldr     tail_r, [base_r]                        // Load tail
            add     tail_r, tail_r, 1                       // tail ++
            and     tail_r, tail_r, MODMASK                 // tail++ & MODMASK
            str     tail_r, [base_r]                        // Store tail 

en_body:    ldr     tail_r, [base_r]                        // Load tail
            adrp    base_r, queue                           // Get base address of of queue
            add     base_r, base_r, :lo12:queue             // format lower 12 bits
            str     value_r, [base_r, tail_r, SXTW 2]       // store value

en_done:    ldp     fp, lr, [sp], 16                        // Deallocate
            ret                                             // return
            

/** dequeue function */
define(head_r, w12)                                 
define(tail_r, w13)  
define(value_r, w11)                              
dequeue:    stp     fp, lr, [sp, -16]!                      // allocate space
            mov     fp, sp                                  // update fp

            bl      queueEmpty                              // branch to queueEmpty
            cmp     w0, TRUE                                // compare w0 to true
            b.ne    de_if                                   // on not equal, branch to de_if

            adrp    x0, underflow                           // prepare first arg
            add     x0, x0, :lo12:underflow                 // format lwoer 12 bits
            bl      printf                                  // branch to printf
            mov     w0, -1                                  // w0 = -1
            b       de_done                                 // branch to done

de_if:      adrp    base_r, head                            // get base address of head
            add     base_r, base_r, :lo12:head              // format lower 12 bits
            ldr     head_r, [base_r]                        // load head

            adrp    base_r, queue                           // get base address of queuee
            add     base_r, base_r, :lo12:queue             // format lower 12 bits
            ldr     value_r, [base_r, head_r, SXTW 2]       // load value

            adrp    base_r, tail                            // get base address of tail
            add     base_r, base_r, :lo12:tail              // format lower 12 bits
            ldr     tail_r, [base_r]                        // load tail

            cmp     head_r, tail_r                          // if (head != tail) then
            b.ne    de_else                                 // branch to de_else

            mov     w22, -1                                 // w22 = -2
            adrp    base_r, head                            // get base address of head
            add     base_r, base_r, :lo12:head              // format lower 12 bits
            str     w22, [base_r]                           // store w22 into base_r
            adrp    base_r, tail                            // get base address of tail
            add     base_r, base_r, :lo12:tail              // format lower 12 bits
            str     w22, [base_r]                           // store w22 into base_r
            b       de_ret                                  // branch to de_ret
    
de_else:    add     head_r, head_r, 1                       // head++
            and     head_r, head_r, MODMASK                 // head++ & MODMASK
            adrp    base_r, head                            // get base address of head
            add     base_r, base_r, :lo12:head              // format lower 12 bits
            str     head_r, [base_r]                        // store head int base

de_ret:     mov     w0, value_r                             // w0 = value

de_done:    ldp     fp, lr, [sp], 16                        // deallocate
            ret                                             // return

/** queueFull function */
define(head_r, w14)                               
define(tail_r, w15)                               
queueFull:  stp     fp, lr, [sp, -16]!                      // allocate space
            mov     fp, sp                                  // update fp

            adrp    base_r, tail                            // get base address of tail
            add     base_r, base_r, :lo12:tail              // format lower 12 bits
            ldr     tail_r, [base_r]                        // load tail
    
            add     tail_r, tail_r, 1                       // tail++
            and     tail_r, tail_r, MODMASK                 // tail++ & MODMASK

            adrp    base_r, head                            // Get base address of head
            add     base_r, base_r, :lo12:head              // format lower 12 bits
            ldr     head_r, [base_r]                        // load head

            cmp     tail_r, head_r                          // if tail != head
            b.ne    fu_false                                // branch to fu_false
            mov     w0, TRUE                                // else, w0 = true
            b       fu_done                                 // branch to done

fu_false:   mov     w0, FALSE                               // w0 = false

fu_done:    ldp     fp, lr, [sp], 16                        // deallocate
            ret                                             // return


/** queueEmpty function */
define(head_r, w19)                               
queueEmpty: stp     fp, lr, [sp, -16]!                      // allocate space
            mov     fp, sp                                  // update FP        

            adrp    base_r, head                            // get base address of head
            add     base_r, base_r, :lo12:head              // format lower 12 bits
            ldr     head_r, [base_r]                        // load head

            cmp     head_r, -1                              // if (head != -1)
            b.ne    em_false                                // then, branch to em_false
            mov     w0, TRUE                                // else, w0 = true
            b       em_done                                 // branch to em_done

em_false:   mov     w0, FALSE                               // w0 = false

em_done:    ldp     fp, lr, [sp], 16                        // deallocate
            ret                                             // return

/** display function */
define(i_r, w20)                                   
define(j_r, w21)                                   
define(count_r, w22)                               
define(tail_r, w23)                                
define(head_r, w24)                                   
display:    stp     fp, lr, [sp, -16]!                      // allocate space
            mov     fp, sp                                  // update fp

            bl      queueEmpty                              // branch queueEmpty
            cmp     w0, TRUE                                // compare w0 to true
            b.ne    di_if                                   // if not equal, branch to di_if

            adrp    x0, empty                               // load first arg
            add     x0, x0, :lo12:empty                     // format lower 12 bits
            bl      printf                                  // call printf
            b       di_done                                 // branch to di_done

di_if:      adrp    base_r, head                            // get base address of head
            add     base_r, base_r, :lo12:head              // format lower 12 bits
            ldr     head_r, [base_r]                        // load head

            adrp    base_r, tail                            // get base address of tail
            add     base_r, base_r, :lo12:tail              // format lower 12 bits
            ldr     tail_r, [base_r]                        // load tail

            sub     count_r, tail_r, head_r                 // count = tail - head
            add     count_r, count_r, 1                     // count ++

            cmp     count_r, 0                              // if (count > 0)
            b.gt    di_body                                 // then, branch to di_body
            add     count_r, count_r, QUEUESIZE             // else, count += QUEUEUSIZe

di_body:    adrp    x0, current                             // load first arg
            add     x0, x0, :lo12:current                   // format lower 12 bits
            bl      printf                                  // printf()

            mov     i_r, head_r                             // i = head
            mov     j_r, 0                                  // j = 0
            b       for_test                                // branch to pre test 

for:        adrp    x0, element                             // load first arg
            add     x0, x0, :lo12:element                   // format lower 12 bits
            adrp    base_r, queue                           // get base address of queue
            add     base_r, base_r, :lo12:queue             // format lower 12 bits
            ldr     w1, [base_r, i_r, SXTW 2]               // load second arg
            bl      printf                                  // printf()

            cmp     i_r, head_r                             // if i != head
            b.ne    next                                    // then, branch to next
            adrp    x0, head_q                              // else, load 1st arg
            add     x0, x0, :lo12:head_q                    // format lower 12 bits
            bl      printf                                  // printf()

next:       cmp     i_r, tail_r                             // if i != tail
            b.ne    for_body                                // then, branch to for_body
            adrp    x0, tail_q                              // else, load 1st arg
            add     x0, x0, :lo12:tail_q                    // format lower 12 bits
            bl      printf                                  // printf()

for_body:   adrp    x0, newline                             // load 1st arg
            add     x0, x0, :lo12:newline                   // format lower 12 bits
            bl      printf                                  // printf()

            add     i_r, i_r, 1                             // i++
            and     i_r, i_r, MODMASK                       // i++ & MODMASK

            add     j_r, j_r, 1                             // j++

for_test:   cmp     j_r, count_r                            // if j < count
            b.lt    for                                     // then branch to for

di_done:    ldp     fp, lr, [sp], 16                        // deallocate
            ret                                             // return
