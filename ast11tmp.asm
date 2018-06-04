

;  CS 218 - Assignment #11
;  Functions Template

; ***********************************************************************
;  Data declarations
;	Note, the error message strings should NOT be changed.
;	All other variables may changed or ignored...

section	.data

; -----
;  Define standard constants.

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
SYS_lseek	equ	8			; system call code for file repositioning
SYS_fork	equ	57			; system call code for fork
SYS_exit	equ	60			; system call code for terminate
SYS_creat	equ	85			; system call code for file open/create
SYS_time	equ	201			; system call code for get time

LF		equ	10
SPACE		equ	" "
NULL		equ	0
ESC		equ	27

O_CREAT		equ	0x40
O_TRUNC		equ	0x200
O_APPEND	equ	0x400

O_RDONLY	equ	000000q			; file permission - read only
O_WRONLY	equ	000001q			; file permission - write only
O_RDWR		equ	000002q			; file permission - read and write

S_IRUSR		equ	00400q
S_IWUSR		equ	00200q
S_IXUSR		equ	00100q

; -----
;  Define program specific constants.

KEY_MAX		equ	56
KEY_MIN		equ	16

BUFF_SIZE	equ	800000			; buffer size

; -----
;  Variables for getOptions() function.

eof		db	FALSE

usageMsg	db	"Usage: blowfish <-en|-de> -if <inputFile> "
		db	"-of <outputFile>", LF, NULL
errIncomplete	db	"Error, command line arguments incomplete."
		db	LF, NULL
errExtra	db	"Error, too many command line arguments."
		db	LF, NULL
errFlag		db	"Error, encryption/decryption flag not "
		db	"valid.", LF, NULL
errReadSpec	db	"Error, invalid read file specifier.", LF, NULL
errWriteSpec	db	"Error, invalid write file specifier.", LF, NULL
errReadFile	db	"Error, opening input file.", LF, NULL
errWriteFile	db	"Error, opening output file.", LF, NULL

; -----
;  Variables for getX() function.

buffMax		dq	BUFF_SIZE
curr		dq	BUFF_SIZE
wasEOF		db	FALSE

errRead		db	"Error, reading from file.", LF,
		db	"Program terminated.", LF, NULL

; -----
;  Variables for writeX() function.

errWrite	db	"Error, writting to file.", LF,
		db	"Program terminated.", LF, NULL

; -----
;  Variables for readKey() function.

chr		db	0

keyPrompt	db	"Enter Key (16-56 characters): ", NULL
keyError	db	"Error, invalid key size.  Key must be between 16 and "
		db	"56 characters long.", LF, NULL

;--------MY VARS------------------------------

fileNameIn		db	0
fileNameOut		db	0
fileDescriptorIn	dq	0
fileDescriptorOut	dq	0

strLen			equ	KEY_MAX

; ------------------------------------------------------------------------
;  Unitialized data

section	.bss

buffer			resb	BUFF_SIZE

inChr			resb	1
inLine			resb	strLen+2


; ############################################################################

section	.text

; ***************************************************************
;  Routine to get arguments (encryption flag, input file
;	name, and output file name) from the command line.
;	Verify files by atemptting to open the files (to make
;	sure they are valid and available).

;  Command Line format:
;	./blowfish <-en|-de> -if <inputFileName> -of <outputFileName>

; -----
;  Arguments:
;	argc (value)
;	address of argv table
;	address of encryption/decryption flag (byte) true for encryption false for dec
;	address of read file descriptor (qword)
;	address of write file descriptor (qword)
;  Returns:
;	TRUE or FALSE
	
global getOptions
getOptions:

	push	rbx
	push	r12
	push	r13
	push	r14
	push	r15
	
	mov	r12, rdi		;argc
	mov	r13, rsi		;argv
	mov	r14, rdx		;encryptFlag
	mov	r15, rcx		;readFile
	mov	r11, r8			;writeFile

;------Check Usage----------

	cmp	rdi, 1					; if no arguments, give usage err
	je	usageErr

;------Check # Args---------

	cmp	rdi, 6					; if incorrect ammount of args, give err
	jb	badCL

	cmp	rdi, 6
	ja	tooManyArgs

;-----Check '-en' or '-de-------------

	mov	rbx, qword [rsi + 8]			; access second command line arg
	cmp	dword [rbx], 0x006e652d			; if == "-en"
	je	needsEncryption				; set encrytpion flag to true

	cmp	dword [rbx], 0x0065642d			; if == "-de"
	je	needsDecryption				; set encryption flag to false

	jmp	flagErr					; if not any, return err

     needsEncryption:
	mov	byte [r14], TRUE			; return true encryption flag
	jmp	next

     needsDecryption:
	mov	byte [r14], FALSE			; return false encryption flag
	jmp	next

     next:

