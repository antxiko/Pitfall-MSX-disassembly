# Preguntas abiertas

Cada byte del cartucho tiene dueño, el listado vuelve a dar el original byte a
byte y sus 337 etiquetas tienen nombre. Lo que **no** quiere decir eso es que
todas lleven escrito qué hacen: 79 llevan su explicación en la propia etiqueta y
el resto se apoya en los 302 comentarios de línea y en las 50 cabeceras de
bloque, así que hay rutinas bautizadas de las que solo está dicho el nombre. Esta
página cuenta qué significan esas cifras exactamente, y qué queda por saber.

## El reloj no cuadra, y no se disimula

El código dice una cosa muy concreta: 0x9DB8 gasta un cuadro por pasada y hace
un tick cada 60 (0xE1D5). Sesenta cuadros.

Lo que **no** se puede decir a partir de ahí es cuánto dura eso en segundos.
Sesenta cuadros son un segundo solo si el bucle corre a un cuadro por
interrupción y no se pierde ninguno, y una medida en el emulador dio del orden
de nueve segundos reales por tick. Esa diferencia sigue sin explicar.

Así que la duración de una partida de «20:00» está sin cerrar. Lo que hay
medido es el periodo —60 cuadros— y lo que hace falta es medir el tick de
verdad, con el reloj del emulador al lado, y ver por dónde se van los cuadros.

## No aparece condición de victoria

Las dos únicas salidas de partida que hay en el código son quedarse sin vidas
(0x8975) y quedarse sin reloj (0x9DEA). Las dos acaban en el mismo sitio: la
secuencia final de 0x9E0E.

Que llevarse los 32 tesoros haga algo **no está demostrado ni descartado**. Lo
que se puede afirmar es lo que se ha buscado y no está: en el código trazado no
no hay ninguna comparación contra 32 que tenga que ver con los tesoros —la única
que hay compara la fase del balanceo de la liana, en 0xA5F0—, y aparte de los 32
bits de tesoros cogidos (0xE21D-0xE220) no aparece ningún contador de cuántos
llevas. Si hay final por
haberlos recogido todos, no sale de ahí.

## La ruta de 190 pantallas es un cálculo, no una partida

El número está bien hecho —sale de recorrer el anillo de 255 escenas con las
reglas de cambio de pantalla del propio cartucho, contando el atajo del
subterráneo— pero mide **pantallas cruzadas**, y nada más.

Lo que no entra en la cuenta: el tiempo, el reloj de 20:00, correr, saltar,
esperar a que un tronco pase, y bajar o subir una escalera, que se cuentan como
gratis. No es una partida grabada.

Falta correrla en el emulador y comprobar dos cosas: que aparecen los 32 tesoros
y que el marcador llega a 114000.

## Qué es cada bicho, y qué es cada estorbo

Tres rutinas (0xAA74, 0xAAB7 y 0xAB85) pintan un dibujo de 3x2 celdas en el
mismo hueco de la pantalla, cada una con sus patrones de sprite y su caja de
colisión —de clase 6 las dos primeras, que matan, y de clase 8 la tercera, que
es tesoro—. Lo que está por dentro se sabe entero. **Cuál es cuál mirándolo, no.**

Lo mismo pasa con el objeto de 0xA69E, que se acerca a la X del jugador y para
cuando lo tiene justo encima, con su caja de clase 9: mata, se mueve así, y qué
animal es hace falta verlo.

Es una tarde de emulador cruzando las capturas con las rutinas, no una
investigación.

## Dieciséis bytes con dueño y sin uso

En 0xBAA2 hay dos listas de ocho bytes, y la segunda es la primera con los
nibbles intercambiados: 61 contra 16, 91 contra 19, B1 contra 1B. El rango está
acotado por los dos lados —el inicializador que acaba justo ahí y el bloque
comprimido que empieza justo después— así que los dieciséis bytes están
declarados y contados.

Pero no tienen consumidor: ni una instrucción trazada los lee, ni ninguna de las
16384 palabras del cartucho vale su dirección. Están explicados como datos, no
como uso, y esa es la diferencia que el «100 %» no distingue.

Con la misma vara: el guion de animación de 0xAF84 y la segunda copia del reloj
de 0x8F00 están perfectamente identificados y tampoco los usa nadie.

## Qué respalda cada cifra, y qué no

Para que quede claro qué hay detrás de los números de este repositorio:

- **Reensambla byte a byte.** El listado publicado se ensambla y el sha256 del
  resultado es el del cartucho. Si un comentario se hubiera comido un byte, esa
  línea no saldría.
- **Ni un byte sin explicar.** Los 16384 se reparten en 9467 de código que el
  trazador alcanza siguiendo el flujo de verdad y 6917 dentro de un rango
  declarado, cada uno con la instrucción que lo lee escrita al lado.
- **Ninguna zona de datos se lee como código.** Es una comprobación aparte, y
  hace falta: un desensamblado puede reensamblar perfecto y estar mintiendo, si
  unos dibujos se están leyendo como instrucciones. Los bytes no cambian, solo
  cambia lo que decimos de ellos.
- **Ningún punto de entrada cae dentro de una zona de datos.** Sembrar el
  trazador con una dirección mal deducida hincha la cobertura sin que salte
  ninguna alarma, así que hay una regla para exactamente eso.

Y lo que ese 100 % **no** quiere decir: que se sepa para qué sirve cada byte.
Quiere decir que cada byte está dentro de un rango con nombre, y que ese nombre
sale de haber leído la instrucción que lo consume. Los tres casos del apartado
de arriba son justo la excepción, y por eso están escritos.

Los comentarios del listado están verificados por muestreo —la tabla del
despachador de 0x8AA0 coincide byte a byte con la ROM, y las seis rutinas
muertas se confirmaron por segunda vía— pero no línea a línea.

## Cuatro avisos para quien siga por aquí

**Un periodo no es una velocidad, y un contador de cuadros no es un reloj.**
Sesenta cuadros por tick es lo que dice el código; cuánto dura eso es otra
pregunta, y confundirlas es lo que dejó abierto el apartado del reloj.

**Escribir 0xE222 a pelo no repinta nada.** La única vía por la que se monta una
escena es 0x9EE6, y se llega a ella desde el arranque de la partida (0x809F) y
desde el cambio de pantalla (0x9CBE y 0x9CF9), y de ningún otro sitio. Para recorrer el mundo en el emulador hay que escribir 0xE7 en 0xE2A3
—la X del jugador— y dejar que el juego cambie de pantalla él solo.

**Y entonces las capturas van corridas una.** El recorrido fotografía después de
dar el paso, así que la captura número N no es la escena N. Se cruzan por su
valor del registro de pantalla, que va en el nombre del fichero, y no por el
número.

**Buscar punteros a lo bruto miente.** Una tira de bytes repetidos parece un
puntero, y leer un operando desde la mitad de una instrucción da direcciones
verosímiles que no existen. Toda pista que salga de ahí se confirma contra el
listado antes de creerla; es la razón de que las herramientas de este
repositorio recorran solo inicios de instrucción.
