#  Jorge Sagastume
#  Section 1001
#  CS 218, MIPS Assignment #4

#  MIPS assembly language program to perform
#  verification of a possible Suduko solution.

#  Sudoku is a popular brain-teaser puzzle that is solved by
#  placing digits 1 through 9 on a 9-by-9 grid of 81 individual
#  cells grouped into nine 3-by-3 regions.  The object of the
#  puzzle is to fill in all of the empty cells with digits from
#  1 to 9 so that the same digit doesn't appear twice in any
#  row, or any column, or any region.

##########################################################################
#  data segment

.data

hdr:	.ascii	"\nMIPS Assignment #4 \n"
	.asciiz	"Program to verify a possible Sudoku solution. \n\n"

TRUE = 1
FALSE = 0
GRID_SIZE = 9
SUB_GRID_SIZE = 3

lines:	.asciiz	"\n\n"

# -----
#  Sudoku Grids

SGrid1:	.word	5, 3, 4, 6, 7, 8, 9, 1, 2	# valid
		.word	6, 7, 2, 1, 9, 5, 3, 4, 8
		.word	1, 9, 8, 3, 4, 2, 5, 6, 7
		.word	8, 5, 9, 7, 6, 1, 4, 2, 3
		.word	4, 2, 6, 8, 5, 3, 7, 9, 1
		.word	7, 1, 3, 9, 2, 4, 8, 5, 6
		.word	9, 6, 1, 5, 3, 7, 2, 8, 4
		.word	2, 8, 7, 4, 1, 9, 6, 3, 5
		.word	3, 4, 5, 2, 8, 6, 1, 7, 9

SGrid2:	.word	5, 3, 4, 6, 7, 8, 9, 1, 2	# valid
		.word	6, 7, 2, 1, 9, 5, 3, 4, 8
		.word	1, 9, 8, 3, 4, 2, 5, 6, 7
		.word	8, 5, 9, 7, 6, 1, 4, 2, 3
		.word	4, 2, 6, 8, 5, 3, 7, 9, 1
		.word	7, 1, 3, 9, 2, 4, 8, 5, 6
		.word	9, 6, 1, 5, 3, 7, 2, 8, 4
		.word	2, 8, 7, 4, 1, 9, 6, 3, 5
		.word	3, 4, 5, 2, 8, 6, 1, 7, 9

SGrid3:	.word	1, 2, 3, 4, 5, 6, 7, 8, 9	# valid
		.word	4, 5, 6, 7, 8, 9, 1, 2, 3
		.word	7, 8, 9, 1, 2, 3, 4, 5, 6
		.word	2, 3, 4, 5, 6, 7, 8, 9, 1
		.word	5, 6, 7, 8, 9, 1, 2, 3, 4
		.word	8, 9, 1, 2, 3, 4, 5, 6, 7
		.word	3, 4, 5, 6, 7, 8, 9, 1, 2
		.word	6, 7, 8, 9, 1, 2, 3, 4, 5
		.word	9, 1, 2, 3, 4, 5, 6, 7, 8

SGrid4:	.word	5, 3, 4, 6, 7, 8, 9, 1, 2	# invalid, bad row
		.word	6, 7, 2, 1, 9, 5, 3, 4, 8
		.word	1, 9, 8, 3, 4, 2, 5, 6, 7
		.word	8, 5, 9, 7, 6, 1, 4, 2, 3
		.word	4, 2, 6, 8, 5, 3, 7, 9, 1
		.word	7, 1, 3, 9, 2, 4, 8, 5, 6
		.word	9, 6, 1, 5, 3, 7, 2, 8, 4
		.word	2, 8, 7, 4, 2, 9, 6, 3, 5
		.word	3, 4, 5, 2, 8, 6, 1, 7, 9

