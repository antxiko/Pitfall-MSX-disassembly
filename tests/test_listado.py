#!/usr/bin/env python3
"""Comprobaciones sobre el listado generado.

Ninguna de estas necesita el cartucho: se hacen sobre src/pitfall.asm y
src/pitfall.notes, que van en el repositorio. Lo que vigilan es que el
listado no se degrade sin que nadie se entere -que no vuelvan a aparecer
etiquetas sin nombre, ni bloques de datos sin identificar, ni comentarios que
se queden por el camino-.
"""
import os
import re
import unittest

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASM = os.path.join(RAIZ, "src", "pitfall.asm")
NOTES = os.path.join(RAIZ, "src", "pitfall.notes")


def asm():
    with open(ASM, encoding="utf-8") as f:
        return f.read()


def notas():
    with open(NOTES, encoding="utf-8") as f:
        return f.read().splitlines()


class TestListado(unittest.TestCase):

    def test_ninguna_etiqueta_sin_nombre(self):
        """Una L_XXXX es una etiqueta que nadie ha bautizado todavia."""
        sueltas = sorted(set(re.findall(r"\bL_[0-9A-F]{4}\b", asm())))
        self.assertEqual(sueltas, [], "quedan etiquetas sin nombre: %s"
                         % " ".join(sueltas[:12]))

    def test_ningun_bloque_de_datos_sin_identificar(self):
        """Cada zona de datos tiene que tener nombre y explicacion."""
        n = asm().count("DATOS sin identificar")
        self.assertEqual(n, 0, "hay %d bloques de datos sin identificar" % n)

    def test_ninguna_etiqueta_declarada_dos_veces(self):
        """Una direccion declarada dos veces infla la cuenta de etiquetas.

        Paso: 0x8D70 estaba declarada dos veces con el mismo texto -una de ellas
        arrastrada al principio del fichero por una escritura que se comio la
        cabecera-, asi que la web publicaba 338 etiquetas cuando el listado
        tenia 337. El listado sale igual, y nadie se enteraba.
        """
        vistas, repetidas = set(), []
        for l in notas():
            if not l.startswith("L "):
                continue
            d = l.split()[1]
            if d in vistas:
                repetidas.append(d)
            vistas.add(d)
        self.assertEqual(repetidas, [], "etiquetas declaradas dos veces: %s"
                         % " ".join(repetidas))

    def test_la_cabecera_de_las_notas_esta_entera(self):
        """El fichero empieza por su cabecera de comentarios, no por una linea
        de datos: si empieza por una directiva, algo se ha comido el principio."""
        primera = next((l for l in notas() if l.strip()), "")
        self.assertTrue(primera.startswith("#"),
                        "las notas empiezan por %r y no por la cabecera" % primera[:40])

    def test_ninguna_etiqueta_declarada_con_equ(self):
        """Un `equ` suelto senala una direccion que el listado no ha colocado.

        Cuando aparece, casi siempre es una tabla apuntada un byte antes de
        donde empieza, o codigo al que el trazador no llega. En los dos casos
        hay algo que mirar, asi que no debe pasar desapercibido.
        """
        sueltas = re.findall(r"(?m)^(\w+):\tequ", asm())
        self.assertEqual(sueltas, [], "hay etiquetas sin colocar: %s"
                         % " ".join(sueltas))

    def test_todos_los_comentarios_llegan_al_listado(self):
        """Una C anclada a una direccion que no es inicio de instruccion se cae.

        mkasm no avisa de eso: sencillamente no la emite. Como el comentario
        sigue en el .notes, es facil creer que esta puesto cuando no lo esta.
        """
        cuerpo = asm()
        perdidos = []
        for ln in notas():
            ln = ln.strip()
            if ln.startswith("C "):
                p = ln.split(None, 2)
                if len(p) > 2 and p[2] not in cuerpo:
                    perdidos.append(p[1])
        self.assertEqual(perdidos, [], "comentarios que no salen: %s"
                         % " ".join(perdidos[:12]))

    def test_todas_las_cabeceras_llegan_al_listado(self):
        cuerpo = asm()
        perdidas = []
        for ln in notas():
            ln = ln.rstrip()
            if ln.startswith("B "):
                p = ln.split(None, 2)
                if len(p) > 2 and p[2].strip() and p[2] not in cuerpo:
                    perdidas.append(p[1])
        self.assertEqual(perdidas, [], "cabeceras que no salen: %s"
                         % " ".join(perdidas[:12]))

    def test_el_listado_lo_genera_la_herramienta(self):
        """Si alguien edita el .asm a mano, el siguiente `make` se lo come."""
        self.assertIn("Generado por tools/mkasm.py", asm())


