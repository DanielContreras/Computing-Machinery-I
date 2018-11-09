/*
CPSC 355, Fall 2018
Assignment 4, Ahmed Elnasri

Assembly equivalent a C program that introduces a variety of new concepts covered in class;
namely subroutines, structs, accessing/modifying structs via subroutines, returning structs
by value via subroutines, pointers and addresses.
*/

//FALSE and TRUE equates
FALSE = 0                                     //Set FALSE to 0
TRUE = 1                                      //Set TRUE to 1

//Box variable offsets; box size
pointx_s = 0                                  //Offset for pointx
pointy_s = 4                                  //Offset for pointy
dimwidth_s = 8                                //Offset for dimension width
dimheight_s = 12                              //Offset for dimension height
area_s = 16                                   //Offset for area
box_size = 20                                 //Total size of box (five variables, all 4-byte integers, 5*4=20)

//Extra memory allocation and offsets for main method
alloc = -(16 + (box_size * 2)) & -16          //Extra memory allocated for main
dealloc = -alloc                              //Deallocate it when done main
first_s = 16                                  //Offset for first box in main
second_s = first_s + box_size                 //Offset for second box in main

//Memory allocation for newbox method
newboxalloc = -(16 + box_size) & -16          //Extra memory allocated for newbox method (box_size is the size of the local variable allocated for the newbox method)
newboxdealloc = -newboxalloc                  //Deallocate it when done newbox

//Memory allocation for equal method
result_s = 16                                 //Offset for result stack variable in equal method
equalalloc = -(16 + 4) & -16                  //Extra memory allocated for equal (the size for result is 4)
equaldealloc = -equalalloc                    //Deallocate it when done equal

//Strings
boxstr:   .string "Box %s origin = (%d, %d)  width = %d  height = %d  area = %d\n" //String for printbox method

first:    .string "first"                     //"first" string
second:   .string "second"                    //"second" string
string:   .string "Initial box values:\n"     //String after initializing boxes
string2:  .string "\nChanged box values:\n"   //string after modifying boxes

          .global main                        //Make main method visible to compiler
          .balign 4                           //Align instructions to 4 bits

//Main method
main:     stp x29, x30, [sp, alloc]!          //Allocate needed memory
          mov x29, sp                         //Set x29 equal to sp

          add x8, x29, first_s                //Place x29 plus the offset for first in x8 (this sets x8 equal to the address for first, allowing newbox to modify it)
          bl newBox                           //Call newbox for first

          add x8, x29, second_s               //Place x29 plus the offset for second in x8 (this sets x8 equal to the address for second, allowing newbox to modify it)
          bl newBox                           //Call newbox for second

          adrp x0, string                     //Set up the string for initial box values
          add x0, x0, :lo12:string            //Format lower 12 bits correctly
          bl printf                           //Call printf

          adrp x0, first                      //Set up printbox parameter string correctly
          add x0, x0, :lo12:first             //Format it's lower 12 bits
          add x1, x29, first_s                //Place address of first in x1
          bl printbox                         //Call printbox (when printbox calls printf, the string in x0 is prepared for it already)

          adrp x0, second                     //Set up printbox parameter string correctly
          add x0, x0, :lo12:second            //Format lower 12 bits
          add x1, x29, second_s               //Place address of second in x1 (it is prepared for printbox already)
          bl printbox                         //Call printbox

          add x0, x29, first_s                //Place address of first in x0
          add x1, x29, second_s               //Place address of second in x1
          bl equal                            //Call equal
          cmp w0, FALSE                       //Compare result of equal cal with FALSE (which is 0)
          b.eq conti                          //If the result is 0, skip next instructions and go to conti

          add x0, x29, first_s                //Place address of first in x0
          mov w1, -5                          //Place constant -5 in w1
          mov w2, 7                           //Place constant 7 in w2
          bl move                             //Call move function

          add x0, x29, second_s               //Place address of second in x0
          mov w1, 3                           //Place constant 3 in w1
          bl expand                           //Call expand function

conti:    adrp x0, string2                    //Set up changed box values string
          add x0, x0, :lo12:string2           //Format bits correctly
          bl printf                           //Call printf

          adrp x0, first                      //Format first string
          add x0, x0, :lo12:first             //Format bits correctly
          add x1, x29, first_s                //Place address of first in x1
          bl printbox                         //Call printbox

          adrp x0, second                     //Format second string
          add x0, x0, :lo12:second            //Format bits correctly
          add x1, x29, second_s               //Place address of first in x1
          bl printbox                         //Call printbox

          ldp x29, x30, [sp], dealloc         //End instruction; deallocate used memory
          ret                                 //End program

