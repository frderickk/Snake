 /*ORGANIZACION DEL COMPUTADOR - TP ARM - SNAKE! - COM 0100b*/
		/*Espinillo,  Elias Natanael*/
		 /*Farias, Federico Emanuel*/


.data

mapa: .asciz "+------------------------------------------------+\n|               ****************                 |\n|               *** VIBORITA ***                 |\n|               ****************                 |\n+------------------------------------------------+\n|                                                |\n|                                                |\n|                                                |\n|                                                |\n|                                                |\n|                                                |\n|                                                |\n|                                                |\n|                                                |\n+------------------------------------------------+\n| Puntaje:                      Nivel:    -      |\n+------------------------------------------------+\n"
longitud = . - mapa
tecla: .ascii " "
lentecla= .-tecla
cls: .asciz "\x1b[H\x1b[2J" @borra pantalla
lencls = . - cls
viborita: .ascii "@"
espacio: .ascii " "
asterisco: .ascii "*"
mensajefinal: .ascii "Game Over!\n"
lenmensajefinal= .-mensajefinal
manzana: .ascii "M"
puntaje: .ascii "0"


.text

//Funciones para escribir o leer la posicion en el mapa

//Escribir el char necesario para mostrar en el tablero
//Inputs: r0 = dir movimiento, r2 = reg para escribir el char,
//r3 = cargo mapa y verifico posicion
//Output: r2 = sobreescribe en en r3 el ascii
//r3 = guarda lo de r2 en el mapa

escribir:
	.fnstart
		push {r0, lr}
		ldr r3, =mapa	@cargo el mapa
		add r3,r0  	@me desplazo hasta la posicion indicada en el movimiento
		strb r2, [r3]	@escribo el movimiento en el mapa cargado en r3
		pop {r0, lr}
  		bx lr
	.fnend

//Lectura del char en la posicion del tablero
//Input: r0 = posicion del movimiento, r2 = registro de lectura,
//r3 = cargo el mapa
//Output: r2 = lee el contenido de r3, r3 = verifica lo que haya en el mapa

leer:
        .fnstart
                push {lr}
                ldr r3, =mapa   @cargo el mapa
                add r3,r0       @me desplazo a la posicion del movimiento
                ldrb r2, [r3]   @leo el ascii de la posicion actual del mapa cargado en r3
                pop {lr}
                bx lr
        .fnend


//Funciones de entrada y salida
//Salida por pantalla

imprimir:
  	.fnstart
		push {r0, lr}
		mov r7, #4
		mov r0, #1
		swi 0
		pop {r0, lr}
		bx lr
  	.fnend

//Lectura de teclado

leertecla:
	.fnstart
		push {r0, lr}
		mov r7, #3
		mov r0, #0
        	ldr r1, =tecla		@tecla + enter
		ldr r2, =lentecla
		swi 0
		pop {r0, lr}
		bx lr
	.fnend

//Borrador de pantalla que nos dieron en el TP

borrarpantalla:
        .fnstart
                push {r0, lr}
                mov r0, #1
                ldr r1, =cls
                ldr r2, =lencls
                mov r7, #4
                swi 0
                pop {r0, lr}
                bx lr
        .fnend


//Funciones de movimiento de la cabeza de la vibora

//Input y output: r0 = es donde cargamos la posicion inicial de la vibora
//y la modificamos segun el movimiento que se haga

moverabajo:
        .fnstart
		add r0, #51	@sumamos a la posicion actual para movernos una fila abajo
		bx lr
        .fnend

moverarriba:
	.fnstart
		sub r0, #51	@restamos a la posicion actual para movernos una fila arriba
		bx lr
	.fnend

moverizquierda:
        .fnstart
                sub r0, #1      @restamos a la posicion actual para movernos una columna
		bx lr		@hacia la izquierda
        .fnend

moverderecha:
	.fnstart
		add r0, #1	@sumamos a la posicion actual para movernos una columna
		bx lr		@hacia la derecha
	.fnend


//Funciones de borrar (colocar espacio), agregar (colocar *) y cabeza (colocar @)