;-----Check '-if'-------------------

	mov	rbx, qword [rsi + 16]			; check "if"
	cmp	dword [rbx], 0x0066692d			; 
	jne	inputFileErr				; if != "-if" return err

;------Get Input File Name------------------

	mov	rbx, qword [rsi + 24]			; acces input file name
	mov	byte[fileNameIn], bl

	push	rdi
	push	rsi

	mov	rax, SYS_open				; system call for file open
	mov	rdi, rbx				; file name string (NULL terminated)
	mov	rsi, O_RDONLY				; read only access
	syscall						; call the kernel

	pop 	rsi
	pop	rdi	

	cmp	rax, 0					; check for successful open > 0
	jl	errorOnOpen				; if < 0 give err
	
	mov	qword[fileDescriptorIn], rax		; store file descriptor
	mov	qword[r15], rax 			; return input file descriptor

;------Check '-of'---------------------
	
	mov	rbx, qword [rsi + 32]			; access -of specifier
	cmp	dword [rbx], 0x00666f2d			; if != "-of" return err
	jne	ofSpecifierErr

;------Get output File Name------------------

	mov	rbx, qword [rsi + 40]			; access output file name
	mov	byte[fileNameOut], bl

	push	rdi
	push	rsi

	mov	rax, SYS_creat				; system call for file open
	mov	rdi, rbx				; file name string (NULL terminated)
	mov	rsi, S_IRUSR | S_IWUSR			; allow read/write access
	syscall						; call the kernel

	pop 	rsi
	pop	rdi	

	cmp	rax, 0					; check for successful open
	jl	writeFileErr				; if < 0 give err
	
	mov	qword[fileDescriptorOut], rax		; store file descriptor
	mov	qword [r8], rax				; return output file descriptor

	mov	rax, TRUE
	jmp	exit

;-----Errors------------------------

     usageErr:
	mov	rdi, usageMsg
	call 	printString
	mov	rax, FALSE
	jmp	exit

     badCL:
	mov	rdi, errIncomplete
	call	printString
	mov	rax, FALSE
	jmp	exit

     tooManyArgs:
	mov	rdi, errExtra
	call	printString
	mov	rax, FALSE
	jmp	exit

     flagErr:
	mov	rdi, errFlag
	call	printString
	mov	rax, FALSE
	jmp	exit

     inputFileErr:
	mov	rdi, errReadSpec
	call	printString
	mov	rax, FALSE
	jmp	exit

     ofSpecifierErr:
	mov	rdi, errWriteSpec
	call	printString
	mov	rax, FALSE
	jmp	exit

     errorOnOpen:
	mov	rdi, errReadFile
	call	printString
	mov	rax, FALSE
	jmp	exit

     writeFileErr:
	mov	rdi, errWriteFile
	call	printString
	mov	rax, FALSE
	jmp	exit


;-------Done---------------

	exit:

	pop	r15
	pop	r14
	pop	r13
	pop	r12
	pop	rbx
	ret


; ***************************************************************
;  Return the X array, 8 characters, from read buffer.
;	This routine performs all buffer management.

; -----
;   Arguments:
;	value of read file descriptor
;	address of X array
;  Returns:
;	TRUE or FALSE

;     NOTE's:
;	- returns TRUE when X array has been filled
;	- if < 8 characters in buffer, NULL fill
;	- returns FALSE only when asked for 8 characters
;		but there are NO more at all (which occurs
;		only when ALL previous characters have already
;		been returned).

;  The read buffer itself and some misc. variables are used
;  ONLY by this routine and as such are not passed.

global getX
getX:

	push	rbx
	push	r12
	push	r13
	push	r14
	push	r15

	mov	r13, rdi		; save File Descriptor address
	mov	r12, rsi		; save address of xArr[]
	mov	r15, 0			; index to set x to 0

     setXtoZero:
	mov	byte [r12 + r15], 0
	inc	r15
	cmp	r15, 9
	jl	setXtoZero 
	

	mov	r14, 0			; set index to 0

    getNextChr:

	mov	rbx, qword [buffMax]	; if(curr > buffMAX) always true the first time
	cmp	qword[curr], rbx	; compare current with buffmax
	jb	fillX

	cmp	byte[wasEOF], TRUE	; if not EOF keep reading, else exit
	jne	notEOF			; of not == EOF keep reading 
	jmp	inputDone

     notEOF:
	mov	rax, SYS_read		; system call for file read
	mov	rdi, r13		; file descriptor
	mov	rsi, buffer		; address of where to place data
	mov	rdx, BUFF_SIZE		; count of characters to read
	syscall

	cmp	rax, 0			; If < 0
	jl	readErr			; exit with err and false

	cmp	rax, 0			; rax == acturalRead if(acturalRead < 0) empty file, exit
	je	inputDone		; exit w/ false

	cmp	rax, BUFF_SIZE		; if (actualRD < requestRD)
	jle	EOFfound
	jmp	stillNotEOF

     EOFfound:
	mov	byte[wasEOF], TRUE	; if actual read < requestRD wasEOF = TRUE
	mov	qword[buffMax], rax	; bfMax updated to actualRD

     stillNotEOF:
	mov	qword[curr], 0		; curr == 0

