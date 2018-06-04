;  Must include:
;	Jorge Sagastume
;	Assignmnet 04
;	Section 1001

; -----
;  Short description of program goes here...
; This program runs through a list of unsigned numbers and calculates the
; sum of the list, average value, max value, min value and estimated median value
; it also calculates the sum of all numbers that are even and numbers that are divisible by 8
; it then calculates the sum and count of all even numbers and sum and count for all numbers
; divisible by 8.


; *****************************************************************
;  Static Data Declarations (initialized)

section	.data

; -----
;  Define standard constants.

NULL		equ	0			; end of string

TRUE		equ	1
FALSE		equ	0

SUCCESS		equ	0			; Successful operation
SYS_exit	equ	60			; call code for terminate

; -----
;  Declare variables.

;	Place data declarations here...
; -----

lst		dd	3712, 1116, 1539, 1240, 1674
		dd	1629, 2412, 1818, 1242, 3333 
		dd	2313, 1215, 2726, 1140, 2565
		dd	2871, 1614, 2418, 2513, 1422 
		dd	1809, 1215, 1525, 2712, 1441
		dd	3622, 1888, 1729, 1615, 2724 
		dd	1217, 1224, 1580, 1147, 2324
		dd	1425, 1816, 1262, 2718, 1192 
		dd	1435, 1235, 2764, 1615, 1310
		dd	1765, 1954, 2967, 1515, 1556 
		dd	2342, 7321, 1556, 2727, 1227
		dd	1927, 1382, 1465, 3955, 1435 
		dd	1225, 2419, 2534, 1345, 2467
		dd	1615, 1959, 1335, 2856, 2553
		dd	1035, 1833, 1464, 1915, 1810
		dd	1465, 1554, 2267, 1615, 1656 
		dd	2192, 1825, 1925, 2312, 1725
		dd	2517, 1498, 1677, 1475, 2034
		dd	1223, 1883, 1173, 1350, 2415
		dd	1089, 1125, 1118, 1713, 3024
length		dd	100

lstMin		dd	0
estMed		dd	0
lstMax		dd	0
lstSum		dd	0
lstAve		dd	0

evenCnt		dd	0
evenSum		dd	0
evenAve		dd	0

eightCnt	dd	0
eightSum	dd	0
eightAve	dd	0







; ----------------------------------------------
;  Uninitialized Static Data Declarations.

section	.bss

;	Place data declarations for uninitialized data here...
;	(i.e., large arrays that are not initialized)


; *****************************************************************

section	.text
global _start
_start:


; -----
;	YOUR CODE GOES HERE...

	mov 	ecx, dword [length]	;length value
	mov	rsi, 0			;index
	mov	eax, dword [lst]
	mov	dword [lstMin], eax
	mov	dword [lstMax], eax

;Calc Sum
     calcLoop:
	mov	eax, dword [lst + (rsi * 4)]	; lst[i]
	add	dword [lstSum], eax
	inc	rsi
	cmp	eax, dword [lstMin]
	jae	minDone
	mov	dword [lstMin], eax
     minDone:
	cmp	eax, dword [lstMax]
	jbe	maxDone
	mov	dword [lstMax], eax
     maxDone:
	
	loop	calcLoop

;Calc Ave
	mov	eax, dword [lstSum]
	mov	edx, 0
	div	dword [length]
	mov	dword [lstAve], eax


;Calc Even
	mov 	ecx, dword [length]
	mov 	rsi, 0
	mov	r9d, 2

     loop1:
	mov	eax, dword [lst+(rsi*4)]
	mov	r10d, eax
	inc	rsi
	mov	edx, 0
	div	r9d
	cmp	edx, 0
	jne	notEven
	inc	dword [evenCnt]
	add	dword [evenSum], r10d
     notEven:

	loop	loop1

;Calc even ave
	mov	eax, dword [evenSum]
	mov	edx, 0
	div	dword [evenCnt]
	mov	dword [evenAve], eax

;Calc eight
	mov	ecx, 0
	mov	ecx, dword [length]
	mov	rsi, 0
	mov	r8d, 8

     loop2:
	mov	eax, dword [lst+rsi*4]
	mov	r11d, eax
	inc 	rsi
	mov 	edx, 0
	div	r8d
	cmp 	edx, 0
	jne	notEight
	inc 	dword [eightCnt]
	add	dword [eightSum], r11d
     notEight:

	loop	loop2

;Calc eight ave
	mov	eax, dword [eightSum]
	mov	edx, 0
	div	dword [eightCnt]
	mov	dword [eightAve], eax

;calc estMed
	mov	eax, 0	
	add	eax, dword [lst + 0]
	add	eax, dword [lst + 196]
	add	eax, dword [lst + 200]
	add	eax, dword [lst + 396]
	mov	edi, 4
	mov	edx, 0
	div	edi
	mov	dword [estMed], eax


	
	



; *****************************************************************
;	Done, terminate program.

last:
	mov	eax, SYS_exit		; call call for exit (SYS_exit)
	mov	ebx, SUCCESS		; return code of 0 (no error)
	syscall


