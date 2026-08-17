# El cartucho

Son 16384 bytes, y ya está. No hay cargador, ni bloques, ni nada que esperar: el
MSX mapea el cartucho en 0x8000-0xBFFF —la página 2— y lo que hay ahí es lo que
hay para siempre. Una sola foto de la memoria, sin solapes: ninguna dirección
significa dos cosas distintas en dos momentos distintos.

## Por dónde entra

Los primeros dieciséis bytes son la cabecera que lee la BIOS:

    41 42 13 80 00 00 00 00 00 00 00 00 00 00 00 00
    'A' 'B'  \_ INIT = 0x8013

Las dos letras son la firma que le dice a la máquina que ahí hay un cartucho
ejecutable, y detrás van cuatro vectores de dos bytes. Solo el primero está
puesto: los otros tres —STATEMENT, DEVICE y TEXT, los que servirían para añadir
instrucciones al BASIC o para declarar un dispositivo— están a cero. Este
cartucho es un juego y nada más.

Detrás de la cabecera, en 0x8010, hay tres bytes que no son cabecera y tampoco
se ejecutan nunca aquí: `C3 F7 80`, o sea un `jp 0x80F7` ya montado. El arranque
los copia tal cual al gancho de interrupción, y es ahí donde se ejecutan.

## Lo que hace el arranque

INIT (0x8013) es corto y muy medido:

- borra los 4 KB de 0xE000 a 0xEFFF de un tirón (0x8017), que es donde va a
  vivir todo el estado del juego, y pone la pila en 0xE54B (0x8023);
- calla el chip de sonido (0x8026) y deja a cero los 16 KB de memoria de vídeo
  (0x802D);
- copia los tres bytes de 0x8010 al gancho H.KEYI, en 0xFD9A (0x803C-0x8046);
- pasa por la presentación (0x805C), vuelve, vuelve a borrar la memoria de vídeo
  y carga los sprites;
- prepara la partida y se mete en un bucle de dos bytes, en 0x80F5.

Ese bucle vacío es el programa principal. **A partir de ahí el juego entero
corre dentro de la interrupción**, cincuenta o sesenta veces por segundo, y el
hilo que arrancó la máquina no vuelve a hacer nada nunca.

## Dónde vive el estado

En el cartucho no hay ni una variable, porque es ROM. Todo lo que el juego
apunta vive en la RAM del MSX a partir de 0xE000, y por eso el listado está
lleno de direcciones que empiezan por 0xE0: no son datos del cartucho, son
variables.

Las que más se leen:

| | |
|---|---|
| 0xE012 | las vidas que quedan |
| 0xE05F | lo que se está pulsando, en formato de joystick |
| 0xE1D0-0xE1D4 | el reloj, guardado ya como números de casilla |
| 0xE1D6-0xE1DB | los seis dígitos del marcador |
| 0xE1E6-0xE1ED | los cuatro vectores de sonido |
| 0xE20E-0xE21B | la copia de los catorce registros del chip de sonido |
| 0xE21D-0xE220 | los 32 bits de los tesoros que ya te has llevado |
| 0xE221 | si lo que corre es la demo |
| 0xE222 | **el registro de pantalla**: el mundo entero cabe aquí |
| 0xE224 / 0xE225 | la variante y el tipo de la escena, sacados de 0xE222 |
| 0xE229-0xE246 | las diez cajas de colisión |
| 0xE247 | cuántos objetos vivos hay, y detrás un puntero por objeto |
| 0xE26A-0xE2BD | la tabla de atributos de sprite, que se vuelca entera cada cuadro |

Y detrás de esa tabla van las estructuras de los objetos, una pegada a la otra
sin un hueco: 0xE2BF, 0xE2D5 (el jugador), 0xE2ED, 0xE303, 0xE319 y 0xE32F. La
del jugador ocupa 24 bytes y las otras cinco 22, que es justo lo que hace falta
para que la cadena cierre en 0xE345.

## La pantalla, y los tres registros que el juego no toca

El cartucho escribe los registros del chip gráfico en cinco sitios contados, y
solo escribe cinco de los ocho: el 0 y el 1 (modo y pantalla), el 3 y el 4 (las
bases de color y de dibujo) y el 7 (el fondo, en 0x8036, valor 0x11: negro).

**Los registros 2, 5 y 6 no los escribe nadie.** Son los que dicen dónde están
la tabla de nombres, los atributos de sprite y los patrones de sprite, y sin
embargo el juego escribe en 0x1800, en 0x1B00 y en 0x3800-0x3FFF a lo largo de
todo el listado. O sea que da por buenas las bases que le dejó puestas la BIOS y
no se molesta en repetirlas.

El reparto que sale es este:

