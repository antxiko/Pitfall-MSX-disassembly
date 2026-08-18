# Hallazgos

Lo que apareció al desmontar el cartucho, con la evidencia al lado. Lo que no
está cerrado está en [Preguntas abiertas](PREGUNTAS-ABIERTAS.html).

## El mundo no está guardado: se calcula

Las 255 pantallas no ocupan ni un byte de mapa. La pantalla en la que estás
**es** el contenido de un byte de RAM, 0xE222, y cambiar de pantalla es hacerlo
girar un paso.

El giro (0xB68F) son dieciséis bytes de `rla` y `xor (hl)`: un registro de
desplazamiento realimentado, comprobado sobre los 256 valores posibles:

    bit nuevo = b7 xor b5 xor b4 xor b3      (máscara 0xB8)

El anillo es **máximo**: recorre los 255 valores no nulos y vuelve al
principio. El 0x00 queda fuera —de un registro así no se sale del cero— y el
juego lo usa para la pantalla del título.

0xB69F es **la función inversa exacta**: desplaza al revés y deshace el paso.
Salir por la izquierda devuelve a la pantalla anterior. Las dos rutinas juntas
ocupan 33 bytes, y son todo el mapa del juego.

Sembrando con 0xC4 (0x8075) sale el orden del mundo yendo a la derecha. Ese
orden se reprodujo por dos caminos independientes: simulando las dos rutinas y
capturando las 255 escenas en el emulador. **Coinciden las 255 de 255.**

## Los ocho bits del registro de pantalla

Al montar la escena (0x9EE6) el byte se parte en tres:

| bits | qué eligen | dónde se leen |
|---|---|---|
| 6-7 | cuál de los cuatro decorados se pinta | 0x9F91 |
| 3-5 | el tipo de escena, de 0 a 7 | 0x9EFB |
| 0-2 | la variante dentro de ese tipo | 0x9EEF |

El bit 7 hace además un segundo trabajo: se vuelve a leer suelto en 0xA9AA, en
las escenas de hoyos, y decide dónde va la **caja de rebote** —clase 10,
centrada en 0xD8 con el bit encendido y en 0x31 apagado— y si se pintan uno o
tres hoyos. La escalera no se mueve: las dos ramas pintan el mismo guion,
0x8F06.

El reparto del anillo se cuenta sin jugar: 31 escenas del tipo 0 y 32 de cada
uno de los otros siete; 63 del decorado 0 y 64 de cada uno de los otros tres.
Los desajustes de uno son el 0x00 que falta.

## El techo del juego son 114000 puntos

Los tesoros son **exactamente** las 32 escenas de tipo 5: el tipo 5 es el único
que despacha por la tabla de 0xAEA4, esa tabla lleva cuatro rutinas repetidas
de dos en dos, y las ocho variantes se reparten a cuatro escenas cada una. Un
tesoro de cada clase ocho veces: 8+8+8+8 = 32.

Cada rutina escribe en 0xE188 lo que vale el suyo —2, 3, 4 o 5, en miles— y
0x878C lo suma al recogerlo:

    8 x (2000 + 3000 + 4000 + 5000) = 112000 puntos

Con los 2000 con los que arranca el marcador (0x8A28), **114000**.

Lo recogido se recuerda en 32 bits justos: 0xE21D-0xE220, un byte por clase y
un bit por tesoro, con el índice dentro de la clase en 0xE223.

La comprobación de «ya está cogido» no usa saltos: 0xAAFF rota el bit hasta el
acarreo y, si estaba a uno, hace `pop hl` y `ret` (0xAB19): **se come su propia
dirección de retorno**, y el código que pintaría el tesoro no llega a
ejecutarse.

## El subterráneo recorre el mundo al triple

Al cambiar de pantalla, 0x9CD2 mira el bit 0 de 0xE2EB —superficie o
subterráneo— y gira el registro **un paso o tres**. Por abajo, tres escenas de
golpe.

Eso se puede medir: la ruta más corta que se lleva los 32 tesoros son **189
pantallas** cruzadas, contra 238 sin bajar nunca —un 21 % menos—. Y no va toda
hacia el mismo lado: derecha hasta el primer tesoro, media vuelta, y los otros
31 por la izquierda —13 cruces a la derecha y 176 a la izquierda—. Ir siempre a
la derecha costaría 190.

Las escaleras para bajar se contaron sobre las 255 capturas del recorrido, y el
resultado es bimodal sin un caso intermedio: o una escena tiene 3 rayas
verticales —decorado— o tiene 8 —escalera—. Las de 8 son 63: exactamente las
escenas de tipos 0 y 1, lo mismo que dice el código. Dos métodos independientes
con el mismo número.

