/*
*	Assignment 4
*	
*	Lecture Section: L01
*	Prof. Leonard Manzara
*
*	Evan Loughlin
*	UCID: 00503393
*	Date: 2017-03-13
*
*	assign4.asm: 
*	An assignment, which practices utilization of subroutines and structs. This program allows the "main" method to act as a driver, which creates instances of two boxes. 
*	It then invokes various methods (subroutines) in the program, which modifies the first box. The output is printed, which indicates the details of the first and second
*	boxes. 
*	
*	
*	Reference material used for this assignment: edwinckc.com/CPSC355/
*
*/


// ================================================================ PRINT FUNCTIONS ==================================================================================
												
print_1:	.string "Box %s origin = (%d, %d) width = %d height = %d area = %d\n"		// Print function, displaying details of a given box.

print_first:	.string "first"									// String for "first" box.					

print_second:	.string "second"								// String for "second" box.

print_init:	.string "Initial box values:\n"							// String for printing before box values.

print_change:	.string "Changed box values:\n"							// String for printing after box values.

// =============================================================== /END PRINT FUNCTIONS ==============================================================================


		.balign 4							// Instructions must be aligned word aligned (4 bytes)


// ============================================================= DEFINE REGISTERS ===================================================================================

		fp .req x29							// Define fp as x29
		lr .req x30							// Define lr as x30	

// ============================================================ / END: DEFINE REGISTERS ============================================================================





// ============================================================ STRUCT EQUATES ==========================================================================


// ------------------------------------------------------------ STRUCT: POINT ----------------------------------------------------------------


		point_x = 0							// Offset of #point_x# from base of struct point
		point_y = 4							// Offset of #point_y# from base of struct point
		struct_point_size = 8						// Size of struct "point". (Two ints, each of size 4 bytes)

// ------------------------------------------------------------ / END: STRUCT: POINT ---------------------------------------------------------



// ------------------------------------------------------------ STRUCT: DIMENSION ------------------------------------------------------------

		dimension_width = 0						// Offset of #dimension_width# from base of struct dimension
		dimension_height = 4						// Offset of #dimension_height# from base of struct dimension
		struct_dimension_size = 8					// Size of struct "dimension". (Two ints, each of size 4 bytes)

// ------------------------------------------------------------ /END: STRUCT: DIMENSION ------------------------------------------------------



// ------------------------------------------------------------ STRUCT: BOX ------------------------------------------------------------------

		box_origin = 0							// Offset of struct "point" within struct "box"
		box_dimension = 8						// Offset of struct "dimension" within struct "box"
		box_area = 16							// Offset of int "area".
		struct_box_size = 20						// Size of the struct "box. (Two structs, each of size 8 bytes, and one int)

// ------------------------------------------------------------- /END: STRUCT: BOX ------------------------------------------------------------

//======================================================================== / END: STRUCT EQUATES ===================================================================




// ================================================================= MEMORY ALLOCATION ==============================================================================

		box_1 = struct_box_size						// "Creating" an instance of box 1 struct in memory
		box_2 = struct_box_size						// "Creating" an instance of box 2 struct in memory
		alloc = -(16 + box_1 + box_2) & -16				// Define total memory allocation, AND with -16 to ensure quadword alignment.
		dealloc = -alloc						// Set the size of memory to be deallocated.
	
		box_1_s = 16							// Offset of box 1 from the frame record.
		box_2_s = box_1_s + struct_box_size				// Offset of box 2 from the frame record.
		

// ================================================================= / END: MEMORY ALLOCATION  =====================================================================




// ================================================================== SUBROUTINE DEFINITIONS =======================================================================

		FALSE = 0							// Define "False" as 0.
		TRUE = 1							// Define "True" as 1.

// ------------------------------------------------------------------- SUBROUTINE: NEWBOX ---------------------------------------------------------------------

newbox:		stp x29, x30, [sp, -16]!					// Allocate 16 bytes of memory for the newbox frame record.
		mov fp, sp							// Move the stack pointer to the frame pointer.

		mov w9, 0							// Use temp register w9 to hold value of 0.
		mov w10, 1							// Use temp register w10 to hold value of 1.

 		str w9,	[x0, box_origin + point_x]				// b.origin.x = 0 
		str w9, [x0, box_origin + point_y]				// b.origin.y = 0
		str w10, [x0, box_dimension + dimension_width]			// b.size.width = 1
		str w10, [x0, box_dimension + dimension_height]			// b.size.height = 1
		str w10, [x0, box_area]						// b.size.area = 1*1 = 1 (no extra operations required, since initially = 1.)

		mov w0, 0							// Return w0 to 0
ret_1:		ldp x29, x30, [sp], 16						// De-allocate the subroutine memory.
		ret								

