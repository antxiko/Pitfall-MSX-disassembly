#!/usr/bin/env python3
"""Genera la portada de la web, en los dos idiomas.

El diseno es el compartido por la serie (tools/estilo_web.py) y la pagina sale
autocontenida, con las imagenes embebidas como data URI.

Ni el rotulo de la cabecera ni la galeria son ilustraciones traidas de fuera:
salen de las capturas que hace el propio cartucho corriendo en openMSX. El
rotulo es su pantalla de presentacion recortada, y la galeria son ocho
pantallas de partida, una por TIPO DE ESCENA, elegidas cruzando el valor del
LFSR de pantalla con la tabla que genera tools/mapa_escenas.py. O sea que si
la lectura del mundo estuviera mal, la galeria saldria descuadrada.

OJO CON EL NOMBRE DE LAS CAPTURAS: `escena_NNN_VV.png` lleva DOS numeros, y el
bueno es VV, el valor del LFSR. NNN va corrido uno, porque el recorrido del
emulador fotografia despues de dar el paso. Aqui se cruza siempre por VV.

Uso: make_web.py <work/omsx> <work/mapa_escenas.tsv> <docs/imagenes>
                 <salida.html> <idioma>
"""
import base64
import csv
import glob
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from estilo_web import ESTILO                                   # noqa: E402
from monta_mapa import lee_png, escribe_png, recorta_y_reduce   # noqa: E402

# Las cifras de la portada salen de contar sobre el listado generado, no de
# escribirlas aqui a ojo: 16384 = 9467 + 6917, que es lo que imprime
# tools/presupuesto.py. Los rotulos se formatean a partir de estos numeros
# para que no puedan quedarse desfasados por su cuenta.
CODIGO = 9467
DATOS = 6917
ESCENAS = 255                       # el anillo del LFSR de 0xE222, sin el 0x00
TESOROS = 32                        # las 32 escenas de tipo 5


def mil(n, idioma):
    return f"{n:,}".replace(",", "." if idioma == "es" else ",")


