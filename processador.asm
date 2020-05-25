global mem 

section .data 

    mem: times 65536 db  0

    regs: times 17  db 0  

    R1 equ $regs+0 
    R2 equ  $regs+1 
    R3 equ  $regs+2  
    R4 equ  $regs+3 
    R5 equ  $regs+4 
    H1 equ  $regs+5 
    H2  equ  $regs+7 
    IP  equ  $regs+9  
    SP equ  $regs+11 
    ZERO equ  $regs+13 
    NEGATIVO  equ  $regs+14  
    CARRY  equ  $regs+15  

    ;indica 8 ou 16 

    8bits:  db 0 


section .text
    exec:  
          mov rdi, mem 
    eterno: 

          mov si, word[$IP] 
          cmp si,17h 
          jl execx 
          ; invalid instruct 
          ; print error return 
          ret 
     execx: 
         jmp [desvio+si*8] 

;Código de Máquina00h  BYTE1 BYTE2 
;AlgoritmoREG1<-REG1+REG2 
;Descrição Coloca em   REG1 o valor de REG1+REG2 
;ConsideraçõesREG1 e REG2 devem ser ou de 8 ou de 16 bits os dois. Caso a soma ultrapasse a capacidade de armazenamento de REG1 o flag CARRY é setado (1). 
;Se o bit de mais alta ordem de REG1 for setado NEGATIVO é setado (1) 
;Se REG1==0 -> ZERO=1  
    OP_ADD: 
        ; obtem o codigo dos  registradores e verifica se sao iguais. 
        ; decodifica op1 
        mov al,byte [rdi+IP+1] ; op1 
        call deco_reg 
        push cl ; 8 ou 16 
        push rax ; ponteiro area 

        ;decodifica op2 
        mov al,byte [rdi+IP+2] ; op2 
        call deco_reg 

        ; cl e rax tem valores. 
        ; compara. 
        pop rbx 
        pop ch 

        ; dois iguais ? 
        cmp cl,ch 
        je   MesmoTamReg 

        ; tam diferentes 
        je INVAL_INSTRUCTION 

        MesmoTamReg: 
            ; RAX aponta para op2 e RBX para op1 pode ser 8 ou 16 
            cmp cl,0 
            jne 16bitsreg 
            ; 8 bits 
            ; do :-) 
            mov cl,byte [RAX] 
            mov ch, byte [RBX] 
            add ch,cl 
            mov  byte [RBX],ch 
            call testaflag 
            jmp fim_ADD 

            16bitsreg: 
                mov cx,word [RAX] 
                mov dx, word [RBX] 
                add dx,cx 
                mov  byte [RBX],dx 

            fim_ADD: 
                add si,3 
                mov word [$IP],si 
                jmp eterno 

    deco_reg:
        ; IN al= código reg 
        ; OUT cl=0 8 bits  cl=1 16 bit  
        ;RAX= endereco da area do registrador.  
        ; obs:  acesso a IP e FLAGS eh invalida 

        cmp al,7 
        je inval_reg 
        cmp al,8 
        jg inval_reg 
        ; ponteiro area 
        mov rax,[regs+al*2]   ; note que isso leva a mudar regs para regs: times 11 dw  
        ; 8 ou 16 
        cmp al,4 
        jg 16breg 
        ; 8 bits 
        mov cl,0  
        ret 

        16breg: 
            mov cl,1 
            ret 
    ;--------  
    ; see flags  

    testaflag: 
        mov al,0 
        mov ah,1 
        mov byte[$CARRY],al 
        jnc zflag 
        ;--- carry 
        mov byte [$CARRY],ah 

        zflag:jne  negflag 

        mov byte [$ZERO],ah 
        mov byte [$NEGATIVO], al 
        jmp fim_ADD 

        negflag: 
            mov byte [$ZERO],al 
            mov byte [$NEGATIVO], ah 
;------- 