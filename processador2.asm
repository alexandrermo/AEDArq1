global mem
global executa 

global R1 ; MUDARAQUI
global R2 ;MUDARAQUI

extern printf ;MUDARAQUI

NULL  equ 0 
segment .data
passou: dq "passou",10,0

mem: times 65536 db 0
regs: times 17  db 0 
R1 equ $regs+0
R2 equ  $regs+1
R3 equ  $regs+2 
R4 equ  $regs+3 
R5 equ  $regs+4
H1 equ  $regs+5
H2  equ  $regs+7
xIP  equ  $regs+9 
xSP equ   $regs+11 
ZERO equ  $regs+13
NEGATIVO   equ  $regs+14 
CARRY  equ  $regs+15 
;indica 8 ou 16
x8bits:  db 0
desvios: dq $OP_ADD
		; 			,$SUB_OP,$AND_OP,$XOR_OP,$OR_OP,$NOT,$CMP_OP
        ;  dq $SHL_OP,$SHR_OP
        ;  dq $PUSH_OP,$POP_OP
        ;  dq  $JMP_OP,$JZ_OP,$JNZ_OP,$JL_OP,$JLE_OP,$JG_OP,$JGE_OP,$JC_OP
        ;  dq  $LOOP_OP,$CALL_OP,$RET_OP,$NOP_OP,$HALT_OP
        ;  dq  $LOAD_OP,$STORE_OP,$STORE_REG_OP
        ;  dq  $IN_OP,$OUT_OP,$INTR_OP
        ;  dq  $ADDZAO_OP,$SUBZAO_OP 

segment .text
    executa: 
          mov rdi, mem
		  mov rsi, 0 ;RSI SERÁ nosso registrador IP
    eterno:
		  mov rdx,0
          mov dl, byte[mem+rsi]
          cmp dl,26h
          jl execx
          ; invalid instruct
          ; print error return
          ret
     execx:
         jmp qword[desvios+edx*8]

         ;C�digo de M�quina	00h  BYTE1 BYTE2
;Algoritmo	REG1<-REG1+REG2
;Descri��o	 Coloca em   REG1 o valor de REG1+REG2
;Considera��es	REG1 e REG2 devem ser ou de 8 ou de 16 bits os dois. Caso a soma ultrapasse a capacidade de armazenamento de REG1 o flag CARRY � setado (1).
;Se o bit de mais alta ordem de REG1 for setado NEGATIVO � setado (1)
;Se REG1==0 -> ZERO=1 
OP_ADD:
; obtem o codigo dos  registradores e verifica se sao iguais.
; decodifica op1
	mov rax, 0
	mov rdx, 0
	mov rcx, 0

	mov al,byte[rdi+rsi+1] ; op1
        call deco_reg
        push cx ; 8 ou 16
	push rax ; ponteiro area
;decodifica op2
	mov al,byte [rdi+rsi+2] ; op2
        call deco_reg
 	; cl e rax tem valores.
; compara.
	pop rbx
	pop dx
	; dois iguais ?
	cmp cl,dl

	je   MesmoTamReg
	; tam diferentes
	; je INVAL_INSTRUCTIONMUDARAQUI
MesmoTamReg:
	; RAX aponta para op2 e RBX para op1 pode ser 8 ou 16
	cmp cl,0
	jne xx16bitsreg
	; 8 bits
	; do :-)
	mov cl,byte[RAX]
	mov dl,byte[RBX]
	add dl,cl
	mov  byte [RBX],dl
	call testaflag
	jmp fim_ADD
xx16bitsreg:
	mov cx,word [RAX]
	mov dx, word [RBX]
	add dx,cx
	mov  byte [RBX],dl
	call testaflag
fim_ADD:
	add si,3
	mov word[xIP],si
	jmp eterno

deco_reg:
; IN al= c�digo reg
; OUT cl=0 8 bits  cl=1 16 bit 
;	RAX= endereco da area do registrador. 
; obs:  acesso a xIP e FLAGS eh invalida
	cmp al,7
	je deco_reg
	cmp al,8
	jg deco_reg
; ponteiro �rea
	mov cl,al
    ; mov cl,al
	
	mov rax,regs
	add rax,rcx
	; 8 ou 16
	cmp cl,4
	jg x16breg
	; 8 bits
	mov rcx, 0
	ret
x16breg:
	mov rcx, 1
	ret

;-------- 
; see flags 
testaflag:
	mov al,0
	mov bl,1
	mov byte[CARRY],al
	jnc zflag
	;--- carry
	mov byte [CARRY],bl
zflag:	
	jne  negflag
	mov byte [ZERO],bl
	mov byte [NEGATIVO], al
	ret
negflag:
	mov byte [ZERO],al
	mov byte [NEGATIVO], bl
    ret 
;-------