global mem
global executa 
;xandin
global R1 ; MUDARAQUI
global R2 ;MUDARAQUI

global H1 ; MUDARAQUI
global H2 ;MUDARAQUI

global xSP ;MUDARAQUI

global existeErro;MUDARAQUI
global ptErro;MUDARAQUI
global posMemErro;MUDARAQUI

global CARRY;MUDARAQUI
global ZERO;MUDARAQUI
global NEGATIVO;MUDARAQUI


NULL  equ 0 
segment .data
;Variáveis de erro
	posMemErro: dw 0 ;posição da memória que deu erro
	ptErro: dq 0 ;ponteiro para a string do erro
	;Strings de erro
	erroParam: db "Parametro(s) invalido(s) na instrucao de posição %pos na memoria.",0
	erroPrivate: db "Tentativa de acessar registrador privado na instrucao de posição %pos na memoria.",0
	erroZao: db "ERRO INSTRUCAO ADDZAO/SUBZAO POSICAO %pos : endereco apontado por um registrador ira ultrapassar area da memora.",0
	erroPilha: db "ERRO INSTRUCAO PILHA POSICAO %pos : Pilha não possui valor de tamanho suficiente para o registrador.",0

	existeErro: db 0 ; bool do erro

mem: times 65535 db 0
regs: times 16  db 0 
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
desvios: dq $ADD_OP, $SUB_OP, $AND_OP,$XOR_OP, $OR_OP, $NOT_OP
		 dq $CMP_OP, $SHL_OP, $SHR_OP, $PUSH_OP,$POP_OP
        dq  $JMP_OP,$JZ_OP,$JNZ_OP,$JL_OP,$JLE_OP,$JG_OP,$JGE_OP,$JC_OP
         dq $LOOP_OP,$CALL_OP,$RET_OP,$NOP_OP,$HALT_OP
		 dq $ADDZAO_OP, $SUBZAO_OP
        dq  $LOAD_OP,$STORE_OP,$STORE_REG_OP
        ;  dq  $IN_OP,$OUT_OP,$INTR_OP

segment .text
    executa: 
          mov rdi, mem
		  mov rsi, 0 ;RSI SERÁ nosso registrador IP
		  mov r8, 0 ;O R8 será nosso bool erro
		  mov ax, 0xFFFF ;O R8 será nosso bool erro
		  mov word[xSP], 0xFFFF ;inicializa o registrador que aponta pro topo da pilha
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
ADD_OP:
	call DECO_2REGS_AND_TESTA

	;verifica se deu algum erro
	cmp r8, 1
	je RETORNO

	;MesmoTamReg:
		; RAX aponta para op2 e RBX para op1 pode ser 8 ou 16
		cmp cl,0
		jne xx16bitsreg_ADD
		; 8 bits
		; do :-)
		mov cl,byte[RAX]
		mov dl,byte[RBX]
		add dl,cl
		mov byte[RBX], dl
		call testaflag
		jmp fim_ADD
	xx16bitsreg_ADD:
		mov cx, word[RAX]
		mov dx, word[RBX]
		add dx,cx
		mov word[RBX], dx
		call testaflag
	fim_ADD:
		add si,3
		mov word[xIP],si
		jmp eterno


;Operação de subtração, REG1 <- REG1 - REG2
SUB_OP:
	call DECO_2REGS_AND_TESTA

	;verifica se deu algum erro
	cmp r8, 1
	je RETORNO

	;MesmoTamReg:
		; RAX aponta para op2 e RBX para op1 pode ser 8 ou 16
		cmp cl,0
		jne xx16bitsreg_SUB
		; 8 bits
		; do :-)
		mov cl,byte[RAX]
		mov dl,byte[RBX]
		sub dl,cl
		mov byte[RBX], dl
		call testaflag
		jmp fim_SUB
	xx16bitsreg_SUB:
		mov cx,word [RAX]
		mov dx, word [RBX]
		sub dx,cx
		mov  word [RBX],dx
		call testaflag
	fim_SUB:
		add si,3
		mov word[xIP],si
		jmp eterno

