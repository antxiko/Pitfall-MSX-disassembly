; ==========================================================================
; PITFALL! - Activision (1984) - MSX1 - cartucho de 16 KB en la pagina 2
; ==========================================================================
; Generado por tools/mkasm.py a partir del trazado de flujo real.
; Los comentarios provienen de tools/../src/*.notes y estan anclados a
; direccion, de modo que sobreviven a un retrazado.
; ==========================================================================

	org 0x08000


; ----------------------------------------------------------------------
; DATOS cabecera_del_cartucho: La cabecera que lee la BIOS: "AB", INIT=0x8013,
;   y a cero los otros tres vectores (STATEMENT, DEVICE y TEXT). Con eso la
;   BIOS llama a 0x8013 nada mas terminar de arrancar la maquina
;   0x8000..0x8010  (16 bytes)
DATA_cabecera_del_cartucho:
	defb 041h,042h	; 8000
	defw 08013h,00000h,00000h,00000h	; 8002  -> INIT 0x0000 0x0000 0x0000
	defb 000h,000h,000h,000h,000h,000h	; 800a

; ----------------------------------------------------------------------
; DATOS plantilla_del_gancho: Los tres bytes C3 F7 80 -un `jp 0x80F7` ya
;   montado- que INIT copia tal cual al gancho H.KEYI (0xFD9A) con el LDIR de
;   0x803C-0x8046. Aqui dentro no se ejecutan nunca: se ejecutan en la RAM del
;   gancho, en cada interrupcion
;   0x8010..0x8013  (3 bytes)
DATA_plantilla_del_gancho:
	defb 0c3h,0f7h,080h	; 8010

; ======================================================================
; CODIGO 0x8013..0x8a69  (2646 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; Borra 0xE000-0xEFFF, engancha 0x80F7 en H.KEYI y cae
; en 0x8065. El bucle de 0x80F5 no hace nada mas: el
; juego entero corre dentro de la interrupcion
; ----------------------------------------------------------------------
INIT:
	di			;8013
	ld hl,0e000h		;8014
	ld bc,01000h		;8017   ; 0x1000 bytes: 0xE000-0xEFFF entero
borra_la_ram_bucle:
	ld (hl),000h		;801a
	inc hl			;801c
	dec bc			;801d
	ld a,b			;801e
	or c			;801f
	jp nz,borra_la_ram_bucle		;8020
	ld sp,0e54bh		;8023   ; la pila, justo debajo del estado del juego
	call reinicia_el_sonido		;8026
	ld a,0f0h		;8029
	out (0aah),a		;802b   ; PPI puerto C: fila 0 del teclado, motor y click apagados
	call borra_la_vram		;802d
	ld bc,08001h		;8030   ; registro 1 del VDP a 0x80: pantalla apagada
	call escribe_registro_vdp		;8033   ; B es el valor y C el registro
	ld bc,01107h		;8036   ; registro 7: el color del borde
	call escribe_registro_vdp		;8039
	ld hl,08010h		;803c   ; los tres bytes de 0x8010 al gancho H.KEYI
	ld de,0fd9ah		;803f
	ld bc,00003h		;8042
	ldir		;8045
	ld bc,0e201h		;8047   ; registro 1 a 0xE2: pantalla encendida e interrupcion de cuadro
	call escribe_registro_vdp		;804a
	xor a			;804d
	ld (0e269h),a		;804e
	call reinicia_el_sonido		;8051
	ld a,00dh		;8054
	ld (0e1e5h),a		;8056
	ld (0e1e3h),a		;8059
	call secuencia_de_presentacion		;805c   ; la presentacion; al volver, 0x805F borra los 16 KB de VRAM
	call borra_la_vram		;805f
	call carga_los_sprites		;8062

; ----------------------------------------------------------------------
; Cada partida empieza aqui, tambien la segunda: 0x9C91
; salta a esta direccion al pulsar RETURN en el final
; ----------------------------------------------------------------------
arranca_la_partida:
	ld sp,0e54bh		;8065   ; la pila se recoloca en cada partida: el final salta aqui sin haberla vaciado
	xor a			;8068
	ld (0e267h),a		;8069
	ld (0e269h),a		;806c
	call reinicia_el_sonido		;806f   ; los vectores de sonido al RET vacio y el PSG callado
	call prepara_la_partida		;8072
	ld a,0c4h		;8075   ; la semilla del registro de pantalla: la primera escena
	ld (0e222h),a		;8077
	call coloca_al_jugador		;807a   ; el jugador, 0xE2D5, es el primero de la lista de objetos
	ld de,0e32fh		;807d   ; y 0xE32F, el de la liana, el segundo
	call anade_objeto		;8080
	ld a,001h		;8083
	ld (0e132h),a		;8085
	ld (0e133h),a		;8088
	ld de,0e2bfh		;808b   ; 0xE2BF es el tercero: el comodin que cada escena reprograma
	ld hl,0b02ah		;808e   ; la plantilla de objeto de 0xB02A a 0xE2BF
	ld bc,00016h		;8091
	ldir		;8094
	ld de,0e2bfh		;8096
	call anade_objeto		;8099
	call pinta_el_subsuelo		;809c
	call monta_la_escena		;809f   ; monta la escena y la pinta
	ld a,003h		;80a2
	ld ix,0e346h		;80a4
	ld (ix+000h),a		;80a8
	ld (ix+001h),a		;80ab
	ld hl,0e345h		;80ae
	ld (hl),001h		;80b1
	ld a,00dh		;80b3
	ld (0e1e5h),a		;80b5   ; 0xE1E5 = 13: el sonido de los pasos se repite cada trece cuadros
	ld (0e1e3h),a		;80b8
	ld a,001h		;80bb
	ld (0e21ch),a		;80bd   ; 0xE21C = 1: el reloj de partida (0x9DB8) no cuenta hasta que 0x8140 lo pone a cero
	ld a,001h		;80c0
	ld (0e132h),a		;80c2
	ld (0e133h),a		;80c5
	ld de,0e2aeh		;80c8   ; cuatro entradas de la tabla de sprites en RAM, de la 17 a la 20
	ld hl,08a90h		;80cb
	ld bc,00004h		;80ce
	ldir		;80d1
	ld de,0e2b2h		;80d3
	ld hl,08a94h		;80d6
	ld bc,00004h		;80d9
	ldir		;80dc
	ld de,0e2b6h		;80de
	ld hl,08a98h		;80e1
	ld bc,00004h		;80e4
	ldir		;80e7
	ld de,0e2bah		;80e9
	ld hl,08a9ch		;80ec
	ld bc,00004h		;80ef
	ldir		;80f2
	ei			;80f4
espera_a_la_interrupcion:
	jr espera_a_la_interrupcion		;80f5   ; se queda aqui para siempre: todo pasa en el gancho

; ----------------------------------------------------------------------
; ############################################################
; EL BUCLE PRINCIPAL, que corre dentro de la interrupcion
; ############################################################
; El juego entero cabe en el gancho H.KEYI: la BIOS llama aqui
; cincuenta o sesenta veces por segundo, y cada pasada es un
; cuadro. El orden es siempre el mismo:
; B249  los dos joysticks, por el PSG
; B26E  la fila 8 del teclado, remapeada a formato joystick
; B35B  la cadena de vectores de sonido
; 9A6F  el cuadro: pantalla y objetos
; y por ultimo los 0x54 bytes de 0xE26A a la VRAM 0x1B00,
; que es la tabla de atributos de sprites de un golpe
; ----------------------------------------------------------------------
bucle_principal:
	call lee_joysticks		;80f7   ; los dos mandos, por el PSG
	call lee_teclado_como_joystick		;80fa   ; la fila 8 del teclado, mezclada encima de lo leido
	call atiende_el_sonido		;80fd   ; los tres vectores de sonido, y de ahi al PSG
	call cuadro_del_juego		;8100   ; el cuadro entero: escena, objetos y jugador
	ld hl,0e26ah		;8103   ; los 0x54 bytes de atributos de sprite, de un golpe
	ld de,01b00h		;8106
	ld bc,00054h		;8109
	call copia_bloque_a_vram		;810c
	pop hl			;810f   ; el primer pop se come la direccion de retorno al gancho: de aqui en adelante la interrupcion se cierra a mano
	pop ix		;8110
	pop iy		;8112
	pop af			;8114
	pop bc			;8115
	pop de			;8116
	pop hl			;8117
	ex af,af'			;8118
	exx			;8119
	in a,(099h)		;811a   ; lee el estado del VDP: asi se reconoce la interrupcion
	ld (0e036h),a		;811c   ; 0xE036 no lo lee nadie en todo el cartucho: lo que cuenta es el propio in
	pop af			;811f
	pop bc			;8120
	pop de			;8121
	pop hl			;8122
	ei			;8123   ; el ei y el ret de aqui son el final de la interrupcion
	ret			;8124
espera_a_que_arranques:		; Manejador de salida: la animacion corre hasta que se pulsa una direccion
	call anima_el_final		;8125
	ld a,(0e05fh)		;8128   ; bits 0-3 de 0xE05F: las cuatro direcciones
	and 00fh		;812b
	ret z			;812d
	ld ix,0e2d5h		;812e
	ld hl,jugador		;8132   ; a partir de aqui manda el manejador normal
	ld (ix+012h),l		;8135
	ld (ix+013h),h		;8138
	ld (ix+011h),001h		;813b
	xor a			;813f
	ld (0e21ch),a		;8140   ; 0xE21C a cero: el cuadro ya corre entero
	ld (0e34ah),a		;8143
	ld iy,0e346h		;8146
	ld (iy+002h),009h		;814a
	ld (iy+000h),001h		;814e
	call anima_el_final		;8152
	ld ix,0e2d5h		;8155
	ld (ix+011h),001h		;8159
	ld (ix+010h),001h		;815d
	ret			;8161
agarra_la_liana:		; Clase 5
	ld a,007h		;8162
	call arranca_un_sonido		;8164
	ld hl,columpia_en_la_liana		;8167
	ld (ix+012h),l		;816a
	ld (ix+013h),h		;816d
	res 5,(ix+000h)		;8170
	res 0,(ix+000h)		;8174
	res 0,(ix+006h)		;8178
	set 7,(ix+016h)		;817c
	ld iy,0e2a2h		;8180
	ld a,(0e1cdh)		;8184   ; 0xE1CC y 0xE1CD, donde esta la liana ahora mismo: la X del jugador se pone diez pixeles a la izquierda del punto de agarre y la Y en la fila de ese punto mas 0x5C
	sub 00ah		;8187
	ld (iy+001h),a		;8189
	ld a,(0e1cch)		;818c
	add a,05ch		;818f
	ld (iy+000h),a		;8191
	bit 7,(ix+006h)		;8194
	jr z,agarra_la_liana_derecha		;8198
	ld (iy+002h),064h		;819a   ; colgado tiene DIBUJO PROPIO, no se queda con el fotograma que llevaba: patron 0x64 mirando a la izquierda y 0x40 a la derecha (con sus dos capas de color, 0xAC/0xF4 y 0x88/0xD0), y el 0x64 es el espejo del 0x40 que fabrica el arranque
	ret			;819e
agarra_la_liana_derecha:
	ld (iy+002h),040h		;819f
	ret			;81a3
columpia_en_la_liana:
	ld a,(0e05fh)		;81a4   ; 0xE05F es la entrada del mando 1, la que mira todo el juego
	bit 1,a		;81a7   ; sin el bit 1 (abajo) no se suelta
	ret z			;81a9
	ld iy,0e2a2h		;81aa   ; 0xE2A2, los cuatro bytes de sprite del jugador
	bit 3,a		;81ae
	jr nz,columpia_hacia_la_derecha		;81b0   ; con abajo y ademas derecha (bit 3) o izquierda (bit 2), el lado lo elige quien juega
	bit 2,a		;81b2
	jr nz,columpia_hacia_la_izquierda		;81b4
	ld hl,0e345h		;81b6
	bit 7,(hl)		;81b9   ; y con abajo a secas manda el bit 7 de 0xE345, que es el IX+0x16 de la liana: se salta hacia donde iba el balanceo
	jr nz,columpia_hacia_la_izquierda		;81bb
columpia_hacia_la_derecha:
	ld de,000c8h		;81bd   ; velocidad hacia la derecha, en 1/256 de pixel por cuadro
	res 7,(ix+006h)		;81c0
	ld (iy+002h),038h		;81c4   ; y al empezar a columpiarse vuelve al patron del aire: 0x38 a la derecha, 0x5C a la izquierda
	jr columpia_arranca		;81c8
columpia_hacia_la_izquierda:
	ld de,0ff38h		;81ca
	set 7,(ix+006h)		;81cd
	ld (iy+002h),05ch		;81d1
columpia_arranca:
	ld (ix+008h),d		;81d5   ; la velocidad elegida arriba, ya en IX+0x07/08
	ld (ix+007h),e		;81d8
	dec (iy+000h)		;81db   ; un pixel arriba para despegarse
	ld hl,suelta_la_liana		;81de   ; y de aqui en adelante manda 0x81F9, o sea que al cuadro siguiente ya se ha soltado
	ld (ix+012h),l		;81e1
	ld (ix+013h),h		;81e4
	res 7,(ix+016h)		;81e7
	set 0,(ix+000h)		;81eb
	set 0,(ix+006h)		;81ef
	ld a,009h		;81f3   ; sonido 9, el del columpio
	call arranca_un_sonido		;81f5
	ret			;81f8
suelta_la_liana:		; Cae al vacio con el manejador del aire
	set 6,(ix+016h)		;81f9   ; bit 6 de IX+0x16: el boton que ya venia pulsado no cuenta como salto nuevo
	ld hl,en_el_aire		;81fd
	ld (ix+012h),l		;8200
	ld (ix+013h),h		;8203
	res 5,(ix+000h)		;8206   ; se apagan la animacion y el "movil" del eje Y
	res 0,(ix+000h)		;820a
	set 0,(ix+006h)		;820e   ; en X si se mueve, y 0x8212 apaga el bit 6 de IX+0x06: cayendo de la liana no se miran las cajas del aire
	res 6,(ix+006h)		;8212
	ld (ix+010h),001h		;8216
	ld a,(0e1e2h)		;821a   ; el paso de la curva sale de 0xE1E2, el cuarto byte de la fase: soltandose solo se cae, nunca se sube
	ld (ix+017h),a		;821d
	ret			;8220

; ----------------------------------------------------------------------
; Morir no repinta la escena: se esconde todo lo demas,
; el jugador se dibuja por trozos hasta reaparecer
; entero y cae al suelo. 0xE189 guarda cuantos objetos
; habia para devolverlos al final
; ----------------------------------------------------------------------
muere:		; Clases 6 y 9
	ld a,006h		;8221   ; sonido 6, el de perder una vida
	call arranca_un_sonido		;8223
	call quita_una_vida		;8226
	ld (ix+011h),05ah		;8229   ; la cuenta a 0x5A: el manejador no vuelve a correr hasta noventa cuadros despues
	ld hl,0e247h		;822d   ; guarda cuantos objetos habia y deja uno: nada mas se mueve
	ld a,(hl)			;8230
	ld (0e189h),a		;8231
	ld (hl),001h		;8234
	ld hl,muere_repinta_vidas		;8236   ; el manejador pasa a 0x8240, que repinta las vidas y arranca la reaparicion
	ld (ix+012h),l		;8239
	ld (ix+013h),h		;823c
	ret			;823f
muere_repinta_vidas:
	call pinta_las_vidas		;8240
reaparece:
	ld ix,0e2d5h		;8243
	ld hl,0e2a5h		;8247
	ld (hl),000h		;824a
	ld hl,0e2a9h		;824c
	ld (hl),000h		;824f
	ld hl,0e2adh		;8251
	ld (hl),000h		;8254
	set 0,(ix+000h)		;8256
	res 0,(ix+006h)		;825a
	res 5,(ix+000h)		;825e
	res 7,(ix+006h)		;8262
	ld iy,0e2a2h		;8266
	ld (iy+001h),020h		;826a   ; X = 0x20: reaparece pegado al borde izquierdo
	ld a,01bh		;826e
	ld (0e184h),a		;8270
	xor a			;8273
	ld (0e185h),a		;8274
	ld hl,reaparece_cuenta		;8277
	ld (ix+012h),l		;827a
	ld (ix+013h),h		;827d
	bit 0,(ix+016h)		;8280   ; bit 0 de IX+0x16: 1 en la superficie, 0 en el subterraneo
	jr nz,reaparece_arriba		;8284
	ld hl,0e293h		;8286
	ld (hl),08ah		;8289
	ld (iy+000h),085h		;828b
	ld a,0a4h		;828f
	ld (0e1cfh),a		;8291   ; 0xE1CF es la Y del suelo: 0xA4 abajo, 0x6C arriba
	ret			;8294
reaparece_arriba:
	ld (iy+000h),040h		;8295
	ld a,06ch		;8299
	ld (0e1cfh),a		;829b
	ret			;829e
reaparece_cae:
	set 0,(ix+000h)		;829f   ; bit 0 de IX+0x00: vuelve a moverse
	res 0,(ix+006h)		;82a3
	set 6,(ix+016h)		;82a7   ; bit 6 de IX+0x16, que solo mira 0x87E9: con el boton todavia pulsado no se encadena otro salto
	ld iy,0e2a2h		;82ab
	inc (iy+000h)		;82af   ; un pixel abajo, y el resto de la caida lo lleva 0x8314
	ld a,01bh		;82b2
	ld (0e184h),a		;82b4
	xor a			;82b7
	ld (0e185h),a		;82b8
	ld hl,cae_hasta_el_suelo		;82bb
	ld (ix+012h),l		;82be
	ld (ix+013h),h		;82c1
	ret			;82c4
reaparece_cuenta:
	ld iy,0e2a2h		;82c5
	ld hl,0e184h		;82c9
	dec (hl)			;82cc   ; 0xE184 baja de 0x1B a 0 mientras el jugador se dibuja
	jr z,reaparece_termina		;82cd
	ld a,006h		;82cf
	cp (hl)			;82d1
	jr nz,reaparece_cuenta_sigue		;82d2
	ld hl,0e2adh		;82d4
	ld (hl),00fh		;82d7
reaparece_cuenta_sigue:
	call patron_reapareciendo		;82d9
	ld hl,0e2a5h		;82dc   ; 0xE2A5 y 0xE2A9 son los colores de los dos sprites del jugador
	ld (hl),00ch		;82df
	ld hl,0e2a9h		;82e1
	ld (hl),006h		;82e4
	ret			;82e6
reaparece_termina:
	ld a,(0e189h)		;82e7   ; devuelve los objetos que se habian escondido
	ld hl,0e247h		;82ea
	ld (hl),a			;82ed
	ld hl,reaparece_cae		;82ee   ; y a partir de aqui manda 0x829F, que arranca la caida
	ld (ix+012h),l		;82f1
	ld (ix+013h),h		;82f4
	res 0,(ix+000h)		;82f7
	ld hl,099efh		;82fb   ; los dos patrones enteros vuelven a la VRAM: se acabo el dibujo por trozos
	ld de,03be0h		;82fe
	ld bc,00020h		;8301
	call copia_bloque_a_vram		;8304
	ld hl,099afh		;8307
	ld de,039a0h		;830a
	ld bc,00020h		;830d
	call copia_bloque_a_vram		;8310
	ret			;8313
cae_hasta_el_suelo:
	ld iy,0e2a2h		;8314
	ld a,(0e1cfh)		;8318
	cp (iy+000h)		;831b   ; cae hasta llegar a la Y del suelo
	ret nc			;831e
	ld (ix+010h),001h		;831f   ; periodo 1: de aqui en adelante el jugador corre en cada cuadro
	ld hl,jugador		;8323
	ld (ix+012h),l		;8326
	ld (ix+013h),h		;8329
	res 0,(ix+000h)		;832c
	ld hl,08ec0h		;8330   ; y los cuatro trozos de mirar a la izquierda, otra vez sin morder
	ld de,03d00h		;8333
	ld bc,00010h		;8336
	call copia_bloque_a_vram		;8339
	ld hl,08ed0h		;833c
	ld de,03ac0h		;833f
	ld bc,00010h		;8342
	call copia_bloque_a_vram		;8345
	ld hl,08ee0h		;8348
	ld de,03d10h		;834b
	ld bc,00010h		;834e
	call copia_bloque_a_vram		;8351
	ld hl,08ef0h		;8354
	ld de,03ad0h		;8357
	ld bc,00010h		;835a
	call copia_bloque_a_vram		;835d
	ret			;8360
se_hunde:		; Clases 3 (charca) y 4 (cocodrilo)
	ld hl,0e185h		;8361   ; el borrado empieza en el byte 0x1B del patron y va comiendo hacia arriba: 0xE185 baja y 0xE184 sube
	ld (hl),01bh		;8364
	ld hl,0e184h		;8366
	ld (hl),001h		;8369
	ld iy,0e2a2h		;836b
	res 0,(ix+006h)		;836f
	res 0,(ix+000h)		;8373
	ld hl,0e247h		;8377   ; tambien esconde los objetos hasta que acabe
	ld a,(hl)			;837a
	ld (0e189h),a		;837b
	ld (hl),001h		;837e
	res 5,(ix+000h)		;8380
	ld hl,se_hunde_paso		;8384   ; el manejador pasa a 0x8393: un paso de hundimiento por cuadro
	ld (ix+012h),l		;8387
	ld (ix+013h),h		;838a
	ld a,006h		;838d   ; sonido 6, el mismo de morir
	call arranca_un_sonido		;838f
	ret			;8392
se_hunde_paso:
	ld iy,0e2a2h		;8393
	ld hl,0e185h		;8397
	dec (hl)			;839a
	jr nz,se_hunde_borra		;839b
	jp se_hunde_termina		;839d
se_hunde_borra:
	ld hl,0e184h		;83a0
	inc (hl)			;83a3
	call patron_hundiendose		;83a4
	inc (iy+000h)		;83a7   ; baja un pixel por cuadro hasta la Y 0x7A
	ld a,07ah		;83aa
	cp (iy+000h)		;83ac
	ret nz			;83af
	ld iy,0e2aah		;83b0
	ld (iy+003h),000h		;83b4
	ret			;83b8
se_hunde_termina:
	call quita_una_vida		;83b9   ; aqui si se pierde la vida: charca y cocodrilo son dos de los cuatro sitios que la quitan
	ld (ix+011h),05ah		;83bc
	ld hl,0e2a2h		;83c0   ; la Y del sprite a 0
	ld (hl),000h		;83c3
	ld hl,0e2a9h		;83c5   ; y el color del segundo a 0: invisible
	ld (hl),000h		;83c8
	ld hl,muere_repinta_vidas		;83ca
	ld (ix+012h),l		;83cd
	ld (ix+013h),h		;83d0
	ret			;83d3

; ----------------------------------------------------------------------
; La escalera no tiene caja de colision: aqui se comprueba a
; mano que el tipo de escena (0xE225) sea 0 o 1 y que la X del
; jugador caiga entre 0x70 y 0x87. El mastil que pinta el guion
; de 0x8F06 esta en la columna 16 (0x80-0x87) y su cabecera en
; las columnas 15-17, asi que la ventana que se acepta es mas
; ancha por la izquierda que el dibujo.
; ----------------------------------------------------------------------
mira_la_escalera:
	ld a,(0e05fh)		;83d4
	and 003h		;83d7
	ret z			;83d9
	ld b,a			;83da
	ld a,(0e225h)		;83db   ; solo los modos 0 y 1 tienen escalera
	cp 002h		;83de
	ret nc			;83e0
	ld iy,0e2a2h		;83e1
	ld a,(iy+001h)		;83e5
	cp 070h		;83e8   ; la X de la columna de la escalera
	ret c			;83ea
	cp 088h		;83eb
	ret nc			;83ed
	bit 0,(ix+016h)		;83ee
	jr z,mira_la_escalera_sube		;83f2
	bit 1,b		;83f4
	ret z			;83f6
	res 0,(ix+016h)		;83f7   ; baja: apaga el bit de superficie
	ld (iy+000h),07fh		;83fb
	jr agarra_la_escalera		;83ff
mira_la_escalera_sube:
	bit 0,b		;8401
	ret z			;8403
	ld (iy+000h),0a3h		;8404
agarra_la_escalera:
	ld hl,trepa_la_escalera		;8408
	ld (ix+012h),l		;840b
	ld (ix+013h),h		;840e
	ld hl,08af9h		;8411   ; el guion de dos fotogramas de 0x8AF9: trepar
	ld (ix+00ch),l		;8414
	ld (ix+00dh),h		;8417
	ld (ix+00fh),000h		;841a
	ld (ix+00eh),001h		;841e
	ld (iy+001h),07ch		;8422
	ld (ix+010h),007h		;8426   ; periodo 7: se trepa despacio
	res 0,(ix+006h)		;842a
	res 0,(ix+000h)		;842e
	ld iy,0e292h		;8432
	ld (iy+001h),07ch		;8436
	ld (iy+000h),07ah		;843a
	ld (iy+002h),000h		;843e
	ld (iy+003h),00bh		;8442
	ret			;8446
trepa_la_escalera:
	ld iy,0e2a2h		;8447
	res 5,(ix+000h)		;844b
	ld a,(iy+000h)		;844f
	cp 083h		;8452   ; por encima de 0x83 hay que mirar los troncos
	call c,mira_los_troncos		;8454
	ld hl,0e05fh		;8457
	cp 07bh		;845a   ; a la altura 0x7B se puede salir del hoyo por los lados
	jr z,sale_del_hoyo		;845c
	bit 0,(hl)		;845e
	jr z,trepa_la_escalera_baja		;8460
	sub 004h		;8462
	ld (iy+000h),a		;8464
	set 5,(ix+000h)		;8467
	ret			;846b
trepa_la_escalera_baja:
	bit 1,(hl)		;846c   ; sin el bit 1 (abajo) no se baja
	ret z			;846e
	ld a,(iy+000h)		;846f   ; cuatro pixeles por paso, hasta la Y 0xA3
	cp 0a3h		;8472
	jr z,trepa_llega_al_subsuelo		;8474
	ld a,004h		;8476
	add a,(iy+000h)		;8478
	ld (iy+000h),a		;847b
	set 5,(ix+000h)		;847e   ; bit 5: mientras se trepa la animacion corre
	ret			;8482
trepa_llega_al_subsuelo:
	ld (ix+010h),001h		;8483
	ld (iy+000h),0a5h		;8487
	ld a,0a5h		;848b
	ld (0e1cfh),a		;848d   ; el suelo del subterraneo esta en 0xA5
	ld hl,jugador		;8490
	ld (ix+012h),l		;8493
	ld (ix+013h),h		;8496
	ret			;8499
sale_del_hoyo:
	ld a,(hl)			;849a   ; solo se sale con izquierda o derecha (bits 2 y 3)
	and 00ch		;849b
	jr z,trepa_la_escalera_baja		;849d
	set 6,(ix+016h)		;849f
	ld b,a			;84a3
	ld a,002h		;84a4   ; sonido 2, el mismo del salto
	call arranca_un_sonido		;84a6
	ld a,b			;84a9
	ld hl,en_el_aire		;84aa   ; de aqui en adelante manda la curva del salto
	ld (ix+012h),l		;84ad
	ld (ix+013h),h		;84b0
	res 5,(ix+000h)		;84b3
	res 0,(ix+000h)		;84b7
	set 0,(ix+006h)		;84bb
	set 0,(ix+016h)		;84bf
	ld (ix+010h),001h		;84c3
	ld (iy+000h),06dh		;84c7   ; la Y de salida, 0x6D
	ld (ix+017h),01fh		;84cb   ; paso 0x1F: el salto entero
	bit 3,a		;84cf
	jr nz,sale_del_hoyo_derecha		;84d1
	ld hl,0ff38h		;84d3   ; a la izquierda 0xFF38, que son 0,78 pixeles por cuadro hacia atras
	ld (ix+007h),l		;84d6
	ld (ix+008h),h		;84d9
	set 7,(ix+006h)		;84dc
	ret			;84e0
sale_del_hoyo_derecha:
	ld hl,000c8h		;84e1   ; y a la derecha 0x00C8, los mismos 0,78 hacia adelante
	ld (ix+007h),l		;84e4
	ld (ix+008h),h		;84e7
	res 7,(ix+006h)		;84ea
	ret			;84ee
mira_los_troncos:		; Solo mientras se trepa
	ld a,(iy+001h)		;84ef
	add a,008h		;84f2
	ld hl,0e232h		;84f4   ; 0xE232, 0xE235 y 0xE238: las cajas de los tres troncos
	ld b,003h		;84f7
mira_los_troncos_bucle:
	inc hl			;84f9
	cp (hl)			;84fa
	inc hl			;84fb
	jr c,mira_los_troncos_siguiente		;84fc
	cp (hl)			;84fe
	jr nc,mira_los_troncos_siguiente		;84ff
	ld a,00ah		;8501   ; sonido 10, el del golpe
	call arranca_un_sonido		;8503
	ld a,005h		;8506   ; el digito 5 dos veces: dos puntos menos
	call resta_al_marcador		;8508
	ld a,005h		;850b
	call resta_al_marcador		;850d
	ld iy,0e2a2h		;8510
	ld ix,0e2d5h		;8514
	ld a,087h		;8518
	ld (iy+000h),a		;851a   ; y de vuelta escalera abajo
	ld (ix+011h),001h		;851d
	ret			;8521
mira_los_troncos_siguiente:
	inc hl			;8522
	djnz mira_los_troncos_bucle		;8523
	ld a,(iy+000h)		;8525
	ret			;8528

; ----------------------------------------------------------------------
; 0xE229-0xE246 son DIEZ cajas de tres bytes: clase, X
; izquierda y X derecha. Diez, no nueve: 0x8545 recorre desde
; 0xE241 con B=2, o sea que llega a la de 0xE244, y el borrado
; de 0x89F3 se lleva por delante hasta 0xE246.
; ----------------------------------------------------------------------
mira_colisiones:
	ld iy,0e2a2h		;8529
	ld a,(iy+001h)		;852d
	add a,008h		;8530   ; la X del centro del jugador
	bit 7,(ix+006h)		;8532
	jr z,mira_colisiones_tabla		;8536
	sub 001h		;8538
mira_colisiones_tabla:
	ld hl,0e229h		;853a   ; siete cajas arriba; abajo solo las dos de 0xE241
	ld b,007h		;853d
	bit 0,(ix+016h)		;853f
	jr nz,mira_colisiones_bucle		;8543
	ld hl,0e241h		;8545
	ld b,002h		;8548
mira_colisiones_bucle:
	ld c,(hl)			;854a   ; el primer byte de la caja es la clase, y los otros dos la X izquierda y la derecha
	inc hl			;854b
	cp (hl)			;854c
	inc hl			;854d
	jr c,mira_colisiones_siguiente		;854e
	cp (hl)			;8550
	jr nc,mira_colisiones_siguiente		;8551
	ld b,a			;8553   ; dentro de la caja: B se queda la X y A pasa a ser la clase
	ld a,c			;8554
	cp 005h		;8555   ; las clases 2, 3 y 4 empujan al jugador fuera de la caja
	jr nc,mira_colisiones_devuelve_la_clase		;8557
	cp 001h		;8559
	jr z,mira_colisiones_devuelve_la_clase		;855b
	dec hl			;855d   ; entrando por la izquierda la X queda en (X izquierda)-5, o sea el centro justo en (X izquierda)+3
	ld a,(hl)			;855e
	add a,003h		;855f
	sub b			;8561
	jr c,mira_colisiones_empuja_a_la_izquierda		;8562
	add a,(iy+001h)		;8564
	ld (iy+001h),a		;8567
	jr mira_colisiones_devuelve_la_clase		;856a
mira_colisiones_empuja_a_la_izquierda:
	inc hl			;856c   ; y por la derecha en (X derecha)-12, el centro en (X derecha)-4
	ld a,b			;856d
	add a,004h		;856e
	sub (hl)			;8570
	jr c,mira_colisiones_devuelve_la_clase		;8571
	ld b,a			;8573
	ld a,(iy+001h)		;8574
	sub b			;8577
	ld (iy+001h),a		;8578
mira_colisiones_devuelve_la_clase:
	ld a,c			;857b
	cp 00ah		;857c
	jr nz,mira_colisiones_vuelve		;857e
	jp rebota_y_retrocede		;8580   ; la clase 10 no vuelve al llamante: salta derecha a rebotar
mira_colisiones_siguiente:
	inc hl			;8583
	djnz mira_colisiones_bucle		;8584
	xor a			;8586
	ret			;8587
mira_colisiones_vuelve:
	ret			;8588
mira_colisiones_en_el_aire:		; La misma busqueda sobre 0xE23B, desde el salto
	ld iy,0e2a2h		;8589   ; 0xE2A2, la entrada de sprite del jugador
	ld a,(iy+001h)		;858d
	add a,008h		;8590   ; mas 8, o sea el centro del muneco: la misma X con la que buscan 0x84EF y 0x8529
	bit 7,(ix+006h)		;8592   ; mirando a la izquierda (bit 7 de IX+0x06) se corre un pixel
	jr z,mira_colisiones_en_el_aire_tabla		;8596
	sub 001h		;8598
mira_colisiones_en_el_aire_tabla:
	ld hl,0e23bh		;859a
	ld b,002h		;859d   ; dos cajas y no diez: en el aire solo se miran las de 0xE23B, o las de 0xE241 si se esta en el subterraneo
	bit 0,(ix+016h)		;859f
	jr nz,mira_colisiones_en_el_aire_bucle		;85a3
	ld hl,0e241h		;85a5
mira_colisiones_en_el_aire_bucle:
	ld c,(hl)			;85a8   ; la misma caja de tres bytes, pero solo sobre las de 0xE23B
	inc hl			;85a9
	cp (hl)			;85aa
	inc hl			;85ab
	jr c,mira_colisiones_en_el_aire_siguiente		;85ac
	cp (hl)			;85ae
	jr nc,mira_colisiones_en_el_aire_siguiente		;85af
	ld b,a			;85b1
	ld a,005h		;85b2   ; en el aire solo cuentan la clase 5 (liana) y la 10 (rebote)
	cp c			;85b4
	jr z,alcanza_la_liana		;85b5
	ld a,00ah		;85b7
	cp c			;85b9
	jr z,rebota_y_retrocede		;85ba
	ld a,(0e1cfh)		;85bc   ; a mas de dos pixeles del suelo no se engancha nada
	inc a			;85bf
	sub (iy+000h)		;85c0
	cp 002h		;85c3
	jr nc,mira_colisiones_en_el_aire_nada		;85c5
	ld a,(0e2a2h)		;85c7   ; pegado al suelo y por encima de la Y 0x6D, se le baja un pixel antes de devolver la clase
	cp 06dh		;85ca
	jr nc,mira_colisiones_en_el_aire_devuelve		;85cc
	inc a			;85ce
	ld (0e2a2h),a		;85cf
mira_colisiones_en_el_aire_devuelve:
	ld a,c			;85d2
	ret			;85d3
mira_colisiones_en_el_aire_siguiente:
	inc hl			;85d4
	djnz mira_colisiones_en_el_aire_bucle		;85d5
mira_colisiones_en_el_aire_nada:
	xor a			;85d7
	ret			;85d8
alcanza_la_liana:
	ld hl,0e2a2h		;85d9   ; la caja de clase 5 ya decidio por la X; esta comprobacion vertical exige a la vez (0xE1CC)-7 < Y y (0xE1CC)-0x14 >= Y, que solo se cumplen juntas porque la segunda resta se desborda. Con 0xE1CC entre 0x07 y 0x10 sale cierta para cualquier Y; con 0x06 -las dos fases del extremo- sale falsa: en la punta del balanceo la liana no se coge
	ld a,(0e1cch)		;85dc   ; ojo con 0xE1CC: en este momento no es una coordenada, es el TERCER byte de la fase (0x06 a 0x10) que 0xA54D acaba de escribir. Solo 0xA616 lo convierte en Y, y eso ya colgado
	sub 007h		;85df
	cp (hl)			;85e1   ; (hl) es la Y del jugador, el primer byte de 0xE2A2
	jr nc,mira_colisiones_en_el_aire_nada		;85e2
	ld a,(0e1cch)		;85e4
	sub 014h		;85e7
	cp (hl)			;85e9
	jr c,mira_colisiones_en_el_aire_nada		;85ea
	ld a,005h		;85ec   ; devuelve la clase 5, y 0x885C se la pasa a despacha_la_clase: por la tabla 0x8AA0 acaba en 0x8162, agarrarse
	ret			;85ee
rebota_y_retrocede:		; Clase 10: invierte la velocidad y retrocede tres pasos. NO baja al subterraneo
	ld a,(ix+007h)		;85ef
	or a			;85f2   ; parado no rebota
	ret z			;85f3
	xor a			;85f4
	bit 2,(ix+016h)		;85f5
	jr nz,rebota_y_retrocede_calcula		;85f9
	ld a,00ah		;85fb
	call arranca_un_sonido		;85fd
rebota_y_retrocede_calcula:
	ld (ix+011h),002h		;8600   ; IX+0x11 = 2: el manejador se salta el cuadro siguiente
	ld ix,0e2d5h		;8604
	ld iy,0e2a2h		;8608
	set 2,(ix+016h)		;860c
	ld a,(ix+008h)		;8610
	cpl			;8613   ; le da la vuelta a la velocidad y retrocede tres pasos
	ld d,a			;8614
	ld a,(ix+007h)		;8615
	cpl			;8618
	ld e,a			;8619
	inc de			;861a
	ld (ix+008h),d		;861b
	ld (ix+007h),e		;861e
	ld h,(iy+001h)		;8621   ; la X va en IY+0x01 con su fraccion en IX+0x0B, la misma pareja que mueve 0x9B1F
	ld l,(ix+00bh)		;8624
	add hl,de			;8627
	add hl,de			;8628
	add hl,de			;8629
	ld (iy+001h),h		;862a
	ld (ix+00bh),l		;862d
	xor a			;8630
	bit 1,(ix+016h)		;8631   ; bit 1 de IX+0x16: ademas se da la vuelta
	ret z			;8635
	ld a,(ix+006h)		;8636
	xor 080h		;8639
	ld (ix+006h),a		;863b
	xor a			;863e
	ret			;863f

; ----------------------------------------------------------------------
; La clase 1 no mata: te tumba y te va restando un punto por
; cuadro mientras te pisa, y se sale andando. Tampoco matan la
; 2, la 5, la 8 ni la 10. Las unicas que cuestan una vida son
; la 6 y la 9, por 0x8226, y la 3 y la 4, por 0x83B9: esos son
; los dos unicos llamantes de quita_una_vida en el cartucho.
; ----------------------------------------------------------------------
arrollado_por_el_tronco:		; Clase 1
	ld iy,0e2a2h		;8640   ; 0xE2A2, la entrada de sprite del jugador
	ld hl,arrollado_pierde_puntos		;8644   ; el manejador pasa a 0x8660: mientras siga tumbado, cada cuadro cuesta puntos
	ld (ix+012h),l		;8647
	ld (ix+013h),h		;864a
	ld (iy+000h),072h		;864d   ; Y a 0x72, cinco pixeles por debajo del 0x6D del suelo: eso es estar tumbado
	res 5,(ix+000h)		;8651   ; bit 5 de IX+0x00 apagado, o sea sin animar: el muneco se queda en una sola pose
	ld a,020h		;8655
	ld (0e268h),a		;8657   ; 0xE268: repite el sonido 4 cada 0x20 cuadros
	ld a,004h		;865a
	call arranca_un_sonido		;865c
	ret			;865f
arrollado_pierde_puntos:
	ld a,(0e268h)		;8660   ; 0xE268 cuenta hasta 0x20 para volver a arrancar el sonido 4
	dec a			;8663
	ld (0e268h),a		;8664
	jp nz,arrollado_resta		;8667
	ld a,020h		;866a
	ld (0e268h),a		;866c
	ld a,004h		;866f
	call arranca_un_sonido		;8671
arrollado_resta:
	ld a,005h		;8674   ; un punto menos por cuadro
	call resta_al_marcador		;8676
	ld ix,0e2d5h		;8679
	res 0,(ix+006h)		;867d
	ld iy,0e2a2h		;8681
	bit 7,(ix+006h)		;8685
	jr z,arrollado_patron_derecha		;8689
	ld (iy+002h),05ch		;868b
	jr arrollado_mira_la_entrada		;868f
arrollado_patron_derecha:
	ld (iy+002h),038h		;8691
arrollado_mira_la_entrada:
	ld a,(0e224h)		;8695   ; de la variante 4 en adelante todavia se puede mover de lado
	cp 004h		;8698
	jr c,arrollado_comprueba		;869a
	ld a,(0e05fh)		;869c   ; bits 2 y 3 de 0xE05F: izquierda y derecha
	and 00ch		;869f
	jr z,arrollado_comprueba		;86a1
	bit 2,a		;86a3
	jr z,arrollado_hacia_la_derecha		;86a5
	set 7,(ix+006h)		;86a7
	set 0,(ix+006h)		;86ab
	ld de,0ff40h		;86af
	ld (ix+008h),d		;86b2
	ld (ix+007h),e		;86b5
	jr arrollado_comprueba		;86b8
arrollado_hacia_la_derecha:
	bit 3,a		;86ba
	jr z,arrollado_comprueba		;86bc
	ld de,000c0h		;86be   ; 0x00C0 en IX+0x07/08: arrastrandose se avanza menos que andando (0x00C8)
	ld (ix+008h),d		;86c1
	ld (ix+007h),e		;86c4
	res 7,(ix+006h)		;86c7
	set 0,(ix+006h)		;86cb
arrollado_comprueba:
	call mira_colisiones		;86cf   ; mientras siga tocando la caja de clase 1 no se levanta
	cp 001h		;86d2
	ret z			;86d4
	ld hl,jugador		;86d5   ; al soltarse vuelven el manejador normal y la Y 0x6D
	ld (ix+012h),l		;86d8
	ld (ix+013h),h		;86db
	ld (iy+000h),06dh		;86de
	ret			;86e2
cae_por_el_hoyo:
	ld iy,0e2a2h		;86e3
	ld a,(iy+000h)		;86e7
	cp 0a5h		;86ea   ; 0xA5 es el fondo, y alli se recupera el mando
	jr c,cae_por_el_hoyo_medio		;86ec
	res 0,(ix+000h)		;86ee   ; se deja de caer y vuelve el manejador normal
	set 6,(ix+016h)		;86f2
	ld hl,jugador		;86f6
	ld (ix+012h),l		;86f9
	ld (ix+013h),h		;86fc
	ld a,06dh		;86ff   ; y la Y del suelo pasa a 0x6D
	ld (0e1cfh),a		;8701
	ret			;8704
cae_por_el_hoyo_medio:
	cp 090h		;8705   ; de la Y 0x90 para abajo el patron es el de caer, 0x5C o 0x38; mas arriba el de estar de pie, 0x58 o 0x34
	jr c,cae_por_el_hoyo_arriba		;8707
	bit 7,(ix+006h)		;8709
	jr z,cae_por_el_hoyo_medio_derecha		;870d
	ld (iy+002h),05ch		;870f
	ret			;8713
cae_por_el_hoyo_medio_derecha:
	ld (iy+002h),038h		;8714
	ret			;8718
cae_por_el_hoyo_arriba:
	ld a,(iy+000h)		;8719   ; estas dos instrucciones sobran: A ya traia esta misma Y desde 0x8705, y el 0xE185 del ld hl no lo lee nadie. Las dos ramas escriben (iy+002h) y vuelven sin tocar ni A ni HL, y quien llama es el despachador de objetos, que tampoco los mira
	ld hl,0e185h		;871c
	bit 7,(ix+006h)		;871f   ; bit 7 de IX+0x06: hacia donde mira
	jr z,cae_por_el_hoyo_arriba_derecha		;8723
	ld (iy+002h),058h		;8725   ; por encima de la Y 0x90 el patron es el de estar de pie, 0x58 a la izquierda y 0x34 a la derecha
	ret			;8729
cae_por_el_hoyo_arriba_derecha:
	ld (iy+002h),034h		;872a
	ret			;872e

; ----------------------------------------------------------------------
; Cada cuadro: anda, mira el boton, mira la escalera y
; mira las cajas. La clase que sale de 0x8529 es la que
; decide todo lo demas
; ----------------------------------------------------------------------
jugador:
	call anda		;872f
	call mira_el_boton		;8732
	call mira_la_escalera		;8735
	call mira_colisiones		;8738   ; la clase que devuelve va derecha al despachador

; ----------------------------------------------------------------------
; LAS DIEZ CLASES DE COLISION. La tabla es 0x8AA0 y el
; indice es la clase; la 0 no salta a ningun sitio.
; 1 tronco 8640    2 hoyo 8751     3 charca 8361
; 4 cocodrilo 8361 5 liana 8162    6 muerte 8221
; 7 sin uso 874B   8 tesoro 878C   9 muerte 8221
; 10 rebote 85EF
; ----------------------------------------------------------------------
despacha_la_clase:
	or a			;873b   ; la clase 0 no salta a ningun sitio
	ret z			;873c
	sla a		;873d   ; doblada, es el indice en la tabla de 0x8AA0
	ld e,a			;873f
	ld d,000h		;8740
	ld hl,08aa0h		;8742
	add hl,de			;8745
	ld e,(hl)			;8746
	inc hl			;8747
	ld d,(hl)			;8748
	ex de,hl			;8749
	jp (hl)			;874a   ; jp (hl): el manejador de la clase hereda el retorno de quien llamo aqui
deja_un_solo_objeto:		; Clase 7: nadie la escribe
	ld hl,0e247h		;874b
	ld (hl),001h		;874e
	ret			;8750
cae_en_el_hoyo:		; Clase 2
	ld hl,cae_por_el_hoyo		;8751
	ld (ix+012h),l		;8754
	ld (ix+013h),h		;8757
	set 0,(ix+000h)		;875a
	res 0,(ix+006h)		;875e
	res 0,(ix+016h)		;8762   ; apaga el bit de superficie: se acaba en el subterraneo
	res 5,(ix+000h)		;8766
	ld hl,0e2a3h		;876a
	ld a,(hl)			;876d
	ld iy,0e292h		;876e
	ld (iy+001h),a		;8772
	ld (iy+000h),07ah		;8775
	ld (iy+002h),000h		;8779
	ld (iy+003h),00bh		;877d
	ld a,003h		;8781   ; el digito 3: cien puntos menos por caer
	call resta_al_marcador		;8783
	ld a,005h		;8786
	call arranca_un_sonido		;8788
	ret			;878b
recoge_el_tesoro:
	ld a,008h		;878c   ; sonido 8, el de recoger
	call arranca_un_sonido		;878e
	ld a,(0e188h)		;8791   ; los miles que dejo escritos la rutina que lo pinto
	call suma_miles		;8794
	ld hl,0e291h		;8797
	ld (hl),000h		;879a
	push ix		;879c
	ld ix,0e23bh		;879e
	ld (ix+000h),000h		;87a2   ; apaga la zona de peligro del tesoro, que ya no esta
	ld a,000h		;87a6
	sub 000h		;87a8
	ld (ix+001h),a		;87aa
	ld a,000h		;87ad
	add a,000h		;87af
	ld (ix+002h),a		;87b1
	pop ix		;87b4
	ld hl,0b08eh		;87b6
	call pinta_celdas		;87b9
	ld a,(0e186h)		;87bc
	ld l,a			;87bf
	ld a,(0e187h)		;87c0
	ld h,a			;87c3
	ld a,(0e223h)		;87c4   ; el mismo indice de 0xAAFF, ahora para construir el bit que hay que marcar
	cp 000h		;87c7
	jr nz,marca_el_tesoro_monta_el_bit		;87c9
	ld a,001h		;87cb
	jr marca_el_tesoro_guarda		;87cd
marca_el_tesoro_monta_el_bit:
	ld b,a			;87cf
	inc b			;87d0
	xor a			;87d1
	scf			;87d2
marca_el_tesoro_bucle:
	rla			;87d3
	djnz marca_el_tesoro_bucle		;87d4
marca_el_tesoro_guarda:
	or (hl)			;87d6   ; y se marca: a partir de aqui 0xAAFF hara que este tesoro no vuelva a aparecer
	ld (hl),a			;87d7
	ld ix,0e2d5h		;87d8
	ret			;87dc
mira_el_boton:
	ld a,(0e05fh)		;87dd
	and 030h		;87e0   ; bits 4 y 5 de 0xE05F: los dos disparos
	jr nz,empieza_el_salto		;87e2
	res 6,(ix+016h)		;87e4
	ret			;87e8
empieza_el_salto:
	bit 6,(ix+016h)		;87e9   ; con el boton mantenido no se vuelve a saltar
	ret nz			;87ed
	set 6,(ix+016h)		;87ee
	ld hl,en_el_aire		;87f2   ; el manejador pasa a 0x8820, con el paso del salto en 0x1F
	ld (ix+012h),l		;87f5
	ld (ix+013h),h		;87f8
	res 5,(ix+000h)		;87fb
	set 1,(ix+016h)		;87ff
	set 6,(ix+006h)		;8803   ; bit 6 de IX+0x06: saltando SI se miran las cajas del aire; soltandose de la liana no, porque 0x8212 lo apaga
	ld (ix+017h),01fh		;8807
	ld a,002h		;880b   ; sonido 2, el del salto
	call arranca_un_sonido		;880d
	bit 7,(ix+006h)		;8810
	jr z,empieza_el_salto_derecha		;8814
	ld (iy+002h),058h		;8816
	ret			;881a
empieza_el_salto_derecha:
	ld (iy+002h),034h		;881b
	ret			;881f

; ----------------------------------------------------------------------
; IX+0x17 es el indice en la curva de 0x8AB6, que se lee del
; final al principio: 0xFF sube un pixel, 0x01 baja y 0x00 se
; queda. No hay velocidad vertical, hay tabla. Del paso 0x1F al
; 0x11 la curva SUBE diez pixeles, y del 0x10 al 1 baja esos
; mismos diez cada vez mas seguidos: el salto entero son 31
; cuadros, 15 subiendo y 16 cayendo.
; El salto y la salida del hoyo arrancan en 0x1F, pero soltarse
; de la liana arranca en (0xE1E2), que es el CUARTO BYTE de la
; fase del balanceo (tabla 0xA61A) y nunca pasa de 0x10: al
; soltarse solo se cae, no se sube. En la vertical vale 0 y
; entonces 0x882E aterriza en el acto; en la punta vale 0x10,
; que es el descenso entero.
; ----------------------------------------------------------------------
en_el_aire:
	call en_el_aire_gira		;8820
	ld iy,0e2a2h		;8823
	ld b,(ix+017h)		;8827
	ld hl,08ab6h		;882a   ; la curva del salto, indexada por el paso que queda
	xor a			;882d
	cp b			;882e
	jr z,en_el_aire_aterriza		;882f
en_el_aire_busca_la_curva:
	inc hl			;8831
	djnz en_el_aire_busca_la_curva		;8832
	ld a,(hl)			;8834
	add a,(iy+000h)		;8835   ; el valor se suma a la Y: 0xFF sube, 0x01 baja
	ld (iy+000h),a		;8838
	res 5,(ix+000h)		;883b
	bit 7,(ix+006h)		;883f
	jr z,en_el_aire_patron_derecha		;8843
	ld (iy+002h),05ch		;8845
	jr en_el_aire_sigue		;8849
en_el_aire_patron_derecha:
	ld (iy+002h),038h		;884b
en_el_aire_sigue:
	dec (ix+017h)		;884f   ; al llegar a cero se aterriza
	jr z,en_el_aire_aterriza		;8852
	bit 6,(ix+006h)		;8854
	ret z			;8858
	call mira_colisiones_en_el_aire		;8859
	jp despacha_la_clase		;885c
en_el_aire_aterriza:
	call mira_colisiones_en_el_aire		;885f   ; una ultima mirada a las cajas antes de tocar suelo
	ld hl,jugador		;8862   ; y de vuelta al manejador de andar
	ld (ix+012h),l		;8865
	ld (ix+013h),h		;8868
	ld (ix+00fh),000h		;886b   ; el fotograma vuelve al primero
	ld (ix+00eh),001h		;886f
	res 1,(ix+016h)		;8873
	res 6,(ix+006h)		;8877
	bit 0,(ix+016h)		;887b
	ret z			;887f
	ld a,06dh		;8880   ; solo arriba se fuerza la Y a 0x6D; en el subterraneo se queda donde cayo
	ld (0e2a2h),a		;8882
	ret			;8885
en_el_aire_gira:
	ld ix,0e2d5h		;8886
	ld iy,0e2a2h		;888a
	ld a,(ix+007h)		;888e   ; solo se gira si el salto empezo parado: con velocidad ya puesta se sale
	or a			;8891
	ret nz			;8892
	ld a,(ix+017h)		;8893
	cp 01dh		;8896   ; solo se gira en los tres primeros pasos del salto
	ret c			;8898
	ld a,(0e05fh)		;8899   ; y hace falta izquierda o derecha (bits 2 y 3)
	and 00ch		;889c
	ret z			;889e
	ld de,000c8h		;889f   ; 0x00C8 a la derecha y 0xFF38 a la izquierda, cada uno con su patron
	res 7,(ix+006h)		;88a2
	ld (iy+002h),038h		;88a6
	bit 2,a		;88aa
	jr z,en_el_aire_gira_guarda		;88ac
	ld de,0ff38h		;88ae
	set 7,(ix+006h)		;88b1
	ld (iy+002h),05ch		;88b5
en_el_aire_gira_guarda:
	ld (ix+007h),e		;88b9   ; la velocidad recien elegida, ya en IX+0x07/08
	ld (ix+008h),d		;88bc
	set 0,(ix+006h)		;88bf
	ld a,01fh		;88c3   ; recupera el avance perdido al cambiar de sentido
	sub (ix+017h)		;88c5
	ld b,a			;88c8
	xor a			;88c9
	cp b			;88ca
	inc b			;88cb
	ret z			;88cc
	ld iy,0e2a3h		;88cd   ; IY+0x01 y IX+0x0B, la pareja de la X: se la mueve a mano una vez por cada paso ya gastado
	ld ix,0e2dbh		;88d1
en_el_aire_gira_recupera:
	call mueve_objeto		;88d5
	djnz en_el_aire_gira_recupera		;88d8
	ld ix,0e2d5h		;88da
	ret			;88de
sonido_de_los_pasos:
	ld hl,0e1e3h		;88df
	dec (hl)			;88e2
	ret nz			;88e3
	ld a,(0e1e5h)		;88e4
	ld (hl),a			;88e7
	ld a,003h		;88e8   ; sonido 3, el de las pisadas
	jp arranca_un_sonido		;88ea
anda:
	ld iy,0e2a2h		;88ed
	ld hl,0e05fh		;88f1
	bit 2,(hl)		;88f4   ; bit 2 de 0xE05F: izquierda
	jr z,anda_a_la_derecha		;88f6
	res 2,(ix+016h)		;88f8   ; andar apaga el bit 2 de IX+0x16, o sea el "ya he rebotado" que mira 0x85F5
	call sonido_de_los_pasos		;88fc
	set 7,(ix+006h)		;88ff
	ld de,08aedh		;8903   ; el guion de andar a la izquierda
	ld (ix+00ch),e		;8906
	ld (ix+00dh),d		;8909
	set 5,(ix+000h)		;890c   ; bit 5 animado y bit 0 movil: hacen falta los dos para que ande
	set 0,(ix+006h)		;8910
	ld de,0ff38h		;8914
	ld (ix+008h),d		;8917
	ld (ix+007h),e		;891a
	ret			;891d
anda_a_la_derecha:
	bit 3,(hl)		;891e   ; bit 3: derecha; sin ninguno de los dos, se para
	jr z,se_para		;8920
	call sonido_de_los_pasos		;8922
	res 2,(ix+016h)		;8925
	res 7,(ix+006h)		;8929
	ld de,08ae1h		;892d   ; y el de andar a la derecha
	ld (ix+00ch),e		;8930
	ld (ix+00dh),d		;8933
	set 5,(ix+000h)		;8936
	set 0,(ix+006h)		;893a
	ld de,000c8h		;893e
	ld (ix+008h),d		;8941
	ld (ix+007h),e		;8944
	ret			;8947
se_para:
	res 5,(ix+000h)		;8948   ; se apagan la animacion y el movimiento
	res 0,(ix+006h)		;894c
	ld (ix+00fh),000h		;8950   ; y el fotograma vuelve al primero
	ld (ix+00eh),001h		;8954
	ld de,00000h		;8958   ; velocidad cero
	ld (ix+008h),d		;895b
	ld (ix+007h),e		;895e
	bit 7,(ix+006h)		;8961   ; de pie: patron 0x58 mirando a la izquierda, 0x34 a la derecha
	ld iy,0e2a2h		;8965
	jr z,se_para_derecha		;8969
	ld (iy+002h),058h		;896b
	ret			;896f
se_para_derecha:
	ld (iy+002h),034h		;8970
	ret			;8974
quita_una_vida:
	ld a,(0e012h)		;8975   ; 0xE012 son las vidas que quedan
	sub 001h		;8978
	ld (0e012h),a		;897a
	ret nc			;897d   ; si no ha habido acarreo aun queda alguna
	ld hl,0e247h		;897e
	ld (hl),001h		;8981
	ld ix,0e2d5h		;8983
	ld hl,09e0eh		;8987
	ld (ix+012h),l		;898a
	ld (ix+013h),h		;898d
	res 5,(ix+000h)		;8990
	res 0,(ix+000h)		;8994
	res 0,(ix+006h)		;8998
	ld a,003h		;899c
	ld (0e21ch),a		;899e
	ld a,001h		;89a1
	ld (0e269h),a		;89a3
	pop de			;89a6   ; sin vidas se come el retorno: el jugador pasa a 0x9E0E
	ret			;89a7

; ----------------------------------------------------------------------
; Las vidas se ven de dos maneras a la vez: tres tiles
; en las filas 2 y 3, y el color de los sprites 12 y 13,
; que se pone a 0 -transparente- cuando esa vida se acaba
; ----------------------------------------------------------------------
pinta_las_vidas:
	ld a,(0e012h)		;89a8
	ld hl,08a76h		;89ab   ; tres filas de tiles distintas segun queden 0, 1 o 2
	ld iy,0e29ah		;89ae
	ld (iy+003h),000h		;89b2   ; color 0: ese sprite deja de verse
	ld iy,0e29eh		;89b6
	ld (iy+003h),000h		;89ba
	or a			;89be
	jr z,pinta_las_vidas_vram		;89bf
	ld hl,08a7ch		;89c1
	ld iy,0e29ah		;89c4
	ld (iy+003h),001h		;89c8
	dec a			;89cc
	jr z,pinta_las_vidas_vram		;89cd
	ld hl,08a82h		;89cf
	ld iy,0e29eh		;89d2
	ld (iy+003h),001h		;89d6
pinta_las_vidas_vram:
	ld de,01843h		;89da   ; tres tiles en la fila 2, columna 3
	ld bc,00003h		;89dd
	push hl			;89e0
	call copia_bloque_a_vram		;89e1
	pop hl			;89e4
	ld de,00003h		;89e5   ; y los tres siguientes justo debajo, en la fila 3
	add hl,de			;89e8
	ld de,01863h		;89e9
	ld bc,00003h		;89ec
	call copia_bloque_a_vram		;89ef
	ret			;89f2
borra_las_cajas:
	ld hl,0e229h		;89f3
	ld de,0e22ah		;89f6
	ld (hl),000h		;89f9
	ld bc,0001dh		;89fb   ; 0x1E bytes: las diez cajas de tres
	ldir		;89fe
	ret			;8a00

; ----------------------------------------------------------------------
; El estado de una partida nueva: marcador a 2000,
; reloj a 20:00 y dos vidas de repuesto
; ----------------------------------------------------------------------
prepara_la_partida:
	ld hl,0b0f0h		;8a01   ; los 32 colores iniciales a la VRAM 0x2000
	ld de,02000h		;8a04
	ld bc,00020h		;8a07
	call copia_bloque_a_vram		;8a0a
	ld hl,0e247h		;8a0d
	ld (hl),000h		;8a10
	ld a,06ch		;8a12
	ld (0e1cfh),a		;8a14
	call prepara_la_pantalla		;8a17
	ld de,0e1d0h		;8a1a
	ld hl,08a69h		;8a1d   ; 0xE1D0: los tiles BA B8 C2 B8 B8, o sea 20:00, y de propina el sexto byte, 0x3C, que cae en 0xE1D5 y es la cuenta de 60 cuadros del tick: el reloj y su temporizador se cargan con el mismo ldir
	ld bc,00006h		;8a20
	ldir		;8a23
	ld de,0e1d6h		;8a25
	ld hl,08a6fh		;8a28   ; 0xE1D6: los digitos 0 0 2 0 0 0, o sea 2000 puntos
	ld bc,00006h		;8a2b
	ldir		;8a2e
	ld de,0e29ah		;8a30
	ld hl,08a88h		;8a33
	ld bc,00004h		;8a36
	ldir		;8a39
	ld de,0e29eh		;8a3b
	ld hl,08a8ch		;8a3e
	ld bc,00004h		;8a41
	ldir		;8a44
	ld hl,0e1d0h		;8a46
	ld de,01867h		;8a49
	ld bc,00005h		;8a4c
	call copia_bloque_a_vram		;8a4f
	ld a,002h		;8a52   ; dos vidas de repuesto
	ld (0e012h),a		;8a54
	call pinta_las_vidas		;8a57
	call pinta_marcador		;8a5a
	ld a,03ch		;8a5d   ; tres contadores a 60 cuadros
	ld (0e25ah),a		;8a5f
	ld (0e25bh),a		;8a62
	ld (0e25ch),a		;8a65
	ret			;8a68

; ----------------------------------------------------------------------
; DATOS inicializador_e1d0: Seis bytes que 0x8A23 copia con LDIR a 0xE1D0
;   0x8a69..0x8a6f  (6 bytes)
DATA_inicializador_e1d0:
	defb 0bah,0b8h,0c2h,0b8h,0b8h,03ch	; 8a69

; ----------------------------------------------------------------------
; DATOS inicializador_e1d6: Seis bytes que 0x8A2E copia a 0xE1D6
;   0x8a6f..0x8a75  (6 bytes)
DATA_inicializador_e1d6:
	defb 000h,000h,002h,000h,000h,000h	; 8a6f

; ----------------------------------------------------------------------
; DATOS tiles_de_las_vidas: Un 0x00 de relleno y TRES filas de seis tiles
;   C3/C5/C6, una por cuenta de vidas: 0x8A76 ninguna, 0x8A7C una, 0x8A82 dos.
;   0x89AB elige la que toca y 0x89DA y 0x89E9 suben sus dos mitades de tres
;   bytes a la VRAM 0x1843 y 0x1863
;   0x8a75..0x8a88  (19 bytes)
DATA_tiles_de_las_vidas:
	defb 000h	; 8a75
	defb 0c3h,0c3h,0c3h,0c3h,0c3h,0c3h	; 8a76
	defb 0c5h,0c3h,0c3h,0c6h,0c3h,0c3h	; 8a7c
	defb 0c5h,0c3h,0c5h,0c6h,0c3h,0c6h	; 8a82

; ----------------------------------------------------------------------
; DATOS inicializador_e29a: Cuatro bytes que 0x8A39 copia a 0xE29A
;   0x8a88..0x8a8c  (4 bytes)
DATA_inicializador_e29a:
	defb 00fh,011h,070h,001h	; 8a88

; ----------------------------------------------------------------------
; DATOS inicializador_e29e: Cuatro bytes que 0x8A44 copia a 0xE29E
;   0x8a8c..0x8a90  (4 bytes)
DATA_inicializador_e29e:
	defb 00fh,021h,070h,001h	; 8a8c

; ----------------------------------------------------------------------
; DATOS inicializador_e2ae: Cuatro bytes que 0x80D1 (en el arranque) copia a
;   0xE2AE
;   0x8a90..0x8a94  (4 bytes)
DATA_inicializador_e2ae:
	defb 0b3h,00eh,010h,000h	; 8a90

; ----------------------------------------------------------------------
; DATOS inicializador_e2b2: Cuatro bytes que 0x80DC copia a 0xE2B2
;   0x8a94..0x8a98  (4 bytes)
DATA_inicializador_e2b2:
	defb 0b3h,00eh,014h,000h	; 8a94

; ----------------------------------------------------------------------
; DATOS inicializador_e2b6: Cuatro bytes que 0x80E7 copia a 0xE2B6
;   0x8a98..0x8a9c  (4 bytes)
DATA_inicializador_e2b6:
	defb 0b3h,00eh,018h,000h	; 8a98

; ----------------------------------------------------------------------
; DATOS inicializador_e2ba: Cuatro bytes que 0x80F2 copia a 0xE2BA
;   0x8a9c..0x8aa0  (4 bytes)
DATA_inicializador_e2ba:
	defb 0b3h,00eh,01ch,000h	; 8a9c

; ----------------------------------------------------------------------
; DATOS tabla_del_despachador_874a: Once punteros de palabra. El despachador
;   de 0x873B los consume con el indice en A (sla / add hl / jp (hl)); con A=0
;   vuelve sin saltar. En 0x8AB6 las palabras dejan de ser punteros a ROM y
;   empiezan los pares 0x0100/0x0101 de la tabla siguiente
;   0x8aa0..0x8ab6  (22 bytes)
DATA_tabla_del_despachador_874a:
	defw 0874bh	; 8aa0  -> deja_un_solo_objeto
	defw 08640h	; 8aa2  -> arrollado_por_el_tronco
	defw 08751h	; 8aa4  -> cae_en_el_hoyo
	defw 08361h	; 8aa6  -> se_hunde
	defw 08361h	; 8aa8  -> se_hunde
	defw 08162h	; 8aaa  -> agarra_la_liana
	defw 08221h	; 8aac  -> muere
	defw 0874bh	; 8aae  -> deja_un_solo_objeto
	defw 0878ch	; 8ab0  -> recoge_el_tesoro
	defw 08221h	; 8ab2  -> muere
	defw 085efh	; 8ab4  -> rebota_y_retrocede

; ----------------------------------------------------------------------
; DATOS curva_del_salto: Treinta y cuatro bytes 0x00/0x01/0xFF que 0x8820
;   indexa con IX+0x17 (de 0x1F a 1, o sea leidos de atras adelante) sumando
;   el valor a IY+0x00. El indice no pasa de 0x1F, asi que la curva se acaba
;   en 0x8AD5
;   0x8ab6..0x8ad8  (34 bytes)
DATA_curva_del_salto:
	defb 000h,001h,001h,001h,001h,001h,001h,001h,000h,001h,000h,000h,001h,000h,000h,000h	; 8ab6  ................
	defb 001h,0ffh,000h,000h,000h,0ffh,000h,0ffh,000h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 8ac6  ................
	defb 000h,000h	; 8ad6

; ----------------------------------------------------------------------
; DATOS datos_sin_identificar_8ad8: Nueve bytes (03 4C 5C 76 83 9C AD 00 00) a
;   los que no apunta ninguna palabra del cartucho
;   0x8ad8..0x8ae1  (9 bytes)
DATA_datos_sin_identificar_8ad8:
	defb 003h,04ch,05ch,076h,083h,09ch,0adh,000h,000h	; 8ad8  .L\v.....

; ----------------------------------------------------------------------
; DATOS guion_anda_derecha: 03 20 / 03 24 / 03 28 / 03 2C / 03 30 / 00 00:
;   cinco fotogramas de tres cuadros. Lo carga 0x892D
;   0x8ae1..0x8aed  (12 bytes)
DATA_guion_anda_derecha:
	defb 003h,020h	; 8ae1
	defb 003h,024h	; 8ae3
	defb 003h,028h	; 8ae5
	defb 003h,02ch	; 8ae7
	defb 003h,030h	; 8ae9
	defb 000h,000h	; 8aeb

; ----------------------------------------------------------------------
; DATOS guion_anda_izquierda: Los mismos tiempos con los patrones espejados,
;   0x44 a 0x54. Lo carga 0x8903
;   0x8aed..0x8af9  (12 bytes)
DATA_guion_anda_izquierda:
	defb 003h,044h	; 8aed
	defb 003h,048h	; 8aef
	defb 003h,04ch	; 8af1
	defb 003h,050h	; 8af3
	defb 003h,054h	; 8af5
	defb 000h,000h	; 8af7

; ----------------------------------------------------------------------
; DATOS guion_trepa: 01 3C / 01 60 / 00 00: dos fotogramas de un cuadro. Lo
;   carga 0x8411
;   0x8af9..0x8aff  (6 bytes)
DATA_guion_trepa:
	defb 001h,03ch	; 8af9
	defb 001h,060h	; 8afb
	defb 000h,000h	; 8afd

; ======================================================================
; CODIGO 0x8aff..0x8e1b  (796 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; Deja la pantalla lista: borra el name table,
; descomprime los patrones de tile y fabrica los
; espejados sin gastar ROM en dibujarlos dos veces
; ----------------------------------------------------------------------
prepara_la_pantalla:
	ld hl,01800h		;8aff   ; 0x300 bytes: el name table entero al tile 0x2C
	ld bc,00300h		;8b02
	ld a,02ch		;8b05
	call rellena_vram		;8b07
	ld hl,01800h		;8b0a
	ld bc,000e0h		;8b0d
	ld a,038h		;8b10   ; las siete primeras filas, al tile 0x38
	call rellena_vram		;8b12
	ld hl,0909eh		;8b15
	call descomprime_rle_a_vram		;8b18
	ld hl,0915bh		;8b1b
	call descomprime_rle_a_vram		;8b1e
	ld bc,00004h		;8b21
	ld hl,00080h		;8b24
	ld de,000a0h		;8b27
	call copia_patrones_en_espejo		;8b2a   ; B1D1 invierte los bits de cada patron: espejo horizontal
	ld bc,00005h		;8b2d
	ld hl,002c0h		;8b30
	ld de,002f8h		;8b33
	call copia_patrones_en_espejo		;8b36
	ld bc,00007h		;8b39
	ld hl,002c0h		;8b3c
	ld de,00320h		;8b3f
	call copia_patrones_volteados		;8b42   ; B20B cruza los bytes: espejo vertical
	ld bc,00005h		;8b45
	ld hl,00320h		;8b48
	ld de,00358h		;8b4b
	call copia_patrones_en_espejo		;8b4e
	ld hl,09090h		;8b51   ; catorce tiles a la fila 23
	ld de,01ae2h		;8b54
	ld bc,0000eh		;8b57
	call copia_bloque_a_vram		;8b5a
	ret			;8b5d

; ----------------------------------------------------------------------
; Los sprites solo estan dibujados mirando a la derecha.
; Los de mirar a la izquierda se fabrican aqui espejando
; los otros, nueve de golpe por bloque
; ----------------------------------------------------------------------
carga_los_sprites:
	ld hl,0939dh		;8b5e
	call descomprime_rle_a_vram		;8b61
	ld b,009h		;8b64
	ld hl,00044h		;8b66   ; nueve sprites del patron 0x20 al 0x44, que es el mismo del reves
	ld de,00020h		;8b69
	call espeja_nueve_sprites		;8b6c
	ld hl,09473h		;8b6f   ; el segundo bloque de nueve: del patron 0x68 al 0x8C
	call descomprime_rle_a_vram		;8b72
	ld b,009h		;8b75
	ld hl,0008ch		;8b77
	ld de,00068h		;8b7a
	call espeja_nueve_sprites		;8b7d
	ld hl,0956ah		;8b80   ; y el tercero: del 0xB0 al 0xD4
	call descomprime_rle_a_vram		;8b83
	ld b,009h		;8b86
	ld hl,000d4h		;8b88
	ld de,000b0h		;8b8b
	call espeja_nueve_sprites		;8b8e
	ret			;8b91

; ----------------------------------------------------------------------
; Los patrones del jugador se montan en RAM (0xE138 y
; 0xE15E) para poder borrarlos a trozos: asi se ve como
; se hunde en la charca y como reaparece despues
; ----------------------------------------------------------------------
borra_parte_del_patron:
	ld hl,0e138h		;8b92
	ld a,(0e185h)		;8b95   ; 0xE185 dice desde que byte y 0xE184 cuantos
	ld e,a			;8b98
	ld d,000h		;8b99
	add hl,de			;8b9b
	ld a,(0e184h)		;8b9c
	ld b,a			;8b9f
	xor a			;8ba0
	cp b			;8ba1
	jr z,borra_parte_del_patron_segundo		;8ba2
borra_parte_del_patron_bucle:
	ld (hl),000h		;8ba4
	inc hl			;8ba6
	djnz borra_parte_del_patron_bucle		;8ba7
borra_parte_del_patron_segundo:
	ld hl,0e15eh		;8ba9   ; lo mismo en el segundo patron, 0xE15E: el muneco son dos capas de color
	ld a,(0e185h)		;8bac
	ld e,a			;8baf
	ld d,000h		;8bb0
	add hl,de			;8bb2
	ld a,(0e184h)		;8bb3   ; con 0xE184 a cero no se borra nada
	ld b,a			;8bb6
	xor a			;8bb7
	cp b			;8bb8
	jr z,borra_parte_del_patron_vuelve		;8bb9
borra_parte_del_patron_segundo_bucle:
	ld (hl),000h		;8bbb
	inc hl			;8bbd
	djnz borra_parte_del_patron_segundo_bucle		;8bbe
borra_parte_del_patron_vuelve:
	ret			;8bc0

; ----------------------------------------------------------------------
; Un sprite de 16x16 son dos mitades de 16 bytes, asi
; que para espejarlo no basta con invertir los bits:
; hay que cruzar ademas las dos mitades
; ----------------------------------------------------------------------
espeja_nueve_sprites:
	push bc			;8bc1
	ld bc,03800h		;8bc2   ; numero de patron por 8 mas 0x3800: la tabla de sprites
	add hl,hl			;8bc5   ; tres add hl,hl: el numero de patron por 8
	add hl,hl			;8bc6
	add hl,hl			;8bc7
	add hl,bc			;8bc8
	ex de,hl			;8bc9   ; y lo mismo con el destino
	add hl,hl			;8bca
	add hl,hl			;8bcb
	add hl,hl			;8bcc
	add hl,bc			;8bcd
	ex de,hl			;8bce
	pop bc			;8bcf
espeja_nueve_sprites_bucle:
	push bc			;8bd0
	push hl			;8bd1
	push de			;8bd2
	ld bc,00010h		;8bd3   ; la mitad izquierda del original va a la mitad DERECHA del espejo, 16 bytes mas alla
	add hl,bc			;8bd6
	ld bc,00002h		;8bd7   ; dos patrones de ocho bytes, que son los 16 de media columna
	ex de,hl			;8bda
	call copia_patrones_en_espejo		;8bdb
	pop hl			;8bde
	ld bc,00010h		;8bdf
	add hl,bc			;8be2
	ex de,hl			;8be3
	pop hl			;8be4
	ld bc,00002h		;8be5
	push hl			;8be8
	push de			;8be9
	ex de,hl			;8bea
	call copia_patrones_en_espejo		;8beb   ; y la mitad derecha del original a la izquierda del espejo: ese es el cruce
	pop hl			;8bee
	ld bc,00010h		;8bef
	add hl,bc			;8bf2
	ex de,hl			;8bf3
	pop hl			;8bf4
	add hl,bc			;8bf5   ; 0x20 bytes adelante en los dos: el sprite siguiente de los nueve
	add hl,bc			;8bf6
	pop bc			;8bf7
	djnz espeja_nueve_sprites_bucle		;8bf8
	ret			;8bfa
patron_hundiendose:
	bit 7,(ix+006h)		;8bfb   ; bit 7 de IX+0x06: hacia donde mira
	jr nz,patron_hundiendose_izquierda		;8bff
	ld de,0e15eh		;8c01
	ld hl,08e60h		;8c04   ; patrones en crudo de 0x8E40 y 0x8E60, sin comprimir
	ld bc,00020h		;8c07
	ldir		;8c0a
	ld de,0e138h		;8c0c
	ld hl,08e40h		;8c0f
	ld bc,00020h		;8c12
	ldir		;8c15
	jr patron_hundiendose_vram		;8c17
patron_hundiendose_izquierda:
	ld de,0e15eh		;8c19   ; mirando a la izquierda las dos mitades se CRUZAN: a 0xE15E -la columna derecha- va 0x8EE0, que es 0x8E40 con los bits de cada byte del reves
	ld hl,08ee0h		;8c1c
	ld bc,00020h		;8c1f   ; 0x20 bytes: las dos capas de color de esa columna, 16 y 16
	ldir		;8c22
	ld de,0e138h		;8c24   ; y a 0xE138 -la columna izquierda- va 0x8EC0, que es 0x8E60 del reves. Espejar un sprite de 16 de ancho es dar la vuelta a los bits Y cambiar las columnas de sitio
	ld hl,08ec0h		;8c27
	ld bc,00020h		;8c2a
	ldir		;8c2d
patron_hundiendose_vram:
	call borra_parte_del_patron		;8c2f   ; el mordisco se da en RAM, y de ahi va a la VRAM
	push iy		;8c32
	push ix		;8c34
	bit 7,(ix+006h)		;8c36
	jr nz,patron_hundiendose_vram_izquierda		;8c3a
	ld (iy+002h),034h		;8c3c   ; patron 0x34 mirando a la derecha
	ld hl,0e138h		;8c40   ; cuatro trozos de 16 bytes: dos medias columnas por cada capa de color
	ld de,03be0h		;8c43
	ld bc,00010h		;8c46
	call copia_bloque_a_vram		;8c49
	ld hl,0e148h		;8c4c
	ld de,039a0h		;8c4f
	ld bc,00010h		;8c52
	call copia_bloque_a_vram		;8c55
	ld hl,0e15eh		;8c58
	ld de,03bf0h		;8c5b
	ld bc,00010h		;8c5e
	call copia_bloque_a_vram		;8c61
	ld hl,0e16eh		;8c64
	ld de,039b0h		;8c67
	ld bc,00010h		;8c6a
	call copia_bloque_a_vram		;8c6d
	jr patron_hundiendose_vuelve		;8c70
patron_hundiendose_vram_izquierda:
	ld (iy+002h),058h		;8c72   ; mirando a la izquierda las medias columnas son otras: 0x3D00/0x3AC0 y 0x3D10/0x3AD0
	ld hl,0e138h		;8c76   ; 0xE138 es la columna izquierda, y sus dos mitades de 16 son las dos capas: la primera al patron 0xA0 (VRAM 0x3D00) y la segunda al 0x58 (0x3AC0)
	ld de,03d00h		;8c79
	ld bc,00010h		;8c7c
	call copia_bloque_a_vram		;8c7f   ; los cuatro bloques suben ya mordidos: el recorte se lo dio 0x8C2F en la RAM
	ld hl,0e148h		;8c82
	ld de,03ac0h		;8c85
	ld bc,00010h		;8c88
	call copia_bloque_a_vram		;8c8b
	ld hl,0e15eh		;8c8e   ; y 0xE15E es la columna derecha, a las mitades derechas de esos dos mismos patrones
	ld de,03d10h		;8c91
	ld bc,00010h		;8c94
	call copia_bloque_a_vram		;8c97
	ld hl,0e16eh		;8c9a
	ld de,03ad0h		;8c9d
	ld bc,00010h		;8ca0
	call copia_bloque_a_vram		;8ca3
patron_hundiendose_vuelve:
	pop ix		;8ca6
	pop iy		;8ca8
	ret			;8caa
patron_reapareciendo:
	ld de,0e15eh		;8cab   ; los dos patrones de 0x8E80 y 0x8EA0 bajan a RAM, donde si se pueden morder
	ld hl,08ea0h		;8cae
	ld bc,00020h		;8cb1
	ldir		;8cb4
	ld de,0e138h		;8cb6
	ld hl,08e80h		;8cb9
	ld bc,00020h		;8cbc
	ldir		;8cbf
	call borra_parte_del_patron		;8cc1   ; se borra el trozo que toque, que 0x82CC va reduciendo cuadro a cuadro
	push iy		;8cc4
	push ix		;8cc6
	ld (iy+002h),038h		;8cc8   ; patron 0x38, el de mirar a la derecha en el aire
	ld hl,0e138h		;8ccc   ; de la RAM a las cuatro medias columnas: 0x3C00/0x39C0 una capa y 0x3C10/0x39D0 la otra
	ld de,03c00h		;8ccf
	ld bc,00010h		;8cd2
	call copia_bloque_a_vram		;8cd5
	ld hl,0e148h		;8cd8
	ld de,039c0h		;8cdb
	ld bc,00010h		;8cde
	call copia_bloque_a_vram		;8ce1
	ld hl,0e15eh		;8ce4
	ld de,03c10h		;8ce7
	ld bc,00010h		;8cea
	call copia_bloque_a_vram		;8ced
	ld hl,0e16eh		;8cf0
	ld de,039d0h		;8cf3
	ld bc,00010h		;8cf6
	call copia_bloque_a_vram		;8cf9
	pop ix		;8cfc
	pop iy		;8cfe
	ret			;8d00
pinta_los_hoyos:
	ld a,(0e225h)		;8d01
	cp 001h		;8d04   ; el modo 1 es el que lleva hoyos; el 0 pinta el bloque entero
	jr z,pinta_los_hoyos_con_cajas		;8d06
	ld hl,08faah		;8d08
	call pinta_celdas		;8d0b
	ret			;8d0e
pinta_los_hoyos_con_cajas:
	ld hl,08f48h		;8d0f   ; el guion de 0x8F48 pinta los dos hoyos
	call pinta_celdas		;8d12
	push ix		;8d15
	ld ix,0e229h		;8d17
	ld (ix+000h),002h		;8d1b   ; clase 2: por aqui se cae al subterraneo
	ld a,054h		;8d1f   ; dos hoyos de 0x11 de ancho: las cajas van de 0x54 a 0x65 y de 0xA3 a 0xB4, o sea que esos dos numeros son el borde IZQUIERDO, no el centro
	sub 000h		;8d21
	ld (ix+001h),a		;8d23
	ld a,054h		;8d26
	add a,011h		;8d28
	ld (ix+002h),a		;8d2a
	pop ix		;8d2d
	push ix		;8d2f
	ld ix,0e22fh		;8d31   ; la segunda caja, igual pero desde 0xA3
	ld (ix+000h),002h		;8d35
	ld a,0a3h		;8d39
	sub 000h		;8d3b
	ld (ix+001h),a		;8d3d
	ld a,0a3h		;8d40
	add a,011h		;8d42
	ld (ix+002h),a		;8d44
	pop ix		;8d47
	ret			;8d49
pinta_la_escalera_b:
	ld hl,08f06h		;8d4a   ; el mastil, guion 0x8F06: la columna 16 y su cabecera de tres columnas. Es identico en la a y en la b
	call pinta_celdas		;8d4d
	ld hl,0904eh		;8d50   ; lo UNICO que cambia entre las dos: los pilares de 0x904E, los mismos que 0x900C pero con los tiles cambiados de lado
	call pinta_celdas		;8d53
	ld hl,0b08eh		;8d56   ; y el guion 0xB08E, seis celdas del tile blanco: borra el hueco 3x2 donde iria el tesoro
	call pinta_celdas		;8d59
	ret			;8d5c
pinta_la_escalera_a:
	ld hl,08f06h		;8d5d   ; el mismo mastil de la columna 16 que pinta la b
	call pinta_celdas		;8d60
	ld hl,0900ch		;8d63   ; y aqui los pilares de 0x900C, columnas 5-6 y 26-27
	call pinta_celdas		;8d66
	ld hl,0b08eh		;8d69   ; el mismo borrado del hueco del tesoro que hace la b
	call pinta_celdas		;8d6c
	ret			;8d6f
pinta_el_layout:		; Vuelca el decorado: 0x71 bytes en crudo desde la fila 4, una fila de 32 que se repite seis veces, los tramos de las filas 12 y 13 y un guion de celdas
	push hl			;8d70
	ld de,0188fh		;8d71   ; 0x71 bytes a 0x188F, o sea desde la fila 4 columna 15: no son cuatro filas enteras
	ld bc,00071h		;8d74
	call copia_bloque_a_vram		;8d77
	pop hl			;8d7a
	ld de,00071h		;8d7b
	add hl,de			;8d7e
	ld de,01900h		;8d7f
	ld b,006h		;8d82   ; una sola fila que se repite seis veces
pinta_el_layout_filas:
	push bc			;8d84
	push hl			;8d85
	push de			;8d86
	ld bc,00020h		;8d87
	call copia_bloque_a_vram		;8d8a
	pop hl			;8d8d   ; el origen no avanza: solo se corre el destino, 0x20 por vuelta
	ld de,00020h		;8d8e
	add hl,de			;8d91
	ex de,hl			;8d92
	pop hl			;8d93
	pop bc			;8d94
	djnz pinta_el_layout_filas		;8d95
	ld de,00020h		;8d97   ; detras de esa fila vienen los cinco bytes de anchura de la fila 12
	add hl,de			;8d9a
	ld b,005h		;8d9b
	ld de,01980h		;8d9d
pinta_el_layout_fila12:
	push bc			;8da0
	push hl			;8da1
	ld c,(hl)			;8da2   ; el byte del tramo entra como C
	ld b,000h		;8da3
	push bc			;8da5
	push de			;8da6
	ld hl,08e1bh		;8da7   ; el byte del tramo es a la vez desplazamiento, longitud y avance
	add hl,bc			;8daa
	call copia_bloque_a_vram		;8dab   ; se pinta desde 0x1980, y el destino avanza esa misma longitud mas uno
	pop hl			;8dae
	pop de			;8daf
	add hl,de			;8db0
	ex de,hl			;8db1
	inc de			;8db2
	pop hl			;8db3
	inc hl			;8db4
	pop bc			;8db5
	djnz pinta_el_layout_fila12		;8db6
	or a			;8db8   ; HL retrocede cinco: la fila 13 lee LOS MISMOS cinco bytes de anchura
	ld de,00005h		;8db9
	sbc hl,de		;8dbc
	ld b,005h		;8dbe
	ld de,019a0h		;8dc0
pinta_el_layout_fila13:
	push bc			;8dc3
	push hl			;8dc4
	ld c,(hl)			;8dc5
	ld b,000h		;8dc6
	push bc			;8dc8
	push de			;8dc9
	ld hl,08e32h		;8dca   ; pero no los usa como desplazamiento: la fila 13 arranca siempre en 0x8E32 y solo cambia lo larga que es
	call copia_bloque_a_vram		;8dcd
	pop hl			;8dd0
	pop de			;8dd1
	add hl,de			;8dd2
	ex de,hl			;8dd3
	inc de			;8dd4
	pop hl			;8dd5
	inc hl			;8dd6
	pop bc			;8dd7
	djnz pinta_el_layout_fila13		;8dd8
	call pinta_celdas		;8dda   ; y al final, el guion de celdas que cierra el layout
	ret			;8ddd

; ----------------------------------------------------------------------
; El subsuelo de fondo, filas 14 a 22 con un tile fijo por
; franja. Lo pinta el arranque de partida (0x809C) y
; monta_la_escena en TODA escena de tipo 2 a 7 (0x9F04), mas
; al entrar en una de tipo 0 o 1 viniendo de tipo 2 o mayor
; (0x9F0B). Lo unico que no lo repinta es pasar de 0/1 a 0/1.
; ----------------------------------------------------------------------
pinta_el_subsuelo:
	ld hl,01800h		;8dde
	ld de,001c0h		;8de1
	add hl,de			;8de4
	ld de,00040h		;8de5
	ld a,030h		;8de8   ; filas 14-15 al tile 0x30
	call rellena_vram_directo		;8dea
	ld hl,01800h		;8ded
	ld de,00200h		;8df0
	add hl,de			;8df3
	ld de,00040h		;8df4
	ld a,040h		;8df7   ; filas 16-17 al 0x40
	call rellena_vram_directo		;8df9
	ld hl,01800h		;8dfc
	ld de,00240h		;8dff
	add hl,de			;8e02
	ld de,00080h		;8e03
	ld a,02ch		;8e06   ; filas 18-21 al 0x2C
	call rellena_vram_directo		;8e08
	ld hl,01800h		;8e0b
	ld de,002c0h		;8e0e
	add hl,de			;8e11
	ld de,00020h		;8e12
	ld a,048h		;8e15   ; fila 22 al 0x48
	call rellena_vram_directo		;8e17
	ret			;8e1a

; ----------------------------------------------------------------------
; DATOS tabla_tramos_fila12: Veintitres bytes: la rampa de tiles F0..FE,F0..F7
;   de la que salen los tramos de la fila 12 (primera pasada, base cargada en
;   0x8DA7, VRAM 0x1980)
;   0x8e1b..0x8e32  (23 bytes)
DATA_tabla_tramos_fila12:
	defb 0f0h,0f1h,0f2h,0f3h,0f4h,0f5h,0f6h,0f7h,0f8h,0f9h,0fah,0fbh,0fch,0fdh,0feh,0f0h	; 8e1b  ................
	defb 0f1h,0f2h,0f3h,0f4h,0f5h,0f6h,0f7h	; 8e2b

; ----------------------------------------------------------------------
; DATOS tabla_tramos_fila13: Catorce bytes 0xFF, los tramos de la fila 13
;   (segunda pasada). 0x8DCA carga 0x8E32 FIJO y copia tantos bytes como diga
;   el tramo, sin indexar: no lleva el `add hl,bc` que si tiene la fila 12 en
;   0x8DAA. Con el tramo mayor que hay en los cuatro layouts, 0x0A, la lectura
;   mas lejana es 0x8E3B, o sea que nunca llega al sprite de 0x8E40
;   0x8e32..0x8e40  (14 bytes)
DATA_tabla_tramos_fila13:
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 8e32  ..............

; ----------------------------------------------------------------------
; DATOS sprite_hundiendose_derecha_1: La columna IZQUIERDA del jugador mirando
;   a la derecha, con las dos capas de color seguidas: 16 bytes de una y 16 de
;   la otra. La copia 0x8C0F a 0xE138, y de ahi 0x8C43 sube la primera mitad a
;   la VRAM 0x3BE0 y 0x8C4F la segunda a 0x39A0, que son las mitades
;   izquierdas de los patrones 0x7C y 0x34
;   0x8e40..0x8e60  (32 bytes)
DATA_sprite_hundiendose_derecha_1:
	defb 000h,000h,000h,000h,003h,003h,003h,000h	; 8e40  ........
	defb 003h,007h,00eh,00dh,006h,007h,002h,003h	; 8e48  ........
	defb 003h,003h,001h,001h,001h,001h,001h,001h	; 8e50  ........
	defb 001h,001h,000h,000h,000h,000h,000h,000h	; 8e58  ........

; ----------------------------------------------------------------------
; DATOS sprite_hundiendose_derecha_2: La columna DERECHA de la misma pose,
;   otra vez con las dos capas seguidas. La copia 0x8C04 a 0xE15E, y 0x8C5B y
;   0x8C67 suben sus mitades a 0x3BF0 y 0x39B0, las mitades derechas de esos
;   dos mismos patrones
;   0x8e60..0x8e80  (32 bytes)
DATA_sprite_hundiendose_derecha_2:
	defb 000h,000h,000h,000h,0c0h,000h,000h,000h	; 8e60  ........
	defb 080h,0c0h,0c0h,0c0h,0d0h,0d0h,040h,0c0h	; 8e68  ......@.
	defb 0c0h,0c0h,0c0h,0c0h,0c0h,0c0h,0c0h,070h	; 8e70  .......p
	defb 000h,0c0h,000h,000h,000h,000h,000h,000h	; 8e78  ........

; ----------------------------------------------------------------------
; DATOS sprite_hundiendose_3: La columna izquierda de la tercera pose, la que
;   carga 0x8CB9 a 0xE138
;   0x8e80..0x8ea0  (32 bytes)
DATA_sprite_hundiendose_3:
	defb 000h,000h,000h,000h,000h,003h,003h,003h	; 8e80  ........
	defb 000h,00fh,03fh,073h,063h,063h,003h,023h	; 8e88  ..?scc.#
	defb 003h,0e7h,03eh,018h,000h,000h,000h,000h	; 8e90  ..>.....
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; 8e98  ........

; ----------------------------------------------------------------------
; DATOS sprite_hundiendose_4: La columna derecha de esa pose, que carga 0x8CAE
;   a 0xE15E
;   0x8ea0..0x8ec0  (32 bytes)
DATA_sprite_hundiendose_4:
	defb 000h,000h,000h,000h,000h,0c0h,000h,000h	; 8ea0  ........
	defb 000h,0c0h,0e0h,062h,0beh,09ch,0c0h,0c0h	; 8ea8  ...b....
	defb 0f8h,018h,018h,01eh,000h,000h,000h,000h	; 8eb0  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; 8eb8  ........

; ----------------------------------------------------------------------
; DATOS sprite_hundiendose_izquierda_1: El espejo de 0x8E60 dandole la vuelta
;   a los bits de cada byte, y falla en uno solo de los 32 (el byte 23 vale
;   0x0F donde saldria 0x0E). La copia 0x8C27 a 0xE138, y 0x8330 sube sus dos
;   mitades a la VRAM 0x3D00 y 0x3AC0
;   0x8ec0..0x8ee0  (32 bytes)
DATA_sprite_hundiendose_izquierda_1:
	defb 000h,000h,000h,000h,003h,000h,000h,000h	; 8ec0  ........
	defb 001h,003h,003h,003h,00bh,00bh,002h,003h	; 8ec8  ........
	defb 003h,003h,003h,003h,003h,003h,003h,00fh	; 8ed0  ........
	defb 000h,003h,000h,000h,000h,000h,000h,000h	; 8ed8  ........

; ----------------------------------------------------------------------
; DATOS sprite_hundiendose_izquierda_2: El espejo de 0x8E40 con los bits de
;   cada byte del reves, y este EXACTO: los 32 bytes. La copia 0x8C1C a
;   0xE15E, y 0x8348 sube sus mitades a 0x3D10 y 0x3AD0
;   0x8ee0..0x8f00  (32 bytes)
DATA_sprite_hundiendose_izquierda_2:
	defb 000h,000h,000h,000h,0c0h,0c0h,0c0h,000h	; 8ee0  ........
	defb 0c0h,0e0h,070h,0b0h,060h,0e0h,040h,0c0h	; 8ee8  ..p.`.@.
	defb 0c0h,0c0h,080h,080h,080h,080h,080h,080h	; 8ef0  ........
	defb 080h,080h,000h,000h,000h,000h,000h,000h	; 8ef8  ........

; ----------------------------------------------------------------------
; DATOS reloj_inicial_duplicado: Los mismos cinco tiles del reloj de salida
;   que hay en 0x8A69 -BA B8 C2 B8 B8, que se lee "20:00"- pero con 0x00
;   detras en vez del divisor 0x3C. Nadie lo copia: la unica palabra del
;   cartucho que vale 0x8F00 esta en 0xA3A3, dentro de una tabla de patrones,
;   o sea que es coincidencia de bytes y no un puntero. Una segunda copia que
;   se quedo sin usar
;   0x8f00..0x8f06  (6 bytes)
DATA_reloj_inicial_duplicado:
	defb 0bah,0b8h,0c2h,0b8h,0b8h,000h	; 8f00

; ----------------------------------------------------------------------
; DATOS guion_celdas_columna: Guion de 16 celdas: cabecera de tres columnas
;   (15-17) en las filas 14-17 y un mastil de UNA sola columna, la 16, con el
;   tile 0x20, en las filas 18-21. Tiles 0x20-0x36. Lo llaman 0x8D4D y 0x8D60
;   0x8f06..0x8f48  (66 bytes)
DATA_guion_celdas_columna:
	defb 010h,000h,0cfh,001h,031h,000h,0d0h,001h,033h,000h,0d1h,001h,034h,000h,0efh,001h	; 8f06  ....1...3...4...
	defb 032h,000h,0f0h,001h,036h,000h,0f1h,001h,035h,000h,010h,002h,020h,000h,030h,002h	; 8f16  2...6...5... .0.
	defb 020h,000h,050h,002h,020h,000h,070h,002h,020h,000h,090h,002h,020h,000h,0b0h,002h	; 8f26   .P. .p. ... ...
	defb 020h,000h,00fh,002h,028h,000h,02fh,002h,028h,000h,011h,002h,029h,000h,031h,002h	; 8f36   ...(./.(...).1.
	defb 029h,000h	; 8f46

; ----------------------------------------------------------------------
; DATOS guion_celdas_bloque_a: Guion de 24 celdas: DOS bloques de 3 columnas
;   por 4 filas, en las filas 14-17 y las columnas 10-12 y 20-22. El centro,
;   de la 13 a la 19, no se toca. Tiles 0x2A-0x56. Lo llama 0x8D12
;   0x8f48..0x8faa  (98 bytes)
DATA_guion_celdas_bloque_a:
	defb 018h,000h,0cah,001h,037h,000h,0cbh,001h,033h,000h,0cch,001h,053h,000h,0eah,001h	; 8f48  ....7...3...S...
	defb 050h,000h,0ebh,001h,036h,000h,0ech,001h,054h,000h,0d4h,001h,055h,000h,0d5h,001h	; 8f58  P...6...T...U...
	defb 033h,000h,0d6h,001h,051h,000h,0f4h,001h,056h,000h,0f5h,001h,036h,000h,0f6h,001h	; 8f68  3...Q...V...6...
	defb 052h,000h,00ah,002h,02ah,000h,00bh,002h,02ch,000h,00ch,002h,02bh,000h,02ah,002h	; 8f78  R...*...,...+.*.
	defb 02ah,000h,02bh,002h,02ch,000h,02ch,002h,02bh,000h,014h,002h,02ah,000h,015h,002h	; 8f88  *.+.,.,.+...*...
	defb 02ch,000h,016h,002h,02bh,000h,034h,002h,02ah,000h,035h,002h,02ch,000h,036h,002h	; 8f98  ,...+.4.*.5.,.6.
	defb 02bh,000h	; 8fa8

; ----------------------------------------------------------------------
; DATOS guion_celdas_bloque_b: Los mismos dos bloques de 3x4 en las columnas
;   10-12 y 20-22, con el tile 0x30 arriba y el 0x40 abajo. Lo llama 0x8D0B
;   0x8faa..0x900c  (98 bytes)
DATA_guion_celdas_bloque_b:
	defb 018h,000h,0cah,001h,030h,000h,0cbh,001h,030h,000h,0cch,001h,030h,000h,0eah,001h	; 8faa  ....0...0...0...
	defb 030h,000h,0ebh,001h,030h,000h,0ech,001h,030h,000h,0d4h,001h,030h,000h,0d5h,001h	; 8fba  0...0...0...0...
	defb 030h,000h,0d6h,001h,030h,000h,0f4h,001h,030h,000h,0f5h,001h,030h,000h,0f6h,001h	; 8fca  0...0...0...0...
	defb 030h,000h,00ah,002h,040h,000h,00bh,002h,040h,000h,00ch,002h,040h,000h,02ah,002h	; 8fda  0...@...@...@.*.
	defb 040h,000h,02bh,002h,040h,000h,02ch,002h,040h,000h,014h,002h,040h,000h,015h,002h	; 8fea  @.+.@.,.@...@...
	defb 040h,000h,016h,002h,040h,000h,034h,002h,040h,000h,035h,002h,040h,000h,036h,002h	; 8ffa  @...@.4.@.5.@.6.
	defb 040h,000h	; 900a

; ----------------------------------------------------------------------
; DATOS guion_celdas_pilares_a: Guion de 16 celdas: dos pilares de dos
;   columnas de ancho en las filas 18-21, columnas 5-6 y 26-27. No es una
;   franja que cruce la pantalla: entre los dos pilares no se pinta nada.
;   Tiles 0x18/0x19/0x1A a la derecha y 0x2C a la izquierda. Lo llama 0x8D66
;   0x900c..0x904e  (66 bytes)
DATA_guion_celdas_pilares_a:
	defb 010h,000h,05ah,002h,018h,000h,05bh,002h,018h,000h,07ah,002h,019h,000h,07bh,002h	; 900c  ..Z...[...z...{.
	defb 019h,000h,09ah,002h,01ah,000h,09bh,002h,01ah,000h,0bah,002h,018h,000h,0bbh,002h	; 901c  ................
	defb 018h,000h,045h,002h,02ch,000h,046h,002h,02ch,000h,065h,002h,02ch,000h,066h,002h	; 902c  ..E.,.F.,.e.,.f.
	defb 02ch,000h,085h,002h,02ch,000h,086h,002h,02ch,000h,0a5h,002h,02ch,000h,0a6h,002h	; 903c  ,...,...,...,...
	defb 02ch,000h	; 904c

; ----------------------------------------------------------------------
; DATOS guion_celdas_pilares_b: Los mismos dos pilares con los tiles cambiados
;   de lado. Lo llama 0x8D53
;   0x904e..0x9090  (66 bytes)
DATA_guion_celdas_pilares_b:
	defb 010h,000h,045h,002h,018h,000h,046h,002h,018h,000h,065h,002h,019h,000h,066h,002h	; 904e  ..E...F...e...f.
	defb 019h,000h,085h,002h,01ah,000h,086h,002h,01ah,000h,0a5h,002h,018h,000h,0a6h,002h	; 905e  ................
	defb 018h,000h,05ah,002h,02ch,000h,05bh,002h,02ch,000h,07ah,002h,02ch,000h,07bh,002h	; 906e  ..Z.,.[.,.z.,.{.
	defb 02ch,000h,09ah,002h,02ch,000h,09bh,002h,02ch,000h,0bah,002h,02ch,000h,0bbh,002h	; 907e  ,...,...,...,...
	defb 02ch,000h	; 908e

; ----------------------------------------------------------------------
; DATOS fila_de_tiles_23: Catorce numeros de tile en crudo que 0x8B51-0x8B5A
;   copia con B1C3 a la VRAM 0x1AE2, o sea la fila 23 del name table, columnas
;   2-15
;   0x9090..0x909e  (14 bytes)
DATA_fila_de_tiles_23:
	defb 0c8h,0c9h,0cah,0cbh,0cch,0cdh,0ceh,0cfh,0d0h,0d1h,0d2h,0d3h,0d4h,0d5h	; 9090  ..............

; ----------------------------------------------------------------------
; DATOS grafico_rle_tiles_a: Bloque RLE para B142: 360 bytes descomprimidos a
;   la VRAM desde 0x0000, el principio de la tabla de patrones. Lo carga
;   0x8B15
;   0x909e..0x915b  (189 bytes)
DATA_grafico_rle_tiles_a:
	defb 000h,000h,008h,0fch,0b8h,008h,000h,008h,03fh,050h,030h,030h,070h,0e0h,0c0h,080h	; 909e  ........?P00p...
	defb 000h,000h,00ch,00ch,00eh,007h,003h,001h,000h,000h,0a0h,054h,0e0h,070h,030h,030h	; 90ae  ...........T.p00
	defb 03ch,03fh,03fh,007h,030h,030h,060h,0e0h,0c0h,080h,000h,000h,0e0h,07fh,00fh,003h	; 90be  <??.00`.........
	defb 005h,000h,042h,080h,0e0h,004h,0ffh,041h,00fh,0a0h,058h,0dfh,0dfh,000h,0fbh,0fbh	; 90ce  ..B....A..X.....
	defb 000h,0dfh,0dfh,000h,0fbh,0fbh,000h,0dfh,0dfh,000h,0fbh,0fbh,000h,0dfh,0dfh,000h	; 90de  ................
	defb 0fbh,0fbh,000h,0a8h,048h,0ffh,0ffh,000h,000h,0ffh,0ffh,000h,000h,0b8h,008h,0f8h	; 90ee  ....H...........
	defb 008h,01fh,008h,0e0h,008h,007h,008h,000h,098h,00dh,000h,006h,007h,00ah,000h,003h	; 90fe  ................
	defb 0ffh,005h,000h,006h,0e0h,005h,000h,003h,0ffh,00ah,000h,003h,01fh,00bh,000h,045h	; 910e  ...............E
	defb 080h,0c0h,0f0h,0f8h,0f8h,0b0h,008h,000h,0b8h,006h,000h,002h,0ffh,0b8h,003h,01fh	; 911e  ................
	defb 00ah,000h,006h,0f8h,00ah,000h,006h,0f8h,00ah,000h,006h,01fh,01bh,000h,042h,007h	; 912e  ..............B.
	defb 0ffh,005h,000h,043h,00fh,0ffh,0ffh,004h,000h,044h,01fh,0ffh,0ffh,0ffh,003h,000h	; 913e  ...C.....D......
	defb 041h,03fh,004h,0ffh,005h,000h,003h,0ffh,004h,000h,004h,0ffh,000h	; 914e  A?...........

; ----------------------------------------------------------------------
; DATOS grafico_rle_tiles_b: Bloque RLE para B142: 760 bytes a la VRAM desde
;   0x0480, mas patrones de la tabla de tiles. Lo carga 0x8B1B
;   0x915b..0x939d  (578 bytes)
DATA_grafico_rle_tiles_b:
	defb 080h,004h,043h,000h,000h,001h,007h,000h,046h,0f0h,03ch,01eh,00eh,00eh,01ch,009h	; 915b  ..C.....F.<.....
	defb 000h,04eh,003h,007h,000h,007h,000h,007h,000h,0f0h,0c0h,0fch,000h,0fch,000h,0ffh	; 916b  .N..............
	defb 005h,000h,003h,080h,017h,000h,042h,001h,006h,004h,000h,044h,01fh,060h,081h,006h	; 917b  ......B....D.`..
	defb 004h,000h,048h,0f0h,070h,0b0h,030h,00fh,008h,008h,00fh,004h,000h,044h,0f8h,008h	; 918b  ..H.p.0......D..
	defb 00bh,0fch,004h,000h,042h,060h,080h,01bh,000h,042h,001h,007h,004h,000h,044h,020h	; 919b  ....B`...B....D 
	defb 0feh,0e7h,001h,007h,000h,041h,0c0h,02dh,000h,041h,001h,005h,000h,046h,030h,030h	; 91ab  .....A.-.A...F00
	defb 000h,0c3h,024h,07eh,004h,000h,048h,080h,000h,000h,000h,001h,003h,003h,001h,004h	; 91bb  ..$~..H.........
	defb 000h,04ch,0c3h,000h,000h,0c3h,07eh,018h,000h,000h,080h,0c0h,0c0h,080h,004h,000h	; 91cb  .L....~.........
	defb 044h,080h,0c0h,0c0h,080h,012h,000h,04ah,003h,003h,000h,0e7h,03ch,018h,03ch,0e7h	; 91db  D......J....<.<.
	defb 0e7h,001h,006h,000h,002h,0c0h,005h,007h,04bh,003h,001h,000h,03fh,001h,0f8h,0f8h	; 91eb  ........K...?...
	defb 001h,0e7h,0ffh,000h,005h,0e0h,042h,0c0h,080h,011h,000h,041h,038h,006h,0c6h,043h	; 91fb  ......B....A8..C
	defb 038h,018h,038h,005h,018h,056h,07eh,07ch,0c6h,006h,00ch,018h,030h,060h,0feh,07ch	; 920b  8.8..V~|....0`.|
	defb 0c6h,006h,01ch,01eh,006h,0c6h,07ch,01eh,036h,066h,0c6h,0feh,003h,006h,054h,0feh	; 921b  ......|.6f....T.
	defb 0c0h,0c0h,07ch,006h,006h,0c6h,07ch,07ch,0c6h,0c0h,0fch,0c6h,0c6h,0c6h,07ch,0feh	; 922b  ..|...||......|.
	defb 006h,00ch,018h,004h,030h,057h,07ch,0c6h,0c6h,07ch,0c6h,0c6h,0c6h,07ch,07ch,0c6h	; 923b  ....0W|..|...||.
	defb 0c6h,07eh,006h,006h,0c6h,07ch,000h,038h,038h,000h,000h,038h,038h,016h,000h,043h	; 924b  .~...|.88..88..C
	defb 030h,030h,0e0h,005h,000h,043h,008h,060h,000h,0b8h,0b8h,098h,05ch,000h,020h,010h	; 925b  00...C.`....\. .
	defb 000h,0c0h,060h,00ch,000h,001h,000h,000h,01ch,020h,000h,001h,000h,000h,0e0h,000h	; 926b  ..`...... ......
	defb 000h,003h,000h,0c0h,000h,008h,008h,010h,060h,006h,000h,055h,040h,020h,00ah,000h	; 927b  ........`..U@ ..
	defb 080h,070h,000h,000h,000h,040h,000h,041h,034h,000h,000h,000h,020h,004h,080h,000h	; 928b  .p...@.A4... ...
	defb 005h,005h,000h,064h,008h,010h,000h,010h,000h,000h,040h,020h,01ch,001h,088h,040h	; 929b  ...d......@ ...@
	defb 000h,000h,060h,018h,005h,080h,018h,007h,000h,020h,010h,006h,0a0h,000h,008h,0c5h	; 92ab  ..`...... ......
	defb 040h,020h,001h,001h,002h,00ch,060h,040h,05dh,000h,020h,010h,005h,080h,081h,024h	; 92bb  @ ....`@]. ....$
	defb 000h,000h,008h,004h,041h,000h,088h,002h,000h,000h,010h,022h,001h,000h,010h,040h	; 92cb  ....A......"...@
	defb 000h,080h,000h,004h,010h,040h,005h,000h,05eh,040h,020h,00eh,000h,000h,007h,000h	; 92db  .....@..^@ .....
	defb 040h,020h,003h,018h,000h,085h,051h,008h,006h,040h,000h,030h,000h,040h,081h,000h	; 92eb  @ ....Q..@.0.@..
	defb 000h,0a0h,000h,002h,004h,020h,080h,05bh,000h,0c0h,010h,003h,000h,000h,040h,030h	; 92fb  ..... .[......@0
	defb 004h,000h,001h,000h,000h,000h,006h,000h,000h,008h,080h,000h,000h,005h,000h,000h	; 930b  ................
	defb 000h,020h,010h,006h,000h,05fh,00ch,0fbh,0dfh,0bfh,0ffh,0ffh,0ffh,000h,0e0h,0e8h	; 931b  . ..._..........
	defb 0feh,03fh,0fbh,0ffh,0ffh,001h,003h,003h,067h,0fdh,0bfh,0efh,0ffh,0c0h,0c0h,0e0h	; 932b  .?......g.......
	defb 060h,0f0h,0f8h,0fch,0efh,070h,000h,001h,00fh,03fh,037h,0efh,0fbh,0ffh,000h,000h	; 933b  `....p...?7.....
	defb 038h,0bfh,0f9h,03fh,0f7h,0ffh,000h,020h,0e0h,0f8h,0cch,0feh,0f6h,0fbh,000h,000h	; 934b  8..?... ........
	defb 000h,030h,038h,068h,0dch,0fdh,000h,000h,001h,001h,031h,0f3h,0bfh,0f9h,008h,0ceh	; 935b  .08h......1.....
	defb 0feh,0fbh,0b7h,0bfh,0ffh,0ffh,068h,000h,00ch,01ch,09fh,0bfh,0fdh,07fh,0bfh,000h	; 936b  ......h.........
	defb 003h,007h,08fh,0cdh,0fdh,0dfh,0efh,00ch,01eh,0bfh,0efh,0dfh,0fdh,0feh,0ffh,004h	; 937b  ................
	defb 00eh,08eh,08bh,09fh,0d7h,0ffh,0ffh,000h,000h,0c0h,0c1h,0e3h,0e2h,0bbh,0efh,008h	; 938b  ................
	defb 0ffh,000h	; 939b

; ----------------------------------------------------------------------
; DATOS grafico_rle_sprites_a: Bloque RLE para B142: 416 bytes a la VRAM desde
;   0x3880, dentro de la tabla de patrones de sprites (0x3800-0x3FFF). Lo
;   carga 0x8B5E
;   0x939d..0x9473  (214 bytes)
DATA_grafico_rle_sprites_a:
	defb 080h,038h,005h,000h,002h,0ffh,00eh,000h,042h,0ffh,0feh,010h,000h,002h,0ffh,00eh	; 939d  .8......B.......
	defb 000h,042h,0fch,0f8h,010h,000h,002h,0ffh,00eh,000h,042h,0f0h,0e0h,010h,000h,041h	; 93ad  .B........B....A
	defb 0ffh,00fh,000h,041h,0c0h,004h,000h,048h,001h,003h,003h,007h,0feh,0f8h,080h,080h	; 93bd  ...A...H........
	defb 008h,000h,044h,0e0h,0f0h,0f8h,01ch,004h,00ch,041h,00fh,007h,000h,049h,003h,003h	; 93cd  ..D......A...I..
	defb 001h,001h,003h,007h,01eh,018h,010h,007h,000h,045h,0c0h,0c0h,0e0h,0e0h,070h,004h	; 93dd  .........E....p.
	defb 030h,041h,03ch,006h,000h,04ah,003h,003h,001h,001h,001h,00fh,00dh,009h,001h,001h	; 93ed  0A<..J..........
	defb 006h,000h,04ah,0c0h,0e0h,0f0h,0f0h,0e0h,0c0h,080h,080h,080h,0e0h,006h,000h,004h	; 93fd  ..J.............
	defb 003h,046h,007h,006h,00ch,018h,018h,01ch,006h,000h,047h,0c0h,0f8h,0fch,00ch,00ch	; 940d  .F........G.....
	defb 00ch,00eh,009h,000h,049h,003h,003h,007h,006h,00eh,01ch,070h,040h,040h,007h,000h	; 941d  ....I......p@@..
	defb 048h,0c0h,0e0h,0f0h,038h,018h,018h,018h,01eh,008h,000h,002h,003h,008h,001h,006h	; 942d  H...8...........
	defb 000h,007h,0c0h,043h,070h,000h,0c0h,006h,000h,044h,003h,0e7h,03eh,018h,00ch,000h	; 943d  ...Cp....D..>...
	defb 044h,0f8h,018h,018h,01eh,00ch,000h,048h,007h,00fh,01fh,018h,00ch,006h,006h,01eh	; 944d  D......H........
	defb 008h,000h,00bh,0c0h,041h,0f0h,004h,000h,043h,07fh,07eh,038h,00dh,000h,044h,0e0h	; 945d  ....A...C.~8..D.
	defb 038h,00fh,006h,00ch,000h,000h	; 946d

; ----------------------------------------------------------------------
; DATOS grafico_rle_sprites_b: Bloque RLE para B142: 288 bytes a la VRAM desde
;   0x3B40, mas patrones de sprites. Lo carga 0x8B6F
;   0x9473..0x956a  (247 bytes)
DATA_grafico_rle_sprites_b:
	defb 040h,03bh,004h,000h,003h,001h,049h,000h,003h,00fh,00dh,00dh,00dh,005h,001h,001h	; 9473  @;....I.........
	defb 004h,000h,04ch,0e0h,080h,080h,000h,0c0h,0e0h,0e0h,0e0h,0f8h,0f8h,0e0h,0e0h,004h	; 9483  ..L.............
	defb 000h,003h,001h,049h,000h,003h,007h,00eh,00dh,007h,003h,002h,003h,004h,000h,044h	; 9493  ...I...........D
	defb 0e0h,080h,080h,000h,004h,0c0h,044h,0e0h,0e0h,040h,0c0h,004h,000h,003h,001h,049h	; 94a3  ......D..@.....I
	defb 000h,001h,003h,003h,007h,007h,003h,002h,003h,004h,000h,045h,0e0h,080h,080h,000h	; 94b3  ...........E....
	defb 0c0h,005h,0e0h,042h,040h,0c0h,004h,000h,003h,001h,049h,000h,003h,00eh,01fh,01bh	; 94c3  ...B@.....I.....
	defb 01bh,01bh,00bh,003h,004h,000h,04ch,0e0h,080h,080h,000h,0c0h,0e0h,0e0h,0e0h,0f8h	; 94d3  ......L.........
	defb 0f0h,0c0h,0c0h,004h,000h,003h,001h,049h,000h,007h,01fh,039h,033h,033h,023h,003h	; 94e3  .......I...933#.
	defb 003h,004h,000h,049h,0e0h,080h,080h,000h,0e0h,0e0h,0f0h,0deh,0cch,003h,0c0h,004h	; 94f3  ...I............
	defb 000h,003h,003h,049h,000h,003h,007h,00eh,00dh,006h,007h,002h,003h,004h,000h,041h	; 9503  ...I...........A
	defb 0c0h,003h,000h,048h,080h,0c0h,0c0h,0c0h,0d0h,0d0h,040h,0c0h,005h,000h,003h,003h	; 9513  ...H......@.....
	defb 048h,000h,00fh,03eh,073h,063h,063h,003h,003h,005h,000h,04bh,0c0h,000h,000h,000h	; 9523  H..>scc....K....
	defb 0c0h,0e0h,062h,0beh,09ch,0c0h,0c0h,006h,000h,04ah,001h,003h,003h,018h,019h,01fh	; 9533  ..b......J......
	defb 00fh,007h,003h,003h,006h,000h,04ah,080h,0c0h,0c0h,000h,080h,0e0h,0f0h,0f0h,0e0h	; 9543  ......J.........
	defb 0c0h,004h,000h,048h,0f0h,0c0h,0c0h,000h,0f0h,0ffh,0cfh,0e0h,004h,0f0h,006h,000h	; 9553  ...H............
	defb 004h,0c0h,041h,080h,005h,000h,000h	; 9563

; ----------------------------------------------------------------------
; DATOS grafico_rle_sprites_c: Bloque RLE para B142: 288 bytes a la VRAM desde
;   0x3D80, mas patrones de sprites. Lo carga 0x8B80
;   0x956a..0x95fe  (148 bytes)
DATA_grafico_rle_sprites_c:
	defb 080h,03dh,007h,000h,041h,001h,005h,000h,041h,008h,007h,000h,047h,060h,060h,0c0h	; 956a  .=..A...A...G``.
	defb 000h,000h,000h,004h,00bh,000h,041h,001h,006h,000h,041h,001h,006h,000h,043h,060h	; 957a  ......A...A...C`
	defb 060h,0c0h,005h,000h,042h,010h,080h,008h,000h,041h,001h,006h,000h,041h,001h,006h	; 958a  `...B....A...A..
	defb 000h,043h,060h,060h,0c0h,006h,000h,041h,080h,008h,000h,041h,001h,006h,000h,041h	; 959a  .C``...A...A...A
	defb 010h,006h,000h,047h,060h,060h,0c0h,000h,000h,000h,004h,00bh,000h,041h,001h,005h	; 95aa  ...G``.......A..
	defb 000h,041h,010h,007h,000h,046h,060h,060h,0c0h,000h,000h,001h,00ch,000h,041h,003h	; 95ba  .A...F``......A.
	defb 006h,000h,041h,001h,006h,000h,043h,0c0h,0c0h,080h,005h,000h,042h,008h,080h,009h	; 95ca  ..A...C.....B...
	defb 000h,041h,003h,005h,000h,041h,060h,007h,000h,045h,0c0h,0c0h,080h,000h,001h,00ch	; 95da  .A...A`..E......
	defb 000h,043h,001h,00dh,001h,00dh,000h,043h,080h,0c0h,080h,00bh,000h,043h,030h,030h	; 95ea  .C.....C.....C00
	defb 0e0h,018h,000h,000h	; 95fa

; ----------------------------------------------------------------------
; DATOS tiles_decorado_3: 128 bytes: 16 patrones de tile en crudo, la entrada
;   [3] de la tabla 0xA086. Se copian a la VRAM 0x0380 con B1C3
;   0x95fe..0x967e  (128 bytes)
DATA_tiles_decorado_3:
	defb 0ffh,0ffh,01fh,007h,000h,000h,000h,000h	; 95fe  ........
	defb 0ffh,0ffh,0ffh,0ffh,0f8h,000h,000h,000h	; 9606  ........
	defb 0ffh,0ffh,0ffh,0f0h,000h,000h,000h,000h	; 960e  ........
	defb 0ffh,0f8h,0f8h,000h,000h,000h,000h,000h	; 9616  ........
	defb 0f0h,01fh,003h,000h,000h,000h,000h,000h	; 961e  ........
	defb 0ffh,0ffh,0ffh,07eh,000h,000h,000h,000h	; 9626  ...~....
	defb 0ffh,0c0h,0c0h,000h,000h,000h,000h,000h	; 962e  ........
	defb 0ffh,0ffh,03fh,00fh,00fh,00fh,003h,003h	; 9636  ..?.....
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 963e  ........
	defb 0ffh,0ffh,0cch,0b0h,0c0h,080h,000h,000h	; 9646  ........
	defb 007h,007h,000h,000h,000h,000h,000h,000h	; 964e  ........
	defb 0ffh,0ffh,03fh,03fh,03fh,00fh,003h,003h	; 9656  ..???...
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 965e  ........
	defb 0ffh,0ffh,0f3h,0e7h,0fdh,0ffh,0f7h,0f0h	; 9666  ........
	defb 0feh,0feh,0f8h,0f8h,0f0h,0f0h,080h,000h	; 966e  ........
	defb 00fh,000h,000h,000h,000h,000h,000h,000h	; 9676  ........

; ----------------------------------------------------------------------
; DATOS tiles_decorado_2: 128 bytes, la entrada [2] de la tabla 0xA086
;   0x967e..0x96fe  (128 bytes)
DATA_tiles_decorado_2:
	defb 007h,000h,000h,000h,000h,000h,000h,000h	; 967e  ........
	defb 0ffh,03fh,007h,000h,000h,000h,000h,000h	; 9686  .?......
	defb 0ffh,0ffh,0e7h,0ffh,0ffh,0ffh,01ch,000h	; 968e  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,01fh,000h	; 9696  ........
	defb 0e7h,0f3h,0ffh,0ffh,0ffh,0ffh,0ffh,03fh	; 969e  .......?
	defb 0ffh,0ffh,0ffh,0efh,09fh,0fch,0f8h,0e0h	; 96a6  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,03fh,00fh,003h	; 96ae  .....?..
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 96b6  ........
	defb 0ffh,0efh,0dfh,0dfh,0ffh,0ffh,0fch,0f0h	; 96be  ........
	defb 0fch,0f0h,0c0h,0c0h,0c0h,080h,000h,000h	; 96c6  ........
	defb 003h,003h,000h,000h,000h,000h,000h,000h	; 96ce  ........
	defb 0ffh,0ffh,03fh,03fh,003h,003h,000h,000h	; 96d6  ..??....
	defb 0ffh,0c7h,0e7h,0ffh,0ffh,0ffh,03fh,03fh	; 96de  ......??
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 96e6  ........
	defb 0ffh,0ffh,0ffh,0fdh,0e7h,0fch,0fch,0c0h	; 96ee  ........
	defb 0ffh,0ffh,0f8h,0f0h,080h,000h,000h,000h	; 96f6  ........

; ----------------------------------------------------------------------
; DATOS tiles_decorado_0: 128 bytes, la entrada [0] de la tabla 0xA086
;   0x96fe..0x977e  (128 bytes)
DATA_tiles_decorado_0:
	defb 0ffh,0ffh,0ffh,0ffh,0e0h,0e0h,080h,080h	; 96fe  ........
	defb 0ffh,0ffh,09fh,0f7h,0ffh,003h,003h,000h	; 9706  ........
	defb 0ffh,0ffh,0ffh,0ffh,0f7h,0efh,0ffh,0fch	; 970e  ........
	defb 0ffh,0ffh,0ffh,0bfh,0e7h,0ffh,0ffh,03fh	; 9716  .......?
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 971e  ........
	defb 0ffh,0ffh,0ffh,0f7h,0cfh,0ffh,0fch,0e0h	; 9726  ........
	defb 0ffh,0ffh,0ffh,0fch,0fch,0f0h,000h,000h	; 972e  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; 9736  ........
	defb 01fh,007h,007h,000h,000h,000h,000h,000h	; 973e  ........
	defb 0ffh,0efh,0cfh,0ffh,0ffh,007h,007h,003h	; 9746  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 974e  ........
	defb 0ffh,0ffh,0bfh,0ffh,0efh,0ffh,0cfh,00fh	; 9756  ........
	defb 0ffh,0ffh,0ffh,0ffh,0dfh,0ffh,0f0h,0e0h	; 975e  ........
	defb 0ffh,0fbh,09fh,0ffh,00fh,003h,003h,000h	; 9766  ........
	defb 0ffh,0f7h,0feh,0f8h,0f0h,0f0h,0c0h,000h	; 976e  ........
	defb 0ffh,0e0h,000h,000h,000h,000h,000h,000h	; 9776  ........

; ----------------------------------------------------------------------
; DATOS tiles_decorado_1: 128 bytes, la entrada [1] de la tabla 0xA086
;   0x977e..0x97fe  (128 bytes)
DATA_tiles_decorado_1:
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,00fh,000h	; 977e  ........
	defb 0ffh,0f8h,0f0h,0f0h,0c0h,000h,000h,000h	; 9786  ........
	defb 001h,000h,000h,000h,000h,000h,000h,000h	; 978e  ........
	defb 0ffh,03fh,03fh,003h,003h,000h,000h,000h	; 9796  .??.....
	defb 0ffh,0ffh,0efh,0f7h,0ffh,0ffh,0f1h,001h	; 979e  ........
	defb 0ffh,0ffh,0f7h,0e7h,0edh,0f6h,0f1h,0e0h	; 97a6  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 97ae  ........
	defb 0ffh,09fh,0fdh,0f3h,0ffh,0ffh,0f7h,0f3h	; 97b6  ........
	defb 0fch,0fch,0fch,0f0h,0c0h,0c0h,080h,000h	; 97be  ........
	defb 0ffh,07fh,007h,007h,001h,001h,001h,000h	; 97c6  ........
	defb 0ffh,0ffh,0ffh,0bfh,0ffh,0ffh,0ffh,03eh	; 97ce  .......>
	defb 0ffh,09fh,0ffh,0f9h,0ffh,0cfh,083h,003h	; 97d6  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 97de  ........
	defb 0ffh,0ffh,0ffh,0ffh,0f9h,0ffh,083h,000h	; 97e6  ........
	defb 0ffh,0ffh,0ffh,0e7h,0c0h,0c0h,080h,000h	; 97ee  ........
	defb 0ffh,0ffh,0ffh,0ebh,0ffh,007h,000h,000h	; 97f6  ........

; ----------------------------------------------------------------------
; DATOS patron_de_sprite_relleno: Un patron de sprite de 32 bytes en crudo,
;   que empieza por FF FF: 0xA002-0xA023 lo copia tal cual con B1C3 a TRES
;   huecos de la tabla de sprites, 0x3C20, 0x3D40 y 0x3E60
;   0x97fe..0x981e  (32 bytes)
DATA_patron_de_sprite_relleno:
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 97fe  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9806  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 980e  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9816  ........

; ----------------------------------------------------------------------
; DATOS sprites_rle_1: Bloque RLE para B142: 64 bytes a la VRAM 0x3FC0 (los
;   dos ultimos patrones de sprite). Lo carga 0xAB57
;   0x981e..0x9850  (50 bytes)
DATA_sprites_rle_1:
	defb 0c0h,03fh,005h,000h,046h,001h,007h,01fh,000h,07fh,07fh,00ah,000h,046h,0f8h,0e4h	; 981e  .?..F........F..
	defb 09ch,078h,070h,040h,005h,000h,04bh,001h,012h,020h,010h,080h,041h,007h,01fh,000h	; 982e  .xp@..K.. ..A...
	defb 07fh,07fh,006h,000h,04ah,010h,024h,000h,000h,0f8h,0e4h,09ch,078h,070h,040h,005h	; 983e  ....J.$.....xp@.
	defb 000h,000h	; 984e

; ----------------------------------------------------------------------
; DATOS sprites_rle_2: Bloque RLE para B142: 64 bytes a 0x3FC0. Lo carga
;   0xAB21
;   0x9850..0x9865  (21 bytes)
DATA_sprites_rle_2:
	defb 0c0h,03fh,020h,000h,048h,001h,012h,020h,010h,080h,040h,000h,010h,009h,000h,042h	; 9850  .? .H.. ..@....B
	defb 010h,024h,00dh,000h,000h	; 9860

; ----------------------------------------------------------------------
; DATOS sprites_rle_3: Bloque RLE para B142: 64 bytes a 0x3FC0. Lo carga
;   0xAABD
;   0x9865..0x989e  (57 bytes)
DATA_sprites_rle_3:
	defb 0c0h,03fh,04ch,000h,004h,002h,003h,007h,037h,011h,00dh,00fh,00fh,006h,003h,007h	; 9865  .?L.....7.......
	defb 000h,049h,030h,060h,0e0h,0e4h,0e4h,0f8h,0f8h,0e0h,040h,006h,000h,04ah,004h,006h	; 9875  .I0`......@..J..
	defb 00eh,02eh,027h,013h,01bh,00fh,007h,003h,005h,000h,04bh,020h,020h,060h,0c0h,0c0h	; 9885  ..'.......K  `..
	defb 0cch,0d0h,0f0h,030h,060h,040h,004h,000h,000h	; 9895  ...0`@...

; ----------------------------------------------------------------------
; DATOS sprites_rle_4: Bloque RLE para B142: 64 bytes a 0x3FC0. Lo carga
;   0xAC22
;   0x989e..0x98bb  (29 bytes)
DATA_sprites_rle_4:
	defb 0c0h,03fh,005h,000h,049h,001h,001h,00fh,00ch,00fh,000h,000h,00fh,001h,007h,000h	; 989e  .?..I...........
	defb 049h,080h,080h,0e0h,000h,0e0h,060h,060h,0e0h,080h,022h,000h,000h	; 98ae  I.....``.."..

; ----------------------------------------------------------------------
; DATOS sprites_rle_5: Bloque RLE para B142: 64 bytes a 0x3FC0. Lo carga
;   0xABC8
;   0x98bb..0x98e0  (37 bytes)
DATA_sprites_rle_5:
	defb 0c0h,03fh,047h,000h,000h,005h,01fh,00fh,003h,001h,00bh,000h,045h,0e0h,0f8h,0f0h	; 98bb  .?G.........E...
	defb 0c0h,080h,00bh,000h,045h,007h,01fh,00fh,003h,001h,00bh,000h,045h,0a0h,078h,0f0h	; 98cb  ....E.......E.x.
	defb 0c0h,080h,009h,000h,000h	; 98db

; ----------------------------------------------------------------------
; DATOS sprites_rle_6: Bloque RLE para B142: 64 bytes a la VRAM 0x3800, los
;   DOS PRIMEROS patrones de sprite. Lo carga 0xACB6
;   0x98e0..0x9919  (57 bytes)
DATA_sprites_rle_6:
	defb 000h,038h,04ch,000h,000h,01fh,078h,061h,060h,078h,03fh,01fh,007h,003h,00ch,007h	; 98e0  .8L...xa`x?.....
	defb 000h,049h,080h,080h,018h,060h,018h,080h,0e0h,01ch,0ceh,005h,000h,04bh,01fh,038h	; 98f0  .I...`.......K.8
	defb 061h,060h,070h,078h,03eh,01fh,007h,000h,018h,006h,000h,04ah,080h,000h,000h,018h	; 9900  a`px>......J....
	defb 070h,080h,080h,0e6h,018h,06eh,004h,000h,000h	; 9910  p....n...

; ----------------------------------------------------------------------
; DATOS sprites_rle_7: Bloque RLE para B142: 64 bytes a 0x3FC0. Lo carga
;   0xAD75
;   0x9919..0x9944  (43 bytes)
DATA_sprites_rle_7:
	defb 0c0h,03fh,006h,000h,044h,07fh,013h,06ch,07fh,00ah,000h,046h,060h,078h,0feh,03eh	; 9919  .?..D..l...F`x.>
	defb 0ceh,0feh,007h,000h,049h,030h,03eh,007h,001h,000h,000h,000h,06ch,07fh,009h,000h	; 9929  ....I0>.....l...
	defb 047h,09ch,0fch,07eh,01eh,00eh,0ceh,0feh,006h,000h,000h	; 9939  G..~.......

; ----------------------------------------------------------------------
; DATOS sprites_rle_8: Bloque RLE para B142: 64 bytes a 0x3FC0. Lo carga
;   0xAD1F
;   0x9944..0x9989  (69 bytes)
DATA_sprites_rle_8:
	defb 0c0h,03fh,060h,000h,003h,00eh,019h,01fh,01fh,019h,01fh,01fh,01ch,013h,00eh,019h	; 9944  .?`.............
	defb 019h,00eh,007h,000h,0c0h,070h,0f8h,0f8h,078h,0f8h,0f8h,0f8h,038h,0c8h,070h,098h	; 9954  .....p..x...8.p.
	defb 098h,070h,0e0h,060h,000h,003h,00eh,01fh,01fh,01eh,01fh,01fh,01fh,01ch,013h,00eh	; 9964  .p.`............
	defb 019h,019h,00eh,007h,000h,0c0h,070h,098h,0f8h,078h,098h,0f8h,0f8h,038h,0c8h,070h	; 9974  ......p..x...8.p
	defb 098h,098h,070h,0e0h,000h	; 9984

; ----------------------------------------------------------------------
; DATOS sprites_rle_9: Bloque RLE para B142: 64 bytes a 0x3FC0. Lo carga
;   0xAA74
;   0x9989..0x99af  (38 bytes)
DATA_sprites_rle_9:
	defb 0c0h,03fh,042h,000h,020h,009h,000h,043h,07fh,000h,07fh,00ch,000h,048h,008h,0c8h	; 9989  .?B. ..C.....H..
	defb 000h,0c0h,000h,000h,000h,010h,009h,000h,043h,07fh,000h,07fh,00ch,000h,046h,004h	; 9999  ........C.....F.
	defb 0c4h,000h,0c0h,000h,000h,000h	; 99a9

; ----------------------------------------------------------------------
; DATOS parado_capa_verde: 32 bytes a la VRAM 0x39A0, que es el patron 0x34:
;   las piernas (color 0x0C) del jugador PARADO, que es tambien el primer
;   cuadro del salto (lo clavan a mano 0x8970 y 0x881B, y no sale en ningun
;   guion de animacion). Lo recarga 0x8307 al acabar de reaparecer, y hace
;   falta porque la animacion de morir escribe ahi mismo el muneco troceado
;   (0x8C4F)
;   0x99af..0x99cf  (32 bytes)
DATA_parado_capa_verde:
	defb 003h,003h,001h,001h,001h,001h,001h,001h	; 99af  ........
	defb 001h,001h,000h,000h,000h,000h,000h,000h	; 99b7  ........
	defb 0c0h,0c0h,0c0h,0c0h,0c0h,0c0h,0c0h,070h	; 99bf  .......p
	defb 000h,0c0h,000h,000h,000h,000h,000h,000h	; 99c7  ........

; ----------------------------------------------------------------------
; DATOS trepa_capa_verde: 32 bytes a la VRAM 0x39E0, que es el patron 0x3C: la
;   mitad de abajo (las piernas, color 0x0C) del jugador TREPANDO. Lo recarga
;   la escena de hoyos en 0xAA07, porque en las escenas con liana ese mismo
;   hueco lo ocupa la cuerda que traza 0xA594. Y justo despues, 0xAA43 lo
;   espeja al patron 0x60, que es el otro fotograma del guion de trepar
;   (0x8AF9)
;   0x99cf..0x99ef  (32 bytes)
DATA_trepa_capa_verde:
	defb 007h,00fh,01fh,018h,00ch,006h,006h,01eh	; 99cf  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; 99d7  ........
	defb 0c0h,0c0h,0c0h,0c0h,0c0h,0c0h,0c0h,0c0h	; 99df  ........
	defb 0c0h,0c0h,0c0h,0f0h,000h,000h,000h,000h	; 99e7  ........

; ----------------------------------------------------------------------
; DATOS parado_capa_roja: 32 bytes a la VRAM 0x3BE0, que es el patron 0x7C =
;   (0x34-0x20)+0x68: la mitad de arriba del mismo fotograma, en color 0x06.
;   Lo recarga 0x82FB por lo mismo que el anterior (0x8C43 lo pisa)
;   0x99ef..0x9a0f  (32 bytes)
DATA_parado_capa_roja:
	defb 000h,000h,000h,000h,003h,003h,003h,000h	; 99ef  ........
	defb 003h,007h,00eh,00dh,006h,007h,002h,003h	; 99f7  ........
	defb 000h,000h,000h,000h,0c0h,000h,000h,000h	; 99ff  ........
	defb 080h,0c0h,0c0h,0c0h,0d0h,0d0h,040h,0c0h	; 9a07  ......@.

; ----------------------------------------------------------------------
; DATOS trepa_capa_roja: 32 bytes a la VRAM 0x3C20, que es el patron 0x84 =
;   (0x3C-0x20)+0x68: la mitad de arriba del mismo fotograma, el cuerpo en
;   color 0x06. Lo recarga 0xAA13
;   0x9a0f..0x9a2f  (32 bytes)
DATA_trepa_capa_roja:
	defb 000h,000h,000h,000h,000h,000h,001h,003h	; 9a0f  ........
	defb 003h,018h,019h,01fh,00fh,007h,003h,003h	; 9a17  ........
	defb 000h,000h,000h,000h,000h,000h,080h,0c0h	; 9a1f  ........
	defb 0c0h,000h,080h,0e0h,0f0h,0f0h,0e0h,0c0h	; 9a27  ........

; ----------------------------------------------------------------------
; DATOS trepa_capa_blanca: 32 bytes a la VRAM 0x3E60, que es el patron 0xCC =
;   (0x3C-0x20)+0xB0: la tercera capa del mismo fotograma, los cuatro puntos
;   de color 0x0F que caen sobre la cabeza. Lo recarga 0xAA1F
;   0x9a2f..0x9a4f  (32 bytes)
DATA_trepa_capa_blanca:
	defb 000h,000h,000h,000h,000h,000h,000h,001h	; 9a2f  ........
	defb 00dh,001h,000h,000h,000h,000h,000h,000h	; 9a37  ........
	defb 000h,000h,000h,000h,000h,000h,000h,080h	; 9a3f  ........
	defb 0c0h,080h,000h,000h,000h,000h,000h,000h	; 9a47  ........

; ----------------------------------------------------------------------
; DATOS tapa_del_suelo: 32 bytes a la VRAM 0x3800, que es el patron 0x00: NO
;   es el jugador, es una barra maciza de 16x5. Se pone en el sprite 0xE292
;   con color 0x0B a la altura Y=0x7A -la linea del suelo- al bajar por la
;   escalera (0x8432-0x8442) y al caer por el hoyo (0x876E-0x877D). Como
;   0xE292 es una entrada mas baja que la del jugador (0xE2A2), se pinta
;   DELANTE: es lo que tapa al muneco mientras cruza el suelo. Lo copia 0xAA2B
;   0x9a4f..0x9a6f  (32 bytes)
DATA_tapa_del_suelo:
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,000h,000h,000h	; 9a4f  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; 9a57  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,000h,000h,000h	; 9a5f  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; 9a67  ........

; ======================================================================
; CODIGO 0x9a6f..0x9cbd  (590 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; ############################################################
; COMO SE LLEGA A LAS 255 PANTALLAS
; ############################################################
; Aqui no hay ninguna busqueda, ni lista, ni indice de mapa. En
; cada cuadro se comprueba UNA condicion -si la X del jugador
; llego al borde- y, si llego, se hace girar el registro de
; 0xE222 un paso (o tres). La pantalla en la que estas ES el
; contenido de ese registro, y por eso el mundo no ocupa
; memoria: se calcula al entrar.
; Detras va el recorrido de los objetos vivos: 0xE247 dice
; cuantos hay y detras viene la lista de punteros a sus
; estructuras. De cada uno se decrementa su contador (+0x11) y
; solo cuando llega a cero se recarga con su periodo (+0x10) y
; se le llama: asi cada objeto corre a su propio ritmo sin que
; haya un temporizador por objeto.
; ----------------------------------------------------------------------
cuadro_del_juego:
	call reloj_de_partida		;9a6f   ; lo primero el reloj, que corre aunque no haya partida
	call cambia_de_pantalla_a_la_derecha		;9a72   ; y lo segundo, mirar si el jugador ha llegado a un borde
	or a			;9a75   ; si ha cambiado de pantalla, este cuadro ya no hace nada mas
	jr nz,fin_del_cuadro		;9a76
	ld a,(0e221h)		;9a78   ; si 0xE221 no es cero corre la DEMO, y la entrada no se lee: se le mete la grabada de 0xE259
	or a			;9a7b
	jr z,recorre_objetos		;9a7c
	ld a,(0e259h)		;9a7e
	ld (0e05fh),a		;9a81
	xor a			;9a84   ; y el mando 2 a cero, aunque no vaya a leerlo nadie
	ld (0e061h),a		;9a85
recorre_objetos:		; 0xE247 = cuantos hay; detras, un puntero por objeto
	ld hl,0e247h		;9a88   ; 0xE247: cuantos objetos vivos hay, y detras sus punteros
	ld b,(hl)			;9a8b   ; B = cuantos objetos hay
	xor a			;9a8c
	cp b			;9a8d   ; con la lista vacia no hay nada que recorrer: el titulo y la pausa se quedan asi
	jr z,fin_del_cuadro		;9a8e
recorre_objetos_bucle:
	push bc			;9a90
	inc hl			;9a91
	ld e,(hl)			;9a92   ; el puntero a la estructura, dos bytes
	inc hl			;9a93
	ld d,(hl)			;9a94
	push hl			;9a95
	push de			;9a96
	pop ix		;9a97   ; IX = la estructura del objeto
	dec (ix+011h)		;9a99   ; el contador propio del objeto; solo actua cuando llega a cero
	jr nz,siguiente_objeto		;9a9c
	ld a,(ix+010h)		;9a9e
	ld (ix+011h),a		;9aa1
	ld e,(ix+014h)		;9aa4   ; IX+0x14/15: donde tiene este objeto sus cuatro bytes de sprite
	ld d,(ix+015h)		;9aa7
	push de			;9aaa   ; DE se apila dos veces: una se saca ya en IY y la otra espera al pop iy de 0x9AD7, que lo repone por si el manejador lo ha cambiado
	push de			;9aab
	pop iy		;9aac
	call anima_objeto		;9aae   ; anima
	push ix		;9ab1
	call mueve_objeto		;9ab3   ; mueve el eje Y (IX+0 con IY+0), y la segunda llamada, con IX+6 e IY+1, el eje X: la X del jugador es IY+0x01 y su fraccion IX+0x0B, la misma pareja que tocan 0x8621 y 0x88CD
	ld de,00006h		;9ab6   ; seis bytes mas alla estan los MISMOS campos para el otro eje...
	add ix,de		;9ab9
	inc iy		;9abb   ; ...e IY+1, que es la X en la tabla de sprites
	call mueve_objeto		;9abd
	pop ix		;9ac0
	bit 6,(ix+000h)		;9ac2   ; bit 6 = tiene manejador propio
	jr z,vuelve_del_manejador		;9ac6
	push ix		;9ac8   ; push ix y pop ix seguidos no hacen nada: IX ya vale eso
	pop ix		;9aca
	ld l,(ix+012h)		;9acc
	ld h,(ix+013h)		;9acf
	ld de,vuelve_del_manejador		;9ad2   ; la vuelta se apila a mano: el manejador se llama con jp (hl)
	push de			;9ad5
	jp (hl)			;9ad6
vuelve_del_manejador:
	pop iy		;9ad7
siguiente_objeto:
	pop hl			;9ad9   ; y al objeto siguiente
	pop bc			;9ada
	djnz recorre_objetos_bucle		;9adb
	call sprites_del_jugador		;9add

; ----------------------------------------------------------------------
; 0xC7 es `rst 0`, y 0x9AE0 es esta misma linea: el
; codigo intenta machacarse con un reset. Esta en ROM,
; asi que no pasa nada; solo morderia a quien copiase
; el cartucho a RAM (?)
; ----------------------------------------------------------------------
fin_del_cuadro:
	ld hl,fin_del_cuadro		;9ae0   ; se escribe encima de si mismo, pero es ROM: no tiene efecto
	ld (hl),0c7h		;9ae3
	call lee_teclas_de_sistema		;9ae5
	call reloj_de_inactividad		;9ae8
	ret			;9aeb
anima_objeto:		; Bit 5 = animado. IX+0x0E cuenta, IX+0x0F es el fotograma
	bit 5,(ix+000h)		;9aec   ; sin el bit 5 el objeto no cambia de patron
	ret z			;9af0
	dec (ix+00eh)		;9af1   ; el contador propio de la animacion
	ret nz			;9af4
	ld a,(ix+00fh)		;9af5   ; el fotograma de ahora, y se pasa al siguiente
	inc a			;9af8
	ld l,(ix+00ch)		;9af9   ; IX+0x0C/0D = guion de fotogramas, pares (espera, patron)
	ld h,(ix+00dh)		;9afc
	push hl			;9aff   ; se guarda el principio del guion: hace falta para volver a empezar
	cp 000h		;9b00   ; con el fotograma 0 no hay que avanzar nada, y ademas un djnz con B a cero daria 256 vueltas
	jr z,anima_objeto_lee		;9b02
	ld b,a			;9b04
anima_objeto_busca:
	inc hl			;9b05   ; dos bytes por fotograma
	inc hl			;9b06
	djnz anima_objeto_busca		;9b07
anima_objeto_lee:
	ld b,a			;9b09   ; B se queda con el numero de fotograma
	ld a,(hl)			;9b0a   ; el primer byte del par: cuantos cuadros aguanta
	pop de			;9b0b
	or a			;9b0c   ; un 0 ahi cierra el guion...
	jr nz,anima_objeto_guarda		;9b0d
	ex de,hl			;9b0f   ; ...y se vuelve al primer par, fotograma 0
	ld a,(hl)			;9b10
	ld b,000h		;9b11
anima_objeto_guarda:
	ld (ix+00eh),a		;9b13   ; la espera nueva a IX+0x0E y el fotograma a IX+0x0F
	ld (ix+00fh),b		;9b16
	inc hl			;9b19
	ld a,(hl)			;9b1a
	ld (iy+002h),a		;9b1b   ; el patron nuevo, ya en la tabla de sprites (IY)
	ret			;9b1e
mueve_objeto:		; Bit 0 = movil. Suma IX+1/2 a la posicion
	bit 0,(ix+000h)		;9b1f   ; sin el bit 0 el objeto no se mueve solo
	ret z			;9b23
	ld h,(iy+000h)		;9b24   ; la parte entera vive en el sprite; IX+5 es la fraccion
	ld l,(ix+005h)		;9b27
	ld d,(ix+002h)		;9b2a   ; IX+1/2 es la velocidad, en 1/256 de pixel por cuadro
	ld e,(ix+001h)		;9b2d
	add hl,de			;9b30   ; la suma es de 16 bits: arriba el pixel y abajo lo que sobra
	ld (iy+000h),h		;9b31
	ld (ix+005h),l		;9b34
	bit 2,(ix+000h)		;9b37   ; bit 2 = tiene topes
	ret z			;9b3b
	set 3,(ix+000h)		;9b3c   ; los bits 3 y 4 se encienden y luego se apaga el del tope que NO se haya pasado: quedan diciendo contra cual se ha chocado
	set 4,(ix+000h)		;9b40
	ld a,h			;9b44
	ld b,(ix+003h)		;9b45   ; IX+3 y IX+4, los dos topes
	cp b			;9b48   ; por debajo de IX+3, rebote
	jr c,mueve_objeto_rebota		;9b49
	res 3,(ix+000h)		;9b4b
	ld b,(ix+004h)		;9b4f
	cp b			;9b52   ; y por encima de IX+4, tambien
	jr nc,mueve_objeto_rebota		;9b53
	res 4,(ix+000h)		;9b55
	ret			;9b59
mueve_objeto_rebota:
	bit 1,(ix+000h)		;9b5a   ; bit 1 = rebota en vez de pararse
	ret z			;9b5e
	ld a,d			;9b5f
	cpl			;9b60   ; complemento a dos: la velocidad cambia de signo
	ld d,a			;9b61
	ld a,e			;9b62
	cpl			;9b63
	ld e,a			;9b64
	inc de			;9b65   ; los dos cpl mas este inc de: complemento a dos de 16 bits
	ld (ix+001h),e		;9b66
	ld (ix+002h),d		;9b69
	ret			;9b6c

; ----------------------------------------------------------------------
; APAGAR LA PANTALLA SI NADIE TOCA NADA
; Tres bytes en cascada (0xE25A/B/C), cada uno de 60. Si
; no llega entrada se van gastando; al agotarse los tres
; se apaga la pantalla y se espera a RETURN, STOP o ESC.
; ----------------------------------------------------------------------
reloj_de_inactividad:
	ld a,(0e05fh)		;9b6d   ; bits 0-3 de 0xE05F: si hay entrada, se recarga la cuenta
	and 00fh		;9b70
	jr z,reloj_de_inactividad_cuenta		;9b72
	ld a,03ch		;9b74   ; con entrada se recargan el segundo y el tercero, pero NO el primero: los 60 cuadros de 0xE25A siguen corriendo, y eso solo desajusta la cuenta en menos de un segundo
	ld (0e25bh),a		;9b76
	ld (0e25ch),a		;9b79
	ret			;9b7c
reloj_de_inactividad_cuenta:
	ld hl,0e25ah		;9b7d   ; 0xE25A gasta uno por cuadro, y solo al agotarse toca el segundo
	dec (hl)			;9b80
	ret nz			;9b81
	ld (hl),03ch		;9b82   ; cada uno vuelve a 60 al pasar el testigo: 60x60x60 cuadros, o sea una hora larga sin tocar nada
	inc hl			;9b84
	dec (hl)			;9b85
	ret nz			;9b86
	ld (hl),03ch		;9b87
	inc hl			;9b89
	dec (hl)			;9b8a
	ret nz			;9b8b
	di			;9b8c   ; con la pantalla apagada ya no hace falta la interrupcion
	ld bc,08201h		;9b8d   ; registro 1 del VDP = 0x82: pantalla apagada
	call escribe_registro_vdp		;9b90
espera_tecla_apagado:
	call lee_joysticks		;9b93   ; aqui dentro los mandos se leen a mano: el bucle principal esta parado
	call lee_teclado_como_joystick		;9b96
	ld a,(0e05fh)		;9b99   ; 0xE05F es la ENTRADA, no un contador: los seis bits bajos son las cuatro direcciones y los dos botones
	and 03fh		;9b9c
	jr nz,vuelve_a_encender		;9b9e
	ld a,007h		;9ba0
	or 0f0h		;9ba2
	out (0aah),a		;9ba4
	in a,(0a9h)		;9ba6
	cpl			;9ba8
	and 094h		;9ba9   ; fila 7, mascara 0x94 = RETURN, STOP o ESC
	jr nz,vuelve_a_encender		;9bab
	jr espera_tecla_apagado		;9bad   ; y a esperar otra vez
vuelve_a_encender:
	ld bc,0e201h		;9baf   ; registro 1 = 0xE2: pantalla e interrupcion otra vez
	call escribe_registro_vdp		;9bb2
espera_a_que_suelten:
	ld a,007h		;9bb5   ; fila 7 del teclado
	or 0f0h		;9bb7
	out (0aah),a		;9bb9
	in a,(0a9h)		;9bbb
	cpl			;9bbd
	and 094h		;9bbe   ; mascara 0x94, los bits 7, 4 y 2 de esa fila: mientras siga pulsado alguno no se sale
	jr nz,espera_a_que_suelten		;9bc0
	ld a,03ch		;9bc2   ; y los tres bytes del reloj de inactividad vuelven a 60
	ld (0e25ah),a		;9bc4
	ld (0e25bh),a		;9bc7
	ld (0e25ch),a		;9bca
	ei			;9bcd
	ret			;9bce
empieza_el_final:		; Deja un solo objeto y le mete el manejador de la despedida
	ld a,001h		;9bcf   ; de todos los objetos solo queda el jugador
	ld (0e247h),a		;9bd1   ; solo queda un objeto vivo
	ld ix,0e2d5h		;9bd4
	ld hl,09e0eh		;9bd8   ; el manejador de la secuencia final
	ld (ix+012h),l		;9bdb
	ld (ix+013h),h		;9bde
	res 5,(ix+000h)		;9be1   ; se le apagan el bit de animado, el de movil de la X y el de movil de la Y: en la despedida no se mueve
	res 0,(ix+006h)		;9be5
	res 0,(ix+000h)		;9be9
	ld a,003h		;9bed
	ld (0e21ch),a		;9bef   ; 0xE21C = 3: el cuadro ya no corre normal
	ret			;9bf2
lee_teclas_de_sistema:
	ld a,(0e221h)		;9bf3   ; en demo no se lee nada
	or a			;9bf6
	jp nz,vuelve_sin_hacer_nada		;9bf7
	ld a,007h		;9bfa   ; fila 7 del teclado, la de RETURN, STOP y ESC
	or 0f0h		;9bfc
	out (0aah),a		;9bfe
	in a,(0a9h)		;9c00
	cpl			;9c02
	ld b,a			;9c03
	ld a,(0e269h)		;9c04
	or a			;9c07
	jr z,mira_stop_y_esc		;9c08
	bit 7,b		;9c0a   ; RETURN, y solo si 0xE269 lo permite
	jp nz,vuelve_al_titulo		;9c0c
mira_stop_y_esc:
	bit 4,b		;9c0f   ; STOP arranca de cero por INIT
	jp nz,INIT		;9c11
	ld a,(0e267h)		;9c14
	or a			;9c17
	jp nz,pausa_espera_soltar		;9c18   ; 0xE267 = por donde va el pulsar-soltar de la pausa
	bit 2,b		;9c1b   ; ESC, el bit 2 de esa fila
	jp z,vuelve_sin_hacer_nada		;9c1d
	call pausa_activa		;9c20   ; se para el juego...
	ld a,001h		;9c23
	ld (0e267h),a		;9c25   ; ...y 0xE267 pasa a 1, que es esperar a que la suelten
	jp vuelve_sin_hacer_nada		;9c28
pausa_espera_soltar:
	cp 001h		;9c2b   ; estado 1: mientras siga pulsada, nada
	jp nz,pausa_segunda_pulsacion		;9c2d
	bit 2,b		;9c30
	jp nz,vuelve_sin_hacer_nada		;9c32
	ld a,002h		;9c35   ; soltada, estado 2: esperando la segunda pulsacion
	ld (0e267h),a		;9c37
	jp vuelve_sin_hacer_nada		;9c3a
pausa_segunda_pulsacion:
	cp 002h		;9c3d   ; estado 2
	jp nz,pausa_ultimo_soltar		;9c3f
	bit 2,b		;9c42   ; y en cuanto la vuelvan a pulsar...
	jp z,vuelve_sin_hacer_nada		;9c44
	call pausa_reanuda		;9c47   ; ...se reanuda, y estado 3
	ld a,003h		;9c4a
	ld (0e267h),a		;9c4c
	jp vuelve_sin_hacer_nada		;9c4f
pausa_ultimo_soltar:
	cp 003h		;9c52   ; estado 3: esperar a que la suelten otra vez
	jp nz,vuelve_sin_hacer_nada		;9c54
	bit 2,b		;9c57
	jp nz,vuelve_sin_hacer_nada		;9c59
	xor a			;9c5c   ; y vuelta al 0, listo para otra pausa
	ld (0e267h),a		;9c5d
vuelve_sin_hacer_nada:
	ret			;9c60
vuelve_al_titulo:
	ld a,(0e34ah)		;9c61   ; 0xE34A solo esta a cero desde que 0x8143 lo borra al llegar el final: en mitad de una partida, RETURN no devuelve al titulo
	or a			;9c64
	ret nz			;9c65
	ld hl,0e132h		;9c66   ; borra 0x17C bytes de estado de un golpe
	ld de,0e133h		;9c69
	ld (hl),000h		;9c6c
	ld bc,0017ch		;9c6e
	ldir		;9c71
	ld hl,0e26ah		;9c73
	ld de,01b00h		;9c76
	ld bc,00044h		;9c79
	call copia_bloque_a_vram		;9c7c   ; tabla de sprites a cero: se van todos de la pantalla
	ld a,001h		;9c7f   ; y se marca que ya se ha vuelto, para que no se repita
	ld (0e34ah),a		;9c81
	ld a,001h		;9c84   ; sonido 1, el mismo que suena al entrar en cada pantalla
	call arranca_un_sonido		;9c86
	ld a,001h		;9c89
	ld (0e1e3h),a		;9c8b   ; 0xE1E3 = 1: el sonido de los pasos suena en el cuadro siguiente
	call carga_los_sprites		;9c8e   ; los patrones de sprite, otra vez a la VRAM
	jp arranca_la_partida		;9c91   ; y a empezar partida: de aqui no se vuelve
pausa_activa:		; Guarda cuantos objetos habia y pone cero: nada se mueve
	ld a,(0e21ch)		;9c94   ; si el cuadro ya esta parado por otra cosa, no se toca nada
	or a			;9c97
	ret nz			;9c98
	ld a,(0e247h)		;9c99
	cp 001h		;9c9c   ; con un solo objeto no se puede pausar (es el final)
	ret z			;9c9e
	ld (0e189h),a		;9c9f   ; se apuntan en 0xE189, igual que al morirse...
	xor a			;9ca2
	ld (0e247h),a		;9ca3   ; ...y la lista se deja a CERO: aqui no queda ni el jugador
	ld a,002h		;9ca6   ; 0xE21C = 2, la marca de pausa que mira el reloj de 0x9DB8
	ld (0e21ch),a		;9ca8
	ret			;9cab
pausa_reanuda:
	ld a,(0e21ch)		;9cac   ; solo se reanuda la pausa del 2: el 3 del final no se toca
	cp 002h		;9caf
	ret nz			;9cb1
	ld a,(0e189h)		;9cb2   ; y los objetos vuelven de 0xE189
	ld (0e247h),a		;9cb5
	xor a			;9cb8
	ld (0e21ch),a		;9cb9
	ret			;9cbc

; ----------------------------------------------------------------------
; DATOS ret_huerfano_9cbd: Un `ret` detras del `ret` que cierra 0x9CAC
;   0x9cbd..0x9cbe  (1 bytes)
DATA_ret_huerfano_9cbd:
	defb 0c9h	; 9cbd

; ======================================================================
; CODIGO 0x9cbe..0xa086  (968 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; ############################################################
; EL CAMBIO DE PANTALLA, y el atajo de tres escenas
; ############################################################
; La X del jugador esta en 0xE2A3. Cuando vale 0xE7 -el
; borde derecho- se reposiciona en 0x19, el otro lado, y
; se avanza el registro de pantalla: UN paso, o TRES si
; el bit 0 de 0xE2EB dice subterraneo. Por abajo el mundo
; se recorre al triple. Al final salta a 0x9EE6, la unica
; via por la que se monta una escena: cambiar 0xE222 a
; pelo no repinta nada
; ----------------------------------------------------------------------
cambia_de_pantalla_a_la_derecha:
	ld iy,0e2a2h		;9cbe   ; los cuatro bytes de sprite del jugador; IY+1 es su X
	ld a,0e7h		;9cc2   ; 0xE7 es la X del borde derecho
	cp (iy+001h)		;9cc4
	jr nz,mira_el_borde_izquierdo		;9cc7
	ld (iy+001h),019h		;9cc9   ; y 0x19 la del izquierdo, por donde reaparece
	ld b,001h		;9ccd   ; una escena por defecto...
	ld hl,0e2ebh		;9ccf
	bit 0,(hl)		;9cd2   ; el bit que decide si se avanza una escena o tres
	jr nz,avanza_una_o_tres_escenas		;9cd4
	ld b,003h		;9cd6   ; ...y tres si esta en el subterraneo
avanza_una_o_tres_escenas:
	push bc			;9cd8   ; el registro se gira B veces, una por escena saltada
	call avanza_pantalla_lfsr		;9cd9
	pop bc			;9cdc
	djnz avanza_una_o_tres_escenas		;9cdd
	jp monta_la_escena		;9cdf   ; montar la escena devuelve 1 en A, que es lo que corta el cuadro en 0x9A75
mira_el_borde_izquierdo:
	ld a,016h		;9ce2   ; 0x16, y reaparece en 0xE3
	cp (iy+001h)		;9ce4
	ld a,000h		;9ce7   ; el ld a,0 va entre el cp y el ret nz porque no toca banderas: A a cero avisa de que no se ha cambiado de pantalla
	ret nz			;9ce9
	ld (iy+001h),0e3h		;9cea
	ld b,001h		;9cee
	ld hl,0e2ebh		;9cf0
	bit 0,(hl)		;9cf3
	jr nz,cambia_de_pantalla_a_la_izquierda		;9cf5
	ld b,003h		;9cf7
cambia_de_pantalla_a_la_izquierda:
	push bc			;9cf9
	call retrocede_pantalla_lfsr		;9cfa   ; el mismo mecanismo al reves, con la rutina inversa del registro
	pop bc			;9cfd
	djnz cambia_de_pantalla_a_la_izquierda		;9cfe
	jp monta_la_escena		;9d00
sprites_del_jugador:		; Dos sprites mas, 16 pixeles por encima y con otro patron
	ld hl,0e2a2h		;9d03   ; 0xE2A2 es la mitad de abajo del muneco; 0xE2A6 y 0xE2AA, las dos de arriba
	ld iy,0e2a6h		;9d06   ; las dos entradas de arriba se dibujan una encima de otra: dos capas de color en el mismo sitio
	ld ix,0e2aah		;9d0a
	ld a,(hl)			;9d0e
	inc hl			;9d0f
	sub 010h		;9d10   ; misma X, Y menos 16: la mitad de arriba
	ld (iy+000h),a		;9d12
	ld (ix+000h),a		;9d15
	ld a,(hl)			;9d18
	ld (iy+001h),a		;9d19
	ld (ix+001h),a		;9d1c
	inc hl			;9d1f
	ld a,(hl)			;9d20
	sub 020h		;9d21   ; el patron de abajo menos 0x20, y de ahi +0x68 y +0xB0: las dos capas de la mitad de arriba
	ld b,a			;9d23
	add a,068h		;9d24   ; los patrones de las dos capas de color
	ld (iy+002h),a		;9d26
	ld a,b			;9d29
	add a,0b0h		;9d2a
	ld (ix+002h),a		;9d2c
	ret			;9d2f
anade_objeto:		; Mete DE al final de la lista de 0xE247
	ld hl,0e247h		;9d30
	ld b,(hl)			;9d33   ; 0xE247 es el contador, y sube uno
	inc (hl)			;9d34
	inc hl			;9d35
	xor a			;9d36   ; con la lista vacia se escribe directo en la primera casilla
	cp b			;9d37
	jr z,anade_objeto_escribe		;9d38
anade_objeto_busca_el_final:
	inc hl			;9d3a   ; dos bytes por puntero: se salta los que ya hay
	inc hl			;9d3b
	djnz anade_objeto_busca_el_final		;9d3c
anade_objeto_escribe:
	ld (hl),e			;9d3e   ; y el nuevo va al final de la lista
	inc hl			;9d3f
	ld (hl),d			;9d40
	ret			;9d41
rellena_vram_directo:		; Escribe A en DE bytes de VRAM desde HL
	ld c,a			;9d42   ; no pasa por 0xB185: se direcciona aqui mismo
	ld a,l			;9d43
	out (099h),a		;9d44
	ld a,h			;9d46
	or 040h		;9d47   ; el 0x40 marca escritura
	out (099h),a		;9d49
rellena_vram_directo_bucle:
	ld a,c			;9d4b   ; ni se relee la direccion ni se redirecciona: el VDP autoincrementa el solo
	out (098h),a		;9d4c
	dec de			;9d4e   ; DE cuenta atras, y el or de sus dos mitades caza el cero
	ld a,d			;9d4f
	or e			;9d50
	jr nz,rellena_vram_directo_bucle		;9d51
	ret			;9d53

; ----------------------------------------------------------------------
; EL MARCADOR Y EL RELOJ
; Seis digitos sueltos en 0xE1D6-0xE1DB (0-9 en binario),
; que aqui se pasan a tiles en 0xE1DC y se vuelcan a la
; VRAM. El reloj de 0xE1D0 es distinto: ya esta guardado
; en tiles, y se cuenta atras sobre ellos.
; ----------------------------------------------------------------------
pinta_marcador:
	ld b,005h		;9d54   ; cinco digitos que pueden salir en blanco; el sexto va aparte
	ld hl,0e1d6h		;9d56   ; 0xE1D6-0xE1DB, los seis digitos en binario
	ld de,0e1dch		;9d59   ; 0xE1DC-0xE1E1, los mismos ya convertidos en tiles
	ld c,0c3h		;9d5c   ; 0xC3 = blanco, para los ceros de delante
pinta_marcador_bucle:
	xor a			;9d5e
	cp (hl)			;9d5f   ; mientras el digito sea cero se sigue tirando del blanco
	jr z,pinta_marcador_digito		;9d60
	ld c,0b8h		;9d62   ; en cuanto sale un digito no nulo se pasa a 0xB8 = '0'
pinta_marcador_digito:
	ld a,c			;9d64
	add a,(hl)			;9d65   ; el digito se suma a la casilla base: 0xC3 es el blanco y 0xB8 el cero
	ld (de),a			;9d66
	inc hl			;9d67
	inc de			;9d68
	djnz pinta_marcador_bucle		;9d69   ; y al digito siguiente
	ld a,0b8h		;9d6b   ; el ultimo digito siempre sale como numero, aunque sea cero
	add a,(hl)			;9d6d
	ld (de),a			;9d6e
	ld hl,0e1dch		;9d6f   ; los seis tiles, de un golpe, a la VRAM
	ld de,01826h		;9d72   ; fila 1, columna 6 de la pantalla
	ld bc,00006h		;9d75
	call copia_bloque_a_vram		;9d78
	ret			;9d7b
resta_al_marcador:		; A = que digito. Los llamantes usan 5 (una unidad) y 3 (cien)
	ld hl,0e1d6h		;9d7c
	ld e,a			;9d7f   ; el digito por el que se empieza, contando desde el de mas peso
	ld d,000h		;9d80
	add hl,de			;9d82
	ld b,a			;9d83   ; y cuantos digitos puede arrastrar el prestamo: los que le quedan a la izquierda mas el
	inc b			;9d84
	ld a,0ffh		;9d85   ; 0xFF = se paso de cero, hay que llevarse una
resta_al_marcador_bucle:
	dec (hl)			;9d87
	cp (hl)			;9d88   ; si el digito se ha pasado de cero (0xFF) se pone a 9 y se sigue por el de la izquierda
	jr nz,pinta_marcador		;9d89
	ld (hl),009h		;9d8b   ; se pone a 9 y se sigue por el de la izquierda
	dec hl			;9d8d
	djnz resta_al_marcador_bucle		;9d8e
	ld hl,0e1d6h		;9d90   ; si el prestamo se come los seis digitos, el marcador se deja a cero en vez de darse la vuelta
	ld de,0e1d7h		;9d93
	ld (hl),000h		;9d96
	ld bc,00005h		;9d98
	ldir		;9d9b
	jr pinta_marcador		;9d9d   ; y a repintar, que la rutina esta justo encima
suma_miles:		; Suma A veces uno en el digito de los miles: los tesoros
	ld b,a			;9d9f   ; A veces de uno en uno: no hay suma, hay incrementos
	ld a,00ah		;9da0   ; el 10 con que se compara cada digito
suma_miles_bucle:
	ld hl,0e1d8h		;9da2   ; 0xE1D8 son los miles; al llegar a 10 se pone a cero y se lleva una a 0xE1D7
	inc (hl)			;9da5
	cp (hl)			;9da6
	jr nz,suma_miles_sigue		;9da7
	ld (hl),000h		;9da9
	dec hl			;9dab
	inc (hl)			;9dac
	cp (hl)			;9dad
	jr nz,suma_miles_sigue		;9dae
	ld (hl),000h		;9db0   ; y de ahi a 0xE1D6, las centenas de mil: mas alla no hay acarreo
	dec hl			;9db2
	inc (hl)			;9db3
suma_miles_sigue:
	djnz suma_miles_bucle		;9db4   ; y otra de las unidades que pedia A
	jr pinta_marcador		;9db6

; ----------------------------------------------------------------------
; LOS 20:00, CONTADOS SOBRE EL BINARIO
; INIT engancha 0x80F7 en H.KEYI (una llamada por interrupcion
; del VDP), 0x8100 llama a cuadro_del_juego sin condicion y este
; llama aqui lo primero: una pasada por interrupcion, y 0xE1D5
; -que vale 60- gasta una por pasada. UN TICK CADA 60
; INTERRUPCIONES: a 60 Hz el tick es un segundo y los 20:00 duran
; veinte minutos; a 50 Hz, 1,2 s y veinticuatro. Medido en partida
; real (tools/omsx_mide_tick.tcl, bp aqui y control en 0x80F7):
; 55 ticks seguidos, los 55 a 60 interrupciones exactas. OJO:
; corre tambien en titulo y demo, sobre tiles sin inicializar;
; los 20:00 se escriben al arrancar la partida.
; ----------------------------------------------------------------------
reloj_de_partida:		; Cuenta atras desde 20:00, un tick cada 60 cuadros
	ld a,(0e21ch)		;9db8   ; en pausa (0xE21C) no corre
	or a			;9dbb
	ret nz			;9dbc
	ld a,(0e247h)		;9dbd   ; sin objetos vivos no hay partida: en el titulo y en la pausa el reloj se queda quieto
	or a			;9dc0
	ret z			;9dc1
	ld hl,0e1d5h		;9dc2   ; 0xE1D5 = cuantos cuadros faltan para el tick
	dec (hl)			;9dc5   ; un cuadro menos
	ret nz			;9dc6
	ld (hl),03ch		;9dc7   ; y otros sesenta
	ld a,0b7h		;9dc9   ; 0xB7 es el tile de antes del '0': asi se ve el prestamo
	dec hl			;9dcb   ; 0xE1D4, las unidades de segundo
	dec (hl)			;9dcc
	cp (hl)			;9dcd
	jr c,mira_si_se_acabo		;9dce
	ld (hl),0c1h		;9dd0   ; se pasaron de cero: vuelven a 9 y toca la decena
	dec hl			;9dd2
	dec (hl)			;9dd3
	cp (hl)			;9dd4
	jr c,mira_si_se_acabo		;9dd5
	ld (hl),0bdh		;9dd7   ; la decena de segundos vuelve a 5
	dec hl			;9dd9   ; dos veces, porque en medio esta el ':'
	dec hl			;9dda
	dec (hl)			;9ddb
	cp (hl)			;9ddc
	jr c,mira_si_se_acabo		;9ddd
	ld (hl),0c1h		;9ddf   ; las unidades de minuto vuelven a 9
	dec hl			;9de1   ; y por fin la decena de minutos
	dec (hl)			;9de2
	ld a,0b8h		;9de3
	cp (hl)			;9de5
	jr nz,mira_si_se_acabo		;9de6
	ld (hl),0c4h		;9de8   ; el tile 0xC4 es tan blanco como el 0xC3 -descomprimido el bloque de 0x915B, sus ocho bytes son cero-, y esta aqui porque le queda UN decremento antes de llegar al 0xC3, que es la marca de tiempo agotado que mira 0x9DEA. O sea: de 09:59 en adelante el cero de la izquierda se borra, y ese mismo hueco es el que avisa del final
mira_si_se_acabo:
	ld a,(0e1d0h)		;9dea   ; 0xC3 en la decena de minutos = se acabo el tiempo
	sub 0c3h		;9ded
	jr z,se_acabo_el_tiempo		;9def
pinta_reloj:
	ld hl,0e1d0h		;9df1
	ld de,01867h		;9df4   ; fila 3, columna 7
	ld bc,00005h		;9df7
	call copia_bloque_a_vram		;9dfa
	ret			;9dfd
se_acabo_el_tiempo:
	call empieza_el_final		;9dfe   ; se acabo: la despedida se monta desde aqui
	ld a,0b8h		;9e01   ; el reloj se deja clavado en 00:00
	ld (0e1d1h),a		;9e03
	ld (0e1d3h),a		;9e06
	ld (0e1d4h),a		;9e09
	jr pinta_reloj		;9e0c
anima_el_final:
	ld ix,0e346h		;9e0e   ; los tres bytes de 0xE346: cuenta, recarga y fotograma
	dec (ix+000h)		;9e12   ; 0xE346 cuenta, 0xE347 recarga, 0xE348 es el fotograma
	ret nz			;9e15
	ld a,(ix+001h)		;9e16   ; se recarga con 0xE347...
	ld (ix+000h),a		;9e19
	call sprites_del_final		;9e1c   ; ...y se recolocan los cuatro sprites que van saliendo
	ld iy,0e346h		;9e1f
	ld e,(iy+002h)		;9e23   ; el fotograma es el desplazamiento dentro de la tabla
	ld d,000h		;9e26
	ld (iy+001h),009h		;9e28   ; la recarga queda en nueve cuadros por fotograma
	xor a			;9e2c
	cp (iy+002h)		;9e2d
	jr nz,anima_el_final_vram		;9e30
	ld (iy+000h),060h		;9e32   ; pero el fotograma 0 se queda 0x60 cuadros en pantalla
anima_el_final_vram:
	ld hl,0a33eh		;9e36   ; 14 tiras de 8 bytes desde 0xA33E; el paso de 0x12 es dentro de la tabla, y en la VRAM se avanza de 8 en 8
	add hl,de			;9e39
	ld de,00640h		;9e3a
	ld b,00eh		;9e3d
anima_el_final_bucle:
	push bc			;9e3f
	push de			;9e40
	push hl			;9e41
	push ix		;9e42
	ld bc,00008h		;9e44   ; ocho bytes por tira
	call copia_bloque_a_vram		;9e47
	pop ix		;9e4a
	pop hl			;9e4c
	ld de,00012h		;9e4d   ; en la tabla se avanza 0x12 por tira y en la VRAM solo 8
	add hl,de			;9e50
	ex de,hl			;9e51
	pop hl			;9e52
	ld bc,00008h		;9e53
	add hl,bc			;9e56
	ex de,hl			;9e57
	pop bc			;9e58
	djnz anima_el_final_bucle		;9e59
	ld iy,0e346h		;9e5b
	ld a,(iy+002h)		;9e5f
	inc (iy+002h)		;9e62   ; fotograma siguiente
	ld a,00ah		;9e65
	cp (iy+002h)		;9e67   ; diez fotogramas y vuelta a empezar
	ret nz			;9e6a
	ld (ix+000h),03ch		;9e6b   ; al dar la vuelta se esperan 0x3C cuadros
	ld (iy+002h),000h		;9e6f
	ret			;9e73
sprites_del_final:		; Cuatro sprites que van saliendo segun avanza 0xE348
	ld a,(0e348h)		;9e74   ; hasta el fotograma 3 los cuatro estan a color 0: no se ven
	cp 003h		;9e77
	jr nc,sprites_del_final_coloca		;9e79
	ld hl,0e2b1h		;9e7b   ; 0xE2B1, 0xE2B5, 0xE2B9 y 0xE2BD son los cuatro colores
	ld (hl),000h		;9e7e
	ld hl,0e2b5h		;9e80
	ld (hl),000h		;9e83
	ld hl,0e2b9h		;9e85
	ld (hl),000h		;9e88
	ld hl,0e2bdh		;9e8a
	ld (hl),000h		;9e8d
sprites_del_final_coloca:
	sub 009h		;9e8f   ; Y = 0xBC menos el fotograma: suben poco a poco
	cpl			;9e91   ; cpl e inc a: complemento a dos, o sea cambiarle el signo a la resta de arriba
	inc a			;9e92
	add a,0b3h		;9e93
	ld iy,0e2aeh		;9e95
	ld (iy+000h),a		;9e99
	ld (iy+003h),006h		;9e9c   ; y el color de cada uno: 6, 0x0A, 0x0C y 4
	ld a,(0e348h)		;9ea0   ; el segundo no sale hasta el fotograma 6
	cp 006h		;9ea3
	ret c			;9ea5
	sub 009h		;9ea6   ; la misma cuenta para el segundo
	cpl			;9ea8
	inc a			;9ea9
	add a,0b3h		;9eaa
	ld iy,0e2b2h		;9eac
	ld (iy+000h),a		;9eb0
	ld (iy+003h),00ah		;9eb3
	ld a,(0e348h)		;9eb7
	cp 007h		;9eba
	ret c			;9ebc
	sub 009h		;9ebd
	cpl			;9ebf
	inc a			;9ec0
	add a,0b3h		;9ec1
	ld iy,0e2b6h		;9ec3
	ld (iy+000h),a		;9ec7
	ld (iy+003h),00ch		;9eca
	ld a,(0e348h)		;9ece
	cp 009h		;9ed1
	ret c			;9ed3
	sub 009h		;9ed4
	cpl			;9ed6
	inc a			;9ed7
	add a,0b3h		;9ed8
	ld iy,0e2bah		;9eda
	ld (iy+000h),a		;9ede
	ld (iy+003h),004h		;9ee1
	ret			;9ee5
monta_la_escena:
	ld a,(0e225h)		;9ee6   ; se guarda el tipo anterior en 0xE226
	ld (0e226h),a		;9ee9   ; hay que saber de que tipo se venia para decidir si toca repintar el subsuelo
	ld a,(0e222h)		;9eec
	and 007h		;9eef   ; bits 0-2 del registro de pantalla = la variante
	ld (0e224h),a		;9ef1
	ld a,(0e222h)		;9ef4
	srl a		;9ef7   ; tres desplazamientos: los bits 3-5 bajan a los 0-2
	srl a		;9ef9
	srl a		;9efb   ; bits 3-5 = el tipo de escena, 0..7
	and 007h		;9efd
	ld (0e225h),a		;9eff
	cp 002h		;9f02   ; los tipos 0 y 1 son de superficie...
	jr nc,monta_la_escena_repinta		;9f04
	ld a,(0e226h)		;9f06   ; ...y ahi solo se repinta el subsuelo si se venia de una escena subterranea
	cp 002h		;9f09
	call nc,pinta_el_subsuelo		;9f0b
	jr monta_la_escena_sigue		;9f0e
monta_la_escena_repinta:
	call pinta_el_subsuelo		;9f10
monta_la_escena_sigue:
	ld a,001h		;9f13   ; sonido 1 al entrar en cada pantalla
	call arranca_un_sonido		;9f15
	call borra_las_cajas		;9f18   ; las diez cajas se borran, y cada tipo de escena rehace las suyas
	xor a			;9f1b
	ld (0e1ceh),a		;9f1c   ; 0xE1CE a cero, y a 1 en 0xAE48. Las dos unicas veces que aparece en el cartucho son escrituras: ni un ld a,(0E1CEh) ni un indexado que llegue -el desplazamiento mayor de toda la ROM es 0x17-. Bandera que se escribe y no se lee (?)
	ld ix,0e2bfh		;9f1f   ; al objeto comodin se le pone el manejador del hoyo, 0xA962
	ld de,0a962h		;9f23
	ld (ix+012h),e		;9f26
	ld (ix+013h),d		;9f29
	ld hl,0e247h		;9f2c
	ld (hl),003h		;9f2f   ; tres objetos vivos al montar la escena: el jugador, la liana y el comodin
	ld hl,0e2a6h		;9f31   ; 0xE2A6-0xE2AD a cero: las dos entradas de sprite que van encima del jugador
	ld de,0e2a7h		;9f34
	ld bc,00007h		;9f37
	ld (hl),000h		;9f3a
	ldir		;9f3c
	ld hl,0e26ah		;9f3e   ; 0xE26A-0xE299 a cero: las doce primeras entradas de la tabla
	ld de,0e26bh		;9f41
	ld bc,0002fh		;9f44
	ld (hl),000h		;9f47
	ldir		;9f49
	ld hl,0e32fh		;9f4b
	res 7,(hl)		;9f4e
	ld hl,0e2a5h		;9f50
	ld (hl),00ch		;9f53   ; 0x0C, 6 y 0x0F: los colores de las tres entradas del muneco (0xE2A2, 0xE2A6 y 0xE2AA)
	ld hl,0e2adh		;9f55   ; este ld hl,0E2ADh no sirve para nada: la linea de al lado machaca HL antes de que se escriba. Sobra
	ld hl,0e2a9h		;9f58
	ld (hl),006h		;9f5b
	ld hl,0e2adh		;9f5d
	ld (hl),00fh		;9f60
	ld hl,0e26ah		;9f62   ; la tabla de sprites entera a la VRAM
	ld de,01b00h		;9f65
	ld bc,00044h		;9f68
	call copia_bloque_a_vram		;9f6b
	ld a,(0e225h)		;9f6e   ; del tipo 2 en adelante se monta ademas el objeto de 0xACB6
	cp 002h		;9f71
	call nc,monta_el_que_sigue		;9f73   ; del tipo 2 en adelante hace falta un objeto mas
	call escoge_decorado_de_la_escena		;9f76
	ld a,(0e225h)		;9f79   ; el tipo de escena, doblado: indice en los ocho punteros de 0xAEB4
	sla a		;9f7c   ; doblado, que la tabla es de punteros
	ld e,a			;9f7e
	ld d,000h		;9f7f
	ld hl,0aeb4h		;9f81
	add hl,de			;9f84
	ld e,(hl)			;9f85
	inc hl			;9f86
	ld d,(hl)			;9f87
	ex de,hl			;9f88
	ld de,vuelve_del_tipo_de_escena		;9f89   ; la vuelta se apila a mano, igual que en el recorrido de objetos
	push de			;9f8c
	jp (hl)			;9f8d
vuelve_del_tipo_de_escena:		; La direccion que el despachador apila antes del jp (hl)
	ld a,001h		;9f8e
	ret			;9f90
escoge_decorado_de_la_escena:
	ld a,(0e222h)		;9f91   ; Los BITS 6-7 del LFSR de pantalla, doblados, son el indice de las dos tablas del decorado: 0xA086 (el juego de 16 tiles) y 0xA08E (el layout). O sea que de los ocho bits del mundo, dos eligen el paisaje, tres el tipo de escena y tres la variante
	and 0c0h		;9f94
	ld b,000h		;9f96   ; los bits 7 y 6 se sacan uno a uno a B con dos rotaciones dobles
	rl a		;9f98
	rl b		;9f9a
	rl a		;9f9c
	rl b		;9f9e
	sla b		;9fa0   ; y B se dobla: la tabla es de punteros
	ld e,b			;9fa2   ; DE se coge ANTES del inc b de 0x9FAC: el indice de las dos tablas es solo el paisaje doblado
	ld d,000h		;9fa3
	ld a,(0e224h)		;9fa5
	bit 2,a		;9fa8   ; y el bit 2 de la variante suma uno, pero solo para 0xE223
	jr nz,escoge_decorado_indice		;9faa
	inc b			;9fac
escoge_decorado_indice:
	ld a,b			;9fad
	ld (0e223h),a		;9fae   ; 0xE223 = de que mitad de la tabla de tesoros se tira
	push de			;9fb1   ; el indice se apila dos veces: hace falta para las dos tablas
	push de			;9fb2
	ld hl,0a086h		;9fb3   ; la tabla de 0xA086 da los dieciseis tiles del paisaje
	add hl,de			;9fb6
	ld e,(hl)			;9fb7
	inc hl			;9fb8
	ld d,(hl)			;9fb9
	ex de,hl			;9fba
	ld de,00380h		;9fbb   ; 0x80 bytes a la VRAM 0x0380: los patrones 0x70 a 0x7F
	ld bc,00080h		;9fbe
	call copia_bloque_a_vram		;9fc1
	ld bc,00010h		;9fc4   ; y los mismos dieciseis, espejados, a 0x0400: los patrones 0x80 a 0x8F
	ld hl,00380h		;9fc7
	ld de,00400h		;9fca
	call copia_patrones_en_espejo		;9fcd
	pop de			;9fd0
	ld hl,0a08eh		;9fd1   ; la otra tabla, 0xA08E, es el guion de celdas de ese paisaje
	add hl,de			;9fd4
	ld e,(hl)			;9fd5
	inc hl			;9fd6
	ld d,(hl)			;9fd7
	ex de,hl			;9fd8
	call pinta_el_layout		;9fd9
	pop de			;9fdc
	ld a,e			;9fdd   ; 0xE227/0xE228 guardan el indice para que 0xA002 pueda reponerlo
	ld (0e227h),a		;9fde
	ld a,d			;9fe1
	ld (0e228h),a		;9fe2
	ret			;9fe5
pinta_celdas:		; Interprete de guiones: primer byte = cuantas celdas, luego pares (posicion, tile)
	ld b,(hl)			;9fe6   ; cabecera de dos bytes; el primero es cuantas celdas vienen
	inc hl			;9fe7
	inc hl			;9fe8
pinta_celdas_bucle:
	push bc			;9fe9
	ld e,(hl)			;9fea   ; cada celda son cuatro bytes: la posicion en dos, el tile, y uno sin usar
	inc hl			;9feb
	ld d,(hl)			;9fec
	inc hl			;9fed
	ld bc,01800h		;9fee   ; la posicion es un desplazamiento sobre la tabla de nombres, 0x1800
	ex de,hl			;9ff1
	add hl,bc			;9ff2
	ex de,hl			;9ff3
	ld bc,00001h		;9ff4
	push hl			;9ff7
	call copia_bloque_a_vram		;9ff8   ; un solo byte por celda, redireccionando el VDP en cada una
	pop hl			;9ffb
	inc hl			;9ffc
	inc hl			;9ffd
	pop bc			;9ffe
	djnz pinta_celdas_bucle		;9fff
	ret			;a001
repone_decorado:		; Vuelve a poner los patrones de sprite y el juego de tiles guardado en 0xE227
	ld hl,097feh		;a002   ; los mismos 0x20 bytes de 0x97FE a tres sitios: los patrones de sprite 0x84, 0xA8 y 0xCC
	ld de,03c20h		;a005
	ld bc,00020h		;a008
	call copia_bloque_a_vram		;a00b
	ld hl,097feh		;a00e   ; el segundo destino, el patron 0xA8
	ld de,03d40h		;a011
	ld bc,00020h		;a014
	call copia_bloque_a_vram		;a017
	ld hl,097feh		;a01a   ; y el tercero, el 0xCC
	ld de,03e60h		;a01d
	ld bc,00020h		;a020
	call copia_bloque_a_vram		;a023
	ld hl,0e227h		;a026   ; 0xE227/0xE228: el indice de decorado que dejo escrito 0x9FDD
	ld e,(hl)			;a029
	inc hl			;a02a
	ld d,(hl)			;a02b
	ld hl,0a086h		;a02c
	add hl,de			;a02f
	ld e,(hl)			;a030
	inc hl			;a031
	ld d,(hl)			;a032
	ex de,hl			;a033
	ld de,00068h		;a034   ; +0x68 dentro del juego de tiles, o sea el catorceavo de los dieciseis
	add hl,de			;a037
	ld de,03c28h		;a038   ; y esos ocho bytes van a la tabla de patrones de SPRITE: 0x3C28, 0x3C38 y 0x3D48
	ld bc,00008h		;a03b
	push hl			;a03e
	call copia_bloque_a_vram		;a03f
	pop hl			;a042
	ld de,00008h		;a043
	add hl,de			;a046
	ld de,03c38h		;a047
	ld bc,00008h		;a04a
	push hl			;a04d
	call copia_bloque_a_vram		;a04e
	pop hl			;a051
	ld de,00008h		;a052
	add hl,de			;a055
	ld de,03d48h		;a056
	ld bc,00008h		;a059
	push hl			;a05c
	call copia_bloque_a_vram		;a05d
	pop hl			;a060
	ld bc,00002h		;a061
	ld hl,03d40h		;a064   ; tres pares mas, espejados: 0x3D40 a 0x3D50, 0x3C20 a 0x3E70 y 0x3C30 a 0x3E60
	ld de,03d50h		;a067
	call copia_patrones_en_espejo		;a06a
	ld bc,00002h		;a06d
	ld hl,03c20h		;a070
	ld de,03e70h		;a073
	call copia_patrones_en_espejo		;a076
	ld bc,00002h		;a079
	ld hl,03c30h		;a07c
	ld de,03e60h		;a07f
	call copia_patrones_en_espejo		;a082
	ret			;a085

; ----------------------------------------------------------------------
; DATOS tabla_juegos_de_tiles: Cuatro palabras: punteros a los cuatro juegos
;   de 16 tiles de arriba, en el orden [0]=0x96FE [1]=0x977E [2]=0x967E
;   [3]=0x95FE. La lee 0x9FB3 con el indice en DE, y ese indice son los BITS
;   6-7 DEL LFSR DE PANTALLA, que 0x9F91-0x9FA3 extrae y dobla: el mundo elige
;   decorado con dos bits
;   0xa086..0xa08e  (8 bytes)
DATA_tabla_juegos_de_tiles:
	defw 096feh	; a086  -> DATA_tiles_decorado_0
	defw 0977eh	; a088  -> DATA_tiles_decorado_1
	defw 0967eh	; a08a  -> DATA_tiles_decorado_2
	defw 095feh	; a08c  -> DATA_tiles_decorado_3

; ----------------------------------------------------------------------
; DATOS tabla_de_layouts: Cuatro palabras: punteros a los cuatro layouts de
;   escena de abajo, [0]=0xA1EE [1]=0xA29A [2]=0xA13E [3]=0xA096. La lee
;   0x9FD1 y el layout lo consume 0x8D70
;   0xa08e..0xa096  (8 bytes)
DATA_tabla_de_layouts:
	defw 0a1eeh	; a08e  -> DATA_layout_escena_0
	defw 0a29ah	; a090  -> DATA_layout_escena_1
	defw 0a13eh	; a092  -> DATA_layout_escena_2
	defw 0a096h	; a094  -> DATA_layout_escena_3

; ----------------------------------------------------------------------
; DATOS layout_escena_3: Layout de escena (entrada [3]): 0x71 + 0x20 + 5 bytes
;   y un guion de 4 celdas que cierra en 0xA13E clavado
;   0xa096..0xa13e  (168 bytes)
DATA_layout_escena_3:
	defb 0e6h,038h,038h,0eeh,038h,038h,038h,0efh,0edh,038h,038h,038h,0d8h,038h,038h,0d9h	; a096  .88.888..888.88.
	defb 038h,0dah,038h,038h,0dbh,0e6h,038h,038h,0efh,0e7h,038h,038h,0dch,038h,0dbh,0e9h	; a0a6  8.88..88..88.8..
	defb 038h,0ech,0efh,038h,0d9h,038h,038h,0eah,0edh,038h,0dfh,038h,0e3h,0e5h,038h,038h	; a0b6  8..8.88..8.8..88
	defb 038h,038h,0dch,0d9h,0eah,038h,0ech,0e9h,0deh,038h,0ddh,0e1h,0e6h,038h,038h,038h	; a0c6  88...8...8...888
	defb 038h,038h,038h,038h,038h,0e2h,0e3h,0e2h,038h,0e1h,0ddh,0dah,038h,0e7h,0dfh,0dbh	; a0d6  88888...8...8...
	defb 038h,070h,071h,072h,073h,074h,075h,076h,077h,078h,079h,07ah,07bh,07ch,07dh,07eh	; a0e6  8pqrstuvwxyz{|}~
	defb 07fh,08fh,08eh,08dh,08ch,08bh,08ah,089h,088h,087h,086h,085h,084h,083h,082h,081h	; a0f6  ................
	defb 080h,008h,008h,008h,008h,008h,008h,008h,008h,000h,008h,008h,008h,000h,008h,008h	; a106  ................
	defb 008h,008h,008h,008h,000h,008h,008h,008h,000h,008h,008h,008h,008h,008h,008h,008h	; a116  ................
	defb 008h,008h,003h,006h,003h,008h,004h,000h,00dh,001h,011h,000h,012h,001h,015h,000h	; a126  ................
	defb 007h,001h,010h,000h,038h,001h,011h,000h	; a136  ....8...

; ----------------------------------------------------------------------
; DATOS layout_escena_2: Layout de escena (entrada [2]), guion de 6 celdas,
;   cierra en 0xA1EE
;   0xa13e..0xa1ee  (176 bytes)
DATA_layout_escena_2:
	defb 038h,0eeh,0efh,038h,038h,038h,0d8h,038h,0e8h,038h,038h,038h,0e6h,038h,0dch,0ddh	; a13e  8..888.8.888.8..
	defb 0deh,038h,0e0h,0e1h,038h,0efh,0dbh,038h,038h,0deh,0dfh,0e0h,038h,0e1h,038h,0e6h	; a14e  .8..8..88...8.8.
	defb 0e7h,0edh,038h,0d8h,0d9h,0dah,038h,0dbh,038h,038h,0e7h,0e8h,038h,038h,038h,0eah	; a15e  ..8...8.88..888.
	defb 0ebh,0ech,038h,0d8h,0d9h,038h,038h,0dbh,038h,038h,0dch,0ddh,0deh,0dfh,038h,038h	; a16e  ..8..88.88....88
	defb 038h,038h,038h,038h,038h,0dah,0dbh,038h,0e6h,0e7h,0e8h,038h,0dch,0dch,038h,0ddh	; a17e  88888..8...8..8.
	defb 038h,070h,071h,072h,073h,074h,075h,076h,077h,078h,079h,07ah,07bh,07ch,07dh,07eh	; a18e  8pqrstuvwxyz{|}~
	defb 07fh,08fh,08eh,08dh,08ch,08bh,08ah,089h,088h,087h,086h,085h,084h,083h,082h,081h	; a19e  ................
	defb 080h,008h,008h,008h,008h,008h,008h,008h,000h,008h,008h,008h,008h,008h,000h,008h	; a1ae  ................
	defb 008h,008h,008h,000h,008h,008h,008h,008h,008h,000h,008h,008h,008h,008h,008h,008h	; a1be  ................
	defb 008h,007h,005h,004h,005h,007h,006h,000h,005h,001h,012h,000h,006h,001h,013h,000h	; a1ce  ................
	defb 019h,001h,017h,000h,01ah,001h,016h,000h,00ch,001h,015h,000h,013h,001h,011h,000h	; a1de  ................

; ----------------------------------------------------------------------
; DATOS layout_escena_0: Layout de escena (entrada [0]), guion de 5 celdas,
;   cierra en 0xA29A
;   0xa1ee..0xa29a  (172 bytes)
DATA_layout_escena_0:
	defb 0efh,038h,038h,0eeh,038h,038h,0ech,0edh,038h,038h,0e6h,038h,038h,0ddh,038h,038h	; a1ee  .88.88..88.88.88
	defb 038h,0deh,0dfh,0e0h,038h,0e1h,038h,0e2h,0e3h,038h,038h,0e4h,0e5h,038h,038h,0e6h	; a1fe  8...8.8..88..88.
	defb 0e7h,038h,0d8h,0d9h,0dah,038h,0dbh,0dch,0ddh,038h,038h,0deh,0dfh,038h,0e0h,0e1h	; a20e  .8...8...88..8..
	defb 0e2h,038h,0e3h,038h,0e4h,0e5h,0e6h,038h,0dch,0ddh,0dfh,038h,0e6h,0d8h,038h,038h	; a21e  .8.8...8...8..88
	defb 038h,038h,038h,038h,0d8h,0d9h,0dah,038h,0dbh,0dch,0ddh,038h,0deh,0deh,0dfh,038h	; a22e  8888...8...8...8
	defb 0e0h,070h,071h,072h,073h,074h,075h,076h,077h,078h,079h,07ah,07bh,07ch,07dh,07eh	; a23e  .pqrstuvwxyz{|}~
	defb 07fh,08fh,08eh,08dh,08ch,08bh,08ah,089h,088h,087h,086h,085h,084h,083h,082h,081h	; a24e  ................
	defb 080h,008h,008h,008h,008h,000h,008h,008h,008h,008h,008h,000h,008h,008h,008h,008h	; a25e  ................
	defb 008h,008h,008h,008h,008h,008h,000h,008h,008h,008h,008h,008h,000h,008h,008h,008h	; a26e  ................
	defb 008h,004h,005h,00ah,005h,004h,005h,000h,002h,001h,012h,000h,003h,001h,013h,000h	; a27e  ................
	defb 01ch,001h,017h,000h,01dh,001h,016h,000h,014h,001h,010h,000h	; a28e  ............

; ----------------------------------------------------------------------
; DATOS layout_escena_1: Layout de escena (entrada [1]), guion de 3 celdas,
;   cierra en 0xA33E, que es justo donde empieza la tabla siguiente
;   0xa29a..0xa33e  (164 bytes)
DATA_layout_escena_1:
	defb 038h,038h,0e8h,038h,038h,0e8h,0e9h,038h,0eah,038h,038h,038h,0ebh,0ech,038h,038h	; a29a  88.88..8.888..88
	defb 038h,0edh,0eeh,0eeh,038h,0efh,038h,0d8h,0d9h,038h,0dah,0dbh,0dch,038h,0dch,0ddh	; a2aa  8...8.8..8...8..
	defb 038h,038h,0deh,0dfh,038h,038h,0e0h,0e1h,038h,0d8h,038h,0d9h,0dah,038h,0dah,0dbh	; a2ba  88..88..8.8..8..
	defb 038h,038h,0dch,0ddh,0deh,038h,0dfh,0e2h,038h,0e1h,038h,0e4h,0e5h,0e6h,038h,038h	; a2ca  88...8..8.8...88
	defb 038h,038h,038h,038h,0d9h,0dah,038h,0dbh,038h,0e6h,0e7h,0dah,038h,038h,0dah,0dbh	; a2da  8888..8.8...88..
	defb 038h,070h,071h,072h,073h,074h,075h,076h,077h,078h,079h,07ah,07bh,07ch,07dh,07eh	; a2ea  8pqrstuvwxyz{|}~
	defb 07fh,08fh,08eh,08dh,08ch,08bh,08ah,089h,088h,087h,086h,085h,084h,083h,082h,081h	; a2fa  ................
	defb 080h,008h,008h,008h,008h,008h,008h,000h,008h,008h,008h,008h,008h,000h,008h,008h	; a30a  ................
	defb 008h,008h,008h,008h,000h,008h,008h,008h,008h,008h,000h,008h,008h,008h,008h,008h	; a31a  ................
	defb 008h,006h,005h,006h,005h,006h,003h,000h,018h,001h,010h,000h,007h,001h,011h,000h	; a32a  ................
	defb 005h,001h,010h,000h	; a33a

; ----------------------------------------------------------------------
; DATOS tabla_patrones_14x18: Catorce registros de 18 bytes. El bucle de
;   0x9E3F copia de cada registro un patron de tile de 8 bytes (la columna
;   dentro del registro la elige DE) a la VRAM desde 0x0640, avanzando de
;   registro en registro. 14 x 18 = 252 bytes, y cierra el hueco exacto
;   0xa33e..0xa43a  (252 bytes)
DATA_tabla_patrones_14x18:
	defb 000h,0f8h,088h,081h,089h,0f9h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; a33e  ..................
	defb 000h,000h,000h,0e7h,024h,0e7h,004h,004h,000h,000h,003h,007h,00dh,019h,03fh,061h,0c1h,000h	; a350  ....$.........?a..
	defb 000h,000h,000h,0b6h,092h,09eh,002h,01eh,000h,000h,01fh,000h,03ch,020h,020h,020h,03ch,000h	; a362  ............<   <.
	defb 000h,002h,000h,072h,042h,042h,000h,000h,000h,000h,0ffh,080h,088h,088h,088h,088h,088h,000h	; a374  ...rBB............
	defb 000h,001h,001h,079h,049h,079h,008h,078h,000h,000h,083h,086h,08ch,098h,0b0h,0e0h,0c0h,000h	; a386  ...yIy.x..........
	defb 000h,002h,00fh,0e2h,022h,023h,000h,000h,000h,000h,0ffh,000h,08fh,088h,08fh,081h,08fh,000h	; a398  ...."#............
	defb 000h,001h,083h,001h,001h,083h,000h,000h,000h,000h,0f0h,000h,011h,011h,011h,011h,011h,000h	; a3aa  ..................
	defb 000h,01eh,012h,01eh,002h,09eh,000h,000h,000h,000h,000h,000h,0f1h,011h,011h,011h,0f1h,000h	; a3bc  ..................
	defb 000h,03ch,024h,03ch,024h,03ch,000h,000h,000h,000h,000h,000h,010h,090h,050h,030h,010h,000h	; a3ce  .<$<$<........P0..
	defb 000h,078h,008h,078h,040h,078h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; a3e0  .x.x@x............
	defb 000h,001h,003h,001h,001h,083h,080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; a3f2  ..................
	defb 000h,01eh,012h,01eh,002h,09eh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; a404  ..................
	defb 000h,03ch,024h,03ch,024h,03ch,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; a416  .<$<$<............
	defb 000h,048h,048h,078h,008h,008h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; a428  .HHx..............

; ======================================================================
; CODIGO 0xa43a..0xa61a  (480 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; ############################################################
; LAS CAJAS DE COLISION
; ############################################################
; 0xE229-0xE246 son DIEZ registros de tres bytes: clase, X
; izquierda y X derecha. Las rutinas de escena escriben las
; suyas al montar la pantalla, y 0x84EF, 0x8529 y 0x8589 las
; recorren con la X del jugador mas 8. La clase elige manejador
; en la tabla 0x8AA0.
; 0  apagada     0x87A2 la borra al coger el tesoro
; 1  tronco      A751 A793 A7D7 -> 8640, resta dos puntos
; 2  suelo       8D1B 8D35 A9F3 -> 8751, resta cien
; 3  charca      A8FC A938 AC91 -> 8361, mata
; 4  cocodrilo   A828 A841 A85A ADCA -> 8361, el mismo
; 5  liana       A5B8 -> 8162, engancha
; 6  mata        AAA2 AAEA -> 8221
; 7  no se escribe nunca, y su entrada apunta a 874B
; 8  tesoro      ABA2 ABFC AC56 -> 878C, suma miles
; 9  mata        A6B1 -> 8221
; 10  rebote      A9B7 A9D6 -> 85EF, da la vuelta y retrocede
; Solo matan la 3, la 4, la 6 y la 9: son las que acaban
; llamando a quita_una_vida. Y OJO con la 10, que no es la
; escalera por mucho que salga en las escenas que la tienen:
; al subterraneo se baja por 0x83D4, que comprueba el tipo de
; escena y la X a mano, sin caja ninguna.
; Comprobado que la 7 no la escribe nadie: no hay un solo
; `ld (ix+000h),007h` en todo el cartucho.
; ----------------------------------------------------------------------
borra_dibujo_liana:		; Pone a cero los 0x40 bytes de 0xE18A
	ld hl,0e18ah		;a43a   ; los 0x40 bytes de 0xE18A son los DOS patrones de sprite de la cuerda, 32 y 32: 0xA594 sube el primero a la VRAM 0x39E0 (patron 0x3C) y 0xA5A0 el segundo a 0x3B00 (el 0x60)
	ld de,0e18bh		;a43d   ; destino un byte por delante del origen: el borrado en cadena de siempre
	ld (hl),000h		;a440   ; se siembra un cero a mano...
	ld bc,0003fh		;a442   ; ...y el LDIR lo arrastra 0x3F veces: 1 + 63 son los 0x40 de 0xE18A a 0xE1C9
	ldir		;a445
	ret			;a447
pinta_punto_liana:		; X en H, Y en C, sobre el mapa de bits de IY
	push de			;a448
	push iy		;a449
	push bc			;a44b
	ld a,007h		;a44c
	cp h			;a44e   ; de la COLUMNA 8 en adelante -H es la X- se salta 16 bytes, que es la mitad DERECHA del mismo patron de 32: no hay un segundo patron
	jr nc,pinta_punto_liana_fila		;a44f
	ld e,010h		;a451
	ld d,000h		;a453
	add iy,de		;a455
pinta_punto_liana_fila:
	ld e,c			;a457   ; la Y si va como desplazamiento directo: cada fila del patron ocupa un byte
	ld d,000h		;a458
	add iy,de		;a45a
	ld a,h			;a45c   ; de la X solo cuentan los tres bits bajos, o sea la columna dentro del byte
	and 007h		;a45d
	ld b,a			;a45f
	inc b			;a460   ; una rotacion mas que la columna: 1 para la columna 0 y 8 para la 7
	xor a			;a461   ; A a cero y acarreo a 1, que es el bit que las RRA van metiendo por la izquierda
	scf			;a462
pinta_punto_liana_mascara:
	rra			;a463   ; rota el bit hasta la columna que toca
	djnz pinta_punto_liana_mascara		;a464
	or (iy+000h)		;a466
	ld (iy+000h),a		;a469
	pop bc			;a46c
	pop iy		;a46d
	pop de			;a46f
	ret			;a470

; ----------------------------------------------------------------------
; LA LIANA SE DIBUJA, NO SE GUARDA
; No hay dibujos de liana en el cartucho: en cada paso se
; traza una recta de 16 puntos sobre un mapa de bits en
; 0xE18A y se manda a la VRAM como patron de sprite. La
; inclinacion sale de la tabla de 0xA61A indexada por la
; fase (0xE1CB), que va y viene entre 1 y 0x20.
; ----------------------------------------------------------------------
mueve_la_liana:
	bit 7,(ix+000h)		;a471   ; bit 7 = esta escena tiene liana
	ret z			;a475
	push ix		;a476
	call borra_dibujo_liana		;a478
	ld b,014h		;a47b
	ld hl,0a61ah		;a47d
	ld a,(0e1cbh)		;a480   ; 0xE1CB es la fase del balanceo, y cada una son 4 bytes
	sla a		;a483
	sla a		;a485
	ld e,a			;a487
	ld d,000h		;a488
	add hl,de			;a48a
	ld e,(hl)			;a48b
	ld d,000h		;a48c
	inc hl			;a48e
	ld a,(hl)			;a48f
	ld ix,0e32fh		;a490
	ld (ix+010h),a		;a494
	push hl			;a497
	ld hl,08000h		;a498
	bit 7,(ix+016h)		;a49b   ; bit 7 de 0xE32F+0x16 = hacia que lado cae
	jr z,mueve_la_liana_extremo		;a49f
	ld a,d			;a4a1
	cpl			;a4a2
	ld d,a			;a4a3
	ld a,e			;a4a4
	cpl			;a4a5
	ld e,a			;a4a6
	inc de			;a4a7
mueve_la_liana_extremo:
	add hl,de			;a4a8   ; veinte veces la pendiente: el punto de abajo del todo
	djnz mueve_la_liana_extremo		;a4a9
	bit 7,(ix+016h)		;a4ab
	jr z,mueve_la_liana_sprite1		;a4af
	ld a,h			;a4b1
	sub 00fh		;a4b2
	ld h,a			;a4b4
mueve_la_liana_sprite1:
	ld ix,0e276h		;a4b5   ; 0xE276 son los cuatro bytes de atributo del primer sprite: Y, X, patron y color
	ld (ix+001h),h		;a4b9
	ld (ix+000h),033h		;a4bc   ; la Y es FIJA, 0x33: la cuerda cuelga siempre de la misma altura y solo se mueve de lado
	ld (ix+003h),001h		;a4c0   ; color 1, negro
	ld hl,00000h		;a4c4   ; el trazado arranca en cero, con H el pixel y L la fraccion; la primera fila ya lleva una pendiente sumada
	add hl,de			;a4c7
	ld c,000h		;a4c8
	ld b,010h		;a4ca   ; dieciseis vueltas, y C lleva la fila, de 0 a 15
	ld iy,0e18ah		;a4cc
mueve_la_liana_bucle:
	ld a,h			;a4d0   ; dieciseis filas, una por linea del patron
	and 00fh		;a4d1
	ld h,a			;a4d3
	call pinta_punto_liana		;a4d4
	add hl,de			;a4d7
	inc c			;a4d8
	djnz mueve_la_liana_bucle		;a4d9
	ld a,h			;a4db   ; en H queda la ultima fila alcanzada: de ahi salen las X de los otros dos sprites
	ld ix,0e32fh		;a4dc
	bit 7,(ix+016h)		;a4e0
	jr z,mueve_la_liana_sprite2		;a4e4
	sub 00fh		;a4e6
mueve_la_liana_sprite2:
	ld ix,0e276h		;a4e8   ; 0xE276 es el primer sprite de la cuerda y 0xE27A el segundo
	ld iy,0e27ah		;a4ec
	ld (iy+003h),001h		;a4f0
	add a,(ix+001h)		;a4f4   ; la X del segundo es la del primero mas lo que se ha desplazado
	ld (iy+001h),a		;a4f7
	ld a,(ix+000h)		;a4fa
	add a,010h		;a4fd   ; y la Y, 16 pixeles mas abajo: los tres sprites van encadenados
	ld (iy+000h),a		;a4ff
	ld a,h			;a502
	sla a		;a503   ; para el tercero el desplazamiento va doblado
	ld ix,0e32fh		;a505
	bit 7,(ix+016h)		;a509
	jr z,mueve_la_liana_sprite3		;a50d
	sub 01eh		;a50f
mueve_la_liana_sprite3:
	ld ix,0e276h		;a511
	ld iy,0e27eh		;a515   ; 0xE27E, el tercero
	add a,(ix+001h)		;a519
	ld (iy+001h),a		;a51c
	ld a,(ix+000h)		;a51f
	add a,020h		;a522   ; y 0x20 por debajo del primero
	ld (iy+000h),a		;a524
	pop hl			;a527
	inc hl			;a528
	ld b,(hl)			;a529
	push hl			;a52a
	ld h,(iy+001h)		;a52b
	ld l,000h		;a52e
mueve_la_liana_agarre:
	add hl,de			;a530   ; desde la X del tercer sprite, tantos pasos mas de pendiente como diga el tercer byte de la fase: 0x10 con la liana vertical y 0x06 en el extremo
	djnz mueve_la_liana_agarre		;a531
	ld a,h			;a533   ; y en H sale ya la X del punto de agarre
	ld ix,0e32fh		;a534
	bit 7,(ix+016h)		;a538
	jr z,mueve_la_liana_guarda_agarre		;a53c
	add a,012h		;a53e   ; cayendo hacia el otro lado, 18 pixeles a la derecha: la recta se dibuja desde la columna 15 y a los sprites se les resto 0x0F y 0x1E en 0xA4B2 y 0xA50F, asi que el punto de agarre hay que devolverlo a su sitio
mueve_la_liana_guarda_agarre:
	ld (0e1cdh),a		;a540   ; 0xE1CD = la X donde se agarra el jugador
	pop hl			;a543   ; el retorno apilado apunta a la fase: se lee de ahi y se sigue detras
	ld c,(hl)			;a544
	inc hl			;a545
	ld a,(hl)			;a546   ; el cuarto byte de la fase va a 0xE1E2: en que paso de la curva del salto se cae al soltarse
	ld (0e1e2h),a		;a547
	ld hl,0e1cch		;a54a
	ld (hl),c			;a54d
	ld b,000h		;a54e
	push bc			;a550
	ld hl,0e18ah		;a551   ; estos dos LDIR fabrican el patron del TERCER sprite -el 0x60- copiando solo B filas de cada mitad (B = tercer byte de la fase) sobre mapas que 0xA43A dejo a cero: el tercer sprite se corta en el punto de agarre. La cuerda mide 32+B filas -48 en vertical, 38 en el extremo- y se acorta al tumbarse
	ld de,0e1aah		;a554
	ldir		;a557
	pop bc			;a559
	ld hl,0e19ah		;a55a
	ld de,0e1bah		;a55d
	ldir		;a560
	ld iy,0e27eh		;a562   ; 0xE27E es el tercer sprite de la cuerda: color 1
	ld (iy+003h),001h		;a566
	ld a,(0e221h)		;a56a   ; si corre la demo (0xE221) los tres sprites de la cuerda cambian de color
	or a			;a56d
	jr z,mueve_la_liana_vuelca		;a56e
	ld hl,0e279h		;a570
	ld (hl),000h		;a573
	ld hl,0e27dh		;a575
	ld (hl),00fh		;a578
	ld hl,0e281h		;a57a
	ld (hl),00fh		;a57d
mueve_la_liana_vuelca:
	ld a,(0e1cbh)		;a57f   ; solo con la fase 1 -la liana vertical- se vuelca aqui la tabla de sprites
	cp 002h		;a582
	jr nc,mueve_la_liana_a_vram		;a584   ; de la fase 2 en adelante se salta el volcado: el bucle principal ya lo hace al final de cada cuadro (0x8106)
	ld a,006h		;a586   ; este ld a,006h no lo lee nadie: 0xB1C3 trabaja con HL, DE y BC, y lo primero que hace 0xB185 es machacar A
	ld hl,0e26ah		;a588   ; los 0x54 bytes de 0xE26A a la VRAM 0x1B00, la tabla de atributos de sprites entera
	ld de,01b00h		;a58b
	ld bc,00054h		;a58e
	call copia_bloque_a_vram		;a591
mueve_la_liana_a_vram:
	ld hl,0e18ah		;a594
	ld de,039e0h		;a597   ; los dos patrones de sprite de la cuerda
	ld bc,00020h		;a59a
	call copia_bloque_a_vram		;a59d
	ld hl,0e1aah		;a5a0
	ld de,03b00h		;a5a3
	ld bc,00020h		;a5a6
	call copia_bloque_a_vram		;a5a9
	pop ix		;a5ac
	ld b,004h		;a5ae   ; la caja de la liana mide ocho pixeles: cuatro a cada lado del punto de agarre
	ld c,004h		;a5b0
	push ix		;a5b2
	ld ix,0e23eh		;a5b4
	ld (ix+000h),005h		;a5b8   ; la caja de la liana, clase 5
	ld a,(0e1cdh)		;a5bc
	sub b			;a5bf
	ld (ix+001h),a		;a5c0
	ld a,(0e1cdh)		;a5c3
	add a,c			;a5c6
	ld (ix+002h),a		;a5c7
	pop ix		;a5ca
	ld a,(0e2ebh)		;a5cc   ; bit 7 de 0xE2EB, que es el IX+0x16 del jugador: lo enciende 0x817C al agarrarse
	bit 7,a		;a5cf
	call nz,lleva_al_jugador_colgado		;a5d1
	ld hl,0e1cbh		;a5d4   ; 0xE1CB es la fase del balanceo, de 1 a 0x20, y el bit 0 de IX+0x16 dice si va o vuelve
	bit 0,(ix+016h)		;a5d7
	jr nz,mueve_la_liana_vuelve		;a5db
	dec (hl)			;a5dd   ; de ida la fase baja hasta 1
	ld a,001h		;a5de
	cp (hl)			;a5e0
	ret nz			;a5e1
	set 0,(ix+016h)		;a5e2
	ld a,(ix+016h)		;a5e6
	xor 080h		;a5e9   ; y al llegar se le da la vuelta al bit 7 de IX+0x16
	ld (ix+016h),a		;a5eb
	ret			;a5ee
mueve_la_liana_vuelve:
	inc (hl)			;a5ef   ; a 0x20 se acabo la ida y empieza la vuelta
	ld a,020h		;a5f0
	cp (hl)			;a5f2
	ret nz			;a5f3
	res 0,(ix+016h)		;a5f4
	ret			;a5f8
lleva_al_jugador_colgado:
	ld iy,0e2a2h		;a5f9   ; colgado, la liana te escribe la X (de 0xE1CD) y la Y (de 0xE1CC mas 0x5D)
	ld hl,0e2dbh		;a5fd
	ld a,(0e1cdh)		;a600
	bit 7,(hl)		;a603
	jr z,lleva_al_jugador_colgado_y		;a605
	add a,003h		;a607
lleva_al_jugador_colgado_y:
	sub 00ah		;a609   ; diez pixeles a la izquierda del punto de agarre, siete si mira al otro lado
	ld (iy+001h),a		;a60b
	ld a,(0e1cch)		;a60e
	add a,05dh		;a611
	ld (iy+000h),a		;a613
	ld (0e1cch),a		;a616   ; la Y ya sumada vuelve a 0xE1CC, que 0xA529 recalcula en cada cuadro
	ret			;a619

; ----------------------------------------------------------------------
; DATOS tabla_del_balanceo: Treinta y tres registros de cuatro bytes, uno por
;   fase del balanceo de la liana: 0xA47D indexa con (0xE1CB)*4 y la fase va y
;   viene entre 1 (vertical) y 0x20 (tumbada). Los cuatro bytes: (1) pendiente
;   de la cuerda en 1/256 de pixel por fila, 0x00 a 0xC9 (el DE que 0xA4C4
;   acumula); (2) PERIODO del objeto (0xA48F lo escribe en 0xE33F), 1 cuadro
;   en el centro y 9 en el extremo: el balanceo frena en las puntas como un
;   pendulo, y media ida son 75 cuadros sumando los 32 periodos; (3) cuantas
;   veces mas se suma la pendiente hasta el punto de agarre (0xA529, guardado
;   en 0xE1CC), 0x10 vertical a 0x06 extremo; (4) en que paso de la curva del
;   salto arranca la caida al soltarse (0xA546 -> 0xE1E2, 0x821A -> IX+0x17),
;   0x00 vertical a 0x10 extremo. Acaba donde empieza su consumidor, 0xA69E
;   0xa61a..0xa69e  (132 bytes)
DATA_tabla_del_balanceo:
	defb 000h,001h,010h,000h	; a61a
	defb 007h,001h,010h,000h	; a61e
	defb 00eh,001h,010h,000h	; a622
	defb 015h,001h,010h,000h	; a626
	defb 01ch,001h,010h,000h	; a62a
	defb 024h,001h,010h,000h	; a62e
	defb 02bh,001h,00fh,001h	; a632
	defb 033h,001h,00fh,001h	; a636
	defb 03ah,001h,00fh,001h	; a63a
	defb 041h,001h,00fh,001h	; a63e
	defb 049h,002h,00fh,001h	; a642
	defb 055h,002h,00eh,002h	; a646
	defb 05ch,002h,00eh,002h	; a64a
	defb 061h,002h,00dh,003h	; a64e
	defb 069h,002h,00dh,003h	; a652
	defb 072h,002h,00ch,004h	; a656
	defb 07ch,002h,00bh,005h	; a65a
	defb 080h,002h,00bh,005h	; a65e
	defb 083h,002h,00bh,005h	; a662
	defb 089h,002h,00ah,006h	; a666
	defb 08dh,002h,00ah,006h	; a66a
	defb 091h,002h,00ah,006h	; a66e
	defb 098h,002h,009h,008h	; a672
	defb 09ch,002h,009h,008h	; a676
	defb 0a0h,002h,009h,008h	; a67a
	defb 0a6h,003h,008h,00bh	; a67e
	defb 0aah,003h,008h,00bh	; a682
	defb 0aeh,003h,008h,00bh	; a686
	defb 0b5h,004h,007h,00fh	; a68a
	defb 0b9h,004h,007h,00fh	; a68e
	defb 0bdh,004h,007h,00fh	; a692
	defb 0c5h,006h,006h,010h	; a696
	defb 0c9h,009h,006h,010h	; a69a

; ======================================================================
; CODIGO 0xa69e..0xaa73  (981 bytes)
; ======================================================================


mueve_el_escorpion:		; Manejador de 0xE2ED, EL ESCORPION del subterraneo (identificado mirando la franja del tunel): se acerca a la X del jugador
	ld hl,0e2a3h		;a69e
	ld iy,0e292h		;a6a1
	ld a,(iy+001h)		;a6a5   ; 0xE292 es donde esta el bicho
	add a,008h		;a6a8
	ld b,a			;a6aa
	push ix		;a6ab
	ld ix,0e241h		;a6ad
	ld (ix+000h),009h		;a6b1   ; su caja, clase 9
	ld a,b			;a6b5
	sub 00ah		;a6b6
	ld (ix+001h),a		;a6b8
	ld a,b			;a6bb
	add a,00ah		;a6bc
	ld (ix+002h),a		;a6be
	pop ix		;a6c1
	ld a,(iy+001h)		;a6c3
	cp (hl)			;a6c6   ; compara su X con la del jugador y decide el lado
	jr c,escorpion_hacia_la_derecha		;a6c7
	jr z,escorpion_se_para		;a6c9
	set 7,(ix+006h)		;a6cb
	ld de,0af58h		;a6cf
	ld (ix+00ch),e		;a6d2
	ld (ix+00dh),d		;a6d5
	set 5,(ix+000h)		;a6d8
	set 0,(ix+006h)		;a6dc
	ld de,0ff40h		;a6e0
	ld (ix+008h),d		;a6e3
	ld (ix+007h),e		;a6e6
	ret			;a6e9
escorpion_hacia_la_derecha:
	res 7,(ix+006h)		;a6ea   ; bit 7 de IX+0x06 apagado: mira a la derecha. La rama de 0xA6CB lo enciende para el otro lado
	ld de,0af52h		;a6ee   ; el guion de animacion de 0xAF52 -el de andar hacia la derecha- a IX+0x0C/0D
	ld (ix+00ch),e		;a6f1
	ld (ix+00dh),d		;a6f4
	set 5,(ix+000h)		;a6f7   ; bit 5 de IX+0x00 = animado, y bit 0 de IX+0x06 = se mueve en X
	set 0,(ix+006h)		;a6fb
	ld d,000h		;a6ff
	ld e,0c0h		;a701   ; 0x00C0 en IX+0x07/08, tres cuartos de pixel por cuadro; el 0xFF40 de la rama de la izquierda es ese mismo paso cambiado de signo
	ld (ix+008h),d		;a703   ; el byte alto en IX+0x08 y el bajo en IX+0x07, en ese orden
	ld (ix+007h),e		;a706
	ret			;a709
escorpion_se_para:
	res 5,(ix+000h)		;a70a   ; justo encima: se queda quieto
	res 0,(ix+006h)		;a70e
	ld (ix+00fh),000h		;a712
	ld (ix+00eh),001h		;a716
	ld iy,0e2a2h		;a71a
	ld de,00000h		;a71e
	ld (ix+008h),d		;a721
	ld (ix+007h),e		;a724
	ret			;a727
mueve_los_troncos:		; Manejador de 0xE303
	ld hl,0e136h		;a728
	ld iy,0e282h		;a72b
	ld a,(0e224h)		;a72f
	cp 004h		;a732   ; con variante 4 o mas los troncos no giran
	jr nc,mueve_los_troncos_quieto		;a734
	inc (hl)			;a736
	bit 3,(hl)		;a737
	jr nz,mueve_los_troncos_quieto		;a739
	ld (iy+000h),06eh		;a73b
	jr coloca_los_troncos		;a73f
mueve_los_troncos_quieto:
	ld (iy+000h),06fh		;a741
coloca_los_troncos:
	ld a,(iy+001h)		;a745   ; el centro del tronco: su X mas 8
	add a,008h		;a748
	ld b,a			;a74a
	push ix		;a74b
	ld ix,0e232h		;a74d
	ld (ix+000h),001h		;a751   ; caja del primer tronco, clase 1
	ld a,b			;a755
	sub 009h		;a756   ; y la caja va de centro-9 a centro+9, dieciocho pixeles
	ld (ix+001h),a		;a758
	ld a,b			;a75b
	add a,009h		;a75c
	ld (ix+002h),a		;a75e
	pop ix		;a761
	ld a,(0e224h)		;a763   ; los otros dos solo salen si la variante lo pide
	and 003h		;a766
	ret z			;a768
	ld ix,0e286h		;a769   ; el segundo tronco, sprite 0xE286: misma Y y mismo patron que el primero, separados por 0xE137
	ld a,(0e137h)		;a76d
	ld iy,0e282h		;a770
	add a,(iy+001h)		;a774
	ld (ix+001h),a		;a777
	add a,008h		;a77a
	ld b,a			;a77c
	ld a,(iy+000h)		;a77d
	ld (ix+000h),a		;a780
	ld a,(iy+002h)		;a783
	ld (ix+002h),a		;a786
	ld (ix+003h),006h		;a789   ; color 6 en los tres troncos
	push ix		;a78d
	ld ix,0e235h		;a78f
	ld (ix+000h),001h		;a793
	ld a,b			;a797
	sub 009h		;a798
	ld (ix+001h),a		;a79a
	ld a,b			;a79d
	add a,009h		;a79e
	ld (ix+002h),a		;a7a0
	pop ix		;a7a3
	ld a,(0e224h)		;a7a5   ; el tercero solo aparece con variante 3 o mas
	cp 003h		;a7a8
	ret c			;a7aa
	ld ix,0e28ah		;a7ab
	ld a,(0e137h)		;a7af
	sla a		;a7b2   ; y va al doble de distancia: dos veces 0xE137
	ld iy,0e282h		;a7b4
	add a,(iy+001h)		;a7b8
	ld (ix+001h),a		;a7bb
	add a,008h		;a7be
	ld b,a			;a7c0
	ld a,(iy+000h)		;a7c1
	ld (ix+000h),a		;a7c4
	ld a,(iy+002h)		;a7c7
	ld (ix+002h),a		;a7ca
	ld (ix+003h),006h		;a7cd
	push ix		;a7d1
	ld ix,0e238h		;a7d3
	ld (ix+000h),001h		;a7d7   ; caja del tercer tronco
	ld a,b			;a7db
	sub 009h		;a7dc
	ld (ix+001h),a		;a7de
	ld a,b			;a7e1
	add a,009h		;a7e2
	ld (ix+002h),a		;a7e4
	pop ix		;a7e7
	ld a,(0e224h)		;a7e9
	cp 005h		;a7ec
	ret nz			;a7ee
	ld hl,0e286h		;a7ef   ; en la variante 5 el segundo se apaga poniendo su Y a cero
	ld (hl),000h		;a7f2
	ret			;a7f4
mueve_los_cocodrilos:		; Manejador de 0xE303 en la laguna: tres bocas
	push ix		;a7f5
	ld ix,0e282h		;a7f7
	ld a,(ix+002h)		;a7fb   ; el patron del primero se copia a los otros dos: las tres bocas van a una
	ld iy,0e286h		;a7fe
	ld (iy+002h),a		;a802
	ld iy,0e28ah		;a805
	ld (iy+002h),a		;a809
	ld c,010h		;a80c   ; anchura de cada boca cerrada
	ld d,005h		;a80e
	ld e,005h		;a810
	cp 0fch		;a812   ; 0xFC = boca abierta, y entonces la caja crece
	jr nz,cocodrilos_cajas		;a814
	ld a,c			;a816
	add a,00bh		;a817
	ld c,a			;a819
	ld a,d			;a81a
	add a,00fh		;a81b
	ld d,a			;a81d
	ld a,e			;a81e
	add a,00fh		;a81f
	ld e,a			;a821
cocodrilos_cajas:
	push ix		;a822
	ld ix,0e229h		;a824
	ld (ix+000h),004h		;a828   ; los tres van en 0x50, 0x6F y 0x88, clase 4
	ld a,050h		;a82c   ; la primera caja arranca en 0x50 y mide lo que diga C
	sub 000h		;a82e
	ld (ix+001h),a		;a830
	ld a,050h		;a833
	add a,c			;a835
	ld (ix+002h),a		;a836
	pop ix		;a839
	push ix		;a83b
	ld ix,0e22ch		;a83d
	ld (ix+000h),004h		;a841
	ld a,06fh		;a845   ; la segunda en 0x6F, con D
	sub 000h		;a847
	ld (ix+001h),a		;a849
	ld a,06fh		;a84c
	add a,d			;a84e
	ld (ix+002h),a		;a84f
	pop ix		;a852
	push ix		;a854
	ld ix,0e22fh		;a856
	ld (ix+000h),004h		;a85a
	ld a,088h		;a85e   ; y la tercera en 0x88, con E: abriendo la boca la primera crece 0x0B y las otras dos 0x0F
	sub 000h		;a860
	ld (ix+001h),a		;a862
	ld a,088h		;a865
	add a,e			;a867
	ld (ix+002h),a		;a868
	pop ix		;a86b
	pop ix		;a86d
	ret			;a86f

; ----------------------------------------------------------------------
; EL HOYO QUE SE ABRE Y SE CIERRA
; 0xE133 es lo ancho que esta (1 a 8) y 0xE132 hacia donde
; va. Se pinta con cuatro tiras de tiles de 0xB0D0 cuya
; longitud es esa anchura, y la caja de clase 3 se estira
; con ella. Mientras se mueve el periodo es 3, o sea un paso
; cada tres cuadros; al llegar a los topes se para, y ahi el
; reparto NO es simetrico: 0x96 cuadros con el hoyo estrecho
; (0xA913) contra 0x44 con el hoyo abierto del todo (0xA952).
; ----------------------------------------------------------------------
abre_el_hoyo:		; Manejador de 0xE2BF: pinta el hoyo mientras se ensancha
	ld ix,0e2bfh		;a870
	ld (ix+010h),003h		;a874   ; mientras se mueve, un paso por cuadro
	ld hl,001d0h		;a878   ; las dos tiras salen de la misma celda, la 0x1D0 (fila 14, columna 16): una crece a la izquierda y la otra a la derecha
	ld de,(0e133h)		;a87b
	ld d,000h		;a87f
	or a			;a881
	sbc hl,de		;a882
	ld de,01800h		;a884   ; 0x1800 es la tabla de nombres: la celda ya es direccion de VRAM
	add hl,de			;a887
	ex de,hl			;a888
	ld hl,0b0d0h		;a889
	ld bc,(0e133h)		;a88c
	call copia_bloque_a_vram		;a890
	ld hl,0e133h		;a893   ; la de la derecha lee los ULTIMOS bytes de la tira de 0xB0D8, no los primeros
	ld a,008h		;a896
	sub (hl)			;a898
	ld e,a			;a899
	ld d,000h		;a89a
	ld hl,0b0d8h		;a89c
	add hl,de			;a89f
	ld de,019d0h		;a8a0
	ld bc,(0e133h)		;a8a3
	call copia_bloque_a_vram		;a8a7
	ld hl,001f0h		;a8aa   ; y otras dos iguales una fila mas abajo, desde la celda 0x1F0
	ld de,(0e133h)		;a8ad
	ld d,000h		;a8b1
	or a			;a8b3
	sbc hl,de		;a8b4
	ld de,01800h		;a8b6
	add hl,de			;a8b9
	ex de,hl			;a8ba
	ld hl,0b0e0h		;a8bb
	ld bc,(0e133h)		;a8be
	call copia_bloque_a_vram		;a8c2
	ld de,001f0h		;a8c5
	ld hl,0e133h		;a8c8
	ld a,008h		;a8cb
	sub (hl)			;a8cd
	ld e,a			;a8ce
	ld d,000h		;a8cf
	ld hl,0b0e8h		;a8d1
	add hl,de			;a8d4
	ld de,019f0h		;a8d5
	ld bc,(0e133h)		;a8d8
	call copia_bloque_a_vram		;a8dc
	ld a,(0e132h)		;a8df
	cp 001h		;a8e2
	jp z,cierra_el_hoyo		;a8e4
	ld a,(0e133h)		;a8e7   ; la anchura por 8 son pixeles: la caja va de 0x88-(8W-8) a 0x88+(8W-24), asi que con W=1 queda del reves y no atrapa a nadie
	sla a		;a8ea
	sla a		;a8ec
	sla a		;a8ee
	sub 008h		;a8f0
	ld l,a			;a8f2
	sub 010h		;a8f3
	ld h,a			;a8f5
	push ix		;a8f6
	ld ix,0e22ch		;a8f8
	ld (ix+000h),003h		;a8fc   ; la caja del hoyo, clase 3
	ld a,088h		;a900
	sub l			;a902
	ld (ix+001h),a		;a903
	ld a,088h		;a906
	add a,h			;a908
	ld (ix+002h),a		;a909
	pop ix		;a90c
	ld hl,0e133h		;a90e
	dec (hl)			;a911   ; al llegar a cero cambia de sentido
	ret nz			;a912
	ld (hl),001h		;a913
	ld a,001h		;a915
	ld (0e132h),a		;a917
	ld ix,0e2bfh		;a91a
	ld (ix+010h),096h		;a91e
	ret			;a922
cierra_el_hoyo:
	ld a,(0e133h)		;a923   ; la misma cuenta de la caja, pero mientras ensancha
	sla a		;a926
	sla a		;a928
	sla a		;a92a
	sub 008h		;a92c
	ld l,a			;a92e
	sub 010h		;a92f
	ld h,a			;a931
	push ix		;a932
	ld ix,0e22ch		;a934
	ld (ix+000h),003h		;a938
	ld a,088h		;a93c
	sub l			;a93e
	ld (ix+001h),a		;a93f
	ld a,088h		;a942
	add a,h			;a944
	ld (ix+002h),a		;a945
	pop ix		;a948
	ld hl,0e133h		;a94a
	inc (hl)			;a94d   ; y la anchura sube hasta 8
	ld a,(hl)			;a94e
	cp 009h		;a94f
	ret c			;a951
	ld (hl),008h		;a952   ; a 8 se para: hoyo del todo abierto
	ld a,000h		;a954
	ld (0e132h),a		;a956
	ld ix,0e2bfh		;a959
	ld (ix+010h),044h		;a95d
	ret			;a961
hoyo_sin_pintar:		; Igual que 0xA870 pero solo mueve la caja
	ld ix,0e2bfh		;a962
	ld (ix+010h),003h		;a966   ; periodo 3: un paso cada tres cuadros mientras se mueve
	ld a,(0e132h)		;a96a   ; 0xE132 dice en que sentido va: con 1 la anchura sube, con 0 baja
	cp 001h		;a96d
	jp z,hoyo_sin_pintar_cierra		;a96f
	ld hl,0e133h		;a972
	dec (hl)			;a975
	ret nz			;a976
	ld (hl),001h		;a977
	ld a,001h		;a979
	ld (0e132h),a		;a97b
	ld ix,0e2bfh		;a97e
	ld (ix+010h),096h		;a982   ; al llegar al minimo se queda quieto 0x96 cuadros
	ret			;a986
hoyo_sin_pintar_cierra:
	ld hl,0e133h		;a987
	inc (hl)			;a98a
	ld a,(hl)			;a98b
	cp 009h		;a98c   ; 0xE133 no pasa de 8
	ret c			;a98e
	ld (hl),008h		;a98f
	ld a,000h		;a991
	ld (0e132h),a		;a993
	ld ix,0e2bfh		;a996
	ld (ix+010h),044h		;a99a   ; y en el maximo solo 0x44
	ret			;a99e
despacha_por_variante:		; HL = tabla, A = variante (0xE224)
	sla a		;a99f   ; la variante doblada: la tabla son punteros de palabra
	ld e,a			;a9a1
	ld d,000h		;a9a2
	add hl,de			;a9a4
	ld e,(hl)			;a9a5
	inc hl			;a9a6
	ld d,(hl)			;a9a7
	ex de,hl			;a9a8
	jp (hl)			;a9a9   ; jp (hl): la rutina de la variante hereda el retorno

; ----------------------------------------------------------------------
; ############################################################
; LOS OCHO TIPOS DE ESCENA
; ############################################################
; Los bits 3-5 del registro de pantalla (0xE225) eligen una de
; estas ocho rutinas por la tabla 0xAEB4, y cada una monta un
; tipo de pantalla distinto. Los nombres salen de leer lo que
; monta cada una y de mirar la captura de las 255 escenas:
; 0 y 1  A9AA  hoyos en el suelo, CON ESCALERA al subterraneo
; 2      AC7C  charca de brea, Y CON LIANA
; 3      AC6B  charca de agua, Y CON LIANA
; 4      AD75  laguna con TRES cocodrilos
; 5      ADF6  la escena del TESORO, la unica que puntua
; 6      AE04  brea con liana
; 7      ADE8  agua, SIN liana
; Lo de la liana estaba mal contado, y se comprueba sin jugar:
; 0x9F4B-0x9F4E apaga el bit 7 de 0xE32F+0x00 al montar CADA
; escena, y ese bit es justo el que mira 0xA471 antes de hacer
; nada. Lo unico que lo vuelve a encender es monta_la_liana
; (0xAE38), que copia encima la plantilla 0xB02A, cuyo primer
; byte vale 0xC0. Y a monta_la_liana la llaman tres sitios y no
; mas: 0xAC88 (tipo 2), 0xAC77 (tipo 3) y 0xAE04 (tipo 6). El
; tipo 7 no la llama, asi que se queda SIN liana; los tipos 2 y
; 3 SI la tienen. Con liana son 96 escenas de las 255, no 64.
; El reparto del anillo es uniforme: 31 escenas del tipo 0 y 32
; de cada uno de los otros siete. Y los tipos 2 y 3 son EL MISMO
; DIBUJO con distinto color: uno escribe 1B 1B 1B (negro, brea)
; en la tabla de colores y el otro 7B 7B 7B (cian, agua)
; ----------------------------------------------------------------------
escena_tipo_0_y_1_hoyos:
	ld a,(0e222h)		;a9aa   ; el bit 7 del registro de pantalla parte este tipo en dos: un hoyo (bit a 0) o tres (bit a 1)
	bit 7,a		;a9ad
	jr z,hoyos_escalera_izquierda		;a9af
	push ix		;a9b1
	ld ix,0e241h		;a9b3
	ld (ix+000h),00ah		;a9b7   ; clase 10 (0xE241), que NO es la escalera: 0x85EF la usa para rebotar
	ld a,0d8h		;a9bb   ; centrada en 0xD8 cuando son tres hoyos
	sub 00ch		;a9bd
	ld (ix+001h),a		;a9bf
	ld a,0d8h		;a9c2
	add a,00ch		;a9c4
	ld (ix+002h),a		;a9c6
	pop ix		;a9c9
	call pinta_la_escalera_a		;a9cb
	jr hoyos_carga_sprites		;a9ce
hoyos_escalera_izquierda:
	push ix		;a9d0
	ld ix,0e241h		;a9d2   ; 0xE241 es la cuarta de las diez cajas de 0xE229
	ld (ix+000h),00ah		;a9d6   ; la misma clase 10 que la otra rama: rebotar, que no es bajar al subterraneo
	ld a,031h		;a9da   ; y en 0x31 cuando es uno
	sub 00ch		;a9dc
	ld (ix+001h),a		;a9de
	ld a,031h		;a9e1
	add a,00dh		;a9e3   ; de 0x25 a 0x3E, veinticinco pixeles: uno mas que la de tres hoyos, que usa +0x0C en vez de +0x0D
	ld (ix+002h),a		;a9e5
	pop ix		;a9e8
	call pinta_la_escalera_b		;a9ea   ; y los pilares del juego b. La escalera en si es la misma en las dos ramas -el guion 0x8F06, columna 16-: lo de la izquierda es donde cae la caja, no donde esta la escalera
hoyos_carga_sprites:
	push ix		;a9ed
	ld ix,0e22ch		;a9ef
	ld (ix+000h),002h		;a9f3   ; caja clase 2
	ld a,07dh		;a9f7   ; la caja del hoyo va de 0x7D a 0x8B, catorce pixeles
	sub 000h		;a9f9
	ld (ix+001h),a		;a9fb
	ld a,07dh		;a9fe
	add a,00eh		;aa00
	ld (ix+002h),a		;aa02
	pop ix		;aa05
	ld hl,099cfh		;aa07   ; tres bloques de 0x20 bytes a los patrones de sprite 0x3C, 0x84 y 0xCC
	ld de,039e0h		;aa0a
	ld bc,00020h		;aa0d
	call copia_bloque_a_vram		;aa10
	ld hl,09a0fh		;aa13
	ld de,03c20h		;aa16
	ld bc,00020h		;aa19
	call copia_bloque_a_vram		;aa1c
	ld hl,09a2fh		;aa1f
	ld de,03e60h		;aa22
	ld bc,00020h		;aa25
	call copia_bloque_a_vram		;aa28
	ld hl,09a4fh		;aa2b   ; y la tapa del suelo al patron 0, que es lo que oculta al muneco al cruzar
	ld de,03800h		;aa2e
	ld bc,00020h		;aa31
	call copia_bloque_a_vram		;aa34
	ld bc,00002h		;aa37   ; se duplican patrones para tener la pareja de sprites
	ld hl,039e0h		;aa3a
	ld de,03b10h		;aa3d
	call copia_patrones_en_espejo		;aa40
	ld bc,00002h		;aa43
	ld hl,039f0h		;aa46
	ld de,03b00h		;aa49
	call copia_patrones_en_espejo		;aa4c
	ld bc,00002h		;aa4f
	ld hl,03c20h		;aa52
	ld de,03d50h		;aa55
	call copia_patrones_en_espejo		;aa58
	ld bc,00002h		;aa5b
	ld hl,03c30h		;aa5e
	ld de,03d40h		;aa61
	call copia_patrones_en_espejo		;aa64
	call pinta_los_hoyos		;aa67
	ld a,(0e224h)		;aa6a
	ld hl,0aec4h		;aa6d
	jp despacha_por_variante		;aa70

; ----------------------------------------------------------------------
; DATOS ret_huerfano_aa73: Un `ret` detras del `jp` de 0xAA70
;   0xaa73..0xaa74  (1 bytes)
DATA_ret_huerfano_aa73:
	defb 0c9h	; aa73

; ======================================================================
; CODIGO 0xaa74..0xacb4  (576 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; Las variantes que ponen el estorbo de la derecha. Cada una
; carga sus patrones de sprite, pinta un dibujo de 3x2 celdas
; en el mismo hueco (filas 14-15, columnas 24-26) y declara su
; caja. Identificados mirando las capturas: la variante 7 es LA
; SERPIENTE (0xAA74), la 6 es LA FOGATA (0xAAB7), y las otras
; seis ponen EL TRONCO parado de 0xAD1F.
; ----------------------------------------------------------------------
monta_la_serpiente:		; Guion 0xB040, sprites de 0x9989, caja clase 6. El dibujo es LA SERPIENTE enroscada con la cabeza alzada (identificada mirando la captura de una escena con variante 7)
	ld hl,09989h		;aa74
	call descomprime_rle_a_vram		;aa77
	ld hl,0b040h		;aa7a
	call pinta_celdas		;aa7d
	ld de,0e28eh		;aa80   ; 0xE28E es la entrada de sprite del estorbo, y 0xE319 su objeto
	ld hl,0b010h		;aa83
	ld bc,00004h		;aa86
	ldir		;aa89
	ld de,0e319h		;aa8b
	ld hl,0b014h		;aa8e
	ld bc,00016h		;aa91
	ldir		;aa94
	ld de,0e319h		;aa96
	call anade_objeto		;aa99
	push ix		;aa9c
	ld ix,0e23bh		;aa9e
	ld (ix+000h),006h		;aaa2   ; clase 6, de 0xC3 a 0xD2
	ld a,0c3h		;aaa6   ; la caja va de 0xC3 a 0xD2, dieciseis pixeles
	sub 000h		;aaa8
	ld (ix+001h),a		;aaaa
	ld a,0c3h		;aaad
	add a,00fh		;aaaf
	ld (ix+002h),a		;aab1
	pop ix		;aab4
	ret			;aab6
monta_la_fogata:		; Guion 0xB0C2, sprites de 0x9865, caja clase 6. El dibujo es LA FOGATA: las llamas blancas sobre dos palos (variante 6)
	ld hl,0b0c2h		;aab7   ; la fogata pinta primero y carga los patrones despues, al reves que la serpiente
	call pinta_celdas		;aaba
	ld hl,09865h		;aabd
	call descomprime_rle_a_vram		;aac0
	ld de,0e28eh		;aac3   ; los mismos 0xE28E y 0xE319 que la serpiente: el estorbo se monta igual
	ld hl,0b010h		;aac6
	ld bc,00004h		;aac9
	ldir		;aacc
	ld de,0e319h		;aace   ; y su objeto 0xE319, con la plantilla de siempre
	ld hl,0b014h		;aad1
	ld bc,00016h		;aad4
	ldir		;aad7
	ld hl,0e291h		;aad9
	ld (hl),00fh		;aadc
	ld de,0e319h		;aade
	call anade_objeto		;aae1
	push ix		;aae4
	ld ix,0e23bh		;aae6
	ld (ix+000h),006h		;aaea
	ld a,0c3h		;aaee
	sub 000h		;aaf0
	ld (ix+001h),a		;aaf2
	ld a,0c3h		;aaf5
	add a,00fh		;aaf7
	ld (ix+002h),a		;aaf9
	pop ix		;aafc
	ret			;aafe

; ----------------------------------------------------------------------
; ############################################################
; LOS 32 TESOROS: DONDE ESTAN, CUANTO VALEN Y COMO SE MARCAN
; ############################################################
; Los tesoros son EXACTAMENTE las 32 escenas de tipo 5, y el
; tipo 5 es el unico que despacha por la tabla 0xAEA4, que
; lleva cuatro rutinas repetidas de dos en dos. Como las ocho
; variantes se reparten a cuatro escenas cada una, sale un
; tesoro de cada clase OCHO veces: 8+8+8+8 = 32, y ni uno mas.
; Cada rutina escribe en 0xE188 lo que vale el suyo -2, 3, 4 o
; 5, o sea miles de puntos-, asi que el mundo entero guarda
; 8*(2000+3000+4000+5000) = 112000 puntos. Con los 2000 con los
; que arranca el marcador, 114000: el techo del juego.
; Y LO COGIDO SE RECUERDA EN 32 BITS: 0xE21D-0xE220, un byte
; por clase y un bit por tesoro. El indice dentro de la clase
; es 0xE223
; ----------------------------------------------------------------------
tesoro_ya_cogido:
	ld hl,0e186h		;aaff   ; guarda el puntero al byte de banderas de esta clase en 0xE186/0xE187, que 0x878C recupera al recogerlo
	ld (hl),e			;ab02
	inc hl			;ab03
	ld (hl),d			;ab04
	ld a,(0e223h)		;ab05   ; 0xE223 es cual de los ocho tesoros de la clase es este: dice que bit mirar
	cp 000h		;ab08
	jr nz,tesoro_ya_cogido_bit		;ab0a
	ld a,(de)			;ab0c
	rr a		;ab0d
	jr tesoro_ya_cogido_decide		;ab0f
tesoro_ya_cogido_bit:
	ld b,a			;ab11
	inc b			;ab12
	ld a,(de)			;ab13
tesoro_ya_cogido_rota:
	rr a		;ab14   ; rota el bit del tesoro hasta el acarreo
	djnz tesoro_ya_cogido_rota		;ab16
tesoro_ya_cogido_decide:
	ret nc			;ab18   ; si el bit estaba a cero -no cogido- vuelve normal y el llamante lo pinta
	pop hl			;ab19   ; y si YA ESTABA COGIDO se come la direccion de retorno: la rutina que pinta el tesoro no llega a ejecutarse
	ret			;ab1a
tesoro_de_4000:
	ld de,0e21dh		;ab1b   ; 0xE21D es el byte de banderas de esta clase: ocho bits, uno por tesoro
	call tesoro_ya_cogido		;ab1e
	ld hl,09850h		;ab21   ; los patrones del dibujo, comprimidos
	call descomprime_rle_a_vram		;ab24
	ld hl,0ae90h		;ab27   ; un byte suelto a 0x2013: la fila 3 del color del tile 2
	ld de,02013h		;ab2a
	ld bc,00001h		;ab2d
	call copia_bloque_a_vram		;ab30
	ld de,0e28eh		;ab33   ; y los cuatro bytes del sprite del tesoro, 0xE28E
	ld hl,0b010h		;ab36
	ld bc,00004h		;ab39
	ldir		;ab3c
	ld a,004h		;ab3e   ; 4 son 4000 puntos: 0x878C lo lee de 0xE188 al recogerlo
	ld (0e188h),a		;ab40
	ld iy,0e28eh		;ab43
	ld (iy+001h),0c4h		;ab47
	ld (iy+003h),007h		;ab4b
	jr coloca_el_tesoro		;ab4f
tesoro_de_3000:
	ld de,0e21eh		;ab51   ; 0xE21E, el byte de los de 3000
	call tesoro_ya_cogido		;ab54
	ld hl,0981eh		;ab57
	call descomprime_rle_a_vram		;ab5a
	ld hl,0ae92h		;ab5d
	ld de,02013h		;ab60
	ld bc,00001h		;ab63
	call copia_bloque_a_vram		;ab66
	ld de,0e28eh		;ab69
	ld hl,0b010h		;ab6c
	ld bc,00004h		;ab6f
	ldir		;ab72
	ld a,003h		;ab74   ; 3 son 3000 puntos. El dibujo es otra barra, con patron distinto (0x981E, y 0x9850 el de 4000) pero el mismo color
	ld (0e188h),a		;ab76
	ld iy,0e28eh		;ab79
	ld (iy+001h),0c4h		;ab7d
	ld (iy+003h),00fh		;ab81
coloca_el_tesoro:		; Guion 0xB0A8, caja clase 8: pinta en el hueco los tiles 0x98-0x9D que la rutina de tesoro de la escena acaba de cargar (saco, barra o anillo), y por eso la caja es la que suma en vez de matar
	ld hl,0b0a8h		;ab85
	call pinta_celdas		;ab88
	ld de,0e319h		;ab8b   ; la plantilla de 0xB014 monta el objeto 0xE319 y lo mete en la lista
	ld hl,0b014h		;ab8e
	ld bc,00016h		;ab91
	ldir		;ab94
	ld de,0e319h		;ab96
	call anade_objeto		;ab99
	push ix		;ab9c
	ld ix,0e23bh		;ab9e
	ld (ix+000h),008h		;aba2   ; clase 8, centrada en 0xCB
	ld a,0cbh		;aba6   ; la caja va de 0xCB-9 a 0xCB+9, dieciocho pixeles
	sub 009h		;aba8
	ld (ix+001h),a		;abaa
	ld a,0cbh		;abad
	add a,009h		;abaf
	ld (ix+002h),a		;abb1
	pop ix		;abb4
	ret			;abb6
tesoro_de_5000:
	ld de,0e220h		;abb7   ; 0xE220, el byte de los de 5000
	call tesoro_ya_cogido		;abba
	ld a,005h		;abbd   ; 5 son 5000 puntos: el anillo con la piedra, el mas caro
	ld (0e188h),a		;abbf
	ld hl,0b05ah		;abc2   ; el guion 0xB05A pinta el hueco 3x2 del anillo
	call pinta_celdas		;abc5
	ld hl,098bbh		;abc8
	call descomprime_rle_a_vram		;abcb
	ld de,0e28eh		;abce
	ld hl,0b010h		;abd1
	ld bc,00004h		;abd4
	ldir		;abd7
	ld de,0e319h		;abd9
	ld hl,0b014h		;abdc
	ld bc,00016h		;abdf
	ldir		;abe2
	ld iy,0e28eh		;abe4
	ld (iy+001h),0c4h		;abe8   ; X 0xC4 y color 0x0F, blanco. No es el unico: tambien van en 0x0F la barra de 3000 (0xAB81) y el saco de 2000 (0xAC46). El que se sale es el de 4000, que va en 0x07
	ld (iy+003h),00fh		;abec
	ld de,0e319h		;abf0
	call anade_objeto		;abf3
	push ix		;abf6
	ld ix,0e23bh		;abf8
	ld (ix+000h),008h		;abfc
	ld a,0cbh		;ac00
	sub 009h		;ac02
	ld (ix+001h),a		;ac04
	ld a,0cbh		;ac07
	add a,009h		;ac09
	ld (ix+002h),a		;ac0b
	pop ix		;ac0e
	ret			;ac10
tesoro_de_2000:
	ld de,0e21fh		;ac11   ; y 0xE21F, el de los de 2000: los cuatro bytes de 0xE21D a 0xE220 son los 32 tesoros
	call tesoro_ya_cogido		;ac14
	ld a,002h		;ac17   ; 2 son 2000 puntos: el saco de dinero
	ld (0e188h),a		;ac19
	ld hl,0b074h		;ac1c   ; el guion de 0xB074, el saco
	call pinta_celdas		;ac1f
	ld hl,0989eh		;ac22   ; los tiles del saco, comprimidos en 0x989E
	call descomprime_rle_a_vram		;ac25
	ld de,0e28eh		;ac28   ; los cuatro bytes de sprite del estorbo, la plantilla de 0xB010
	ld hl,0b010h		;ac2b
	ld bc,00004h		;ac2e
	ldir		;ac31
	ld de,0e319h		;ac33   ; y su objeto de 22 bytes, la plantilla de 0xB014
	ld hl,0b014h		;ac36
	ld bc,00016h		;ac39
	ldir		;ac3c
	ld iy,0e28eh		;ac3e
	ld (iy+001h),0c4h		;ac42   ; X 0xC4 y color 0x0F: los mismos que el anillo de 0xABE8 y la barra de 0xAB7D
	ld (iy+003h),00fh		;ac46
	ld de,0e319h		;ac4a
	call anade_objeto		;ac4d   ; con esto el estorbo entra en la lista de objetos
	push ix		;ac50
	ld ix,0e23bh		;ac52
	ld (ix+000h),008h		;ac56   ; la caja del tesoro, clase 8: la unica que suma miles en vez de matar
	ld a,0cbh		;ac5a   ; centrada en 0xCB, de 0xCB-9 a 0xCB+9: los mismos dieciocho pixeles que los otros tres tesoros
	sub 009h		;ac5c
	ld (ix+001h),a		;ac5e
	ld a,0cbh		;ac61
	add a,009h		;ac63
	ld (ix+002h),a		;ac65
	pop ix		;ac68
	ret			;ac6a
escena_tipo_3_agua_con_liana:
	ld hl,0b0fbh		;ac6b   ; los tres bytes 7B 7B 7B de 0xB0FB a la VRAM 0x200B: el charco en cian, que es el agua. La brea escribe 1B 1B 1B en ese mismo sitio desde 0xAC7C
	ld de,0200bh		;ac6e
	ld bc,00003h		;ac71
	call copia_bloque_a_vram		;ac74
	call monta_la_liana		;ac77   ; y este tipo TAMBIEN monta la liana, igual que el 2: el que se queda sin ella es el 7
	jr charca_cajas_y_rotulo		;ac7a   ; de aqui en adelante la brea y el agua hacen exactamente lo mismo
escena_tipo_2_brea_con_liana:
	ld hl,0b110h		;ac7c
	ld de,0200bh		;ac7f
	ld bc,00003h		;ac82
	call copia_bloque_a_vram		;ac85
	call monta_la_liana		;ac88
charca_cajas_y_rotulo:		; Comun a la brea y al agua: la caja del charco y el rotulo
	push ix		;ac8b   ; se aparta el IX del objeto en curso, que aqui dentro hace falta para apuntar a las cajas
	ld ix,0e22ch		;ac8d   ; 0xE22C es la segunda de las diez cajas de 0xE229
	ld (ix+000h),003h		;ac91   ; clase 3, de 0x50 a 0xB0: todo el ancho del charco
	ld a,080h		;ac95   ; centrada en 0x80 -el medio de la pantalla- con 0x30 a cada lado: 96 pixeles de charco
	sub 030h		;ac97
	ld (ix+001h),a		;ac99
	ld a,080h		;ac9c
	add a,030h		;ac9e
	ld (ix+002h),a		;aca0
	pop ix		;aca3
	ld hl,0aed4h		;aca5   ; el rotulo de 0xAED4, 28 celdas repartidas en las filas 14 y 15
	call pinta_celdas		;aca8
	ld a,(0e224h)		;acab   ; 0xE224 es la variante, o sea los bits 0-2 del registro de pantalla
	ld hl,0aec4h		;acae
	jp despacha_por_variante		;acb1   ; salto sin retorno: 0xA99F acaba en jp (hl) y la rutina de la variante hereda el retorno de aqui

; ----------------------------------------------------------------------
; DATOS ret_huerfano_acb4: Un `ret` detras del `jp` de 0xACB1
;   0xacb4..0xacb5  (1 bytes)
DATA_ret_huerfano_acb4:
	defb 0c9h	; acb4

; ======================================================================
; CODIGO 0xacb5..0xade7  (306 bytes)
; ======================================================================


variante_que_no_hace_nada:		; Entrada de tabla que es solo un ret
	ret			;acb5
monta_el_que_sigue:		; Carga sus sprites y suelta el objeto 0xE2ED
	ld hl,098e0h		;acb6   ; los patrones del bicho, comprimidos en 0x98E0
	call descomprime_rle_a_vram		;acb9
	ld b,002h		;acbc   ; dos patrones espejados: el 0 se copia al 8 mirando al otro lado
	ld de,00000h		;acbe
	ld hl,00008h		;acc1
	call espeja_nueve_sprites		;acc4
	ld de,0e292h		;acc7   ; 0xE292 es la entrada de sprite que va DELANTE del jugador
	ld hl,0af5eh		;acca
	ld bc,00004h		;accd
	ldir		;acd0
	ld de,0e2edh		;acd2   ; la plantilla de 0xAF62 monta el objeto 0xE2ED, que entra en la lista
	ld hl,0af62h		;acd5
	ld bc,00016h		;acd8
	ldir		;acdb
	ld de,0e2edh		;acdd
	call anade_objeto		;ace0
	ret			;ace3
coloca_al_jugador:		; Copia las cuatro posiciones iniciales del jugador y sus capas
	ld de,0e2a2h		;ace4   ; las tres entradas de sprite del muneco: 0xE2A2, 0xE2A6 y 0xE2AA
	ld hl,0af78h		;ace7
	ld bc,00004h		;acea
	ldir		;aced
	ld de,0e2a6h		;acef
	ld hl,0af7ch		;acf2
	ld bc,00004h		;acf5
	ldir		;acf8
	ld de,0e2aah		;acfa
	ld hl,0af80h		;acfd
	ld bc,00004h		;ad00
	ldir		;ad03
	ld de,0e2d5h		;ad05   ; y los 0x18 bytes de su estructura, plantilla 0xAF98
	ld hl,0af98h		;ad08
	ld bc,00018h		;ad0b
	ldir		;ad0e
	ld de,0e2d5h		;ad10
	call anade_objeto		;ad13
	ld ix,0e2d5h		;ad16
	set 0,(ix+016h)		;ad1a   ; bit 0 de IX+0x16: se empieza en la superficie
	ret			;ad1e
monta_los_troncos:		; Plantilla 0xAFC2 a 0xE303; su manejador es 0xA728
	ld hl,09944h		;ad1f
	call descomprime_rle_a_vram		;ad22
	ld de,0e282h		;ad25   ; 0xE282 es el sprite del primer tronco; de el se copian los otros dos
	ld hl,0afb6h		;ad28
	ld bc,00004h		;ad2b
	ldir		;ad2e
	ld de,0e303h		;ad30
	ld hl,0afc2h		;ad33
	ld bc,00016h		;ad36
	ldir		;ad39
	ld de,0e303h		;ad3b
	call anade_objeto		;ad3e
	xor a			;ad41
	ld (0e136h),a		;ad42
	ld a,(0e224h)		;ad45
	ld b,01ah		;ad48   ; separacion 0x1A entre troncos, y 0x3A de la variante 2 en adelante
	cp 002h		;ad4a
	jr c,monta_los_troncos_separacion		;ad4c
	ld b,03ah		;ad4e
monta_los_troncos_separacion:
	ld hl,0e137h		;ad50
	ld (hl),b			;ad53
	cp 004h		;ad54   ; con variante 4 o mas el tercero se queda parado
	jr c,monta_los_troncos_variante_1		;ad56
	ld ix,0e303h		;ad58
	res 0,(ix+006h)		;ad5c   ; el bit 0 de IX+0x06 es el "movil" de la X: apagado, el tronco se queda quieto
	ld (ix+000h),0c0h		;ad60
monta_los_troncos_variante_1:
	cp 001h		;ad64
	ret nz			;ad66
	ld a,(0e2a3h)		;ad67   ; 0xE2A3 es la X del jugador
	cp 0e2h		;ad6a   ; solo si el jugador esta pasado de 0xE2
	ret c			;ad6c
	ld hl,0e283h		;ad6d
	ld a,(hl)			;ad70
	sub 008h		;ad71
	ld (hl),a			;ad73
	ret			;ad74
escena_tipo_4_cocodrilos:
	ld hl,09919h		;ad75   ; los patrones de los cocodrilos, comprimidos en 0x9919
	call descomprime_rle_a_vram		;ad78
	ld de,0e282h		;ad7b   ; tres bloques de 4 bytes, uno por cocodrilo: son los tres que se ven en la captura
	ld hl,0afdeh		;ad7e
	ld bc,00004h		;ad81
	ldir		;ad84
	ld de,0e286h		;ad86
	ld hl,0afe2h		;ad89
	ld bc,00004h		;ad8c
	ldir		;ad8f
	ld de,0e28ah		;ad91
	ld hl,0afe6h		;ad94
	ld bc,00004h		;ad97
	ldir		;ad9a
	ld de,0e303h		;ad9c   ; la plantilla de 0xAFEA monta el objeto 0xE303, que lleva el manejador 0xA7F5
	ld hl,0afeah		;ad9f
	ld bc,00016h		;ada2
	ldir		;ada5
	ld hl,0e313h		;ada7
	ld (hl),087h		;adaa
	ld de,0e303h		;adac
	call anade_objeto		;adaf
	ld hl,0b0fbh		;adb2   ; los tres bytes 7B 7B 7B a 0x200B: el color del agua, que deshace el parche de la brea
	ld de,0200bh		;adb5
	ld bc,00003h		;adb8
	call copia_bloque_a_vram		;adbb
	ld hl,0aed4h		;adbe
	call pinta_celdas		;adc1
	push ix		;adc4
	ld ix,0e238h		;adc6
	ld (ix+000h),004h		;adca
	ld a,09fh		;adce   ; la cuarta caja, de 0x9F a 0xB0
	sub 000h		;add0
	ld (ix+001h),a		;add2
	ld a,09fh		;add5
	add a,011h		;add7
	ld (ix+002h),a		;add9
	pop ix		;addc
	ld hl,0ae94h		;adde   ; y la variante elige el estorbo de la derecha, por la tabla 0xAE94
	ld a,(0e224h)		;ade1
	jp despacha_por_variante		;ade4

; ----------------------------------------------------------------------
; DATOS ret_huerfano_ade7: Un `ret` detras del `jp` de 0xADE4
;   0xade7..0xade8  (1 bytes)
DATA_ret_huerfano_ade7:
	defb 0c9h	; ade7

; ======================================================================
; CODIGO 0xade8..0xae37  (79 bytes)
; ======================================================================


escena_tipo_7_agua_sin_liana:
	ld hl,0b0fbh		;ade8
	ld de,0200bh		;adeb
	ld bc,00003h		;adee
	call copia_bloque_a_vram		;adf1
	jr monta_objeto_de_escena		;adf4
escena_tipo_5_tesoro:
	ld hl,0b110h		;adf6
	ld de,0200bh		;adf9
	ld bc,00003h		;adfc
	call copia_bloque_a_vram		;adff
	jr monta_objeto_de_escena		;ae02
escena_tipo_6_brea_con_liana:
	call monta_la_liana		;ae04
	ld hl,0b110h		;ae07
	ld de,0200bh		;ae0a
	ld bc,00003h		;ae0d
	call copia_bloque_a_vram		;ae10
monta_objeto_de_escena:		; Comun a los tipos 5, 6 y 7
	ld ix,0e2bfh		;ae13
	ld de,0a870h		;ae17
	ld (ix+012h),e		;ae1a
	ld (ix+013h),d		;ae1d
	ld (ix+011h),001h		;ae20
	ld hl,0aec4h		;ae24   ; la tabla de variantes: la 0xAEA4 solo para el tipo 5
	ld a,(0e225h)		;ae27
	cp 005h		;ae2a
	jr nz,monta_objeto_de_escena_despacha		;ae2c
	ld hl,0aea4h		;ae2e
monta_objeto_de_escena_despacha:
	ld a,(0e224h)		;ae31
	jp despacha_por_variante		;ae34

; ----------------------------------------------------------------------
; DATOS ret_huerfano_ae37: Un `ret` detras del `jp` de 0xAE34
;   0xae37..0xae38  (1 bytes)
DATA_ret_huerfano_ae37:
	defb 0c9h	; ae37

; ======================================================================
; CODIGO 0xae38..0xae90  (88 bytes)
; ======================================================================


monta_la_liana:		; La llaman los tipos 2, 3 y 6
	call repone_decorado		;ae38
	ld de,0e26ah		;ae3b
	ld hl,0af46h		;ae3e
	ld bc,0000ch		;ae41
	ldir		;ae44
monta_la_liana_objeto:
	ld a,001h		;ae46
	ld (0e1ceh),a		;ae48
	ld de,0e32fh		;ae4b
	ld hl,0b02ah		;ae4e   ; la plantilla del objeto de la liana
	ld bc,00016h		;ae51
	ldir		;ae54
	ld hl,0a471h		;ae56   ; y su manejador
	ld ix,0e32fh		;ae59
	ld (ix+013h),h		;ae5d
	ld (ix+012h),l		;ae60
	ld iy,0e276h		;ae63   ; los tres sprites de la cuerda: patrones 0x3C, 0x3C y 0x60, color 0
	ld (iy+002h),03ch		;ae67
	ld (iy+003h),000h		;ae6b
	ld iy,0e27ah		;ae6f
	ld (iy+002h),03ch		;ae73
	ld (iy+003h),000h		;ae77
	ld iy,0e27eh		;ae7b
	ld (iy+002h),060h		;ae7f
	ld (iy+003h),000h		;ae83
	ld (ix+011h),001h		;ae87
	ld (ix+010h),001h		;ae8b
	ret			;ae8f

; ----------------------------------------------------------------------
; DATOS colores_del_tesoro: Dos parejas (4B 00 4B 00) de las que solo se usa
;   el primer byte de cada una: 0xAB1B copia el de 0xAE90 y 0xAB51 el de
;   0xAE92 a la VRAM 0x2013, el color del tile del tesoro. Los dos valen 0x4B,
;   asi que lo que distingue a las dos barras es el patron y no el color
;   0xae90..0xae94  (4 bytes)
DATA_colores_del_tesoro:
	defb 04bh,000h	; ae90
	defb 04bh,000h	; ae92

; ----------------------------------------------------------------------
; DATOS tabla_de_submodos_1: Ocho punteros de palabra para el despachador
;   parametrico de 0xA99F, indexados por el submodo (0xE224)=(0xE222)&7. La
;   base la carga el llamante de 0xADE4. Solo dos rutinas distintas,
;   alternadas de dos en dos: 0xACB5 y 0xAE38
;   0xae94..0xaea4  (16 bytes)

; ----------------------------------------------------------------------
; OJO AL CERRAR ESTO: esta tabla es un SEGUNDO camino hacia
; monta_la_liana, aparte de las llamadas directas de los tipos 2, 3 y 6.
; Va indexada por el SUBMODO (0xE224 = (0xE222) and 7), no por el tipo
; de escena, y sus indices 2, 3, 6 y 7 apuntan a monta_la_liana. La carga
; 0xADDE, dentro de la rutina que elige el estorbo de la derecha.
; Comprobado por la sesion principal el 2026-08-21: el tipo 7 (0xADE8)
; efectivamente NO llama a monta_la_liana, asi que la correccion del
; listado se sostiene; pero **queda sin cerrar si por este camino puede
; aparecer liana en escenas donde el reparto por tipo dice que no**, y
; por eso NO se han tocado todavia las filas 2/3/6/7 de la tabla de
; escenas de las dos webs. Cerrar antes de publicarlo alli.
; ----------------------------------------------------------------------
DATA_tabla_de_submodos_1:
	defw 0acb5h	; ae94  -> variante_que_no_hace_nada
	defw 0acb5h	; ae96  -> variante_que_no_hace_nada
	defw 0ae38h	; ae98  -> monta_la_liana
	defw 0ae38h	; ae9a  -> monta_la_liana
	defw 0acb5h	; ae9c  -> variante_que_no_hace_nada
	defw 0acb5h	; ae9e  -> variante_que_no_hace_nada
	defw 0ae38h	; aea0  -> monta_la_liana
	defw 0ae38h	; aea2  -> monta_la_liana

; ----------------------------------------------------------------------
; DATOS tabla_de_submodos_2: Ocho punteros de palabra para 0xA99F, mismos
;   indices. La base la carga 0xAE2E, y SOLO cuando el modo (0xE225) es 5.
;   Cuatro rutinas distintas repetidas dos veces: 0xAC11, 0xAB51, 0xAB1B,
;   0xABB7
;   0xaea4..0xaeb4  (16 bytes)
DATA_tabla_de_submodos_2:
	defw 0ac11h	; aea4  -> tesoro_de_2000
	defw 0ab51h	; aea6  -> tesoro_de_3000
	defw 0ab1bh	; aea8  -> tesoro_de_4000
	defw 0abb7h	; aeaa  -> tesoro_de_5000
	defw 0ac11h	; aeac  -> tesoro_de_2000
	defw 0ab51h	; aeae  -> tesoro_de_3000
	defw 0ab1bh	; aeb0  -> tesoro_de_4000
	defw 0abb7h	; aeb2  -> tesoro_de_5000

; ----------------------------------------------------------------------
; DATOS tabla_de_modos: Ocho punteros de palabra, uno por TIPO DE ESCENA (los
;   bits 3-5 del LFSR de pantalla 0xE222). El despachador de 0x9F81-0x9F8D lee
;   el indice de 0xE225, lo dobla y salta por aqui con un call indirecto (ld
;   de,9F8Eh / push de / jp (hl)). El indice lo calcula 0x9EF4-0x9EFF como
;   ((0xE222)>>3)&7, o sea 0..7: ocho entradas y ni una mas
;   0xaeb4..0xaec4  (16 bytes)
DATA_tabla_de_modos:
	defw 0a9aah	; aeb4  -> escena_tipo_0_y_1_hoyos
	defw 0a9aah	; aeb6  -> escena_tipo_0_y_1_hoyos
	defw 0ac7ch	; aeb8  -> escena_tipo_2_brea_con_liana
	defw 0ac6bh	; aeba  -> escena_tipo_3_agua_con_liana
	defw 0ad75h	; aebc  -> escena_tipo_4_cocodrilos
	defw 0adf6h	; aebe  -> escena_tipo_5_tesoro
	defw 0ae04h	; aec0  -> escena_tipo_6_brea_con_liana
	defw 0ade8h	; aec2  -> escena_tipo_7_agua_sin_liana

; ----------------------------------------------------------------------
; DATOS tabla_de_submodos_3: Ocho punteros de palabra para 0xA99F, mismos
;   indices. La cargan los llamantes de 0xAA70, 0xACB1 y el camino de 0xAE24
;   cuando el modo no es 5. Seis de las ocho entradas apuntan al mismo sitio,
;   0xAD1F; las otras dos, 0xAAB7 y 0xAA74
;   0xaec4..0xaed4  (16 bytes)
DATA_tabla_de_submodos_3:
	defw 0ad1fh	; aec4  -> monta_los_troncos
	defw 0ad1fh	; aec6  -> monta_los_troncos
	defw 0ad1fh	; aec8  -> monta_los_troncos
	defw 0ad1fh	; aeca  -> monta_los_troncos
	defw 0ad1fh	; aecc  -> monta_los_troncos
	defw 0ad1fh	; aece  -> monta_los_troncos
	defw 0aab7h	; aed0  -> monta_la_fogata
	defw 0aa74h	; aed2  -> monta_la_serpiente

; ----------------------------------------------------------------------
; DATOS guion_celdas_rotulo: Guion de 28 celdas en las filas 14-15, columnas
;   9-22: dos lineas de tiles consecutivos (0x58-0x6F), un rotulo pintado
;   celda a celda. Lo llaman 0xACA8 y 0xADC1
;   0xaed4..0xaf46  (114 bytes)
DATA_guion_celdas_rotulo:
	defb 01ch,000h,0c9h,001h,058h,000h,0cah,001h,059h,000h,0cbh,001h,05ah,000h,0cch,001h	; aed4  ....X...Y...Z...
	defb 05dh,000h,0cdh,001h,05bh,000h,0ceh,001h,05eh,000h,0cfh,001h,05ch,000h,0d0h,001h	; aee4  ]...[...^...\...
	defb 063h,000h,0d1h,001h,05eh,000h,0d2h,001h,062h,000h,0d3h,001h,05dh,000h,0d4h,001h	; aef4  c...^...b...]...
	defb 061h,000h,0d5h,001h,060h,000h,0d6h,001h,05fh,000h,0e9h,001h,064h,000h,0eah,001h	; af04  a...`..._...d...
	defb 065h,000h,0ebh,001h,066h,000h,0ech,001h,069h,000h,0edh,001h,067h,000h,0eeh,001h	; af14  e...f...i...g...
	defb 06ah,000h,0efh,001h,068h,000h,0f0h,001h,06fh,000h,0f1h,001h,06ah,000h,0f2h,001h	; af24  j...h...o...j...
	defb 06eh,000h,0f3h,001h,069h,000h,0f4h,001h,06dh,000h,0f5h,001h,06ch,000h,0f6h,001h	; af34  n...i...m...l...
	defb 06bh,000h	; af44

; ----------------------------------------------------------------------
; DATOS inicializador_e26a: Doce bytes que 0xAE44 copia a 0xE26A
;   0xaf46..0xaf52  (12 bytes)
DATA_inicializador_e26a:
	defb 02fh,068h,084h,00ch,02fh,078h,0a8h,00ch,02fh,088h,0cch,00ch	; af46  /h../x../...

; ----------------------------------------------------------------------
; DATOS guion_anim_sigue_derecha: 03 00 / 03 04 / 00 00: dos fotogramas de
;   tres cuadros. Lo carga 0xA6EE cuando el bicho de 0xE2ED va hacia la
;   derecha
;   0xaf52..0xaf58  (6 bytes)
DATA_guion_anim_sigue_derecha:
	defb 003h,000h	; af52
	defb 003h,004h	; af54
	defb 000h,000h	; af56

; ----------------------------------------------------------------------
; DATOS guion_anim_sigue_izquierda: 03 08 / 03 0C / 00 00: los mismos tiempos
;   con los otros dos patrones. Lo carga 0xA6CF, el camino de la izquierda
;   0xaf58..0xaf5e  (6 bytes)
DATA_guion_anim_sigue_izquierda:
	defb 003h,008h	; af58
	defb 003h,00ch	; af5a
	defb 000h,000h	; af5c

; ----------------------------------------------------------------------
; DATOS inicializador_e292: Cuatro bytes que 0xACD0 copia a 0xE292
;   0xaf5e..0xaf62  (4 bytes)
DATA_inicializador_e292:
	defb 0a2h,080h,000h,00fh	; af5e

; ----------------------------------------------------------------------
; DATOS plantilla_objeto_e2ed: Plantilla de objeto de 22 bytes que 0xACDB
;   copia a 0xE2ED. Su manejador (offset 0x12) es 0xA69E
;   0xaf62..0xaf78  (22 bytes)
DATA_plantilla_objeto_e2ed:
	defb 0e0h,000h,000h,000h,000h,000h,007h,000h,001h,008h,0ddh,000h,052h,0afh,001h,000h,003h,005h,09eh,0a6h,092h,0e2h	; af62  ............R.........

; ----------------------------------------------------------------------
; DATOS inicializador_e2a2: Cuatro bytes que 0xACED copia a 0xE2A2
;   0xaf78..0xaf7c  (4 bytes)
DATA_inicializador_e2a2:
	defb 06dh,020h,034h,00ch	; af78

; ----------------------------------------------------------------------
; DATOS inicializador_e2a6: Cuatro bytes que 0xACF8 copia a 0xE2A6
;   0xaf7c..0xaf80  (4 bytes)
DATA_inicializador_e2a6:
	defb 06dh,020h,034h,006h	; af7c

; ----------------------------------------------------------------------
; DATOS inicializador_e2aa: Cuatro bytes que 0xAD03 copia a 0xE2AA
;   0xaf80..0xaf84  (4 bytes)
DATA_inicializador_e2aa:
	defb 06dh,020h,034h,00fh	; af80

; ----------------------------------------------------------------------
; DATOS guion_anim_sin_usar: Un guion entero y bien formado -nueve fotogramas,
;   patrones 0x20 a 0x40 de cuatro en cuatro, cincuenta cuadros cada uno- que
;   NO USA NADIE: ni una instruccion lo carga, ni ninguna de las 16384
;   palabras del cartucho vale su direccion. Cincuenta cuadros por fotograma
;   es lento, de rotulo o de decorado, no de bicho
;   0xaf84..0xaf98  (20 bytes)
DATA_guion_anim_sin_usar:
	defb 032h,020h	; af84
	defb 032h,024h	; af86
	defb 032h,028h	; af88
	defb 032h,02ch	; af8a
	defb 032h,030h	; af8c
	defb 032h,034h	; af8e
	defb 032h,038h	; af90
	defb 032h,03ch	; af92
	defb 032h,040h	; af94
	defb 000h,000h	; af96

; ----------------------------------------------------------------------
; DATOS plantilla_objeto_e2d5: Plantilla de objeto de 24 bytes que 0xAD0E
;   copia a 0xE2D5. Su manejador es 0x8125
;   0xaf98..0xafb0  (24 bytes)
DATA_plantilla_objeto_e2d5:
	defb 0c0h,000h,001h,000h,000h,000h,000h,0b4h,000h,010h,0ddh,000h,000h,000h,001h,000h,001h,005h,025h,081h,0a2h,0e2h,000h,000h	; af98  ..................%.....

; ----------------------------------------------------------------------
; DATOS guion_anim_troncos: 0A F8 / 0A FC / 00 00: dos patrones alternandose
;   cada diez cuadros, que es el tronco rodando. Lo apunta el campo +0x0C de
;   la plantilla de 0xAFC2, cuyo manejador es 0xA728
;   0xafb0..0xafb6  (6 bytes)
DATA_guion_anim_troncos:
	defb 00ah,0f8h	; afb0
	defb 00ah,0fch	; afb2
	defb 000h,000h	; afb4

; ----------------------------------------------------------------------
; DATOS inicializador_e282: Cuatro bytes que 0xAD2E copia a 0xE282
;   0xafb6..0xafba  (4 bytes)
DATA_inicializador_e282:
	defb 06fh,0c3h,0f8h,006h	; afb6

; ----------------------------------------------------------------------
; DATOS inicializadores_troncos_2_y_3: Dos bloques de cuatro bytes (Y, X,
;   patron, color) iguales entre si -6F E0 F8 06- y hermanos del de 0xAFB6,
;   que es el primer tronco. Nadie los copia: 0xAD2E se lleva solo los cuatro
;   del primero y 0xA745 coloca los otros dos por codigo a partir de el. O sea
;   que los datos estan escritos y no se usan
;   0xafba..0xafc2  (8 bytes)
DATA_inicializadores_troncos_2_y_3:
	defb 06fh,0e0h,0f8h,006h	; afba
	defb 06fh,0e0h,0f8h,006h	; afbe

; ----------------------------------------------------------------------
; DATOS plantilla_objeto_e303: Plantilla de objeto de 22 bytes que 0xAD39
;   copia a 0xE303. Su manejador es 0xA728
;   0xafc2..0xafd8  (22 bytes)
DATA_plantilla_objeto_e303:
	defb 0e0h,000h,000h,000h,000h,000h,001h,038h,0ffh,000h,000h,000h,0b0h,0afh,001h,000h,001h,002h,028h,0a7h,082h,0e2h	; afc2  .......8..........(...

; ----------------------------------------------------------------------
; DATOS guion_anim_cocodrilos: 01 F8 / 01 FC / 00 00: los mismos dos patrones
;   que el tronco pero cambiando cada cuadro, que es la boca del cocodrilo. Lo
;   apunta la plantilla de 0xAFEA, manejador 0xA7F5
;   0xafd8..0xafde  (6 bytes)
DATA_guion_anim_cocodrilos:
	defb 001h,0f8h	; afd8
	defb 001h,0fch	; afda
	defb 000h,000h	; afdc

; ----------------------------------------------------------------------
; DATOS inicializador_e282_b: Cuatro bytes que 0xAD84 copia a 0xE282
;   0xafde..0xafe2  (4 bytes)
DATA_inicializador_e282_b:
	defb 070h,078h,0f8h,001h	; afde

; ----------------------------------------------------------------------
; DATOS inicializador_e286: Cuatro bytes que 0xAD8F copia a 0xE286
;   0xafe2..0xafe6  (4 bytes)
DATA_inicializador_e286:
	defb 070h,060h,0f8h,001h	; afe2

; ----------------------------------------------------------------------
; DATOS inicializador_e28a: Cuatro bytes que 0xAD9A copia a 0xE28A
;   0xafe6..0xafea  (4 bytes)
DATA_inicializador_e28a:
	defb 070h,090h,0f8h,001h	; afe6

; ----------------------------------------------------------------------
; DATOS plantilla_objeto_e303_b: Otra plantilla de 22 bytes para 0xE303,
;   copiada por 0xADA5. Su manejador es 0xA7F5
;   0xafea..0xb000  (22 bytes)
DATA_plantilla_objeto_e303_b:
	defb 0e0h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0d8h,0afh,001h,000h,004h,005h,0f5h,0a7h,082h,0e2h	; afea  ......................

; ----------------------------------------------------------------------
; DATOS guion_anim_estorbo: Siete pares con esperas desiguales (2, 1, 3, 2, 2,
;   4, 1) entre los patrones 0xF8 y 0xFC: un parpadeo irregular. Lo apunta la
;   plantilla de 0xB014, la del estorbo de la derecha
;   0xb000..0xb010  (16 bytes)
DATA_guion_anim_estorbo:
	defb 002h,0f8h	; b000
	defb 001h,0fch	; b002
	defb 003h,0f8h	; b004
	defb 002h,0fch	; b006
	defb 002h,0f8h	; b008
	defb 004h,0fch	; b00a
	defb 001h,0f8h	; b00c
	defb 000h,000h	; b00e

; ----------------------------------------------------------------------
; DATOS inicializador_e28e: Los cuatro bytes de atributo del sprite 9 (Y=0x6F,
;   X=0xC3, patron=0xF8, color=0x06) que copian a 0xE28E SEIS sitios distintos
;   (0xAA89, 0xAACC, 0xAB3C, 0xAB72, 0xABD7, 0xAC31)
;   0xb010..0xb014  (4 bytes)
DATA_inicializador_e28e:
	defb 06fh,0c3h,0f8h,006h	; b010

; ----------------------------------------------------------------------
; DATOS plantilla_objeto_e319: Plantilla de objeto de 22 bytes que copian a
;   0xE319 cinco sitios (0xAA94, 0xAAD7, 0xAB94, 0xABE2, 0xAC3C). Su campo de
;   manejador viene a CERO: se rellena despues en marcha
;   0xb014..0xb02a  (22 bytes)
DATA_plantilla_objeto_e319:
	defb 0a0h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0b0h,001h,000h,004h,005h,000h,000h,08eh,0e2h	; b014  ......................

; ----------------------------------------------------------------------
; DATOS plantilla_objeto_e2bf: Plantilla de objeto de 22 bytes que el arranque
;   (0x8094) copia a 0xE2BF y 0xAE54 copia a 0xE32F. Su manejador es 0xA962
;   0xb02a..0xb040  (22 bytes)
DATA_plantilla_objeto_e2bf:
	defb 0c0h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,009h,004h,062h,0a9h,000h,000h	; b02a  ..................b...

; ----------------------------------------------------------------------
; DATOS guion_celdas_serpiente: Guion de 6 celdas: LA SERPIENTE, 3x2 en filas
;   14-15, columnas 24-26, tiles 0x90-0x95. Lo llama 0xAA7D
;   0xb040..0xb05a  (26 bytes)
DATA_guion_celdas_serpiente:
	defb 006h,000h,0d8h,001h,090h,000h,0d9h,001h,091h,000h,0dah,001h,092h,000h,0f8h,001h	; b040  ................
	defb 093h,000h,0f9h,001h,094h,000h,0fah,001h,095h,000h	; b050  ..........

; ----------------------------------------------------------------------
; DATOS guion_celdas_objeto_2: Guion de 6 celdas: mismo hueco 3x2, tiles
;   0xA8-0xAD. Lo llama 0xABC5
;   0xb05a..0xb074  (26 bytes)
DATA_guion_celdas_objeto_2:
	defb 006h,000h,0d8h,001h,0a8h,000h,0d9h,001h,0a9h,000h,0dah,001h,0aah,000h,0f8h,001h	; b05a  ................
	defb 0abh,000h,0f9h,001h,0ach,000h,0fah,001h,0adh,000h	; b06a  ..........

; ----------------------------------------------------------------------
; DATOS guion_celdas_objeto_3: Guion de 6 celdas: mismo hueco 3x2, tiles
;   0xB0-0xB5. Lo llama 0xAC1F
;   0xb074..0xb08e  (26 bytes)
DATA_guion_celdas_objeto_3:
	defb 006h,000h,0d8h,001h,0b0h,000h,0d9h,001h,0b1h,000h,0dah,001h,0b2h,000h,0f8h,001h	; b074  ................
	defb 0b3h,000h,0f9h,001h,0b4h,000h,0fah,001h,0b5h,000h	; b084  ..........

; ----------------------------------------------------------------------
; DATOS guion_celdas_borrado: Guion de 6 celdas: el mismo hueco de 3x2, pero
;   las seis con el MISMO tile 0x30, que es el blanco. O sea que no pinta
;   nada: BORRA el objeto. Lo llaman 0x87B9 (al recoger el tesoro), 0x8D59 y
;   0x8D6C
;   0xb08e..0xb0a8  (26 bytes)
DATA_guion_celdas_borrado:
	defb 006h,000h,0d8h,001h,030h,000h,0d9h,001h,030h,000h,0dah,001h,030h,000h,0f8h,001h	; b08e  ....0...0...0...
	defb 030h,000h,0f9h,001h,030h,000h,0fah,001h,030h,000h	; b09e  0...0...0.

; ----------------------------------------------------------------------
; DATOS guion_celdas_tesoro: Guion de 6 celdas: EL TESORO, mismo hueco 3x2,
;   tiles 0x98-0x9D (los patrones los carga antes la rutina de cada tesoro:
;   saco, barra o anillo). Lo llama 0xAB88
;   0xb0a8..0xb0c2  (26 bytes)
DATA_guion_celdas_tesoro:
	defb 006h,000h,0d8h,001h,098h,000h,0d9h,001h,099h,000h,0dah,001h,09ah,000h,0f8h,001h	; b0a8  ................
	defb 09bh,000h,0f9h,001h,09ch,000h,0fah,001h,09dh,000h	; b0b8  ..........

; ----------------------------------------------------------------------
; DATOS guion_celdas_fogata: Guion de 3 celdas: LA FOGATA, solo la fila 15 del
;   hueco, columnas 24-26, tiles 0xA0-0xA2. Lo llama 0xAABA
;   0xb0c2..0xb0d0  (14 bytes)
DATA_guion_celdas_fogata:
	defb 003h,000h,0f8h,001h,0a0h,000h,0f9h,001h,0a1h,000h,0fah,001h,0a2h,000h	; b0c2  ..............

; ----------------------------------------------------------------------
; DATOS filas_del_rotulo: Cuatro filas de 8 tiles (0x58-0x6F, mas el blanco
;   0x30 en las cuatro esquinas). Las copian CUATRO sitios, uno por fila:
;   0xA889, 0xA89C, 0xA8BB y 0xA8D1, todos con la longitud leida de 0xE133 y
;   con 8 menos esa longitud como desplazamiento (0xA896, 0xA8CB): el rotulo
;   dibujandose por columnas
;   0xb0d0..0xb0f0  (32 bytes)
DATA_filas_del_rotulo:
	defb 030h,058h,059h,05ah,05dh,05bh,05eh,05ch	; b0d0  0XYZ][^\
	defb 063h,05eh,062h,05dh,061h,060h,05fh,030h	; b0d8  c^b]a`_0
	defb 030h,064h,065h,066h,069h,067h,06ah,068h	; b0e0  0defigjh
	defb 06fh,06ah,06eh,069h,06dh,06ch,06bh,030h	; b0e8  ojnimlk0

; ----------------------------------------------------------------------
; DATOS colores_iniciales: Treinta y dos bytes de color que 0x8A01 copia a la
;   VRAM 0x2000, el principio de la tabla de colores. Los tres del offset
;   +0x0B (0xB0FB, 7B 7B 7B) los reescriben en 0x200B tres sitios (0xAC6B,
;   0xADB2 y 0xADE8), deshaciendo el parche de 0xB110
;   0xb0f0..0xb110  (32 bytes)
DATA_colores_iniciales:
	defb 098h,097h,087h,08fh,091h,061h,01bh,08ch	; b0f0  .....a..
	defb 006h,016h,01bh,07bh,07bh,07bh,0c7h,0c7h	; b0f8  ...{{{..
	defb 0c7h,0c7h,01bh,05bh,06bh,0dbh,0cbh,0fch	; b100  ...[k...
	defb 0fch,0f1h,0f1h,03ch,03ch,03ch,037h,037h	; b108  ...<<<77

; ----------------------------------------------------------------------
; DATOS colores_alternativos: Tres bytes (1B 1B 1B) que escriben en la VRAM
;   0x200B tres sitios distintos (0xAC7C, 0xADF6 y 0xAE07), encima de los
;   originales: el parche de color que deshacen 0xAC6B, 0xADB2 y 0xADE8
;   0xb110..0xb113  (3 bytes)
DATA_colores_alternativos:
	defb 01bh,01bh,01bh	; b110

; ======================================================================
; CODIGO 0xb113..0xb393  (640 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; ############################################################
; LA CAPA DE VDP
; ############################################################
; Puerto 0x98 datos, 0x99 direccion y registros. Fuera de este
; bloque solo tocan el VDP 0x811A y 0x9D44.
; ----------------------------------------------------------------------
borra_la_vram:		; Los 16 KB de VRAM a cero. La llama INIT dos veces
	xor a			;b113   ; el valor con que se rellena: cero
	ld hl,00000h		;b114
	ld bc,04000h		;b117   ; 0x4000 = los 16 KB enteros, sin respetar nada de lo que hubiera
	call rellena_vram		;b11a
	ret			;b11d

; ----------------------------------------------------------------------
; El mismo descompresor que 0xB142 pero escribiendo en RAM.
; NADIE lo llama: ni un call, ni un salto, ni un puntero.
; ----------------------------------------------------------------------
descomprime_rle_a_ram:		; Gemelo de 0xB142 que escribe en RAM; sin uso
	ld a,(hl)			;b11e   ; gemelo instruccion a instruccion de 0xB14F, con `ld (de),a` donde el otro saca por el puerto 0x98
	and 03fh		;b11f   ; el contador va en los seis bits bajos del token
	ret z			;b121   ; un token 0x00 cierra el bloque
	ld b,a			;b122
	bit 7,(hl)		;b123   ; bit 7: saltar N posiciones sin escribir nada
	jr nz,descomprime_rle_a_ram_salta		;b125
	bit 6,(hl)		;b127   ; bit 6: N literales seguidos; sin ninguno de los dos, un byte repetido N veces
	inc hl			;b129
	ld a,(hl)			;b12a
	jr nz,descomprime_rle_a_ram_literales		;b12b
descomprime_rle_a_ram_repite:
	ld (de),a			;b12d   ; repetir: el mismo byte en N posiciones consecutivas
	inc de			;b12e
	djnz descomprime_rle_a_ram_repite		;b12f
	jr descomprime_rle_a_ram_sigue		;b131
descomprime_rle_a_ram_literales:
	ld (de),a			;b133   ; literales: cada vuelta trae un byte nuevo del cartucho
	inc de			;b134
	inc hl			;b135
	ld a,(hl)			;b136
	djnz descomprime_rle_a_ram_literales		;b137
	jr descomprime_rle_a_ram		;b139
descomprime_rle_a_ram_salta:
	add a,e			;b13b   ; el salto deja el destino nuevo en A, pero mirar lo que pasa despues
	jr nc,descomprime_rle_redirecciona		;b13c   ; sin acarreo cae en 0xB174, que es la rama de VRAM: sacaria la direccion por el puerto 0x99
	inc d			;b13e   ; y con acarreo sube D pero deja E como estaba, o sea que no mueve el destino. Rota por los dos lados, lo que encaja con que no la llame nadie
descomprime_rle_a_ram_sigue:
	inc hl			;b13f
	jr descomprime_rle_a_ram		;b140
descomprime_rle_a_vram:		; Vuelca a la VRAM el bloque RLE apuntado por HL
	ld e,(hl)			;b142   ; los dos primeros bytes del bloque: la direccion de VRAM
	inc hl			;b143
	ld d,(hl)			;b144
	ld a,e			;b145   ; la direccion al VDP, byte bajo primero
	out (099h),a		;b146
	ld a,d			;b148
	add a,040h		;b149   ; +0x40 = marcar escritura; D se guarda ya con el bit puesto
	ld d,a			;b14b
	out (099h),a		;b14c
descomprime_rle_siguiente_token:
	inc hl			;b14e   ; el token siguiente va pegado detras del dato que acaba de gastarse
descomprime_rle_token:
	ld a,(hl)			;b14f
	and 03fh		;b150   ; contador en los 6 bits bajos; 0 termina
	ret z			;b152
	ld b,a			;b153   ; B es lo que va a contar el djnz
	bit 7,(hl)		;b154   ; bit 7 salta N, bit 6 N literales, ninguno repite N veces
	jr nz,descomprime_rle_salta		;b156
	bit 6,(hl)		;b158
	inc hl			;b15a
	ld a,(hl)			;b15b
	jr nz,descomprime_rle_literales		;b15c
descomprime_rle_repite:
	out (098h),a		;b15e   ; repetir: como el VDP autoincrementa solo, basta con repetir el out sin volver a direccionar
	inc de			;b160   ; el VDP no usa DE, pero hay que llevarlo al dia para cuando venga un token de salto
	nop			;b161   ; los dos nop son el retardo que pide el VDP entre escrituras
	nop			;b162
	djnz descomprime_rle_repite		;b163
	jr descomprime_rle_siguiente_token		;b165
descomprime_rle_literales:
	out (098h),a		;b167   ; literales: aqui el `inc hl` y el `ld a,(hl)` ya dan el respiro que en 0xB161 hacen los dos nop
	inc de			;b169
	inc hl			;b16a
	ld a,(hl)			;b16b
	djnz descomprime_rle_literales		;b16c
	jr descomprime_rle_token		;b16e
descomprime_rle_salta:
	add a,e			;b170   ; salto: el contador se suma al destino, y como el VDP se queda donde estaba hay que redireccionarlo
	jr nc,descomprime_rle_redirecciona		;b171
	inc d			;b173
descomprime_rle_redirecciona:
	ld e,a			;b174   ; la direccion nueva, baja y alta; D ya lleva puesto el 0x40 desde 0xB149
	out (099h),a		;b175
	ld a,d			;b177
	out (099h),a		;b178
	jr descomprime_rle_siguiente_token		;b17a
escribe_registro_vdp:		; B = valor, C = numero de registro
	ld a,b			;b17c   ; primero el valor...
	out (099h),a		;b17d
	ld a,c			;b17f   ; ...y despues el numero: el VDP quiere los dos bytes en ese orden
	or 080h		;b180   ; el 0x80 convierte el numero en el comando del VDP
	out (099h),a		;b182
	ret			;b184
direcciona_vram_escritura:
	ld a,l			;b185   ; byte bajo de la direccion y luego el alto, como en todo el VDP
	out (099h),a		;b186
	ld a,h			;b188
	or 040h		;b189   ; bit 14 a 1: escritura
	out (099h),a		;b18b
	push af			;b18d   ; push/pop af: retardo obligado antes de tocar el puerto de datos
	pop af			;b18e
	ret			;b18f
direcciona_vram_lectura:
	ld a,l			;b190   ; primero el byte bajo de la direccion
	out (099h),a		;b191
	ld a,h			;b193   ; y el alto SIN el 0x40 que pone 0xB189: eso deja el VDP en lectura
	out (099h),a		;b194
	push af			;b196   ; push af y pop af no cambian nada: son 21 ciclos de espera
	pop af			;b197
	ret			;b198
escribe_byte_en_vram:		; Sin uso: nadie la llama
	push af			;b199   ; el push guarda el dato porque 0xB185 se lleva A por delante
	call direcciona_vram_escritura		;b19a
	pop af			;b19d
	out (098h),a		;b19e
	ret			;b1a0
lee_byte_de_vram:		; Sin uso: nadie la llama
	call direcciona_vram_lectura		;b1a1   ; sin uso: el juego lee la VRAM siempre por bloques, con 0xB1B6
	in a,(098h)		;b1a4
	ret			;b1a6
rellena_vram:		; HL destino, BC cuantos, A valor
	push de			;b1a7
	ld d,a			;b1a8   ; el valor se aparca en D porque A hace falta para direccionar
	call direcciona_vram_escritura		;b1a9
rellena_vram_bucle:
	ld a,d			;b1ac
	out (098h),a		;b1ad   ; el puerto 0x98 autoincrementa: se direcciona una vez y se escribe de corrido
	dec bc			;b1af   ; BC cuenta hacia atras hasta cero
	ld a,b			;b1b0
	or c			;b1b1
	jr nz,rellena_vram_bucle		;b1b2
	pop de			;b1b4
	ret			;b1b5
lee_bloque_de_vram:		; VRAM HL -> RAM DE, BC bytes
	call direcciona_vram_lectura		;b1b6
lee_bloque_de_vram_bucle:
	in a,(098h)		;b1b9   ; de la VRAM a la RAM, byte a byte
	ld (de),a			;b1bb
	inc de			;b1bc
	dec bc			;b1bd
	ld a,b			;b1be
	or c			;b1bf
	jr nz,lee_bloque_de_vram_bucle		;b1c0
	ret			;b1c2
copia_bloque_a_vram:		; RAM HL -> VRAM DE, BC bytes
	ex de,hl			;b1c3   ; la rutina recibe origen en HL y destino en DE, y 0xB185 direcciona con HL: hay que cruzarlos
	call direcciona_vram_escritura		;b1c4
copia_bloque_a_vram_bucle:
	ld a,(de)			;b1c7   ; y de la RAM a la VRAM
	out (098h),a		;b1c8
	inc de			;b1ca
	dec bc			;b1cb
	ld a,b			;b1cc
	or c			;b1cd
	jr nz,copia_bloque_a_vram_bucle		;b1ce
	ret			;b1d0

; ----------------------------------------------------------------------
; Invierte cada byte bit a bit: la fila queda del reves, o sea
; el dibujo en ESPEJO. Asi el cartucho guarda media pareja.
; ----------------------------------------------------------------------
copia_patrones_en_espejo:		; BC patrones de VRAM HL a VRAM DE
	push bc			;b1d1   ; los tres push guardan cuenta, origen y destino: el `jp nz` de 0xB207 vuelve aqui y la pila tiene que quedar cuadrada
	push hl			;b1d2
	push de			;b1d3
	ld de,0e072h		;b1d4   ; la fila baja a 0xE072, ocho bytes de RAM que hacen de banco de paso
	ld bc,00008h		;b1d7
	call lee_bloque_de_vram		;b1da   ; hay que bajarla: el Z80 no sabe rotar un byte que esta en la VRAM
	ld hl,0e072h		;b1dd
	ld c,008h		;b1e0   ; ocho filas por patron
copia_patrones_en_espejo_fila:
	ld b,008h		;b1e2   ; ocho bits por fila
copia_patrones_en_espejo_bits:
	rr (hl)		;b1e4   ; rr saca el bit 0 y rl a lo mete por el bit 0: A acaba invertido
	rl a		;b1e6
	djnz copia_patrones_en_espejo_bits		;b1e8
	ld (hl),a			;b1ea   ; la fila, ya del reves, encima de la original en el banco de paso
	inc hl			;b1eb
	dec c			;b1ec
	jr nz,copia_patrones_en_espejo_fila		;b1ed
	pop de			;b1ef   ; se saca el destino y se vuelve a apilar: hace falta otra vez en 0xB1FA
	push de			;b1f0
	ld hl,0e072h		;b1f1
	ld bc,00008h		;b1f4
	call copia_bloque_a_vram		;b1f7   ; la fila invertida vuelve a la VRAM, ya en el patron destino
	pop de			;b1fa
	pop hl			;b1fb
	ld bc,00008h		;b1fc   ; ocho bytes adelante en origen y en destino: el patron siguiente
	add hl,bc			;b1ff
	ex de,hl			;b200
	add hl,bc			;b201
	ex de,hl			;b202
	pop bc			;b203
	dec bc			;b204   ; y otra vuelta, hasta agotar BC
	ld a,b			;b205
	or c			;b206
	jp nz,copia_patrones_en_espejo		;b207
	ret			;b20a

; ----------------------------------------------------------------------
; Igual que 0xB1D1 pero cambiando el orden de los ocho bytes:
; el patron queda volteado en VERTICAL.
; ----------------------------------------------------------------------
copia_patrones_volteados:		; BC patrones de VRAM HL a VRAM DE
	push bc			;b20b
	push hl			;b20c
	push de			;b20d
	ld de,0e072h		;b20e   ; el patron entero baja a 0xE072: aqui no se rota nada, se reordenan las ocho filas
	ld bc,00008h		;b211
	call lee_bloque_de_vram		;b214
	ld hl,0e072h		;b217
	ld ix,0e079h		;b21a   ; el primero contra el ultimo, cuatro intercambios
	ld b,004h		;b21e   ; cuatro intercambios: 0 con 7, 1 con 6, 2 con 5 y 3 con 4
copia_patrones_volteados_bucle:
	ld d,(ix+000h)		;b220   ; el de arriba por el de abajo: cuatro intercambios y el patron queda del reves
	ld e,(hl)			;b223
	ld (ix+000h),e		;b224
	ld (hl),d			;b227
	inc hl			;b228
	dec ix		;b229   ; HL sube desde el primero e IX baja desde el ultimo: se cruzan en el centro
	djnz copia_patrones_volteados_bucle		;b22b
	pop de			;b22d
	push de			;b22e
	ld hl,0e072h		;b22f
	ld bc,00008h		;b232
	call copia_bloque_a_vram		;b235   ; los ocho bytes ya volteados, de vuelta a la VRAM
	pop de			;b238
	pop hl			;b239
	ld bc,00008h		;b23a   ; y al patron siguiente
	add hl,bc			;b23d
	ex de,hl			;b23e
	add hl,bc			;b23f
	ex de,hl			;b240
	pop bc			;b241
	dec bc			;b242   ; una vuelta por patron, hasta agotar BC
	ld a,b			;b243
	or c			;b244
	jp nz,copia_patrones_volteados		;b245
	ret			;b248
lee_joysticks:		; Los dos puertos, a 0xE05F y 0xE061
	ld a,00fh		;b249   ; registro 15 del PSG: seleccion del puerto de mando
	out (0a0h),a		;b24b
	ld a,0afh		;b24d   ; 0xAF: bit 6 a 0, puerto 1
	out (0a1h),a		;b24f
	ld a,00eh		;b251   ; registro 14 del PSG: por ahi entra el mando ya seleccionado
	out (0a0h),a		;b253
	in a,(0a2h)		;b255
	cpl			;b257   ; el PSG los entrega al reves; cpl deja 1 = pulsado
	ld (0e05fh),a		;b258   ; el puerto 1 se guarda en 0xE05F, que es la entrada que mira todo el juego
	ld a,00fh		;b25b
	out (0a0h),a		;b25d
	ld a,0dfh		;b25f   ; 0xDF: bit 6 a 1, puerto 2
	out (0a1h),a		;b261
	ld a,00eh		;b263
	out (0a0h),a		;b265
	in a,(0a2h)		;b267
	cpl			;b269
	ld (0e061h),a		;b26a   ; y el puerto 2 en 0xE061, que NADIE lee: ni un `ld a,(0E061h)` fuera del 0xB29C de aqui al lado, que solo lo mezcla consigo mismo. El segundo mando no vale para jugar
	ret			;b26d

; ----------------------------------------------------------------------
; La fila 8 del teclado -espacio y cursores- se recoloca bit a
; bit hasta quedar en formato de joystick, y se mezcla con los
; dos mandos: teclado y palanca son la misma cosa.
; ----------------------------------------------------------------------
lee_teclado_como_joystick:
	ld a,008h		;b26e   ; fila 8 por el PPI: 0xAA selecciona, 0xA9 lee
	or 0f0h		;b270   ; los cuatro bits altos del puerto C llevan otras senales: el 0xF0 los deja como estan
	out (0aah),a		;b272
	in a,(0a9h)		;b274   ; la fila entra por el puerto 0xA9, un bit por tecla
	cpl			;b276   ; tambien llega al reves: cpl deja 1 = pulsada
	res 1,a		;b277   ; el bit 1 de la fila 8 es una tecla que aqui no pinta nada; se borra para dejar el sitio libre
	bit 0,a		;b279   ; bit 0, espacio -> disparo (bit 1)
	jr z,lee_teclado_como_joystick_derecha		;b27b
	set 1,a		;b27d   ; y ahi va el espacio, convertido en boton de disparo
lee_teclado_como_joystick_derecha:
	res 0,a		;b27f   ; la fila 8 trae bit 0 espacio, bit 4 izquierda, bit 5 arriba, bit 6 abajo y bit 7 derecha
	bit 7,a		;b281   ; bit 7, derecha -> bit 0
	jr z,lee_teclado_como_joystick_izquierda		;b283
	set 0,a		;b285   ; la derecha, al bit 0
lee_teclado_como_joystick_izquierda:
	res 7,a		;b287
	bit 4,a		;b289   ; bit 4, izquierda -> bit 7
	jr z,lee_teclado_como_joystick_monta		;b28b
	set 7,a		;b28d   ; y la izquierda al bit 7
lee_teclado_como_joystick_monta:
	rlca			;b28f   ; tres rotaciones y 0x1F: 0 arriba 1 abajo 2 izq 3 der 4 disparo
	rlca			;b290
	rlca			;b291
	and 01fh		;b292   ; arriba y abajo (bits 5 y 6) no hay que tocarlos: el giro los deja en 0 y 1 el solo
	ld b,a			;b294   ; en B quedan los cinco bits ya colocados
	ld a,(0e05fh)		;b295   ; se mezclan con el puerto 1, y luego con el 2: teclado y palanca dan lo mismo
	or b			;b298
	ld (0e05fh),a		;b299   ; se mezcla con OR: una direccion vale si viene del mando O del teclado
	ld a,(0e061h)		;b29c   ; y lo mismo con el puerto 2, aunque de 0xE061 no vuelva a leer nadie
	or b			;b29f
	ld (0e061h),a		;b2a0
	ret			;b2a3

; ----------------------------------------------------------------------
; Ni a 0xB2A4 ni a 0xB2F4 los apunta NADIE: barrido de las 16384
; palabras del cartucho. Y a 0xB2E8 solo la llama 0xB2F4, que ya
; es codigo muerto. Las tres son INALCANZABLES: biblioteca de
; teclado que se quedo dentro sin que nada la use.
; ----------------------------------------------------------------------
explora_el_teclado:		; Nueve filas; la tecla nueva a 0xE266. Sin uso
	ld c,009h		;b2a4   ; las nueve filas del teclado, de la 0 a la 8
	ld hl,0e25dh		;b2a6   ; 0xE25D-0xE265: como estaba cada fila la vuelta anterior
explora_el_teclado_fila:
	ld b,008h		;b2a9   ; ocho teclas por fila
	ld e,001h		;b2ab   ; E es la mascara de un bit que va recorriendo la fila
	ld a,009h		;b2ad   ; 9 menos C da el numero de fila: el bucle cuenta al reves
	sub c			;b2af
	or 0f0h		;b2b0
	out (0aah),a		;b2b2
	in a,(0a9h)		;b2b4
	cpl			;b2b6   ; 1 = pulsada, como en todas partes
	ld d,a			;b2b7
explora_el_teclado_tecla:
	ld a,d			;b2b8   ; se compara la fila de ahora con la de la vuelta anterior
	and e			;b2b9
	jr z,explora_el_teclado_suelta		;b2ba
	ld a,(hl)			;b2bc   ; pulsada, pero ya lo estaba: no es tecla nueva
	and e			;b2bd
	jr nz,explora_el_teclado_sigue		;b2be
	ld a,(hl)			;b2c0   ; pulsada y antes no: se apunta en el espejo y se saca el codigo
	or e			;b2c1
	ld (hl),a			;b2c2
	push bc			;b2c3
	ld a,009h		;b2c4
	sub c			;b2c6
	rlca			;b2c7   ; codigo = fila*8 + columna
	rlca			;b2c8
	rlca			;b2c9
	ld c,a			;b2ca
	ld a,008h		;b2cb   ; 8 menos B da la columna
	sub b			;b2cd
	or c			;b2ce
	or 080h		;b2cf   ; bit 7 = hay tecla nueva
	ld (0e266h),a		;b2d1
	pop bc			;b2d4
	jr explora_el_teclado_sigue		;b2d5
explora_el_teclado_suelta:
	ld a,(hl)			;b2d7   ; y al reves: si se ha soltado, se apaga su bit en el espejo
	and e			;b2d8
	jr z,explora_el_teclado_sigue		;b2d9
	ld a,e			;b2db
	cpl			;b2dc
	and (hl)			;b2dd
	ld (hl),a			;b2de
explora_el_teclado_sigue:
	rlc e		;b2df   ; la mascara pasa a la tecla siguiente
	djnz explora_el_teclado_tecla		;b2e1
	inc hl			;b2e3   ; un byte mas alla en el espejo, que es la fila siguiente
	dec c			;b2e4
	jr nz,explora_el_teclado_fila		;b2e5
	ret			;b2e7
coge_la_tecla:		; Z si no hay ninguna. Solo la llama 0xB2F4, que ya es codigo muerto
	ld a,(0e266h)		;b2e8   ; entrega la tecla que apunto 0xB2D1
	bit 7,a		;b2eb   ; sin el bit 7 no hay tecla nueva y vuelve con Z
	ret z			;b2ed
	res 7,a		;b2ee   ; se apaga al leerla: cada pulsacion se entrega una sola vez
	ld (0e266h),a		;b2f0
	ret			;b2f3
espera_una_tecla:		; Sin uso
	call coge_la_tecla		;b2f4   ; y esta se queda dando vueltas para siempre: nadie llama a 0xB2A4, asi que 0xE266 no cambia nunca
	jr z,espera_una_tecla		;b2f7
	ret			;b2f9

; ----------------------------------------------------------------------
; Catorce bytes de RAM que son copia de los registros 0 a 13 del
; PSG, y que 0xB37B vuelca enteros al final de cada cuadro con los
; outd de 0xB386 y 0xB390 (0xB380 y 0xB384 solo ponen el puerto
; en C). Las unicas otras escrituras al puerto 0xA1 del cartucho
; son las de lee_joysticks, 0xB24F y 0xB261, y esas solo tocan
; el registro 15.
; ----------------------------------------------------------------------
reinicia_el_sonido:		; Vectores al RET vacio y PSG callado
	ld hl,vector_de_sonido_vacio		;b2fa   ; 0xB392 es un RET solo: el vector que no hace nada
	ld a,000h		;b2fd
	ld (0e1eeh),a		;b2ff   ; 0xE1EE a 0 mientras se tocan los vectores; 0xB35B no los recorre
	ld (0e1e6h),hl		;b302   ; las cuatro ranuras apuntando al ret vacio: ningun canal tiene nada que hacer
	ld (0e1e8h),hl		;b305
	ld (0e1eah),hl		;b308
	ld (0e1ech),hl		;b30b
	ld a,001h		;b30e
	ld (0e1eeh),a		;b310   ; y 0xE1EE otra vez a 1: 0xB35B ya puede recorrerlas
	ld hl,0e20eh		;b313   ; 0xE20E-0xE21B, la copia en RAM de los catorce registros del PSG
	ld bc,0000eh		;b316
	ld a,000h		;b319
	ld (hl),a			;b31b   ; el primer byte a mano y el ldir lo va arrastrando: rellenar copiandose a si mismo
	ld d,h			;b31c
	ld e,l			;b31d
	inc de			;b31e
	dec bc			;b31f   ; 13 copias, que el primer byte ya esta puesto
	ld a,b			;b320
	or c			;b321
	jr z,reinicia_el_sonido_vuelca		;b322
	ldir		;b324
	ld a,0bfh		;b326   ; 0xBF en el mezclador: tono y ruido apagados en los tres canales
	ld (0e215h),a		;b328
reinicia_el_sonido_vuelca:
	jp vuelca_registros_psg		;b32b   ; y el volcado se hace ya, sin esperar al final del cuadro: el PSG se calla en el acto

; ----------------------------------------------------------------------
; A = numero de sonido, y la tabla de 0xB393 dice en que ranura
; se instala y con que rutina. La ranura fija el canal: 0 = A,
; 1 = B, 2 = ruido en C. Leido de la tabla:
; 0 y 1 -> 0xB392, y ademas en la ranura 3, que 0xB35B ni
; siquiera recorre: son sonidos MUDOS
; 2 B3CE  3 B52E  4 B475  5 B3B4  6 B5E4
; 7 B5BE  8 B564  9 B49F  10 B4E6
; ----------------------------------------------------------------------
arranca_un_sonido:		; A = numero de sonido (0..10)
	cp 00bh		;b32e   ; del 11 en adelante no hay sonido: se sale sin tocar nada
	ret nc			;b330
	push bc			;b331   ; los tres push: la llaman desde cualquier parte del juego y no puede tocar nada
	push de			;b332
	push hl			;b333
	ld hl,0e1eeh		;b334   ; 0xE1EE a cero mientras se cambian los vectores: 0xB35B no los recorre
	ld (hl),000h		;b337
	ld b,a			;b339   ; A se guarda en B porque hace falta entero para el A*3
	add a,a			;b33a   ; A*3: registros de tres bytes
	add a,b			;b33b
	ld b,000h		;b33c   ; BC = el desplazamiento dentro de la tabla
	ld c,a			;b33e
	ld hl,0b393h		;b33f   ; la fila de la tabla de 0xB393
	add hl,bc			;b342
	ld a,(hl)			;b343   ; el primer byte de la fila es la ranura
	add a,a			;b344   ; la ranura, doblada, es el desplazamiento dentro de 0xE1E6
	ld de,0e1e6h		;b345   ; la base de las cuatro ranuras
	ld c,a			;b348
	ex de,hl			;b349   ; HL pasa a la ranura de 0xE1E6 y DE a la fila
	add hl,bc			;b34a
	inc de			;b34b
	ld a,(de)			;b34c   ; los otros dos bytes son la direccion de la rutina
	ld (hl),a			;b34d   ; el byte bajo de la rutina...
	inc de			;b34e
	inc hl			;b34f
	ld a,(de)			;b350
	ld (hl),a			;b351   ; ...y el alto: el vector ya esta instalado
	ld a,001h		;b352   ; y 0xE1EE vuelve a 1: 0xB35B ya puede recorrerlos
	ld (0e1eeh),a		;b354
	pop hl			;b357
	pop de			;b358
	pop bc			;b359
	ret			;b35a

; ----------------------------------------------------------------------
; Los tres vectores y el volcado, cada cuadro. La cuarta
; ranura, 0xE1EC, se inicializa pero no se ejecuta nunca.
; ----------------------------------------------------------------------
atiende_el_sonido:
	ld a,(0e1eeh)		;b35b   ; si 0xE1EE esta a cero no hay nada instalado
	and a			;b35e
	ret z			;b35f
	ld hl,(0e1e6h)		;b360   ; la ranura 0, el canal A
	call salta_al_vector_a		;b363   ; el Z80 no tiene `call (hl)`: se llama a un `jp (hl)` de una linea para que el vector pueda volver
	jr atiende_el_sonido_canal_b		;b366
salta_al_vector_a:
	jp (hl)			;b368
atiende_el_sonido_canal_b:
	ld hl,(0e1e8h)		;b369   ; la ranura 1, el canal B
	call salta_al_vector_b		;b36c
	jr atiende_el_sonido_canal_c		;b36f
salta_al_vector_b:
	jp (hl)			;b371
atiende_el_sonido_canal_c:
	ld hl,(0e1eah)		;b372   ; la ranura 2, el ruido del canal C
	call salta_al_vector_c		;b375
	jr vuelca_registros_psg		;b378   ; y aqui se acaban: la ranura 3 (0xE1EC) se instala en 0xB30B y no la ejecuta nadie
salta_al_vector_c:
	jp (hl)			;b37a
vuelca_registros_psg:		; 0xE20E-0xE21B a los registros 0-13
	ld hl,0e21bh		;b37b   ; se empieza por el final: 0xE21B es el registro 13
	ld b,00dh		;b37e   ; outd escribe y decrementa a la vez el registro y el puntero
vuelca_registros_psg_bucle:
	ld c,0a0h		;b380   ; el puerto 0xA0 elige el registro y el 0xA1 recibe el dato
	out (c),b		;b382
	ld c,0a1h		;b384
	outd		;b386   ; outd escribe (HL) y decrementa a la vez HL y B: del registro 13 hacia abajo
	jr nz,vuelca_registros_psg_bucle		;b388
	ld c,0a0h		;b38a   ; con B ya a cero el bucle ha salido, y el registro 0 se escribe aparte
	out (c),b		;b38c   ; el registro 0 se escribe aparte, y B vale ya cero, que es justo su numero
	ld c,0a1h		;b38e
	outd		;b390
vector_de_sonido_vacio:
	ret			;b392   ; un ret y nada mas: ahi apuntan las ranuras que no suenan

; ----------------------------------------------------------------------
; DATOS tabla_instaladora_de_vectores: Once registros de 3 bytes
;   [ranura][puntero]: la rutina de 0xB32E copia el puntero al vector
;   0xE1E6+ranura*2 y pone 0xE1EE a 1. El limite lo fija el propio codigo (cp
;   0Bh / ret nc), y en 0xB3B4 empieza ya la primera rutina instalable
;   0xb393..0xb3b4  (33 bytes)
DATA_tabla_instaladora_de_vectores:
	defb 003h,092h,0b3h	; b393
	defb 003h,092h,0b3h	; b396
	defb 001h,0ceh,0b3h	; b399
	defb 002h,02eh,0b5h	; b39c
	defb 000h,075h,0b4h	; b39f
	defb 001h,0b4h,0b3h	; b3a2
	defb 000h,0e4h,0b5h	; b3a5
	defb 000h,0beh,0b5h	; b3a8
	defb 000h,064h,0b5h	; b3ab
	defb 000h,09fh,0b4h	; b3ae
	defb 001h,0e6h,0b4h	; b3b1

; ======================================================================
; CODIGO 0xb3b4..0xb3bd  (9 bytes)
; ======================================================================


sonido_5:		; Canal B, guion de 0xB3BD
	ld hl,0b3bdh		;b3b4   ; 0xE1F5 = por donde va el guion del canal B
	ld (0e1f5h),hl		;b3b7
	jp arranca_barrido_canal_b		;b3ba

; ----------------------------------------------------------------------
; DATOS guion_sonido_b3bd: Guion de barrido del instalador 0xB3B4 (ld
;   hl,0B3BDh / ld (0E1F5h),hl): DOS registros de 8 bytes (0xB3BD y 0xB3C5) y
;   el 0x00 final en 0xB3CD
;   0xb3bd..0xb3ce  (17 bytes)
DATA_guion_sonido_b3bd:
	defb 033h,001h,001h,000h,000h,00ah,000h,030h,002h,00ch,003h,0ffh,000h,000h,000h,000h	; b3bd  3......0........
	defb 000h	; b3cd

; ======================================================================
; CODIGO 0xb3ce..0xb3d7  (9 bytes)
; ======================================================================


sonido_2:		; Canal B, guion de 0xB3D7
	ld hl,0b3d7h		;b3ce   ; mismo motor, otro guion
	ld (0e1f5h),hl		;b3d1
	jp arranca_barrido_canal_b		;b3d4

; ----------------------------------------------------------------------
; DATOS guion_sonido_b3d7: Guion del instalador 0xB3CE, con sus secciones
;   encadenadas y su 0x00 final en 0xB3EF
;   0xb3d7..0xb3f0  (25 bytes)
DATA_guion_sonido_b3d7:
	defb 00ah,003h,001h,0ffh,0ffh,0e7h,000h,087h,001h,000h,000h,000h,000h,000h,000h,000h	; b3d7  ................
	defb 008h,009h,001h,090h,000h,027h,0ffh,0b7h,000h	; b3e7  .....'...

; ======================================================================
; CODIGO 0xb3f0..0xb47e  (142 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; Guion de OCHO bytes por nota, medido por donde va a parar
; cada uno: [cuadros][volumen][periodo alto][periodo bajo]
; [paso del periodo][paso del volumen], los dos pasos de 16
; bits con signo y el alto delante. El volumen lleva parte
; fraccionaria en 0xE1FC/FD y solo sale el byte alto.
; ----------------------------------------------------------------------
arranca_barrido_canal_b:		; Se instala en la ranura 1
	ld hl,barrido_canal_b		;b3f0   ; desde el cuadro siguiente manda 0xB403; esta cabecera solo corre una vez
	ld (0e1e8h),hl		;b3f3
	ld a,(0e215h)		;b3f6
	res 1,a		;b3f9   ; bit 1 del mezclador a 0: tono del canal B encendido
	ld (0e215h),a		;b3fb
	ld a,001h		;b3fe   ; 0xE1F7 = cuadros que le quedan a la nota. Con 1, la primera entra ya en el cuadro siguiente
	ld (0e1f7h),a		;b400
barrido_canal_b:		; Un cuadro: nota nueva o seguir barriendo
	ld a,(0e1f7h)		;b403   ; un cuadro menos
	dec a			;b406
	ld (0e1f7h),a		;b407
	and a			;b40a
	jp p,barrido_canal_b_avanza		;b40b   ; mientras no se pase de cero, seguir barriendo sin tocar la nota
	ld hl,(0e1f5h)		;b40e
	ld a,(hl)			;b411   ; un 0 en el guion es el final
	and a			;b412
	jr nz,barrido_canal_b_nota		;b413
	ld hl,0b392h		;b415   ; guion agotado: la ranura vuelve al ret vacio
	ld (0e1e8h),hl		;b418
	ld a,000h		;b41b   ; y el volumen del canal B a cero, que apagar el mezclador no basta para callarlo del todo
	ld (0e217h),a		;b41d
	ld a,(0e215h)		;b420
	set 1,a		;b423   ; bit 1 del mezclador a 1: canal B apagado
	ld (0e215h),a		;b425
	ret			;b428
barrido_canal_b_nota:
	ld (0e1f7h),a		;b429   ; primer byte del registro: cuantos cuadros dura la nota
	inc hl			;b42c
	ld a,(hl)			;b42d   ; segundo byte: el volumen, que entra por el byte ALTO del acumulador de 0xE1FC
	ld (0e1fdh),a		;b42e
	ld a,000h		;b431   ; y la parte fraccionaria arranca a cero en cada nota
	ld (0e1fch),a		;b433
	inc hl			;b436
	ld a,(hl)			;b437
	ld (0e211h),a		;b438   ; 0xE211/0xE210: periodo del canal B
	inc hl			;b43b
	ld a,(hl)			;b43c   ; el periodo, el byte alto delante
	ld (0e210h),a		;b43d
	inc hl			;b440
	ld a,(hl)			;b441   ; el paso del periodo, en 0xE1F8/F9...
	ld (0e1f9h),a		;b442
	inc hl			;b445
	ld a,(hl)			;b446
	ld (0e1f8h),a		;b447
	inc hl			;b44a
	ld a,(hl)			;b44b   ; ...y el del volumen, en 0xE1FA/FB; los dos de 16 bits con signo
	ld (0e1fbh),a		;b44c
	inc hl			;b44f
	ld a,(hl)			;b450
	ld (0e1fah),a		;b451
	inc hl			;b454
	ld (0e1f5h),hl		;b455   ; el puntero queda apuntando al registro siguiente
barrido_canal_b_avanza:
	ld bc,(0e1f8h)		;b458   ; esto corre TODOS los cuadros, haya nota nueva o no: eso es el barrido
	ld hl,(0e210h)		;b45c
	adc hl,bc		;b45f   ; periodo += paso, cada cuadro
	ld (0e210h),hl		;b461
	ld bc,(0e1fah)		;b464
	ld hl,(0e1fch)		;b468
	adc hl,bc		;b46b   ; el volumen barre igual que el tono, pero con `adc` y sin limpiar el acarreo: el que deje la suma del periodo de 0xB45F se cuela aqui, porque entre las dos no hay nada que toque las banderas
	ld (0e1fch),hl		;b46d
	ld a,h			;b470
	ld (0e217h),a		;b471   ; el byte alto del acumulador es el volumen que ve el PSG
	ret			;b474
sonido_4:		; Canal A, guion de 0xB47E
	ld hl,0b47eh		;b475
	ld (0e1efh),hl		;b478
	jp arranca_guion_canal_a		;b47b

; ----------------------------------------------------------------------
; DATOS guion_sonido_b47e: Ocho registros de 4 bytes y el 0x00. Los periodos
;   NO forman escala (037F, 0120, 0222, 012D, 019F, 0137, 01BF, 0143); lo que
;   cae de golpe en golpe es el VOLUMEN, de 0x0D a 0x04: un sonido que se
;   apaga. Instalador 0xB475 (jp 0xB5EA); cierra EXACTO donde empieza el
;   codigo de 0xB49F
;   0xb47e..0xb49f  (33 bytes)
DATA_guion_sonido_b47e:
	defb 002h,003h,07fh,00dh	; b47e
	defb 001h,001h,020h,00ah	; b482
	defb 002h,002h,022h,009h	; b486
	defb 002h,001h,02dh,008h	; b48a
	defb 002h,001h,09fh,007h	; b48e
	defb 001h,001h,037h,006h	; b492
	defb 001h,001h,0bfh,005h	; b496
	defb 001h,001h,043h,004h	; b49a
	defb 000h	; b49e

; ======================================================================
; CODIGO 0xb49f..0xb56d  (206 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; Barrido sin guion: 19 cuadros con el periodo del canal A
; subiendo de 0x00F9 de 0x14 en 0x14, o sea el tono cayendo.
; ----------------------------------------------------------------------
sonido_9:		; Canal A, barrido descendente escrito en el codigo
	ld hl,sonido_9_paso		;b49f   ; la tabla instala ESTA direccion: el primer cuadro monta el sonido, cambia el vector a 0xB4BD y sigue de largo hasta el
	ld (0e1e6h),hl		;b4a2
	ld a,(0e215h)		;b4a5
	res 0,a		;b4a8   ; bit 0 del mezclador a 0: tono del canal A encendido
	ld (0e215h),a		;b4aa
	ld a,009h		;b4ad   ; volumen del canal A
	ld (0e216h),a		;b4af
	ld a,013h		;b4b2   ; 0xE1F2 = diecinueve cuadros de barrido
	ld (0e1f2h),a		;b4b4
	ld hl,000f9h		;b4b7   ; periodo de salida del canal A
	ld (0e20eh),hl		;b4ba
sonido_9_paso:
	ld a,(0e1f2h)		;b4bd   ; un cuadro menos
	dec a			;b4c0
	ld (0e1f2h),a		;b4c1
	jp p,sonido_9_avanza		;b4c4   ; mientras no pase de cero, a seguir bajando
	ld hl,0b392h		;b4c7   ; gastado: ranura al ret vacio...
	ld (0e1e6h),hl		;b4ca
	ld a,(0e215h)		;b4cd
	set 0,a		;b4d0   ; ...bit 0 del mezclador a 1, o sea tono de A apagado...
	ld (0e215h),a		;b4d2
	ld a,000h		;b4d5   ; ...y volumen de A a cero
	ld (0e216h),a		;b4d7
	ret			;b4da
sonido_9_avanza:
	ld bc,00014h		;b4db   ; mas periodo es menos tono: el sonido cae
	ld hl,(0e20eh)		;b4de
	add hl,bc			;b4e1   ; el periodo sube 0x14 por cuadro, y mas periodo es menos tono
	ld (0e20eh),hl		;b4e2
	ret			;b4e5

; ----------------------------------------------------------------------
; Tres cuadros con el periodo del canal B bajando de 0x0382 de
; 0x7F en 0x7F -o en 0x80: el sbc de 0xB528 se lleva el
; acarreo y nadie lo limpia antes-: un chasquido que sube.
; ----------------------------------------------------------------------
sonido_10:		; Canal B, chasquido ascendente de tres cuadros
	ld hl,sonido_10_paso		;b4e6   ; igual que 0xB49F: el primer cuadro monta y cae en 0xB504
	ld (0e1e8h),hl		;b4e9
	ld a,(0e215h)		;b4ec
	res 1,a		;b4ef   ; bit 1 del mezclador a 0: tono del canal B encendido
	ld (0e215h),a		;b4f1
	ld a,00bh		;b4f4   ; volumen del canal B
	ld (0e217h),a		;b4f6
	ld hl,00382h		;b4f9   ; periodo de salida 0x0382, bien grave
	ld (0e210h),hl		;b4fc
	ld a,003h		;b4ff   ; 0xE1F3 = tres cuadros y fuera
	ld (0e1f3h),a		;b501
sonido_10_paso:
	ld a,(0e1f3h)		;b504   ; un cuadro menos
	dec a			;b507
	ld (0e1f3h),a		;b508
	jp p,sonido_10_avanza		;b50b   ; mientras no pase de cero, a seguir subiendo
	ld hl,0b392h		;b50e
	ld (0e1e8h),hl		;b511
	ld a,(0e215h)		;b514
	set 1,a		;b517   ; bit 1 a 1 y volumen a cero: el canal B se apaga
	ld (0e215h),a		;b519
	ld a,000h		;b51c
	ld (0e217h),a		;b51e
	ret			;b521
sonido_10_avanza:
	ld bc,0007fh		;b522
	ld hl,(0e210h)		;b525
	sbc hl,bc		;b528   ; `sbc` y no `sub`: se lleva el acarreo que quedara de antes, y por eso el paso es 0x7F o 0x80
	ld (0e210h),hl		;b52a
	ret			;b52d

; ----------------------------------------------------------------------
; El unico sonido de RUIDO: apaga el tono del canal C y pone
; el ruido en su sitio, un solo cuadro.
; ----------------------------------------------------------------------
sonido_3:		; Un cuadro de ruido en el canal C
	ld hl,sonido_3_paso		;b52e   ; la ranura 2, que es la del canal C
	ld (0e1eah),hl		;b531
	ld a,(0e215h)		;b534
	res 5,a		;b537   ; bit 5 a 0 enciende el ruido en C, bit 2 a 1 apaga su tono
	set 2,a		;b539
	ld (0e215h),a		;b53b
	ld a,01fh		;b53e   ; periodo del ruido
	ld (0e214h),a		;b540
	ld a,009h		;b543   ; volumen del canal C
	ld (0e218h),a		;b545
	ld a,001h		;b548   ; 0xE1F4 = un solo cuadro
	ld (0e1f4h),a		;b54a
sonido_3_paso:
	ld a,(0e1f4h)		;b54d   ; un cuadro menos
	dec a			;b550
	ld (0e1f4h),a		;b551
	ret p			;b554   ; `ret p`: aqui no hay nada que barrer, solo esperar a que pase el cuadro
	ld a,(0e215h)		;b555
	set 5,a		;b558   ; bit 5 a 1: se apaga el ruido de C. El tono se queda apagado, que es como estaba
	ld (0e215h),a		;b55a
	ld hl,0b392h		;b55d   ; y la ranura, al ret vacio. Este sonido NO pone su volumen a cero al acabar, al reves que 0xB4D5 y 0xB51C: 0xE218 se queda en 9 hasta que lo borre 0xB2FA. No se oye porque el mezclador deja tono y ruido de C apagados
	ld (0e1eah),hl		;b560
	ret			;b563
sonido_8:		; Canal A, guion de 0xB56D: el de recoger el tesoro
	ld hl,0b56dh		;b564   ; 0xE1EF = por donde va el guion del canal A
	ld (0e1efh),hl		;b567
	jp arranca_guion_canal_a		;b56a

; ----------------------------------------------------------------------
; DATOS guion_sonido_b56d: Veinte registros. Instalador 0xB564; cierra EXACTO
;   en 0xB5BE
;   0xb56d..0xb5be  (81 bytes)
DATA_guion_sonido_b56d:
	defb 003h,000h,0feh,00ah	; b56d
	defb 002h,000h,000h,000h	; b571
	defb 003h,000h,0beh,00ah	; b575
	defb 002h,000h,000h,000h	; b579
	defb 003h,000h,094h,00ah	; b57d
	defb 002h,000h,000h,000h	; b581
	defb 00ah,000h,07fh,00ah	; b585
	defb 002h,000h,000h,000h	; b589
	defb 002h,000h,094h,00ah	; b58d
	defb 001h,000h,000h,000h	; b591
	defb 010h,000h,07fh,009h	; b595
	defb 001h,000h,000h,000h	; b599
	defb 002h,000h,07fh,008h	; b59d
	defb 001h,000h,000h,000h	; b5a1
	defb 002h,000h,07fh,007h	; b5a5
	defb 001h,000h,000h,000h	; b5a9
	defb 002h,000h,07fh,006h	; b5ad
	defb 001h,000h,000h,000h	; b5b1
	defb 002h,000h,07fh,004h	; b5b5
	defb 001h,000h,000h,000h	; b5b9
	defb 000h	; b5bd

; ======================================================================
; CODIGO 0xb5be..0xb5c7  (9 bytes)
; ======================================================================


sonido_7:		; Canal A, guion de 0xB5C7
	ld hl,0b5c7h		;b5be   ; mismo motor, otro guion
	ld (0e1efh),hl		;b5c1
	jp arranca_guion_canal_a		;b5c4

; ----------------------------------------------------------------------
; DATOS guion_sonido_b5c7: Siete registros. Instalador 0xB5BE; cierra EXACTO
;   en 0xB5E4
;   0xb5c7..0xb5e4  (29 bytes)
DATA_guion_sonido_b5c7:
	defb 01ch,002h,01bh,00ah	; b5c7
	defb 004h,001h,00dh,00ah	; b5cb
	defb 030h,001h,040h,00ah	; b5cf
	defb 005h,001h,00dh,00ah	; b5d3
	defb 005h,001h,040h,00ah	; b5d7
	defb 005h,001h,00dh,00ah	; b5db
	defb 013h,001h,040h,00ah	; b5df
	defb 000h	; b5e3

; ======================================================================
; CODIGO 0xb5e4..0xb632  (78 bytes)
; ======================================================================


sonido_6:		; Canal A, guion de 0xB632
	ld hl,0b632h		;b5e4   ; y este ni salta: cae directamente en el motor, que empieza en la linea de al lado
	ld (0e1efh),hl		;b5e7

; ----------------------------------------------------------------------
; Guion de CUATRO bytes por nota, leidos por 0xB683:
; [cuadros][periodo alto][periodo bajo][volumen]. Aqui el tono
; no barre: cada nota se queda quieta hasta la siguiente.
; ----------------------------------------------------------------------
arranca_guion_canal_a:		; Se instala en la ranura 0
	ld hl,guion_canal_a_paso		;b5ea   ; desde el cuadro siguiente manda 0xB5FD
	ld (0e1e6h),hl		;b5ed
	ld a,001h		;b5f0   ; 0xE1F1 = cuadros que le quedan a la nota; con 1, la primera entra en el cuadro siguiente
	ld (0e1f1h),a		;b5f2
	ld a,(0e215h)		;b5f5
	res 0,a		;b5f8   ; bit 0 del mezclador a 0: tono del canal A encendido
	ld (0e215h),a		;b5fa
guion_canal_a_paso:
	ld a,(0e1f1h)		;b5fd   ; un cuadro menos
	dec a			;b600
	ld (0e1f1h),a		;b601
	ret p			;b604   ; `ret p`: mientras queden cuadros la nota no se toca. Aqui el tono no barre
	ld hl,(0e1efh)		;b605   ; por donde iba el guion
	call lee_registro_de_guion		;b608
	and a			;b60b   ; si 0xB683 no devuelve nada es que el guion acabo
	jr nz,guion_canal_a_nota		;b60c
	ld a,(0e215h)		;b60e   ; guion agotado: tono apagado, ranura al ret vacio...
	set 0,a		;b611
	ld (0e215h),a		;b613
	ld hl,0b392h		;b616
	ld (0e1e6h),hl		;b619
	ld a,000h		;b61c   ; ...y volumen de A a cero
	ld (0e216h),a		;b61e
	ret			;b621
guion_canal_a_nota:
	ld a,b			;b622   ; los cuadros que dura la nota nueva
	ld (0e1f1h),a		;b623
	ld (0e20eh),de		;b626   ; DE al periodo del canal A
	ld a,c			;b62a
	ld (0e216h),a		;b62b   ; C al volumen del canal A
	ld (0e1efh),hl		;b62e   ; y el puntero, ya avanzado por 0xB683
	ret			;b631

; ----------------------------------------------------------------------
; DATOS guion_sonido_b632: Veinte registros de 4 bytes. Lo instala 0xB5E4 (ld
;   hl,0B632h / ld (0E1EFh),hl) y despues, cada cuadro, 0xB605 recupera el
;   puntero de 0xE1EF, 0xB608 lee el registro que toca y 0xB62E vuelve a
;   guardar el puntero ya avanzado. Cierra EXACTO en 0xB683
;   0xb632..0xb683  (81 bytes)
DATA_guion_sonido_b632:
	defb 01ch,003h,027h,00bh	; b632
	defb 008h,002h,0cfh,009h	; b636
	defb 010h,002h,0a7h,00bh	; b63a
	defb 010h,003h,027h,00ah	; b63e
	defb 004h,002h,03bh,00bh	; b642
	defb 004h,002h,050h,00ah	; b646
	defb 004h,002h,03bh,00bh	; b64a
	defb 004h,002h,050h,00ah	; b64e
	defb 004h,002h,03bh,00bh	; b652
	defb 004h,002h,050h,00ah	; b656
	defb 004h,002h,03bh,00bh	; b65a
	defb 004h,002h,050h,00ah	; b65e
	defb 004h,002h,03bh,00bh	; b662
	defb 004h,002h,050h,00ah	; b666
	defb 004h,002h,03bh,00bh	; b66a
	defb 004h,002h,050h,00ah	; b66e
	defb 004h,002h,03bh,00bh	; b672
	defb 004h,002h,050h,00ah	; b676
	defb 004h,002h,03bh,009h	; b67a
	defb 004h,002h,050h,008h	; b67e
	defb 000h	; b682

; ======================================================================
; CODIGO 0xb683..0xb6b0  (45 bytes)
; ======================================================================


lee_registro_de_guion:		; B cuadros, DE periodo, C volumen; A=0 si acabo
	ld a,(hl)			;b683   ; un 0 en el primer byte cierra el guion
	and a			;b684
	ret z			;b685
	ld b,a			;b686   ; el primer byte son los cuadros
	inc hl			;b687
	ld d,(hl)			;b688   ; los otros tres bytes: periodo en DE y volumen en C
	inc hl			;b689
	ld e,(hl)			;b68a
	inc hl			;b68b
	ld c,(hl)			;b68c
	inc hl			;b68d   ; HL sale apuntando al registro siguiente: el llamante solo tiene que guardarlo
	ret			;b68e

; ----------------------------------------------------------------------
; ############################################################
; EL MUNDO NO ESTA GUARDADO: SE CALCULA
; ############################################################
; Las 255 escenas no ocupan ni un byte de mapa: salen del
; registro de desplazamiento realimentado 0xE222. No es
; aleatorio: el orden esta fijado. La realimentacion,
; comprobada sobre los 256 valores posibles, es
; bit nuevo = b7 xor b5 xor b4 xor b3      (mascara 0xB8)
; y el anillo es maximo: 255 valores no nulos y vuelta al
; principio. El 0x00 queda fuera -de un LFSR no se sale del
; cero- y es la pantalla del titulo. Sembrando con 0xC4
; (0x8075) sale el orden del mundo yendo a la derecha;
; tools/mapa_escenas.py lo reproduce y las 255 capturas del
; emulador salen en ese mismo orden, 255 de 255.
; ----------------------------------------------------------------------
avanza_pantalla_lfsr:
	ld hl,0e222h		;b68f   ; El paso ADELANTE: desplaza 0xE222 a la izquierda metiendo el bit de realimentacion
	ld a,(hl)			;b692   ; el truco: cada `rla` empuja al acarreo el bit 7 de A, y cada `xor (hl)` vuelve a meter el registro entero para que lo que suba sea la xor de varios bits
	rla			;b693
	xor (hl)			;b694
	rla			;b695
	xor (hl)			;b696
	rla			;b697
	rla			;b698
	xor (hl)			;b699
	rla			;b69a
	ld a,(hl)			;b69b   ; tras los cinco giros el acarreo lleva b7^b5^b4^b3; se recarga A con el registro...
	rla			;b69c   ; ...y este ultimo `rla` lo corre a la izquierda metiendo esa realimentacion por el bit 0
	ld (hl),a			;b69d
	ret			;b69e
retrocede_pantalla_lfsr:
	ld hl,0e222h		;b69f   ; El paso ATRAS: la funcion inversa exacta de 0xB68F, desplazando a la derecha. Salir de una pantalla por la izquierda deshace lo que la derecha hizo
	ld a,(hl)			;b6a2   ; el mismo montaje para calcular el bit, pero al final se gira a la DERECHA
	rla			;b6a3
	xor (hl)			;b6a4
	rla			;b6a5
	xor (hl)			;b6a6
	rla			;b6a7
	rla			;b6a8
	rla			;b6a9
	xor (hl)			;b6aa
	rra			;b6ab
	ld a,(hl)			;b6ac   ; comprobado sobre los 256 valores: 0xB69F deshace exactamente lo que hace 0xB68F, en los dos sentidos
	rra			;b6ad
	ld (hl),a			;b6ae
	ret			;b6af

; ----------------------------------------------------------------------
; DATOS ret_huerfano_b6b0: Un `ret` detras del que cierra la rutina que
;   retrocede el registro de pantalla
;   0xb6b0..0xb6b1  (1 bytes)
DATA_ret_huerfano_b6b0:
	defb 0c9h	; b6b0

; ======================================================================
; CODIGO 0xb6b1..0xb9e4  (819 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; ############################################################
; LA PRESENTACION VA EN SCREEN 2; EL JUEGO, EN SCREEN 1
; ############################################################
; INIT llama aqui una sola vez, en 0x805C. Pone el registro 0
; del VDP a 0x02 -modo grafico 2- para el rotulo de entrada, y
; al salir lo devuelve a 0x00, modo grafico 1: de ahi que la
; tabla de colores del juego sean solo 32 bytes. Y no sale por
; una tecla: sale cuando el guion de la demo gasta 7 entradas.
; ----------------------------------------------------------------------
secuencia_de_presentacion:
	di			;b6b1
	ld bc,00200h		;b6b2   ; registro 0 = 0x02: modo grafico 2
	call escribe_registro_vdp		;b6b5
	ld bc,0e201h		;b6b8   ; registro 1 = 0xE2: 16K, pantalla e interrupcion activas, sprites 16x16
	call escribe_registro_vdp		;b6bb
	ld bc,00304h		;b6be   ; registro 4 = 0x03: patrones en 0x0000
	call escribe_registro_vdp		;b6c1
	ld bc,0ff03h		;b6c4   ; registro 3 = 0xFF: colores en 0x2000, los tres bancos
	call escribe_registro_vdp		;b6c7
	call carga_los_sprites		;b6ca   ; los patrones de sprite, los mismos que usa el juego
	ld hl,01800h		;b6cd   ; la tabla de nombres entera al tile 0
	ld bc,00300h		;b6d0
	xor a			;b6d3
	call rellena_vram		;b6d4
	ld hl,02000h		;b6d7   ; el PRIMER banco de color (0x2000-0x27FF) a 0xF1: blanco sobre negro
	ld bc,00800h		;b6da
	ld a,0f1h		;b6dd
	call rellena_vram		;b6df
	ld hl,0ba2dh		;b6e2   ; veinticinco tiles seguidos en la fila 6: el rotulo de Activision, que no es texto sino dibujo troceado
	ld de,018c0h		;b6e5
	ld bc,00019h		;b6e8
	call copia_bloque_a_vram		;b6eb
	ld hl,02800h		;b6ee   ; y los otros dos bancos (0x2800-0x37FF) a 0x61; 0xB99F los repinta a 0xA1 al cerrarse la franja
	ld bc,01000h		;b6f1
	ld a,061h		;b6f4
	call rellena_vram		;b6f6
	ld hl,0e247h		;b6f9   ; la lista de objetos se vacia: la presentacion monta los suyos
	ld (hl),000h		;b6fc
	ld de,0e2d5h		;b6fe   ; el jugador (0xE2D5), el de la liana (0xE32F) y el comodin (0xE2BF)
	call anade_objeto		;b701
	ld de,0e32fh		;b704
	call anade_objeto		;b707
	ld de,0e2bfh		;b70a
	call anade_objeto		;b70d
	ld ix,0e2bfh		;b710   ; y al comodin se le reprograma todo a mano, sin plantilla
	ld (ix+000h),0c0h		;b714   ; se le calza a mano el manejador de 0xB7F1 al objeto 0xE2BF
	ld (ix+010h),001h		;b718   ; periodo 1: a partir de la primera vez corre cada cuadro
	ld (ix+011h),009h		;b71c   ; pero la primera tarda nueve
	ld hl,revela_el_dibujo		;b720
	ld (ix+012h),l		;b723
	ld (ix+013h),h		;b726
	ld hl,0bab2h		;b729   ; el ultimo patron de sprite de la tabla...
	call descomprime_rle_a_vram		;b72c
	ld hl,0bacah		;b72f   ; ...y los tres primeros
	call descomprime_rle_a_vram		;b732
	ld de,0e26ah		;b735   ; los atributos de los tres sprites que baja 0xB897
	ld hl,0bc61h		;b738
	ld bc,0000ch		;b73b
	ldir		;b73e
	ld de,0e28eh		;b740   ; y los del sprite 9, el que echa a andar en 0xB853
	ld hl,0ba46h		;b743
	ld bc,00004h		;b746
	ldir		;b749
	ld a,001h		;b74b
	ld (0e221h),a		;b74d   ; 0xE221 = 1: modo DEMO, la entrada sale de 0xE259
	ei			;b750   ; `ei`: de aqui en adelante la presentacion la mueve la interrupcion, y esta rutina solo mira el contador
secuencia_de_presentacion_espera:
	ld ix,0e2bfh		;b751   ; +0x0B lo sube 0xB9C8: a la septima entrada del guion se sale
	ld a,(ix+00bh)		;b755
	cp 007h		;b758
	jr c,secuencia_de_presentacion_espera		;b75a
	ld hl,0e132h		;b75c   ; 0xE132 y los 0x17C siguientes a cero. Ahi dentro caen la marca de demo (0xE221), la lista de objetos (0xE247) y la tabla de sprites: la presentacion se apaga de un borron
	ld de,0e133h		;b75f
	ld (hl),000h		;b762
	ld bc,0017ch		;b764
	ldir		;b767
	ld hl,0e26ah		;b769   ; y la tabla ya en blanco a la VRAM, 0x44 bytes -diecisiete sprites-, que el bucle del juego manda 0x54
	ld de,01b00h		;b76c
	ld bc,00044h		;b76f
	call copia_bloque_a_vram		;b772
	halt			;b775   ; `halt`: apagar la pantalla a media imagen se ve, asi que se espera al retrazado
	ld bc,0a201h		;b776   ; registro 1 = 0xA2: pantalla apagada
	call escribe_registro_vdp		;b779
	ld hl,02000h		;b77c   ; la tabla de colores de SCREEN 2 entera, 0x1800 bytes
	ld bc,01800h		;b77f
	ld a,011h		;b782   ; 0x11 en toda la tabla de colores: todo a negro
	call rellena_vram		;b784
	halt			;b787   ; y otro `halt` antes de cambiar de modo
	ld bc,00000h		;b788   ; registro 0 = 0x00: de vuelta a modo grafico 1, el del juego
	call escribe_registro_vdp		;b78b
	ld bc,0e201h		;b78e   ; registro 1 = 0xE2 otra vez: pantalla encendida, ya en modo grafico 1
	call escribe_registro_vdp		;b791
	ld bc,08003h		;b794
	call escribe_registro_vdp		;b797
	ld bc,00004h		;b79a   ; registro 3 = 0x80 y registro 4 = 0x00: las tablas del juego
	call escribe_registro_vdp		;b79d
	di			;b7a0   ; `di`, y quien vuelve a permitir las interrupciones es 0x80F4, con el juego ya montado: de ahi en adelante todo corre dentro del gancho
	ret			;b7a1

; ----------------------------------------------------------------------
; Fin de la presentacion: se monta el jugador y se le pasa el
; mando al guion grabado de 0xB9C8.
; ----------------------------------------------------------------------
arranca_la_demo:
	ld ix,0e2d5h		;b7a2   ; el jugador
	set 0,(ix+016h)		;b7a6   ; la demo se juega en la superficie
	ld hl,0e2a2h		;b7aa   ; IX+0x14/15 apunta a sus atributos de sprite, 0xE2A2
	ld (ix+014h),l		;b7ad
	ld (ix+015h),h		;b7b0
	ld (ix+000h),0c0h		;b7b3   ; banderas 0xC0: el bit 0 apagado, o sea que no se mueve solo, y el 6 encendido, o sea manejador propio
	ld (ix+002h),001h		;b7b7   ; periodo 1: el jugador se mueve todos los cuadros
	ld hl,08243h		;b7bb   ; y el manejador es 0x8243, el mismo de reaparecer
	ld (ix+012h),l		;b7be
	ld (ix+013h),h		;b7c1
	ld a,(0e247h)		;b7c4   ; calcado de lo que hace morirse (0x822D): se apunta en 0xE189 cuantos objetos hay...
	ld (0e189h),a		;b7c7
	ld a,001h		;b7ca
	ld (0e247h),a		;b7cc   ; ...y se deja uno solo, el jugador, hasta que 0x82E7 devuelva la cuenta. Por eso el guion grabado no arranca hasta que el muneco termina de aparecer
	ld (ix+010h),001h		;b7cf
	ld (ix+011h),001h		;b7d3
	ld ix,0e2bfh		;b7d7
	ld hl,avanza_el_guion_de_la_demo		;b7db   ; a partir de aqui el objeto 0xE2BF es el que lee el guion
	ld (ix+012h),l		;b7de
	ld (ix+013h),h		;b7e1
	call monta_la_liana_objeto		;b7e4   ; la liana, que en la demo tambien se columpia
	ld hl,0e345h		;b7e7   ; 0xE345 es el +0x16 de la liana (0xE32F): puesto a 1, su bit 7 queda apagado y el columpio de la demo arranca hacia la derecha, que es lo que mira 0x81B9
	ld (hl),001h		;b7ea
	xor a			;b7ec
	ld (0e1cbh),a		;b7ed   ; y la fase del balanceo a cero
	ret			;b7f0

; ----------------------------------------------------------------------
; El rotulo no se pinta: se revela. Cada cuadro desplaza un
; pixel los diez patrones de 0xE132 y los vuelca a la tabla de
; patrones; cada ocho cuadros recarga el dibujo y avanza una
; columna, hasta la 0x18.
; ----------------------------------------------------------------------
revela_el_dibujo:		; Saca el rotulo de entrada, un pixel por cuadro
	ld ix,0e2bfh		;b7f1   ; el comodin de la presentacion; +0x09 cuenta cuadros y +0x0A columnas
	ld a,(ix+009h)		;b7f5
	and 007h		;b7f8   ; uno de cada ocho cuadros toca columna nueva
	jr z,revela_el_dibujo_columna		;b7fa
	jp revela_el_dibujo_desplaza		;b7fc
revela_el_dibujo_columna:
	ld hl,0ba4ah		;b7ff   ; columna nueva: el dibujo se recarga entero y sin desplazar
	ld de,0e132h		;b802
	ld bc,00058h		;b805   ; 0x58 bytes, pero solo se corren los 0x50 primeros: diez patrones de ocho
	ldir		;b808
	inc (ix+00ah)		;b80a   ; una columna mas
	ld e,(ix+00ah)		;b80d
	ld a,018h		;b810   ; columna 0x18: se acabo, y toma el relevo 0xB8C3
	cp e			;b812
	jr nz,revela_el_dibujo_color		;b813
	ld ix,0e2bfh		;b815   ; se acabo el rotulo: el comodin pasa a mover la franja
	ld hl,anima_la_franja		;b819
	ld (ix+012h),l		;b81c
	ld (ix+013h),h		;b81f
	ld (ix+00bh),003h		;b822   ; +0x0B = 3, que es lo que cuenta las tres pasadas de la franja
	ld (ix+00fh),001h		;b826   ; anchura 1, periodo 1 y cinco cuadros para la primera
	ld (ix+010h),001h		;b82a
	ld (ix+011h),005h		;b82e
	ret			;b832
revela_el_dibujo_color:
	ld l,e			;b833   ; la columna, por 8: cada tile son ocho bytes de color
	ld h,000h		;b834
	add hl,hl			;b836
	add hl,hl			;b837
	add hl,hl			;b838
	ld de,020b8h		;b839   ; 0x20B8 = tabla de colores, entrada del tile 0x17
	add hl,de			;b83c
	ex de,hl			;b83d
	ld hl,0ba9ah		;b83e   ; los ocho colores del rotulo, uno por columna revelada
	ld bc,00008h		;b841
	call copia_bloque_a_vram		;b844
	ld ix,0e2bfh		;b847
revela_el_dibujo_desplaza:
	ld e,(ix+00ah)		;b84b   ; por donde va la columna
	ld a,00bh		;b84e   ; a partir de la columna 12 aparece el sprite 9 y echa a andar
	cp e			;b850
	jr nc,revela_el_dibujo_sigue		;b851
	ld iy,0e28eh		;b853   ; el sprite 9 se pone en el patron 0x0F y empieza a bajar
	ld (iy+003h),00fh		;b857
	inc (iy+001h)		;b85b
revela_el_dibujo_sigue:
	inc (ix+009h)		;b85e   ; un cuadro mas
	ld hl,0e132h		;b861   ; el banco de paso, con los diez patrones dentro
	ld de,00008h		;b864   ; de patron a patron van ocho bytes: el bucle de dentro corre la misma columna en los diez
	ld b,008h		;b867   ; y el de fuera, las ocho columnas del patron
revela_el_dibujo_columna_bits:
	push bc			;b869
	push hl			;b86a
	ld b,00ah		;b86b
	or a			;b86d
	scf			;b86e   ; scf: por la izquierda entran unos, que es el fondo
revela_el_dibujo_bits:
	rr (hl)		;b86f   ; diez patrones, uno cada 8 bytes: la fila se corre un pixel
	push af			;b871
	add hl,de			;b872
	pop af			;b873
	djnz revela_el_dibujo_bits		;b874
	pop hl			;b876
	inc hl			;b877
	pop bc			;b878
	djnz revela_el_dibujo_columna_bits		;b879
	ld l,(ix+00ah)		;b87b   ; el destino sube un tile por columna: el dibujo se corre ocho pixeles y salta al tile siguiente
	ld h,000h		;b87e
	add hl,hl			;b880
	add hl,hl			;b881
	add hl,hl			;b882
	ld de,000b0h		;b883   ; 0x00B0 = tabla de patrones, tile 0x16
	add hl,de			;b886
	ex de,hl			;b887
	ld hl,0e132h		;b888
	ld bc,00050h		;b88b   ; los 0x50 bytes desplazados, de vuelta a la tabla de patrones
	call copia_bloque_a_vram		;b88e
	ld a,(0e2c9h)		;b891   ; los tres sprites de abajo no salen hasta la columna 5
	cp 005h		;b894
	ret c			;b896
	ld a,(0e26bh)		;b897   ; 0xE26B es la X del sprite 0: se mueve a la izquierda
	dec a			;b89a
	ld (0e26bh),a		;b89b
	cp 045h		;b89e   ; por debajo de X=0x45 el sprite cambia de color...
	jr c,revela_el_dibujo_sprite_2		;b8a0
	ld hl,0e26dh		;b8a2   ; ...al 5
	ld (hl),005h		;b8a5
revela_el_dibujo_sprite_2:
	add a,010h		;b8a7   ; el segundo va dieciseis pixeles detras del primero
	ld (0e26fh),a		;b8a9
	cp 045h		;b8ac
	jr c,revela_el_dibujo_sprite_3		;b8ae
	ld hl,0e271h		;b8b0
	ld (hl),005h		;b8b3
revela_el_dibujo_sprite_3:
	add a,010h		;b8b5   ; y el tercero, otros dieciseis
	ld (0e273h),a		;b8b7
	cp 045h		;b8ba
	ret c			;b8bc
	ld hl,0e275h		;b8bd
	ld (hl),005h		;b8c0
	ret			;b8c2

; ----------------------------------------------------------------------
; La franja de las filas 15 y 16 se abre y se cierra desde la
; columna 16 hacia los dos lados. El bit 0 de +0x0B alterna:
; abre, cierra (y cambia el color), abre y arranca la demo.
; ----------------------------------------------------------------------
anima_la_franja:
	ld ix,0e2bfh		;b8c3   ; el mismo comodin, ahora con la franja
	ld (ix+010h),006h		;b8c7   ; periodo 6: la franja se abre de seis en seis cuadros
	bit 1,(ix+00bh)		;b8cb   ; el bit 1 elige cual de las dos parejas de tiles se carga
	jr nz,anima_la_franja_variante_b		;b8cf
	ld hl,0bb01h		;b8d1   ; con +0x0B en 1 van los tiles de 0xBB01 y 0xBB4A...
	call descomprime_rle_a_vram		;b8d4
	ld hl,0bb4ah		;b8d7
	call descomprime_rle_a_vram		;b8da
	jr anima_la_franja_pinta		;b8dd
anima_la_franja_variante_b:
	ld hl,0bb95h		;b8df   ; ...y con 3 o 2, los de 0xBB95 y 0xBBFB: las dos primeras pasadas salen con un dibujo y la tercera con el otro
	call descomprime_rle_a_vram		;b8e2
	ld hl,0bbfbh		;b8e5
	call descomprime_rle_a_vram		;b8e8
anima_la_franja_pinta:
	ld ix,0e2bfh		;b8eb
	ld hl,001f0h		;b8ef   ; 0x19F0 = fila 15, columna 16: el centro desde donde se abre
	ld e,(ix+00fh)		;b8f2   ; IX+0x0F es la anchura y el paso a la vez
	ld d,000h		;b8f5
	or a			;b8f7
	sbc hl,de		;b8f8
	ld de,01800h		;b8fa
	add hl,de			;b8fd
	ex de,hl			;b8fe
	ld hl,0ba06h		;b8ff   ; la mitad izquierda arranca siempre en el tile 0x0A y crece hacia la derecha
	ld bc,(0e2ceh)		;b902   ; 0xE2CE es el +0x0F del propio objeto: anchura y contador a la vez
	ld b,000h		;b906
	call copia_bloque_a_vram		;b908
	ld ix,0e2bfh		;b90b
	ld a,007h		;b90f   ; y la derecha se lee de atras adelante, para acabar siempre en el 0x17: la franja se abre por el centro
	sub (ix+00fh)		;b911
	ld e,a			;b914
	ld d,000h		;b915
	ld hl,0ba0dh		;b917
	add hl,de			;b91a
	ld de,019f0h		;b91b
	ld bc,(0e2ceh)		;b91e
	ld b,000h		;b922
	call copia_bloque_a_vram		;b924
	ld ix,0e2bfh		;b927
	ld hl,00210h		;b92b   ; y otro par igual una fila mas abajo, desde la celda 0x210
	ld e,(ix+00fh)		;b92e
	ld d,000h		;b931
	or a			;b933
	sbc hl,de		;b934
	ld de,01800h		;b936
	add hl,de			;b939
	ex de,hl			;b93a
	ld hl,0ba06h		;b93b
	ld bc,(0e2ceh)		;b93e
	ld b,000h		;b942
	call copia_bloque_a_vram		;b944
	ld ix,0e2bfh		;b947
	ld a,007h		;b94b   ; lo mismo que 0xB90F, una fila mas abajo
	sub (ix+00fh)		;b94d
	ld e,a			;b950
	ld d,000h		;b951
	ld hl,0ba0dh		;b953
	add hl,de			;b956
	ld de,01a10h		;b957
	ld bc,(0e2ceh)		;b95a
	ld b,000h		;b95e
	call copia_bloque_a_vram		;b960
	ld ix,0e2bfh		;b963
	bit 0,(ix+00bh)		;b967   ; bit 0 de +0x0B: 1 abre, 0 cierra
	jr z,anima_la_franja_cierra		;b96b
	inc (ix+00fh)		;b96d   ; abriendo, la anchura sube hasta 7
	ld a,008h		;b970   ; y al llegar a 8 se para
	cp (ix+00fh)		;b972
	ret nz			;b975
	dec (ix+00fh)		;b976   ; la anchura se deja en 7 y +0x0B baja uno: se acaba la pasada
	dec (ix+00bh)		;b979
	ld (ix+011h),050h		;b97c   ; 0x50 cuadros de pausa entre pasada y pasada
	ld a,000h		;b980
	cp (ix+00bh)		;b982
	ret nz			;b985
	ld hl,arranca_la_demo		;b986   ; tercera pasada terminada: a la demo
	ld (ix+012h),l		;b989
	ld (ix+013h),h		;b98c
	ret			;b98f
anima_la_franja_cierra:
	dec (ix+00fh)		;b990   ; cerrando, la anchura baja hasta 1
	ret nz			;b993
	ld (ix+00fh),001h		;b994   ; al cerrar del todo vuelve a 1
	dec (ix+00bh)		;b998
	ld (ix+011h),020h		;b99b   ; 0x20 cuadros de pausa antes de la pasada siguiente
	ld hl,02800h		;b99f   ; 0xA1 en los bancos de color de abajo: la franja cambia de tono
	ld bc,01000h		;b9a2
	ld a,0a1h		;b9a5
	call rellena_vram		;b9a7
	ret			;b9aa

; ----------------------------------------------------------------------
; Copia patrones sueltos leyendo de 0x10 en 0x10. NADIE la
; llama: ni un call ni un puntero apuntan aqui.
; ----------------------------------------------------------------------
copia_patrones_salteados:		; Sin uso: nadie la llama
	push bc			;b9ab
	push de			;b9ac
	push hl			;b9ad
	ex de,hl			;b9ae   ; el destino no llega como direccion sino como NUMERO de patron...
	add hl,hl			;b9af   ; ...y se multiplica por ocho para dar la direccion en la VRAM
	add hl,hl			;b9b0
	add hl,hl			;b9b1
	ld bc,00000h		;b9b2   ; add hl,0: no hace nada, resto de otra version (?)
	add hl,bc			;b9b5
	ex de,hl			;b9b6
	ld bc,00008h		;b9b7   ; ocho bytes, o sea un patron
	call copia_bloque_a_vram		;b9ba
	pop hl			;b9bd
	ld de,00010h		;b9be   ; en el origen se avanza 0x10, o sea DOS patrones: de ahi lo de salteados
	add hl,de			;b9c1
	pop de			;b9c2
	inc de			;b9c3   ; y en el destino solo uno
	pop bc			;b9c4
	djnz copia_patrones_salteados		;b9c5
	ret			;b9c7

; ----------------------------------------------------------------------
; LA DEMO ESTA GRABADA: la tabla de 0xB9E4 son parejas
; [cuadros][entrada], y la entrada viene en el formato que
; saca 0xB26E. Las seis primeras son la partida: 0x48 quieto,
; 0x3A a la derecha, 0x20 saltando a la derecha, 0xBA quieto,
; 0x10 agachado, 0x40 a la derecha, y tres esperas de 0xFF
; cuadros. Lo que sigue (01 02 03 04...) parece relleno (?).
; ----------------------------------------------------------------------
avanza_el_guion_de_la_demo:
	ld ix,0e2bfh		;b9c8   ; el comodin otra vez, ahora llevando la cuenta del guion
	ld e,(ix+00bh)		;b9cc
	sla e		;b9cf   ; +0x0B es la entrada del guion, doblada porque son parejas
	ld d,000h		;b9d1
	ld hl,0b9e4h		;b9d3   ; la tabla de parejas
	add hl,de			;b9d6
	ld a,(hl)			;b9d7
	ld (ix+011h),a		;b9d8   ; el primer byte del par: cuantos cuadros hasta la entrada siguiente
	inc hl			;b9db
	ld a,(hl)			;b9dc
	ld (0e259h),a		;b9dd   ; la entrada que 0x9A7E le mete al jugador
	inc (ix+00bh)		;b9e0   ; y a la pareja siguiente, que es la que mira 0xB755 para salirse
	ret			;b9e3

; ----------------------------------------------------------------------
; DATOS guion_grabado_de_la_demo: Diecisiete parejas [cuadros][entrada] que
;   0xB9C8 recorre con el indice de IX+0x0B doblado: el primer byte va a
;   IX+0x11 (0xB9D8) y el segundo a 0xE259 (0xB9DD), que es de donde la demo
;   se saca los mandos. Acotada por la estructura siguiente, que empieza en
;   0xBA06
;   0xb9e4..0xba06  (34 bytes)
DATA_guion_grabado_de_la_demo:
	defb 048h,000h	; b9e4
	defb 03ah,008h	; b9e6
	defb 020h,018h	; b9e8
	defb 0bah,000h	; b9ea
	defb 010h,002h	; b9ec
	defb 040h,008h	; b9ee
	defb 0ffh,000h	; b9f0
	defb 0ffh,000h	; b9f2
	defb 0ffh,000h	; b9f4
	defb 001h,002h	; b9f6
	defb 003h,004h	; b9f8
	defb 005h,006h	; b9fa
	defb 007h,008h	; b9fc
	defb 000h,000h	; b9fe
	defb 000h,000h	; ba00
	defb 000h,000h	; ba02
	defb 000h,000h	; ba04

; ----------------------------------------------------------------------
; DATOS filas_de_tiles_seguidos: Los tiles 0x0A a 0x17 dos veces seguidas
;   (0xBA06 y 0xBA14) y detras diez 0x2C y un 0x2D, que ya no son continuacion
;   de la serie sino relleno con otro tile. 0xB8FF copia desde 0xBA06 y 0xB917
;   desde 0xBA0D, los dos con la longitud sacada de 0xE2CE
;   0xba06..0xba2d  (39 bytes)
DATA_filas_de_tiles_seguidos:
	defb 00ah,00bh,00ch,00dh,00eh,00fh,010h,011h,012h,013h,014h,015h,016h,017h,00ah,00bh	; ba06  ................
	defb 00ch,00dh,00eh,00fh,010h,011h,012h,013h,014h,015h,016h,017h,02ch,02ch,02ch,02ch	; ba16  ............,,,,
	defb 02ch,02ch,02ch,02ch,02ch,02ch,02dh	; ba26

; ----------------------------------------------------------------------
; DATOS fila_dibujo_6: Veinticinco tiles CONSECUTIVOS (0x22 a 0x3A) que 0xB6E2
;   copia a la VRAM 0x18C0, la fila 6 del name table, columnas 0-24. No es
;   texto: es un dibujo troceado tile a tile, como todo lo que parece letra en
;   este cartucho
;   0xba2d..0xba46  (25 bytes)
DATA_fila_dibujo_6:
	defb 022h,023h,024h,025h,026h,027h,028h,029h,02ah,02bh,02ch,02dh,02eh,02fh,030h,031h	; ba2d  "#$%&'()*+,-./01
	defb 032h,033h,034h,035h,036h,037h,038h,039h,03ah	; ba3d  23456789:

; ----------------------------------------------------------------------
; DATOS inicializador_e28e_b: Cuatro bytes que 0xB749 copia a 0xE28E
;   0xba46..0xba4a  (4 bytes)
DATA_inicializador_e28e_b:
	defb 02fh,000h,0f8h,000h	; ba46

; ----------------------------------------------------------------------
; DATOS inicializador_e132: Ochenta y ocho bytes que 0xB808 copia a 0xE132
;   0xba4a..0xbaa2  (88 bytes)
DATA_inicializador_e132:
	defb 0feh,0fch,0f8h,0f0h,0e0h,0c0h,080h,000h,0c7h,0c0h,0cfh,0cch,0cch,0cch,0cch,0cfh	; ba4a  ................
	defb 0ffh,018h,099h,019h,019h,019h,019h,099h,0f8h,018h,098h,099h,09bh,09eh,09ch,098h	; ba5a  ................
	defb 03fh,060h,0c0h,08ch,00ch,00ch,00ch,00ch,0ffh,000h,0fch,0c0h,0fch,00ch,00ch,0fch	; ba6a  ?`..............
	defb 080h,000h,0cfh,0cch,0cch,0cch,0cch,0cfh,000h,000h,0cch,0ceh,0cfh,0cdh,0cch,0cch	; ba7a  ................
	defb 000h,000h,060h,060h,060h,0e0h,0e0h,060h,000h,000h,000h,000h,000h,000h,000h,000h	; ba8a  ..```..`........
	defb 060h,090h,0b0h,0a0h,0c0h,030h,050h,040h	; ba9a  `....0P@

; ----------------------------------------------------------------------
; DATOS listas_nibble_espejo: Dos listas de 8 bytes, y la segunda es la
;   primera CON LOS NIBBLES INTERCAMBIADOS (61->16, 91->19, B1->1B...). Son
;   bytes de la tabla de COLORES: el nibble alto es la tinta y el bajo el
;   fondo. La primera lista es byte a byte la de 0xBA9A -60 90 B0 A0 C0 30 50
;   40, los ocho colores del rotulo que 0xB83E vuelca a 0x20B8- con el nibble
;   bajo puesto a 1: los mismos ocho colores sobre NEGRO en vez de sobre
;   transparente. Y la segunda es esa con la tinta y el fondo cambiados.
;   Consumidor sin encontrar: los unicos literales de la ROM que caen en esta
;   zona son 0xBA4A (0xB7FF, ldir de 0x58 bytes que acaba justo en 0xBAA2),
;   0xBA9A (0xB83E, ocho bytes que tambien acaban en 0xBAA2) y 0xBAB2
;   (0xB729); ninguno entra aqui. Acotada por el inicializador que acaba en
;   0xBAA2 y el bloque RLE que empieza en 0xBAB2
;   0xbaa2..0xbab2  (16 bytes)
DATA_listas_nibble_espejo:
	defb 061h,091h,0b1h,0a1h,0c1h,031h,051h,041h	; baa2  a....1QA
	defb 016h,019h,01bh,01ah,01ch,013h,015h,014h	; baaa  ........

; ----------------------------------------------------------------------
; DATOS graficos_rle_b7_sprites: Bloque RLE: 32 bytes a la VRAM 0x3FC0, o sea
;   UN patron de sprite de 16x16 -0xB6B8 pone el registro 1 del VDP a 0xE2,
;   con el bit 1 a uno-, el ultimo de la tabla que arranca en 0x3800. Lo carga
;   0xB729
;   0xbab2..0xbaca  (24 bytes)
DATA_graficos_rle_b7_sprites:
	defb 0c0h,03fh,048h,001h,003h,006h,00ch,01fh,030h,060h,0c0h,008h,000h,043h,0c7h,0c0h	; bab2  .?H.....0`...C..
	defb 0cfh,004h,0cch,041h,0cfh,008h,000h,000h	; bac2  ...A....

; ----------------------------------------------------------------------
; DATOS graficos_rle_b7_sprites2: Bloque RLE: 96 bytes a la VRAM 0x3800, los
;   tres primeros patrones de sprite. Lo carga 0xB72F
;   0xbaca..0xbb01  (55 bytes)
DATA_graficos_rle_b7_sprites2:
	defb 000h,038h,047h,000h,07dh,04dh,07dh,061h,061h,061h,00ah,000h,046h,0f7h,036h,0f7h	; baca  .8G.}M}aaa..F.6.
	defb 0e6h,0b6h,0b7h,00ah,000h,046h,0bdh,031h,03dh,00dh,00dh,0bdh,00ah,000h,046h,0ech	; bada  .....F.1=.....F.
	defb 08eh,0cfh,08fh,08dh,0ech,00ah,000h,041h,0dfh,005h,0c6h,00ah,000h,046h,0bch,030h	; baea  .......A.....F.0
	defb 03ch,00ch,00ch,03ch,009h,000h,000h	; bafa

; ----------------------------------------------------------------------
; DATOS graficos_rle_tiles_v1a: Bloque RLE: 112 bytes (14 tiles) a la VRAM
;   0x0850, banco 1 de la tabla de patrones. Rama del bit 1 de IX+0x0B
;   apagado; lo carga 0xB8D1
;   0xbb01..0xbb4a  (73 bytes)
DATA_graficos_rle_tiles_v1a:
	defb 050h,008h,010h,000h,003h,07fh,005h,03fh,044h,0f8h,0fch,0feh,03fh,004h,01fh,044h	; bb01  P......?D...?..D
	defb 0fdh,0fdh,079h,079h,004h,078h,043h,0ffh,0ffh,0bdh,005h,03ch,05ah,0ffh,0ffh,0beh	; bb11  ..yy.xC....<Z...
	defb 0beh,03eh,03eh,03fh,03fh,0f8h,0f9h,039h,01bh,003h,076h,0f6h,0ffh,0f3h,0fbh,0f9h	; bb21  .>>??..9..v.....
	defb 07dh,07dh,03dh,03dh,0ffh,0f1h,0f1h,006h,0e0h,042h,0f8h,0f8h,006h,0f0h,041h,07dh	; bb31  }}==.....B....A}
	defb 007h,07ch,043h,0dfh,095h,091h,00dh,000h,000h	; bb41  .|C......

; ----------------------------------------------------------------------
; DATOS graficos_rle_tiles_v1b: Bloque RLE: 112 bytes a la VRAM 0x1050. Son
;   los mismos NUMEROS de tile que el banco 1 (0x0A-0x17) pero con DIBUJO
;   DISTINTO: descomprimidos los dos, 72 de los 112 bytes cambian. Lo carga
;   0xB8D7
;   0xbb4a..0xbb95  (75 bytes)
DATA_graficos_rle_tiles_v1b:
	defb 050h,010h,010h,000h,006h,03fh,05bh,07fh,07fh,03fh,0feh,0fch,0f8h,000h,000h,080h	; bb4a  P....?[..?......
	defb 080h,078h,078h,0fch,0fch,0fch,000h,000h,000h,03ch,03ch,07eh,07eh,07eh,000h,000h	; bb5a  .xx......<<~~~..
	defb 000h,03fh,005h,03eh,046h,07fh,07fh,0ffh,07fh,07ch,03eh,004h,000h,044h,0ffh,0ffh	; bb6a  .?.>F....|>..D..
	defb 01fh,03fh,004h,000h,044h,0e0h,0e2h,0e7h,0ffh,004h,000h,044h,0f0h,0f1h,0f3h,0ffh	; bb7a  .?..D......D....
	defb 004h,000h,005h,07ch,043h,000h,07ch,07ch,010h,000h,000h	; bb8a  ...|C.||...

; ----------------------------------------------------------------------
; DATOS graficos_rle_tiles_v2a: Bloque RLE: 112 bytes a la VRAM 0x0850, la
;   variante con el bit 1 de IX+0x0B encendido. Lo carga 0xB8DF
;   0xbb95..0xbbfb  (102 bytes)
DATA_graficos_rle_tiles_v2a:
	defb 050h,008h,00bh,000h,065h,0f8h,0fch,06eh,066h,066h,000h,000h,000h,01ch,03eh,03eh	; bb95  P...e..nff....>>
	defb 036h,077h,000h,000h,000h,0e7h,0e7h,066h,066h,07eh,000h,000h,000h,07bh,07bh,031h	; bba5  6w.....ff~...{{1
	defb 031h,031h,000h,000h,000h,0e0h,0f0h,0b8h,098h,098h,078h,000h,000h,000h,007h,00fh	; bbb5  11........x.....
	defb 01ch,018h,018h,000h,000h,000h,09fh,0dfh,0cch,00ch,00fh,000h,000h,000h,0c1h,0e3h	; bbc5  ................
	defb 0e3h,0e3h,0c7h,000h,000h,000h,0ceh,0efh,0e7h,067h,076h,000h,000h,000h,07bh,07bh	; bbd5  .........gv...{{
	defb 0b1h,0f1h,0f1h,000h,000h,000h,0f9h,0f9h,098h,080h,0e0h,000h,000h,080h,09eh,03fh	; bbe5  ...............?
	defb 033h,030h,03eh,008h,000h,000h	; bbf5

; ----------------------------------------------------------------------
; DATOS graficos_rle_tiles_v2b: Bloque RLE: 112 bytes a la VRAM 0x1050, y
;   cierra EXACTO contra el inicializador de 0xBC61. Lo carga 0xB8E5
;   0xbbfb..0xbc61  (102 bytes)
DATA_graficos_rle_tiles_v2b:
	defb 050h,010h,008h,000h,078h,066h,066h,06eh,0fch,0f8h,000h,000h,000h,063h,07fh,07fh	; bbfb  P...xffn.....c..
	defb 0e3h,0f7h,000h,000h,000h,03ch,03ch,03ch,098h,098h,000h,000h,000h,031h,031h,031h	; bc0b  .....<<<.....111
	defb 07bh,07bh,000h,000h,000h,098h,098h,0b8h,0f0h,0e0h,000h,000h,000h,018h,018h,01ch	; bc1b  {{..............
	defb 00fh,007h,000h,000h,000h,00dh,00dh,0cch,0deh,09eh,000h,000h,000h,065h,086h,0c7h	; bc2b  .............e..
	defb 0c7h,0eeh,0efh,000h,000h,000h,036h,0f6h,0f6h,03fh,07fh,000h,000h,000h,071h,031h	; bc3b  ......6..?....q1
	defb 031h,07bh,07bh,000h,000h,000h,0e0h,080h,098h,0f8h,0f8h,000h,000h,000h,01fh,003h	; bc4b  1{{.............
	defb 033h,03fh,01eh,00bh,000h,000h	; bc5b

; ----------------------------------------------------------------------
; DATOS inicializador_e26a_b: Doce bytes que 0xB73E copia a 0xE26A
;   0xbc61..0xbc6d  (12 bytes)
DATA_inicializador_e26a_b:
	defb 03ch,0ffh,000h,000h,03ch,0ffh,004h,000h,03ch,0ffh,008h,000h	; bc61  <...<...<...

; ----------------------------------------------------------------------
; DATOS relleno: Los 915 bytes finales del cartucho, TODOS a 0x00 (comprobado
;   byte a byte): relleno hasta completar los 16 KB
;   0xbc6d..0xc000  (915 bytes)
DATA_relleno:
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bc6d  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bc7d  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bc8d  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bc9d  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bcad  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bcbd  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bccd  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bcdd  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bced  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bcfd  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bd0d  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bd1d  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bd2d  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bd3d  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bd4d  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bd5d  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bd6d  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bd7d  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bd8d  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bd9d  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bdad  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bdbd  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bdcd  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bddd  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bded  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bdfd  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; be0d  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; be1d  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; be2d  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; be3d  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; be4d  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; be5d  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; be6d  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; be7d  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; be8d  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; be9d  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bead  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bebd  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; becd  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bedd  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; beed  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; befd  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bf0d  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bf1d  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bf2d  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bf3d  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bf4d  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bf5d  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bf6d  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bf7d  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bf8d  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bf9d  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bfad  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bfbd  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bfcd  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bfdd  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bfed  ................
	defb 000h,000h,000h	; bffd
