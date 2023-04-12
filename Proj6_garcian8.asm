TITLE String Primitives and Macros  

; Author: Andrew Garcia
; Last Modified: 12/4/2022
; OSU email address: garcian8@oregonstate.edu
; Course number/section: 271   CS271 Section: 400
; Project Number: Project 6         Due Date: 12/4/2022
; Description: Program asked the user to enter 10 signed numbers. A macro is invoked
;			   to read the string of numbers from the user. That string of numbers is 
;			   then converted to a signed representation of that number. Basic calculations
;			   are performed and all the original numbers and results of the calculations
;			   are converted back to strings and displayed to the user.

INCLUDE Irvine32.inc

; --------------------------------------------------------------------------------- 
; Name: mGetString
; 
; Reads a user entered string and stores it.
; 
; Preconditions: None
; 
; Receives: 
; promptString = prompt to the user
; array1 = storage for user entered string
; arraySize = array length 
; 
; returns: array1 = a user entered string
; ---------------------------------------------------------------------------------

mGetString MACRO promptString, array1, arraySize
push	EDX
push	ECX
mov		EDX, promptString
call	WriteString
mov		EDX, array1
mov		ECX, arraySize
call	ReadString
pop		ECX
pop		EDX

ENDM

; --------------------------------------------------------------------------------- 
; Name: mDisplayString
; 
; Displays a string
; 
; Preconditions: None
; 
; Receives: 
; stringOffset = string address
; 
; returns: None
; ---------------------------------------------------------------------------------

mDisplayString MACRO stringOffset
push	EDX
mov		EDX,  stringOffset
call	WriteString
pop		EDX

ENDM

ARRAYSIZE	=	10

.data

intro1			BYTE	"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures",13,10
				BYTE	"Written by: Andrew Garcia.",0
instruct1		BYTE	"Please provide 10 signed decimal integers.",13,10
				BYTE	"Each number must be able to fit in a 32 bit register. Once you have",13,10
				BYTE	"entered all off your numbers, I will display a list of the integers the",13,10
				BYTE	"integers, their sum, and their average value.",13,10,0
prompt1			BYTE	"Please enter a signed number: ",0
error1			BYTE	"ERROR: You did not enter a signed number or your number was too big.",0
prompt2			BYTE	"Please try again: ",0
endPrompt1		BYTE	"You entered the following numbers:",0
sumString		BYTE	"The sum of these numbers is: ",0
trnAvgString	BYTE	"The truncated average is: ",0
exitString		BYTE	"Thank you so much for a playing my game! - Mario 1996",0
convertedNum	DWORD	1 DUP(?)
numArray		DWORD	10 DUP(?)
userString		BYTE	15 DUP(0)
commaAndSpace	BYTE	", ",0

.code
main PROC
	push	OFFSET intro1
	push	OFFSET instruct1
	call	introduction
	call	CrLf
	
	; Setup loop counter and initialize EDI to numArray offset
	mov		ECX, 10
	mov		EDI, OFFSET numArray

_someLoop:
	; Loop to get 10 user entered values
	push	ECX
	push	EDI							; ECX and EDI conserved
	push	OFFSET prompt1
	push	OFFSET prompt2
	push	OFFSET convertedNum
	push	OFFSET error1
	call	ReadVal
	mov		EAX, convertedNum
	pop		EDI
	pop		ECX							; ECX and EDI restored
	mov		[EDI], EAX
	add		EDI, 4
	LOOP	_someLoop
	call	CrLf


	push	OFFSET userString
	push	OFFSET numArray
	push	OFFSET endPrompt1
	push	OFFSET commaAndSpace
	call	DisplayNumList
	call	CrLf

	push	OFFSET userString
	push	OFFSET sumString
	push	OFFSET trnAvgString
	push	OFFSET numArray
	call	Calculations
	call	CrLf
	call	CrLf

	push	OFFSET exitString
	call	goodbye

	Invoke ExitProcess,0	; exit to operating system
main ENDP


; --------------------------------------------------------------------------------------------------------------------------
; Name: introduction
; Procedure introduces the program and programmer and explains the rules of the program.
; Preconditions: intro1 and instruct1 are strings passed by reference to the procedure introducing the program.
; Postconditions: EDX, EBP, and ESP are changed.
; Receives: offset of intro1 and instruct1
; Returns: None
; ---------------------------------------------------------------------------------------------------------------------------

introduction PROC
	push	EBP
	mov		EBP, ESP

	; Macro invoked to print out string
	mov		EDX, [EBP+12]
	mDisplayString EDX
	call	CrLf

	; Macro invoked to print out string
	call	CrLf
	mov		EDX, [EBP+8]
	mDisplayString EDX
	call	CrLf

	pop		EBP
	ret		8
