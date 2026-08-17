# El juego

Un explorador cruza la jungla de izquierda a derecha recogiendo tesoros, con un
reloj que se acaba. Todo lo que viene aquí sale de leer el código que lo hace.

## El mundo son 255 pantallas, y no ocupan un solo byte de mapa

La escena en la que estás es el contenido de un byte de RAM, 0xE222. Cuando la X
del jugador llega al borde derecho —0xE7— se le pone en 0x19, o sea al otro
lado, y ese byte se hace girar un paso (0x9CBE). Por la izquierda, en 0x16, pasa
lo mismo al revés con la función inversa (0x9CF9).

Ese giro recorre 255 valores distintos antes de volver al principio, así que el
mundo es un anillo de 255 pantallas y **el orden está fijado**: la partida
siempre empieza en la misma escena, y la siguiente siempre es la misma. No hay
nada aleatorio, y no hay ninguna lista de pantallas en el cartucho.

Del byte se leen tres cosas distintas al montar la escena (0x9EE6):

| bits | qué eligen |
|---|---|
| 6-7 | el decorado: cuál de los cuatro paisajes se pinta (0x9F91) |
| 3-5 | el tipo de escena, de 0 a 7 (0x9EFB) |
| 0-2 | la variante dentro de ese tipo (0x9EEF) |

## Las ocho clases de pantalla

Los bits 3-5 eligen una de ocho rutinas por la tabla de 0xAEB4, y cada una monta
un tipo de pantalla:

| Tipo | Rutina | Qué es | Cuántas hay |
|---|---|---|---|
| 0 | 0xA9AA | hoyos en el suelo, con escalera al subterráneo | 31 |
| 1 | 0xA9AA | los mismos: las dos entradas de la tabla apuntan al mismo sitio | 32 |
| 2 | 0xAC7C | charca de brea | 32 |
| 3 | 0xAC6B | charca de agua | 32 |
| 4 | 0xAD75 | laguna con tres cocodrilos | 32 |
| 5 | 0xADF6 | **la escena del tesoro**, la única que puntúa | 32 |
| 6 | 0xAE04 | brea con liana | 32 |
| 7 | 0xADE8 | agua con liana | 32 |

El reparto es prácticamente uniforme porque el anillo recorre los 255 valores no
nulos: solo el tipo 0 se queda con una escena menos.

Los tipos 0 y 1 comparten rutina, así que esas 63 escenas son la misma clase de
pantalla. Lo que las parte en dos es **otro bit**: 0xA9AA lee suelto el bit 7 del
registro y con él decide dónde va la **caja de rebote** —la de clase 10, centrada
en 0xD8 con el bit encendido y en 0x31 con él apagado— y cuál de los dos dibujos
de hoyos se pinta, el de uno o el de tres. La escalera no se mueve de sitio: las
dos ramas pintan el mismo guion de celdas, 0x8F06 (0x8D4A y 0x8D5D).

Y los tipos 2 y 3 son **el mismo dibujo con distinto color**: 0xAC7C escribe `1B 1B
1B` en la tabla de colores, que deja el charco negro —brea—, y 0xAC6B escribe
`7B 7B 7B`, que lo deja cian —agua—.

Los tres cocodrilos de la laguna van en las X 0x50, 0x6F y 0x88 (0xA828), y
abren la boca cada cuadro (guion de 0xAFD8). Con la boca abierta, su caja de
colisión crece (0xA812).

## Los 32 tesoros, contados sin jugar una partida

Los tesoros son exactamente las 32 escenas de tipo 5, porque el tipo 5 es el
único que despacha por la tabla de 0xAEA4, y esa tabla lleva cuatro rutinas
repetidas de dos en dos. Como las ocho variantes se reparten a cuatro escenas
cada una, sale un tesoro de cada clase ocho veces:

| Rutina | Vale | Cuántos |
|---|---|---|
| 0xAC11 | 2000 | 8 |
| 0xAB51 | 3000 | 8 |
| 0xAB1B | 4000 | 8 |
| 0xABB7 | 5000 | 8 |

Son cuatro dibujos: el saco de dinero, dos barras y el anillo con la piedra, que
es el más caro. Las dos barras comparten hasta el color —el byte de color vale
0x4B en 0xAE90 y también en 0xAE92—, y lo único que las distingue es el patrón.