;Operação lógica AND, REG1 <- REG1 AND REG2
AND_OP:
	call DECO_2REGS_AND_TESTA

	;verifica se deu algum erro
	cmp r8, 1
	je RETORNO

	;MesmoTamReg:
		; RAX aponta para op2 e RBX para op1 pode ser 8 ou 16
		cmp cl,0
		jne xx16bitsreg_AND
		; 8 bits
		; do :-)
		mov cl,byte[RAX]
		mov dl,byte[RBX]
		and dl,cl
		mov byte[RBX], dl
		call testaflag
		jmp fim_AND
	xx16bitsreg_AND:
		mov cx,word [RAX]
		mov dx, word [RBX]
		and dx,cx
		mov  word [RBX],dx
		call testaflag
	fim_AND:
		add si,3
		mov word[xIP],si
		jmp eterno

;Operação lógica XOR, REG1 <- REG1 XOR REG2
XOR_OP:
	call DECO_2REGS_AND_TESTA

	;verifica se deu algum erro
	cmp r8, 1
	je RETORNO

	;MesmoTamReg:
		; RAX aponta para op2 e RBX para op1 pode ser 8 ou 16
		cmp cl,0
		jne xx16bitsreg_XOR
		; 8 bits
		; do :-)
		mov cl,byte[RAX]
		mov dl,byte[RBX]
		xor dl,cl
		mov byte[RBX], dl
		call testaflag
		jmp fim_XOR
	xx16bitsreg_XOR:
		mov cx,word [RAX]
		mov dx, word [RBX]
		xor dx,cx
		mov  word [RBX],dx
		call testaflag
	fim_XOR:
		add si,3
		mov word[xIP],si
		jmp eterno



;Operação lógica OR, REG1 <- REG1 OR REG2
OR_OP:
	call DECO_2REGS_AND_TESTA

	;verifica se deu algum erro
	cmp r8, 1
	je RETORNO

	;MesmoTamReg:
		; RAX aponta para op2 e RBX para op1 pode ser 8 ou 16
		cmp cl,0
		jne xx16bitsreg_OR
		; 8 bits
		; do :-)
		mov cl,byte[RAX]
		mov dl,byte[RBX]
		or dl,cl
		mov byte[RBX], dl
		call testaflag
		jmp fim_OR
	xx16bitsreg_OR:
		mov cx,word [RAX]
		mov dx, word [RBX]
		or dx,cx
		mov  word [RBX],dx
		call testaflag
	fim_OR:
		add si,3
		mov word[xIP],si
		jmp eterno

;Operação lógica NOT, REG1 <- NOT REG1
NOT_OP:
	call DECO_1REG_AND_TESTA

	;verifica se deu algum erro
	cmp r8, 1
	je RETORNO

	;rax cx
	;verifica se é um reg de 8 ou 16 bits
	cmp cl, 0
	jne xx16bitsreg_NOT
		;8 bits
		mov cl, byte[RAX]
		not cl
		mov byte[RAX], cl
		call testaflag
		jmp FIM_NOT
	xx16bitsreg_NOT:
		;16 bits
		mov cx, word[RAX]
		not cx
		mov word[RAX], cx
		call testaflag
	FIM_NOT:
		add si,2
		mov word[xIP],si
		jmp eterno

;Compara dois registradores e seta os flags
CMP_OP:
	call DECO_2REGS_AND_TESTA

	;verifica se deu algum erro
	cmp r8, 1
	je RETORNO

	;MesmoTamReg:
		; RAX aponta para op2 e RBX para op1 pode ser 8 ou 16
		cmp cl,0
		jne xx16bitsreg_CMP
		; 8 bits
		; do :-)
		mov cl,byte[RAX]
		mov dl,byte[RBX]
		sub dl, cl
		call testaflag
		jmp fim_CMP
	xx16bitsreg_CMP:
		mov cx,word [RAX]
		mov dx, word [RBX]
		sub dx,cx
		call testaflag
	fim_CMP:
		add si,3
		mov word[xIP],si
		jmp eterno

