# Juega TU a Pitfall!, y el arnes recoge el mapa solo.
#
#   - Cada vez que cambia la pantalla (el LFSR de 0xE222), espera medio
#     segundo a que se dibuje y CAPTURA a work/omsx/mapa/escena_XX.png,
#     una sola vez por escena.
#   - Guarda replay solo cada minuto en work/omsx/partida_pitfall.omr
#     (leccion aprendida: la primera version de este arnes en otro juego
#     dependia de guardar a mano al salir, y se perdio la sesion entera).
#   - Un rotulo OSD te dice escena, reloj interno y capturas que van.
#
# Arrancar:   openmsx -machine C-BIOS_MSX1_EU -cart pitfall.rom -script tools/omsx_juega_tu.tcl
# Controles:  RETURN/cursores/espacio (el teclado emula al joystick).
# Cerrar la ventana cuando acabes: el replay del ultimo minuto ya esta en disco.

set DIR "C:/Users/Antxiko/Documents/DES_ASM/PITFALL_DISAM/work/omsx"
file mkdir $DIR
file mkdir "$DIR/mapa"
set renderer SDLGL-PP

# Grabar historia desde el principio, y a disco cada minuto.
reverse start
proc salva {} {
    global DIR
    reverse savereplay "$DIR/partida_pitfall.omr"
    after time 60 salva
}
after time 60 salva

set capturadas [dict create]
set ultima -1

osd create text info -x 4 -y 4 -size 14 -rgba 0xffffffff

proc vigila {} {
    global capturadas ultima DIR
    set e [debug read memory 0xE222]
    set mn [debug read memory 0xE25C]
    set sg [debug read memory 0xE25B]
    osd configure info -text [format "escena %02X  reloj %02d:%02d  capturas %d" \
        $e $mn $sg [dict size $capturadas]]
    if {$e != $ultima} {
        set ultima $e
        if {![dict exists $capturadas $e]} {
            dict set capturadas $e 1
            after time 0.5 [list captura $e]
        }
    }
    after time 0.25 vigila
}
proc captura {e} {
    global DIR
    screenshot [format "%s/mapa/escena_%02X.png" $DIR $e]
}
after time 2 vigila
