*-----------------------------------------------------------
* Title      : PRAFIN25
* Written by : Adrián González Alcalá y Adrián Reina Sorribas
* Description: Emulador de la BUIBEX
*-----------------------------------------------------------
      ORG $1000
EMEM: DC.W $A00E,$500B,$C002,$A20F,$500B,$C00B,$E804,$C814,$F7FB
      DC.W $500B,$4007,$C020,$8010,$0000,$0004,$0003,$0000
EIR:  DC.W 0 ;eregistro de instruccion
EPC:  DC.W 0 ;econtador de programa
ET0:  DC.W 0 ;eregistro T0
ET1:  DC.W 0 ;eregistro T1
ER2:  DC.W 0 ;eregistro R2
ER3:  DC.W 0 ;eregistro R3
ER4:  DC.W 0 ;eregistro R4
ER5:  DC.W 0 ;eregistro R5
ESR:  DC.W 0 ;eregistro de estado (00000000 00000ZNC)

START:
    CLR.W EPC
    
FETCH:
    ;--- IFETCH: INICIO FETCH
        ;*** En esta seccion debeis introducir el codigo necesario para cargar
        ;*** en EIR la siguiente instruccion a ejecutar, indicada por el EPC,
	;*** y dejar listo el EPC para que apunte a la siguiente instruccion

    MOVE.W EPC, D0
    MULU.W #2, D0
    MOVE.W D0, A0
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
	SIMHALT
EJMI:
	MOVE EIR, D3
	AND.W #$00FF, D3
	MOVE.W D3, EPC   ;EPC = 00000000mmmmmmmm
    BRA FETCH
EJMZ:
    MOVE.W ESR, D3   ;D3 = 0000000000000ZNC
    BTST #2, D3
    BNE EJMI         ;Si Z = 1, salta a JMI, si no vuelve al fetch
	BRA FETCH
EJMN: 
	MOVE.W ESR, D3   ;D3 = 0000000000000ZNC
    BTST #1, D3
    BNE EJMI         ;Si N = 1, salta a JMI, si no vuelve al fetch
	BRA FETCH
ESTO:
	MOVE.W EIR, D3
	AND.W #$0200, D3
	LSR.W #8, D3
	LSR.W #1, D3     ;D3 = 000000000000000j
    JSR EXTRAE       ;D4 = eregistro j
    
    MOVE.W EIR, D3
	AND.W #$00FF, D3 ;D4 = 00000000mmmmmmmm
	MULU.W #2, D3    ;Cada posicion de memoria son 2 bytes
	MOVE.W D3, A3
	MOVE.W D4, EMEM(A3)    ;eposición memoria mmmmmmmm = D4

	BRA FETCH
ELOA:
	MOVE.W EIR, D4
	AND.W #$00FF, D4 ;D4 = 00000000mmmmmmmm
	MULU.W #2, D4    ;Cada posicion de memoria son 2 bytes
	MOVE.W D4, A3
	MOVE.W EMEM(A3), D4  ;D4 = eposición memoria mmmmmmmm
	JSR GUARDA_ZyN

	MOVE.W EIR, D3
	AND.W #$0200, D3
	LSR.W #8, D3
	LSR.W #1, D3     ;D3 = 000000000000000j
	JSR CARGA        ;eregistro j = D4

	BRA FETCH
ETRA:
    MOVE.W EIR, D3
    AND.W #$0038, D3
    LSR.W #3, D3    ;D3 = 0000000000000aaa
    JSR EXTRAE      ;D4 = eregistro aaa
    
    MOVE.W EIR, D3
    AND.W #$0007, D3 ;D3 = 0000000000000bbb
    JSR CARGA       ;eregistro bbb = D4
    
    BRA FETCH
EADD:
    MOVE.W EIR, D3
    AND.W #$0038, D3
    LSR.W #3, D3    ;D3 = 0000000000000aaa
    JSR EXTRAE
    MOVE.W D4, D5   ;D5 = eregistro aaa
    
    MOVE.W EIR, D3
    AND.W #$0007, D3 ;D3 = 0000000000000bbb
    JSR EXTRAE      ;D4 = eregistro bbb
    
    ADD.W D5, D4
    JSR GUARDA_ESR
    
    MOVE.W EIR, D3
    AND.W #$0007, D3 ;D3 = 0000000000000bbb
    JSR CARGA       ;eregistro bbb = D4 + D5
    
    BRA FETCH