;-----------

     fillX:

	mov	r10, qword[curr]	; r10 = curr to use in buffer[curr]
	mov	r11b, byte[buffer+r10]	; r11b = buffer[curr]
	mov	byte [chr], r11b	; chr = buffer[curr]
	mov	byte[r12+r14], r11b
	inc 	r14			; i++
	inc	qword[curr]
	
	cmp	r14, 8
	jl	getNextChr

	mov	rax, TRUE
	jmp	exit2
	
	

;-----ERROR-----------------------------------
     readErr:
	mov	rdi, errRead
	call	printString
	mov	rax, FALSE
	jmp	exit2

;----------------------------------------------

    inputDone:
	mov	rax, FALSE
	jmp	exit2

     exit2:	

	pop	r15
	pop	r14
	pop	r13
	pop	r12
	pop	rbx
	ret

; ***************************************************************
;  Write X array (8 characters) to output file.
;	No requirement to buffer here.

;     NOTE:	for encryption write -> always write 8 characters
;		for decryption write -> exclude any trailing NULLS

;     NOTE:	this routine returns FALSE only if there is an
;		error on write (which would not normally occur).

; -----
;  Arguments are:
;	value of write file descriptor 	-----rdi----
;	address of X array		-----rsi----
;	value of encryption flag	-----rdx------
;  Returns:
;	TRUE or FALSE

global writeX
writeX:

	push	rbx
	push	r12
	push	r13
	push	r14

	mov	rbx, rdi		; Name of outputfile
	mov	r12, rsi		; address of X array
	mov	r13, rdx		; value of encryption flag

	mov	rax, SYS_write		; sys service for file write
	mov	rdi, rbx		; address of file descriptor for output file
	mov	rsi, r12		; address of characters to write
	mov	rdx, 8			; count of chars to write

	pop	r14
	pop	r13
	pop	r12
	pop	rbx
	ret

; ***************************************************************
;  Get a encryption/decryption key from user.
;	Key must be between MIN and MAX characters long.

;     NOTE:	must ensure there are no buffer overflow
;		if the user enters >MAX characters

; -----
;  Arguments:
;	address of the key buffer
;	value of key MIN length
;	value of key MAX length

global readKey
readKey:

	push	rbx
	push	r12
	push	r13

	mov	r13, rdi

	mov	rdi, keyPrompt		; output initial prompt message
	call	printString		; call print string function for prompt

;------Read input from user-----------
	
	mov	rbx, inLine		; inLine addr into rbx
	mov	r12, 0			; counter set to 0

     readChrs:
	mov	rax, SYS_read
	mov	rdi, STDIN
	lea	rsi, [inChr]		; address of character
	mov	rdx, 1			; count (how many to read)
	syscall				; syscall

	mov	al, byte [inChr]	; get chr just read
	cmp	al, LF			; if == LF
	je 	readDone		; read is done

	inc	r12			; else inc counter
	cmp	r12, strLen		; cmpr to max length
	jge	readChrs		; if => strLen stop placing in buffer

	mov	byte [rbx], al		; inLine[i] = chr [store in buffer]
	inc	rbx			; update tmpStr addr

	jmp	readChrs		; read next chr

     readDone:

	cmp	r12, KEY_MIN
	jl	keyErr
	cmp	r12, KEY_MAX + 1
	jg	keyErr

	;mov	rdi, inLine
	;call 	printString

	mov	eax, dword [inLine]

	mov	dword [r13], eax
	mov	rax, TRUE
	jmp	endKey

     keyErr:
	mov	rdi, keyError
	call	printString
	mov	rax, FALSE
	jmp	endKey

     endKey:
	pop	r13
	pop	r12
	pop	rbx
	ret

; ***************************************************************
;  Generic function to display a string to the screen.
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

; ***************************************************************


