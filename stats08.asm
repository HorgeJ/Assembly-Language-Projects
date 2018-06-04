;  Jorge Sagastume
;  Section 1001
;  CS 218 - Assignment 8
;  Functions Template.

; --------------------------------------------------------------------
;  Write some assembly language functions.

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
;  Define constants.

TRUE		equ	1
FALSE		equ	0

; -----
;  Local variables for combSort() function.

	swapped		db	TRUE
	dTen		dd	10
	dTwelve		dd	12
	dThree		dd	3
	dFour		dd	4
	dTwo		dd	2
	gap		dd	0
	kurt		dq	0



; -----
;  Local variables for lstStats() function (if any).



section	.bss

; -----
;  Unitialized variables (if any).



; ********************************************************************************

section	.text

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


;	YOUR CODE GOES HERE

	push	r12


	mov	eax, esi 		; gap length in esi
	mov	byte [swapped], TRUE		; set swap to TRUE

;-----Outer Loop---------------------
     outerLoop:
	cmp	eax, 1
	jg	getGap
	cmp	byte [swapped], TRUE
	je	getGap				; cmp swapped to FALSE
	jmp	outerLoopDone			; if FALSE outer loop is done

     getGap:
	imul	dword [dTen]			; (gap * 10)
	cdq					; convert double to quad for idiv
	idiv	dword [dTwelve]			; (gap * 10) / 12
	mov	dword [gap], eax		; store result into gap variable
	mov	r9d, dword [gap]		; store gap into r9

	cmp	dword [gap], 1			; cmp 1 to gap
	ja	dontSet				; if gap > 1 skip gap setting
	mov	dword [gap], 1			; else set gap to 1

     dontSet:
	mov	r12, 0				; set index
	mov	byte [swapped], FALSE		; set swapped bool to false

;----------Inner Loop-------------------
     innerLoop
	mov	r8, r12				; move index to r8
	add	r8d, r9d			; add gap to i (gap + i)
	mov	eax, r8d			; move (i + gap) into eax
	imul	dword [dFour]			; imul by dWord size
	movsxd	r13, eax			; rdi = (i + gap)	
	
	cmp	r8d,  esi			; if (i + gap) >= length
	jae	innerLoopDone			; end inner loop
						; else begin swap compare
	mov	eax, dword [rdi + r12 * 4]	; take array [i]
	mov	ebx, dword [rdi + r13]		; take array [i + gap]	
	
	cmp	eax, ebx			; if eax <= ebx
	jge	swapDone			; leave as is, else swap points

	mov	dword [rdi + r12 * 4], ebx	; swap ebx into old eax position
	mov	dword [rdi + r13], eax		; swap eax into old ebx position
	mov	byte [swapped], TRUE		; change swapped bool to TRUE

     swapDone:					; swap completed
	inc 	r12				; inc i
	jmp	innerLoop			; jmp back to inner loop	

     innerLoopDone:
	mov	eax, r9d			; preserve gap			
	inc 	r12				; inc i
	jmp	outerLoop			; jmp back to outerloop

     outerLoopDone:

	pop	r12
	ret


; --------------------------------------------------------
;  Find statistical information for a list of integers:
;	sum, average, minimum, maximum, and, median

;  Note, for an odd number of items, the median value is defined as
;  the middle value.  For an even number of values, it is the integer
;  average of the two middle values.

;  This function must call the lstSum(), lstMedian(), and
;  lstAvergae() functions.

;  Note, assumes the list is already sorted.

; -----
;  Call:
;	call lstStats(list, len, sum, ave, min, max, med)

;  Arguments Passed:
;	1) list, addr - rdi
;	2) length, value - rsi
;	3) sum, addr - rdx
;	4) average, addr - rcx
;	5) minimum, addr - r8
;	6) maximum, addr - r9
;	7) median, addr - stack, rbp+16

;  Returns:
;	sum, average, minimum, maximum, and median
;		via pass-by-reference

global lstStats
lstStats:


;	YOUR CODE GOES HERE
	
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


;	YOUR CODE GOES HERE

	push	r12

	mov	rax, rsi
	mov	rdx, 0
	div	dword [dTwo]

	mov	r10, rax

	cmp	rdx, 0
	je	evenLength

	mov	r12d, dword [rdi + r10 * 4]
	mov	eax, r12d
	jmp 	medDone

     evenLength:
	mov	r12d, dword [rdi + r10 * 4]
	dec	r10
	mov	r11d, dword [rdi + r10 * 4]
	
	add	r12d, r11d
	mov	eax, r12d
	cdq	
	idiv	dword [dTwo]
	

     medDone:
	pop	r12
	ret



; --------------------------------------------------------
;  Function to calculate the median of a sorted list.

; -----
;  Call:
;	ans = lstEstMedian(lst, len)

;  Arguments Passed:
;	1) list, address - rdi
;	1) length, value - rsi

;  Returns:
;	sum (in eax)

global	lstEstMedian
lstEstMedian:


;	YOUR CODE GOES HERE

	push	r12

	mov	eax, esi
	mov	edx, 0
	div	dword [dTwo]
	mov	r11, 0
	mov	r11d, eax

	mov	eax, dword [rdi]

	mov	r10, 0
	mov	r10d, esi
	sub	r10, 1

	add	eax, dword [rdi + r10 * 4]
	add 	eax, dword [rdi + r11 * 4]

	cmp	rdx, 1
	je	oddMedian
	dec 	r11
	add 	eax, dword [rdi + r11 * 4]
	cdq
	idiv	dword [dFour]
	jmp	done

     oddMedian:
	cdq
	idiv	dword [dThree] 

      done:


	pop	r12
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


;	YOUR CODE GOES HERE

	push 	r12
	mov	r12, 0		; counter/index
	mov	rax, 0		; running sum

     sumLoop:
	add	eax, dword [rdi + r12 * 4]	; sum += arr[i]
	inc	r12				; counter++
	cmp	r12, rsi			; compare counter to length
	jl	sumLoop


	pop r12
	ret

	
	



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


;	YOUR CODE GOES HERE



	call	lstSum

	mov	edx, 0	
	div	esi
	


	ret



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


;	YOUR CODE GOES HERE

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
	
	mov	qword[kurt], rax
	mov	qword[kurt + 8], rdx
	add	r13, qword [kurt]

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
	ret





; ********************************************************************************


