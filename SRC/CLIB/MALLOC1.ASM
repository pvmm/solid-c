; Входящие функции:
;
;  sbrk  (выдел. блока памяти между указ. своб. памяти "$MEMRY" и стеком)
;  brk
;  free
;  malloc
;  calloc
;  realoc
;





	MODULE	sbrk
;
; "malloc.h"
; Выделяет блок длиной n в пределях между указателем
; свободной памяти и указателем стека.
; Значение n может быть отрицательным, тогда количество
; захваченной памяти уменьшается на n байтов.
; При успешном выделении возвращает указатель на выде-
; ленный блок.
; Если памяти недостаточно, возвращает -1 (0FFFFh).
;
; in: hl = размер блока
; out: hl = указатель на выдел. блок, если Ok.
;      hl = -1 при недостатке памяти.
;
; char *sbrk(int n)
;
sbrk_::
	ld	de,($MEMRY)		; адрес указателя своб. памяти
	add	hl,de
	jr	c,sbrkerr		; переполн. числа
	call	brk_
	ld	a,h
	and	l
	inc	a
	ret	z			; ошибка
	ex	de,hl			; hl=начало выдел. блока
	ret

; Set free memory pointer.
; int brk(int n)
brk_::
	push	hl
	inc	h
	inc	h			; + 512 bytes reserved
	or	a
	sbc	hl,sp			; выделить память
	pop	hl
	jr	nc,sbrkerr		; мало памяти
	ld	($MEMRY),hl		; новое полож. указателя своб. памяти
	ret
	;
sbrkerr:ld	hl,-1			; EOF ошибка
	ret

; указатель начала свободной памяти (до стека)
$MEMRY::
	dw	0			; заполняется линкером!

	ENDMODULE


	MODULE	free
;
; "malloc.h", "stdlib.h"
; Функция освобождает блок памяти.
; Аргумент ptr указывает на ранее захваченный блок
; памяти посредством вызова malloc, calloc, realloc.
; Возвращаемого значения нет.
;
; void free(char *ptr)
;
free_::
	dec	hl
	dec	hl
	dec	hl
	dec	hl			; на начало заголовка блока
	ld	c,l
	ld	b,h
	ld	hl,(_alloc_)
	ld	(?49+1),hl
	ex	de,hl
@22:	ld	a,e
	sub	c
	ld	a,d
	sbc	a,b
	jr	nc,@19
	ld	l,e
	ld	h,d
	ld	a,c
	sub	(hl)
	inc	hl
	ld	a,b
	sbc	a,(hl)
	jr	c,@20
@19:	ld	l,e
	ld	h,d
	ld	a,e
	sub	(hl)
	inc	hl
	ld	a,d
	sbc	a,(hl)
	jr	c,@21
	ld	a,e
	sub	c
	ld	a,d
	sbc	a,b
	jr	c,@20
	ld	l,e
	ld	h,d
	ld	a,c
	sub	(hl)
	inc	hl
	ld	a,b
	sbc	a,(hl)
	jr	c,@20
@21:	ex	de,hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	(?49+1),de
	jr	@22
	;
@20:	ld	l,e
	ld	h,d
	ld	(?48+1),bc
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	push	bc
?48:	ld	bc,0			; сохр. значение
	ld	hl,2
	add	hl,bc
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	add	hl,hl			;1+1=2
	add	hl,hl			;2+2=4
	add	hl,bc
	ld	(?48+1),bc
	pop	bc
	push	de
	ld	a,l
	cp	c
	jr	nz,$+4
	ld	a,h
	cp	b
	jr	nz,@23
	ld	hl,(?48+1)
	push	hl
	inc	hl
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	push	hl
?49:	ld	hl,0			; сохр. значение
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	inc	hl
	inc	hl
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	add	hl,de
	ex	de,hl
	pop	hl
	ld	(hl),d
	dec	hl
	ld	(hl),e
	ld	hl,(?49+1)
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	pop	hl
	ld	(hl),c
	inc	hl
	ld	(hl),b
	jr	@24
	;
@23:	ex	de,hl
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	ld	hl,(?48+1)
	ld	(hl),c
	inc	hl
	ld	(hl),b
@24:	pop	de
	ld	hl,2
	add	hl,de
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	add	hl,hl
	add	hl,hl
	add	hl,de
	push	de
	ld	bc,(?48+1)
	ld	a,l
	cp	c
	jr	nz,$+4
	ld	a,h
	cp	b
	jr	nz,@25
	ld	hl,2
	add	hl,de
	push	de
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	push	hl
	ld	hl,2
	add	hl,bc
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	add	hl,de
	ex	de,hl
	pop	hl
	ld	(hl),d
	dec	hl
	ld	(hl),e
	ld	l,c
	ld	h,b
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	pop	de
	ex	de,hl
	ld	(hl),c
	inc	hl
	ld	(hl),b
	jr	@26
	;
