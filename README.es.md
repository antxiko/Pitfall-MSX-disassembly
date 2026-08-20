# Pitfall! (Activision, 1984, MSX1) — desensamblado comentado

Un cartucho de 16 KB de 1984, desmontado byte a byte. Los 16.384 bytes están
acotados y con dueño, y dentro no hay ni un mapa guardado: las 255 pantallas de
la selva salen de un registro de ocho bits, y los 32 tesoros son exactamente
las 32 escenas de un tipo.

📖 **[Documentación completa](https://antxiko.github.io/Pitfall-MSX-disassembly/es/)**
· [In English](https://antxiko.github.io/Pitfall-MSX-disassembly/)
· [README in English](README.md)

---

## Qué es esto

*Pitfall!* de MSX es la conversión que Activision hizo en 1984 de su juego de
Atari 2600 de 1982. En este repositorio está su código, comentado, con las
herramientas para volver a montarlo y comprobar que lo que sale es el original.

La máquina mapea los 16 KB en 0x8000-0xBFFF —la página 2—, la BIOS llama al
punto de entrada 0x8013, y de ahí el código no vuelve: el arranque se mete en
un bucle vacío de dos bytes y **el juego entero corre dentro de la
interrupción**, cincuenta o sesenta veces por segundo. Todo el estado vive en
la RAM a partir de 0xE000.

## Por qué esto se puede creer

`make` traza el flujo, genera el listado y exige que al ensamblarlo vuelva a
salir exactamente el original:

```
  ensamblado : 16384 bytes  4d899d62...82c8be58
  original   : 16384 bytes  4d899d62...82c8be58
OK: reproducible byte a byte
```

Un listado puede reensamblar perfecto y estar mal —si unos dibujos se leen como
instrucciones, los bytes no cambian—, así que al lado corren dos comprobaciones
más: ningún rango declarado como datos puede salir como código, y ningún punto
de entrada puede caer dentro de uno.

## Las cifras

| | |
|---|---|
| bytes de código | 9.467 |
| bytes de datos | 6.917 |
| bytes sin explicar | **0** |
| etiquetas bautizadas | 337 |
| comentarios anclados | 583 |
| rangos de datos con explicación | 130 |

## Unas cuantas cosas que aparecieron

- **El mundo no está guardado: se genera.** La pantalla en la que estás *es* un
  byte de RAM, 0xE222, y cambiar de pantalla es hacerlo girar un paso con un
  registro de desplazamiento realimentado. El anillo es máximo: 255 pantallas,
  siempre en el mismo orden, salidas de 33 bytes de código.
- **Los 32 tesoros son exactamente las 32 escenas de un tipo**, y el techo del
  juego —114.000 puntos— se cuenta sin jugar: ocho tesoros de cada uno de los
  cuatro valores, más los 2.000 de salida del marcador.
- **Al tesoro ya cogido se le come la dirección de retorno.** 0xAAFF rota su
  bit hasta el acarreo y, si estaba encendido, hace `pop hl` y `ret`: el código
  que pintaría el tesoro no llega a ejecutarse.
- **El subterráneo recorre el mundo al triple**: cruzar una pantalla por abajo
  gira el registro tres pasos en vez de uno. La ruta que se lleva los 32
  tesoros son 189 pantallas, contra 238 sin bajar nunca.
- **Un tick del reloj son 60 interrupciones**, medido en partida real: a 60 Hz
  los 20:00 duran veinte minutos de pared, y a 50 Hz, veinticuatro.
- **La liana se pinta cuadro a cuadro, y no hay ningún dibujo suyo guardado.**
  El código traza una recta de dieciséis puntos sobre un mapa de bits en RAM y
  la manda a la memoria de vídeo como patrón de sprite. La inclinación sale de
  una tabla, así que la cuerda que se ve son cuentas, no un gráfico.
- **En el cartucho no hay ni una palabra escrita.** La fuente son diez dígitos,
  los dos puntos y el blanco; todo lo que parece texto es dibujo. Lo único que
  el cartucho firma es el **Copyright 1982, 1984** del pie de la presentación.

Hay más, con la evidencia al lado, en
[la página de hallazgos](https://antxiko.github.io/Pitfall-MSX-disassembly/es/HALLAZGOS.html).

## Lo que sigue abierto

En el código no aparece condición de victoria: no hay contador de tesoros ni
comparación contra 32. La ruta de 189 pantallas es un cálculo sobre las reglas
del cartucho, sin validar jugándola. Y los 16 bytes de 0xBAA2 no tienen
consumidor. Están en
[la página de preguntas abiertas](https://antxiko.github.io/Pitfall-MSX-disassembly/es/PREGUNTAS-ABIERTAS.html).

## Para empezar

Hacen falta `pasmo`, `z80dasm` y Python 3. El cartucho **no** se distribuye
aquí: pon tu copia en la raíz como `pitfall.rom`, 16384 bytes, sha256
`4d899d6258a8b06dfae8c91a8c57230fa23ff364136d6a243fafeaf282c8be58`.

```sh
make          # traza, monta el listado y lo comprueba todo
make verify   # ensambla y compara con el cartucho
make sanity   # lo que el reensamblado no puede cazar
```

Las instrucciones completas, en
[Empezar](https://antxiko.github.io/Pitfall-MSX-disassembly/es/EMPEZAR.html).

## Licencia y atribución

El juego no es nuestro: *Pitfall!* es de Activision, y todos los derechos
siguen siendo de sus titulares. Lo que sí es nuestro —las herramientas, los
comentarios y la documentación— se publica con la licencia de `LICENSE`. La imagen del
cartucho no se distribuye. Ver [AVISO-LEGAL.md](AVISO-LEGAL.md).
