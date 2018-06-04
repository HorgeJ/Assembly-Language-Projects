

; Jorge Sagastume
; section 1001
;  CS 218 - Assignment #12
;  Narcissistic Number Counting Program
;  Provided template with threading calls

; -----
;  Narcissistic Numbers
;	1, 2, 3, 4, 5,
;	6, 7, 8, 9, 153,
;	370, 371, 407, 1634, 8208,
;	9474, 54748, 92727, 93084, 548834,
;	1741725, 4210818, 9800817, 9926315, 24678050,
;	24678051, 88593477, 146511208, 472335975, 534494836,
;	912985153, 4679307774, 32164049650, 32164049651

; ***************************************************************

section	.data

; -----
;  Define standard constants.

LF		equ	10			; line feed
NULL		equ	0			; end of string
ESC		equ	27			; escape key

TRUE		equ	1
FALSE		equ	0

SUCCESS		equ	0			; Successful operation
NOSUCCESS	equ	1			; Unsuccessful operation

STDIN		equ	0			; standard input
STDOUT		equ	1			; standard output
STDERR		equ	2			; standard error

SYS_read	equ	0			; call code for read
SYS_write	equ	1			; call code for write
SYS_open	equ	2			; call code for file open
SYS_close	equ	3			; call code for file close
SYS_fork	equ	57			; call code for fork
SYS_exit	equ	60			; call code for terminate
SYS_creat	equ	85			; call code for file open/create
SYS_time	equ	201			; call code for get time

; -----
;  Message strings

header		db	"**********************************************", LF
		db	ESC, "[1m", "Narcissistic Number Counting "
		db	"Program", ESC, "[0m", LF, LF, NULL
msgStart	db	"--------------------------------------", LF	
		db	"Start Counting", LF, NULL
nMsgMain	db	"Narcissistic Count: ", NULL
msgProgDone	db	LF, "Completed.", LF, NULL

numberLimit	dq	0		; limit (quad)
parFlag		db	FALSE		; parallel flag
					;   initially false -> sequential
					;   true -> parallel

; -----
;  Globals (used by threads)

idxCounter	dq	0
nCount		dq	0

myLock		dq	0

; -----
;  Thread data structures

pthreadID0	dq	0, 0, 0, 0, 0
pthreadID1	dq	0, 0, 0, 0, 0
pthreadID2	dq	0, 0, 0, 0, 0

; -----
;  Local variables for thread function.

msgThread1	db	" ...Thread starting...", LF, NULL

; -----
;  Local variables for printMessageValue

newLine		db	LF, NULL

; -----
;  Local variables for getParams function

LIMITMIN	equ	1
LIMITMAX	equ	4000000000

errUsage	db	"Usgae: ./narCounter <-sq|-pr> ",
		db	"-lm <nonaryNumber>", LF, NULL
errOptions	db	"Error, invalid command line options."
		db	LF, NULL
errPARsel	db	"Error, invalid sequential/parallel selection."
		db	LF, NULL
errLSpec	db	"Error, invalid limit specifier."
		db	LF, NULL
errLValue	db	"Error, limit out of range."
		db	LF, NULL

; -----
;  Local variables for int2Nonary function

qNine		dq	9
tmpNum		dq	0

;-------My Vars----------
rSum		dq	0
digit		dq	0
qTen		dq	10

; -----

section	.bss

tmpString	resb	20


; ***************************************************************

section	.text

; -----
; External statements for thread functions.

extern	pthread_create, pthread_join

; ================================================================
;  Narcissistic number counting program.

global main
main:

; -----
;  Check command line arguments

	mov	rdi, rdi			; argc
	mov	rsi, rsi			; argv
	mov	rdx, parFlag
	mov	rcx, numberLimit
	call	getArgs

	cmp	rax, TRUE
	jne	progDone

; -----
;  Initial actions:
;	Display initial messages

	mov	rdi, header
	call	printString

	mov	rdi, msgStart
	call	printString

; -----
;  Create new thread(s)
;	pthread_create(&pthreadID0, NULL, &threadFunction0, NULL);
;  if sequntial, start 1 thread
;  if parallel, start 3 threads

	mov	rdi, pthreadID0
	mov	rsi, NULL
	mov	rdx, narcissisticCounter
	mov	rcx, NULL
	call	pthread_create

	cmp	byte [parFlag], TRUE
	jne	WaitForThreadCompletion

	mov	rdi, pthreadID1
	mov	rsi, NULL
	mov	rdx, narcissisticCounter
	mov	rcx, NULL
	call	pthread_create

	mov	rdi, pthreadID2
	mov	rsi, NULL
	mov	rdx, narcissisticCounter
	mov	rcx, NULL
	call	pthread_create

