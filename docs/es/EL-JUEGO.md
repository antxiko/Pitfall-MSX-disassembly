# El juego

Un explorador cruza la jungla recogiendo tesoros, con un reloj que se acaba.
Todo lo de esta página sale de leer el código que lo hace.

## El mundo son 255 pantallas, y no ocupan un byte de mapa

La escena en la que estás es el contenido de un byte de RAM, 0xE222. Cuando la
X del jugador llega al borde derecho —0xE7— se le pone en 0x19, el otro lado, y
ese byte se hace girar un paso (0x9CBE). Por la izquierda, en 0x16, lo mismo al
revés con la función inversa (0x9CF9).

El giro recorre 255 valores antes de repetirse, así que el mundo es un anillo
de 255 pantallas con el orden fijado: la partida siempre empieza en la misma
escena y la siguiente siempre es la misma. No hay nada aleatorio ni ninguna
lista de pantallas en el cartucho.

Al montar la escena (0x9EE6), del byte se leen tres cosas:

| bits | qué eligen |
|---|---|
| 6-7 | el decorado: cuál de los cuatro paisajes se pinta (0x9F91) |
| 3-5 | el tipo de escena, de 0 a 7 (0x9EFB) |
| 0-2 | la variante dentro de ese tipo (0x9EEF) |

## Las ocho clases de pantalla

Los bits 3-5 eligen una de ocho rutinas por la tabla de 0xAEB4:

| Tipo | Rutina | Qué es | Cuántas hay |
|---|---|---|---|
| 0 | 0xA9AA | hoyos en el suelo, con escalera al subterráneo | 31 |
| 1 | 0xA9AA | los mismos: las dos entradas apuntan al mismo sitio | 32 |
| 2 | 0xAC7C | charca de brea | 32 |
| 3 | 0xAC6B | charca de agua | 32 |
| 4 | 0xAD75 | laguna con tres cocodrilos | 32 |
| 5 | 0xADF6 | **la escena del tesoro**, la única que puntúa | 32 |
| 6 | 0xAE04 | brea con liana | 32 |
| 7 | 0xADE8 | agua con liana | 32 |

El reparto es casi uniforme porque el anillo recorre los 255 valores no nulos:
solo el tipo 0 se queda con una escena menos.

Los tipos 0 y 1 comparten rutina; lo que parte esas 63 escenas en dos es el bit
7 del registro, que 0xA9AA lee suelto para decidir dónde va la **caja de
rebote** —clase 10, centrada en 0xD8 con el bit encendido y en 0x31 apagado— y
si se pintan uno o tres hoyos. La escalera no se mueve de sitio: las dos ramas
pintan el mismo guion de celdas, 0x8F06 (0x8D4A y 0x8D5D).

Los tipos 2 y 3 son **el mismo dibujo con distinto color**: 0xAC7C escribe
`1B 1B 1B` en la tabla de colores —charco negro, brea— y 0xAC6B escribe
`7B 7B 7B` —cian, agua—.

Los tres cocodrilos van en las X 0x50, 0x6F y 0x88 (0xA828) y abren la boca
cada cuadro (guion de 0xAFD8); con la boca abierta su caja de colisión crece
(0xA812).

## Los 32 tesoros, contados sin jugar

Los tesoros son exactamente las 32 escenas de tipo 5: el tipo 5 es el único que
despacha por la tabla de 0xAEA4, que lleva cuatro rutinas repetidas de dos en
dos, y las ocho variantes se reparten a cuatro escenas cada una. Un tesoro de
cada clase ocho veces:

| Rutina | Vale | Cuántos |
|---|---|---|
| 0xAC11 | 2000 | 8 |
| 0xAB51 | 3000 | 8 |
| 0xAB1B | 4000 | 8 |
| 0xABB7 | 5000 | 8 |

Son cuatro dibujos: el saco de dinero, dos barras y el anillo. Las dos barras
comparten color (0x4B en 0xAE90 y 0xAE92): las distingue el patrón.

8 × (2000+3000+4000+5000) = **112000 puntos** repartidos por el mundo. El
marcador arranca en 2000 (0x8A28), así que el techo del juego son **114000**.

Lo recogido se recuerda en 32 bits: 0xE21D-0xE220, un byte por clase y un bit
por tesoro, con el índice dentro de la clase en 0xE223. Al entrar en una escena
de tesoro, 0xAAFF mira ese bit y, si está encendido, el tesoro no vuelve a
aparecer.

## El subterráneo

Por los hoyos se baja al subterráneo, y también por la escalera de las escenas
de tipos 0 y 1. La escalera no tiene caja de colisión: se comprueba a mano que
la escena sea de esas y que la X del jugador caiga entre 0x70 y 0x88 (0x83D4).
Esa ventana es más ancha que el dibujo: el mástil que pinta 0x8F06 va de 0x80 a
0x87, así que se baja también desde un poco antes de pisarlo.

Abajo el mundo corre al triple: el bit 0 de 0xE2EB dice si estás en la
superficie —0xACE4 lo enciende al empezar, 0x8751 lo apaga al caer por un hoyo,
0x849A lo enciende al salir— y con él apagado cruzar una pantalla gira el
registro **tres pasos en vez de uno** (0x9CD2).

Con esas dos reglas se calcula la ruta más corta que se lleva los 32 tesoros:
**189 pantallas** cruzadas, contra 238 sin bajar nunca —un 21 % menos—. No va
toda hacia el mismo lado: derecha hasta el primer tesoro, media vuelta, y los
otros 31 por la izquierda. Es un cálculo en pantallas cruzadas, no una partida:
la escalera se cuenta gratis y el reloj no entra.

## Lo que cuesta puntos, y lo que cuesta una vida