introduction ENDP


; --------------------------------------------------------------------------------------------------------------------------
; Name: ReadVal
; Procedure asks the user to enter a signed integer. That signed integer is loaded character by character and each character
; is sent for validation by the validation procedure. Once validation is complete the user entered string will be stored in the
; variable offset of userStrin.
; Preconditions: prompt1 and prompt2 are strings passed by reference. userString is a BYTE string entered by the user, error1 
; is a string and count is a DWORD
; Postconditions: EDX, EBP, EDI, ECX, EBX, EAX, and ESI are changed.
; Receives: offset of prompt1, prompt2, error1, userString, and the value of count
; Returns: A string in userString
; --------------------------------------------------------------------------------------------------------------------------


ReadVal PROC
	; Local variable setup to have a memory location for user entered string values
	LOCAL	userString1[25]:BYTE 
	; Initializes EDI, EDX, and ECX
	mov		EDI, [EBP+12]				; convertedNum
	mov		EDX, [EBP+20]				; prompt1
	lea		ECX, userString1

	; Macro invoked to read user entered values
	mGetString EDX, ECX, LENGTHOF userString1

_loadByte:
	; stores string byte entered by user
	mov		ECX, EAX
	lea		EAX, userString1
	push	EAX
	push	ECX							
	push	EDI
	call	validation					; go validate that num entered is a num using ascii values	
	cmp		EBX, 1						; if 1 is returned, the number was invalid so jump to _invalidNum
	je		_invalidNum
	jmp		_finished2

_invalidNum:
	; For case where num entered was invalid
	dec		EBX							; resets EBX
	mov		EDX, [EBP+8]				; error string
	mDisplayString EDX					; macro invoked to dsisplay error string
	call	CrLf
	mov		EDX, [EBP+16]				; prompt2
	lea		ECX, userString1
	mGetString EDX, ECX, LENGTHOF userString1
	jmp		_loadByte					; user is re-prompted to enter a number and then jmp back to _loadByte
	

_finished2:
	ret		16
ReadVal ENDP


; --------------------------------------------------------------------------------------------------------------------------
; Name: validation
; Procedure validates that the number entered by the user falls within the range of ASCII values that represent numbers. The
; ASCII value for - and + is ignored.
; Preconditions: intro1 and intro2 are strings passed by reference to the procedure introducing the program.
; Postconditions: EBP, ESI, ECX, EDX, EAX are changed.
; Receives: Number to be validated, userNum offset, and userString1 from ReadVal
; Returns: 1 or 0 in EBX. Validated number.
; --------------------------------------------------------------------------------------------------------------------------


validation PROC
	; Initializes values 
	push	EBP
	mov		EBP, ESP
	mov		ESI, [EBP+16]	; user byte. ascii char
	mov		ECX, [EBP+12]
	mov		EDX, [EBP+8]	; user num
	cld

_loadByte:
	; Load bytes one by one and check that they fall within the range below
	lodsb
	cmp		al, 43			; if a + is encountred jump, ignore, and loop 
	je		_loopByte
	cmp		al, 45			; if a - is encountred jump, ignore, and loop 
	je		_loopByte
	cmp		al, 48
	jnge	_invalidDigit
	cmp		al, 57
	jnle	_invalidDigit
	loop	_loadByte
	jmp		_convert		; once all bytes have been loaded jmp to convert

_loopByte:
	; to loop when encountering a ASCII value that is valid and is ignored
	loop	_loadByte

_invalidDigit:
	; set EBX to 1 if number invalid and return
	mov		EBX, 1
	jmp		_end

_convert:
	; Gather needed values and call ConvertNumber
	mov		ECX, [EBP+12]
	push	ECX
	push	ESI
	push	EDX
	call	ConvertNumber

_end:
	pop		EBP
	ret		12
validation ENDP


; --------------------------------------------------------------------------------------------------------------------------
; Name: ConvertNumber
; Converts ASCII representation of a number passed to the procedure to a signed integer value.
; Preconditions: userString and userNum are offsets 
; Postconditions: EBP, ESI, EDX, ECX, EAX, EBX, and EDI are changed.
; Receives: userString, userNum, and value entered by user. 
; Returns: Signed integer in convertedNum
; --------------------------------------------------------------------------------------------------------------------------


ConvertNumber PROC
	; Local variables: tempNum used to move data between registers, negBool: to track when a negative number is encountered
	LOCAL tempNum:BYTE, negBool:DWORD

	; Initialize values and set direction flag
	mov		ESI, [EBP+12]			; userString
	mov		EDX, [EBP+8]			; user num variable
	mov		ECX, [EBP+16]			; counter
	std

