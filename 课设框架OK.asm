TIMER0      EQU     0600H       ;IOY0 
TIMER1      EQU     0602H 
TIMER2      EQU     0604H 
TIMERM      EQU     0606H
P8255A      EQU     0640H       ;IOY1
P8255B      EQU     0642H 
P8255C      EQU     0644H 
P8255M      EQU     0646H
;---------------------------------------------------------------
DATA        SEGMENT 
DISCODE     DB      3FH,06H,5BH,4FH,66H,6DH,7DH,07H     ;0--7的显示代码
            DB      7FH,6FH,77H,7CH,39H,5EH,79H,71H     ;8--F的显示代码
INDEX       DB      00H,00H,00H,00H,00H,00H,0CCH,0CCH
DYNBUFF     DB      00H,00H,00H,00H,00H,00H,00H,00H     ;动态显示代码缓冲
LOCATN      DB      00H,00H,00H,00H,00H,00H,00H,00H     ;动态显示位置控制
HOUR        DB      12          ;小时
MINUTE      DB      34          ;分钟
SECOND      DB      50          ;秒
			
STA       DB      01H
DATA        ENDS
SSTACK      SEGMENT PARA    STACK   'STACK'
            DW      32  DUP(?)
SSTACK      ENDS
CODE        SEGMENT 
            ASSUME  CS:CODE, DS:DATA,SS: SSTACK			
START:      MOV     AX,DATA	
            MOV     DS,AX
;--------------------------------------------------------------- 8255初始化
INITA:      MOV     DX, P8255M 
            MOV     AL, 80H 
            OUT     DX, AL 
            MOV     DX, P8255B 
            MOV     AL, 0FFH 
            OUT     DX, AL 
;--------------------------------------------------------------- 中断芯片
INITB:      PUSH    DS
            MOV     AX,0000H	
            MOV     DS,AX		
            MOV     AX,OFFSET	 MIR7
            MOV     SI,003CH
            MOV     [SI],AX
            MOV     AX,CS
            MOV     SI,003EH
            MOV     [SI],AX
            MOV     AX,OFFSET	 MIR6
            MOV     SI,0038H
            MOV     [SI],AX
            MOV     AX,CS
            MOV     SI,003AH
            MOV     [SI],AX
            MOV     AX, OFFSET	 SIR1 
            MOV     SI, 00C4H 
            MOV     [SI], AX 
            MOV     AX, CS 
            MOV     SI, 00C6H 
            MOV     [SI], AX 
            CLI	
            POP     DS		
;---------------------------------------------------------------主片
            MOV     AL,11H
            OUT     20H,AL          ;ICW1
            MOV     AL,08H
            OUT     21H,AL          ;ICW2
            MOV     AL,04H
            OUT     21H,AL          ;ICW3
            MOV     AL,01H
            OUT     21H,AL          ;ICW4
;-------------------------------------------------------------初始化从片8259 
            MOV     AL, 11H 
            OUT     0A0H, AL        ;ICW1 
            MOV     AL, 30H 
            OUT     0A1H, AL        ;ICW2 
            MOV     AL, 02H 
            OUT     0A1H, AL        ;ICW3 
            MOV     AL, 01H 
            OUT     0A1H, AL        ;ICW4
;--------------------------------------------------------------- 
            MOV     AL, 0FFH        ;OCW1 = 1111 1101B
            OUT     0A1H,AL 		
            MOV     AL,2BH          ;OCW1 = 00101011B
            OUT     21H,AL	
            STI	
;--------------------------------------------------------------- 定时器芯片
INITC:  	MOV DX, TIMERM
			MOV AL, 36H ;计数器 0，方式 3 
			OUT DX, AL 
			MOV DX, TIMER0 
			MOV AX, 1000
			OUT DX, AL 
			MOV AL, AH 
			OUT DX, AL 
            MOV     DX, TIMERM      ;8254控制字 
            MOV     AL, 76H         ;计数器1，方式3 
            OUT     DX, AL
            MOV     DX, TIMER1
            MOV     AX, 1000
            OUT     DX, AL 
            MOV     AL, AH 
            OUT     DX, AL 
;--------------------------------------------------------------- 8255初始化
INITD:      NOP
;--------------------------------------------------------------- 
BEGIN:      NOP
AA2:        JMP     AA2


;-------数码管1
DIS1 PROC
	PUSH DX
	PUSH AX		
	PUSH BX
	MOV DX, P8255A
	MOV AL, 0FEH
	OUT DX, AL
	
	MOV BL, 0AH
	MOV AL, SECOND
	DIV BL
	MOV BX, OFFSET DISCODE
	;MOV AL, 06H
	MOV AL, AH
	XLAT
	;XOR BX, BX
	;MOV BL, AL
	MOV DX, P8255B
	OUT DX, AL
	POP BX
	POP AX
	POP DX
	RET
DIS1 ENDP



DIS2 PROC
	PUSH DX
	PUSH AX	
	PUSH BX	
	MOV DX, P8255A
	MOV AL, 0FDH
	OUT DX, AL
	
	MOV BL, 0AH	
	MOV AL, SECOND
	DIV BL
	MOV SI, OFFSET DISCODE
	;MOV AL, 5BH
	XOR BX, BX
	MOV BL, AL
	MOV AL, [BX + SI]
	MOV DX, P8255B
	OUT DX, AL
	POP BX
	POP AX
	POP DX
	RET
