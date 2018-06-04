

;  Jorge Sagastume
;  CS 218
;  Section 1001
;  Assignment #10

;  Wheels - Support Functions.
;  Provided Template

; -----
;  Function: getParams
;	Gets, checks, converts, and returns command line arguments.

;  Function drawWheels()
;	Plots provided functions

; ---------------------------------------------------------

;	MACROS (if any) GO HERE


; ---------------------------------------------------------

section  .data

; -----
;  Define standard constants.

TRUE		equ	1
FALSE		equ	0

SUCCESS		equ	0			; successful operation
NOSUCCESS	equ	1

STDIN		equ	0			; standard input
STDOUT		equ	1			; standard output
STDERR		equ	2			; standard error

SYS_read	equ	0			; code for read
SYS_write	equ	1			; code for write
SYS_open	equ	2			; code for file open
SYS_close	equ	3			; code for file close
SYS_fork	equ	57			; code for fork
SYS_exit	equ	60			; code for terminate
SYS_creat	equ	85			; code for file open/create
SYS_time	equ	201			; code for get time

LF		equ	10
SPACE		equ	" "
NULL		equ	0
ESC		equ	27

; -----
;  OpenGL constants

GL_COLOR_BUFFER_BIT	equ	16384
GL_POINTS		equ	0
GL_POLYGON		equ	9
GL_PROJECTION		equ	5889

GLUT_RGB		equ	0
GLUT_SINGLE		equ	0

; -----
;  Define constants.

SPD_MIN		equ	1
SPD_MAX		equ	50			; 55(9) = 50

CLR_MIN		equ	0
CLR_MAX		equ	0xFFFFFF

SIZ_MIN		equ	100			; 121(9) = 100
SIZ_MAX		equ	2000			; 2662(9) = 2000

; -----
;  Local variables for getRadii procedure.

STR_LENGTH	equ	12

ddNine		dd	9

errUsage	db	"Usage: ./wheels -sp <nonaryNumber> -cl <nonaryNumber> "
		db	"-sz <nonaryNumber>"
		db	LF, NULL
errBadCL	db	"Error, invalid or incomplete command line argument."
		db	LF, NULL

errSpdSpec	db	"Error, speed specifier incorrect."
		db	LF, NULL
errSpdValue	db	"Error, speed value must be between 1 and 55(9)."
		db	LF, NULL

errClrSpec	db	"Error, color specifier incorrect."
		db	LF, NULL
errClrValue	db	"Error, color value must be between 0 and 34511010(9)."
		db	LF, NULL

errSizSpec	db	"Error, size specifier incorrect."
		db	LF, NULL
errSizValue	db	"Error, size value must be between 121(9) and 2662(9)."
		db	LF, NULL

; -----
;  Local variables for spirograph routine.

t		dq	0.0			; loop variable
s		dq	0.0
tStep		dq	0.001			; t step
sStep		dq	0.0
x		dq	0			; current x
y		dq	0			; current y
scale		dq	1000.0			; speed scale

fltZero		dq	0.0
fltOne		dq	1.0
fltTwo		dq	2.0
fltThree	dq	3.0
fltFour		dq	4.0
fltSix		dq	6.0
fltTwoPiS	dq	0.0

pi		dq	3.14159265358

fltTmp1		dq	0.0
fltTmp2		dq	0.0

red		dd	0			; 0-255
green		dd	0			; 0-255
blue		dd	0			; 0-255

;-------My Vars----------
rSum		dd	0
signVar		dd	0
digit		dd	0
Aval		dd	0
dNine		dd	9

twoPi		dq	0.0
sixPi		dq	0.0
cosT		dq	0.0
sinT		dq	0.0
twoPiS		dq	0.0
fourPiS		dq	0.0
twoCos		dq	0.0
twoSin		dq	0.0
;------------------------


; ------------------------------------------------------------

section  .text

; -----
; Open GL routines.

extern	glutInit, glutInitDisplayMode, glutInitWindowSize, glutInitWindowPosition
extern	glutCreateWindow, glutMainLoop
extern	glutDisplayFunc, glutIdleFunc, glutReshapeFunc, glutKeyboardFunc
extern	glutSwapBuffers, gluPerspective, glutPostRedisplay
extern	glClearColor, glClearDepth, glDepthFunc, glEnable, glShadeModel
extern	glClear, glLoadIdentity, glMatrixMode, glViewport
extern	glTranslatef, glRotatef, glBegin, glEnd, glVertex3f, glColor3f
extern	glVertex2f, glVertex2i, glColor3ub, glOrtho, glFlush, glVertex2d

