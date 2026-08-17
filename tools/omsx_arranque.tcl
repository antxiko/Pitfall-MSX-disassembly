# Arranque de Pitfall! en C-BIOS: captura, volcados y muestreo del PC.
#
# Lecciones aplicadas (memoria medir-en-el-emulador-msx): el renderer arranca
# 'uninitialized' bajo -script y hay que encenderlo; la captura se pide con
# 'after realtime' y el acelerador PUESTO; y las medidas de verdad son las
# lecturas sincronas de VRAM/RAM, no la foto.

set DIR "C:/Users/Antxiko/Documents/DES_ASM/PITFALL_DISAM/work/omsx"
file mkdir $DIR

set renderer SDLGL-PP

# Muestreo del PC cada 0,02 s emulados: barato (dict incr y comparaciones).
set cnt [dict create total 0 b11e 0 b199 0 b2a4 0 b9ab 0 gancho 0]
proc muestra {} {
    global cnt
    set pc [reg PC]
    dict incr cnt total
    if {$pc >= 0xB11E && $pc < 0xB142} { dict incr cnt b11e }
    if {$pc >= 0xB199 && $pc < 0xB1A7} { dict incr cnt b199 }
    if {$pc >= 0xB2A4 && $pc < 0xB2FA} { dict incr cnt b2a4 }
    if {$pc >= 0xB9AB && $pc < 0xB9C8} { dict incr cnt b9ab }
    if {$pc >= 0x80F7 && $pc < 0x8125} { dict incr cnt gancho }
    after time 0.02 muestra
}
after time 1 muestra

proc vuelca {nombre} {
    global DIR
    set f [open "$DIR/$nombre.vram.bin" w]
    fconfigure $f -translation binary
    puts -nonewline $f [debug read_block VRAM 0 0x4000]
    close $f
    set f [open "$DIR/$nombre.ram.bin" w]
    fconfigure $f -translation binary
    puts -nonewline $f [debug read_block memory 0xE000 0x1000]
    close $f
}

# A los 14 s reales: foto del titulo + volcados.
after realtime 14 {
    screenshot "$DIR/arranque.png"
    vuelca arranque
}

# A los 30 s: otra foto (demo o titulo avanzado), volcados, resultados y fuera.
after realtime 30 {
    screenshot "$DIR/demo.png"
    vuelca demo
    set f [open "$DIR/pc_muestras.txt" w]
    puts $f [dict get $cnt total]
    dict for {k v} $cnt { puts $f "$k $v" }
    close $f
    exit
}