Ocho por cada una, y ni uno más: 8 × (2000+3000+4000+5000) = **112000 puntos**
repartidos por el mundo. El marcador arranca en 2000 (0x8A28), así que el techo
del juego son **114000 puntos**.

Lo que ya te has llevado se recuerda en 32 bits: 0xE21D-0xE220, un byte por
clase y un bit por tesoro, con el índice dentro de la clase en 0xE223. Al entrar
en una escena de tesoro, 0xAAFF mira ese bit, y si está encendido no pinta nada:
el tesoro no vuelve a aparecer.

## El subterráneo, que es un atajo de verdad

Por los hoyos se baja al subterráneo, y también por la escalera que llevan las
escenas de tipos 0 y 1 —63 de las 255—. La escalera no tiene caja de colisión:
se comprueba a mano que la escena sea de esas y que la X del jugador caiga entre
0x70 y 0x88 (0x83D4). Esa ventana es **más ancha que el dibujo**: el mástil que
pinta el guion de celdas de 0x8F06 es la columna 16, o sea de 0x80 a 0x87, así que
se baja también desde un poco antes de pisarlo.

Y ahí abajo el mundo corre al triple. El bit 0 de 0xE2EB dice si estás en la
superficie —0xACE4 lo enciende al empezar la partida, 0x8751 lo apaga al caer
por un hoyo y 0x849A lo vuelve a encender al salir—, y cuando está apagado,
cruzar una pantalla hace girar el registro **tres pasos en vez de uno** (0x9CD2).
Tres escenas de golpe.

Sobre esas dos reglas se puede calcular la ruta más corta que se lleva los 32
tesoros: **190 pantallas** cruzadas, contra 238 si no se baja nunca: el atajo
ahorra un 20 %. No son 190 a la derecha; 186 lo son, y en cuatro el cálculo
retrocede para encadenar dos tesoros.

Es un cálculo, no una partida: el coste está medido en pantallas cruzadas, la
escalera se cuenta como gratis, y el reloj no entra en la cuenta.

## Lo que te cuesta puntos, y lo que te cuesta una vida

De las diez clases de caja solo cuatro cuestan una vida: la 3 y la 4 por 0x83B9,
y la 6 y la 9 por 0x8226, que son los dos únicos sitios del cartucho desde los
que se llama a quitar una vida. Esto es lo que hacen las demás:

- **el tronco** (clase de colisión 1, manejador 0x8640) te tumba y te va restando
  **un punto por cuadro** mientras te pisa (0x8674). Se sale andando, y en cuanto
  la caja deja de dar clase 1 se vuelve al manejador normal;
- **golpearte con un tronco mientras trepas** cuesta dos puntos y te manda
  escalera abajo (0x8506);
- **caer por un hoyo** cuesta cien puntos, y acabas en el subterráneo (0x8781);
- **la charca y el cocodrilo** te hunden (0x8361): el dibujo del jugador se va
  comiendo por abajo un byte a la vez mientras baja hasta la Y 0x7A, y ahí se
  pierde una vida;
- **las clases 6 y 9** matan directamente (0x8221).

Se empieza con dos vidas de repuesto (0x8A52), y se ven de dos maneras a la vez:
tres casillas en las filas 2 y 3 de la pantalla, y el color de los sprites 12 y
13, que se pone a cero —transparente— cuando esa vida se acaba (0x89A8).

Al perder una, la escena no se repinta: se esconde todo lo demás guardando
cuántos objetos había en 0xE189, el jugador se vuelve a dibujar por trozos y cae
al suelo, y al terminar se devuelven los objetos (0x8221-0x82E7). Reapareces
pegado al borde izquierdo, en la X 0x20 (0x826A).

## El reloj y el marcador

El reloj arranca en **20:00** y cuenta hacia atrás. No está guardado como número:
los cinco bytes de 0xE1D0 son ya los números de casilla `BA B8 C2 B8 B8`, o sea
los dibujos de «2», «0», «:», «0» y «0», y la cuenta atrás se hace sobre ellos
(0x9DB8). Cuando el prestamo llega a la decena de minutos y ahí aparece el
blanco (0xC3), se acabó el tiempo (0x9DEA): el reloj se queda clavado en 00:00 y
arranca la secuencia final.

