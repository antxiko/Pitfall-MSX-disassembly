# El código

## Todo pasa dentro de la interrupción

El programa principal son dos bytes: un salto a sí mismo, en 0x80F5. El juego
corre en el gancho H.KEYI, que la BIOS llama en cada retrazado y que hace
siempre lo mismo (0x80F7-0x8100):

    B249   los dos joysticks, por el chip de sonido
    B26E   la fila 8 del teclado, recolocada en formato de joystick
    B35B   la cadena de vectores de sonido
    9A6F   el cuadro: la pantalla y los objetos

y detrás, en 0x8103, los 0x54 bytes de 0xE26A a la memoria de vídeo 0x1B00: la
tabla de atributos de sprite entera, una vez por cuadro.

## Y de ahí no se vuelve a la BIOS

El final del gancho no es un `ret` normal: son once `pop` seguidos
(0x810F-0x8122) que desapilan lo que la BIOS guardó al entrar en la
interrupción —incluidos los registros alternativos, tras el `ex af,af'` y el
`exx` de 0x8118—, con un `in a,(099h)` en medio (0x811A) que lee el estado del
chip gráfico y da la interrupción por atendida.

El primer `pop hl` se come la dirección de retorno a la BIOS, y el `ei` /
`ret` de 0x8123 devuelve el control directamente al programa interrumpido. El
resto de la rutina de interrupción de la BIOS no llega a correr.

## El cuadro

0x9A6F, en orden:

1. el reloj de la partida (0x9DB8);
2. el borde de la pantalla (0x9CBE): si el jugador llegó, se cambia de escena y
   el cuadro acaba ahí;
3. si 0xE221 no es cero corre la demo, y la entrada se sustituye por la grabada
   en 0xE259 (0x9A7E);
4. el recorrido de los objetos vivos (0x9A88);
5. los dos sprites de encima del jugador (0x9D03);
6. el cierre (0x9AE0): teclas de sistema y reloj de inactividad.

## El muñeco son tres sprites, uno por color

Un sprite del MSX1 es de un color, así que un jugador de tres colores son tres
sprites. 0x9D03 monta los otros dos a partir del principal: la misma X, **16
píxeles más arriba**, con los patrones (P-0x20)+0x68 y (P-0x20)+0xB0. Los
colores los escribe la rutina que monta la escena: 0x0C en 0xE2A5, 0x06 en
0xE2A9 y 0x0F en 0xE2AD. `reaparece` los pone a cero para esconder al muñeco
(0x8247) y los enciende a destiempo al volver (0x82D4-0x82E1): ese es el
parpadeo.

Harry mide 16x32 y no son tres capas exactas: los dos sprites de arriba se
solapan entre ellos —dos colores en la mitad de arriba— y el principal va
debajo, un color para las piernas. Recompuesto desde la memoria de vídeo
volcada (`tools/render_jugador.py`), esta es la tira de los doce fotogramas que
nombran los guiones del cartucho:

![Los doce fotogramas del protagonista](../imagenes/jugador-tira.png)

Los tiempos son los del cartucho: andar son cinco fotogramas de tres cuadros
(0x8AE1) y trepar dos de un cuadro (0x8AF9). Andar a la izquierda usa los
patrones 0x44-0x54 (0x8AED), espejo exacto de los 0x20-0x30, comprobado píxel a
píxel. Los dos patrones de estar parado, 0x34 y 0x58, no vienen de un guion:
los clava a mano `se_para` (0x8970 y 0x896B), y por eso no están en la tira.

En el TMS9918 **el sprite de número más bajo va delante**, así que el de 0xE2A6
tapa al de 0xE2AA. Importa en los dos fotogramas de trepar, los únicos donde
las dos capas de arriba se solapan: cinco píxeles cada uno, que con el orden al
revés saldrían blancos en vez de rojos.

La velocidad: `anda` (0x88ED) escribe 0x00C8 —200/256, 0,78 píxeles por
cuadro— y 0xFF38 para el otro lado, el mismo número en negativo.