;Shift a esquerda de um registrador e seta os flags
SHL_OP:
	call DECO_1REG_AND_TESTA

	;verifica se deu algum erro
	cmp r8, 1
	je RETORNO

	;rax cx
	;verifica se é um reg de 8 ou 16 bits
	;e depois dobra o número, pois dobrar o número faz o papel do SHL, com a resalva de
			;setar o flag negativo certo
	cmp cl, 0
	jne xx16bitsreg_SHL
		;8 bits
		mov cl, byte[RAX]
		add cl, cl
		mov byte[RAX], cl
		call testaflag
		cmp cl, 0
		jge NAO_NEGATIVO_SHL
			;seta o negativo caso tenha sido passado um número que era positivo e após o SHL
					;ficou negativo
			mov byte[NEGATIVO], 1
			jmp FIM_SHL
	xx16bitsreg_SHL:
		;16 bits
		mov cx, word[RAX]
		add cx, cx
		mov word[RAX], cx
		call testaflag
		cmp cx, 0
		jge NAO_NEGATIVO_SHL
			;seta o negativo caso tenha sido passado um número que era positivo e após o SHL
					;ficou negativo
			mov byte[NEGATIVO], 1
			jmp FIM_SHL
	NAO_NEGATIVO_SHL:
		;não seta o negativo caso tenha sido passado um número que era negativo e após o SHL
					;ficou positivo
			mov byte[NEGATIVO], 0
	FIM_SHL:
		add si,2
		mov word[xIP],si
		jmp eterno

;Shift a direita de um registrador e seta os flags
SHR_OP:
	call DECO_1REG_AND_TESTA

	;verifica se deu algum erro
	cmp r8, 1
	je RETORNO

	;rax cx
	;verifica se é um reg de 8 ou 16 bits
	; e depois acha a metade do número arredondada para baixo, pois dá o mesmo resultado
			;que o SHR, porém é preciso setar os flags de acordo depois
			; e mudar o bit de mais alta ordem para 0
			; e resolver o caso exceção de -1 em binário(exemplo 8 bits): 11111111
			; o flag carry sempre será setado se e somente se for um número ímpar a se fazer o SHR
			; para setar o flag zero é preciso comparar o número resultado com 0
			; o flag negativo sempre será 0
	cmp cl, 0
	jne xx16bitsreg_SHR
		;8 bits
		mov cx, 0
		mov dx, 0
		mov cl, byte[RAX]
		mov dl, -1
		mov r9, 0
		cmp cl, -1
		je EXCECAO_SHR_8BITS
			call acha_metade
		EXCECAO_SHR_8BITS:
			and dl, 7Fh  ;seta o bit de mais alta ordem como 0
			mov byte[RAX], dl
			jmp FIM_SHR
	xx16bitsreg_SHR:
		;16 bits
		mov cx, 0
		mov dx, 0
		mov cx, word[RAX]
		mov dx, -1
		mov r9, 0
		cmp cx, -1
		je EXCECAO_SHR_16BITS
			call acha_metade
		EXCECAO_SHR_16BITS:
			and dx, 7FFFh  ;seta o bit de mais alta ordem como 0
			mov word[RAX], dx
	FIM_SHR:
		;seta os flags
		mov byte[CARRY], r9b ; se o número passado foi ímpar irá setar o carry
		mov byte[ZERO], 0
		mov byte[NEGATIVO], 0
		cmp dx, 0
		jne NAO_SETA_ZERO_SHR
			mov byte[ZERO], 1
		NAO_SETA_ZERO_SHR:
			add si,2
			mov word[xIP],si
			jmp eterno

;Empilha o valor em um registrador na pilha
PUSH_OP:
	call DECO_1REG_AND_TESTA

	;verifica se deu algum erro
	cmp r8, 1
	je RETORNO

	;rax cx
	;verifica se é um reg de 8 ou 16 bits
	;cx receberá o endereço do topo da PILHA e fará as operações nele
			;partes baixas de rdx receberá o valor do registrador e empilhará
	cmp cl, 0
	jne xx16bitsreg_PUSH
		;8 bits
		mov rcx, 0
		mov cx, word[xSP]
		dec cx
		mov dl, byte[RAX]
		mov byte[rdi+rcx], dl
		jmp FIM_PUSH
	xx16bitsreg_PUSH:
		;16 bits
		mov rcx, 0
		mov cx, word[xSP]
		sub cx, 2
		mov dx, word[RAX]
		mov word[rdi+rcx], dx
	FIM_PUSH:
		mov word[xSP],cx
		add si,2
		mov word[xIP],si
		jmp eterno


