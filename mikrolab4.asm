CODE    SEGMENT PARA 'CODE'
        ASSUME CS:CODE, DS:DATA, SS:STAK
STAK    SEGMENT PARA STACK 'STACK'
        DW 20 DUP(?)
STAK    ENDS

DATA    SEGMENT PARA 'DATA'

SAMPLES DB 200 DUP(?)
FILTERS DB 200 DUP(?)
lambda DB ?
DATA    ENDS


START PROC
        MOV AX, DATA
	MOV DS, AX
	
	
	;8255 control word , 8255 adresi: 0000h 
	MOV AL, 90H  ; mod0 porta okuma 
	OUT 06H, AL
	;00H : 8255
	;600H : DAC030
	MOV DX,200H ;ADC ;interrupt 400h
	;800H  TIMER	
	MOV FILTERS[0],50
	;TIMER
	MOV DX, 806H
	MOV AL, 00110100b ;Counter 0  2 BCD
	OUT DX,AL
	
	MOV DX,800H
	MOV AL,7DH ;5000/125=40
	OUT DX,AL
	MOV AL,0H
	OUT DX,AL
	
ENDLESS:
      ;pulse gelme kontrolünü örneklemek için:
      TEKRAR:
      ;pulse gelme kontrolü (port a için)
      MOV DX,00H
      IN AL,DX
      SHR AL,1 ; port 0'a baðlý timer pulse
      JC TEKRAR
      
      PULSE_OUT:
      MOV DX,00H
      IN AL,DX
      SHR AL,1 ; pulse çýkýþ kontrolü
      JNC PULSE_OUT
      
      
      MOV DX,200H ; dijitalleþtirme kýsmý baþlamasý için
      MOV AL,00H
      OUT DX,AL
      
      MOV DX,400H;IO2
      INTR_KONTROL:
      
      IN AL,DX
      TEST AL, 10H;ad4 1 gelene kadar
      JNZ INTR_KONTROL
      
      MOV DX,200H;1 gelince 200. adresten okuma
      IN AL, DX
      
      MOV SAMPLES[SI],AL;okuduðu deðeri daha sonra gösterebilmek için samples'a kaydettim
      INC SI
      CALL DELAY
      CMP SI,200
      JE FILTER
      
      JMP ENDLESS
      
FILTER: 
      MOV CX,199
      MOV SI,1
LOOP1:
      MOV AL,SAMPLES[SI]
      SUB AL,SAMPLES[SI-1]
      ADD AL,FILTERS[SI-1]
      PUSH CX
      MOV CL,5
      SAR AL,CL
      POP CX
      MOV FILTERS[SI],AL
      INC SI
      LOOP LOOP1
      
DAC:      
      XOR SI,SI ;diziden okumak için tekrar 0'ladým
DONGU:
      TEKRAR2:
      
      ;ayný frekansla analoga çevirmek için port A'da tekrar kontrol yaptým
      MOV DX,00H
      IN AL,DX
      SHR AL,1
      JC TEKRAR2
      
      PULSE_OUT2:
      MOV DX,00H
      IN AL,DX
      SHR AL,1
      JNC PULSE_OUT2
     
      MOV DX, 600H ;dac adresi IO3 
      MOV AL, FILTERS[SI]
      OUT DX,AL;dizideki dijital deðeri analog olarak outladýk
      INC SI;diðer indise geç
      CALL DELAY
      CMP SI,200;dizi bitiþi kontrolü
      JB DONGU      

      JMP DAC    
      

        JMP ENDLESS
	RET
START ENDP

DELAY PROC NEAR
   PUSH CX
   MOV CX,0Fh
   COUNT:
   LOOP COUNT
   POP CX
RET
DELAY ENDP

	
CODE    ENDS
        END START