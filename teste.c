#include<stdio.h>
#include<stdint.h>

extern int8_t mem[];
extern int8_t R1; //TESTE
extern int8_t R2; //TESTE
extern int16_t H1; //TESTE
extern int16_t H2; //TESTE
extern int16_t xSP; //TESTE
extern int8_t existeErro;
extern char* ptErro;
extern int16_t posMemErro;
extern int8_t CARRY; //TESTE
extern int8_t ZERO; //TESTE
extern int8_t NEGATIVO; //TESTE
extern void executa();

int main(){

    R1 = 12;
    R2 = 31;

    H1 = 0x0009;
    H2 = 0x0001;

    mem[0] = 0x06;
    mem[1] = 0x07;
    mem[2] = 0x00;
    mem[3] = 0x00;
    mem[4] = 0x00;
    mem[5] = 0x01;
    mem[6] = 0x27;
    mem[7] = 0x07;

    R1 = 1;
    R2 = 2;

    H1 = 0;
    H2 = 0xFFFE;

    mem[0] = 0x00;
    mem[1] = 0x05;
    mem[2] = 0x06;
    mem[3] = 0x26;
    mem[4] = 0x01;
    mem[5] = 0x0A;
    mem[6] = 0x05;
    mem[7] = 0x26;
    

    executa();

    if  (existeErro){ //Verifica se existe erro
        int i = 0;
        while(ptErro[i] != 0){ //Printa o erro
            if  (ptErro[i] == '%'){
                printf("%d", posMemErro); //Printa a posição de memória do erro
                i += 4;
            }else{
                printf("%c", ptErro[i]); //Printa a string do erro
                i++;
            }
            if  (ptErro[i] == 0) printf("\n");
        }
        
    }
    if  (!existeErro) printf("R1: %d, R2: %d, SP: %d, H1: %d CARRY: %d, ZERO: %d, NEGATIVO: %d\n", 
                                R1, R2, xSP, H1, CARRY, ZERO, NEGATIVO);
    return 0;
}