SGrid5:	.word	2, 3, 4, 5, 6, 7, 8, 9, 1	# invalid, bad col
		.word	5, 6, 7, 8, 9, 1, 2, 3, 4
		.word	8, 9, 1, 2, 3, 4, 5, 6, 7
		.word	1, 2, 3, 4, 5, 6, 7, 8, 9
		.word	4, 5, 6, 7, 8, 9, 1, 2, 3
		.word	3, 4, 5, 6, 7, 8, 9, 1, 2
		.word	7, 8, 9, 1, 2, 3, 4, 5, 6
		.word	6, 7, 8, 9, 1, 2, 3, 4, 5
		.word	8, 9, 1, 2, 3, 4, 5, 6, 7

SGrid6:	.word	2, 3, 4, 5, 6, 7, 8, 9, 1	# invalid, bad col
		.word	5, 6, 7, 8, 9, 1, 2, 3, 4
		.word	8, 9, 1, 2, 3, 4, 5, 6, 7
		.word	1, 2, 3, 4, 5, 6, 7, 8, 9
		.word	7, 8, 9, 1, 2, 3, 4, 5, 6
		.word	4, 5, 6, 7, 8, 9, 1, 2, 3
		.word	3, 4, 5, 6, 7, 8, 9, 1, 2
		.word	7, 8, 9, 1, 2, 3, 4, 5, 6
		.word	9, 1, 2, 3, 4, 5, 6, 7, 8

SGrid7:	.word	1, 2, 3, 4, 5, 6, 7, 8, 9	# invalid, bad subgrid
		.word	2, 3, 4, 5, 6, 7, 8, 9, 1
		.word	3, 4, 5, 6, 7, 8, 9, 1, 2
		.word	4, 5, 6, 7, 8, 9, 1, 2, 3
		.word	5, 6, 7, 8, 9, 1, 2, 3, 4
		.word	6, 7, 8, 9, 1, 2, 3, 4, 5
		.word	7, 8, 9, 1, 2, 3, 4, 5, 6
		.word	8, 9, 1, 2, 3, 4, 5, 6, 7
		.word	9, 1, 2, 3, 4, 5, 6, 7, 8

SGrid8:	.word	2, 3, 4, 5, 6, 7, 8, 9, 1	# invalid, bad subgrid
		.word	5, 6, 7, 8, 9, 1, 2, 3, 4
		.word	8, 9, 1, 2, 3, 4, 5, 6, 7
		.word	1, 2, 3, 4, 5, 6, 7, 8, 9
		.word	4, 5, 6, 7, 8, 9, 1, 2, 3
		.word	3, 4, 5, 6, 7, 8, 9, 1, 2
		.word	7, 8, 9, 1, 2, 3, 4, 5, 6
		.word	6, 7, 8, 9, 1, 2, 3, 4, 5
		.word	9, 1, 2, 3, 4, 5, 6, 7, 8

SGrid9:	.word	1, 2, 3, 4, 5, 6, 7, 8, 9	# valid
		.word	4, 5, 6, 7, 8, 9, 1, 2, 3
		.word	7, 8, 9, 1, 2, 3, 4, 5, 6
		.word	2, 3, 4, 5, 6, 7, 8, 9, 1
		.word	5, 6, 7, 8, 9, 1, 2, 3, 4
		.word	8, 9, 1, 2, 3, 4, 5, 6, 7
		.word	3, 4, 5, 6, 7, 8, 9, 1, 2
		.word	6, 7, 8, 9, 1, 2, 3, 4, 5
		.word	9, 1, 2, 3, 4, 5, 6, 7, 8

SGrid10:
		.word	1, 2, 3, 4, 5, 6, 7, 8, 9	# invalid, bad subgrid
		.word	4, 5, 6, 7, 8, 9, 1, 2, 3
		.word	7, 8, 9, 1, 2, 3, 4, 5, 6
		.word	2, 3, 4, 5, 6, 7, 8, 9, 1
		.word	5, 6, 7, 8, 9, 1, 2, 3, 4
		.word	3, 4, 5, 6, 7, 8, 9, 1, 2
		.word	8, 9, 1, 2, 3, 4, 5, 6, 7
		.word	6, 7, 8, 9, 1, 2, 3, 4, 5
		.word	9, 1, 2, 3, 4, 5, 6, 7, 8

isValid:	.byte	TRUE