;Desempilha o valor da pilha em um registrador
POP_OP:
	call DECO_1REG_AND_TESTA

	;verifica se deu algum erro
	cmp r8, 1
	je RETORNO

	
	;bx receberá o endereço do topo da PILHA e fará as operações nele
	mov rbx, 0
	mov bx, word[xSP]
	;verifica se a pilha está vazia e mostra o erro se tiver
	cmp bx, 0xFFFF
	je EXCEDEU_PILHA

	;verifica se é um reg de 8 ou 16 bits
	cmp cl, 0
	;partes baixas do rcx receberá o valor na pilha e passará para o registrador
	jne xx16bitsreg_POP
		;8 bits
		mov cl, byte[rdi+rbx]
		mov byte[RAX], cl
		inc rbx
		mov word[xSP], bx
		jmp FIM_POP
	;ao se tratar de registradores de 16 bits, verifica se a pilha tem um valor maior
			;que 8 bytes pra passar, caso contrário mostra erro
	xx16bitsreg_POP:
		;16 bits
		cmp bx, 0xFFFE
		je EXCEDEU_PILHA
		mov cx, word[rdi+rbx]
		mov word[RAX], cx
		add rbx, 2
		mov word[xSP], bx
	FIM_POP:
		add si,2
		mov word[xIP],si
		jmp eterno
JMP_OP:
	xor rax,rax
	mov ax,word [rsi+rdi+1]
   mov rsi,rax
   jmp eterno
;INSTRUÇÃO DE DESVIO JZ_OP
JZ_OP:
    mov al,byte [ZERO]
    cmp al,1
    je JMP_OP
 nao_desvia:
    add rsi, 3
    jmp eterno
;INSTRUÇÃO DE DESVIO JNZ_OP
JNZ_OP:
    mov al,byte [ZERO]
    cmp al,0
    je JMP_OP
    jmp nao_desvia
;INSTRUÇÃO DE DESVIO JL_OP	
JL_OP:    
    mov al,byte [NEGATIVO]
    cmp al,1
    je JMP_OP
	jmp nao_desvia
;INSTRUÇÃO DE DESVIO JLE_OP
JLE_OP:
	mov al, byte [NEGATIVO]
	cmp al,1
	je JMP_OP
	mov al, byte [ZERO]
	cmp al,1
	je JMP_OP
	jmp nao_desvia
;INSTRUÇÃO DE DESVIO JG_OP
JG_OP:
	mov al, byte[NEGATIVO]
	cmp al,0
	je JMP_OP
	mov al,byte [ZERO]
	cmp al,0
	je JMP_OP
	jmp nao_desvia
;INSTRUÇÃO DE DESVIO JGE_OP
JGE_OP:
	mov al,byte [NEGATIVO]
    cmp al,0
    je JMP_OP
	jmp nao_desvia
;INSTRUÇÃO DE DESVIO JC_OP
JC_OP:
	mov al, byte[CARRY]
	cmp al,1
	je JMP_OP
	jmp nao_desvia
LOOP_OP: ; sempre faz
   xor rax,rax
   mov ax, word[H1]
   sub ax,1
   cmp ax,0
   jle FIM_LOOP_OP 
   mov word[H1], ax
   mov rdx, rsi
   mov si, word[rdi+rdx+1]
   mov word[xIP], si
   jmp eterno
FIM_LOOP_OP:
	mov word[H1],ax
	add si,3
	mov word[xIP],si
	jmp eterno
CALL_OP:
	mov rdx,rsi
	add rdx,3
	push rdx
	mov rdx,rsi
	mov si, word[rdi+rdx+1]
	mov word[xIP],si
	jmp eterno
RET_OP:
	pop rsi
	mov word[xIP],si
	jmp eterno
HALT_OP:
	jmp RETORNO
;INSTRUÇÃO ESPECIAL NOP
NOP_OP:
	add rsi,1
	jmp eterno
LOAD_OP:
	call DECO_1REG_AND_TESTA
	cmp r8,1
	je INVAL_INSTRUCTION_PARAM
	mov bl, byte[rdi+rsi+2]
	cmp bl,0
	je LOAD0
	cmp bl,1
	je LOAD1
	cmp bl,2
	je LOAD2
	cmp bl,3
	je LOAD3

