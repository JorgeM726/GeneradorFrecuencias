PROCESSOR 16F887
#include <xc.inc>
    
  CONFIG FOSC=INTRC_NOCLKOUT	//oscilador interno
  CONFIG WDTE=OFF   // WDT disabled (reinicio repetitivo de pic)
  CONFIG PWRTE=OFF   // PWRT enabled (espera de 72ms al iniciar)
  CONFIG MCLRE=OFF  // El pin de MCLR se utiliza como I/O
  CONFIG CP=OFF    //Sin protección de código
  CONFIG CPD=OFF   //Sin protección de datos
  
  CONFIG BOREN=OFF  // Sin reinicio cuando el voltaje de alimentación baja de 4V
  CONFIG IESO=OFF   //Reinicio sin cambio de reloj de interno a externo
  CONFIG FCMEN=OFF  //Cambio de reloj externo a interno en caso de fallo
  CONFIG LVP=OFF	    //programación en bajo voltaje permitida
  
; configuration word 2
   CONFIG WRT=OFF  //Protección de autoescritura por el programa desactivada
   CONFIG BOR4V=BOR40V	//Reinicio abajo de 4V, (BOR21V-2.1V)
   


 ;----------------variables----------------- 
PSECT udata_bank0   
  
  
  contsin:	DS 1 ;Contador para utilizar la tabla senoidal
  contsq:	DS 1 ;Contador para utilizar la tabla cuadrada
  conttri:	DS 1 ;Contador para utilizar la tabla triangular
  freq:		DS 1 ;Contador para aumentar la frecuencia
  carga:	DS 1 ;Variable para mandar precarga a tmr0
  controldisp:	DS 1 ;Contador para multiplexado
  cuenta1:	DS 1 ;Variable para delay entre displays
  
    
    
;--------------variables Temporales---------------
PSECT udata_shr
  W_TEMP:	DS 1	    
  STATUS_TEMP:  DS 1

PSECT resVect, class=CODE, abs, delta=2
;-----------vector reset--------------
ORG 00h     ;posicion 0000h para el reset
resetVec:
    PAGESEL main
    goto main

PSECT intVect, class=CODE, abs, delta=2
;-----------vector interrupt--------------
ORG 04h     ;posicion 0004h para las interrupciones
    
push:
    movwf	W_TEMP
    swapf	STATUS, W
    movwf	STATUS_TEMP	;guardar w y status

isr:
    btfsc	RBIF	;chequear bandera de interrupt de puerto b
    call	int_iocb
    btfsc	T0IF		;chequear interrupt de tmr0
    call	T0_int
   
    
pop:
    swapf   STATUS_TEMP, W
    movwf   STATUS
    swapf   W_TEMP, F
    swapf   W_TEMP, W	    ;regresar w y status
    retfie
    
;---------------Aumento y decremento de frecuencia---------------  
int_iocb:
    banksel	PORTA    
    btfss	PORTB, 0    
    call	freq_inc
    btfss	PORTB, 1
    call	freq_dec
    bcf		RBIF	    ;limpiar bandera de interrupción
    return

freq_inc:
    incf	freq		    ;aumentar frecuencia
    movf	freq, W
    call	tablaFrecuencias    ;Llamar a tabla con la precarga 
    movwf	carga		    ;Mover a precarga utilizada en reiniciotmr0
    return
freq_dec:
    
    decf	freq		    ;aumentar frecuencia
    movf	freq, W
    call	tablaFrecuencias    ;Llamar a tabla con la precarga 
    movwf	carga		    ;Mover a precarga utilizada en reiniciotmr0
    return

;---------------Selección de onda y reinicio timer---------------   
T0_int:
    
    call	reinicio_tmr0 ;reiniciar el tmr0 con la frecuencia variable
    btfss	PORTB,4
    call	cuadrada
    btfss	PORTB,5
    call	triangular
    btfss	PORTB, 6
    call	sinusoidal
    return
    
;-----------------------Onda triangular---------------------   
    
triangular:
    
    incf	conttri		;incrementar contador para puntero
    movf	conttri, W	;enviar a tabla 
    call	tria
    movwf	PORTD
    
    return
    
;-----------------------Onda senoidal--------------------- 

sinusoidal:
    incf	contsin		;incrementar contador para puntero
    movf	contsin, W	;enviar a tabla
    call	sin
    movwf	PORTD
   
    return
;-----------------------Onda cuadrada---------------------     
cuadrada:
    
    incf	contsq		;incrementar contador para puntero
    movf	contsq, W	;enviar a tabla
    call	squ
    movwf	PORTD
   
    return
    
    

    
    