addrs:	.word	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

stars:	.ascii	"\n********************************** \n\n"
	.asciiz	"Grid Number:  "


# -----
#  Variables for sudokuVerify function.

found:	.byte	FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE


# -----
#  Variables for displaySudoku function.

new_ln:	.asciiz	"\n"
top_ln:	.asciiz	"  +-------+-------+-------+ \n"
bar:	.asciiz	"| "
space:	.asciiz	" "
space2:	.asciiz	"  "

vmsg:	.asciiz	"\nSudoku Solution IS valid.\n\n"
invmsg:	.asciiz	"\nSudoku Solution IS NOT valid.\n\n"


##########################################################################
#  text/code segment

.text

.globl main
.ent main
main:

# -----
#  Display main program header.

	la	$a0, hdr
	li	$v0, 4
	syscall					# print header

# -----
#  Set grid addresses array.
#	Address array is used to allow a looped calls
#	the Sudoku verification and display routines.

	la	$t0, addrs

	la	$t1, SGrid1
	sw	$t1, ($t0)
	la	$t1, SGrid2
	sw	$t1, 4($t0)
	la	$t1, SGrid3
	sw	$t1, 8($t0)
	la	$t1, SGrid4
	sw	$t1, 12($t0)
	la	$t1, SGrid5
	sw	$t1, 16($t0)
	la	$t1, SGrid6
	sw	$t1, 20($t0)
	la	$t1, SGrid7
	sw	$t1, 24($t0)
	la	$t1, SGrid8
	sw	$t1, 28($t0)
	la	$t1, SGrid9
	sw	$t1, 32($t0)
	la	$t1, SGrid10
	sw	$t1, 36($t0)
	sw	$zero, 40($t0)

# -----
#  Main loop to check and display all grids.
#	grid addresses are stored in an array.
#	last entry in addresses array is zero, for loop termination

	la	$s0, addrs
	li	$s1, 1			# grid number counter

mainSudokuLoop:
	lw	$t0, ($s0)
	beqz	$t0, sudokuDone

# -----
#  Verify a possible Sudoku solution.

	lw	$a0, ($s0)
	la	$a1, isValid
	jal	sudokuVerify

# -----
#  Display header and Sudoku grid count

	li	$v0, 4
	la	$a0, stars
	syscall

	li	$v0, 1
	move	$a0, $s1
	syscall

	li	$v0, 4
	la	$a0, lines
	syscall

# -----
#  Display sudoku grid with result.

	lw	$a0, ($s0)
	li	$a1, 0
	lb	$a1, isValid
	jal	displaySudoku

# -----
#  Update counters and loop to check for next grid.

	add	$s1, $s1, 1
	addu	$s0, $s0, 4
	b	mainSudokuLoop

# -----
#  Done, terminate program.

sudokuDone:
	li	$v0, 10
	syscall

.end main


# ---------------------------------------------------------
#  Procedure to verify a Sudoku solution.

#  A valid Sudoku solution must satisfy the following constraints:
#     * Each value (1 through 9) must appear exactly once in each row.
#     * Each value (1 through 9) must appear exactly once in each column.
#     * Each value (1 through 9) must appear exactly once in each
#       3 x 3 sub-grid, where the  9 x 9 board is divided into 9 such sub-grids.

# -----
#  Formula for multiple dimension array indexing:
#	addr of ARRY(x,y) = [ (x * y_dimension) + y ] * data_size

# -----
#  Arguments
#	$a0 - address Sudoku grid
#	$a1 - address of boolean variable for result (true/false)

.globl	sudokuVerify
.ent	sudokuVerify
sudokuVerify:

#	YOUR CODE GOES HERE
   sub $sp, $sp, 40
   sw $ra, ($sp)
   sw $s0, 4($sp)
   sw $s1, 8($sp)
   sw $s2, 12($sp)
   sw $s3, 16($sp)
   sw $s4, 20($sp)
   sw $s5, 24($sp)
   sw $s6, 28($sp)
   sw $s7, 32($sp)
   sw $s8, 36($sp)

 	move  $s0, $a0 			# move sudoku grid address to s0
 	move  $s1, $a1 			# move address of boolean to s1

 #-------ZERO OUT FOUND FUNCTION-----------------

   la  $a0, found 			# Store found array address for func call
   jal zeroFoundArray 		# call function to zero out found array

