
;
;-----------------Multtiplicacion de 16 bits-------------------------
;los operandos se encontraran en r1 y r2
;en r0 se pondra el resultado final de la operacion
;copiar y pegar todo este codigo en donde se necesite llamar a la funcion
;	
;
.orig x3000



	ld r1,nax
	ld r2,nbx
	jsr MULT16B
	halt
	nax .fill x58F8 ; 159=0101100011111000 = x58F8
	nbx .fill x4400 ; 4 = 0100010000000000 = x4400



MULT16B	st r1,na
		st r2,nb
		
		lea r0,datos_previos
		str r3,r0,#0
		str r4,r0,#1
		str r5,r0,#2
		str r6,r0,#3
		str r7,r0,#4
		
		and r0,r0,#0
		and r1,r1,#0
		and r2,r2,#0
		and r5,r5,#0
		and r6,r6,#0

		ld r3, na		; multiplicador de 16 bits
		ld r4, nb		; multiplicando de 16 bits
		and r1,r1,x0 	; signo1	
		and r2,r2,x0 	; signo2
		ld r5,mascs  	; mascara para el signo
		and r1,r5,r3 	; almaceno el signo en r1 y r2 para xor
		and r2,r5,r4
;	
		jsr XOR			; ejecutamos la operacion
		st r0, stt		; guardo la xor en la posicion stt
;	
		ld r5,masce		; cargo la mascara para sacar el exponente
		and r1,r3,r5	; saco el exponente de n1, guardo en r1
		and r2,r4,r5	; saco el exponente de n2, guardo en r2
		add r6,r1,r2	; sumo los exponentes
		ld r5, bias		; cargo el bias en r5
		not r5,r5		; hallo el -bias 
		add r5,r5,#1	; -bias
		add r6, r6,r5	; sumo los exponentes y les resto el bias
		st r6, es		; los guardo en es

		ld r5, mascm	; cargo la mascara para la mantisa	
		and r1,r3,r5	; cargo la mantisa del numero 1
		and r2,r4,r5	; cargo la mantisa del numero 2
		ld r5, mascb22
		add r1,r1,r5	; agrego el 1 virtual
		add r2,r2,r5	; agrego el 1 virtual
		jsr MULT2x 		; envio las mantisas en r1 y r2 y 
						; retorno los resultados en r0 y r3
;
		and r5,r5,#0    ; necesito hallar el bit 24 en r3
		ld r5,mascb22	; cargo una mascara adecuada para sacar el bit 24
;
		not r6,r5	 
		add r6,r6,#1
;		
		and r4,r5,r3	; guardo el bit24 en r5
;
		brz masc10	; si el bit 24 es un 1, debo quitarlo
;				; y esa es mi mantisa
		add r3,r3,r6	;r3, mantisa lista
		st r3, mant
		ld r4, es	;debo sumarle #1 al exponente
		ld r5, mascb22  ;1 adecuado para el exponente
		add r4,r4,r5
		st r4, es	;guardo el nuevo exponente
		brnzp result1
;
masc10	add r4,r0,#0	;si el bit 22 es un cero, necesito correr el dato que hay en r3
		add r1,r3,#0	;un bit a la izquierda, y tomar el ultimo bit de r0
		and r0,r0,#0
		and r2,r2,#0	;en r0 esta la mantisa
		add r2,r2,#1	;en r2 estara la cantidad de corrimientos (=1)
		
		jsr SHIFTL	;en r3 estara la mantisa que va a enviar su ultimo bit
		ld r5, mascm
		and r0,r0,r5
		st r0, mant
		
		and r0,r4,r5	;pongo en r4 el ultimo bit de r3
		and r2,r2,#0
		add r2,r2,#9 	;debo correr el dato 9 veces a la derecha
		jsr SHIFTR
		ld r1,mant
		add r0,r0,r1	;sumo el ultimo bit de r3, en r0 (r3 era el pedazo final de la mantisa, r0 el pedazo inicial)
		add r3,r0,#0
result1		st r3, mant 	;guardo el resultado de la mantisa en mant

		and r0,r0,#0	;hallo el numero resultado y lo pongo en r0
		ld r1,stt
		ld r2,es
		add r0,r0,r1
		add r0,r0,r2
		add r0,r0,r3

		ld r1,na
		ld r2,nb
		lea r6,datos_previos
		ldr r3,r6,#0
		ldr r4,r6,#1
		ldr r5,r6,#2
		ldr r7,r6,#4
		ldr r6,r6,#3
		RET