extern	cos, sin


; ******************************************************************
;  Function getParams()
;	Gets draw speed, draw color, and screen size
;	from the command line arguments.

;	Performs error checking, converts ASCII/nonary to integer.
;	Command line format (fixed order):
;	  "-sp <nonaryNumber> -cl <nonaryNumber> -sz <nonaryNumber>"

; -----
;  Arguments:
;	ARGC, double-word, value	;rdi
;	ARGV, double-word, address	;rsi
;	speed, double-word, address	;rdx
;	color, double-word, address	;rcx
;	size, double-word, address	;r8

global	getParams
getParams:

	push	rbx
	push	r10
	push	r12
	push	r13
	push	r14
	push	r15

	mov	r13, rsi ;argv
	mov	r15, rdx ;speed
	mov	r12, rcx ;color
	mov	r14, r8 ;size

;------Check Usage----------

	cmp	rdi, 1
	je	usageErr

;------Check # Args---------

	cmp	rdi, 7
	jne	badCL

;-----Check 'sp'-------------

	mov	rbx, qword [rsi + 8]
	cmp	dword [rbx], 0x0070732d
	jne	SpdSpecerr

;-------Check Speed Value----

	mov	rbx, qword [rsi + 16]
	mov	r10, 0

     checkOne:
	mov	al, byte [rbx + r10]
	cmp	al, NULL
	je	checkDone
	cmp	al, "0"
	jb	SpdValueErr
	cmp	al, "8"
	ja	SpdValueErr
	inc 	r10
	jmp	checkOne

     checkDone:	
	mov	r10, 0
	mov	r11, 0
	mov	dword [rSum], 0
	mov	rax, 0

     multLoop:
	mov	al, byte [rbx + r10]
	cmp	al, NULL
	je	outLoop

	sub	al, 48
	movsx	r11d, al
	mov	dword [digit], r11d		;store digit into var
	mov	eax, dword [rSum]		;move rSum for Mult
	mul	dword [dNine]
	mov	dword [rSum], eax		; store result into rSum
	;mov	dword [rSum + 4], edx
	add	eax, dword [digit]		; add digit to running sum
	mov	dword [rSum], eax		; store answer into running sum

	inc	r10
	jmp	multLoop

     outLoop:
	mov	eax, dword [rSum]
	mov	rdx, rax			; pass  speed value back by refrence
	mov	dword [r15], eax

	cmp	rax, SPD_MIN			; if value is less than min jmp err
	jl	SpdValueErr
	cmp	rax, SPD_MAX			; if value is greater than max jmp err
	jg	SpdValueErr

;-------------Check Color Specifier-------
	mov	rbx, qword [rsi + 24] 
	cmp	dword [rbx], 0x006c632d		; if rsi+24 
	jne	ClrSpecErr

;-------------Check Color Value------------

	mov	rbx, qword [rsi + 32]
	mov	r10, 0

     checkTwo:
	mov	al, byte [rbx + r10]
	cmp	al, NULL
	je	checkTwoDone
	cmp	al, "0"
	jb	ClrValueErr
	cmp	al, "8"
	ja	ClrValueErr
	inc 	r10
	jmp	checkTwo

     checkTwoDone:	
	mov	r10, 0
	mov	r11, 0
	mov	dword [digit], 0
	mov	dword [rSum], 0
	mov	rax, 0

     multLoopTwo:
	mov	al, byte [rbx + r10]
	cmp	al, NULL
	je	outLoopTwo

	sub	al, 48
	movsx	r11d, al
	mov	dword [digit], r11d		;store digit into var
	mov	eax, dword [rSum]		;move rSum for Mult
	mul	dword [dNine]
	mov	dword [rSum], eax		; store result into rSum
	mov	dword [rSum + 4], edx
	add	eax, dword [digit]		; add digit to running sum
	mov	dword [rSum], eax		; store answer into running sum

	inc	r10
	jmp	multLoopTwo

     outLoopTwo:
	mov	eax, dword [rSum]
	mov	rcx, rax			; pass  color value back by refrence
	mov	dword [r12], eax

	cmp	rax, CLR_MIN			; if value is less than min jmp err
	jl	ClrValueErr
	cmp	rax, CLR_MAX			; if value is greater than max jmp err
	jg	ClrValueErr

