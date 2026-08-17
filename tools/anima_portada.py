#!/usr/bin/env python3
"""La animacion de la portada: correr, saltar, liana, caer y correr al otro lado.

NADA DE ESTO SE ELIGE AQUI. Cada numero sale del cartucho:

  - los fotogramas de correr, del guion 0x8AE1: cinco, de tres cuadros cada uno;
  - la velocidad, de `anda` (0x88ED): 0x00C8 en el campo de velocidad, que va en
    1/256 de pixel por cuadro, o sea 200/256 = 0,78125 px por interrupcion;
  - el salto, de la curva de 0x8AB6: 0x00 mantiene, 0xFF sube un pixel y 0x01
    baja uno, leida del final al principio (0x8820 la indexa con IX+0x17 de 0x1F
    a 1). Sale un salto de diez pixeles;
  - la liana, del trazador de 0xA471 y de la tabla de 0xA61A: la inclinacion de
    cada fase, el periodo de cada fase -de 1 en el centro a 9 en el extremo, o
    sea que el balanceo frena en los extremos- y el punto donde se agarra.

La UNICA suposicion es que la maquina va a 60 Hz: el cartucho cuenta
interrupciones, no segundos.

Y una cosa que sale de leer el codigo y no de la imaginacion: al colgarse, el
jugador NO cambia de dibujo. Los tres sprites de la cuerda se quedan con el
patron 0x3C (0xAE67 y 0xAE73) y el jugador se queda con el suyo, asi que aqui se
le congela el fotograma que llevaba.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from render_liana import registros, punto_de_agarre, SPRITES, FILAS_POR_SPRITE  # noqa: E402

ORG = 0x8000
CURVA_SALTO = 0x8AB6
PASOS_SALTO = 0x20                  # el indice de 0x8820 va de 0x1F a 1
PX_CUADRO = 0x00C8 / 256            # la velocidad de 0x88ED
HZ = 60                             # la suposicion, y la unica

ANCHO_JUGADOR, ALTO_JUGADOR = 16, 32
FOTOGRAMAS_ANDA = 5                 # los del guion 0x8AE1
CUADROS_POR_FOTOGRAMA = 3           # idem
DERECHA_0, IZQUIERDA_0 = 0, 5       # donde empiezan en la tira de doce
CIELO = "#42ebf5"                   # color 7 del TMS9918: el cielo de las escenas


def curva_del_salto(rom):
    """Las alturas del salto, cuadro a cuadro, tal como las suma 0x8820.

    Devuelve una lista de desplazamientos verticales acumulados (negativo es
    hacia arriba), uno por cuadro de vuelo.
    """
    c = rom[CURVA_SALTO - ORG:CURVA_SALTO - ORG + PASOS_SALTO]
    y, alturas = 0, []
    for paso in range(PASOS_SALTO - 1, 0, -1):      # de 0x1F a 1
        b = c[paso]
        y += -1 if b == 0xFF else (1 if b == 0x01 else 0)
        alturas.append(y)
    return alturas


def fases_del_balanceo(regs):
    """La media ida de la liana: (fase, cuadros que dura) de la 1 a la 0x20."""
    return [(f, regs[f][1]) for f in range(1, 0x21)]


class Escena:
    """Los numeros de la banda, todos en pixeles y cuadros de MSX."""

    def __init__(self, rom, ancho):
        self.regs = registros(rom)
        self.alturas = curva_del_salto(rom)
        self.ancho = ancho
        self.media_ida = sum(p for _, p in fases_del_balanceo(self.regs))

        # El agarre mas tumbado manda en la geometria: la cuerda llega ahi, y la
        # cabeza del jugador tiene que llegar justo a esa fila en lo alto del
        # salto. De ahi sale el alto de la banda, no de un gusto.
        dx, fila = punto_de_agarre(self.regs[0x20][0], self.regs[0x20][2])
        self.agarre_dx, self.agarre_fila = dx, fila
        self.subida = -min(self.alturas)                     # diez pixeles
        # El suelo queda donde tiene que quedar para que la cabeza llegue al
        # agarre justo en la cima del salto: si el salto sube 10 px, el suelo
        # esta 10 px mas abajo de lo que estaria si se agarrase de pie.
        self.alto = fila + ALTO_JUGADOR + self.subida
        self.suelo = self.alto                                # donde pisa
        self.ancla = ancho // 2                               # la cuerda, al centro

        # el punto de agarre a la izquierda, y donde tiene que estar su caja
        self.x_agarre = self.ancla - dx - ANCHO_JUGADOR // 2
        self.cima = self.alturas.index(min(self.alturas)) + 1  # cuadros hasta la cima
        self.correr_1 = self.media_ida - self.cima             # para que cuadre
        self.caida = self.subida                               # baja lo que subio
        self.correr_2 = self.media_ida - self.caida
        self.medio = self.media_ida * 4                        # cuadros de media vuelta
        self.total = 2 * self.medio

    # -- la posicion del jugador, cuadro a cuadro ---------------------------
    def jugador(self, t):
        """(x, y, fotograma) en el cuadro t de la media vuelta hacia la derecha."""
        x_salto_fin, y_suelo = self.x_agarre, self.suelo - ALTO_JUGADOR
        if t < self.correr_1:                                  # corriendo
            x = x_salto_fin - (self.cima + self.correr_1 - t) * PX_CUADRO
            return x, y_suelo, self._paso(t, DERECHA_0)
        t -= self.correr_1
        if t < self.cima:                                      # saltando
            x = x_salto_fin - (self.cima - t) * PX_CUADRO
            return x, y_suelo + self.alturas[t], self._quieto(DERECHA_0)
        t -= self.cima
        if t < 2 * self.media_ida:                             # colgado
            x, fila = self._agarre(t)
            return x, fila, self._quieto(DERECHA_0)
        t -= 2 * self.media_ida
        if t < self.caida:                                     # cayendo
            x = self.ancla + self.agarre_dx - ANCHO_JUGADOR // 2
            return x, self.agarre_fila + t, self._quieto(DERECHA_0)
        t -= self.caida
        x = (self.ancla + self.agarre_dx - ANCHO_JUGADOR // 2) + t * PX_CUADRO
        return x, y_suelo, self._paso(t, DERECHA_0)

    def _agarre(self, t):
        """Colgado: la X y la fila salen del punto de agarre de cada fase."""
        fase, lado = self._fase_colgado(t)
        dx, fila = punto_de_agarre(self.regs[fase][0], self.regs[fase][2])
        x = self.ancla + (dx if lado > 0 else -dx) - ANCHO_JUGADOR // 2
        return x, fila

    def _fase_colgado(self, t):
        """De la fase 0x20 por la izquierda a la 0x20 por la derecha."""
        acumulado = 0
        for fase, dura in reversed(fases_del_balanceo(self.regs)):   # 0x20 -> 1
            if t < acumulado + dura:
                return fase, -1
            acumulado += dura
        t -= acumulado
        acumulado = 0
        for fase, dura in fases_del_balanceo(self.regs):             # 1 -> 0x20
            if t < acumulado + dura:
                return fase, +1
            acumulado += dura
        return 0x20, +1

    def _paso(self, t, base):
        return base + (t // CUADROS_POR_FOTOGRAMA) % FOTOGRAMAS_ANDA

    def _quieto(self, base):
        return base + 2                        # se queda con el fotograma que llevaba

    # -- la fase de la liana, cuadro a cuadro -------------------------------
    def liana(self, t):
        """(fotograma de la cuerda, lado) en el cuadro t del ciclo de 2 medias idas."""
        acumulado = 0
        for fase, dura in fases_del_balanceo(self.regs):
            if t < acumulado + dura:
                return fase
            acumulado += dura
        t -= acumulado
        acumulado = 0
        for fase, dura in reversed(fases_del_balanceo(self.regs)):
            if t < acumulado + dura:
                return fase
            acumulado += dura
        return 1


# ---------------------------------------------------------------------------
# El CSS
# ---------------------------------------------------------------------------
# Los fotogramas y las posiciones se emiten como keyframes explicitos porque el
# ritmo NO es constante: el balanceo frena en los extremos (el periodo de cada
# fase esta en la tabla) y el salto sigue una curva. Un steps() no sabe de eso.
#
# Todo va en porcentajes -de la banda o del propio elemento- para que la escena
# mida exactamente lo mismo que el rotulo que hay encima a cualquier ancho de
# pantalla, sin una sola medida absoluta.
CABECERA = """
.escena{{position:relative;margin:0 auto;width:min(100%,{logo}px);
  aspect-ratio:{ancho}/{alto};background:{cielo};overflow:hidden;
  border-bottom:1px solid var(--linea)}}