TXT = {
    "es": dict(
        titulo="Pitfall! (1984) — desensamblado comentado",
        aviso="<b>La ruta óptima es un cálculo, no una partida grabada.</b> "
              "Las 190 pantallas del guion salen de aplicar Dijkstra sobre el "
              "mundo que genera el cartucho, y se cuentan en PANTALLAS "
              "CRUZADAS, no en tiempo: correr, saltar, esquivar y el reloj de "
              "20:00 no entran en esa cuenta, y bajar una escalera se cuenta "
              "gratis. Todo lo demás —el listado, las cifras y el mapa— sale "
              "del binario y se reproduce con <code>make</code>.",
        claim="Un cartucho de 16 KB de 1984, desmontado byte a byte. "
              "Dentro no hay ni un mapa guardado: las 255 pantallas de la "
              "selva las va inventando un registro de ocho bits, los 32 "
              "tesoros son exactamente las 32 escenas de un tipo, y la liana "
              "no está dibujada en ninguna parte.",
        ficha=["Activision · <b>1984</b>", "Cartucho de <b>16 KB</b>",
               "MSX1 · <b>página 2</b>", "Volcado <b>4d899d62…</b>"],
        nav=[("#numbers", "Las cifras"), ("#findings", "Hallazgos"),
             ("#screens", "El mundo")],
        docnav=[("EMPEZAR.html", "Empezar"), ("EL-JUEGO.html", "El juego"),
                ("EL-CARTUCHO.html", "El cartucho"),
                ("EL-CODIGO.html", "El código"),
                ("HALLAZGOS.html", "Hallazgos"),
                ("PREGUNTAS-ABIERTAS.html", "Preguntas abiertas")],
        otro=("../", "In English"),
        h_num="El juego en cifras", h_find="Lo que apareció al desmontarlo",
        h_scr="Los ocho tipos de escena",
        cifras=[("100 %", "del binario explicado"),
                (str(ESCENAS), "escenas del mundo"),
                (str(TESOROS), "tesoros escondidos"),
                (mil(CODIGO, "es"), "bytes de código"),
                (mil(DATOS, "es"), "bytes de datos"),
                ("0", "bytes sin identificar")],
        nota_scr="Estas ocho sí son capturas, pero no de jugar: al emulador se "
                 "le dicta el valor del registro de pantalla y se le pide una "
                 "foto de cada escena, así que las 255 salen seguidas y sin "
                 "repetir. Aquí hay una de cada tipo, elegida cruzando el "
                 "valor del registro con la tabla que sale del cartucho. Si "
                 "esa lectura estuviera mal, lo que se vería debajo de cada "
                 "pie sería otra cosa.",
        pie_leg="Esto es trabajo de documentación y preservación sobre un "
                "juego de 1984: el código y los gráficos siguen siendo de sus "
                "autores y de Activision, y la imagen del cartucho no se "
                "distribuye.",
    ),
    "en": dict(
        titulo="Pitfall! (1984) — a commented disassembly",
        aviso="<b>The optimal route is a calculation, not a recorded game.</b> "
              "The 190 screens of the walkthrough come from running Dijkstra "
              "over the world the cartridge generates, and they are counted in "
              "SCREENS CROSSED, not in time: running, jumping, dodging and the "
              "20:00 clock are not in that count, and taking a ladder is "
              "counted as free. Everything else —the listing, the numbers and "
              "the map— comes from the binary and is reproducible with "
              "<code>make</code>.",
        claim="A 16 KB cartridge from 1984, taken apart byte by byte. "
              "There's no map stored inside it: the jungle's 255 screens are "
              "made up as it goes by an eight-bit register, the 32 treasures "
              "are exactly the 32 scenes of one type, and the vine isn't drawn "
              "anywhere at all.",
        ficha=["Activision · <b>1984</b>", "A <b>16 KB</b> cartridge",
               "MSX1 · <b>page 2</b>", "Dump <b>4d899d62…</b>"],
        nav=[("#numbers", "The numbers"), ("#findings", "What turned up"),
             ("#screens", "The world")],
        docnav=[("GETTING-STARTED.html", "Getting started"),
                ("THE-GAME.html", "The game"),
                ("THE-CARTRIDGE.html", "The cartridge"),
                ("THE-CODE.html", "The code"),
                ("FINDINGS.html", "Findings"),
                ("OPEN-QUESTIONS.html", "Open questions")],
        otro=("es/", "En castellano"),
        h_num="The game in numbers", h_find="What turned up when we took it apart",
        h_scr="The eight kinds of scene",
        cifras=[("100%", "of the binary explained"),
                (str(ESCENAS), "scenes in the world"),
                (str(TESOROS), "treasures hidden"),
                (mil(CODIGO, "en"), "bytes of code"),
                (mil(DATOS, "en"), "bytes of data"),
                ("0", "bytes unidentified")],
        nota_scr="These eight are screen captures, but not of anyone playing: "
                 "the emulator is told what to put in the screen register and "
                 "asked for a photograph of each scene, so all 255 come out "
                 "one after another with no repeats. Here is one of each kind, "
                 "picked by crossing the register value with the table that "
                 "comes out of the cartridge. Get that reading wrong and what "
                 "you would see under each caption would be something else.",
        pie_leg="This is documentation and preservation work on a 1984 game: "
                "the code and artwork still belong to their authors and to "
                "Activision, and the cartridge image is not distributed.",
    ),
}