;---------Check Speed Specifier----------------------
	mov	rbx, qword [rsi + 40] 
	cmp	dword [rbx], 0x007a732d		; if rsi+40  !== -sz, give err
	jne	SizSpecErr

;--------Check Size Value---------------------------

	mov	rbx, qword [rsi + 48]
	mov	r10, 0

     checkThree:
	mov	al, byte [rbx + r10]
	cmp	al, NULL
	je	checkThreeDone
	cmp	al, "0"
	jb	SizValueErr
	cmp	al, "8"
	ja	SizValueErr
	inc 	r10
	jmp	checkThree

     checkThreeDone:	
	mov	r10, 0
	mov	r11, 0
	mov	dword [digit], 0
	mov	dword [rSum], 0
	mov	rax, 0

     multLoopThree:
	mov	al, byte [rbx + r10]
	cmp	al, NULL
	je	outLoopThree

	sub	al, 48
	movsx	r11d, al
	mov	dword [digit], r11d		;store digit into var
	mov	eax, dword [rSum]		;move rSum for Mult
	mul	dword [dNine]
	mov	dword [rSum], eax		; store result into rSum
	mov	dword [rSum + 4], edx
	add	eax, dword [digit]		; add digit to running sum
	mov	dword [rSum], eax		; store answer into running sum

	inc	r10
	jmp	multLoopThree

     outLoopThree:
	mov	eax, dword [rSum]
	mov	dword[r8], eax			; pass  speed value back by refrence

	cmp	rax, SIZ_MIN			; if value is less than min jmp err
	jl	SizValueErr
	cmp	rax, SIZ_MAX			; if value is greater than max jmp err
	jg	SizValueErr
	
	mov	rax, TRUE
	jmp	exit

;-----Errors-----------------

     usageErr:
	mov	rdi, errUsage
	call 	printString
	mov	rax, FALSE
	jmp	exit

     badCL:
	mov	rdi, errBadCL
	call	printString
	mov	rax, FALSE
	jmp	exit

     SpdSpecerr:
	mov	rdi, errSpdSpec
	call	printString
	mov	rax, FALSE
	jmp	exit

     SpdValueErr:
	mov	rdi, errSpdValue
	call	printString
	mov	rax, FALSE
	jmp	exit

     ClrSpecErr:
	mov	rdi, errClrSpec
	call	printString
	mov	rax, FALSE
	jmp	exit

     ClrValueErr:
	mov	rdi, errClrValue
	call	printString
	mov	rax, FALSE
	jmp	exit

     SizSpecErr:
	mov	rdi, errSizSpec
	call	printString
	mov	rax, FALSE
	jmp	exit

     SizValueErr:
	mov	rdi, errSizSpec
	call	printString
	mov	rax, FALSE
	jmp	exit
     

;-------Done---------------

	exit:

	pop	r15
	pop	r14
	pop	r13
	pop	r12
	pop	r10
	pop	rbx
	ret


; ******************************************************************
;  Draw wheels function.
;	Plot the provided functions:

; -----
;  Gloabl variables Accessed:

common	speed		1:4			; draw speed, dword, integer value
common	color		1:4			; draw color, dword, integer value
common	size		1:4			; screen size, dword, integer value

global drawWheels
drawWheels:

	push	r12
	push	r13
	push	r14

;-------USED REGISTERS

	; xmm14 = xmm14 = cos(t)
	; xmm15 = sin(t)
	; xmm8 = 2cos(2*pi*s)/3
	; xmm9 = 2sin(2*pi*s)/3
	; xmm7 = 2pi/3
	; xmm12 = 2pi


;------------2pi-----------------------------------
	movsd 	xmm12, qword[pi]
	mulsd 	xmm12, qword[fltTwo]	;xmm12 = 2pi
	movsd	qword[twoPi], xmm12

;------------ 6pi------------------------------------------------------
	movsd	xmm10, qword[pi]			; put pi in xmm10
	mulsd	xmm10, qword[fltSix]			; multiply pi by 6
	movsd	qword[sixPi], xmm10			; store 6pi in var
