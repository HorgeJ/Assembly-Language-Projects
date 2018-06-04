;  Jorge Sagastume
;  Section 1001
;  CS 218 - Assignment 9
;  Functions Template.

; --------------------------------------------------------------------
;  Write assembly language functions.

;  The value returning function, rdNonaryNum(), should read
;  a nonary number from the user (STDIN) and perform
;  apprpriate error checking and conversion (string to integer).

;  The value returning function lstEstMedian() returns the
;  median for a list of unsorted numbers.

;  The void function, combSort(), sorts the numbers into
;  ascending order (large to small).  Uses the comb sort
;  algorithm from assignment #7 (with sort order modified).

;  The value returning function lstSum() returns the sum
;  for a list of numbers.

;  The value returning function lstAverage() returns the
;  average for a list of numbers.

;  The value returning function lstMedian() returns the
;  median for a list of sorted numbers.

;  The void function, lstStats(), finds the sum, average, minimum,
;  maximum, and median for a list of numbers.  Results returned
;  via reference.

;  The value returning function, lstKurtosis(), computes the
;  kurtosis statictic for the data set.  Summation for the
;  dividend must be performed as a quad.


; ********************************************************************************

section	.data

; -----
;  Define standard constants.

TRUE		equ	1
FALSE		equ	0

EXIT_SUCCESS	equ	0			; Successful operation

STDIN		equ	0			; standard input
STDOUT		equ	1			; standard output
STDERR		equ	2			; standard error

SYS_read	equ	0			; system call code for read
SYS_write	equ	1			; system call code for write
SYS_open	equ	2			; system call code for file open
SYS_close	equ	3			; system call code for file close
SYS_fork	equ	57			; system call code for fork
SYS_exit	equ	60			; system call code for terminate
SYS_creat	equ	85			; system call code for file open/create
SYS_time	equ	201			; system call code for get time

LF		equ	10
SPACE		equ	" "
NULL		equ	0
ESC		equ	27

; -----
;  Define program specific constants.

MAXNUM		equ	100000
MINNUM		equ	-100000
BUFFSIZE	equ	51			; 50 chars plus NULL

; -----
;  NO static local variables allowed...


; ********************************************************************************

section	.text

; --------------------------------------------------------
;  Read an ASCII nonary number from the user.
;  Perform appropriate error checking and, if OK,
;  convert to integer.

; -----
;  HLL Call:
;	bool = rdNonaryNum(&numberRead, promptStr, errMsg1,
;				errMsg2, errMsg3);

;  Arguments Passed:
;	numberRead, addr - rdi
;	promptStr, addr - rsi
;	errMsg1, addr - rdx
;	errMsg2, addr - rcx
;	errMsg3, addr - r8

;  Returns:
;	true/false
;	number read (via reference)

global	readNonaryNum
readNonaryNum:

	push 	rbp
	mov	rbp, rsp
	sub	rsp, 56
	push	rbx
	push	r12
	push	r13
	push	r14
	push	r15

	mov	r13, rdi		;preserve value
	mov	dword [rbp - 55], 0	; running sum
	lea	rbx, byte [rbp - 51]	; line
	mov	r12 , 0			; counter
     
	mov	rdi, rsi		; load prompt message
	call	printString		; call print string function
	jmp	nxtChr			; after prompt get chr

     nxtChr:
	mov	rax, SYS_read
	mov	rdi, STDIN
	lea	rsi, byte [rbp - 56]	; address of character from user
	mov	rdx, 1			; count (how many to read)
	syscall				; syscall 
	
	mov	rax, 0
	mov	al, byte [rbp - 56]
	cmp	al, LF			; if chr is LF
	je	inputDone		; input is done

	cmp	al, " "			; if chr is space
	je	nxtChr			; get next chr

	inc 	r12			; counter++
	cmp	r12, BUFFSIZE		; if counter > BUFFSIZE stop placing in BUFFER
	ja	inputOver		; jmp to value to large error

	mov	byte [rbx], al		; store the chr
	inc 	rbx			; increment the line
	jmp	nxtChr			; get next chr

     inputDone:
	mov	byte [rbx], NULL
	
	lea	rbx, byte [rbp - 51]	; get addrress of first chr stored
	mov	al, byte [rbx]		; store value of pointer in al
	mov	r14, 0			; i = 0 [stored chrs]
	cmp	al, NULL
	je	terminate
	jmp	exit

     ;inputCheck:
	;mov	al, byte [rbx + r14]
	;cmp	al, NULL
	;je	convertNonary
	;cmp	al, "0"
	;jb	outOfRange
	;cmp	al, "8"
	;ja	outOfRange

	;inc	r14
	;jmp	inputCheck

