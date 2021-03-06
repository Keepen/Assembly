;8255 流水灯实验
DATA SEGMENT 
	P8255A DW 0640H
	P8255B DW 0642H
	P8255C DW 0644H
	P8255M DW 0646H
DATA ENDS 
SSTACK SEGMENT 
	DW 32 DUP(?)
SSTACK ENDS
CODE SEGMENT
	ASSUME CS:CODE, DS:DATA, SS:SSTACK
START:
	MOV AX, DATA
	MOV DS, AX
	MOV DX, P8255M
	MOV AL, 80H
	OUT DX, AL
	MOV BX, 8001H	;L15~L8 从从左向右亮；L7~L0 从右向左亮
AA1:MOV DX, P8255A	;向A口写入状态字
	MOV AL, BL
	OUT DX, AL
	ROL BL, 1
	MOV DX, P8255B	;向B口写入状态字
	MOV AL, BH
	OUT DX, AL
	ROR BH, 1
	
	CALL DELAY
	JMP AA1
DELAY PROC
	PUSH SI
	PUSH CX
	MOV SI, 13FFH
D11:MOV CX, 9000H
D22:LOOP D22
	DEC SI
	JNZ D11
	POP CX
	POP SI
	RET
DELAY ENDP
CODE ENDS
	END START
	
	