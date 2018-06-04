#  Jorge Sagastume
#  Section 1001
#  CS 218, MIPS Assignment #1

#  Example program to find the:
#	min, max, and average of a list of numbers.
#	min, max, and average of the positive values in the list.
#	min, max, and average of the values that are evenly
#		divisible by 5.

###########################################################
#  data segment

.data

array:		.word	  1120,  193,  982, -339,  564, -631,  421, -148,  936, -1157
			.word	 -1117,  171, -697,  161, -147,  137, -327,  151, -147,  1354
			.word	   432, -551,  176, -487,  490, -810,  111, -523,  532, -1445
			.word	  -163,  745, -571,  529, -218,  219, -122,  934, -370,  1121
			.word	  1315, -145,  313, -174,  118, -259,  672, -126,  230, -1135
			.word	  -199,  104, -106,  107, -124,  625, -126,  229, -248,  1992
			.word	  1132, -133,  936,  136,  338, -941,  843, -645,  447, -1449
			.word	 -1171,  271, -477, -228,  178,  184, -586,  186, -388,  1188
			.word	   950, -852,  754,  256, -658, -760,  161, -562,  263, -1764
			.word	 -1199,  213, -124, -366,  740,  356, -375,  387, -115,  1426
len:		.word	  100

min:		.word	0
max:		.word	0
ave:		.word	0

posMin:		.word	0
posMax:		.word	0
posAve:		.word	0

fiveMin:	.word	0
fiveMax:	.word	0
fiveAve:	.word	0

hdr:		.ascii	"MIPS Assignment #1\n\n"	
			.ascii	"Program to find: \n"
			.ascii	"   * min, max, and average for a list of numbers.\n"
			.ascii	"   * min, max, and average of the positive values.\n"
			.ascii	"   * min, max, and average of the values that are"
			.asciiz	" evenly divisible by 5.\n\n"

new_ln:		.asciiz	"\n"

a0_st:		.asciiz	"\n    List min = "
a1_st:		.asciiz	"\n    List max = "
a2_st:		.asciiz	"\n    List ave = "

a3_st:		.asciiz	"\n\n    Positive min = "
a4_st:		.asciiz	"\n    Positive max = "
a5_st:		.asciiz	"\n    Positive ave = "

a6_st:		.asciiz	"\n\n    Divisible by 5 min = "
a7_st:		.asciiz	"\n    Divisible by 5 max = "
a8_st:		.asciiz	"\n    Divisible by 5 ave = "

#----------------MY VARS--------------


###########################################################
#  text/code segment

.text
.globl	chk1
.globl	main
.ent	main
main:

# -----
#  Display header.

	la	$a0, hdr
	li	$v0, 4
	syscall

# *******************************************************************

#	YOUR CODE GOES HERE

#-------------Min, Max, Sum Loop-------------------------------------
#   Set min and max to first item in list and then
#   loop through the array and check min and max against
#   each item in the list, updating the min and max values
#   as needed.

	la		$t0, array				# set $t0 to addr of array
	lw		$t1, len				# set $t1 to len value
	li 		$t5, 0					# sum

	lw		$s2, ($t0)				# set min, $t2 to array[0]
	lw		$s3, ($t0)				# set max, $t3 to array[0]

minmaxLoop:
	lw		$t4, ($t0)				# put array[n] into $t4, val

	add    	$t5, $t5, $t4			# sum += array[n]

	bge		$t4, $s2, notNewMin		# if(array[n] >= min) {branch to notNewMin}
	move	$s2, $t4				# else {set array[n] to new min in $s2}

notNewMin:
	ble		$t4, $s3, notNewMax		# if(array[n] <= max) {branch to notNewMax}
	move	$s3, $t4				# else {set array[n] to new max in $s3}

notNewMax:
	sub		$t1, $t1, 1   			# subtract 1 from length [dec counter]
	addu	$t0, $t0, 4 			# increment address of array pointer by word
	bnez	$t1, minmaxLoop

#-------Store Min, Max------------------------------------------------
	sw		$s2, min 				# store min value from $s2 into min var
	sw		$s3, max 				# store max value from $s3 into max var

#-------Calc Ave-----------------------------------------------------

	lw		$t1, len 				# store length value in $t1
	divu 	$t6, $t5, $t1 			# ave = sum / len
	sw		$t6, ave 				# store $t6 val into ave var

#--------Positive Loop-------------------------------------------------

	la		$t0, array				# set $t0 to addr of array
	lw		$t1, len				# set $t1 to len value
	li 		$t5, 0					# positive val sum

	lw		$s2, ($t0)				# set postive min, $t2 to array[0]
	lw		$s3, ($t0)				# set positive max, $t3 to array[0]

positiveLoop:
	lw	$t4, ($t0)					# set $t4 to array[n]

	blez $t4, notNewPosMax			# if array[n] < 0, branch to notPos

	add    	$t5, $t5, $t4			# PositiveSum += array[n]

	bge		$t4, $s2, notNewPosMin	# if(array[n] >= min) {branch to notNewMin}
	move	$s2, $t4				# else {set array[n] to new min in $s2}

