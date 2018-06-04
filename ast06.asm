;  Name: Jorge Sagastume
;  Section: 1001
;  CS 218, Assignment #6
;  Provided Main

;  Write a simple assembly language program to calculate
;  the x-intercepts for each line in a series of lines.

;  The points data are provided as nonary (base 9) values
;  represented as ASCII characters and must be converted
;  into integers in order to perform the calculations.

; --------------------------------------------------------------
;  Macro to convert nonary (base 9) value in ASCII format
;  into an integer.
;  Assumes valid data, no error checking is performed.

;  Call:  nonary2int  <stringAddr>, <integer>
;	Arguments:
;		%1 -> <stringAddr>, string address
;		%2 -> <integerAddr>, address for integer result

;  Reads <stringAddr> and converts to integer and places
;  in <integer>

; -----
; Algorithm:
;	runningSum = 0
;   startLoop
;	get character from string
;	convert character to integer (integerDigit)
;	runningSum = runningSum * 9
;	runningSum = runningSum + integerDigit
;   next loop
;   return final result (from running sum)

; Note,	<stringAddr> is passed as address in RSI
;	<integerAddr> is passed as address on RDI

%macro	nonary2int	2


;	YOUR CODE GOES HERE

	mov	r14, 0
	mov	dword [rSum], 0		;rsum = 0
	mov	dword [signVar], 1	;signVar = 1
	
	mov	al, byte [%1 + r14]	;get starting address/sign char
	cmp	al, 45			;if al != "-"
	je	%%negSign
	jmp	%%multLoop		;then jump to cvtLoop

     %%negSign:
	mov	dword [signVar], -1	;negate sign

     %%multLoop:			;Loop to convert throug multiplication
	inc	r14			;i++ to next char
	mov	al, byte [%1 + r14]	;get next char
	cmp	al, 0			;check for NULL, if Null break out Loop
	je	%%outLoop		;if al == NULL then break out

	sub	al, 48			;Convert to digit by subtracting "0"
	movsx	r10d, al		;convert digit to double variable
	mov	dword [digit], r10d	;store double digit into var
	mov	eax, dword [rSum]	;move running to sum to do mult
	imul	dword [dNine]		;multiply current running sum by 9
	mov	dword [rSum], eax	;store result into running sum
	add	eax, dword [digit]	;add digit to running sum
	mov	dword [rSum], eax	;store the answer into the running sume var

	jmp	%%multLoop		

     %%outLoop:				;out Loop to generate final num
	mov	eax, dword [rSum]	;move runnimg sum to eax for mult
	imul	dword [signVar]		;multiply by the sign
	mov	dword [%2], eax		;store answer in address for int result




%endmacro

; --------------------------------------------------------------
;  Macro to convert integer to nonary value in ASCII format.

;  Call:  int2nonary    <integer>, <stringAddr>, <length>
;	Arguments:
;		%1 -> <integer>, value
;		%2 -> <stringAddr>, string address

;  Reads <integer> and places nonary characters,
;	including the sign and NULL into <stringAddr>

%macro	int2nonary	2


;	YOUR CODE GOES HERE

	mov	r13, 0			;digit count = 0
	mov	ebx, 9			;nine for divide
	mov	eax, dword [%1]		;get x-intercept

     %%divLoop:
	cdq
	idiv	ebx			;divide by 9
	push 	rdx			;push the remainder
	inc	r13			;inc digit count

	cmp 	eax, 0			;if (result > 0)
	jne	%%divLoop

;--------Convert Remainders and store------------

	mov	rbx, %2			;address of string
	mov	r12, 0			;idx = 0

	cmp	dword [%1], 0		;compare to 0
	jl	%%negate		;if num is less than 0 negate sign
	mov	byte [rbx+r12], 43	;else add "+"
	inc	r12			;increment 
	jmp	%%popLoop

     %%negate:
	mov	byte [rbx+r12], 45
	inc	r12

     %%popLoop:
	pop	rax			;pop int digit
	add	al, 48			;char = int + "0"

	mov	byte [rbx+r12], al
	inc 	r12
	dec	r13
	cmp	r13, 0
	ja	%%popLoop

	mov	byte [rbx+r12], NULL


%endmacro

; --------------------------------------------------------------
;  Simple macro to display a string to the console.
;	Call:	printString  <stringAddr>

;	Arguments:
;		%1 -> <stringAddr>, string address

;  Count characters (excluding NULL).
;  Display string starting at address <stringAddr>

%macro	printString	1
	push	rax			; save altered registers
	push	rdi
	push	rsi
	push	rdx
	push	rcx

	mov	rdx, 0
	mov	rdi, %1
%%countLoop:
	cmp	byte [rdi], NULL
	je	%%countLoopDone
	inc	rdi
	inc	rdx
	jmp	%%countLoop