;--------------------CODIGO---------------------------
PSECT code, delta=2, abs
ORG 100h    ; posicion para le codigo

;---------------------Tablas de redireccionamiento--------------------------- 
 

 ;-----------------------Tabla para frecuencias---------------------     

tablaFrecuencias:
	CLRF PCLATH
	BSF	 PCLATH, 0          ; 0100h
	andlw 0x0f
	ADDWF   PCL		    ; El valor del PC se suma con w
	RETLW	7	;989
	RETLW	21	;1047
	RETLW	34	;1107
	RETLW	47	;1175
	RETLW	59	;1246
	RETLW	70	;1318
	RETLW	81	;1398.5
	RETLW	91	;1481.5
	RETLW	100	;1565
	RETLW	109	;1658.5
	RETLW	118	;1763.5
	RETLW	126	;1870
	RETLW	133	;1972.5
	RETLW	140	;2087.5
	RETLW	147	;2217.5
	RETLW	153	;2342
	RETURN
	
	
;-----------------------Tablas para ondas ---------------------     

sin:
	CLRF PCLATH
	BSF	 PCLATH, 0          ; 0100h
	andlw 0x3f
	ADDWF   PCL		    ; El valor del PC se suma con w
	RETLW	128
	RETLW	140
	RETLW	152
	RETLW	165
	RETLW	176
	RETLW	188
	RETLW	198
	RETLW	208
	RETLW	218
	RETLW	226
	RETLW	234
	RETLW	240
	RETLW	245
	RETLW	250
	RETLW	253
	RETLW	254
	RETLW	255
	RETLW	254
	RETLW	253
	RETLW	250
	RETLW	245
	RETLW	240
	RETLW	234
	RETLW	226
	RETLW	218
	RETLW	208
	RETLW	198
	RETLW	188
	RETLW	176
	RETLW	165
	RETLW	152
	RETLW	140
	RETLW	128
	RETLW	115
	RETLW	103
	RETLW	90
	RETLW	79
	RETLW	67
	RETLW	57
	RETLW	47
	RETLW	37
	RETLW	29
	RETLW	21
	RETLW	15
	RETLW	10
	RETLW	5
	RETLW	2
	RETLW	1
	RETLW	0
	RETLW	1
	RETLW	2
	RETLW	5
	RETLW	10
	RETLW	15
	RETLW	21
	RETLW	29
	RETLW	37
	RETLW	47
	RETLW	57
	RETLW	67
	RETLW	79
	RETLW	90
	RETLW	103
	RETLW	115	  
	RETURN

squ:
	CLRF PCLATH
	BSF	 PCLATH, 0          ; 0100h
	andlw 1
	ADDWF   PCL		    ; El valor del PC se suma con w
	RETLW   255	    ; 1	        
	RETLW   0	    ; 0	 
	RETURN
	
tria:
	CLRF PCLATH
	BSF	 PCLATH, 0          ; 0100h
	andlw 0x1f
	ADDWF   PCL		    ; El valor del PC se suma con w
	RETLW	16
	RETLW	32
	RETLW	48
	RETLW	64
	RETLW	80
	RETLW	96
	RETLW	112
	RETLW	128
	RETLW	143
	RETLW	159
	RETLW	175
	RETLW	191
	RETLW	207
	RETLW	223
	RETLW	239
	RETLW	255
	RETLW	239
	RETLW	223
	RETLW	207
	RETLW	191
	RETLW	175
	RETLW	159
	RETLW	143
	RETLW	128
	RETLW	112
	RETLW	96
	RETLW	80
	RETLW	64
	RETLW	48
	RETLW	32
	RETLW	16
	RETLW	0

	RETURN
	
	
;--------------------Tablas para displays------------------	
tablaDisp:
	CLRF PCLATH
	BSF	 PCLATH, 0          ; 0100h
	andlw 3
	ADDWF   PCL		    ; El valor del PC se suma con w
	RETLW   0b00000001	    ; 1	    
	RETLW   0b00000010	    ; 1	    
	RETLW   0b00000100	    ; 1	    
	RETLW   0b00001000	    ; 1  
	 
	
	RETURN
	


 disp1:
	CLRF PCLATH
	BSF	 PCLATH, 0          ; 0100h
	andlw 0x0f
	ADDWF   PCL		    ; El valor del PC se suma con w
	RETLW	0b10011000	    	;989
	RETLW	0b11111000	    	;1047
	RETLW	0b11111000	    	;1107
	RETLW	0b10010010	    	;1175
	RETLW	0b10000010	    	;1246
	RETLW	0b10000000	    	;1318
	RETLW	0b10000000	    	;1398.5
	RETLW	0b11111001	    	;1481.5
	RETLW	0b10010010	    	;1565
	RETLW	0b10000000	    	;1658.5
	RETLW	0b10110000	    	;1763.5
	RETLW	0b11000000	    	;1870
	RETLW	0b10100100	    	;1972.5
	RETLW	0b11111000	    	;2087.5
	RETLW	0b11111000	    	;2217.5
	RETLW	0b10100100	    	;2342
	RETURN
