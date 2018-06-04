; Name: Jorge Sagastume
; Section: 1001
; CS 218
; Assignment #7

;  Sort a list of number using the comb sort algorithm.
;  Also finds the minimum, median, maximum, sum, and average of the list.

; **********************************************************************************
;  Comb Sort Algorithm:

;  void function combSort(array, length)
;     gap = length
;
;     outter loop until gap = 1 and swapped = false
;         gap = (gap * 10) / 12	     			// update gap for next sweep
;         if gap < 1
;           gap = 1
;         end if
;
;         i = 0
;         swapped = false
;
;         inner loop until i + gap >= length	       // single comb sweep
;             if  array[i] > array[i+gap]
;                 swap(array[i], array[i+gap])
;                 swapped = true
;             end if
;             i = i + 1
;         end inner loop
;      end outter loop
;  end function


; **********************************************************************************
;  Macro, "int2nonary", to convert a signed base-10 integer into
;  an ASCII string representing the nonary value.  The macro stores
;  the result into an ASCII string (byte-size, signed,
;  NULL terminated).  Each integer is a doubleword value.
;  Assumes valid/correct data.  As such, no error checking is performed.

; --------------------------------------------------------------
;  Macro to convert integer to nonary value in ASCII format.


;	MACRO CODE FROM ASST #6 GOES HERE

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
	mov	eax, dword [%1]		;get array value

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
	jmp	%%popLoop		;go to pop loop

     %%negate:
	mov	byte [rbx+r12], 45	;add "-" sign
	inc	r12			;inc idx

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

; **********************************************************************************

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

LIMIT		equ	10000
MAX_STR_LENGTH	equ	20

; -----
;  Provided data

array		dd	 1113, -1232,  2146,  1376,  5120,  2356,  3164,  4565, -3155,  3157
		dd	-2759,  6326,   171,  -547, -5628, -7527,  7569,  1177,  6785, -3514
		dd	 1001,   128, -1133,  9105,  3327,   101, -2115, -1108,     1,  2115
		dd	 1227, -1226,  5129,  -117,  -107,   105,  3109,  9999,  1150,  3414
		dd	-1107,  6103,  1245,  5440,  1465,  2311,   254,  4528, -1913,  6722
		dd	 4149,  2126, -5671,  7647, -4628,   327,  2390,  1177,  8275, -5614
		dd	 3121,  -415,   615,   122,  7217,   421,   410,  1129,  812,   2134
		dd	-1221,  2234, -7151,  -432,   114,  1629,  2114,  -522,  2413,   131
		dd	 5639,   126,  1162,   441,   127,   877,   199,  5679, -1101,  3414
		dd	 2101,  -133,  5133,  6450, -4532, -8619,   115,  1618,  9999,  -115
		dd	-1219,  3116,  -612,  -217,   127, -6787, -4569,  -679,  5675,  4314
		dd	 3104,  6825,  1184,  2143,  1176,   134,  5626,   100,  4566,  2346
		dd	 1214, -6786,  1617,   183, -3512,  7881,  8320,  3467, -3559,  -190
		dd	  103,  -112,    -1,  9186,  -191,  -186,   134,  1125,  5675,  3476
		dd	-1100,     1,  1146,  -100,   101,    51,  5616, -5662,  6328,  2342
		dd	 -137, -2113,  3647,   114,  -115,  6571,  7624,   128,  -113,  3112
		dd	 1724,  6316,  4217, -2183,  4352,   121,   320,  4540,  5679,  1190
		dd	-9130,   116,  5122,   117,   127,  5677,   101,  3727,     0,  3184
		dd	 1897, -6374,  1190,    -1,  1224,     0,   116,  8126,  6784,  2329
		dd	-2104,   124, -3112,   143,   176, -7534, -2126,  6112,   156,  1103
		dd	 1153,   172,  1146, -2176,  -170,   156,   164,  -165,   155,  5156
		dd	 -894, -4325,   900,   143,   276,  5634,  7526,  3413,  7686,  7563
		dd	  511,  1383, 11133,  4150,   825,  5721,  5615, -4568, -6813, -1231
		dd	 9999,   146,  8162,  -147,  -157,  -167,   169,   177,   175,  2144
		dd	-1527, -1344,  1130,  2172,  7224,  7525,   100,     1,  2100,  1134   
		dd	  181,   155,  2145,   132,   167,  -185,  2150,  3149,  -182,  1434
		dd	  177,    64, 11160,  4172,  3184,   175,   166,  6762,   158, -4572
		dd	-7561, -1283,  5133,  -150,  -135,  5631,  8185,   178,  1197,  1185
		dd	 5649,  6366,  3162,  5167,   167, -1177,  -169, -1177,  -175,  1169
		dd	 3684,  9999, 11217,  3183, -2190,  1100,  4611, -1123,  3122,  -131


length		dd	300

minimum		dd	0
median		dd	0
maximum		dd	0
sum		dd	0
average		dd	0

; -----
;  Misc. data definitions (if any).

lookVar		dd	0
swapped		db	TRUE
dTen		dd	10
dTwelve		dd	12
dFour		dd	4
dTwo		dd	2
gap		dd	0

; -----
;  Provided string definitions.

newLine		db	LF, NULL

hdr		db	LF, "CS 218 - Assignment #7"
		db	LF, LF, NULL

hdrMin		db	"Minimum: ", NULL
hdrMax		db	"Maximum: ", NULL
hdrMed		db	"Median:  ", NULL
hdrSum		db	"Sum:     ", NULL
hdrAve		db	"Average: ", NULL
	

; **********************************************************************************

section .bss

tempString	resb	MAX_STR_LENGTH+1