Cada tick gasta 60 cuadros (0xE1D5), y en pausa el reloj no corre (0x9DB8).

El marcador son seis dígitos sueltos en 0xE1D6-0xE1DB, en binario, que se pasan
a casillas al pintarlos y se escriben en la fila 1, columna 6 (0x9D72). Los ceros
de delante se pintan en blanco hasta que sale un dígito no nulo (0x9D5C). Sumar
un tesoro es sumar en el dígito de los miles (0x9D9F); restar puntos es la rutina
de 0x9D7C, a la que se le pasa qué dígito tocar.

## Los mandos

Cuatro direcciones y un disparo, y da igual que vengan del joystick o del
teclado: la barra espaciadora y los cursores se recolocan en los mismos bits
(0xB26E). Arriba, abajo, izquierda y derecha son los bits 0 a 3 de 0xE05F, y los
dos disparos los bits 4 y 5 (0x87E0).

Con el botón mantenido no se vuelve a saltar (0x87E9), y de la liana solo se
suelta uno pulsando abajo (0x81A7).

Tres teclas hacen otra cosa, y se miran en la fila 7 del teclado (0x9BF3):

| | |
|---|---|
| ESC | pausa, con una máquina de estados de pulsar-soltar en 0xE267 |
| RETURN | vuelve al título, pero solo si 0xE269 lo permite |
| STOP | arranca de cero, saltando a INIT |

La pausa está resuelta de una manera bonita: 0x9C94 guarda cuántos objetos había
y pone cero. Con la lista de objetos vacía no se mueve nada, y no hace falta ni
un `if` repartido por el resto del código. Con un solo objeto vivo no se puede
pausar, porque eso quiere decir que lo que corre es la secuencia final.

## Si nadie toca nada, la pantalla se apaga

0x9B6D lleva tres contadores en cascada, 0xE25A, 0xE25B y 0xE25C, cada uno de
60. Mientras llegue entrada se recargan los dos de fuera, 0xE25B y 0xE25C
(0x9B74); el primero sigue contando y se recarga él solo al llegar a cero
(0x9B82). Cuando se agotan los tres, el registro 1
del chip gráfico se pone a 0x82 y la pantalla se apaga (0x9B8D). A partir de ahí
el juego se queda en un bucle de espera con la interrupción deshabilitada —el `di`
va antes de apagar, en 0x9B8C—, así que ahí no hay cuadros que contar. Despierta
cualquiera de las cuatro direcciones o de los dos botones (0x9B99) y, por la fila
7 del teclado, RETURN, STOP o ESC (0x9BA9). Al volver, el registro 1 vuelve a
0xE2 (0x9BAF).

## La demo se juega sola, y va grabada byte a byte

De la presentación (0xB6B1) no se sale con una tecla: se sale cuando el guion de
la demo ha gastado siete de sus entradas (0xB751). A partir de ahí, 0xE221 vale 1 y la entrada del
jugador ya no se lee: cada cuadro se le mete la que dicta la tabla de 0xB9E4,
que son parejas [cuántos cuadros][qué se pulsa] en el mismo formato que sale del
teclado (0xB9C8).

Con seis parejas se acaba la partida de la demo, y detrás vienen tres esperas de
0xFF cuadros: no hay ninguna inteligencia jugando, hay dieciocho bytes —doce de
partida y seis de espera—.

## El final

Se llega a él por dos puertas, y son las dos únicas: quedarse sin vidas (0x8975,
que al pasarse de cero se come su propia dirección de retorno y le calza al
jugador el manejador 0x9E0E) o quedarse sin reloj (0x9DEA, que pasa por 0x9BCF).

Las dos hacen lo mismo: dejar un solo objeto vivo y darle el manejador de la
despedida. Lo que se ve entonces son cuatro sprites que van saliendo y subiendo
—su Y es 0xBC menos el fotograma (0x9E8F)— sobre catorce tiras de dibujo que se
recorren en diez fotogramas y vuelven a empezar (0x9E67).

Pulsar RETURN ahí salta a 0x8065, que es donde empieza cada partida, también la
segunda (0x9C91).