;
;espacios reservados en memoria y constantes utilizadas
;________________________________________________________________________
	na .blkw 1 ; 159=0101100011111000 = x58F8
	nb .blkw 1 ; 4 = 0100010000000000 = x4400
	stt .blkw 1
	es  .blkw 1
	mascs .fill x8000	;1000000000000000 mascara para el signo
	masce .fill x7C00	;0111110000000000 mascara para el exponente
	mascm .fill x03ff	;0000001111111111 mascara para la mantisa
	mascb22 .fill x0400	;0000010000000000 mascara para el bit 22
	bias  .fill x3c00 	;0011110000000000 bias
	mant  .blkw 1
	datos_previos .blkw 5
;_________________________________________________________________________
;
;_______________________________funciones______________________________
;
;_________________________________XOR___________________________________
;los operandos se encuentran en r1 y r2
; el resultado estara en r0
;
;
XOR st r3, guarXOR3		;Se almacenan en memoria los registros a utilizar
	st r4, guarXOR4
	st r5, guarXOR5
	st r6, guarXOR6
;
	not r3,r1			;se realiza la xor= ((~A) and B) or(+) (A and(~B))
	not r4,r2
	and r5,r1,r4
	and r6,r2,r3 
	add r0,r5,r6
;
	ld r3, guarXOR3 ;se cargan los datos anteriormente ubicados en la memoria
	ld r4, guarXOR4
	ld r5, guarXOR5
	ld r6, guarXOR6
;
	ret
;
	guarXOR3 .blkw 1
	guarXOR4 .blkw 1
	guarXOR5 .blkw 1
	guarXOR6 .blkw 1
;_______________________________________________________________________________________
;
;_____________________________MULT2X____________________________________________________
;multiplicacion en 11 bits(incluyendo el '1 virtual') con carry de 11 bits para overflow
;se usan r1 y r2 como operandos y el resultado se almacena en r0 y r3
MULT2x	st r2,guarmt22	;multiplicando
		;st r3,guarmt23	;carry
		st r4,guarmt24	;auxiliar para carry
		st r5,guarmt25  ;auxiliar para determinar el carry, bitmask
		st r6,guarmt26  ;auxiliar para determinar el carry, not(bitmask)
;

		and r3,r3,#0 	;r3 es el carry de 16 bits
		and r0,r0,#0
		and r4,r4,#0
		ld r5, bitmask
		not r6,r5
		add r6,r6,#1
;
;
		add r2,r2,#0		;no puedo tener un multiplicando negativo
		brp mult2x1
		not r2,r2
		add r2,r2,#1

mult2x1	add r0,r1,r0		;funcion principal de la multiplicacion
		and r4,r0,r5		
		add r4,r4,r6
		brn not_over		;determino si debo agregar carry mirando si hay bits
		add r3,r3,#1		;de salida en el bit 12. de ser asi comienzo a acumular
		add r0,r0,r6		;esos bits en r3 y los quito del registro de salida r0
not_over add r2,r2,#-1
		brp mult2x1
		
		ld r2,guarmt22
		ld r4,guarmt24
		ld r5,guarmt25
		ld r6,guarmt26
	ret
	
		guarmt22	.blkw 1
		;guarmt23	.blkw 1
		guarmt24 	.blkw 1
		guarmt25 	.blkw 1
		guarmt26 	.blkw 1
		guarx1 		.fill x07FF
		guarx2 		.fill x0002
		bitmask 	.fill x0800
;
;
;
;_____________________________________________________________________
;______________________________SHIFTR_________________________________
;funcion para mover cadenas de bits hacia la derecha
;
;
SHIFTR	st r0, guarsr1 	; se utilizan los registros r0, r1, r2 y r3
		st r2, guarsr2	; en r0 se recibe el numero a mover a la derecha
		st r3, guarsr3	; en r1 se encuentra el numero de corrimientos
						; r2 y r3 son para uso interno
		add r3,r1,#0	
		and r1,r1,#0
		and r2,r2,#0	; se inicializan los registros r3(# de corrimientos),
						; r1(para verificar si ya llegue a uno o a cero) 
						; y r2(en donde se almacenara el resultado parcial)
;
shiftr1	add r1,r0,#0	; se guarda en r1 el valor actual para verificar si ya terminé
		add r1,r1,#-1
		brnz step 		; se le resta -1 y si es negativo o cero ya termine

		add r2,r2,#1	; se guarda el divisor
		add r0,r0,#-2	; se divide por 10(bin), por lo tanto esta es la operacion
		
		brp shiftr1		; si el numero almacenado es mayor que cero, volver a dividir 
						; entre diez
						;
step	add r0,r2,#0	; se debe realizar las operaciones anteriores tantas veces
		and r2,r2,#0	; como corrimientos se necesiten
		and r1,r1,#0
		add r3,r3,#-1	
		brp shiftr1
		ld r1,guarsr1	; se cargan los valores originales. Solo se conserva R0 como 
		ld r2,guarsr2	; resultado del algoritmo
		ld r3,guarsr3	