.escena .liana{{position:absolute;top:0;left:calc(100%*{liana_x}/{ancho});
  width:calc(100%*{liana_w}/{ancho});height:calc(100%*{liana_h}/{alto});
  image-rendering:pixelated;background:url({img_liana}) 0 0/{sabana_liana}% 100%;
  animation:fase {t_fase:.4g}s linear infinite,
            lado {t_ciclo:.4g}s step-end infinite}}
.escena .corre{{position:absolute;top:0;left:0;
  width:calc(100%*{jug_w}/{ancho});height:calc(100%*{jug_h}/{alto});
  image-rendering:pixelated;background:url({img_jug}) 0 0/{sabana_jug}% 100%;
  animation:va {t_ciclo:.4g}s linear infinite,
            paso {t_ciclo:.4g}s step-end infinite}}
@media(prefers-reduced-motion:reduce){{.escena .liana,.escena .corre{{animation:none}}}}
"""


def _pc(v, total):
    return round(100.0 * v / total, 4)


def css(rom, ancho, ancho_logo, img_jug, img_liana, fotogramas_jug, liana_w):
    """El CSS entero de la escena, con la banda del ancho del rotulo."""
    e = Escena(rom, ancho)
    liana_h = SPRITES * FILAS_POR_SPRITE
    n_liana = len(e.regs)

    # -- el jugador: una llave por cambio de fotograma y por tramo de vuelo ---
    va, paso = [], []
    ultimo = None
    for t in range(e.total):
        media, tt = divmod(t, e.medio)
        x, y, f = e.jugador(tt)
        if media:                                  # la vuelta es el espejo
            x = e.ancho - x - ANCHO_JUGADOR
            f = f - DERECHA_0 + IZQUIERDA_0
        # posicion: cada dos cuadros basta, y en los tramos rectos interpola CSS
        if t % 2 == 0 or tt in (e.correr_1, e.correr_1 + e.cima):
            va.append((t, _pc(x, ANCHO_JUGADOR), _pc(y, ALTO_JUGADOR)))
        if f != ultimo:
            paso.append((t, f))
            ultimo = f

    ll = []
    for t in range(2 * e.media_ida):
        f = e.liana(t)
        if not ll or ll[-1][1] != f:
            ll.append((t, f))

    def k_va():
        return "".join("%s%%{transform:translate(%s%%,%s%%)}"
                       % (_pc(t, e.total), x, y) for t, x, y in va)

    def k_paso():
        return "".join("%s%%{background-position-x:%s%%}"
                       % (_pc(t, e.total), _pc(f, fotogramas_jug - 1))
                       for t, f in paso)

    def k_fase():
        return "".join("%s%%{background-position-x:%s%%}"
                       % (_pc(t, 2 * e.media_ida), _pc(f, n_liana - 1))
                       for t, f in ll)

    # el lado de la cuerda: dos medias idas a cada lado, y la vuelta al espejo
    lados = [(0, -1), (2 * e.media_ida, 1), (e.medio + 0, 1),
             (e.medio + 2 * e.media_ida, -1)]
    k_lado = "".join("%s%%{transform:scaleX(%d)}" % (_pc(t, e.total), s)
                     for t, s in lados)

    return (CABECERA.format(
        logo=ancho_logo, ancho=ancho, alto=e.alto, cielo=CIELO,
        liana_x=e.ancla - liana_w // 2, liana_w=liana_w, liana_h=liana_h,
        img_liana=img_liana, sabana_liana=100 * n_liana,
        img_jug=img_jug, sabana_jug=100 * fotogramas_jug,
        jug_w=ANCHO_JUGADOR, jug_h=ALTO_JUGADOR,
        t_fase=2 * e.media_ida / HZ, t_ciclo=e.total / HZ)
        + "@keyframes va{%s}\n@keyframes paso{%s}\n"
          "@keyframes fase{%s}\n@keyframes lado{%s}\n"
          % (k_va(), k_paso(), k_fase(), k_lado))
