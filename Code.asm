
; -------------------------------------------------------------------
; Task description: 
;   Center alignment of a sentence (ASCII string) in a memory field of given character length. 
;   The size of the field is an input parameter. Use space characters (ASCII code: 0x20) 
;   to fill the empty positions. The field which contains the aligned text does not need 
;   to be null-terminated.
;   Inputs: Start address of the (null-terminated) string (pointer), 
;           start address of the field (pointer), 
;           length of the field (value)
;   Output: The correctly filled field containing the aligned text
; -------------------------------------------------------------------


; Definitions
; -------------------------------------------------------------------

; Address symbols for creating pointers

FIELD_ADDR_IRAM  EQU 0x40
FIELD_LEN  EQU 16
CHARACTER  EQU 0x20   ;CHARACTER symbols helps us to use any character for flling empty positions by just changing one statement
; Test data for input parameters
; (Try also other values while testing your code.)

; Store the string in the code memory as an array

ORG 0x0090 ; Move if more code memory is required for the program code
STR_ADDR_CODE:
DB "Hello 8051!"
DB 0

; Interrupt jump table
ORG 0x0000;
    SJMP  MAIN                  ; Reset vector



; Beginning of the user program, move it freely if needed
ORG 0x0010

; -------------------------------------------------------------------
; MAIN program
; -------------------------------------------------------------------
; Purpose: Prepare the inputs and call the subroutines
; -------------------------------------------------------------------

MAIN:

    ; Prepare input parameters for the subroutine
	MOV DPTR,#STR_ADDR_CODE
	MOV R6,#FIELD_ADDR_IRAM
	MOV R7,#FIELD_LEN
	
; Infinite loop: Call the subroutine repeatedly
LOOP:

    CALL STR_ALIGN_CENTER ; Call the right align subroutine

    SJMP  LOOP




; ===================================================================           
;                           SUBROUTINE(S)
; ===================================================================           

; -------------------------------------------------------------------
; STR_ALIGN_CENTER
; -------------------------------------------------------------------
; Purpose: Center alignment of a sentence (ASCII string) in a memory field of given character length.
; -------------------------------------------------------------------
; INPUT(S):
;   DPTR - Base address of the string in code memory
;   R6 - Base address of the field in internal memory
;   R7 - Length of the field
; OUTPUT(S): 
;   Center aligned string in the given field memory
; MODIFIES:
;   PSW, A, B, DPTR, R0, R1, R2, R5, R6, R7
; -------------------------------------------------------------------

STR_ALIGN_CENTER:

; [TODO: Place your code here]

MOV A,R7					;Field length from R7 to A
MOV	R2,A					;Saving field length for infinite loop iterations   
MOV R1,#-1  				;initialized with -1 because R1 is incremented at the end of Subroutine "STR_LENGTH"  
MOV R4,#0xFF 				;R4 Will be used later in STR_LENGTH for assisting A in indexed addressing


; -------------------------------------------------------------------
; STR_LENGTH
; -------------------------------------------------------------------
; Purpose: Finds number of characters in the string
; -------------------------------------------------------------------
; INPUT(S):
;   DPTR - Base address of the string in code memory
;   R4 - Used to move data in Accumulator for index addrressing to extract characers from DPTR
;   R1 -  R1 stores string length
; OUTPUT(S): 

; MODIFIES:
; R1, R4, DPTR,A 
; -------------------------------------------------------------------

STR_LENGTH:
inc R4					;Used to move data in Accumulator for index addrressing to extract characers from DPTR
MOV A,R4  				;Moving value into Accumulator to extract characters via indexed addressing
movc A,@A+DPTR			;Indexed addressing using Accumulator register

inc R1					;counting the string length character by character
jnz STR_LENGTH			;the loop stops when 0(null character) is detected

MOV A, R6				;To move starting address of string in code memory to R0 through A
MOV R0,A                ;To move starting address of string in code memory to R0 through A

; -------------------------------------------------------------------
; NORMAL_STR
; -------------------------------------------------------------------
; Purpose:  Checks if a string is null string or more lengthy string than memory field or full string or the number of characters in string is one less than the field length, and jumps to their respective subroutines
;			If not any of the above, then it is a normal string, then it finds the number of empty positions, and moves to the next subroutine in the code to start alignment.
; -------------------------------------------------------------------
; INPUT(S):
;   R1 -  R1 has string length in it
;   R7 -  R7 has field length stored in it.
; OUTPUT(S): 

; MODIFIES:
; A, R5, R3, B, R1, R2, R1 
; -------------------------------------------------------------------

NORMAL_STR:				;Subroutine to check string types and align the normal string in memory
MOV A,R1				;To check if string is a null string
JZ DEFAULT				;Jumps to NULL_STR if there is no character in the string


MOV A,R1 				;To use string length later for copying the string into the memory field
MOV R5,A 				;To use string length later for copying the string into the memory field