HALLAZGOS = {
    "es": [
        ("El mundo no está guardado: se genera",
         "<p>No hay un mapa en el cartucho. Las 255 pantallas salen de un solo "
         "byte, 0xE222, que es un registro de desplazamiento realimentado: la "
         "semilla es 0xC4 y la realimentación, los bits 7, 5, 4 y 3. Al salir "
         "por la derecha lo avanza 0xB68F y al salir por la izquierda lo "
         "retrocede 0xB69F, que es su inversa exacta.</p>"
         "<p>De esos ocho bits salen las tres decisiones de cada pantalla: dos "
         "bits eligen el decorado, tres el tipo de escena y tres la variante. "
         "El anillo es máximo —255 estados, el 0x00 se queda fuera y es el que "
         "usa la pantalla del título— y la simulación coincide con el emulador "
         "en las 255.</p>"),
        ("Los 32 tesoros son exactamente las 32 escenas de un tipo",
         "<p>El tipo 5 es el único que despacha por la tabla 0xAEA4, que lleva "
         "cuatro rutinas repetidas de dos en dos. Como las ocho variantes se "
         "reparten a cuatro escenas cada una, sale un tesoro de cada clase "
         "ocho veces: 8+8+8+8 = 32, y ni uno más.</p>"
         "<p>Cada rutina escribe en 0xE188 lo que vale el suyo —2, 3, 4 o 5, o "
         "sea miles de puntos—, así que el mundo entero guarda "
         "8·(2000+3000+4000+5000) = 112000 puntos. Con los 2000 con los que "
         "arranca el marcador, <b>114000: el techo del juego</b>.</p>"),
        ("Al tesoro ya cogido se le come la dirección de retorno",
         "<p>Lo recogido se recuerda en 32 bits, 0xE21D-0xE220: un byte por "
         "clase de tesoro y un bit por tesoro. Antes de pintar uno, 0xAAFF "
         "rota su bit hasta el acarreo.</p>"
         "<p>Y si estaba a uno no salta ni pone una bandera: hace "
         "<code>pop hl</code> y <code>ret</code>. Se traga la dirección de "
         "retorno del que le llamó, así que la rutina que pintaba el tesoro no "
         "llega a ejecutarse nunca. Ahorrarse un salto sale caro de leer y "
         "barato de correr.</p>"),
        ("El subterráneo recorre el mundo al triple",
         "<p>El cambio de pantalla lo hace 0x9CBE: cuando la X del jugador "
         "llega al borde derecho lo reposiciona al otro lado y avanza el "
         "registro de pantalla. Pero avanza <b>uno o tres pasos</b> según el "
         "bit 0 de 0xE2EB, que es el que dice si se va por arriba o por el "
         "túnel. La rutina de la izquierda es simétrica.</p>"
         "<p>Por eso el atajo vale oro, y por eso la ruta que se lleva los 32 "
         "tesoros baja siempre que puede: 190 pantallas usando el túnel contra "
         "238 sin bajar nunca, un 20 % menos. Bajar sólo se puede por una "
         "escalera, y las escaleras están medidas sobre las 255 capturas: son "
         "las 63 escenas de tipo 0 y 1, y ni una más.</p>"),
        ("La liana no está dibujada en ninguna parte",
         "<p>No hay un solo dibujo de liana en el cartucho. En cada paso, "
         "0xA471 traza una recta de dieciséis puntos sobre un mapa de bits en "
         "0xE18A y la manda a la memoria de vídeo como patrón de sprite. La "
         "inclinación sale de la tabla de 0xA61A, indexada por la fase del "
         "balanceo, que va y viene entre 1 y 0x20.</p>"),
        ("En este cartucho no hay ni una palabra escrita",
         "<p>Ni una cadena, ni un alfabeto, ni un mensaje escondido. La fuente "
         "que carga el juego son diez dígitos, los dos puntos y el blanco: con "
         "eso se escriben el marcador y el reloj, y no da para una letra.</p>"
         "<p>Todo lo que parece texto —el rótulo de la presentación y el "
         "<b>Copyright 1982, 1984</b> del pie— son dibujos partidos en "
         "casillas, una por posición. Por eso buscar cadenas en la ROM no "
         "devuelve nada legible, y por eso esa línea del pie, con sus dos "
         "fechas, es lo único que el cartucho firma.</p>"),
    ],
    "en": [
        ("The world isn't stored, it's generated",
         "<p>There is no map in the cartridge. The 255 screens come out of a "
         "single byte, 0xE222, a feedback shift register: the seed is 0xC4 and "
         "the feedback taps are bits 7, 5, 4 and 3. Leaving to the right, "
         "0xB68F steps it forward; leaving to the left, 0xB69F —its exact "
         "inverse— steps it back.</p>"
         "<p>Those eight bits carry the three decisions of every screen: two "
         "bits pick the scenery, three the kind of scene and three the "
         "variant. The ring is maximal —255 states, with 0x00 left outside it "
         "and used by the title screen— and the simulation agrees with the "
         "emulator on all 255.</p>"),
        ("The 32 treasures are exactly the 32 scenes of one kind",
         "<p>Type 5 is the only one dispatched through table 0xAEA4, which "
         "holds four routines repeated two by two. Since the eight variants "
         "share out four scenes each, every class of treasure comes up eight "
         "times: 8+8+8+8 = 32, and not one more.</p>"
         "<p>Each routine writes what its own is worth into 0xE188 —2, 3, 4 or "
         "5, that is thousands of points— so the whole world holds "
         "8·(2000+3000+4000+5000) = 112000 points. With the 2000 the score "
         "starts at, <b>114000: the ceiling of the game</b>.</p>"),
        ("A treasure already taken has its return address eaten",
         "<p>What has been picked up is remembered in 32 bits, 0xE21D-0xE220: "
         "one byte per class of treasure and one bit per treasure. Before "
         "drawing one, 0xAAFF rotates its bit out into the carry.</p>"
         "<p>And if it was set, there's no branch and no flag: it does "
         "<code>pop hl</code> and <code>ret</code>. It swallows its caller's "
         "return address, so the routine that was going to draw the treasure "
         "never runs at all. Saving one jump costs a lot to read and nothing "
         "to run.</p>"),
        ("The tunnel crosses the world three times as fast",
         "<p>Changing screen is 0x9CBE's job: when the player's X reaches the "
         "right-hand edge it puts him back on the other side and steps the "
         "screen register on. But it steps on <b>one place or three</b> "
         "depending on bit 0 of 0xE2EB, which is what says whether you're up "
         "on the surface or down in the tunnel. The left-hand routine is "
         "symmetrical.</p>"
         "<p>That's why the shortcut is worth so much, and why the route that "
         "collects all 32 treasures goes underground whenever it can: 190 "
         "screens using the tunnel against 238 never going down, 20 % fewer. "
         "You can only go down by a ladder, and the ladders are measured over "
         "the 255 captures: they're the 63 scenes of types 0 and 1, and not "
         "one more.</p>"),
        ("The vine isn't drawn anywhere",
         "<p>There isn't a single picture of a vine in the cartridge. On every "
         "step, 0xA471 traces a sixteen-point straight line onto a bitmap at "
         "0xE18A and sends it to video memory as a sprite pattern. The slope "
         "comes from the table at 0xA61A, indexed by the phase of the swing, "
         "which runs up and down between 1 and 0x20.</p>"),
        ("There isn't one written word in this cartridge",
         "<p>Not a string, not an alphabet, not a hidden message. The font the "
         "game loads is ten digits, the colon and a blank: enough for the "
         "score and the clock, and not enough for a single letter.</p>"
         "<p>Everything that looks like text —the title banner and the "
         "<b>Copyright 1982, 1984</b> at the foot— is drawing, cut into tiles, "
         "one per position. That's why searching the ROM for strings returns "
         "nothing readable, and why that one line at the foot, with its two "
         "dates, is the only thing the cartridge signs.</p>"),
    ],
}

