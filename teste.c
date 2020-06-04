#include<stdio.h>
#include<stdint.h>

extern int8_t mem[];
extern int8_t R1; //TESTE
extern int8_t R2; //TESTE
extern int16_t H1; //TESTE
extern int16_t H2; //TESTE
extern int8_t existeErro;
extern char* ptErro;
extern int16_t posMemErro;
extern int8_t CARRY; //TESTE
extern int8_t ZERO; //TESTE
extern int8_t NEGATIVO; //TESTE
extern void executa();

int main(){
    R1 = 0x00;
    R2 = 0x00;

    H1 = 0x0000;
    H2 = 0x0000;

    mem[0] = 0x04;
    mem[1] = 0x05;
    mem[2] = 0x06;
    mem[3] = 0x27;
    
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
            if  (ptErro[i+1] == 0) printf("\n");
        }
        
    }
    printf("R1: %d, H1: %d, CARRY: %d, ZERO: %d, NEGATIVO: %d\n", R1, H1, CARRY, ZERO, NEGATIVO);
    return 0;
}