disp2:
	CLRF PCLATH
	BSF	 PCLATH, 0          ; 0100h
	andlw 0x0f
	ADDWF   PCL		    ; El valor del PC se suma con w
	RETLW	0b10000000    	    	;0989
	RETLW	0b10011001    	    	;1047
	RETLW	0b11000000    	    	;1107
	RETLW	0b11111000    	    	;1175
	RETLW	0b10011001    	    	;1246
	RETLW	0b11111001    	    	;1318
	RETLW	0b10011000    	    	;1398.5
	RETLW	0b10000000    	    	;1481.5
	RETLW	0b10000010    	    	;1565
	RETLW	0b10010010    	    	;1658.5
	RETLW	0b10000010    	    	;1763.5
	RETLW	0b11111000    	    	;1870
	RETLW	0b11111000    	    	;1972.5
	RETLW	0b10000000    	    	;2087.5
	RETLW	0b11111001    	    	;2217.5
	RETLW	0b10011001    	    	;2342
	RETURN
disp3:
	CLRF PCLATH
	BSF	 PCLATH, 0          ; 0100h
	andlw 0x0f
	ADDWF   PCL		    ; El valor del PC se suma con w
	RETLW	0b10011000	    	;0989
	RETLW	0b11000000    	    	;1047
	RETLW	0b11111001    	    	;1107
	RETLW	0b11111001    	    	;1175
	RETLW	0b10100100    	    	;1246
	RETLW	0b10110000    	    	;1318
	RETLW	0b10110000    	    	;1398.5
	RETLW	0b10011001    	    	;1481.5
	RETLW	0b10010010    	    	;1565
	RETLW	0b10000010    	    	;1658.5
	RETLW	0b11111000    	    	;1763.5
	RETLW	0b10000000    	    	;1870
	RETLW	0b10011000    	    	;1972.5
	RETLW	0b11000000    	    	;2087.5
	RETLW	0b10100100    	    	;2217.5
	RETLW	0b10110000    	    	;2342
	RETURN
disp4:
	CLRF PCLATH
	BSF	 PCLATH, 0          ; 0100h
	andlw 0x0f
	ADDWF   PCL		    ; El valor del PC se suma con w
	RETLW	0b11000000    	    	;0989
	RETLW	0b11111001    	    	;1047
	RETLW	0b11111001    	    	;1107
	RETLW	0b11111001    	    	;1175
	RETLW	0b11111001    	    	;1246
	RETLW	0b11111001    	    	;1318
	RETLW	0b11111001    	    	;1398.5
	RETLW	0b11111001    	    	;1481.5
	RETLW	0b11111001    	    	;1565
	RETLW	0b11111001    	    	;1658.5
	RETLW	0b11111001    	    	;1763.5
	RETLW	0b11111001    	    	;1870
	RETLW	0b11111001    	    	;1972.5
	RETLW	0b10100100    	    	;2087.5
	RETLW	0b10100100    	    	;2217.5
	RETLW	0b10100100    	    	;2342
	RETURN

;-------------------Configuración de puertos, reloj, tmr0 e interrupciones	
main:
    banksel	    ANSEL	 
    clrf	    ANSEL	
    clrf	    ANSELH
    banksel	    TRISA	 
    clrf	    TRISA
    banksel	    TRISE
    clrf	    TRISE
    banksel	    TRISC	
    clrf	    TRISC
    
   
    movlw	    0xFF
    movwf	    TRISB
    
    bcf		    OPTION_REG, 7 ;Pullups de PORTB
    movlw	    0xFF
    movwf	    WPUB
    clrf	    TRISD	;PORTD como salida
    
    call	    config_reloj	
    call	    config_ioc	
    call	    int_enable
    call	    timer0
    
    
    banksel	    PORTA	;se limpian los puertos
    clrf	    PORTA
    clrf	    PORTB
    clrf	    PORTC
    clrf	    PORTD
    clrf	    PORTE
    movlw	    0
    movwf	    freq
    
    
   