LOAD0:
	cmp rcx,0
	je LOAD0_8BITS
	mov rbx,0
	mov bl, byte[rdi+rsi+3]
	shl rbx, 8
	mov r9,0
	mov r9b, byte[rdi+rsi+4]
	add rbx, r9
	mov word[rax],bx
	add rsi,5
	mov word[xIP], si
	jmp eterno

LOAD0_8BITS:
	mov bl, byte[rdi+rsi+3]
	mov byte[rax],bl
	add rsi,4
	mov word[xIP], si
	jmp eterno
LOAD1:
	add rsi,2
	mov rbx,rax
	mov r9,rcx
	call DECO_1REG_AND_TESTA
	cmp r8,1
	je INVAL_INSTRUCTION_PARAM 
	cmp r9,rcx ; Verificando se são do mesmo tipo, se não chamo o erro
	jne INVAL_INSTRUCTION_PARAM  
	cmp rcx,0 ; verificando se e 8bits, se não continuo o codigo	
	je LOAD1_8BITS
	mov r9w, word[rax]
	mov word[rdx],r9w
	add rsi,2
	mov word[xIP], si
	jmp eterno
LOAD1_8BITS:
	mov r9b, byte[rax]
	mov byte[rbx], r9b
	add rsi,2
	mov word[xIP], si
	jmp eterno
	
LOAD2:
	cmp rcx,1 ; verificando se o registrador é de 16 bits, se sim chamo o erro
	je INVAL_INSTRUCTION_PARAM
	mov rbx,0
	mov bl, byte[rdi+rsi+3]
	shl rbx, 8
	mov r9,0
	mov r9b, byte[rdi+rsi+4]
	add rbx, r9
	mov dl, byte[rdi+rbx]
	mov byte[rax],dl
	add rsi,5
	mov word[xIP], si
	jmp eterno

LOAD3:
	cmp rcx,1 ; verificando se o registrador é de 16 bits, se sim chamo o erro
	je INVAL_INSTRUCTION_PARAM
	add rsi,2
	mov rbx,rax
	mov r9,rcx
	call DECO_1REG_AND_TESTA
	cmp r8,1
	je INVAL_INSTRUCTION_PARAM 
	cmp rcx,0 ; verificando se o registrador é de 8 bits, se sim chamo o erro
	je INVAL_INSTRUCTION_PARAM 
	mov r9,0
	mov r9w, word[rax]
	mov al, byte[rdi+r9]
	mov byte[rbx], al
	add rsi, 2
	mov word[xIP], si
	jmp eterno
STORE_OP:
	add rsi,2
	call DECO_1REG_AND_TESTA
	cmp r8,1
	je INVAL_INSTRUCTION_PARAM
	cmp rcx,1
	je INVAL_INSTRUCTION_PARAM 
	mov rbx,0
	mov bl, byte[rdi+rsi-2]
	shl rbx, 8
	mov r9,0
	mov r9b, byte[rdi+rsi-1]
	add rbx, r9
	mov r9b,byte[rax]
	mov byte[rdi+rbx], r9b
	add rsi,2
	mov word[xIP], si
	jmp eterno
STORE_REG_OP:
	call DECO_1REG_AND_TESTA
	cmp r8,1
	je INVAL_INSTRUCTION_PARAM
	cmp rcx, 0
	je INVAL_INSTRUCTION_PARAM
	mov rbx, rax
	add rsi,1
	call DECO_1REG_AND_TESTA
	cmp r8,1
	je INVAL_INSTRUCTION_PARAM
	cmp rcx, 1
	je INVAL_INSTRUCTION_PARAM
	mov r9b, byte[rax]
	mov rcx,0
	mov cx, word[rbx]
	mov byte[rdi+rcx],r9b
	add rsi,2
	mov word[xIP], si
	jmp eterno
;Operação Aritmética ADDZAO
ADDZAO_OP:
	call DECO_2REGS_AND_TESTA
	
	cmp r8,1
	je RETORNO

	;verifica se os registradores são de 8 bits
	cmp rax, regs+5
	jl INVAL_INSTRUCTION_PARAM
	cmp rbx, regs+5
	jl INVAL_INSTRUCTION_PARAM
	;verifica se algum registrador está apontando para um endereço onde se somar 255 posições ultrapassará
	;a área de memória
	mov cx, word[RAX]
	add cx, 255
	cmp rcx, 65535
	jg EXCEDEU_AREA_MEMORIA_ZAO
	mov cx, word[RBX]
	add cx, 255
	cmp rcx, 65535
	jg EXCEDEU_AREA_MEMORIA_ZAO

	call SOMA_ZAO
	ret