RET

		guarsr1 .blkw 1
		guarsr2 .blkw 1
		guarsr3 .blkw 1
;______________________________________________________________________________________

;______________________________SHIFTL__________________________________________________
;operacion para mover cadenas de bits  a la izquierda
SHIFTL		st r2, guarshiftl	; se guarda el dato en r2
op_shiftL	add r0,r0,r1 		; se multiplica el valor guardado en r1 por 10(bin)
			add r2,r2,#-1		; se corre tantas veces hacia la izquierda como lo
								; indique R2
			brzp op_shiftL		; mientras que r2 sea zero o positivo, se sigue 	
								; multiplicando por 10(bin)
			ld r2, guarshiftl	;R0 es el resultado del programa y r1 es el operando,
						;		R2 es para uso interno
RET
			guarshiftl .blkw 1
;______________________________________________________________________________________

;__________________________________________________________________		

;__________________________________________________________________
;_______________________SUMA_______________________________________
SUMA16B	lea r0,savep 
		st r1,na
		st r2,nb
		str r3,r0,#0
		str r4,r0,#1
		str r5,r0,#2
		str r6,r0,#3
		str r7,r0,#4


		and r0,r0,#0
		and r1,r1,#0
		and r2,r2,#0
		and r5,r5,#0
		and r6,r6,#0

		ld r3, na		; sumando de 16 bits
		ld r4, nb		; sumando de 16 bits
		and r1,r1,x0 	; signo1	
		and r2,r2,x0 	; signo2
		ld r5,mascs  	; mascara para el signo
		and r1,r5,r3 	; almaceno el signo en r1 y r2 para xor
		and r2,r5,r4
		st r1,sa 		;guardo los signos de a y de b para comodidad
		st r2,sb
		jsr XOR			; ejecutamos la operacion
		st r0, stt		; guardo la xor en la posicion stt

		ld r5,masce		; cargo la mascara para sacar el exponente (bit 16)
		and r0,r3,r5	; saco el exponente de n1, guardo en r0 
		and r1,r4,r5	; saco el exponente de n2, guardo en r1
		st r0,ea
		st r1,eb
		not r1,r1 		; niego el exponente del segundo para la diferencia
		add r1,r1,#1
		add r0,r1,r0 	; calculo la diferencia

		st r0,diffe		; guardo la diferencia para futuras instancias
		ld r5,masc15	; mascara para sacar el bit 15 diffe(5)
		and r5,r0,r5	; sacamos el bit 15
		
		brz maxb		; branch para calculo del max
		not r0,r0		; si el bit 15 es 1, niego diffe
		add r0,r0,#1
maxb	
		and r1,r1,#0
		add r1,r1,#10
		jsr SHIFTR
		st r0, max
		add r1,r0,#0
		st r5,diffe15	; guardo el bit 15 de diffe, importante mas adelante
		add r6,r3,#0
		ld r5, mascm	; cargo la mascara para la mantisa
		and r0,r6,r5	; saco la mantisa de na, guardo en r0
		ld r5, mascb11	; cargo la mascara para el bit 11
		add r0,r5,r0	; agrego el bit adicional a la mantisa de NA
		add r2,r0,#0	; por si acaso no hay corrimiento
		and r3,r3,#0
		st r0,ma 		;guardo la mantisa de a('1'& mantisa(na) )
		ld r5,diffe15	; segun el bit de diffe(5), calculo el desplazamiento a la izquierda
		brz na_shifting	; segun el bit 15 de diffe, corro la mantisa max veces hacia la izquierda

		jsr SHIFTRX		; corro hacia la derecha max veces la mantisa
						;r1 dato, r2 corrimientos, r3 y r0 solucion
na_shifting	
		st r2,aa1
		st r3,aa2

		ld r5, mascm	; cargo la mascara para la mantisa
		and r0,r4,r5	; saco la mantisa de n2, guardo en r1
		ld r5, mascb11	; cargo la mascara para el bit 11
		add r0,r5,r0	; agrego el bit adicional a la mantisa de NB
		st r0,mb 		; guardo la mantisa de nb
		add r2,r0,#0
		and r3,r3,#0
		ld r5,diffe15	; cargo el bit 15 de diffe, para el branch
		brp nb_shifting	; segun el bit 15 de diffe, corro la mantisa max veces hacia la izquierda
			jsr SHIFTRX		; corro hacia la izquierda max veces la mantisa

