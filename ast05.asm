;  Must include:
;	Name: Jorge Sagastume
;	Assignmnet 05
;	Section 1001

; -----
; This assembly program calculates come geometric information based on a set of two points.
; It will calculate slope, the distance betweeen two points and mid point of two points. 
; 


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
;  Data Set

; Points Set #1, (x1, y1)
	x1		db	 -33, -14, -23, -11, -34
			db	 -12, -10, -85, -63, -05
			db	 -64, -13, -24, -13, -65 
			db	 -44, -12, -13, -12, -23
			db	 -65, -64, -73, -16, -34
			db	 -53, -13, -43, -13, -35
			db	 -44, -69, -34, -33, -32
			db	 -34, -23, -15, -14, -01
			db	 -22, -42, -33, -02, -11
			db	 -25, -14, -23, -46, -54

	y1		db	  48,  94,  62,  63,  18
			db	  61,  45,  52,  29,  65
			db	  12,  10,  85,  63,  25
			db	  76,  47,  55,  19,  13
			db	  28,  45,  61,  64,  65
			db	  77,  20,  56,  47,  61
			db	  52,  19,  65,  61,  31
			db	  65,  14,  23,  15,  14
			db	  01,  71,  11,  21,  21
			db	  18,  25,  31,  34,  55

	; Points Set #2, (x2, y2)
	x2		dw	 245, 234, 123, 223, 123
			dw	 253, 153, 243, 153, 235
			dw	 134, 234, 156, 264, 142
			dw	 253, 153, 284, 142, 234
			dw	 245, 234, 123, 223, 123
			dw	 234, 134, 256, 164, 242
			dw	 253, 253, 184, 242, 134
			dw	 256, 164, 242, 134, 201
			dw	 101, 223, 172, 203, 177
			dw	 215, 114, 243, 153, 255
	 
	y2		dw	 4445, 4734, 3123, 3023, 1223
			dw	 2753, 1753, 4443, 2953, 3235
			dw	 1734, 3734, 2256, 4764, 4342
			dw	  753, 1753, 1284, 3442, 5434
			dw	 2145, 2734, 2123, 1223, 6523
			dw	 4734, 2734,  956, 7264, 1242
			dw	 1753, 1753, 6784, 4542, 7134
			dw	 2756, 2764, 2742, 5734, 1201
			dw	 4701, 1723, 1772, 4612, 3422
			dw	 1713, 6703, 5724, 1602, 5614

	length		dq	50

	slpMin		dd	0
	slpEstMed	dd	0
	slpMax		dd	0
	slpSum		dd	0
	slpAve		dd	0

	dstMin		dd	0
	dstEstMed	dd	0
	dstMax		dd	0
	dstSum		dd	0
	dstAve		dd	0

;Extra Variables
	ddTwo		dd	2




; ----------------------------------------------
;  Uninitialized Static Data Declarations.

section	.bss

;	Place data declarations for uninitialized data here...
;	(i.e., large arrays that are not initialized)


	slopes		resd	50
	distances	resd	50
	xMid		resw	50
	yMid		resw	50


; *****************************************************************

section	.text
global _start
_start:


; --------Slopes

	mov	rcx, qword [length]	;Length counter
	mov	rsi, 0			;index
	
	;Slopes = y2[rsi*2] - y1[rsi] / x2[rsi*2] - x1[rsi]
     slpLoop
	movsx	eax, word[y2+rsi*2]
	movsx	ebx, byte[y1+rsi]
	sub	eax, ebx
	cdq

	movsx	r8d, word[x2+rsi*2]
	movsx	r9d, byte[x1+rsi]
	sub	r8d, r9d
	idiv	r8d

	mov	dword [slopes + rsi * 4], eax
	inc	rsi

	loop	slpLoop