ESUB:
    MOVE.W EIR, D3
    AND.W #$0038, D3
    LSR.W #3, D3    ;D3 = 0000000000000aaa
    JSR EXTRAE
    MOVE.W D4, D5   ;D5 = eregistro aaa
    
    MOVE.W EIR, D3
    AND.W #$0007, D3 ;D3 = 0000000000000bbb
    JSR EXTRAE      ;D4 = eregistro bbb
    
    NOT.W D5
    ADDQ.W #1, D5
    ADD.W D5, D4
    JSR GUARDA_ESR
    
    MOVE.W EIR, D3
    AND.W #$0007, D3 ;D3 = 0000000000000bbb
    JSR CARGA       ;eregistro bbb = D4 + (NOT(D5) + 1)
    
    BRA FETCH
ECMP:
    MOVE.W EIR, D3
    AND.W #$0038, D3
    LSR.W #3, D3    ;D3 = 0000000000000aaa
    JSR EXTRAE
    MOVE.W D4, D5   ;D5 = eregistro aaa
    
    MOVE.W EIR, D3
    AND.W #$0007, D3 ;D3 = 0000000000000bbb
    JSR EXTRAE      ;D4 = eregistro bbb
    
    NOT.W D5
    ADDQ.W #1, D5
    ADD.W D5, D4    ;D4 = D4 + (NOT(D5) + 1)
    JSR GUARDA_ESR
    
    BRA FETCH
ENAN:
    MOVE.W EIR, D3
    AND.W #$0038, D3
    LSR.W #3, D3    ;D3 = 0000000000000aaa
    JSR EXTRAE
    MOVE.W D4, D5   ;D5 = eregistro aaa
    
    MOVE.W EIR, D3
    AND.W #$0007, D3 ;D3 = 0000000000000bbb
    JSR EXTRAE      ;D4 = eregistro bbb
    
    AND.W D4, D5
    NOT.W D4
    JSR GUARDA_ZyN
    
    MOVE.W EIR, D3
    AND.W #$0007, D3 ;D3 = 0000000000000bbb
    JSR CARGA       ;eregistro bbb = NOT(D4 AND D5)
    
    BRA FETCH
ESET:
    MOVE.W EIR, D6
    AND.W #$07F8, D6
    LSR.W #3, D6    ;D6 = 00000000cccccccc
    EXT D6
    JSR GUARDA_ZyN
    
    MOVE.W EIR, D3
    AND.W #$0007, D3 ;D3 = 0000000000000bbb
    
    MOVE.W EIR, D3
    AND.W #$0007, D3 ;D3 = 0000000000000bbb
    JSR CARGA       ;eregistro bbb = D4
    
    BRA FETCH
EINC:
    MOVE.W EIR, D3
    AND.W #$0007, D3 ;D3 = 0000000000000bbb
    JSR EXTRAE      ;D4 = eregistro bbb
    
    MOVE.W EIR, D6
    AND.W #$07F8, D6
    LSR.W #3, D6    ;D6 = 00000000cccccccc
    EXT D6
    
    ADD.W D6, D4
    JSR GUARDA_ESR
    
    MOVE.W EIR, D3
    AND.W #$0007, D3 ;D3 = 0000000000000bbb
    JSR CARGA       ;eregistro bbb = D4 + D6
    
    BRA FETCH
    ;--- FEXEC: FIN EJECUCION
    
    

    ;--- ISUBR: INICIO SUBRUTINAS
        ;*** Aqui debeis incluir las subrutinas que necesite vuestra solucion
        ;*** SALVO DECOD, que va en la siguiente seccion
    
EXTRAE: ;Extrae a D4 el contenido del eregistro cuyo índice está definido por
        ;el contenido de D3. Para ello utiliza A2 y se multiplica el contenido
        ;de D3 por 4 porque cada instrucción "MOVE.W etiqueta, D4" ocupa 4
        ;bytes por ser los registros de direccionamiento corto y cada
        ;instrucción "BRA.S FIN_CARGA" ocupa 2 bytes.
    MULU #6, D3
    MOVEA.L D3, A2
    JMP LISTA_EXTRAE(A2)
LISTA_EXTRAE:
    MOVE.W ET0, D4
    BRA.S FIN_EXTRAE
    MOVE.W ET1, D4
    BRA.S FIN_EXTRAE
    MOVE.W ER2, D4
    BRA.S FIN_EXTRAE    
    MOVE.W ER3, D4
    BRA.S FIN_EXTRAE
    MOVE.W ER4, D4
    BRA.S FIN_EXTRAE
    MOVE.W ER5, D4
FIN_EXTRAE:
    RTS

CARGA:  ;Carga el contenido de D4 en el eregistro cuyo índice está definido por
        ;el contenido de D3. Para ello utiliza A2 y se multiplica el contenido
        ;de D3 por 6 porque cada instrucción "MOVE.W D4, etiqueta" ocupa 4 bytes
        ;por ser los registros de direccionamiento corto y cada instrucción
        ;"BRA.S FIN_CARGA" ocupa 2 bytes,
    MULU #6, D3
    MOVEA.L D3, A2
    JMP LISTA_CARGA(A2)