El volcado del emulador coincide: tres entradas de sprite en 0xE2A2 con la
misma X, Y 109 la principal y 93 las otras dos, patrones 0x34, 0x7C y 0xC4 —
exactamente 0x34, (0x34-0x20)+0x68 y (0x34-0x20)+0xB0—.

## Los objetos: seis bytes por eje, y un contador por cabeza

0xE247 dice cuántos objetos hay vivos, y detrás va un puntero por objeto. De
cada uno se decrementa su contador (+0x11) y **solo al llegar a cero** se
recarga con su periodo (+0x10) y se le atiende (0x9A99): cada objeto corre a su
ritmo con un único bucle.

La estructura, leída en el recorrido de 0x9A88:

| | |
|---|---|
| +0x00 a +0x05 | banderas, velocidad de 16 bits, topes y fracción — de un eje |
| +0x06 a +0x0B | lo mismo del otro eje |
| +0x0C / +0x0D | el guion de animación |
| +0x0E / +0x0F | el contador de animación y el fotograma |
| +0x10 / +0x11 | el periodo y su cuenta |
| +0x12 / +0x13 | su manejador |
| +0x14 / +0x15 | dónde están sus atributos de sprite |

Que los dos bloques de movimiento son idénticos se ve en el código: 0x9AB3
llama a la rutina de mover, 0x9AB9 suma **seis** a IX, y 0x9ABD vuelve a llamar
a la misma rutina.

La posición no está en la estructura: la parte entera vive en el atributo del
sprite (0x9B24) y en la estructura solo queda la fracción, en +0x05. Mover un
objeto es sumar su velocidad a un número de 16 bits cuyo byte alto es lo que ve
el chip gráfico.

Las banderas de cada eje (0x9B1F):

| | |
|---|---|
| bit 0 | se mueve |
| bit 1 | al llegar al tope rebota en vez de pararse (0x9B5A) |
| bit 2 | tiene topes, en +0x03 y +0x04 |
| bit 5 | está animado (0x9AEC) |
| bit 6 | tiene manejador propio (0x9AC2) |

## Cuatro despachadores, todos con el mismo truco

Los saltos a direcciones calculadas apilan el retorno a mano: `ld de,<vuelta>`
/ `push de` / `jp (hl)` (0x9AD2, y 0x9F89 igual). Las direcciones de vuelta
están declaradas como puntos de entrada del trazador.

| Qué elige | Dónde | Índice | Tabla |
|---|---|---|---|
| el manejador de un objeto | 0x9AD6 | el propio objeto, +0x12/+0x13 | ninguna |
| el tipo de escena | 0x9F81 | 0xE225, de 0 a 7 | 0xAEB4 |
| la variante de la escena | 0xA99F | 0xE224, de 0 a 7 | 0xAE94, 0xAEA4 o 0xAEC4, según el llamante |
| qué pasa al chocar | 0x873B | la clase de la caja, de 0 a 10 | 0x8AA0 |

El de variantes recibe la tabla en HL: la misma rutina sirve para tres tablas,
y cuál se usa lo decide el llamante. La de 0xAEA4 solo la carga 0xAE2E, y solo
con el tipo de escena 5.

## Las cajas de colisión

0xE229-0xE246 son diez registros de tres bytes: clase, X izquierda y X derecha.
Las escriben las rutinas de escena al montar la pantalla y las recorren 0x84EF,
0x8529 y 0x8589 con la X del jugador más ocho —su centro—.

Las siete primeras son de la superficie y las de 0xE241 en adelante del
subterráneo (0x853A). La clase va directa al despachador de 0x873B:

| | | |
|---|---|---|
| 0 | apagada | no salta a ningún sitio |
| 1 | tronco | 0x8640: tumba y resta puntos |
| 2 | suelo | 0x8751: por ahí se cae al subterráneo |
| 3 | charca | 0x8361: hunde |
| 4 | cocodrilo | 0x8361: el mismo sitio |
| 5 | liana | 0x8162: engancha |
| 6 | mata | 0x8221 |
| 7 | — | apunta a 0x874B, y no la escribe nadie |
| 8 | tesoro | 0x878C: suma |
| 9 | mata | 0x8221 |
| 10 | rebote | 0x85EF: invierte la marcha y retrocede. **No es la escalera** |