; **********************************************************************************

section	.text
global	_start
_start:

; ******************************
;  Sort data using Comb sort.
;  Find sum and compute the average.
;  Get/save min and max.
;  Find median.

;  Comb Sort Algorithm:

;  void function combSort(array, length)
;     gap = length
;
;     outter loop WHILE gap = 1 OR swapped = TRUE
;         gap = (gap * 10) / 12	     			// update gap for next sweep
;         if gap < 1
;           gap = 1
;         end if
;
;         i = 0
;         swapped = false
;
;         inner loop until i + gap >= length	       // single comb sweep
;             if  array[i] > array[i+gap]
;                 swap(array[i], array[i+gap])
;                 swapped = true
;             end if
;             i = i + 1
;         end inner loop
;      end outter loop
;  end function


;	YOUR CODE GOES HERE
; COMB SORT!
; function combSort(array,length)

	mov	eax, dword [length] 		; gap
	mov	byte [swapped], TRUE		; set swap to TRUE

;-----Outer Loop---------------------
     outerLoop:
	cmp	byte [swapped], TRUE		; cmp swapped to FALSE
	jne	outerLoopDone			; if FALSE outer loop is done

	imul	dword [dTen]			; (gap * 10)
	cdq					; convert double to quad for idiv
	idiv	dword [dTwelve]			; (gap * 10) / 12
	mov	dword [gap], eax		; store result into gap variable
	mov	r9d , dword [gap]		; store gap into r9

	cmp	dword [gap], 1			; cmp 1 to gap
	ja	dontSet				; if gap > 1 skip gap setting
	mov	dword [gap], 1			; else set gap to 1

     dontSet:
	mov	rsi, 0				; set index
	mov	byte [swapped], FALSE		; set swapped bool to false

;----------Inner Loop-------------------
     innerLoop
	mov	r8, rsi				; move index to r8
	add	r8d, r9d			; add gap to i (gap + i)
	mov	eax, r8d			; move (i + gap) into eax
	imul	dword [dFour]			; imul by dWord size
	movsxd	rdi, eax			; rdi = (i + gap)	
	
	cmp	r8d, dword [length]		; if (i + gap) >= length
	jae	innerLoopDone			; end inner loop
						; else begin swap compare
	mov	eax, dword [array + rsi * 4]	; take array [i]
	mov	ebx, dword [array + rdi]	; take array [i + gap]	
	
	cmp	eax, ebx			; if eax <= ebx
	jle	swapDone			; leave as is, else swap points

	mov	dword [array + rsi * 4], ebx	; swap ebx into old eax position
	mov	dword [array + rdi], eax	; swap eax into old ebx position
	mov	byte [swapped], TRUE		; change swapped bool to TRUE

     swapDone:					; swap completed
	inc 	rsi				; inc i
	jmp	innerLoop			; jmp back to inner loop	

     innerLoopDone:
	mov	eax, r9d			; preserve gap			
	inc 	rsi				; inc i
	jmp	outerLoop			; jmp back to outerloop

     outerLoopDone:

;-------------Min and Max-----------------

	mov	rsi, 0				; reset index back to 0
	mov	eax, dword [array + rsi * 4]	; place min into eax
	mov	dword [minimum], eax		; store min from eax into min variable

	movsxd	rsi, dword [length]		; store length into index
	mov	eax, dword [array + rsi * 4 - 4]; move max value into eax
	mov	dword [maximum], eax		; store eax into max value variable

;-------------Sum Loop----------------

	mov	rax, 0				; set rax to 0
	mov	rsi, 0				; set index back to 0
	movsxd	rcx, dword [length]		; set rcx to length

     sumLoop:
	mov	eax, dword [array + rsi * 4]	; mov to eax array[i]
	add	dword [sum], eax		; add array[i] to sum
	inc 	rsi				; inc i
	loop	sumLoop				; dec rcx, loop back

;----------------Ave-----------------
	mov	eax, dword [sum]		; move sum to eax
	mov	edx, 0				; clear edx 	
	div	dword [length]			; divide sum in eax by length
	mov	dword [average], eax		; store result into average variable

;---------------Median----------------

	;mov	eax, dword [array + 596]	; first middle value of even array
	;mov	ebx, dword [array + 600]	; second middle value of even array
	;add 	eax, ebx			; sum of values in eax
	;cdq					; convert double to quad for idiv
	;idiv	dword [dTwo]			; idiv eax by 2
	;mov	dword [median], eax		; store result from eax into median variable

;---------------Median------------------

	mov	rsi, 0
	mov	esi, dword [length]
	mov	rax, 1
	and 	rax, rsi
	shr	rsi, 1
	mov	eax, dword [array + rsi * 4]
	cmp	eax, 1
	je	medDone
	dec 	rsi
	add 	eax, dword [array + rsi * 4]
	mov	edx, 0
	div	dword [dTwo]	

     medDone:
	mov	dword [median], eax





; ******************************
;  Display results to screen in duodecimal.

	printString	hdr

	printString	hdrMin
	int2nonary	minimum, tempString
	printString	tempString
	printString	newLine

	printString	hdrMax
	int2nonary	maximum, tempString
	printString	tempString
	printString	newLine

	printString	hdrMed
	int2nonary	median, tempString
	printString	tempString
	printString	newLine

	printString	hdrSum
	int2nonary	sum, tempString
	printString	tempString
	printString	newLine

	printString	hdrAve
	int2nonary	average, tempString
	printString	tempString
	printString	newLine
	printString	newLine

; ******************************
;  Done, terminate program.

last:
	mov	rax, SYS_exit
	mov	rbx, SUCCESS
	syscall


