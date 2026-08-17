# Hallazgos

Lo que apareció al desmontar el cartucho, con la evidencia al lado. Todo lo de
esta página se comprueba leyendo el binario; lo que todavía no está cerrado está
en [Preguntas abiertas](PREGUNTAS-ABIERTAS.html).

## El mundo no está guardado: se calcula

Las 255 pantallas de este juego no ocupan ni un byte de mapa. No hay lista, ni
índice, ni tabla de escenas: la pantalla en la que estás **es** el contenido de
un byte de RAM, 0xE222, y cambiar de pantalla es hacerlo girar un paso.

El giro está en 0xB68F, y son dieciséis bytes de `rla` y `xor (hl)`. Leídos y
comprobados sobre los 256 valores posibles, lo que hacen es un registro de
desplazamiento realimentado:

    bit nuevo = b7 xor b5 xor b4 xor b3      (máscara 0xB8)

Con esa realimentación el anillo es **máximo**: recorre los 255 valores no nulos
y vuelve al principio. El 0x00 se queda fuera, porque de un registro así nadie
sale del cero, y por eso el juego lo usa para la pantalla del título: el estado
que no pertenece al mundo.

Y hay una segunda rutina, 0xB69F, que es **la función inversa exacta**: desplaza
al revés y deshace lo que hizo la otra. Salir de una pantalla por la izquierda te
devuelve exactamente a la de antes. Las dos juntas ocupan 33 bytes, y eso es
todo el mapa de este juego.

Sembrando con 0xC4, que es lo que hace el arranque en 0x8075, sale el orden
concreto en el que se recorre el mundo yendo siempre a la derecha. Ese orden se
reprodujo por dos caminos independientes: simulando las dos rutinas sobre los
datos, y capturando las 255 escenas en el emulador. **Coinciden las 255 de 255.**

## Los ocho bits del registro de pantalla no desperdician ninguno

Ese byte no es solo un contador de posición. Al montar la escena (0x9EE6) se
parte en tres trozos, y cada trozo elige una cosa distinta:

| bits | qué eligen | dónde se leen |
|---|---|---|
| 6-7 | cuál de los cuatro decorados se pinta | 0x9F91 |
| 3-5 | el tipo de escena, de 0 a 7 | 0x9EFB |
| 0-2 | la variante dentro de ese tipo | 0x9EEF |

Ocho bits, tres trabajos, cero desperdicio. Una pantalla entera de este juego se
describe con un byte, y por eso el mundo se puede escribir entero sin jugar.

El bit 7 hace además **un segundo trabajo**, que es el detalle que más cuesta
ver: aparte de ir dentro del índice del decorado, se vuelve a leer suelto en
0xA9AA, en las escenas de hoyos, y decide dónde va la **caja de rebote** —la de
clase 10, centrada en 0xD8 con el bit encendido y en 0x31 con él apagado— y cuál
de los dos dibujos de hoyos se pinta. La escalera no se mueve: las dos ramas
pintan el mismo guion, 0x8F06.

El reparto que sale del anillo es prácticamente uniforme, y también se puede
contar sin jugar: 31 escenas del tipo 0 y 32 de cada uno de los otros siete; 63
del decorado 0 y 64 de cada uno de los otros tres. Los desajustes de uno son el
0x00 que falta.

## El techo del juego son 114000 puntos, y se cuenta sin jugar

Los tesoros son **exactamente** las 32 escenas de tipo 5. No hace falta
recorrerlas: el tipo 5 es el único que despacha por la tabla de 0xAEA4, esa
tabla lleva cuatro rutinas repetidas de dos en dos, y las ocho variantes se
reparten a cuatro escenas cada una. Sale un tesoro de cada clase ocho veces:
8+8+8+8 = 32, y ni uno más.

Cada rutina escribe en 0xE188 lo que vale el suyo —2, 3, 4 o 5, o sea miles de
puntos— y 0x878C lo suma al recogerlo. Así que el mundo entero guarda

    8 x (2000 + 3000 + 4000 + 5000) = 112000 puntos

y con los 2000 con los que arranca el marcador (0x8A28), **114000**. Ese es el
techo del juego, y sale de leer una tabla de dieciséis bytes.

Lo que ya te has llevado se recuerda en 32 bits justos: 0xE21D-0xE220, un byte
por clase de tesoro y un bit por tesoro, con el índice dentro de la clase en
0xE223.

Y la comprobación de «este ya está cogido» se resuelve de una manera que no se
ve a la primera. 0xAAFF rota el bit hasta el acarreo; si estaba a cero vuelve
normal y quien la llamó pinta el tesoro, pero si estaba a uno hace `pop hl` y
`ret` (0xAB19): **se come su propia dirección de retorno**, salta por encima del
código que pintaría el tesoro y devuelve el control dos niveles más arriba.

