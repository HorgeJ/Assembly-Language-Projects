#  CS 218, MIPS Assignment #2
#  Provided Template

#	Program to calculate area of each trapezoid in a
#	series of trapezoids.
#	Also finds min, med, max, sum, and average for
#	the trapezoid areas.

#	Formula:
#	   tAreas[n] = (heights[i] * (aSides[i] + cSides[i] / 2))

###########################################################
#  data segment

.data

aSides:
		.word	   1,    2,    3,    4,    5,    6,    7,    8,    9,   10
		.word	 202,  209,  215,  219,  223,  225,  231,  242,  244,  249
		.word	 251,  253,  266,  269,  271,  272,  280,  288,  291,  299
		.word	  15,   25,   33,   44,   58,   69,   72,   86,   99,  101
		.word	1469, 2474, 3477, 4479, 5482, 5484, 6486, 7788, 8492, 9493
		.word	 107,  121,  137,  141,  157,  167,  177,  181,  191,  199
		.word	 369,  374,  377,  379,  382,  384,  386,  388,  392,  393

cSides:
		.word	 206,  212,  222,  231,  246,  250,  254,  278,  288,  292
		.word	 332,  351,  376,  387,  390,  400,  411,  423,  432,  445
		.word	 457,  487,  499,  501,  523,  524,  525,  526,  575,  594
		.word	   1,    2,    3,    4,    5,    6,    7,    8,    9,   10
		.word	1782, 2795, 3807, 3812, 4827, 5847, 6867, 7879, 7888, 9894
		.word	  32,   51,   76,   87,   90,  100,  111,  123,  132,  145
		.word	 634,  652,  674,  686,  697,  704,  716,  720,  736,  753

heights:
		.word	 203,  215,  221,  239,  248,  259,  262,  274,  280,  291
		.word	 400,  404,  406,  407,  424,  425,  426,  429,  448,  492
		.word	 501,  513,  524,  536,  540,  556,  575,  587,  590,  596
		.word	1912, 2925, 3927, 4932, 5447, 5957, 6967, 7979, 7988, 9994
		.word	   1,    2,    3,    4,    5,    6,    7,    8,    9,   10
		.word	 102,  113,  122,  139,  144,  151,  161,  178,  186,  197
		.word	 782,  795,  807,  812,  827,  847,  867,  879,  888,  894

tAreas:	.space	280

len:	.word	70

taMin:	.word	0
taMed:	.word	0
taMax:	.word	0
taSum:	.word	0
taAve:	.word	0

#------My Vars---------
first:	.word	0
last:	.word	0
mid1:	.word	0
mid2:	.word	0

LN_CNTR	= 7


# -----

hdr:	.ascii	"MIPS Assignment #2 \n\n"
		.ascii	"  Program to calculate area of each trapezoid"
		.ascii	" in a series of trapezoids.\n"
		.ascii	"  Also finds min, est. med, max, sum, and average "
		.ascii	"for the trapezoid areas. \n\n"
		.ascii	"  Formula: \n"
		.asciiz	"    tAreas[n] = (heights[i] * (aSides[i] + cSides[i] / 2))\n\n"

newLine:
		.asciiz	"\n"
blnks:	.asciiz	"  "

a1_st:	.asciiz	"\nTrapezoid areas min = "
a2_st:	.asciiz	"\nTrapezoid areas emed = "
a3_st:	.asciiz	"\nTrapezoid areas max = "
a4_st:	.asciiz	"\nTrapezoid areas sum = "
a5_st:	.asciiz	"\nTrapezoid areas ave = "


###########################################################
#  text/code segment

.text
.globl main
.ent main

main:

# -----
#  Display header.

	la	$a0, hdr
	li	$v0, 4
	syscall				# print header

# -----


#	YOUR CODE GOES HERE

	lw	$t0, len			# set length as index
	la	$s1, aSides			# store address of aSides in t1
	la	$s2, cSides			# store address of cSides in t2
	la	$s3, heights		# store address of heights in t3
	la	$s7, tAreas			# addres of array to store areas

calcLoop:

	lw	$t1, ($s1)			# load aSides[i] val into $t1
	lw	$t2, ($s2)			# load cSides[i] val into $t2
	lw	$t3, ($s3)			# load heights[i] val into $t3

	addu $t4, $t2, $t1		# $t4 = aSides[i] + cSides[i]
	div $t4, $t4, 2 		# $t4 = (aSides[i] + cSides[i] / 2)
	mul $t4, $t4, $t3		# $t4 = hights[i] * (aSides[i] + cSides[i] / 2)

	sw $t4, ($s7) 			# store result value into tAreas[i] value
	sub	 $t0, $t0, 1 		# i--

	addu  $s1, $s1, 4 		# next aSides value
	addu  $s2, $s2, 4 		# next cSides value
	addu  $s3, $s3, 4 		# next heights value
	addu  $s7, $s7, 4 		# next tAreas value

	bnez $t0, calcLoop		# if(i =! 0) loop again

#--------------Array Display------------------------------------------------

	la $s0, tAreas
	li $s1, 0
	lw $s2, len

printLoop:
	li $v0, 1 				# call code for print integer
	lw $a0, ($s0) 			# get array[i]
	syscall 				# system call

	li $v0, 4 				# print spaces
	la $a0, blnks
	syscall

	addu $s0, $s0, 4 		# update addr (next word)
	add $s1, $s1, 1 		# increment counter

	rem $t0, $s1, 7
	bnez $t0, skipNewLine

	li $v0, 4 # print new line
	la $a0, newLine
	syscall

	skipNewLine:
	bne $s1, $s2, printLoop # if cnter<len > loop