@25:	ex	de,hl
	ld	(hl),c
	inc	hl
	ld	(hl),b
@26:	pop	hl
	ld	(_alloc_),hl
	ret

; ячейка адреса выдел. блока памяти
_alloc_::
	dw	0

	dseg
; структура заголовка блока
_base_::
	dw	0			; addr next free block
	dw	0			; size of this free block

	ENDMODULE


	MODULE	malloc
;
; "malloc.h", "stdlib.h"
; Функция захватывает блок памяти размером в size байтов.
; Функция возвращает указатель на выделенный блок памяти.
; Если свободной памяти недостаточно, возвращается NULL.
;
; char *malloc(int size)
;
malloc_::
	inc	hl
	inc	hl
	inc	hl
	srl	h			; hl/4
	rr	l
	srl	h
	rr	l
	inc	hl
	ld	(units+1),hl		; размер нового блока
	ld	hl,(_alloc_##)
	ld	a,l
	or	h
	jr	nz,@0
	ld	(_base_##+2),hl		; сбр. размер выдел. блока
	ld	hl,_base_##		; структура заголовка блока
	ld	(_alloc_##),hl		; адрес выдел. блока
	ld	(_base_##),hl		; адрес след. заголовка
	;
@0:	ld	(prev+1),hl
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	ld	(tp+1),hl		; hl=_base_
@3:	ld	hl,(tp+1)
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	ld	a,l
	cp	c
	jp	nz,@1
	ld	a,h
	cp	b
	jp	z,@1
	inc	hl
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	add	hl,hl			; *4
	add	hl,hl			;
	ex	de,hl
	ld	hl,(tp+1)
	add	hl,de
	ld	a,l
	cp	c
	jp	nz,@1
	ld	a,h
	cp	b
	jp	nz,@1
	ld	hl,(tp+1)
	ld	e,l;
	ld	d,h;
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	ld	hl,(_alloc_##)
	ld	a,l
	cp	c
	jr	nz,@2
	ld	a,h
	cp	b
	jr	nz,@2
	;ld	hl,(tp+1)
	ld	l,e;
	ld	h,d;
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	ld	(_alloc_##),hl
@2:	;ld	hl,(tp+1)
	ex	de,hl;
	ld	c,l;
	ld	b,h;
	inc	hl
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	push	hl
	;ld	hl,(tp+1)
	ld	l,c;
	ld	h,b;
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	inc	hl
	inc	hl
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	add	hl,de
	ex	de,hl
	pop	hl
	ld	(hl),d
	dec	hl
	ld	(hl),e
	;ld	hl,(tp+1)
	ld	l,c;
	ld	h,b;
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	;ld	c,(hl)
	;inc	hl
	;ld	b,(hl)
	;ld	hl,(tp+1)
	;ld	(hl),c
	;inc	hl
	;ld	(hl),b
	ld	a,(hl);
	ld	(bc),a;
	inc	hl;
	inc	bc;
	ld	a,(hl);
	ld	(bc),a;
	jp	@3
	;
@1:	ld	hl,(tp+1)
	inc	hl
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
units:	ld	hl,0			; размер нового блока
	ld	a,c
	sub	l
	ld	a,b
	sbc	a,h
	jp	c,@4
	ld	hl,(tp+1)
	ld	e,l;
	ld	d,h;
	inc	hl
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	ld	hl,(units+1)		; размер нового блока
	ld	a,c
	cp	l
	jr	nz,@5
	ld	a,b
	cp	h
	jr	nz,@5
	;ld	hl,(tp+1)
	ex	de,hl;
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
prev:	ld	hl,0			; сохр. значение
	ld	(hl),c
	inc	hl
	ld	(hl),b
	jp	@6
	;
@5:	;ld	hl,(units+1)		; hl=(units+1) размер нового блока
	add	hl,hl
	add	hl,hl
	ex	de,hl
	;ld	hl,(tp+1)
	add	hl,de
	ld	(_alloc_##),hl
	ex	de,hl
	ld	hl,(prev+1)
	ld	(hl),e
	inc	hl
	ld	(hl),d
	ld	hl,(tp+1)
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	;ld	hl,(_alloc_##)
	ex	de,hl;
	ld	(hl),c
	inc	hl
	ld	(hl),b
	;ld	hl,(tp+1)
	;inc	hl
	ex	de,hl;
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	;ld	hl,(units+1)		; размер нового блока
	ld	de,(units+1)
	ld	a,c
	sub	e ;l
	ld	c,a
	ld	a,b
	sbc	a,d ;h
	ld	b,a
	ld	hl,(_alloc_##)
	inc	hl
	inc	hl
	ld	(hl),c
	inc	hl
	ld	(hl),b
	;ld	de,(units+1)		; размер нового блока
	ld	hl,(tp+1)
	inc	hl
	inc	hl
	ld	(hl),e
	inc	hl
	ld	(hl),d
@6:	ld	hl,(prev+1)
	ld	(_alloc_##),hl
tp:	ld	hl,0			; сохр. значение
	ld	(hl),0
	inc	hl
	ld	(hl),0
	inc	hl
	inc	hl
	inc	hl			; перейти на выдел. блок
	ret
	;
@4:	ld	de,(tp+1)
	ld	hl,(_alloc_##)
	ld	a,e
	cp	l
	jr	nz,@7
	ld	a,d
	cp	h
	jr	nz,@7
	ld	hl,512
	call	sbrk_##
	ld	(tp+1),hl
	ld	a,l
	and	h
	inc	a
	jr	nz,@8
	inc	hl			; NULL
	ret
	;
@8:	ld	(hl),0
	inc	hl
	ld	(hl),0
	inc	hl
	ld	(hl),128		; 512/sizeof(FREE)
	inc	hl
	ld	(hl),0
	inc	hl
	call	free_##
	ld	hl,(_alloc_##)
	ld	(tp+1),hl
@7:	ld	hl,(tp+1)
	ld	(prev+1),hl
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	ld	(tp+1),hl
	jp	@3

	ENDMODULE


	MODULE	calloc
;
; "malloc.h", "stdlib.h"
; Функция захватывает пространство для хранения массива из n элементов,
; каждый размером size байт. Каждый элемент инициализируется в 0.
; Функция возвращает указатель на захваченное пространство.
; Если недостаточно памяти, возвращается значение NULL.
;
; char *calloc(int n, int size)
;
calloc_::
	call	?MULHD##		; n * size = размер всего массива
	ld	(@34+1),hl
	call	malloc_##		; выделить память
	ld	a,l
	or	h
	ret	z			; недостаточно памяти (hl=NULL)
@34:	ld	bc,0			; сохр. размер массива
	ld	(hl),0			; байт заполнения
	push	hl
	ld	d,h
	ld	e,l
	inc	de
	dec	bc
	ldir
	pop	hl			; Ok
	ret

	ENDMODULE


	MODULE	realloc
;
; "malloc.h"
; Функция изменяет размер ранее выделенного блока памяти.
; Аргумент ptr указывает на начало блока. Аргумент size задает новый
; размер блока в байтах. Содержимое блока не изменяется.
; Если size равен 0, блок освобождается и возвращается NULL.
; Если ptr равен NULL, то отводится (по malloc) size байтов памяти
; и возвращается указатель на этот блок.
; Аргумент ptr может указывать на блок, который должен быть освобожден
; прежде, чем последуют вызовы malloc, calloc, realloc.
; Функция возвращает указатель на перезахваченный блок памяти.
; Блок может быть передвинут, если его размеры изменены, поэтому аргу-
; мент ptr для функции realloc не обязательно должен быть таким же,
; как и возвращаемое значение.
; Возвращается значение NULL, если памяти недостаточно для расширения
; блока к заданному размеру. При этом первоначальный блок остается
; неизменным.
;
; char *realloc(*ptr, int size);
;
realloc_::
	ld	a,l
	or	h
	jr	nz,@0			; *ptr != NULL
	ex	de,hl
	jp	malloc_##
	;
@0:	ld	a,e
	or	d
	jr	nz,@1			; size != 0
	call	free_##
	ld	hl,0			; NULL
	ret
	;
@1:	push	hl			; *ptr
	dec	hl
	ld	a,(hl)
	dec	hl
	ld	l,(hl)			; hl=размер блока ptr
	ld	h,a
	add	hl,hl			;
	add	hl,hl			; *4
	dec	hl
	dec	hl
	dec	hl
	dec	hl
	ld	(osize+1),hl
	pop	hl
	push	de			; size
	push	hl			; ptr
	push	de
	call	free_##
	pop	hl			; size
	call	malloc_##
	ld	(@3+1),hl		; новый блок
	pop	de			; ptr
	pop	bc			; size
	ld	a,l
	or	h
	jr	z,@3			; ошибка
	; alloc != ptr
	ld	a,l
	cp	e
	jr	nz,osize
	ld	a,h
	cp	d
	jr	z,@3
osize:	ld	hl,0			; сохр. значение
	; size > osize ?
	ld	a,l
	sub	c
	ld	a,h
	sbc	a,b
	jr	nc,@2			; osize > size
	ld	c,l			; bc=osize
	ld	b,h
@2:	ex	de,hl			; hl = *ptr
	ld	de,(@3+1)
	call	movmem_##		; hl=from, de=to, bc=size
@3:	ld	hl,0			; сохр. указатель на новый блок
	ret

	ENDMODULE