## El subterráneo recorre el mundo al triple

En 0x9CD2, al cambiar de pantalla, se mira el bit 0 de 0xE2EB —que es el que
dice si estás en la superficie— y el registro se hace girar **un paso o tres**.
Por debajo, tres escenas de golpe.

Eso convierte al subterráneo en un atajo de verdad, y se puede medir: la ruta
más corta que se lleva los 32 tesoros son **190 pantallas** cruzadas, contra 238
sin bajar nunca. Un 20 % menos. Y no son 190 a la derecha: 186 lo son, y en
cuatro el cálculo retrocede para encadenar dos tesoros.

Para bajar hace falta una escalera, y las escaleras se contaron sobre las 255
capturas del recorrido. El resultado es limpio de una manera poco habitual: es
**bimodal, sin un solo caso intermedio**. O una escena tiene 3 rayas verticales
—que es decorado— o tiene 8, que es escalera. Las de 8 son 63, y son exactamente
las 63 escenas de tipos 0 y 1, que es lo que la lectura del código ya decía. Dos
métodos que no comparten nada dando el mismo número.

El anillo entero es [el mapa del mundo](../imagenes/mapa-del-mundo.png), las 255
escenas en rejilla y etiquetadas, y la ruta es [el guion de la partida
perfecta](../imagenes/guion-de-la-partida-perfecta.png), una casilla por pantalla
cruzada.

## En este cartucho no hay ni una letra

Ni una cadena, ni un alfabeto, ni un mensaje escondido de los programadores.

La fuente que carga el juego son **doce casillas**: los diez dígitos (0xB8-0xC1),
los dos puntos (0xC2) y el blanco (0xC3). Con eso se escriben el marcador y el
reloj, y no da para una sola letra.

Todo lo demás que parece texto en la pantalla es **dibujo** partido en casillas
consecutivas, una por posición. Por eso una búsqueda de cadenas en la ROM no
devuelve nada legible: lo poco que sale son coincidencias de bytes de gráficos y
de código.

La única firma de los autores es la línea del pie de la presentación, y también
es un dibujo: dos fechas, 1982 y 1984.

## La liana no está dibujada: se traza

No hay ningún gráfico de liana en el cartucho, y no lo hay porque no hace falta.
En cada paso, 0xA471 dibuja una recta de 16 puntos sobre un mapa de bits de 0x40
bytes que vive en la RAM (0xE18A) y lo sube a la memoria de vídeo como patrón de
sprite (0xA594). La inclinación sale de la tabla de 0xA61A, indexada por la fase
del balanceo (0xE1CB), que va y viene entre 1 y 0x20.

O sea que la liana es un sprite que el juego se dibuja a sí mismo cuadro a
cuadro. Guardar los fotogramas costaría bastante más que las instrucciones que
los calculan.

## Los sprites de mirar a la izquierda no están en la ROM

Solo está dibujada la mitad. Los de mirar a la izquierda se fabrican al arrancar
espejando los otros (0x8B5E), y hay dos rutinas para eso: 0xB1D1, que invierte
cada byte bit a bit —lo que da el espejo horizontal—, y 0xB20B, que además
cambia el orden de los ocho bytes.

Hace falta el espejo de verdad y no solo invertir bits, porque un sprite de
16x16 en un MSX son **dos mitades de 16 bytes**, así que para darle la vuelta hay
que cruzar además las dos mitades (0x8BC1).

Los guiones de animación lo cuadran sin dejar dudas: andar a la derecha usa los
patrones 0x20 a 0x30 y andar a la izquierda los 0x44 a 0x54. La diferencia es
0x24, que son exactamente nueve sprites de cuatro patrones, que es lo que el
bucle del espejo procesa de una vez.

## La brea y el agua son el mismo dibujo, y les separan tres bytes

Los tipos de escena 2 y 3 pintan lo mismo. Lo único que cambia es que 0xAC7C
escribe `1B 1B 1B` en la posición 0x200B de la tabla de colores —negro, brea— y
0xAC6B escribe encima `7B 7B 7B` —cian, agua—.

El parche gasta tres bytes propios, en 0xB110. La restauración no gasta ninguno:
el `7B 7B 7B` que devuelve el charco al agua es el mismo que ya está dentro de
la tabla de colores inicial, en 0xB0FB, y 0xAC6B lo copia de ahí.

Y el mismo truco está en los tesoros. Las dos barras —la de 3000 y la de 4000—
comparten color: el byte de color vale 0x4B tanto en 0xAE90 como en 0xAE92. Lo
que las distingue es el patrón, no el color.