nb_shifting	st r2,ab1
			st r3,ab2

			ld r0,aa1
			ld r1,aa2

			ld r4, diffe15 ;saco todas las variables necesarias para el if
			ld r6,diffe
			ld r5,stt	; si el signo de la xor es cero salta a sum1(suma de dos numeros de igual signo)
			brz sum1

				not r3,r3
				add r3,r3,#1
				not r2,r2
				add r2,r2,#1
				add r0,r0,r2 	;aa1-ab1
				add r1,r1,r3 	;aa2-ab2
				lea r4, sum
				str r0,r4,#0
				str r1,r4,#1

				ld r4, diffe15
				add r6,r6,#0	
				brz case_diffe1 ;diffe ="000000000..."
					add r4,r4,#0
					brz sum2

case_diffe1				ld r2,ab1 ;cargo nuevamente los datos de aa y ab
						ld r3,ab2
						ld r0,aa1
						ld r1,aa2
						
						not r0,r0
						add r0,r0,#1
						not r1,r1
						add r1,r1,#1
						add r0,r2,r0 	;ab1-aa1
						add r1,r1,r3 	;ab2-aa2
						lea r4, sum
						str r0,r4,#0
						str r1,r4,#1
				brnzp sum2
					
sum1		ld r2,ab1 ;cargo nuevamente los datos de aa y ab
			ld r3,ab2
			ld r0,aa1
			ld r1,aa2
			
			add r0,r0,r2 ;calculo sum en sus dos partes 			
			add r1,r1,r3
			lea r4,sum
			str r0,r4,#0
			str r1,r4,#1
			
			ld r5, mascb12
			and r2,r0,r5
			brz case2		;cero indica no overflow, 1 indica overflow
				ld r4,mascb11 	;r4 sera ac=1 para el esquema
				and r1,r1,#0
				add r1,r1,#1
				not r5,r5
				add r5,r5,#1
				add r0,r0,r5	;quito el bit12 de la mantisa
				jsr SHIFTR
				ld r6,mascm
				and r0,r0,r6
				st r0,mr 		
				BRnzp case3			

case2		ld r1, sum
			and r4,r4,#0 	;r4 sera ac=0 para el esquema
			ld r5,mascm 		
			and r1,r1,r5
			st r1,mr
case3		ld r5,diffe15
			brz case4
			ld r0,eb
			BRnzp ets
case4		ld r0,ea
ets 		add r0,r0,r4

			st r0,et
			brnzp signo
sum2	lea r6,sum 		;recorro cada posicion de sum para verificar desde donde empieza el dato
		ldr r1,r6,#0	;r1 es la primera parte de la suma
		and r2,r2,#0
		add r2,r2,#1	;cuantas veces se desplazara a la izquierda
		ldr r3,r6,#1	;r3 es la segunda parte de la suma
		and r4,r4,#0	;cuantas veces he ejecutado corrimientos?

		ld r5,mascb11
		and r0,r0,r5	;si hay un 1, me salgo del algoritmo
		brp listo		
busca1	jsr SHIFTL 
		add r1,r0,#0	;guardo en r1 la salida del algoritmo para loop
		add r4,r4,#1	;cuantas veces he realizado corrimientos?
		add r6,r4,#-11
		brz busca2
		and r0,r0,r5	;si hay un 1, me salgo del algoritmo
		brz busca1
		st r4,despl 	
		brp listo

busca2	add r1,r3,#0
		ld r3,minus22
		
busca2a jsr SHIFTL 
		add r1,r0,#0	;guardo en r1 la salida del algoritmo para loop
		add r4,r4,#1	;cuantas veces he realizado corrimientos?
		add r6,r4,r3
		brz listo
		and r0,r0,r5	;si hay un 1, me salgo del algoritmo
		brz busca2a
		st r4,despl
		ld r6,mascm
		and r1,r1,r6
		st r1, mr
		brnzp exit1

listo 	add r2,r1,#0

		not r4,r4
		add r4,r4,#1
		add r1,r4,#11 ;averiguo cuantas veces desplazar a la derecha

		lea r0,sum 		;cargo el numero a desplazar en r0
		ldr r0,r0,#1
	    jsr SHIFTR
	    add r2,r2,r0
	    ld r6,mascm
		and r2,r2,r6
	    st r2,mr

exit1 	ld r1,diffe15
		brz expB

		ld r1,despl		;le resto despl al exponente 
		and r0,r0,#0
		and r2,r2,#0
		add r2,r2,#10
		jsr SHIFTL
		ld r1,eb
		not r0,r0
		add r0,r0,#1
		add r1,r1,r0
		st r1,et

		BRnzp signo

expB	ld r1,despl		;le resto despl al exponente 
		and r0,r0,#0
		and r2,r2,#0
		add r2,r2,#10
		jsr SHIFTL
		ld r1,ea
		not r0,r0
		add r0,r0,#1
		add r1,r1,r0

		st r1,et