;-----------Errors------------------------
     inputOver:
	mov	rdi, r8
	call 	printString
	jmp	exit

     outOfRange:
	mov	rdi, rcx
	call	printString
	jmp	exit

     terminate:
	mov	rax, FALSE
	mov	byte [rbx], NULL
	jmp	exit

;------------------------------------------
     ;convertNonary:
	;mov	rax, 0		;running Sum	

     exit:
	pop	r15
	pop	r14
	pop	r13
	pop 	r12
	pop	rbx
	mov	rsp, rbp
	pop	rbp
	ret
	


; **********************************************************************************
;  Perform comb sort

; -----
;  HLL Call:
;	call combSort(list, len)

;  Arguments Passed:
;	1) list, addr - rdi
;	2) length, value - rsi

;  Returns:
;	sorted list (list passed by reference)

global	combSort
combSort:
	
	push 	rbp
	mov	rbp, rsp
	sub	rsp, 17
	push	r12

;-------- Initialize locals--------------------

	mov	dword [rbp - 4], 10	; dword [dTen]
	mov	dword [rbp - 8], 12	; dword [dTwelve]
	mov	dword [rbp - 12], 4	; dword [dFour]
	mov	dword [rbp - 16], 0	; dword [gap]
	;mov	byte [rbp - 17], TRUE	; swapped

;-----------------------------------------------

	mov	eax, esi 			; gap length in esi
	mov	byte [rbp - 17], TRUE		; set swap to TRUE

;-----Outer Loop---------------------
     outerLoop:
	cmp	eax, 1
	jg	getGap
	cmp	byte [rbp - 17], TRUE
	je	getGap				; cmp swapped to FALSE
	jmp	outerLoopDone			; if FALSE outer loop is done

     getGap:
	imul	dword [rbp - 4]			; (gap * 10)
	cdq					; convert double to quad for idiv
	idiv	dword [rbp - 8]			; (gap * 10) / 12
	mov	dword [rbp - 16], eax		; store result into gap variable
	mov	r9d, dword [rbp - 16]		; store gap into r9

	cmp	dword [rbp - 16], 1		; cmp 1 to gap
	ja	dontSet				; if gap > 1 skip gap setting
	mov	dword [rbp - 16], 1		; else set gap to 1

     dontSet:
	mov	r12, 0				; set index
	mov	byte [rbp - 17], FALSE		; set swapped bool to false

;----------Inner Loop-------------------
     innerLoop
	mov	r8, r12				; move index to r8
	add	r8d, r9d			; add gap to i (gap + i)
	mov	eax, r8d			; move (i + gap) into eax
	imul	dword [rbp - 12]		; imul by dWord size
	movsxd	r13, eax			; rdi = (i + gap)	
	
	cmp	r8d,  esi			; if (i + gap) >= length
	jae	innerLoopDone			; end inner loop
						; else begin swap compare
	mov	eax, dword [rdi + r12 * 4]	; take array [i]
	mov	ebx, dword [rdi + r13]		; take array [i + gap]	
	
	cmp	eax, ebx			; if eax <= ebx
	jle	swapDone			; leave as is, else swap points

	mov	dword [rdi + r12 * 4], ebx	; swap ebx into old eax position
	mov	dword [rdi + r13], eax		; swap eax into old ebx position
	mov	byte [rbp - 17], TRUE		; change swapped bool to TRUE

     swapDone:					; swap completed
	inc 	r12				; inc i
	jmp	innerLoop			; jmp back to inner loop	

     innerLoopDone:
	mov	eax, r9d			; preserve gap			
	inc 	r12				; inc i
	jmp	outerLoop			; jmp back to outerloop

     outerLoopDone:

	pop	r12				; return value
	pop	rbx
	mov	rsp, rbp
	pop	rbp
	ret


; --------------------------------------------------------
;  Find statistical information for a list of integers:
;	sum, average, minimum, maximum, and, median

;  Note, for an odd number of items, the median value is defined as
;  the middle value.  For an even number of values, it is the integer
;  average of the two middle values.

