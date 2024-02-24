# 1 "../../Downloads/i2c.c"
# 1 "<built-in>" 1
# 1 "<built-in>" 3
# 288 "<built-in>" 3
# 1 "<command line>" 1
# 1 "<built-in>" 2
# 1 "C:\\Program Files\\Microchip\\xc8\\v2.46\\pic\\include\\language_support.h" 1 3
# 2 "<built-in>" 2
# 1 "../../Downloads/i2c.c" 2








#pragma warning disable 520


# 1 "C:\\Program Files\\Microchip\\xc8\\v2.46\\pic\\include\\c99\\stdint.h" 1 3



# 1 "C:\\Program Files\\Microchip\\xc8\\v2.46\\pic\\include\\c99\\musl_xc8.h" 1 3
# 5 "C:\\Program Files\\Microchip\\xc8\\v2.46\\pic\\include\\c99\\stdint.h" 2 3
# 26 "C:\\Program Files\\Microchip\\xc8\\v2.46\\pic\\include\\c99\\stdint.h" 3
# 1 "C:\\Program Files\\Microchip\\xc8\\v2.46\\pic\\include\\c99\\bits/alltypes.h" 1 3
# 133 "C:\\Program Files\\Microchip\\xc8\\v2.46\\pic\\include\\c99\\bits/alltypes.h" 3
typedef unsigned __int24 uintptr_t;
# 148 "C:\\Program Files\\Microchip\\xc8\\v2.46\\pic\\include\\c99\\bits/alltypes.h" 3
typedef __int24 intptr_t;
# 164 "C:\\Program Files\\Microchip\\xc8\\v2.46\\pic\\include\\c99\\bits/alltypes.h" 3
typedef signed char int8_t;




typedef short int16_t;




typedef __int24 int24_t;




typedef long int32_t;





typedef long long int64_t;
# 194 "C:\\Program Files\\Microchip\\xc8\\v2.46\\pic\\include\\c99\\bits/alltypes.h" 3
typedef long long intmax_t;





typedef unsigned char uint8_t;




typedef unsigned short uint16_t;




typedef __uint24 uint24_t;




typedef unsigned long uint32_t;





typedef unsigned long long uint64_t;
# 235 "C:\\Program Files\\Microchip\\xc8\\v2.46\\pic\\include\\c99\\bits/alltypes.h" 3
typedef unsigned long long uintmax_t;
# 27 "C:\\Program Files\\Microchip\\xc8\\v2.46\\pic\\include\\c99\\stdint.h" 2 3

typedef int8_t int_fast8_t;

typedef int64_t int_fast64_t;


typedef int8_t int_least8_t;
typedef int16_t int_least16_t;

typedef int24_t int_least24_t;
typedef int24_t int_fast24_t;

typedef int32_t int_least32_t;

typedef int64_t int_least64_t;


typedef uint8_t uint_fast8_t;

typedef uint64_t uint_fast64_t;


typedef uint8_t uint_least8_t;
typedef uint16_t uint_least16_t;

typedef uint24_t uint_least24_t;
typedef uint24_t uint_fast24_t;

typedef uint32_t uint_least32_t;

typedef uint64_t uint_least64_t;
# 148 "C:\\Program Files\\Microchip\\xc8\\v2.46\\pic\\include\\c99\\stdint.h" 3
# 1 "C:\\Program Files\\Microchip\\xc8\\v2.46\\pic\\include\\c99\\bits/stdint.h" 1 3
typedef int16_t int_fast16_t;
typedef int32_t int_fast32_t;
typedef uint16_t uint_fast16_t;
typedef uint32_t uint_fast32_t;
# 149 "C:\\Program Files\\Microchip\\xc8\\v2.46\\pic\\include\\c99\\stdint.h" 2 3
# 11 "../../Downloads/i2c.c" 2
# 36 "../../Downloads/i2c.c"
__bit RS;
uint8_t i2c_addr, backlight_val = 0x08;

void I2C_Init(uint32_t i2c_clk_freq);
void I2C_Start();
void I2C_Stop();
void I2C_Write(uint8_t i2c_data);
void LCD_Write_Nibble(uint8_t n);
void LCD_Cmd(uint8_t Command);
void LCD_Goto(uint8_t col, uint8_t row);
void LCD_PutC(char LCD_Char);
void LCD_Print(char* LCD_Str);
void LCD_Begin(uint8_t _i2c_addr);