# Los pies de la galeria: uno por TIPO DE ESCENA (los bits 3-5 del registro de
# pantalla), en el orden de la tabla de 0xAEB4. Lo que dice cada uno esta en
# src/pitfall.notes, en el bloque de 0xA9AA.
TIPOS = [
    ("Tipo 0 · 0xA9AA — hoyos en el suelo, con escalera al subterráneo. El "
     "bit 7 del registro de pantalla parte el tipo en dos: un hoyo o tres",
     "Type 0 · 0xA9AA — pits in the ground, with a ladder down to the tunnel. "
     "Bit 7 of the screen register splits the type in two: one pit or three"),
    ("Tipo 1 · 0xA9AA — la otra mitad de los hoyos, y la otra mitad de las "
     "escaleras: entre los tipos 0 y 1 están las 63 bajadas que hay",
     "Type 1 · 0xA9AA — the other half of the pits, and the other half of the "
     "ladders: types 0 and 1 hold the 63 ways down there are"),
    ("Tipo 2 · 0xAC7C — charca de brea. El mismo dibujo que el tipo 3 con "
     "otro color: escribe 1B 1B 1B en la tabla de colores",
     "Type 2 · 0xAC7C — a tar pit. The same drawing as type 3 in another "
     "colour: it writes 1B 1B 1B into the colour table"),
    ("Tipo 3 · 0xAC6B — charca de agua, que es el parche de color deshecho: "
     "7B 7B 7B donde el tipo 2 ponía 1B 1B 1B",
     "Type 3 · 0xAC6B — a water pool, which is that colour patch undone: "
     "7B 7B 7B where type 2 put 1B 1B 1B"),
    ("Tipo 4 · 0xAD75 — laguna con tres cocodrilos: tres bloques de cuatro "
     "bytes en el código, tres cocodrilos en la pantalla",
     "Type 4 · 0xAD75 — a lagoon with three crocodiles: three four-byte "
     "blocks in the code, three crocodiles on screen"),
    ("Tipo 5 · 0xADF6 — la escena del tesoro, la única que puntúa. Son 32 en "
     "el anillo, ocho de cada valor",
     "Type 5 · 0xADF6 — the treasure scene, the only one that scores. There "
     "are 32 of them in the ring, eight of each value"),
    ("Tipo 6 · 0xAE04 — brea con liana, y la liana se traza punto a punto en "
     "cada paso",
     "Type 6 · 0xAE04 — tar with a vine, and the vine is traced point by "
     "point on every step"),
    ("Tipo 7 · 0xADE8 — agua con liana. Con el tipo 6 y el 4, las tres "
     "escenas que obligan a cruzar por arriba",
     "Type 7 · 0xADE8 — water with a vine. With types 6 and 4, the three "
     "scenes that make you cross over the top"),
]