De las diez clases de caja de colisión solo cuatro cuestan una vida: la 3 y la
4 por 0x83B9, la 6 y la 9 por 0x8226 —los dos únicos llamantes de quitar una
vida—. El resto:

- **el tronco** (clase 1, 0x8640) te tumba y resta **un punto por cuadro**
  mientras te pisa (0x8674); se sale andando;
- **un tronco mientras trepas** resta dos puntos y te manda escalera abajo
  (0x8506);
- **caer por un hoyo** resta cien puntos y acabas en el subterráneo (0x8781);
- **la charca y el cocodrilo** te hunden (0x8361): el dibujo del jugador se va
  comiendo por abajo hasta la Y 0x7A, y ahí se pierde la vida;
- **las clases 6 y 9** matan directamente (0x8221).

Los bichos que montan las escenas, identificados en las capturas:

| rutina | qué es | caja |
|---|---|---|
| 0xAA74 | la serpiente | clase 6, mata |
| 0xAAB7 | la fogata | clase 6, mata |
| 0xAD1F | el tronco parado (los que ruedan salen de su plantilla) | clase 1 |
| 0xA69E | el escorpión del subterráneo: se acerca a tu X | clase 9, mata |

Se empieza con dos vidas de repuesto (0x8A52), visibles de dos maneras: tres
casillas en las filas 2 y 3, y el color de los sprites 12 y 13, que se pone a
cero —transparente— al gastarse esa vida (0x89A8).

Al perder una, la escena no se repinta: se esconde todo lo demás guardando
cuántos objetos había en 0xE189, el jugador se redibuja por trozos, cae al
suelo y se devuelven los objetos (0x8221-0x82E7). Se reaparece pegado al borde
izquierdo, X 0x20 (0x826A).

## El reloj y el marcador

El reloj arranca en **20:00** y cuenta hacia atrás. No es un número: los cinco
bytes de 0xE1D0 son ya números de casilla —`BA B8 C2 B8 B8`, los dibujos de
«2», «0», «:», «0», «0»— y la cuenta atrás se hace sobre ellos (0x9DB8). Cuando
el préstamo llega a la decena de minutos, se acabó el tiempo (0x9DEA): el reloj
se queda en 00:00 y arranca la secuencia final.

Un tick gasta 60 cuadros (0xE1D5), y el gancho de interrupción llama al reloj
una vez por interrupción, sin condición por el camino: **un tick son 60
interrupciones**. Medido en partida real (`tools/omsx_mide_tick.tcl`): 55 ticks
seguidos, los 55 a 60 interrupciones exactas. A 60 Hz los 20:00 duran veinte
minutos de pared; a 50 Hz, veinticuatro: el cartucho cuenta interrupciones, no
segundos. La rutina corre también en el título y en la demo, sobre casillas sin
inicializar; los 20:00 se escriben al arrancar la partida. En pausa no corre.

El marcador son seis dígitos en binario en 0xE1D6-0xE1DB, pasados a casillas al
pintarlos en la fila 1, columna 6 (0x9D72). Los ceros de delante van en blanco
hasta el primer dígito no nulo (0x9D5C). Un tesoro suma en el dígito de los
miles (0x9D9F); restar puntos es 0x9D7C, con el dígito a tocar como parámetro.

## Los mandos

Cuatro direcciones y un disparo, del joystick o del teclado: la barra y los
cursores se recolocan en los mismos bits (0xB26E). Direcciones en los bits 0-3
de 0xE05F, disparos en el 4 y el 5 (0x87E0).

Con el botón mantenido no se vuelve a saltar (0x87E9), y de la liana solo se
suelta uno pulsando abajo (0x81A7).

Tres teclas más, miradas en la fila 7 del teclado (0x9BF3):

| | |
|---|---|
| ESC | pausa, con una máquina de pulsar-soltar en 0xE267 |
| RETURN | vuelve al título, solo si 0xE269 lo permite |
| STOP | arranca de cero, saltando a INIT |

La pausa: 0x9C94 guarda cuántos objetos había y pone cero. Con la lista vacía
no se mueve nada, sin un solo `if` repartido por el código. Con un único objeto
vivo no se puede pausar: eso es la secuencia final.

## Si nadie toca nada, la pantalla se apaga

0x9B6D lleva tres contadores en cascada (0xE25A/B/C, de 60 cada uno). Con
entrada se recargan los dos de fuera (0x9B74); agotados los tres, el registro 1
del chip gráfico se pone a 0x82 y la pantalla se apaga (0x9B8D). El juego queda
en un bucle de espera con la interrupción deshabilitada (`di` en 0x9B8C).
Despierta cualquier dirección o botón (0x9B99) y, por la fila 7, RETURN, STOP o
ESC (0x9BA9).

## La demo va grabada byte a byte

De la presentación (0xB6B1) no se sale con una tecla: se sale cuando el guion
de la demo gasta siete entradas (0xB751). Con 0xE221 a 1, la entrada del
jugador no se lee: cada cuadro se mete la que dicta la tabla de 0xB9E4, parejas
[cuántos cuadros][qué se pulsa] en el mismo formato del teclado (0xB9C8). La
partida de la demo son seis parejas y tres esperas de 0xFF cuadros: dieciocho
bytes.

## El final

Dos puertas, y solo dos: quedarse sin vidas (0x8975, que al pasarse de cero se
come su dirección de retorno y calza al jugador el manejador 0x9E0E) o quedarse
sin reloj (0x9DEA, por 0x9BCF). Las dos dejan un solo objeto vivo con el
manejador de la despedida: cuatro sprites que van saliendo y subiendo —Y = 0xBC
menos el fotograma (0x9E8F)— sobre catorce tiras de dibujo que se recorren en
diez fotogramas (0x9E67).

RETURN ahí salta a 0x8065, donde empieza cada partida (0x9C91).
