#include<stdio.h>
#include<stdint.h>

extern int8_t mem[];
extern int8_t R1;
extern int8_t R2;
extern void executa();

int main(){
    printf("passou");
    R1 = 0x01;
    R2 = 0x02;
    mem[0] = 0x00;
    mem[1] = 0x00;
    mem[2] = 0x01;
    mem[3] = 0x27;
    
    executa();

    printf("%d", R1);
}