;------------------------------------------------------------------------

	movsd	xmm10, qword[twoPi]
	mulsd	xmm10, qword[s]				; 2pi * s
	movsd	xmm0, xmm10				; store (2pi*s) in xmm0 for function call
	call	cos					; = cos(2*pi*s)
	mulsd	xmm0, qword [fltTwo]			; = 2cos(2*pi*s)
	divsd	xmm0, qword [fltThree]			; = 2cos(2*pi*s)/3
	movsd	qword [twoCos], xmm0

	movsd	xmm4,qword[fltTwo]
	mulsd	xmm4,qword[pi]	;2*pi
	mulsd 	xmm4,qword[s]	;2*pi*s
	movsd	qword[twoPiS], xmm4

	movsd	xmm0,qword[fltTwoPiS]
 	mulsd	xmm0,qword[fltTwo]
	movsd	qword[fourPiS], xmm0

	movsd	xmm11, qword[twoPi]
	mulsd	xmm11, qword[s]				; 2pi * s
	movsd	xmm0, xmm11				; store (2pi*s) in xmm0 for function call
	call	sin					; = sin(2*pi*s)
	mulsd	xmm0, qword [fltTwo]			; = 2sin(2*pi*s)
	divsd	xmm0, qword [fltThree]			; = 2sin(2*pi*s)/3
	movsd	qword [twoSin], xmm0


; -----
;  Set draw speed step
;	sStep = speed / scale

;	YOUR CODE GOES HERE

	mov	r12, 0
	mov	r12d, dword [speed]			;set r12 to speed val

	cvtsi2sd xmm3, r12				; convert speed in to float

	divsd	xmm3, qword[scale]			; = speed/scale
	movsd	qword[sStep], xmm3			; sStep = speed/scale

; -----
;  Prepare for drawing
	; glClear(GL_COLOR_BUFFER_BIT);
	mov	rdi, GL_COLOR_BUFFER_BIT
	call	glClear

	; glBegin();
	mov	rdi, GL_POINTS
	call	glBegin

; -----
;  Set draw color(r,g,b)
;	uses glColor3ub(r,g,b)

;	YOUR CODE GOES HERE

 	mov	eax, dword[color]
  	mov	byte[blue], al
  	shr	eax, 8
  	mov	byte[green], al
  	shr	eax, 8
  	mov	byte[red], al
	shr	eax, 16

  	mov	edi, dword[red]
  	mov	esi, dword[green]
 	mov	edx, dword[blue]
 	call	glColor3ub

; -----
;  main plot loop
;	iterate t from 0.0 to 2*pi by tStep
;	uses glVertex2d(x,y) for each formula


;	YOUR CODE GOES HERE

	;movsd	xmm0, qword[fltZero]
	;movsd	qword[t], xmm0		; set t to 0

     ;trigLoop:
	;movsd	xmm6, qword[t]
	;ucomisd	xmm6, qword[twoPi]		; compare t to 2pi if t >= 2pi
	;ja	trigDone
	
	movsd	xmm0, qword[fltZero]
	movsd	qword[t], xmm0		; set t to 0

     formula1:
	movsd	xmm6, qword[t]
	ucomisd	xmm6, qword[twoPi]		; compare t to 2pi if t >= 2pi
	jae	formula1Done

;------------COS-----------------------------------

	movsd	xmm0, qword[t]
	call	cos
	movsd	qword [x], xmm0		;cos(t)
	movsd	qword[cosT], xmm0	; store cos(t) into var
	movsd	xmm14, xmm0		;xmm14 = cos(t) ***********************

;------------SIN------------------------------------

	movsd	xmm0, qword[t]
	call	sin
	movsd	qword[y], xmm0		; sin(t)
	movsd	qword[sinT], xmm0	; store sin(t) into var
	movsd	xmm15, xmm0		; xmm15 = sin(t) ***********************

	movsd	xmm0, qword[x]
	movsd	xmm1, qword[y]
	call 	glVertex2d

	movsd	xmm1, qword [t]
	addsd	xmm1, qword[tStep]
	movsd	qword[t], xmm1
	jmp	formula1

     formula1Done:

	movsd	xmm0, qword[fltZero]
	movsd	qword[t], xmm0		; set t to 0

     formula2:
	movsd	xmm6, qword[t]
	ucomisd	xmm6, qword[twoPi]		; compare t to 2pi if t >= 2pi
	jae	formula2Done