signo ld r1,diffe 	;se calcula el signo de la operacion
		brz diffe_s0

		ld r2,diffe15
		brz diffe15_s0

		ld r4,sb
		BRnzp ext_sign
diffe15_s0
		ld r4,sa
		
		BRnzp ext_sign

diffe_s0 ld r3,stt
		 brz s_xor

		ld r4,aa1
		ld r5,ab1
		add r0,r4,r5
		brzp aa_mayor

		 ld r4,sb

		 BRnzp ext_sign
aa_mayor ld r4,sa
		 BRnzp ext_sign
s_xor 	ld r4,sa
ext_sign st r4,sr


		ld r1,mr
		ld r2,et
		ld r3,sr
		add r0,r2,r1
		add r0,r0,r3



		lea r6,savep
		ld r1,na
		ld r2,nb
		ldr r3,r6,#0
		ldr r4,r6,#1
		ldr r5,r6,#2
		ldr r7,r6,#4
		ldr r6,r6,#3
ret
;espacios reservados en memoria y constantes utilizadas
;________________________________________________________________________
	savep  .blkw 5		;respaldo para las variables
	na .blkw 1 ;xE418 ; -35 1101000001100000
	nb .blkw 1 ;x5858 ; 100 0101011001000000100
	sa .blkw 1 		;signo del primer numero
	sb .BLKW 1		;signo del segundo numero
	ea .blkw 1 		;exponente del primer numero
	eb .BLKW 1		;exponente del segundo numero
	ma .BLKW 1 		;mantisa del primer numero
	mb .BLKW 1 		;mantisa del segundo numero

	aa1 .blkw 1		;parte 1 de la operacion para a
	aa2 .blkw 1		;parte 2 de la operacion para a
	ab1 .blkw 1		;parte 1 de la operacion para b
	ab2 .blkw 1		;parte 2 de la operacion para b
	stt .blkw 1		;signo del resultado
	sum .blkw 2		;sum[2]={+-aa1+-ab1,+-aa2+-ab2}
	es  .blkw 1		;exponente del resultado	
	mant  .blkw 1		;mantisa del resultado
	mr .blkw 1			;MR mantisa temporal, hay que ajustarla
	et .blkw 1			;exponente total
	sr .blkw 1			;signo final
	despl .blkw 1		;cantidad de desplazamientos hechos a la 
						;izquierda en la suma de mantisas (max 22)
	diffe  .blkw 1 		;espacio para la diferencia entre exponentes
	diffe15  .blkw 1 	;bit 15 de diffe
	max  .blkw 1 		;espacio la variable max
	mascs  .fill x8000	;1000000000000000 mascara para el signo
	masce  .fill x7C00	;0111110000000000 mascara para el exponente
	mascm  .fill x03FF	;0000 0011 1111 1111 mascara para la mantisa
	mascb11 .fill x0400	;0000010000000000 mascara para el bit 11
	mascb12 .fill x0800	;0000100000000000 mascara para el bit 12
	masc15 .fill x4000 	;0100000000000000 mascara para el bit 15
	minus22 .fill #22	;numero 22, dato para resta
	bias   .fill x3c00 	;0011110000000000 bias
	
;_________________________________________________________________________
;
;_______________________________funciones______________________________


;_________________________________XOR___________________________________
;los operandos se encuentran en r1 y r2
; el resultado estara en r0
;
;
XOR st r3, guarXOR3		;Se almacenan en memoria los registros a utilizar
	st r4, guarXOR4
	st r5, guarXOR5
	st r6, guarXOR6
;
	not r3,r1			;se realiza la xor= ((~A) and B) or(+) (A and(~B))
	not r4,r2
	and r5,r1,r4
	and r6,r2,r3 
	add r0,r5,r6
;
	ld r3, guarXOR3 ;se cargan los datos anteriormente ubicados en la memoria
	ld r4, guarXOR4
	ld r5, guarXOR5
	ld r6, guarXOR6
;
	ret
;
	guarXOR3 .blkw 1
	guarXOR4 .blkw 1
	guarXOR5 .blkw 1
	guarXOR6 .blkw 1
;_____________________________________________________________________
;______________________________SHIFTR_________________________________
;funcion para mover cadenas de bits hacia la derecha
;
;
SHIFTR	st r0, guarsr1 	; se utilizan los registros r0, r1, r2 y r3
		st r2, guarsr2	; en r0 se recibe el numero a mover a la derecha
		st r3, guarsr3	; en r1 se encuentra el numero de corrimientos
						; r2 y r3 son para uso interno
		add r3,r1,#0	
		and r1,r1,#0
		and r2,r2,#0	; se inicializan los registros r3(# de corrimientos),
						; r1(para verificar si ya llegue a uno o a cero) 
						; y r2(en donde se almacenara el resultado parcial)
