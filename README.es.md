# Pitfall! (Activision, 1984, MSX1) — desensamblado comentado

Un cartucho de 16 KB de 1984, desmontado byte a byte. Los 16.384 bytes están
acotados y con dueño, y dentro no hay ni un mapa guardado: las 255 pantallas de
la selva las va inventando un registro de ocho bits, los 32 tesoros son
exactamente las 32 escenas de un tipo, y la liana no está dibujada en ninguna
parte.

📖 **[Documentación completa](https://antxiko.github.io/Pitfall-MSX-disassembly/es/)**
· [In English](https://antxiko.github.io/Pitfall-MSX-disassembly/)
· [README in English](README.md)

---

## Qué es esto

*Pitfall!* de MSX es la conversión que Activision hizo en 1984 de su propio juego
de Atari 2600 de 1982. En este repositorio está su código, comentado, con las
herramientas para volver a montarlo y para comprobar que lo que sale es de verdad
el original.

Que sea un cartucho cambia la forma del trabajo. No hay cargador ni bloques que
esperar: la máquina mapea los 16 KB en 0x8000-0xBFFF —la página 2— y eso es toda
la foto, una sola imagen de la memoria sin solapes. La BIOS lee una cabecera «AB»,
llama al punto de entrada de 0x8013, y de ahí el código no vuelve: el arranque se
mete en un bucle vacío de dos bytes y **el juego entero corre dentro de la
interrupción**, cincuenta o sesenta veces por segundo.

Tampoco hay ni una variable en el cartucho, porque es ROM. Todo el estado vive en
la RAM de la máquina a partir de 0xE000, y por eso el listado está lleno de
direcciones que empiezan por 0xE0 y no son datos.

## Por qué esto se puede creer

`make` traza el flujo, genera el listado y exige que al ensamblarlo vuelva a
salir exactamente el original:

```
  ensamblado : 16384 bytes  4d899d62...82c8be58
  original   : 16384 bytes  4d899d62...82c8be58
OK: reproducible byte a byte
```

Esa es la prueba que decide si un desensamblado es fiable, pero no es la única que
hay aquí, porque un listado puede reensamblar perfecto y estar mintiendo: si unos
dibujos se leen como instrucciones, los bytes no cambian —solo cambia lo que
decimos de ellos—. Así que al lado corren dos comprobaciones más:

- ningún rango declarado como datos puede salir como código;
- y ningún punto de entrada puede caer dentro de uno.

## Las cifras

| | |
|---|---|
| bytes de código | 9.467 |
| bytes de datos | 6.917 |
| bytes sin explicar | **0** |
| etiquetas bautizadas | 337 |
| comentarios anclados | 302 |
| rangos de datos con explicación | 130 |

## Unas cuantas cosas que aparecieron

- **El mundo no está guardado: se genera.** La pantalla en la que estás *es* un
  byte de RAM, 0xE222, y cambiar de pantalla es hacerlo girar un paso con un
  registro de desplazamiento realimentado. El anillo es máximo: 255 pantallas,
  siempre en el mismo orden, salidas de 33 bytes de código. Ese es todo el mapa
  de este juego.
- **Los 32 tesoros son exactamente las 32 escenas de un tipo**, y el techo del
  juego —114.000 puntos— se cuenta sin jugar: ocho tesoros de cada uno de los
  cuatro valores, más los 2.000 con los que arranca el marcador.
- **Al tesoro ya cogido se le come la dirección de retorno.** 0xAAFF rota su bit
  de «ya lo tienes» hasta el acarreo, y si estaba encendido hace `pop hl` y
  `ret`: se traga la dirección de vuelta de quien la llamó, así que el código que
  habría pintado el tesoro no llega a ejecutarse.
- **El subterráneo recorre el mundo al triple**: cruzar una pantalla por abajo
  hace girar el registro tres pasos en vez de uno, y por eso la ruta que se lleva
  todo son 190 pantallas y no 238.
- **La liana no está dibujada en ninguna parte.** Cada cuadro se traza una recta
  de dieciséis puntos sobre un mapa de bits en la RAM y se manda a la memoria de
  vídeo como patrón de sprite.
- **En el cartucho no hay ni una palabra escrita.** La fuente son diez dígitos,
  los dos puntos y el blanco; todo lo que parece texto es dibujo partido en
  casillas. Lo único que el cartucho firma es el **Copyright 1982, 1984** del pie
  de la presentación.

Hay más, con la evidencia al lado, en
[la página de hallazgos](https://antxiko.github.io/Pitfall-MSX-disassembly/es/HALLAZGOS.html).

## Lo que sigue abierto

Cada byte tiene dueño, pero no todo está cerrado. El caso más claro es el reloj:
el código hace un tick cada 60 cuadros y una medida en el emulador dio del orden
de nueve segundos reales por tick, y esa diferencia sigue sin explicar. La ruta de
190 pantallas es un cálculo sobre las reglas del propio cartucho, no una partida
grabada. Y en el código no aparece condición de victoria: no hay una sola
comparación contra 32 en ninguna parte. Esas y las demás están en
[la página de preguntas abiertas](https://antxiko.github.io/Pitfall-MSX-disassembly/es/PREGUNTAS-ABIERTAS.html).

## Para empezar

Hacen falta `pasmo`, `z80dasm` y Python 3. El cartucho **no** se distribuye aquí:
pon tu propia copia en la raíz del proyecto como `pitfall.rom`, 16384 bytes,
sha256 `4d899d6258a8b06dfae8c91a8c57230fa23ff364136d6a243fafeaf282c8be58`.

```sh
make          # traza, monta el listado y lo comprueba todo
make verify   # solo la prueba de fuego
make sanity   # lo que el reensamblado no puede cazar
```

Las instrucciones completas están en
[Empezar](https://antxiko.github.io/Pitfall-MSX-disassembly/es/EMPEZAR.html).

## Licencia y atribución

El juego no es nuestro: *Pitfall!* es de Activision, y todos los derechos siguen
siendo de sus titulares. Lo que sí es nuestro —las herramientas, los comentarios,
el análisis y la documentación— se publica con la licencia de `LICENSE`. La imagen
del cartucho no se distribuye. Ver [AVISO-LEGAL.md](AVISO-LEGAL.md).
