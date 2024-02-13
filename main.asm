//******************************************************************************
//Universidad del Valle de Guatemala
//IE2023: Programacion de Microcontroladores
//Proyecto: Laboratorio_2.asm
//Author : Fernando Gabriel Caballeros Cu
//Hardware : ATMega328P
//Creado : 05/02/2023
//******************************************************************************
//Encabezado
//******************************************************************************
.include "M328PDEF.inc"
.cseg 
.org 0x00
//******************************************************************************
//Stack
//******************************************************************************
LDI R16, LOW(RAMEND)
OUT SPL, R16 
LDI R17, HIGH(RAMEND)
OUT SPH, R17
//******************************************************************************
//Configuración
//******************************************************************************
Setup:
	LDI R16, (1 << CLKPCE)
	STS CLKPR, R16					//SE HABILITA EL PRESCALER
	LDI R16, 0b0000_0100
	STS CLKPR, R16					//FRECUENCIA DE 1MGHz

	LDI R16, 0b0000_0101			//PULLUPS en PORTC
	OUT PORTC, R16	
	
	LDI R16, 0x1F
	OUT DDRB, R16					//ENTRADAS Y SALIDAS DEL PUERTOB

	LDI R16, 0b0010_0000			//ENTRADAS Y SALIDAS DEL PUERTOC
	OUT DDRC, R16					

	LDI R16, 0xFF
	OUT DDRD, R16					//ENTRADAS Y SALIDAS DEL PUERTOD


	CALL TIMER_0					//SE CONMIENZA EL TIMER0

	tabla7seg: .DB 0x40, 0x79, 0x24, 0x30, 0x19, 0x12, 0x02, 0x78, 0x00, 0x10, 0x08, 0x03, 0x46, 0x21, 0x06, 0x0E

Main:
	LDI ZH, HIGH(tabla7seg << 1)
	LDI ZL, LOW(tabla7seg << 1)
	LPM R19, Z
	SBRS R19, 0
	CBI	PORTD, PD2
	SBRC R19, 0
	SBI PORTD, PD2
	SBRS R19, 1
	CBI	PORTD, PD3
	SBRC R19, 1
	SBI PORTD, PD3
	SBRS R19, 2
	CBI	PORTD, PD4
	SBRC R19, 2
	SBI PORTD, PD4
	SBRS R19, 3
	CBI	PORTD, PD5
	SBRC R19, 3
	SBI PORTD, PD5
	SBRS R19, 4
	CBI	PORTD, PD6
	SBRC R19, 4
	SBI PORTD, PD6
	SBRS R19, 5
	CBI	PORTD, PD7
	SBRC R19, 5
	SBI PORTD, PD7
	SBRS R19, 6
	CBI	PORTB, PB0
	SBRC R19, 6
	SBI PORTB, PB0

	CLR R16
	CLR R17
	CLR R18
	CLR R21
	CLR R22
	CLR R23

	LDI R20, 0x10

Loop:

	IN R16, TIFR0			//CARGAR LAS BANDERAS EN DONDE ESTA EL OVERFLOW A R16
	SBRS R16, TOV0			//EN CASO ESTE ENCENDIDA, LE IMPEDIRA EL REGRESO A LOOP
	RJMP Loop

	LDI R16, 98 
	OUT TCNT0, R16
	SBI TIFR0, TOV0 
	
	MOV R18, R21			//ANTIREBOTE
	IN R21, PINC
	CP R21, R18
	BREQ timer_cont
	CALL Delay
	IN R21, PINC
	CP R18, R21
	BREQ timer_cont
	
	SBRS R21, PC0			//BOTON PARA INCREMENTAR EL DISPLAY
	RJMP inc_disp
	SBRS R21, PC2			//BOTON PARA DECREMENTAR EL DISPLAY
	RJMP dec_disp

timer_cont:

	CPI R16, 0x0F			//SI EL CONTADOR COMPLETA LOS 4 BITS SE REINICIA
	BRNE inc_cont
	RJMP reset_cont
//******************************************************************************
//Subrutinas
//******************************************************************************
TIMER_0:			//MODO NORMAL, PRESCALER 1024
	OUT TCCR0A, R16 

	LDI R16, (1 << CS02) | (1 << CS00)
	OUT TCCR0B, R16 

	LDI R16, 98
	OUT TCNT0, R16
	RET

;******************************************************************************
//CONTADOR DE 4 BITS
inc_cont:
	CPI R22, 9
	BREQ inc_
	INC R22
	RJMP Loop
inc_:
	INC R17
	CLR R22
	RJMP leds_cont

reset_cont:
	LDI R17, 0x00
	RJMP leds_cont

//LEDS DEL CONTADOR DE 4 BITS
leds_cont:
	CALL alarma
	SBRS R17, 0
	CBI	PORTB, PB1
	SBRC R17, 0
	SBI PORTB, PB1
	SBRS R17, 1
	CBI	PORTB, PB2
	SBRC R17, 1
	SBI PORTB, PB2
	SBRS R17, 2
	CBI	PORTB, PB3
	SBRC R17, 2
	SBI PORTB, PB3
	SBRS R17, 3
	CBI	PORTB, PB4
	SBRC R17, 3
	SBI PORTB, PB4
	RJMP Loop

//DISPLAY
inc_disp:
	INC ZL
	INC R23
	CPI R19, 0x0E
	BREQ reset_disp_1
	LPM R19, Z
	RJMP leds_display7
reset_disp_1:
	LDI ZL, LOW(tabla7seg << 1)
	LPM R19, Z
	CLR R23
	RJMP leds_display7

dec_disp:
	DEC ZL
	DEC R23
	CPI R19, 0x40
	BREQ reset_disp_2
	LPM R19, Z
	RJMP leds_display7
reset_disp_2:
	ADD ZL, R20
	LPM R19, Z
	LDI R23, 0x0F
	RJMP leds_display7
//LEDS DEL DISPLAY
leds_display7:
	SBRS R19, 0
	CBI	PORTD, PD2
	SBRC R19, 0
	SBI PORTD, PD2
	SBRS R19, 1
	CBI	PORTD, PD3
	SBRC R19, 1
	SBI PORTD, PD3
	SBRS R19, 2
	CBI	PORTD, PD4
	SBRC R19, 2
	SBI PORTD, PD4
	SBRS R19, 3
	CBI	PORTD, PD5
	SBRC R19, 3
	SBI PORTD, PD5
	SBRS R19, 4
	CBI	PORTD, PD6
	SBRC R19, 4
	SBI PORTD, PD6
	SBRS R19, 5
	CBI	PORTD, PD7
	SBRC R19, 5
	SBI PORTD, PD7
	SBRS R19, 6
	CBI	PORTB, PB0 
	SBRC R19, 6
	SBI PORTB, PB0
	RJMP timer_cont

//DELAY
delay:
	LDI R16, 100
Ldelay:
	DEC R16
	BRNE Ldelay 
	RET

//ALARMA
alarma:
	CP R17, R23		//COMPARA LOS REGISTROS
	BREQ alarm
	RET
alarm:
	CLR R17
	SBIS PORTC, PC5
	RJMP on
	RJMP off
on:
	SBI PORTC, PC5	
	RET
off:
	CBI PORTC, PC5
	RET