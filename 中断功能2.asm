SSTACK SEGMENT STACK
	DW 32 DUP(?)
SSTACK ENDS
CODE SEGMENT
	ASSUME CS : CODE
START: NOP
	PUSH DS
	MOV AX, 0000H
	MOV DS, AX
	MOV AX, OFFSET MIR7	;取中断入口地址
	MOV SI, 003CH		;中断矢量地址
	MOV [SI], AX		;写IRQ7的偏移矢量
	MOV AX, CS
	MOV SI, 003EH
	MOV [SI], AX		;写IRQ7的段地址
	MOV AX, OFFSET SIR1
	MOV SI, 00C4H
	MOV [SI], AX
	MOV AX, CS
	MOV AX, CS
	MOV SI, 00C6H
	MOV [SI], AX
	CLI
	POP DS
	
	;初始化主片8259
	MOV AL, 11H
	OUT 20H, AL	;ICW1
	MOV AL, 08H
	OUT 21H, AL	;ICW2
	MOV AL, 04H
	OUT 21H, AL	;ICW3
	MOV AL, 01H
	OUT 21H, AL	;ICW4
	
	;初始化从片8259
	MOV AL, 11H
	OUT 0A0H, AL	;ICW1
	MOV AL, 30H
	OUT 0A1H, AL	;ICW2
	MOV AL, 02H
	OUT 0A1H, AL	;ICW3
	MOV AL, 01H
	OUT 0A1H, AL	;ICW4
	MOV AL, 0FDH
	OUT 0A1H, AL	;OCW1:1111 1101
	MOV AL, 6BH
	OUT 21H, AL		;主片8259OCW1
	STI
	
AA1:NOP
	JMP AA1
MIR7 PROC
	PUSH AX
	;CALL DELAY
	MOV AX, 014DH
	INT 10H	;M
	MOV AX, 0137H
	INT 10H	;7
	MOV AX, 0120H
	INT 10H
	MOV AL, 20H
	OUT 20H, AL	;中断结束命令
	POP AX
	IRET
MIR7 ENDP
SIR1 PROC
	PUSH AX
	CALL DELAY
	MOV AX, 0153H
	INT 10H	;$
	MOV AX, 0131H
	INT 10H	;1
	MOV AX, 0120H
	INT 10H
	MOV AL, 20H
	OUT 0A0H, AL
	OUT 20H, AL
	POP AX
	IRET
SIR1 ENDP
DELAY PROC
	PUSH CX
	MOV CX, 0F00H
AA0:PUSH AX
	POP AX
	LOOP AA0
	POP CX
	RET
DELAY ENDP
CODE ENDS
	END START


	
	
	
	