//Input: r1 = cargamos los ascii, r2 = vemos el contenido de r1 y lo escribimos en el mapa

borrar:
	.fnstart
		push {lr}
		ldr r1, =espacio
		ldrb r2, [r1]
		bl escribir
		pop {lr}
		bx lr
	.fnend

cabeza:
	.fnstart
		push {lr}
		ldr r1, =viborita
		ldrb r2, [r1]
		bl escribir
		pop {lr}
		bx lr
	.fnend


//Modificadores de ultimo asterisco

//Input y output: r10 = es donde se cargo previamente las posiciones de *s y los modificamos

moverabajoasterisco:
        .fnstart
		add r10, #51 	@sumamos a la posicion actual para mover el * una fila abajo
		bx lr
        .fnend

moverarribaasterisco:
	.fnstart
		sub r10, #51  	@restamos a la posicion actual para mover el * fila arriba
		bx lr
	.fnend

moverizquierdaasterisco:
        .fnstart
		sub r10, #1 	@restamos a la posicion actual para mover el * una columna
		bx lr		@hacia la izquierda
        .fnend

moverderechaasterisco:
	.fnstart
		add r10, #1   	@sumamos a la posicion actual para mover el * una columna
		bx lr		@hacia la derecha
	.fnend


//Funciones para dibujar lo que se necesite segun el movimiento

//Input y output: r0 = utiliza el movimiento del * de r10 y lo sobreescribe,
//r1 = carga el ascii del *, r2 = lee el contenido de r1,
//r10 = tenemos el movimiento realizado por los asteriscos

agregarasterisco:
	.fnstart
		push {r0,lr}
		ldr r1, =asterisco
		ldrb r2, [r1]
		mov r0, r10
		bl escribir
		pop {r0,lr}
		bx lr
	.fnend

borrarasterisco:
	.fnstart
		push {r0, lr}
		mov r0, r10
		bl borrar
		pop {r0, lr}
		bx lr
	.fnend

guardarreg10:
	.fnstart
		push {lr}
		mov r10, r0
		pop {lr}
		bx lr
	.fnend


//Calculo mi proxima posicion del asterisco verificando
//que la posicion que sigue sea un *, si lo es guardamos
//esa posicion para poder seguir el movimiento de la vibora
//Input y output: r0 = utiliza el movimiento de r10 y le suma uno para
//leer la posicion, r2 = comparo si tengo un * y lo guardo en r10

proximaposicionasterisco:
	.fnstart
		push {r0, lr}

			//Verificamos si se mueve y modifica segun el movimiento
			//de la cabeza para seguir el rastro, por eso usamos
			//la subrutina para guardar en r10 aparte.

			mov r0, r10
			add r0, #1		@si se mueve a la derecha
			bl leer
			cmp r2, #'*'
			bleq guardarreg10
			cmp r2, #'*'
			beq finpos

			mov r0, r10
			add r0, #51		@si se mueve para abajo
			bl leer
			cmp r2, #'*'
			bleq guardarreg10
			cmp r2, #'*'
			beq finpos

			mov r0, r10
			sub r0, #51		@si se mueve para arriba
			bl leer
			cmp r2, #'*'
			bleq guardarreg10
			cmp r2, #'*'
			beq finpos

			mov r0, r10
			sub r0, #1		@si se mueve a la izquierda
			bl leer
			cmp r2, #'*'
			bleq guardarreg10
			cmp r2, #'*'
			beq finpos
	finpos:
		pop {r0, lr}
		bx lr
	.fnend


//Carga y dibuja en el mapa el * sin r0
//Input y output: r1 = carga el ascii, r2 = lee el contenido de r1

cargarasteriscosinr0:
	.fnstart
		push {lr}
		ldr r1, =asterisco
		ldrb r2, [r1]
		bl escribir
		pop {lr}
		bx lr
	.fnend


//Funciones de comer manzana y agregar *

