/*
 * File:   newmain1.c
 * Author: yildi
 * Created on 12 ?ubat 2024 Pazartesi, 00:26
 */

#include "conf.h"
#include "lcd.h"
uint16_t AN0RES=0;
uint16_t AN1RES=0;
char* TempinSTR[16];
char* TempoutSTR[16];

void ADC_Init();
uint16_t ADC_Read(uint8_t);

void ADC_Init()
{
    TRISA = 0xff;       /*set as input port*/
    ADCON1=0b11001101;      /*ref vtg is VDD and Configure pin as analog pin*/    
    ADCON2 = 0x92;      /*Right Justified, 4Tad and Fosc/32. */
    ADRESH=0;           /*Flush ADC output Register*/
    ADRESL=0;               // ADC Clock = Fosc/8
}
uint16_t ADC_Read(uint8_t channel)
{
    int digital;
    ADCON0 =(ADCON0 & 0b11000011)|((channel<<2) & 0b00111100);      /*channel is selected i.e (CHS3:CHS0) and ADC is disabled i.e ADON=0*/
    ADCON0 |= ((1<<ADON)|(1<<GO));                   /*Enable ADC and start conversion*/
    while(ADCON0bits.GO_nDONE==1);                  /*wait for End of conversion i.e. Go/done'=0 conversion completed*/        
    digital = (ADRESH*256) | (ADRESL);              /*Combine 8-bit LSB and 2-bit MSB*/
    return(digital);
}

double termistorin(int AN0RES){
    double tempin;
    tempin = log(((10240000 / AN0RES) - 10000));
    tempin = 1 / (0.001129148 + (0.000234125 + (0.0000000876741 * tempin * tempin)) * tempin);
    tempin = tempin - 273.15;
    return tempin;
}

double termistorout(int AN1RES){
    double tempout;
    tempout = log(((10240000 / AN1RES) - 10000));
    tempout = 1 / (0.001129148 + (0.000234125 + (0.0000000876741 * tempout * tempout)) * tempout);
    tempout = tempout - 273.15;
    return tempout;
}

void menu(){
    AN0RES = ADC_Read(0); //Read AN0
    AN1RES = ADC_Read(1); //Read AN1
    double tempin = termistorin(AN0RES);
    double tempout = termistorin(AN1RES);
    sprintf(TempinSTR, "IN: %.2f%cC  ",tempin,0xdf);
    sprintf(TempoutSTR, "OUT: %.2f%cC  ",tempout,0xdf);
    LCD_Set_Cursor(1, 1);
    LCD_Write_String(TempinSTR);
    LCD_Set_Cursor(2, 1);
    LCD_Write_String(TempoutSTR);
    __delay_ms(500);
}

void main(void) {
    __delay_ms(300); //LCD power-up delay
    ADC_Init();
    I2C_Master_Init();
    LCD_Init(0X4E);    // LCD slave Address
    LCD_Clear();
    while (1){
        menu();
    }
    return;
}

