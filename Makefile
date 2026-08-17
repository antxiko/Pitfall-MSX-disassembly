# Pitfall! (Activision, 1984, MSX1) - desensamblado
#
# El orden de las cosas: trazar el flujo -> generar el listado -> comprobar que
# vuelve a dar la ROM byte a byte -> las comprobaciones que el reensamblado NO
# cubre.
#
# La ROM no se distribuye. Hace falta en la raiz como pitfall.rom, y
# `make comprueba` verifica el sha256.

ROM      = pitfall.rom
SHA      = 4d899d6258a8b06dfae8c91a8c57230fa23ff364136d6a243fafeaf282c8be58
SRC      = src
WORK     = work
ORG      = 0x8000
TITULO   = PITFALL! - Activision (1984) - MSX1 - cartucho de 16 KB en la pagina 2

all: listado verify sanity test

$(ROM):
	@echo "=================================================================="
	@echo " Falta $(ROM), y este repositorio NO lo distribuye."
	@echo ""
	@echo " Es Pitfall! (Activision, 1984) para MSX, 16384 bytes exactos."
	@echo " Ponlo aqui con ese nombre. Para comprobar que es el mismo:"
	@echo "     shasum -a 256 $(ROM)"
	@echo "     $(SHA)"
	@echo ""
	@echo " Sin el se puede leer el listado ya generado en $(SRC)/, y los"
	@echo " tests que no dependen del binario siguen pasando."
	@echo "=================================================================="
	@false

comprueba: $(ROM)
	@echo "$(SHA)  $(ROM)" | shasum -a 256 -c -

# El trazado sigue el flujo desde los puntos de entrada. Los que no se pueden
# deducir estaticamente -ganchos de interrupcion, destinos de saltos
# indirectos- estan declarados en el .entries, cada uno con su justificacion.
$(WORK)/pitfall.trace.json: $(ROM) $(SRC)/pitfall.entries $(SRC)/pitfall.nocode
	@mkdir -p $(WORK)
	python3 tools/z80trace.py $(ROM) $(ORG) $(SRC)/pitfall.entries \
	        $(WORK)/pitfall $(SRC)/pitfall.nocode

trace: $(WORK)/pitfall.trace.json

listado: $(WORK)/pitfall.trace.json $(SRC)/pitfall.notes
	python3 tools/mkasm.py $(ROM) $(ORG) $(WORK)/pitfall.trace.json \
	        $(SRC)/pitfall.notes work/msx.sym $(SRC)/pitfall.asm "$(TITULO)"

# La prueba que decide si el desensamblado es fiable.
verify: $(SRC)/pitfall.asm $(ROM)
	@sh tools/verify_build.sh $(SRC)/pitfall.asm $(ROM) $(ORG)

# Lo que el reensamblado NO puede cazar: que unos datos se esten leyendo como
# codigo. El binario sale identico igual, porque los bytes no cambian; lo unico
# que cambia es lo que decimos de ellos.
sanity: $(WORK)/pitfall.trace.json
	@echo "=================================================================="
	@echo " ningun byte declarado como datos puede salir como codigo"
	@echo "=================================================================="
	@python3 tools/check_trace.py $(WORK)/pitfall.trace.json $(SRC)/pitfall.nocode
	@python3 tools/check_datos_como_codigo.py $(WORK) $(SRC)
	@echo "=================================================================="
	@echo " ningun punto de entrada puede caer dentro de una zona de datos"
	@echo "=================================================================="
	@python3 tools/check_entradas.py $(SRC)/pitfall.entries $(SRC)/pitfall.notes \
	        $(SRC)/pitfall.nocode
	@echo "=================================================================="
	@echo " ni un byte del cartucho sin asignar"
	@echo "=================================================================="
	@python3 tools/presupuesto.py $(WORK) $(SRC)

test:
	@echo "=================================================================="
	@echo " Tests"
	@echo "=================================================================="
	@python3 -m unittest discover -s tests -v

clean:
	rm -rf $(WORK)/pitfall.trace.json $(WORK)/pitfall.map $(WORK)/png

.PHONY: all comprueba trace listado verify sanity test clean
