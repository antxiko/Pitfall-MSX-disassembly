; ==========================================================================
; PITFALL! - Activision (1984) - MSX1 - cartucho de 16 KB en la pagina 2
; ==========================================================================
; Generado por tools/mkasm.py a partir del trazado de flujo real.
; Los comentarios provienen de tools/../src/*.notes y estan anclados a
; direccion, de modo que sobreviven a un retrazado.
; ==========================================================================

	org 0x08000


; ----------------------------------------------------------------------
; Direcciones que solo aparecen como VALOR -en un `ld`, no en
; un salto-: son punteros que el codigo se pasa o numeros que
; casualmente coinciden con una direccion. No hay nada que
; trazar en ellas; el equ existe para que el listado ensamble.
; ----------------------------------------------------------------------
lb403h:	equ 0x0b403
lb4bdh:	equ 0x0b4bd
lb504h:	equ 0x0b504
lb54dh:	equ 0x0b54d
lb5fdh:	equ 0x0b5fd

; ----------------------------------------------------------------------
; DATOS cabecera_del_cartucho: La cabecera que lee la BIOS: "AB", INIT=0x8013, y a cero los otros tres vectores (STATEMENT, DEVICE y TEXT). Con eso la BIOS llama a 0x8013 nada mas terminar de arrancar la maquina
;   0x8000..0x8010  (16 bytes)
; DATOS plantilla_del_gancho: Los tres bytes C3 F7 80 -un `jp 0x80F7` ya montado- que INIT copia tal cual al gancho H.KEYI (0xFD9A) con el LDIR de 0x803C-0x8046. Aqui dentro no se ejecutan nunca: se ejecutan en la RAM del gancho, en cada interrupcion
;   0x8010..0x8013  (3 bytes)
; ----------------------------------------------------------------------
	defb 041h,042h,013h,080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; 8000  AB..............
	defb 0c3h,0f7h,080h	; 8010  ...

; ======================================================================
; CODIGO 0x8013..0x8a69  (2646 bytes)
; ======================================================================


INIT:
	di			;8013
	ld hl,0e000h		;8014
	ld bc,01000h		;8017
L_801A:
	ld (hl),000h		;801a
	inc hl			;801c
	dec bc			;801d
	ld a,b			;801e
	or c			;801f
	jp nz,L_801A		;8020
	ld sp,0e54bh		;8023
	call L_B2FA		;8026
	ld a,0f0h		;8029
	out (0aah),a		;802b
	call L_B113		;802d
	ld bc,08001h		;8030
	call L_B17C		;8033
	ld bc,01107h		;8036
	call L_B17C		;8039
	ld hl,08010h		;803c
	ld de,0fd9ah		;803f
	ld bc,00003h		;8042
	ldir		;8045
	ld bc,0e201h		;8047
	call L_B17C		;804a
	xor a			;804d
	ld (0e269h),a		;804e
	call L_B2FA		;8051
	ld a,00dh		;8054
	ld (0e1e5h),a		;8056
	ld (0e1e3h),a		;8059
	call L_B6B1		;805c
	call L_B113		;805f
	call L_8B5E		;8062
L_8065:
	ld sp,0e54bh		;8065
	xor a			;8068
	ld (0e267h),a		;8069
	ld (0e269h),a		;806c
	call L_B2FA		;806f
	call L_8A01		;8072
	ld a,0c4h		;8075
	ld (0e222h),a		;8077
	call L_ACE4		;807a
	ld de,0e32fh		;807d
	call L_9D30		;8080
	ld a,001h		;8083
	ld (0e132h),a		;8085
	ld (0e133h),a		;8088
	ld de,0e2bfh		;808b
	ld hl,0b02ah		;808e
	ld bc,00016h		;8091
	ldir		;8094
	ld de,0e2bfh		;8096
	call L_9D30		;8099
	call L_8DDE		;809c
	call L_9EE6		;809f
	ld a,003h		;80a2
	ld ix,0e346h		;80a4
	ld (ix+000h),a		;80a8
	ld (ix+001h),a		;80ab
	ld hl,0e345h		;80ae
	ld (hl),001h		;80b1
	ld a,00dh		;80b3
	ld (0e1e5h),a		;80b5
	ld (0e1e3h),a		;80b8
	ld a,001h		;80bb
	ld (0e21ch),a		;80bd
	ld a,001h		;80c0
	ld (0e132h),a		;80c2
	ld (0e133h),a		;80c5
	ld de,0e2aeh		;80c8
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
L_80F5:
	jr L_80F5		;80f5

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
	call L_B249		;80f7
	call L_B26E		;80fa
	call L_B35B		;80fd
	call cuadro_del_juego		;8100
	ld hl,0e26ah		;8103
	ld de,01b00h		;8106
	ld bc,00054h		;8109
	call L_B1C3		;810c
	pop hl			;810f
	pop ix		;8110
	pop iy		;8112
	pop af			;8114
	pop bc			;8115
	pop de			;8116
	pop hl			;8117
	ex af,af'			;8118
	exx			;8119
	in a,(099h)		;811a
	ld (0e036h),a		;811c
	pop af			;811f
	pop bc			;8120
	pop de			;8121
	pop hl			;8122
	ei			;8123
	ret			;8124
L_8125:
	call L_9E0E		;8125
	ld a,(0e05fh)		;8128
	and 00fh		;812b
	ret z			;812d
	ld ix,0e2d5h		;812e
	ld hl,L_872F		;8132
	ld (ix+012h),l		;8135
	ld (ix+013h),h		;8138
	ld (ix+011h),001h		;813b
	xor a			;813f
	ld (0e21ch),a		;8140
	ld (0e34ah),a		;8143
	ld iy,0e346h		;8146
	ld (iy+002h),009h		;814a
	ld (iy+000h),001h		;814e
	call L_9E0E		;8152
	ld ix,0e2d5h		;8155
	ld (ix+011h),001h		;8159
	ld (ix+010h),001h		;815d
	ret			;8161
L_8162:
	ld a,007h		;8162
	call L_B32E		;8164
	ld hl,L_81A4		;8167
	ld (ix+012h),l		;816a
	ld (ix+013h),h		;816d
	res 5,(ix+000h)		;8170
	res 0,(ix+000h)		;8174
	res 0,(ix+006h)		;8178
	set 7,(ix+016h)		;817c
	ld iy,0e2a2h		;8180
	ld a,(0e1cdh)		;8184
	sub 00ah		;8187
	ld (iy+001h),a		;8189
	ld a,(0e1cch)		;818c
	add a,05ch		;818f
	ld (iy+000h),a		;8191
	bit 7,(ix+006h)		;8194
	jr z,L_819F		;8198
	ld (iy+002h),064h		;819a
	ret			;819e
L_819F:
	ld (iy+002h),040h		;819f
	ret			;81a3
L_81A4:
	ld a,(0e05fh)		;81a4
	bit 1,a		;81a7
	ret z			;81a9
	ld iy,0e2a2h		;81aa
	bit 3,a		;81ae
	jr nz,L_81BD		;81b0
	bit 2,a		;81b2
	jr nz,L_81CA		;81b4
	ld hl,0e345h		;81b6
	bit 7,(hl)		;81b9
	jr nz,L_81CA		;81bb
L_81BD:
	ld de,000c8h		;81bd
	res 7,(ix+006h)		;81c0
	ld (iy+002h),038h		;81c4
	jr L_81D5		;81c8
L_81CA:
	ld de,0ff38h		;81ca
	set 7,(ix+006h)		;81cd
	ld (iy+002h),05ch		;81d1
L_81D5:
	ld (ix+008h),d		;81d5
	ld (ix+007h),e		;81d8
	dec (iy+000h)		;81db
	ld hl,L_81F9		;81de
	ld (ix+012h),l		;81e1
	ld (ix+013h),h		;81e4
	res 7,(ix+016h)		;81e7
	set 0,(ix+000h)		;81eb
	set 0,(ix+006h)		;81ef
	ld a,009h		;81f3
	call L_B32E		;81f5
	ret			;81f8
L_81F9:
	set 6,(ix+016h)		;81f9
	ld hl,L_8820		;81fd
	ld (ix+012h),l		;8200
	ld (ix+013h),h		;8203
	res 5,(ix+000h)		;8206
	res 0,(ix+000h)		;820a
	set 0,(ix+006h)		;820e
	res 6,(ix+006h)		;8212
	ld (ix+010h),001h		;8216
	ld a,(0e1e2h)		;821a
	ld (ix+017h),a		;821d
	ret			;8220
L_8221:
	ld a,006h		;8221
	call L_B32E		;8223
	call L_8975		;8226
	ld (ix+011h),05ah		;8229
	ld hl,0e247h		;822d
	ld a,(hl)			;8230
	ld (0e189h),a		;8231
	ld (hl),001h		;8234
	ld hl,L_8240		;8236
	ld (ix+012h),l		;8239
	ld (ix+013h),h		;823c
	ret			;823f
L_8240:
	call L_89A8		;8240
L_8243:
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
	ld (iy+001h),020h		;826a
	ld a,01bh		;826e
	ld (0e184h),a		;8270
	xor a			;8273
	ld (0e185h),a		;8274
	ld hl,L_82C5		;8277
	ld (ix+012h),l		;827a
	ld (ix+013h),h		;827d
	bit 0,(ix+016h)		;8280
	jr nz,L_8295		;8284
	ld hl,0e293h		;8286
	ld (hl),08ah		;8289
	ld (iy+000h),085h		;828b
	ld a,0a4h		;828f
	ld (0e1cfh),a		;8291
	ret			;8294
L_8295:
	ld (iy+000h),040h		;8295
	ld a,06ch		;8299
	ld (0e1cfh),a		;829b
	ret			;829e
L_829F:
	set 0,(ix+000h)		;829f
	res 0,(ix+006h)		;82a3
	set 6,(ix+016h)		;82a7
	ld iy,0e2a2h		;82ab
	inc (iy+000h)		;82af
	ld a,01bh		;82b2
	ld (0e184h),a		;82b4
	xor a			;82b7
	ld (0e185h),a		;82b8
	ld hl,L_8314		;82bb
	ld (ix+012h),l		;82be
	ld (ix+013h),h		;82c1
	ret			;82c4
L_82C5:
	ld iy,0e2a2h		;82c5
	ld hl,0e184h		;82c9
	dec (hl)			;82cc
	jr z,L_82E7		;82cd
	ld a,006h		;82cf
	cp (hl)			;82d1
	jr nz,L_82D9		;82d2
	ld hl,0e2adh		;82d4
	ld (hl),00fh		;82d7
L_82D9:
	call L_8CAB		;82d9
	ld hl,0e2a5h		;82dc
	ld (hl),00ch		;82df
	ld hl,0e2a9h		;82e1
	ld (hl),006h		;82e4
	ret			;82e6
L_82E7:
	ld a,(0e189h)		;82e7
	ld hl,0e247h		;82ea
	ld (hl),a			;82ed
	ld hl,L_829F		;82ee
	ld (ix+012h),l		;82f1
	ld (ix+013h),h		;82f4
	res 0,(ix+000h)		;82f7
	ld hl,099efh		;82fb
	ld de,03be0h		;82fe
	ld bc,00020h		;8301
	call L_B1C3		;8304
	ld hl,099afh		;8307
	ld de,039a0h		;830a
	ld bc,00020h		;830d
	call L_B1C3		;8310
	ret			;8313
L_8314:
	ld iy,0e2a2h		;8314
	ld a,(0e1cfh)		;8318
	cp (iy+000h)		;831b
	ret nc			;831e
	ld (ix+010h),001h		;831f
	ld hl,L_872F		;8323
	ld (ix+012h),l		;8326
	ld (ix+013h),h		;8329
	res 0,(ix+000h)		;832c
	ld hl,08ec0h		;8330
	ld de,03d00h		;8333
	ld bc,00010h		;8336
	call L_B1C3		;8339
	ld hl,08ed0h		;833c
	ld de,03ac0h		;833f
	ld bc,00010h		;8342
	call L_B1C3		;8345
	ld hl,08ee0h		;8348
	ld de,03d10h		;834b
	ld bc,00010h		;834e
	call L_B1C3		;8351
	ld hl,08ef0h		;8354
	ld de,03ad0h		;8357
	ld bc,00010h		;835a
	call L_B1C3		;835d
	ret			;8360
L_8361:
	ld hl,0e185h		;8361
	ld (hl),01bh		;8364
	ld hl,0e184h		;8366
	ld (hl),001h		;8369
	ld iy,0e2a2h		;836b
	res 0,(ix+006h)		;836f
	res 0,(ix+000h)		;8373
	ld hl,0e247h		;8377
	ld a,(hl)			;837a
	ld (0e189h),a		;837b
	ld (hl),001h		;837e
	res 5,(ix+000h)		;8380
	ld hl,L_8393		;8384
	ld (ix+012h),l		;8387
	ld (ix+013h),h		;838a
	ld a,006h		;838d
	call L_B32E		;838f
	ret			;8392
L_8393:
	ld iy,0e2a2h		;8393
	ld hl,0e185h		;8397
	dec (hl)			;839a
	jr nz,L_83A0		;839b
	jp L_83B9		;839d
L_83A0:
	ld hl,0e184h		;83a0
	inc (hl)			;83a3
	call L_8BFB		;83a4
	inc (iy+000h)		;83a7
	ld a,07ah		;83aa
	cp (iy+000h)		;83ac
	ret nz			;83af
	ld iy,0e2aah		;83b0
	ld (iy+003h),000h		;83b4
	ret			;83b8
L_83B9:
	call L_8975		;83b9
	ld (ix+011h),05ah		;83bc
	ld hl,0e2a2h		;83c0
	ld (hl),000h		;83c3
	ld hl,0e2a9h		;83c5
	ld (hl),000h		;83c8
	ld hl,L_8240		;83ca
	ld (ix+012h),l		;83cd
	ld (ix+013h),h		;83d0
	ret			;83d3
L_83D4:
	ld a,(0e05fh)		;83d4
	and 003h		;83d7
	ret z			;83d9
	ld b,a			;83da
	ld a,(0e225h)		;83db
	cp 002h		;83de
	ret nc			;83e0
	ld iy,0e2a2h		;83e1
	ld a,(iy+001h)		;83e5
	cp 070h		;83e8
	ret c			;83ea
	cp 088h		;83eb
	ret nc			;83ed
	bit 0,(ix+016h)		;83ee
	jr z,L_8401		;83f2
	bit 1,b		;83f4
	ret z			;83f6
	res 0,(ix+016h)		;83f7
	ld (iy+000h),07fh		;83fb
	jr L_8408		;83ff
L_8401:
	bit 0,b		;8401
	ret z			;8403
	ld (iy+000h),0a3h		;8404
L_8408:
	ld hl,L_8447		;8408
	ld (ix+012h),l		;840b
	ld (ix+013h),h		;840e
	ld hl,08af9h		;8411
	ld (ix+00ch),l		;8414
	ld (ix+00dh),h		;8417
	ld (ix+00fh),000h		;841a
	ld (ix+00eh),001h		;841e
	ld (iy+001h),07ch		;8422
	ld (ix+010h),007h		;8426
	res 0,(ix+006h)		;842a
	res 0,(ix+000h)		;842e
	ld iy,0e292h		;8432
	ld (iy+001h),07ch		;8436
	ld (iy+000h),07ah		;843a
	ld (iy+002h),000h		;843e
	ld (iy+003h),00bh		;8442
	ret			;8446
L_8447:
	ld iy,0e2a2h		;8447
	res 5,(ix+000h)		;844b
	ld a,(iy+000h)		;844f
	cp 083h		;8452
	call c,L_84EF		;8454
	ld hl,0e05fh		;8457
	cp 07bh		;845a
	jr z,L_849A		;845c
	bit 0,(hl)		;845e
	jr z,L_846C		;8460
	sub 004h		;8462
	ld (iy+000h),a		;8464
	set 5,(ix+000h)		;8467
	ret			;846b
L_846C:
	bit 1,(hl)		;846c
	ret z			;846e
	ld a,(iy+000h)		;846f
	cp 0a3h		;8472
	jr z,L_8483		;8474
	ld a,004h		;8476
	add a,(iy+000h)		;8478
	ld (iy+000h),a		;847b
	set 5,(ix+000h)		;847e
	ret			;8482
L_8483:
	ld (ix+010h),001h		;8483
	ld (iy+000h),0a5h		;8487
	ld a,0a5h		;848b
	ld (0e1cfh),a		;848d
	ld hl,L_872F		;8490
	ld (ix+012h),l		;8493
	ld (ix+013h),h		;8496
	ret			;8499
L_849A:
	ld a,(hl)			;849a
	and 00ch		;849b
	jr z,L_846C		;849d
	set 6,(ix+016h)		;849f
	ld b,a			;84a3
	ld a,002h		;84a4
	call L_B32E		;84a6
	ld a,b			;84a9
	ld hl,L_8820		;84aa
	ld (ix+012h),l		;84ad
	ld (ix+013h),h		;84b0
	res 5,(ix+000h)		;84b3
	res 0,(ix+000h)		;84b7
	set 0,(ix+006h)		;84bb
	set 0,(ix+016h)		;84bf
	ld (ix+010h),001h		;84c3
	ld (iy+000h),06dh		;84c7
	ld (ix+017h),01fh		;84cb
	bit 3,a		;84cf
	jr nz,L_84E1		;84d1
	ld hl,0ff38h		;84d3
	ld (ix+007h),l		;84d6
	ld (ix+008h),h		;84d9
	set 7,(ix+006h)		;84dc
	ret			;84e0
L_84E1:
	ld hl,000c8h		;84e1
	ld (ix+007h),l		;84e4
	ld (ix+008h),h		;84e7
	res 7,(ix+006h)		;84ea
	ret			;84ee
L_84EF:
	ld a,(iy+001h)		;84ef
	add a,008h		;84f2
	ld hl,0e232h		;84f4
	ld b,003h		;84f7
L_84F9:
	inc hl			;84f9
	cp (hl)			;84fa
	inc hl			;84fb
	jr c,L_8522		;84fc
	cp (hl)			;84fe
	jr nc,L_8522		;84ff
	ld a,00ah		;8501
	call L_B32E		;8503
	ld a,005h		;8506
	call L_9D7C		;8508
	ld a,005h		;850b
	call L_9D7C		;850d
	ld iy,0e2a2h		;8510
	ld ix,0e2d5h		;8514
	ld a,087h		;8518
	ld (iy+000h),a		;851a
	ld (ix+011h),001h		;851d
	ret			;8521
L_8522:
	inc hl			;8522
	djnz L_84F9		;8523
	ld a,(iy+000h)		;8525
	ret			;8528
L_8529:
	ld iy,0e2a2h		;8529
	ld a,(iy+001h)		;852d
	add a,008h		;8530
	bit 7,(ix+006h)		;8532
	jr z,L_853A		;8536
	sub 001h		;8538
L_853A:
	ld hl,0e229h		;853a
	ld b,007h		;853d
	bit 0,(ix+016h)		;853f
	jr nz,L_854A		;8543
	ld hl,0e241h		;8545
	ld b,002h		;8548
L_854A:
	ld c,(hl)			;854a
	inc hl			;854b
	cp (hl)			;854c
	inc hl			;854d
	jr c,L_8583		;854e
	cp (hl)			;8550
	jr nc,L_8583		;8551
	ld b,a			;8553
	ld a,c			;8554
	cp 005h		;8555
	jr nc,L_857B		;8557
	cp 001h		;8559
	jr z,L_857B		;855b
	dec hl			;855d
	ld a,(hl)			;855e
	add a,003h		;855f
	sub b			;8561
	jr c,L_856C		;8562
	add a,(iy+001h)		;8564
	ld (iy+001h),a		;8567
	jr L_857B		;856a
L_856C:
	inc hl			;856c
	ld a,b			;856d
	add a,004h		;856e
	sub (hl)			;8570
	jr c,L_857B		;8571
	ld b,a			;8573
	ld a,(iy+001h)		;8574
	sub b			;8577
	ld (iy+001h),a		;8578
L_857B:
	ld a,c			;857b
	cp 00ah		;857c
	jr nz,L_8588		;857e
	jp L_85EF		;8580
L_8583:
	inc hl			;8583
	djnz L_854A		;8584
	xor a			;8586
	ret			;8587
L_8588:
	ret			;8588
L_8589:
	ld iy,0e2a2h		;8589
	ld a,(iy+001h)		;858d
	add a,008h		;8590
	bit 7,(ix+006h)		;8592
	jr z,L_859A		;8596
	sub 001h		;8598
L_859A:
	ld hl,0e23bh		;859a
	ld b,002h		;859d
	bit 0,(ix+016h)		;859f
	jr nz,L_85A8		;85a3
	ld hl,0e241h		;85a5
L_85A8:
	ld c,(hl)			;85a8
	inc hl			;85a9
	cp (hl)			;85aa
	inc hl			;85ab
	jr c,L_85D4		;85ac
	cp (hl)			;85ae
	jr nc,L_85D4		;85af
	ld b,a			;85b1
	ld a,005h		;85b2
	cp c			;85b4
	jr z,L_85D9		;85b5
	ld a,00ah		;85b7
	cp c			;85b9
	jr z,L_85EF		;85ba
	ld a,(0e1cfh)		;85bc
	inc a			;85bf
	sub (iy+000h)		;85c0
	cp 002h		;85c3
	jr nc,L_85D7		;85c5
	ld a,(0e2a2h)		;85c7
	cp 06dh		;85ca
	jr nc,L_85D2		;85cc
	inc a			;85ce
	ld (0e2a2h),a		;85cf
L_85D2:
	ld a,c			;85d2
	ret			;85d3
L_85D4:
	inc hl			;85d4
	djnz L_85A8		;85d5
L_85D7:
	xor a			;85d7
	ret			;85d8
L_85D9:
	ld hl,0e2a2h		;85d9
	ld a,(0e1cch)		;85dc
	sub 007h		;85df
	cp (hl)			;85e1
	jr nc,L_85D7		;85e2
	ld a,(0e1cch)		;85e4
	sub 014h		;85e7
	cp (hl)			;85e9
	jr c,L_85D7		;85ea
	ld a,005h		;85ec
	ret			;85ee
L_85EF:
	ld a,(ix+007h)		;85ef
	or a			;85f2
	ret z			;85f3
	xor a			;85f4
	bit 2,(ix+016h)		;85f5
	jr nz,L_8600		;85f9
	ld a,00ah		;85fb
	call L_B32E		;85fd
L_8600:
	ld (ix+011h),002h		;8600
	ld ix,0e2d5h		;8604
	ld iy,0e2a2h		;8608
	set 2,(ix+016h)		;860c
	ld a,(ix+008h)		;8610
	cpl			;8613
	ld d,a			;8614
	ld a,(ix+007h)		;8615
	cpl			;8618
	ld e,a			;8619
	inc de			;861a
	ld (ix+008h),d		;861b
	ld (ix+007h),e		;861e
	ld h,(iy+001h)		;8621
	ld l,(ix+00bh)		;8624
	add hl,de			;8627
	add hl,de			;8628
	add hl,de			;8629
	ld (iy+001h),h		;862a
	ld (ix+00bh),l		;862d
	xor a			;8630
	bit 1,(ix+016h)		;8631
	ret z			;8635
	ld a,(ix+006h)		;8636
	xor 080h		;8639
	ld (ix+006h),a		;863b
	xor a			;863e
	ret			;863f
L_8640:
	ld iy,0e2a2h		;8640
	ld hl,L_8660		;8644
	ld (ix+012h),l		;8647
	ld (ix+013h),h		;864a
	ld (iy+000h),072h		;864d
	res 5,(ix+000h)		;8651
	ld a,020h		;8655
	ld (0e268h),a		;8657
	ld a,004h		;865a
	call L_B32E		;865c
	ret			;865f
L_8660:
	ld a,(0e268h)		;8660
	dec a			;8663
	ld (0e268h),a		;8664
	jp nz,L_8674		;8667
	ld a,020h		;866a
	ld (0e268h),a		;866c
	ld a,004h		;866f
	call L_B32E		;8671
L_8674:
	ld a,005h		;8674
	call L_9D7C		;8676
	ld ix,0e2d5h		;8679
	res 0,(ix+006h)		;867d
	ld iy,0e2a2h		;8681
	bit 7,(ix+006h)		;8685
	jr z,L_8691		;8689
	ld (iy+002h),05ch		;868b
	jr L_8695		;868f
L_8691:
	ld (iy+002h),038h		;8691
L_8695:
	ld a,(0e224h)		;8695
	cp 004h		;8698
	jr c,L_86CF		;869a
	ld a,(0e05fh)		;869c
	and 00ch		;869f
	jr z,L_86CF		;86a1
	bit 2,a		;86a3
	jr z,L_86BA		;86a5
	set 7,(ix+006h)		;86a7
	set 0,(ix+006h)		;86ab
	ld de,0ff40h		;86af
	ld (ix+008h),d		;86b2
	ld (ix+007h),e		;86b5
	jr L_86CF		;86b8
L_86BA:
	bit 3,a		;86ba
	jr z,L_86CF		;86bc
	ld de,000c0h		;86be
	ld (ix+008h),d		;86c1
	ld (ix+007h),e		;86c4
	res 7,(ix+006h)		;86c7
	set 0,(ix+006h)		;86cb
L_86CF:
	call L_8529		;86cf
	cp 001h		;86d2
	ret z			;86d4
	ld hl,L_872F		;86d5
	ld (ix+012h),l		;86d8
	ld (ix+013h),h		;86db
	ld (iy+000h),06dh		;86de
	ret			;86e2
L_86E3:
	ld iy,0e2a2h		;86e3
	ld a,(iy+000h)		;86e7
	cp 0a5h		;86ea
	jr c,L_8705		;86ec
	res 0,(ix+000h)		;86ee
	set 6,(ix+016h)		;86f2
	ld hl,L_872F		;86f6
	ld (ix+012h),l		;86f9
	ld (ix+013h),h		;86fc
	ld a,06dh		;86ff
	ld (0e1cfh),a		;8701
	ret			;8704
L_8705:
	cp 090h		;8705
	jr c,L_8719		;8707
	bit 7,(ix+006h)		;8709
	jr z,L_8714		;870d
	ld (iy+002h),05ch		;870f
	ret			;8713
L_8714:
	ld (iy+002h),038h		;8714
	ret			;8718
L_8719:
	ld a,(iy+000h)		;8719
	ld hl,0e185h		;871c
	bit 7,(ix+006h)		;871f
	jr z,L_872A		;8723
	ld (iy+002h),058h		;8725
	ret			;8729
L_872A:
	ld (iy+002h),034h		;872a
	ret			;872e
L_872F:
	call L_88ED		;872f
	call L_87DD		;8732
	call L_83D4		;8735
	call L_8529		;8738
L_873B:
	or a			;873b
	ret z			;873c
	sla a		;873d
	ld e,a			;873f
	ld d,000h		;8740
	ld hl,08aa0h		;8742
	add hl,de			;8745
	ld e,(hl)			;8746
	inc hl			;8747
	ld d,(hl)			;8748
	ex de,hl			;8749
	jp (hl)			;874a
L_874B:
	ld hl,0e247h		;874b
	ld (hl),001h		;874e
	ret			;8750
L_8751:
	ld hl,L_86E3		;8751
	ld (ix+012h),l		;8754
	ld (ix+013h),h		;8757
	set 0,(ix+000h)		;875a
	res 0,(ix+006h)		;875e
	res 0,(ix+016h)		;8762
	res 5,(ix+000h)		;8766
	ld hl,0e2a3h		;876a
	ld a,(hl)			;876d
	ld iy,0e292h		;876e
	ld (iy+001h),a		;8772
	ld (iy+000h),07ah		;8775
	ld (iy+002h),000h		;8779
	ld (iy+003h),00bh		;877d
	ld a,003h		;8781
	call L_9D7C		;8783
	ld a,005h		;8786
	call L_B32E		;8788
	ret			;878b
L_878C:
	ld a,008h		;878c
	call L_B32E		;878e
	ld a,(0e188h)		;8791
	call L_9D9F		;8794
	ld hl,0e291h		;8797
	ld (hl),000h		;879a
	push ix		;879c
	ld ix,0e23bh		;879e
	ld (ix+000h),000h		;87a2
	ld a,000h		;87a6
	sub 000h		;87a8
	ld (ix+001h),a		;87aa
	ld a,000h		;87ad
	add a,000h		;87af
	ld (ix+002h),a		;87b1
	pop ix		;87b4
	ld hl,0b08eh		;87b6
	call L_9FE6		;87b9
	ld a,(0e186h)		;87bc
	ld l,a			;87bf
	ld a,(0e187h)		;87c0
	ld h,a			;87c3
	ld a,(0e223h)		;87c4
	cp 000h		;87c7
	jr nz,L_87CF		;87c9
	ld a,001h		;87cb
	jr L_87D6		;87cd
L_87CF:
	ld b,a			;87cf
	inc b			;87d0
	xor a			;87d1
	scf			;87d2
L_87D3:
	rla			;87d3
	djnz L_87D3		;87d4
L_87D6:
	or (hl)			;87d6
	ld (hl),a			;87d7
	ld ix,0e2d5h		;87d8
	ret			;87dc
L_87DD:
	ld a,(0e05fh)		;87dd
	and 030h		;87e0
	jr nz,L_87E9		;87e2
	res 6,(ix+016h)		;87e4
	ret			;87e8
L_87E9:
	bit 6,(ix+016h)		;87e9
	ret nz			;87ed
	set 6,(ix+016h)		;87ee
	ld hl,L_8820		;87f2
	ld (ix+012h),l		;87f5
	ld (ix+013h),h		;87f8
	res 5,(ix+000h)		;87fb
	set 1,(ix+016h)		;87ff
	set 6,(ix+006h)		;8803
	ld (ix+017h),01fh		;8807
	ld a,002h		;880b
	call L_B32E		;880d
	bit 7,(ix+006h)		;8810
	jr z,L_881B		;8814
	ld (iy+002h),058h		;8816
	ret			;881a
L_881B:
	ld (iy+002h),034h		;881b
	ret			;881f
L_8820:
	call L_8886		;8820
	ld iy,0e2a2h		;8823
	ld b,(ix+017h)		;8827
	ld hl,08ab6h		;882a
	xor a			;882d
	cp b			;882e
	jr z,L_885F		;882f
L_8831:
	inc hl			;8831
	djnz L_8831		;8832
	ld a,(hl)			;8834
	add a,(iy+000h)		;8835
	ld (iy+000h),a		;8838
	res 5,(ix+000h)		;883b
	bit 7,(ix+006h)		;883f
	jr z,L_884B		;8843
	ld (iy+002h),05ch		;8845
	jr L_884F		;8849
L_884B:
	ld (iy+002h),038h		;884b
L_884F:
	dec (ix+017h)		;884f
	jr z,L_885F		;8852
	bit 6,(ix+006h)		;8854
	ret z			;8858
	call L_8589		;8859
	jp L_873B		;885c
L_885F:
	call L_8589		;885f
	ld hl,L_872F		;8862
	ld (ix+012h),l		;8865
	ld (ix+013h),h		;8868
	ld (ix+00fh),000h		;886b
	ld (ix+00eh),001h		;886f
	res 1,(ix+016h)		;8873
	res 6,(ix+006h)		;8877
	bit 0,(ix+016h)		;887b
	ret z			;887f
	ld a,06dh		;8880
	ld (0e2a2h),a		;8882
	ret			;8885
L_8886:
	ld ix,0e2d5h		;8886
	ld iy,0e2a2h		;888a
	ld a,(ix+007h)		;888e
	or a			;8891
	ret nz			;8892
	ld a,(ix+017h)		;8893
	cp 01dh		;8896
	ret c			;8898
	ld a,(0e05fh)		;8899
	and 00ch		;889c
	ret z			;889e
	ld de,000c8h		;889f
	res 7,(ix+006h)		;88a2
	ld (iy+002h),038h		;88a6
	bit 2,a		;88aa
	jr z,L_88B9		;88ac
	ld de,0ff38h		;88ae
	set 7,(ix+006h)		;88b1
	ld (iy+002h),05ch		;88b5
L_88B9:
	ld (ix+007h),e		;88b9
	ld (ix+008h),d		;88bc
	set 0,(ix+006h)		;88bf
	ld a,01fh		;88c3
	sub (ix+017h)		;88c5
	ld b,a			;88c8
	xor a			;88c9
	cp b			;88ca
	inc b			;88cb
	ret z			;88cc
	ld iy,0e2a3h		;88cd
	ld ix,0e2dbh		;88d1
L_88D5:
	call L_9B1F		;88d5
	djnz L_88D5		;88d8
	ld ix,0e2d5h		;88da
	ret			;88de
L_88DF:
	ld hl,0e1e3h		;88df
	dec (hl)			;88e2
	ret nz			;88e3
	ld a,(0e1e5h)		;88e4
	ld (hl),a			;88e7
	ld a,003h		;88e8
	jp L_B32E		;88ea
L_88ED:
	ld iy,0e2a2h		;88ed
	ld hl,0e05fh		;88f1
	bit 2,(hl)		;88f4
	jr z,L_891E		;88f6
	res 2,(ix+016h)		;88f8
	call L_88DF		;88fc
	set 7,(ix+006h)		;88ff
	ld de,08aedh		;8903
	ld (ix+00ch),e		;8906
	ld (ix+00dh),d		;8909
	set 5,(ix+000h)		;890c
	set 0,(ix+006h)		;8910
	ld de,0ff38h		;8914
	ld (ix+008h),d		;8917
	ld (ix+007h),e		;891a
	ret			;891d
L_891E:
	bit 3,(hl)		;891e
	jr z,L_8948		;8920
	call L_88DF		;8922
	res 2,(ix+016h)		;8925
	res 7,(ix+006h)		;8929
	ld de,08ae1h		;892d
	ld (ix+00ch),e		;8930
	ld (ix+00dh),d		;8933
	set 5,(ix+000h)		;8936
	set 0,(ix+006h)		;893a
	ld de,000c8h		;893e
	ld (ix+008h),d		;8941
	ld (ix+007h),e		;8944
	ret			;8947
L_8948:
	res 5,(ix+000h)		;8948
	res 0,(ix+006h)		;894c
	ld (ix+00fh),000h		;8950
	ld (ix+00eh),001h		;8954
	ld de,00000h		;8958
	ld (ix+008h),d		;895b
	ld (ix+007h),e		;895e
	bit 7,(ix+006h)		;8961
	ld iy,0e2a2h		;8965
	jr z,L_8970		;8969
	ld (iy+002h),058h		;896b
	ret			;896f
L_8970:
	ld (iy+002h),034h		;8970
	ret			;8974
L_8975:
	ld a,(0e012h)		;8975
	sub 001h		;8978
	ld (0e012h),a		;897a
	ret nc			;897d
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
	pop de			;89a6
	ret			;89a7
L_89A8:
	ld a,(0e012h)		;89a8
	ld hl,08a76h		;89ab
	ld iy,0e29ah		;89ae
	ld (iy+003h),000h		;89b2
	ld iy,0e29eh		;89b6
	ld (iy+003h),000h		;89ba
	or a			;89be
	jr z,L_89DA		;89bf
	ld hl,08a7ch		;89c1
	ld iy,0e29ah		;89c4
	ld (iy+003h),001h		;89c8
	dec a			;89cc
	jr z,L_89DA		;89cd
	ld hl,08a82h		;89cf
	ld iy,0e29eh		;89d2
	ld (iy+003h),001h		;89d6
L_89DA:
	ld de,01843h		;89da
	ld bc,00003h		;89dd
	push hl			;89e0
	call L_B1C3		;89e1
	pop hl			;89e4
	ld de,00003h		;89e5
	add hl,de			;89e8
	ld de,01863h		;89e9
	ld bc,00003h		;89ec
	call L_B1C3		;89ef
	ret			;89f2
L_89F3:
	ld hl,0e229h		;89f3
	ld de,0e22ah		;89f6
	ld (hl),000h		;89f9
	ld bc,0001dh		;89fb
	ldir		;89fe
	ret			;8a00
L_8A01:
	ld hl,0b0f0h		;8a01
	ld de,02000h		;8a04
	ld bc,00020h		;8a07
	call L_B1C3		;8a0a
	ld hl,0e247h		;8a0d
	ld (hl),000h		;8a10
	ld a,06ch		;8a12
	ld (0e1cfh),a		;8a14
	call L_8AFF		;8a17
	ld de,0e1d0h		;8a1a
	ld hl,08a69h		;8a1d
	ld bc,00006h		;8a20
	ldir		;8a23
	ld de,0e1d6h		;8a25
	ld hl,08a6fh		;8a28
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
	call L_B1C3		;8a4f
	ld a,002h		;8a52
	ld (0e012h),a		;8a54
	call L_89A8		;8a57
	call L_9D54		;8a5a
	ld a,03ch		;8a5d
	ld (0e25ah),a		;8a5f
	ld (0e25bh),a		;8a62
	ld (0e25ch),a		;8a65
	ret			;8a68

; ----------------------------------------------------------------------
; DATOS inicializador_e1d0: Seis bytes que 0x8A23 copia con LDIR a 0xE1D0
;   0x8a69..0x8a6f  (6 bytes)
; DATOS inicializador_e1d6: Seis bytes que 0x8A2E copia a 0xE1D6
;   0x8a6f..0x8a75  (6 bytes)
; DATOS fila_tiles_c3: Un 0x00 y dieciocho tiles C3/C5/C6: la fila que 0x89AB (ld hl,08A76h) usa sobre las estructuras de 0xE29A/0xE29E
;   0x8a75..0x8a88  (19 bytes)
; DATOS inicializador_e29a: Cuatro bytes que 0x8A39 copia a 0xE29A
;   0x8a88..0x8a8c  (4 bytes)
; DATOS inicializador_e29e: Cuatro bytes que 0x8A44 copia a 0xE29E
;   0x8a8c..0x8a90  (4 bytes)
; DATOS inicializador_e2ae: Cuatro bytes que 0x80D1 (en el arranque) copia a 0xE2AE
;   0x8a90..0x8a94  (4 bytes)
; DATOS inicializador_e2b2: Cuatro bytes que 0x80DC copia a 0xE2B2
;   0x8a94..0x8a98  (4 bytes)
; DATOS inicializador_e2b6: Cuatro bytes que 0x80E7 copia a 0xE2B6
;   0x8a98..0x8a9c  (4 bytes)
; DATOS inicializador_e2ba: Cuatro bytes que 0x80F2 copia a 0xE2BA
;   0x8a9c..0x8aa0  (4 bytes)
; DATOS tabla_del_despachador_874a: Once punteros de palabra. El despachador de 0x873B los consume con el indice en A (sla / add hl / jp (hl)); con A=0 vuelve sin saltar. En 0x8AB6 las palabras dejan de ser punteros a ROM y empiezan los pares 0x0100/0x0101 de la tabla siguiente
;   0x8aa0..0x8ab6  (22 bytes)
; DATOS tabla_de_incrementos: Setenta y tres bytes de valores 0x00/0x01/0xFF: el manejador 0x8820 los indexa con el contador IX+0x17 (bucle inc hl/djnz en 0x8831) y SUMA el valor a IY+0x00, o sea una curva de desplazamiento paso a paso
;   0x8ab6..0x8aff  (73 bytes)
; ----------------------------------------------------------------------
	defb 0bah,0b8h,0c2h,0b8h,0b8h,03ch,000h,000h,002h,000h,000h,000h,000h,0c3h,0c3h,0c3h	; 8a69  .....<..........
	defb 0c3h,0c3h,0c3h,0c5h,0c3h,0c3h,0c6h,0c3h,0c3h,0c5h,0c3h,0c5h,0c6h,0c3h,0c6h,00fh	; 8a79  ................
	defb 011h,070h,001h,00fh,021h,070h,001h,0b3h,00eh,010h,000h,0b3h,00eh,014h,000h,0b3h	; 8a89  .p..!p..........
	defb 00eh,018h,000h,0b3h,00eh,01ch,000h,04bh,087h,040h,086h,051h,087h,061h,083h,061h	; 8a99  .......K.@.Q.a.a
	defb 083h,062h,081h,021h,082h,04bh,087h,08ch,087h,021h,082h,0efh,085h,000h,001h,001h	; 8aa9  .b.!.K...!......
	defb 001h,001h,001h,001h,001h,000h,001h,000h,000h,001h,000h,000h,000h,001h,0ffh,000h	; 8ab9  ................
	defb 000h,000h,0ffh,000h,0ffh,000h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,000h,000h,003h	; 8ac9  ................
	defb 04ch,05ch,076h,083h,09ch,0adh,000h,000h,003h,020h,003h,024h,003h,028h,003h,02ch	; 8ad9  L\v...... .$.(.,
	defb 003h,030h,000h,000h,003h,044h,003h,048h,003h,04ch,003h,050h,003h,054h,000h,000h	; 8ae9  .0...D.H.L.P.T..
	defb 001h,03ch,001h,060h,000h,000h	; 8af9  .<.`..

; ======================================================================
; CODIGO 0x8aff..0x8e1b  (796 bytes)
; ======================================================================


L_8AFF:
	ld hl,01800h		;8aff
	ld bc,00300h		;8b02
	ld a,02ch		;8b05
	call L_B1A7		;8b07
	ld hl,01800h		;8b0a
	ld bc,000e0h		;8b0d
	ld a,038h		;8b10
	call L_B1A7		;8b12
	ld hl,0909eh		;8b15
	call L_B142		;8b18
	ld hl,0915bh		;8b1b
	call L_B142		;8b1e
	ld bc,00004h		;8b21
	ld hl,00080h		;8b24
	ld de,000a0h		;8b27
	call L_B1D1		;8b2a
	ld bc,00005h		;8b2d
	ld hl,002c0h		;8b30
	ld de,002f8h		;8b33
	call L_B1D1		;8b36
	ld bc,00007h		;8b39
	ld hl,002c0h		;8b3c
	ld de,00320h		;8b3f
	call L_B20B		;8b42
	ld bc,00005h		;8b45
	ld hl,00320h		;8b48
	ld de,00358h		;8b4b
	call L_B1D1		;8b4e
	ld hl,09090h		;8b51
	ld de,01ae2h		;8b54
	ld bc,0000eh		;8b57
	call L_B1C3		;8b5a
	ret			;8b5d
L_8B5E:
	ld hl,0939dh		;8b5e
	call L_B142		;8b61
	ld b,009h		;8b64
	ld hl,00044h		;8b66
	ld de,00020h		;8b69
	call L_8BC1		;8b6c
	ld hl,09473h		;8b6f
	call L_B142		;8b72
	ld b,009h		;8b75
	ld hl,0008ch		;8b77
	ld de,00068h		;8b7a
	call L_8BC1		;8b7d
	ld hl,0956ah		;8b80
	call L_B142		;8b83
	ld b,009h		;8b86
	ld hl,000d4h		;8b88
	ld de,000b0h		;8b8b
	call L_8BC1		;8b8e
	ret			;8b91
L_8B92:
	ld hl,0e138h		;8b92
	ld a,(0e185h)		;8b95
	ld e,a			;8b98
	ld d,000h		;8b99
	add hl,de			;8b9b
	ld a,(0e184h)		;8b9c
	ld b,a			;8b9f
	xor a			;8ba0
	cp b			;8ba1
	jr z,L_8BA9		;8ba2
L_8BA4:
	ld (hl),000h		;8ba4
	inc hl			;8ba6
	djnz L_8BA4		;8ba7
L_8BA9:
	ld hl,0e15eh		;8ba9
	ld a,(0e185h)		;8bac
	ld e,a			;8baf
	ld d,000h		;8bb0
	add hl,de			;8bb2
	ld a,(0e184h)		;8bb3
	ld b,a			;8bb6
	xor a			;8bb7
	cp b			;8bb8
	jr z,L_8BC0		;8bb9
L_8BBB:
	ld (hl),000h		;8bbb
	inc hl			;8bbd
	djnz L_8BBB		;8bbe
L_8BC0:
	ret			;8bc0
L_8BC1:
	push bc			;8bc1
	ld bc,03800h		;8bc2
	add hl,hl			;8bc5
	add hl,hl			;8bc6
	add hl,hl			;8bc7
	add hl,bc			;8bc8
	ex de,hl			;8bc9
	add hl,hl			;8bca
	add hl,hl			;8bcb
	add hl,hl			;8bcc
	add hl,bc			;8bcd
	ex de,hl			;8bce
	pop bc			;8bcf
L_8BD0:
	push bc			;8bd0
	push hl			;8bd1
	push de			;8bd2
	ld bc,00010h		;8bd3
	add hl,bc			;8bd6
	ld bc,00002h		;8bd7
	ex de,hl			;8bda
	call L_B1D1		;8bdb
	pop hl			;8bde
	ld bc,00010h		;8bdf
	add hl,bc			;8be2
	ex de,hl			;8be3
	pop hl			;8be4
	ld bc,00002h		;8be5
	push hl			;8be8
	push de			;8be9
	ex de,hl			;8bea
	call L_B1D1		;8beb
	pop hl			;8bee
	ld bc,00010h		;8bef
	add hl,bc			;8bf2
	ex de,hl			;8bf3
	pop hl			;8bf4
	add hl,bc			;8bf5
	add hl,bc			;8bf6
	pop bc			;8bf7
	djnz L_8BD0		;8bf8
	ret			;8bfa
L_8BFB:
	bit 7,(ix+006h)		;8bfb
	jr nz,L_8C19		;8bff
	ld de,0e15eh		;8c01
	ld hl,08e60h		;8c04
	ld bc,00020h		;8c07
	ldir		;8c0a
	ld de,0e138h		;8c0c
	ld hl,08e40h		;8c0f
	ld bc,00020h		;8c12
	ldir		;8c15
	jr L_8C2F		;8c17
L_8C19:
	ld de,0e15eh		;8c19
	ld hl,08ee0h		;8c1c
	ld bc,00020h		;8c1f
	ldir		;8c22
	ld de,0e138h		;8c24
	ld hl,08ec0h		;8c27
	ld bc,00020h		;8c2a
	ldir		;8c2d
L_8C2F:
	call L_8B92		;8c2f
	push iy		;8c32
	push ix		;8c34
	bit 7,(ix+006h)		;8c36
	jr nz,L_8C72		;8c3a
	ld (iy+002h),034h		;8c3c
	ld hl,0e138h		;8c40
	ld de,03be0h		;8c43
	ld bc,00010h		;8c46
	call L_B1C3		;8c49
	ld hl,0e148h		;8c4c
	ld de,039a0h		;8c4f
	ld bc,00010h		;8c52
	call L_B1C3		;8c55
	ld hl,0e15eh		;8c58
	ld de,03bf0h		;8c5b
	ld bc,00010h		;8c5e
	call L_B1C3		;8c61
	ld hl,0e16eh		;8c64
	ld de,039b0h		;8c67
	ld bc,00010h		;8c6a
	call L_B1C3		;8c6d
	jr L_8CA6		;8c70
L_8C72:
	ld (iy+002h),058h		;8c72
	ld hl,0e138h		;8c76
	ld de,03d00h		;8c79
	ld bc,00010h		;8c7c
	call L_B1C3		;8c7f
	ld hl,0e148h		;8c82
	ld de,03ac0h		;8c85
	ld bc,00010h		;8c88
	call L_B1C3		;8c8b
	ld hl,0e15eh		;8c8e
	ld de,03d10h		;8c91
	ld bc,00010h		;8c94
	call L_B1C3		;8c97
	ld hl,0e16eh		;8c9a
	ld de,03ad0h		;8c9d
	ld bc,00010h		;8ca0
	call L_B1C3		;8ca3
L_8CA6:
	pop ix		;8ca6
	pop iy		;8ca8
	ret			;8caa
L_8CAB:
	ld de,0e15eh		;8cab
	ld hl,08ea0h		;8cae
	ld bc,00020h		;8cb1
	ldir		;8cb4
	ld de,0e138h		;8cb6
	ld hl,08e80h		;8cb9
	ld bc,00020h		;8cbc
	ldir		;8cbf
	call L_8B92		;8cc1
	push iy		;8cc4
	push ix		;8cc6
	ld (iy+002h),038h		;8cc8
	ld hl,0e138h		;8ccc
	ld de,03c00h		;8ccf
	ld bc,00010h		;8cd2
	call L_B1C3		;8cd5
	ld hl,0e148h		;8cd8
	ld de,039c0h		;8cdb
	ld bc,00010h		;8cde
	call L_B1C3		;8ce1
	ld hl,0e15eh		;8ce4
	ld de,03c10h		;8ce7
	ld bc,00010h		;8cea
	call L_B1C3		;8ced
	ld hl,0e16eh		;8cf0
	ld de,039d0h		;8cf3
	ld bc,00010h		;8cf6
	call L_B1C3		;8cf9
	pop ix		;8cfc
	pop iy		;8cfe
	ret			;8d00
L_8D01:
	ld a,(0e225h)		;8d01
	cp 001h		;8d04
	jr z,L_8D0F		;8d06
	ld hl,08faah		;8d08
	call L_9FE6		;8d0b
	ret			;8d0e
L_8D0F:
	ld hl,08f48h		;8d0f
	call L_9FE6		;8d12
	push ix		;8d15
	ld ix,0e229h		;8d17
	ld (ix+000h),002h		;8d1b
	ld a,054h		;8d1f
	sub 000h		;8d21
	ld (ix+001h),a		;8d23
	ld a,054h		;8d26
	add a,011h		;8d28
	ld (ix+002h),a		;8d2a
	pop ix		;8d2d
	push ix		;8d2f
	ld ix,0e22fh		;8d31
	ld (ix+000h),002h		;8d35
	ld a,0a3h		;8d39
	sub 000h		;8d3b
	ld (ix+001h),a		;8d3d
	ld a,0a3h		;8d40
	add a,011h		;8d42
	ld (ix+002h),a		;8d44
	pop ix		;8d47
	ret			;8d49
L_8D4A:
	ld hl,08f06h		;8d4a
	call L_9FE6		;8d4d
	ld hl,0904eh		;8d50
	call L_9FE6		;8d53
	ld hl,0b08eh		;8d56
	call L_9FE6		;8d59
	ret			;8d5c
L_8D5D:
	ld hl,08f06h		;8d5d
	call L_9FE6		;8d60
	ld hl,0900ch		;8d63
	call L_9FE6		;8d66
	ld hl,0b08eh		;8d69
	call L_9FE6		;8d6c
	ret			;8d6f
L_8D70:
	push hl			;8d70
	ld de,0188fh		;8d71
	ld bc,00071h		;8d74
	call L_B1C3		;8d77
	pop hl			;8d7a
	ld de,00071h		;8d7b
	add hl,de			;8d7e
	ld de,01900h		;8d7f
	ld b,006h		;8d82
L_8D84:
	push bc			;8d84
	push hl			;8d85
	push de			;8d86
	ld bc,00020h		;8d87
	call L_B1C3		;8d8a
	pop hl			;8d8d
	ld de,00020h		;8d8e
	add hl,de			;8d91
	ex de,hl			;8d92
	pop hl			;8d93
	pop bc			;8d94
	djnz L_8D84		;8d95
	ld de,00020h		;8d97
	add hl,de			;8d9a
	ld b,005h		;8d9b
	ld de,01980h		;8d9d
L_8DA0:
	push bc			;8da0
	push hl			;8da1
	ld c,(hl)			;8da2
	ld b,000h		;8da3
	push bc			;8da5
	push de			;8da6
	ld hl,08e1bh		;8da7
	add hl,bc			;8daa
	call L_B1C3		;8dab
	pop hl			;8dae
	pop de			;8daf
	add hl,de			;8db0
	ex de,hl			;8db1
	inc de			;8db2
	pop hl			;8db3
	inc hl			;8db4
	pop bc			;8db5
	djnz L_8DA0		;8db6
	or a			;8db8
	ld de,00005h		;8db9
	sbc hl,de		;8dbc
	ld b,005h		;8dbe
	ld de,019a0h		;8dc0
L_8DC3:
	push bc			;8dc3
	push hl			;8dc4
	ld c,(hl)			;8dc5
	ld b,000h		;8dc6
	push bc			;8dc8
	push de			;8dc9
	ld hl,08e32h		;8dca
	call L_B1C3		;8dcd
	pop hl			;8dd0
	pop de			;8dd1
	add hl,de			;8dd2
	ex de,hl			;8dd3
	inc de			;8dd4
	pop hl			;8dd5
	inc hl			;8dd6
	pop bc			;8dd7
	djnz L_8DC3		;8dd8
	call L_9FE6		;8dda
	ret			;8ddd
L_8DDE:
	ld hl,01800h		;8dde
	ld de,001c0h		;8de1
	add hl,de			;8de4
	ld de,00040h		;8de5
	ld a,030h		;8de8
	call L_9D42		;8dea
	ld hl,01800h		;8ded
	ld de,00200h		;8df0
	add hl,de			;8df3
	ld de,00040h		;8df4
	ld a,040h		;8df7
	call L_9D42		;8df9
	ld hl,01800h		;8dfc
	ld de,00240h		;8dff
	add hl,de			;8e02
	ld de,00080h		;8e03
	ld a,02ch		;8e06
	call L_9D42		;8e08
	ld hl,01800h		;8e0b
	ld de,002c0h		;8e0e
	add hl,de			;8e11
	ld de,00020h		;8e12
	ld a,048h		;8e15
	call L_9D42		;8e17
	ret			;8e1a

; ----------------------------------------------------------------------
; DATOS tabla_tramos_fila12: Veintitres bytes: la rampa de tiles F0..FE,F0..F7 de la que salen los tramos de la fila 12 (primera pasada, base cargada en 0x8DA7, VRAM 0x1980)
;   0x8e1b..0x8e32  (23 bytes)
; DATOS tabla_tramos_fila13: Veinte bytes, todos 0xFF: los tramos de la fila 13 (segunda pasada, base cargada en 0x8DCA, VRAM 0x19A0). Su final, 0x8E46, coincide EXACTO con el mayor uso posible, 0x8E32+2x0x0A
;   0x8e32..0x8e46  (20 bytes)
; DATOS guion_celdas_columna: Guion de 16 celdas para 0x9FE6: una columna de 3 de ancho por 8 de alto en filas 14-21, columnas 15-17, tiles 0x20-0x36. Lo llaman 0x8D4D y 0x8D60
;   0x8f06..0x8f48  (66 bytes)
; DATOS guion_celdas_bloque_a: Guion de 24 celdas: un bloque en filas 14-17, columnas 10-22, tiles 0x2A-0x56. Variante A de la misma zona que el guion siguiente. Lo llama 0x8D12
;   0x8f48..0x8faa  (98 bytes)
; DATOS guion_celdas_bloque_b: Guion de 24 celdas: mismas filas 14-17 y columnas 10-22 que el anterior, tiles 0x30-0x40. Variante B. Lo llama 0x8D0B
;   0x8faa..0x900c  (98 bytes)
; DATOS guion_celdas_franja_a: Guion de 16 celdas: franja baja en filas 18-21, columnas 5-27, tiles 0x18-0x2C. Variante A. Lo llama 0x8D66
;   0x900c..0x904e  (66 bytes)
; DATOS guion_celdas_franja_b: Guion de 16 celdas: misma franja 18-21 que el anterior, tiles 0x18-0x2C. Variante B. Lo llama 0x8D53
;   0x904e..0x9090  (66 bytes)
; DATOS fila_de_tiles_23: Catorce numeros de tile en crudo que 0x8B51-0x8B5A copia con B1C3 a la VRAM 0x1AE2, o sea la fila 23 del name table, columnas 2-15
;   0x9090..0x909e  (14 bytes)
; DATOS grafico_rle_tiles_a: Bloque RLE para B142: 360 bytes descomprimidos a la VRAM desde 0x0000, el principio de la tabla de patrones. Lo carga 0x8B15
;   0x909e..0x915b  (189 bytes)
; DATOS grafico_rle_tiles_b: Bloque RLE para B142: 760 bytes a la VRAM desde 0x0480, mas patrones de la tabla de tiles. Lo carga 0x8B1B
;   0x915b..0x939d  (578 bytes)
; DATOS grafico_rle_sprites_a: Bloque RLE para B142: 416 bytes a la VRAM desde 0x3880, dentro de la tabla de patrones de sprites (0x3800-0x3FFF). Lo carga 0x8B5E
;   0x939d..0x9473  (214 bytes)
; DATOS grafico_rle_sprites_b: Bloque RLE para B142: 288 bytes a la VRAM desde 0x3B40, mas patrones de sprites. Lo carga 0x8B6F
;   0x9473..0x956a  (247 bytes)
; DATOS grafico_rle_sprites_c: Bloque RLE para B142: 288 bytes a la VRAM desde 0x3D80, mas patrones de sprites. Lo carga 0x8B80
;   0x956a..0x95fe  (148 bytes)
; DATOS tiles_decorado_3: 128 bytes: 16 patrones de tile en crudo, la entrada [3] de la tabla 0xA086. Se copian a la VRAM 0x0380 con B1C3
;   0x95fe..0x967e  (128 bytes)
; DATOS tiles_decorado_2: 128 bytes, la entrada [2] de la tabla 0xA086
;   0x967e..0x96fe  (128 bytes)
; DATOS tiles_decorado_0: 128 bytes, la entrada [0] de la tabla 0xA086
;   0x96fe..0x977e  (128 bytes)
; DATOS tiles_decorado_1: 128 bytes, la entrada [1] de la tabla 0xA086
;   0x977e..0x97fe  (128 bytes)
; DATOS patron_de_sprite_relleno: Un patron de sprite de 32 bytes en crudo, que empieza por FF FF: 0xA002-0xA023 lo copia tal cual con B1C3 a TRES huecos de la tabla de sprites, 0x3C20, 0x3D40 y 0x3E60
;   0x97fe..0x981e  (32 bytes)
; DATOS sprites_rle_1: Bloque RLE para B142: 64 bytes a la VRAM 0x3FC0 (los dos ultimos patrones de sprite). Lo carga 0xAB57
;   0x981e..0x9850  (50 bytes)
; DATOS sprites_rle_2: Bloque RLE para B142: 64 bytes a 0x3FC0. Lo carga 0xAB21
;   0x9850..0x9865  (21 bytes)
; DATOS sprites_rle_3: Bloque RLE para B142: 64 bytes a 0x3FC0. Lo carga 0xAABD
;   0x9865..0x989e  (57 bytes)
; DATOS sprites_rle_4: Bloque RLE para B142: 64 bytes a 0x3FC0. Lo carga 0xAC22
;   0x989e..0x98bb  (29 bytes)
; DATOS sprites_rle_5: Bloque RLE para B142: 64 bytes a 0x3FC0. Lo carga 0xABC8
;   0x98bb..0x98e0  (37 bytes)
; DATOS sprites_rle_6: Bloque RLE para B142: 64 bytes a la VRAM 0x3800, los DOS PRIMEROS patrones de sprite. Lo carga 0xACB6
;   0x98e0..0x9919  (57 bytes)
; DATOS sprites_rle_7: Bloque RLE para B142: 64 bytes a 0x3FC0. Lo carga 0xAD75
;   0x9919..0x9944  (43 bytes)
; DATOS sprites_rle_8: Bloque RLE para B142: 64 bytes a 0x3FC0. Lo carga 0xAD1F
;   0x9944..0x9989  (69 bytes)
; DATOS sprites_rle_9: Bloque RLE para B142: 64 bytes a 0x3FC0. Lo carga 0xAA74
;   0x9989..0x99af  (38 bytes)
; DATOS sprite_crudo_5: 32 bytes a la VRAM 0x39A0: los copia 0x8307-0x8310, y el volcado del emulador los encuentra alli tal cual (titulo y demo)
;   0x99af..0x99cf  (32 bytes)
; DATOS sprite_crudo_1: 32 bytes de patron de sprite sin comprimir, a la VRAM 0x39E0. Lo copia 0xAA07
;   0x99cf..0x99ef  (32 bytes)
; DATOS sprite_crudo_6: 32 bytes a la VRAM 0x3BE0: los copia 0x82FB-0x8304, confirmado igual en el volcado
;   0x99ef..0x9a0f  (32 bytes)
; DATOS sprite_crudo_2: 32 bytes a la VRAM 0x3C20. Lo copia 0xAA13
;   0x9a0f..0x9a2f  (32 bytes)
; DATOS sprite_crudo_3: 32 bytes a la VRAM 0x3E60. Lo copia 0xAA1F
;   0x9a2f..0x9a4f  (32 bytes)
; DATOS sprite_crudo_4: 32 bytes a la VRAM 0x3800. Lo copia 0xAA2B
;   0x9a4f..0x9a6f  (32 bytes)
; ----------------------------------------------------------------------
	defb 0f0h,0f1h,0f2h,0f3h,0f4h,0f5h,0f6h,0f7h,0f8h,0f9h,0fah,0fbh,0fch,0fdh,0feh,0f0h	; 8e1b  ................
	defb 0f1h,0f2h,0f3h,0f4h,0f5h,0f6h,0f7h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 8e2b  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,000h,000h,000h,000h,003h,003h,003h,000h,003h,007h,00eh	; 8e3b  ................
	defb 00dh,006h,007h,002h,003h,003h,003h,001h,001h,001h,001h,001h,001h,001h,001h,000h	; 8e4b  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,0c0h,000h,000h,000h,080h,0c0h,0c0h	; 8e5b  ................
	defb 0c0h,0d0h,0d0h,040h,0c0h,0c0h,0c0h,0c0h,0c0h,0c0h,0c0h,0c0h,070h,000h,0c0h,000h	; 8e6b  ...@........p...
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,003h,003h,003h,000h,00fh,03fh	; 8e7b  ...............?
	defb 073h,063h,063h,003h,023h,003h,0e7h,03eh,018h,000h,000h,000h,000h,000h,000h,000h	; 8e8b  scc.#..>........
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0c0h,000h,000h,000h,0c0h,0e0h	; 8e9b  ................
	defb 062h,0beh,09ch,0c0h,0c0h,0f8h,018h,018h,01eh,000h,000h,000h,000h,000h,000h,000h	; 8eab  b...............
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,003h,000h,000h,000h,001h,003h,003h	; 8ebb  ................
	defb 003h,00bh,00bh,002h,003h,003h,003h,003h,003h,003h,003h,003h,00fh,000h,003h,000h	; 8ecb  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,0c0h,0c0h,0c0h,000h,0c0h,0e0h,070h	; 8edb  ...............p
	defb 0b0h,060h,0e0h,040h,0c0h,0c0h,0c0h,080h,080h,080h,080h,080h,080h,080h,080h,000h	; 8eeb  .`.@............
	defb 000h,000h,000h,000h,000h,0bah,0b8h,0c2h,0b8h,0b8h,000h,010h,000h,0cfh,001h,031h	; 8efb  ...............1
	defb 000h,0d0h,001h,033h,000h,0d1h,001h,034h,000h,0efh,001h,032h,000h,0f0h,001h,036h	; 8f0b  ...3...4...2...6
	defb 000h,0f1h,001h,035h,000h,010h,002h,020h,000h,030h,002h,020h,000h,050h,002h,020h	; 8f1b  ...5... .0. .P. 
	defb 000h,070h,002h,020h,000h,090h,002h,020h,000h,0b0h,002h,020h,000h,00fh,002h,028h	; 8f2b  .p. ... ... ...(
	defb 000h,02fh,002h,028h,000h,011h,002h,029h,000h,031h,002h,029h,000h,018h,000h,0cah	; 8f3b  ./.(...).1.)....
	defb 001h,037h,000h,0cbh,001h,033h,000h,0cch,001h,053h,000h,0eah,001h,050h,000h,0ebh	; 8f4b  .7...3...S...P..
	defb 001h,036h,000h,0ech,001h,054h,000h,0d4h,001h,055h,000h,0d5h,001h,033h,000h,0d6h	; 8f5b  .6...T...U...3..
	defb 001h,051h,000h,0f4h,001h,056h,000h,0f5h,001h,036h,000h,0f6h,001h,052h,000h,00ah	; 8f6b  .Q...V...6...R..
	defb 002h,02ah,000h,00bh,002h,02ch,000h,00ch,002h,02bh,000h,02ah,002h,02ah,000h,02bh	; 8f7b  .*...,...+.*.*.+
	defb 002h,02ch,000h,02ch,002h,02bh,000h,014h,002h,02ah,000h,015h,002h,02ch,000h,016h	; 8f8b  .,.,.+...*...,..
	defb 002h,02bh,000h,034h,002h,02ah,000h,035h,002h,02ch,000h,036h,002h,02bh,000h,018h	; 8f9b  .+.4.*.5.,.6.+..
	defb 000h,0cah,001h,030h,000h,0cbh,001h,030h,000h,0cch,001h,030h,000h,0eah,001h,030h	; 8fab  ...0...0...0...0
	defb 000h,0ebh,001h,030h,000h,0ech,001h,030h,000h,0d4h,001h,030h,000h,0d5h,001h,030h	; 8fbb  ...0...0...0...0
	defb 000h,0d6h,001h,030h,000h,0f4h,001h,030h,000h,0f5h,001h,030h,000h,0f6h,001h,030h	; 8fcb  ...0...0...0...0
	defb 000h,00ah,002h,040h,000h,00bh,002h,040h,000h,00ch,002h,040h,000h,02ah,002h,040h	; 8fdb  ...@...@...@.*.@
	defb 000h,02bh,002h,040h,000h,02ch,002h,040h,000h,014h,002h,040h,000h,015h,002h,040h	; 8feb  .+.@.,.@...@...@
	defb 000h,016h,002h,040h,000h,034h,002h,040h,000h,035h,002h,040h,000h,036h,002h,040h	; 8ffb  ...@.4.@.5.@.6.@
	defb 000h,010h,000h,05ah,002h,018h,000h,05bh,002h,018h,000h,07ah,002h,019h,000h,07bh	; 900b  ...Z...[...z...{
	defb 002h,019h,000h,09ah,002h,01ah,000h,09bh,002h,01ah,000h,0bah,002h,018h,000h,0bbh	; 901b  ................
	defb 002h,018h,000h,045h,002h,02ch,000h,046h,002h,02ch,000h,065h,002h,02ch,000h,066h	; 902b  ...E.,.F.,.e.,.f
	defb 002h,02ch,000h,085h,002h,02ch,000h,086h,002h,02ch,000h,0a5h,002h,02ch,000h,0a6h	; 903b  .,...,...,...,..
	defb 002h,02ch,000h,010h,000h,045h,002h,018h,000h,046h,002h,018h,000h,065h,002h,019h	; 904b  .,...E...F...e..
	defb 000h,066h,002h,019h,000h,085h,002h,01ah,000h,086h,002h,01ah,000h,0a5h,002h,018h	; 905b  .f..............
	defb 000h,0a6h,002h,018h,000h,05ah,002h,02ch,000h,05bh,002h,02ch,000h,07ah,002h,02ch	; 906b  .....Z.,.[.,.z.,
	defb 000h,07bh,002h,02ch,000h,09ah,002h,02ch,000h,09bh,002h,02ch,000h,0bah,002h,02ch	; 907b  .{.,...,...,...,
	defb 000h,0bbh,002h,02ch,000h,0c8h,0c9h,0cah,0cbh,0cch,0cdh,0ceh,0cfh,0d0h,0d1h,0d2h	; 908b  ...,............
	defb 0d3h,0d4h,0d5h,000h,000h,008h,0fch,0b8h,008h,000h,008h,03fh,050h,030h,030h,070h	; 909b  ...........?P00p
	defb 0e0h,0c0h,080h,000h,000h,00ch,00ch,00eh,007h,003h,001h,000h,000h,0a0h,054h,0e0h	; 90ab  ..............T.
	defb 070h,030h,030h,03ch,03fh,03fh,007h,030h,030h,060h,0e0h,0c0h,080h,000h,000h,0e0h	; 90bb  p00<??.00`......
	defb 07fh,00fh,003h,005h,000h,042h,080h,0e0h,004h,0ffh,041h,00fh,0a0h,058h,0dfh,0dfh	; 90cb  .....B....A..X..
	defb 000h,0fbh,0fbh,000h,0dfh,0dfh,000h,0fbh,0fbh,000h,0dfh,0dfh,000h,0fbh,0fbh,000h	; 90db  ................
	defb 0dfh,0dfh,000h,0fbh,0fbh,000h,0a8h,048h,0ffh,0ffh,000h,000h,0ffh,0ffh,000h,000h	; 90eb  .......H........
	defb 0b8h,008h,0f8h,008h,01fh,008h,0e0h,008h,007h,008h,000h,098h,00dh,000h,006h,007h	; 90fb  ................
	defb 00ah,000h,003h,0ffh,005h,000h,006h,0e0h,005h,000h,003h,0ffh,00ah,000h,003h,01fh	; 910b  ................
	defb 00bh,000h,045h,080h,0c0h,0f0h,0f8h,0f8h,0b0h,008h,000h,0b8h,006h,000h,002h,0ffh	; 911b  ..E.............
	defb 0b8h,003h,01fh,00ah,000h,006h,0f8h,00ah,000h,006h,0f8h,00ah,000h,006h,01fh,01bh	; 912b  ................
	defb 000h,042h,007h,0ffh,005h,000h,043h,00fh,0ffh,0ffh,004h,000h,044h,01fh,0ffh,0ffh	; 913b  .B....C.....D...
	defb 0ffh,003h,000h,041h,03fh,004h,0ffh,005h,000h,003h,0ffh,004h,000h,004h,0ffh,000h	; 914b  ...A?...........
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
	defb 0ffh,000h,080h,038h,005h,000h,002h,0ffh,00eh,000h,042h,0ffh,0feh,010h,000h,002h	; 939b  ...8......B.....
	defb 0ffh,00eh,000h,042h,0fch,0f8h,010h,000h,002h,0ffh,00eh,000h,042h,0f0h,0e0h,010h	; 93ab  ...B........B...
	defb 000h,041h,0ffh,00fh,000h,041h,0c0h,004h,000h,048h,001h,003h,003h,007h,0feh,0f8h	; 93bb  .A...A...H......
	defb 080h,080h,008h,000h,044h,0e0h,0f0h,0f8h,01ch,004h,00ch,041h,00fh,007h,000h,049h	; 93cb  ....D......A...I
	defb 003h,003h,001h,001h,003h,007h,01eh,018h,010h,007h,000h,045h,0c0h,0c0h,0e0h,0e0h	; 93db  ...........E....
	defb 070h,004h,030h,041h,03ch,006h,000h,04ah,003h,003h,001h,001h,001h,00fh,00dh,009h	; 93eb  p.0A<..J........
	defb 001h,001h,006h,000h,04ah,0c0h,0e0h,0f0h,0f0h,0e0h,0c0h,080h,080h,080h,0e0h,006h	; 93fb  ....J...........
	defb 000h,004h,003h,046h,007h,006h,00ch,018h,018h,01ch,006h,000h,047h,0c0h,0f8h,0fch	; 940b  ...F........G...
	defb 00ch,00ch,00ch,00eh,009h,000h,049h,003h,003h,007h,006h,00eh,01ch,070h,040h,040h	; 941b  ......I......p@@
	defb 007h,000h,048h,0c0h,0e0h,0f0h,038h,018h,018h,018h,01eh,008h,000h,002h,003h,008h	; 942b  ..H...8.........
	defb 001h,006h,000h,007h,0c0h,043h,070h,000h,0c0h,006h,000h,044h,003h,0e7h,03eh,018h	; 943b  .....Cp....D..>.
	defb 00ch,000h,044h,0f8h,018h,018h,01eh,00ch,000h,048h,007h,00fh,01fh,018h,00ch,006h	; 944b  ..D......H......
	defb 006h,01eh,008h,000h,00bh,0c0h,041h,0f0h,004h,000h,043h,07fh,07eh,038h,00dh,000h	; 945b  ......A...C.~8..
	defb 044h,0e0h,038h,00fh,006h,00ch,000h,000h,040h,03bh,004h,000h,003h,001h,049h,000h	; 946b  D.8.....@;....I.
	defb 003h,00fh,00dh,00dh,00dh,005h,001h,001h,004h,000h,04ch,0e0h,080h,080h,000h,0c0h	; 947b  ..........L.....
	defb 0e0h,0e0h,0e0h,0f8h,0f8h,0e0h,0e0h,004h,000h,003h,001h,049h,000h,003h,007h,00eh	; 948b  ...........I....
	defb 00dh,007h,003h,002h,003h,004h,000h,044h,0e0h,080h,080h,000h,004h,0c0h,044h,0e0h	; 949b  .......D......D.
	defb 0e0h,040h,0c0h,004h,000h,003h,001h,049h,000h,001h,003h,003h,007h,007h,003h,002h	; 94ab  .@.....I........
	defb 003h,004h,000h,045h,0e0h,080h,080h,000h,0c0h,005h,0e0h,042h,040h,0c0h,004h,000h	; 94bb  ...E.......B@...
	defb 003h,001h,049h,000h,003h,00eh,01fh,01bh,01bh,01bh,00bh,003h,004h,000h,04ch,0e0h	; 94cb  ..I...........L.
	defb 080h,080h,000h,0c0h,0e0h,0e0h,0e0h,0f8h,0f0h,0c0h,0c0h,004h,000h,003h,001h,049h	; 94db  ...............I
	defb 000h,007h,01fh,039h,033h,033h,023h,003h,003h,004h,000h,049h,0e0h,080h,080h,000h	; 94eb  ...933#....I....
	defb 0e0h,0e0h,0f0h,0deh,0cch,003h,0c0h,004h,000h,003h,003h,049h,000h,003h,007h,00eh	; 94fb  ...........I....
	defb 00dh,006h,007h,002h,003h,004h,000h,041h,0c0h,003h,000h,048h,080h,0c0h,0c0h,0c0h	; 950b  .......A...H....
	defb 0d0h,0d0h,040h,0c0h,005h,000h,003h,003h,048h,000h,00fh,03eh,073h,063h,063h,003h	; 951b  ..@.....H..>scc.
	defb 003h,005h,000h,04bh,0c0h,000h,000h,000h,0c0h,0e0h,062h,0beh,09ch,0c0h,0c0h,006h	; 952b  ...K......b.....
	defb 000h,04ah,001h,003h,003h,018h,019h,01fh,00fh,007h,003h,003h,006h,000h,04ah,080h	; 953b  .J............J.
	defb 0c0h,0c0h,000h,080h,0e0h,0f0h,0f0h,0e0h,0c0h,004h,000h,048h,0f0h,0c0h,0c0h,000h	; 954b  ...........H....
	defb 0f0h,0ffh,0cfh,0e0h,004h,0f0h,006h,000h,004h,0c0h,041h,080h,005h,000h,000h,080h	; 955b  ..........A.....
	defb 03dh,007h,000h,041h,001h,005h,000h,041h,008h,007h,000h,047h,060h,060h,0c0h,000h	; 956b  =..A...A...G``..
	defb 000h,000h,004h,00bh,000h,041h,001h,006h,000h,041h,001h,006h,000h,043h,060h,060h	; 957b  .....A...A...C``
	defb 0c0h,005h,000h,042h,010h,080h,008h,000h,041h,001h,006h,000h,041h,001h,006h,000h	; 958b  ...B....A...A...
	defb 043h,060h,060h,0c0h,006h,000h,041h,080h,008h,000h,041h,001h,006h,000h,041h,010h	; 959b  C``...A...A...A.
	defb 006h,000h,047h,060h,060h,0c0h,000h,000h,000h,004h,00bh,000h,041h,001h,005h,000h	; 95ab  ..G``.......A...
	defb 041h,010h,007h,000h,046h,060h,060h,0c0h,000h,000h,001h,00ch,000h,041h,003h,006h	; 95bb  A...F``......A..
	defb 000h,041h,001h,006h,000h,043h,0c0h,0c0h,080h,005h,000h,042h,008h,080h,009h,000h	; 95cb  .A...C.....B....
	defb 041h,003h,005h,000h,041h,060h,007h,000h,045h,0c0h,0c0h,080h,000h,001h,00ch,000h	; 95db  A...A`..E.......
	defb 043h,001h,00dh,001h,00dh,000h,043h,080h,0c0h,080h,00bh,000h,043h,030h,030h,0e0h	; 95eb  C.....C.....C00.
	defb 018h,000h,000h,0ffh,0ffh,01fh,007h,000h,000h,000h,000h,0ffh,0ffh,0ffh,0ffh,0f8h	; 95fb  ................
	defb 000h,000h,000h,0ffh,0ffh,0ffh,0f0h,000h,000h,000h,000h,0ffh,0f8h,0f8h,000h,000h	; 960b  ................
	defb 000h,000h,000h,0f0h,01fh,003h,000h,000h,000h,000h,000h,0ffh,0ffh,0ffh,07eh,000h	; 961b  ..............~.
	defb 000h,000h,000h,0ffh,0c0h,0c0h,000h,000h,000h,000h,000h,0ffh,0ffh,03fh,00fh,00fh	; 962b  .............?..
	defb 00fh,003h,003h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0cch,0b0h,0c0h	; 963b  ................
	defb 080h,000h,000h,007h,007h,000h,000h,000h,000h,000h,000h,0ffh,0ffh,03fh,03fh,03fh	; 964b  .............???
	defb 00fh,003h,003h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0f3h,0e7h,0fdh	; 965b  ................
	defb 0ffh,0f7h,0f0h,0feh,0feh,0f8h,0f8h,0f0h,0f0h,080h,000h,00fh,000h,000h,000h,000h	; 966b  ................
	defb 000h,000h,000h,007h,000h,000h,000h,000h,000h,000h,000h,0ffh,03fh,007h,000h,000h	; 967b  ............?...
	defb 000h,000h,000h,0ffh,0ffh,0e7h,0ffh,0ffh,0ffh,01ch,000h,0ffh,0ffh,0ffh,0ffh,0ffh	; 968b  ................
	defb 0ffh,01fh,000h,0e7h,0f3h,0ffh,0ffh,0ffh,0ffh,0ffh,03fh,0ffh,0ffh,0ffh,0efh,09fh	; 969b  ..........?.....
	defb 0fch,0f8h,0e0h,0ffh,0ffh,0ffh,0ffh,0ffh,03fh,00fh,003h,0ffh,0ffh,0ffh,0ffh,0ffh	; 96ab  ........?.......
	defb 0ffh,0ffh,0ffh,0ffh,0efh,0dfh,0dfh,0ffh,0ffh,0fch,0f0h,0fch,0f0h,0c0h,0c0h,0c0h	; 96bb  ................
	defb 080h,000h,000h,003h,003h,000h,000h,000h,000h,000h,000h,0ffh,0ffh,03fh,03fh,003h	; 96cb  .............??.
	defb 003h,000h,000h,0ffh,0c7h,0e7h,0ffh,0ffh,0ffh,03fh,03fh,0ffh,0ffh,0ffh,0ffh,0ffh	; 96db  .........??.....
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0fdh,0e7h,0fch,0fch,0c0h,0ffh,0ffh,0f8h,0f0h,080h	; 96eb  ................
	defb 000h,000h,000h,0ffh,0ffh,0ffh,0ffh,0e0h,0e0h,080h,080h,0ffh,0ffh,09fh,0f7h,0ffh	; 96fb  ................
	defb 003h,003h,000h,0ffh,0ffh,0ffh,0ffh,0f7h,0efh,0ffh,0fch,0ffh,0ffh,0ffh,0bfh,0e7h	; 970b  ................
	defb 0ffh,0ffh,03fh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0f7h,0cfh	; 971b  ..?.............
	defb 0ffh,0fch,0e0h,0ffh,0ffh,0ffh,0fch,0fch,0f0h,000h,000h,000h,000h,000h,000h,000h	; 972b  ................
	defb 000h,000h,000h,01fh,007h,007h,000h,000h,000h,000h,000h,0ffh,0efh,0cfh,0ffh,0ffh	; 973b  ................
	defb 007h,007h,003h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0bfh,0ffh,0efh	; 974b  ................
	defb 0ffh,0cfh,00fh,0ffh,0ffh,0ffh,0ffh,0dfh,0ffh,0f0h,0e0h,0ffh,0fbh,09fh,0ffh,00fh	; 975b  ................
	defb 003h,003h,000h,0ffh,0f7h,0feh,0f8h,0f0h,0f0h,0c0h,000h,0ffh,0e0h,000h,000h,000h	; 976b  ................
	defb 000h,000h,000h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,00fh,000h,0ffh,0f8h,0f0h,0f0h,0c0h	; 977b  ................
	defb 000h,000h,000h,001h,000h,000h,000h,000h,000h,000h,000h,0ffh,03fh,03fh,003h,003h	; 978b  ............??..
	defb 000h,000h,000h,0ffh,0ffh,0efh,0f7h,0ffh,0ffh,0f1h,001h,0ffh,0ffh,0f7h,0e7h,0edh	; 979b  ................
	defb 0f6h,0f1h,0e0h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,09fh,0fdh,0f3h,0ffh	; 97ab  ................
	defb 0ffh,0f7h,0f3h,0fch,0fch,0fch,0f0h,0c0h,0c0h,080h,000h,0ffh,07fh,007h,007h,001h	; 97bb  ................
	defb 001h,001h,000h,0ffh,0ffh,0ffh,0bfh,0ffh,0ffh,0ffh,03eh,0ffh,09fh,0ffh,0f9h,0ffh	; 97cb  ..........>.....
	defb 0cfh,083h,003h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0f9h	; 97db  ................
	defb 0ffh,083h,000h,0ffh,0ffh,0ffh,0e7h,0c0h,0c0h,080h,000h,0ffh,0ffh,0ffh,0ebh,0ffh	; 97eb  ................
	defb 007h,000h,000h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 97fb  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 980b  ................
	defb 0ffh,0ffh,0ffh,0c0h,03fh,005h,000h,046h,001h,007h,01fh,000h,07fh,07fh,00ah,000h	; 981b  ....?..F........
	defb 046h,0f8h,0e4h,09ch,078h,070h,040h,005h,000h,04bh,001h,012h,020h,010h,080h,041h	; 982b  F...xp@..K.. ..A
	defb 007h,01fh,000h,07fh,07fh,006h,000h,04ah,010h,024h,000h,000h,0f8h,0e4h,09ch,078h	; 983b  .......J.$.....x
	defb 070h,040h,005h,000h,000h,0c0h,03fh,020h,000h,048h,001h,012h,020h,010h,080h,040h	; 984b  p@....? .H.. ..@
	defb 000h,010h,009h,000h,042h,010h,024h,00dh,000h,000h,0c0h,03fh,04ch,000h,004h,002h	; 985b  ....B.$....?L...
	defb 003h,007h,037h,011h,00dh,00fh,00fh,006h,003h,007h,000h,049h,030h,060h,0e0h,0e4h	; 986b  ..7........I0`..
	defb 0e4h,0f8h,0f8h,0e0h,040h,006h,000h,04ah,004h,006h,00eh,02eh,027h,013h,01bh,00fh	; 987b  ....@..J....'...
	defb 007h,003h,005h,000h,04bh,020h,020h,060h,0c0h,0c0h,0cch,0d0h,0f0h,030h,060h,040h	; 988b  ....K  `.....0`@
	defb 004h,000h,000h,0c0h,03fh,005h,000h,049h,001h,001h,00fh,00ch,00fh,000h,000h,00fh	; 989b  ....?..I........
	defb 001h,007h,000h,049h,080h,080h,0e0h,000h,0e0h,060h,060h,0e0h,080h,022h,000h,000h	; 98ab  ...I.....``.."..
	defb 0c0h,03fh,047h,000h,000h,005h,01fh,00fh,003h,001h,00bh,000h,045h,0e0h,0f8h,0f0h	; 98bb  .?G.........E...
	defb 0c0h,080h,00bh,000h,045h,007h,01fh,00fh,003h,001h,00bh,000h,045h,0a0h,078h,0f0h	; 98cb  ....E.......E.x.
	defb 0c0h,080h,009h,000h,000h,000h,038h,04ch,000h,000h,01fh,078h,061h,060h,078h,03fh	; 98db  ......8L...xa`x?
	defb 01fh,007h,003h,00ch,007h,000h,049h,080h,080h,018h,060h,018h,080h,0e0h,01ch,0ceh	; 98eb  ......I...`.....
	defb 005h,000h,04bh,01fh,038h,061h,060h,070h,078h,03eh,01fh,007h,000h,018h,006h,000h	; 98fb  ..K.8a`px>......
	defb 04ah,080h,000h,000h,018h,070h,080h,080h,0e6h,018h,06eh,004h,000h,000h,0c0h,03fh	; 990b  J....p....n....?
	defb 006h,000h,044h,07fh,013h,06ch,07fh,00ah,000h,046h,060h,078h,0feh,03eh,0ceh,0feh	; 991b  ..D..l...F`x.>..
	defb 007h,000h,049h,030h,03eh,007h,001h,000h,000h,000h,06ch,07fh,009h,000h,047h,09ch	; 992b  ..I0>.....l...G.
	defb 0fch,07eh,01eh,00eh,0ceh,0feh,006h,000h,000h,0c0h,03fh,060h,000h,003h,00eh,019h	; 993b  .~........?`....
	defb 01fh,01fh,019h,01fh,01fh,01ch,013h,00eh,019h,019h,00eh,007h,000h,0c0h,070h,0f8h	; 994b  ..............p.
	defb 0f8h,078h,0f8h,0f8h,0f8h,038h,0c8h,070h,098h,098h,070h,0e0h,060h,000h,003h,00eh	; 995b  .x...8.p..p.`...
	defb 01fh,01fh,01eh,01fh,01fh,01fh,01ch,013h,00eh,019h,019h,00eh,007h,000h,0c0h,070h	; 996b  ...............p
	defb 098h,0f8h,078h,098h,0f8h,0f8h,038h,0c8h,070h,098h,098h,070h,0e0h,000h,0c0h,03fh	; 997b  ..x...8.p..p...?
	defb 042h,000h,020h,009h,000h,043h,07fh,000h,07fh,00ch,000h,048h,008h,0c8h,000h,0c0h	; 998b  B. ..C.....H....
	defb 000h,000h,000h,010h,009h,000h,043h,07fh,000h,07fh,00ch,000h,046h,004h,0c4h,000h	; 999b  ......C.....F...
	defb 0c0h,000h,000h,000h,003h,003h,001h,001h,001h,001h,001h,001h,001h,001h,000h,000h	; 99ab  ................
	defb 000h,000h,000h,000h,0c0h,0c0h,0c0h,0c0h,0c0h,0c0h,0c0h,070h,000h,0c0h,000h,000h	; 99bb  ...........p....
	defb 000h,000h,000h,000h,007h,00fh,01fh,018h,00ch,006h,006h,01eh,000h,000h,000h,000h	; 99cb  ................
	defb 000h,000h,000h,000h,0c0h,0c0h,0c0h,0c0h,0c0h,0c0h,0c0h,0c0h,0c0h,0c0h,0c0h,0f0h	; 99db  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,003h,003h,003h,000h,003h,007h,00eh,00dh	; 99eb  ................
	defb 006h,007h,002h,003h,000h,000h,000h,000h,0c0h,000h,000h,000h,080h,0c0h,0c0h,0c0h	; 99fb  ................
	defb 0d0h,0d0h,040h,0c0h,000h,000h,000h,000h,000h,000h,001h,003h,003h,018h,019h,01fh	; 9a0b  ..@.............
	defb 00fh,007h,003h,003h,000h,000h,000h,000h,000h,000h,080h,0c0h,0c0h,000h,080h,0e0h	; 9a1b  ................
	defb 0f0h,0f0h,0e0h,0c0h,000h,000h,000h,000h,000h,000h,000h,001h,00dh,001h,000h,000h	; 9a2b  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,080h,0c0h,080h,000h,000h	; 9a3b  ................
	defb 000h,000h,000h,000h,0ffh,0ffh,0ffh,0ffh,0ffh,000h,000h,000h,000h,000h,000h,000h	; 9a4b  ................
	defb 000h,000h,000h,000h,0ffh,0ffh,0ffh,0ffh,0ffh,000h,000h,000h,000h,000h,000h,000h	; 9a5b  ................
	defb 000h,000h,000h,000h	; 9a6b  ....

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
	call L_9DB8		;9a6f
	call cambia_de_pantalla_a_la_derecha		;9a72
	or a			;9a75
	jr nz,L_9AE0		;9a76
	ld a,(0e221h)		;9a78   ; si 0xE221 no es cero corre la DEMO, y la entrada no se lee: se le mete la grabada de 0xE259
	or a			;9a7b
	jr z,L_9A88		;9a7c
	ld a,(0e259h)		;9a7e
	ld (0e05fh),a		;9a81
	xor a			;9a84
	ld (0e061h),a		;9a85
L_9A88:
	ld hl,0e247h		;9a88   ; 0xE247: cuantos objetos vivos hay, y detras sus punteros
	ld b,(hl)			;9a8b
	xor a			;9a8c
	cp b			;9a8d
	jr z,L_9AE0		;9a8e
L_9A90:
	push bc			;9a90
	inc hl			;9a91
	ld e,(hl)			;9a92
	inc hl			;9a93
	ld d,(hl)			;9a94
	push hl			;9a95
	push de			;9a96
	pop ix		;9a97
	dec (ix+011h)		;9a99   ; el contador propio del objeto; solo actua cuando llega a cero
	jr nz,L_9AD9		;9a9c
	ld a,(ix+010h)		;9a9e
	ld (ix+011h),a		;9aa1
	ld e,(ix+014h)		;9aa4
	ld d,(ix+015h)		;9aa7
	push de			;9aaa
	push de			;9aab
	pop iy		;9aac
	call L_9AEC		;9aae
	push ix		;9ab1
	call L_9B1F		;9ab3
	ld de,00006h		;9ab6
	add ix,de		;9ab9
	inc iy		;9abb
	call L_9B1F		;9abd
	pop ix		;9ac0
	bit 6,(ix+000h)		;9ac2
	jr z,L_9AD7		;9ac6
	push ix		;9ac8
	pop ix		;9aca
	ld l,(ix+012h)		;9acc
	ld h,(ix+013h)		;9acf
	ld de,L_9AD7		;9ad2
	push de			;9ad5
	jp (hl)			;9ad6
L_9AD7:
	pop iy		;9ad7
L_9AD9:
	pop hl			;9ad9
	pop bc			;9ada
	djnz L_9A90		;9adb
	call L_9D03		;9add
L_9AE0:
	ld hl,L_9AE0		;9ae0
	ld (hl),0c7h		;9ae3
	call L_9BF3		;9ae5
	call L_9B6D		;9ae8
	ret			;9aeb
L_9AEC:
	bit 5,(ix+000h)		;9aec
	ret z			;9af0
	dec (ix+00eh)		;9af1
	ret nz			;9af4
	ld a,(ix+00fh)		;9af5
	inc a			;9af8
	ld l,(ix+00ch)		;9af9
	ld h,(ix+00dh)		;9afc
	push hl			;9aff
	cp 000h		;9b00
	jr z,L_9B09		;9b02
	ld b,a			;9b04
L_9B05:
	inc hl			;9b05
	inc hl			;9b06
	djnz L_9B05		;9b07
L_9B09:
	ld b,a			;9b09
	ld a,(hl)			;9b0a
	pop de			;9b0b
	or a			;9b0c
	jr nz,L_9B13		;9b0d
	ex de,hl			;9b0f
	ld a,(hl)			;9b10
	ld b,000h		;9b11
L_9B13:
	ld (ix+00eh),a		;9b13
	ld (ix+00fh),b		;9b16
	inc hl			;9b19
	ld a,(hl)			;9b1a
	ld (iy+002h),a		;9b1b
	ret			;9b1e
L_9B1F:
	bit 0,(ix+000h)		;9b1f
	ret z			;9b23
	ld h,(iy+000h)		;9b24
	ld l,(ix+005h)		;9b27
	ld d,(ix+002h)		;9b2a
	ld e,(ix+001h)		;9b2d
	add hl,de			;9b30
	ld (iy+000h),h		;9b31
	ld (ix+005h),l		;9b34
	bit 2,(ix+000h)		;9b37
	ret z			;9b3b
	set 3,(ix+000h)		;9b3c
	set 4,(ix+000h)		;9b40
	ld a,h			;9b44
	ld b,(ix+003h)		;9b45
	cp b			;9b48
	jr c,L_9B5A		;9b49
	res 3,(ix+000h)		;9b4b
	ld b,(ix+004h)		;9b4f
	cp b			;9b52
	jr nc,L_9B5A		;9b53
	res 4,(ix+000h)		;9b55
	ret			;9b59
L_9B5A:
	bit 1,(ix+000h)		;9b5a
	ret z			;9b5e
	ld a,d			;9b5f
	cpl			;9b60
	ld d,a			;9b61
	ld a,e			;9b62
	cpl			;9b63
	ld e,a			;9b64
	inc de			;9b65
	ld (ix+001h),e		;9b66
	ld (ix+002h),d		;9b69
	ret			;9b6c
L_9B6D:
	ld a,(0e05fh)		;9b6d
	and 00fh		;9b70
	jr z,L_9B7D		;9b72
	ld a,03ch		;9b74
	ld (0e25bh),a		;9b76
	ld (0e25ch),a		;9b79
	ret			;9b7c
L_9B7D:
	ld hl,0e25ah		;9b7d
	dec (hl)			;9b80
	ret nz			;9b81
	ld (hl),03ch		;9b82
	inc hl			;9b84
	dec (hl)			;9b85
	ret nz			;9b86
	ld (hl),03ch		;9b87
	inc hl			;9b89
	dec (hl)			;9b8a
	ret nz			;9b8b
	di			;9b8c
	ld bc,08201h		;9b8d
	call L_B17C		;9b90
L_9B93:
	call L_B249		;9b93
	call L_B26E		;9b96
	ld a,(0e05fh)		;9b99
	and 03fh		;9b9c
	jr nz,L_9BAF		;9b9e
	ld a,007h		;9ba0
	or 0f0h		;9ba2
	out (0aah),a		;9ba4
	in a,(0a9h)		;9ba6
	cpl			;9ba8
	and 094h		;9ba9
	jr nz,L_9BAF		;9bab
	jr L_9B93		;9bad
L_9BAF:
	ld bc,0e201h		;9baf
	call L_B17C		;9bb2
L_9BB5:
	ld a,007h		;9bb5
	or 0f0h		;9bb7
	out (0aah),a		;9bb9
	in a,(0a9h)		;9bbb
	cpl			;9bbd
	and 094h		;9bbe
	jr nz,L_9BB5		;9bc0
	ld a,03ch		;9bc2
	ld (0e25ah),a		;9bc4
	ld (0e25bh),a		;9bc7
	ld (0e25ch),a		;9bca
	ei			;9bcd
	ret			;9bce
L_9BCF:
	ld a,001h		;9bcf
	ld (0e247h),a		;9bd1
	ld ix,0e2d5h		;9bd4
	ld hl,09e0eh		;9bd8
	ld (ix+012h),l		;9bdb
	ld (ix+013h),h		;9bde
	res 5,(ix+000h)		;9be1
	res 0,(ix+006h)		;9be5
	res 0,(ix+000h)		;9be9
	ld a,003h		;9bed
	ld (0e21ch),a		;9bef
	ret			;9bf2
L_9BF3:
	ld a,(0e221h)		;9bf3
	or a			;9bf6
	jp nz,L_9C60		;9bf7
	ld a,007h		;9bfa
	or 0f0h		;9bfc
	out (0aah),a		;9bfe
	in a,(0a9h)		;9c00
	cpl			;9c02
	ld b,a			;9c03
	ld a,(0e269h)		;9c04
	or a			;9c07
	jr z,L_9C0F		;9c08
	bit 7,b		;9c0a
	jp nz,L_9C61		;9c0c
L_9C0F:
	bit 4,b		;9c0f
	jp nz,INIT		;9c11
	ld a,(0e267h)		;9c14
	or a			;9c17
	jp nz,L_9C2B		;9c18
	bit 2,b		;9c1b
	jp z,L_9C60		;9c1d
	call L_9C94		;9c20
	ld a,001h		;9c23
	ld (0e267h),a		;9c25
	jp L_9C60		;9c28
L_9C2B:
	cp 001h		;9c2b
	jp nz,L_9C3D		;9c2d
	bit 2,b		;9c30
	jp nz,L_9C60		;9c32
	ld a,002h		;9c35
	ld (0e267h),a		;9c37
	jp L_9C60		;9c3a
L_9C3D:
	cp 002h		;9c3d
	jp nz,L_9C52		;9c3f
	bit 2,b		;9c42
	jp z,L_9C60		;9c44
	call L_9CAC		;9c47
	ld a,003h		;9c4a
	ld (0e267h),a		;9c4c
	jp L_9C60		;9c4f
L_9C52:
	cp 003h		;9c52
	jp nz,L_9C60		;9c54
	bit 2,b		;9c57
	jp nz,L_9C60		;9c59
	xor a			;9c5c
	ld (0e267h),a		;9c5d
L_9C60:
	ret			;9c60
L_9C61:
	ld a,(0e34ah)		;9c61
	or a			;9c64
	ret nz			;9c65
	ld hl,0e132h		;9c66
	ld de,0e133h		;9c69
	ld (hl),000h		;9c6c
	ld bc,0017ch		;9c6e
	ldir		;9c71
	ld hl,0e26ah		;9c73
	ld de,01b00h		;9c76
	ld bc,00044h		;9c79
	call L_B1C3		;9c7c
	ld a,001h		;9c7f
	ld (0e34ah),a		;9c81
	ld a,001h		;9c84
	call L_B32E		;9c86
	ld a,001h		;9c89
	ld (0e1e3h),a		;9c8b
	call L_8B5E		;9c8e
	jp L_8065		;9c91
L_9C94:
	ld a,(0e21ch)		;9c94
	or a			;9c97
	ret nz			;9c98
	ld a,(0e247h)		;9c99
	cp 001h		;9c9c
	ret z			;9c9e
	ld (0e189h),a		;9c9f
	xor a			;9ca2
	ld (0e247h),a		;9ca3
	ld a,002h		;9ca6
	ld (0e21ch),a		;9ca8
	ret			;9cab
L_9CAC:
	ld a,(0e21ch)		;9cac
	cp 002h		;9caf
	ret nz			;9cb1
	ld a,(0e189h)		;9cb2
	ld (0e247h),a		;9cb5
	xor a			;9cb8
	ld (0e21ch),a		;9cb9
	ret			;9cbc

; ----------------------------------------------------------------------
; DATOS sin identificar  0x9cbd..0x9cbe  (1 bytes)
; ----------------------------------------------------------------------
	defb 0c9h	; 9cbd  .

; ======================================================================
; CODIGO 0x9cbe..0xa086  (968 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; ############################################################
; EL CAMBIO DE PANTALLA, y el atajo de tres escenas
; ############################################################
; La X del jugador esta en 0xE2A3 (el campo +1 de la
; estructura de 0xE2A2). Cuando vale 0xE7 -el borde
; derecho- esto lo reposiciona en 0x19, o sea al otro
; lado, y acto seguido avanza el registro de pantalla.
; Y AQUI ESTA LO BUENO: avanza UNO o TRES pasos segun el
; bit 0 de 0xE2EB. Tres pasos son tres escenas de golpe,
; que es el atajo del subterraneo del Pitfall! original:
; por abajo se recorre el mundo al triple de velocidad.
; Al final salta a 0x9EE6, que monta la escena nueva; esa
; es la UNICA via por la que se dibuja una escena, asi que
; cambiar 0xE222 por las bravas no repinta nada
; ----------------------------------------------------------------------
cambia_de_pantalla_a_la_derecha:
	ld iy,0e2a2h		;9cbe
	ld a,0e7h		;9cc2   ; 0xE7 es la X del borde derecho
	cp (iy+001h)		;9cc4
	jr nz,L_9CE2		;9cc7
	ld (iy+001h),019h		;9cc9   ; y 0x19 la del izquierdo, por donde reaparece
	ld b,001h		;9ccd
	ld hl,0e2ebh		;9ccf
	bit 0,(hl)		;9cd2   ; el bit que decide si se avanza una escena o tres
	jr nz,L_9CD8		;9cd4
	ld b,003h		;9cd6
L_9CD8:
	push bc			;9cd8
	call avanza_pantalla_lfsr		;9cd9
	pop bc			;9cdc
	djnz L_9CD8		;9cdd
	jp L_9EE6		;9cdf
L_9CE2:
	ld a,016h		;9ce2
	cp (iy+001h)		;9ce4
	ld a,000h		;9ce7
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
	jp L_9EE6		;9d00
L_9D03:
	ld hl,0e2a2h		;9d03
	ld iy,0e2a6h		;9d06
	ld ix,0e2aah		;9d0a
	ld a,(hl)			;9d0e
	inc hl			;9d0f
	sub 010h		;9d10
	ld (iy+000h),a		;9d12
	ld (ix+000h),a		;9d15
	ld a,(hl)			;9d18
	ld (iy+001h),a		;9d19
	ld (ix+001h),a		;9d1c
	inc hl			;9d1f
	ld a,(hl)			;9d20
	sub 020h		;9d21
	ld b,a			;9d23
	add a,068h		;9d24
	ld (iy+002h),a		;9d26
	ld a,b			;9d29
	add a,0b0h		;9d2a
	ld (ix+002h),a		;9d2c
	ret			;9d2f
L_9D30:
	ld hl,0e247h		;9d30
	ld b,(hl)			;9d33
	inc (hl)			;9d34
	inc hl			;9d35
	xor a			;9d36
	cp b			;9d37
	jr z,L_9D3E		;9d38
L_9D3A:
	inc hl			;9d3a
	inc hl			;9d3b
	djnz L_9D3A		;9d3c
L_9D3E:
	ld (hl),e			;9d3e
	inc hl			;9d3f
	ld (hl),d			;9d40
	ret			;9d41
L_9D42:
	ld c,a			;9d42
	ld a,l			;9d43
	out (099h),a		;9d44
	ld a,h			;9d46
	or 040h		;9d47
	out (099h),a		;9d49
L_9D4B:
	ld a,c			;9d4b
	out (098h),a		;9d4c
	dec de			;9d4e
	ld a,d			;9d4f
	or e			;9d50
	jr nz,L_9D4B		;9d51
	ret			;9d53
L_9D54:
	ld b,005h		;9d54
	ld hl,0e1d6h		;9d56
	ld de,0e1dch		;9d59
	ld c,0c3h		;9d5c
L_9D5E:
	xor a			;9d5e
	cp (hl)			;9d5f
	jr z,L_9D64		;9d60
	ld c,0b8h		;9d62
L_9D64:
	ld a,c			;9d64
	add a,(hl)			;9d65
	ld (de),a			;9d66
	inc hl			;9d67
	inc de			;9d68
	djnz L_9D5E		;9d69
	ld a,0b8h		;9d6b
	add a,(hl)			;9d6d
	ld (de),a			;9d6e
	ld hl,0e1dch		;9d6f
	ld de,01826h		;9d72
	ld bc,00006h		;9d75
	call L_B1C3		;9d78
	ret			;9d7b
L_9D7C:
	ld hl,0e1d6h		;9d7c
	ld e,a			;9d7f
	ld d,000h		;9d80
	add hl,de			;9d82
	ld b,a			;9d83
	inc b			;9d84
	ld a,0ffh		;9d85
L_9D87:
	dec (hl)			;9d87
	cp (hl)			;9d88
	jr nz,L_9D54		;9d89
	ld (hl),009h		;9d8b
	dec hl			;9d8d
	djnz L_9D87		;9d8e
	ld hl,0e1d6h		;9d90
	ld de,0e1d7h		;9d93
	ld (hl),000h		;9d96
	ld bc,00005h		;9d98
	ldir		;9d9b
	jr L_9D54		;9d9d
L_9D9F:
	ld b,a			;9d9f
	ld a,00ah		;9da0
L_9DA2:
	ld hl,0e1d8h		;9da2
	inc (hl)			;9da5
	cp (hl)			;9da6
	jr nz,L_9DB4		;9da7
	ld (hl),000h		;9da9
	dec hl			;9dab
	inc (hl)			;9dac
	cp (hl)			;9dad
	jr nz,L_9DB4		;9dae
	ld (hl),000h		;9db0
	dec hl			;9db2
	inc (hl)			;9db3
L_9DB4:
	djnz L_9DA2		;9db4
	jr L_9D54		;9db6
L_9DB8:
	ld a,(0e21ch)		;9db8
	or a			;9dbb
	ret nz			;9dbc
	ld a,(0e247h)		;9dbd
	or a			;9dc0
	ret z			;9dc1
	ld hl,0e1d5h		;9dc2
	dec (hl)			;9dc5
	ret nz			;9dc6
	ld (hl),03ch		;9dc7
	ld a,0b7h		;9dc9
	dec hl			;9dcb
	dec (hl)			;9dcc
	cp (hl)			;9dcd
	jr c,L_9DEA		;9dce
	ld (hl),0c1h		;9dd0
	dec hl			;9dd2
	dec (hl)			;9dd3
	cp (hl)			;9dd4
	jr c,L_9DEA		;9dd5
	ld (hl),0bdh		;9dd7
	dec hl			;9dd9
	dec hl			;9dda
	dec (hl)			;9ddb
	cp (hl)			;9ddc
	jr c,L_9DEA		;9ddd
	ld (hl),0c1h		;9ddf
	dec hl			;9de1
	dec (hl)			;9de2
	ld a,0b8h		;9de3
	cp (hl)			;9de5
	jr nz,L_9DEA		;9de6
	ld (hl),0c4h		;9de8
L_9DEA:
	ld a,(0e1d0h)		;9dea
	sub 0c3h		;9ded
	jr z,L_9DFE		;9def
L_9DF1:
	ld hl,0e1d0h		;9df1
	ld de,01867h		;9df4
	ld bc,00005h		;9df7
	call L_B1C3		;9dfa
	ret			;9dfd
L_9DFE:
	call L_9BCF		;9dfe
	ld a,0b8h		;9e01
	ld (0e1d1h),a		;9e03
	ld (0e1d3h),a		;9e06
	ld (0e1d4h),a		;9e09
	jr L_9DF1		;9e0c
L_9E0E:
	ld ix,0e346h		;9e0e
	dec (ix+000h)		;9e12
	ret nz			;9e15
	ld a,(ix+001h)		;9e16
	ld (ix+000h),a		;9e19
	call L_9E74		;9e1c
	ld iy,0e346h		;9e1f
	ld e,(iy+002h)		;9e23
	ld d,000h		;9e26
	ld (iy+001h),009h		;9e28
	xor a			;9e2c
	cp (iy+002h)		;9e2d
	jr nz,L_9E36		;9e30
	ld (iy+000h),060h		;9e32
L_9E36:
	ld hl,0a33eh		;9e36
	add hl,de			;9e39
	ld de,00640h		;9e3a
	ld b,00eh		;9e3d
L_9E3F:
	push bc			;9e3f
	push de			;9e40
	push hl			;9e41
	push ix		;9e42
	ld bc,00008h		;9e44
	call L_B1C3		;9e47
	pop ix		;9e4a
	pop hl			;9e4c
	ld de,00012h		;9e4d
	add hl,de			;9e50
	ex de,hl			;9e51
	pop hl			;9e52
	ld bc,00008h		;9e53
	add hl,bc			;9e56
	ex de,hl			;9e57
	pop bc			;9e58
	djnz L_9E3F		;9e59
	ld iy,0e346h		;9e5b
	ld a,(iy+002h)		;9e5f
	inc (iy+002h)		;9e62
	ld a,00ah		;9e65
	cp (iy+002h)		;9e67
	ret nz			;9e6a
	ld (ix+000h),03ch		;9e6b
	ld (iy+002h),000h		;9e6f
	ret			;9e73
L_9E74:
	ld a,(0e348h)		;9e74
	cp 003h		;9e77
	jr nc,L_9E8F		;9e79
	ld hl,0e2b1h		;9e7b
	ld (hl),000h		;9e7e
	ld hl,0e2b5h		;9e80
	ld (hl),000h		;9e83
	ld hl,0e2b9h		;9e85
	ld (hl),000h		;9e88
	ld hl,0e2bdh		;9e8a
	ld (hl),000h		;9e8d
L_9E8F:
	sub 009h		;9e8f
	cpl			;9e91
	inc a			;9e92
	add a,0b3h		;9e93
	ld iy,0e2aeh		;9e95
	ld (iy+000h),a		;9e99
	ld (iy+003h),006h		;9e9c
	ld a,(0e348h)		;9ea0
	cp 006h		;9ea3
	ret c			;9ea5
	sub 009h		;9ea6
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
L_9EE6:
	ld a,(0e225h)		;9ee6
	ld (0e226h),a		;9ee9
	ld a,(0e222h)		;9eec
	and 007h		;9eef
	ld (0e224h),a		;9ef1
	ld a,(0e222h)		;9ef4
	srl a		;9ef7
	srl a		;9ef9
	srl a		;9efb
	and 007h		;9efd
	ld (0e225h),a		;9eff
	cp 002h		;9f02
	jr nc,L_9F10		;9f04
	ld a,(0e226h)		;9f06
	cp 002h		;9f09
	call nc,L_8DDE		;9f0b
	jr L_9F13		;9f0e
L_9F10:
	call L_8DDE		;9f10
L_9F13:
	ld a,001h		;9f13
	call L_B32E		;9f15
	call L_89F3		;9f18
	xor a			;9f1b
	ld (0e1ceh),a		;9f1c
	ld ix,0e2bfh		;9f1f
	ld de,0a962h		;9f23
	ld (ix+012h),e		;9f26
	ld (ix+013h),d		;9f29
	ld hl,0e247h		;9f2c
	ld (hl),003h		;9f2f
	ld hl,0e2a6h		;9f31
	ld de,0e2a7h		;9f34
	ld bc,00007h		;9f37
	ld (hl),000h		;9f3a
	ldir		;9f3c
	ld hl,0e26ah		;9f3e
	ld de,0e26bh		;9f41
	ld bc,0002fh		;9f44
	ld (hl),000h		;9f47
	ldir		;9f49
	ld hl,0e32fh		;9f4b
	res 7,(hl)		;9f4e
	ld hl,0e2a5h		;9f50
	ld (hl),00ch		;9f53
	ld hl,0e2adh		;9f55
	ld hl,0e2a9h		;9f58
	ld (hl),006h		;9f5b
	ld hl,0e2adh		;9f5d
	ld (hl),00fh		;9f60
	ld hl,0e26ah		;9f62
	ld de,01b00h		;9f65
	ld bc,00044h		;9f68
	call L_B1C3		;9f6b
	ld a,(0e225h)		;9f6e
	cp 002h		;9f71
	call nc,L_ACB6		;9f73
	call escoge_decorado_de_la_escena		;9f76
	ld a,(0e225h)		;9f79
	sla a		;9f7c
	ld e,a			;9f7e
	ld d,000h		;9f7f
	ld hl,0aeb4h		;9f81
	add hl,de			;9f84
	ld e,(hl)			;9f85
	inc hl			;9f86
	ld d,(hl)			;9f87
	ex de,hl			;9f88
	ld de,L_9F8E		;9f89
	push de			;9f8c
	jp (hl)			;9f8d
L_9F8E:
	ld a,001h		;9f8e
	ret			;9f90
escoge_decorado_de_la_escena:
	ld a,(0e222h)		;9f91   ; Los BITS 6-7 del LFSR de pantalla, doblados, son el indice de las dos tablas del decorado: 0xA086 (el juego de 16 tiles) y 0xA08E (el layout). O sea que de los ocho bits del mundo, dos eligen el paisaje, tres el tipo de escena y tres la variante
	and 0c0h		;9f94
	ld b,000h		;9f96
	rl a		;9f98
	rl b		;9f9a
	rl a		;9f9c
	rl b		;9f9e
	sla b		;9fa0
	ld e,b			;9fa2
	ld d,000h		;9fa3
	ld a,(0e224h)		;9fa5
	bit 2,a		;9fa8
	jr nz,L_9FAD		;9faa
	inc b			;9fac
L_9FAD:
	ld a,b			;9fad
	ld (0e223h),a		;9fae
	push de			;9fb1
	push de			;9fb2
	ld hl,0a086h		;9fb3
	add hl,de			;9fb6
	ld e,(hl)			;9fb7
	inc hl			;9fb8
	ld d,(hl)			;9fb9
	ex de,hl			;9fba
	ld de,00380h		;9fbb
	ld bc,00080h		;9fbe
	call L_B1C3		;9fc1
	ld bc,00010h		;9fc4
	ld hl,00380h		;9fc7
	ld de,00400h		;9fca
	call L_B1D1		;9fcd
	pop de			;9fd0
	ld hl,0a08eh		;9fd1
	add hl,de			;9fd4
	ld e,(hl)			;9fd5
	inc hl			;9fd6
	ld d,(hl)			;9fd7
	ex de,hl			;9fd8
	call L_8D70		;9fd9
	pop de			;9fdc
	ld a,e			;9fdd
	ld (0e227h),a		;9fde
	ld a,d			;9fe1
	ld (0e228h),a		;9fe2
	ret			;9fe5
L_9FE6:
	ld b,(hl)			;9fe6
	inc hl			;9fe7
	inc hl			;9fe8
L_9FE9:
	push bc			;9fe9
	ld e,(hl)			;9fea
	inc hl			;9feb
	ld d,(hl)			;9fec
	inc hl			;9fed
	ld bc,01800h		;9fee
	ex de,hl			;9ff1
	add hl,bc			;9ff2
	ex de,hl			;9ff3
	ld bc,00001h		;9ff4
	push hl			;9ff7
	call L_B1C3		;9ff8
	pop hl			;9ffb
	inc hl			;9ffc
	inc hl			;9ffd
	pop bc			;9ffe
	djnz L_9FE9		;9fff
	ret			;a001
L_A002:
	ld hl,097feh		;a002
	ld de,03c20h		;a005
	ld bc,00020h		;a008
	call L_B1C3		;a00b
	ld hl,097feh		;a00e
	ld de,03d40h		;a011
	ld bc,00020h		;a014
	call L_B1C3		;a017
	ld hl,097feh		;a01a
	ld de,03e60h		;a01d
	ld bc,00020h		;a020
	call L_B1C3		;a023
	ld hl,0e227h		;a026
	ld e,(hl)			;a029
	inc hl			;a02a
	ld d,(hl)			;a02b
	ld hl,0a086h		;a02c
	add hl,de			;a02f
	ld e,(hl)			;a030
	inc hl			;a031
	ld d,(hl)			;a032
	ex de,hl			;a033
	ld de,00068h		;a034
	add hl,de			;a037
	ld de,03c28h		;a038
	ld bc,00008h		;a03b
	push hl			;a03e
	call L_B1C3		;a03f
	pop hl			;a042
	ld de,00008h		;a043
	add hl,de			;a046
	ld de,03c38h		;a047
	ld bc,00008h		;a04a
	push hl			;a04d
	call L_B1C3		;a04e
	pop hl			;a051
	ld de,00008h		;a052
	add hl,de			;a055
	ld de,03d48h		;a056
	ld bc,00008h		;a059
	push hl			;a05c
	call L_B1C3		;a05d
	pop hl			;a060
	ld bc,00002h		;a061
	ld hl,03d40h		;a064
	ld de,03d50h		;a067
	call L_B1D1		;a06a
	ld bc,00002h		;a06d
	ld hl,03c20h		;a070
	ld de,03e70h		;a073
	call L_B1D1		;a076
	ld bc,00002h		;a079
	ld hl,03c30h		;a07c
	ld de,03e60h		;a07f
	call L_B1D1		;a082
	ret			;a085

; ----------------------------------------------------------------------
; DATOS tabla_juegos_de_tiles: Cuatro palabras: punteros a los cuatro juegos de 16 tiles de arriba, en el orden [0]=0x96FE [1]=0x977E [2]=0x967E [3]=0x95FE. La lee 0x9FB3 con el indice en DE, y ese indice son los BITS 6-7 DEL LFSR DE PANTALLA, que 0x9F91-0x9FA3 extrae y dobla: el mundo elige decorado con dos bits
;   0xa086..0xa08e  (8 bytes)
; DATOS tabla_de_layouts: Cuatro palabras: punteros a los cuatro layouts de escena de abajo, [0]=0xA1EE [1]=0xA29A [2]=0xA13E [3]=0xA096. La lee 0x9FD1 y el layout lo consume L_8D70
;   0xa08e..0xa096  (8 bytes)
; DATOS layout_escena_3: Layout de escena (entrada [3]): 0x71 + 0x20 + 5 bytes y un guion de 4 celdas que cierra en 0xA13E clavado
;   0xa096..0xa13e  (168 bytes)
; DATOS layout_escena_2: Layout de escena (entrada [2]), guion de 6 celdas, cierra en 0xA1EE
;   0xa13e..0xa1ee  (176 bytes)
; DATOS layout_escena_0: Layout de escena (entrada [0]), guion de 5 celdas, cierra en 0xA29A
;   0xa1ee..0xa29a  (172 bytes)
; DATOS layout_escena_1: Layout de escena (entrada [1]), guion de 3 celdas, cierra en 0xA33E, que es justo donde empieza la tabla siguiente
;   0xa29a..0xa33e  (164 bytes)
; DATOS tabla_patrones_14x18: Catorce registros de 18 bytes. El bucle de 0x9E3F copia de cada registro un patron de tile de 8 bytes (la columna dentro del registro la elige DE) a la VRAM desde 0x0640, avanzando de registro en registro. 14 x 18 = 252 bytes, y cierra el hueco exacto
;   0xa33e..0xa43a  (252 bytes)
; ----------------------------------------------------------------------
	defb 0feh,096h,07eh,097h,07eh,096h,0feh,095h,0eeh,0a1h,09ah,0a2h,03eh,0a1h,096h,0a0h	; a086  ..~.~.......>...
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
	defb 007h,001h,010h,000h,038h,001h,011h,000h,038h,0eeh,0efh,038h,038h,038h,0d8h,038h	; a136  ....8...8..888.8
	defb 0e8h,038h,038h,038h,0e6h,038h,0dch,0ddh,0deh,038h,0e0h,0e1h,038h,0efh,0dbh,038h	; a146  .888.8...8..8..8
	defb 038h,0deh,0dfh,0e0h,038h,0e1h,038h,0e6h,0e7h,0edh,038h,0d8h,0d9h,0dah,038h,0dbh	; a156  8...8.8...8...8.
	defb 038h,038h,0e7h,0e8h,038h,038h,038h,0eah,0ebh,0ech,038h,0d8h,0d9h,038h,038h,0dbh	; a166  88..888...8..88.
	defb 038h,038h,0dch,0ddh,0deh,0dfh,038h,038h,038h,038h,038h,038h,038h,0dah,0dbh,038h	; a176  88....8888888..8
	defb 0e6h,0e7h,0e8h,038h,0dch,0dch,038h,0ddh,038h,070h,071h,072h,073h,074h,075h,076h	; a186  ...8..8.8pqrstuv
	defb 077h,078h,079h,07ah,07bh,07ch,07dh,07eh,07fh,08fh,08eh,08dh,08ch,08bh,08ah,089h	; a196  wxyz{|}~........
	defb 088h,087h,086h,085h,084h,083h,082h,081h,080h,008h,008h,008h,008h,008h,008h,008h	; a1a6  ................
	defb 000h,008h,008h,008h,008h,008h,000h,008h,008h,008h,008h,000h,008h,008h,008h,008h	; a1b6  ................
	defb 008h,000h,008h,008h,008h,008h,008h,008h,008h,007h,005h,004h,005h,007h,006h,000h	; a1c6  ................
	defb 005h,001h,012h,000h,006h,001h,013h,000h,019h,001h,017h,000h,01ah,001h,016h,000h	; a1d6  ................
	defb 00ch,001h,015h,000h,013h,001h,011h,000h,0efh,038h,038h,0eeh,038h,038h,0ech,0edh	; a1e6  .........88.88..
	defb 038h,038h,0e6h,038h,038h,0ddh,038h,038h,038h,0deh,0dfh,0e0h,038h,0e1h,038h,0e2h	; a1f6  88.88.888...8.8.
	defb 0e3h,038h,038h,0e4h,0e5h,038h,038h,0e6h,0e7h,038h,0d8h,0d9h,0dah,038h,0dbh,0dch	; a206  .88..88..8...8..
	defb 0ddh,038h,038h,0deh,0dfh,038h,0e0h,0e1h,0e2h,038h,0e3h,038h,0e4h,0e5h,0e6h,038h	; a216  .88..8...8.8...8
	defb 0dch,0ddh,0dfh,038h,0e6h,0d8h,038h,038h,038h,038h,038h,038h,0d8h,0d9h,0dah,038h	; a226  ...8..888888...8
	defb 0dbh,0dch,0ddh,038h,0deh,0deh,0dfh,038h,0e0h,070h,071h,072h,073h,074h,075h,076h	; a236  ...8...8.pqrstuv
	defb 077h,078h,079h,07ah,07bh,07ch,07dh,07eh,07fh,08fh,08eh,08dh,08ch,08bh,08ah,089h	; a246  wxyz{|}~........
	defb 088h,087h,086h,085h,084h,083h,082h,081h,080h,008h,008h,008h,008h,000h,008h,008h	; a256  ................
	defb 008h,008h,008h,000h,008h,008h,008h,008h,008h,008h,008h,008h,008h,008h,000h,008h	; a266  ................
	defb 008h,008h,008h,008h,000h,008h,008h,008h,008h,004h,005h,00ah,005h,004h,005h,000h	; a276  ................
	defb 002h,001h,012h,000h,003h,001h,013h,000h,01ch,001h,017h,000h,01dh,001h,016h,000h	; a286  ................
	defb 014h,001h,010h,000h,038h,038h,0e8h,038h,038h,0e8h,0e9h,038h,0eah,038h,038h,038h	; a296  ....88.88..8.888
	defb 0ebh,0ech,038h,038h,038h,0edh,0eeh,0eeh,038h,0efh,038h,0d8h,0d9h,038h,0dah,0dbh	; a2a6  ..888...8.8..8..
	defb 0dch,038h,0dch,0ddh,038h,038h,0deh,0dfh,038h,038h,0e0h,0e1h,038h,0d8h,038h,0d9h	; a2b6  .8..88..88..8.8.
	defb 0dah,038h,0dah,0dbh,038h,038h,0dch,0ddh,0deh,038h,0dfh,0e2h,038h,0e1h,038h,0e4h	; a2c6  .8..88...8..8.8.
	defb 0e5h,0e6h,038h,038h,038h,038h,038h,038h,0d9h,0dah,038h,0dbh,038h,0e6h,0e7h,0dah	; a2d6  ..888888..8.8...
	defb 038h,038h,0dah,0dbh,038h,070h,071h,072h,073h,074h,075h,076h,077h,078h,079h,07ah	; a2e6  88..8pqrstuvwxyz
	defb 07bh,07ch,07dh,07eh,07fh,08fh,08eh,08dh,08ch,08bh,08ah,089h,088h,087h,086h,085h	; a2f6  {|}~............
	defb 084h,083h,082h,081h,080h,008h,008h,008h,008h,008h,008h,000h,008h,008h,008h,008h	; a306  ................
	defb 008h,000h,008h,008h,008h,008h,008h,008h,000h,008h,008h,008h,008h,008h,000h,008h	; a316  ................
	defb 008h,008h,008h,008h,008h,006h,005h,006h,005h,006h,003h,000h,018h,001h,010h,000h	; a326  ................
	defb 007h,001h,011h,000h,005h,001h,010h,000h,000h,0f8h,088h,081h,089h,0f9h,000h,000h	; a336  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0e7h,024h,0e7h	; a346  ..............$.
	defb 004h,004h,000h,000h,003h,007h,00dh,019h,03fh,061h,0c1h,000h,000h,000h,000h,0b6h	; a356  ........?a......
	defb 092h,09eh,002h,01eh,000h,000h,01fh,000h,03ch,020h,020h,020h,03ch,000h,000h,002h	; a366  ........<   <...
	defb 000h,072h,042h,042h,000h,000h,000h,000h,0ffh,080h,088h,088h,088h,088h,088h,000h	; a376  .rBB............
	defb 000h,001h,001h,079h,049h,079h,008h,078h,000h,000h,083h,086h,08ch,098h,0b0h,0e0h	; a386  ...yIy.x........
	defb 0c0h,000h,000h,002h,00fh,0e2h,022h,023h,000h,000h,000h,000h,0ffh,000h,08fh,088h	; a396  ......"#........
	defb 08fh,081h,08fh,000h,000h,001h,083h,001h,001h,083h,000h,000h,000h,000h,0f0h,000h	; a3a6  ................
	defb 011h,011h,011h,011h,011h,000h,000h,01eh,012h,01eh,002h,09eh,000h,000h,000h,000h	; a3b6  ................
	defb 000h,000h,0f1h,011h,011h,011h,0f1h,000h,000h,03ch,024h,03ch,024h,03ch,000h,000h	; a3c6  .........<$<$<..
	defb 000h,000h,000h,000h,010h,090h,050h,030h,010h,000h,000h,078h,008h,078h,040h,078h	; a3d6  ......P0...x.x@x
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h,003h,001h	; a3e6  ................
	defb 001h,083h,080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,01eh	; a3f6  ................
	defb 012h,01eh,002h,09eh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; a406  ................
	defb 000h,03ch,024h,03ch,024h,03ch,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; a416  .<$<$<..........
	defb 000h,000h,000h,048h,048h,078h,008h,008h,000h,000h,000h,000h,000h,000h,000h,000h	; a426  ...HHx..........
	defb 000h,000h,000h,000h	; a436  ....

; ======================================================================
; CODIGO 0xa43a..0xa61a  (480 bytes)
; ======================================================================


L_A43A:
	ld hl,0e18ah		;a43a
	ld de,0e18bh		;a43d
	ld (hl),000h		;a440
	ld bc,0003fh		;a442
	ldir		;a445
	ret			;a447
L_A448:
	push de			;a448
	push iy		;a449
	push bc			;a44b
	ld a,007h		;a44c
	cp h			;a44e
	jr nc,L_A457		;a44f
	ld e,010h		;a451
	ld d,000h		;a453
	add iy,de		;a455
L_A457:
	ld e,c			;a457
	ld d,000h		;a458
	add iy,de		;a45a
	ld a,h			;a45c
	and 007h		;a45d
	ld b,a			;a45f
	inc b			;a460
	xor a			;a461
	scf			;a462
L_A463:
	rra			;a463
	djnz L_A463		;a464
	or (iy+000h)		;a466
	ld (iy+000h),a		;a469
	pop bc			;a46c
	pop iy		;a46d
	pop de			;a46f
	ret			;a470
L_A471:
	bit 7,(ix+000h)		;a471
	ret z			;a475
	push ix		;a476
	call L_A43A		;a478
	ld b,014h		;a47b
	ld hl,0a61ah		;a47d
	ld a,(0e1cbh)		;a480
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
	bit 7,(ix+016h)		;a49b
	jr z,L_A4A8		;a49f
	ld a,d			;a4a1
	cpl			;a4a2
	ld d,a			;a4a3
	ld a,e			;a4a4
	cpl			;a4a5
	ld e,a			;a4a6
	inc de			;a4a7
L_A4A8:
	add hl,de			;a4a8
	djnz L_A4A8		;a4a9
	bit 7,(ix+016h)		;a4ab
	jr z,L_A4B5		;a4af
	ld a,h			;a4b1
	sub 00fh		;a4b2
	ld h,a			;a4b4
L_A4B5:
	ld ix,0e276h		;a4b5
	ld (ix+001h),h		;a4b9
	ld (ix+000h),033h		;a4bc
	ld (ix+003h),001h		;a4c0
	ld hl,00000h		;a4c4
	add hl,de			;a4c7
	ld c,000h		;a4c8
	ld b,010h		;a4ca
	ld iy,0e18ah		;a4cc
L_A4D0:
	ld a,h			;a4d0
	and 00fh		;a4d1
	ld h,a			;a4d3
	call L_A448		;a4d4
	add hl,de			;a4d7
	inc c			;a4d8
	djnz L_A4D0		;a4d9
	ld a,h			;a4db
	ld ix,0e32fh		;a4dc
	bit 7,(ix+016h)		;a4e0
	jr z,L_A4E8		;a4e4
	sub 00fh		;a4e6
L_A4E8:
	ld ix,0e276h		;a4e8
	ld iy,0e27ah		;a4ec
	ld (iy+003h),001h		;a4f0
	add a,(ix+001h)		;a4f4
	ld (iy+001h),a		;a4f7
	ld a,(ix+000h)		;a4fa
	add a,010h		;a4fd
	ld (iy+000h),a		;a4ff
	ld a,h			;a502
	sla a		;a503
	ld ix,0e32fh		;a505
	bit 7,(ix+016h)		;a509
	jr z,L_A511		;a50d
	sub 01eh		;a50f
L_A511:
	ld ix,0e276h		;a511
	ld iy,0e27eh		;a515
	add a,(ix+001h)		;a519
	ld (iy+001h),a		;a51c
	ld a,(ix+000h)		;a51f
	add a,020h		;a522
	ld (iy+000h),a		;a524
	pop hl			;a527
	inc hl			;a528
	ld b,(hl)			;a529
	push hl			;a52a
	ld h,(iy+001h)		;a52b
	ld l,000h		;a52e
L_A530:
	add hl,de			;a530
	djnz L_A530		;a531
	ld a,h			;a533
	ld ix,0e32fh		;a534
	bit 7,(ix+016h)		;a538
	jr z,L_A540		;a53c
	add a,012h		;a53e
L_A540:
	ld (0e1cdh),a		;a540
	pop hl			;a543
	ld c,(hl)			;a544
	inc hl			;a545
	ld a,(hl)			;a546
	ld (0e1e2h),a		;a547
	ld hl,0e1cch		;a54a
	ld (hl),c			;a54d
	ld b,000h		;a54e
	push bc			;a550
	ld hl,0e18ah		;a551
	ld de,0e1aah		;a554
	ldir		;a557
	pop bc			;a559
	ld hl,0e19ah		;a55a
	ld de,0e1bah		;a55d
	ldir		;a560
	ld iy,0e27eh		;a562
	ld (iy+003h),001h		;a566
	ld a,(0e221h)		;a56a
	or a			;a56d
	jr z,L_A57F		;a56e
	ld hl,0e279h		;a570
	ld (hl),000h		;a573
	ld hl,0e27dh		;a575
	ld (hl),00fh		;a578
	ld hl,0e281h		;a57a
	ld (hl),00fh		;a57d
L_A57F:
	ld a,(0e1cbh)		;a57f
	cp 002h		;a582
	jr nc,L_A594		;a584
	ld a,006h		;a586
	ld hl,0e26ah		;a588
	ld de,01b00h		;a58b
	ld bc,00054h		;a58e
	call L_B1C3		;a591
L_A594:
	ld hl,0e18ah		;a594
	ld de,039e0h		;a597
	ld bc,00020h		;a59a
	call L_B1C3		;a59d
	ld hl,0e1aah		;a5a0
	ld de,03b00h		;a5a3
	ld bc,00020h		;a5a6
	call L_B1C3		;a5a9
	pop ix		;a5ac
	ld b,004h		;a5ae
	ld c,004h		;a5b0
	push ix		;a5b2
	ld ix,0e23eh		;a5b4
	ld (ix+000h),005h		;a5b8
	ld a,(0e1cdh)		;a5bc
	sub b			;a5bf
	ld (ix+001h),a		;a5c0
	ld a,(0e1cdh)		;a5c3
	add a,c			;a5c6
	ld (ix+002h),a		;a5c7
	pop ix		;a5ca
	ld a,(0e2ebh)		;a5cc
	bit 7,a		;a5cf
	call nz,L_A5F9		;a5d1
	ld hl,0e1cbh		;a5d4
	bit 0,(ix+016h)		;a5d7
	jr nz,L_A5EF		;a5db
	dec (hl)			;a5dd
	ld a,001h		;a5de
	cp (hl)			;a5e0
	ret nz			;a5e1
	set 0,(ix+016h)		;a5e2
	ld a,(ix+016h)		;a5e6
	xor 080h		;a5e9
	ld (ix+016h),a		;a5eb
	ret			;a5ee
L_A5EF:
	inc (hl)			;a5ef
	ld a,020h		;a5f0
	cp (hl)			;a5f2
	ret nz			;a5f3
	res 0,(ix+016h)		;a5f4
	ret			;a5f8
L_A5F9:
	ld iy,0e2a2h		;a5f9
	ld hl,0e2dbh		;a5fd
	ld a,(0e1cdh)		;a600
	bit 7,(hl)		;a603
	jr z,L_A609		;a605
	add a,003h		;a607
L_A609:
	sub 00ah		;a609
	ld (iy+001h),a		;a60b
	ld a,(0e1cch)		;a60e
	add a,05dh		;a611
	ld (iy+000h),a		;a613
	ld (0e1cch),a		;a616
	ret			;a619

; ----------------------------------------------------------------------
; DATOS tabla_de_registros_de_4: Treinta y tres registros de 4 bytes: 0xA47D los indexa con (0xE1CB)*4. El primer byte crece a saltos de 7 (0x00, 0x07, 0x0E, 0x15...) y los otros tres van casi fijos (01 10 00). Acaba justo donde empieza su consumidor, el manejador 0xA69E
;   0xa61a..0xa69e  (132 bytes)
; ----------------------------------------------------------------------
	defb 000h,001h,010h,000h,007h,001h,010h,000h,00eh,001h,010h,000h,015h,001h,010h,000h	; a61a  ................
	defb 01ch,001h,010h,000h,024h,001h,010h,000h,02bh,001h,00fh,001h,033h,001h,00fh,001h	; a62a  ....$...+...3...
	defb 03ah,001h,00fh,001h,041h,001h,00fh,001h,049h,002h,00fh,001h,055h,002h,00eh,002h	; a63a  :...A...I...U...
	defb 05ch,002h,00eh,002h,061h,002h,00dh,003h,069h,002h,00dh,003h,072h,002h,00ch,004h	; a64a  \...a...i...r...
	defb 07ch,002h,00bh,005h,080h,002h,00bh,005h,083h,002h,00bh,005h,089h,002h,00ah,006h	; a65a  |...............
	defb 08dh,002h,00ah,006h,091h,002h,00ah,006h,098h,002h,009h,008h,09ch,002h,009h,008h	; a66a  ................
	defb 0a0h,002h,009h,008h,0a6h,003h,008h,00bh,0aah,003h,008h,00bh,0aeh,003h,008h,00bh	; a67a  ................
	defb 0b5h,004h,007h,00fh,0b9h,004h,007h,00fh,0bdh,004h,007h,00fh,0c5h,006h,006h,010h	; a68a  ................
	defb 0c9h,009h,006h,010h	; a69a  ....

; ======================================================================
; CODIGO 0xa69e..0xaa73  (981 bytes)
; ======================================================================


L_A69E:
	ld hl,0e2a3h		;a69e
	ld iy,0e292h		;a6a1
	ld a,(iy+001h)		;a6a5
	add a,008h		;a6a8
	ld b,a			;a6aa
	push ix		;a6ab
	ld ix,0e241h		;a6ad
	ld (ix+000h),009h		;a6b1
	ld a,b			;a6b5
	sub 00ah		;a6b6
	ld (ix+001h),a		;a6b8
	ld a,b			;a6bb
	add a,00ah		;a6bc
	ld (ix+002h),a		;a6be
	pop ix		;a6c1
	ld a,(iy+001h)		;a6c3
	cp (hl)			;a6c6
	jr c,L_A6EA		;a6c7
	jr z,L_A70A		;a6c9
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
L_A6EA:
	res 7,(ix+006h)		;a6ea
	ld de,0af52h		;a6ee
	ld (ix+00ch),e		;a6f1
	ld (ix+00dh),d		;a6f4
	set 5,(ix+000h)		;a6f7
	set 0,(ix+006h)		;a6fb
	ld d,000h		;a6ff
	ld e,0c0h		;a701
	ld (ix+008h),d		;a703
	ld (ix+007h),e		;a706
	ret			;a709
L_A70A:
	res 5,(ix+000h)		;a70a
	res 0,(ix+006h)		;a70e
	ld (ix+00fh),000h		;a712
	ld (ix+00eh),001h		;a716
	ld iy,0e2a2h		;a71a
	ld de,00000h		;a71e
	ld (ix+008h),d		;a721
	ld (ix+007h),e		;a724
	ret			;a727
L_A728:
	ld hl,0e136h		;a728
	ld iy,0e282h		;a72b
	ld a,(0e224h)		;a72f
	cp 004h		;a732
	jr nc,L_A741		;a734
	inc (hl)			;a736
	bit 3,(hl)		;a737
	jr nz,L_A741		;a739
	ld (iy+000h),06eh		;a73b
	jr L_A745		;a73f
L_A741:
	ld (iy+000h),06fh		;a741
L_A745:
	ld a,(iy+001h)		;a745
	add a,008h		;a748
	ld b,a			;a74a
	push ix		;a74b
	ld ix,0e232h		;a74d
	ld (ix+000h),001h		;a751
	ld a,b			;a755
	sub 009h		;a756
	ld (ix+001h),a		;a758
	ld a,b			;a75b
	add a,009h		;a75c
	ld (ix+002h),a		;a75e
	pop ix		;a761
	ld a,(0e224h)		;a763
	and 003h		;a766
	ret z			;a768
	ld ix,0e286h		;a769
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
	ld (ix+003h),006h		;a789
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
	ld a,(0e224h)		;a7a5
	cp 003h		;a7a8
	ret c			;a7aa
	ld ix,0e28ah		;a7ab
	ld a,(0e137h)		;a7af
	sla a		;a7b2
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
	ld (ix+000h),001h		;a7d7
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
	ld hl,0e286h		;a7ef
	ld (hl),000h		;a7f2
	ret			;a7f4
L_A7F5:
	push ix		;a7f5
	ld ix,0e282h		;a7f7
	ld a,(ix+002h)		;a7fb
	ld iy,0e286h		;a7fe
	ld (iy+002h),a		;a802
	ld iy,0e28ah		;a805
	ld (iy+002h),a		;a809
	ld c,010h		;a80c
	ld d,005h		;a80e
	ld e,005h		;a810
	cp 0fch		;a812
	jr nz,L_A822		;a814
	ld a,c			;a816
	add a,00bh		;a817
	ld c,a			;a819
	ld a,d			;a81a
	add a,00fh		;a81b
	ld d,a			;a81d
	ld a,e			;a81e
	add a,00fh		;a81f
	ld e,a			;a821
L_A822:
	push ix		;a822
	ld ix,0e229h		;a824
	ld (ix+000h),004h		;a828
	ld a,050h		;a82c
	sub 000h		;a82e
	ld (ix+001h),a		;a830
	ld a,050h		;a833
	add a,c			;a835
	ld (ix+002h),a		;a836
	pop ix		;a839
	push ix		;a83b
	ld ix,0e22ch		;a83d
	ld (ix+000h),004h		;a841
	ld a,06fh		;a845
	sub 000h		;a847
	ld (ix+001h),a		;a849
	ld a,06fh		;a84c
	add a,d			;a84e
	ld (ix+002h),a		;a84f
	pop ix		;a852
	push ix		;a854
	ld ix,0e22fh		;a856
	ld (ix+000h),004h		;a85a
	ld a,088h		;a85e
	sub 000h		;a860
	ld (ix+001h),a		;a862
	ld a,088h		;a865
	add a,e			;a867
	ld (ix+002h),a		;a868
	pop ix		;a86b
	pop ix		;a86d
	ret			;a86f
L_A870:
	ld ix,0e2bfh		;a870
	ld (ix+010h),003h		;a874
	ld hl,001d0h		;a878
	ld de,(0e133h)		;a87b
	ld d,000h		;a87f
	or a			;a881
	sbc hl,de		;a882
	ld de,01800h		;a884
	add hl,de			;a887
	ex de,hl			;a888
	ld hl,0b0d0h		;a889
	ld bc,(0e133h)		;a88c
	call L_B1C3		;a890
	ld hl,0e133h		;a893
	ld a,008h		;a896
	sub (hl)			;a898
	ld e,a			;a899
	ld d,000h		;a89a
	ld hl,0b0d8h		;a89c
	add hl,de			;a89f
	ld de,019d0h		;a8a0
	ld bc,(0e133h)		;a8a3
	call L_B1C3		;a8a7
	ld hl,001f0h		;a8aa
	ld de,(0e133h)		;a8ad
	ld d,000h		;a8b1
	or a			;a8b3
	sbc hl,de		;a8b4
	ld de,01800h		;a8b6
	add hl,de			;a8b9
	ex de,hl			;a8ba
	ld hl,0b0e0h		;a8bb
	ld bc,(0e133h)		;a8be
	call L_B1C3		;a8c2
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
	call L_B1C3		;a8dc
	ld a,(0e132h)		;a8df
	cp 001h		;a8e2
	jp z,L_A923		;a8e4
	ld a,(0e133h)		;a8e7
	sla a		;a8ea
	sla a		;a8ec
	sla a		;a8ee
	sub 008h		;a8f0
	ld l,a			;a8f2
	sub 010h		;a8f3
	ld h,a			;a8f5
	push ix		;a8f6
	ld ix,0e22ch		;a8f8
	ld (ix+000h),003h		;a8fc
	ld a,088h		;a900
	sub l			;a902
	ld (ix+001h),a		;a903
	ld a,088h		;a906
	add a,h			;a908
	ld (ix+002h),a		;a909
	pop ix		;a90c
	ld hl,0e133h		;a90e
	dec (hl)			;a911
	ret nz			;a912
	ld (hl),001h		;a913
	ld a,001h		;a915
	ld (0e132h),a		;a917
	ld ix,0e2bfh		;a91a
	ld (ix+010h),096h		;a91e
	ret			;a922
L_A923:
	ld a,(0e133h)		;a923
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
	inc (hl)			;a94d
	ld a,(hl)			;a94e
	cp 009h		;a94f
	ret c			;a951
	ld (hl),008h		;a952
	ld a,000h		;a954
	ld (0e132h),a		;a956
	ld ix,0e2bfh		;a959
	ld (ix+010h),044h		;a95d
	ret			;a961
L_A962:
	ld ix,0e2bfh		;a962
	ld (ix+010h),003h		;a966
	ld a,(0e132h)		;a96a
	cp 001h		;a96d
	jp z,L_A987		;a96f
	ld hl,0e133h		;a972
	dec (hl)			;a975
	ret nz			;a976
	ld (hl),001h		;a977
	ld a,001h		;a979
	ld (0e132h),a		;a97b
	ld ix,0e2bfh		;a97e
	ld (ix+010h),096h		;a982
	ret			;a986
L_A987:
	ld hl,0e133h		;a987
	inc (hl)			;a98a
	ld a,(hl)			;a98b
	cp 009h		;a98c
	ret c			;a98e
	ld (hl),008h		;a98f
	ld a,000h		;a991
	ld (0e132h),a		;a993
	ld ix,0e2bfh		;a996
	ld (ix+010h),044h		;a99a
	ret			;a99e
L_A99F:
	sla a		;a99f
	ld e,a			;a9a1
	ld d,000h		;a9a2
	add hl,de			;a9a4
	ld e,(hl)			;a9a5
	inc hl			;a9a6
	ld d,(hl)			;a9a7
	ex de,hl			;a9a8
	jp (hl)			;a9a9
L_A9AA:
	ld a,(0e222h)		;a9aa
	bit 7,a		;a9ad
	jr z,L_A9D0		;a9af
	push ix		;a9b1
	ld ix,0e241h		;a9b3
	ld (ix+000h),00ah		;a9b7
	ld a,0d8h		;a9bb
	sub 00ch		;a9bd
	ld (ix+001h),a		;a9bf
	ld a,0d8h		;a9c2
	add a,00ch		;a9c4
	ld (ix+002h),a		;a9c6
	pop ix		;a9c9
	call L_8D5D		;a9cb
	jr L_A9ED		;a9ce
L_A9D0:
	push ix		;a9d0
	ld ix,0e241h		;a9d2
	ld (ix+000h),00ah		;a9d6
	ld a,031h		;a9da
	sub 00ch		;a9dc
	ld (ix+001h),a		;a9de
	ld a,031h		;a9e1
	add a,00dh		;a9e3
	ld (ix+002h),a		;a9e5
	pop ix		;a9e8
	call L_8D4A		;a9ea
L_A9ED:
	push ix		;a9ed
	ld ix,0e22ch		;a9ef
	ld (ix+000h),002h		;a9f3
	ld a,07dh		;a9f7
	sub 000h		;a9f9
	ld (ix+001h),a		;a9fb
	ld a,07dh		;a9fe
	add a,00eh		;aa00
	ld (ix+002h),a		;aa02
	pop ix		;aa05
	ld hl,099cfh		;aa07
	ld de,039e0h		;aa0a
	ld bc,00020h		;aa0d
	call L_B1C3		;aa10
	ld hl,09a0fh		;aa13
	ld de,03c20h		;aa16
	ld bc,00020h		;aa19
	call L_B1C3		;aa1c
	ld hl,09a2fh		;aa1f
	ld de,03e60h		;aa22
	ld bc,00020h		;aa25
	call L_B1C3		;aa28
	ld hl,09a4fh		;aa2b
	ld de,03800h		;aa2e
	ld bc,00020h		;aa31
	call L_B1C3		;aa34
	ld bc,00002h		;aa37
	ld hl,039e0h		;aa3a
	ld de,03b10h		;aa3d
	call L_B1D1		;aa40
	ld bc,00002h		;aa43
	ld hl,039f0h		;aa46
	ld de,03b00h		;aa49
	call L_B1D1		;aa4c
	ld bc,00002h		;aa4f
	ld hl,03c20h		;aa52
	ld de,03d50h		;aa55
	call L_B1D1		;aa58
	ld bc,00002h		;aa5b
	ld hl,03c30h		;aa5e
	ld de,03d40h		;aa61
	call L_B1D1		;aa64
	call L_8D01		;aa67
	ld a,(0e224h)		;aa6a
	ld hl,0aec4h		;aa6d
	jp L_A99F		;aa70

; ----------------------------------------------------------------------
; DATOS sin identificar  0xaa73..0xaa74  (1 bytes)
; ----------------------------------------------------------------------
	defb 0c9h	; aa73  .

; ======================================================================
; CODIGO 0xaa74..0xacb4  (576 bytes)
; ======================================================================


L_AA74:
	ld hl,09989h		;aa74
	call L_B142		;aa77
	ld hl,0b040h		;aa7a
	call L_9FE6		;aa7d
	ld de,0e28eh		;aa80
	ld hl,0b010h		;aa83
	ld bc,00004h		;aa86
	ldir		;aa89
	ld de,0e319h		;aa8b
	ld hl,0b014h		;aa8e
	ld bc,00016h		;aa91
	ldir		;aa94
	ld de,0e319h		;aa96
	call L_9D30		;aa99
	push ix		;aa9c
	ld ix,0e23bh		;aa9e
	ld (ix+000h),006h		;aaa2
	ld a,0c3h		;aaa6
	sub 000h		;aaa8
	ld (ix+001h),a		;aaaa
	ld a,0c3h		;aaad
	add a,00fh		;aaaf
	ld (ix+002h),a		;aab1
	pop ix		;aab4
	ret			;aab6
L_AAB7:
	ld hl,0b0c2h		;aab7
	call L_9FE6		;aaba
	ld hl,09865h		;aabd
	call L_B142		;aac0
	ld de,0e28eh		;aac3
	ld hl,0b010h		;aac6
	ld bc,00004h		;aac9
	ldir		;aacc
	ld de,0e319h		;aace
	ld hl,0b014h		;aad1
	ld bc,00016h		;aad4
	ldir		;aad7
	ld hl,0e291h		;aad9
	ld (hl),00fh		;aadc
	ld de,0e319h		;aade
	call L_9D30		;aae1
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
L_AAFF:
	ld hl,0e186h		;aaff
	ld (hl),e			;ab02
	inc hl			;ab03
	ld (hl),d			;ab04
	ld a,(0e223h)		;ab05
	cp 000h		;ab08
	jr nz,L_AB11		;ab0a
	ld a,(de)			;ab0c
	rr a		;ab0d
	jr L_AB18		;ab0f
L_AB11:
	ld b,a			;ab11
	inc b			;ab12
	ld a,(de)			;ab13
L_AB14:
	rr a		;ab14
	djnz L_AB14		;ab16
L_AB18:
	ret nc			;ab18
	pop hl			;ab19
	ret			;ab1a
L_AB1B:
	ld de,0e21dh		;ab1b
	call L_AAFF		;ab1e
	ld hl,09850h		;ab21
	call L_B142		;ab24
	ld hl,0ae90h		;ab27
	ld de,02013h		;ab2a
	ld bc,00001h		;ab2d
	call L_B1C3		;ab30
	ld de,0e28eh		;ab33
	ld hl,0b010h		;ab36
	ld bc,00004h		;ab39
	ldir		;ab3c
	ld a,004h		;ab3e
	ld (0e188h),a		;ab40
	ld iy,0e28eh		;ab43
	ld (iy+001h),0c4h		;ab47
	ld (iy+003h),007h		;ab4b
	jr L_AB85		;ab4f
L_AB51:
	ld de,0e21eh		;ab51
	call L_AAFF		;ab54
	ld hl,0981eh		;ab57
	call L_B142		;ab5a
	ld hl,0ae92h		;ab5d
	ld de,02013h		;ab60
	ld bc,00001h		;ab63
	call L_B1C3		;ab66
	ld de,0e28eh		;ab69
	ld hl,0b010h		;ab6c
	ld bc,00004h		;ab6f
	ldir		;ab72
	ld a,003h		;ab74
	ld (0e188h),a		;ab76
	ld iy,0e28eh		;ab79
	ld (iy+001h),0c4h		;ab7d
	ld (iy+003h),00fh		;ab81
L_AB85:
	ld hl,0b0a8h		;ab85
	call L_9FE6		;ab88
	ld de,0e319h		;ab8b
	ld hl,0b014h		;ab8e
	ld bc,00016h		;ab91
	ldir		;ab94
	ld de,0e319h		;ab96
	call L_9D30		;ab99
	push ix		;ab9c
	ld ix,0e23bh		;ab9e
	ld (ix+000h),008h		;aba2
	ld a,0cbh		;aba6
	sub 009h		;aba8
	ld (ix+001h),a		;abaa
	ld a,0cbh		;abad
	add a,009h		;abaf
	ld (ix+002h),a		;abb1
	pop ix		;abb4
	ret			;abb6
L_ABB7:
	ld de,0e220h		;abb7
	call L_AAFF		;abba
	ld a,005h		;abbd
	ld (0e188h),a		;abbf
	ld hl,0b05ah		;abc2
	call L_9FE6		;abc5
	ld hl,098bbh		;abc8
	call L_B142		;abcb
	ld de,0e28eh		;abce
	ld hl,0b010h		;abd1
	ld bc,00004h		;abd4
	ldir		;abd7
	ld de,0e319h		;abd9
	ld hl,0b014h		;abdc
	ld bc,00016h		;abdf
	ldir		;abe2
	ld iy,0e28eh		;abe4
	ld (iy+001h),0c4h		;abe8
	ld (iy+003h),00fh		;abec
	ld de,0e319h		;abf0
	call L_9D30		;abf3
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
L_AC11:
	ld de,0e21fh		;ac11
	call L_AAFF		;ac14
	ld a,002h		;ac17
	ld (0e188h),a		;ac19
	ld hl,0b074h		;ac1c
	call L_9FE6		;ac1f
	ld hl,0989eh		;ac22
	call L_B142		;ac25
	ld de,0e28eh		;ac28
	ld hl,0b010h		;ac2b
	ld bc,00004h		;ac2e
	ldir		;ac31
	ld de,0e319h		;ac33
	ld hl,0b014h		;ac36
	ld bc,00016h		;ac39
	ldir		;ac3c
	ld iy,0e28eh		;ac3e
	ld (iy+001h),0c4h		;ac42
	ld (iy+003h),00fh		;ac46
	ld de,0e319h		;ac4a
	call L_9D30		;ac4d
	push ix		;ac50
	ld ix,0e23bh		;ac52
	ld (ix+000h),008h		;ac56
	ld a,0cbh		;ac5a
	sub 009h		;ac5c
	ld (ix+001h),a		;ac5e
	ld a,0cbh		;ac61
	add a,009h		;ac63
	ld (ix+002h),a		;ac65
	pop ix		;ac68
	ret			;ac6a
L_AC6B:
	ld hl,0b0fbh		;ac6b
	ld de,0200bh		;ac6e
	ld bc,00003h		;ac71
	call L_B1C3		;ac74
	call L_AE38		;ac77
	jr L_AC8B		;ac7a
L_AC7C:
	ld hl,0b110h		;ac7c
	ld de,0200bh		;ac7f
	ld bc,00003h		;ac82
	call L_B1C3		;ac85
	call L_AE38		;ac88
L_AC8B:
	push ix		;ac8b
	ld ix,0e22ch		;ac8d
	ld (ix+000h),003h		;ac91
	ld a,080h		;ac95
	sub 030h		;ac97
	ld (ix+001h),a		;ac99
	ld a,080h		;ac9c
	add a,030h		;ac9e
	ld (ix+002h),a		;aca0
	pop ix		;aca3
	ld hl,0aed4h		;aca5
	call L_9FE6		;aca8
	ld a,(0e224h)		;acab
	ld hl,0aec4h		;acae
	jp L_A99F		;acb1

; ----------------------------------------------------------------------
; DATOS sin identificar  0xacb4..0xacb5  (1 bytes)
; ----------------------------------------------------------------------
	defb 0c9h	; acb4  .

; ======================================================================
; CODIGO 0xacb5..0xade7  (306 bytes)
; ======================================================================


L_ACB5:
	ret			;acb5
L_ACB6:
	ld hl,098e0h		;acb6
	call L_B142		;acb9
	ld b,002h		;acbc
	ld de,00000h		;acbe
	ld hl,00008h		;acc1
	call L_8BC1		;acc4
	ld de,0e292h		;acc7
	ld hl,0af5eh		;acca
	ld bc,00004h		;accd
	ldir		;acd0
	ld de,0e2edh		;acd2
	ld hl,0af62h		;acd5
	ld bc,00016h		;acd8
	ldir		;acdb
	ld de,0e2edh		;acdd
	call L_9D30		;ace0
	ret			;ace3
L_ACE4:
	ld de,0e2a2h		;ace4
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
	ld de,0e2d5h		;ad05
	ld hl,0af98h		;ad08
	ld bc,00018h		;ad0b
	ldir		;ad0e
	ld de,0e2d5h		;ad10
	call L_9D30		;ad13
	ld ix,0e2d5h		;ad16
	set 0,(ix+016h)		;ad1a
	ret			;ad1e
L_AD1F:
	ld hl,09944h		;ad1f
	call L_B142		;ad22
	ld de,0e282h		;ad25
	ld hl,0afb6h		;ad28
	ld bc,00004h		;ad2b
	ldir		;ad2e
	ld de,0e303h		;ad30
	ld hl,0afc2h		;ad33
	ld bc,00016h		;ad36
	ldir		;ad39
	ld de,0e303h		;ad3b
	call L_9D30		;ad3e
	xor a			;ad41
	ld (0e136h),a		;ad42
	ld a,(0e224h)		;ad45
	ld b,01ah		;ad48
	cp 002h		;ad4a
	jr c,L_AD50		;ad4c
	ld b,03ah		;ad4e
L_AD50:
	ld hl,0e137h		;ad50
	ld (hl),b			;ad53
	cp 004h		;ad54
	jr c,L_AD64		;ad56
	ld ix,0e303h		;ad58
	res 0,(ix+006h)		;ad5c
	ld (ix+000h),0c0h		;ad60
L_AD64:
	cp 001h		;ad64
	ret nz			;ad66
	ld a,(0e2a3h)		;ad67
	cp 0e2h		;ad6a
	ret c			;ad6c
	ld hl,0e283h		;ad6d
	ld a,(hl)			;ad70
	sub 008h		;ad71
	ld (hl),a			;ad73
	ret			;ad74
L_AD75:
	ld hl,09919h		;ad75
	call L_B142		;ad78
	ld de,0e282h		;ad7b
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
	ld de,0e303h		;ad9c
	ld hl,0afeah		;ad9f
	ld bc,00016h		;ada2
	ldir		;ada5
	ld hl,0e313h		;ada7
	ld (hl),087h		;adaa
	ld de,0e303h		;adac
	call L_9D30		;adaf
	ld hl,0b0fbh		;adb2
	ld de,0200bh		;adb5
	ld bc,00003h		;adb8
	call L_B1C3		;adbb
	ld hl,0aed4h		;adbe
	call L_9FE6		;adc1
	push ix		;adc4
	ld ix,0e238h		;adc6
	ld (ix+000h),004h		;adca
	ld a,09fh		;adce
	sub 000h		;add0
	ld (ix+001h),a		;add2
	ld a,09fh		;add5
	add a,011h		;add7
	ld (ix+002h),a		;add9
	pop ix		;addc
	ld hl,0ae94h		;adde
	ld a,(0e224h)		;ade1
	jp L_A99F		;ade4

; ----------------------------------------------------------------------
; DATOS sin identificar  0xade7..0xade8  (1 bytes)
; ----------------------------------------------------------------------
	defb 0c9h	; ade7  .

; ======================================================================
; CODIGO 0xade8..0xae37  (79 bytes)
; ======================================================================


L_ADE8:
	ld hl,0b0fbh		;ade8
	ld de,0200bh		;adeb
	ld bc,00003h		;adee
	call L_B1C3		;adf1
	jr L_AE13		;adf4
L_ADF6:
	ld hl,0b110h		;adf6
	ld de,0200bh		;adf9
	ld bc,00003h		;adfc
	call L_B1C3		;adff
	jr L_AE13		;ae02
L_AE04:
	call L_AE38		;ae04
	ld hl,0b110h		;ae07
	ld de,0200bh		;ae0a
	ld bc,00003h		;ae0d
	call L_B1C3		;ae10
L_AE13:
	ld ix,0e2bfh		;ae13
	ld de,0a870h		;ae17
	ld (ix+012h),e		;ae1a
	ld (ix+013h),d		;ae1d
	ld (ix+011h),001h		;ae20
	ld hl,0aec4h		;ae24
	ld a,(0e225h)		;ae27
	cp 005h		;ae2a
	jr nz,L_AE31		;ae2c
	ld hl,0aea4h		;ae2e
L_AE31:
	ld a,(0e224h)		;ae31
	jp L_A99F		;ae34

; ----------------------------------------------------------------------
; DATOS sin identificar  0xae37..0xae38  (1 bytes)
; ----------------------------------------------------------------------
	defb 0c9h	; ae37  .

; ======================================================================
; CODIGO 0xae38..0xae90  (88 bytes)
; ======================================================================


L_AE38:
	call L_A002		;ae38
	ld de,0e26ah		;ae3b
	ld hl,0af46h		;ae3e
	ld bc,0000ch		;ae41
	ldir		;ae44
L_AE46:
	ld a,001h		;ae46
	ld (0e1ceh),a		;ae48
	ld de,0e32fh		;ae4b
	ld hl,0b02ah		;ae4e
	ld bc,00016h		;ae51
	ldir		;ae54
	ld hl,0a471h		;ae56
	ld ix,0e32fh		;ae59
	ld (ix+013h),h		;ae5d
	ld (ix+012h),l		;ae60
	ld iy,0e276h		;ae63
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
; DATOS tabla_de_submodos_1: Ocho punteros de palabra para el despachador parametrico de 0xA99F, indexados por el submodo (0xE224)=(0xE222)&7. La base la carga el llamante de 0xADE4. Solo dos rutinas distintas, alternadas de dos en dos: 0xACB5 y 0xAE38
;   0xae94..0xaea4  (16 bytes)
; DATOS tabla_de_submodos_2: Ocho punteros de palabra para 0xA99F, mismos indices. La base la carga 0xAE2E, y SOLO cuando el modo (0xE225) es 5. Cuatro rutinas distintas repetidas dos veces: 0xAC11, 0xAB51, 0xAB1B, 0xABB7
;   0xaea4..0xaeb4  (16 bytes)
; DATOS tabla_de_modos: Ocho punteros de palabra, uno por TIPO DE ESCENA (los bits 3-5 del LFSR de pantalla 0xE222). El despachador de 0x9F81-0x9F8D lee el indice de 0xE225, lo dobla y salta por aqui con un call indirecto (ld de,9F8Eh / push de / jp (hl)). El indice lo calcula 0x9EF4-0x9EFF como ((0xE222)>>3)&7, o sea 0..7: ocho entradas y ni una mas
;   0xaeb4..0xaec4  (16 bytes)
; DATOS tabla_de_submodos_3: Ocho punteros de palabra para 0xA99F, mismos indices. La cargan los llamantes de 0xAA70, 0xACB1 y el camino de 0xAE24 cuando el modo no es 5. Seis de las ocho entradas apuntan al mismo sitio, 0xAD1F; las otras dos, 0xAAB7 y 0xAA74
;   0xaec4..0xaed4  (16 bytes)
; DATOS guion_celdas_rotulo: Guion de 28 celdas en las filas 14-15, columnas 9-22: dos lineas de tiles consecutivos (0x58-0x6F), un rotulo pintado celda a celda. Lo llaman 0xACA8 y 0xADC1
;   0xaed4..0xaf46  (114 bytes)
; DATOS inicializador_e26a: Doce bytes que 0xAE44 copia a 0xE26A
;   0xaf46..0xaf52  (12 bytes)
; DATOS inicializador_e292: Cuatro bytes que 0xACD0 copia a 0xE292
;   0xaf5e..0xaf62  (4 bytes)
; DATOS plantilla_objeto_e2ed: Plantilla de objeto de 22 bytes que 0xACDB copia a 0xE2ED. Su manejador (offset 0x12) es 0xA69E
;   0xaf62..0xaf78  (22 bytes)
; DATOS inicializador_e2a2: Cuatro bytes que 0xACED copia a 0xE2A2
;   0xaf78..0xaf7c  (4 bytes)
; DATOS inicializador_e2a6: Cuatro bytes que 0xACF8 copia a 0xE2A6
;   0xaf7c..0xaf80  (4 bytes)
; DATOS inicializador_e2aa: Cuatro bytes que 0xAD03 copia a 0xE2AA
;   0xaf80..0xaf84  (4 bytes)
; DATOS plantilla_objeto_e2d5: Plantilla de objeto de 24 bytes que 0xAD0E copia a 0xE2D5. Su manejador es 0x8125
;   0xaf98..0xafb0  (24 bytes)
; DATOS inicializador_e282: Cuatro bytes que 0xAD2E copia a 0xE282
;   0xafb6..0xafba  (4 bytes)
; DATOS plantilla_objeto_e303: Plantilla de objeto de 22 bytes que 0xAD39 copia a 0xE303. Su manejador es 0xA728
;   0xafc2..0xafd8  (22 bytes)
; DATOS inicializador_e282_b: Cuatro bytes que 0xAD84 copia a 0xE282
;   0xafde..0xafe2  (4 bytes)
; DATOS inicializador_e286: Cuatro bytes que 0xAD8F copia a 0xE286
;   0xafe2..0xafe6  (4 bytes)
; DATOS inicializador_e28a: Cuatro bytes que 0xAD9A copia a 0xE28A
;   0xafe6..0xafea  (4 bytes)
; DATOS plantilla_objeto_e303_b: Otra plantilla de 22 bytes para 0xE303, copiada por 0xADA5. Su manejador es 0xA7F5
;   0xafea..0xb000  (22 bytes)
; DATOS inicializador_e28e: Cuatro bytes que copian a 0xE28E cinco sitios distintos (0xAA89, 0xAACC, 0xAB3C, 0xAB72, 0xABD7, 0xAC31)
;   0xb010..0xb014  (4 bytes)
; DATOS plantilla_objeto_e319: Plantilla de objeto de 22 bytes que copian a 0xE319 cinco sitios (0xAA94, 0xAAD7, 0xAB94, 0xABE2, 0xAC3C). Su campo de manejador viene a CERO: se rellena despues en marcha
;   0xb014..0xb02a  (22 bytes)
; DATOS plantilla_objeto_e2bf: Plantilla de objeto de 22 bytes que el arranque (0x8094) copia a 0xE2BF y 0xAE54 copia a 0xE32F. Su manejador es 0xA962
;   0xb02a..0xb040  (22 bytes)
; DATOS guion_celdas_objeto_1: Guion de 6 celdas: objeto de 3x2 en filas 14-15, columnas 24-26, tiles 0x90-0x95. Primera de las seis variantes del mismo hueco de pantalla. Lo llama 0xAA7D
;   0xb040..0xb05a  (26 bytes)
; DATOS guion_celdas_objeto_2: Guion de 6 celdas: mismo hueco 3x2, tiles 0xA8-0xAD. Lo llama 0xABC5
;   0xb05a..0xb074  (26 bytes)
; DATOS guion_celdas_objeto_3: Guion de 6 celdas: mismo hueco 3x2, tiles 0xB0-0xB5. Lo llama 0xAC1F
;   0xb074..0xb08e  (26 bytes)
; DATOS guion_celdas_objeto_4: Guion de 6 celdas: mismo hueco 3x2, las seis con el MISMO tile 0x30. Parece el borrado del objeto (?), pendiente de ver el patron del tile. Lo llaman 0x8D59 y 0x8D6C
;   0xb08e..0xb0a8  (26 bytes)
; DATOS guion_celdas_objeto_5: Guion de 6 celdas: mismo hueco 3x2, tiles 0x98-0x9D. Lo llama 0xAB88
;   0xb0a8..0xb0c2  (26 bytes)
; DATOS guion_celdas_objeto_6: Guion de 3 celdas: solo la fila 15 del hueco, columnas 24-26, tiles 0xA0-0xA2. Lo llama 0xAABA
;   0xb0c2..0xb0d0  (14 bytes)
; DATOS filas_del_rotulo: Cuatro filas de 8 numeros de tile (0x58-0x6F, los mismos del guion del rotulo): 0xA889 y 0xA89C las copian a la VRAM con LONGITUD CRECIENTE leida de 0xE133 (y 8 menos esa longitud en 0xA896), o sea el rotulo dibujandose por columnas
;   0xb0d0..0xb0f0  (32 bytes)
; DATOS colores_iniciales: Treinta y dos bytes de color que 0x8A01 copia a la VRAM 0x2000, el principio de la tabla de colores. Los tres del offset +0x0B (0xB0FB, 7B 7B 7B) los reutiliza 0xAC6B escribiendolos de vuelta en 0x200B: la restauracion del parche de abajo
;   0xb0f0..0xb110  (32 bytes)
; DATOS colores_alternativos: Tres bytes (1B 1B 1B) que 0xAC7C escribe en la VRAM 0x200B, encima de los originales: el parche de color que 0xAC6B deshace
;   0xb110..0xb113  (3 bytes)
; ----------------------------------------------------------------------
	defb 04bh,000h,04bh,000h,0b5h,0ach,0b5h,0ach,038h,0aeh,038h,0aeh,0b5h,0ach,0b5h,0ach	; ae90  K.K.....8.8.....
	defb 038h,0aeh,038h,0aeh,011h,0ach,051h,0abh,01bh,0abh,0b7h,0abh,011h,0ach,051h,0abh	; aea0  8.8...Q.......Q.
	defb 01bh,0abh,0b7h,0abh,0aah,0a9h,0aah,0a9h,07ch,0ach,06bh,0ach,075h,0adh,0f6h,0adh	; aeb0  ........|.k.u...
	defb 004h,0aeh,0e8h,0adh,01fh,0adh,01fh,0adh,01fh,0adh,01fh,0adh,01fh,0adh,01fh,0adh	; aec0  ................
	defb 0b7h,0aah,074h,0aah,01ch,000h,0c9h,001h,058h,000h,0cah,001h,059h,000h,0cbh,001h	; aed0  ..t.....X...Y...
	defb 05ah,000h,0cch,001h,05dh,000h,0cdh,001h,05bh,000h,0ceh,001h,05eh,000h,0cfh,001h	; aee0  Z...]...[...^...
	defb 05ch,000h,0d0h,001h,063h,000h,0d1h,001h,05eh,000h,0d2h,001h,062h,000h,0d3h,001h	; aef0  \...c...^...b...
	defb 05dh,000h,0d4h,001h,061h,000h,0d5h,001h,060h,000h,0d6h,001h,05fh,000h,0e9h,001h	; af00  ]...a...`..._...
	defb 064h,000h,0eah,001h,065h,000h,0ebh,001h,066h,000h,0ech,001h,069h,000h,0edh,001h	; af10  d...e...f...i...
	defb 067h,000h,0eeh,001h,06ah,000h,0efh,001h,068h,000h,0f0h,001h,06fh,000h,0f1h,001h	; af20  g...j...h...o...
	defb 06ah,000h,0f2h,001h,06eh,000h,0f3h,001h,069h,000h,0f4h,001h,06dh,000h,0f5h,001h	; af30  j...n...i...m...
	defb 06ch,000h,0f6h,001h,06bh,000h,02fh,068h,084h,00ch,02fh,078h,0a8h,00ch,02fh,088h	; af40  l...k./h../x../.
	defb 0cch,00ch,003h,000h,003h,004h,000h,000h,003h,008h,003h,00ch,000h,000h,0a2h,080h	; af50  ................
	defb 000h,00fh,0e0h,000h,000h,000h,000h,000h,007h,000h,001h,008h,0ddh,000h,052h,0afh	; af60  ..............R.
	defb 001h,000h,003h,005h,09eh,0a6h,092h,0e2h,06dh,020h,034h,00ch,06dh,020h,034h,006h	; af70  ........m 4.m 4.
	defb 06dh,020h,034h,00fh,032h,020h,032h,024h,032h,028h,032h,02ch,032h,030h,032h,034h	; af80  m 4.2 2$2(2,2024
	defb 032h,038h,032h,03ch,032h,040h,000h,000h,0c0h,000h,001h,000h,000h,000h,000h,0b4h	; af90  282<2@..........
	defb 000h,010h,0ddh,000h,000h,000h,001h,000h,001h,005h,025h,081h,0a2h,0e2h,000h,000h	; afa0  ..........%.....
	defb 00ah,0f8h,00ah,0fch,000h,000h,06fh,0c3h,0f8h,006h,06fh,0e0h,0f8h,006h,06fh,0e0h	; afb0  ......o...o...o.
	defb 0f8h,006h,0e0h,000h,000h,000h,000h,000h,001h,038h,0ffh,000h,000h,000h,0b0h,0afh	; afc0  .........8......
	defb 001h,000h,001h,002h,028h,0a7h,082h,0e2h,001h,0f8h,001h,0fch,000h,000h,070h,078h	; afd0  ....(.........px
	defb 0f8h,001h,070h,060h,0f8h,001h,070h,090h,0f8h,001h,0e0h,000h,000h,000h,000h,000h	; afe0  ..p`..p.........
	defb 000h,000h,000h,000h,000h,000h,0d8h,0afh,001h,000h,004h,005h,0f5h,0a7h,082h,0e2h	; aff0  ................
	defb 002h,0f8h,001h,0fch,003h,0f8h,002h,0fch,002h,0f8h,004h,0fch,001h,0f8h,000h,000h	; b000  ................
	defb 06fh,0c3h,0f8h,006h,0a0h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; b010  o...............
	defb 000h,0b0h,001h,000h,004h,005h,000h,000h,08eh,0e2h,0c0h,000h,000h,000h,000h,000h	; b020  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,009h,004h,062h,0a9h,000h,000h	; b030  ............b...
	defb 006h,000h,0d8h,001h,090h,000h,0d9h,001h,091h,000h,0dah,001h,092h,000h,0f8h,001h	; b040  ................
	defb 093h,000h,0f9h,001h,094h,000h,0fah,001h,095h,000h,006h,000h,0d8h,001h,0a8h,000h	; b050  ................
	defb 0d9h,001h,0a9h,000h,0dah,001h,0aah,000h,0f8h,001h,0abh,000h,0f9h,001h,0ach,000h	; b060  ................
	defb 0fah,001h,0adh,000h,006h,000h,0d8h,001h,0b0h,000h,0d9h,001h,0b1h,000h,0dah,001h	; b070  ................
	defb 0b2h,000h,0f8h,001h,0b3h,000h,0f9h,001h,0b4h,000h,0fah,001h,0b5h,000h,006h,000h	; b080  ................
	defb 0d8h,001h,030h,000h,0d9h,001h,030h,000h,0dah,001h,030h,000h,0f8h,001h,030h,000h	; b090  ..0...0...0...0.
	defb 0f9h,001h,030h,000h,0fah,001h,030h,000h,006h,000h,0d8h,001h,098h,000h,0d9h,001h	; b0a0  ..0...0.........
	defb 099h,000h,0dah,001h,09ah,000h,0f8h,001h,09bh,000h,0f9h,001h,09ch,000h,0fah,001h	; b0b0  ................
	defb 09dh,000h,003h,000h,0f8h,001h,0a0h,000h,0f9h,001h,0a1h,000h,0fah,001h,0a2h,000h	; b0c0  ................
	defb 030h,058h,059h,05ah,05dh,05bh,05eh,05ch,063h,05eh,062h,05dh,061h,060h,05fh,030h	; b0d0  0XYZ][^\c^b]a`_0
	defb 030h,064h,065h,066h,069h,067h,06ah,068h,06fh,06ah,06eh,069h,06dh,06ch,06bh,030h	; b0e0  0defigjhojnimlk0
	defb 098h,097h,087h,08fh,091h,061h,01bh,08ch,006h,016h,01bh,07bh,07bh,07bh,0c7h,0c7h	; b0f0  .....a.....{{{..
	defb 0c7h,0c7h,01bh,05bh,06bh,0dbh,0cbh,0fch,0fch,0f1h,0f1h,03ch,03ch,03ch,037h,037h	; b100  ...[k......<<<77
	defb 01bh,01bh,01bh	; b110  ...

; ======================================================================
; CODIGO 0xb113..0xb393  (640 bytes)
; ======================================================================


L_B113:
	xor a			;b113
	ld hl,00000h		;b114
	ld bc,04000h		;b117
	call L_B1A7		;b11a
	ret			;b11d
L_B11E:
	ld a,(hl)			;b11e
	and 03fh		;b11f
	ret z			;b121
	ld b,a			;b122
	bit 7,(hl)		;b123
	jr nz,L_B13B		;b125
	bit 6,(hl)		;b127
	inc hl			;b129
	ld a,(hl)			;b12a
	jr nz,L_B133		;b12b
L_B12D:
	ld (de),a			;b12d
	inc de			;b12e
	djnz L_B12D		;b12f
	jr L_B13F		;b131
L_B133:
	ld (de),a			;b133
	inc de			;b134
	inc hl			;b135
	ld a,(hl)			;b136
	djnz L_B133		;b137
	jr L_B11E		;b139
L_B13B:
	add a,e			;b13b
	jr nc,L_B174		;b13c
	inc d			;b13e
L_B13F:
	inc hl			;b13f
	jr L_B11E		;b140
L_B142:
	ld e,(hl)			;b142
	inc hl			;b143
	ld d,(hl)			;b144
	ld a,e			;b145
	out (099h),a		;b146
	ld a,d			;b148
	add a,040h		;b149
	ld d,a			;b14b
	out (099h),a		;b14c
L_B14E:
	inc hl			;b14e
L_B14F:
	ld a,(hl)			;b14f
	and 03fh		;b150
	ret z			;b152
	ld b,a			;b153
	bit 7,(hl)		;b154
	jr nz,L_B170		;b156
	bit 6,(hl)		;b158
	inc hl			;b15a
	ld a,(hl)			;b15b
	jr nz,L_B167		;b15c
L_B15E:
	out (098h),a		;b15e
	inc de			;b160
	nop			;b161
	nop			;b162
	djnz L_B15E		;b163
	jr L_B14E		;b165
L_B167:
	out (098h),a		;b167
	inc de			;b169
	inc hl			;b16a
	ld a,(hl)			;b16b
	djnz L_B167		;b16c
	jr L_B14F		;b16e
L_B170:
	add a,e			;b170
	jr nc,L_B174		;b171
	inc d			;b173
L_B174:
	ld e,a			;b174
	out (099h),a		;b175
	ld a,d			;b177
	out (099h),a		;b178
	jr L_B14E		;b17a
L_B17C:
	ld a,b			;b17c
	out (099h),a		;b17d
	ld a,c			;b17f
	or 080h		;b180
	out (099h),a		;b182
	ret			;b184
L_B185:
	ld a,l			;b185
	out (099h),a		;b186
	ld a,h			;b188
	or 040h		;b189
	out (099h),a		;b18b
	push af			;b18d
	pop af			;b18e
	ret			;b18f
L_B190:
	ld a,l			;b190
	out (099h),a		;b191
	ld a,h			;b193
	out (099h),a		;b194
	push af			;b196
	pop af			;b197
	ret			;b198
L_B199:
	push af			;b199
	call L_B185		;b19a
	pop af			;b19d
	out (098h),a		;b19e
	ret			;b1a0
L_B1A1:
	call L_B190		;b1a1
	in a,(098h)		;b1a4
	ret			;b1a6
L_B1A7:
	push de			;b1a7
	ld d,a			;b1a8
	call L_B185		;b1a9
L_B1AC:
	ld a,d			;b1ac
	out (098h),a		;b1ad
	dec bc			;b1af
	ld a,b			;b1b0
	or c			;b1b1
	jr nz,L_B1AC		;b1b2
	pop de			;b1b4
	ret			;b1b5
L_B1B6:
	call L_B190		;b1b6
L_B1B9:
	in a,(098h)		;b1b9
	ld (de),a			;b1bb
	inc de			;b1bc
	dec bc			;b1bd
	ld a,b			;b1be
	or c			;b1bf
	jr nz,L_B1B9		;b1c0
	ret			;b1c2
L_B1C3:
	ex de,hl			;b1c3
	call L_B185		;b1c4
L_B1C7:
	ld a,(de)			;b1c7
	out (098h),a		;b1c8
	inc de			;b1ca
	dec bc			;b1cb
	ld a,b			;b1cc
	or c			;b1cd
	jr nz,L_B1C7		;b1ce
	ret			;b1d0
L_B1D1:
	push bc			;b1d1
	push hl			;b1d2
	push de			;b1d3
	ld de,0e072h		;b1d4
	ld bc,00008h		;b1d7
	call L_B1B6		;b1da
	ld hl,0e072h		;b1dd
	ld c,008h		;b1e0
L_B1E2:
	ld b,008h		;b1e2
L_B1E4:
	rr (hl)		;b1e4
	rl a		;b1e6
	djnz L_B1E4		;b1e8
	ld (hl),a			;b1ea
	inc hl			;b1eb
	dec c			;b1ec
	jr nz,L_B1E2		;b1ed
	pop de			;b1ef
	push de			;b1f0
	ld hl,0e072h		;b1f1
	ld bc,00008h		;b1f4
	call L_B1C3		;b1f7
	pop de			;b1fa
	pop hl			;b1fb
	ld bc,00008h		;b1fc
	add hl,bc			;b1ff
	ex de,hl			;b200
	add hl,bc			;b201
	ex de,hl			;b202
	pop bc			;b203
	dec bc			;b204
	ld a,b			;b205
	or c			;b206
	jp nz,L_B1D1		;b207
	ret			;b20a
L_B20B:
	push bc			;b20b
	push hl			;b20c
	push de			;b20d
	ld de,0e072h		;b20e
	ld bc,00008h		;b211
	call L_B1B6		;b214
	ld hl,0e072h		;b217
	ld ix,0e079h		;b21a
	ld b,004h		;b21e
L_B220:
	ld d,(ix+000h)		;b220
	ld e,(hl)			;b223
	ld (ix+000h),e		;b224
	ld (hl),d			;b227
	inc hl			;b228
	dec ix		;b229
	djnz L_B220		;b22b
	pop de			;b22d
	push de			;b22e
	ld hl,0e072h		;b22f
	ld bc,00008h		;b232
	call L_B1C3		;b235
	pop de			;b238
	pop hl			;b239
	ld bc,00008h		;b23a
	add hl,bc			;b23d
	ex de,hl			;b23e
	add hl,bc			;b23f
	ex de,hl			;b240
	pop bc			;b241
	dec bc			;b242
	ld a,b			;b243
	or c			;b244
	jp nz,L_B20B		;b245
	ret			;b248
L_B249:
	ld a,00fh		;b249
	out (0a0h),a		;b24b
	ld a,0afh		;b24d
	out (0a1h),a		;b24f
	ld a,00eh		;b251
	out (0a0h),a		;b253
	in a,(0a2h)		;b255
	cpl			;b257
	ld (0e05fh),a		;b258
	ld a,00fh		;b25b
	out (0a0h),a		;b25d
	ld a,0dfh		;b25f
	out (0a1h),a		;b261
	ld a,00eh		;b263
	out (0a0h),a		;b265
	in a,(0a2h)		;b267
	cpl			;b269
	ld (0e061h),a		;b26a
	ret			;b26d
L_B26E:
	ld a,008h		;b26e
	or 0f0h		;b270
	out (0aah),a		;b272
	in a,(0a9h)		;b274
	cpl			;b276
	res 1,a		;b277
	bit 0,a		;b279
	jr z,L_B27F		;b27b
	set 1,a		;b27d
L_B27F:
	res 0,a		;b27f
	bit 7,a		;b281
	jr z,L_B287		;b283
	set 0,a		;b285
L_B287:
	res 7,a		;b287
	bit 4,a		;b289
	jr z,L_B28F		;b28b
	set 7,a		;b28d
L_B28F:
	rlca			;b28f
	rlca			;b290
	rlca			;b291
	and 01fh		;b292
	ld b,a			;b294
	ld a,(0e05fh)		;b295
	or b			;b298
	ld (0e05fh),a		;b299
	ld a,(0e061h)		;b29c
	or b			;b29f
	ld (0e061h),a		;b2a0
	ret			;b2a3
L_B2A4:
	ld c,009h		;b2a4
	ld hl,0e25dh		;b2a6
L_B2A9:
	ld b,008h		;b2a9
	ld e,001h		;b2ab
	ld a,009h		;b2ad
	sub c			;b2af
	or 0f0h		;b2b0
	out (0aah),a		;b2b2
	in a,(0a9h)		;b2b4
	cpl			;b2b6
	ld d,a			;b2b7
L_B2B8:
	ld a,d			;b2b8
	and e			;b2b9
	jr z,L_B2D7		;b2ba
	ld a,(hl)			;b2bc
	and e			;b2bd
	jr nz,L_B2DF		;b2be
	ld a,(hl)			;b2c0
	or e			;b2c1
	ld (hl),a			;b2c2
	push bc			;b2c3
	ld a,009h		;b2c4
	sub c			;b2c6
	rlca			;b2c7
	rlca			;b2c8
	rlca			;b2c9
	ld c,a			;b2ca
	ld a,008h		;b2cb
	sub b			;b2cd
	or c			;b2ce
	or 080h		;b2cf
	ld (0e266h),a		;b2d1
	pop bc			;b2d4
	jr L_B2DF		;b2d5
L_B2D7:
	ld a,(hl)			;b2d7
	and e			;b2d8
	jr z,L_B2DF		;b2d9
	ld a,e			;b2db
	cpl			;b2dc
	and (hl)			;b2dd
	ld (hl),a			;b2de
L_B2DF:
	rlc e		;b2df
	djnz L_B2B8		;b2e1
	inc hl			;b2e3
	dec c			;b2e4
	jr nz,L_B2A9		;b2e5
	ret			;b2e7
L_B2E8:
	ld a,(0e266h)		;b2e8
	bit 7,a		;b2eb
	ret z			;b2ed
	res 7,a		;b2ee
	ld (0e266h),a		;b2f0
	ret			;b2f3
L_B2F4:
	call L_B2E8		;b2f4
	jr z,L_B2F4		;b2f7
	ret			;b2f9
L_B2FA:
	ld hl,L_B392		;b2fa
	ld a,000h		;b2fd
	ld (0e1eeh),a		;b2ff
	ld (0e1e6h),hl		;b302
	ld (0e1e8h),hl		;b305
	ld (0e1eah),hl		;b308
	ld (0e1ech),hl		;b30b
	ld a,001h		;b30e
	ld (0e1eeh),a		;b310
	ld hl,0e20eh		;b313
	ld bc,0000eh		;b316
	ld a,000h		;b319
	ld (hl),a			;b31b
	ld d,h			;b31c
	ld e,l			;b31d
	inc de			;b31e
	dec bc			;b31f
	ld a,b			;b320
	or c			;b321
	jr z,L_B32B		;b322
	ldir		;b324
	ld a,0bfh		;b326
	ld (0e215h),a		;b328
L_B32B:
	jp L_B37B		;b32b
L_B32E:
	cp 00bh		;b32e
	ret nc			;b330
	push bc			;b331
	push de			;b332
	push hl			;b333
	ld hl,0e1eeh		;b334
	ld (hl),000h		;b337
	ld b,a			;b339
	add a,a			;b33a
	add a,b			;b33b
	ld b,000h		;b33c
	ld c,a			;b33e
	ld hl,0b393h		;b33f
	add hl,bc			;b342
	ld a,(hl)			;b343
	add a,a			;b344
	ld de,0e1e6h		;b345
	ld c,a			;b348
	ex de,hl			;b349
	add hl,bc			;b34a
	inc de			;b34b
	ld a,(de)			;b34c
	ld (hl),a			;b34d
	inc de			;b34e
	inc hl			;b34f
	ld a,(de)			;b350
	ld (hl),a			;b351
	ld a,001h		;b352
	ld (0e1eeh),a		;b354
	pop hl			;b357
	pop de			;b358
	pop bc			;b359
	ret			;b35a
L_B35B:
	ld a,(0e1eeh)		;b35b
	and a			;b35e
	ret z			;b35f
	ld hl,(0e1e6h)		;b360
	call L_B368		;b363
	jr L_B369		;b366
L_B368:
	jp (hl)			;b368
L_B369:
	ld hl,(0e1e8h)		;b369
	call L_B371		;b36c
	jr L_B372		;b36f
L_B371:
	jp (hl)			;b371
L_B372:
	ld hl,(0e1eah)		;b372
	call L_B37A		;b375
	jr L_B37B		;b378
L_B37A:
	jp (hl)			;b37a
L_B37B:
	ld hl,0e21bh		;b37b
	ld b,00dh		;b37e
L_B380:
	ld c,0a0h		;b380
	out (c),b		;b382
	ld c,0a1h		;b384
	outd		;b386
	jr nz,L_B380		;b388
	ld c,0a0h		;b38a
	out (c),b		;b38c
	ld c,0a1h		;b38e
	outd		;b390
L_B392:
	ret			;b392

; ----------------------------------------------------------------------
; DATOS tabla_instaladora_de_vectores: Once registros de 3 bytes [ranura][puntero]: la rutina de 0xB32E copia el puntero al vector 0xE1E6+ranura*2 y pone 0xE1EE a 1. El limite lo fija el propio codigo (cp 0Bh / ret nc), y en 0xB3B4 empieza ya la primera rutina instalable
;   0xb393..0xb3b4  (33 bytes)
; ----------------------------------------------------------------------
	defb 003h,092h,0b3h,003h,092h,0b3h,001h,0ceh,0b3h,002h,02eh,0b5h,000h,075h,0b4h,001h	; b393  .............u..
	defb 0b4h,0b3h,000h,0e4h,0b5h,000h,0beh,0b5h,000h,064h,0b5h,000h,09fh,0b4h,001h,0e6h	; b3a3  .........d......
	defb 0b4h	; b3b3  .

; ======================================================================
; CODIGO 0xb3b4..0xb3bd  (9 bytes)
; ======================================================================


L_B3B4:
	ld hl,0b3bdh		;b3b4
	ld (0e1f5h),hl		;b3b7
	jp L_B3F0		;b3ba

; ----------------------------------------------------------------------
; DATOS guion_sonido_b3bd: Guion de sonido del instalador 0xB3B4 (ld hl,0B3BDh / ld (0E1F5h),hl): un registro, el 0x00, y las secciones encadenadas de detras
;   0xb3bd..0xb3ce  (17 bytes)
; ----------------------------------------------------------------------
	defb 033h,001h,001h,000h,000h,00ah,000h,030h,002h,00ch,003h,0ffh,000h,000h,000h,000h	; b3bd  3......0........
	defb 000h	; b3cd  .

; ======================================================================
; CODIGO 0xb3ce..0xb3d7  (9 bytes)
; ======================================================================


L_B3CE:
	ld hl,0b3d7h		;b3ce
	ld (0e1f5h),hl		;b3d1
	jp L_B3F0		;b3d4

; ----------------------------------------------------------------------
; DATOS guion_sonido_b3d7: Guion del instalador 0xB3CE, con sus secciones encadenadas y su 0x00 final en 0xB3EF
;   0xb3d7..0xb3f0  (25 bytes)
; ----------------------------------------------------------------------
	defb 00ah,003h,001h,0ffh,0ffh,0e7h,000h,087h,001h,000h,000h,000h,000h,000h,000h,000h	; b3d7  ................
	defb 008h,009h,001h,090h,000h,027h,0ffh,0b7h,000h	; b3e7  .....'...

; ======================================================================
; CODIGO 0xb3f0..0xb47e  (142 bytes)
; ======================================================================


L_B3F0:
	ld hl,lb403h		;b3f0
	ld (0e1e8h),hl		;b3f3
	ld a,(0e215h)		;b3f6
	res 1,a		;b3f9
	ld (0e215h),a		;b3fb
	ld a,001h		;b3fe
	ld (0e1f7h),a		;b400
L_B403:
	ld a,(0e1f7h)		;b403
	dec a			;b406
	ld (0e1f7h),a		;b407
	and a			;b40a
	jp p,L_B458		;b40b
	ld hl,(0e1f5h)		;b40e
	ld a,(hl)			;b411
	and a			;b412
	jr nz,L_B429		;b413
	ld hl,0b392h		;b415
	ld (0e1e8h),hl		;b418
	ld a,000h		;b41b
	ld (0e217h),a		;b41d
	ld a,(0e215h)		;b420
	set 1,a		;b423
	ld (0e215h),a		;b425
	ret			;b428
L_B429:
	ld (0e1f7h),a		;b429
	inc hl			;b42c
	ld a,(hl)			;b42d
	ld (0e1fdh),a		;b42e
	ld a,000h		;b431
	ld (0e1fch),a		;b433
	inc hl			;b436
	ld a,(hl)			;b437
	ld (0e211h),a		;b438
	inc hl			;b43b
	ld a,(hl)			;b43c
	ld (0e210h),a		;b43d
	inc hl			;b440
	ld a,(hl)			;b441
	ld (0e1f9h),a		;b442
	inc hl			;b445
	ld a,(hl)			;b446
	ld (0e1f8h),a		;b447
	inc hl			;b44a
	ld a,(hl)			;b44b
	ld (0e1fbh),a		;b44c
	inc hl			;b44f
	ld a,(hl)			;b450
	ld (0e1fah),a		;b451
	inc hl			;b454
	ld (0e1f5h),hl		;b455
L_B458:
	ld bc,(0e1f8h)		;b458
	ld hl,(0e210h)		;b45c
	adc hl,bc		;b45f
	ld (0e210h),hl		;b461
	ld bc,(0e1fah)		;b464
	ld hl,(0e1fch)		;b468
	adc hl,bc		;b46b
	ld (0e1fch),hl		;b46d
	ld a,h			;b470
	ld (0e217h),a		;b471
	ret			;b474
L_B475:
	ld hl,0b47eh		;b475
	ld (0e1efh),hl		;b478
	jp L_B5EA		;b47b

; ----------------------------------------------------------------------
; DATOS guion_sonido_b47e: Ocho registros y el 0x00: los periodos bajan de 0x0D7F a 0x0443, una escala descendente. Instalador 0xB475; cierra EXACTO donde empieza el codigo de 0xB49F
;   0xb47e..0xb49f  (33 bytes)
; ----------------------------------------------------------------------
	defb 002h,003h,07fh,00dh,001h,001h,020h,00ah,002h,002h,022h,009h,002h,001h,02dh,008h	; b47e  ...... ..."...-.
	defb 002h,001h,09fh,007h,001h,001h,037h,006h,001h,001h,0bfh,005h,001h,001h,043h,004h	; b48e  ......7.......C.
	defb 000h	; b49e  .

; ======================================================================
; CODIGO 0xb49f..0xb56d  (206 bytes)
; ======================================================================


L_B49F:
	ld hl,lb4bdh		;b49f
	ld (0e1e6h),hl		;b4a2
	ld a,(0e215h)		;b4a5
	res 0,a		;b4a8
	ld (0e215h),a		;b4aa
	ld a,009h		;b4ad
	ld (0e216h),a		;b4af
	ld a,013h		;b4b2
	ld (0e1f2h),a		;b4b4
	ld hl,000f9h		;b4b7
	ld (0e20eh),hl		;b4ba
L_B4BD:
	ld a,(0e1f2h)		;b4bd
	dec a			;b4c0
	ld (0e1f2h),a		;b4c1
	jp p,L_B4DB		;b4c4
	ld hl,0b392h		;b4c7
	ld (0e1e6h),hl		;b4ca
	ld a,(0e215h)		;b4cd
	set 0,a		;b4d0
	ld (0e215h),a		;b4d2
	ld a,000h		;b4d5
	ld (0e216h),a		;b4d7
	ret			;b4da
L_B4DB:
	ld bc,00014h		;b4db
	ld hl,(0e20eh)		;b4de
	add hl,bc			;b4e1
	ld (0e20eh),hl		;b4e2
	ret			;b4e5
L_B4E6:
	ld hl,lb504h		;b4e6
	ld (0e1e8h),hl		;b4e9
	ld a,(0e215h)		;b4ec
	res 1,a		;b4ef
	ld (0e215h),a		;b4f1
	ld a,00bh		;b4f4
	ld (0e217h),a		;b4f6
	ld hl,00382h		;b4f9
	ld (0e210h),hl		;b4fc
	ld a,003h		;b4ff
	ld (0e1f3h),a		;b501
L_B504:
	ld a,(0e1f3h)		;b504
	dec a			;b507
	ld (0e1f3h),a		;b508
	jp p,L_B522		;b50b
	ld hl,0b392h		;b50e
	ld (0e1e8h),hl		;b511
	ld a,(0e215h)		;b514
	set 1,a		;b517
	ld (0e215h),a		;b519
	ld a,000h		;b51c
	ld (0e217h),a		;b51e
	ret			;b521
L_B522:
	ld bc,0007fh		;b522
	ld hl,(0e210h)		;b525
	sbc hl,bc		;b528
	ld (0e210h),hl		;b52a
	ret			;b52d
L_B52E:
	ld hl,lb54dh		;b52e
	ld (0e1eah),hl		;b531
	ld a,(0e215h)		;b534
	res 5,a		;b537
	set 2,a		;b539
	ld (0e215h),a		;b53b
	ld a,01fh		;b53e
	ld (0e214h),a		;b540
	ld a,009h		;b543
	ld (0e218h),a		;b545
	ld a,001h		;b548
	ld (0e1f4h),a		;b54a
L_B54D:
	ld a,(0e1f4h)		;b54d
	dec a			;b550
	ld (0e1f4h),a		;b551
	ret p			;b554
	ld a,(0e215h)		;b555
	set 5,a		;b558
	ld (0e215h),a		;b55a
	ld hl,0b392h		;b55d
	ld (0e1eah),hl		;b560
	ret			;b563
L_B564:
	ld hl,0b56dh		;b564
	ld (0e1efh),hl		;b567
	jp L_B5EA		;b56a

; ----------------------------------------------------------------------
; DATOS guion_sonido_b56d: Veinte registros. Instalador 0xB564; cierra EXACTO en 0xB5BE
;   0xb56d..0xb5be  (81 bytes)
; ----------------------------------------------------------------------
	defb 003h,000h,0feh,00ah,002h,000h,000h,000h,003h,000h,0beh,00ah,002h,000h,000h,000h	; b56d  ................
	defb 003h,000h,094h,00ah,002h,000h,000h,000h,00ah,000h,07fh,00ah,002h,000h,000h,000h	; b57d  ................
	defb 002h,000h,094h,00ah,001h,000h,000h,000h,010h,000h,07fh,009h,001h,000h,000h,000h	; b58d  ................
	defb 002h,000h,07fh,008h,001h,000h,000h,000h,002h,000h,07fh,007h,001h,000h,000h,000h	; b59d  ................
	defb 002h,000h,07fh,006h,001h,000h,000h,000h,002h,000h,07fh,004h,001h,000h,000h,000h	; b5ad  ................
	defb 000h	; b5bd  .

; ======================================================================
; CODIGO 0xb5be..0xb5c7  (9 bytes)
; ======================================================================


L_B5BE:
	ld hl,0b5c7h		;b5be
	ld (0e1efh),hl		;b5c1
	jp L_B5EA		;b5c4

; ----------------------------------------------------------------------
; DATOS guion_sonido_b5c7: Siete registros. Instalador 0xB5BE; cierra EXACTO en 0xB5E4
;   0xb5c7..0xb5e4  (29 bytes)
; ----------------------------------------------------------------------
	defb 01ch,002h,01bh,00ah,004h,001h,00dh,00ah,030h,001h,040h,00ah,005h,001h,00dh,00ah	; b5c7  ........0.@.....
	defb 005h,001h,040h,00ah,005h,001h,00dh,00ah,013h,001h,040h,00ah,000h	; b5d7  ..@.......@..

; ======================================================================
; CODIGO 0xb5e4..0xb632  (78 bytes)
; ======================================================================


L_B5E4:
	ld hl,0b632h		;b5e4
	ld (0e1efh),hl		;b5e7
L_B5EA:
	ld hl,lb5fdh		;b5ea
	ld (0e1e6h),hl		;b5ed
	ld a,001h		;b5f0
	ld (0e1f1h),a		;b5f2
	ld a,(0e215h)		;b5f5
	res 0,a		;b5f8
	ld (0e215h),a		;b5fa
L_B5FD:
	ld a,(0e1f1h)		;b5fd
	dec a			;b600
	ld (0e1f1h),a		;b601
	ret p			;b604
	ld hl,(0e1efh)		;b605
	call L_B683		;b608
	and a			;b60b
	jr nz,L_B622		;b60c
	ld a,(0e215h)		;b60e
	set 0,a		;b611
	ld (0e215h),a		;b613
	ld hl,0b392h		;b616
	ld (0e1e6h),hl		;b619
	ld a,000h		;b61c
	ld (0e216h),a		;b61e
	ret			;b621
L_B622:
	ld a,b			;b622
	ld (0e1f1h),a		;b623
	ld (0e20eh),de		;b626
	ld a,c			;b62a
	ld (0e216h),a		;b62b
	ld (0e1efh),hl		;b62e
	ret			;b631

; ----------------------------------------------------------------------
; DATOS guion_sonido_b632: Veinte registros. Instalador 0xB5E4 (ld hl,0B632h en 0xB5E4... lo carga 0xB62E via L_B622); cierra EXACTO en 0xB683
;   0xb632..0xb683  (81 bytes)
; ----------------------------------------------------------------------
	defb 01ch,003h,027h,00bh,008h,002h,0cfh,009h,010h,002h,0a7h,00bh,010h,003h,027h,00ah	; b632  ..'...........'.
	defb 004h,002h,03bh,00bh,004h,002h,050h,00ah,004h,002h,03bh,00bh,004h,002h,050h,00ah	; b642  ..;...P...;...P.
	defb 004h,002h,03bh,00bh,004h,002h,050h,00ah,004h,002h,03bh,00bh,004h,002h,050h,00ah	; b652  ..;...P...;...P.
	defb 004h,002h,03bh,00bh,004h,002h,050h,00ah,004h,002h,03bh,00bh,004h,002h,050h,00ah	; b662  ..;...P...;...P.
	defb 004h,002h,03bh,00bh,004h,002h,050h,00ah,004h,002h,03bh,009h,004h,002h,050h,008h	; b672  ..;...P...;...P.
	defb 000h	; b682  .

; ======================================================================
; CODIGO 0xb683..0xb6b0  (45 bytes)
; ======================================================================


L_B683:
	ld a,(hl)			;b683
	and a			;b684
	ret z			;b685
	ld b,a			;b686
	inc hl			;b687
	ld d,(hl)			;b688
	inc hl			;b689
	ld e,(hl)			;b68a
	inc hl			;b68b
	ld c,(hl)			;b68c
	inc hl			;b68d
	ret			;b68e

; ----------------------------------------------------------------------
; ############################################################
; EL MUNDO NO ESTA GUARDADO: SE CALCULA
; ############################################################
; Las 255 escenas no ocupan ni un byte de mapa. Salen de un
; registro de desplazamiento realimentado de 8 bits, 0xE222,
; que es el mismo truco del Pitfall! de Atari 2600.
; NO ES ALEATORIO: el orden esta fijado y se puede escribir
; entero. La realimentacion, sacada de los rla/xor de aqui
; abajo y comprobada sobre los 256 valores posibles, es
; bit nuevo = b7 xor b5 xor b4 xor b3      (mascara 0xB8)
; y el registro se desplaza a la izquierda metiendo ese bit.
; Con esa realimentacion el anillo es MAXIMO: recorre los 255
; valores no nulos y vuelve al principio. El 0x00 se queda
; fuera -de un LFSR nadie sale del cero- y por eso el juego
; lo usa para la pantalla del titulo.
; Sembrando con 0xC4, que es lo que hace el arranque en
; 0x8075, sale el orden en que se recorre el mundo yendo
; siempre a la derecha. tools/mapa_escenas.py lo reproduce, y
; las 255 capturas del emulador salieron en ESE MISMO orden,
; las 255 de 255.
; ----------------------------------------------------------------------
avanza_pantalla_lfsr:
	ld hl,0e222h		;b68f   ; El paso ADELANTE: desplaza 0xE222 a la izquierda metiendo el bit de realimentacion
	ld a,(hl)			;b692
	rla			;b693
	xor (hl)			;b694
	rla			;b695
	xor (hl)			;b696
	rla			;b697
	rla			;b698
	xor (hl)			;b699
	rla			;b69a
	ld a,(hl)			;b69b
	rla			;b69c
	ld (hl),a			;b69d
	ret			;b69e
retrocede_pantalla_lfsr:
	ld hl,0e222h		;b69f   ; El paso ATRAS: la funcion inversa exacta de 0xB68F, desplazando a la derecha. Salir de una pantalla por la izquierda deshace lo que la derecha hizo
	ld a,(hl)			;b6a2
	rla			;b6a3
	xor (hl)			;b6a4
	rla			;b6a5
	xor (hl)			;b6a6
	rla			;b6a7
	rla			;b6a8
	rla			;b6a9
	xor (hl)			;b6aa
	rra			;b6ab
	ld a,(hl)			;b6ac
	rra			;b6ad
	ld (hl),a			;b6ae
	ret			;b6af

; ----------------------------------------------------------------------
; DATOS sin identificar  0xb6b0..0xb6b1  (1 bytes)
; ----------------------------------------------------------------------
	defb 0c9h	; b6b0  .

; ======================================================================
; CODIGO 0xb6b1..0xb9e4  (819 bytes)
; ======================================================================


L_B6B1:
	di			;b6b1
	ld bc,00200h		;b6b2
	call L_B17C		;b6b5
	ld bc,0e201h		;b6b8
	call L_B17C		;b6bb
	ld bc,00304h		;b6be
	call L_B17C		;b6c1
	ld bc,0ff03h		;b6c4
	call L_B17C		;b6c7
	call L_8B5E		;b6ca
	ld hl,01800h		;b6cd
	ld bc,00300h		;b6d0
	xor a			;b6d3
	call L_B1A7		;b6d4
	ld hl,02000h		;b6d7
	ld bc,00800h		;b6da
	ld a,0f1h		;b6dd
	call L_B1A7		;b6df
	ld hl,0ba2dh		;b6e2
	ld de,018c0h		;b6e5
	ld bc,00019h		;b6e8
	call L_B1C3		;b6eb
	ld hl,02800h		;b6ee
	ld bc,01000h		;b6f1
	ld a,061h		;b6f4
	call L_B1A7		;b6f6
	ld hl,0e247h		;b6f9
	ld (hl),000h		;b6fc
	ld de,0e2d5h		;b6fe
	call L_9D30		;b701
	ld de,0e32fh		;b704
	call L_9D30		;b707
	ld de,0e2bfh		;b70a
	call L_9D30		;b70d
	ld ix,0e2bfh		;b710
	ld (ix+000h),0c0h		;b714
	ld (ix+010h),001h		;b718
	ld (ix+011h),009h		;b71c
	ld hl,L_B7F1		;b720
	ld (ix+012h),l		;b723
	ld (ix+013h),h		;b726
	ld hl,0bab2h		;b729
	call L_B142		;b72c
	ld hl,0bacah		;b72f
	call L_B142		;b732
	ld de,0e26ah		;b735
	ld hl,0bc61h		;b738
	ld bc,0000ch		;b73b
	ldir		;b73e
	ld de,0e28eh		;b740
	ld hl,0ba46h		;b743
	ld bc,00004h		;b746
	ldir		;b749
	ld a,001h		;b74b
	ld (0e221h),a		;b74d
	ei			;b750
L_B751:
	ld ix,0e2bfh		;b751
	ld a,(ix+00bh)		;b755
	cp 007h		;b758
	jr c,L_B751		;b75a
	ld hl,0e132h		;b75c
	ld de,0e133h		;b75f
	ld (hl),000h		;b762
	ld bc,0017ch		;b764
	ldir		;b767
	ld hl,0e26ah		;b769
	ld de,01b00h		;b76c
	ld bc,00044h		;b76f
	call L_B1C3		;b772
	halt			;b775
	ld bc,0a201h		;b776
	call L_B17C		;b779
	ld hl,02000h		;b77c
	ld bc,01800h		;b77f
	ld a,011h		;b782
	call L_B1A7		;b784
	halt			;b787
	ld bc,00000h		;b788
	call L_B17C		;b78b
	ld bc,0e201h		;b78e
	call L_B17C		;b791
	ld bc,08003h		;b794
	call L_B17C		;b797
	ld bc,00004h		;b79a
	call L_B17C		;b79d
	di			;b7a0
	ret			;b7a1
L_B7A2:
	ld ix,0e2d5h		;b7a2
	set 0,(ix+016h)		;b7a6
	ld hl,0e2a2h		;b7aa
	ld (ix+014h),l		;b7ad
	ld (ix+015h),h		;b7b0
	ld (ix+000h),0c0h		;b7b3
	ld (ix+002h),001h		;b7b7
	ld hl,08243h		;b7bb
	ld (ix+012h),l		;b7be
	ld (ix+013h),h		;b7c1
	ld a,(0e247h)		;b7c4
	ld (0e189h),a		;b7c7
	ld a,001h		;b7ca
	ld (0e247h),a		;b7cc
	ld (ix+010h),001h		;b7cf
	ld (ix+011h),001h		;b7d3
	ld ix,0e2bfh		;b7d7
	ld hl,L_B9C8		;b7db
	ld (ix+012h),l		;b7de
	ld (ix+013h),h		;b7e1
	call L_AE46		;b7e4
	ld hl,0e345h		;b7e7
	ld (hl),001h		;b7ea
	xor a			;b7ec
	ld (0e1cbh),a		;b7ed
	ret			;b7f0
L_B7F1:
	ld ix,0e2bfh		;b7f1
	ld a,(ix+009h)		;b7f5
	and 007h		;b7f8
	jr z,L_B7FF		;b7fa
	jp L_B84B		;b7fc
L_B7FF:
	ld hl,0ba4ah		;b7ff
	ld de,0e132h		;b802
	ld bc,00058h		;b805
	ldir		;b808
	inc (ix+00ah)		;b80a
	ld e,(ix+00ah)		;b80d
	ld a,018h		;b810
	cp e			;b812
	jr nz,L_B833		;b813
	ld ix,0e2bfh		;b815
	ld hl,L_B8C3		;b819
	ld (ix+012h),l		;b81c
	ld (ix+013h),h		;b81f
	ld (ix+00bh),003h		;b822
	ld (ix+00fh),001h		;b826
	ld (ix+010h),001h		;b82a
	ld (ix+011h),005h		;b82e
	ret			;b832
L_B833:
	ld l,e			;b833
	ld h,000h		;b834
	add hl,hl			;b836
	add hl,hl			;b837
	add hl,hl			;b838
	ld de,020b8h		;b839
	add hl,de			;b83c
	ex de,hl			;b83d
	ld hl,0ba9ah		;b83e
	ld bc,00008h		;b841
	call L_B1C3		;b844
	ld ix,0e2bfh		;b847
L_B84B:
	ld e,(ix+00ah)		;b84b
	ld a,00bh		;b84e
	cp e			;b850
	jr nc,L_B85E		;b851
	ld iy,0e28eh		;b853
	ld (iy+003h),00fh		;b857
	inc (iy+001h)		;b85b
L_B85E:
	inc (ix+009h)		;b85e
	ld hl,0e132h		;b861
	ld de,00008h		;b864
	ld b,008h		;b867
L_B869:
	push bc			;b869
	push hl			;b86a
	ld b,00ah		;b86b
	or a			;b86d
	scf			;b86e
L_B86F:
	rr (hl)		;b86f
	push af			;b871
	add hl,de			;b872
	pop af			;b873
	djnz L_B86F		;b874
	pop hl			;b876
	inc hl			;b877
	pop bc			;b878
	djnz L_B869		;b879
	ld l,(ix+00ah)		;b87b
	ld h,000h		;b87e
	add hl,hl			;b880
	add hl,hl			;b881
	add hl,hl			;b882
	ld de,000b0h		;b883
	add hl,de			;b886
	ex de,hl			;b887
	ld hl,0e132h		;b888
	ld bc,00050h		;b88b
	call L_B1C3		;b88e
	ld a,(0e2c9h)		;b891
	cp 005h		;b894
	ret c			;b896
	ld a,(0e26bh)		;b897
	dec a			;b89a
	ld (0e26bh),a		;b89b
	cp 045h		;b89e
	jr c,L_B8A7		;b8a0
	ld hl,0e26dh		;b8a2
	ld (hl),005h		;b8a5
L_B8A7:
	add a,010h		;b8a7
	ld (0e26fh),a		;b8a9
	cp 045h		;b8ac
	jr c,L_B8B5		;b8ae
	ld hl,0e271h		;b8b0
	ld (hl),005h		;b8b3
L_B8B5:
	add a,010h		;b8b5
	ld (0e273h),a		;b8b7
	cp 045h		;b8ba
	ret c			;b8bc
	ld hl,0e275h		;b8bd
	ld (hl),005h		;b8c0
	ret			;b8c2
L_B8C3:
	ld ix,0e2bfh		;b8c3
	ld (ix+010h),006h		;b8c7
	bit 1,(ix+00bh)		;b8cb
	jr nz,L_B8DF		;b8cf
	ld hl,0bb01h		;b8d1
	call L_B142		;b8d4
	ld hl,0bb4ah		;b8d7
	call L_B142		;b8da
	jr L_B8EB		;b8dd
L_B8DF:
	ld hl,0bb95h		;b8df
	call L_B142		;b8e2
	ld hl,0bbfbh		;b8e5
	call L_B142		;b8e8
L_B8EB:
	ld ix,0e2bfh		;b8eb
	ld hl,001f0h		;b8ef
	ld e,(ix+00fh)		;b8f2
	ld d,000h		;b8f5
	or a			;b8f7
	sbc hl,de		;b8f8
	ld de,01800h		;b8fa
	add hl,de			;b8fd
	ex de,hl			;b8fe
	ld hl,0ba06h		;b8ff
	ld bc,(0e2ceh)		;b902
	ld b,000h		;b906
	call L_B1C3		;b908
	ld ix,0e2bfh		;b90b
	ld a,007h		;b90f
	sub (ix+00fh)		;b911
	ld e,a			;b914
	ld d,000h		;b915
	ld hl,0ba0dh		;b917
	add hl,de			;b91a
	ld de,019f0h		;b91b
	ld bc,(0e2ceh)		;b91e
	ld b,000h		;b922
	call L_B1C3		;b924
	ld ix,0e2bfh		;b927
	ld hl,00210h		;b92b
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
	call L_B1C3		;b944
	ld ix,0e2bfh		;b947
	ld a,007h		;b94b
	sub (ix+00fh)		;b94d
	ld e,a			;b950
	ld d,000h		;b951
	ld hl,0ba0dh		;b953
	add hl,de			;b956
	ld de,01a10h		;b957
	ld bc,(0e2ceh)		;b95a
	ld b,000h		;b95e
	call L_B1C3		;b960
	ld ix,0e2bfh		;b963
	bit 0,(ix+00bh)		;b967
	jr z,L_B990		;b96b
	inc (ix+00fh)		;b96d
	ld a,008h		;b970
	cp (ix+00fh)		;b972
	ret nz			;b975
	dec (ix+00fh)		;b976
	dec (ix+00bh)		;b979
	ld (ix+011h),050h		;b97c
	ld a,000h		;b980
	cp (ix+00bh)		;b982
	ret nz			;b985
	ld hl,L_B7A2		;b986
	ld (ix+012h),l		;b989
	ld (ix+013h),h		;b98c
	ret			;b98f
L_B990:
	dec (ix+00fh)		;b990
	ret nz			;b993
	ld (ix+00fh),001h		;b994
	dec (ix+00bh)		;b998
	ld (ix+011h),020h		;b99b
	ld hl,02800h		;b99f
	ld bc,01000h		;b9a2
	ld a,0a1h		;b9a5
	call L_B1A7		;b9a7
	ret			;b9aa
L_B9AB:
	push bc			;b9ab
	push de			;b9ac
	push hl			;b9ad
	ex de,hl			;b9ae
	add hl,hl			;b9af
	add hl,hl			;b9b0
	add hl,hl			;b9b1
	ld bc,00000h		;b9b2
	add hl,bc			;b9b5
	ex de,hl			;b9b6
	ld bc,00008h		;b9b7
	call L_B1C3		;b9ba
	pop hl			;b9bd
	ld de,00010h		;b9be
	add hl,de			;b9c1
	pop de			;b9c2
	inc de			;b9c3
	pop bc			;b9c4
	djnz L_B9AB		;b9c5
	ret			;b9c7
L_B9C8:
	ld ix,0e2bfh		;b9c8
	ld e,(ix+00bh)		;b9cc
	sla e		;b9cf
	ld d,000h		;b9d1
	ld hl,0b9e4h		;b9d3
	add hl,de			;b9d6
	ld a,(hl)			;b9d7
	ld (ix+011h),a		;b9d8
	inc hl			;b9db
	ld a,(hl)			;b9dc
	ld (0e259h),a		;b9dd
	inc (ix+00bh)		;b9e0
	ret			;b9e3

; ----------------------------------------------------------------------
; DATOS tabla_b9d3: Bytes que 0xB9D3 lee con el indice en DE (ld hl,0B9E4h / add hl,de) y guarda en IX+0x11. Acotada por la estructura siguiente, que empieza en 0xBA06
;   0xb9e4..0xba06  (34 bytes)
; DATOS filas_de_tiles_seguidos: Numeros de tile consecutivos (0A..17, dos veces y pico). B8FF copia desde 0xBA06 y B917 desde 0xBA0D, los dos con la longitud leida de la RAM (0xE2CE) y B1C3 a la VRAM
;   0xba06..0xba2d  (39 bytes)
; DATOS fila_texto_6: Veinticinco numeros de tile en crudo que 0xB6E2 copia con B1C3 a la VRAM 0x18C0, la fila 6 del name table, columnas 0-24
;   0xba2d..0xba46  (25 bytes)
; DATOS inicializador_e28e_b: Cuatro bytes que 0xB749 copia a 0xE28E
;   0xba46..0xba4a  (4 bytes)
; DATOS inicializador_e132: Ochenta y ocho bytes que 0xB808 copia a 0xE132
;   0xba4a..0xbaa2  (88 bytes)
; DATOS listas_nibble_espejo: Dos listas de 8 bytes, y la segunda es la primera CON LOS NIBBLES INTERCAMBIADOS (61->16, 91->19, B1->1B...). Consumidor sin encontrar: ni una instruccion trazada ni un puntero literal en toda la ROM apuntan aqui. Acotada por el inicializador que acaba en 0xBAA2 y el bloque RLE que empieza en 0xBAB2
;   0xbaa2..0xbab2  (16 bytes)
; DATOS graficos_rle_b7_sprites: Bloque RLE: 32 bytes a la VRAM 0x3FC0 (la pareja de sprites del modo). Lo carga 0xB729
;   0xbab2..0xbaca  (24 bytes)
; DATOS graficos_rle_b7_sprites2: Bloque RLE: 96 bytes a la VRAM 0x3800, los tres primeros patrones de sprite. Lo carga 0xB72F
;   0xbaca..0xbb01  (55 bytes)
; DATOS graficos_rle_tiles_v1a: Bloque RLE: 112 bytes (14 tiles) a la VRAM 0x0850, banco 1 de la tabla de patrones. Rama del bit 1 de IX+0x0B apagado; lo carga 0xB8D1
;   0xbb01..0xbb4a  (73 bytes)
; DATOS graficos_rle_tiles_v1b: Bloque RLE: 112 bytes a la VRAM 0x1050, los MISMOS tiles en el banco 2. Lo carga 0xB8D7
;   0xbb4a..0xbb95  (75 bytes)
; DATOS graficos_rle_tiles_v2a: Bloque RLE: 112 bytes a la VRAM 0x0850, la variante con el bit 1 de IX+0x0B encendido. Lo carga 0xB8DF
;   0xbb95..0xbbfb  (102 bytes)
; DATOS graficos_rle_tiles_v2b: Bloque RLE: 112 bytes a la VRAM 0x1050, y cierra EXACTO contra el inicializador de 0xBC61. Lo carga 0xB8E5
;   0xbbfb..0xbc61  (102 bytes)
; DATOS inicializador_e26a_b: Doce bytes que 0xB73E copia a 0xE26A
;   0xbc61..0xbc6d  (12 bytes)
; DATOS relleno: Los 915 bytes finales del cartucho, TODOS a 0x00 (comprobado byte a byte): relleno hasta completar los 16 KB
;   0xbc6d..0xc000  (915 bytes)
; ----------------------------------------------------------------------
	defb 048h,000h,03ah,008h,020h,018h,0bah,000h,010h,002h,040h,008h,0ffh,000h,0ffh,000h	; b9e4  H.:. .....@.....
	defb 0ffh,000h,001h,002h,003h,004h,005h,006h,007h,008h,000h,000h,000h,000h,000h,000h	; b9f4  ................
	defb 000h,000h,00ah,00bh,00ch,00dh,00eh,00fh,010h,011h,012h,013h,014h,015h,016h,017h	; ba04  ................
	defb 00ah,00bh,00ch,00dh,00eh,00fh,010h,011h,012h,013h,014h,015h,016h,017h,02ch,02ch	; ba14  ..............,,
	defb 02ch,02ch,02ch,02ch,02ch,02ch,02ch,02ch,02dh,022h,023h,024h,025h,026h,027h,028h	; ba24  ,,,,,,,,-"#$%&'(
	defb 029h,02ah,02bh,02ch,02dh,02eh,02fh,030h,031h,032h,033h,034h,035h,036h,037h,038h	; ba34  )*+,-./012345678
	defb 039h,03ah,02fh,000h,0f8h,000h,0feh,0fch,0f8h,0f0h,0e0h,0c0h,080h,000h,0c7h,0c0h	; ba44  9:/.............
	defb 0cfh,0cch,0cch,0cch,0cch,0cfh,0ffh,018h,099h,019h,019h,019h,019h,099h,0f8h,018h	; ba54  ................
	defb 098h,099h,09bh,09eh,09ch,098h,03fh,060h,0c0h,08ch,00ch,00ch,00ch,00ch,0ffh,000h	; ba64  ......?`........
	defb 0fch,0c0h,0fch,00ch,00ch,0fch,080h,000h,0cfh,0cch,0cch,0cch,0cch,0cfh,000h,000h	; ba74  ................
	defb 0cch,0ceh,0cfh,0cdh,0cch,0cch,000h,000h,060h,060h,060h,0e0h,0e0h,060h,000h,000h	; ba84  ........```..`..
	defb 000h,000h,000h,000h,000h,000h,060h,090h,0b0h,0a0h,0c0h,030h,050h,040h,061h,091h	; ba94  ......`....0P@a.
	defb 0b1h,0a1h,0c1h,031h,051h,041h,016h,019h,01bh,01ah,01ch,013h,015h,014h,0c0h,03fh	; baa4  ...1QA.........?
	defb 048h,001h,003h,006h,00ch,01fh,030h,060h,0c0h,008h,000h,043h,0c7h,0c0h,0cfh,004h	; bab4  H.....0`...C....
	defb 0cch,041h,0cfh,008h,000h,000h,000h,038h,047h,000h,07dh,04dh,07dh,061h,061h,061h	; bac4  .A.....8G.}M}aaa
	defb 00ah,000h,046h,0f7h,036h,0f7h,0e6h,0b6h,0b7h,00ah,000h,046h,0bdh,031h,03dh,00dh	; bad4  ..F.6......F.1=.
	defb 00dh,0bdh,00ah,000h,046h,0ech,08eh,0cfh,08fh,08dh,0ech,00ah,000h,041h,0dfh,005h	; bae4  ....F........A..
	defb 0c6h,00ah,000h,046h,0bch,030h,03ch,00ch,00ch,03ch,009h,000h,000h,050h,008h,010h	; baf4  ...F.0<..<...P..
	defb 000h,003h,07fh,005h,03fh,044h,0f8h,0fch,0feh,03fh,004h,01fh,044h,0fdh,0fdh,079h	; bb04  ....?D...?..D..y
	defb 079h,004h,078h,043h,0ffh,0ffh,0bdh,005h,03ch,05ah,0ffh,0ffh,0beh,0beh,03eh,03eh	; bb14  y.xC....<Z....>>
	defb 03fh,03fh,0f8h,0f9h,039h,01bh,003h,076h,0f6h,0ffh,0f3h,0fbh,0f9h,07dh,07dh,03dh	; bb24  ??..9..v.....}}=
	defb 03dh,0ffh,0f1h,0f1h,006h,0e0h,042h,0f8h,0f8h,006h,0f0h,041h,07dh,007h,07ch,043h	; bb34  =.....B....A}.|C
	defb 0dfh,095h,091h,00dh,000h,000h,050h,010h,010h,000h,006h,03fh,05bh,07fh,07fh,03fh	; bb44  ......P....?[..?
	defb 0feh,0fch,0f8h,000h,000h,080h,080h,078h,078h,0fch,0fch,0fch,000h,000h,000h,03ch	; bb54  .......xx......<
	defb 03ch,07eh,07eh,07eh,000h,000h,000h,03fh,005h,03eh,046h,07fh,07fh,0ffh,07fh,07ch	; bb64  <~~~...?.>F....|
	defb 03eh,004h,000h,044h,0ffh,0ffh,01fh,03fh,004h,000h,044h,0e0h,0e2h,0e7h,0ffh,004h	; bb74  >..D...?..D.....
	defb 000h,044h,0f0h,0f1h,0f3h,0ffh,004h,000h,005h,07ch,043h,000h,07ch,07ch,010h,000h	; bb84  .D.......|C.||..
	defb 000h,050h,008h,00bh,000h,065h,0f8h,0fch,06eh,066h,066h,000h,000h,000h,01ch,03eh	; bb94  .P...e..nff....>
	defb 03eh,036h,077h,000h,000h,000h,0e7h,0e7h,066h,066h,07eh,000h,000h,000h,07bh,07bh	; bba4  >6w.....ff~...{{
	defb 031h,031h,031h,000h,000h,000h,0e0h,0f0h,0b8h,098h,098h,078h,000h,000h,000h,007h	; bbb4  111........x....
	defb 00fh,01ch,018h,018h,000h,000h,000h,09fh,0dfh,0cch,00ch,00fh,000h,000h,000h,0c1h	; bbc4  ................
	defb 0e3h,0e3h,0e3h,0c7h,000h,000h,000h,0ceh,0efh,0e7h,067h,076h,000h,000h,000h,07bh	; bbd4  ..........gv...{
	defb 07bh,0b1h,0f1h,0f1h,000h,000h,000h,0f9h,0f9h,098h,080h,0e0h,000h,000h,080h,09eh	; bbe4  {...............
	defb 03fh,033h,030h,03eh,008h,000h,000h,050h,010h,008h,000h,078h,066h,066h,06eh,0fch	; bbf4  ?30>...P...xffn.
	defb 0f8h,000h,000h,000h,063h,07fh,07fh,0e3h,0f7h,000h,000h,000h,03ch,03ch,03ch,098h	; bc04  ....c.......<<<.
	defb 098h,000h,000h,000h,031h,031h,031h,07bh,07bh,000h,000h,000h,098h,098h,0b8h,0f0h	; bc14  ....111{{.......
	defb 0e0h,000h,000h,000h,018h,018h,01ch,00fh,007h,000h,000h,000h,00dh,00dh,0cch,0deh	; bc24  ................
	defb 09eh,000h,000h,000h,065h,086h,0c7h,0c7h,0eeh,0efh,000h,000h,000h,036h,0f6h,0f6h	; bc34  ....e........6..
	defb 03fh,07fh,000h,000h,000h,071h,031h,031h,07bh,07bh,000h,000h,000h,0e0h,080h,098h	; bc44  ?....q11{{......
	defb 0f8h,0f8h,000h,000h,000h,01fh,003h,033h,03fh,01eh,00bh,000h,000h,03ch,0ffh,000h	; bc54  .......3?....<..
	defb 000h,03ch,0ffh,004h,000h,03ch,0ffh,008h,000h,000h,000h,000h,000h,000h,000h,000h	; bc64  .<...<..........
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bc74  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bc84  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bc94  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bca4  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bcb4  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bcc4  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bcd4  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bce4  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bcf4  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bd04  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bd14  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bd24  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bd34  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bd44  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bd54  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bd64  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bd74  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bd84  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bd94  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bda4  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bdb4  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bdc4  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bdd4  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bde4  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bdf4  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; be04  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; be14  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; be24  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; be34  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; be44  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; be54  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; be64  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; be74  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; be84  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; be94  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bea4  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; beb4  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bec4  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bed4  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bee4  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bef4  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bf04  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bf14  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bf24  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bf34  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bf44  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bf54  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bf64  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bf74  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bf84  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bf94  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bfa4  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bfb4  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bfc4  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bfd4  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bfe4  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bff4  ............
