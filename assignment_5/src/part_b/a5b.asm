/**
 * Daniel Contreras
 * 10080311
 * CPSC 355 Fall 2018
 */

/** M4 Definitions */
define(argc_r, w19)
define(argv_r, x20)

define(month_r, w21)
define(day_r, w22)
define(season_r, w25)
define(tmp_month_r, w26)
define(suffix_r, w3)

define(month_base_r, x23)
define(suffix_base_r, x22)
define(season_base_r, x24)

/** Strings representing months of the year */
jan_m:      .string "January"
feb_m:      .string "February"
mar_m:      .string "March"
apr_m:      .string "April"
may_m:      .string "May"
jun_m:      .string "June"
jul_m:      .string "July"
aug_m:      .string "August"
sep_m:      .string "September"
oct_m:      .string "October"
nov_m:      .string "November"
dec_m:      .string "December"

/** Strings representing seasons of the year */
win_m:      .string "Winter"
spr_m:      .string "Spring"
sum_m:      .string "Summer"
fal_m:      .string "Fall"

/** Strings representing suffixes */
th_m:		.string "th"
st_m:		.string "st"				
nd_m:		.string "nd"				
rd_m:		.string "rd"					
						
/** Strings containing messages to display */
display:	.string "%s %d%s is %s\n"			
usage:		.string "Usage: a5b mm dd\n"	
err_msg:	.string "Error: Day is out of range for that month\n"		

/** Initialize arrays in the .data section and doubleword aligned*/
            .data
            .balign 8
month_m:    .dword  jan_m, feb_m, mar_m, apr_m, may_m, jun_m, jul_m, aug_m, sep_m, oct_m, nov_m, dec_m
suffix_m:   .dword  th_m, st_m, nd_m, rd_m
season_m:   .dword  win_m, spr_m, sum_m, fal_m

		    .text

            fp  .req x29
            lr  .req x30

            .balign 4
            .global main

main:       stp     fp, lr, [sp, -16]!								// Memory Allocations
            mov     fp, sp											// Update fp

            mov     argc_r, w0                  					// Store argc_c in w0
            mov     argv_r, x1                  					// Store arg_v in x1

            cmp     argc_r, 3                   					// Check that 3 command line arguments have been given
            b.eq    continue                    					// If true, branch to continue
            adrp    x0, usage                   					// else, prepare the error message
            add     x0, x0, :lo12:usage         					// Format lower 12 bits of usage
            bl      printf                      					// Call to printf
            b       done                        					// Branch to done (terminate program)

continue:   ldr     x0, [argv_r, 8]									// Load first command line arg into x0
            bl      atoi											// Convert arg to int 
            mov     month_r, w0										// Move the converted arg into month_r

            ldr     x0, [argv_r, 16]								// Load second command line arg into x0
            bl      atoi											// Convert arg to int
            mov     day_r, w0										// Move the converted arg into day_r

            cmp     month_r, 1										// if (month < 1) then,
            b.lt    error											// branch to error
            cmp     month_r, 12										// if (month > 12) then,
            b.gt    error											// branch to error
            cmp     day_r, 1										// if (day < 1) then
            b.lt    error											// branch to error
            cmp     day_r, 31										// if (day > 31) then,
            b.gt    error											// branch to error

suffix_s:	cmp	    day_r, 11										// else, if (day < 11)
		    b.lt	suffix											// branch to suffix
		    cmp	    day_r, 13										// else if (day > 13)
		    b.gt	suffix											// branch to suffix
		    mov	    suffix_r, 0										// else suffix = "th"

suffix:	    mov	    w24, 10											// w24 = 10 (for modulus)
		    udiv	suffix_r, day_r, w24							// suffix = day / 10
		    msub	suffix_r, w24, suffix_r, day_r					// suffix = 10 - (suffix * day)
		    cmp	    suffix_r, 3										// if (suffix <= 3)
		    b.le	season											// branch to season
		    mov	    suffix_r, 0										// else, suffix = "th"
		    b	    season											// branch to season

season:		mov	    tmp_month_r, month_r							// tmp_month = month
		    cmp	    day_r, 21										// if (day < 21) then,
		    b.lt	season1											// branch to season1
		    add	    tmp_month_r, tmp_month_r, 1						// else, tmp_month++ 

season1:	cmp	    tmp_month_r, 12									// if (tmp_month <= 12)
		    b.le	winter											// branch to winter
		    mov	    tmp_month_r, 1									// else, tmp_month = 1

winter:		cmp	    tmp_month_r, 3									// if (tmp_month > 3)
		    b.gt	spring											// branch to spring
		    mov	    season_r, 0										// season_r = winter
		    b	    output											// branch to output

spring:		cmp	    tmp_month_r, 5									// if (tmp_month > 5)
		    b.gt	summer											// branch to summer
		    mov	    season_r, 1										// season_r = spring
		    b	    output											// branch to output

summer:		cmp	    tmp_month_r, 9									// if (month > 9)
		    b.gt	fall											// branch to fall
		    mov	    season_r, 2										// else, season = summer
		    b	    output											// branch to output

fall:		mov	    season_r, 3										// else, season = fall

output:		adrp	x0, display				            			// Load string arg to x0
		    add	    x0, x0, :lo12:display			    			// format string
    
		    adrp	month_base_r, month_m				            // Get base address of month
		    add	    month_base_r, month_base_r, :lo12:month_m		// Format lower 12 bits
		    sub	    month_r, month_r, 1				                // month - 1 (to account for having incremented it)
		    ldr	    x1, [month_base_r, month_r, SXTW 3]			    // Load first arg
    
		    mov	    w2, day_r					                    // second arg

		    adrp	suffix_base_r, suffix_m				            // Get base address of suffix
		    add	    suffix_base_r, suffix_base_r, :lo12:suffix_m	// Format lower 12 bits
		    ldr	    x3, [suffix_base_r, suffix_r, SXTW 3]			// 3rd arg
    
		    adrp	season_base_r, season_m				            // Get base address of season
		    add	    season_base_r, season_base_r, :lo12:season_m	// Format lower 12 bits
		    ldr	    x4, [season_base_r, season_r, SXTW 3]			// 4th arg
		    bl	    printf					                        // call printf
		    b	    done					                        // branch to done

error:		adrp	x0, err_msg										// add err_msg to arg	
		    add	    x0, x0, :lo12:err_msg							// format string
		    bl	    printf											// call printf

done:		ldp	    x29, x30, [sp], 16								// Deallocate space
		    ret														// Return