;----------------------------------Loop principal---------------------    
loop:
    
    ;--------Manejo de displays-----
    
    incfsz	cuenta1, f
    goto	$+5
    incf	controldisp, f
    movf	controldisp, w
    call	tablaDisp
    movwf	PORTA
    
    ;------Selección de funcionamiento de display para cada onda
    btfss	PORTB, 4
    call	funcCuadrada
    btfss	PORTB,5
    call	funcTriangular
    btfss	PORTB,6
    call	funcSin
    
     
    goto loop
    
    
;-----------------------Funcionamiento de displays para onda cudrada-------------------------     
funcCuadrada:
    
    btfss PORTB,7
    call khz
    btfsc PORTB,7
    call hz
   
    return
hz:
    bsf		PORTE,0
    bcf		PORTE,1
    btfsc	PORTA,0
    call	d11
    btfsc	PORTA,1
    call	d22
    btfsc	PORTA, 2
    call	d33
    btfsc	PORTA,3
    call	d44
    return
    
khz:
    bsf		PORTE,1
    bcf		PORTE,0
    bcf		PORTE,0
    btfsc	PORTA,0
    call	d1
    btfsc	PORTA,1
    call	d2
    btfsc	PORTA, 2
    call	d3
    btfsc	PORTA,3
    call	d4
    return
    
d1:
    movf	freq, W
    call	disp3
    movwf	PORTC
    return
d2:
    movf	freq, W
    call	disp4
    movwf	PORTC
   
    return
d3:
    movlw	0b11000000   
    movwf	PORTC
    movwf	PORTC
    return
d4:
    movlw	0b11000000   
    movwf	PORTC
    return
d11:
    movf	freq, W
    call	disp1
    movwf	PORTC
    return
d22:
    movf	freq, W
    call	disp2
    movwf	PORTC
    
    return
d33:
    movf	freq, W
    call	disp3
    movwf	PORTC
    return
d44:
    movf	freq, W
    call	disp4
    movwf	PORTC
    return
;-----------------------Funcionamiento de displays para onda senoidal-------------------------     

funcSin:
    clrf	PORTE
    btfsc	PORTA,0
    call	ds1
    btfsc	PORTA,1
    call	ds2
    btfsc	PORTA, 2
    call	ds3
    btfsc	PORTA,3
    call	ds4
    return
ds1:
   movlw	0b10000110	     	    	    
    movwf	PORTC
    return
ds2:
   movlw	0b11001000	    	    	    
    movwf	PORTC
    
    return
ds3:
    movlw	0b11111001	    	    	    
    movwf	PORTC
    return
ds4:
    movlw	0b10010010	    	    
    movwf	PORTC
    return
;-----------------------Funcionamiento de displays para onda triangular-------------------------     

funcTriangular:
    clrf	PORTE
    movlw	0b10110110	    
    movwf	PORTC
    return

;--------------------------Configuración de reloj, interrupciones y timer-----------        
config_ioc:
    banksel	    TRISA
    movlw	    0xFF
    movwf	    IOCB ;INterrupciones on change de PORTB
    banksel	    PORTA
    movf	    PORTB, W
    bcf		    RBIF    ;limpiar bandera de interrupt
    return
    
config_reloj:
    BANKSEL	    OSCCON
    bcf		    OSCCON, 3	    ;Oscilador interno a 8Mhz
    bsf		    OSCCON, 4
    bsf		    OSCCON, 5
    bsf		    OSCCON, 6
    return
    
timer0:
    BANKSEL	    OPTION_REG
    bcf		    T0CS	    ;clock interno
    bcf		    T0SE            ;edge
    bcf		    PSA		;asignar prescaler a tmr0
    bcf		    PS2		;TMR0 con prescaler 1:8
    bcf		    PS1
    bsf		    PS0      
    banksel	    PORTA
    return
    

reinicio_tmr0:
    movf	    carga, W
    movwf	    TMR0    ;cargar  a tmr0 para iniciar cuenta otra vez
    bcf		    T0IF    ;limpiar bandera
    return


    
int_enable:
    bsf		GIE     ;habilitar interrupciones globales
    bsf		RBIE	;habilitar interrupción del portb
    bcf		RBIF	;bajar bandera
    bsf		T0IE	;habilitar interrupción de tmr0
    bcf		T0IF	;bajar bandera
    bsf		TMR1IE
    bcf		TMR0IF
    
    return
    


END