El anillo entero es [el mapa del mundo](../imagenes/mapa-del-mundo.png), y la
ruta, [el guion de la partida
perfecta](../imagenes/guion-de-la-partida-perfecta.png), una casilla por
pantalla cruzada.

## En este cartucho no hay ni una letra

Ni una cadena, ni un alfabeto, ni un mensaje escondido. La única fuente son
**doce casillas**: los diez dígitos (0xB8-0xC1), los dos puntos (0xC2) y el
blanco (0xC3), lo justo para el marcador y el reloj.

Todo lo demás que parece texto es **dibujo** partido en casillas consecutivas.
Por eso buscar cadenas en la ROM no devuelve nada legible. La única firma es la
línea del pie de la presentación, también dibujo: dos fechas, 1982 y 1984.

## La liana se pinta con cuentas, no está guardada como dibujo

La liana que se ve en pantalla se pinta en cada cuadro, y la pinta el código:
lo que no lleva el cartucho es un gráfico de ella. En cada paso, 0xA471 traza
una recta de 16 puntos sobre un mapa de bits en RAM (0xE18A) y lo sube a la
memoria de vídeo como patrón de sprite (0xA594). La inclinación sale de la
tabla de 0xA61A, indexada por la fase del balanceo (0xE1CB), que va y viene
entre 1 y 0x20. Así que la cuerda es un sprite que el juego se fabrica solo,
de dieciséis puntos en dieciséis puntos.

## Los sprites de mirar a la izquierda no están en la ROM

Solo está dibujada la mitad: los de mirar a la izquierda se fabrican al
arrancar espejando los otros (0x8B5E). Hay dos rutinas: 0xB1D1 invierte cada
byte bit a bit —espejo horizontal— y 0xB20B además cambia el orden de los ocho
bytes. Y hace falta cruzar las dos mitades del sprite (0x8BC1), porque un
sprite de 16x16 son dos mitades de 16 bytes.

Los guiones de animación lo cuadran: andar a la derecha usa los patrones
0x20-0x30 y andar a la izquierda los 0x44-0x54. La diferencia, 0x24, son
exactamente los nueve sprites de cuatro patrones que el bucle del espejo
procesa de una vez.

## La brea y el agua son el mismo dibujo

Los tipos de escena 2 y 3 pintan lo mismo; solo cambia que 0xAC7C escribe
`1B 1B 1B` en la posición 0x200B de la tabla de colores —negro, brea— y 0xAC6B
escribe `7B 7B 7B` —cian, agua—.

El parche gasta tres bytes propios (0xB110). La restauración, ninguno: el
`7B 7B 7B` del agua es el mismo que ya está dentro de la tabla de colores
inicial, en 0xB0FB, y 0xAC6B lo copia de ahí.

El mismo truco en los tesoros: las dos barras —3000 y 4000— comparten color
(0x4B en 0xAE90 y 0xAE92); las distingue el patrón.

## El juego se queda con la interrupción

El gancho no termina con un `ret` normal, sino con **once `pop` seguidos**
(0x810F-0x8122) que desapilan lo que la BIOS guardó —incluidos los registros
alternativos— con un `in a,(099h)` en medio (0x811A) que da la interrupción por
atendida.

El primer `pop hl` se lleva la dirección de retorno a la BIOS, y el `ei` /
`ret` de 0x8123 vuelve directamente al programa interrumpido: el resto de la
rutina de interrupción de la BIOS no se ejecuta nunca.

## Un `rst 0` que intenta machacar el propio código

Al final de cada cuadro, en 0x9AE0:

```asm
fin_del_cuadro:
    ld hl,fin_del_cuadro      ; 9ae0
    ld (hl),0c7h              ; 9ae3
```

0xC7 es `rst 0`, y la dirección es la de esa misma línea: el cuadro termina
intentando escribirse encima un salto al arranque de la máquina. En un cartucho
no hace nada, porque 0x9AE0 es ROM. **Para qué está no se puede demostrar desde
el binario**; la lectura que encaja es un guardián contra correr el juego desde
RAM —ahí la escritura sí llega, y el juego se suicida en el primer cuadro—,
pero es una lectura, no una medida.

## El sonido no toca el chip: toca catorce bytes de RAM

Un solo sitio escribe los registros de sonido: el bucle de `outd` de 0xB380,
que vuelca la copia de 0xE20E-0xE21B una vez por cuadro. Al puerto 0xA1 se
escribe en otros dos sitios (0xB24F, 0xB261), pero es el registro 15: el lector
de mandos eligiendo puerto de joystick.

Encima van cuatro vectores en 0xE1E6-0xE1ED, y la tabla de 0xB393 dice qué
rutina se instala en cuál para cada uno de los once sonidos.

Un detalle que no se ve jugando: **los sonidos 0 y 1 son mudos por partida
doble**. Su entrada apunta a 0xB392 —un `ret` suelto— y además van a la ranura
3, la única que la cadena de 0xB35B no recorre.

