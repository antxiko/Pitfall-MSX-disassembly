# El tick del reloj de partida, medido de verdad y con su control al lado.
#
# La medida anterior (omsx_reloj.tcl) tenia dos fallos que la invalidan:
# vigilaba 0xE25A/B/C, que NO son el reloj del marcador (el marcador vive en
# 0xE1D0-0xE1D4 con su contador de cuadros en 0xE1D5), y pulsaba ESPACIO y
# RETURN cuando el juego arranca con una DIRECCION (0x8128 mira los bits 0-3
# de 0xE05F): nunca salio del titulo. De ahi salieron los "~9 s por tick".
#
# Aqui se mide lo que dice el listado, en partida de verdad:
#   - bp en 0x9DC7, que es el `ld (hl),03ch` que SOLO se ejecuta cuando
#     0xE1D5 llega a cero: cada pasada es UN tick, con su tiempo emulado.
#   - bp de control en 0x80F7, el gancho de interrupcion del juego: cuenta
#     interrupciones, que es el reloj de la maquina. Si el control no corre,
#     la medida no vale (leccion de la serie: un cero sin control no es dato).
#
#   openmsx -machine C-BIOS_MSX1_EU -cart pitfall.rom -script tools/omsx_mide_tick.tcl
set DIR "C:/Users/Antxiko/Documents/DES_ASM/PITFALL_DISAM/work/omsx"
file mkdir $DIR
set renderer SDLGL-PP
set LOG [open "$DIR/tick.log" w]
proc lg {msg} { global LOG; puts $LOG "[format %8.3f [machine_info time]] $msg"; flush $LOG }

set ints 0
debug set_bp 0x80F7 {} { incr ::ints }

set ticks 0
set int_tick_previo 0
debug set_bp 0x9DC7 {} {
    incr ::ticks
    set reloj ""
    foreach a {0xE1D0 0xE1D1 0xE1D2 0xE1D3 0xE1D4} {
        append reloj [format %02X [debug read memory $a]]
    }
    set demo [debug read memory 0xE221]
    set pant [debug read memory 0xE222]
    set objs [debug read memory 0xE247]
    set x    [debug read memory 0xE2A3]
    lg "tick $::ticks ints=$::ints (+[expr {$::ints - $::int_tick_previo}]) tiles=$reloj demo=$demo pant=[format %02X $pant] objs=$objs x=$x"
    set ::int_tick_previo $::ints
}

# DERECHA un segundo, tres veces: si la primera cae en mal momento (demo,
# transicion), alguna de las otras arranca la partida.
foreach t {12 30 48} {
    after time $t       { keymatrixdown 8 0x80 ; lg "DERECHA abajo" }
    after time [expr {$t+1}] { keymatrixup 8 0x80 ; lg "DERECHA arriba" }
}
after time 14 { set throttle off ; lg "acelerador quitado" }

after time 95 {
    set throttle on
    after realtime 3 {
        screenshot "$DIR/tick_final.png"
        lg "fin ints=$::ints ticks=$::ticks"
        exit
    }
}