# El recorte del rotulo: sobre la captura ya reducida a la mitad, se busca el
# rectangulo de lo que no es fondo. El fondo de openMSX no es (0,0,0) exacto
# -el negro del MSX le sale con un tinte-, de ahi el umbral.
UMBRAL, MARGEN, ESCALA = 40, 4, 2

# ---------------------------------------------------------------------------
# Harry andando encima del titulo
# ---------------------------------------------------------------------------
# NI EL DIBUJO NI EL RITMO SE ELIGEN AQUI: los doce fotogramas de
# docs/imagenes/jugador.png los saca tools/render_jugador.py de la VRAM volcada
# montando las tres capas de sprite como las monta 0x9D03, y los tiempos son
# los del guion de animacion del cartucho.
#
#   guion_anda_derecha (0x8AE1)  cinco fotogramas de TRES interrupciones cada
#   uno -> 15 interrupciones por zancada, 0,25 s a 60 Hz.
#   anda (0x88ED)  escribe 0x00C8 en la velocidad del jugador, que va en 1/256
#   de pixel por cuadro: 200/256 = 0,78125 px por interrupcion, 46,875 px/s.
#
# La banda que cruza es el ancho del rotulo que hay debajo, medido sobre
# logo.png y no elegido a ojo, y Harry se dibuja a la misma escala que el
# rotulo: asi los pixeles de arriba y los de abajo son del mismo tamano.
# Cruzarla, a 46,875 px/s, sale de dividir. La vuelta se hace VOLTEANDO el
# dibujo en vez de usar los patrones de la izquierda porque se ha comprobado
# sobre la tira que los cinco de 0x44-0x54 son el espejo exacto de los de
# 0x20-0x30: se ve exactamente lo mismo.
#
# El "a 60 Hz" es la unica suposicion: en una maquina de 50 Hz el cartucho
# anda mas despacio, porque cuenta interrupciones y no segundos.
FOTOGRAMAS_ANDA = 5                 # los del guion 0x8AE1
ZANCADA = 5 * 3 / 60                # 0,25 s: cinco fotogramas de tres cuadros
PXS = 0x00C8 / 256 * 60             # 46,875 px por segundo: la velocidad de 0x893E
ANCHO_LOGO = 640                    # lo que mide el rotulo en la portada (CSS)

# TODO va en PORCENTAJES, y a proposito: la banda tiene que medir exactamente lo
# mismo que el rotulo que hay debajo, y el rotulo se pinta con
# `width:min(100%,640px)`. Con `100vw` no cuadraba -100vw incluye la barra de
# scroll y el 100% del rotulo no-, asi que la banda salia unos pixeles mas ancha
# y encima podia empujar scroll horizontal. Con el mismo min() y un
# aspect-ratio, los pixeles de arriba y los de abajo miden igual a cualquier
# ancho de pantalla, y sin una sola medida absoluta mas.
ANIM = """
.paseo{{position:relative;margin:0 auto;width:min(100%,{logo}px);
  aspect-ratio:{ancho}/32;border-bottom:1px solid var(--linea);overflow:hidden}}
.paseo b{{position:absolute;left:0;top:0;height:100%;
  width:calc(100%*16/{ancho});animation:va {viaje:.4g}s linear infinite}}
.paseo i{{display:block;width:100%;height:100%;overflow:hidden;
  animation:mira {viaje:.4g}s steps(2,jump-none) infinite}}
.paseo u{{display:block;width:{sabana}%;height:100%;image-rendering:pixelated;
  background:url({img}) 0 0/100% 100%;
  animation:paso {zancada:.4g}s steps({fot}) infinite}}
@keyframes va{{0%{{transform:translateX(0)}}
  50%{{transform:translateX(calc(100%*{recorrido}/16))}}
  100%{{transform:translateX(0)}}}}
@keyframes paso{{from{{transform:translateX(0)}}
  to{{transform:translateX(-{avance:.6g}%)}}}}
@keyframes mira{{from{{transform:scaleX(1)}}to{{transform:scaleX(-1)}}}}
@media(prefers-reduced-motion:reduce){{.paseo b,.paseo i,.paseo u{{animation:none}}}}
"""