Las clases 2, 3 y 4 además empujan al jugador **de lado** para sacarlo de la
caja (0x8555-0x8578): lo que se ajusta es su X; la Y no se toca ahí.

## El mundo no está guardado: se calcula

La escena en la que estás **es** el contenido de 0xE222, un registro de
desplazamiento realimentado de 8 bits. 0xB68F lo avanza y 0xB69F lo retrocede
con la función inversa exacta: salir por la izquierda deshace lo que la derecha
hizo. Los ocho bits se reparten enteros: 6-7 el decorado (0x9F91), 3-5 el tipo
(0x9EFB), 0-2 la variante (0x9EEF).

El detalle, con el porqué de las 255 pantallas, está en
[Hallazgos](HALLAZGOS.html).

## Dibujar una escena

0x9EE6 es la única vía por la que se monta una pantalla: cambiar 0xE222 a pelo
no repinta nada. Lee del registro el decorado, el tipo y la variante, y monta:

- **el layout**, un bloque de la tabla de 0xA08E que consume 0x8D70: 0x71 bytes
  en crudo para las filas 4 a 7, una fila de 0x20 bytes pintada seis veces,
  cinco bytes para los tramos de las filas 12 y 13, y un guion de celdas. Los
  cuatro layouts cierran cada uno donde empieza el siguiente;
- **el juego de 16 casillas** del decorado, de la tabla de 0xA086;
- **los guiones de celdas** (0x9FE6): el primer byte dice cuántas celdas, el
  segundo se salta —0x9FE7 y 0x9FE8 son dos `inc hl`—, y detrás registros de
  cuatro bytes con la posición en la tabla de nombres y la casilla. Así se
  pintan la escalera, las franjas del suelo y los objetos de 3x2 de la derecha.

Los tramos de suelo ahorran dos bytes por tramo: el byte del layout es **a la
vez** desplazamiento dentro de la tabla, longitud y avance de memoria de vídeo
(0x8DA7). Cada tramo copia de `tabla+N` a `tabla+2N`.

## La entrada: dos mandos y un teclado en el mismo byte

0xB249 lee los dos puertos de joystick por el chip de sonido y los deja en
0xE05F y 0xE061 —con un `cpl` en 0xB257, porque el chip los entrega
invertidos—. 0xB26E coge la fila 8 del teclado —barra y cursores— y la recoloca
bit a bit: tres rotaciones y un `and 0x1F` (0xB28F) dejan bit 0 arriba, 1
abajo, 2 izquierda, 3 derecha, 4 disparo.

Las dos fuentes acaban en el mismo sitio con la misma forma, así que el resto
del juego no sabe cuál se usa. La demo lo aprovecha: escribe en 0xE05F la
entrada grabada (0x9A7E).

## El sonido no toca el chip: toca catorce bytes de RAM

0xE20E-0xE21B es una copia de los registros 0 a 13 del chip de sonido, y 0xB37B
la vuelca entera con un bucle de `outd`, una vez por cuadro. Fuera de ahí solo
se escribe el puerto 0xA1 en 0xB24F y 0xB261, y no para sonar: es el registro
15, con el que el lector de mandos elige puerto.

Encima van cuatro vectores en 0xE1E6-0xE1ED. Pedir un sonido es llamar a 0xB32E
con un número de 0 a 10; la tabla de 0xB393 —registros [ranura][puntero]— dice
en qué ranura se instala y con qué rutina, y la ranura fija el canal. Cada
cuadro, 0xB35B llama a lo instalado en las tres primeras.

