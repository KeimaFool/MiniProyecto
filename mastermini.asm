;*******************************************************************************
;                                                                              
;    LAB8                           
;    26/10/2018                                               
;    Sang Woo Shin Ji                                                     
;    15372                                    
;    Microcontroladores Seccion 30                                                 
;    Description:   Mini Proyecto
;                                                                              
;*******************************************************************************
#include "p16f887.inc"

; CONFIG1
; __config 0xF0F1
 __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF

;*******************************************************************************
;VARIABLES
;*******************************************************************************
GPR_VAR        UDATA
W_TEMP	    RES	1
STATUS_TEMP RES	1
DELAY1	    RES 1
DELAY2	    RES 1
SERVO	    RES 1
	
	
	
RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START                   ; go to beginning of program

    ;Interrupciones
ISR_VECT  CODE    0x0004
  
    PUSH:
    MOVWF W_TEMP
    SWAPF STATUS,W
    MOVWF STATUS_TEMP
  ISR:
    
  POP:
    SWAPF STATUS_TEMP,W
    MOVWF STATUS
    SWAPF W_TEMP,F
    SWAPF W_TEMP,W
    RETFIE	

MAIN_PROG CODE                      ; let linker place main program

START:
 
    SETUP:
    BANKSEL ANSEL ;MANEJO DE PUERTOS
    CLRF ANSEL
    CLRF ANSELH
    BSF ANSEL,0
    BANKSEL TRISA
    BSF OSCCON, IRCF2
    BCF OSCCON, IRCF1
    BCF OSCCON, IRCF0	;1MHz
    CLRF TRISA
    CLRF TRISB
    MOVLW .255
    MOVWF TRISC
    CLRF TRISD
    BSF TRISA,0
    BANKSEL PORTA
    CLRF PORTA
    CLRF PORTB
    CLRF PORTC
    CLRF PORTD
    
    CLRF ADCON1	;CONDICIONES DE ADC
    MOVLW B'01000001'
    MOVWF ADCON0
    
    BCF INTCON,7 ;INTERRUPCIONES
    BCF INTCON,6
    BCF INTCON,5
    BCF OPTION_REG, T0CS 
    BSF OPTION_REG, PSA
    BCF INTCON, T0IF
    MOVLW .100
    MOVWF TMR0
    
    BANKSEL PR2 ;PWM CONFIG
    MOVLW .189
    MOVWF PR2
    BANKSEL TMR2
    CLRF TMR2 
    BCF T2CON,1
    BSF T2CON,0
    BCF PIR1,1
    BSF T2CON,2
    
    MOVLW B'00001100'
    MOVWF CCP1CON
    BANKSEL TRISC
    CLRF TRISC
   
    BANKSEL TXSTA
    BCF	    TXSTA, SYNC		    ; ASINCRÓNO
    BSF	    TXSTA, BRGH		    ; LOW SPEED
    BANKSEL BAUDCTL
    BSF	    BAUDCTL, BRG16	    ; 8 BITS BAURD RATE GENERATOR
    BANKSEL SPBRG
    MOVLW   .25	    
    MOVWF   SPBRG		    ; CARGAMOS EL VALOR DE BAUDRATE CALCULADO
    CLRF    SPBRGH
    BANKSEL RCSTA
    BSF	    RCSTA, SPEN		    ; HABILITAR SERIAL PORT
    BCF	    RCSTA, RX9		    ; SOLO MANEJAREMOS 8BITS DE DATOS
    BSF	    RCSTA, CREN		    ; HABILITAMOS LA RECEPCIÓN 
    BANKSEL TXSTA
    BSF	    TXSTA, TXEN		    ; HABILITO LA TRANSMISION

    BANKSEL PORTA
    
    LOOP:
    
    
    
    CALL    DELAY
    BSF    ADCON0, GO	
CHECKADC:
    BTFSC   ADCON0, GO	
    GOTO    CHECKADC
    MOVF    ADRESH, W
    MOVWF   SERVO
    SUBLW   .200
    BTFSS STATUS,C
    GOTO CHECK_RCIF
    MOVF SERVO,0
    MOVWF   CCPR1L		
    BCF	    PIR1, ADIF	
    
CHECK_TXIF: 
    MOVF   SERVO,0	    ; ENVÍA PORTB POR EL TX
    MOVWF   TXREG
   
    BTFSS   PIR1, TXIF
    GOTO    $-1
    
    GOTO LOOP

CHECK_RCIF:			    ; RECIBE EN RX y lo muestra en PORTD
    BTFSS   PIR1, RCIF
    GOTO    CHECK_TXIF
    MOVF    RCREG, W
    MOVWF   CCPR1L
    
    DELAY:
    MOVLW   .25
    MOVWF DELAY2
    MOVLW   .255		    
    MOVWF   DELAY1	    
    DECFSZ  DELAY1		    ;DECREMENTA CONT1
    GOTO    $-1			    ; IR A LA POSICION DEL PC - 1
    DECFSZ  DELAY2		    ;DECREMENTA CONT1
    GOTO    $-5	
    RETURN
    
    
    END