class TestRangosDeDatos(unittest.TestCase):

    def test_los_rangos_no_se_solapan(self):
        """Dos rangos D que se pisen quieren decir que uno de los dos miente."""
        rangos = []
        for ln in notas():
            if ln.startswith("D "):
                p = ln.split(None, 3)
                rangos.append((int(p[1], 0), int(p[2], 0), p[2]))
        rangos.sort()
        for (a1, b1, _), (a2, b2, _) in zip(rangos, rangos[1:]):
            self.assertLessEqual(b1, a2,
                                 "se solapan 0x%04X-0x%04X y 0x%04X-0x%04X"
                                 % (a1, b1, a2, b2))

    def test_todos_los_rangos_van_al_derecho(self):
        for ln in notas():
            if ln.startswith("D "):
                p = ln.split(None, 3)
                a, b = int(p[1], 0), int(p[2], 0)
                self.assertLess(a, b, "rango del reves: %s" % ln)

    def test_todos_los_rangos_estan_explicados(self):
        """Un rango con nombre pero sin descripcion no explica nada."""
        mudos = []
        for ln in notas():
            if ln.startswith("D "):
                p = ln.split(None, 4)
                if len(p) < 5 or not p[4].strip():
                    mudos.append(p[1])
        self.assertEqual(mudos, [], "rangos sin explicacion: %s"
                         % " ".join(mudos))


class TestNadaDeOtroJuego(unittest.TestCase):
    """Que no se cuele material de otro proyecto.

    Las herramientas de este repositorio vienen de un tronco comun, y con ellas
    viajan textos que hablan de OTRO juego: un pie de pagina, un enlace al
    repositorio equivocado, el titulo que se le pone a cada pagina. Eso no lo
    caza ninguna otra comprobacion -la web se genera igual de bien y los
    enlaces internos siguen sin romperse- y acaba publicado.

    Este test barre las fuentes y lo que se publica buscando el nombre de los
    demas juegos y de sus editoras.
    """

    AJENOS = ("temptations", "ale hop", "alehop", "colt 36", "colt36",
              "stardust", "topo soft", "antarctic", "konami")

    def _barre(self, ficheros):
        malos = []
        for ruta in ficheros:
            with open(ruta, encoding="utf-8", errors="ignore") as f:
                texto = f.read().lower()
            for nombre in self.AJENOS:
                if nombre in texto:
                    malos.append("%s: %s" % (os.path.relpath(ruta, RAIZ), nombre))
        return malos

    def _todos(self, carpeta, exts):
        out = []
        for base, _, ficheros in os.walk(os.path.join(RAIZ, carpeta)):
            if ".forja" in base or "__pycache__" in base:
                continue
            out += [os.path.join(base, f) for f in ficheros
                    if f.endswith(exts)]
        return out

    def test_las_herramientas_no_hablan_de_otro_juego(self):
        malos = self._barre(self._todos("tools", (".py", ".sh", ".tcl")))
        self.assertEqual(malos, [], "material de otro proyecto: %s"
                         % "; ".join(malos))

    def test_la_web_no_habla_de_otro_juego(self):
        malos = self._barre(self._todos("docs", (".md", ".html")))
        self.assertEqual(malos, [], "material de otro proyecto: %s"
                         % "; ".join(malos))

    def test_la_raiz_no_habla_de_otro_juego(self):
        raiz = [os.path.join(RAIZ, f) for f in
                ("README.md", "README.es.md", "AVISO-LEGAL.md",
                 "LEGAL-NOTICE.md", "LICENSE", "Makefile")]
        malos = self._barre([r for r in raiz if os.path.exists(r)])
        self.assertEqual(malos, [], "material de otro proyecto: %s"
                         % "; ".join(malos))

    def test_el_listado_no_habla_de_otro_juego(self):
        malos = self._barre([ASM, NOTES,
                             os.path.join(RAIZ, "src", "pitfall.entries"),
                             os.path.join(RAIZ, "src", "pitfall.nocode")])
        self.assertEqual(malos, [], "material de otro proyecto: %s"
                         % "; ".join(malos))