;  Wait for thread(s) to complete.
;	pthread_join (pthreadID0, NULL);

WaitForThreadCompletion:
	mov	rdi, qword [pthreadID0]
	mov	rsi, NULL
	call	pthread_join

	cmp	byte [parFlag], TRUE
	jne	showFinalResults

	mov	rdi, qword [pthreadID1]
	mov	rsi, NULL
	call	pthread_join

	mov	rdi, qword [pthreadID2]
	mov	rsi, NULL
	call	pthread_join

; -----
;  Display final count

showFinalResults:
	mov	rdi, newLine
	call	printString

	mov	rdi, nMsgMain
	call	printString
	mov	rdi, qword [nCount]
	mov	rsi, tmpString
	call	int2nonary
	mov	rdi, tmpString
	call	printString
	mov	rdi, newLine
	call	printString


; **********
;  Program done, display final message
;	and terminate.

	mov	rdi, msgProgDone
	call	printString

progDone:
	mov	rax, SYS_exit			; system call for exit
	mov	rdi, SUCCESS			; return code SUCCESS
	syscall

; ******************************************************************
;  Thread function, numberTypeCounter()
;	Detemrine the type (abundent, deficient, perfect) of
;	numbers between 1 and numberLimit (gloabally available)

; -----
;  Arguments:
;	N/A (global variable accessed)
;  Returns:
;	N/A (global variable accessed)

;	YOUR CODE GOES HERE
global narcissisticCounter
narcissisticCounter:

	push	rbx
	push	r12
	push	r15
	push	r14
	push	r15

;----------SET UP--------------------------------

	mov	r13, 0				; set counter to 0
	mov	r11, 0				; set num length
	mov	rbx, qword[numberLimit] 	; limit initialization
		
;---------Initial message--------------------------
	mov	rdi, msgThread1			; load first message
	call	printString			; print first message

;---------Number Generation-------------------------
	
     genNum:
	call	spinLock			; call lock
	cmp	rbx, qword[idxCounter] 		; if(rbx == limit) {DONE}
	call	spinUnlock			; call unlock
	je	narcissisticCounterExit		; exit function
	
	call	spinLock			; call lock
	inc	qword[idxCounter]		; inc index
	call	spinUnlock			; call unlock
	
	mov	r12, 0				; initialize sum to 0
	mov	rax, qword[idxCounter]		; store index in rax
	mov	r9, rax 			; preserve val

;---------Get Length-------------------------------------

	mov	r11, 0				; initialize length to 0
     getLength:
	mov	rdx, 0				; set remainder to 0
	div	qword[qTen]			; divide by ten to get nums
	inc	r11				; length + 1
	push	rdx				; preserve num
	cmp	rax, 0				; check for end of nums
	jne	getLength			; if(num!=0) dont exit

;-------Get nums off stack--------------------------------- 

	mov	rcx, r11			; get loop counter
     getStack:
	pop	r10				; place quad sized num from stack into r10
	mov	rax, 1				; store 1 in rax for mult
	mov	r15, 0				; initilize pop index to 0

     powerLoop:
	cmp	r15, r11			; if(pop[i]==length)
	je	store				; done
	mul	r10				; else{mult by num}
	inc	r15				; pop[i]++
	jmp	powerLoop

;------store in sum-----------------------------------	
     store:
	add	r12, rax			; sum += mult rax
	loop	getStack			; jump back rcx--
	
	cmp	r12, r9 			; if(sum==index) narcissistic found
	jne	noneFound			; else {no narcissistic found}

	lock	inc	qword[nCount]		; [nCount]++
	
     noneFound:
	jmp	genNum				; get next number

;-----------Function Exit---------------------

     narcissisticCounterExit:			; exit function
	
	pop	r15
	pop	r14
	pop	r13
	pop	r12
	pop	rbx
	ret

; ******************************************************************
;  Mutex lock
;	checks lock (shared gloabl variable)
;		if unlocked, sets lock
;		if locked, lops to recheck until lock is free