LISTA_CARGA:
    MOVE.W D4, ET0
    BRA.S FIN_CARGA
    MOVE.W D4, ET1
    BRA.S FIN_CARGA
    MOVE.W D4, ER2
    BRA.S FIN_CARGA
    MOVE.W D4, ER3
    BRA.S FIN_CARGA
    MOVE.W D4, ER4
    BRA.S FIN_CARGA
    MOVE.W D4, ER5
FIN_CARGA:
    RTS
    
GUARDA_ESR: ;Guarda las flags Z, N y C del registro SR como los tres últimos
            ;bits del eregistro ESR. Para ello utiliza D2.
    MOVE.W SR, D2   ;D2 = xxxxxxxxxxxxNZxC
    MOVE.L D0, -(SP)
    CLR D0

    AND.W #$000D, D2 ;D2 = 000000000000NZ0C
    
    MOVE.W D2, D0
    AND.W #$0008, D0 ;D0 = 000000000000N000
    LSR.W #2, D0    ;D0 = 00000000000000N0
    AND.W #$0005, D2 ;D2 = 0000000000000Z0C
    OR.W D2, D0
    
    MOVE.W D0, ESR  ;ESR = 0000000000000ZNC
    
    MOVE.L (SP)+, D0
    RTS
    
GUARDA_ZyN: ;Guarda las flags Z y N del registro SR como los dos últimos bits
            ;del eregistro ESR. Para ello utiliza D2.
    MOVE.W SR, D2   ;D2 = xxxxxxxxxxxxNZxC
    MOVE.L D0, -(SP)
    CLR D0

    AND.W #$000C, D2 ;D2 = 000000000000NZ00
    
    MOVE.W D2, D0
    AND.W #$0008, D0 ;D0 = 000000000000N000
    LSR.W #2, D0    ;D0 = 00000000000000N0
    AND.W #$0004, D2 ;D2 = 0000000000000Z00
    OR.W D2, D0
    
    MOVE.W ESR, D2
    AND.W #$0001, D2 ;D2 = 000000000000000(C anterior)
    OR.W D2, D0
    
    MOVE.W D0, ESR  ;ESR = 0000000000000ZN(C anterior)
    
    MOVE.L (SP)+, D0
    RTS
    
    ;--- FSUBR: FIN SUBRUTINAS
    
    

    ;--- IDECOD: INICIO DECOD
        ;*** Tras la etiqueta DECOD, debeis implementar la subrutina de 
        ;*** decodificacion, que debera ser de libreria, siguiendo la interfaz
        ;*** especificada en el enunciado
DECOD:
	MOVE.L D0, -(SP)
	CLR D0

	MOVE.W 8(SP), D0
	BTST #15, D0
	BNE I
O:      ;Cada etiqueta O, OO, OI, IIO, ... es la combinación conocida que
        ;contiene D0 antes de que el programa se dirija a la posición de la
        ;etiqueta
	BTST #14, D0
	BNE OI
OO:
	MOVE.W #0, 10(SP) ;guarda id 0
	BRA FIN_DECOD
OI:
	BTST #13, D0
	BNE OII
OIO:
	BTST #12, D0
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
	BTST #14, D0
	BNE II
IO:
	BTST #13, D0
	BNE IOI
IOO: 	
	MOVE.W #4, 10(SP) ;guarda id 4
	BRA FIN_DECOD
IOI:
	MOVE.W #5, 10(SP) ;guarda id 5
	BRA FIN_DECOD
II: 	
	BTST #13, D0
	BNE III
IIO:
	BTST #12, D0
	BNE IIOI
IIOO:
	BTST #11, D0
	BNE IIOOI
IIOOO:
	MOVE.W #6, 10(SP) ;guarda id 6
	BRA FIN_DECOD
IIOOI:
	MOVE.W #7, 10(SP) ;guarda id 7
	BRA FIN_DECOD
IIOI:
	BTST #11, D0
	BNE IIOII
IIOIO:
	MOVE.W #8, 10(SP) ;guarda id 8
	BRA FIN_DECOD
IIOII:
	MOVE.W #9, 10(SP) ;guarda id 9
	BRA FIN_DECOD
III:
	BTST #12, D0
	BNE IIII
IIIO:
	BTST #11, D0
	BNE IIIOI
IIIOO:
	MOVE.W #10, 10(SP) ;guarda id 10
	BRA FIN_DECOD
IIIOI:
	MOVE.W #11, 10(SP) ;guarda id 11
	BRA FIN_DECOD
IIII:
	MOVE.W #12, 10(SP) ;guarda id 12
	BRA FIN_DECOD

FIN_DECOD:
	MOVE.L (SP)+, D0
	RTS
	
    ;--- FDECOD: FIN DECOD
    END    START


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