_resetPointer:
	; Block used to return ESI pointer oto beginning of string 
	lodsb
	LOOP	_resetPointer
	mov		ECX, [EBP+16]
	cld								; direction flag cleared prior to loading digits

_loadDigits:
	; Load individual digits and check for + or - signs
	lodsb 
	cmp		AL, 43
	je		_loop
	cmp		AL, 45
	je		_setNeg
	
	; Block used to convert ASCII values to their respective numbers
	sub		AL, 48
	mov		BL, AL					; new AL value stored in BL
	mov		AL, tempNum				; tempNum moved into AL 
	mov		DL, 10
	mul		DL						; Multiply value in AL by current tempNum
	JO		_tooBig					; check for overflow
	add		AL, BL					; add to AL the old AL stored in BL
	JO		_tooBig					; check for overflow
	mov		tempNum, AL
	loop	_loadDigits
	jmp		_storeNum				; once complete jump to code block for storage

_loop:
	; if + sign is encountred it can be ignored and move on to next character
	LOOP	_loadDigits

_setNeg:
	; sets negBool to one for future use
	mov		EBX, 1
	mov		negBool, EBX
	LOOP	_loadDigits

_tooBig:
	; if value caused an overflow set EBX to 1 and return
	mov		EBX, 1
	jmp		_finished

_storeNum:
	; stores num in convertedNum
	movzx	EAX, tempNum
	cmp		negBool, 1				; checks if number should be negative
	je		_storeNegNum
	mov		[EDI], EAX				
	mov		EBX, 0
	jmp		_finished

_storeNegNum:
	; Stores negative num in convertedNum
	mov		negBool, 0				; resets negBool
	neg		EAX
	mov		[EDI], EAX				; stores num in convertedNum offset variable 
	mov		EBX, 0

_finished:
	ret		12
ConvertNumber ENDP


; --------------------------------------------------------------------------------------------------------------------------
; Name: WriteVal
; Procedure handles the printing of signed numbers passed to it from other procedures
; Preconditions: Number value passed and offset of empty byte array
; Postconditions: EBP, ESP, EAX, EBX, and ESI are changed
; Receives: An integer and an empty byte array
; Returns: None
; --------------------------------------------------------------------------------------------------------------------------


WriteVal PROC
	; initialize values
	push	EBP
	mov		EBP, ESP
	mov		EAX, [EBP+12]			; a number
	mov		EBX, [EBP+8]			; empty byte array
	
	; push number and byte array to be converted into string and stored in byte array
	push	EAX
	push	EBX
	call	ConvertString				

_end:
	pop		EBP
	ret		8
WriteVal ENDP


; --------------------------------------------------------------------------------------------------------------------------
; Name: ConvertString
; Procedure converts a signed integer to the appropriate string.
; Preconditions: Empty string array is passed by offset and a number is passed to convert.
; Postconditions: EAX, EDI, EBX are changed
; Receives: number in EAX and offset of empty string
; Returns: string of ASCII values
; ---------------------------------------------------------------------------------------------------------------------------


ConvertString PROC
	; temp local variable used for transfer of data between registers, counter for future use in loop, and negBool to set to 1 or 0
	LOCAL temp:DWORD, counter:DWORD, negBool:DWORD
	
	; Values initialized 
	mov		EAX, [EBP+12]			; number
	mov		EDI, [EBP+8]			; empty string	
	cld
	mov		counter, 0
	mov		negBool, 0
	mov		EAX, [EBP+12]

_convert:
	; Block converts an integer to its respective ASCII value
	cmp		EAX, 0	
	jl		_isNeg					; if value negative jmp to _isNeg
	mov		EBX, 10
	cdq
	div		EBX
	add		EDX, 48					; calculations to convert number to ASCII value
	push	EAX
	mov		temp, EDX
	mov		EAX, temp				; temp stores remainder which will be moved into EAX
	cld		
	STOSB							; value in EAX stored to EDI
	inc		counter					
	pop		EAX	
	cmp		EAX, 0
	je		_reverse				; once all digits have been converted jump to _reverse
	jmp		_convert		

_isNeg:
	; sets negBool to 1 and converts the value in EAX to its unsigned form
	mov		negBool, 1
	neg		EAX
	jmp		_convert


_reverse:
	; push necessary values to reverse the string
	push	EDI
	push	counter
	push	negBool
	call	ReverseString
	mov		negBool, 0				; reset negBool
	
_end:	
	ret		8
ConvertString ENDP

; --------------------------------------------------------------------------------------------------------------------------
; Name: ReverseString
; Procedure reverses the string passed to it.
; Preconditions: counter and negBool are DWORD values and userString is a Byte array
; Postconditions: EBP, ESP, EBX, ECX, ESI, EDI, and EAX are changed.
; Receives: value of counter and negBool and offset of userString
; Returns: none
; ---------------------------------------------------------------------------------------------------------------------------