Hay dos motores y tres efectos a mano. El de 0xB3F0 lee guiones de ocho bytes y
barre tono y volumen a la vez, con parte fraccionaria en 0xE1FC de la que solo
sale el byte alto (0xB471); el de 0xB5EA lee guiones de cuatro bytes y deja
cada nota quieta. Los tres sin guion —0xB49F, 0xB4E6, 0xB52E— llevan el barrido
en el código: 19 cuadros subiendo el periodo de 0x14 en 0x14, tres cuadros
bajándolo de 0x7F en 0x7F —o 0x80: el `sbc` de 0xB528 se lleva el acarreo y
nadie lo limpia—, y un cuadro de ruido.

## La liana se traza, no se dibuja

No hay ningún dibujo de liana en el cartucho. En cada paso, 0xA471 traza una
recta de 16 puntos sobre un mapa de bits de 0x40 bytes en RAM (0xE18A) y lo
sube a la memoria de vídeo como patrón de sprite (0xA594). La inclinación sale
de la tabla de 0xA61A —33 registros de cuatro bytes— indexada por la fase del
balanceo, 0xE1CB, que va y viene entre 1 y 0x20 (0xA5EF).

Los cuatro bytes de cada fase:

| byte | qué es | de la vertical al extremo |
|---|---|---|
| 1 | la pendiente, en 1/256 de píxel por fila | 0x00 → 0xC9 |
| 2 | el **periodo** del objeto (0xA48F) | 1 → 9 cuadros |
| 3 | dónde acaba la cuerda y se agarra uno (0xA529) | 0x10 → 0x06 |
| 4 | en qué paso de la curva del salto arranca la caída al soltarse (0xA546) | 0x00 → 0x10 |

Como el periodo crece hacia las puntas, **el balanceo corre por el centro y
frena en los extremos**, como un péndulo: no hay física, hay una columna de una
tabla. Media ida son los 32 periodos sumados, 75 cuadros.

La cuerda no mide las 48 filas de sus tres sprites: el tercero lleva el patrón
0x60, que 0xA551 fabrica copiando del primero tantas filas como diga el tercer
byte, así que la cuerda **acaba en el punto de agarre** y se acorta al
tumbarse: 48 filas en vertical, 38 en el extremo.

Reproduciendo el trazador con los mismos datos (`tools/render_liana.py`) salen
las 33 fases:

![Las 33 fases de la liana superpuestas](../imagenes/liana.png)

El borde de abajo es el punto de agarre de cada fase, y por eso las de fuera
acaban más arriba. Contra una captura del emulador, la cuerda cae a **0,28
píxeles de media** de donde el modelo la pone (fase 0x1C); hasta los escalones
se repiten, porque la máquina reinicia el acumulador en cada sprite y pierde la
fracción cada 16 filas.

Colgado, la liana te escribe la X y la Y (0xA5F9), con dibujo propio: patrón
0x40, o 0x64 mirando a la izquierda (0x819A). Soltarse es pulsar abajo
(0x81A7).

## El salto es una tabla, no una velocidad

El salto empieza en 0x87E9 y el paso se guarda en +0x17 de la estructura del
jugador. En el aire (0x8820) ese número cuenta de 0x1F a 0 y se usa como índice
en la curva de 0x8AB6, leída del final al principio: 0xFF sube un píxel, 0x01
baja uno, 0x00 mantiene (0x8835). No hay velocidad vertical: hay una tabla.

De 0x1F a 0x11 la curva sube diez píxeles y de 0x10 a 1 los baja cada vez más
seguidos: 31 cuadros, 15 subiendo y 16 cayendo. **Soltarse de la liana usa la
misma curva pero no empieza en 0x1F**: empieza en el cuarto byte de la fase del
balanceo (0x821A), que nunca pasa de 0x10 —la mitad que baja—, así que
soltándose solo se cae. En la vertical vale 0 y se aterriza en el acto
(0x882E); en la punta vale 0x10, el descenso entero.

Girarse en el aire solo se puede en los tres primeros pasos (0x8896), y al
hacerlo se recupera el avance perdido al cambiar de sentido (0x88C3).
