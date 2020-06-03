#include<stdio.h>
#include<stdint.h>

extern int8_t mem[];
extern int8_t R1;
extern int8_t R2;
extern int8_t existeErro;
extern char* ptErro;
extern int16_t posMemErro;
extern void executa();

int main(){
    printf("passou");
    R1 = 0x01;
    R2 = 0x02;
    mem[0] = 0x00;
    mem[1] = 0x00;
    mem[2] = 0x07;
    mem[3] = 0x27;
    
    executa();

    if  (existeErro){ //Verifica se existe erro
        int i = 0;
        while(ptErro[i] != 0){
            printf("%c", ptErro[i]); //Printa a string do erro
            i++;
        }
        printf("%d\n", posMemErro); //Printa a posição de memória do erro
    }
    printf("%d\n", R1);
    return 0;
}