def paseo_css(ruta_jug, ruta_logo):
    """El CSS de la animacion, con las medidas sacadas del rotulo y del binario.

    El ancho de la banda son los pixeles de MSX que ocupa el rotulo -logo.png
    lleva dos pixeles por cada uno del MSX, que es la ESCALA con que se
    recorta-, y de ahi sale su aspect-ratio. Si no hay rotulo, se usa la
    pantalla entera del MSX: 256 px.
    """
    if os.path.exists(ruta_logo):
        ancho = lee_png(ruta_logo)[0] // ESCALA
    else:
        ancho = 256
    recorrido = ancho - 16                     # Harry ocupa 16 px de los suyos
    # Cuantos fotogramas trae la tira se cuenta en la propia tira, no aqui: es
    # su ancho entre 16, y si algun dia sale a otra escala, su alto entre 32.
    w_tira, h_tira, _ = lee_png(ruta_jug)
    fotogramas = w_tira // (16 * (h_tira // 32))
    return ANIM.format(img=img64(ruta_jug), ancho=ancho, logo=ANCHO_LOGO,
                       recorrido=recorrido, zancada=ZANCADA,
                       viaje=2 * recorrido / PXS,      # el ciclo es IDA Y VUELTA
                       fot=FOTOGRAMAS_ANDA, sabana=100 * fotogramas,
                       avance=100 * FOTOGRAMAS_ANDA / fotogramas)


def img64(ruta):
    with open(ruta, "rb") as f:
        return "data:image/png;base64," + base64.b64encode(f.read()).decode()


def _reduce(captura):
    """La captura de openMSX (640x480) recortada a la pantalla del MSX y a la mitad."""
    w, h, filas = lee_png(captura)
    return recorta_y_reduce(w, h, filas)


def _recorta(w, h, filas, x0, y0, x1, y1, escala):
    out = []
    for y in range(y0, y1 + 1):
        fila = filas[y]
        nueva = bytearray()
        for x in range(x0, x1 + 1):
            nueva += fila[x * 3:x * 3 + 3] * escala
        for _ in range(escala):
            out.append(nueva)
    return (x1 - x0 + 1) * escala, (y1 - y0 + 1) * escala, out


def logo_png(captura, ruta):
    """El rotulo de la cabecera: la pantalla de presentacion, recortada.

    No es una imagen dibujada aparte ni un logotipo bajado de ningun sitio: es
    lo que el cartucho pinta al arrancar -la franja de colores, el rotulo de la
    editora, el monigote y el titulo-, con el fondo negro recortado alrededor.
    """
    w, h, filas = _reduce(captura)
    def claro(fila, x):
        return max(fila[x * 3:x * 3 + 3]) > UMBRAL
    ys = [y for y, fila in enumerate(filas) if any(claro(fila, x) for x in range(w))]
    xs = [x for x in range(w) if any(claro(fila, x) for fila in filas)]
    if not ys or not xs:
        raise SystemExit("la captura %s esta en negro entero" % captura)
    y0, y1 = max(0, ys[0] - MARGEN), min(h - 1, ys[-1] + MARGEN)
    x0, x1 = max(0, xs[0] - MARGEN), min(w - 1, xs[-1] + MARGEN)
    escribe_png(ruta, *_recorta(w, h, filas, x0, y0, x1, y1, ESCALA))


def por_tipo(tsv):
    """El valor del LFSR de la primera escena de cada tipo, en orden de anillo."""
    elegido = {}
    with open(tsv, newline="", encoding="utf-8") as f:
        for fila in csv.DictReader(f, delimiter="\t"):
            t = int(fila["tipo"])
            if t not in elegido:
                elegido[t] = fila["lfsr"]
    return elegido