;-------------X = cost(t)/3 + 2*cos(2*pi*s)/3 -------------------------
	movsd	xmm10, qword [fltZero]			; clear xmm10
	
	movsd	xmm10, qword[t]				; store cos(t) in xmm10
	movsd	xmm0, xmm10
	call	cos
	movsd	xmm10, xmm0
	divsd	xmm10, qword [fltThree]			; cos(t)/3.0
	movsd	qword [fltTmp1], xmm10			; store result into tmp float var

	movsd	xmm10, qword[twoPi]
	mulsd	xmm10, qword[s]				; 2pi * s
	movsd	xmm0, xmm10				; store (2pi*s) in xmm0 for function call
	call	cos					; = cos(2*pi*s)
	mulsd	xmm0, qword [fltTwo]			; = 2cos(2*pi*s)
	divsd	xmm0, qword [fltThree]			; = 2cos(2*pi*s)/3
	;movsd	qword [twoCos], xmm0
	movsd	xmm8, xmm0				; xmm8 = 2cos(2*pi*s)/3 **************

	addsd	xmm0, qword [fltTmp1]			; xmm0 = cost(t)/3 + 2*cos(2*pi*s)/3
	movsd	qword[x], xmm0				; store result in x

;-------------Y = sin(t)/3 + 2*sin(2*pi*s)/3 -------------------------
	
	movsd	xmm11, qword[t]
	movsd	xmm0, xmm11
	call	sin
	movsd	xmm11, xmm0
	divsd	xmm11, qword [fltThree]			; sin(t)/3.0
	movsd	qword [fltTmp2], xmm11			; store result into tmp float var

	movsd	xmm11, qword[twoPi]
	mulsd	xmm11, qword[s]				; 2pi * s
	movsd	xmm0, xmm11				; store (2pi*s) in xmm0 for function call
	call	sin					; = sin(2*pi*s)
	mulsd	xmm0, qword [fltTwo]			; = 2sin(2*pi*s)
	divsd	xmm0, qword [fltThree]			; = 2sin(2*pi*s)/3
	;movsd	qword [twoSin], xmm0
	movsd	xmm9, xmm0				; xmm9 = 2sin(2*pi*s)/3 **************

	addsd	xmm0, qword [fltTmp2]			; xmm0 = sin(t)/3 + 2*sin(2*pi*s)/3
	movsd	qword[y], xmm0				; store result in y

	movsd	xmm0, qword[x]
	movsd	xmm1, qword[y]
	call 	glVertex2d

	movsd	xmm1, qword [t]
	addsd	xmm1, qword[tStep]
	movsd	qword[t], xmm1
	jmp	formula2

     formula2Done:

	movsd	xmm0, qword[fltZero]
	movsd	qword[t], xmm0		; set t to 0

     formula3:
	movsd	xmm6, qword[t]
	ucomisd	xmm6, qword[twoPi]		; compare t to 2pi if t >= 2pi
	jae	formula3Done

;------------ X = 2cos(2Pi*s)/3 + t*cos(4Pi*s) / 6Pi------------------
	movsd	xmm10, qword [fltZero]			; clear xmm10 

	movsd	xmm0, qword[twoPiS]
	call	cos			
	mulsd	xmm0,qword[fltTwo]
	divsd	xmm0,qword[fltThree] 	
	movsd	qword[fltTmp1],xmm0

	movsd	xmm0,qword[twoPiS] 		
 	mulsd	xmm0,qword[fltTwo]
	movsd	qword[fourPiS], xmm0
	movsd	xmm0,qword[fourPiS]
	call	cos
 	mulsd	xmm0, qword[t]
	divsd	xmm0,qword[sixPi]
	movsd	qword[fltTmp2], xmm0

	movsd	xmm1,qword[fltTmp1]
	addsd	xmm1,qword[fltTmp2]
	movsd	qword[x],xmm1 