MOV A,R7 				;Moving field length to accumulator
SUBB A,R1				;Subtracting string length from field length to caluate number of empty places in the field
MOV R3,A				;;Storing answer of substraction for further cases

CLR C					; Clearing carry flag  to check if (field length - string length) is a negative number
RLC A					; MSB bit goes into carry falg
JC DEFAULT 				;Jumps to DEFAULT if there are more characters than memory field size

MOV A,R3
JZ FULL_STR				;Jumps to FULL_STR for a string having same length as memory field

MOV B,A					;Storing answer of previous substraction for further cases
SUBB A,#1				;To check if only one position is empty
JZ ONE_EMPTY_POS		;Jumps if only one position is empty

MOV A,B					;Moving the no. of empty positions to Accumulator
MOV B,#2				;To Divide empty positions equally for center allignment of string
DIV AB					;Division operation executes here andremainder goes to B
MOV R1,A				;Storing the number of space characters needed in R1 for empty positions on left side of string

ADD A,B					;For a string having odd no. of characters
MOV R2,A 				;Storing the number of space characters needed in R2 for empty positions on right side of string

; -------------------------------------------------------------------
; PRE_STR_SPACES
; -------------------------------------------------------------------
; Purpose:  For center alignment, places space characters before(left side) of the string in memory field
;			At the end it initializes R4 with 0xFF for to be used for indexed addressing mode in the next sub-routine
; -------------------------------------------------------------------
; INPUT(S):
;   R0 -  R0 contains starting address of the memory field in data memory.
;   R1 -  Contains the number of empty positions to be filled before(left side of) the string in memory field 

; OUTPUT(S): 
; 	R0 - The starting address of memory field is taken as input and space characters are stored in those addresses of memory field using R0 as an output
; MODIFIES:
; A, R0, R1, R4 
; -------------------------------------------------------------------


PRE_STR_SPACES:  			;Subroutine for putting space characters behing the string
MOV A,#CHARACTER			;Moving ASCII code of space character into accumulator
MOV @R0,A					;Placing space characters at the addresses of memory field pointed by R0
inc R0						;Moving to the address of next position in memory field
djnz R1,PRE_STR_SPACES		;Number of iterations of loop is equal to number of space characters to be placed

MOV R4,#0xFF				;R4 Will be used later in STR_COPY for assisting A in indexed addressing


; -------------------------------------------------------------------
; STR_COPY
; -------------------------------------------------------------------
; Purpose:  Copies string characters from code memory to data memory using index addressing
; -------------------------------------------------------------------
; INPUT(S):
;   R4 - R4 increments the offset value of Accumulator used in previous loop iteration for indexed addressing
;   R0 - R0 contains starting address of the memory field in data memory.
;   R5 - Number of characters in the string was passed into R5, after execution of subroutine STR_LENGTH 
; OUTPUT(S): 
; 	R0 - R0 has memory address of immediate data memory position after placing space characters in PRE_STR_SPACES subroutine  and now string characters will be placed in memory field using R0 as an output register
; MODIFIES:
; A, R0, R4, R5 
; -------------------------------------------------------------------


STR_COPY:  				;Subroutine to copy string characters into the memory field excluding null termination character
inc R4					;Used to move data in Accumulator for index addrressing to extract characers from DPTR(string)
MOV A,R4				;Moving value into Accumulator to extract characters via indexed addressing
movc A,@A+DPTR			;Moving data at string memory addresses in code memory to accumulator using index addressing
MOV @R0,A				;Moving string characters excluding null termination character to given memory field adresses in the internal memory 
inc R0					;Incerementing R0 to point at next empty position address in the field memory
djnz R5,STR_COPY		;Number of loop iterations equals number of characters in the string or string length excluding null termination character

; -------------------------------------------------------------------
; POST_STR_SPACES
; -------------------------------------------------------------------
; Purpose:  For center alignment, places space characters after(right side) of the string in memory field, and then jumps to subroutine LAST
; -------------------------------------------------------------------
; INPUT(S):
;	DPTR - Contains starting address of string in code memory
;   R0 - R0 has memory address of immediate data memory position after placing string characters in previous STR_COPY subroutine .
;   R2 - Contains the number of empty positions to be filled after(right side of) the string inmemory field 
; OUTPUT(S): 
; 	R0 - R0 has memory address of immediate data memory position after placing string characters in STR_COPY subroutine  and now space characters are placed in the remaining empty positions usinf R0 as an output register 
; MODIFIES:
; A, R0, R2 
; -------------------------------------------------------------------
POST_STR_SPACES:			;Subroutine to Subroutine for putting space characters ahead/after the string
MOV A,#CHARACTER			;Moving ASCII code of space character into accumulator
MOV @R0,A					;Placing space characters at the addresses of memory field pointed by R0
inc R0						;Moving to the address of next position in memory field
djnz R2,POST_STR_SPACES		;Number of iterations of loop is equal to number of space characters to be placed
JMP LAST					;jumps to RET in subroutine LAST