## El juego se queda con la interrupción y no se la devuelve a la BIOS

El gancho de interrupción no termina con un `ret` normal. Termina con **once
`pop` seguidos** (0x810F-0x8122), que desapilan uno a uno los registros que la
BIOS había guardado al entrar —incluidos los alternativos, tras el `ex af,af'` y
el `exx` de 0x8118—, con un `in a,(099h)` metido en medio (0x811A) que lee el
estado del chip gráfico, que es lo que da la interrupción por atendida.

El primer `pop hl` se lleva la dirección de retorno a la BIOS, y el `ei` / `ret`
de 0x8123 devuelve el control directamente al programa interrumpido. El resto de
la rutina de interrupción de la BIOS no llega a ejecutarse nunca.

## Hay un `rst 0` que intenta machacar el código del propio juego

Al final de cada cuadro, en 0x9AE0, hay estas dos instrucciones:

```asm
fin_del_cuadro:
    ld hl,fin_del_cuadro      ; 9ae0
    ld (hl),0c7h              ; 9ae3
```

0xC7 es `rst 0`, y la dirección que se escribe es la de esa misma línea. O sea
que el cuadro termina, cada vez, intentando escribir sobre sí mismo un salto al
arranque de la máquina.

En un cartucho eso no hace nada, porque 0x9AE0 es ROM y la escritura se pierde
por el camino. Lo que hace está comprobado leyendo los bytes; **para qué está no
se puede demostrar desde el binario**. La lectura que encaja es que sea un
guardián contra correr el juego desde RAM: la escritura solo llega a alguna
parte si eso de ahí no es ROM, y entonces el juego se suicida en el primer
cuadro. Pero es una lectura, no una medida.

## El sonido no toca el chip: toca catorce bytes de RAM

En todo el cartucho hay **un solo sitio** que escribe los registros de sonido: el
bucle de `outd` de 0xB380. Lo que hay en 0xE20E-0xE21B es una copia en RAM de los
registros 0 a 13, y 0xB37B la vuelca entera una vez por cuadro, contando de 13 a
0. Al puerto 0xA1 se escribe en otros dos sitios, 0xB24F y 0xB261, pero no es
sonido: es el registro 15, con el que el lector de mandos elige qué puerto de
joystick mira.

Encima de eso van cuatro vectores en 0xE1E6-0xE1ED, y la tabla de 0xB393 dice
qué rutina se instala en cuál para cada uno de los once sonidos.

De ahí sale un detalle que no se ve jugando: **los sonidos 0 y 1 son mudos, y
por partida doble**. Su entrada en la tabla apunta a 0xB392, que es un `ret`
suelto, y además los instala en la ranura 3, que es la única de las cuatro que
la cadena de 0xB35B ni siquiera recorre.

## El rótulo de entrada no se pinta: se revela

La presentación (0xB7F1) no vuelca un dibujo. Cada cuadro desplaza **un píxel**
los diez patrones que tiene cargados en 0xE132 y los sube a la tabla de patrones;
cada ocho cuadros recarga el dibujo y avanza una columna, hasta llegar a la 0x18.

Por la izquierda entran unos, que es el fondo (el `scf` de 0xB86E), y a partir de
la columna 12 aparece un sprite que echa a andar. El resultado es el rótulo
apareciendo por franjas, y no cuesta ni un fotograma guardado.

La presentación tampoco sale por una tecla: sale cuando el guion grabado de la
demo gasta siete entradas (0xB751).

## La presentación va en un modo de pantalla y el juego en otro

En 0xB6B2, el registro 0 del chip gráfico se pone a 0x02: modo gráfico 2, el de
los tres bancos independientes, que es el que hace falta para el rótulo de
entrada. Al salir, en 0xB788, vuelve a 0x00, que es modo gráfico 1.

Ese cambio explica una cifra que si no descoloca: **la tabla de colores del juego
son 32 bytes**, no 6144. En el modo del juego el color va por grupo de ocho
casillas, así que los 32 bytes de 0xB0F0 son la paleta entera.

Hay una segunda consecuencia, más útil todavía para leer el cartucho: los
registros 2, 5 y 6 —los que dicen dónde están la tabla de nombres, los atributos
de sprite y los patrones de sprite— **no los escribe nadie en todo el binario**.
El juego se queda con lo que dejó la BIOS y escribe en 0x1800, 0x1B00 y 0x3800
sin declararlo.

## Los bloques cierran unos contra otros, y eso es lo que fija su tamaño