//Muevo r10 dependiendo de si como una manzana en una direccion especifica y
//actualizo el puntaje segun corresponda
//Input: r0 = posicion del puntaje r1 = cargo el puntaje, r2 = lee el contenido de r1,
//r4 = suma 1 al puntaje si come manzana y lo suma al contador
//Output: r2 = actualiza el puntaje, r10 = agrega en la posicion necesaria

comimanzanader:
	.fnstart
		push {r0, lr}
		ldr r1, =puntaje
		ldrb r2, [r1]
		mov r0, #780		@pos del puntaje en el mapa
		add r4, #0x1
		add r2, r4
		bl escribir
		sub r10, #1
		pop {r0, lr}
		bx lr
	.fnend

comimanzanaizq:
	.fnstart
		push {r0, lr}
		ldr r1, =puntaje
		ldrb r2, [r1]
		mov r0, #780		@pos del puntaje en el mapa
		add r4, #0x1
		add r2, r4
		bl escribir
		add r10, #1
		pop {r0, lr}
		bx lr
	.fnend

comimanzanaup:
	.fnstart
		push {r0, lr}
		ldr r1, =puntaje
		ldrb r2, [r1]
		mov r0, #780		@pos del puntaje en el mapa
		add r4, #0x1
		add r2, r4
		bl escribir
		add r10, #51
		pop {r0, lr}
		bx lr
	.fnend

comimanzanadown:
	.fnstart
		push {r0, lr}
		ldr r1, =puntaje
		ldrb r2, [r1]
		mov r0, #780		@pos del puntaje en el mapa
		add r4, #0x1
		add r2, r4
		bl escribir
		sub r10, #51
		pop {r0, lr}
		bx lr
	.fnend


//Funcion para finalizar por impacto de bordes

//o movimientos prohibidos (comerse a si misma o yendo en direccion
//contraria a su cabeza),

finimpacto:
	.fnstart
		push {lr}
		bl cabeza
		bal fin
		pop {lr}
	.fnend


//Main

.global main
main:

	//Cargamos la cabeza
	//de la vibora
	ldr r1, =viborita
	ldrb r2, [r1]
	mov r0, #320
	bl escribir


	//Cargo los asteriscos
	//al inicio del mapa
	ldr r1, =asterisco
	ldrb r2, [r1]
	mov r0, #316
	add r0, #1
	mov r10, r0
	bl escribir
	add r0, #1
	bl escribir
	add r0, #1
	bl escribir


	//Escribo las manzanas
	//en el mapa
	ldr r1, =manzana
	ldrb r2, [r1]
	mov r0, #340
	bl escribir
	add r0, #30
	bl escribir
	add r0, #60
	bl escribir
	add r0, #35
	bl escribir
	add r0, #75
	bl escribir
	add r0, #55
	bl escribir
	add r0, #10
	bl escribir
	add r0, #25
	bl escribir
	add r0, #15
	bl escribir


	//Cargo y escribo el puntaje en la posicion necesaria
	ldr r1, =puntaje
	ldrb r2, [r1]
	mov r0, #780
	mov r4, #0			@contador de puntaje
	bl escribir


	//Vuelvo a la posicion del @
	mov r0,#320

	//Dibujamos el mapa en pantalla con lo que se necesita
	ldr r1, =mapa	 		@cargamos el mapa
	ldr r2, =longitud   		@cargamos len del mapa
	bl imprimir


//Luego de cargar y escrbir en el mapa todo lo necesario comenzamos el ciclo

ciclo:
	//Leemos la tecla ingresada
	bl leertecla
	ldrb r2, [r1]


	//Verificacion de las teclas ingresadas

	cmp r2, #'s'
	beq abajo		@si tecleamos s ira hacia abajo

	cmp r2, #'w'
        beq arriba		@si tecleamos w ira hacia arriba

	cmp r2, #'a'
        beq izq			@si tecleamos a ira hacia la izquierda

	cmp r2, #'d'
        beq der			@si tecleamos d ira hacia la derecha

	cmp r2, #'q'
	beq fin			@si tecleamos q saldremos del programa

	bal ciclo		@valida que no se toquen otras teclas que no sean
				@las permitidas


