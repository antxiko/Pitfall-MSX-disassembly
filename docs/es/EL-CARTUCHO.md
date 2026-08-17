# El cartucho

Son 16384 bytes. No hay cargador ni bloques: el MSX mapea el cartucho en
0x8000-0xBFFF —la página 2— y esa es toda la foto de la memoria, sin solapes:
ninguna dirección significa dos cosas en dos momentos distintos.

## Por dónde entra

Los primeros dieciséis bytes son la cabecera que lee la BIOS:

    41 42 13 80 00 00 00 00 00 00 00 00 00 00 00 00
    'A' 'B'  \_ INIT = 0x8013

Las dos letras marcan un cartucho ejecutable; de los cuatro vectores solo está
puesto INIT —STATEMENT, DEVICE y TEXT, los del BASIC, van a cero—.

En 0x8010 hay tres bytes que no son cabecera y tampoco se ejecutan aquí:
`C3 F7 80`, un `jp 0x80F7` ya montado. El arranque los copia al gancho de
interrupción, y ahí es donde corren.

## Lo que hace el arranque

INIT (0x8013):

- borra 0xE000-0xEFFF de un tirón (0x8017), donde vivirá el estado, y pone la
  pila en 0xE54B (0x8023);
- calla el chip de sonido (0x8026) y borra los 16 KB de memoria de vídeo
  (0x802D);
- copia los tres bytes de 0x8010 al gancho H.KEYI, 0xFD9A (0x803C-0x8046);
- pasa por la presentación (0x805C), vuelve a borrar la memoria de vídeo y
  carga los sprites;
- prepara la partida y se mete en un bucle de dos bytes, 0x80F5.

Ese bucle vacío es el programa principal. **El juego entero corre dentro de la
interrupción**, cincuenta o sesenta veces por segundo.

## Dónde vive el estado

Todo lo que el juego apunta vive en la RAM a partir de 0xE000. Las direcciones
más leídas:

| | |
|---|---|
| 0xE012 | las vidas que quedan |
| 0xE05F | lo que se está pulsando, en formato de joystick |
| 0xE1D0-0xE1D4 | el reloj, guardado ya como números de casilla |
| 0xE1D6-0xE1DB | los seis dígitos del marcador |
| 0xE1E6-0xE1ED | los cuatro vectores de sonido |
| 0xE20E-0xE21B | la copia de los catorce registros del chip de sonido |
| 0xE21D-0xE220 | los 32 bits de los tesoros ya recogidos |
| 0xE221 | si lo que corre es la demo |
| 0xE222 | **el registro de pantalla**: el mundo entero cabe aquí |
| 0xE224 / 0xE225 | la variante y el tipo de la escena, sacados de 0xE222 |
| 0xE229-0xE246 | las diez cajas de colisión |
| 0xE247 | cuántos objetos vivos hay, y detrás un puntero por objeto |
| 0xE26A-0xE2BD | la tabla de atributos de sprite, volcada entera cada cuadro |

Detrás van las estructuras de los objetos, pegadas sin hueco: 0xE2BF, 0xE2D5
(el jugador), 0xE2ED, 0xE303, 0xE319 y 0xE32F. La del jugador ocupa 24 bytes y
las otras cinco 22, con lo que la cadena cierra en 0xE345.

## La pantalla, y los tres registros que el juego no toca

El cartucho escribe cinco de los ocho registros del chip gráfico: el 0 y el 1
(modo y pantalla), el 3 y el 4 (bases de color y dibujo) y el 7 (el borde,
0x11: negro, en 0x8036).

**Los registros 2, 5 y 6 no los escribe nadie**: son los que dicen dónde están
la tabla de nombres, los atributos de sprite y los patrones de sprite, y el
juego escribe en 0x1800, 0x1B00 y 0x3800-0x3FFF dando por buenas las bases que
dejó la BIOS.

| | |
|---|---|
| 0x0000 | los patrones de casilla (registro 4 = 0x00, en 0xB79A) |
| 0x1800 | la tabla de nombres |
| 0x1B00 | los atributos de sprite |
| 0x2000 | los colores (registro 3 = 0x80, en 0xB794) |
| 0x3800 | los patrones de sprite |