;------------ Y = 2sin(2Pi*s)/3 + t*sin(4Pi*s) / 6Pi------------------
	movsd	xmm10, qword [fltZero]			; clear xmm10 

	movsd	xmm0,qword[twoPiS]
	call	sin		
	mulsd	xmm0,qword[fltTwo]
	divsd	xmm0,qword[fltThree]
	movsd	qword[fltTmp1], xmm0

	movsd	xmm0,qword[fourPiS]
	call	sin
 	mulsd	xmm0, qword[t]
	divsd	xmm0,qword[sixPi]

	movsd	qword[fltTmp2], xmm0

	movsd	xmm1,qword[fltTmp1]
	subsd	xmm1,qword[fltTmp2]
	movsd	qword[y],xmm1


	movsd	xmm0, qword[x]
	movsd	xmm1, qword[y]
	call 	glVertex2d

	movsd	xmm1, qword [t]
	addsd	xmm1, qword[tStep]
	movsd	qword[t], xmm1
	jmp	formula3

     formula3Done:

	movsd	xmm0, qword[fltZero]
	movsd	qword[t], xmm0		; set t to 0

     formula4:
	movsd	xmm6, qword[t]
	ucomisd	xmm6, qword[twoPi]		; compare t to 2pi if t >= 2pi
	jae	formula4Done

;------------ X = 2cos(2Pi*s)/3 + t*cos(4Pi*s + 2Pi/3) / 6Pi ------------------

	movsd	xmm10, qword [fltZero]			; clear xmm10 

	movsd	xmm10, qword[pi]			; xmm10 = pi
	mulsd	xmm10, qword[fltFour]			; = 4pi
	mulsd	xmm10, qword[s]				; = 4pi*s

	movsd	xmm7, qword[twoPi]			; store 2pi in xmm7 for div
	divsd	xmm7, qword[fltThree]			; = 2Pi/3

	addsd	xmm10, xmm7				; = 4pi*s + 2Pi/3

	movsd	xmm0, xmm10				; move to xmm0 for function call
	call	cos					; = cos(4pi*s + 2Pi/3)
	movsd	xmm10, xmm0				; place result back into xmm10
	mulsd	xmm10, qword[t]				; = t*cos(4pi*s + 2Pi/3)
	divsd	xmm10, qword[sixPi]			; = t*cos(4pi*s + 2Pi/3)/6pi

	addsd	xmm10, qword[twoCos]				; = t*cos(4pi*s + 2Pi/3)/6pi + 2cos(2*pi*s)/3
	movsd	qword[x], xmm10				; store result in x

;------------ Y = 2sin(2Pi*s)/3 - t*sin(4Pi*s + 2Pi/3) / 6Pi ------------------

	movsd	xmm10, qword [fltZero]			; clear xmm10 

	movsd	xmm10, qword[pi]			; xmm10 = pi
	mulsd	xmm10, qword[fltFour]			; = 4pi
	mulsd	xmm10, qword[s]				; = 4pi*s

	movsd	xmm7, qword[twoPi]			; store 2pi in xmm7 for div
	divsd	xmm7, qword[fltThree]			; = 2Pi/3

	addsd	xmm10, xmm7				; = 4pi*s + 2Pi/3

	movsd	xmm0, xmm10				; move to xmm0 for function call
	call	sin					; = sin(4pi*s + 2Pi/3)
	movsd	xmm10, xmm0				; place result back into xmm10
	mulsd	xmm10, qword[t]				; = t*sin(4pi*s + 2Pi/3)
	divsd	xmm10, qword[sixPi]			; = t*sin(4pi*s + 2Pi/3)/6pi
	
	movsd	xmm4, qword[twoSin]			; move 2sin(2Pi*s)/3 to xmm4
	subsd	xmm4, xmm10				; = 2sin(2Pi*s)/3 - t*sin(4Pi*s) / 6Pi
	movsd	qword[y], xmm4				; store result in y

	movsd	xmm0, qword[x]
	movsd	xmm1, qword[y]
	call 	glVertex2d

	movsd	xmm1, qword [t]
	addsd	xmm1, qword[tStep]
	movsd	qword[t], xmm1
	jmp	formula4

     formula4Done:

	movsd	xmm0, qword[fltZero]
	movsd	qword[t], xmm0		; set t to 0

     formula5:
	movsd	xmm6, qword[t]
	ucomisd	xmm6, qword[twoPi]		; compare t to 2pi if t >= 2pi
	jae	formula5Done