## El rótulo de entrada no se pinta: se revela

La presentación (0xB7F1) no vuelca un dibujo: cada cuadro desplaza **un píxel**
los diez patrones cargados en 0xE132 y los sube a la tabla de patrones; cada
ocho cuadros recarga el dibujo y avanza una columna, hasta la 0x18. Por la
izquierda entran unos —el fondo, el `scf` de 0xB86E— y desde la columna 12
aparece un sprite que echa a andar. No hay ni un fotograma guardado.

De la presentación no se sale con una tecla: se sale cuando el guion grabado de
la demo gasta siete entradas (0xB751).

## La presentación va en un modo de pantalla y el juego en otro

0xB6B2 pone el registro 0 del chip gráfico a 0x02 —modo gráfico 2, tres bancos
independientes— para el rótulo de entrada; 0xB788 lo devuelve a 0x00, modo
gráfico 1.

Consecuencias: **la tabla de colores del juego son 32 bytes**, no 6144 —en el
modo del juego el color va por grupo de ocho casillas—, y los registros 2, 5 y
6 —tabla de nombres, atributos y patrones de sprite— **no los escribe nadie en
todo el binario**: el juego usa las bases que dejó la BIOS.

## Los bloques cierran unos contra otros

Saber dónde acaba una tabla suele ser lo peor de un desensamblado: el tamaño no
está escrito y equivocarse no da error.

Aquí casi todo se delimita solo, porque los datos van pegados sin hueco: los
cinco bloques grandes de gráficos comprimidos (0x909E-0x95FE), los nueve de
sprites de escena (0x981E-0x99AF), los seis de la presentación (0xBAB2-0xBC61),
los cinco guiones de celdas (0x8F06-0x9090) y los cuatro layouts (0xA096-
0xA33E) cierran cada uno **exactamente** donde empieza el siguiente. Se prueba
con N entradas y solo una N cierra.

## Un byte que es tres cosas a la vez

Los tramos de suelo de las filas 12 y 13: el layout lleva cinco bytes, y cada
byte es a la vez **desplazamiento dentro de la tabla, longitud de la copia y
avance en la memoria de vídeo** (0x8DA7). Cada tramo copia de `tabla+N` a
`tabla+2N`.

Efecto lateral que delimita los datos: los N de los cuatro layouts son 3, 4, 5,
6, 7, 8 y 0x0A, así que el uso llega justo a `tabla+0x14`.

## El hoyo pasa más tiempo cerrado que abierto

El hoyo (0xA870) lleva su anchura en 0xE133, de 1 a 8, y la dirección en
0xE132; la caja de clase 3 se estira con él. El ciclo no es simétrico: 0x96
cuadros con el hoyo estrecho (0xA913) contra 0x44 abierto del todo (0xA952) —
cerrado más del doble de tiempo—.

## Lo que sobró dentro del cartucho

Cosas que están y no se usan. Ninguna es una sospecha: todas se comprobaron
barriendo las 16384 palabras del cartucho en busca de su dirección.

- **Seis rutinas que nadie llama**: 0xB11E, 0xB199, 0xB1A1, 0xB2A4, 0xB2F4 y
  0xB9AB. 0xB11E es el descompresor de 0xB142 gemelo, escribiendo a memoria en
  vez de al puerto de vídeo; 0xB2A4 es un explorador de teclado completo, con
  antirrebote y código de tecla, que el juego no necesita: le basta la fila 8.
- **Seis `ret` huérfanos** (0x9CBD, 0xAA73, 0xACB4, 0xADE7, 0xAE37, 0xB6B0): un
  byte 0xC9 pegado tras el final de una rutina, sin nadie que lo apunte. Cuatro
  van tras un `jp` que se lleva el control; dos, tras otro `ret`.
- **Un guion de animación bien formado** en 0xAF84 —nueve fotogramas, cincuenta
  cuadros cada uno— que no carga nadie.
- **Una segunda copia del reloj de salida** en 0x8F00, los mismos cinco números
  de casilla «20:00» de 0x8A69 con un 0x00 detrás en vez del divisor. Nadie la
  copia.
- **Los datos de los troncos segundo y tercero** (0xAFBA), sin usar: 0xAD2E se
  lleva solo los del primero y 0xA745 coloca los otros dos por código.
- **Una clase de colisión que no existe**: la entrada 7 de la tabla de 0x8AA0
  apunta a 0x874B, y ninguna instrucción escribe un 7 en el campo de clase.
- **Dos listas de ocho bytes** en 0xBAA2, la misma con los nibbles
  intercambiados. Sigue sin consumidor: está en
  [Preguntas abiertas](PREGUNTAS-ABIERTAS.html).