;--------Slope Calc

	mov	rcx, qword [length]	;Length counter
	mov	rsi, 0			;index 
	mov	eax, dword [slopes]
	mov	dword [slpMin], eax
	mov	dword [slpMax], eax 

     calcLoop:
	mov	eax, dword [slopes + rsi * 4]	; lst[i]
	add	dword [slpSum], eax
	inc	rsi
	cmp	eax, dword [slpMin]
	jae	minDone
	mov	dword [slpMin], eax
     minDone:
	cmp	eax, dword [slpMax]
	jbe	maxDone
	mov	dword [slpMax], eax
     maxDone:
	
	loop	calcLoop

;-------Slopes Ave
	
	mov	eax, dword [slpSum]
	mov	edx, 0
	idiv	qword [length]
	mov	dword [slpAve], eax

;-------Slope Median

	mov	eax, 0
	mov	r8d, 4
	add	eax, dword [slopes]
	add	eax, dword [slopes + 92]
	add	eax, dword [slopes + 96]
	add	eax, dword [slopes + 196]
	mov	edx, 0
	idiv	r8d
	mov	dword [slpEstMed], eax

;-------Distances

	mov	rcx, qword [length]	;Length counter
	mov	rsi, 0			;index

;	distances = SQRT[ (x2[i] + x1[i])^2 + (y2[i] + y1[i])^2 ]

    disLoop
	movsx	eax, word [x2+rsi*2]
	movsx	ebx, byte [x1+rsi]
	add	eax, ebx
	imul	eax
	
	movsx	r8d, word [y2+rsi*2]
	movsx	r9d, byte [y1+rsi]
	add	r8d, r9d
	imul	r8d, r8d
	
	add		eax, r8d

	cvtsi2sd 	xmm0, eax
	sqrtsd		xmm0, xmm0
	cvtsd2si	eax, xmm0
	
	mov	dword [distances + rsi*4], eax
	inc 	rsi
	loop	disLoop

;--------Distances Calc

	mov	rcx, qword [length]
	mov	rsi, 0
	mov	eax, dword [distances]
	mov	dword [dstMin], eax
	mov	dword [dstMin], eax

     dstCalcLoop:
	mov	eax, dword [distances + rsi*4]
	add	dword [dstSum], eax
	cmp	eax, dword [dstMin]
	jae	dstMinDone
	mov	dword [dstMin], eax
     dstMinDone:
	cmp	eax, dword [dstMax]
	jbe	dstMaxDone
	mov	dword [dstMax], eax
     dstMaxDone:
	inc	rsi
	loop	dstCalcLoop

;-------Distances Ave Calc

	mov	eax, dword [dstSum]
	mov	edx, 0
	div	qword [length]
	mov	dword [dstAve], eax

;-------Distances EstMed

	mov	eax, 0
	mov	r8d, 4
	add	eax, dword [distances]
	add	eax, dword [distances + 92]
	add	eax, dword [distances + 96]
	add	eax, dword [distances + 196]
	mov	edx, 0
	idiv	r8d
	mov	dword [dstEstMed], eax
	
;-------xMid

	mov	rcx, qword [length]
	mov	rsi, 0
	mov	bp, 2

     xMidLoop:
	movsx	ax, byte [x1+rsi]
	mov	bx, word [x2+rsi*2]
	add	ax, bx
	cwd
	idiv	bp
	mov	word [xMid + rsi*2], ax
	inc 	rsi
	loop	xMidLoop 

;-------yMid

	mov	rcx, qword [length]
	mov	rsi, 0
	mov	bp, 2

     yMidLoop:
	movsx	ax, byte [y1+rsi]
	mov	bx, word [y2+rsi*2]
	add	ax, bx
	cwd
	idiv	bp
	mov	word [yMid + rsi*2], ax
	inc 	rsi
	loop	yMidLoop 
		
	




; *****************************************************************
;	Done, terminate program.

last:
	mov	eax, SYS_exit		; call call for exit (SYS_exit)
	mov	ebx, SUCCESS		; return code of 0 (no error)
	syscall


