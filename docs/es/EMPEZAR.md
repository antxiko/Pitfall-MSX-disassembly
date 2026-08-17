# Empezar

## Lo que hace falta

`pasmo` y `z80dasm` para ensamblar y desensamblar, y Python 3 para las
herramientas. Nada más: no hay dependencias que instalar ni entorno que montar.

El cartucho no se distribuye con este repositorio, solo el trabajo de
documentación, así que hace falta tu propia copia con el nombre `pitfall.rom`
en la raíz del proyecto. Son 16384 bytes exactos y tiene que dar este sha256:

    4d899d6258a8b06dfae8c91a8c57230fa23ff364136d6a243fafeaf282c8be58

Si el tuyo no da eso, es otro volcado y el listado no reensamblará. `make
comprueba` te lo dice en una línea.

## Las órdenes

```sh
make          # traza, genera el listado y lo comprueba todo
make verify   # solo la prueba de fuego: ¿vuelve a salir el cartucho?
make sanity   # lo que el reensamblado NO puede cazar
make test     # los trece tests del listado, que no necesitan el cartucho
```

`make` a secas hace el ciclo entero y falla si algo no cuadra: si el listado
deja de reproducir el cartucho byte a byte, si el trazador se ha metido en una
zona declarada como datos, si un punto de entrada cae dentro de esa zona, o si
queda un solo byte de los 16384 sin dueño.

## La prueba que decide

Lo único que convierte un desensamblado en algo fiable es que vuelva a dar el
original. Aquí eso es `make verify`, y lo que hace es ensamblar el listado
publicado y comparar el sha256 con el del cartucho:

    ensamblado : 16384 bytes  4d899d62...82c8be58
    original   : 16384 bytes  4d899d62...82c8be58
    OK: reproducible byte a byte

Mientras esa línea salga, ni un comentario de este repositorio puede haberse
comido un byte por el camino.

## La segunda prueba, que es la que casi nadie hace

Un listado puede reensamblar perfecto y estar mintiendo: si unos dibujos se
están leyendo como instrucciones, los bytes no cambian —solo cambia lo que
decimos de ellos— y el sha256 sale igual. `make sanity` es exactamente esa
comprobación, y termina con el reparto completo:

      codigo trazado              9467   57.78 %
      datos identificados         6917   42.22 %
      sin explicar                   0    0.00 %
      ==========================================
      explicado                  16384  100.00 %

## Sin el cartucho

Se puede leer igualmente el listado de `src/pitfall.asm` y las notas, que es
donde está el trabajo: 5679 líneas con 338 rutinas y tablas bautizadas, 302
comentarios anclados a su dirección y 119 rangos de datos con su explicación al
lado. Los trece tests corren igual, porque ninguno necesita el binario.

## Cómo está organizado

El listado **no se toca a mano**. Se genera, y lo gobiernan tres ficheros:

| | |
|---|---|
| `src/pitfall.entries` | los puntos de entrada: por dónde empieza a trazar |
| `src/pitfall.nocode` | las zonas que NO son código, y por qué se sabe |
| `src/pitfall.notes` | los nombres, los comentarios y los rangos de datos |

De ahí sale `src/pitfall.asm`. Si quieres cambiar un comentario o bautizar una
rutina, va en el `.notes`, anclado a su dirección; así el comentario sobrevive a
un retrazado y nunca se despega de la instrucción que explica.

El `.entries` es aquí más largo de lo que suele: este cartucho declara **un solo
punto de entrada** —la BIOS lee la cabecera y llama a 0x8013— y todo lo demás
llega por caminos que ningún trazador estático puede seguir. El gancho de
interrupción (0x80F7), los manejadores de objeto que viajan dentro de plantillas
copiadas a RAM, las cuatro tablas de despacho y los vectores de sonido están
declarados uno a uno, cada cual con la instrucción que lo escribe apuntada al
lado.

## Las herramientas

En `tools/` está todo, y cada una lleva escrito en su cabecera qué hace y por
qué se hizo así:

| | |
|---|---|
| `z80trace.py` | sigue el flujo desde los puntos de entrada |
| `mkasm.py` | monta el listado con las notas ancladas |
| `presupuesto.py` | el reparto de los 16384 bytes, y qué queda sin dueño |
| `refs.py` | qué instrucciones apuntan a un rango, sin inventarse punteros |
| `quien_apunta.py` | para cada hueco, quién lo lee desde el código trazado |
| `busca_autoescritura.py` | busca escrituras a la ROM: el efecto de una protección, no una forma concreta |
| `mapa_escenas.py` | reproduce el anillo de 255 escenas desde el cartucho |
| `busca_escaleras.py` | en qué escenas se puede bajar al subterráneo |
| `ruta_optima.py` | la ruta mínima para llevarse los 32 tesoros |
| `monta_mapa_guion.py` | las 255 escenas en rejilla, etiquetadas |
| `dibuja_guion.py` | esa ruta dibujada, una casilla por pantalla |
| `omsx_*.tcl` | los arneses de openMSX: arranque, capturas y recorrido del mundo |