;
shiftr1	add r1,r0,#0	; se guarda en r1 el valor actual para verificar si ya terminé
		add r1,r1,#-1
		brnz step 		; se le resta -1 y si es negativo o cero ya termine

		add r2,r2,#1	; se guarda el divisor
		add r0,r0,#-2	; se divide por 10(bin), por lo tanto esta es la operacion
		
		brp shiftr1		; si el numero almacenado es mayor que cero, volver a dividir 
						; entre diez
						;
step	add r0,r2,#0	; se debe realizar las operaciones anteriores tantas veces
		and r2,r2,#0	; como corrimientos se necesiten
		and r1,r1,#0
		add r3,r3,#-1	
		brp shiftr1
		ld r1,guarsr1	; se cargan los valores originales. Solo se conserva R0 como 
		ld r2,guarsr2	; resultado del algoritmo
		ld r3,guarsr3	
RET

		guarsr1 .blkw 1
		guarsr2 .blkw 1
		guarsr3 .blkw 1
;______________________________________________________________________________________

;______________________________SHIFTL__________________________________________________
;operacion para mover cadenas de bits  a la izquierda
;R0 es el resultado del programa y r1 es el operando,
;R2 es para uso interno; se guarda el dato en r2
SHIFTL		st r2, guarshiftl	
			
			and r0,r0,#0
			add r0,r1,#0
op_shiftL	add r0,r0,r0 		; se multiplica el valor guardado en r1 por 10(bin)
			add r2,r2,#-1		; se corre tantas veces hacia la izquierda como lo
								; indique R2
			brp op_shiftL		; mientras que r2 sea zero o positivo, se sigue 	
								; multiplicando por 10(bin)
			ld r2, guarshiftl	
RET
			guarshiftl .blkw 1
;______________________________________________________________________________________

;______________________________________________________________________________________

;______________________________SHIFTLX__________________________________________________
;operacion para mover cadenas de 11 bits  a la izquierda con carry de 11bits
;_____________________________________________________________________


	SHIFTLX		st r2, guarlx2	; guarda datos en r0(solucion), r1(numero a desplazar),
			st r4, guarlx4		; r2(cantidad de desplazamientos),r3(carry de 16bits)
			st r5, guarlx5
			st r6, guarlx6
						
			and r0,r0,#0
			and r3,r3,#0
			and r4,r4,#0 		;inicializo r4, r5 y r6 por seguridad
			and r5,r5,#0
			ld r5,mascb12		;cargo la mascara del bit 12
			not r6,r5			;creo la antimascara (para restar)
			add r6,r6,#1
			add r1,r1,#0
			brz zeros			; si lo que ingresó es cero, ya termine	
			add r0,r1,#0

op_shiftLx	add r0,r0,r0 		; se multiplica el valor guardado en r1 por 10(bin)
			add r4,r4,r4		; se corre el carry a la izquierda
			
			and r3,r0,r5		;recojo el bit 12
			brz zero 			;si el bit 12 es cero no hay carry(pero si se desplaza hacia la izquierda)
			add r4,r4,#1		;si el bit 12 es uno, se le suma uno al carry
			add r0,r0,r6		;y se resta ese uno del bit 12


zero		add r2,r2,#-1		; se corre tantas veces hacia la izquierda como lo
								; indique R2
			brp op_shiftLx		; mientras que r2 sea zero o positivo, se sigue 	
								; multiplicando por 10(bin)
				
			add r3,r4,#0		;el carry estara en r3		
			ld r2, guarlx2 		;R0 es el resultado del programa , r1 es el operando,
			ld r4, guarlx4 		;R2 son los desplazamientos, r3 es el carry (12b)
			ld r5, guarlx5
			ld r6, guarlx6
zeros
RET
			guarlx2 .BLKW 1
			guarlx4 .BLKW 1
			guarlx5 .BLKW 1
			guarlx6 .BLKW 1



;_____________________________________________________________________

;________________________________SHIFTRX_________________________________
		; Funcion para mover cadenas de 11 bits hacia la derecha
		; con carry de 11 bits
		; se recibe en r0 el dato a mover y en r1 
		; el numero de posiciones a desplazar
		; se da la respuesta en r2 (solucion) y r3 (carry), 

SHIFTRX	st r0, numrx
		st r1, timesrx
		and r2,r2,#0 ;solucion al problema(cociente entre 2)
		and r3,r3,#0
		lea r3,numrx
		str r4,r3,#1 ;guardo los datos para usar los registros libremente
		str r5,r3,#2
		str r6,r3,#3

		and r4,r4,#0
		and r3,r3,#0
		ld r5,mascb1
		
			add r1,r1,#0
			brz cero