global	spinLock
spinLock:
	mov	rax, 1			; Set the EAX register to 1.

lock	xchg	rax, qword [myLock]	; Atomically swap the RAX register with
					;  the lock variable.
					; This will always store 1 to the lock, leaving
					;  the previous value in the RAX register.

	test	rax, rax	        ; Test RAX with itself. Among other things, this will
					;  set the processor's Zero Flag if RAX is 0.
					; If RAX is 0, then the lock was unlocked and
					;  we just locked it.
					; Otherwise, RAX is 1 and we didn't acquire the lock.

	jnz	spinLock		; Jump back to the MOV instruction if the Zero Flag is
					;  not set; the lock was previously locked, and so
					; we need to spin until it becomes unlocked.
	ret

; ******************************************************************
;  Mutex unlock
;	unlock the lock (shared global variable)

global	spinUnlock
spinUnlock:
	mov	rax, 0			; Set the RAX register to 0.

	xchg	rax, qword [myLock]	; Atomically swap the RAX register with
					;  the lock variable.
	ret

; ******************************************************************
;  Function getArgs()
;	Get, check, convert, verify range, and return the
;	sequential/parallel option and the limit.

;  Example HLL call:
;	stat = getArgs(argc, argv, &parFlag, &numberLimit)

;  This routine performs all error checking, conversion of ASCII/Nonary
;  to integer, verifies legal range.
;  For errors, applicable message is displayed and FALSE is returned.
;  For good data, all values are returned via addresses with TRUE returned.

;  Command line format (fixed order):
;	<-sq|-pr> -lm <nonaryNumber>

; -----
;  Arguments:
;	1) ARGC, value				RDI
;	2) ARGV, address			RSI
;	3) parallel flag (bool), address	RDX
;	4) limit (qword), address		RCX


;	YOUR CODE GOES HERE

global getArgs
getArgs:

	push	rbx
	push	r12
	push	r13
	push	r14

	mov	r14, rdx		; store addrress of parallel flag (bool)
	mov	r13, rcx		; store address of limit (qword), address

;------get args--------------------------
	
	cmp	rdi, 1			;check argc for arguments
	je	usageErr		; if(none) show err

	cmp	rdi, 4			; check for correct # of args
	jne	optionsErr		; if(argc != 4) show err

;------Check -sq or -pr -------------------
	mov	rbx, qword[rsi+8]	; get first command line argument
	cmp	dword[rbx], 0x0071732d 	; check for "-" "s" "q"
	je	seq			; if (seq) parallel flag == false

	cmp	dword[rbx], 0x0072702d ; check for "-" "p" "r"
	je	para 	

	jmp	pARselerr		; err for none of correct specifiers

     seq:
	mov	byte[r14], FALSE	; return FALSE to addrress of parallel flag
	jmp	next

     para:
	mov	byte[r14], TRUE		; return TRUE to addrress of parallel flag
	jmp	next

     next:

;------check "-lm"-------------------------

	mov	rbx, qword[rsi+16]	; get second command line argument
	cmp	dword[rbx], 0x006d6c2d	; if rbx != "-lm" give err
	jne	specErr

;------check value and convert ASCII/Nonary to integer-----------

	mov	rbx, qword[rsi+24]		; get third command line argument
	
	mov	r10, 0
	checkOne:
	mov	al, byte[rbx + r10]	; get rbx[i]
	cmp	al, NULL		; if(rbx[i] == NULL) done
	je	checkDone		; reached the end, done checking
	cmp	al, "0"
	jb	LValueErr		; err
	cmp	al, "8"
	ja	LValueErr		; err
	inc 	r10			; i++
	jmp	checkOne		; get next chr

     checkDone:

	mov	rdi, rbx
	mov	rsi, tmpNum		; addr num
	call	nonary2int

	cmp	qword[tmpNum], LIMITMIN	; if value is less than min jmp err
	jb	LValueErr
	cmp	qword[tmpNum], LIMITMAX	; if value is greater than max jmp err
	ja	LValueErr
	
	mov	r12, qword[tmpNum]	; store tmpNum in r12 for storage
	mov	qword[r13], r12		; return converted num value
	
	mov	rax, TRUE		; set rax to true for return
	jmp	exit			; exit function with true