%%countLoopDone:

	mov	rax, SYS_write		; system call for write (SYS_write)
	mov	rdi, STDOUT		; standard output
	mov	rsi, %1			; address of the string
	syscall				; call the kernel

	pop	rcx			; restore registers to original values
	pop	rdx
	pop	rsi
	pop	rdi
	pop	rax
%endmacro

; --------------------------------------------------------------

section	.data

; -----
;  Define constants.

TRUE		equ	1
FALSE		equ	0

SUCCESS		equ	0			; successful operation
NOSUCCESS	equ	1			; unsuccessful operation

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

NUMS_PER_LINE	equ	3
MAX_STR_LENGTH	equ	20

; -----
;  Assignment #6 Provided Data:

Anum		db	"-125", NULL
Aval		dd	0
Cval		dd	-134120
xInt		dd	0

Alst		db	    "+117", NULL,     "-347", NULL,     "+647", NULL
		db	    "+275", NULL,     "+134", NULL,     "+206", NULL
		db	    "+618", NULL,    "+1231", NULL,    "-1018", NULL
		db	     "+28", NULL,     "+283", NULL,    "-1206", NULL
		db	    "-184", NULL,     "+481", NULL,    "-2034", NULL
		db	    "-164", NULL,      "+71", NULL,    "-1845", NULL

Clst		db	 "+128127", NULL,  "+162221", NULL, "+3412231", NULL
		db	"-1176825", NULL,  "+158027", NULL, "-1174821", NULL
		db	  "+28435", NULL,   "-15816", NULL, "-2876520", NULL
		db	 "+217458", NULL,  "-257410", NULL, "-6520287", NULL
		db	 "-120168", NULL,   "+12872", NULL, "+1451345", NULL
		db	"+1718221", NULL,  "+268760", NULL,  "-823575", NULL

length		dd	18
xIntSum		dd	0
xIntAve		dd	0

; -----
;  Misc. variables for main.

hdr		db	"------------------------------------"
		db	"-------------------------"
		db	LF, ESC, "[1m", "CS 218 - Assignment #6"
		db	ESC, "[0m", LF
		db	"X-Intercepts Program"
		db	LF, NULL

xHdr		db	LF, "X-intercept (test): ", NULL
xIntsHdr	db	LF, "X-intercepts: ", LF, NULL
smHdr		db	LF, "X-intercepts Sum: ", NULL
avHdr		db	LF, "X-intercepts Ave: ", NULL

numCount	dd	0
tempNum		dd	0

;-------My Vars----------
rSum		dd	0
signVar		dd	0
lookVar		dd	0
digit		dd	0
;------------------------

newLine		db	LF, NULL
dNine		dd	9
dTwo		dd	2
spaces		db	"    ", NULL

; --------------------------------------------------------------
;  Uninitialized (empty) variables

section	.bss

tmpString	resb	MAX_STR_LENGTH+1

Avalues		resd	18
Cvalues		resd	18
xInts		resd	18

; --------------------------------------------------------------

section	.text
global	_start
_start:

; -----
;  Display initial headers.

	printString	hdr

; ########################################################################
;  Part A - no macros.

; -----
;  Convert nonary x value (in ASCII format) to integer.
;	Do not use macro here...

;	YOUR CODE GOES HERE

	mov	r14, 0
	mov	dword [rSum], 0		;rsum = 0
	mov	dword [signVar], 1	;signVar = 1
	
	mov	al, byte [Anum + r14]	;get starting address/sign char
	cmp	al, 45			;if al != "-"
	je	negSign
	jmp	multLoop		;then jump to cvtLoop

     negSign:
	mov	dword [signVar], -1	;negate sign

     multLoop:				;Loop to convert throug multiplication
	inc	r14			;i++ to next char
	mov	al, byte [Anum + r14]	;get next char
	cmp	al, 0			;check for NULL, if Null break out Loop
	je	outLoop			;if al == NULL then break out

	sub	al, 48			;Convert to digit by subtracting "0"
	movsx	r10d, al		;convert digit to double variable
	mov	dword [digit], r10d	;store double digit into var
	mov	eax, dword [rSum]	;move running to sum to do mult
	imul	dword [dNine]		;multiply current running sum by 9
	mov	dword [rSum], eax	;store result into running sum
	add	eax, dword [digit]	;add digit to running sum
	mov	dword [rSum], eax	;store the answer into the running sume var

	jmp	multLoop		

     outLoop:				;out Loop to generate final num
	mov	eax, dword [rSum]	;move runnimg sum to eax for mult
	imul	dword [signVar]		;multiply by the sign
	mov	dword [Aval], eax	;store answer in Aval

; -----
;  Compute X intercept based on point slope formula.
;	x = C/A

