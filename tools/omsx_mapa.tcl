# EL MAPA: recorrer el mundo solo y capturar cada pantalla.
#
# El mundo de Pitfall! son 255 escenas encadenadas por el LFSR de 0xE222
# (0xB68F avanza, 0xB69F retrocede). Este arnes arranca partida, corre a la
# DERECHA sin parar y salta cada dos segundos -que es lo que hace un jugador-,
# y cada vez que 0xE222 toma un valor NUEVO espera medio segundo a que la
# escena se dibuje y la captura en work/omsx/mapa/escena_XX.png.
#
# La entrada va por la fila 8 del teclado, que es la que lee 0xB26E y remapea
# al formato del joystick: bit 7 = derecha, bit 0 = espacio (saltar).
#
# Nota de por que NO se hace en el atractor: la demo inyecta su propia entrada
# en 0xE05F y pulsar teclas a destiempo la corrompe (tres carreras dieron tres
# comportamientos distintos). Aqui se pulsa RETURN primero, o sea que lo que se
# recorre es una PARTIDA.

set DIR "C:/Users/Antxiko/Documents/DES_ASM/PITFALL_DISAM/work/omsx"
file mkdir $DIR
file mkdir "$DIR/mapa"
set renderer SDLGL-PP

set LOG [open "$DIR/mapa.log" w]
proc lg {msg} { global LOG; puts $LOG "[format %7.1f [machine_info time]]  $msg"; flush $LOG }

set vistas [dict create]
set ultimo -1
set quietud 0

# Arranque de partida: RETURN.
after time 12 { keymatrixdown 7 0x80 ; lg "RETURN" }
after time 13 { keymatrixup 7 0x80 }

# A partir de los 15 s: derecha sostenida.
after time 15 { keymatrixdown 8 0x80 ; lg "derecha sostenida" }

# Saltar cada 2 s (espacio), sin soltar la derecha.
proc salta {} {
    keymatrixdown 8 0x01
    after time 0.25 { keymatrixup 8 0x01 }
    after time 2 salta
}
after time 17 salta

# Sin acelerador desde que empieza la partida: recorrer 255 escenas a velocidad
# real serian horas.
after time 18 { set throttle off ; lg "acelerador quitado" }

# El acelerador va QUITADO para recorrer el mundo en un rato, pero con el
# quitado el renderizador se salta todos los cuadros y la captura sale NEGRA.
# Asi que para cada foto se pone el acelerador, se espera en tiempo REAL a que
# pinte, se dispara, y se vuelve a quitar.
proc captura {e} {
    global DIR
    set ::throttle on
    after realtime 0.4 [list disparo $e]
}
proc disparo {e} {
    global DIR
    screenshot [format "%s/mapa/escena_%02X.png" $DIR $e]
    set ::throttle off
}

proc vigila {} {
    global vistas ultimo quietud
    set e [debug read memory 0xE222]
    if {$e != $ultimo} {
        set ultimo $e
        set quietud 0
        if {![dict exists $vistas $e]} {
            dict set vistas $e 1
            after time 0.6 [list captura $e]
            lg [format "escena %02X  (van %d)" $e [dict size $vistas]]
        }
    } else {
        incr quietud
        # Si lleva 40 vigilancias (20 s) sin cambiar de escena, esta atascado:
        # se suelta y se vuelve a pulsar la derecha, por si murio y hay que
        # reanudar, y se prueba a ir hacia la izquierda un momento.
        if {$quietud == 40} {
            keymatrixup 8 0x80
            keymatrixdown 8 0x10
            lg "atascado: probando izquierda"
        }
        if {$quietud >= 60} {
            keymatrixup 8 0x10
            keymatrixdown 8 0x80
            set quietud 0
            lg "vuelta a la derecha"
        }
    }
    after time 0.5 vigila
}
after time 16 vigila

# Fin: informe de cuantas escenas se han visto.
after time 3000 {
    set f [open "$DIR/mapa_vistas.txt" w]
    puts $f [dict size $vistas]
    foreach e [lsort -integer [dict keys $vistas]] { puts $f [format "%02X" $e] }
    close $f
    lg [format "FIN: %d escenas distintas" [dict size $vistas]]
    exit
}