;Operação Aritmética SUBZAO
SUBZAO_OP:
	call DECO_2REGS_AND_TESTA
	
	cmp r8,1
	je RETORNO

	;verifica se os registradores são de 8 bits
	cmp rax, regs+5
	jl INVAL_INSTRUCTION_PARAM
	cmp rbx, regs+5
	jl INVAL_INSTRUCTION_PARAM

	;verifica se algum registrador está apontando para um endereço onde se somar 255 posições ultrapassará
	;a área de memória
	mov cx, word[RAX]
	add cx, 255
	cmp rcx, 65535
	jg EXCEDEU_AREA_MEMORIA_ZAO
	mov cx, word[RBX]
	add cx, 255
	cmp rcx, 65535
	jg EXCEDEU_AREA_MEMORIA_ZAO

	;multiplica o número apontado pelo segundo registrador por -1 e depois faz a soma
	;rsi será o carry se houver e rdi o indice
	mov rcx, rdi
	push rdi
	mov rdi, 0
	mov di, word[RAX]
	add rcx, rdi
	push rsi
	push rax
	mov rdi, 0
	mov rsi, 0
	LOOP_SUBZAO:
		mov rax, qword[rcx+rdi] 
		not rax
		inc rax
		add rax, rsi
		mov rsi, 0
		mov qword[rcx+rdi], rax
		jnc CONTINUA_SUBZAO
			mov rsi, 1
		CONTINUA_SUBZAO:
			add rdi, 8
			cmp rdi, 248
			jl LOOP_SUBZAO
	
	pop rax
	pop rsi
	pop rdi
	call SOMA_ZAO
	ret




; CASO PRECISE SAIR DA EXECUÇÃO
RETORNO:
	ret








;ERROS
	INVAL_INSTRUCTION_PARAM:
		;Se algum parâmetro da instrução for inválido
		mov r8, 1
		mov byte[existeErro], r8b
		mov rax, erroParam
		mov qword[posMemErro],rsi
		mov qword[ptErro], rax
		ret

	PRIVATE_REGISTER:
		;Se tentou acessar um registrador privado
		mov r8, 1
		mov byte[existeErro], r8b
		mov rax, erroPrivate
		mov qword[posMemErro],rsi
		mov qword[ptErro], rax
		ret

	EXCEDEU_AREA_MEMORIA_ZAO:
		;Se tentou fazer alguma operacao de ADDZAO OU SUBZAO passando do endereço de memória
		mov r8, 1
		mov byte[existeErro], r8b
		mov rax, erroZao
		mov qword[posMemErro],rsi
		mov qword[ptErro], rax
		ret

	EXCEDEU_PILHA:
		;Se tentou acessar a pilha sem possuir valor grande o suficiente para o registrador
		mov r8, 1
		mov byte[existeErro], r8b
		mov rax, erroPilha
		mov qword[posMemErro],rsi
		mov qword[ptErro], rax
		ret


