# EL MAPA: las 255 escenas del mundo, dibujadas por el propio juego.
#
# COMO CAMBIA DE PANTALLA PITFALL!, que es lo unico que hace falta saber
# (medido en 0x9CBE): la X del jugador vive en 0xE2A3 (IY+1 con IY=0xE2A2), y
# cuando vale 0xE7 -el borde derecho- el juego lo reposiciona en 0x19, avanza
# el LFSR de 0xE222 y salta a 0x9EE6, que monta la escena nueva.
#
# Asi que aqui no se juega ni se falsea nada: se le escribe al jugador que ya
# esta en el borde, y el juego cambia de pantalla con SUS rutinas. Escena
# nueva, foto, y otra vez. Escribir 0xE222 a pelo NO sirve -comprobado-, porque
# la escena solo se monta al cruzar el borde.
#
# El bit 0 de 0xE2EB decide si el LFSR avanza UNO o TRES pasos (tres es el
# atajo del subterraneo); aqui se enciende para ir de una en una y recorrer el
# anillo entero en su orden.

set DIR "C:/Users/Antxiko/Documents/DES_ASM/PITFALL_DISAM/work/omsx"
file mkdir $DIR
file mkdir "$DIR/mapa"
set renderer SDLGL-PP

set LOG [open "$DIR/mapa_lfsr.log" w]
proc lg {msg} { global LOG; puts $LOG "[format %7.1f [machine_info time]]  $msg"; flush $LOG }

# El titulo tiene el registro de pantalla a 0x00, que no pertenece al anillo.
# Asi que no se empieza hasta ver una partida de verdad: 0xE21C a 1 y 0xE222
# fuera de cero. Se insiste con RETURN hasta que arranque -una sola pulsacion
# no siempre la coge, segun en que punto este el atractor-.
set INTENTOS 0
proc arranca {} {
    global INTENTOS
    if {[debug read memory 0xE21C] == 1 && [debug read memory 0xE222] != 0} {
        lg [format "partida arrancada (E222=%02X), empieza el recorrido" \
            [debug read memory 0xE222]]
        after time 1 paso
        return
    }
    incr INTENTOS
    if {$INTENTOS > 20} { lg "NO arranca la partida" ; exit }
    keymatrixdown 7 0x80
    after time 0.5 { keymatrixup 7 0x80 }
    after time 3 arranca
}
after time 12 arranca

set N 0
set VISTAS [dict create]

proc paso {} {
    global N DIR VISTAS
    if {$N >= 258} {
        lg [format "FIN: %d escenas distintas capturadas" [dict size $VISTAS]]
        set f [open "$DIR/mapa_orden.txt" w]
        foreach e [dict keys $VISTAS] { puts $f $e }
        close $f
        exit
    }
    # Un paso del LFSR por cambio de pantalla, no tres.
    set e2eb [debug read memory 0xE2EB]
    debug write memory 0xE2EB [expr {$e2eb | 1}]
    # Y el jugador, ya en el borde derecho: el juego hara lo demas.
    debug write memory 0xE2A3 0xE7
    after time 0.45 retrata
}

proc retrata {} {
    global N DIR VISTAS
    set v [debug read memory 0xE222]
    set clave [format "%02X" $v]
    if {![dict exists $VISTAS $clave]} {
        dict set VISTAS $clave $N
        screenshot [format "%s/mapa/escena_%03d_%02X.png" $DIR $N $v]
    }
    if {$N % 25 == 0} {
        lg [format "paso %3d: E222=%02X  decorado=%d tipo=%d variante=%d  (%d distintas)" \
            $N $v [expr {($v >> 6) & 3}] [expr {($v >> 3) & 7}] [expr {$v & 7}] \
            [dict size $VISTAS]]
    }
    incr N
    after time 0.15 paso
}