def muestras(capturas, tsv, imgdir):
    """Una pantalla de partida por tipo de escena, recortada y a media resolucion.

    Devuelve la lista de (fichero, pie_es, pie_en) que la galeria embebe. Si no
    estan las capturas -hacen falta openMSX y tools/omsx_mapa_lfsr.tcl- la
    galeria se queda vacia y la portada se genera igual.
    """
    if not os.path.isdir(capturas) or not os.path.exists(tsv):
        print("  (sin capturas en %s: la portada sale sin galeria)" % capturas)
        return []
    elegido = por_tipo(tsv)
    out = []
    for tipo in range(len(TIPOS)):
        lfsr = elegido.get(tipo)
        if lfsr is None:
            continue
        # se cruza por el LFSR, NUNCA por el numero de captura
        halladas = glob.glob(os.path.join(
            capturas, "escena_[0-9][0-9][0-9]_%s.png" % lfsr[2:].upper()))
        if not halladas:
            continue
        w, h, filas = _reduce(sorted(halladas)[0])
        fich = "escena-tipo-%d.png" % tipo
        escribe_png(os.path.join(imgdir, fich), w, h, filas)
        out.append((fich,) + TIPOS[tipo])
    return out


def main(argv):
    if len(argv) < 6:
        print(__doc__)
        return 2
    capturas, tsv, imgdir, salida, idioma = argv[1:6]
    t = TXT[idioma]
    os.makedirs(imgdir, exist_ok=True)

    ruta_logo = os.path.join(imgdir, "logo.png")
    arranque = os.path.join(capturas, "arranque.png")
    if os.path.exists(arranque):
        logo_png(arranque, ruta_logo)
    cabecera = (f'<img src="{img64(ruta_logo)}" alt="Pitfall! (1984)">'
                if os.path.exists(ruta_logo) else "<h1>Pitfall! (1984)</h1>")

    # Harry anda encima del titulo si esta la tira de fotogramas; si no la hay
    # -sale de la VRAM volcada, que no se versiona-, la portada va sin el.
    ruta_jug = os.path.join(imgdir, "jugador.png")
    anim = paseo = ""
    if os.path.exists(ruta_jug):
        anim = paseo_css(ruta_jug, ruta_logo)
        # tres cajas: la que viaja (b), la ventana de un fotograma que voltea (i)
        # y la sabana de doce que se corre por dentro (u)
        paseo = '<div class="paseo" aria-hidden="true"><b><i><u></u></i></b></div>'

    nav = "".join(f'<a href="{h}">{x}</a>' for h, x in t["nav"])
    nav += "".join(f'<a href="{h}">{x}</a>' for h, x in t["docnav"])
    nav += (f'<a href="{t["otro"][0]}" style="margin-left:auto;color:var(--oro)">'
            f'{t["otro"][1]}</a>')

    cifras = "".join(f'<div class="cifra"><b>{v}</b><span>{e}</span></div>'
                     for v, e in t["cifras"])
    halls = "".join(f'<div class="hall"><h3>{tit}</h3>{cuerpo}</div>'
                    for tit, cuerpo in HALLAZGOS[idioma])
    imgs = ""
    for fich, es, en in muestras(os.path.join(capturas, "mapa"), tsv, imgdir):
        pie = es if idioma == "es" else en
        imgs += (f'<figure><img src="{img64(os.path.join(imgdir, fich))}" '
                 f'alt="{pie}"><figcaption>{pie}</figcaption></figure>')

    html = f"""<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>{t['titulo']}</title>
<style>{ESTILO}{anim}</style>
<header class="top">
  {cabecera}
  {paseo}
  <p class="claim">{t['claim']}</p>
  <p class="ficha">{' · '.join(t['ficha'])}</p>
</header>
<p class="ficha" style="border:1px solid var(--oro);padding:.8em 1em;margin:1.5em 0">
{t['aviso']}</p>
<nav>{nav}</nav>
<section id="numbers">
  <h2>{t['h_num']}</h2>
  <div class="cifras">{cifras}</div>
</section>
<section id="findings"><h2>{t['h_find']}</h2>{halls}</section>
<section id="screens">
  <h2>{t['h_scr']}</h2>
  <p class="n">{t['nota_scr']}</p>
  <div class="galeria">{imgs}</div>
</section>
<footer><p>{t['pie_leg']}</p></footer>
"""
    with open(salida, "w", encoding="utf-8") as f:
        f.write(html)
    print("  %s: %d KB (%s)" % (salida, len(html) // 1024, idioma))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