;FUNÇÕES
	DECO_2REGS_AND_TESTA:
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

		pop rbx
		pop dx
		
		;verifica se ocorreu erro no deco_reg
		cmp r8,1
		je RETORNO

		
		cmp rax, regs+11
		je INVAL_INSTRUCTION_PARAM

		cmp rbx, regs+11
		je INVAL_INSTRUCTION_PARAM

		; dois iguais ?
		cmp cl,dl

		jne INVAL_INSTRUCTION_PARAM
		ret

	DECO_1REG_AND_TESTA:
		mov rax, 0
		mov rdx, 0
		mov rcx, 0

		mov al,byte[rdi+rsi+1] ; op1
		call deco_reg
		
		;verifica se ocorreu erro no deco_reg
		cmp r8,1
		je RETORNO
		
		;verifica se é o reg SP
		cmp rax, regs+11
		je INVAL_INSTRUCTION_PARAM

		ret



	deco_reg:
		; IN al= c�digo reg
		; OUT cl=0 8 bits  cl=1 16 bit 
		;	RAX= endereco da area do registrador. 
		; obs:  acesso a xIP e FLAGS eh invalida
		cmp al,7
		je PRIVATE_REGISTER
		cmp al,8
		jg PRIVATE_REGISTER

		mov cl,al
		; mov cl,al
		
		mov rax,regs
		add rax,rcx
		cmp cl, 5
		jle CONTINUA_DECO
		;CONSIDERA_REGS_16BITS:
			mov rdx, 0
			mov dl, cl
			sub dl, 5
			cmp dl, 4
			jle TUDO_CONSIDERADO
			;CONSIDERA_CARRYS:
				mov dl, 4
			TUDO_CONSIDERADO:
				add rax, rdx
		CONTINUA_DECO:
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
		mov byte[ZERO],al
		mov byte[NEGATIVO],al
		jnc zflag
		;--- carry
		mov byte[CARRY],bl
		zflag:	
			jne  negflag
			; zero
			mov byte[ZERO], bl
		negflag:
			jl negSet
			ret
			negSet:
			; negativo
				mov byte[NEGATIVO], bl
				ret 
		;-------

	;soma dois números grandes
	SOMA_ZAO:
		;o rcx apontará para a posição de memória que está em H1 e o rdx de H2
		mov rcx, rdi
		mov rdx, rdi

		push rdi   ;para salvar o endereço da variavel mem
		mov rdi, 0

		mov di, word[RBX]
		add cx, di

		mov di, word[RAX]
		add dx, di
		;o rsi será o  carry da soma anterior
		;percorreremos os vetores de 8 em 8 bytes usando o rdi com indice
		
		push rsi   ;para salvar o valor de IP
		mov rdi, 0
		mov rsi, 0
		mov byte[ZERO],0
		LOOP_ZAO:
			mov rbx, qword[rcx+rdi]
			mov rax, qword[rdx+rdi]
			add rbx, rax
			add rbx,rsi
			mov rsi, 0
			mov qword[rcx+rdi], rbx
			jnc CONTINUA_ZAO
				mov rsi, 1
			CONTINUA_ZAO:
				;setar o flag zero enquanto faz a soma
				cmp rbx, 0
				je NAO_SETA_ZERO_ZAO
					mov byte[ZERO], 1
				NAO_SETA_ZERO_ZAO:		
					add rdi, 8
					cmp rdi, 248
					jl LOOP_ZAO
			
			;seta os flags carry e negativo
			mov byte[CARRY],sil
			pop rsi ;pega o valor de IP
			pop rdi ;pega a posição da variável mem
			mov byte[NEGATIVO], 0
			add rcx, 0
			jge FIM_ZAO
				mov byte[NEGATIVO], 1
				FIM_ZAO:
					ret

	;Acha a metade de um número que está no reg cx e
			;retorna o resultado  em dx
			;e retorna R9 = 0 se número no cx par ou R9 = 1 se número no cx ímpar
	acha_metade:
		mov r9, 0
		mov dx, 0
		cmp cx, 0
		jge NAO_NEGATIVO_ACHA_METADE
			LOOP_NEGATIVO_ACHA_METADE:
				dec dx
				push dx
				add dx, dx
				cmp dx, cx
				je FIM_ACHA_METADE
					pop dx
					jl ARREDONDA_PRA_CIMA
						jmp LOOP_NEGATIVO_ACHA_METADE
		NAO_NEGATIVO_ACHA_METADE:
			push dx
			je FIM_ACHA_METADE
			LOOP_NAO_NEGATIVO_ACHA_METADE:
				inc dx
				push dx
				add dx, dx
				cmp dx, cx
				je FIM_ACHA_METADE
					pop dx
					jg ARREDONDA_PRA_BAIXO
						jmp LOOP_NAO_NEGATIVO_ACHA_METADE
		ARREDONDA_PRA_BAIXO:
			mov r9, 1
			dec dx
			push dx
			jmp FIM_ACHA_METADE
		ARREDONDA_PRA_CIMA:
			mov r9, 1
			inc dx
			push dx
		FIM_ACHA_METADE:
			pop dx
			ret
