;====================================================================
; Main.asm file generated by New Project wizard
;
; Created:   Cum Mar 11 2016
; Processor: 8086
; Compiler:  MASM32
;
; Before starting simulation set Internal Memory Size 
; in the 8086 model properties to 0x10000
;====================================================================
CODE    SEGMENT PARA 'CODE'
        ASSUME CS:CODE, DS:DATA, SS:STAK
STAK    SEGMENT PARA STACK 'STACK'
        DW 20 DUP(?)
STAK    ENDS

DATA    SEGMENT PARA 'DATA'
SERIALDATA  DB 60 DUP (?)
holder	db 0
DATA    ENDS


START PROC FAR
    
    CALL INIT8251
ENDLESS:XOR DI,DI
    XOR SI,SI

    MOV DX, 0105H ;Control adresini DXe att?k.
TEKRARx1:

    MOV holder, 53H ;s yollamak i?in
    CALL SENDDATA
    
    
TEKRARx2:;MOV DX,0105H ;
    
    CALL RECEIVEDATA
    
   
    SHR AL, 1
    CMP AL,3FH ;SORU ?SARET?
    JNE TEKRARx2
    
    MOV CL,3
    
     
TEKRARx3:
    
    MOV holder,49D
    CALL SENDDATA
    LOOP TEKRARx3    
    
TEKRAR4:
    CALL RECEIVEDATA
    SHR AL, 1
    CMP AL,54H
    JE SON 
    MOV SERIALDATA[DI],AL
    INC DI
    JMP TEKRAR4
    
    
    
SON:    
    MOV CX, DI
son2:   
    
    MOV AL, SERIALDATA[SI]
    MOV holder,AL
    CALL SENDDATA
    INC SI
    OUT DX, AL
    LOOP son2
    JMP ENDLESS
     
RETF
START ENDP
    
TKONTROL PROC NEAR ;transmit ready kontrol fonksiyonu
TEKRAR:
    IN AL, DX ;Status Reg degerlerini ald?k.
    AND AL, 01H ;Transmit ready degerinini kontrolu icin maskeleme
    JZ TEKRAR ;Transmit ready olana kadar d?n
RET 
TKONTROL ENDP

RKONTROL PROC NEAR ;receive ready kontrol fonksiyonu
TEKRAR2:
    
    IN AL, DX
    AND AL, 02H ; receive ready control?
    JZ TEKRAR2
RET
RKONTROL ENDP

INIT8251 PROC NEAR ;8251 init
MOV AX, DATA
    MOV DS, AX
    MOV DX, 0105h
    MOV AL, 01001101B  ; mod yazmac? asenkron, 1stop biti , parity biti yok, baud rate factor 1
    OUT DX, AL
    MOV AL, 40H	; resetliyoruz 0100 0000
    OUT DX, AL
    MOV AL, 01001101B ; tekrar mod yazmac?
    OUT DX, AL
    MOV AL, 00010101B ; kontrol yazmac? , transmit ve receiveri enable'lad?k
    OUT DX, AL
RET
INIT8251 ENDP

SENDDATA PROC NEAR
    MOV DX, 0105H
    CALL TKONTROL
    MOV DX, 0101H
    MOV AL, holder
    OUT DX, AL
RET
SENDDATA ENDP

RECEIVEDATA PROC NEAR
    MOV DX, 0105H
    CALL RKONTROL

    MOV DX, 0101H
    IN AL, DX
RET
RECEIVEDATA ENDP
    
CODE    ENDS
        END START