; -------------------------------------------------------------------
; FULL_STR
; -------------------------------------------------------------------
; Purpose:  Copies string characters from code memory to data memory using index addressing for a string having same length as memory field, and jumps to LAST subroutine
; -------------------------------------------------------------------
; INPUT(S):
;	DPTR - Contains starting address of string in code memory
;   R0 - R0 contains starting address of the memory field in data memory.
;   R5 - Number of characters in the string was passed into R5, after execution of subroutine STR_LENGTH 
; OUTPUT(S): 
; 	R0 - R0 has memory address of immediate data memory position after placing space characters in PRE_STR_SPACES subroutine  and now string characters will be placed in memory field using R0 as an output register
; MODIFIES:
; A, R0, R4, R5 
; -------------------------------------------------------------------

FULL_STR:
MOV R4,#0xFF
LOOP4:  				;Subroutine to copy string characters into the memory field excluding null termination character
inc R4					;Used to move data in Accumulator for index addrressing to extract characers from DPTR(string)
MOV A,R4				;Moving value into Accumulator to extract characters via indexed addressing
movc A,@A+DPTR			;Moving data at string memory addresses in code memory to accumulator using index addressing
MOV @R0,A				;Moving string characters excluding null termination character to given memory field adresses in the internal memory 
inc R0					;Incerementing R0 to point at next empty position address in the field memory
djnz R5,LOOP4			;Number of loop iterations equals number of characters in the string or string length excluding null termination character

JMP LAST				;jumps to RET in subroutine LAST

; -------------------------------------------------------------------
; ONE_EMPTY_POS
; -------------------------------------------------------------------
; Purpose:  Aligns string characters for a string having no. of characters one less than the memory field length, and jumps to LAST subroutine
; -------------------------------------------------------------------
; INPUT(S):
;	DPTR - Contains starting address of string in code memory
;   R0 - R0 contains starting address of the memory field in data memory.
;   R5 - Number of characters in the string was passed into R5, after execution of subroutine STR_LENGTH 
; OUTPUT(S): 
; 	R0 - R0 has memory address of immediate data memory position after placing space characters in PRE_STR_SPACES subroutine  and now string characters will be placed in memory field using R0 as an output register
; MODIFIES:
; A, R0, R4, R5 
; -------------------------------------------------------------------

ONE_EMPTY_POS:
MOV R4,#0xFF			;R4 Will be used later in STR_COPY for assisting A in indexed addressing

STR_COPY2:  			;Subroutine to copy string characters into the memory field excluding null termination character
inc R4					;Used to move data in Accumulator for index addrressing to extract characers from DPTR(string)
MOV A,R4				;Moving value into Accumulator to extract characters via indexed addressing
movc A,@A+DPTR			;Moving data at string memory addresses in code memory to accumulator using index addressing
MOV @R0,A				;Moving string characters excluding null termination character to given memory field adresses in the internal memory 
inc R0					;Incerementing R0 to point at next empty position address in the field memory
djnz R5,STR_COPY2		;Number of loop iterations equals number of characters in the string or string length excluding null termination character


MOV @R0,#CHARACTER      ;Puts the alignment character to last empty position in field
JMP LAST				;jumps to RET in subroutine LAST
		
; -------------------------------------------------------------------
; DEFAULT
; -------------------------------------------------------------------
; Purpose:  Fills the whole memory field with space characters for a null string(having no characters)or string having more characters than memory field
; -------------------------------------------------------------------
; INPUT(S):
;   R0 - R0 contains starting address of the memory field in data memory.
;   R7 - Data memory Field Length
;	R2 - Field Length stored in a safety register to  avoid infinte iterations of LOOP1 
; OUTPUT(S): 
; 	R0 - Space characters are paced in to the given memory field using register R0 as an output
; MODIFIES:
; A, R0, R7 
; ------------------------------------------------------------------

DEFAULT:
MOV A,#CHARACTER    	;The alignment character is moved to accumulator
LOOP1:
      MOV @R0,A    		;The alignment character is moved to the address pointed by R0
	  inc R0       		;incrementing string address
	  DJNZ R7,LOOP1		;Loop iterations are equal to field length
MOV A,R2 				;Field length goes to R7 register
MOV R7,A				;Field Length stored in a safety register to  avoid infinte iterations of LOOP1
JMP LAST 				;jumps to RET in subroutine LAST
; -------------------------------------------------------------------
; LAST
; -------------------------------------------------------------------
; Purpose:  Return the main subroutine STR_ALIGN_CENTER and infinite LOOP starts
; -------------------------------------------------------------------
; INPUT(S):
 
; OUTPUT(S): 

; MODIFIES:
 
; ------------------------------------------------------------------


LAST:                ;It is used to Return the main subroutine STR_ALIGN_CENTER and infinite LOOP starts 
RET					;Return
END 				; End of the source file



