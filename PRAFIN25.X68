*-----------------------------------------------------------
* Title      : PRAFIN25
* Written by : Adrián González Alcalá y Adrián Reina Sorribas
* Description: Emulador de la BUIBEX
*-----------------------------------------------------------
    ORG $1000
N:	ECU 17 ;numero de componentes de EMEM
EMEM:   DC.W $A00E,$500B,$C002,$A20F,$500B,$C00B,$E804,$C814,$F7FB
        DC.W $500B,$4007,$C020,$8010,$0000,$0004,$0003,$0000
EIR:    DC.W 0 ;eregistro de instruccion
EPC:    DC.W 0 ;econtador de programa
ET0:    DC.W 0 ;eregistro T0
ET1:    DC.W 0 ;eregistro T1
ER2:    DC.W 0 ;eregistro R2
ER3:    DC.W 0 ;eregistro R3
ER4:    DC.W 0 ;eregistro R3
ER5:    DC.W 0 ;eregistro R3
ESR:    DC.W 0 ;eregistro de estado (00000000 00000ZNC)
CODE:   DS.W N ;CODIGO TEMPORAL

START:



FETCH:
    ;--- IFETCH: INICIO FETCH
        ;*** En esta seccion debeis introducir el codigo necesario para cargar
        ;*** en EIR la siguiente instruccion a ejecutar, indicada por el EPC,
	;*** y dejar listo el EPC para que apunte a la siguiente instruccion

	MOVE.W EPC, D0
    	MULU.W #2, D0
    	ADD.W D0, A0
	MOVE.W EMEM(A0), EIR
	
	ADDQ.W #1, EPC

    ;--- FFETCH: FIN FETCH
    
    
    
    ;--- IBRDECOD: INICIO SALTO A DECOD
        ;*** En esta seccion debeis preparar la pila para llamar a la subrutina
        ;*** DECOD, llamar a la subrutina, y vaciar la pila correctamente,
        ;*** almacenando el resultado de la decodificacion en D1

	SUBQ.W #2, SP
	MOVE.W EIR, -(SP)

	JSR DECOD

	ADDQ.W #2, SP
	MOVE.W (SP)+, D1

    ;--- FBRDECOD: FIN SALTO A DECOD


    
    ;--- IBREXEC: INICIO SALTO A FASE DE EJECUCION
        ;*** Esta seccion se usa para saltar a la fase de ejecucion
        ;*** NO HACE FALTA MODIFICARLA
    MULU #6,D1
    MOVEA.L D1,A1
    JMP JMPLIST(A1)
JMPLIST:
    JMP EHLT
    JMP EJMI
    JMP EJMZ
    JMP EJMN
    JMP ESTO
    JMP ELOA
    JMP ETRA
    JMP EADD
    JMP ESUB
    JMP ECMP
    JMP ENAN
    JMP ESET
    JMP EINC
    ;--- FBREXEC: FIN SALTO A FASE DE EJECUCION
    
    
    
    ;--- IEXEC: INICIO EJECUCION
        ;*** En esta seccion debeis implementar la ejecucion de cada einstr.
	
	; ESCRIBID EN CADA ETIQUETA LA FASE DE EJECUCION DE CADA INSTRUCCION
EHLT:
EJMI:
EJMZ:
EJMN:
ESTO:
ELOA:
ETRA:
EADD:
ESUB:
ECMP:
ENAN:
ESET:
EINC:
    ;--- FEXEC: FIN EJECUCION
    
    

    ;--- ISUBR: INICIO SUBRUTINAS
        ;*** Aqui debeis incluir las subrutinas que necesite vuestra solucion
        ;*** SALVO DECOD, que va en la siguiente seccion

	        ; ESCRIBID VUESTRO CODIGO AQUI
        
    ;--- FSUBR: FIN SUBRUTINAS
    
    

    ;--- IDECOD: INICIO DECOD
        ;*** Tras la etiqueta DECOD, debeis implementar la subrutina de 
        ;*** decodificacion, que debera ser de libreria, siguiendo la interfaz
        ;*** especificada en el enunciado
DECOD:
	MOVE.L D0, -(SP)

	MOVE.L 8(SP), D0
	BTST.L #15, D0
	BNE I
O:
	BTST.L #14, D0
	BNE OI
OO:
	MOVE.W #0, 10(SP) ;guarda id 0
	BRA FIN_DECOD
OI:
	BTST.L #13, D0
	BNE OII
OIO:
	BTST.L #12, D0
	BNE OIOI
OIOO:
	MOVE.W #1, 10(SP) ;guarda id 1
	BRA FIN_DECOD
OIOI:
	MOVE.W #2, 10(SP) ;guarda id 2
	BRA FIN_DECOD
OII:
	MOVE.W #3, 10(SP) ;guarda id 3
	BRA FIN_DECOD

I:


FIN_DECOD:
	MOVE.L (SP)+, D0
	RTS

    ;--- FDECOD: FIN DECOD
    END    START



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