;------ERRORS--------------------------------------

     usageErr:
	mov	rdi, errUsage
	call	printString
	mov	rax, FALSE
	jmp	exit

     optionsErr:
	mov	rdi, errOptions
	call	printString
	mov	rax, FALSE
	jmp	exit

     pARselerr:
	mov	rdi, errPARsel
	call	printString
	mov	rax, FALSE
	jmp	exit

     specErr:
	mov	rdi, errLSpec
	call	printString
	mov	rax, FALSE
	jmp	exit

     LValueErr:
	mov	rdi, errLSpec
	call	printString
	mov	rax, FALSE

;------END---------------------------------------

     exit:					; exit function
	
	pop	r14
	pop	r13
	pop	r12
	pop	rbx
	ret


; ******************************************************************
;  Function: Check and convert ASCII/Nonary to integer

;  Example HLL Call:
;	stat = nonary2int(nonaryStr, &num);


;	YOUR CODE GOES HERE

global nonary2int
nonary2int:

	push	rbx
	push	r12
;------get addresses-----------------------

	mov	rbx, rdi		; addr nonaryStr
	mov	r12, rsi		; num
;------Set up--------------------------------

	mov	r10, 0			; index
	mov	r11, 0	
	mov	qword [rSum], 0		; set rSum to 0
	mov	rax, 0			; reset rax

;--------Multiplication Loop-------------------------
     multLoop:
	mov	al, byte [rbx + r10]		; get first char
	cmp	al, NULL			; if (char==NULL) DONE
	je	outLoop				; else keep checking

	sub	al, 48				; al - "0"
	movsx	r11, al
	mov	qword [digit], r11		;store digit into var
	mov	rax, qword [rSum]		;move rSum for Mult
	mul	qword [qNine]
	mov	qword [rSum], rax		; store result into rSum
	;mov	qword [rSum + 8], rdx
	add	rax, qword [digit]		; add digit to running sum
	mov	qword [rSum], rax		; store answer into running sum

	inc	r10
	jmp	multLoop

;----------Mult done----------------------------------------

     outLoop:
	mov	rax, qword [rSum]		; store running sum in rax
	mov	qword [r12], rax		; return limit to address of limit (qword)

     nonary2intDone:
    	pop	r12
	pop	rbx
	ret



; ******************************************************************
;  Convert integer to ASCII/Nonary string.
;	Note, no error checking required on integer.

; -----
;  Arguments:
;	1) integer, value	RDI
;	2) string, address	RSI
; -----
;  Returns:
;	ASCII/Nonary string (NULL terminated)


;	YOUR CODE GOES HERE

global int2nonary
int2nonary:
	push 	rbx
	push	r12

;-----SET UP---------------------------
	mov	rax,rdi		; get integer value into rax
	mov	rcx, 0      	; set loop counter to 0
	mov 	r9,9      	; nine for division
	mov 	r12,"0"		; for subtracting by char "0"

;-------Count digits loop------------
     countLoop:
	mov 	rdx, 0  	; set remainder to 0
        div 	r9   		; divide by 9
        inc 	rcx    		; inc loop counter
        cmp	rax, 0  	; cmp num to 0
        jne 	countLoop	; if ( num != to 0) keep counting

;---------convert digit---------------

	mov	rax, rdi	; move digit to rax
	add	rsi, rcx	; add to integer value	
	mov	byte[rsi], NULL	; null term
	dec 	rsi		; rsi--

;----------loop for conversion----------

convertloop:
        mov 	rdx, 0          ; set remainder to 0
        div 	r9             ; divide by 9
        add	rdx, r12      	; add "0"
        mov	byte[rsi], dl   ; store digit
        dec 	rsi		; dec index
        cmp 	rax, 0		; if (rax == 0) DONE 
        jne 	convertloop	; else {keep converting}

	pop	r12
	pop	rbx
	ret


; ******************************************************************
;  Generic function to display a string to the screen.
;  String must be NULL terminated.
;  Algorithm:
;	Count characters in string (excluding NULL)
;	Use syscall to output characters

;  Arguments:
;	1) address, string
;  Returns:
;	nothing

global	printString
printString:

; -----
; Count characters to write.

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
	mov	rsi, rdi			; address of characters to write
	mov	rdi, STDOUT			; file descriptor for standard in
						; rdx=count to write, set above
	syscall					; system call

; -----
;  String printed, return to calling routine.

printStringDone:
	ret

; ******************************************************************


