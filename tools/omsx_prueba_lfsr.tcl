# PRUEBA CORTA: ¿basta con escribir 0xE222 para que el juego pinte otra escena?
#
# Si el juego pasa por su rutina de montar escena a menudo, escribir el LFSR y
# esperar deberia bastar, y entonces el mapa se levanta sin breakpoints. Seis
# escenas del anillo, tres segundos cada una: si las capturas salen distintas,
# la via es buena.
#
# (El intento con breakpoint en 0x9EE6 fallo: su callback usaba una variable
# que aun no existia, el bp saltaba sin parar y la emulacion se arrastraba.)

set DIR "C:/Users/Antxiko/Documents/DES_ASM/PITFALL_DISAM/work/omsx"
file mkdir $DIR
file mkdir "$DIR/prueba"
set renderer SDLGL-PP

set LOG [open "$DIR/prueba.log" w]
proc lg {msg} { global LOG; puts $LOG "[format %7.1f [machine_info time]]  $msg"; flush $LOG }

after time 12 { keymatrixdown 7 0x80 ; lg "RETURN" }
after time 13 { keymatrixup 7 0x80 }

set VALORES {0xC4 0x89 0x12 0x25 0x4B 0x97}
set N 0

proc prueba {} {
    global VALORES N DIR
    if {$N >= [llength $VALORES]} { lg "fin de la prueba" ; exit }
    set v [lindex $VALORES $N]
    debug write memory 0xE222 $v
    lg [format "escrito E222=%02X (E224=%02X E225=%02X)" $v \
        [debug read memory 0xE224] [debug read memory 0xE225]]
    after time 2 [list retrata $v]
}
proc retrata {v} {
    global DIR N
    screenshot [format "%s/prueba/p%d_%02X.png" $DIR $N $v]
    lg [format "foto %d: E222 quedo en %02X, E225=%02X" $N \
        [debug read memory 0xE222] [debug read memory 0xE225]]
    incr N
    after time 1 prueba
}
after time 20 prueba