shiftrx_op  and r6,r0,r5
			brz bitmov
			ld r5,mascb12
			add r4,r4,r5
			ld r5,mascb1
bitmov		add r3,r0,#0	; se guarda en r2 el valor actual para verificar si ya terminé
			add r3,r3,#-1
			brnz steprx 		; se le resta -1 y si es negativo o cero ya termine

			add r2,r2,#1
			add r0,r0,#-2
			brp bitmov		; si el numero almacenado es mayor que cero, volver a dividir 
							; entre diez
							; se debe realizar las operaciones anteriores tantas veces
steprx		

			add r4,r4,#0
			brz carry
			and r6,r6,#0
carry_mov	add r6,r6,#1
			add r4,r4,#-2
			brp carry_mov

carry		add r4,r6,#0	; r4 contiene el carry movido a la derecha
			add r0,r2,#0	;r0 continene el elemento corrido a la derecha
			and r2,r2,#0
			add r1,r1,#-1	
			brp shiftrx_op


cero		ld r1,timesrx
			add r2,r0,#0
			add r3,r4,#0


			ld r0,numrx
			lea r6,numrx
			ldr r4,r6,#1
			ldr r5,r6,#2
			ldr r6,r6,#3
			ret


		numrx .blkw 4 ;
		timesrx .blkw 1;
		mascb1 .fill x0001;
		
		;mascb11 .fill x0400	;0000010000000000 mascara para el bit 11
		;mascb12 .fill x0800	;0000100000000000 mascara para el bit 12

;_____________________________________________________________________		

;__________________________________________________________________
;_______________________DIVISION___________________________________ 
; recibe r4 y r5 y hace la division R4/R5
;
DIVISION

lea r0, save
str r3, r0,#1
str r4, r0,#2
str r5, r0,#3
str r6, r0,#4
str r7, r0,#5



and r0,r0, #0	;se inicializan todos los registros en cero
and r3,r3, #0
and r4,r4, #0
and r5,r5, #0
and r6,r6, #0
and r7,r7, #0
;
st r1, N1		;el dividendo y el divisor se encuentran almacenados en n1 y n2
st r2,N2
;
ld r0,signo
and r4,r1,r0
and r5,r2,r0
add r0,r4,r5
st  r0, signoF	;extraigo el signo de ambos operadores, lo opero y lo almaceno
;
ld r0, signo
not r0,r0
and r4,r1,r0  
st  r4,N1
and r5,r2,r0
st  r5,N2
;
ld r0, unoinv
ld r3, mantisa
and r4,r1,r3
add r4,r4,r0
st r4,MAN1 		;Extraigo las mantisas de los numeros para operarlas
and r5,r2,r3 	; y hago comparaciones de magnitud con ellas
add r5,r5,r0
st r5,MAN2

;
;------------ mantisa1 < mantisa2
not r5,r5
add r5,r5, #1
add r5,r5 ,#4
brzp cambio
and r5,r5,#0
add r5,r5, #1
st r5, permit
cambio
;
JSR DIV 	;calculo la division de mantisas
;
ld r3, expo 	;saco los exponentes de los numeros
ld r1, N1
ld r2, N2
and r4,r1,r3; EXPONENTE 1
st r4, E1
and r5,r2,r3; EXPONENTE 2
st r5, E2
;
JSR DESPLAZAMIENTO
;
ld r3, bias 	;calculo y realizo los desplazamientos necesarios en los exponentes
not r3,r3
add r3,r3,#1
;
ld r1, exponentecorr
ld r2, exponentecorr2
;
add r4, r1, r3
st r4, expobias1
add r5,r2,r3
ld r0, permit
brz label
add r5,r5, #1
label
st r5, expobias2
;
not r5,r5
add r5,r5,#1
;
add r6,r4,r5; resta exponentes
ld r3,bias
add r6,r6,r3
ld r3,DIEZ
LACH
add r6,r6,r6
add r3,r3,#-1
brnp LACH
;
st r6,expoF
ld r1,DEC
ld r0,expoF
add r0,r1,r0
;
ld r1,signoF
add r0,r1,r0
;
st r0, Resultado
;
ld r1,N1
Ld r2,N2

lea r6, save
ldr r3, r6,#1
ldr r4, r6,#2
ldr r5, r6,#3
ldr r7, r6,#5
ldr r6, r6,#4

RET
;

