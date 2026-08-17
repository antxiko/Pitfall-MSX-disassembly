# EL MAPA: las 255 escenas, dibujadas por el propio juego.
#
# La idea, despues de comprobar que JUGAR no sirve (25 minutos corriendo a la
# derecha dieron cinco escenas repetidas): el mundo de Pitfall! no esta
# almacenado, lo genera un LFSR en 0xE222. Asi que en vez de recorrerlo se le
# DICTA al juego que escena montar.
#
# Como: 0x9EE6 es el principio de "monta la escena" -de ahi salen el submodo
# (0xE224), el tipo (0xE225 y el despachador de 0xAEB4) y el decorado (0x9F91
# con los bits 6-7)-. Se para la maquina ahi con un breakpoint, se guarda el
# estado, y a partir de ese punto, para cada valor del anillo: restaurar,
# escribir 0xE222, soltar medio segundo para que dibuje, y capturar.
#
# Asi cada PNG lo dibuja el juego con sus propias rutinas: no hay ni un pixel
# reinterpretado por nosotros.

set DIR "C:/Users/Antxiko/Documents/DES_ASM/PITFALL_DISAM/work/omsx"
file mkdir $DIR
file mkdir "$DIR/mapa"
set renderer SDLGL-PP

set LOG [open "$DIR/mapa_lfsr.log" w]
proc lg {msg} { global LOG; puts $LOG "[format %7.1f [machine_info time]]  $msg"; flush $LOG }

# --- El anillo del LFSR, replicando 0xB68F con la semantica exacta del Z80.
proc avanza {v} {
    set a $v ; set c 0
    foreach x {1 1 0 1} {
        set nc [expr {$a >> 7}]
        set a [expr {(($a << 1) | $c) & 0xFF}]
        set c $nc
        if {$x} { set a [expr {$a ^ $v}] }
    }
    set nc [expr {$a >> 7}]
    set a [expr {(($a << 1) | $c) & 0xFF}]
    set c $nc
    set a $v
    set a [expr {(($a << 1) | $c) & 0xFF}]
    return $a
}
set ANILLO {}
set v 0xC4
while {1} {
    lappend ANILLO $v
    set v [avanza $v]
    if {$v == 0xC4} break
}
lg "anillo de [llength $ANILLO] escenas"

# --- Arranque: RETURN para empezar partida.
after time 12 { keymatrixdown 7 0x80 ; lg "RETURN" }
after time 13 { keymatrixup 7 0x80 }

# --- El breakpoint que congela el juego justo antes de montar una escena.
set BASE_HECHO 0
set bp [debug set_bp 0x9EE6 {} {
    global BASE_HECHO bp
    if {$BASE_HECHO} return
    set BASE_HECHO 1
    debug remove_bp $bp
    savestate -f base_escena
    lg "estado base guardado en 0x9EE6"
    after time 0.1 siguiente
}]

set IDX 0
proc siguiente {} {
    global IDX ANILLO DIR
    if {$IDX >= [llength $ANILLO]} {
        lg "FIN: [llength $ANILLO] escenas capturadas"
        exit
    }
    set v [lindex $ANILLO $IDX]
    loadstate base_escena
    debug write memory 0xE222 $v
    # Medio segundo emulado para que la escena se dibuje entera.
    after time 0.5 [list retrata $v]
}
proc retrata {v} {
    global DIR
    set ::throttle on
    after realtime 0.35 [list disparo $v]
}
proc disparo {v} {
    global DIR IDX
    screenshot [format "%s/mapa/escena_%03d_%02X.png" $DIR $IDX $v]
    set ::throttle off
    if {$IDX % 16 == 0} { lg [format "van %d escenas (ultima 0x%02X)" $IDX $v] }
    incr IDX
    siguiente
}

after time 40 { if {!$BASE_HECHO} { lg "NO se llego al breakpoint de 0x9EE6" ; exit } }