;  This function must call the lstAvergae() function
;  to get the average.

;  Note, assumes the list is already sorted.

; -----
;  Call:
;	call lstStats(list, len, sum, ave, min, max, med)

;  Arguments Passed:
;	list, addr - rdi
;	length, value - rsi
;	sum, addr - rdx
;	average, addr - rcx
;	minimum, addr - r8
;	maximum, addr - r9
;	median, addr - stack, rbp+16

;  Returns:
;	sum, average, minimum, maximum, and median
;		via pass-by-reference

global lstStats
lstStats:

	push 	rbp
	mov	rbp, rsp
	push 	r12	

;------------MIN & MAX-----------------
	mov	eax, 0
	mov	eax, dword [rdi]
	mov	dword [r9], eax
	
	mov	r12, 0
	mov	r12, rsi
	dec 	r12
	mov	eax, 0
	mov	eax, dword [rdi + r12 * 4]
	mov	dword [r8], eax
	mov	eax, 0


;-------------SUM CALL-----------------
	call 	lstSum
	mov	dword [rdx], eax

;-------------AVERAGE CALL-----------------
	call	lstAverage
	mov	dword [rcx], eax

;-------------LST MEDIAN---------------
	call	lstMedian
	mov	r12, qword [rbp + 16]
	mov	dword [r12], eax
	
	
	pop	r12
	pop 	rbp
	ret


; --------------------------------------------------------
;  Function to calculate the median of a sorted list.

; -----
;  Call:
;	ans = lstMedian(lst, len)

;  Arguments Passed:
;	1) list, address - rdi
;	1) length, value - rsi

;  Returns:
;	median (in eax)

global	lstMedian
lstMedian:

	push	rbp
	mov	rbp, rsp
	sub	rsp, 4
	
	push	rbx	
	push	r12				; preserve register

	mov	dword [rbp-4], 2		; dword [dTwo]

	mov	rax, rsi			; put length value in rax
	mov	rdx, 0				; counter set to 0
	div	dword [rbp-4]			; div length by 2

	mov	r10, rax			; move answer to r10

	cmp	rdx, 0				; compare remainder to 0
	je	evenLength			; if 0 go to even length

	mov	r12d, dword [rdi + r10 * 4]	; else treat as odd, put mid val in r12d
	mov	eax, r12d			; put mid val in eax
	jmp 	medDone				; done, return value in eax

     evenLength:
	mov	r12d, dword [rdi + r10 * 4]	; if even take 1st mid val
	dec	r10				; dec index
	mov	r11d, dword [rdi + r10 * 4]	; take second mid val
	
	add	r12d, r11d			; add both mid values
	mov	eax, r12d			; move result to eax
	cdq					; convert double to quad
	idiv	dword [rbp-4]			; divide by 2, answer in eax
	

     medDone:
	pop	r12				; return value
	pop	rbx
	mov	rsp, rbp
	pop	rbp
	ret					; return answer in eax



; --------------------------------------------------------
;  Function to calculate the median of a sorted list.

; -----
;  Call:
;	ans = lstEstMedian(lst, len)

;  Arguments Passed:
;	1) list, address - rdi
;	1) length, value - rsi

;  Returns:
;	estimated median (in eax)

global	lstEstMedian
lstEstMedian:
	
	push	rbp
	mov	rbp, rsp
	sub	rsp, 12			; allocate locals
	push	r12			; preserve r12

;-------- Initialize locals--------------------

	mov	dword [rbp - 4], 2	; dword [dTwo]
	mov	dword [rbp - 8], 3	; dword [dThree]
	mov	dword [rbp - 12], 4	; dword [dFour]

;-----------------------------------------------

	mov	eax, esi		; set eax to length
	mov	edx, 0			; set remainder to 0
	div	dword [rbp - 4]		; div length by 2
	mov	r11, 0			
	mov	r11d, eax		; place result in r11d	

	mov	eax, dword [rdi]	; place first list item in eax

	mov	r10, 0			
	mov	r10d, esi		; place length in r10d
	sub	r10, 1			; sub 1

	add	eax, dword [rdi + r10 * 4] ; add first middle val
	add 	eax, dword [rdi + r11 * 4] ; add second middle val

	cmp	rdx, 1			; cmp 1 to remainder
	je	oddMedian		; if remainder == 1 median is odd
	dec 	r11			; dec index
	add 	eax, dword [rdi + r11 * 4]	
	cdq
	idiv	dword [rbp - 12]	; dword [dFour]
	jmp	done			; done

     oddMedian:
	cdq				; convert
	idiv	dword [rbp - 8] 	; dword [dThree]

      done:


	pop	r12
	mov	rsp, rbp
	pop	rbp
	ret