// ------------------------------------------------------------------- / END: SUBROUTINE: NEWBOX --------------------------------------------------------------


// ------------------------------------------------------------------- SUBROUTINE: MOVE -----------------------------------------------------------------------

move:		stp x29, x30, [sp, -16]!					// Allocate 16 bytes of memory for the move frame record.
		mov fp, sp							// Reset the stack pointer to the current frame record

										// For this function, x0, w1, and w2 are inputs.

		mov x21, x0							// x21 = base address of box struct to be moved.
		mov w22, w1							// w22 = int deltaX (amount to move x)
		mov w23, w2							// w23 = int deltaY (amount to move y)

		ldr w24, [x21, box_origin + point_x]				// Load current box x value to w24
		add w24, w24, w22						// X_new = X + deltaX
		str w24, [x21, box_origin + point_x]				// Store new x value back in memory

		ldr w24, [x21, box_origin + point_y]				// Load current y value to w24
		add w24, w24, w23						// Y_new = Y + deltaY
		str w24, [x21, box_origin + point_y]				// Store new y value back in memory

		mov x0, 0							// Return x0 to 0
		mov w1, 0							// Return w1 to 0
		mov w2, 0							// Return w2 to 0
	
ret2:		ldp x29, x30, [sp], 16						// De-allocate the subroutine memory.
		ret								// Return to caller
						
// ------------------------------------------------------------------- / END: SUBROUTINE: MOVE ----------------------------------------------------------------
		

// ------------------------------------------------------------------- SUBROUTINE: EXPAND ---------------------------------------------------------------------

expand:		stp x29, x30, [sp, -16]!					// Allocate 16 bytes of memory for the expand subroutine
		mov fp, sp							// Reset the stack pointer to the current frame record.

		mov x21, x0							// x21 = base address of box to be expanded
		mov w22, w1							// w22 = factor (input for this subroutine)

		ldr w24, [x21, box_dimension + dimension_width]			// Load box.dimension.width from memory, based on base address
		mul w24, w24, w22						// Multiply width by factor
		str w24, [x21, box_dimension + dimension_width]			// Store new factored dimension back in memory

		ldr w25, [x21, box_dimension + dimension_height]		// Load box.dimension.height from memory, based on base address 
		mul w25, w25, w22						// Multiply height by factor
		str w25, [x21, box_dimension + dimension_height]		// Store new factored dimension back in memory

		mul w25, w25, w25						// w25 = area = height * width
		str w25, [x21, box_area]					// Store new area in memory.

		mov x0, 0							// Return x0 to 0
		mov w1, 0							// Return w1 to 0

ret3:		ldp x29, x30, [sp], 16						// De-allocate the subroutine memory
		ret								// Return to caller

// ------------------------------------------------------------------- /END: SUBROUTINE: EXPAND ---------------------------------------------------------------


// ------------------------------------------------------------------- SUBROUTINE: PRINTBOX -------------------------------------------------------------------

printbox:	stp x29, x30, [sp, -16]!					// Allocate 16 bytes of memory for the print box function.
		mov fp, sp							// Move SP to new FP

										// x0 register is taken as an input, which indicates the base of the array.
										// All other temp registers are loaded in this subroutine.
		
		mov x21, x0							// Move base address stored in x0 into x19		
		mov x25, x1							// Move the "string" input (first or second) into x25

		adrp x0, print_1						// Load arguments into register for print_1 function	
		add w0, w0, :lo12:print_1					
		ldr w2, [x21, box_origin + point_x]				// Load #box.origin.x# into w1
		ldr w3, [x21, box_origin + point_y]				// Load #box.origin.y# into w2
		ldr w4, [x21, box_dimension + dimension_width]			// Load #box.dimension.width# into w3
		ldr w5, [x21, box_dimension + dimension_height]			// Load #box.dimension.height# into w4
		ldr w6, [x21, box_area]						// Load #box.area# into w5
		bl printf							// Branch to print function


		mov x0, 0							// Return x0 to 0
ret4:		ldp x29, x30, [sp], 16						// De-allocate the frame record.
		ret

// ------------------------------------------------------------------- / END: SUBROUTINE: PRINTBOX -------------------------------------------------------------


// ------------------------------------------------------------------- SUBROUTINE: EQUAL -----------------------------------------------------------------------