DIS2 ENDP



DIS3 PROC
	PUSH DX
	PUSH AX	
	PUSH BX	
	MOV DX, P8255A
	MOV AL, 0FBH
	OUT DX, AL
	
	MOV AL, MINUTE
	MOV BL, 0AH
	DIV BL
	MOV SI, OFFSET DISCODE
	;MOV AL, 4FH
	MOV AL, AH
	XOR BX, BX
	MOV BL, AL
	MOV AL, [BX + SI]
	MOV DX, P8255B
	OUT DX, AL
	POP BX
	POP AX
	POP DX
	RET
DIS3 ENDP

DIS4 PROC
	PUSH DX
	PUSH AX		
	MOV DX, P8255A
	MOV AL, 0F7H
	OUT DX, AL
	
	MOV SI, OFFSET DISCODE
	MOV BL, 0AH
	MOV AL, MINUTE
	DIV BL
	;MOV AL, 66H
	XOR BX, BX
	MOV BL, AL
	MOV AL, [BX + SI]
	
	MOV DX, P8255B
	OUT DX, AL
	POP AX
	POP DX
	RET
DIS4 ENDP




DIS5 PROC
	PUSH DX
	PUSH AX		
	MOV DX, P8255A
	MOV AL, 0EFH
	OUT DX, AL
	
	MOV SI, OFFSET DISCODE
	MOV BL, 0AH
	MOV AL, HOUR
	DIV BL
	MOV AL, AH
	;MOV AL, 6DH
	XOR BX, BX
	MOV BL, AL
	MOV AL, [BX + SI]
	MOV DX, P8255B
	OUT DX, AL
	POP AX
	POP DX
	RET
DIS5 ENDP



DIS6 PROC
	PUSH DX
	PUSH AX		
	MOV DX, P8255A
	MOV AL, 0DFH
	OUT DX, AL
	
	MOV BL, 0AH
	MOV DX, P8255B
	MOV AL, HOUR
	DIV BL
	;MOV AL, 7DH
	XOR BX, BX
	MOV BL, AL
	MOV AL, [BX + SI]
	OUT DX, AL
	POP AX
	POP DX
	RET
DIS6 ENDP


DISP PROC
	PUSH AX
	MOV AL, STA
	TEST AL, 01H
	JNZ D1
	TEST AL, 02H
	JNZ D2
	TEST AL, 04H
	JNZ D3
	TEST AL, 08H
	JNZ D4
	TEST AL, 10H
	JNZ D5
	TEST AL, 20H
	JNZ D6
	JMP DOWN
D1:CALL DIS1
	ROL AL, 1
	JMP DOWN
D2:CALL DIS2
	ROL AL, 1
	JMP DOWN
D3:CALL DIS3
	ROL AL, 1
	JMP DOWN
D4:CALL DIS4
	ROL AL, 1
	JMP DOWN
D5:CALL DIS5
	ROL AL, 1
	JMP DOWN
D6:CALL DIS6
	MOV AL, 01H
	JMP DOWN
	
DOWN:MOV STA, AL
	POP AX
	RET
DISP ENDP






;--------------------------------------------------------------- 
MIR7        PROC    NEAR
            PUSH    AX
            PUSH    DX
            MOV     AX,0137H
            INT     10H             ;显示字符7
            MOV     AX,0120H
            INT     10H

		;	CALL DISP
			
            MOV     AL,20H
            OUT     20H,AL
            POP     DX
            POP     AX			
            IRET
MIR7        ENDP
;--------------------------------------------------------------- 
MIR6        PROC    NEAR
            PUSH    AX
            PUSH    DX
			MOV AX, 0133H
			INT 10H
			CALL DISP
			MOV AL, SECOND
			INC AL
			MOV BL, AL
			CMP BL, 60
			JAE CSECOND
			MOV SECOND, AL
			JMP DDOWN
CSECOND:MOV AL, 0
		MOV SECOND, AL
		MOV BL, MINUTE
		INC BL
		MOV CL, BL
		CMP CL, 60
		JAE CMINUTE
		MOV MINUTE, BL
		JMP DDOWN
CMINUTE:MOV AL, 0
		MOV MINUTE, 0
		MOV BL, HOUR
		INC BL
		MOV CL, BL
		CMP CL, 24	
		JAE CHOUR
		MOV BL, HOUR
		JMP DDOWN
CHOUR:	MOV AL, 0
		MOV HOUR, AL
		MOV MINUTE, AL
		MOV SECOND, AL
		JMP DDOWN

DDOWN:							
            MOV     AL,20H
            OUT     20H,AL
            POP     DX
            POP     AX			
            IRET 
MIR6        ENDP	
SIR1        PROC    NEAR
            PUSH    AX
            PUSH    DX
            MOV     AX,0131H
            INT     10H             ;显示字符1
            MOV     AX,0120H
            INT     10H
			
            MOV     AL, 20H 
            OUT     0A0H, AL 
            OUT     20H, AL
            POP     DX
            POP     AX			
            IRET
SIR1        ENDP
;---------------------------------------------------以下为子程序
DELAY:      PUSH    SI
            PUSH    CX
            MOV     SI,	00FFH
D11:        MOV     CX,	00FFH
D22:        LOOP    D22
            DEC     SI
            JNZ     D11             ;延时结束
            POP     CX              
            POP     SI
            RET


;---------------------------------------------------------------         	
CODE        ENDS
            END     START
