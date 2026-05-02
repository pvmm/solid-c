; Входящие функции:
;
;  movmem
;  memset
;  memcpy
;  memmove
;  memcmp
;




	MODULE	movmem
;
; "mem.h"
; Функция movmem копирует len байт из source в destin.
; Если исходная и результирующия строка перекрываются,
; копирование все-равно производится корректно.
;
; Функция setmem устанавливает первые len байт блока addr
; в значение value.
;
; void movmem(*source, *destin, len)
; void setmem(*addr, len, char value)
;
setmem_::
	ld	a,b
	or	c
	ret	z
	ld	(hl),e			; value
	ld	e,l
	ld	d,h
	inc	de
	dec	bc
movmem_::
	ld	a,b
	or	c
	ret	z
	ldir
	ret

	ENDMODULE


	MODULE	memset
;
; "mem.h"
; Функция заполняет первые count байт буфера dest символом "c".
; Функция возвращает указатель на буфер dest.
;
; void *memset(*dest, c, count)
;
memset_::
	push	hl
	call	setmem_##
	pop	hl			; вернуть адрес dest
	ret

	ENDMODULE


	MODULE	memcpy
;
; "mem.h"
; Функция копирует count байтов из source в dest.
; Если некоторые участки source и dest перекрываются, функция
; гарантирует, что байты из перекрываемого участка, принадле-
; жащие source, будут скопированы перед перезаписью.
; Функция возвращает указатель на dest.
;
; void *memcpy(*dest, *source, count)
;
memcpy_::
	ld	a,b
	or	c
	ret	z			; count = 0
	push	hl
	ex	de,hl
	ldir
	pop	hl			; вернуть адрес dest
	ret

	ENDMODULE


	MODULE	memmove
;
; "mem.h"
; Функция кoпируют count байтов из source в dest.
; Если некoтoрые oбласти в source и dest перекрываются, функция
; гарантирует, чтo исхoдные source байт из перекрывающейся oбласти
; будут скoпирoваны перед переписыванием.
; Функция возвращает указатель на dest.
;
; void *memmove(*dest, *source, count)
;
memmove_::
	ld	a,b
	or	c
	ret	z			; count = 0
	push	hl
	ex	de,hl
	ld	a,d
	cp	h
	jr	nz,@1
	ld	a,e
	cp	l
@1:	jr	nc,@2
	ldir
	pop	hl
	ret
@2:	add	hl,bc
	ex	de,hl
	add	hl,bc
	ex	de,hl
	lddr
	pop	hl
	ret

	ENDMODULE


	MODULE	memcmp
;
; "mem.h"
; Функция производит последовательное лексиграф. сравнение
; первых count байтов из buf1 и buf2, и продолжает это, пока
; они совпадают, либо пока не выполнится заданное количество
; сравнений count.
; Функция возвращает значение, указывающее на соотношение
; этих буферов:
;	< 0	buf1 < buf2
;	= 0	buf1 = buf2
;	> 0	buf1 > buf2
;
; int memcmp(*buf1, *buf2, count)
;
memcmp_::
	ld	a,(de)
	sub	(hl)
	jr	nz,@1
	inc	hl
	inc	de
	dec	bc
	ld	a,b
	or	c
	jp	nz,memcmp_
	ld	h,a			; hl = 0
	ld	l,a
	ret
@1:	ld	hl,1			; hl = 1
	ret	nc
	ld	hl,-1			; hl = -1
	ret

	ENDMODULE