equal:		stp x29, x30, [sp, -16]!					// Allocate 16 bytes of memory for the equal subroutine
		mov fp, sp							// Move SP to new FP

		mov x19, x0							// x0 is input: base of struct box 1
		mov x20, x1							// x1 is input: base of struct box 2

		ldr x21, [x19, box_origin + point_x]				// Load box1_origin_x into x21
		ldr x22, [x20, box_origin + point_x]				// Load box2_origin_x into x22
		cmp x21, x22							// Compare two numbers
		b.ne false_eq							// If the two numbers are not equal, branch to return false.

		ldr x21, [x19, box_origin + point_y]				// Load box1_origin_y into x21
		ldr x22, [x20, box_origin + point_y]				// Load box2_origin_y into x22
		cmp x21, x22							// Compare two numbers
		b.ne false_eq							// If the two numbers are not equal, branch to return false.

		ldr x21, [x19, box_dimension + dimension_width]			// Load box1_width into x21
		ldr x22, [x20, box_dimension + dimension_width]			// Load box2_width into x22
		cmp x21, x22							// Compare two numbers
		b.ne false_eq							// If the two numbers are not equal, branch to return false.

		ldr x21, [x19, box_dimension + dimension_height]		// Load box1_height into x21
		ldr x22, [x20, box_dimension + dimension_height]		// Load box2_height into x22
		cmp x21, x22							// Compare two numbers
		b.ne false_eq							// If the two numbers are not equal, branch to return false.

		mov x0, TRUE							// If the program has got to this point, all variables are equal. Set x0 to true.
		b done_eq							// Branch to the end of the program.
false_eq:		
		mov x0, FALSE							// Set x0 to false.

done_eq:	ldp x29, x30, [sp], 16						// De-allocate the frame record
		ret								// Return to caller.



// ------------------------------------------------------------------- / END: SUBROUTINE: EQUAL ----------------------------------------------------------------



// ================================================================== /END SUBROUTINE DEFINITIONS ===================================================================



// ============================================================ MAIN ===============================================================================================

		.global main							// Makes "main" visible to the OS

main:		stp x29, x30, [sp, alloc]!					// Save FP and LR to stack, allocating by the amount "alloc", pre-increment SP. 
		mov fp, sp							// Update frame pointer (FP) to current stack pointer (SP)
		
		add x19, fp, box_1_s						// Set x19 = base address of box 1 (used throughout program, not changed)
		add x20, fp, box_2_s						// Set x20 = base address of box 2 (used throughout program, not changed)

		mov x0, x19							// x0 = base address of box_1
		bl newbox							// newBox() - initializes the variables in memory from offset at base of box1
		
		mov x0, x20							// x0 = base address of box_2
		bl newbox							// newBox() - initializes the variables in memory from offset at base of box2
	
		adrp x0, print_init						// Print out "Initial box values:"
		add w0, w0, :lo12:print_init					
		bl printf

print_bef:	mov x0, x19							// x0 = base address of box_1
		adrp x1, print_first						// Load the "first" string into x1
		add w1, w1, :lo12:print_first					// Load the lower 12 bits into "first"
		bl printbox							// printBox() - print the contents of box_1

		mov x0, x20							// x0 = base address of box_2
		adrp x1, print_second						// Load the "second" string into x1
		add w1, w1, :lo12:print_second					// Load the lower 12 bits into "second"	
		bl printbox							// printBox() - print the contents of box_2

		mov x0, x19							// Move address of x19 into x0
		mov x1, x20							// Move address of x20 into x1
		bl equal							// Branch to subroutine "equal", comparing the two structs.
		mov x0, x21							// Move result of "equal" into x21
			
		cmp x21, xzr							// Compare result of "equal" with zero
		b.eq next							// If x21 = 0, then equal was false, so branch to next.

		mov x0, x19							// Move base of box_1 into x0 for move function
		mov w1, -5							// Move -5 into w1, for deltaX
		mov w2,	7							// Move 7 into w2, for deltaY
		bl move								// Branch to "move" subroutine

		mov x0, x20							// Move base of box_2 into x1 for expand subroutine
		mov w1, 3							// Move "3" into w1, for factor
		bl expand							// Branch to expand function

next: 			
	
		adrp x0, print_change						// Print out "Changed box values"
		add w0, w0, :lo12:print_change					
		bl printf


print_aft:	mov x0, x19							// x0 = base address of box_1
		adrp x1, print_first						// Load the "first" string into x1
		add w1, w1, :lo12:print_first					// Load the lower 12 bits into "first"
		bl printbox							// printBox() - print the contents of box_1

		mov x0, x20							// x0 = base address of box_2
		adrp x1, print_second						// Load the "second" string into x1
		add w1, w1, :lo12:print_second					// Load the lower 12 bits into "second"	
		bl printbox							// printBox() - print the contents of box_2

done:		mov w0, 0							// Return 0 to OS
		ldp fp, lr, [sp], dealloc					// De-allocate stack memory.

		ret								// Returns to calling code in OS

// ================================================================ / END: MAIN ======================================================================================