//Parte del ciclo que se encarga de borrar pantalla, cargar los char necesarios
//leer que hay y que sigue en las posiciones, comparar y verificar las colisiones
//y escribir en el mapa ya sea la vibora o escribir el rastro

	abajo:
		bl borrarpantalla		@borramos la pantalla

		//Movimiento de los *
		bl cargarasteriscosinr0
		bl borrarasterisco
		bl proximaposicionasterisco
		bl agregarasterisco

		//Movimiento de @
		bl moverabajo

		//Verificacion con piso
		bl leer
		cmp r2, #'-'
		beq finimpacto

		//Verificacion de autocomerse
		bl leer
		cmp r2, #'*'
		beq finimpacto

		//Verificacion de comer manzana
		bl leer
		cmp r2, #'M'
		bleq comimanzanadown
		bl agregarasterisco

		//Luego de las verificaciones se escribe el @
		bl cabeza
		bal seguir		@seguimos a la etiqueta que muestra por pantalla


	arriba:
		bl borrarpantalla	@borramos la pantalla

		//Movimiento de los *
		bl cargarasteriscosinr0
		bl borrarasterisco
		bl proximaposicionasterisco
		bl agregarasterisco

		//Movimiento de @
		bl moverarriba

		//Verificacion con techo
		bl leer
		cmp r2, #'-'
		beq finimpacto

		//Verificacion de autocomerse
		bl leer
		cmp r2, #'*'
		beq finimpacto

		//Verificacion de comer manzana
		bl leer
		cmp r2, #'M'
		bleq comimanzanaup
		bl agregarasterisco

		//Luego de las verificaciones se escribe el @
		bl cabeza
		bal seguir		@seguimos a la etiqueta que muestra por pantalla


	izq:
		bl borrarpantalla	@borramos la pantalla

		//Movimiento de los *
		bl cargarasteriscosinr0
		bl borrarasterisco
		bl proximaposicionasterisco
		bl agregarasterisco

		//Movimiento de @
		bl moverizquierda

		//Verificacion con pared
		bl leer
		cmp r2, #'|'
		beq finimpacto

		//Verificacion de autocomerse
		bl leer
		cmp r2, #'*'
		beq finimpacto

		//Verificacion de comer manzana
		bl leer
		cmp r2, #'M'
		bleq comimanzanaizq
		bl agregarasterisco

		//Luego de las verificaciones se escribe el @
		bl cabeza
		bal seguir		@seguimos a la etiqueta que muestra por pantalla


	der:
		bl borrarpantalla	@borramos la pantalla

		//Movimiento de los *
		bl cargarasteriscosinr0
		bl borrarasterisco
		bl proximaposicionasterisco
		bl agregarasterisco

		//Movimiento de @
		bl moverderecha

		//Verificacion con pared
		bl leer
		cmp r2, #'|'
		beq finimpacto

		//Verificacion de autocomerse
		bl leer
		cmp r2, #'*'
		beq finimpacto

		//Verificacion de comer manzana
		bl leer
		cmp r2, #'M'
		bleq comimanzanader
		bl agregarasterisco

		//Luego de las verificaciones se escribe el @
		bl cabeza
		bal seguir		@seguimos a la etiqueta que muestra por pantalla


//Mostramos por pantalla lo sucedido anteriormente en el ciclo de movimientos

seguir:

	ldr r1, =mapa	 		@cargamos el mapa
	ldr r2, =longitud   		@cargamos len del mapa
	bl imprimir
					@volvemos siempre al ciclo de deteccion de teclas
        bal ciclo                       @y movimiento de la viborita


//Terminamos el programa

fin:

	ldr r1, =mapa			@cargamos el mapa por ultima vez
	ldr r2, =longitud		@cargamos el len del mapa
	bl imprimir

	ldr r1, =mensajefinal		@cargamos el mensaje de Game over!
	ldr r2, =lenmensajefinal	@cargamos el len del mensaje
	bl imprimir			@mostramos el mensaje

	mov r7, #1
	swi 0