#--------------Min, Max, Sum Loop --------------------------------------------

	la		$t0, tAreas				# set $t0 to addr of tAreas
	lw		$t1, len				# set $t1 to len value [i]
	li 		$t5, 0					# sum

	lw		$s2, ($t0)				# set min, $t2 to tAreas[0]
	lw		$s3, ($t0)				# set max, $t3 to tAreas[0]
	
	minmaxLoop:
	lw		$t4, ($t0)				# put tAreas[i] into $t4, val

	addu    $t5, $t5, $t4			# sum += tAreas[i]

	bge		$t4, $s2, notNewMin		# if(tAreas[i] >= min) {branch to notNewMin}
	move	$s2, $t4				# else {set tAreas[i] to new min in $s2}

notNewMin:
	ble		$t4, $s3, notNewMax		# if(tAreas[i] <= max) {branch to notNewMax}
	move	$s3, $t4				# else {set tAreas[i] to new max in $s3}

notNewMax:
	sub		$t1, $t1, 1   			# subtract 1 from length [dec counter]
	addu	$t0, $t0, 4 			# increment address of tAreas pointer by word
	bnez	$t1, minmaxLoop

#-------Store Min, Max------------------------------------------------
	sw		$s2, taMin 				# store min value from $s2 into min var
	sw		$s3, taMax 				# store max value from $s3 into max var
	sw		$t5, taSum				# store summ value from $t5 into sum var

#-------Calc Ave-----------------------------------------------------

	lw		$t1, len 				# store length value in $t1
	divu 	$t6, $t5, $t1 			# ave = sum / len
	sw		$t6, taAve 				# store $t6 val into taAve var

#--------Calc Est Median-------------------------------------------------

	la	$t0, tAreas				    # address of tAreas
	lw	$t1, len 					# store val of length

	lw	$t7, ($t0)					# set first value to $t2 from tAreas[0]
	sw	$t7, first	

	subu $t2, $t1, 1 				# dec len by 4
	mul  $t3, $t2, 4 				# cvt index into offset
	addu $t4, $t0, $t3				# add base addrres of tAreas

	lw	$t5, ($t4)					# get array[len - 1] last value
	sw	$t5, last

#---Check for even or odd length

	lw	$t1, len					# store val of length

	remu $t2, $t1, 2 				# check for even or odd length % 2

	beqz $t2, evenLength			# if rem=0 then length is even, branch to even
									# else length is odd

	 divu $t2, $t1, 2 				# length / 2
	 mul $t3, $t2, 4 				# cvt index into offset
	 add $t4, $t0, $t3				# add base addrr of tAreas

	 lw  $t5, ($t4)					# get tAreas[len/2]
	 sw  $t5, mid1					# store first mid val in var

#--- Calculate odd length

	li  $t5, 0						# clear reg

	lw	$t1, first					# load val of first into reg
	lw	$t2, mid1					# load val of mid1 into reg
	lw	$t4, last					# load val of last into reg

	addu $t5, $t1, $t2				# sum = first + mid1
	addu $t5, $t5, $t4				# sum = sum + last

	divu $t5, $t5, 3 				# estMed = sum / 3
	sw 	 $t5, taMed					# store estMed value into taMed var

	j done 							# uncondistional jump to done

#--- Calculate even length

evenLength:

	 divu $t2, $t1, 2 				# length / 2
	 mul $t3, $t2, 4 				# cvt index into offset
	 add $t4, $t0, $t3				# add base addrr of tAreas

	 lw  $t5, ($t4)					# get tAreas[len/2]
	 sw  $t5, mid1 					# store $t5 val into mid1 var

	 subu $t4, $t4, 4 				# len/2 - 1
	 lw	 $t6, ($t4) 				# get tAreas[len/2 - 1]
	 sw  $t6, mid2 					# store $t6 val into mid2 var

	li  $t5, 0 						# clear reg

	lw	$t1, first 					# load val of first into reg
	lw	$t2, mid1   				# load val of mid1 into reg
	lw	$t3, mid2 					# load val of mid2 into reg
	lw	$t4, last 					# load val of last into reg

	addu $t5, $t1, $t2 				# sum = first + mid1
	addu $t5, $t5, $t3 				# sum = sum + mid2
	addu $t5, $t5, $t4 				# sum = sum + last

	divu $t5, $t5, 4 				# estMed = sum / 4
	sw 	 $t5, taMed 				# sotre estMed value into taMed var

done:





	
	

##########################################################
#  Display results.

	la	$a0, newLine		# print a newline
	li	$v0, 4
	syscall
	la	$a0, newLine		# print a newline
	li	$v0, 4
	syscall

#  Print min message followed by result.

	la	$a0, a1_st
	li	$v0, 4
	syscall				# print "min = "

	lw	$a0, taMin
	li	$v0, 1
	syscall				# print min

# -----
#  Print middle message followed by result.

	la	$a0, a2_st
	li	$v0, 4
	syscall				# print "med = "

	lw	$a0, taMed
	li	$v0, 1
	syscall				# print mid

# -----
#  Print max message followed by result.

	la	$a0, a3_st
	li	$v0, 4
	syscall				# print "max = "

	lw	$a0, taMax
	li	$v0, 1
	syscall				# print max

# -----
#  Print sum message followed by result.

	la	$a0, a4_st
	li	$v0, 4
	syscall				# print "sum = "

	lw	$a0, taSum
	li	$v0, 1
	syscall				# print sum

# -----
#  Print average message followed by result.

	la	$a0, a5_st
	li	$v0, 4
	syscall				# print "ave = "

	lw	$a0, taAve
	li	$v0, 1
	syscall				# print average

# -----
#  Done, terminate program.

endit:
	la	$a0, newLine		# print a newline
	li	$v0, 4
	syscall

	li	$v0, 10
	syscall				# all done!

.end main