#------- CHECK ROWS-------------------------------

	move $s2, $zero 			# zero out row counter

nextRow:
	move $s3, $zero 			# zero out column counter

addCol:
	mul  $t0, $s2, GRID_SIZE 	# (rowIndex * colSize)
	addu $t0, $t0, $s3 			# (rowIndex * colSize + colIndex)
	mul  $t0, $t0, 4 			# (rowIndex * colSize + colIndex) * DATASIZE
	addu $t0, $s0, $t0 			# baseAddress + (rowIndex * colSize + colIndex) * DATASIZE

	lw 	 $t5, ($t0) 			# get sudoku[i][i] value

	#la   $a0, found 			# Store found array address for func call
	#move $a1, $t5				# $a1 - index to set
	#jal setFoundArray 			# call function to sum 1 at sudoku[i][i] value index

	addu $s3, $s3, 1 			# add one to row counter
	blt  $s3, 9, addCol			# fire up the next column

	addu $s2, $s2, 1 			# next row
	blt  $s2, 9, nextRow 		# get next row

#------- CHECK COLUMNS----------------------------

checkCol:

#------- CHECK SUBGRIDS -------------------------

   la  $a0, found 			# Store found array address for func call
   jal checkFoundArray 		# call checkFoundArray func, returns true or false

   sb  $v0, isValid 		# store function result in isValid variable

	lw $ra, ($sp)
   lw $s0, 4($sp)
   lw $s1, 8($sp)
   lw $s2, 12($sp)
   lw $s3, 16($sp)
   lw $s4, 20($sp)
   lw $s5, 24($sp)
   lw $s6, 28($sp)
   lw $s7, 32($sp)
   lw $s8, 36($sp)
   add $sp, $sp, 40
jr	$ra
.end	sudokuVerify


# ---------------------------------------------------------
#  Function to zero 'found' array (9)

# -----
#  Arguments
#	$a0 - address of 'found' array
# -----
#  Returns
#	found array, all entries set to false.

.globl	zeroFoundArray
.ent	zeroFoundArray
zeroFoundArray:


#	YOUR CODE GOES HERE


	move $t0, $a0 		# move foundArray address to s0 [array of bytes]
	li 	 $t1, 9 		# set counter to 9

zeroLoop:

	li 	$t2, 0 			# load 0 into $t0
	sb 	$t2, ($t0) 		# store 0 into foundArray

	addu $t0, $t0, 1 	# get next addrress of array
	subu $t1, $t1, 1 	# counter--

	bnez $t1, zeroLoop 	# if counter !== 0 Loop again

jr	$ra
.end	zeroFoundArray


# ---------------------------------------------------------
#  Function to check 'found' array.
#	if a FALSE is found, returns FALSE
#	if no FALSE is found, returns TRUE

# -----
#  Arguments
#	$a0 - address of 'found' array
# -----
#  Returns
#	$v0 - FALSE or TRUE

.globl	checkFoundArray
.ent	checkFoundArray
checkFoundArray:

#	YOUR CODE GOES HERE
	move $t0, $a0 		# move foundArray address to s0 [array of bytes]
	li 	 $t1, 9 		# set counter to 9

checkLoop:

	li 	$t2, 0 			# load 0 into $t0
	lb 	$t2, ($t0) 		# load foundArray[i] into $t2

	bne $t2, 1, isBad 	# if one entry is false or greater than 1, found is bad

	addu $t0, $t0, 1 	# get next addrress of array
	subu $t1, $t1, 1 	# counter--

	bnez $t1, checkLoop # if counter !== 0 Loop again
	li $v0, TRUE
	j checkDone

isBad:

	li  $v0, FALSE

checkDone:


jr	$ra
.end	checkFoundArray


# ---------------------------------------------------------
#  Function to set 'found' array.
#	sets found($a1)

