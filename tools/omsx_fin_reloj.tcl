# Que pasa cuando se acaba el reloj de la partida.
#
# El reloj del marcador vive en 0xE1D0-0xE1D4 como TILES ('0' = 0xB8, ':' =
# 0xC2), y arranca en "20:00" (BA B8 C2 B8 B8). Aqui se arranca partida y se le
# escribe "00:02" para llegar al final en dos segundos en vez de en veinte
# minutos, y se capturan los treinta segundos siguientes.

set DIR "C:/Users/Antxiko/Documents/DES_ASM/PITFALL_DISAM/work/omsx"
file mkdir $DIR
file mkdir "$DIR/fin"
set renderer SDLGL-PP

set LOG [open "$DIR/fin.log" w]
proc lg {msg} { global LOG; puts $LOG "[format %7.1f [machine_info time]]  $msg"; flush $LOG }

after time 12 { keymatrixdown 7 0x80 ; lg "RETURN" }
after time 13 { keymatrixup 7 0x80 }

# Un poco de partida de verdad antes de tocar nada.
after time 16 { keymatrixdown 8 0x80 ; lg "derecha" }
after time 19 { keymatrixup 8 0x80 }

after time 34 {
    # "00:02", ya arrancada la partida (E21C pasa a 1 sobre el segundo 23:
    # antes de eso el propio arranque reescribe el reloj a 20:00)
    debug write memory 0xE1D0 0xB8
    debug write memory 0xE1D1 0xB8
    debug write memory 0xE1D2 0xC2
    debug write memory 0xE1D3 0xB8
    debug write memory 0xE1D4 0xBA
    lg "reloj forzado a 00:02"
}

proc estado {} {
    set t ""
    foreach a {0xE1D0 0xE1D1 0xE1D2 0xE1D3 0xE1D4} { append t [format "%02X " [debug read memory $a]] }
    lg [format "reloj=%s E21C=%02X E346=%02X E347=%02X E348=%02X E222=%02X manejador=%02X%02X" \
        $t [debug read memory 0xE21C] [debug read memory 0xE346] [debug read memory 0xE347] \
        [debug read memory 0xE348] [debug read memory 0xE222] \
        [debug read memory 0xE2E8] [debug read memory 0xE2E7]]
    after time 1 estado
}
after time 20 estado

proc foto {n} {
    global DIR
    screenshot [format "%s/fin/fin_%02d.png" $DIR $n]
}
for {set i 0} {$i < 14} {incr i} {
    after time [expr {36 + $i * 2}] [list foto $i]
}

after time 66 {
    set f [open "$DIR/fin.ram.bin" w]
    fconfigure $f -translation binary
    puts -nonewline $f [debug read_block memory 0xE000 0x1000]
    close $f
    lg "fin"
    exit
}