;	YOUR CODE GOES HERE

	mov	eax, dword [Cval]	;place C val into eax reg
	cdq				;convert double to quad
	idiv	dword [Aval]		;idiv eax by Aval
	mov	dword [xInt], eax	;move answer from eax to xInt var




; -----
;  Convert x-intercept into ASCII for printing.

	printString	xHdr

;	YOUR CODE GOES HERE

	mov	eax, dword [xInt]	;get x-intercept
	mov	rcx, 0			;digit count = 0
	mov	ebx, 9			;nine for divide

     divLoop:
	mov	edx, 0
	cdq
	idiv	ebx			;divide by 9
	push 	rdx			;push the remainder
	inc	rcx			;inc digit count

	cmp 	eax, 0			;if (result > 0)
	jne	divLoop

;--------Convert Remainders and store------------

	mov	rbx, tmpString
	mov	r12, 0

	cmp	dword [xInt], 0
	jl	negate
	mov	byte [rbx+r12], 43
	inc	r12
	jmp	popLoop

     negate:
	mov	byte [rbx+r12], 45
	inc	r12

     popLoop:
	pop	rax			;pop int digit
	add	al, 48			;char = int + "0"

	mov	byte [rbx+r12], al
	inc 	r12
	loop	popLoop

	mov	byte [rbx+r12], NULL


	printString	tmpString
	printString	newLine
	printString	newLine


; ########################################################################
;  Part B - convert code from Part A into macro
;	call macro multiple times in a loop.

; -----
;  Convert Alst[] nonary data (in ASCII format) to integer.

	mov	ecx, dword [length]
	mov	rsi, Alst
	mov	rdi, Avalues

cvtAloop:
	push	rcx				; save register contents
	push	rsi
	push	rdi

	nonary2int	rsi, rdi

	pop	rdi				; restore register contents
	pop	rsi
	pop	rcx

nxtChrA:					; goto next string
	cmp	byte [rsi], NULL
	je	gotAEOS
	inc	rsi
	jmp	nxtChrA
gotAEOS:
	inc	rsi				; next Alst
	add	rdi, 4				; next Avalues

	dec	ecx
	cmp	ecx, 0
	jne	cvtAloop

; -----
;  Convert Clst[] nonary data (in ASCII format) to integer.

	mov	ecx, dword [length]
	mov	rsi, Clst
	mov	rdi, Cvalues

cvtCloop:
	push	rcx				; save register contents
	push	rsi
	push	rdi

	nonary2int	rsi, rdi

	pop	rdi				; restore register contents
	pop	rsi
	pop	rcx

nxtChrC:					; goto next string
	cmp	byte [rsi], NULL
	je	gotCEOS
	inc	rsi
	jmp	nxtChrC
gotCEOS:
	inc	rsi				; next Alst
	add	rdi, 4				; next Avalues

	dec	ecx
	cmp	ecx, 0
	jne	cvtCloop

; -----
;  Calculate the x-intercepts.
;  Also find x-intercepts sum and average.

	mov	ecx, dword [length]
	mov	rsi, 0
	mov	dword [xIntSum], 0			; sum = 0

xIntLoop:
	mov	eax, dword [Cvalues+rsi*4]
	cdq
	idiv	dword [Avalues+rsi*4]

	mov	dword [xInts+rsi*4], eax		; save Xint
	add	dword [xIntSum], eax			; sum

	inc	rsi
	loop	xIntLoop

; -----
;  Find x-intercepts average.

	mov	eax, dword [xIntSum]
	cdq
	idiv	dword [length]
	mov	dword [xIntAve], eax

; -----
;  Convert integer x-intercepts into nonary (in ASCII format) for printing.
;  For every 4th line, print a newLine (for formatting).

	printString	xIntsHdr

	mov	ecx, dword [length]
	mov	rdi, xInts
	mov	rsi, 0
	mov	dword [numCount], 0

cvtBAloop:
	mov	eax, dword [xInts+rsi*4]
	mov	dword [tempNum], eax

	int2nonary	tempNum, tmpString
	printString	tmpString
	printString	spaces

	inc	dword [numCount]
	cmp	dword [numCount], NUMS_PER_LINE
	jl	skipNewline1
	printString	newLine
	mov	dword [numCount], 0
skipNewline1:

	inc	rsi
	dec	rcx
	cmp	rcx, 0
	jne	cvtBAloop

; -----
;  Convert integer sum into nonary (in ASCII format) for printing.

	printString	smHdr
	int2nonary	xIntSum, tmpString
	printString	tmpString

; -----
;  Convert integer average into nonary (in ASCII format) for printing.

	printString	avHdr
	int2nonary	xIntAve, tmpString
	printString	tmpString

	printString	newLine
	printString	newLine

; -----
; Done, terminate program.

last:
	mov	rax, SYS_exit
	mov	rbx, SUCCESS
	syscall


