#!/usr/bin/env python3
"""Reproduce el trazador de la liana del cartucho y saca sus fotogramas.

    python3 tools/render_liana.py pitfall.rom docs/imagenes/liana.png [escala]

En el cartucho NO hay ningun dibujo de liana: en cada paso se traza una recta de
16 puntos sobre un mapa de bits de 0x40 bytes en la RAM (0xE18A) y se manda a la
VRAM como patron de sprite. Aqui se hace lo mismo leyendo los mismos datos, que
es la segunda via que confirma la lectura: si el trazador esta bien entendido,
sale una cuerda, y sale con la misma inclinacion que la de las capturas.

LO QUE HACE 0xA471, instruccion por instruccion:
  - la fase del balanceo esta en 0xE1CB y va y viene entre 1 y 0x20 (0xA5EF);
  - cada fase son cuatro bytes de la tabla de 0xA61A, indexada por fase*4;
  - el PRIMER byte es la pendiente, en 1/256 de pixel por fila: DE = pendiente,
    y si la liana cae al otro lado se le da la vuelta con complemento a dos
    (0xA4A1-0xA4A7);
  - HL es un acumulador de 16 bits del que H es la columna: se pone a 0, se le
    suma DE, y en cada una de las 16 filas se pinta el punto (H y 0x0F, fila) y
    se vuelve a sumar DE (0xA4C4-0xA4D9);
  - ese patron de 16x16 se usa para los TRES sprites de la cuerda, colocados en
    X = base + k*H y en Y = 0x33 + k*0x10 (0xA4B5, 0xA4E8, 0xA511), o sea que la
    recta se continua sola de un sprite al siguiente;
  - y el punto de agarre -donde cuelga el jugador- sale de sumar la pendiente
    B veces mas, siendo B el TERCER byte del registro (0xA527-0xA530).

EL SEGUNDO BYTE DEL REGISTRO ES EL PERIODO DEL OBJETO (0xA48F-0xA494 lo escribe
en +0x10 de 0xE32F). Y no es constante: vale 1 cerca de la vertical y 9 en el
extremo, o sea que el balanceo FRENA en los extremos y corre por el centro, como
un pendulo. Eso no se ve en la tabla de un vistazo, pero esta en el segundo byte.

El color de la cuerda es el 1 -negro-, que es lo que 0xA4C0 escribe en el byte de
atributo del primer sprite. Por eso se ve sobre el cielo cian y no se veria sobre
un fondo negro.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from monta_mapa import escribe_png                                   # noqa: E402

ORG = 0x8000
TABLA = 0xA61A
FASES = 33                      # 0x00 a 0x20; el balanceo usa de 1 a 0x20
FILAS_POR_SPRITE = 16
SPRITES = 3                     # 0xE276, 0xE27A y 0xE27E
NEGRO = (0, 0, 0)               # color 1 del TMS9918, el de la cuerda
CIELO = (66, 235, 245)          # color 7: el cielo sobre el que se ve


def registros(rom):
    """Los 33 registros de cuatro bytes: pendiente, periodo, agarre y un cuarto."""
    o = TABLA - ORG
    return [tuple(rom[o + i * 4:o + i * 4 + 4]) for i in range(FASES)]


def patron_de_la_cuerda(pendiente, derecha=True):
    """Los 16 puntos del patron, y cuanto avanza la columna en esas 16 filas.

    Se hace con el mismo acumulador de 16 bits que el cartucho: H es la columna y
    L la parte fraccionaria, y de H solo se miran los cuatro bits bajos, que es
    lo que cabe en un sprite de 16 de ancho.
    """
    de = pendiente if derecha else -pendiente
    hl = 0
    puntos = []
    for fila in range(FILAS_POR_SPRITE):
        hl = (hl + de) & 0xFFFF
        h = (hl >> 8) & 0x0F                       # el `and 00fh` de 0xA4D1
        hl = (h << 8) | (hl & 0xFF)                # ...y se vuelve a guardar en H
        puntos.append((h, fila))
    return puntos, (hl >> 8) & 0x0F


def cuerda_entera(pendiente, derecha=True):
    """La cuerda de los tres sprites: el mismo patron repetido y desplazado."""
    puntos, avance = patron_de_la_cuerda(pendiente, derecha)
    fuera = []
    for k in range(SPRITES):
        dx = k * avance if derecha else -k * avance
        for x, y in puntos:
            fuera.append((x + dx, y + k * FILAS_POR_SPRITE))
    return fuera


def punto_de_agarre(pendiente, agarre, derecha=True):
    """Donde cuelga el jugador: la pendiente sumada `agarre` veces mas."""
    de = pendiente if derecha else -pendiente
    hl = (SPRITES * FILAS_POR_SPRITE) * de          # el final de la cuerda
    hl += agarre * de
    return (hl >> 8), SPRITES * FILAS_POR_SPRITE + agarre


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        return 1
    rom = open(sys.argv[1], "rb").read()
    salida = sys.argv[2]
    escala = int(sys.argv[3]) if len(sys.argv) > 3 else 1

    regs = registros(rom)
    alto = SPRITES * FILAS_POR_SPRITE
    # ancho de un fotograma: lo que la cuerda mas inclinada se va de lado, con
    # sitio a los dos lados para que valga el mismo lienzo en las dos direcciones
    maxdx = max(abs(x) for p, _ in [(cuerda_entera(r[0]), 0) for r in regs] for x, _ in p)
    ancho = 2 * maxdx + 2
    centro = maxdx

    lienzo = [[None] * (ancho * FASES) for _ in range(alto)]
    for i, r in enumerate(regs):
        for x, y in cuerda_entera(r[0]):
            lienzo[y][i * ancho + centro + x] = NEGRO

    filas = []
    for y in range(alto):
        fila = bytearray()
        for c in lienzo[y]:
            fila += (b"\0\0\0\0" if c is None else bytes(c) + b"\xff") * escala
        for _ in range(escala):
            filas.append(bytes(fila))
    escribe_png(salida, ancho * FASES * escala, alto * escala, filas, alfa=True)

    print("%s: %d fotogramas de %dx%d (%dx%d)"
          % (salida, FASES, ancho, alto, ancho * FASES * escala, alto * escala))
    print("  pendiente de la fase 0x20 (la mas tumbada): 0x%02X = %.3f px por fila"
          % (regs[0x20][0], regs[0x20][0] / 256))
    ida = sum(r[1] for r in regs[1:])
    print("  periodo por fase: de %d en el centro a %d en el extremo"
          % (regs[1][1], regs[0x20][1]))
    print("  media ida (fases 1 a 0x20): %d cuadros; ida y vuelta: %d"
          % (ida, 2 * ida))
    for f in (1, 0x10, 0x20):
        x, y = punto_de_agarre(regs[f][0], regs[f][2])
        print("  agarre en la fase 0x%02X: %+d px de lado, fila %d" % (f, x, y))
    return 0


if __name__ == "__main__":
    sys.exit(main())