class TestLaWebNoMiente(unittest.TestCase):
    """Que las cifras publicadas sigan siendo las del arbol.

    Este test existe porque ya pasó: la pagina de EMPEZAR publicaba «5679
    lineas» y «119 rangos de datos» cuando el listado tenia 5715 y 130. Nadie lo
    caza -la web se genera igual, los enlaces no se rompen y el reensamblado no
    tiene nada que ver-, y una cifra vieja publicada como hecho es exactamente
    lo que este repositorio dice no hacer.

    Todas las cifras se cuentan sobre src/, sin el cartucho: el reparto de bytes
    tambien, porque los datos son la suma de los rangos declarados y el codigo
    es lo que queda de los 16384.
    """

    CARTUCHO = 16384

    def cifras(self):
        ls = notas()
        datos = sum(int(l.split()[2], 16) - int(l.split()[1], 16)
                    for l in ls if l.startswith("D "))
        return {
            "lineas": len(asm().splitlines()),
            "etiquetas": sum(1 for l in ls if l.startswith("L ")),
            "comentarios": sum(1 for l in ls if l.startswith("C ")),
            "rangos": sum(1 for l in ls if l.startswith("D ")),
            "datos": datos,
            "codigo": self.CARTUCHO - datos,
        }

    # Como se escribe cada cifra en las paginas, en los dos idiomas. El numero
    # va suelto en la prosa o dentro de una fila de tabla, y puede llevar el
    # separador de miles de su idioma (9.467 en castellano, 9,467 en ingles).
    PATRONES = {
        "lineas": r"([\d.,]+)\s+(?:líneas|lines)\b",
        "etiquetas": r"(?:^\|\s*(?:etiquetas bautizadas|named labels)\s*\|\s*([\d.,]+)"
                     r"|([\d.,]+)\s+(?:etiquetas|rutinas y tablas bautizadas"
                     r"|labels|routines and tables named))",
        "comentarios": r"(?:^\|\s*(?:comentarios anclados|anchored comments)\s*\|\s*([\d.,]+)"
                       r"|([\d.,]+)\s+comentarios\b|([\d.,]+)\s+comments\b)",
        "rangos": r"(?:^\|\s*(?:rangos de datos con explicación"
                  r"|data ranges with an explanation)\s*\|\s*([\d.,]+)"
                  r"|([\d.,]+)\s+(?:rangos de datos|ranges of data))",
        "codigo": r"(?:^\|\s*(?:bytes de código|bytes of code)\s*\|\s*([\d.,]+)"
                  r"|([\d.,]+)\s+(?:de código|of code)\b)",
        "datos": r"(?:^\|\s*(?:bytes de datos|bytes of data)\s*\|\s*([\d.,]+)"
                 r"|([\d.,]+)\s+(?:de datos|of data)\b)",
    }

    def paginas(self):
        docs = os.path.join(RAIZ, "docs")
        out = []
        for base, _, ficheros in os.walk(docs):
            if "imagenes" in base:
                continue
            out += [os.path.join(base, f) for f in ficheros if f.endswith(".md")]
        out += [os.path.join(RAIZ, f) for f in ("README.md", "README.es.md")
                if os.path.exists(os.path.join(RAIZ, f))]
        return out

    def test_las_cifras_publicadas_son_las_del_arbol(self):
        esperado = self.cifras()
        malas = []
        for ruta in self.paginas():
            with open(ruta, encoding="utf-8") as f:
                texto = f.read()
            for clave, patron in self.PATRONES.items():
                for m in re.finditer(patron, texto, re.M):
                    visto = next(g for g in m.groups() if g)
                    n = int(visto.replace(".", "").replace(",", ""))
                    if n != esperado[clave]:
                        malas.append("%s: %s dice %s y son %d"
                                     % (os.path.relpath(ruta, RAIZ), clave,
                                        visto, esperado[clave]))
        self.assertEqual(malas, [], "cifras desfasadas: %s" % "; ".join(malas))

    def test_cada_cifra_se_publica_al_menos_una_vez(self):
        """Si un patron deja de encontrar nada, el test de arriba pasa en vacio."""
        trozos = []
        for ruta in self.paginas():
            with open(ruta, encoding="utf-8") as f:
                trozos.append(f.read())
        texto = "\n".join(trozos)
        sin = [c for c, p in self.PATRONES.items()
               if not re.search(p, texto, re.M)]
        self.assertEqual(sin, [], "estas cifras ya no aparecen en la web, asi que"
                                  " nadie las vigila: %s" % ", ".join(sin))


if __name__ == "__main__":
    unittest.main()