notNewPosMin:
	ble		$t4, $s3, notNewPosMax	# if(array[n] <= max) {branch to notNewMax}
	move	$s3, $t4				# else { array[n] > current max so set array[n] to new max in $s3}

notNewPosMax:
	sub		$t1, $t1, 1   			# subtract 1 from length [dec counter]
	addu	$t0, $t0, 4 			# increment address of array pointer by word
	bnez	$t1, positiveLoop

#-------Store PosMin, PosMax -----------------------------------------------------

	sw		$s2, posMin 			# store min value from $s2 into posMin var
	sw		$s3, posMax 			# store max value from $s3 into posMax var

#-------Calc PosAve-----------------------------------------------------

	lw		$t1, len 				# store length value in $t1
	divu 	$t6, $t5, $t1 			# ave = sum / len
	sw		$t6, posAve 			# store $t6 val into ave Posvar

#-----------Five loop-------------------------------------------------------------
	la		$t0, array				# set $t0 to addr of array
	lw		$t1, len				# set $t1 to len value
	li 		$t5, 0					# positive val sum

	lw		$s2, ($t0)				# set postive min, $t2 to array[0]
	lw		$s3, ($t0)				# set positive max, $t3 to array[0]

fiveLoop:
	lw		$t4, ($t0)				# set $t4 to array[n]

	rem		$t6, $t4, 5 			# $t6 = $t4%5
	bnez	$t6, notNewFiveMax		# if not divisible by 5, get next num

	add    	$t5, $t5, $t4			# PositiveSum += array[n]

	bge		$t4, $s2, notNewFiveMin	# if(array[n] >= min) {branch to notNewMin}
	move	$s2, $t4				# else {set array[n] to new min in $s2}

notNewFiveMin:
	ble		$t4, $s3, notNewFiveMax	# if(array[n] <= max) {branch to notNewMax}
	move	$s3, $t4				# else { array[n] > current max so set array[n] to new max in $s3}

notNewFiveMax:
	sub		$t1, $t1, 1   			# subtract 1 from length [dec counter]
	addu	$t0, $t0, 4 			# increment address of array pointer by word
	bnez	$t1, fiveLoop

#-------Store PosMin, PosMax -----------------------------------------------------

	sw		$s2, fiveMin 			# store min value from $s2 into posMin var
	sw		$s3, fiveMax 			# store max value from $s3 into posMax var

#-------Calc PosAve-----------------------------------------------------

	lw		$t1, len 				# store length value in $t1
	divu 	$t6, $t5, $t1 			# ave = sum / len
	sw		$t6, fiveAve 			# store $t6 val into ave fiveVar



# *******************************************************************
#  Display results.

#  Print list min message followed by result.

	la	$a0, a0_st
	li	$v0, 4
	syscall						# print "List min = "

	lw		$a0, min
	li		$v0, 1
	syscall						# print min

# -----
#  Print max message followed by result.

	la		$a0, a1_st
	li		$v0, 4
	syscall						# print "List max = "

	lw		$a0, max
	li		$v0, 1
	syscall						# print max

# -----
#  Print average message followed by result.

	la	$a0, a2_st
	li	$v0, 4
	syscall						# print "List ave = "

	lw		$a0, ave
	li		$v0, 1
	syscall						# print average

# -----
#  Display results - positive numbers.

#  Print min message followed by result.

	la		$a0, a3_st
	li		$v0, 4
	syscall						# print "Positive min = "

	lw		$a0, posMin
	li		$v0, 1
	syscall						# print pos min

# -----
#  Print max message followed by result.

	la		$a0, a4_st
	li		$v0, 4
	syscall						# print "Positive max = "

	lw		$a0, posMax
	li	$v0, 1
	syscall						# print pos max

# -----
#  Print average message followed by result.

	la		$a0, a5_st
	li		$v0, 4
	syscall						# print "Psoitive ave = "

	lw		$a0, posAve
	li		$v0, 1
	syscall						# print pos average

	la	$a0, new_ln				# print a newline
	li	$v0, 4
	syscall

# -----
#  Display results - divisible by 5 numbers.

#  Print min message followed by result.

	la		$a0, a6_st
	li		$v0, 4
	syscall						# print "Divisible by 5 min = "

	lw		$a0, fiveMin
	li		$v0, 1
	syscall						# print min

# -----
#  Print max message followed by result.

	la		$a0, a7_st
	li		$v0, 4
	syscall						# print "Divisible by 5 max = "

	lw		$a0, fiveMax
	li	$v0, 1
	syscall						# print max

# -----
#  Print average message followed by result.

	la		$a0, a8_st
	li		$v0, 4
	syscall						# print "Divisible by 5 ave = "

	lw		$a0, fiveAve
	li		$v0, 1
	syscall						# print average

	la	$a0, new_ln				# print a newline
	li	$v0, 4
	syscall

# -----
#  Done, terminate program.

	li	$v0, 10
	syscall						# all done!

.end main