| | |
|---|---|
| 0x0000 | los patrones de casilla (registro 4 = 0x00, en 0xB79A) |
| 0x1800 | la tabla de nombres |
| 0x1B00 | los atributos de sprite |
| 0x2000 | los colores (registro 3 = 0x80, en 0xB794) |
| 0x3800 | los patrones de sprite |

El registro 1 vale 0xE2 (0x8047): 16 KB, pantalla e interrupción encendidas y
sprites de 16x16.

Hay un detalle que se paga en bytes: **la presentación va en un modo y el juego
en otro**. En 0xB6B2 el registro 0 se pone a 0x02 —modo gráfico 2, el de los
tres bancos independientes— para el rótulo de entrada, y al salir, en 0xB788,
vuelve a 0x00, modo gráfico 1. Por eso la tabla de colores del juego son 32
bytes y no 6144: en el modo del juego el color va por grupo de ocho casillas, no
por casilla.

## Cómo están guardados los dibujos

Hay un descompresor de 58 bytes en 0xB142 que vuelca directamente al puerto de
vídeo. El formato se lee entero en él: dos bytes de dirección de destino y luego
tokens de un byte con el contador en los seis bits bajos —bit 7 saltar N
posiciones, bit 6 copiar N bytes literales, ninguno de los dos repetir N veces
el byte siguiente, y un cero cierra—.

Con eso van comprimidos los patrones de casilla y de sprite (0x909E-0x95FE), los
nueve bloques de sprite de los manejadores de escena (0x981E-0x99AF) y los seis
de la presentación (0xBAB2-0xBC61). Lo que no va comprimido son los cuatro
juegos de 16 casillas del decorado (0x95FE-0x97FE) y siete patrones de sprite
sueltos: el de relleno de 0x97FE-0x981E y los seis de 0x99AF-0x9A6F, de 32 bytes
cada uno, sin nada que ahorrar.

Cada bloque comprimido acaba **exactamente** donde empieza el siguiente, y eso
es lo que fija su tamaño sin tener que suponerlo.

## La tipografía cabe en doce casillas

En este cartucho no hay ni una cadena de texto. Lo único parecido a una fuente
son doce casillas: los diez dígitos (0xB8-0xC1), los dos puntos (0xC2) y el
blanco (0xC3). Con eso se escriben el marcador y el reloj, y no da para una sola
letra. Todo lo demás que parece texto en la pantalla es dibujo.

## El reparto completo

Ni un byte sin dueño: 9467 de código que el trazador alcanza siguiendo el flujo
de verdad y 6917 de datos, cada uno dentro de un rango declarado con la
instrucción que lo lee escrita al lado.

| | |
|---|---|
| 0x8000-0x8010 | la cabecera |
| 0x8010-0x8013 | los tres bytes que se copian al gancho de interrupción |
| 0x8013-0x8A69 | arranque, el jugador, las colisiones, el salto, el marcador y las vidas |
| 0x8A69-0x8AFF | inicializadores de RAM, la tabla de clases, la curva del salto y los guiones de andar |
| 0x8AFF-0x8E1B | carga de pantalla y de sprites, y el pintado de la escena |
| 0x8E1B-0x8F06 | los tramos de suelo y los seis patrones del hundimiento |
| 0x8F06-0x9090 | los guiones de celdas del decorado |
| 0x9090-0x909E | catorce números de casilla en crudo: la fila 23 de la pantalla |
| 0x909E-0x95FE | los cinco bloques grandes de gráficos comprimidos |
| 0x95FE-0x97FE | los cuatro juegos de 16 casillas del decorado |
| 0x97FE-0x9A6F | los sprites: nueve bloques comprimidos y siete patrones en crudo |
| 0x9A6F-0xA086 | el cuadro, los objetos, el cambio de pantalla, el marcador y el reloj |
| 0xA086-0xA43A | las tablas de decorado, los cuatro layouts de escena y la de 14x18 |
| 0xA43A-0xA61A | la liana |
| 0xA61A-0xA69E | las 33 pendientes con las que se traza la liana |
| 0xA69E-0xAE90 | los manejadores de objeto y las ocho rutinas de escena |
| 0xAE90-0xAED4 | las cuatro tablas de despacho |
| 0xAED4-0xB113 | guiones de celdas, plantillas de objeto, guiones de animación y los colores |
| 0xB113-0xB393 | la capa de vídeo, la entrada y el volcado del sonido |
| 0xB393-0xB6B1 | la tabla de sonidos y las nueve rutinas que instala |
| 0xB6B1-0xB9E4 | la presentación y la demo |
| 0xB9E4-0xBC6D | las tablas y los gráficos de la presentación |
| 0xBC6D-0xC000 | el relleno hasta los 16 KB: 915 bytes, todos a cero |