Saber dónde acaba una tabla suele ser lo peor de un desensamblado, porque el
tamaño no está escrito en ninguna parte y equivocarse no da ningún error.

Aquí casi todo se delimita solo, porque los datos van pegados sin un byte de
hueco. Los cinco bloques grandes de gráficos comprimidos (0x909E-0x95FE), los
nueve de sprites de los manejadores de escena (0x981E-0x99AF), los seis de la
presentación (0xBAB2-0xBC61), los cinco guiones de celdas (0x8F06-0x9090) y los
cuatro layouts de escena (0xA096-0xA33E) cierran cada uno **exactamente** donde
empieza el siguiente, y el último cierra contra la primera instrucción del
código que viene detrás.

Se prueba con N entradas y solo una N cierra. Con eso, el tamaño deja de ser una
suposición.

## Un byte que es tres cosas a la vez

El detalle de programación más apretado del cartucho está en cómo se pintan los
tramos de suelo de las filas 12 y 13. El layout de la escena lleva cinco bytes
para eso, y cada uno de esos bytes es, al mismo tiempo, **desplazamiento dentro
de la tabla, longitud de la copia y avance en la memoria de vídeo** (0x8DA7):
cada tramo copia de `tabla+N` a `tabla+2N`.

Se lee en 0x8DA0-0x8DB6, y tiene un efecto lateral que ayuda a delimitar los
datos: los N que usan los cuatro layouts son 3, 4, 5, 6, 7, 8 y 0x0A, así que el
uso llega justo hasta `tabla+0x14` y ni un byte más.

## El hoyo está más rato abierto que cerrado

El hoyo que se abre y se cierra (0xA870) tiene su anchura en 0xE133, de 1 a 8, y
la dirección en 0xE132. La caja de colisión de clase 3 se estira con él, así que
el peligro no es un dibujo: es una caja que crece y mengua.

Y el periodo del objeto alterna entre 0x96 y 0x44. O sea que el ciclo **no es
simétrico**, y va al contrario de lo que uno esperaría: son 0x96 cuadros con el
hoyo estrecho (0xA913) contra 0x44 con el hoyo abierto del todo (0xA952). Está
cerrado más del doble de tiempo del que está abierto.

## Lo que sobró dentro del cartucho

Al cerrar los 16384 bytes aparecieron unas cuantas cosas que están y no sirven
para nada. Ninguna es una sospecha: todas se comprobaron barriendo las 16384
palabras del cartucho, y no solo el código trazado, para ver si alguna vez
aparece su dirección.

- **Seis rutinas que nadie llama**: 0xB11E, 0xB199, 0xB1A1, 0xB2A4, 0xB2F4 y
  0xB9AB. La primera es especialmente reveladora: es el descompresor de 0xB142
  **gemelo, pero escribiendo a memoria en vez de al puerto de vídeo**. Y 0xB2A4
  es un explorador de teclado completo, con antirrebote y código de tecla, que
  el juego no usa porque le basta con la fila 8.
- **Seis `ret` huérfanos** (0x9CBD, 0xAA73, 0xACB4, 0xADE7, 0xAE37, 0xB6B0): un
  solo byte 0xC9 pegado detrás del final de una rutina, sin nadie que lo apunte.
  Cuatro de los seis van justo después de un `jp` que se lleva el control fuera;
  los otros dos (0x9CBD y 0xB6B0) van detrás de otro `ret`. En los dos casos son
  el cierre que el ensamblador escribió y que nunca se ejecuta.
- **Un guion de animación entero y bien formado** en 0xAF84 —nueve fotogramas,
  patrones de 0x20 a 0x40 de cuatro en cuatro, cincuenta cuadros cada uno— que no
  carga nadie.
  Cincuenta cuadros por fotograma es lento: eso no es un bicho.
- **Una segunda copia del reloj de salida** en 0x8F00, con los mismos cinco
  números de casilla que se leen «20:00» que hay en 0x8A69, pero con un 0x00
  detrás en vez del divisor. Nadie la copia.
- **Los datos de los troncos segundo y tercero** (0xAFBA), escritos y sin usar:
  0xAD2E se lleva solo los del primero y 0xA745 coloca los otros dos por código.
- **Una clase de colisión que no existe**: la tabla de 0x8AA0 tiene once
  entradas y la número 7 apunta a 0x874B, pero no hay en todo el cartucho una
  sola instrucción que escriba un 7 en el campo de la clase.
- Y **dos listas de ocho bytes** en 0xBAA2 que son la misma con los nibbles
  intercambiados (61 contra 16, 91 contra 19, B1 contra 1B). Esa sigue sin
  consumidor; está en [Preguntas abiertas](PREGUNTAS-ABIERTAS.html).
