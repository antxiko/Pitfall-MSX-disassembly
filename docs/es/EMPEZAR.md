# Empezar

## Lo que hace falta

`pasmo` y `z80dasm` para ensamblar y desensamblar, y Python 3 para las
herramientas. No hay más dependencias.

El cartucho no se distribuye con este repositorio: hace falta tu propia copia,
con el nombre `pitfall.rom` en la raíz del proyecto. Son 16384 bytes exactos con
este sha256:

    4d899d6258a8b06dfae8c91a8c57230fa23ff364136d6a243fafeaf282c8be58

Con otro volcado el listado no reensamblará. `make comprueba` lo dice en una
línea.

## Las órdenes

```sh
make          # traza, genera el listado y lo comprueba todo
make verify   # ensambla el listado y compara el sha256 con el cartucho
make sanity   # lo que el reensamblado no puede cazar
make test     # los 17 tests del listado, que no necesitan el cartucho
```

`make` falla si el listado deja de reproducir el cartucho byte a byte, si el
trazador se mete en una zona declarada como datos, si un punto de entrada cae
dentro de una, o si queda un byte de los 16384 sin dueño.

## La prueba que decide

Un desensamblado es fiable si al ensamblarlo vuelve a salir el original. Eso es
`make verify`:

    ensamblado : 16384 bytes  4d899d62...82c8be58
    original   : 16384 bytes  4d899d62...82c8be58
    OK: reproducible byte a byte

## La segunda prueba

Un listado puede reensamblar perfecto y estar mal: si unos dibujos se leen como
instrucciones, los bytes no cambian —solo cambia lo que se dice de ellos—.
`make sanity` cruza los rangos de datos contra el trazado y termina con el
reparto:

      codigo trazado              9467   57.78 %
      datos identificados         6917   42.22 %
      sin explicar                   0    0.00 %
      ==========================================
      explicado                  16384  100.00 %

## Sin el cartucho

El trabajo está en `src/pitfall.asm` y en las notas: 5711 líneas con 337
rutinas y tablas bautizadas, 305 comentarios anclados a su dirección y 130
rangos de datos con su explicación al lado. Los 17 tests corren sin el binario.

## Cómo está organizado

El listado **no se toca a mano**: se genera, y lo gobiernan tres ficheros.

| | |
|---|---|
| `src/pitfall.entries` | los puntos de entrada: por dónde empieza a trazar |
| `src/pitfall.nocode` | las zonas que NO son código, y por qué se sabe |
| `src/pitfall.notes` | los nombres, los comentarios y los rangos de datos |

De ahí sale `src/pitfall.asm`. Cada nota va en el `.notes`, anclada a su
dirección, así que sobrevive a un retrazado.

El `.entries` es largo porque el cartucho declara **un solo punto de entrada**
—la BIOS lee la cabecera y llama a 0x8013— y lo demás llega por caminos que un
trazador estático no puede seguir: el gancho de interrupción (0x80F7), los
manejadores que viajan dentro de plantillas copiadas a RAM, las cuatro tablas
de despacho y los vectores de sonido, declarados uno a uno con la instrucción
que los escribe apuntada al lado.

## Las herramientas

En `tools/`, cada una con su cabecera:

| | |
|---|---|
| `z80trace.py` | sigue el flujo desde los puntos de entrada |
| `mkasm.py` | monta el listado con las notas ancladas |
| `presupuesto.py` | el reparto de los 16384 bytes, y qué queda sin dueño |
| `refs.py` | qué instrucciones apuntan a un rango, sin inventarse punteros |
| `quien_apunta.py` | para cada hueco, quién lo lee desde el código trazado |
| `busca_autoescritura.py` | busca escrituras a la ROM |
| `mapa_escenas.py` | reproduce el anillo de 255 escenas desde el cartucho |
| `busca_escaleras.py` | en qué escenas se puede bajar al subterráneo |
| `ruta_optima.py` | la ruta mínima para llevarse los 32 tesoros |
| `monta_mapa_guion.py` | las 255 escenas en rejilla, etiquetadas |
| `dibuja_guion.py` | esa ruta dibujada, una casilla por pantalla |
| `omsx_*.tcl` | los arneses de openMSX: arranque, capturas y recorrido |