# -----
#  Arguments
#	$a0 - address of 'found' array
#	$a1 - index to set
# -----
#  Returns
#	found array, with $a1 entries set to true

.globl	setFoundArray
.ent	setFoundArray
setFoundArray:

#	YOUR CODE GOES HERE

	move $t0, $a0 		# move foundArray address to s0 [array of bytes]
	move $t1, $a1 		# move value of index to set to t1

	addu $t2, $t0, $t1 	# get index for adding to found array
	lb $t3, ($t2) 		# get value from found array at index
	addu $t2, $t3, 1 	# add one at index location


jr	$ra
.end	setFoundArray


# ---------------------------------------------------------
#  Procedure to display formatted Sudoku grid to output.
#	formatting as per assignment directions

#  Arguments:
#	$a0 - starting address of matrix to ptint
#	$a1 - flag valid (true) or not valid (false)
# new_ln:	.asciiz	"\n"
# top_ln:	.asciiz	"  +-------+-------+-------+ \n"
# bar:	.asciiz	"| "
# space:	.asciiz	" "
# space2:	.asciiz	"  "

#vmsg:	.asciiz	"\nSudoku Solution IS valid.\n\n"
#invmsg:	.asciiz	"\nSudoku Solution IS NOT valid.\n\n"

.globl	displaySudoku
.ent	displaySudoku
displaySudoku:

	sub	$sp, $sp, 12
	sw	$s0, ($sp)
	sw	$s1, 4($sp)
	sw 	$s2, 8($sp)
	addu $fp, $sp, 12

#---------PRINT LIST------------------

	move $s0, $a0 			# move list address to s0
	li $s1, 0 				# set counter to 0
	li $s2, 81		 		# move length value to s2

#---------PRINT TOP LINE---------------
	li $v0, 4 				# print top line
	la $a0, top_ln
	syscall

	li $v0, 4 				# print double space
	la $a0, space2
	syscall

	li $v0, 4 				# print bar
	la $a0, bar
	syscall

printLoop:
	li $v0, 1 				# call code for print integer
	lw $a0, ($s0) 			# get array[i]
	syscall 				# system call

	li $v0, 4 				# print spaces
	la $a0, space
	syscall

	addu $s0, $s0, 4 		# update addr (next word)
	add $s1, $s1, 1 		# increment counter

	rem $t0, $s1, 3
	bnez $t0, skipNewBar

	li $v0, 4 				# print bar
	la $a0, bar
	syscall

skipNewBar:

	rem $t0, $s1, 9
	bnez $t0, skipNewLine

	li $v0, 4 				# print new line
	la $a0, new_ln
	syscall

	rem $t0, $s1, 27
	beqz $t0, skipSpace


	li $v0, 4 				# double space
	la $a0, space2
	syscall

skipSpace:

	rem $t0, $s1, 27
	beqz $t0, skipNewBar2

	li $v0, 4 				# print bar
	la $a0, bar
	syscall

skipNewBar2:

	rem $t0, $s1, 27
	bnez $t0, skipNewLine

	li $v0, 4 				# print top line
	la $a0, top_ln
	syscall

	li $v0, 4 				# double space
	la $a0, space2
	syscall

	rem $t0, $s1, 81
	beqz $t0, skipNewBar3

	li $v0, 4 				# print bar
	la $a0, bar
	syscall

skipNewBar3:

skipNewLine:
	bne $s1, $s2, printLoop # if cnter<len > loop

	li $v0, 4 				# print new line
	la $a0, new_ln
	syscall

#------CHECK VALIDITY--------------------

	beqz $a1, notValid

	li $v0, 4 				# print top line
	la $a0, vmsg
	syscall

	j vDone

notValid:

	li $v0, 4 				# print top line
	la $a0, invmsg
	syscall

vDone:

# ­­­­­
#----------Done, restore registers and return to calling routine.
	lw	$s0, ($sp)
	lw	$s1, 4($sp)
	lw 	$s2, 8($sp)
	addu $sp, $sp, 4

jr	$ra
.end displaySudoku