# basado en el código de Francis Sanabria
#########################################
# Sang Woo Shin 15372
# Jeffrey
# Mini-Proyect
#Micro Controladores
##########################################

import serial
import time
import sys

#COMUNICACION SERIAL DE PIC CON LA CUMPU
ser= serial.Serial(port='COM4',baudrate=9600, parity=serial.PARITY_NONE, stopbits=serial.STOPBITS_ONE,bytesize=serial.EIGHTBITS, timeout=0)
while 1:
    ser.flushInput()
    ser.flushOutput()
    time.sleep(.3)
    recibido1=ser.read()
    ser.write(recibido1)
    numero = ord(recibido1)
    print(numero)
    # RECUERDEN CONECTAR EL RX AL TX