El registro 1 vale 0xE2 (0x8047): 16 KB, pantalla e interrupción encendidas,
sprites de 16x16.

**La presentación va en un modo y el juego en otro**: 0xB6B2 pone el registro 0
a 0x02 —modo gráfico 2— para el rótulo de entrada, y 0xB788 lo devuelve a 0x00,
modo gráfico 1. Por eso la tabla de colores del juego son 32 bytes y no 6144:
en el modo del juego el color va por grupo de ocho casillas.

## Cómo están guardados los dibujos

Hay un descompresor de 58 bytes en 0xB142 que vuelca directamente al puerto de
vídeo. El formato: dos bytes de dirección de destino y tokens de un byte con el
contador en los seis bits bajos —bit 7 saltar N posiciones, bit 6 copiar N
literales, ninguno repetir N veces el byte siguiente, cero cierra—.

Así van los patrones de casilla y de sprite (0x909E-0x95FE), los nueve bloques
de sprite de los manejadores de escena (0x981E-0x99AF) y los seis de la
presentación (0xBAB2-0xBC61). Sin comprimir van los cuatro juegos de 16
casillas del decorado (0x95FE-0x97FE) y siete patrones de sprite sueltos
(0x97FE-0x981E y 0x99AF-0x9A6F).

Cada bloque comprimido acaba **exactamente** donde empieza el siguiente, y eso
fija su tamaño sin suponer nada.

## La tipografía cabe en doce casillas

No hay ni una cadena de texto. La única fuente son doce casillas: los diez
dígitos (0xB8-0xC1), los dos puntos (0xC2) y el blanco (0xC3), lo justo para el
marcador y el reloj. Todo lo demás que parece texto es dibujo.

## El reparto completo

Ni un byte sin dueño: 9467 de código trazado y 6917 de datos, cada uno dentro
de un rango declarado con la instrucción que lo lee al lado.

| | |
|---|---|
| 0x8000-0x8010 | la cabecera |
| 0x8010-0x8013 | los tres bytes que se copian al gancho de interrupción |
| 0x8013-0x8A69 | arranque, el jugador, las colisiones, el salto, el marcador y las vidas |
| 0x8A69-0x8AFF | inicializadores de RAM, la tabla de clases, la curva del salto y los guiones de andar |
| 0x8AFF-0x8E1B | carga de pantalla y de sprites, y el pintado de la escena |
| 0x8E1B-0x8F06 | los tramos de suelo y los seis patrones del hundimiento |
| 0x8F06-0x9090 | los guiones de celdas del decorado |
| 0x9090-0x909E | catorce números de casilla en crudo: la fila 23 |
| 0x909E-0x95FE | los cinco bloques grandes de gráficos comprimidos |
| 0x95FE-0x97FE | los cuatro juegos de 16 casillas del decorado |
| 0x97FE-0x9A6F | los sprites: nueve bloques comprimidos y siete patrones en crudo |
| 0x9A6F-0xA086 | el cuadro, los objetos, el cambio de pantalla, el marcador y el reloj |
| 0xA086-0xA43A | las tablas de decorado, los cuatro layouts de escena y la de 14x18 |
| 0xA43A-0xA61A | la liana |
| 0xA61A-0xA69E | las 33 fases con las que se traza la liana |
| 0xA69E-0xAE90 | los manejadores de objeto y las ocho rutinas de escena |
| 0xAE90-0xAED4 | las cuatro tablas de despacho |
| 0xAED4-0xB113 | guiones de celdas, plantillas de objeto, guiones de animación y los colores |
| 0xB113-0xB393 | la capa de vídeo, la entrada y el volcado del sonido |
| 0xB393-0xB6B1 | la tabla de sonidos y las nueve rutinas que instala |
| 0xB6B1-0xB9E4 | la presentación y la demo |
| 0xB9E4-0xBC6D | las tablas y los gráficos de la presentación |
| 0xBC6D-0xC000 | el relleno hasta los 16 KB: 915 bytes, todos a cero |
