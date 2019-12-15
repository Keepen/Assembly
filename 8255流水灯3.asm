;8255 流水灯实验
DATA SEGMENT 
	P8255A DW 0640H
	P8255B DW 0642H
	P8255C DW 0644H
	P8255M DW 0646H
	BUF DB 18H,24H,42H,81H
DATA ENDS 
SSTACK SEGMENT 
	DW 32 DUP(?)
SSTACK ENDS
CODE SEGMENT
	ASSUME CS:CODE, DS:DATA, SS:SSTACK
START:
	MOV AX, DATA
	MOV DS, AX
	MOV DX, P8255M	;送控制字
	MOV AL, 80H
	OUT DX, AL
	MOV BX, BUF
	MOV CL, 0
AA1:MOV AL, CL
	XLAT			;查表指令，BX存放地址，AL存放索引
	MOV DX, P8255A
	OUT DX, AL
	MOV DX, P8255B
	OUT DX, AL
	INC CL
	TEST CL, 4		;当越界时， 从表头开始重新查找
	JNZ KK
	CALL DELAY
	JMP AA1
KK: MOV CL, 0

DELAY PROC
	PUSH SI
	PUSH CX
	MOV SI, 13FFH	;管外循环 -- 可以对循环次数进行粗调
D11:MOV CX, 9000H	;管内循环 -- 可以对循环次数进行细调
D22:LOOP D22
	DEC SI
	JNZ D11
	POP CX
	POP SI
	RET
DELAY ENDP
CODE ENDS 
	END START



