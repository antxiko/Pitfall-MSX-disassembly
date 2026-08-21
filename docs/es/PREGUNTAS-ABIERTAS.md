# Preguntas abiertas

Cada byte del cartucho tiene dueño, el listado vuelve a dar el original byte a
byte y sus 337 etiquetas tienen nombre. Eso no quiere decir que todas lleven
escrito qué hacen: 78 llevan su explicación en la propia etiqueta y el resto se
apoya en los 988 comentarios de línea y en las 50 cabeceras de bloque. Esta
página dice qué significan esas cifras y qué queda por saber.

## No aparece condición de victoria

Las dos únicas salidas de partida son quedarse sin vidas (0x8975) y quedarse
sin reloj (0x9DEA), y las dos acaban en la secuencia final de 0x9E0E.

Que llevarse los 32 tesoros haga algo **no está demostrado ni descartado**. Lo
que se ha buscado y no está: en el código trazado no hay ninguna comparación
contra 32 que tenga que ver con los tesoros —la única compara la fase del
balanceo de la liana, 0xA5F0— y, aparte de los 32 bits de tesoros cogidos
(0xE21D-0xE220), no hay ningún contador de cuántos llevas.

## La ruta de 189 pantallas es un cálculo, no una partida

El número sale de recorrer el anillo de 255 escenas con las reglas de cambio de
pantalla del propio cartucho, contando el atajo del subterráneo. Mide
**pantallas cruzadas** y nada más: saltar, esperar un tronco y usar la escalera
se cuentan gratis.

Cabe en el reloj, y esa cuenta también sale del cartucho: se anda a 200/256 de
píxel por cuadro (0x88ED) y una pantalla va de la X 0x19 a la 0xE7, 206
píxeles: 264 cuadros, 4,4 segundos a 60 Hz. Los 189 cruces suman 49.896
cuadros —13,9 minutos— contra los 72.000 del reloj de 20:00: el 70 % del reloj
solo en andar, con unos seis minutos de margen. Sigue siendo aritmética del
modelo.

Falta correr la ruta en el emulador y comprobar que aparecen los 32 tesoros y
que el marcador llega a 114000.

## Dieciséis bytes con dueño y sin uso

En 0xBAA2 hay dos listas de ocho bytes, y la segunda es la primera con los
nibbles intercambiados: 61 contra 16, 91 contra 19, B1 contra 1B. El rango está
acotado por los dos lados, pero no tiene consumidor: ni una instrucción trazada
lo lee, ni ninguna de las 16384 palabras del cartucho vale su dirección. Están
explicados como datos, no como uso.

Con la misma vara: el guion de animación de 0xAF84 y la segunda copia del reloj
de 0x8F00 están identificados y tampoco los usa nadie.

## Qué respalda cada cifra, y qué no

- **Reensambla byte a byte.** El listado publicado se ensambla y el sha256 es
  el del cartucho.
- **Ni un byte sin explicar.** Los 16384 se reparten en 9467 de código trazado
  y 6917 dentro de un rango declarado, cada uno con la instrucción que lo lee
  al lado.
- **Ninguna zona de datos se lee como código.** Comprobación aparte del
  reensamblado, que no puede cazar eso: si unos dibujos se leen como
  instrucciones, los bytes no cambian.
- **Ningún punto de entrada cae dentro de una zona de datos.** Sembrar el
  trazador con una dirección mal deducida hincharía la cobertura sin alarma.

Lo que el 100 % **no** quiere decir: que se sepa para qué sirve cada byte.
Quiere decir que cada byte está en un rango con nombre, y que ese nombre sale
de la instrucción que lo consume. Los tres casos del apartado anterior son la
excepción, y por eso están escritos.

Los comentarios del listado están verificados por muestreo, no línea a línea.

## Cuatro avisos para quien siga por aquí

**Un periodo no es una velocidad, y un contador de cuadros no es un reloj.** El
código dice cuadros por tick; cuánto dura eso depende de la máquina, y las dos
cosas se confunden con facilidad.

**Escribir 0xE222 a pelo no repinta nada.** La única vía por la que se monta
una escena es 0x9EE6, y se llega desde el arranque de partida (0x809F) y desde
el cambio de pantalla (0x9CBE y 0x9CF9). Para recorrer el mundo en el emulador
hay que escribir 0xE7 en 0xE2A3 —la X del jugador— y dejar que el juego cambie
de pantalla solo.

**Las capturas del recorrido van corridas una.** Se fotografía después de dar
el paso, así que la captura N no es la escena N. Se cruzan por el valor del
registro de pantalla, que va en el nombre del fichero.

**Buscar punteros a lo bruto miente.** Una tira de bytes repetidos parece un
puntero, y leer un operando desde la mitad de una instrucción da direcciones
verosímiles que no existen. Toda pista de ahí se confirma contra el listado;
por eso las herramientas de este repositorio recorren solo inicios de
instrucción.