;division para un registro de 32 bits de longitud
DIV
st r5,saveR5
st r4,saveR4
st r3,saveR3
st r6,saveR6
st r0,saveR0 ; REGISTRO PARTE ENTERA
st r1,saveR1 ; REGISTRO PARTE FRACCION
st r7,saveR7
;
ld r4,MAN1
ld r5,MAN2
and r0,r0,#0
and r1,r1,#0
add r6,r5,#0
;
ld r0,permit
brz jh
add r4,r4,r4
jh
add r0,r0,#0
;
not r5,r5
add r5,r5,#1
add r4,r4,r5
brzp GO
ld r5,debajo
add r4,r4,r4
GO
;
ld r3,DIEZ
add r3,r3,#1
POLS
brz salir
;
add r1,r1,r1
add r0,r4,r5
brzp correr
add r0,r0,#0
brnzp juts
;
correr
add r1,r1,#1
add r4,r4,r5
juts 
add r4,r4,r4
add r3,r3,#-1
brnzp POLS
;
salir
st r1,DEC
ld r5,saveR5
ld r4,saveR4
ld r3,saveR3
ld r6,saveR6
ld R7,saveR7
RET
;
MENOSUNO .FILL X0400
CINCO .FILL X0005
debajo .FILL XFC00
DIEZ .FILL X000A
QUINCE .FILL X000F
expo .FILL X7C00 
mantisa .FILL X03FF
signo .FILL X8000
exponentecorr .BLKW 1
exponentecorr2 .BLKW 1
expobias1 .BLKW 1
expobias2 .BLKW 1
bias .FILL X000F
;
MAN1 .BLKW 1
MAN2 .BLKW 1
S1 .BLKW 1
S2  .BLKW 1
signoF  .BLKW 1
permit .BLKW 1
;
expoF .BLKW 1
MF .BLKW 1
save .blkw 7
saveR5 .BLKW 1
saveR2 .BLKW 1
saveR4 .BLKW 1
saveR3 .BLKW 1
saveR6 .BLKW 1
saveR1 .BLKW 1
saveR0 .BLKW 1
saveR7 .BLKW 1
ENT .BLKW 1
DEC .BLKW 1
unoinv .FILL X0400 
;
JAH .FILL X07FF
JAL .FILL X03FF
;
Resultado .BLKW 1
;
N1 .blkw 1;X4B40
N2 .blkw 1;X4280
OVERFLOW .FILL XFFFF
ERR .FILL XFFFF
E1 .BLKW 1
E2 .BLKW 1
ERROR;
ld r0, ERR;
HALT
;
DESPLAZAMIENTO
st r5, saveR5
st r6, saveR6
st r4, saveR4
st r1, saveR1
st r2, saveR2  
st r3, saveR3
st r7, saveR3
;
and r5,r5,#0
and r6,r6,#0
ld r1, E1
ld r4, CINCO
LOPO
add r1,r1,r1 ;-----------MOVEMOS EL EXPONENTE UNO A LA IZQUIERDA PAR ELIMINAR EL CERO DEL SIGNO
brn sumauno
add  r1,r1,#0
brzp sumacero
;
sumauno
;
add r5,r5,r5
add r5,r5,#1
add r4,r4,#-1
brnp LOPO
add r4,r4,#0
brz CORR
;
sumacero
;
add r5,r5,r5
add r5,r5,#0
add r4,r4,#-1
brnp LOPO
add r4,r4,#0
brz CORR
;
CORR 
and r1,r1,#0 ;-----------NUEVO REGISTRO DESTINADO PARA EL EXPONENTE 1
and r1,r1,r5;
st r1, exponentecorr
;
and r0,r0,#0
and r1,r1,#0
and r2,r2,#0
and r3,r3,#0
and r4,r4,#0
and r5,r5,#0
and r6,r6,#0
;
ld r2,E2
ld r4,CINCO
LOPO2
add r2,r2,r2 ;------------MOVEMOS EL EXPONENTE UNO A LA IZQUIERDA PAR ELIMINAR EL CERO DEL SIGNO
brn sumauno2
add r2,r2,#0
brzp sumacero2
;
sumauno2
;
add r6,r6,r6
add r6,r6,#1
add r4,r4,#-1
brnp LOPO2
add r4,r4,#0
brz corr2
;
sumacero2
;
add r6,r6,r6
add r6,r6,#0
add r4,r4,#-1
brnp LOPO2
add r4,r4,#0
brz corr2
;
corr2
;
and r2,r2,#0 ;-----------NUEVO REGISTRO DESTINADO PARA EL EXPONENTE 2
and r2,r2,r6;
st r2, exponentecorr2
;
ld r5, saveR5
ld r6, saveR6
ld r4, saveR4
ld r3, saveR3
ld r2, saveR2
ld r1, saveR1
RET
;__________________________________________________________________