; --------------------------------------------------------
;  Function to calculate the sum of a list.

; -----
;  Call:
;	ans = lstSum(lst, len)

;  Arguments Passed:
;	1) list, address - rdi
;	1) length, value - rsi

;  Returns:
;	sum (in eax)
global	lstSum
lstSum:

	push 	r12
	mov	r12, 0				; counter/index
	mov	rax, 0				; running sum

     sumLoop:
	add	eax, dword [rdi + r12 * 4]	; sum += arr[i]
	inc	r12				; counter++
	cmp	r12, rsi			; compare counter to length
	jl	sumLoop				; if counter == length exit 


	pop r12
	ret					; return sum in eax


; --------------------------------------------------------
;  Function to calculate the average of a list.

; -----
;  Call:
;	ans = lstAverage(lst, len)

;  Arguments Passed:
;	1) list, address - rdi
;	1) length, value - rsi

;  Returns:
;	average (in eax)

global	lstAverage
lstAverage:

	call	lstSum		; place sum of list in eax

	mov	edx, 0		; set remainder to 0
	div	esi		; div sum/length
	


	ret			; return average in eax


; --------------------------------------------------------
;  Function to calculate the kurtosis statisic.

; -----
;  Call:
;  kStat = lstKurtosis(list, len, ave)

;  Arguments Passed:
;	1) list, address - rdi
;	2) len, value - esi
;	3) ave, value - edx

;  Returns:
;	kurtosis statistic (in rax)

global lstKurtosis
lstKurtosis:

	push	rbp
	mov	rbp, rsp
	sub	rsp, 16

	push	r12
	push	r13
	push	r14
	push	r15
	push	rcx

	mov	r13, 0 		;top sum
	mov	r14, 0		;bottom sum
	mov	r10, 0		; [i]
	mov	r15, 0

	mov	r12d, esi	;length
	mov	rcx, 0
	mov	r15, rdx	;ave
	mov	r11, 0
	
     kurtLoop:
	mov 	rdx, 0
	cmp	r10, r12
	je	kurtDone

	movsxd	rax, dword [rdi + r10 * 4] 	;x[i]
	sub	rax, r15
	mov	rcx, rax			;x[i] - AVE
	imul	rax				;(x[i]-AVE)^2

	mov	r11, rax		
	add	r14, r11

	imul 	rcx				; To the third
	imul	rcx				; To the fourth
	
	mov	qword[rbp - 8], rax
	mov	qword[rbp - 16], rdx
	add	r13, qword [rbp - 8]

	inc 	r10
	jmp	kurtLoop

     kurtDone:
	mov	rax, r13
	cmp	r14, 0
	jne	continue
	mov	rax, 0
	jmp	kurtEnd
     continue:
	cqo
	idiv	r14

     kurtEnd:

	pop	rcx
	pop	r15
	pop	r14
	pop	r13
	pop	r12

	mov	rsp, rbp
	pop	rbp
	ret




; ********************************************************************************
;  Generic procedure to display a string to the screen.
;  String must be NULL terminated.

;  Algorithm:
;	Count characters in string (excluding NULL)
;	Use syscall to output characters

; -----
;  HLL Call:
;	printString(stringAddr);

;  Arguments:
;	1) address, string
;  Returns:
;	nothing

global	printString
printString:

; -----
;  Count characters to write.

	mov	rdx, 0
strCountLoop:
	cmp	byte [rdi+rdx], NULL
	je	strCountLoopDone
	inc	rdx
	jmp	strCountLoop
strCountLoopDone:
	cmp	rdx, 0
	je	printStringDone

; -----
;  Call OS to output string.

	mov	rax, SYS_write			; system code for write()
	mov	rsi, rdi			; address of char to write
	mov	rdi, STDOUT			; file descriptor for std in
						; rdx=count to write, set above
	syscall					; system call

; -----
;  String printed, return to calling routine.

printStringDone:
	ret

; ******************************************************************