//newBox method
newBox:   stp x29, x30, [sp, newboxalloc]!    //Allocate needed memory for function
          mov x29, sp                         //Set sp equal to x29

          add x9, x29, box_size               //Set x9 equal to x29 + box size (x9 is base address of the local variable in newbox)
          str xzr, [x9, pointx_s]             //Store zero in the local variable's pointx field
          str xzr, [x9, pointy_s]             //Store zero in its pointy field
          mov w10, 1                          //Set w10 equal to the constant 1
          str w10, [x9, dimwidth_s]           //Set the local variable's dimension width field to 1
          str w10, [x9, dimheight_s]          //Set it's height field to 1
          ldr w10, [x9, dimwidth_s]           //Set w10 equal to the width field
          ldr w11, [x9, dimheight_s]          //Set w11 equal to the height field
          mul w10, w11, w10                   //Set w10 equal to the product of it and w11 (height * width)
          str w10, [x9, area_s]               //Place w10 in the area field

          ldr w10, [x9, pointx_s]             //Retrieve the value of the pointx field of the local variable
          str w10, [x8, pointx_s]             //Store it's contents in the address pointed to by x8 (the main method placed the address of either first or second in x8, so to modify first/second, we must access x8)
          ldr w10, [x9, pointy_s]             //Retrieve pointy
          str w10, [x8, pointy_s]             //Store it in the main method's variable
          ldr w10, [x9, dimwidth_s]           //Retrieve dimwidth
          str w10, [x8, dimwidth_s]           //Store it in the main method's variable
          ldr w10, [x9, dimheight_s]          //Retrieve dimheight
          str w10, [x8, dimheight_s]          //Store it in the main method's variable
          ldr w10, [x9, area_s]               //Retrieve the area
          str w10, [x8, area_s]               //Store it in the main method's variable

          ldp x29, x30, [sp], newboxdealloc   //Deallocate extra memory allocated to newbox
          ret                                 //Return to main method

printbox: stp x29, x30, [sp, -16]!            //Allocate printbox memory
          mov x29, sp                         //Update x29

          //x1 will hold the address of the provided variable, allowing it to be accessed
          ldr x2, [x1, pointx_s]              //Set x2 to the value of pointx
          ldr x3, [x1, pointy_s]              //Set x3 to the value of pointy
          ldr x4, [x1, dimwidth_s]            //Set x4 to the value of dimwidth
          ldr x5, [x1, dimheight_s]           //Set x5 to the value of dimheight
          ldr x6, [x1, area_s]                //Set x6 to the value of area

          mov x1, x0                          //Move the string parameter (already set up in main) to the second parameter
          adrp x0, boxstr                     //Place the box string in x0
          add x0, x0, :lo12:boxstr            //Format it's lower 12 bits correctly
          bl printf                           //Call printf

          ldp x29, x30, [sp], 16              //Deallocate used memory
          ret                                 //Return

//equal method
equal:    stp x29, x30, [sp, equalalloc]!     //Allocate memory for method
          mov x29, sp                         //Update x29

          mov w9, FALSE                       //Initially, set w9 to FALSE (0)
          str w9, [x29, result_s]             //Set it in local stack variable

          ldr w10, [x0, pointx_s]             //Set w10 to the pointx variable in first
          ldr w11, [x1, pointx_s]             //Set w11 to the pointx variable in second
          cmp w10, w11                        //Compare them
          b.ne endeq                          //If they aren't equal, jump to endeq

          ldr w10, [x0, pointy_s]             //Set w10 to the pointy variable in first
          ldr w11, [x1, pointy_s]             //Set w11 to the pointy variable in second
          cmp w10, w11                        //Compare them
          b.ne endeq                          //If they aren't equal, jump to endeq

          ldr w10, [x0, dimwidth_s]           //Set w10 to the width variable in first
          ldr w11, [x1, dimwidth_s]           //Set w11 to the width variable in second
          cmp w10, w11                        //Compare them
          b.ne endeq                          //If they aren't equal jump to endeq

          ldr w10, [x0, dimheight_s]          //Set w10 to the height variable in first
          ldr w11, [x1, dimheight_s]          //Set w11 to the height variable in second
          cmp w10, w11                        //Compare them
          b.ne endeq                          //If they aren't equal, jump to endeq

          mov w9, TRUE                        //At this point, all fields must be equal. So set w9 to TRUE.
          str w9, [x29, result_s]             //Set w9 into result local variable
          ldr w0, [x29, result_s]             //Set w0 equal to the result local stack variable

endeq:    ldp x29, x30, [sp], equaldealloc    //Deallocate used memory
          ret                                 //Return (result is in w0)

//move method
move:     stp x29, x30, [sp, -16]!            //Allocate memory for move method
          mov x29, sp                         //Update x29

          ldr w9, [x0, pointx_s]              //Set w9 to the value of pointx (x0 holds the address of the struct in main)
          add w9, w9, w1                      //Set w9 equal to pointx + deltax
          str w9, [x0, pointx_s]              //Set the updated w9 back into the struct
          ldr w9, [x0, pointy_s]              //Set w9 equal to pointy
          add w9, w9, w2                      //Set w9 equal to pointy + deltay
          str w9, [x0, pointy_s]              //Set the updated w9 back into the struct

          ldp x29, x30, [sp], 16              //Deallocate used memory
          ret                                 //Return

//expand method
expand:   stp x29, x30, [sp, -16]!            //Allocated memory for expand method
          mov x29, sp                         //Update x29

          ldr w9, [x0, dimwidth_s]            //Set w9 equal to the width (x0 holds the address of the struct in main)
          mul w9, w9, w1                      //Multiply w9 by the factor
          str w9, [x0, dimwidth_s]            //Set the updated w9 back into the struct
          ldr w9, [x0, dimheight_s]           //Set w9 equal to the height
          mul w9, w9, w1                      //Multiply w9 by the factor
          str w9, [x0, dimheight_s]           //Set the updated w9 back into the struct
          ldr w10, [x0, dimwidth_s]           //Set w10 equal to the updated width
          mul w9, w9, w10                     //Multiply w9 (the updated height) by the updated height to make w9 the updated area
          str w9, [x0, area_s]                //Set the updated area in w9 back into the struct

          mov w0, 0                           //Set return value to 0
          ldp x29, x30, [sp], 16              //Deallocate used memory
          ret                                 //Return