;------------ X = 2cos(2Pi*s)/3 + t*cos(4Pi*s - 2Pi/3) / 6Pi ------------------

	movsd	xmm10, qword [fltZero]			; clear xmm10 

	movsd	xmm10, qword[pi]			; xmm10 = pi
	mulsd	xmm10, qword[fltFour]			; = 4pi
	mulsd	xmm10, qword[s]				; = 4pi*s

	movsd	xmm7, qword[twoPi]			; store 2pi in xmm7 for div
	divsd	xmm7, qword[fltThree]			; = 2Pi/3

	subsd	xmm10, xmm7				; = 4pi*s - 2Pi/3

	movsd	xmm0, xmm10				; move to xmm0 for function call
	call	cos					; = cos(4pi*s + 2Pi/3)
	movsd	xmm10, xmm0				; place result back into xmm10
	mulsd	xmm10, qword[t]				; = t*cos(4pi*s + 2Pi/3)
	divsd	xmm10, qword[sixPi]			; = t*cos(4pi*s + 2Pi/3)/6pi

	addsd	xmm10, qword[twoCos]			; = t*cos(4pi*s - 2Pi/3)/6pi + 2cos(2*pi*s)/3
	movsd	qword[x], xmm10				; store result in x

;------------ Y = 2sin(2Pi*s)/3 - t*sin(4Pi*s + 2Pi/3) / 6Pi ------------------

	movsd	xmm10, qword [fltZero]			; clear xmm10 

	movsd	xmm10, qword[pi]			; xmm10 = pi
	mulsd	xmm10, qword[fltFour]			; = 4pi
	mulsd	xmm10, qword[s]				; = 4pi*s

	movsd	xmm7, qword[twoPi]			; store 2pi in xmm7 for div
	divsd	xmm7, qword[fltThree]			; = 2Pi/3

	subsd	xmm10, xmm7				; = 4pi*s + 2Pi/3

	movsd	xmm0, xmm10				; move to xmm0 for function call
	call	sin					; = sin(4pi*s + 2Pi/3)
	movsd	xmm10, xmm0				; place result back into xmm10
	mulsd	xmm10, qword[t]				; = t*sin(4pi*s + 2Pi/3)
	divsd	xmm10, qword[sixPi]			; = t*sin(4pi*s + 2Pi/3)/6pi

	movsd	xmm4, qword[twoSin]			; = 2sin(2Pi*s)
	subsd	xmm4, xmm10				; = 2sin(2Pi*s)/3 - t*sin(4Pi*s-2Pi/3)/6Pi
	movsd	qword[y], xmm4				; store result in y

	movsd	xmm0, qword[x]
	movsd	xmm1, qword[y]
	call 	glVertex2d

	movsd	xmm1, qword [t]
	addsd	xmm1, qword[tStep]
	movsd	qword[t], xmm1
	jmp	formula5

     formula5Done:

;------ increment t

	;movsd	xmm1, qword [t]
	;addsd	xmm1, qword[tStep]
	;movsd	qword[t], xmm1

	;jmp	trigLoop
	
     ;trigDone:


; -----
;  Display image

	call	glEnd
	call	glFlush

; -----
;  Update s, s += sStep;
;  if (s > 1.0)
;	s = 0.0;

	movsd	xmm0, qword [s]			; s+= sStep
	addsd	xmm0, qword [sStep]
	movsd	qword [s], xmm0

	movsd	xmm0, qword [s]
	movsd	xmm1, qword [fltOne]
	ucomisd	xmm0, xmm1			; if (s > 1.0)
	jbe	resetDone

	movsd	xmm0, qword [fltZero]
	movsd	qword [sStep], xmm0
resetDone:

	call	glutPostRedisplay

; -----
;	YOUR CODE GOES HERE (restore registers)

	pop	r14
	pop	r13
	pop	r12

	ret

; ******************************************************************
;  Generic procedure to display a string to the screen.
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
	push	rbp
	mov	rbp, rsp
	push	rbx
	push	rsi
	push	rdi
	push	rdx

; -----
;  Count characters in string.

	mov	rbx, rdi			; str addr
	mov	rdx, 0
strCountLoop:
	cmp	byte [rbx], NULL
	je	strCountDone
	inc	rbx
	inc	rdx
	jmp	strCountLoop
strCountDone:

	cmp	rdx, 0
	je	prtDone

; -----
;  Call OS to output string.

	mov	rax, SYS_write			; system code for write()
	mov	rsi, rdi			; address of characters to write
	mov	rdi, STDOUT			; file descriptor for standard in
						; EDX=count to write, set above
	syscall					; system call

; -----
;  String printed, return to calling routine.

prtDone:
	pop	rdx
	pop	rdi
	pop	rsi
	pop	rbx
	pop	rbp
	ret

; ******************************************************************