ReverseString PROC
	; Local variable used to write the reversed values to
	LOCAL someString[20]:BYTE
	; initialize variables
	mov		EBX, [EBP+8]
	mov		ECX, [EBP+12]
	mov		ESI, [EBP+16]
	dec		ESI
	lea		EDI, someString
	cld

	; checks if EBX (negBool) is not equal to 0. If it is not then it is negative
	cmp		EBX, 0
	je		_revLoop
	mov		EAX, 45					; ASCII value for - prepended 
	STOSB
	
_revLoop:
	; Reverse loop from exploration to reverse the string stored in ESI
    STD
    LODSB
    CLD
    STOSB
	LOOP   _revLoop
	mov		EAX, 0					; add null terminator
	STOSB
	lea		EAX, someString
	mDisplayString EAX				; display value
	ret		12
ReverseString ENDP

; --------------------------------------------------------------------------------------------------------------------------
; Name: DisplayNumList
; Procedure sends values in numArray ot WriteVal to be printed to the console.
; Preconditions: endPrompt1 is a string, numArray is an array of 10 signed integers and userString is an empty string
; Postconditions: EBP, EDX, ECX, ESI, EAX, EBX are changed.
; Receives: offset of endPrompt1, offset of numArray and offset of userString
; Returns: none
; ---------------------------------------------------------------------------------------------------------------------------

DisplayNumList PROC
	; Local variable used to preserve ESI because I was having weird issues with it and this was my "solution"
	LOCAL storeEsi:DWORD
	; print string
	mov		EDX, [EBP+12]
	mDisplayString EDX
	call	CrLf

	; initialize loop counter and ESI to numArray
	mov		ECX, ARRAYSIZE
	mov		ESI, [EBP+16]			; num array

_someLoop:
	; Loop through values of numArray and call writeval
	push	ECX
	mov		EAX, [ESI]
	mov		EBX, [EBP+20]			; user string
	mov		storeEsi, ESI
	push	EAX
	push	EBX
	call	WriteVal
	mov		EDX, [EBP+8]
	mDisplayString EDX				; weird behavior with this with larger values that I could not figure out in time. commaAndSpace data was being overwritten somehow?		
	mov		ESI, storeEsi
	add		ESI, 4
	pop		ECX
	loop	_someLoop

	ret		8
DisplayNumList ENDP


; --------------------------------------------------------------------------------------------------------------------------
; Name: Calculations
; Procedure performs two calculations on the array of signed integers. Calculates the truncated average and sum.
; Preconditions: numArray is an array of 10 signed integers, userString is an empty string, sumString and trnAvgString are strings
; Postconditions: EBP, ECX, ESI, EDX, EAX, EBX are changed.
; Receives: offset of numArray, userString, sumString, and trnAvgString
; Returns: None
; ---------------------------------------------------------------------------------------------------------------------------


Calculations PROC
	; Setup stack frame and initialize values
	push	EBP
	mov		EBP, ESP
	mov		ECX, ARRAYSIZE
	mov		ESI, [EBP+8]
	mov		EAX, 0
	mov		EDX, [EBP+16]
	mDisplayString EDX				; print string using macro
	

	_sumLoop:
	; loop to sum values in numArray
	add		EAX, [ESI]
	add		ESI, 4
	loop	_sumLoop
	mov		EBX, [EBP+20]
	push	EAX
	push	EBX
	call	WriteVal				; sum then pushed to WriteVal to be displayed
	call	CrLf

	mov		EDX, [EBP+12]
	mDisplayString EDX				; print string using macro
	mov		ESI, [EBP+8]
	mov		EAX, 0
	mov		ECX, ARRAYSIZE			; re-initialize values for the average

_sumLoop2:
	; loop and sum again
	add		EAX, [ESI]
	add		ESI, 4
	loop	_sumLoop2

_average:
	; calculate average
	mov		EBX, ARRAYSIZE
	cdq
	idiv	EBX
	mov		EBX, [EBP+20]
	PUSH	EAX
	push	EBX
	call	WriteVal				; call writeval to have average displayed

	pop		EBP
	ret		12
Calculations ENDP


; --------------------------------------------------------------------------------------------------------------------------
; Name: goodbye
; Procedure displays closing message.
; Preconditions: exitString is a string containing exit message
; Postconditions: EDX, EBP, and ESP are changed.
; Receives: offset of exitString
; Returns: None
; ---------------------------------------------------------------------------------------------------------------------------

goodbye PROC
	push	EBP
	mov		EBP, ESP

	; Macro invoked to print out string
	mov		EDX, [EBP+8]
	mDisplayString EDX
	call	CrLf
	pop		EBP
	ret		4

goodbye ENDP

END main
