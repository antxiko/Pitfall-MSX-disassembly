# Carrera rapida hacia el fin de partida de Pitfall!.
#
# Registra cada transicion de modo (0xE225/0xE224/0xE222) y de pantalla
# (0xE1CB) con su instante emulado; prueba ESPACIO a los 10 s (y se VE en el
# log si cambia el modo); quita el acelerador y deja correr mas alla del
# reloj de 20 minutos. Al final, foto con el renderer encendido y volcados.

set DIR "C:/Users/Antxiko/Documents/DES_ASM/PITFALL_DISAM/work/omsx"
file mkdir $DIR
set renderer SDLGL-PP

set LOG [open "$DIR/final.log" w]
proc lg {msg} {
    global LOG
    puts $LOG "[format %8.1f [machine_info time]]  $msg"
    flush $LOG
}

set prev ""
set prevscene -1
proc vigila {} {
    global prev prevscene
    set e5 [debug read memory 0xE225]
    set e4 [debug read memory 0xE224]
    set m  [debug read memory 0xE222]
    set sc [debug read memory 0xE1CB]
    set k [format "modo %d sub %d (E222=%02X)" $e5 $e4 $m]
    if {$k ne $prev} { lg $k ; set prev $k }
    if {$sc != $prevscene} { lg "pantalla $sc" ; set prevscene $sc }
    after time 1 vigila
}
after time 5 vigila

after time 10 { keymatrixdown 7 0x80 ; lg "RETURN abajo" }
after time 12 { keymatrixup 7 0x80 ; lg "RETURN arriba" }

proc volcado {nombre} {
    global DIR
    set f [open "$DIR/$nombre.ram.bin" w]
    fconfigure $f -translation binary
    puts -nonewline $f [debug read_block memory 0xE000 0x1000]
    close $f
    lg "volcado $nombre"
}
after time 60  { volcado t60 }
after time 120 { volcado t120 }

after time 20 { set throttle off ; lg "acelerador quitado" }

# 1650 s emulados > 20 min de reloj + arranque.
after time 1650 {
    set throttle on
    lg "acelerador puesto para la foto"
    after realtime 3 {
        screenshot "$DIR/final.png"
        set f [open "$DIR/final.vram.bin" w]
        fconfigure $f -translation binary
        puts -nonewline $f [debug read_block VRAM 0 0x4000]
        close $f
        set f [open "$DIR/final.ram.bin" w]
        fconfigure $f -translation binary
        puts -nonewline $f [debug read_block memory 0xE000 0x1000]
        close $f
        lg "fin"
        exit
    }
}
