# Aviso legal y atribución

*(Also available [in English](LEGAL-NOTICE.md).)*

## De quién es cada cosa

**El juego no es nuestro.** *Pitfall!* de MSX lo publicó **Activision** en 1984, y
es la conversión que esa misma empresa hizo de su juego de Atari 2600 de 1982.
Todos los derechos sobre el juego siguen siendo de sus titulares.

**Lo que sí es nuestro** son las herramientas de este repositorio, los comentarios
del listado, el análisis y la documentación. Eso se publica con la licencia de
`LICENSE`.

## Qué hay en este repositorio

El fichero `src/pitfall.asm` es el desensamblado comentado del cartucho. Se
publica para la **preservación, el estudio y la documentación** de un título de
1984 que es parte de la historia del software del MSX.

La imagen del cartucho (`.rom`) **no** se distribuye aquí. Quien quiera volver a
montar el listado tiene que poner la suya, y el `Makefile` comprueba su sha256
antes de hacer nada.

Las imágenes de `docs/` salen de dos sitios distintos, y conviene decir cuál es
cuál:

- el mapa del mundo, las ocho escenas de muestra y el rótulo de la portada **son
  capturas de pantalla**, hechas moviendo el cartucho en un emulador con los
  guiones de este repositorio —al emulador se le dicta qué valor poner en el
  registro de pantalla y se le pide una foto de cada escena—;
- la tira de fotogramas del protagonista no es un dibujo: son los propios
  patrones de sprite del juego, leídos de la memoria de vídeo volcada y
  recompuestos exactamente como los monta el código;
- y el diagrama del guion está generado, no fotografiado: es la ruta más corta
  calculada sobre el mundo que produce el propio cartucho.

Ninguna es una ilustración traída de fuera, y todas son parte de la prueba de que
la lectura del binario es correcta: si la lectura estuviera mal, las imágenes
saldrían descuadradas.

## En qué se apoya

En nada de nadie. Todo lo que se afirma aquí sale de leer este binario, y cada
afirmación lleva su evidencia al lado: la instrucción que lee un dato, la tabla
que cierra exactamente donde tiene que cerrar, o la cuenta que sale sola. Lo que
no está cerrado se dice que no lo está, en la página de preguntas abiertas.

## Si eres uno de los autores

Si trabajaste en *Pitfall!* o tienes derechos sobre el juego, y preferirías que
este material no estuviera publicado, **dilo y se retira, sin discusión**. La
intención de este trabajo es justo la contraria de perjudicarte: es dejar
constancia de cómo se hizo.