void I2C_Init(uint32_t i2c_clk_freq)
{
  SSPCON1 = 0x28;
  SSPCON2 = 0x00;
  SSPSTAT = 0x00;
  SSPADD = (__XTAL_FREQ/(4 * i2c_clk_freq)) - 1;
  SSPSTAT = 0;
}

void I2C_Start()
{
  while ((SSPSTAT & 0x04) || (SSPCON2 & 0x1F));
  SEN = 1;
}

void I2C_Stop()
{
  while ((SSPSTAT & 0x04) || (SSPCON2 & 0x1F));
  PEN = 1;
}

void I2C_Write(uint8_t i2c_data)
{
  while ((SSPSTAT & 0x04) || (SSPCON2 & 0x1F));
  SSPBUF = i2c_data;
}

void I2C_Repeated_Start()
{
  while ((SSPSTAT & 0x04) || (SSPCON2 & 0x1F));
  RSEN = 1;
}

uint8_t I2C_Read(uint8_t ack)
{
  uint8_t _data;
  while ((SSPSTAT & 0x04) || (SSPCON2 & 0x1F));
  RCEN = 1;
  while ((SSPSTAT & 0x04) || (SSPCON2 & 0x1F));
  _data = SSPBUF;
  while ((SSPSTAT & 0x04) || (SSPCON2 & 0x1F));

  ACKDT = !ack;
  ACKEN = 1;
  return _data;
}



void Expander_Write(uint8_t value)
{
  I2C_Start();
  I2C_Write(i2c_addr);
  I2C_Write(value | backlight_val);
  I2C_Stop();
}

void LCD_Write_Nibble(uint8_t n)
{
  n |= RS;
  Expander_Write(n & 0xFB);
  __delay_us(1);
  Expander_Write(n | 0x04);
  __delay_us(1);
  Expander_Write(n & 0xFB);
  __delay_us(100);
}

void LCD_Cmd(uint8_t Command)
{
  RS = 0;
  LCD_Write_Nibble(Command & 0xF0);
  LCD_Write_Nibble((Command << 4) & 0xF0);
  if((Command == 0x01) || (Command == 0x02))
    __delay_ms(2);
}

void LCD_Goto(uint8_t col, uint8_t row)
{
  switch(row)
  {
    case 2:
      LCD_Cmd(0xC0 + col - 1);
      break;
    case 3:
      LCD_Cmd(0x94 + col - 1);
      break;
    case 4:
      LCD_Cmd(0xD4 + col - 1);
    break;
    default:
      LCD_Cmd(0x80 + col - 1);
  }

}

void LCD_PutC(char LCD_Char)
{
  RS = 1;
  LCD_Write_Nibble(LCD_Char & 0xF0);
  LCD_Write_Nibble((LCD_Char << 4) & 0xF0);
}

void LCD_Print(char* LCD_Str)
{
  uint8_t i = 0;
  RS = 1;
  while(LCD_Str[i] != '\0')
  {
    LCD_Write_Nibble(LCD_Str[i] & 0xF0);
    LCD_Write_Nibble( (LCD_Str[i++] << 4) & 0xF0 );
  }
}

void LCD_Begin(uint8_t _i2c_addr)
{
  i2c_addr = _i2c_addr;
  Expander_Write(0);

  __delay_ms(40);
  LCD_Cmd(3);
  __delay_ms(5);
  LCD_Cmd(3);
  __delay_ms(5);
  LCD_Cmd(3);
  __delay_ms(5);
  LCD_Cmd(0x02);
  __delay_ms(5);
  LCD_Cmd(0x20 | (2 << 2));
  __delay_ms(50);
  LCD_Cmd(0x0C);
  __delay_ms(50);
  LCD_Cmd(0x01);
  __delay_ms(50);
  LCD_Cmd(0x04 | 0x02);
  __delay_ms(50);
}

void Backlight() {
  backlight_val = 0x08;
  Expander_Write(0);
}

void noBacklight() {
  backlight_val = 0x00;
  Expander_Write(0);
}
