# El reloj de Pitfall! y el arranque por tecla, medidos sin suponer nada.
set DIR "C:/Users/Antxiko/Documents/DES_ASM/PITFALL_DISAM/work/omsx"
file mkdir $DIR
set renderer SDLGL-PP
set LOG [open "$DIR/reloj.log" w]
proc lg {msg} { global LOG; puts $LOG "[format %7.1f [machine_info time]]  $msg"; flush $LOG }

set prev ""
proc vigila {} {
    global prev
    set e5  [debug read memory 0xE225]
    set e4  [debug read memory 0xE224]
    set in1 [debug read memory 0xE05F]
    set ra  [debug read memory 0xE25A]
    set rb  [debug read memory 0xE25B]
    set rc  [debug read memory 0xE25C]
    set sc  [debug read memory 0xE1CB]
    set k [format "m%d s%d in=%02X reloj=%02X/%02X/%02X pant=%d" $e5 $e4 $in1 $ra $rb $rc $sc]
    if {$k ne $prev} { lg $k ; set prev $k }
    after time 1 vigila
}
after time 5 vigila

after time 15 { keymatrixdown 8 0x01 ; lg "ESPACIO abajo" }
after time 18 { keymatrixup 8 0x01 ; lg "ESPACIO arriba" }
after time 22 { keymatrixdown 7 0x80 ; lg "RETURN abajo" }
after time 25 { keymatrixup 7 0x80 ; lg "RETURN arriba" }
after time 30 { type "\r" ; lg "type RETURN" }
after time 35 { set throttle off ; lg "acelerador quitado" }

after time 1700 {
    set throttle on
    after realtime 3 {
        screenshot "$DIR/reloj_final.png"
        set f [open "$DIR/reloj_final.ram.bin" w]
        fconfigure $f -translation binary
        puts -nonewline $f [debug read_block memory 0xE000 0x1000]
        close $f
        lg "fin"
        exit
    }
}
